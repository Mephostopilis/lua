#include "ringbuf.h"

int main(int argv, char * argc[]) {
	ringbuf_t *rb = ringbuf_new(5);
	void *head = ringbuf_memcpy_into(rb, "hello, world", 10);

	char buf[100] = { 0 };
	ringbuf_memcpy_from(buf, rb, 5);

	return 0;
}