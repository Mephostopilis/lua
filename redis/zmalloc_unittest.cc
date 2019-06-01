extern "C" {
#include "zmalloc.h"
}

#include <gtest/gtest.h>
#include <cmath>

namespace {

	TEST(zmalloc_test, zzalloc) {
		void *p = zmalloc(10);
		void *a[10];
		for (size_t i = 0; i < 10; i++) {
			a[i] = zmalloc(pow(2, i));
		}
		size_t sz = zmalloc_get_memory_size();
		fprintf(stderr, "mem size = %d\n", sz);
	}
}

