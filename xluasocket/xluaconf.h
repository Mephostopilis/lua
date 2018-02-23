#ifndef XLUACONF_H
#define XLUACONF_H

#if defined(_MSC_VER) || defined(_WIN32)
#include <Winsock2.h>
#include <Wininet.h>
#include <ws2tcpip.h>
#include <Windows.h>
#pragma comment (lib, "Ws2_32.lib")
#else
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <netdb.h>
#include <sys/select.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/timeb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#endif

#define MALLOC  malloc
#define FREE    free
#define REALLOC realloc

#define HEADER_TYPE_LINE 0
#define HEADER_TYPE_PG   1

#define RINGBUF_SIZE      4096
#define WRITE_BUFFER_SIZE 2048
#define MAX_WRITE_WRITEBUF_COUNT (100)

#endif // !XLUACONF_H
