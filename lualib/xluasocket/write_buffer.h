#ifndef WRITE_BUFFER_H
#define WRITE_BUFFER_H

#include <stdint.h>
#include <stdbool.h>

struct write_buffer;
struct wb_list;

int
wb_write_fd(struct write_buffer *wb, int fd);

/*
** @ send is empty
*/
bool
wb_is_empty(struct write_buffer *wb);

int
wb_bytes_free(struct write_buffer *wb);

struct wb_list*
wb_list_new(int size);

void
wb_list_free(struct wb_list* list);

struct write_buffer *
wb_list_alloc_wb(struct wb_list* list);

void
wb_list_free_wb(struct wb_list* list, struct write_buffer *wb);

void
wb_list_push_string(struct wb_list* list, char *buffer, int sz);

void
wb_list_push_line(struct wb_list* list, char *buffer, int sz);

void
wb_list_push_wb(struct wb_list* list, struct write_buffer *wb);

struct write_buffer*
wb_list_pop(struct wb_list* list);

#endif