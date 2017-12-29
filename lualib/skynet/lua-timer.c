#define LUA_LIB

#include "skynet_timer.h"

#include <lua.h>
#include <lauxlib.h>

#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

static int
linit(lua_State *L) {
	skynet_timer_init();
	return 0;
}

static int
lstarttime(lua_State *L) {
	uint32_t t = skynet_starttime();
	lua_pushinteger(L, t);
	return 1;
}

static int
lnow(lua_State *L) {
	uint64_t t = skynet_now();
	lua_pushinteger(L, t);
	return 1;
}


static int
lupdate(lua_State *L) {
	skynet_updatetime();
	return 0;
}

static int
ltimeout(lua_State *L) {
	lua_Integer time = luaL_checkinteger(L, 1);
	lua_Integer session = luaL_checkinteger(L, 2);
	luaL_checktype(L, 3, LUA_TFUNCTION);
	lua_getglobal(L, "skynet_timer");
	if (!lua_istable(L, -1)) {
		lua_newtable(L);
		lua_setglobal(L, "skynet_timer");
		lua_getglobal(L, "skynet_timer");
	}
	luaL_checktype(L, -1, LUA_TTABLE);
	lua_pushvalue(L, 3);
	lua_rawseti(L, -2, session);
	skynet_timeout((uintptr_t)L, (int)time, (int)session);
	return 0;
}

LUAMOD_API int
luaopen_skynet_timer(lua_State *L) {
	luaL_checkversion(L);

	luaL_Reg il[] = {
		{ "init", linit },
		{ "starttime", lstarttime },
		{ "now", lnow },
		{ "update", lupdate },
		{ "timeout", ltimeout },
		{ NULL, NULL },
	};
	luaL_newlib(L, il);
	return 1;
}