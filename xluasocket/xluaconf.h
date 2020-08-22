#ifndef XLUACONF_H
#define XLUACONF_H

#include "platform.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/timeb.h>
#include <sys/types.h>
#include <unistd.h>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "Win32_Interop/Win32_Extras.h"

#include <Wininet.h>
#include <ws2tcpip.h>
#pragma comment(lib, "Ws2_32.lib")

#ifndef ssize_t
#define ssize_t intptr_t
#endif // !

#ifdef near
#undef near
#endif // near

#endif

#define MALLOC malloc
#define FREE free
#define REALLOC realloc

#endif // !XLUACONF_H
