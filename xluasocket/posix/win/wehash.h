#ifndef wehash_H
#define wehash_H

#include "uthash.h"
#include <assert.h>
#include <WinSock2.h>


//struct wehash {
//	int idx;
//	int sock;
//	WSAEVENT we;
//	void *ud;
//	UT_hash_handle hh;
//};
//
//
//typedef void(*wehash_foreach_cb_t)(struct wehash *);
//
//static int
//wehash_add(struct wehash **self, struct wehash *f) {
//	struct wehash *s;
//	HASH_FIND_PTR(*self, &f->we, s);
//	if (s == NULL) {
//		HASH_ADD_PTR(*self, we, f);
//		return 0;
//	}
//	return 1;
//}
//
//static struct wehash *
//wehash_get(struct wehash **self, WSAEVENT *we) {
//	struct wehash *s;
//	HASH_FIND_PTR(*self, we, s);
//	return s;
//}
//
//static struct wehash *
//wehash_del(struct wehash **self, WSAEVENT *we) {
//	struct wehash *s;
//	HASH_FIND_PTR(*self, we, s);
//	if (s != NULL) {
//		HASH_DEL(*self, s);
//	}
//	return s;
//}

#endif // !wehash_H
