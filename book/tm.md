# TM

元表，元表的作用有哪些，主要用来干什么。在lua中能单独设置元表只有Table与UData数据类型。元表主要类型

```
typedef enum {
  TM_INDEX,
  TM_NEWINDEX,
  TM_GC,
  TM_MODE,
  TM_LEN,
  TM_EQ,  /* last tag method with fast access */
  TM_ADD,
  TM_SUB,
  TM_MUL,
  TM_MOD,
  TM_POW,
  TM_DIV,
  TM_IDIV,
  TM_BAND,
  TM_BOR,
  TM_BXOR,
  TM_SHL,
  TM_SHR,
  TM_UNM,
  TM_BNOT,
  TM_LT,
  TM_LE,
  TM_CONCAT,
  TM_CALL,
  TM_N        /* number of elements in the enum */
} TMS;
```

当Table调用相应的方法的时候，如果找不到对应的key，就会调用TM\_INDEX元方法，而TM\_INDEX怎么判断存在，需要靠

而LUA\_TNIL是一个占位符，其实根本没有值。LUA\_TBOOLEAN、LUA\_TLIGHTUSERDATA、LUA\_TNUMBER是栈里分配的数据，后面45678数据类型都是gc数据类型，可是只有LUA\_TTABLE与LUA\_TUSERDATA两种数据类型有`struct Table *metatable;`字段。所以能够给出接口自定义设置metatable的数据类型也就是这两种。在baselib里面的setmetatable此函数也只是针对Table数据类型，也就是说，你写lua代码用setmetatabel函数是可以改变Table的。但是其他所有类型是不可以改变的。但是USERDATA数据类型也是可以改变的，这时候其实给了C接口的。下面我来看下源码  
`static int luaB_setmetatable (lua_State *L) {        
      int t = lua_type(L, 2);        
      luaL_checktype(L, 1, LUA_TTABLE);        
  luaL_argcheck(L, t == LUA_TNIL || t == LUA_TTABLE, 2,        
                    "nil or table expected");        
  if (luaL_getmetafield(L, 1, "__metatable") != LUA_TNIL)        
    return luaL_error(L, "cannot change a protected metatable");        
  lua_settop(L, 2);        
  lua_setmetatable(L, 1);        
  return 1;        
}`

此函数首先会判数据类型是否是LUA\_TTABLE，对于给的第二个参数也是有限制的，只能是LUA\_TNIL或者LUA\_TTABLE，也就是元表只能是一个Table，不能是其他数据类型，通过调用luaL\_getmetafield\(L, 1, "**metatable"\)获取参数1Table的一个字段，key为**metatable的数据，并且压入栈。看到return 1，就是返回原来的元表。下一局lua\_settop\(L, 2\)是标记至少有两个值。lua\_setmetatable\(L, 1\)是把参数2的值设置成参数1的表，return 1是去除掉参数，函数。  
`LUAI_FUNC const TValue * luaT_gettm(Table *events, TMS event, TString *ename);`此函数获取一个Table，  
TMS这些枚举类型对应着一些字符串，Table是可以用整数为键的，这里有一个tms-&gt;tmname的转换。所以flags是用来cache tm。  
`const TValue *luaT_gettmbyobj(lua_State *L, const TValue *o, TMS event);`这个函数直接获取元表中的属性。

`void luaT_callTM(lua_State *L, const TValue *f, const TValue *p1, const TValue *p2, const TValue *p2, int hasres)`调用函数，这是调用元函数

`TValue *luaH_newkey(lua_State, Table *t, const TValue *key)`插入一个新建到hashtable，检测主要位置是否为空，如果不是空，在主要位置要碰撞，

