/*
** 缓存发送数据
*/

#ifndef WRITE_BUFFER_H
#define WRITE_BUFFER_H

#include <stdint.h>
#include <stdbool.h>

struct write_buffer {
	struct write_buffer * next;
	char *ptr;                 // send ptr
	int len;                   // pack ptr
	int cap;
	char buffer[0];
};

struct wb_list;

#if defined(XLUASOCKET)
int
wb_write_fd(struct write_buffer *wb, int fd);
#endif

/*
** @ send is empty
*/
bool
wb_is_empty(struct write_buffer *wb);

int
wb_bytes_free(struct write_buffer *wb);

struct wb_list*
wb_list_new();

void
wb_list_free(struct wb_list* list);

size_t
wb_list_size(struct wb_list* list);

struct write_buffer *
wb_list_alloc_wb(struct wb_list* list, int hint);

void
wb_list_free_wb(struct wb_list* list, struct write_buffer *wb);

void
wb_list_push_string(struct wb_list* list, char *buffer, int sz);

void
wb_list_push_line(struct wb_list* list, char *buffer, int sz);

void
wb_list_push_buffer(struct wb_list* list, char *buffer, int sz);

void
wb_list_push_wb(struct wb_list* list, struct write_buffer *wb);

struct write_buffer*
wb_list_pop(struct wb_list* list);

#endif