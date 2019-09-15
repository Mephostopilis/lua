# lparser

编译器首先回事词法分析，语法分析，语义分析，

## 词法分析

词法分析主要在llex这个模块中，这个模块主要是读取字符并且分析字符生成token与SemInfo。


## 语法分析
主要实现是lparser里面，语法分析就是通过判断当前token与前后token去判断是什么语句。这里主要判断是是在statement这里。


## 语义分析
主要实现是在lparser里面。通过语法分析，判断出当前是什么语句，针对特定语句，判断语义是否正确。


这个文件是在很多，多的都不想看了，lua里面都是函数，一个模块是一个函数，模块里面定义的是一个函数，这些函数有着父子关系，但是在编译的时候，这里有个疑问，在编译的时候，生成code，但是我就是不明白一点就是就是这些常量是怎么保存的，一个proto里面有很多常量，但是执行code的时候，是基于寄存器，那么这些值都是已经在的，所以当你生成code，然后去加载code的时候，又是怎么初始这个常量的，其实生成二进制，就是dum proto。

LexState数据结构主要分析词法，每次都需要读取一个token，而这特token就会决定下一步该怎么做

Dyndata该怎么做，这个数据结构总是用

```
/* dynamic structures used by the parser */
typedef struct Dyndata {
  struct {  /* list of active local variables */
    Vardesc *arr;
    int n;
    int size;
  } actvar;
  Labellist gt;  /* list of pending gotos */
  Labellist label;   /* list of active labels */
} Dyndata;
```

actvar当有一个变量的时候存储到里面，Vardesc主要描述一个变量的信息，也是主要用来调式的。而gt与label主要是goto与label的描述。当一个proto生成的时候都是在Dyndata里面。

当一个chunk生成的时候，主要开始mainfunc这个函数开始。