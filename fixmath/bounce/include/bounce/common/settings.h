﻿/*
* Copyright (c) 2016-2016 Irlan Robson http://www.irlan.net
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

#ifndef B3_SETTINGS_H
#define B3_SETTINGS_H

#include <bounce/common/math/b3r32.h>
#include <assert.h>
#include <cstring>
#include <new>
#include <float.h>

typedef signed int i32;
typedef signed short i16;
typedef signed char	i8;
typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned char u8;
typedef unsigned long long u64;
#if !defined(B3_NO_PROFILE)
typedef double float64;
#endif
#if defined(B3_NO_FIXMATH)
typedef float  float32;
#else 
typedef struct b3R32 float32;
#endif


// You can modify the following parameters as long
// as you know what you're doing.

#if defined(B3_NO_FIXMATH)
#define B3_PI (3.14159265359f)
#define	B3_MAX_FLOAT (FLT_MAX)
#define	B3_EPSILON   (FLT_EPSILON)
#else
#define B3_PI        b3R32(3.14159265359f)
#define	B3_MAX_FLOAT (b3R32::max())
#define	B3_EPSILON   (b3R32::zero())
#endif

#define	B3_MAX_U8 (0xFF)
#define	B3_MAX_U32 (0xFFFFFFFF)

// Collision
#if defined(B3_NO_FIXMATH)
// How much an AABB in the broad-phase should be extended by 
// to disallow unecessary proxy updates.
// A larger value increases performance when there are 
// no objects closer to the AABB because no contacts are 
// even created.
#define B3_AABB_EXTENSION (0.2f)

// This is used to extend AABBs in the broad-phase. 
// Is used to predict the future position based on the current displacement.
// This is a dimensionless multiplier.
#define B3_AABB_MULTIPLIER (2.0f)

// Collision and constraint tolerance.
#define B3_LINEAR_SLOP (0.005f)
#define B3_ANGULAR_SLOP (2.0f / 180.0f * B3_PI)

// The radius of the hull shape skin.
#define B3_HULL_RADIUS (0.0f * B3_LINEAR_SLOP)
#define B3_HULL_RADIUS_SUM (2.0f * B3_HULL_RADIUS)
#else
#define B3_AABB_EXTENSION (b3R32(0.2f))

// This is used to extend AABBs in the broad-phase. 
// Is used to predict the future position based on the current displacement.
// This is a dimensionless multiplier.
#define B3_AABB_MULTIPLIER (b3R32(2.0f))

// Collision and constraint tolerance.
#define B3_LINEAR_SLOP  (b3R32(0.005f))
#define B3_ANGULAR_SLOP (b3R32(2.0f) / b3R32(180.0f) * B3_PI)

// The radius of the hull shape skin.
#define B3_HULL_RADIUS     (b3R32(0.0f) * B3_LINEAR_SLOP)
#define B3_HULL_RADIUS_SUM (b3R32(2.0f) * B3_HULL_RADIUS)
#endif

// Dynamics
#if defined(B3_NO_FIXMATH)
// The maximum number of manifolds that can be build 
// for all contacts. 
#define B3_MAX_MANIFOLDS (3)

// If this is equal to 4 then the contact generator
// will keep the hull-hull manifold clipped points up to 4 such that 
// still creates a stable manifold to the solver. More points 
// usually means better torque balance but can decrease 
// the performance of the solver significantly. 
// Therefore, keep this to 4 for greater performance.
#define B3_MAX_MANIFOLD_POINTS (4)

// Maximum translation per step to prevent numerical instability 
// due to large linear velocity.
#define B3_MAX_TRANSLATION (2.0f)
#define B3_MAX_TRANSLATION_SQUARED (B3_MAX_TRANSLATION * B3_MAX_TRANSLATION)

// Maximum rotation per step to prevent numerical instability due to 
// large angular velocity.
#define B3_MAX_ROTATION (0.5f * B3_PI)
#define B3_MAX_ROTATION_SQUARED (B3_MAX_ROTATION * B3_MAX_ROTATION)

// The maximum position correction used when solving constraints. This helps to
// prevent overshoot.
#define B3_MAX_LINEAR_CORRECTION (0.2f)
#define B3_MAX_ANGULAR_CORRECTION (8.0f / 180.0f * B3_PI)

// This controls how faster overlaps should be resolved per step.
// This is less than and would be close to 1, so that the all overlap is resolved per step.
// However values very close to 1 may lead to overshoot.
#define B3_BAUMGARTE (0.1f)

// If the relative velocity of a contact point is below 
// the threshold then restitution is not applied.
#define B3_VELOCITY_THRESHOLD (1.0f)

// Sleep

#define B3_TIME_TO_SLEEP (0.2f)
#define B3_SLEEP_LINEAR_TOL (0.05f)
#define B3_SLEEP_ANGULAR_TOL (2.0f / 180.0f * B3_PI)
#else
// The maximum number of manifolds that can be build 
// for all contacts. 
#define B3_MAX_MANIFOLDS (3)

// If this is equal to 4 then the contact generator
// will keep the hull-hull manifold clipped points up to 4 such that 
// still creates a stable manifold to the solver. More points 
// usually means better torque balance but can decrease 
// the performance of the solver significantly. 
// Therefore, keep this to 4 for greater performance.
#define B3_MAX_MANIFOLD_POINTS (4)

// Maximum translation per step to prevent numerical instability 
// due to large linear velocity.
#define B3_MAX_TRANSLATION         (b3R32(2.0f))
#define B3_MAX_TRANSLATION_SQUARED (B3_MAX_TRANSLATION * B3_MAX_TRANSLATION)

// Maximum rotation per step to prevent numerical instability due to 
// large angular velocity.
#define B3_MAX_ROTATION         (b3R32(0.5f) * B3_PI)
#define B3_MAX_ROTATION_SQUARED (B3_MAX_ROTATION * B3_MAX_ROTATION)

// The maximum position correction used when solving constraints. This helps to
// prevent overshoot.
#define B3_MAX_LINEAR_CORRECTION  (b3R32(0.2f))
#define B3_MAX_ANGULAR_CORRECTION (b3R32(8.0f) / b3R32(180.0f) * B3_PI)

// This controls how faster overlaps should be resolved per step.
// This is less than and would be close to 1, so that the all overlap is resolved per step.
// However values very close to 1 may lead to overshoot.
#define B3_BAUMGARTE (b3R32(0.1f))

// If the relative velocity of a contact point is below 
// the threshold then restitution is not applied.
#define B3_VELOCITY_THRESHOLD (b3R32(1.0f))

// Sleep

#define B3_TIME_TO_SLEEP     (b3R32(0.2f))
#define B3_SLEEP_LINEAR_TOL  (b3R32(0.05f))
#define B3_SLEEP_ANGULAR_TOL (b3R32(2.0f) / b3R32(180.0f) * B3_PI)
#endif

// Memory

#define B3_NOT_USED(x) ((void)(x))
#define B3_ASSERT(c) assert(c)
#define B3_STATIC_ASSERT(c) static_assert(c)

#define B3_KiB(n) (1024 * n)
#define B3_MiB(n) (1024 * B3_KiB(n))
#define B3_GiB(n) (1024 * B3_MiB(n))

#ifndef B3_FORCE_INLINE
# if defined(_MSC_VER) && (_MSC_VER >= 1200)
#  define B3_FORCE_INLINE __forceinline
# else
#  define B3_FORCE_INLINE __inline
# endif
#endif

#define B3_JOIN(a, b) a##b
#define B3_CONCATENATE(a, b) B3_JOIN(a, b)
#define B3_UNIQUE_NAME(name) B3_CONCATENATE(name, __LINE__)

#define B3_PROFILE(name) b3ProfileScope B3_UNIQUE_NAME(scope)(name)

// You should implement this function to use your own memory allocator.
void* b3Alloc(u32 size);

// You must implement this function if you have implemented b3Alloc.
void b3Free(void* block);

// You should implement this function to visualize log messages coming 
// from this software.
void b3Log(const char* string, ...);

// You should implement this function to listen when a profile scope is opened.
void b3BeginProfileScope(const char* name);

// You must implement this function if you have implemented b3BeginProfileScope.
// Implement this function to listen when a profile scope is closed.
void b3EndProfileScope();

inline b3R32 b3Cos(b3R32 x) {
	return b3R32::Cos(x);
}

inline b3R32 b3Sin(b3R32 x) {
	return b3R32::Sin(x);
}

// 
struct b3ProfileScope {
	b3ProfileScope(const char* name) {
		b3BeginProfileScope(name);
	}

	~b3ProfileScope() {
		b3EndProfileScope();
	}
};

// The current version this software.
struct b3Version {
	u32 major; //significant changes 
	u32 minor; //minor features
	u32 revision; //patches
};

// The current version of Bounce.
extern b3Version b3_version;

#endif