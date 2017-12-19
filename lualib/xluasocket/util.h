#ifndef UTIL_H
#define UTIL_H

#include <assert.h>
#include <stdint.h>

static int int22bytes_bd(int32_t src, char *bufer, int idx, int len) {
	int i = idx + len - 1;
	for (; i >= idx; --i) {
		bufer[i] = (char)((src >> (len - 1 - i) * 8) & 0xff);
	}
	return 1;
}

static int bytes2int_bd(char *src, int len, int32_t *dst) {
	assert(len == 4);
	int i = 0;
	for (; i < len; i++) {
		*dst |= (src[i] << ((3 - i) * 8)) & 0xffffffff;
	}
	return 1;
}

static int unpackbH(char *src, int len, uint16_t *dst) {
	assert(len == 2);
	int i = 0;
	for (; i < 2; i++) {
		*dst |= (src[i] << ((1 - i) * 8)) & 0xffffffff;
	}
	return 1;
}

#endif // !UTIL_H
