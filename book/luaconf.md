# luaconf

这篇我将会讲一下关于配置，lua语言是怎么做的，你可以定制你自己的lua语言，很多设置都在这里。

如果你也看lua源码的话，那么你一定会发现两个数据类型LUA_INTEGER、LUA_NUMBER，这两个数据类型是在哪里，就是在这里定义的，lua里的基本数据类型是一个number类型，那么这个number数据类型，通过配置去选定整数类型与浮点数类型会选定多少位的。