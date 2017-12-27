#include "ringbuf.h"
#include "write_buffer.h"
#include <assert.h>
#include <string.h>

int main(int argv, char * argc[]) {
	ringbuf_t *rb = ringbuf_new(5);
	int count = 100000;
	while (count--) {
		assert(ringbuf_write_int16(rb, 12) == 0);
		assert(ringbuf_bytes_used(rb) == 2);
		int16_t  n = 0;
		assert(ringbuf_read_int16(rb, &n) == 0);
		assert(ringbuf_bytes_used(rb) == 0);
		assert(n == 12);

		assert(ringbuf_write_int32(rb, 24) == 0);
		assert(ringbuf_bytes_used(rb) == 4);
		int32_t n1 = 0;
		assert(ringbuf_read_int32(rb, &n1) == 0);
		assert(ringbuf_bytes_used(rb) == 0);
		assert(n1 == 24);

		assert(ringbuf_write_string(rb, "hello", 5) == 0);
		assert(ringbuf_bytes_used(rb) == 7);
		uint8_t *out = NULL;
		int size = 0;
		assert(ringbuf_read_string(rb, &out, &size) == 0);
		assert(ringbuf_bytes_used(rb) == 0);
		assert(strncmp(out, "hello", size) == 0);
		assert(size == 5);

		assert(ringbuf_write_line(rb, "hello", 5) == 0);
		assert(ringbuf_bytes_used(rb) == 6);
		out = NULL;
		size = 0;
		assert(ringbuf_read_line(rb, &out, &size) == 0);
		assert(ringbuf_bytes_used(rb) == 0);
		assert(strncmp(out, "hello", size) == 0);
		assert(size == 5);

		assert(ringbuf_write_int16(rb, 12) == 0);
		assert(ringbuf_bytes_used(rb) == 2);
		assert(ringbuf_write_int32(rb, 24) == 0);
		assert(ringbuf_bytes_used(rb) == 6);
		assert(ringbuf_write_string(rb, "hello", 5) == 0);
		assert(ringbuf_bytes_used(rb) == 13);
		assert(ringbuf_write_line(rb, "hello", 5) == 0);
		assert(ringbuf_bytes_used(rb) == 19);

		assert(ringbuf_read_int16(rb, &n) == 0);
		assert(ringbuf_bytes_used(rb) == 17);
		assert(n == 12);

		n1 = 0;
		assert(ringbuf_read_int32(rb, &n1) == 0);
		assert(ringbuf_bytes_used(rb) == 13);
		assert(n1 == 24);

		out = NULL;
		size = 0;
		assert(ringbuf_read_string(rb, &out, &size) == 0);
		assert(ringbuf_bytes_used(rb) == 6);
		assert(strncmp(out, "hello", size) == 0);
		assert(size == 5);

		out = NULL;
		size = 0;
		assert(ringbuf_read_line(rb, &out, &size) == 0);
		assert(ringbuf_bytes_used(rb) == 0);
		assert(strncmp(out, "hello", size) == 0);
		assert(size == 5);
	}
	void *head = ringbuf_memcpy_into(rb, "hello, world", 10);
	char buf[100] = { 0 };
	ringbuf_memcpy_from(buf, rb, 5);

	// -----------------test write buffer ---------------------------

	struct wb_list* list = wb_list_new(10);
	wb_list_push_line(list, "hello world, ni hao.", 15);
	struct write_buffer *wb = wb_list_pop(list);


	system("pause");

	return 0;
}