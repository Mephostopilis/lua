#ifndef skynet_xlogger_h
#define skynet_xlogger_h


/*
** 1.分等级输出各个文件里面
** 2.切分日志
*/

#include "xlog.h"
#include "xlogger_message.h"

struct xloggerdd;
struct xloggerdd *
xloggerdd_create(const char *path, logger_level loglevel, size_t rollsize);
void xloggerdd_release(struct xloggerdd *self);

int xloggerdd_log(struct xloggerdd *self, logger_level level, const char *buf, size_t len);
int xloggerdd_push(struct xloggerdd *self, struct xlogger_append_request *request);
int xloggerdd_flush(struct xloggerdd *self);
int xloggerdd_check_roll(struct xloggerdd *self);
#endif