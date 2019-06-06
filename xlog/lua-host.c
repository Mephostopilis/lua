#define LUA_LIB

#include "xlogger_message.h"
#include "xlog.h"
#include "xloggerdd.h"

#include <lua.h>
#include <lauxlib.h>

#include <string.h>
#include <stdint.h>

#define MALLOC  malloc
#define REALLOC realloc
#define FREE    free

struct xloggerd {
	struct xloggerdd *d;
};

static int
lalloc(lua_State *L) {
	const char *logdir = luaL_checkstring(L, 1);
	int rollsize = luaL_checkinteger(L, 2);
	int level = luaL_checkinteger(L, 3);
	int append = luaL_checkinteger(L, 4);
	struct xloggerd *d = lua_newuserdata(L, sizeof(*d));
	if (d == NULL) {
		luaL_error(L, "newuserdata error");
	}
	memset(d, 0, sizeof(*d));
	d->d = xloggerdd_create(logdir, level, rollsize, append);
	if (d->d == NULL) {
		return 0;
	}
	lua_pushvalue(L, lua_upvalueindex(1));
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
lappend(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	struct xlogger_append_request *append_request = lua_touserdata(L, 2);
	xloggerdd_push(inst->d, append_request);

	return 0;
}

static int
llog(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	size_t sz;
	const char *buf = lua_tolstring(L, 2, &sz);
	xloggerdd_log(inst->d, LOG_INFO, buf, sz);
	return 0;
}

static int
lflush(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	xloggerdd_flush(inst->d);
	return 0;
}

static int
lclose(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	xloggerdd_flush(inst->d);
	return 0;
}

LUAMOD_API int
luaopen_xlog_host(lua_State *L) {
	luaL_checkversion(L);
	lua_createtable(L, 0, 2); // meta
	luaL_Reg l[] =
	{
		{ "free",  lfree },
		{ "append", lappend },
		{ "log", llog },
		{ "flush", lflush },
		{ "close", lclose },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	lua_setfield(L, -2, "__index");
	lua_pushcfunction(L, lfree);
	lua_setfield(L, -2, "__gc");
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}
