#if defined(XLUA) && defined(ANDROID)
#else
#define LUA_LIB
#endif // !ANDROID

#include "mt_rand.h"
#include <lua.h>
#include <lauxlib.h>
#include <stdio.h>
#include <math.h>

static int
lrand(lua_State *L) {
	MTState *s = lua_touserdata(L, 1);
	uint32_t r = php_mt_rand(s);
	lua_pushinteger(L, (lua_Integer)r);
	return 1;
}

static int
lrand_range(lua_State *L) {
	MTState *s = lua_touserdata(L, 1);
	lua_Integer min = lua_tointeger(L, 2);
	lua_Integer max = lua_tointeger(L, 3);
	uint32_t r = php_mt_rand_range(s, min, max);
	lua_pushinteger(L, r);
	return 1;
}

static int
lnewstate(lua_State *L) {
	lua_Integer seed = luaL_checkinteger(L, 1);
	seed = (seed < 0) ? 0 : seed;

	lua_pushvalue(L, lua_upvalueindex(1));
	MTState *s = lua_newuserdata(L, sizeof(MTState));
	lua_setmetatable(L, -1);
	mt_srand((uint32_t)seed, s);
	return 1;
}

LUAMOD_API int
luaopen_mtrand(lua_State *L) {
	luaL_checkversion(L);

	luaL_Reg indextable[] = {
		{ "rand", lrand },
		{ "rand_range", lrand_range },
		{ NULL, NULL },
	};
	luaL_newlib(L, indextable);

	lua_createtable(L, 0, 1);
	lua_setfield(L, -1, "__index");

	lua_pushcclosure(L, lnewstate, 1);

	return 1;
}
