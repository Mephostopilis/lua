# Table

```
typedef struct Table {
  CommonHeader;
  lu_byte flags;  /* 1<<p means tagmethod(p) is not present */
  lu_byte lsizenode;  /* log2 of size of 'node' array */
  unsigned int sizearray;  /* size of 'array' array */
  TValue *array;  /* array part */
  Node *node;
  Node *lastfree;  /* any free position is before this position */
  struct Table *metatable;
  GCObject *gclist;
} Table;

```

Table这个数据结构，由于属于GC对象，那么肯定是有CommonHeader的。lsizenode是lu_byte数据类型，也就是说最大值是255，log2的值却会很大，这也是node初始化的手就有1个内存，并且有一个Dummy节点。而flags是用来存储此表的元表类型，当要去判断此表是否有元表与相应的元表的类型，直接判断flags相应的位就可以了。gclist是gc相关的。请看GC片。