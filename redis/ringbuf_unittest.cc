extern "C" {
#include "ringbuf.h"
#include "write_buffer.h"
}
#include <string.h>
#include <gtest/gtest.h>

namespace {

	TEST(RINGBUFTest, Write) {
		 int cap = 5;
		 ringbuf_t *rb = ringbuf_new(cap);
		 EXPECT_EQ(ringbuf_capacity(rb), cap);
		 EXPECT_EQ(ringbuf_buffer_size(rb), cap + 1);


		 // write
		 EXPECT_EQ(ringbuf_memcpy_int16(rb, 1), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_bytes_used(rb), 2);
		 EXPECT_EQ(ringbuf_memcpy_int32(rb, 2), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_bytes_used(rb), 6);
		
		 EXPECT_EQ(ringbuf_capacity(rb), 10);
		 EXPECT_EQ(ringbuf_buffer_size(rb), 11);

		 const char *p = "hello";
		 EXPECT_EQ(ringbuf_memcpy_string(rb, p, 5), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_bytes_used(rb), 13);
		 EXPECT_EQ(ringbuf_memcpy_line(rb, p, 5), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_bytes_used(rb), 19);

		 EXPECT_EQ(ringbuf_memcpy_buffer(rb, "hello", 5), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_bytes_used(rb), 19+5);


		 int16_t n1 = 0;
		 int16_t n2 = 0;
		 EXPECT_EQ(ringbuf_try_get_int16(&n1, rb), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_get_int16(&n2, rb), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_bytes_used(rb), 17);
		 EXPECT_EQ(n1, 1);
		 EXPECT_EQ(n2, 1);
		
		 int32_t n3 = 0;
		 EXPECT_EQ(ringbuf_get_int32(&n3, rb), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_bytes_used(rb), 13);
		 EXPECT_EQ(n3, 2);

		
		 char *out = NULL;
		 size_t size = 0;
		 EXPECT_EQ(ringbuf_get_string(&out, &size, rb), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_bytes_used(rb), 6);
		 EXPECT_EQ(size, 5);
		 EXPECT_EQ(strncmp((const char *)out, "hello", size), 0);
		
		 out = NULL;
		 size = 0;
		 EXPECT_EQ(ringbuf_get_line(&out, &size, rb), RINGBUF_OK);
		 EXPECT_EQ(ringbuf_bytes_used(rb), 0);
		 EXPECT_EQ(size, 5);
		 EXPECT_EQ(strncmp((const char *)out, "hello", size), 0);
		
		 ringbuf_free(rb);
	}

	TEST(RINGBUFTest, Read) {
		EXPECT_EQ(1, 1);
	}

	TEST(WriteBufferTest, Write) {
		// struct wb_list* list = wb_list_new();
		// wb_list_push_line(list, "hello world, ni hao.", 21);
		// EXPECT_EQ(wb_list_size(list), 3);
		// struct write_buffer *wb = NULL;
		// wb = wb_list_pop(list);
		// //EXPECT_NE(wb, NULL);
		// EXPECT_EQ(wb_bytes_free(wb), 0);
		// wb_list_free_wb(list, wb);

		// wb = wb_list_pop(list);
		// //EXPECT_NE(wb, NULL);
		// EXPECT_EQ(wb_bytes_free(wb), 0);
		// wb_list_free_wb(list, wb);

		// wb = wb_list_pop(list);
		// //EXPECT_NE(wb, NULL);
		// EXPECT_EQ(wb_bytes_free(wb), 8);
		// wb_list_free_wb(list, wb);

		// wb_list_free(list);
	}
}
