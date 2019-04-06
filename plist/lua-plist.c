#ifndef ANDROID
#define LUA_LIB
#endif // !ANDROID

#include <lua.h>
#include <lauxlib.h>
#include <plist/plist.h>

static int
lplist_new_dict(lua_State *L) {
	plist_t node = plist_new_dict();
	lua_pushlightuserdata(L, node);
	return 1;
}

static int
lplist_new_array(lua_State *L) {
	plist_t node = plist_new_array();
	lua_pushlightuserdata(L, node);
	return 1;
}

static int
lplist_new_string(lua_State *L) {
	size_t l;
	const char *c = luaL_checklstring(L, 1, &l);
	plist_t node = plist_new_string(c);
	lua_pushlightuserdata(L, node);
	return 1;
}

static int
lplist_new_bool(lua_State *L) {
	size_t l;
	int b = lua_toboolean(L, 1);
	plist_t node = plist_new_bool(b);
	lua_pushlightuserdata(L, node);
	return 1;
}

static int
lplist_new_uint(lua_State *L) {
	size_t l;
	lua_Integer i = luaL_checkinteger(L, 1);
	plist_t node = plist_new_uint(i);
	lua_pushlightuserdata(L, node);
	return 1;
}

static int
lplist_new_real(lua_State *L) {
	size_t l;
	lua_Number f = luaL_checknumber(L, 1);
	plist_t node = plist_new_real(f);
	lua_pushlightuserdata(L, node);
	return 1;
}

// array
static int
lplist_array_get_size(lua_State *L) {
	plist_t self = lua_touserdata(L, 1);
	lua_Integer i = luaL_checkinteger(L, 1);
	plist_t node = plist_array_get_size(self, i);
	lua_pushlightuserdata(L, node);
	return 1;
}

static int
lplist_array_get_item(lua_State *L) {
	plist_t self = lua_touserdata(L, 1);
	lua_Integer i = luaL_checkinteger(L, 1);
	plist_t node = plist_array_get_size(self, i);
	lua_pushlightuserdata(L, node);
	return 1;
}

// dict
static int
lplist_dict_get_item(lua_State *L) {
	plist_t self = lua_touserdata(L, 1);
	size_t l;
	const char *key = luaL_checklstring(L, 1, &l);
	plist_t node = plist_dict_get_item(self, key);
	lua_pushlightuserdata(L, node);
	return 1;
}

static int
lplist_from_xml(lua_State *L) {
	size_t l;
	const char *xml = luaL_checklstring(L, 1, &l);
	plist_t node = NULL;
	plist_from_xml(xml, l, &node);
	lua_pushlightuserdata(L, node);
	return 1;
}


LUAMOD_API int
luaopen_plist(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "new_dict", lplist_new_dict },
		{ "new_array", lplist_new_array },
		{ "new_string", lplist_new_string },
		{ "new_bool", lplist_new_bool },
		{ "new_uint", lplist_new_uint },
		{ "new_real", lplist_new_real },
		{ "array_get_size", lplist_array_get_size },
		{ "array_get_item", lplist_array_get_item },
		{ "dict_get_item", lplist_dict_get_item },
		{ "from_xml", lplist_from_xml },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
