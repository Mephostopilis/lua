# My Awesome Book

---

This file file serves as your book's preface, a great place to describe your book's content and ideas.

一个lua模块可以生成字节码，而任何一个vm都可以运行，怎么靠一个一段模块生成，怎是不容易的。怎么解决  
lua\_pcallk-&gt;luaD\_pcall-&gt;luaD\_rawrunprotected-&gt;f\_call-&gt;luaD\_callnoyield-&gt;luaD\_call-&gt;luaD\_precall\(这是真正执行的地方）。  
这一串调用链，都是在修改CallInfo，CallInfo就是调用栈信息，lua真个vm的实现就是怎么稳定的调用，而这一切就是核心，转到ldo，这些都是ldo里面的内容

