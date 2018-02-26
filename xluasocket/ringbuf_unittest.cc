extern "C" {
#include "ringbuf.h"
#include "write_buffer.h"
}
#include <string.h>
#include <gtest/gtest.h>

namespace {

	TEST(RINGBUFTest, Write) {
		ringbuf_t *rb = ringbuf_new(5);
		EXPECT_EQ(ringbuf_capacity(rb), 5);
		EXPECT_EQ(ringbuf_buffer_size(rb), 6);

		// write
		EXPECT_EQ(ringbuf_write_int16(rb, 1), 2);
		EXPECT_EQ(ringbuf_bytes_used(rb), 2);
		EXPECT_EQ(ringbuf_write_int32(rb, 2), 4);
		EXPECT_EQ(ringbuf_bytes_used(rb), 6);
		
		EXPECT_EQ(ringbuf_capacity(rb), 10);
		EXPECT_EQ(ringbuf_buffer_size(rb), 11);

		const char *p = "hello";
		EXPECT_EQ(ringbuf_write_string(rb, (const uint8_t *)p, 5), 7);
		EXPECT_EQ(ringbuf_bytes_used(rb), 13);
		EXPECT_EQ(ringbuf_write_line(rb, (const uint8_t *)p, 5), 6);
		EXPECT_EQ(ringbuf_bytes_used(rb), 19);


		int16_t n1 = 0;
		EXPECT_EQ(ringbuf_read_int16(rb, &n1), 2);
		EXPECT_EQ(ringbuf_bytes_used(rb), 17);
		EXPECT_EQ(n1, 1);

		
		int32_t n2 = 0;
		EXPECT_EQ(ringbuf_read_int32(rb, &n2), 4);
		EXPECT_EQ(ringbuf_bytes_used(rb), 13);
		EXPECT_EQ(n2, 2);

		
		uint8_t *out = NULL;
		int size = 0;
		EXPECT_EQ(ringbuf_read_string(rb, &out, &size), 7);
		EXPECT_EQ(ringbuf_bytes_used(rb), 6);
		EXPECT_EQ(size, 5);
		EXPECT_EQ(strncmp((const char *)out, "hello", size), 0);
		
		out = NULL;
		size = 0;
		EXPECT_EQ(ringbuf_read_line(rb, &out, &size), 6);
		EXPECT_EQ(ringbuf_bytes_used(rb), 0);
		EXPECT_EQ(size, 5);
		EXPECT_EQ(strncmp((const char *)out, "hello", size), 0);
		
		ringbuf_free(&rb);
	}

	TEST(RINGBUFTest, Read) {
		EXPECT_EQ(1, 1);
	}

	TEST(WriteBufferTest, Write) {
		struct wb_list* list = wb_list_new(10);
		wb_list_push_line(list, "hello world, ni hao.", 21);
		EXPECT_EQ(wb_list_size(list), 3);
		struct write_buffer *wb = NULL;
		wb = wb_list_pop(list);
		//EXPECT_NE(wb, NULL);
		EXPECT_EQ(wb_bytes_free(wb), 0);
		wb_list_free_wb(list, wb);

		wb = wb_list_pop(list);
		//EXPECT_NE(wb, NULL);
		EXPECT_EQ(wb_bytes_free(wb), 0);
		wb_list_free_wb(list, wb);

		wb = wb_list_pop(list);
		//EXPECT_NE(wb, NULL);
		EXPECT_EQ(wb_bytes_free(wb), 8);
		wb_list_free_wb(list, wb);

		wb_list_free(list);
	}
}
