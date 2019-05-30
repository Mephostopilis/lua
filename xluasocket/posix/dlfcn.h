#pragma once
#ifndef dlfcn_h
#define dlfcn_h

enum { RTLD_NOW, RTLD_GLOBAL, RTLD_LOCAL };

void *dlopen(const char *filename, int flag);

char *dlerror(void);

void *dlsym(void *handle, const char *symbol);

int dlclose(void *handle);

#endif // !dlfcn_h
