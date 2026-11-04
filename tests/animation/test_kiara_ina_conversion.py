"""Exercise both character graphs using the bundled Lua runtime, without a window."""
import ctypes
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]


class CharacterConversionTest(unittest.TestCase):
    def test_kiara_and_ina(self):
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
        prefix = "package.path = " + json.dumps(ROOT.as_posix() + "/?.lua;") + " .. package.path\n"
        prefix += "characterSprites = {}\n"
        for character in ("kiara", "ina"):
            atlas = json.loads((ROOT / f"assets/sprites/characters/{character}/{character}Atlas.json").read_text())
            prefix += f"characterSprites.{character} = {{" + ",".join(
                "[" + json.dumps(sprite["spriteId"]) + "] = true" for sprite in atlas["sprites"]) + "}\n"
        state = library.luaL_newstate()
        self.assertTrue(state)
        try:
            library.luaL_openlibs(state)
            code = (prefix + (ROOT / "tests/animation/kiara_ina_conversion.lua").read_text()).encode()
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
