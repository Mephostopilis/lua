#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>

struct node {
	uint32_t hash;
	uint32_t next;
	char key[64];
	union {
		int     b;
		int32_t i;
		int64_t l;
		float   f;
		double  d;
		char   *p;
	}
}

struct hash {
	struct node *data;
	int cap;
	int size;
	int free;
}

uint32_t JSHash(char *str) {  
	int len = strlen(str);
	uint32_t hash = 1315423911;  
	for(int i = 0; i < len; i++) {  
         hash ^= ((hash << 5) + str[i] + (hash >> 2));  
    }  
    return hash;  
}  

struct hash *
hash_alloc(int cap) {
	struct hash *inst = (struct hash *)malloc(sizeof(*inst));
	inst->cap = cap;
	inst->size = 0;
	inst->free = cap - 1;
	inst->data = (struct node *)malloc(sizeof(struct node) * cap);
	return inst;
}

void 
hash_free(struct hash *self) {
	free(self->data);
	free(self);
}

static struct node *
hash_get_free() {
	if (self->free < 0)
	{
		self->free = self->cap - 1;
	}
	struct node *node = self->data[self->free];
	while (strlen(node->key) != 0)
	{
		self->free--;
		node = self->data[self->free];
	}
	return node;
}

struct node *
hash_insert(struct hash *self, char *key) {
	if (self->size == self->cap)
	{
		return;
	}
	assert(strlen(key) > 0);
	uint32_t hash = JSHash(key);
	uint32_t idx = hash % self->cap;
	struct node *mp = self->data[idx];
	if (strlen(mp->key) == 0) {
		memcpy(mp->key, key, strlen(key));
		mp->hash = hash;
		mp->next = -1;
		return mp;
	} else {
		if (mp->hash % self->cap == idx) {
			struct node *free = hash_get_free();
			memcpy(free->key, key, strlen(key));
			free->hash = hash;
			free->next = -1;

			struct node *node = mp;
			while (node->next != -1) {
				node = self->data[node->next];
			}
			node->next = (free - self->data);
			return free;
		} else {
			struct node *free = hash_get_free();
			*free = *mp;

			uint32_t old_idx = free->hash % self->cap;
			struct node *old_mp = self->data[old_idx];

			struct node *node = old_mp;
			while (node->next != -1) {
				node = self->data[node->next];
			}
			node->next = free - self->data;

			memcpy(mp->key, key, strlen(key));
			mp->hash = hash;
			mp->next = -1;
			return mp;
		}
	}
}


struct node *
hash_search(struct hash *self, char *key) {
	assert(strlen(key) > 0);
	uint32_t hash = JSHash(key);
	uint32_t idx = hash % self->cap;
	struct node *node = &self->data[idx];
	while (strcmp(node->key, key) != 0) {
		if (node->next != -1)
		{
			node = &self->data[node->next];
		}
	}
	if (strcmp(node->key, key) == 0)
	{
		// hit
		return node;
	} else {
		return NULL;
	}
}