#ifndef xlogger_message_h
#define xlogger_message_h

#include "xlog.h"
#include "list.h"

// ------------------------xlogger--------------------------------------
struct xlogger_append_request {
	struct list_head head;
	logger_level level;
	size_t size;
	char buffer[0];
};


#endif // !xlogger_message_h
