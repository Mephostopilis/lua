#ifndef SHASH_H
#define SHASH_H

#include <message/message.h>
#include <uthash/uthash.h>
#include <assert.h>

typedef void(*response_cb_t)(struct message *msg);

struct shash {
	int id;
	response_cb_t cb;
	UT_hash_handle hh;
};

static struct shash *
shash_find(struct shash **self, int id);

static void 
shash_add(struct shash **self, struct shash *p) {
	HASH_ADD_INT(*self, id, p);
	assert(shash_find(*self, p->id) != NULL);
}

static struct shash *
shash_find(struct shash **self, int id) {
	struct shash *s;
	HASH_FIND_INT(*self, &id, s);
	return s;
}

static void 
shash_del(struct shash **self, struct shash *p) {
	HASH_DEL(*self, p);
}
#endif // !SHASH_H
