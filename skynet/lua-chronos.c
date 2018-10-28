/**
The MIT License (MIT)

Copyright (c) ldrumm 2014

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "chronos.h"
#include <lua.h>
#include <lauxlib.h>


#if LUA_VERSION_NUM < 502
	#define luaL_newlib(L, l) ( lua_newtable(L), luaL_register(L, NULL, l))
#endif

static int
lchronos_nanotime(lua_State * L) {
	clock_gettime_mono
}

static const struct luaL_Reg chronos_reg[] = {
    {"nanotime", lchronos_nanotime},
    {NULL, NULL}
};


LUA_API int luaopen_chronos(lua_State *L){
    luaL_newlib(L, chronos_reg);
    return 1;
}
