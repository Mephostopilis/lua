#pragma once
#ifndef win32_dlfcn_h
#define win32_dlfcn_h

#ifndef dlopen
#define dlopen(filename,flag) replace_dlopen(filename,flag)
#endif // !dlopen
#ifndef dlerror()
#define dlerror() replace_dlerror()
#endif // !dlerror()
#ifndef dlsym
#define dlsym(handle,symbol) replace_dlsym(handle, symbol)
#endif // !dlsym
#ifndef dlclose
#define dlclose(handle) replace_dlclose(handle)
#endif // !dlclose



enum { RTLD_NOW, RTLD_GLOBAL, RTLD_LOCAL };

void *replace_dlopen(const char *filename, int flag);

char *replace_dlerror(void);

void *replace_dlsym(void *handle, const char *symbol);

int replace_dlclose(void *handle);

#endif // !dlfcn_h
