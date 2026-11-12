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
    kind: str
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
    has_return: bool = False


@dataclass
class State:
    name: str
    opening: int
    table: int = -1
    max_frames: int = 0
    enter: Callback = None
    keys: dict = field(default_factory=dict)
    occupied: set = field(default_factory=set)


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
                self.states[name] = self.read_state(name, value)

    def top_level(self, opening):
        i = opening + 1
        while i < self.ends[opening]:
            yield i
            i = self.ends.get(i, i) + 1

    def read_state(self, name, opening):
        state = State(name, opening)
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
                state.occupied.add(index)
        return state

    def read_callback(self, first):
        close = self.ends.get(first)
        parameters = self.ends.get(first + 1)
        if close is None or parameters is None or parameters < first + 3:
            return None
        actor = self.values[first + 2]
        if not re.fullmatch(r"[A-Za-z_]\w*", actor):
            return None
        callback = Callback(actor, first, parameters + 1, close)
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
        return callback

    def preview(self, state, frame, defaults, default_sprite=""):
        boxes = dict(defaults)
        sprite = default_sprite
        callbacks = [state.enter] + [state.keys[i] for i in sorted(state.keys) if i <= frame]
        for callback in callbacks:
            if callback is None:
                continue
            sprite = callback.sprite or sprite
            for name, method, value in callback.box_calls:
                box = boxes.get(name, Box(name, "Hitbox", (0, 0, 0, 0)))
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
        return sprite, boxes

    def edit(self, state, frame, sprite, boxes):
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
        if boxes:
            box_lines.append("            -- animation editor boxes")
            box_lines.append(f"            if {actor}:Hitbox() then")
            for box in boxes.values():
                name = quote(box.name)
                bounds = ", ".join(format(v, ".15g") for v in box.bounds)
                box_lines.append(f"                {actor}:Hitbox():SetBounds({name}, {bounds})")
                box_lines.append(f"                {actor}:Hitbox():SetActive({name}, {str(box.active).lower()})")
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
            if box_lines:
                if callback.has_return:
                    raise ValueError("This frame returns early. Place box calls manually in its Lua callback.")
                block = re.search(
                    r"(?m)^ +-- animation editor boxes\r?\n.*?^ +-- end animation editor boxes[^\r\n]*",
                    original, re.S,
                )
                if block:
                    edits.append((block.start(), block.end(), eol.join(box_lines)))
                else:
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

    def managed_names(self, callback):
        if callback is None:
            return set()
        body = self.source[self.tokens[callback.first].start():self.tokens[callback.close].start()]
        marker = "            -- animation editor boxes"
        if marker not in body:
            return set()
        tail = body.split(marker, 1)[1].split("-- end animation editor boxes", 1)[0]
        return {string_value(match[1]) for match in re.finditer(
            r':SetBounds\(("(?:\\.|[^"\\])*")\s*,', tail
        )}
