#ifndef RBTREE_H
#define RBTREE_H

#include <stdbool.h>

struct connection;
struct connection_array;

typedef void(*pfn_foreach_t)(struct connection *c);
typedef int(*pfn_comp_t)(void *_1, void *_2);

struct connection {
	int free;             // 1 use, 0 free. fixed by connection_arry

	int id_color;         // managed by rbtree, 0 back, 1 red.
	int id_parent;        // managed by rbtree
	int id_lnext;         // managed by rbtree, -1(NULL)
	int id_rnext;         // managed by rbtree, -1(NULL)

	void *key;
	void *value;
};

struct rbtree {
	struct connection_array *arr;
	int root;
	int size;
	pfn_comp_t comp;
};

struct rbtree * 
rbtree_alloc(pfn_comp_t comp);

void 
rbtree_free(struct rbtree *inst);

bool 
rbtree_insert(struct rbtree *inst, int parent, void *key, struct connection **cc);

bool
rbtree_remove(struct rbtree *inst, int idx, void *key, struct connection **cc);

bool
rbtree_search(struct rbtree *inst, int idx, void *key, struct connection **cc);

void 
rbtree_foreach(struct rbtree *inst, int idx, pfn_foreach_t cb);

#endif