//#include "./../../lua.h"
//#include "./../../lauxlib.h"
//
//
//static int
//ltest(lua_State *L) {
//	int a = 13;
//	int b = 14;
//	int c = a + b;
//	lua_pushinteger(L, c);
//	return 1;
//}
//
//LUAMOD_API int luaopen_test(lua_State *L) {
//	luaL_checkversion(L);
//	luaL_Reg funcs[] = {
//		{"tset", ltest},
//		{NULL, NULL}
//	};
//	luaL_newlib(L, funcs);
//	return 1;
//}