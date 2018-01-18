#define LUA_LIB

#include "lua.hpp"
#include "NFCNavigationModule.h"

struct navigatoin {
	NFCNavigationHandle *handle;
};

static int
lalloc(lua_State *L) {
	size_t l;
	const char *respath = luaL_checklstring(L, 1, &l);
	struct navigatoin *n = (struct navigatoin *)lua_newuserdata(L, sizeof(struct navigation));
	n->handle = NFCNavigationHandle::Create(respath);

	lua_pushvalue(L, lua_upvalueindex(1));
	lua_setmetatable(L, -2);
	return 1;
}

static int 
lfindpath(lua_State *L) {
	struct navigatoin *n = (struct navigatoin *)lua_touserdata(L, 0);
	lua_Number start_x = luaL_checknumber(L, 1);
	lua_Number start_y = luaL_checknumber(L, 2);
	lua_Number start_z = luaL_checknumber(L, 3);
	lua_Number end_x = luaL_checknumber(L, 4);
	lua_Number end_y = luaL_checknumber(L, 5);
	lua_Number end_z = luaL_checknumber(L, 6);

	float start[3];
	start[0] = start_x;
	start[1] = start_y;
	start[2] = start_z;

	float end[3];
	end[0] = end_x;
	end[1] = end_y;
	end[2] = end_z;

	std::vector<std::array<float, 3>> paths;
	int pos = n->handle->FindStraightPath(start, end, paths);
	if (pos > 0)
	{
		lua_pushinteger(L, pos);

	}
	return 0;
}

static int
FindRandomPointAroundCircle(lua_State *L, const float* centerPos, std::vector<float[3]>& points, int32_t max_points, float maxRadius) {
	struct navigatoin *n = (struct navigatoin *)luaL_checkudata(L, 0, "");
	lua_Number start_x = luaL_checknumber(L, 1);
	lua_Number start_y = luaL_checknumber(L, 2);
	lua_Number start_z = luaL_checknumber(L, 3);
}

static int 
Raycast(const float* start, const float* end, std::vector<float[3]>& hitPointVec) {
	return 0;
}

extern "C" {
LUAMOD_API int luaopen_navigation(lua_State *L);
}

LUAMOD_API int
luaopen_navigation(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg metatable[] = {
		/*{ "__newindex", lnewindex },
		{ "__pairs", lpairs },
		{ "__len", llen },*/
		{ NULL, NULL },
	};
	luaL_newlib(L, metatable);
	lua_pushcclosure(L, lalloc, 1);

	return 1;
}
