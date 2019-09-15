# Table

# 复合数据类型Table

在lua中任何数据结构都是用table表示的，这篇将重点讲解Table

Table数据类型的数据结构如下：

```
typedef struct Table {
       GCObject *next;
       lu_byte tt;
       lu_byte marked;
       lu_byte flags;  /* 1<<p means tagmethod(p) is not present */ /* 用来判断当前表中的元表是否拥有相应的元方法,不能每次都去判断是否有元方法 */
       lu_byte lsizenode;  /* log2 of size of 'node' array */ /* lsizenode == 0 的时候，node数组size为1 */
       unsigned int sizearray;  /* size of 'array' array */
       TValue *array;  /* array part */
       Node *node;
       Node *lastfree;  /* any free position is before this position */ /* 默认是 */
       struct Table *metatable;  /* 表作为唯一的数据结构，还有一个重要作用，元表，在udata里，也需要用到元表 */
       GCObject *gclist; /* gc 的时候 */
} Table;
```

Table分为两部分，hash部分与 数组部分，**luaH\_new**新建一个Table，那么Table在新建初始的时。

```
Table *luaH_new (lua_State *L) {
  GCObject *o = luaC_newobj(L, LUA_TTABLE, sizeof(Table));
  Table *t = gco2t(o);
  t->metatable = NULL;             /* 默认没有元表的 */
  t->flags = cast_byte(~0);        /* flags初始都是1，那么 */
  t->array = NULL;
  t->sizearray = 0;
  setnodevector(L, t, 0);         /* 此函数用来初始hash表node数组大小 */
  return t;
}

static void setnodevector (lua_State *L, Table *t, unsigned int size) {
  int lsize;
  if (size == 0) {  /* no elements to hash part? */ /* 当size == 0 的时候，没有元素，用dummynode去填充 */
    t->node = cast(Node *, dummynode);  /* use common 'dummynode' */
    lsize = 0;
  }
  else {
    int i;
    lsize = luaO_ceillog2(size);
    if (lsize > MAXHBITS)
      luaG_runerror(L, "table overflow");
    size = twoto(lsize);
    t->node = luaM_newvector(L, size, Node);
    for (i = 0; i < (int)size; i++) {
      Node *n = gnode(t, i);
      gnext(n) = 0;
      setnilvalue(wgkey(n));
      setnilvalue(gval(n));
    }
  }
  t->lsizenode = cast_byte(lsize);
  t->lastfree = gnode(t, size);  /* all positions are free */ /* 倒序开始那free节点 */
}
```

table作为复合类型在我们在用lua编程的时候，插入与获取是最长用的操作，而这里

**CommonHeader**凡是gc对象都有这个头，想当于所有gc对象都继承了它的字段，用宏定义，源码是  
`#define CommonHeader    GCObject *next; lu_byte tt; lu_byte marked`  
next用来连接global\_State-&gt;allgc,而tt是用标记数据类型的，其实也就是gc的数据类型，marked是用来标记颜色的，分别有white、gray、black。

**flags**是用来标记方法的，主要用来标记TM

**lsizenode**是用来记录下面一个哈希表**node**的长度的。

**sizearray**是用来记录数组**array**的长度的。

**lastfree**用来记录

**gclist**实在标记graylist或者其他list的时候用来连接的，所有gc对象都有这么一个gclist字段，主要有Table、Proto、lua\_State。

## 分析方法

在开始分析方法之前，ltable.h头文件定义了一些宏，用来快速访问Table里面的数据，宏定义在头文件里面，说明这些可能会被外部模块访问。

```
gnode(t,i)    (&(t)->node[i])
gval(n)        (&(n)->i_val)
gnext(n)    ((n)->i_key.nk.next)

'const' to avoid wrong writings that can mess up field 'next'
gkey(n)        cast(const TValue*, (&(n)->i_key.tvk))

writable version of 'gkey'; allows updates to individual fields,
 but not to the whole (which has incompatible type)
wgkey(n)        (&(n)->i_key.nk)
```

**gnode**是用来获取哈希表中的node，根据相应的hashvalue，gval是获取node里面的i\_val的。gnext相应的node获取next，next是一个索引值，lua里面的table里的hashtable对于hash冲突用的是拉链发，也就是说，在TValue生产一个hash值然后求余得出索引有冲突找下一个有空的位置，并把这个位置放在next这里。为甚么这里都是TValue类型，因为Table在设置的时候用来操作的时候只会针对TValue。

[^1]: Enter footnote here.

