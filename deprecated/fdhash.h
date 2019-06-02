#ifndef FDHASH_H
#define FDHASH_H

#include "uthash.h"
#include <assert.h>
#include <WinSock2.h>

struct shash {
	int idx;
	int sock;
	WSAEVENT we;
	void *ud;
	UT_hash_handle hh;
};

struct fdhash {
	int idx;
	int sock;
	WSAEVENT we;
	void *ud;
	struct shash uu;
	UT_hash_handle hh;
};

typedef void(*fdhash_foreach_cb_t)(struct fdhash *, void *ud);

/*
** @breif
** @return [1] 0 成功
*/
static int
fdhash_add(struct fdhash **self, struct fdhash *f) {
	struct shash *stb = &((*self)->uu);
	struct shash *s;
	HASH_FIND_INT(stb, &(stb)->sock, s);
	if (s == NULL) {
		HASH_ADD_INT(stb, sock, (struct shash *)f);
		return 0;
	}
	return 1;
}

static struct fdhash *
fdhash_get(struct fdhash **self, int id) {
	struct fdhash *tb = *self;
	struct shash *stb = &(tb->uu);
	struct fdhash *s;
	HASH_FIND_INT(stb, &id, s);
	return s;
}

static struct fdhash *
fdhash_del(struct fdhash **self, int id) {
	struct fdhash *tb = *self;
	struct shash *stb = &(tb->uu);
	struct fdhash *s;
	HASH_FIND_INT(stb, &id, s);
	if (s != NULL) {
		HASH_DEL(stb, s);
	}
	return s;
}

static size_t
fdhash_size(struct fdhash **self) {
	struct fdhash *tb = *self;
	struct shash *stb = &(tb->uu);
	size_t n;
	n = HASH_COUNT(stb);
	return n;
}

static void
fdhash_foreach(struct fdhash **self, fdhash_foreach_cb_t cb, void *ud) {
	struct fdhash *tb = *self;
	struct shash *stb = &(tb->uu);
	struct shash *iter = stb;
	for (; iter != NULL; iter = iter->hh.next) {
		cb((struct fdhash *)iter, ud);
	}
}

static void
fdhash_clear(struct fdhash **self) {
	//HASH_CLEAR(*self->)
}


typedef void(*wehash_foreach_cb_t)(struct wehash *);

static int
wehash_add(struct fdhash **self, struct fdhash *f) {
	struct fdhash *s;
	HASH_FIND_PTR(*self, &f->uu.we, s);
	if (s == NULL) {
		HASH_ADD_PTR(*self, uu.we, f);
		return 0;
	}
	return 1;
}

static struct fdhash *
wehash_get(struct fdhash **self, WSAEVENT *we) {
	struct fdhash *s;
	HASH_FIND_PTR(*self, we, s);
	return s;
}

static struct fdhash *
wehash_del(struct fdhash **self, WSAEVENT *we) {
	struct fdhash *s;
	HASH_FIND_PTR(*self, we, s);
	if (s != NULL) {
		HASH_DEL(*self, s);
	}
	return s;
}

#endif // !SHASH_H
