#include "write_buffer.h"
#include "xluaconf.h"
#include "protoc.h"
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>

struct write_buffer {
	struct write_buffer * next;
	char *ptr;                 // send ptr
	int len;                   // pack ptr
	int cap;
	char buffer[0];
};

struct wb_list {
	struct write_buffer * head;
	struct write_buffer * tail;
	struct write_buffer * freelist;
	int wb_size;
};

int
wb_write_fd(struct write_buffer *ptr, int fd) {
	assert(ptr != NULL);
	char buffer[1024] = { 0 };
	int count = min(1024, (ptr->buffer + ptr->len - ptr->ptr));
	memcpy(buffer, ptr->ptr, count);
	printf("prof write fd %s", buffer);
	int n = send(fd, ptr->ptr, (ptr->buffer + ptr->len - ptr->ptr), 0);
	if (n > 0) {
		ptr->ptr = ptr->ptr + n;
	}
	return n;
}

bool
wb_is_empty(struct write_buffer *wb) {
	return (wb->ptr == (wb->buffer + wb->len)) ? true : false;
}

int
wb_bytes_free(struct write_buffer *wb) {
	return (wb->cap - wb->len);
}

struct wb_list*
	wb_list_new(int size) {
	struct wb_list* list = MALLOC(sizeof(*list));
	list->head = NULL;
	list->tail = NULL;
	list->freelist = NULL;
	list->wb_size = size;
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
}

struct write_buffer *
	wb_list_alloc_wb(struct wb_list* list) {
	struct write_buffer *ptr = list->freelist;
	if (ptr == NULL) {
		assert(list->wb_size > 0);
		ptr = MALLOC(sizeof(*ptr) + list->wb_size);
	} else {
		list->freelist = list->freelist->next;
	}
	memset(ptr, 0, sizeof(*ptr) + list->wb_size);
	ptr->cap = list->wb_size;
	ptr->ptr = ptr->buffer;
	return ptr;
}

void
wb_list_free_wb(struct wb_list* list, struct write_buffer *wb) {
	assert(list && wb);
	wb->next = list->freelist;
	list->freelist = wb;
}

void
wb_list_push_string(struct wb_list* list, char *buffer, int sz) {
	struct write_buffer *wb = wb_list_pop(list);
	if (wb == NULL) {
		wb = wb_list_alloc_wb(list);
	}
	if (wb_bytes_free(wb) < 2) {
		wb_list_push_wb(list, wb);
		wb = wb_list_alloc_wb(list);
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
			wb = wb_list_alloc_wb(list);
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
			wb = wb_list_alloc_wb(list);
		} else if (wb_bytes_free(wb) < sz) {
			wb_list_push_wb(list, wb);
			wb = wb_list_alloc_wb(list);
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
		wb = wb_list_alloc_wb(list);
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
