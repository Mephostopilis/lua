#include "xloggerdd.h"
#include "xlog.h"

#include "list.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <inttypes.h>

#ifdef _MSC_VER
#include <Windows.h>
#else
#include <unistd.h>
#include <dirent.h>
#endif // DEBUG

#define ONE_MB	          (1024*1024)
#define DEFAULT_ROLL_SIZE (128*ONE_MB)		// ��־�ļ��ﵽ512M������һ�����ļ�
#define DEFAULT_PATH      ("logs")
#define DEFAULT_INTERVAL  (5)			    // ��־ͬ�������̼��ʱ��
#define MAX_PATH_LEN      (128)
#define MALLOC malloc
#define FREE   free

struct xloggerdd {
	char path[MAX_PATH_LEN];
	logger_level loglevel;  // 在這之上才落地
	size_t rollsize;        // �ļ����ʱ�����
	size_t allocsize;
	FILE* handle[LOG_MAX];
	size_t written_bytes[LOG_MAX];	// ��д���ļ����ֽ���
	struct list_head head;  // 所有的
};

static size_t
get_file_size(const char *filename) {
	struct stat statbuff;
	if (stat(filename, &statbuff) < 0) {
		return -1;
	}
	return statbuff.st_size;
}

static int
check_and_create_dir_(char *fullpath, int count) {
#ifdef _MSC_VER
	BOOL bValue = FALSE;
	WIN32_FIND_DATA  FindFileData;
	HANDLE hFind = FindFirstFileA(fullpath, &FindFileData);
	if ((hFind != INVALID_HANDLE_VALUE) && (FindFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
		bValue = TRUE;
	}
	FindClose(hFind);
	if (!bValue) {
		CreateDirectoryA(fullpath, NULL);
		return XLOG_OK;
	}
#else
	// ��������ڣ������ļ���
	DIR* dir = opendir(basepath);
	if (dir == NULL) {
		switch (errno) {
		case ENOENT:
			if (mkdir(basepath, 0755) == -1) {
				fprintf(stderr, "mkdir error: %s\n", strerror(errno));
				return XLOG_ERR_MKDIR;
			}
			break;
		default:
			fprintf(stderr, "opendir error: %s\n", strerror(errno));
			return XLOG_ERR_MKDIR;
		}
		return XLOG_ERR_OK;
	} else
		closedir(dir);
#endif
	return XLOG_ERR_EXISTS_DIR;
}

static int
check_and_create_date_dir(const char *basepath, int basepathcount, char *datepath, int datepathcount, int *sz) {
	time_t cs = time(NULL);
	struct tm *tm = localtime(&cs);
	assert(tm != NULL);

	char timebuf[32] = { 0 };
	strftime(timebuf, sizeof(timebuf), "%Y%m%d", tm);
#if defined(_MSC_VER)
	*sz = snprintf(datepath, datepathcount, "%s\\%s", basepath, timebuf);
#else
	*sz = snprintf(datepath, datepathcount, "%s/%s", basepath, timebuf);
#endif
	return check_and_create_dir_(datepath, *sz);
}

static size_t
get_filename(char *datepath, int count, logger_level level, char *filename, size_t filename_count) {
	assert(level >= LOG_DEBUG && level < LOG_MAX);
	assert(filename != NULL);
	memset(filename, 0, count);

	time_t cs = time(NULL);
	struct tm *tm = localtime(&cs);
	assert(tm != NULL);

	char timebuf[32] = { 0 };
	strftime(timebuf, sizeof(timebuf), "%Y%m%d", tm);
#if defined(_MSC_VER)
	if (level == LOG_DEBUG) {
		snprintf(filename, filename_count, "%s\\%llu-%s.log", datepath, cs, "debug");
	} else if (level == LOG_INFO) {
		snprintf(filename, filename_count, "%s\\%llu-%s.log", datepath, cs, "info");
	} else if (level == LOG_WARNING) {
		snprintf(filename, filename_count, "%s\\%llu-%s.log", datepath, cs, "warning");
	} else if (level == LOG_ERROR) {
		snprintf(filename, filename_count, "%s\\%llu-%s.log", datepath, cs, "error");
	} else if (level == LOG_FATAL) {
		snprintf(filename, filename_count, "%s\\%llu-%s.log", datepath, cs, "fatal");
	}
#else 
	if (level == LOG_DEBUG) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "debug", cs);
	} else if (level == LOG_INFO) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "info", cs);
	} else if (level == LOG_WARNING) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "warning", cs);
	} else if (level == LOG_ERROR) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "error", cs);
	} else if (level == LOG_FATAL) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "fatal", cs);
	}
#endif
	return strlen(filename);
}

static int
check_file(const char *datepath, logger_level loglevel) {
	char fullpath[MAX_PATH_LEN] = { 0 };
	for (size_t i = loglevel; i < LOG_MAX; i++) {
		// create
		memset(fullpath, 0, MAX_PATH_LEN);
		size_t len = get_filename(datepath, strlen(datepath), i, fullpath, MAX_PATH_LEN);
		assert(len > 0);

		FILE *f = fopen(fullpath, "w+");
		if (f == NULL) {
#ifdef _MSC_VER
			DWORD dw = GetLastError();
			char buffer[128] = { 0 };
			if (FormatMessage(FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM,
				NULL,
				dw,
				0,
				buffer,
				sizeof(buffer) / sizeof(char),
				NULL)) {
				fprintf(stderr, "open file error: %s\n", buffer);
			}
#else
			fprintf(stderr, "open file error: %s\n", strerror(errno));
#endif // _MSC_VER
			return XLOG_ERR_OPEN;
		} else {
			fclose(f);
		}
	}
	return XLOG_OK;
}

/*
** @breif 只保证文件夹是存在的
** @return 0
*/
static int
check_dir(const char *path, char *basepath, int *sz) {
	char dir[32][32];  // max 32
	memset(dir, 0, 32 * 32);
	int len = strlen(path);
	int i = 0, j = 0, k = 0;
	for (; i < len; i++) {
		char t = path[i];
		if (t == '\\' || t == '/') {
			j++; k = 0; continue;
		}
		if (t == '.') {
			if (i + 1 < len) {
				char n1 = path[i + 1];
				if (n1 != '.') { // 
					if (i > 0) {
						char n2 = path[i - 1]; // 上一个
						if (n2 != '.')
							break; // 文件
					}
				}
			}
		}
		if (k >= 32) {
			return XLOG_OVERfLOW_DIR_NAME;
		}
		dir[j][k++] = t;
	}
	
	for (i = 0, k = 0; i <= j; i++) {
		len = strlen(dir[i]);
		memcpy(basepath + k, dir[i], len);
		k += len;
		int err = check_and_create_dir_(basepath, k);
		if (err == XLOG_OK ||
			err == XLOG_ERR_EXISTS_DIR) {
#ifdef _MSC_VER
			if (i < j)
				basepath[k++] = '\\';
#else
			if (i < j)
				fullpath[k++] = '/';
#endif // _MSC_VER
			continue;
		}
		return err;
	}
	*sz = k;
	return XLOG_OK;
}


static int
xloggerdd_init_(struct xloggerdd *self, const char *datepath) {
	char fullpath[MAX_PATH_LEN] = { 0 };
	for (size_t i = self->loglevel; i < LOG_MAX; i++) {
		// create
		memset(fullpath, 0, MAX_PATH_LEN);
		size_t len = get_filename(datepath, strlen(datepath), i, fullpath, MAX_PATH_LEN);
		assert(len > 0);

		if (self->handle[i] == NULL) {
			FILE *f = fopen(fullpath, "w+");
			if (f == NULL) {
#ifdef _MSC_VER
				DWORD dw = GetLastError();
				char buffer[128] = { 0 };
				if (FormatMessage(FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM,
					NULL,
					dw,
					0,
					buffer,
					sizeof(buffer) / sizeof(char),
					NULL)) {
					fprintf(stderr, "open file error: %s\n", buffer);
				}
#else
				fprintf(stderr, "open file error: %s\n", strerror(errno));
#endif // _MSC_VER
				f = stdout;
			}
			self->handle[i] = f;
		}
	}
	return XLOG_OK;
}

struct xloggerdd *
xloggerdd_create(const char *path, logger_level loglevel, size_t rollsize) {
	// check path
	int sz = 0;
	char basepath[MAX_PATH_LEN] = { 0 };
	if (check_dir(path, basepath, &sz)) {
		fprintf(stderr, "path is wrong\n");
		return NULL;
	}
	char datepath[MAX_PATH_LEN] = { 0 };
	int datepathsz = 0;
	int err = check_and_create_date_dir(basepath, sz, datepath, MAX_PATH_LEN, &datepathsz);
	if (err > XLOG_ERR_EXISTS_DIR) {
		fprintf(stderr, "datepath is wrong\n");
		return NULL;
	}
	if (check_file(datepath, loglevel)) {
		fprintf(stderr, "open file failture\n");
		return NULL;
	}
	if (loglevel < LOG_DEBUG || loglevel >= LOG_MAX) {
		fprintf(stderr, "logleve is %d\n", loglevel);
		return NULL;
	}
	if (path != NULL && strlen(path) >= MAX_PATH_LEN) {
		fprintf(stderr, "path len more than %d\n", MAX_PATH_LEN);
		return NULL;
	}
	struct xloggerdd *inst = (struct xloggerdd *)MALLOC(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	inst->loglevel = loglevel;
	if (rollsize > 0) {
		inst->rollsize = rollsize * ONE_MB;
	} else {
		inst->rollsize = DEFAULT_ROLL_SIZE;
	}
	
	if (path == NULL)
		strncpy(inst->path, DEFAULT_PATH, strlen(DEFAULT_PATH));
	else {
		strncpy(inst->path, basepath, strlen(basepath));
	}

	INIT_LIST_HEAD(&inst->head);

	xloggerdd_init_(inst, datepath);
	return inst;
}

void
xloggerdd_release(struct xloggerdd *self) {
	xloggerdd_flush(self);
	for (size_t i = self->loglevel; i < LOG_MAX; i++) {
		FILE *f = self->handle[i];
		if (f == NULL || f == stdout) {
			continue;
		}
		fclose(f);
		self->handle[i] = NULL;
	}
	FREE(self);
}

int 
xloggerdd_log(struct xloggerdd *self, logger_level level, const char *buf, size_t len) {
	if (len <= 0 || buf == NULL) {
		return XLOG_ERR_PARAM;
	}
	size_t allocsz = sizeof(struct xlogger_append_request) + len;
	struct xlogger_append_request *request = MALLOC(allocsz);
	if (request == NULL) {
		return XLOG_ERR_ALLOCNULL;
	}
	request->level = level;
	request->size = len;
	memcpy(request->buffer, buf, len);
	self->allocsize += allocsz;
	xloggerdd_push(self, request);
	return XLOG_OK;
}

int
xloggerdd_push(struct xloggerdd *self, struct xlogger_append_request *request) {
	list_add_tail(&request->head, &self->head);
	return 0;
}

int
xloggerdd_flush(struct xloggerdd *self) {
	struct list_head *pos = NULL, *n = NULL;
	list_for_each_safe(pos, n, &self->head) {
		struct xlogger_append_request *request = (struct xlogger_append_request *)pos;
		if (request->level < self->loglevel) {
			//printf(request->buffer);
			FREE(request);
			continue;
		}
		assert(request->level >= LOG_DEBUG && request->level < LOG_MAX);
		FILE *f = self->handle[request->level];
		if (f == NULL || f == stdout) {
			FREE(request);
			continue;
		}
		size_t nbytes = 0;
		while (nbytes < request->size) {
#ifdef _MSC_VER
			size_t nn = _fwrite_nolock(request->buffer + nbytes, 1, request->size - nbytes, f);
#else
			size_t nn = fwrite_unlocked(request->buffer + nbytes, 1, request->size - nbytes, f);
#endif // _MSC_VER
			nbytes += nn;
		}
		self->written_bytes[request->level] += nbytes;
		FREE(request);
	}
	INIT_LIST_HEAD(&self->head);

	for (size_t i = self->loglevel; i < LOG_MAX; i++) {
		FILE *f = self->handle[i];
		if (f == NULL) {
			continue;
		}
		fflush(f);
	}
	return 0;
}

int
xloggerdd_check_roll(struct xloggerdd *self) {
	// 日期到了
    char datepath[MAX_PATH_LEN] = { 0 };
	int sz = 0;
	if (!check_and_create_date_dir(self->path, strlen(self->path), datepath, MAX_PATH_LEN, &sz)) {
		// 没有并且创建了,初始新文件
		xloggerdd_init_(self, datepath);
	}

	// check roll
	for (size_t i = self->loglevel; i < LOG_MAX; i++) {
		FILE *f = self->handle[i];
		if (f == NULL) {
			continue;
		}
		size_t nbytes = self->written_bytes[i];
		if (nbytes > self->rollsize) {
			fclose(f);
			self->handle[i] = NULL;
		}
	}
	xloggerdd_init_(self, datepath);
	return XLOG_OK;
}