"""Source-preserving edits for Project Holo's literal Lua animation tables."""
from dataclasses import dataclass, field
import json
import math
import re


PIXELS_PER_UNIT = 32
TOKEN = re.compile(
    r'--\[(?P<comment_eq>=*)\[.*?\](?P=comment_eq)\]|--[^\n]*'
    r'|\[(?P<string_eq>=*)\[.*?\](?P=string_eq)\]'
    r'|"(?:\\.|[^"\\])*"|\x27(?:\\.|[^\x27\\])*\x27'
    r'|[A-Za-z_]\w*|\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|[^\s]',
    re.S,
)
OPEN = {"{": "}", "(": ")", "[": "]"}
BLOCKS = {"function": "end", "if": "end", "do": "end", "repeat": "until"}
MANAGED_BOX_BLOCK = re.compile(
    r"^ +-- animation editor boxes\r?\n.*?^ +-- end animation editor boxes[^\r\n]*",
    re.M | re.S,
)
EXIT_BOX_BLOCK = re.compile(
    r"^ +-- animation editor exit cleanup\r?\n.*?^ +-- end animation editor exit cleanup\r?\n",
    re.M | re.S,
)


def string_value(token):
    # Atlas IDs and box names use ordinary quoted strings.
    if token.startswith(('"', "'")):
        return re.sub(r"""\\([\\'"])""", r"\1", token[1:-1])
    return None


def quote(value):
    return json.dumps(value, ensure_ascii=False)


@dataclass(frozen=True)
class Box:
    name: str
    kind: str | None
    bounds: tuple
    active: bool = False

    def rectangle(self, origin, zoom):
        x, y, width, height = self.bounds
        ox, oy = origin
        scale = zoom * PIXELS_PER_UNIT
        return (ox + x * scale, oy - (y + height) * scale,
                ox + (x + width) * scale, oy - y * scale)

    @staticmethod
    def from_rectangle(start, end, origin, zoom):
        ox, oy = origin
        left, right = sorted(round((x - ox) / zoom) for x in (start[0], end[0]))
        top, bottom = sorted(round((y - oy) / zoom) for y in (start[1], end[1]))
        return tuple(v / PIXELS_PER_UNIT for v in (left, -bottom, right - left, bottom - top))


@dataclass
class Callback:
    actor: str
    first: int
    body: int
    close: int
    sprite: str = ""
    sprite_token: int = -1
    sprite_calls: int = 0
    box_calls: list = field(default_factory=list)
    managed_box_calls: dict = field(default_factory=dict)
    managed_box_indices: list = field(default_factory=list)
    has_return: bool = False


@dataclass
class State:
    name: str
    opening: int
    assignment: int
    table: int = -1
    max_frames: int = 0
    enter: Callback = None
    tick: Callback = None
    exit_field: int = -1
    exit_callback: Callback = None
    keys: dict = field(default_factory=dict)
    occupied: set = field(default_factory=set)
    frame_tokens: dict = field(default_factory=dict)


class Script:
    def __init__(self, source):
        self.source = source
        self.tokens = [m for m in TOKEN.finditer(source) if not m[0].startswith("--")]
        self.values = [m[0] for m in self.tokens]
        self.ends = {}
        stack = []
        for index, token in enumerate(self.values):
            if token in OPEN or token in BLOCKS:
                stack.append((index, OPEN.get(token, BLOCKS.get(token))))
            elif stack and token == stack[-1][1]:
                self.ends[stack.pop()[0]] = index
        self.states = {}
        self.atlas_id = ""
        for i, token in enumerate(self.values):
            if token != "states":
                continue
            if self.values[i + 1:i + 2] == ["."]:
                name, value = self.values[i + 2], i + 4
            elif self.values[i + 1:i + 2] == ["["]:
                name, value = string_value(self.values[i + 2]), i + 5
            else:
                continue
            if name is None or self.values[value - 1:value] != ["="] or value >= len(self.values):
                continue
            if name == "spriteAsset":
                self.atlas_id = string_value(self.values[value]) or ""
            elif name != "parameters" and self.values[value] == "{" and value in self.ends:
                self.states[name] = self.read_state(name, value, i)

    def top_level(self, opening):
        i = opening + 1
        while i < self.ends[opening]:
            yield i
            i = self.ends.get(i, i) + 1

    def read_state(self, name, opening, assignment):
        state = State(name, opening, assignment)
        for i in self.top_level(opening):
            fields = self.values[i:i + 3]
            if len(fields) != 3:
                continue
            field_name, equals, value = fields
            if equals != "=":
                continue
            if field_name == "maxFrames" and value.isdecimal():
                state.max_frames = int(value)
            if field_name == "onEnter" and value == "function":
                state.enter = self.read_callback(i + 2)
            if field_name == "tick" and value == "function":
                state.tick = self.read_callback(i + 2, actor_parameter=1)
            if field_name == "onExit":
                state.exit_field = i
                state.exit_callback = self.read_callback(i + 2) if value == "function" else None
            if field_name != "keyFrames" or value != "{" or i + 2 not in self.ends:
                continue
            state.table = i + 2
            for key in self.top_level(state.table):
                if self.values[key] != "[" or self.values[key + 2:key + 4] != ["]", "="]:
                    continue
                frame = self.values[key + 1]
                if not frame.isdecimal():
                    continue
                index = int(frame)
                callback = self.read_callback(key + 4) if self.values[key + 4:key + 5] == ["function"] else None
                if callback and index not in state.occupied:
                    state.keys[index] = callback
                else:
                    state.keys.pop(index, None)
                if index in state.occupied:
                    state.frame_tokens.pop(index, None)
                else:
                    state.frame_tokens[index] = key + 1
                state.occupied.add(index)
        return state

    def read_callback(self, first, actor_parameter=0):
        close = self.ends.get(first)
        parameters = self.ends.get(first + 1)
        actor_token = first + 2 + 2 * actor_parameter
        if close is None or parameters is None or parameters <= actor_token:
            return None
        actor = self.values[actor_token]
        if not re.fullmatch(r"[A-Za-z_]\w*", actor):
            return None
        callback = Callback(actor, first, parameters + 1, close)
        managed = MANAGED_BOX_BLOCK.search(
            self.source, self.tokens[first].start(), self.tokens[close].start()
        )
        direct = set(self.top_level(first))
        aliases = set()
        for i in range(callback.body, close):
            if i in direct and self.values[i] == "return":
                callback.has_return = True
            if (i in direct and self.values[i] == "local"
                    and self.values[i + 2:i + 8] == ["=", actor, ":", "Hitbox", "(", ")"]):
                aliases.add(self.values[i + 1])
            if self.values[i:i + 3] == [actor, ":", "Sprite"]:
                end = self.ends.get(i + 3, i)
                if (self.values[i + 4:end] in ([], ['"sprite"'], ["'sprite'"])
                        and self.values[end + 1:end + 4] == [":", "SetSprite", "("]):
                    callback.sprite_calls += 1
                    if i in direct and self.ends.get(end + 3) == end + 5:
                        sprite = string_value(self.values[end + 4])
                        if sprite is not None:
                            callback.sprite, callback.sprite_token = sprite, end + 4
            if self.values[i:i + 3] == [actor, ":", "Hitbox"]:
                end = self.ends.get(i + 3)
                if end is None or self.values[i + 4:end] not in ([], ['"hitbox"'], ["'hitbox'"]):
                    continue
            elif self.values[i] in aliases:
                end = i
            else:
                continue
            method_tokens = self.values[end + 1:end + 3]
            if len(method_tokens) != 2:
                continue
            colon, method = method_tokens
            if colon != ":" or method not in ("SetBounds", "SetActive", "SetPosition", "SetSize"):
                continue
            stop = self.ends.get(end + 3)
            if stop is None:
                continue
            args = "".join(self.values[end + 4:stop])
            match = re.fullmatch(r"""("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'),(.+)""", args)
            if not match:
                continue
            name = string_value(match[1])
            if method == "SetActive" and match[2] in ("true", "false"):
                callback.box_calls.append((name, method, match[2] == "true"))
            elif method != "SetActive":
                try:
                    bounds = tuple(float(part) for part in match[2].split(","))
                except ValueError:
                    continue
                expected = 4 if method == "SetBounds" else 2
                if len(bounds) == expected and all(math.isfinite(v) for v in bounds):
                    callback.box_calls.append((name, method, bounds))
                else:
                    continue
            else:
                continue
            if managed and managed.start() <= self.tokens[i].start() < managed.end():
                callback.managed_box_calls[name, method] = callback.box_calls[-1][2]
                callback.managed_box_indices.append(len(callback.box_calls) - 1)
        return callback

    def preview(self, state, frame, defaults, default_sprite="", box_commands=None):
        boxes = dict(defaults)
        sprite = default_sprite
        callbacks = [state.enter] + [state.keys[i] for i in sorted(state.keys) if i <= frame]
        for callback in callbacks:
            if callback is None:
                continue
            sprite = callback.sprite or sprite
            calls = callback.box_calls
            if box_commands is not None and callback is state.keys.get(frame):
                calls = [call for index, call in enumerate(calls) if index not in callback.managed_box_indices]
                insert = next(iter(callback.managed_box_indices), len(calls))
                calls[insert:insert] = [(name, method, value) for (name, method), value in box_commands.items()]
            for name, method, value in calls:
                box = boxes.get(name, Box(name, None, (0, 0, 0, 0)))
                bounds, active = box.bounds, box.active
                if method == "SetBounds":
                    bounds = value
                elif method == "SetPosition":
                    bounds = value + bounds[2:]
                elif method == "SetSize":
                    bounds = bounds[:2] + value
                else:
                    active = value
                boxes[name] = Box(name, box.kind, bounds, active)
        if box_commands is not None and frame not in state.keys:
            # A draft at a new keyframe follows the inherited preview.
            for (name, method), value in box_commands.items():
                box = boxes.get(name, Box(name, None, (0, 0, 0, 0)))
                bounds = value if method == "SetBounds" else box.bounds
                active = value if method == "SetActive" else box.active
                boxes[name] = Box(name, box.kind, bounds, active)
        return sprite, boxes

    def move_keyframe(self, state, frame, destination):
        if frame not in state.frame_tokens:
            raise ValueError("Select a keyframe with a unique literal frame number.")
        if not 0 <= destination <= 2147483647:
            raise ValueError("Enter a nonnegative 32-bit frame index.")
        if destination == frame:
            return self.source
        if destination in state.occupied:
            raise ValueError(f"Frame {destination} already has a keyframe.")
        token = self.tokens[state.frame_tokens[frame]]
        return self.source[:token.start()] + str(destination) + self.source[token.end():]

    def state_text(self, state):
        start = self.tokens[state.assignment].start()
        end = self.tokens[self.ends[state.opening]].end()
        return self.source[start:end]

    def sync_exit_cleanup(self, state):
        names = sorted({
            name for callback in [state.enter, state.tick, *state.keys.values()] if callback
            for name, method, value in callback.box_calls if method == "SetActive" and value is True
        })
        callback = state.exit_callback
        if names and state.exit_field >= 0 and callback is None:
            raise ValueError("This state uses a computed onExit. Add its box cleanup in Lua.")
        if not names and callback is None:
            return self.source

        eol = "\r\n" if "\r\n" in self.source else "\n"
        actor = callback.actor if callback else "actor"
        block = ""
        if names:
            lines = ["        -- animation editor exit cleanup", f"        if {actor}:Hitbox() then"]
            lines.extend(f"            {actor}:Hitbox():SetActive({quote(name)}, false)" for name in names)
            lines.extend(["        end", "        -- end animation editor exit cleanup"])
            block = eol.join(lines) + eol

        if callback is None:
            opening = self.tokens[state.opening].end()
            suffix = self.source[opening:]
            separator = "" if suffix.startswith(("\r\n", "\n")) else eol
            handler = eol + "    onExit = function(actor)" + eol + block + "    end,"
            return self.source[:opening] + handler + separator + suffix

        body = self.tokens[callback.body - 1].end()
        close = self.tokens[callback.close].start()
        existing = EXIT_BOX_BLOCK.search(self.source, body, close)
        if existing:
            return self.source[:existing.start()] + block + self.source[existing.end():]
        if not block:
            return self.source
        if "return" in self.values[callback.body:callback.close]:
            # Run before the existing body when it may exit early.
            return self.source[:body] + eol + block + "        " + self.source[body:]
        line_start = self.source.rfind("\n", body, close) + 1
        if line_start >= body and not self.source[line_start:close].strip():
            return self.source[:line_start] + block + self.source[line_start:]
        return self.source[:close] + eol + block + "    " + self.source[close:]

    def edit(self, state, frame, sprite, box_commands=None):
        """Return (updated source, pasteable frame entry or new keyFrames field)."""
        callback = state.keys.get(frame)
        if frame in state.occupied and callback is None:
            raise ValueError("This frame uses a callback the editor cannot safely modify.")
        if state.table < 0:
            fields = list(self.top_level(state.opening))
            if any(self.values[i:i + 2] == ["keyFrames", "="] for i in fields):
                raise ValueError("This state uses a computed keyFrames table.")
        eol = "\r\n" if "\r\n" in self.source else "\n"
        actor = callback.actor if callback else "actor"
        sprite_call = f'{actor}:Sprite("sprite"):SetSprite({quote(sprite)})'
        box_lines = []
        if box_commands:
            box_lines.append("            -- animation editor boxes")
            box_lines.append(f"            if {actor}:Hitbox() then")
            for (name, method), value in box_commands.items():
                args = str(value).lower() if isinstance(value, bool) else ", ".join(
                    format(number, ".15g") for number in value
                )
                box_lines.append(f"                {actor}:Hitbox():{method}({quote(name)}, {args})")
            box_lines.extend(["            end", "            -- end animation editor boxes"])

        if callback:
            start = self.tokens[callback.first].start()
            end_token = self.tokens[callback.close]
            original = self.source[start:end_token.start()]
            edits = []
            if sprite and sprite != callback.sprite:
                if callback.sprite_calls > 1 or (callback.sprite_calls and callback.sprite_token < 0):
                    raise ValueError("This frame has dynamic or multiple sprite calls. Edit its sprite in Lua.")
                if callback.sprite_token >= 0:
                    token = self.tokens[callback.sprite_token]
                    edits.append((token.start() - start, token.end() - start, quote(sprite)))
                else:
                    offset = self.tokens[callback.body - 1].end() - start
                    edits.append((offset, offset, eol + "            " + sprite_call + eol + "            "))
            if box_commands is not None:
                block = MANAGED_BOX_BLOCK.search(original)
                if block:
                    left, right = block.span()
                    if not box_lines and original[right:].startswith(eol):
                        right += len(eol)
                    edits.append((left, right, eol.join(box_lines)))
                elif box_lines:
                    if callback.has_return:
                        raise ValueError("This frame returns early. Place box calls manually in its Lua callback.")
                    edits.append((len(original), len(original), eol + eol.join(box_lines) + eol + "        "))
            for left, right, replacement in sorted(edits, reverse=True):
                original = original[:left] + replacement + original[right:]
            updated = original + "end"
            return (self.source[:start] + updated + self.source[end_token.end():],
                    f"        [{frame}] = {updated},")

        lines = [f"        [{frame}] = function(actor)"]
        if sprite:
            lines.append("            " + sprite_call)
        lines.extend(box_lines)
        lines.append("        end,")
        entry = eol.join(lines)
        if state.table < 0:
            entry = eol.join(["    keyFrames = {", entry, "    },"])
        opening = self.tokens[state.table if state.table >= 0 else state.opening].end()
        suffix = self.source[opening:]
        separator = "" if suffix.startswith(("\n", "\r\n")) else eol
        return self.source[:opening] + eol + entry + separator + suffix, entry
