
#if defined(XLUA) && defined(ANDROID)
#else
#define LUA_LIB
#endif // !ANDROID

#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <lauxlib.h>
#include <lua.h>

LUAMOD_API
int luaopen_httpparser(lua_State* L)
{
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}