"""Standalone sprite keyframe and hitbox editor for Project Holo."""
import argparse
import json
import math
import os
from pathlib import Path
import tempfile
from time import perf_counter
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

from PIL import Image, ImageTk

from animation_editor_lua import Box, PIXELS_PER_UNIT, Script


ROOT = Path(__file__).resolve().parents[1]
KIARA = ROOT / "assets/animation/kiara/kiara.lua"
PLAYBACK_FPS = 60


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def load_project(lua_path, atlas_path=None, texture_path=None, prefab_path=None):
    raw = lua_path.read_bytes()
    script = Script(raw.decode("utf-8-sig"))
    if not script.states:
        raise ValueError("No literal states.name = {...} tables found.")
    rows = read_json(ROOT / "assets/datatables/assetPathDataTable.json")["rows"]
    paths = {row["rowId"]: ROOT / row["assetPath"] for row in rows}
    atlas_path = atlas_path or paths.get(script.atlas_id)
    if atlas_path is None or not atlas_path.is_file():
        atlas_path = Path(filedialog.askopenfilename(
            title="Choose sprite atlas JSON", filetypes=[("JSON", "*.json")]))
        if not atlas_path.is_file():
            raise ValueError("Choose the sprite atlas JSON to open this script.")
    atlas = read_json(atlas_path)
    texture_path = texture_path or paths.get(atlas.get("spriteAsset"), atlas_path.with_suffix(".png"))
    if not texture_path.is_file():
        texture_path = Path(filedialog.askopenfilename(
            title="Choose atlas texture", filetypes=[("Images", "*.png *.jpg *.webp")]))
        if not texture_path.is_file():
            raise ValueError("Choose the atlas texture to open this script.")
    with Image.open(texture_path) as image:
        texture = image.convert("RGBA")
    sprites = {entry["spriteId"]: entry for entry in atlas["sprites"]}
    if not sprites:
        raise ValueError("The atlas has no sprites.")

    prefab = prefab_path or ROOT / "assets/prefabs/characters" / lua_path.stem / (lua_path.stem + ".json")
    defaults, default_sprite = {}, ""
    if prefab_path or prefab.is_file():
        for component in read_json(prefab)["components"]:
            data = component["data"]
            if component.get("componentName") == "sprite":
                default_sprite = data.get("defaultSprite", "")
            if component.get("componentName") == "hitbox":
                for entry in data["hitboxes"]:
                    point, size = entry["position"], entry["size"]
                    box = Box(entry["name"], entry["type"], (point["x"], point["y"], size["x"], size["y"]),
                              entry.get("active", False))
                    defaults[box.name] = box
    return raw, script, texture, sprites, defaults, default_sprite


def write_script(path, expected, source):
    if path.read_bytes() != expected:
        raise ValueError("The Lua file changed on disk. Copy your draft and reopen the file before writing.")
    bom = b"\xef\xbb\xbf" if expected.startswith(b"\xef\xbb\xbf") else b""
    raw = bom + source.encode("utf-8")
    with tempfile.NamedTemporaryFile(dir=path.parent, prefix=path.name + ".", delete=False) as stream:
        temporary = Path(stream.name)
        try:
            stream.write(raw)
        except OSError:
            stream.close()
            temporary.unlink()
            raise
    try:
        if path.read_bytes() != expected:
            raise ValueError("The Lua file changed on disk while preparing the write.")
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)
    return raw


class Editor:
    def __init__(self, root):
        self.root = root
        self.path = None
        self.frame = 0
        self.zoom = 3
        self.photo = None
        self.photo_key = None
        self.play_timer = None
        self.loop = tk.BooleanVar(value=True)
        self.drag = None
        self.draft = {}
        self.sprite = tk.StringVar()
        self.state_name = tk.StringVar()
        self.frame_text = tk.StringVar(value="0")
        self.status = tk.StringVar(value="Open a character Lua script.")
        self.name = tk.StringVar()
        self.kind = tk.StringVar(value="Hitbox")
        self.active = tk.BooleanVar(value=True)
        self.coordinates = [tk.StringVar(value="0") for _ in range(4)]
        self.frame_label = tk.StringVar()
        self.selected_box = None
        self.baseline_sprite = ""

        root.title("Project Holo Animation Editor")
        root.geometry("1180x760")
        root.minsize(900, 580)
        root.protocol("WM_DELETE_WINDOW", self.close)
        top = ttk.Frame(root, padding=8)
        top.pack(fill="x")
        ttk.Button(top, text="Open Lua…", command=self.open_dialog).pack(side="left")
        ttk.Label(top, text="State").pack(side="left", padx=(14, 4))
        self.state_picker = ttk.Combobox(top, textvariable=self.state_name, state="readonly", width=30)
        self.state_picker.pack(side="left")
        self.state_picker.bind("<<ComboboxSelected>>", self.change_state)
        ttk.Label(top, text="Frame").pack(side="left", padx=(14, 4))
        frame_input = ttk.Entry(top, textvariable=self.frame_text, width=7)
        frame_input.pack(side="left")
        frame_input.bind("<Return>", lambda _event: self.go_to_frame())
        ttk.Button(top, text="Go", width=4, command=self.go_to_frame).pack(side="left", padx=4)
        ttk.Label(top, textvariable=self.frame_label).pack(side="left", padx=5)

        workspace = ttk.Panedwindow(root, orient="horizontal")
        workspace.pack(fill="both", expand=True, padx=8)
        timeline = ttk.Frame(workspace, padding=6, width=162)
        preview = ttk.Frame(workspace)
        inspector = ttk.Frame(workspace, padding=8, width=330)
        workspace.add(timeline, weight=0)
        workspace.add(preview, weight=1)
        workspace.add(inspector, weight=0)

        ttk.Label(timeline, text="Keyframes").pack(anchor="w")
        self.keys = tk.Listbox(timeline, width=23, exportselection=False)
        self.keys.pack(fill="both", expand=True, pady=(5, 0))
        self.keys.bind("<<ListboxSelect>>", self.pick_key)

        controls = ttk.Frame(preview, padding=5)
        controls.pack(fill="x")
        self.play_button = ttk.Button(controls, text="Play", width=7, command=self.toggle_playback)
        self.play_button.pack(side="left")
        self.play_button.state(["disabled"])
        ttk.Checkbutton(controls, text="Loop", variable=self.loop).pack(side="left", padx=(5, 14))
        ttk.Label(controls, text="Zoom").pack(side="left", padx=(0, 4))
        ttk.Button(controls, text="−", width=3, command=lambda: self.zoom_by(-1)).pack(side="left")
        ttk.Button(controls, text="+", width=3, command=lambda: self.zoom_by(1)).pack(side="left", padx=4)
        self.canvas = tk.Canvas(preview, bg="#202630", highlightthickness=0, width=480, height=450)
        self.canvas.pack(fill="both", expand=True)
        self.canvas.bind("<Configure>", lambda _event: self.redraw())
        self.canvas.bind("<MouseWheel>", lambda event: self.zoom_by(1 if event.delta > 0 else -1))
        self.canvas.bind("<ButtonPress-1>", self.start_drag)
        self.canvas.bind("<B1-Motion>", self.draw_drag)
        self.canvas.bind("<ButtonRelease-1>", self.finish_drag)

        ttk.Label(inspector, text="Sprite ID").pack(anchor="w")
        self.sprite_picker = ttk.Combobox(inspector, textvariable=self.sprite, width=32)
        self.sprite_picker.pack(fill="x", pady=(3, 8))
        self.sprite_picker.bind("<<ComboboxSelected>>", lambda _event: self.redraw())
        self.sprite_picker.bind("<KeyRelease>", self.filter_sprites)

        ttk.Label(inspector, text="Hitboxes and hurtboxes").pack(anchor="w")
        self.boxes = tk.Listbox(inspector, exportselection=False, height=8)
        self.boxes.pack(fill="x", pady=(3, 6))
        self.boxes.bind("<<ListboxSelect>>", self.pick_box)
        ttk.Label(inspector, text="Box name and type").pack(anchor="w")
        name_row = ttk.Frame(inspector)
        name_row.pack(fill="x")
        self.name_entry = ttk.Entry(name_row, textvariable=self.name, width=18)
        self.name_entry.pack(side="left", fill="x", expand=True)
        ttk.Combobox(name_row, textvariable=self.kind, values=("Hitbox", "Hurtbox"),
                     state="readonly", width=9).pack(side="left", padx=(5, 0))
        ttk.Checkbutton(inspector, text="Active on this frame", variable=self.active).pack(anchor="w", pady=5)
        bounds = ttk.Frame(inspector)
        bounds.pack(fill="x")
        for index, (label, value) in enumerate(zip(("X", "Y", "Width", "Height"), self.coordinates)):
            bounds.columnconfigure(index, weight=1)
            ttk.Label(bounds, text=label).grid(row=0, column=index, sticky="w")
            ttk.Entry(bounds, textvariable=value, width=7).grid(row=1, column=index, sticky="ew", padx=(0, 3))
        ttk.Button(inspector, text="Apply box values", command=self.apply_box).pack(fill="x", pady=5)
        ttk.Button(inspector, text="New box", command=self.new_box).pack(fill="x")

        ttk.Separator(inspector).pack(fill="x", pady=12)
        ttk.Button(inspector, text="Copy keyframe Lua", command=lambda: self.export(False)).pack(fill="x")
        ttk.Button(inspector, text="Write keyframe to Lua…", command=lambda: self.export(True)).pack(fill="x", pady=5)
        ttk.Button(inspector, text="Copy prefab box component", command=self.copy_component).pack(fill="x")
        ttk.Label(root, textvariable=self.status, padding=8, wraplength=850).pack(fill="x")
        self.playback_edit_controls = [frame_input] + [
            widget for parent in (inspector, name_row, bounds) for widget in parent.winfo_children()
            if isinstance(widget, (ttk.Button, ttk.Entry, ttk.Checkbutton))
        ]

    def dirty(self):
        return bool(self.draft) or self.sprite.get() != self.baseline_sprite

    def may_leave(self):
        return not self.dirty() or messagebox.askyesno(
            "Discard frame draft?", "Leave this frame and discard the current draft?")

    def close(self):
        if self.may_leave():
            self.pause_playback()
            self.root.destroy()

    def open_dialog(self):
        self.pause_playback()
        if not self.may_leave():
            return
        path = filedialog.askopenfilename(initialdir=ROOT / "assets/animation",
                                          filetypes=[("Lua scripts", "*.lua")])
        if path:
            self.open(Path(path))

    def open(self, path, atlas=None, texture=None, prefab=None):
        self.pause_playback()
        try:
            project = load_project(path, atlas, texture, prefab)
        except (OSError, ValueError, KeyError, TypeError) as error:
            messagebox.showerror("Open animation", str(error))
            return
        self.raw, self.script, self.texture, self.sprites, self.defaults, self.default_sprite = project
        self.authored_types = {}
        self.photo_key = None
        self.path = path
        self.sprite_picker["values"] = tuple(sorted(self.sprites))
        self.state_picker["values"] = tuple(self.script.states)
        name = next((state.name for state in self.script.states.values() if state.keys), next(iter(self.script.states)))
        self.select_state(name)
        self.play_button.state(["!disabled"])
        self.root.title(f"Project Holo Animation Editor — {path.name}")

    def select_state(self, name):
        self.state_name.set(name)
        self.state = self.script.states[name]
        self.refresh_keys()
        self.load_frame(0)

    def change_state(self, _event):
        self.pause_playback()
        if self.may_leave():
            self.select_state(self.state_name.get())
        else:
            self.state_name.set(self.state.name)

    def go_to_frame(self):
        if self.path is None:
            return
        requested_frame = self.frame_text.get()
        self.pause_playback()
        try:
            index = int(requested_frame)
            if index < 0 or index > 2147483647:
                raise ValueError
        except ValueError:
            self.status.set("Enter a nonnegative 32-bit frame index.")
            return
        if index != self.frame and self.may_leave():
            self.load_frame(index)
        self.frame_text.set(str(self.frame))

    def pick_key(self, _event):
        selection = self.keys.curselection()
        if selection:
            self.frame_text.set(str(self.key_indices[selection[0]]))
            self.go_to_frame()
            self.highlight_frame()

    def highlight_frame(self):
        self.keys.selection_clear(0, "end")
        if self.frame in self.key_indices:
            index = self.key_indices.index(self.frame)
            self.keys.selection_set(index)
            self.keys.see(index)

    def preview_frame(self, frame):
        self.frame = frame
        self.frame_text.set(str(frame))
        self.baseline_sprite, self.base_boxes = self.script.preview(
            self.state, frame, self.defaults, self.default_sprite)
        self.sprite.set(self.baseline_sprite)
        for name, kind in self.authored_types.items():
            if name in self.base_boxes:
                box = self.base_boxes[name]
                self.base_boxes[name] = Box(name, kind, box.bounds, box.active)
        self.highlight_frame()
        label = "Existing keyframe" if frame in self.state.occupied else "New keyframe"
        if self.state.max_frames:
            label += f" · maxFrames {self.state.max_frames}"
        self.frame_label.set(label)

    def refresh_keys(self):
        self.key_indices = sorted(self.state.occupied)
        self.keys.delete(0, "end")
        for index in self.key_indices:
            callback = self.state.keys.get(index)
            sprite = callback.sprite if callback else ""
            self.keys.insert("end", f"{index}  {sprite or '(callback)'}")

    def load_frame(self, frame):
        self.draft.clear()
        self.preview_frame(frame)
        self.reset_box_selection()
        self.sprite_picker["values"] = tuple(sorted(self.sprites))
        self.status.set(f"{self.path.name} · {len(self.sprites)} atlas sprites")
        self.refresh_boxes()

    def toggle_playback(self):
        if self.play_timer is not None:
            self.pause_playback()
            return
        if self.path is None or not self.may_leave():
            return
        self.play_length = max(1, self.state.max_frames, max(self.key_indices, default=0) + 1)
        self.play_start_frame = self.frame if self.frame < self.play_length - 1 else 0
        self.play_cycle = 0
        self.load_frame(self.play_start_frame)
        self.play_button.configure(text="Pause")
        self.set_editing_enabled(False)
        self.status.set("Playing at 60 FPS. Pause to edit the current frame.")
        self.play_started = perf_counter()
        self.play_timer = self.root.after(16, self.advance_playback)

    def advance_playback(self):
        elapsed = perf_counter() - self.play_started
        index = self.play_start_frame + int(elapsed * PLAYBACK_FPS)
        cycle, frame = divmod(index, self.play_length)
        if not self.loop.get() and cycle > self.play_cycle:
            self.preview_frame(self.play_length - 1)
            self.pause_playback()
            return
        self.play_cycle = cycle
        if frame != self.frame:
            self.preview_frame(frame)
            self.refresh_boxes()
        self.play_timer = self.root.after(8, self.advance_playback)

    def pause_playback(self):
        if self.play_timer is None:
            return
        self.root.after_cancel(self.play_timer)
        self.play_timer = None
        self.play_button.configure(text="Play")
        self.set_editing_enabled(True)
        self.load_frame(self.frame)

    def set_editing_enabled(self, enabled):
        for widget in self.playback_edit_controls:
            widget.state(["!disabled" if enabled else "disabled"])

    def filter_sprites(self, event):
        query = self.sprite.get().casefold()
        self.sprite_picker["values"] = tuple(key for key in sorted(self.sprites) if query in key.casefold())
        self.redraw()

    def zoom_by(self, amount):
        self.zoom = min(12, max(1, self.zoom + amount))
        self.redraw()

    def origin(self):
        return self.canvas.winfo_width() // 2, int(self.canvas.winfo_height() * .70)

    def redraw(self):
        self.canvas.delete("all")
        if self.path is None:
            return
        ox, oy = self.origin()
        width, height = self.canvas.winfo_width(), self.canvas.winfo_height()
        step = PIXELS_PER_UNIT * self.zoom
        for x in range(ox % step, width, step):
            self.canvas.create_line(x, 0, x, height, fill="#343d49")
        for y in range(oy % step, height, step):
            self.canvas.create_line(0, y, width, y, fill="#343d49")
        self.canvas.create_line(0, oy, width, oy, fill="#748294")
        self.canvas.create_line(ox, 0, ox, height, fill="#748294")
        sprite = self.sprites.get(self.sprite.get())
        if sprite:
            x, y = sprite["point"]["x"], sprite["point"]["y"]
            w, h = sprite["size"]["x"], sprite["size"]["y"]
            pivot = sprite["pivot"]
            photo_key = (self.sprite.get(), self.zoom)
            if photo_key != self.photo_key:
                crop = self.texture.crop((x, y, x + w, y + h))
                self.photo = ImageTk.PhotoImage(crop.resize((w * self.zoom, h * self.zoom), Image.Resampling.NEAREST))
                self.photo_key = photo_key
            self.canvas.create_image(ox - pivot["x"] * self.zoom, oy - pivot["y"] * self.zoom,
                                     anchor="nw", image=self.photo)
        else:
            self.canvas.create_text(12, 12, anchor="nw", fill="#e1e8f0",
                                    text="Choose a sprite ID from the atlas.")
        for box in (self.base_boxes | self.draft).values():
            if min(box.bounds[2:]) <= 0:
                continue
            color = "#ff7373" if box.kind == "Hitbox" else "#67c7ff"
            left, top, right, bottom = box.rectangle((ox, oy), self.zoom)
            self.canvas.create_rectangle(left, top, right, bottom, outline=color,
                                         width=3 if box.name == self.selected_box else 1,
                                         dash=() if box.active else (5, 4))
            self.canvas.create_text(left + 3, top + 2, text=box.name, fill=color, anchor="nw")
        self.canvas.create_line(ox - 5, oy, ox + 5, oy, fill="white")
        self.canvas.create_line(ox, oy - 5, ox, oy + 5, fill="white")

    def new_box(self):
        self.reset_box_selection()
        self.redraw()

    def reset_box_selection(self):
        self.selected_box = None
        self.boxes.selection_clear(0, "end")
        self.name.set("")
        self.kind.set("Hitbox")
        self.active.set(True)
        for value in self.coordinates:
            value.set("0")

    def refresh_boxes(self):
        boxes = self.base_boxes | self.draft
        self.box_names = sorted(boxes)
        self.boxes.delete(0, "end")
        for index, name in enumerate(self.box_names):
            box = boxes[name]
            self.boxes.insert("end", f"{name}  ·  {box.kind}  ·  {'on' if box.active else 'off'}")
            if name == self.selected_box:
                self.boxes.selection_set(index)
        self.redraw()

    def pick_box(self, _event):
        if self.play_timer is not None:
            return
        selection = self.boxes.curselection()
        if not selection:
            return
        self.selected_box = self.box_names[selection[0]]
        box = self.draft.get(self.selected_box) or self.base_boxes[self.selected_box]
        self.name.set(box.name)
        self.kind.set(box.kind)
        self.active.set(box.active)
        for field, number in zip(self.coordinates, box.bounds):
            field.set(format(number, ".15g"))
        self.redraw()

    def start_drag(self, event):
        if self.path is None or self.play_timer is not None:
            return
        if not self.name.get().strip():
            self.status.set("Enter a box name or select an existing box, then drag to set its bounds.")
            self.name_entry.focus_set()
            return
        self.drag = (event.x, event.y)

    def draw_drag(self, event):
        if self.drag is not None:
            self.canvas.delete("drag")
            self.canvas.create_rectangle(*self.drag, event.x, event.y, outline="white", dash=(4, 3), tags="drag")

    def finish_drag(self, event):
        if self.drag is None:
            return
        bounds = Box.from_rectangle(self.drag, (event.x, event.y), self.origin(), self.zoom)
        self.drag = None
        self.canvas.delete("drag")
        if min(bounds[2:]) > 0:
            for field, number in zip(self.coordinates, bounds):
                field.set(str(number))
            self.apply_box()

    def apply_box(self):
        if self.path is None:
            return
        try:
            name = self.name.get().strip()
            if not name or any(ord(char) < 32 for char in name):
                raise ValueError("Enter a box name.")
            bounds = tuple(float(value.get()) for value in self.coordinates)
            if (not all(math.isfinite(v) and abs(v) <= 1e30 for v in bounds)
                    or min(bounds[2:]) < 0):
                raise ValueError("Use finite coordinates and nonnegative width and height.")
        except ValueError as error:
            self.status.set(str(error))
            return
        existing = self.defaults.get(name)
        kind = existing.kind if existing else self.kind.get()
        self.kind.set(kind)
        self.draft[name] = Box(name, kind, bounds, self.active.get())
        self.selected_box = name
        self.refresh_boxes()
        if name in self.defaults:
            self.status.set(f"Updated {name} in the frame draft.")
        else:
            self.status.set(f"{name} needs a matching prefab definition. Use Copy prefab box component.")

    def copy(self, value):
        self.root.clipboard_clear()
        self.root.clipboard_append(value)

    def export(self, write):
        if self.path is None:
            return
        try:
            sprite = self.sprite.get().strip()
            if sprite and sprite not in self.sprites and sprite != self.baseline_sprite:
                raise ValueError("Choose a valid atlas sprite ID.")
            callback = self.state.keys.get(self.frame)
            sprite_edit = sprite if sprite != self.baseline_sprite or callback is None else ""
            if not sprite_edit and not self.draft and callback is None:
                raise ValueError("Choose a sprite or add a box for the new keyframe.")
            boxes = {name: self.base_boxes[name] for name in sorted(self.script.managed_names(callback))
                     if name in self.base_boxes}
            boxes.update(self.draft)
            source, entry = self.script.edit(self.state, self.frame, sprite_edit, boxes if self.draft else {})
            if not write:
                self.copy(entry)
                if self.state.table < 0:
                    self.status.set("Copied a keyFrames field. Paste it inside the state table.")
                else:
                    self.status.set("Copied Lua. Replace this frame entry or paste it into the state's keyFrames table.")
                return
            if source == self.script.source:
                self.status.set("No keyframe changes to write.")
                return
            updated = Script(source)
            if self.frame not in updated.states[self.state.name].keys:
                raise ValueError("The edited keyframe could not be read back.")
            if not messagebox.askyesno("Write keyframe?", f"Write {self.state.name} frame {self.frame} to {self.path.name}?"):
                return
            self.raw = write_script(self.path, self.raw, source)
            self.script = updated
            self.state = updated.states[self.state.name]
            self.refresh_keys()
            undefined = sorted(self.draft.keys() - self.defaults.keys())
            self.authored_types.update({name: boxes[name].kind for name in undefined})
            self.load_frame(self.frame)
            self.status.set("Wrote keyframe." + (f" Add prefab definitions for {', '.join(undefined)}." if undefined else ""))
        except (OSError, ValueError) as error:
            messagebox.showerror("Export keyframe", str(error))

    def copy_component(self):
        if self.path is None:
            return
        boxes = self.defaults | self.base_boxes | self.draft
        if not boxes:
            self.status.set("Draw or apply a named box first.")
            return
        definitions = []
        for name, box in sorted(boxes.items()):
            initial = self.defaults.get(name, box)
            x, y, width, height = initial.bounds
            definitions.append({"name": name, "type": initial.kind, "position": {"x": x, "y": y},
                                "size": {"x": width, "y": height},
                                "active": initial.active if name in self.defaults else False})
        self.copy(json.dumps({"componentType": "hitbox", "componentName": "hitbox",
                              "data": {"hitboxes": definitions}}, indent=2))
        self.status.set("Copied the prefab component JSON. Add or merge it in the character's components array.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("lua", nargs="?", type=Path, default=KIARA)
    parser.add_argument("--atlas", type=Path)
    parser.add_argument("--texture", type=Path)
    parser.add_argument("--prefab", type=Path)
    args = parser.parse_args()
    root = tk.Tk()
    editor = Editor(root)
    editor.open(args.lua.resolve(), args.atlas, args.texture, args.prefab)
    root.mainloop()


if __name__ == "__main__":
    main()

