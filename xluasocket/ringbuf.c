/*
 * ringbuf.c - C ring buffer (FIFO) implementation.
 *
 * Written in 2011 by Drew Hess <dhess-src@bothan.net>.
 *
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to
 * the public domain worldwide. This software is distributed without
 * any warranty.
 *
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software. If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

#include "xluaconf.h"
#include "ringbuf.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#if defined(_MSC_VER)
#include <math.h>
#define MIN min
#endif

static int
CheckEnd() {
	int i = 0x12345678;
	char *c = (char *)&i;
	return (*c == 0x12);
}

/*
 * The code is written for clarity, not cleverness or performance, and
 * contains many assert()s to enforce invariant assumptions and catch
 * bugs. Feel free to optimize the code and to remove asserts for use
 * in your own projects, once you're comfortable that it functions as
 * intended.
 */

struct ringbuf {
	uint8_t *buf;
	uint8_t *head, *tail;
	size_t size;
};

/*
* Return a pointer to one-past-the-end of the ring buffer's
* contiguous buffer. You shouldn't normally need to use this function
* unless you're writing a new ringbuf_* function.
*/
static const uint8_t *
ringbuf_end(const ringbuf_t *rb) {
	return (rb->buf + rb->size);
}

static int
ringbuf_ext(ringbuf_t *rb) {
	size_t capacity = ringbuf_capacity(rb);
	size_t realsize = capacity * 2 + 1;
	size_t newrealsize = capacity * 2 * 2 + 1;
	size_t newsize = capacity * 2 + 1;
	uint8_t *oldbuf = rb->buf;
	/*if (REALLOC(oldbuf, size * 2) != NULL) {
		rb->size = size;
		return 0;
	}*/
	uint8_t *buf = MALLOC(newrealsize);
	if (buf == NULL) {
		return -1;
	}
	if (rb->head >= rb->tail) {
		memcpy(buf, oldbuf, rb->size);
		rb->head = buf + (rb->head - oldbuf);
		rb->tail = buf + (rb->tail - oldbuf);
		rb->size = newsize;
		rb->buf = buf;
	} else {

		const uint8_t *backend = ringbuf_end(rb);
		int n = backend - rb->tail;
		memcpy(buf + 1, rb->tail, n);
		uint8_t *head = buf + 1 + n;
		memcpy(head, rb->buf, rb->head - rb->buf);
		head = head + (rb->head - rb->buf);
		rb->head = head;
		rb->tail = buf;
		rb->buf = buf;
		rb->size = newsize;
	}
	free(oldbuf);
	return 0;
}

ringbuf_t *
ringbuf_new(size_t capacity) {
	ringbuf_t *rb = MALLOC(sizeof(struct ringbuf));
	if (rb) {

		/* One byte is used for detecting the full condition. */
		rb->size = capacity + 1;
		size_t realsize = capacity * 2 + 1;
		rb->buf = MALLOC(realsize);
		if (rb->buf)
			ringbuf_reset(rb);
		else {
			free(rb);
			return 0;
		}
	}
	return rb;
}

size_t
ringbuf_buffer_size(const ringbuf_t *rb) {
	return rb->size;
}

void
ringbuf_reset(ringbuf_t *rb) {
	rb->head = rb->tail = rb->buf;
}

void
ringbuf_free(ringbuf_t **rb) {
	assert(rb && (*rb));
	free((*rb)->buf);
	free((*rb));
	*rb = 0;
}

size_t
ringbuf_capacity(const ringbuf_t *rb) {
	return (rb->size - 1);
}

/*
** |*******tail***********head**************|end
*/
size_t
ringbuf_bytes_free(const ringbuf_t *rb) {
	if (rb->head >= rb->tail)
		return ringbuf_capacity(rb) - (rb->head - rb->tail);
	else
		return rb->tail - rb->head - 1;
}

size_t
ringbuf_bytes_used(const  ringbuf_t *rb) {
	return ringbuf_capacity(rb) - ringbuf_bytes_free(rb);
}


bool
ringbuf_is_full(const  ringbuf_t *rb) {
	return (ringbuf_bytes_free(rb) == 0) ? true : false;
}

bool
ringbuf_is_empty(const  ringbuf_t *rb) {
	return (ringbuf_bytes_free(rb) == ringbuf_capacity(rb)) ? true : false;
}

/*
 * Given a ring buffer rb and a pointer to a location within its
 * contiguous buffer, return the a pointer to the next logical
 * location in the ring buffer.
 */
static uint8_t *
ringbuf_nextp(ringbuf_t *rb, const uint8_t *p) {
	/*
	 * The assert guarantees the expression (++p - rb->buf) is
	 * non-negative; therefore, the modulus operation is safe and
	 * portable.
	 */
	assert((p >= rb->buf) && (p < ringbuf_end(rb)));
	return rb->buf + ((++p - rb->buf) % ringbuf_buffer_size(rb));
}

size_t
ringbuf_findchr(const ringbuf_t *rb, int c, size_t offset) {
	const uint8_t *bufend = ringbuf_end(rb);
	size_t bytes_used = ringbuf_bytes_used(rb);
	if (offset >= bytes_used)
		return bytes_used;

	const uint8_t *start = rb->buf +
		(((rb->tail - rb->buf) + offset) % ringbuf_buffer_size(rb));
	assert(bufend > start);
	size_t n = MIN(bufend - start, bytes_used - offset);
	const uint8_t *found = memchr(start, c, n);
	if (found)
		return offset + (found - start);
	else
		return ringbuf_findchr(rb, c, offset + n);
}

size_t
ringbuf_memset(ringbuf_t *dst, int c, size_t len) {
	const uint8_t *bufend = ringbuf_end(dst);
	size_t nwritten = 0;
	size_t count = MIN(len, ringbuf_buffer_size(dst));
	int overflow = count > ringbuf_bytes_free(dst);

	while (nwritten != count) {

		/* don't copy beyond the end of the buffer */
		assert(bufend > dst->head);
		size_t n = MIN(bufend - dst->head, count - nwritten);
		memset(dst->head, c, n);
		dst->head += n;
		nwritten += n;

		/* wrap? */
		if (dst->head == bufend)
			dst->head = dst->buf;
	}

	if (overflow) {
		dst->tail = ringbuf_nextp(dst, dst->head);
		assert(ringbuf_is_full(dst));
	}

	return nwritten;
}

void *
ringbuf_memcpy_into(ringbuf_t *dst, const void *src, size_t count) {
	const uint8_t *u8src = src;
	const uint8_t *bufend = ringbuf_end(dst);
	int overflow = count > ringbuf_bytes_free(dst);
	size_t nread = 0;

	while (nread != count) {
		/* don't copy beyond the end of the buffer */
		assert(bufend > dst->head);
		size_t n = MIN(bufend - dst->head, count - nread);
		memcpy(dst->head, u8src + nread, n);
		dst->head += n;
		nread += n;

		/* wrap? */
		if (dst->head == bufend)
			dst->head = dst->buf;
	}

	if (overflow) {
		dst->tail = ringbuf_nextp(dst, dst->head);
		assert(ringbuf_is_full(dst));
	}

	return dst->head;
}

ssize_t
ringbuf_read_fd(ringbuf_t *rb, int fd, size_t hint_max) {
	if (ringbuf_is_full(rb)) {
		ringbuf_ext(rb);
	}
	const uint8_t *bufend = ringbuf_end(rb);
	size_t nfree = ringbuf_bytes_free(rb);

	/* don't write beyond the end of the buffer */
	assert(bufend > rb->head);
	int count = MIN(bufend - rb->head, nfree);
	ssize_t n = recv(fd, rb->head, count, 0);
	if (n > 0) {
		assert(rb->head + n <= bufend);
		rb->head += n;

		/* wrap? */
		if (rb->head == bufend)
			rb->head = rb->buf;

		/* fix up the tail pointer if an overflow occurred */
		if (n > nfree) {
			rb->tail = ringbuf_nextp(rb, rb->head);
			assert(ringbuf_is_full(rb));
		}
	}

	return n;
}

int
ringbuf_read_string(ringbuf_t *rb, uint8_t **out, int *size) {
	if (ringbuf_bytes_used(rb) < 2) {
		return 0;
	}
	assert(ringbuf_read_int16(rb, size) == 2);
	if (ringbuf_bytes_used(rb) >= *size) {
		if (rb->head >= rb->tail) {
			*out = rb->tail;
			rb->tail += *size;
			return (*size + 2);
		} else {
			int n = ((rb->tail - rb->buf) + *size) % rb->size;
			const uint8_t *end = ringbuf_end(rb);
			memcpy(end, rb->buf, n);
			*out = rb->tail;
			rb->tail = rb->buf + n;
			return (*size + 2);
		}
	}
	return 0;
}

int
ringbuf_read_line(ringbuf_t *rb, uint8_t **out, int *size) {
	if (ringbuf_bytes_used(rb) > 0) {
		// 
		int bytes_used = ringbuf_bytes_used(rb);
		int ofs = ringbuf_findchr(rb, '\n', 0);
		if (ofs < bytes_used) {
			*size = ofs;
			if (rb->head >= rb->tail) {
				*out = rb->tail;
				rb->tail += ofs;
				rb->tail[0] = '\0';
				rb->tail += 1;
				return (ofs + 1);
			} else {
				int n = rb->tail - rb->buf;
				n = (n + *size) % rb->size;
				const uint8_t *end = ringbuf_end(rb);
				memcpy(end, rb->buf, n);
				*out = rb->tail;
				rb->buf[n] = '\0';
				rb->tail = rb->buf + n + 1;
				if (rb->tail == end)
					rb->tail = rb->buf;
				return (ofs + 1);
			}
		}
	}
	return 0;
}

int
ringbuf_read_int64(ringbuf_t *rb, int64_t *out) {
	*out = 0;
	int len = 8;
	if (ringbuf_bytes_used(rb) >= len) {
		if (!CheckEnd()) { // 低位字节存高位
			for (size_t i = 0; i < len; i++) {
				uint8_t *c = rb->tail;
				*out |= (*c << ((len - i - 1) * 8)) & 0xffffffff;
				rb->tail = ringbuf_nextp(rb, rb->tail);
			}
		} else {
			for (size_t i = 0; i < len; i++) {
				uint8_t *c = rb->tail;
				*out |= (*c) & 0xffffffff;
				rb->tail = ringbuf_nextp(rb, rb->tail);
			}
		}
		if (rb->tail == ringbuf_end(rb))
			rb->tail = rb->buf;
		return 0;
	}
	return -1;
}

int
ringbuf_read_int32(ringbuf_t *rb, int32_t *out) {
	*out = 0;
	int len = 4;
	if (ringbuf_bytes_used(rb) >= len) {
		if (!CheckEnd()) { // 低位字节存高位
			for (size_t i = 0; i < len; i++) {
				uint8_t *c = rb->tail;
				*out |= (*c << ((len - i - 1) * 8)) & 0xffffffff;
				rb->tail = ringbuf_nextp(rb, rb->tail);
			}
		} else {
			for (size_t i = 0; i < len; i++) {
				uint8_t *c = rb->tail;
				*out |= (*c) & 0xffffffff;
				rb->tail = ringbuf_nextp(rb, rb->tail);
			}
		}
		if (rb->tail == ringbuf_end(rb))
			rb->tail = rb->buf;
		return len;
	}
	return 0;
}

int
ringbuf_read_int16(ringbuf_t *rb, int16_t *out) {
	*out = 0;
	int len = 2;
	if (ringbuf_bytes_used(rb) >= len) {
		if (!CheckEnd()) { // 低位字节存高位,ld
			for (size_t i = 0; i < len; i++) {
				uint8_t *c = rb->tail;
				*out |= (*c << ((len - i - 1) * 8)) & 0xffffffff;
				rb->tail = ringbuf_nextp(rb, rb->tail);
			}
		} else {
			for (size_t i = 0; i < len; i++) {
				uint8_t *c = rb->tail;
				*out |= (*c) & 0xffffffff;
				rb->tail = ringbuf_nextp(rb, rb->tail);
			}
		}
		if (rb->tail == ringbuf_end(rb))
			rb->tail = rb->buf;
		return len;
	}
	return 0;
}

int
ringbuf_read_int8(ringbuf_t *rb, int8_t *out) {
	*out = 0;
	int len = 1;
	if (ringbuf_bytes_used(rb) >= len) {
		if (!CheckEnd()) { // 低位字节存高位
			for (size_t i = 0; i < len; i++) {
				uint8_t *c = rb->tail;
				*out |= (*c << ((len - i - 1) * 8)) & 0xffffffff;
				rb->tail = ringbuf_nextp(rb, rb->tail);
			}
		} else {
			for (size_t i = 0; i < len; i++) {
				uint8_t *c = rb->tail;
				*out |= (*c) & 0xffffffff;
				rb->tail = ringbuf_nextp(rb, rb->tail);
			}
		}
		if (rb->tail == ringbuf_end(rb))
			rb->tail = rb->buf;
		return len;
	}
	return 0;
}

void *
ringbuf_memcpy_from(void *dst, ringbuf_t *src, size_t count) {
	size_t bytes_used = ringbuf_bytes_used(src);
	if (count > bytes_used)
		return 0;

	uint8_t *u8dst = dst;
	const uint8_t *bufend = ringbuf_end(src);
	size_t nwritten = 0;
	while (nwritten != count) {
		assert(bufend > src->tail);
		size_t n = MIN(bufend - src->tail, count - nwritten);
		memcpy(u8dst + nwritten, src->tail, n);
		src->tail += n;
		nwritten += n;

		/* wrap ? */
		if (src->tail == bufend)
			src->tail = src->buf;
	}

	assert(count + ringbuf_bytes_used(src) == bytes_used);
	return src->tail;
}

ssize_t
ringbuf_write_fd(ringbuf_t *rb, int fd) {
	size_t bytes_used = ringbuf_bytes_used(rb);
	if (bytes_used <= 0) {
		return bytes_used;
	}

	const uint8_t *bufend = ringbuf_end(rb);
	assert(bufend > rb->head);
	int count = MIN(bufend - rb->tail, bytes_used);
	ssize_t n = send(fd, rb->tail, count, 0);
	if (n > 0) {
		assert(rb->tail + n <= bufend);
		rb->tail += n;

		/* wrap? */
		if (rb->tail == bufend)
			rb->tail = rb->buf;

		assert(n + ringbuf_bytes_used(rb) == bytes_used);
	}

	return n;
}

int
ringbuf_write_string(ringbuf_t *rb, const uint8_t *buf, size_t size) {
	if (ringbuf_bytes_free(rb) < size + 2) {
		ringbuf_ext(rb);
	}
	assert(ringbuf_write_int16(rb, size) == 2);
	const uint8_t *end = ringbuf_end(rb);
	int n = MIN(end - rb->head, size);
	memcpy(rb->head, buf, n);
	if (n < size) {
		memcpy(rb->buf, buf + n, size - n);
	}
	rb->head = rb->buf + (((rb->head - rb->buf) + size) % rb->size);
	return (size + 2);
}

int
ringbuf_write_line(ringbuf_t *rb, const uint8_t *buf, size_t size) {
	if (ringbuf_bytes_free(rb) < size + 1) {
		ringbuf_ext(rb);
	}
	const uint8_t *end = ringbuf_end(rb);
	int n = MIN(end - rb->head, size);
	memcpy(rb->head, buf, n);
	if (n < size) {
		memcpy(rb->buf, buf + n, size - n);
	}
	rb->head = rb->buf + (((rb->head - rb->buf) + size) % rb->size);
	assert(rb->head < end);
	rb->head[0] = '\n';
	rb->head = ringbuf_nextp(rb, rb->head);
	return (size + 1);
}

int
ringbuf_write_int32(ringbuf_t *rb, int32_t val) {
	int len = 4;
	if (ringbuf_bytes_free(rb) < len) {
		ringbuf_ext(rb);
	}
	if (CheckEnd()) { // bd
		for (size_t i = 0; i < len; i++) {
			rb->head[0] = (val << (i * 8)) & 0xff;
			rb->head = ringbuf_nextp(rb, rb->head);
		}
	} else {
		for (size_t i = 0; i < len; i++) {
			rb->head[0] = (val << ((len - 1 - i) * 8)) & 0xff;
			rb->head = ringbuf_nextp(rb, rb->head);
		}
	}
	if (rb->head == ringbuf_end(rb))
		rb->head = rb->buf;
	return len;
}

int
ringbuf_write_int16(ringbuf_t *rb, int16_t val) {
	int len = 2;
	if (ringbuf_bytes_free(rb) < 2) {
		ringbuf_ext(rb);
	}
	if (CheckEnd()) { // bd
		for (size_t i = 0; i < len; i++) {
			rb->head[0] = (val << (i * 8)) & 0xff;
			rb->head = ringbuf_nextp(rb, rb->head);
		}
	} else {
		for (size_t i = 0; i < len; i++) {
			rb->head[0] = (val << ((len - 1 - i) * 8)) & 0xff;
			rb->head = ringbuf_nextp(rb, rb->head);
		}
	}
	if (rb->head == ringbuf_end(rb))
		rb->head = rb->buf;
	return len;
}

void *
ringbuf_copy(ringbuf_t *dst, ringbuf_t *src, size_t count) {
	size_t src_bytes_used = ringbuf_bytes_used(src);
	if (count > src_bytes_used)
		return 0;
	int overflow = count > ringbuf_bytes_free(dst);

	const uint8_t *src_bufend = ringbuf_end(src);
	const uint8_t *dst_bufend = ringbuf_end(dst);
	size_t ncopied = 0;
	while (ncopied != count) {
		assert(src_bufend > src->tail);
		size_t nsrc = MIN(src_bufend - src->tail, count - ncopied);
		assert(dst_bufend > dst->head);
		size_t n = MIN(dst_bufend - dst->head, nsrc);
		memcpy(dst->head, src->tail, n);
		src->tail += n;
		dst->head += n;
		ncopied += n;

		/* wrap ? */
		if (src->tail == src_bufend)
			src->tail = src->buf;
		if (dst->head == dst_bufend)
			dst->head = dst->buf;
	}

	assert(count + ringbuf_bytes_used(src) == src_bytes_used);

	if (overflow) {
		dst->tail = ringbuf_nextp(dst, dst->head);
		assert(ringbuf_is_full(dst));
	}

	return dst->head;
}
