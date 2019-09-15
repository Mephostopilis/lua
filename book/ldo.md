# ldo

调用栈在描述你所有函数的调用关系，lua开始执行的是从C开始的，永远第一个是从C调用pcall，lua从开始设计的时候就是C去做借口，所以，lua在执行的的时候C调用lua，lua调用C会平凡的交换。

C调用lua只给几个接口，具体是luaDcall，lua\_callnoyield，luaD\_pcall,所以这些接口都会从C到lua进口。

这里可以说是核心，我们知道lua执行代码的时候，都是通过虚拟机去执行，哪怕是我们不写一行lua代码，全部都用C代码去实现，也是需要lua虚拟机去调用。  
首先要解释一个函数

```
LUA_API void lua_pushcclosure (lua_State *L, lua_CFunction fn, int n) {
  lua_lock(L);
  if (n == 0) {
    setfvalue(L->top, fn);
  }
  else {
    CClosure *cl;
    api_checknelems(L, n);
    api_check(L, n <= MAXUPVAL, "upvalue index too large");
    luaC_checkGC(L);
    cl = luaF_newCclosure(L, n);
    cl->f = fn;
    L->top -= n;
    while (n--) {
      setobj2n(L, &cl->upvalue[n], L->top + n);
      /* does not need barrier because closure is white */
    }
    setclCvalue(L, L->top, cl);
  }
  api_incr_top(L);
  lua_unlock(L);
}
```

这个函数大家应该很熟悉，就是把一个C函数加入到数据栈里面去。那我么将一句一句开始解析。lua\_lock\(L\);这句是因为此函数会对数据栈添加数据，那么就会改变，如果是多线程就需要锁定。但是一般都没有定义。判断n是否为0，如果为0，那么新添加的函数是没有上值的，只需要一句setfvalue\(L-&gt;top, fn\);api\_incr\_top\(\);（api\_incr\_top与api\_checknelems是lapi.h头文件里面，有一个很关键的表达式，\(n\) &lt; \(L-&gt;top - l-&gt;ci-fun\),这也就是为什么func指向的是stack那个值）这两句代码就完成任务。而如果不为0呢，这里可以是负数，那是你不能这么用，

`typedef int (*Pfunc) (lua_State *L, void *ud)`函数指针,通过被luaD\_rawrunprotected调用，那么

`int luaD_poscall(lua_State *L, CallInfo *ci, StkId firstResult, int nres`这个函数就是把CallInfo去掉，并且把那个函数也去掉，然后

关键移除主要有两个函数`static int moveresults(lua_State *L, const TValue *firstResult, StkId res, int nres, int wanted)`这个函数主要作用就是res = firstResult,在上面函数还有一个`L->ci = ci->previous`

