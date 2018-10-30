#ifndef mt_rand_h
#define mt_rand_h

#include <stdint.h>

#define N             (624)                /* length of state vector */
#define M             (397)                /* a period parameter */

typedef struct {
  uint32_t state[N];
  uint32_t left;
  uint32_t *next;  
} MTState;

void
mt_srand(uint32_t seed, MTState *mtInfo);

uint32_t
php_mt_rand(MTState *mtInfo);

uint32_t
php_mt_rand_range(MTState *mtInfo, uint32_t min, uint32_t max);

#endif