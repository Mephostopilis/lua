#include "write_buffer.h"
#include "protoc.h"
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>

#if defined(_MSC_VER)
#include <Windows.h>
#include <math.h>
#define MAX max
#define MIN min
#else
#define MAX(a,b) (((a) > (b)) ? (a) : (b))
#define MIN(a,b) (((a) < (b)) ? (a) : (b))
#endif

#if !defined(MALLOC)
#define MALLOC malloc
#endif

#if !defined(FREE)
#define FREE free
#endif

#define WRITE_BUFFER_SIZE (8)

struct wb_list {
	struct write_buffer * head;
	struct write_buffer * tail;
	struct write_buffer * freelist;
	int count;  // 统计分配的wb数量
};

#if defined(XLUASOCKET)
int
wb_write_fd(struct write_buffer *wb, int fd) {
	assert(wb != NULL);
	int n = send(fd, wb->ptr, (wb->buffer + wb->len - wb->ptr), 0);
	if (n > 0) {
#if defined(_DEBUG)
		int sz = (wb->buffer + wb->len - wb->ptr);
		char *buffer = (char *)malloc(sz + 1);
		memset(buffer, 0, sz + 1);
		memcpy(buffer, wb->ptr, sz);
		printf("prof write fd [[%s]] ---------- \n", buffer);
		free(buffer);
#endif
		wb->ptr += n;
	}
	return n;
}
#endif

bool
wb_is_empty(struct write_buffer *wb) {
	return (wb->ptr == (wb->buffer + wb->len)) ? true : false;
}

int
wb_bytes_free(struct write_buffer *wb) {
	return (wb->cap - wb->len);
}

struct wb_list*
	wb_list_new() {
	struct wb_list* list = MALLOC(sizeof(*list));
	list->head = NULL;
	list->tail = NULL;
	list->freelist = NULL;
	list->count = 0;
	return list;
}

void
wb_list_free(struct wb_list* list) {
	struct write_buffer *first = list->head;
	while (first) {
		struct write_buffer *tmp = first;
		first = first->next;
		FREE(tmp);
	}
	first = list->freelist;
	while (first) {
		struct write_buffer *tmp = first;
		first = first->next;
		FREE(tmp);
	}
}

size_t
wb_list_size(struct wb_list* list) {
	size_t size = 0;
	struct write_buffer *wb = list->head;
	while (wb) {
		size++;
		wb = wb->next;
	}
	return size;
}

struct write_buffer *
	wb_list_alloc_wb(struct wb_list* list, int hint) {
	int offset = WRITE_BUFFER_SIZE;
	struct write_buffer *ptr = list->freelist;
	if (ptr == NULL) {
		while ((1 << offset) < hint) {
			++offset;
		}
		ptr = MALLOC(sizeof(*ptr) + (1 << offset));
		list->count++;
		goto LABLE;
	}

	// 寻找大于此内存的
	if (ptr->cap < hint) {
		for (struct write_buffer *p = ptr->next; p != NULL; ptr = p, p = p->next) {
			if (p->cap > hint) {
				ptr->next = p->next;
				ptr = p;
				goto LABLE;
			}
		}
		// foreach over
		assert(ptr->next == NULL);
		ptr = NULL;
	} else {
		list->freelist = ptr->next;
	}
LABLE:
	if (ptr == NULL) {
		while ((1 << offset) < hint) {
			++offset;
		}
		ptr = MALLOC(sizeof(*ptr) + (1 << offset));
		list->count++;
	}

	ptr->next = NULL;
	ptr->cap = 1 << offset;
	ptr->len = 0;
	ptr->ptr = ptr->buffer;
	memset(ptr->buffer, 0, ptr->cap);
	return ptr;
}

void
wb_list_free_wb(struct wb_list* list, struct write_buffer *wb) {
	assert(list && wb);
	wb->ptr = wb->buffer;
	wb->len = 0;
	wb->next = list->freelist;
	list->freelist = wb;
}

void
wb_list_push_string(struct wb_list* list, char *buffer, int sz) {
	assert(list != NULL);
	if (buffer == NULL) {
		return;
	}
	if (sz <= 0) {
		return;
	}

	struct write_buffer *wb = wb_list_alloc_wb(list, sz + 2);
	int ofs = WriteInt16(wb->buffer + wb->len, 0, sz);
	wb->len += ofs;
	assert(wb_bytes_free(wb) >= sz);
	memcpy(wb->buffer + wb->len, buffer, sz);
	wb->len += sz;
	wb_list_push_wb(list, wb);
}

void
wb_list_push_line(struct wb_list* list, char *buffer, int sz) {
	assert(list != NULL);
	if (buffer == NULL) {
		return;
	}
	if (sz <= 0) {
		return;
	}
	struct write_buffer *wb = wb_list_alloc_wb(list, sz + 1);
	assert(wb != NULL);
	assert(wb->cap > sz);
	memcpy(wb->buffer, buffer, sz);
	wb->buffer[sz] = '\n';
	wb->len = sz + 1;
	wb_list_push_wb(list, wb);
}

void
wb_list_push_wb(struct wb_list* list, struct write_buffer *wb) {
	if (list->head == NULL) {
		list->head = wb;
		list->tail = wb;
	} else {
		list->tail->next = wb;
		list->tail = wb;
	}
	list->tail->next = NULL;
}

struct write_buffer*
	wb_list_pop(struct wb_list* list) {
	if (list->head == NULL) {
		return NULL;
	} else if (list->head == list->tail) {
		struct	write_buffer* ptr = list->head;
		list->head = list->tail = NULL;
		return ptr;
	} else {
		struct	write_buffer* ptr = list->head;
		list->head = list->head->next;
		return ptr;
	}
}
