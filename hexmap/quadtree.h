#ifndef quadtree_h
#define quadtree_h

struct rect {
	float min_x;
	float min_y;
	float max_x;
	float max_y;
};

struct obj;
struct quadtree;

typedef void (*trigger)(struct obj *a, struct obj *b);

struct quadtree *
quadtree_alloc(struct rect rt, int depth);

void
quadtree_free(struct quadtree *self);

struct obj *
quadtree_insert(struct quadtree *self, float x, float y, void *ud, trigger cb);

void
quadtree_update(struct quadtree *self, struct obj *o, float x, float y);

#endif

