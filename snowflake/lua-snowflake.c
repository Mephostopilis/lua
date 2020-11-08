#define LUA_LIB

#include "spinlock.h"

#include <lauxlib.h>
#include <lua.h>

#include <assert.h>
#include <stdint.h>
#include <string.h>

#define MAX_INDEX_VAL (0x0fff) // （12）
#define MAX_WORKID_VAL (0x03ff) //  (10)
#define MAX_TIMESTAMP_VAL (0x01ffffffffff) //  (41)

typedef struct ctx {
    struct spinlock lock;
    int64_t last_timestamp;
    int16_t work_id;
    int16_t index;
    volatile int inited;
} ctx_t;

static ctx_t TI;

#if defined(USE_SKYNET)
// ms
static int64_t
get_timestamp()
{
    int64_t st = skynet_starttime() * 100; // sec
    int64_t ct = skynet_now();
    return (st + ct);
}
#else
static int64_t
get_timestamp()
{
    return 0;
}
#endif

static void
wait_next_msec(ctx_t* TI)
{
    assert(TI != NULL);
    int64_t current_timestamp = 0;
    do {
        current_timestamp = get_timestamp();
    } while (TI->last_timestamp >= current_timestamp);
    TI->last_timestamp = current_timestamp;
    TI->index = 0;
}

static int64_t
next_id(ctx_t* TI)
{
    if (TI->inited != 1) {
        return -1;
    }
    int64_t current_timestamp = get_timestamp();
    if (current_timestamp == TI->last_timestamp) {
        if (TI->index < MAX_INDEX_VAL) {
            ++TI->index;
        } else {
            wait_next_msec(TI);
        }
    } else {
        TI->last_timestamp = current_timestamp;
        TI->index = 0;
    }
    int64_t nextid = (int64_t)(
        ((TI->last_timestamp & MAX_TIMESTAMP_VAL) << 22) | ((TI->work_id & MAX_WORKID_VAL) << 12) | (TI->index & MAX_INDEX_VAL));
    return nextid;
}

static int
linit(lua_State* L)
{

    /*lua_State* L1 = luaL_newstate();
	luaL_traceback(L1, L, NULL, 1);
	size_t len;
	const char *s = luaL_tolstring(L1, 1, &len);*/

    lua_Integer id = luaL_checkinteger(L, 1);
    if (id < 0 || id > MAX_WORKID_VAL) {
        return luaL_error(L, "Work id is in range of 0 - 1023.");
    }

    SPIN_INIT(&TI);
    TI.last_timestamp = get_timestamp();
    TI.work_id = (int16_t)id;
    TI.index = 0;
    TI.inited = 1;

    return 0;
}

static int
lnextid(lua_State* L)
{
    SPIN_LOCK(&TI);
    int64_t id = next_id(&TI);
    SPIN_UNLOCK(&TI);

    lua_pushinteger(L, id);
    return 1;
}

static int
lexit(lua_State* L)
{
    SPIN_DESTROY(&TI);
    return 0;
}

LUAMOD_API int
luaopen_snowflake(lua_State* l)
{
    luaL_checkversion(l);
    luaL_Reg lib[] = {
        {"init", linit},
        {"exit", lexit},
        {"next_id", lnextid},
        {NULL, NULL}};
    luaL_newlib(l, lib);
    return 1;
}