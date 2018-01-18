extern "C" {
#include "ringbuf.h"
#include "write_buffer.h"
}
#include <string.h>
#include <gtest/gtest.h>

namespace {

	TEST(RINGBUFTest, Write) {
		ringbuf_t *rb = ringbuf_new(5);
		EXPECT_EQ(1, 1);
		EXPECT_EQ(2, 2);
		EXPECT_EQ(ringbuf_write_int16(rb, 12), 0);
		EXPECT_EQ(ringbuf_bytes_used(rb), 2);
		int16_t  n = 0;
		EXPECT_EQ(ringbuf_read_int16(rb, &n), 0);
		EXPECT_EQ(ringbuf_bytes_used(rb), 0);
		EXPECT_EQ(n, 12);
	}
	TEST(RingbufReadTest, Read) {
		EXPECT_EQ(1, 1);
	}

	/*EXPECT_EQ(ringbuf_write_int32(rb, 24) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 4);
	int32_t n1 = 0;
	EXPECT_EQ(ringbuf_read_int32(rb, &n1) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 0);
	EXPECT_EQ(n1 == 24);

	EXPECT_EQ(ringbuf_write_string(rb, "hello", 5) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 7);
	uint8_t *out = NULL;
	int size = 0;
	EXPECT_EQ(ringbuf_read_string(rb, &out, &size) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 0);
	EXPECT_EQ(strncmp(out, "hello", size) == 0);
	EXPECT_EQ(size == 5);

	EXPECT_EQ(ringbuf_write_line(rb, "hello", 5) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 6);
	out = NULL;
	size = 0;
	EXPECT_EQ(ringbuf_read_line(rb, &out, &size) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 0);
	EXPECT_EQ(strncmp(out, "hello", size) == 0);
	EXPECT_EQ(size == 5);

	EXPECT_EQ(ringbuf_write_int16(rb, 12) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 2);
	EXPECT_EQ(ringbuf_write_int32(rb, 24) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 6);
	EXPECT_EQ(ringbuf_write_string(rb, "hello", 5) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 13);
	EXPECT_EQ(ringbuf_write_line(rb, "hello", 5) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 19);

	EXPECT_EQ(ringbuf_read_int16(rb, &n) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 17);
	EXPECT_EQ(n == 12);

	n1 = 0;
	EXPECT_EQ(ringbuf_read_int32(rb, &n1) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 13);
	EXPECT_EQ(n1 == 24);

	out = NULL;
	size = 0;
	EXPECT_EQ(ringbuf_read_string(rb, &out, &size) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 6);
	EXPECT_EQ(strncmp(out, "hello", size) == 0);
	EXPECT_EQ(size == 5);

	out = NULL;
	size = 0;
	EXPECT_EQ(ringbuf_read_line(rb, &out, &size) == 0);
	EXPECT_EQ(ringbuf_bytes_used(rb) == 0);
	EXPECT_EQ(strncmp(out, "hello", size) == 0);
	EXPECT_EQ(size == 5);*/

}

//int main(int argv, char * argc[]) {
//	ringbuf_t *rb = ringbuf_new(5);
//	int count = 100000;
//	while (count--) {
//		EXPECT_EQ(ringbuf_write_int16(rb, 12) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 2);
//		int16_t  n = 0;
//		EXPECT_EQ(ringbuf_read_int16(rb, &n) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 0);
//		EXPECT_EQ(n == 12);
//
//		EXPECT_EQ(ringbuf_write_int32(rb, 24) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 4);
//		int32_t n1 = 0;
//		EXPECT_EQ(ringbuf_read_int32(rb, &n1) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 0);
//		EXPECT_EQ(n1 == 24);
//
//		EXPECT_EQ(ringbuf_write_string(rb, "hello", 5) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 7);
//		uint8_t *out = NULL;
//		int size = 0;
//		EXPECT_EQ(ringbuf_read_string(rb, &out, &size) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 0);
//		EXPECT_EQ(strncmp(out, "hello", size) == 0);
//		EXPECT_EQ(size == 5);
//
//		EXPECT_EQ(ringbuf_write_line(rb, "hello", 5) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 6);
//		out = NULL;
//		size = 0;
//		EXPECT_EQ(ringbuf_read_line(rb, &out, &size) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 0);
//		EXPECT_EQ(strncmp(out, "hello", size) == 0);
//		EXPECT_EQ(size == 5);
//
//		EXPECT_EQ(ringbuf_write_int16(rb, 12) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 2);
//		EXPECT_EQ(ringbuf_write_int32(rb, 24) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 6);
//		EXPECT_EQ(ringbuf_write_string(rb, "hello", 5) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 13);
//		EXPECT_EQ(ringbuf_write_line(rb, "hello", 5) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 19);
//
//		EXPECT_EQ(ringbuf_read_int16(rb, &n) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 17);
//		EXPECT_EQ(n == 12);
//
//		n1 = 0;
//		EXPECT_EQ(ringbuf_read_int32(rb, &n1) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 13);
//		EXPECT_EQ(n1 == 24);
//
//		out = NULL;
//		size = 0;
//		EXPECT_EQ(ringbuf_read_string(rb, &out, &size) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 6);
//		EXPECT_EQ(strncmp(out, "hello", size) == 0);
//		EXPECT_EQ(size == 5);
//
//		out = NULL;
//		size = 0;
//		EXPECT_EQ(ringbuf_read_line(rb, &out, &size) == 0);
//		EXPECT_EQ(ringbuf_bytes_used(rb) == 0);
//		EXPECT_EQ(strncmp(out, "hello", size) == 0);
//		EXPECT_EQ(size == 5);
//	}
//	void *head = ringbuf_memcpy_into(rb, "hello, world", 10);
//	char buf[100] = { 0 };
//	ringbuf_memcpy_from(buf, rb, 5);
//
//	// -----------------test write buffer ---------------------------
//
//	struct wb_list* list = wb_list_new(10);
//	wb_list_push_line(list, "hello world, ni hao.", 15);
//	struct write_buffer *wb = wb_list_pop(list);
//
//
//	system("pause");
//
//	return 0;
//}