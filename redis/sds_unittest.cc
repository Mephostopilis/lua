extern "C" {
	#include "sds.h"
}

#include <gtest/gtest.h>
#include <cmath>

namespace {

	TEST(sds_test, zzalloc) {
		sds s1 = sdsnew("hello world");
		sds s2 = sdsnew("i am world");
		sds s3 = sdscatsds(s1, s2);
		sds s4 = sdscatprintf(s3, "%s", "hello");
		sds s5 = s4;
		EXPECT_EQ(sdscmp(s5, s4), 0);
		fprintf(stderr, "%s", s4);
	}
}

