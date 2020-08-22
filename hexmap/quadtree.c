// feel good.
#include "quadtree.h"
#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#define MALLOC malloc
#define FREE free

struct obj {
    int id;
    float x;
    float y;
    void* ud;
    int state; // 1 static, 2 dynamic
    trigger cb;
    struct quadnode* qnode;
};

struct listnode {
    struct listnode* next;
    struct obj obj;
};

struct list {
    struct listnode* head;
    int size;
};

struct quadnode {
    struct quadnode* parent;
    struct quadnode* children[4];
    bool leaf;
    struct rect box;
    struct list staticlist;
    struct list dynamiclist;
};

struct quadtree {
    struct quadnode* root;
    struct listnode* freelist;
    int depth;
    int size;
    int obj_id;
};

static void
quadtree_create_node(struct quadtree* self, struct quadnode* data, struct quadnode* parent, int l)
{
    if (l > self->depth) {
        return;
    }
    parent->leaf = false;

    float mid_x = (parent->box.min_x + parent->box.max_x) / 2;
    float mid_y = (parent->box.min_y + parent->box.max_y) / 2;

    // top right
    struct quadnode* tr = &data[self->size++];
    tr->parent = parent;
    for (int i = 0; i < 4; ++i) {
        tr->children[i] = NULL;
    }
    tr->leaf = true;
    tr->box.min_x = mid_x;
    tr->box.min_y = mid_y;
    tr->box.max_x = parent->box.max_x;
    tr->box.max_y = parent->box.max_y;
    tr->staticlist.head = NULL;
    tr->staticlist.size = 0;
    tr->dynamiclist.head = NULL;
    tr->dynamiclist.size = 0;

    parent->children[0] = tr;
    quadtree_create_node(self, data, tr, l + 1);

    // top left
    struct quadnode* tl = &data[self->size++];
    tl->parent = parent;
    tl->leaf = true;
    for (int i = 0; i < 4; ++i) {
        tl->children[i] = NULL;
    }
    tl->box.min_x = parent->box.min_x;
    tl->box.min_y = mid_y;
    tl->box.max_x = mid_x;
    tl->box.max_y = parent->box.max_y;
    tl->staticlist.head = NULL;
    tl->staticlist.size = 0;
    tl->dynamiclist.head = NULL;
    tl->dynamiclist.size = 0;

    parent->children[1] = tl;
    quadtree_create_node(self, data, tl, l + 1);

    // bottom left
    struct quadnode* bl = &data[self->size++];
    bl->parent = parent;
    bl->leaf = true;
    for (int i = 0; i < 4; ++i) {
        bl->children[i] = NULL;
    }
    bl->box.min_x = parent->box.min_x;
    bl->box.min_y = parent->box.min_y;
    bl->box.max_x = mid_x;
    bl->box.max_y = mid_y;
    bl->staticlist.head = NULL;
    bl->staticlist.size = 0;
    bl->dynamiclist.head = NULL;
    bl->dynamiclist.size = 0;

    parent->children[2] = bl;
    quadtree_create_node(self, data, bl, l + 1);

    // bottom right
    struct quadnode* br = &data[self->size++];
    br->parent = parent;
    br->leaf = true;
    for (int i = 0; i < 4; ++i) {
        br->children[i] = NULL;
    }
    br->box.min_x = mid_x;
    br->box.min_y = parent->box.min_y;
    br->box.max_x = parent->box.max_x;
    br->box.max_y = mid_y;
    br->staticlist.head = NULL;
    br->staticlist.size = 0;
    br->dynamiclist.head = NULL;
    br->dynamiclist.size = 0;

    parent->children[3] = br;
    quadtree_create_node(self, data, br, l + 1);
}

struct quadtree*
quadtree_alloc(struct rect rt, int depth)
{
    struct quadtree* tree = (struct quadtree*)malloc(sizeof(*tree));
    tree->root = NULL;
    tree->freelist = NULL;
    tree->depth = depth;
    tree->size = 0;
    tree->obj_id = 0;

    int num = 30;
    struct quadnode* data = (struct quadnode*)malloc(sizeof(*data) * num);
    memset(data, 0, sizeof(*data) * num);

    tree->root = &data[tree->size++];
    tree->root->parent = NULL;
    for (int i = 0; i < 4; ++i) {
        tree->root->children[i] = NULL;
    }
    tree->root->leaf = true;
    tree->root->box = rt;
    tree->root->staticlist.head = NULL;
    tree->root->staticlist.size = 0;
    tree->root->dynamiclist.head = NULL;
    tree->root->dynamiclist.size = 0;
    tree->size++;

    quadtree_create_node(tree, data, tree->root, 2);
    return tree;
}

static void
quadtree_free_list(struct quadtree* self, struct quadnode* qnode)
{
    if (qnode->leaf) {
        if (qnode->staticlist.size > 0) {
            struct listnode* node = qnode->staticlist.head;
            while (node) {
                struct listnode* tmp = node;
                node = node->next;
                free(tmp);
            }
        }
        if (qnode->dynamiclist.size > 0) {
            struct listnode* node = qnode->dynamiclist.head;
            while (node) {
                struct listnode* tmp = node;
                node = node->next;
                free(node);
            }
        }
    } else {
        quadtree_free_list(self, qnode->children[0]);
        quadtree_free_list(self, qnode->children[1]);
        quadtree_free_list(self, qnode->children[2]);
        quadtree_free_list(self, qnode->children[3]);
    }
}

void quadtree_free(struct quadtree* self)
{
    quadtree_free_list(self, self->root);
    while (self->freelist != NULL) {
        struct listnode* node = self->freelist;
        self->freelist = self->freelist->next;
        free(node);
    }
    free(self->root);
    free(self);
}

static struct quadnode*
quadtree_query(struct quadtree* self, struct quadnode* p, float x, float y)
{
    if (p->leaf) {
        return p;
    } else {
        float mid_x = (p->box.min_x + p->box.max_x) / 2;
        float mid_y = (p->box.min_y + p->box.max_y) / 2;

        if (x < mid_x) {
            if (y < mid_y) {
                return quadtree_query(self, p->children[2], x, y);
            } else {
                return quadtree_query(self, p->children[1], x, y);
            }
        } else {
            if (y < mid_y) {
                return quadtree_query(self, p->children[3], x, y);
            } else {
                return quadtree_query(self, p->children[0], x, y);
            }
        }
    }
}

static struct listnode*
quadtree_list_remove(struct quadtree* self, struct list* li, struct obj* o)
{
    assert(li && o);
    if (li->size > 0) {
        if (&li->head->obj == o) {
            struct listnode* node = li->head;
            li->head = li->head->next;
            li->size--;
            return node;
        } else {
            struct listnode* prid = li->head;
            struct listnode* node = li->head->next;
            while (node) {
                if (&node->obj == o) {
                    prid->next = node->next;
                    li->size--;
                    return node;
                } else {
                    prid = node;
                    node = node->next;
                }
            }
            assert(false);
        }
    } else {
        assert(false);
    }
    return NULL;
}

static void
quadtree_list_add(struct quadtree* self, struct list* li, struct listnode* node)
{
    assert(li && node);

    node->next = li->head;
    li->head = node;
    li->size++;
}

struct obj*
quadtree_insert(struct quadtree* self, float x, float y, void* ud, trigger cb)
{
    assert(x >= self->root->box.min_x && x <= self->root->box.max_x);
    assert(y >= self->root->box.min_y && y <= self->root->box.max_y);

    struct listnode* node = NULL;
    if (self->freelist != NULL) {
        node = self->freelist;
        self->freelist = self->freelist->next;
        node->obj.x = x;
        node->obj.y = y;
        node->obj.ud = ud;
        node->obj.qnode = NULL;
        node->obj.cb = cb;
    } else {
        node = (struct listnode*)malloc(sizeof(*node));
        node->next = NULL;
        node->obj.id = ++self->obj_id;
        node->obj.x = x;
        node->obj.y = y;
        node->obj.ud = ud;
        node->obj.qnode = NULL;
        node->obj.cb = cb;
    }
    assert(node != NULL);
    struct quadnode* qnode = quadtree_query(self, self->root, x, y);

    quadtree_list_add(self, &qnode->staticlist, node);
    node->obj.state = 1;
    node->obj.qnode = qnode;

    return &node->obj;
}

void quadtree_remove(struct quadtree* self, struct obj* o)
{
    struct quadnode* qnode = o->qnode;
    struct list* li = NULL;
    if (o->state == 1) { // static
        li = &qnode->staticlist;
    } else {
        li = &qnode->dynamiclist;
    }
    struct listnode* node = quadtree_list_remove(self, li, o);

    node->next = self->freelist;
    self->freelist = node;
}

void quadtree_update(struct quadtree* self, struct obj* o, float x, float y)
{
    if (o->x == x && o->y == y) {
        if (o->state == 1) { // static
        } else {
            struct quadnode* qnode = o->qnode;
            struct list* li = &qnode->dynamiclist;

            // remove from dynamic
            struct listnode* node = quadtree_list_remove(self, li, o);

            // add into static
            quadtree_list_add(self, &qnode->staticlist, node);

            o->state = 1;
        }
    } else {
        if (o->state == 1) {
            // judge
            struct quadnode* qnode = o->qnode;
            struct list* li = &qnode->staticlist;

            // remove from static
            struct listnode* node = quadtree_list_remove(self, li, o);

            if (x >= qnode->box.min_x && x < qnode->box.max_x && y >= qnode->box.min_y && y < qnode->box.max_y) {
                // add into dynamic
                quadtree_list_add(self, &qnode->dynamiclist, node);

                //
                o->x = x;
                o->y = y;
                o->state = 2;
            } else {
                struct quadnode* qnode = quadtree_query(self, self->root, x, y);

                // add into dynamic
                quadtree_list_add(self, &qnode->dynamiclist, node);

                //
                o->x = x;
                o->y = y;
                o->state = 2;
                o->qnode = qnode;
            }
        } else {
            struct quadnode* qnode = o->qnode;
            if (x >= qnode->box.min_x && x < qnode->box.max_x && y >= qnode->box.min_y && y < qnode->box.max_y) {

                //
                o->x = x;
                o->y = y;
            } else {
                struct listnode* node = quadtree_list_remove(self, &qnode->staticlist, o);
                struct quadnode* qnode = quadtree_query(self, self->root, x, y);

                // add into dynamic
                quadtree_list_add(self, &qnode->dynamiclist, node);

                //
                o->x = x;
                o->y = y;
                o->qnode = qnode;
            }
        }
    }
}
