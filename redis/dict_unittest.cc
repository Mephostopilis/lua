extern "C" {
#include "dict.h"
#include "sds.h"
#include "xxhash.h"
}

#include <gtest/gtest.h>
#include <cmath>

struct M {
	int a;
	sds s;
};

unsigned int dictEncObjHash(const void *key) {
	//robj *o = (robj*)key;

	//if (sdsEncodedObject(o)) {
	//	return dictGenHashFunction(o->ptr, (int)sdslen((sds)o->ptr));          WIN_PORT_FIX /* cast (int) */
	//} else {
	//	if (o->encoding == OBJ_ENCODING_INT) {
	//		char buf[32];
	//		int len;

	//		len = ll2string(buf, 32, (PORT_LONG)o->ptr);
	//		return dictGenHashFunction((unsigned char*)buf, len);
	//	} else {
	//		unsigned int hash;

	//		o = getDecodedObject(o);
	//		hash = dictGenHashFunction(o->ptr, (int)sdslen((sds)o->ptr));      WIN_PORT_FIX /* cast (int) */
	//			decrRefCount(o);
	//		return hash;
	//	}
	//}
	M *m1 = (M *)key;
	/*sds *s = (sds*)key;
	sds s1 = *s;
	size_t l = sdslen(*s);*/

	return 0;
}

int dictEncObjKeyCompare(void *privdata, const void *key1,
	const void *key2) {
	sds o1 = (sds)key1, o2 = (sds)key2;
	/*robj *o1 = (robj*)key1, *o2 = (robj*)key2;
	int cmp;

	if (o1->encoding == OBJ_ENCODING_INT &&
		o2->encoding == OBJ_ENCODING_INT)
		return o1->ptr == o2->ptr;

	o1 = getDecodedObject(o1);
	o2 = getDecodedObject(o2);
	cmp = dictSdsKeyCompare(privdata, o1->ptr, o2->ptr);
	decrRefCount(o1);
	decrRefCount(o2);*/
	//return cmp;
	return 1;
}

void dictObjectDestructor(void *privdata, void *val) {
	DICT_NOTUSED(privdata);

	if (val == NULL) return; /* Values of swapped out keys as set to NULL */
	//decrRefCount(val);
}

dictType hashDictType = {
	dictEncObjHash,             /* hash function */
	NULL,                       /* key dup */
	NULL,                       /* val dup */
	dictEncObjKeyCompare,       /* key compare */
	dictObjectDestructor,  /* key destructor */
	dictObjectDestructor   /* val destructor */
};



namespace {

	TEST(dict_test, zzalloc) {
		sds s1 = sdsnew("hello world");
		sds s2 = sdsnew("i am world");
		sds s3 = sdscatsds(s1, s2);
		sds s4 = sdscatprintf(s3, "%s", "hello");
		sds s5 = sdsdup(s1);
		M m1, m2;
		m1.s = s1;
		m1.a = 10;
		m2.s = s2;
		m2.a = 14;
		dict *d = dictCreate(&hashDictType, NULL);
		dictAdd(d, &m1, &m2);
		//dictAdd(d, s2, s3);

		//fprintf(stderr, "mem size = %d\n", sz);
	}
}

