#include "log.h"
#include "spinlock.h"
#include <assert.h>
#include <stdarg.h>

struct logger {
	struct spinlock lock;
};

static struct logger d;

void
LOG_INIT() {
	SPIN_INIT(&d);
}

void
LOG_INFO(char *fmt, ...) {
	SPIN_LOCK(&d);
	SPIN_UNLOCK(&d);
}