#ifndef socket_cpoll_h
#define socket_cpoll_h

#include <stdbool.h>

struct event;
typedef int poll_fd;

bool
ssp_invalid(int efd);

int
ssp_create();

void
ssp_release(int efd);

int
ssp_add(int efd, int sock, void *ud);

void
ssp_del(int efd, int sock);

void
ssp_write(int efd, int sock, void *ud, bool enable);

int
ssp_wait(int efd, struct event *e, int max);

void
ssp_nonblocking(int fd);

static bool 
sp_invalid(poll_fd fd) { return ssp_invalid(fd); }
static poll_fd 
sp_create() { return ssp_create(); }
static void 
sp_release(poll_fd fd) { ssp_release(fd); }
static int 
sp_add(poll_fd fd, int sock, void *ud) { return ssp_add(fd, sock, ud); }
static void 
sp_del(poll_fd fd, int sock) { ssp_del(fd, sock); }
static void 
sp_write(poll_fd fd, int sock, void *ud, bool enable) { ssp_write(fd, sock, ud, enable); }
static int sp_wait(poll_fd fd, struct event *e, int max) { return ssp_wait(fd, e, max); }
static void sp_nonblocking(int sock) { ssp_nonblocking(sock); }

#endif
