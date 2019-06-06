#include "xloggerdd.h"
#include "xlog/xlogger_buffer.h"
#include "xlogger_message.h"

#include <skynet.h>
#include <skynet_env.h>
#include <message/message.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <assert.h>

struct xloggerd {
	struct xloggerdd *d;
};

struct xloggerd *
xloggerd_create(void) {
	struct xloggerd *inst = skynet_malloc(sizeof(struct xloggerd));
	const char *logdir = skynet_getenv("xlogpath");
	const char *logroll = skynet_getenv("xlogroll");
	int rollsize = atoi(logroll);
	struct xloggerdd *d = xloggerdd_create(LOG_INFO, rollsize, logdir);
	inst->d = d;
	return inst;
}

void
xloggerd_release(struct xloggerd * inst) {
	xloggerdd_release(inst->d);
	skynet_free(inst);
}

static int
_logger(struct skynet_context * context, void *ud, int type, int session, uint32_t source, const void * msg, size_t sz) {
	struct xloggerd * inst = ud;
	if (type == PTYPE_TEXT) {
		struct message *message = (struct message *)(msg);
		if (strcmp(message->cmd, "FLUSH") == 0) {
			assert(0);
			//struct xloggerd_flush_request *flush_request = CAST_USERTYPE_POINTER(message, struct xloggerd_flush_request);
			//xloggerdd_flush(inst->d, flush_request->buffer);

			//// response
			//size_t flush_msg_size = sizeof(struct message) + sizeof(struct xloggerd_flush_response);
			//struct message *flush = skynet_malloc(flush_msg_size);
			//memset(flush, 0, flush_msg_size);
			//const char *cmd = "FLUSH";
			//memcpy(flush->cmd, cmd, strlen(cmd));

			//struct xloggerd_flush_response *flush_response = CAST_USERTYPE_POINTER(flush, struct xloggerd_flush_response);
			//flush_response->buffer = flush_request->buffer;

			//skynet_sendname(context, source, ".xlogger", PTYPE_TEXT | PTYPE_TAG_DONTCOPY, session, flush, flush_msg_size);
			return 0;  // 删除消息
		} else if (strcmp(message->cmd, "APPEND") == 0) {
			struct xlogger_append_request *append_request = CAST_USERTYPE_POINTER(message, struct xlogger_append_request);
			xloggerdd_push(inst->d, append_request);
			xloggerdd_flush(inst->d);

			return 1;  // 保留消息
		} else if (strcmp(message->cmd, "CLOSE") == 0) {
			assert(0);
			/*size_t closeres_message_size = sizeof(struct message);
			struct message *closeres = skynet_malloc(closeres_message_size);
			const char *cmd = "CLOSE";
			memcpy(closeres->cmd, cmd, strlen(cmd));

			skynet_sendname(context, source, ".xlogger", PTYPE_TEXT | PTYPE_TAG_DONTCOPY, session, closeres, closeres_message_size);*/

			return 0;
		} else {
			assert(0);
		}
	}
	return 0;
}

int
xloggerd_init(struct xloggerd * inst, struct skynet_context *ctx, const char * parm) {
	xloggerdd_init(inst->d);
	skynet_callback(ctx, inst, _logger);
	skynet_command(ctx, "REG", ".xloggerd");
	return 0;
}
