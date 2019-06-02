#ifndef bh_wp_h
#define bh_wp_h

struct HexWaypoint;

#define UNIT_T             struct HexWaypoint *
#include "binheap.h"
#define bh_wp_value_t      UNIT_T
#define bh_wp_iterator_t   UNIT_T *
#define bh_wp_t            binheap_t
#define bh_wp_new          binheap_new
#define bh_wp_destroy      binheap_destroy
#define bh_wp_destroy_free binheap_destroy_free
#define bh_wp_size         binheap_size
#define bh_wp_capacity     binheap_capacity
#define bh_wp_traverse     binheap_traverse
#define bh_wp_push         binheap_push
#define bh_wp_pop          binheap_pop
#define bh_wp_peek         binheap_peek
#define bh_wp_search       binheap_search

#endif // !bh_wp_h
