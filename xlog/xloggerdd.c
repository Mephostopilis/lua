#include "xloggerdd.h"
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
#define XLOG_MAXPATHLEN      MAX_PATH
#else
#include <unistd.h>
#include <dirent.h>
#include <limits.h>
#define XLOG_MAXPATHLEN      PATH_MAX
#endif // DEBUG

#define ONE_MB	          (1024*1024)
#define DEFAULT_ROLL_SIZE (128*ONE_MB)		// ��־�ļ��ﵽ512M������һ�����ļ�
#define DEFAULT_PATH      ("logs")
#define DEFAULT_INTERVAL  (5)			    // ��־ͬ�������̼��ʱ��

struct xloggerdd {
	int initd;
	char basepath[XLOG_MAXPATHLEN];
	logger_level loglevel;  // 在這之上才落地
	time_t pt;              // 开始七点
	size_t rollsize;        // �ļ����ʱ�����
	size_t allocsize;       // 统计内存大小
	size_t freesize;
	size_t mocksize;
	size_t wirtesize;
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
	DIR* dir = opendir(fullpath);
	if (dir == NULL) {
		switch (errno) {
		case ENOENT:
			if (mkdir(fullpath, 0755) == -1) {
				fprintf(stderr, "mkdir error: %s\n", strerror(errno));
				return XLOG_ERR_MKDIR;
			}
			break;
		default:
			fprintf(stderr, "opendir error: %s\n", strerror(errno));
			return XLOG_ERR_MKDIR;
		}
		return XLOG_OK;
	} else
		closedir(dir);
#endif
	return XLOG_ERR_EXISTS_DIR;
}

// basepath + filename.log
static size_t
get_filename(char *basepath, int count, logger_level level, char *ofilename, size_t fhint) {
	assert(basepath != NULL);
	assert(level >= LOG_DEBUG && level < LOG_MAX);
	assert(ofilename != NULL);

	time_t cs = time(NULL);

#if defined(_MSC_VER)
	if (level == LOG_DEBUG) {
		return snprintf(ofilename, fhint, "%s\\%llu-%s.log", basepath, cs, "debug");
	} else if (level == LOG_INFO) {
		return snprintf(ofilename, fhint, "%s\\%llu-%s.log", basepath, cs, "info");
	} else if (level == LOG_WARNING) {
		return snprintf(ofilename, fhint, "%s\\%llu-%s.log", basepath, cs, "warning");
	} else if (level == LOG_ERROR) {
		return snprintf(ofilename, fhint, "%s\\%llu-%s.log", basepath, cs, "error");
	} else if (level == LOG_FATAL) {
		return snprintf(ofilename, fhint, "%s\\%llu-%s.log", basepath, cs, "fatal");
	}
#else
	if (level == LOG_DEBUG) {
		return snprintf(ofilename, fhint, "%s/%llu-%s.log", basepath, cs, "debug");
	} else if (level == LOG_INFO) {
		return snprintf(ofilename, fhint, "%s/%llu-%s.log", basepath, cs, "info");
	} else if (level == LOG_WARNING) {
		return snprintf(ofilename, fhint, "%s/%llu-%s.log", basepath, cs, "warning");
	} else if (level == LOG_ERROR) {
		return snprintf(ofilename, fhint, "%s/%llu-%s.log", basepath, cs, "error");
	} else if (level == LOG_FATAL) {
		return snprintf(ofilename, fhint, "%s/%llu-%s.log", basepath, cs, "fatal");
	}
#endif
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
				basepath[k++] = '/';
#endif // _MSC_VER
			continue;
		}
		return err;
	}
	*sz = k;
	return XLOG_OK;
}

static int
xloggerdd_init_(struct xloggerdd *self) {

	int i = self->loglevel;
	for (; i < LOG_MAX; i++) {
		// create
		char path[XLOG_MAXPATHLEN] = { 0 };
		size_t psz = xloggerdd_gen_dir_(self, path, XLOG_MAXPATHLEN);

		char fullpath[XLOG_MAXPATHLEN] = { 0 };
		size_t len = get_filename(path, psz, i, fullpath, XLOG_MAXPATHLEN);
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

static size_t
xloggerdd_gen_dir_(struct xloggerdd *self, char *fullpath, size_t hint) {
	if (fullpath == NULL) {
		return 0;
	}
	char path[XLOG_MAXPATHLEN] = { 0 };
	size_t sz = 0;
	struct tm *ntm = localtime(&self->pt);
	char timebuf[32] = { 0 };
	strftime(timebuf, sizeof(timebuf), "%Y%m%d", ntm);
#if defined(_MSC_VER)
	sz = snprintf(path, XLOG_MAXPATHLEN, "%s\\%s", self->basepath, timebuf);
#else
	sz = snprintf(path, XLOG_MAXPATHLEN, "%s/%s", self->basepath, timebuf);
#endif

	strncpy(fullpath, path, sz);
	return sz;
}

struct xloggerdd *
	xloggerdd_create(const char *path, logger_level loglevel, size_t rollsize) {
	// check path
	int sz = 0;
	char basepath[XLOG_MAXPATHLEN] = { 0 };
	if (check_dir(path, basepath, &sz)) {
		fprintf(stderr, "path is wrong\n");
		return NULL;
	}
	// check loglevel
	if (loglevel < LOG_DEBUG || loglevel > LOG_FATAL) {
		return NULL;
	}
	// check rollsize
	if (rollsize > 0) {
		rollsize = rollsize * ONE_MB;
	} else {
		rollsize = DEFAULT_ROLL_SIZE;
	}
	// create
	struct xloggerdd *inst = (struct xloggerdd *)MALLOC(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	strncpy(inst->basepath, basepath, strlen(basepath));
	inst->loglevel = loglevel;
	inst->rollsize = rollsize;

	INIT_LIST_HEAD(&inst->head);

	xloggerdd_check_date(inst);
	inst->initd = 1;
	return inst;
}

void
xloggerdd_release(struct xloggerdd *self) {
	xloggerdd_flush(self);
	int i = self->loglevel;
	for (; i < LOG_MAX; i++) {
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
	list_add_tail(&request->head, &self->head);
	return XLOG_OK;
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
		if (f == NULL) {
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
		self->wirtesize += nbytes;
		self->freesize += sizeof(struct xlogger_append_request) + request->size;
		self->mocksize += sizeof(struct xlogger_append_request) + nbytes;
		FREE(request);
	}
	INIT_LIST_HEAD(&self->head);

	int i = self->loglevel;
	for (; i < LOG_MAX; i++) {
		FILE *f = self->handle[i];
		if (f == NULL) {
			continue;
		}
		fflush(f);
	}
	return XLOG_OK;
}

int
xloggerdd_check_roll(struct xloggerdd *self) {
	// check self
	if (self == NULL) {
		return XLOG_ERR_PARAM;
	}
	/*if (self->initd == 0) {
		return XLOG_NOT_INITED;
	}*/

	// check roll
	int i = self->loglevel;
	for (; i < LOG_MAX; i++) {
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
	// 获得文件
	xloggerdd_init_(self);
	return XLOG_OK;
}

int
xloggerdd_check_date(struct xloggerdd *self) {
	// 日期到了
	time_t cs = time(NULL);
	if (cs == self->pt) {
		return XLOG_OK;
	}
	struct tm *ltm = localtime(&self->pt);
	struct tm *tm = localtime(&cs);
	if (tm->tm_year == ltm->tm_year && tm->tm_yday == tm->tm_yday) {
		if (self->initd == 0) {
			goto entry;
		}
		return XLOG_OK;
	}
entry:
	self->pt = cs;
	// 关掉所有文件
	int i = self->loglevel;
	for (; i < LOG_MAX; i++) {
		FILE *f = self->handle[i];
		if (f == NULL) {
			continue;
		}
		fclose(f);
		self->handle[i] = NULL;
	}

	// 获取日期文件夹
	char path[XLOG_MAXPATHLEN] = { 0 };
	size_t sz = xloggerdd_gen_dir_(self, path, XLOG_MAXPATHLEN);

	int err = check_and_create_dir_(path, XLOG_MAXPATHLEN);
	if (err > XLOG_ERR_EXISTS_DIR) {
		fprintf(stderr, "datepath is wrong\n");
		return err;
	}
	// 获得文件
	xloggerdd_init_(self);
	return XLOG_OK;
}