#ifndef ANDROID
#define LUA_LIB
#endif // !ANDROID

#include <lua.h>
#include <lauxlib.h>

#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

/*
 * 1 ~ cap
*/

#define NEXT_INDEX(i, cap) ((i) > (cap)) ? ((i) % (cap)) : (i)

static lua_Integer
lsize(lua_Integer cap, lua_Integer head, lua_Integer tail) {
	assert(head > 0 && tail > 0 && head <= cap && tail <= cap);
	if (tail == head) {
		return 0;
	} else if (tail > head) {
		return tail - head;
	} else {
		return tail + cap - head;
	}
}

static int
lenqueue(lua_State *L) {
	if (!lua_gettop(L) >= 2) {
		luaL_error(L, "element of queue must not be nil.");
	}
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	lua_Integer head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	lua_Integer tail = luaL_checkinteger(L, -1);
	lua_pop(L, 3);

	lua_pushvalue(L, 2); // forbit more args.
	lua_rawseti(L, 1, tail);

	tail = NEXT_INDEX(tail + 1, cap);
	if (head == tail) {
		lua_Integer new_cap = cap * 2;
		if (tail == 1) {
			tail = cap + 1;
		} else {
			int i;
			for (i = 1; i < tail; i++) {
				lua_rawgeti(L, 1, i);
				lua_rawseti(L, 1, cap + i);
			}
			tail = cap + tail;
		}
		lua_pushinteger(L, new_cap);
		lua_rawseti(L, 1, 0);
		lua_pushinteger(L, head);
		lua_rawseti(L, 1, new_cap + 1);
		lua_pushinteger(L, tail);
		lua_rawseti(L, 1, new_cap + 2);

		assert(cap == lsize(new_cap, head, tail));
		lua_pushinteger(L, cap);
		return 1;
	}
	lua_pushinteger(L, tail);
	lua_rawseti(L, 1, cap + 2);
	lua_Integer size = lsize(cap, head, tail);
	lua_pushinteger(L, size);
	return 1;
}

static int
ldequeue(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	lua_Integer head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	lua_Integer tail = luaL_checkinteger(L, -1);
	lua_pop(L, 3);

	lua_Integer size = lsize(cap, head, tail);
	if (size > 0) {
		lua_rawgeti(L, 1, head);

		head = NEXT_INDEX(head + 1, cap);
		lua_pushinteger(L, head);
		lua_rawseti(L, 1, cap + 1);

		return 1;
	}
	return 0;
}

static int
lat(lua_State *L) {
	if (lua_gettop(L) < 2) {
		luaL_error(L, "you must be ready for offset.");
	}
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_Integer i = luaL_checkinteger(L, 2);

	lua_rawgeti(L, 1, 0);
	lua_Integer cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	lua_Integer head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	lua_Integer tail = luaL_checkinteger(L, -1);
	lua_pop(L, 3);

	assert(i <= cap);
	lua_Integer size = lsize(cap, head, tail);
	if (i <= size) {
		lua_Integer idx = NEXT_INDEX(head + i - 1, cap);
		lua_rawgeti(L, 1, idx);
		return 1;
	} else {
		luaL_error(L, "more than size");
	}
	return 0;
}

static int
lremove(lua_State *L) {
	if (lua_gettop(L) < 2) {
		luaL_error(L, "less then 2.");
	}
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_rawgeti(L, 1, 0);
	lua_Integer cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	lua_Integer head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	lua_Integer tail = luaL_checkinteger(L, -1);

	if (lua_type(L, 2) == LUA_TTABLE) {
		const void *ptr = lua_topointer(L, 2);
		lua_Integer i;
		for (i = head; i != tail; i = NEXT_INDEX(i + 1, cap)) {
			lua_rawgeti(L, 1, i);
			if (lua_type(L, -1) == LUA_TTABLE) {
				if (lua_topointer(L, -1) == ptr) {
					// remove
					lua_Integer j = 0;
					for (j = i; NEXT_INDEX(j + 1, cap) != tail; j = NEXT_INDEX(j + 1, cap)) {
						lua_rawgeti(L, 1, NEXT_INDEX(j + 1, cap));
						lua_rawseti(L, 1, j);
					}
					tail = j;
					lua_pushinteger(L, tail);
					lua_rawseti(L, 1, cap + 2);
					break;
				}
			} else {
				luaL_error(L, "not suport others types.");
			}
		}
	}
	return 0;
}

static int
llen(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);

	lua_rawgeti(L, 1, 0);
	lua_Integer cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	lua_Integer head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	lua_Integer tail = luaL_checkinteger(L, -1);
	lua_pop(L, 3);

	lua_Integer size = lsize(cap, head, tail);
	lua_pushinteger(L, size);
	return 1;
}

static int
lnext(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);

	lua_rawgeti(L, 1, 0);
	lua_Integer cap = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 1);
	lua_Integer head = luaL_checkinteger(L, -1);
	lua_rawgeti(L, 1, cap + 2);
	lua_Integer tail = luaL_checkinteger(L, -1);
	lua_pop(L, 3);

	lua_Integer size = lsize(cap, head, tail);
	lua_Integer idx;
	if (lua_isnoneornil(L, 2)) {
		idx = 0;
	} else {
		idx = lua_tointeger(L, 2);
	}
	lua_Integer i = NEXT_INDEX(head + idx, cap);
	if (i != tail) {
		lua_pushinteger(L, idx + 1);
		lua_rawgeti(L, 1, i);
		return 2;
	}
	return 0;
}

static int
lpairs(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_pushcfunction(L, lnext);
	lua_pushvalue(L, 1);
	lua_pushnil(L);
	return 3;
}

static int
lfree(lua_State *L) {
	return 0;
}

static int
lalloc(lua_State *L) {
	int len = 16;
	int n = lua_gettop(L);
	while (n > len) {
		len *= 2;
	}
	lua_createtable(L, n, 3);
	lua_pushvalue(L, lua_upvalueindex(1));
	lua_setmetatable(L, -2);

	lua_pushinteger(L, len);
	lua_rawseti(L, -2, 0);
	lua_pushinteger(L, 1);
	lua_rawseti(L, -2, len + 1);
	lua_pushinteger(L, 1);
	lua_rawseti(L, -2, len + 2);

	return 1;
}

LUAMOD_API int
luaopen_chestnut_queue(lua_State *L) {
	luaL_checkversion(L);

	luaL_Reg l[] = {
		{ "__pairs", lpairs },
		{ "__len", llen },
		{ "__gc", lfree},
		{ NULL, NULL },
	};
	luaL_newlib(L, l); // met

	luaL_Reg il[] = {
		{ "enqueue", lenqueue },
		{ "dequeue", ldequeue },
		{ "at", lat },
		{ "remove", lremove },
		{ NULL, NULL },
	};
	luaL_newlib(L, il);

	lua_setfield(L, -2, "__index");
	lua_pushcclosure(L, lalloc, 1);
	return 1;
}