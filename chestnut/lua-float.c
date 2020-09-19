#define LUA_LIB

#include <assert.h>
#include <lauxlib.h>
#include <lua.h>
#include <stdbool.h>
#include <stdint.h>

union float_number {
    double d;
    int64_t i;
};

static bool
check_support()
{
#ifdef _MSC_VER
#else
    assert(sizeof(int64_t) == sizeof(double)); /*double must be 64bit*/
    assert(0x3ff0000000000000 == ((union float_number) {1.0}).i); /*check little-endian and IEEE 754*/
#endif // _MSC_VER
    return true;
}

static int
lua_encode_float(lua_State* L)
{
    assert(check_support());

    union float_number number;
    number.d = lua_tonumber(L, 1);
    lua_pushinteger(L, number.i);
    return 1;
}

static int
lua_decode_float(lua_State* L)
{
    assert(check_support());

    union float_number number;
    number.i = lua_tointeger(L, 1);
    lua_pushnumber(L, number.d);
    return 1;
}

LUAMOD_API int
luaopen_chestnut_float(lua_State* L)
{
    luaL_checkversion(L);
    luaL_Reg l[] = {
        {"encode", lua_encode_float},
        {"decode", lua_decode_float},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}