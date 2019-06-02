#include "rbtree.h"

#include "skynet.h"

#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <assert.h>

#define SIZE 11

struct connection_array {
	struct connection *data;
	int cfree;
	int csize;
	int ccap;
};

static struct connection_array *
connection_array_alloc(int cap) {
	struct connection_array *inst = (struct connection_array *)skynet_malloc(sizeof(*inst));
	if (inst == NULL) {
		return NULL;
	}
	inst->csize = 0;
	inst->ccap = cap;
	inst->cfree = cap - 1;
	inst->data = NULL;
	struct connection *c = (struct connection *)skynet_malloc(sizeof(*c) * cap);
	if (c == NULL) {
		skynet_free(inst);
		return NULL;
	}
	inst->data = c;
	memset(c, 0, sizeof(*c) * cap);
	return inst;
}

static void
connection_array_free(struct connection_array *inst) {
	if (inst->data != NULL) {
		skynet_free(inst->data);
	}
	skynet_free(inst);
}

static struct connection *
connection_array_at(struct connection_array *inst, int idx) {
	if (idx >= 0 && idx < inst->ccap) {
		return &inst->data[idx];
	}
	return NULL;
}

static int
connection_array_idx(struct connection_array *inst, struct connection *c) {
	return (int)(c - inst->data);
}

static int
connection_array_alloc_co(struct connection_array *inst) {
	if (inst->csize >= inst->ccap) {
		int cap = inst->ccap * 2;
		struct connection *c = (struct connection *)skynet_malloc(sizeof(*c) * cap);
		memset(c, 0, sizeof(*c) *cap);
		memcpy(c, inst->data, inst->ccap * sizeof(struct connection));
		inst->data = c;

		for (size_t i = 0; i < inst->ccap; i++) {
			struct connection *c = connection_array_at(inst, i);
		}

		// inst->csize
		inst->ccap = cap;
		inst->cfree = cap - 1;
	}
	struct connection *c = NULL;
	int idx = 0;
	do {
		if (inst->cfree < 0) {
			inst->cfree = inst->ccap - 1;
		}
		idx = inst->cfree;
		c = &inst->data[idx];
		if (c->free == 0) {  // free
			c->free = 1;
			inst->cfree--;
			inst->csize++;
			break;
		} else {
			inst->cfree--;
		}
	} while (1);
	assert(idx >= 0 && idx < inst->ccap);
	return idx;
}

static void
connection_array_free_co(struct connection_array *inst, int idx) {
	assert(idx < inst->ccap && idx >= 0);
	struct connection *c = &inst->data[idx];
	assert(c->free == 1);
	c->free = 0;
	inst->csize--;
}

// bst
struct rbtree * rbtree_alloc(pfn_comp_t comp) {
	struct rbtree *inst = (struct rbtree *)skynet_malloc(sizeof(*inst));
	if (inst == NULL) {
		return NULL;
	}
	inst->arr = connection_array_alloc(127);
	inst->root = -1;
	inst->size = 0;
	inst->comp = comp;
	return inst;
}

void rbtree_free(struct rbtree *inst) {
	connection_array_free(inst->arr);
	skynet_free(inst);
}

static void rbtree_rotate_left(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	struct connection *r = connection_array_at(inst->arr, c->id_rnext);
	struct connection *p = connection_array_at(inst->arr, c->id_parent);

	c->id_rnext = r->id_lnext;
	if (r->id_lnext >= 0) {
		struct connection *rl = connection_array_at(inst->arr, r->id_lnext);
		rl->id_parent = idx;
	}

	c->id_parent = connection_array_idx(inst->arr, r);
	r->id_lnext = idx;

	if (p) {
		r->id_parent = connection_array_idx(inst->arr, p);
		if (p->id_rnext == idx) {
			p->id_rnext = connection_array_idx(inst->arr, r);
		} else {
			p->id_lnext = connection_array_idx(inst->arr, r);
		}
	} else {
		r->id_parent = -1;
		inst->root = connection_array_idx(inst->arr, r);
	}

	//r->id_color = c->id_color;
	//c->id_color = 1;   // red
}

static void rbtree_rotate_right(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	struct connection *p = connection_array_at(inst->arr, c->id_parent);
	struct connection *l = connection_array_at(inst->arr, c->id_lnext);

	c->id_lnext = l->id_rnext;
	if (l->id_rnext >= 0) {
		struct connection *lr = connection_array_at(inst->arr, l->id_rnext);
		lr->id_parent = idx;
	}

	c->id_parent = connection_array_idx(inst->arr, l);
	l->id_rnext = idx;

	if (p) {
		l->id_parent = connection_array_idx(inst->arr, p);
		if (p->id_rnext == idx) {
			p->id_rnext = connection_array_idx(inst->arr, l);
		} else {
			p->id_lnext = connection_array_idx(inst->arr, l);
		}
	} else {
		l->id_parent = -1;
		inst->root = connection_array_idx(inst->arr, l);
	}

	//l->id_color = c->id_color;
	//c->id_color = 1;  // red
}

static void rbtree_flip_color(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	assert(c->id_color == 0);
	c->id_color = 1; // red

	struct connection *r = connection_array_at(inst->arr, c->id_rnext);
	struct connection *l = connection_array_at(inst->arr, c->id_lnext);
	r->id_color = 0;  // black
	l->id_color = 0;  // black
}

static void rbtree_insert_fix(struct rbtree *inst, int idx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (c->id_parent == -1) {    // case 1: root == idx
		c->id_color = 0;         // black;
		inst->root = idx;
		return;
	} else {
		struct connection *p = connection_array_at(inst->arr, c->id_parent);
		if (p->id_color == 0) {  // case 2: parnet is black.
			return;
		} else {
			// notice
			assert(c->id_color == 1 && p->id_color == 1 && p->id_parent >= 0);
			struct connection *g = connection_array_at(inst->arr, p->id_parent);
			struct connection *u = NULL;
			if (g->id_rnext >= 0 && g->id_lnext == c->id_parent) {
				u = connection_array_at(inst->arr, g->id_rnext);  // uncle is r child.
			} else if (g->id_lnext >= 0 && g->id_rnext == c->id_parent) {
				u = connection_array_at(inst->arr, g->id_lnext);  // uncle is l child.
			}
			if (u && u->id_color == 1) {  // case 3: both parent and uncle is red.
				rbtree_flip_color(inst, p->id_parent);
				rbtree_insert_fix(inst, p->id_parent);
			} else { // case 4
				if (idx == p->id_rnext && c->id_parent == g->id_lnext && (g->id_rnext == -1 || u->id_color == 0)) {
					rbtree_rotate_left(inst, c->id_parent);
					idx = c->id_lnext;
					c = connection_array_at(inst->arr, idx);
					p = connection_array_at(inst->arr, c->id_parent);
					g = connection_array_at(inst->arr, p->id_parent);
				} else if (idx == p->id_lnext && c->id_parent == g->id_rnext && (g->id_lnext == -1 || u->id_color == 0)) {
					rbtree_rotate_right(inst, c->id_parent);
					idx = c->id_rnext;
					c = connection_array_at(inst->arr, idx);
					p = connection_array_at(inst->arr, c->id_parent);
					g = connection_array_at(inst->arr, p->id_parent);
				}
				// case 5
				p->id_color = 0;
				g->id_color = 1;
				if (idx == p->id_lnext) {
					rbtree_rotate_right(inst, p->id_parent);
				} else {
					rbtree_rotate_left(inst, p->id_parent);
				}
			}
		}
	}
}

static struct connection * rbtree_get_connection(struct rbtree *inst, int *idx) {
	if (*idx == -1) {
		*idx = connection_array_alloc_co(inst->arr);
		return connection_array_at(inst->arr, *idx);
	} else {
		return connection_array_at(inst->arr, *idx);
	}
}

bool rbtree_insert(struct rbtree *inst, int parent, void *key, struct connection **cc) {
	if (parent == -1) {
		// achive c
		int idx = -1;
		struct connection *c = rbtree_get_connection(inst, &idx);
		assert(c != NULL && idx != -1);
		assert(inst->size == 0);
		inst->root = idx;
		inst->size++;

		//c->id = key;
		c->key = key;
		c->id_color = 0;   // black
		c->id_parent = parent;
		c->id_lnext = -1;
		c->id_rnext = -1;

		rbtree_insert_fix(inst, idx);

		*cc = c;
		return true;
	} else {
		assert(parent >= 0 && parent < inst->arr->ccap);
		struct connection *p = connection_array_at(inst->arr, parent);
		if (inst->comp(key, p->key) < 0) {  // left
			if (p->id_lnext == -1) {
				int idx = -1;
				struct connection *c = rbtree_get_connection(inst, &idx);
				assert(c != NULL && idx != -1);

				p->id_lnext = idx;
				inst->size++;

				//c->id = key;
				c->key = key;
				c->id_color = 1;  // red
				c->id_parent = parent;
				c->id_lnext = -1;
				c->id_rnext = -1;

				// fix 
				rbtree_insert_fix(inst, idx);

				*cc = c;
				return true;
			} else {
				return rbtree_insert(inst, p->id_lnext, key, cc);
			}
		} else {
			if (p->id_rnext == -1) {
				int idx = -1;
				struct connection *c = rbtree_get_connection(inst, &idx);
				assert(c != NULL && idx != -1);

				p->id_rnext = idx;
				inst->size++;

				//c->id = key;
				c->key = key;
				c->id_color = 1;
				c->id_parent = parent;
				c->id_lnext = -1;
				c->id_rnext = -1;

				// fix 
				rbtree_insert_fix(inst, idx);

				*cc = c;
				return true;
			} else {
				return rbtree_insert(inst, p->id_rnext, key, cc);
			}
		}
	}
}

static int
rbtree_find_min(struct rbtree *inst, int idx) {
	int c_idx = idx;
	struct connection *c = connection_array_at(inst->arr, c_idx);
	while (c->id_lnext >= 0) {
		c_idx = c->id_lnext;
		c = connection_array_at(inst->arr, c_idx);
	}
	return c_idx;
}

static void
rbtree_replace_node_in_parent(struct rbtree *inst, int idx, int nidx) {
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (c->id_parent >= 0) {
		struct connection *p = connection_array_at(inst->arr, c->id_parent);
		if (p->id_rnext == idx) {
			p->id_rnext = nidx;
		} else {
			p->id_lnext = nidx;
		}
	}
	if (nidx >= 0) {
		struct connection *nc = connection_array_at(inst->arr, nidx);
		nc->id_parent = c->id_parent;
	}

	// c->free = 0;
}

static int
rbtree_sibling(struct rbtree *inst, int parent, int idx) {
	if (parent >= 0) {
		struct connection *p = connection_array_at(inst->arr, parent);
		struct connection *c = connection_array_at(inst->arr, idx);

		if (p->id_lnext == idx) {
			return p->id_rnext;
		} else {
			return p->id_lnext;
		}
	} else {
		return -1;
	}
}

// idx n
static void
rbtree_remove_fix(struct rbtree *inst, int parent, int idx) {
	if (parent >= 0) { // case 1
		struct connection *p = connection_array_at(inst->arr, parent);
		struct connection *c = connection_array_at(inst->arr, idx);

		int s_idx = rbtree_sibling(inst, parent, idx);
		struct connection *s = connection_array_at(inst->arr, s_idx);
		struct connection *sl = NULL;
		struct connection *sr = NULL;
		if (s && s->id_lnext >= 0) {
			sl = connection_array_at(inst->arr, s->id_lnext);
		}
		if (s && s->id_rnext >= 0) {
			sr = connection_array_at(inst->arr, s->id_rnext);
		}

		if (s && s->id_color == 1) {  // case 2: s->red
			p->id_color = 1;
			s->id_color = 0;
			if (idx == p->id_rnext) {
				rbtree_rotate_right(inst, c->id_parent);
			} else {
				rbtree_rotate_left(inst, c->id_parent);
			}
			// after rotate
			p = connection_array_at(inst->arr, c->id_parent);
			s_idx = rbtree_sibling(inst, c->id_parent, idx);
			s = connection_array_at(inst->arr, s_idx);
			if (s && s->id_lnext >= 0) {
				sl = connection_array_at(inst->arr, s->id_lnext);
			}
			if (s && s->id_rnext >= 0) {
				sr = connection_array_at(inst->arr, s->id_rnext);
			}
		}

		// case 3
		if (p->id_color == 0 &&
			(s_idx == -1 || s->id_color == 0) &&
			(s && (s->id_lnext == -1 || sl->id_color == 0)) &&
			(s && (s->id_rnext == -1 || sr->id_color == 0))) {
			s->id_color = 1; // red
			rbtree_remove_fix(inst, p->id_parent, s->id_parent);
		} else {
			if (p->id_color == 1 &&
				(s_idx == -1 || s->id_color == 0) &&
				(s->id_lnext == -1 || sl->id_color == 0) &&
				(s->id_rnext == -1 || sr->id_color == 0)) {
				s->id_color = 1;
				p->id_color = 0;
			} else {
				// case 5
				if (s && s->id_color == 0) {
					if (idx == p->id_lnext &&
						(sl && sl->id_color == 1) &&
						(s->id_rnext == -1 || sr->id_color == 0)) {
						s->id_color = 1;
						sl->id_color = 0;
						rbtree_rotate_right(inst, s_idx);
					} else if (idx == p->id_rnext &&
						(s->id_lnext == -1 || sl->id_color == 0) &&
						(sr && sr->id_color == 1)) {
						s->id_color = 1;
						sr->id_color = 0;
						rbtree_rotate_left(inst, s_idx);
					}
					// after rotate
					p = connection_array_at(inst->arr, c->id_parent);
					s_idx = rbtree_sibling(inst, c->id_parent, idx);
					s = connection_array_at(inst->arr, s_idx);
					if (s && s->id_lnext >= 0) {
						sl = connection_array_at(inst->arr, s->id_lnext);
					}
					if (s && s->id_rnext >= 0) {
						sr = connection_array_at(inst->arr, s->id_rnext);
					}
				}

				s->id_color = p->id_color;
				p->id_color = 0;

				if (idx == p->id_lnext) {
					sr->id_color = 0;
					rbtree_rotate_left(inst, c->id_parent);
				} else {
					sl->id_color = 0;
					rbtree_rotate_right(inst, c->id_parent);
				}
			}
		}
	}
}

bool
rbtree_remove(struct rbtree *inst, int idx, void *key, struct connection **cc) {
	if (idx == -1) {
		return false;
	}
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (inst->comp(key, c->key) < 0) {
		rbtree_remove(inst, c->id_lnext, key, cc);
	} else if (inst->comp(key, c->key) > 0) {
		rbtree_remove(inst, c->id_rnext, key, cc);
	} else {
		int child = -1;
		struct connection *child_c = NULL;
		if (c->id_lnext >= 0 && c->id_rnext >= 0) {
			int min_idx = rbtree_find_min(inst, c->id_rnext);
			// replace c
			struct connection *n = connection_array_at(inst->arr, min_idx);
			struct connection *np = connection_array_at(inst->arr, n->id_parent);
			if (np->id_lnext == min_idx) {
				np->id_lnext = n->id_lnext; // (-1) remove from 
			} else {
				np->id_rnext = n->id_lnext;
			}

			n->id_lnext = c->id_lnext;
			n->id_rnext = c->id_rnext;
			n->id_parent = c->id_parent;

			struct connection *p = connection_array_at(inst->arr, c->id_parent);
			if (p->id_lnext == idx) {
				p->id_lnext = min_idx;
			} else {
				p->id_rnext = min_idx;
			}

			if (n->id_lnext >= 0) {
				struct connection *l = connection_array_at(inst->arr, n->id_lnext);
				l->id_parent = min_idx;
			}

			if (n->id_rnext >= 0) {
				struct connection *r = connection_array_at(inst->arr, n->id_rnext);
				r->id_parent = min_idx;
			}

			child = min_idx;
			child_c = n;
		} else if (c->id_lnext >= 0 && c->id_rnext == -1) {
			rbtree_replace_node_in_parent(inst, idx, c->id_lnext);
			child = c->id_lnext;
			child_c = connection_array_at(inst->arr, c->id_lnext);
			// fix
		} else if (c->id_lnext == -1 && c->id_rnext >= 0) {
			rbtree_replace_node_in_parent(inst, idx, c->id_rnext);
			child = c->id_rnext;
			child_c = connection_array_at(inst->arr, c->id_rnext);
		} else {
			assert(c->id_lnext == -1 && c->id_rnext == -1);
			rbtree_replace_node_in_parent(inst, idx, -1);
		}

		// fix
		if (c->id_color == 0) {
			if (child_c && child_c->id_color == 1) { // red
				child_c->id_color = 0;          // to be black.
			} else {
				rbtree_remove_fix(inst, c->id_parent, child); // c->black, child->black.
			}
		}

		// last
		*cc = c;
		connection_array_free_co(inst->arr, idx);
		return true;
	}
	return false;
}

bool
rbtree_search(struct rbtree *inst, int idx, void *key, struct connection **cc) {
	if (idx == -1) { // leaf
		*cc = NULL;
		return false;
	}
	assert(idx >= 0 && idx < inst->arr->ccap);
	struct connection *c = connection_array_at(inst->arr, idx);
	if (inst->comp(key, c->key) < 0) {
		return rbtree_search(inst, c->id_lnext, key, cc);
	} else if (inst->comp(key, c->key) == 0) {
		*cc = c;
		return true;
	} else {
		return rbtree_search(inst, c->id_rnext, key, cc);
	}
}

void rbtree_foreach(struct rbtree *inst, int idx, pfn_foreach_t cb) {
	if (idx == -1) {
		return;
	}
	struct connection *c = connection_array_at(inst->arr, idx);
	cb(c);
	rbtree_foreach(inst, c->id_lnext, cb);
	rbtree_foreach(inst, c->id_rnext, cb);
}