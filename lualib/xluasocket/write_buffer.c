#include "write_buffer.h"
#include "xluaconf.h"
#include "util.h"
#include <stdlib.h>
#include <string.h>
#include <assert.h>

struct write_buffer {
	struct write_buffer * next;
	char *ptr;
	int len;
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
	int n = send(fd, ptr->ptr, ptr->buffer + ptr->len - ptr->ptr, 0);
	if (n > 0) {
		ptr->ptr = ptr->ptr + n;
	}
	return n;
}

bool
wb_is_empty(struct write_buffer *wb) {
	return (wb->ptr == (wb->buffer + wb->len)) ? true : false;
}

struct wb_list*
	wb_list_new() {
	struct wb_list* list = MALLOC(sizeof(*list));
	list->head = NULL;
	list->tail = NULL;
	list->freelist = NULL;
	return list;
}

void
wb_list_free(struct wb_list* list) {
	struct write_buffer *first = list->head;
	while (first) {
		struct write_buffer *tmp = first;
		first = first->next;
		FREE(tmp->buffer);
		FREE(tmp);
	}
}

struct write_buffer *
	wb_list_alloc_wb(struct wb_list* list) {
	struct write_buffer *ptr = NULL;
	if (list->freelist != NULL) {
		ptr = list->freelist;
		list->freelist = list->freelist->next;
	} else {
		ptr = MALLOC(sizeof(*ptr) + list->wb_size);
	}
	memset(ptr, 0, sizeof(*ptr) + list->wb_size);
	ptr->cap = list->wb_size;
	ptr->ptr = ptr->buffer;
	return ptr;
}

void
wb_list_free_wb(struct wb_list* list, struct write_buffer *wb) {
	if (list->freelist == NULL) {
		list->freelist = wb;
	} else {
		struct write_buffer *ptr = list->freelist;
		while (ptr->next != NULL) {
			ptr = ptr->next;
		}
		ptr->next = wb;
	}
	wb->next = NULL;
}

void
wb_list_push(struct wb_list* list, uint8_t header, char *buffer, int sz) {
	assert(list->wb_size >= sz);
	struct write_buffer *wb = wb_list_alloc_wb(list);
	if (header == HEADER_TYPE_PG) {
		int22bytes_bd(sz, wb->buffer, 0, 2);
		int csz = (sz > (wb->cap - 2)) ? (wb->cap - 2) : (sz);
		memcpy(wb->buffer + 2, buffer, csz);
		int n = csz;
		wb->len = csz;
		wb_list_push_wb(list, wb);
		while (n < sz) {
			wb = wb_list_alloc_wb(list);
			csz = (sz > (wb->cap)) ? (wb->cap) : (sz);
			memcpy(wb->buffer, buffer + n, csz);
			n += csz;
			wb->len = csz;
			wb_list_push_wb(list, wb);
		}
	} else if (header == HEADER_TYPE_LINE) {
		struct write_buffer *wb = NULL;
		int n = 0;
		while (n < sz) {
			wb = wb_list_alloc_wb(list);
			int csz = ((sz) > (WRITE_BUFFER_SIZE)) ? (WRITE_BUFFER_SIZE) : sz;
			memcpy(wb->buffer, buffer, csz);
			n += csz;
			wb->len = csz;
			wb_list_push_wb(list, wb);
		}
		wb = wb_list_pop(list);
		if (wb->len < wb->cap) {
			wb->buffer[wb->len] = '\n';
			wb->len = wb->len + 1;
		} else {
			wb = wb_list_alloc_wb(list);
			wb->buffer[0] = '\n';
			wb->len = 1;
			wb_list_push_wb(list, wb);
		}
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
