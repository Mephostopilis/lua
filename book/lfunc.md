# lfunc

这一部分主要讲的是proto，但是不会包括执行，这里有很多原因，所以这里。

Proto是一个gc对象，首先来看下结构描述，所有代码都会编译成proto，这才最终目标

一个proto有如此多的字段，但是在执行一个函数的时候，获取指令，并按照指令去执行一些操作，主要还是4个地方，stack，upvalue（upvalue如果close是在upvalue上），k常量（常量都是在proto中的），proto只有size，没有对应的

---

```
GCObject    *next;                  // GCObject 连接在一起
lu_byte      tt;                    // gcobject的数据类型
lu_byte      marked;             ----------- 标记黑白
lu_byte      numparams;       ----------fixed parameters
lu_byte      maxstacksize;           // 此变量
int          sizeupvalues;          // size of 'upvalues'
int          sizek;                 // size of 'k'
int          sizecode;              // size of 'code'
int          sizelineinfo;           // debug.
int          sizep;                 // size of 'p'
int          sizelocavars;          // size of 'locvars'   debug.
int          linedefined;           // debug
int          lastlinedefined;       // debug info
TValue      *k;
Instruction *code;
struct Proto **p;
int          *lineinfo;            // 映射opcode到行信息，也就是说每一个指令调试的时候，在执行该指令出错的时候，调试源码的行数
LocVar       *locvars;             // local var
Upvaldesc    *upvalues;            // upvalue
struct LClosure *cache;            // 上一个创建的闭包

GCObject     *gclist;              // 在gc的时候用来连接gray list

```



