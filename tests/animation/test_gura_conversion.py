"""Run the authored Gura Lua through the bundled Lua 5.4 runtime, without a window."""
import ctypes
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]


class GuraConversionTest(unittest.TestCase):
    def test_graph_and_playback(self):
        library = ctypes.CDLL(str(ROOT / "include/lua/lua54.dll"))
        library.luaL_newstate.restype = ctypes.c_void_p
        library.luaL_openlibs.argtypes = [ctypes.c_void_p]
        library.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
        library.luaL_loadstring.restype = ctypes.c_int
        library.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_ssize_t, ctypes.c_void_p]
        library.lua_pcallk.restype = ctypes.c_int
        library.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
        library.lua_tolstring.restype = ctypes.c_char_p
        library.lua_close.argtypes = [ctypes.c_void_p]
        state = library.luaL_newstate()
        self.assertTrue(state)
        try:
            library.luaL_openlibs(state)
            metadata = json.loads((ROOT / "assets/sprites/characters/gura/guraAtlas.json").read_text())
            sprite_table = "validSprites = {" + ",".join(
                "[" + json.dumps(sprite["spriteId"]) + "] = true" for sprite in metadata["sprites"]) + "}\n"
            # Lua paths are absolute so this check also runs outside the repository cwd.
            prefix = "package.path = " + json.dumps(str(ROOT).replace("\\", "/") + "/?.lua;") + " .. package.path\n"
            harness = (ROOT / "tests/animation/gura_conversion.lua").read_text()
            harness = harness.replace('dofile("assets/animation/gura/gura.lua")',
                "dofile(" + json.dumps(str(ROOT / "assets/animation/gura/gura.lua").replace("\\", "/")) + ")")
            code = (prefix + sprite_table + harness).encode()
            result = library.luaL_loadstring(state, code)
            if result == 0:
                result = library.lua_pcallk(state, 0, 0, 0, 0, None)
            if result:
                error = library.lua_tolstring(state, -1, None)
                self.fail(error.decode() if error else f"Lua failed with status {result}")
        finally:
            library.lua_close(state)


if __name__ == "__main__":
    unittest.main()
