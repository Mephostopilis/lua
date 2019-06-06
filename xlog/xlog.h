#ifndef XLOG_H
#define XLOG_H

typedef enum logger_level {
	LOG_DEBUG = 0,
	LOG_INFO,
	LOG_WARNING,
	LOG_ERROR,
	LOG_FATAL,
	LOG_MAX
} logger_level;

#define XLOG_OK 0
#define XLOG_ERR_EXISTS_DIR 1
#define XLOG_OVERfLOW_DIR_NAME 2
#define XLOG_ERR_MKDIR 3
#define XLOG_ERR_OPEN 4
#define XLOG_ERR_ALLOCNULL 5
#define XLOG_ERR_PARAM 6


#endif // !XLOG_H
