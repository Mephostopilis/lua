#ifndef shash_h
#define shash_h

#include <stdint.h>

struct shash;

struct shash *
shash_alloc(int cap);

void
shash_free(struct shash *self);

int
shash_insert(struct shash *self, int32_t i, int32_t v);

int32_t
shash_search(struct shash *self, int32_t i);

int
shash_remove(struct shash *self, int32_t i);

#endif // !shash_h
