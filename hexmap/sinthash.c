#include "shash.h"

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>

struct node {
	uint32_t hash;
	int      next;  // 0 ~ cap-1 Õý³££¬-1,free, cap 
	int64_t k;
	int64_t v;
};

struct shash {
	struct node *data;
	int cap;
	int size;
	int free;
};

uint32_t JSHash(char *str) {
	int len = strlen(str);
	uint32_t hash = 1315423911;
	for (int i = 0; i < len; i++) {
		hash ^= ((hash << 5) + str[i] + (hash >> 2));
	}
	return hash;
}

struct shash *
shash_alloc(int cap) {
	struct shash *inst = (struct shash *)malloc(sizeof(*inst));
	inst->cap = cap;
	inst->size = 0;
	inst->free = cap - 1;
	inst->data = (struct node *)malloc(sizeof(struct node) * cap);
	for (size_t i = 0; i < cap; i++)
	{
		inst->data[i].k.next = -1;
	}
	return inst;
}

void
shash_free(struct shash *self) {
	free(self->data);
	free(self);
}

static struct node *
shash_get_free(struct shash *self) {
	if (self->free < 0)
	{
		self->free = self->cap - 1;
	}
	int step = 0;
	struct node *node = &(self->data[self->free]);
	while (node->k.next != -1)
	{
		self->free--;
		node = &self->data[self->free];
		step++;
		if (step >= self->cap)
		{
			break;
		}
	}
	if (step == self->cap)
	{
		int ocap = self->cap;
		int cap = ocap * 2;
		struct node *data = (struct node *)malloc(sizeof(struct node) * cap);
		for (size_t i = ocap; i < cap; i++)
		{
			self->data[i].k.next = -1;
		}
		memcpy(data, self->data, sizeof(struct node) *ocap);
		free(self->data);
		self->data = data;
		self->free = cap - 1;
		return &self->data[self->free];
	}
	return node;
}

int
shash_insert(struct shash *self, int32_t i, int32_t v) {
	/*if (self->size == self->cap)
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
	}
	else {
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
		}
		else {
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
	}*/
	return NULL;
}


int32_t
shash_search(struct shash *self, int32_t i){
	//assert(strlen(key) > 0);
	//uint32_t hash = JSHash(key);
	//uint32_t idx = hash % self->cap;
	//struct node *node = &self->data[idx];
	//while (strcmp(node->key, key) != 0) {
	//	if (node->next != -1)
	//	{
	//		node = &self->data[node->next];
	//	}
	//}
	//if (strcmp(node->key, key) == 0)
	//{
	//	// hit
	//	return node;
	//}
	//else {
	//	return NULL;
	//}
}

int
shash_remove(struct shash *self, int32_t i) {

}