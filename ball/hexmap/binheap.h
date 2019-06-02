/*
* binheap.h
* Copyright (C) 2016-2017 Hu
*
*
* binaryheap.h is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* binaryheap.h is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with binaryheap.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef BIN_HEAP_H
#define BIN_HEAP_H

#ifdef __cplusplus
extern "C" {
#endif

/*
	* TODO:
	* - Needs benchmarking
	* - Implement better traversal functionality
	*/


	/* Override to change heap resizing. Heaps resize doubles capacity. */
#ifndef BINHEAP_RESIZE
#define BINHEAP_RESIZE 1
#endif

/* Starting heap size */
#ifndef BINHEAP_INITIAL_CAPACITY
#define BINHEAP_INITIAL_CAPACITY 20
#endif

/* Override to avoid malloc */
#ifndef BINHEAP_ALLOC
#include <stdlib.h>
#define BINHEAP_ALLOC(x)        malloc(x)
#define BINHEAP_REALLOC(x, num) realloc(x, num)
#define BINHEAP_FREE(x)         free(x)
#endif

#ifndef UNIT_T
#error "unit_t must be defined."
#endif // !UNIT_T
#define unit_size sizeof(UNIT_T)

#include <assert.h>
#include <stdio.h>
#include <string.h>

typedef UNIT_T * binheap_iterator_t;

/* Comparitor function pointer */
typedef int(*compare_f)(binheap_iterator_t, binheap_iterator_t);

/* Visitor function pointer */
typedef void(*visit_f)(binheap_iterator_t);

typedef void(*free_f)(binheap_iterator_t);

/* Forward declare */
typedef struct binheap {
	compare_f cmp;
	free_f free;
	size_t size;
	size_t capacity;
	UNIT_T data[0];
} *binheap_t;

static void bubble_up(binheap_t* heap, size_t index);
static void bubble_down(binheap_t* heap, size_t index);
static int  resize(binheap_t* heap);

#define alloc_size(cap) (sizeof(binheap_t) + (unit_size * (cap))) 

static size_t HEAP_CAPACITY_MAX = (size_t)-1;

static struct binheap *
	binheap_new(compare_f cmp, free_f free) {
	assert(cmp);
	binheap_t heap = (binheap_t)BINHEAP_ALLOC(alloc_size(BINHEAP_INITIAL_CAPACITY));
	assert(heap);
	if (!heap)
		return NULL;

	heap->cmp = cmp;
	heap->free = free;
	heap->size = 0;
	heap->capacity = BINHEAP_INITIAL_CAPACITY;

	return heap;
}

static void
	binheap_destroy(binheap_t* heap) {
	assert(heap);
	BINHEAP_FREE(*heap);
}

static void
	binheap_destroy_free(binheap_t* heap, free_f free) {
	assert(heap && *heap);
	free_f fpn = (*heap)->free;
	if (free != NULL) {
		fpn = free;
	}

	size_t i;
	for (i = 0; i < (*heap)->size; ++i) {
		fpn(&(*heap)->data[i]);
	}

	binheap_destroy(heap);
}

static size_t
	binheap_size(binheap_t* heap) {
	assert(heap && *heap);
	return ((*heap)->size);
}

static size_t
	binheap_capacity(binheap_t* heap) {
	assert(heap);
	return ((*heap)->capacity);
}

static void
	binheap_traverse(binheap_t* heap, visit_f visit) {
	assert(heap && (*heap));
	assert(visit);

	if (!(*heap)->size)
		return;

	size_t i = 0;
	for (; i < (*heap)->size; ++i) {
		visit(&(*heap)->data[i]);
	}
}

static int
	binheap_push(binheap_t* heap, UNIT_T * ptr) {
	assert(heap);

	/* Check for overflow */
	if ((*heap)->size + 1 == HEAP_CAPACITY_MAX)
		return 0;

	/* If we ran out of space attempt to grab some more */
	if ((*heap)->size == (*heap)->capacity) {
		if (!resize(heap))
			return 0;
	}

	/* Do the add then bubble up */

	(*heap)->data[(*heap)->size++] = *ptr;
	bubble_up(heap, (*heap)->size - 1);

	return 1;
}

static void
	binheap_pop(binheap_t* heap, binheap_iterator_t* out) {
	assert(heap);

	if ((*heap)->size == 0)
		return;

	*out = &(*heap)->data[0];

	/* Take the last element in the heap and bubble it down */
	if (--(*heap)->size > 0) {
		*(*heap)->data = (*heap)->data[(*heap)->size];
		bubble_down(heap, 0);
	}
}

static void
	binheap_peek(binheap_t* heap, binheap_iterator_t* out) {
	assert(heap);
	*out = ((*heap)->size > 0 ? &(*heap)->data[0] : NULL);
}

static int
	binheap_search(binheap_t* heap, binheap_iterator_t* out, binheap_iterator_t elt, compare_f cmp) {
	assert(heap &&  *heap);
	int i = 0;
	for (; i < (*heap)->capacity; i++) {
		binheap_iterator_t ptr = &(*heap)->data[i];
		if (cmp(ptr, elt) == 0) {
			*out = ptr;
			return 1;
		}
	}
}

int resize(binheap_t* heap) {
	size_t new_size = (*heap)->capacity << 1;
	/* Bail if resizing is not allowed or if the resize overflowed */
	if (!BINHEAP_RESIZE || (new_size < (*heap)->capacity && new_size < HEAP_CAPACITY_MAX))
		return 0;

	binheap_t new_heap = (binheap_t)BINHEAP_REALLOC((*heap), alloc_size(new_size));

	if (!new_heap) {
		/* When realloc fails, our entire block of memory is invalidated so
		* unfortunately, we must free it along with the entire heap */
		return 0;
	}

	if (new_heap != *heap) {
		memcpy(new_heap, *heap, alloc_size((*heap)->capacity));
		binheap_destroy(heap);
		*heap = new_heap;
	} else {
		*heap = new_heap;
	}

	return 1;
}

void bubble_up(binheap_t* heap, size_t index) {
	assert(heap);
	assert(index >= 0);
	assert(index < (*heap)->size);

	/* If we are at the root level, we are sorted */
	if (index == 0)
		return;

	size_t parent_index = (index - 1) / 2;

	if ((*heap)->cmp(&(*heap)->data[index], &(*heap)->data[parent_index]) < 0) {
		UNIT_T tmp = (*heap)->data[index];
		(*heap)->data[index] = (*heap)->data[parent_index];
		(*heap)->data[parent_index] = tmp;

		bubble_up(heap, parent_index);
	}
}

/**
* Recursively bubbles down data elements in a heap based on the user
* comparitor function (min/max). The result of this operation is a
* binary heap with its top-most element being the smallest/largest
* in the heap.
*
* @param[in] heap  The binary heap
* @param[in] index The current heap index
*/
void bubble_down(binheap_t* heap, size_t index) {
	assert(heap);
	assert(index >= 0);
	assert(index < (*heap)->size);

	/* We are at the bottom of the heap, we are sorted */
	if (index == (*heap)->size - 1)
		return;

	size_t swp = index;
	size_t left = (index << 1) + 1;
	size_t right = (index << 1) + 2;

	/* If this element compares less than its left child or right children swap it */
	if (left < (*heap)->size && (*heap)->cmp(&(*heap)->data[left], &(*heap)->data[swp]) < 0)
		swp = left;
	if (right < (*heap)->size && (*heap)->cmp(&(*heap)->data[right], &(*heap)->data[swp]) < 0)
		swp = right;

	/* Perform the actual swap, and continue to bubble down */
	if (swp != index) {
		UNIT_T tmp = (*heap)->data[index];
		(*heap)->data[index] = (*heap)->data[swp];
		(*heap)->data[swp] = tmp;

		bubble_down(heap, swp);
	}
}

#ifdef __cplusplus
}
#endif

#endif /* binheap_H */
