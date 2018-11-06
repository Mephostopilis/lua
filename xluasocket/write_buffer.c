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
wb_write_fd(struct write_buffer *ptr, int fd) {
	assert(ptr != NULL);
	char buffer[1024] = { 0 };
	int count = MIN(1024, (ptr->buffer + ptr->len - ptr->ptr));
	memcpy(buffer, ptr->ptr, count);
#if defined(_DEBUG)
	printf("prof write fd [[%s]] ---------- \n", buffer);
#endif
	int n = send(fd, ptr->ptr, count, 0);
	if (n > 0) {
		ptr->ptr = ptr->ptr + n;
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
		goto LABLE;
	}

	// 寻找大于此内存的
	if (ptr->cap < hint) {
		while (ptr->next != NULL) {
			if (ptr->next->cap > hint) {
				struct write_buffer *tmp = ptr->next;
				ptr->next = ptr->next->next;
				ptr = tmp;
				goto LABLE;
			}
			ptr = ptr->next;
		}
		if (ptr->next == NULL) {
			ptr = NULL;
		}
	}
LABLE:
	if (ptr == NULL) {
		while ((1 << offset) < hint) {
			++offset;
		}
		ptr = MALLOC(sizeof(*ptr) + (1 << offset));
	}

	ptr->next = NULL;
	ptr->cap = 1 << offset;
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
	struct write_buffer *wb = wb_list_pop(list);
	if (wb == NULL) {
		wb = wb_list_alloc_wb(list, sz);
	}
	if (wb_bytes_free(wb) < 2) {
		wb_list_push_wb(list, wb);
		wb = wb_list_alloc_wb(list, sz);
	}
	int ofs = WriteInt16(wb->buffer + wb->len, 0, sz);
	wb->len += ofs;
	int n = 0;
	int realsz = ((sz - n) > (wb_bytes_free(wb))) ? (wb_bytes_free(wb)) : (sz - n);
	memcpy(wb->buffer + wb->len, buffer, realsz);
	n += realsz;
	wb->len += realsz;
	wb_list_push_wb(list, wb);

	while (n < sz) {
		wb = wb_list_pop(list);
		if (wb_bytes_free(wb) < (sz - n)) {
			wb_list_push_wb(list, wb);
			wb = wb_list_alloc_wb(list, sz);
		}
		realsz = ((sz - n) > (wb_bytes_free(wb))) ? (wb_bytes_free(wb)) : (sz - n);
		memcpy(wb->buffer + wb->len, buffer + n, realsz);
		n += realsz;
		wb->len += realsz;
		wb_list_push_wb(list, wb);
	}
}

void
wb_list_push_line(struct wb_list* list, char *buffer, int sz) {
	struct write_buffer *wb = wb_list_pop(list);
	int n = 0;
	while (n < sz) {
		if (wb == NULL) {
			wb = wb_list_alloc_wb(list, sz);
		} else if (wb_bytes_free(wb) < sz) {
			wb_list_push_wb(list, wb);
			wb = wb_list_alloc_wb(list, sz);
		}

		int realsz = ((sz - n) > wb_bytes_free(wb)) ? (wb_bytes_free(wb)) : (sz - n);
		memcpy(wb->buffer + wb->len, buffer + n, realsz);
		n += realsz;
		wb->len += realsz;
	}
	if (wb->len < wb->cap) {
		wb->buffer[wb->len] = '\n';
		wb->len = wb->len + 1;
		wb_list_push_wb(list, wb);
	} else {
		wb_list_push_wb(list, wb);
		wb = wb_list_alloc_wb(list, sz);
		wb->buffer[0] = '\n';
		wb->len = 1;
		wb_list_push_wb(list, wb);
	}
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
