#if defined(XLUA) && defined(ANDROID)
#else
#define LUA_LIB
#endif // !ANDROID

#include "mt_rand.h"
#include <lua.h>
#include <lauxlib.h>
#include <stdio.h>
#include <math.h>

