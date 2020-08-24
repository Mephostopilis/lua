#ifndef __array_h__
#define __array_h__

#if defined(_MSC_VER)
#include <malloc.h>
#define ARRAY(type, name, size) type* name = (type*)_malloca((size) * sizeof(type))
#else
#define ARRAY(type, name, size) type name[size]
#endif

#endif
