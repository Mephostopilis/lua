#pragma once
#ifndef aabb_h
#define aabb_h

#include <base/cstdafx.h>

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>


struct aabb {
	struct vector3 min;
	struct vector3 max;
};

static inline struct vector3
	aabb_center(struct aabb *A) {
#ifdef FIXEDPT
	fix16_t fix16_half = fix16_div(fix16_one, fix16_from_int(2));
	struct vector3 center;
	center.x = fix16_mul(fix16_add(A->min.x, A->max.x), fix16_half);
	center.y = fix16_mul(fix16_add(A->min.y, A->max.y), fix16_half);
	center.z = fix16_mul(fix16_add(A->min.z, A->max.z), fix16_half);

	return center;
#endif // FIXEDPT
}

static inline void
	aabb_corners(struct vector3 corners[8]) {

}

static inline bool
	aabb_intersects(struct aabb *A, struct aabb *B) {
	return ((A->min.x >= B->min.x && A->min.x <= B->max.x) || (B->min.x >= A->min.x && B->min.x <= B->max.x)) &&
		((A->min.y >= B->min.y && A->min.y <= B->max.y) || (B->min.y >= A->min.y &&B->min.y <= A->max.y)) &&
		((A->min.z >= B->min.z && A->min.z <= B->max.z) || (B->min.z >= A->min.z && B->min.z <= A->max.z));
}

static inline bool
	aabb_contain_point(struct aabb *A, struct vector3 point) {
	if (point.x < A->min.x) return false;
	if (point.y < A->min.y) return false;
	if (point.z < A->min.z) return false;
	if (point.x > A->max.x) return false;
	if (point.y > A->max.y) return false;
	if (point.z > A->max.z) return false;
	return true;
}

static inline void
	aabb_merge(struct aabb *A, struct aabb *B) {
	A->min.x = fix16_min(A->min.x, B->min.x);
	A->min.y = fix16_min(A->min.y, B->min.y);
	A->min.z = fix16_min(A->min.z, B->min.z);

	A->max.x = fix16_max(A->max.x, B->max.x);
	A->max.y = fix16_max(A->max.y, B->max.y);
	A->max.z = fix16_max(A->max.z, B->max.z);
}

static inline void
	aabb_reset(struct aabb *A) {

}

static inline bool
	aabb_empty(struct aabb *A) {
	return A->min.x > A->max.x || A->min.y > A->max.y || A->min.z > A->max.z;
}

#ifdef __cplusplus
}
#endif
#endif // !aabb_h

