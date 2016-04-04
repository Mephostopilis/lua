/*
** $Id: lfunc.h,v 2.15 2015/01/13 15:49:11 roberto Exp $
** Auxiliary functions to manipulate prototypes and closures
** See Copyright Notice in lua.h
*/

#ifndef lfunc_h
#define lfunc_h


#include "lobject.h"


#define sizeCclosure(n)	(cast(int, sizeof(CClosure)) + \
                         cast(int, sizeof(TValue)*((n)-1)))

#define sizeLclosure(n)	(cast(int, sizeof(LClosure)) + \
                         cast(int, sizeof(TValue *)*((n)-1)))


/* test whether thread is in 'twups' list */
#define isintwups(L)	(L->twups != L)


/*
** maximum number of upvalues in a closure (both C and Lua). (Value
** must fit in a VM register.)
*/
#define MAXUPVAL	255


/*
** Upvalues for Lua closures
*/
struct UpVal {
  TValue *v;        /* points to stack or to its own value */ /* 这个值该主要用来干什么*/
  lu_mem refcount;  /* reference counter */
  union {
    struct {        /* (when open) */
      UpVal *next;  /* linked list */
      int touched;  /* mark to avoid cycles with dead threads */
    } open;
    TValue value;   /* the value (when closed) */   /* when closed 是什么时候*/
  } u;
};

/* 这么用来判断是否open，也就是是v没有指向value的时候，就是open的，那么next就会指向下一个*/
#define upisopen(up)	((up)->v != &(up)->u.value)


LUAI_FUNC Proto *luaF_newproto (lua_State *L);                     /* new*/
LUAI_FUNC CClosure *luaF_newCclosure (lua_State *L, int nelems);   /* new*/
LUAI_FUNC LClosure *luaF_newLclosure (lua_State *L, int nelems);   /* new*/
LUAI_FUNC void luaF_initupvals (lua_State *L, LClosure *cl);       /* new upvals*/
LUAI_FUNC UpVal *luaF_findupval (lua_State *L, StkId level);
LUAI_FUNC void luaF_close (lua_State *L, StkId level);
LUAI_FUNC void luaF_freeproto (lua_State *L, Proto *f);
LUAI_FUNC const char *luaF_getlocalname (const Proto *func, int local_number,
                                         int pc);


#endif
