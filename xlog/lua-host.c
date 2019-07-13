#define LUA_LIB

#include "xlog.h"
#include "xloggerdd.h"

#include <lua.h>
#include <lauxlib.h>

#include <string.h>
#include <stdint.h>

struct xloggerd {
	struct xloggerdd *d;
};

static int
lalloc(lua_State *L) {
	const char *logdir = luaL_checkstring(L, 1);
	int rollsize = luaL_checkinteger(L, 2);
	int level = luaL_checkinteger(L, 3);
	struct xloggerd *d = lua_newuserdata(L, sizeof(*d));
	if (d == NULL) {
		luaL_error(L, "newuserdata error");
	}
	memset(d, 0, sizeof(*d));
	d->d = xloggerdd_create(logdir, level, rollsize);
	if (d->d == NULL) {
		return 0;
	}
	lua_pushvalue(L, lua_upvalueindex(1));
	if (lua_istable(L, -1)) {
		lua_getfield(L, -1, "__index");
		if (!lua_istable(L, -1)) {
			luaL_error(L, "hh");
		}
		lua_pop(L, 1);
		lua_getfield(L, -1, "__gc");
		if (!lua_isfunction(L, -1)) {
			luaL_error(L, "hh");
		}
		lua_pop(L, 1);
	}
	lua_setmetatable(L, -2);
	return 1;
}

static int
lfree(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	if (inst == NULL) {
		luaL_error(L, "inst is nil.");
	}
	xloggerdd_release(inst->d);
	return 0;
}

static int
llog(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	// int top = lua_gettop(L);
	int level = luaL_checkinteger(L, 2);
	size_t sz;
	const char *buf = luaL_checklstring(L, 3, &sz);
	int err = xloggerdd_log(inst->d, level, buf, sz);
	lua_pushinteger(L, err);
	return 1;
}

static int
lcheck(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	xloggerdd_check_date(inst->d);
	xloggerdd_check_roll(inst->d);
	return 0;
}

static int
lflush(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	int err = xloggerdd_flush(inst->d);
	lua_pushinteger(L, err);
	return 1;
}

static int
lcall(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	return 0;
}

LUAMOD_API int
luaopen_xlog_host(lua_State *L) {
	luaL_checkversion(L);
	lua_createtable(L, 0, 2); // meta
	luaL_Reg l[] =
	{
		{ "log", llog },
		{ "check", lcheck },
		{ "flush", lflush },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	lua_setfield(L, -2, "__index");
	lua_pushcfunction(L, lfree);
	lua_setfield(L, -2, "__gc");
	lua_pushcfunction(L, lcall);
	lua_setfield(L, -2, "__call");
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}
