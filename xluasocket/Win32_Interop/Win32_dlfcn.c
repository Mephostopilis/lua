#include "dlfcn.h"
#define WIN32_LEAN_AND_MEAN  // 屏蔽Windows.h里部分api
#include <Windows.h>
#include <stdio.h>

#define SKYNET_LLE_FLAGS 0
static char buffer[128] = { 0 };

void *replace_dlopen(const char *filename, int flag) {
	(void)flag;
	return LoadLibraryExA(filename, NULL, SKYNET_LLE_FLAGS);
}

char *replace_dlerror(void) {
	memset(buffer, 0, 128);
	int error = GetLastError();
	if (FormatMessageA(FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM,
		NULL, error, 0, buffer, sizeof(buffer) / sizeof(char), NULL)) {
		return buffer;
	} else {
		snprintf(buffer, 128, "system error %d\n", error);
		return buffer;
	}
}

void *replace_dlsym(void *handle, const char *symbol) {
	return GetProcAddress((HMODULE)handle, symbol);
}

int replace_dlclose(void *handle) {
	return FreeLibrary((HMODULE)handle);
}