/*
* Copyright (c) 2015-2015 Irlan Robson http://www.irlans.wordpress.com
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

#include "b3r32.h"
#if defined(GNUFIXMATH)
#include <fixmath.h>
#else
#include <fix16.h>
#endif

b3R32 b3R32::max = b3R32(fix16_maximum);
b3R32 b3R32::min = b3R32(fix16_minimum);
b3R32 b3R32::pi = b3R32(fix16_pi);
b3R32 b3R32::e = b3R32(fix16_e);
b3R32 b3R32::one = b3R32(fix16_one);
b3R32 b3R32::zero = 0;

b3R32::b3R32() {
	i = 0;
}

b3R32::b3R32(const int16_t b) { i = fix16_from_int(b); }

b3R32::b3R32(const b3R32 &b) {
	i = b.i;
}

b3R32::b3R32(const int32_t v) {
	i = fix16_from_int(v);
}

b3R32::b3R32(const uint32_t b) {
	i = fix16_from_int(b);
}

b3R32::b3R32(const uint64_t b) { i = fix16_from_int(b); }

b3R32::b3R32(const float b) { i = fix16_from_float(b); }
b3R32::b3R32(const double b) { i = fix16_from_dbl(b); }

// Add this vector with another vector.
b3R32& b3R32::operator+=(const b3R32& b) {
#if defined(GNUFIXMATH)
	i = fx_addx(i, b.i);
	return (*this);
#else
	i = fix16_add(i, b.i);
	return (*this);
#endif
}

b3R32& b3R32::operator+=(b3R32& b) {
#if defined(GNUFIXMATH)
	i = fx_addx(i, b.i);
	return (*this);
#else
	i = fix16_add(i, b.i);
	return (*this);
#endif
}

// Subtract this vector from another vector.
b3R32& b3R32::operator-=(const b3R32& b) {
#if defined(GNUFIXMATH)
	i = fx_subx(i, b.i);
	return (*this);
#else
	i = fix16_sub(i, b.i);
	return (*this);
#endif
}

b3R32& b3R32::operator-=(b3R32& b) {
#if defined(GNUFIXMATH)
	i = fx_subx(i, b.i);
	return (*this);
#else
	i = fix16_sub(i, b.i);
	return (*this);
#endif
}

// Multiply this vector by a scalar.
b3R32& b3R32::operator*=(const b3R32& b) {
#if defined(GNUFIXMATH)
	i = fx_mulx(i, b.i, 10);
	return (*this);
#else
	i = fix16_smul(i, b.i);
	return (*this);
#endif
}

b3R32& b3R32::operator*=(b3R32& b) {
#if defined(GNUFIXMATH)
	i = fx_mulx(i, b.i, 10);
	return (*this);
#else
	i = fix16_smul(i, b.i);
	return (*this);
#endif
}

// Multiply this vector by a scalar.
b3R32& b3R32::operator/=(const b3R32& b) {
#if defined(GNUFIXMATH)
	i = fx_divx(i, b.i, 10);
	return (*this);
#else
	i = fix16_smul(i, b.i);
	return (*this);
#endif
}

b3R32 & b3R32::operator++() {
#if defined(GNUFIXMATH)
	i = fx_addx(i, 1);
	return (*this);
#else
	i = fix16_sadd(i, one);
	return (*this);
#endif
}

b3R32 & b3R32::operator++(int) {
#if defined(GNUFIXMATH)
	i = fx_addx(i, 1);
	return (*this);
#else
	i = fix16_ssub(i, one);
	return (*this);
#endif
}

b3R32::operator bool() {
	return (i > 0);
}

b3R32::operator int32_t() {
	return i;
}

// Set to the zero vector.
void b3R32::SetZero() {
	i = 0;
}

// Set from a triple.
void b3R32::Set(int32_t v) {
	i = v;
}

// Negate a vector.
b3R32 operator-(const b3R32& a) {
#if defined(GNUFIXMATH)
	fixed_t i = fx_subx(0, a.i);
	return b3R32(i);
#else
	fix16_t v = fix16_sub(0, a.i);
	return b3R32(v);
#endif
}

b3R32 b3R32::Sqrt(const b3R32& b) {
#if defined(GNUFIXMATH)
	fixed_t i = fx_sqrtx(b.i, 10);
	return b3R32(i);
#else
	fix16_t v = fix16_sqrt(b.i);
	return b3R32(v);
#endif
}

b3R32 b3R32::Sin(const b3R32& b) {
#if defined(GNUFIXMATH)
	fixed_t v = fx_sinx(b.i, 10);
	return b3R32(v);
#else
	fix16_t v = fix16_sin(b.i);
	return b3R32(v);
#endif
}

b3R32 b3R32::Cos(const b3R32& b) {
#if defined(GNUFIXMATH)
	fixed_t v = fx_cosx(b.i, 10);
	return b3R32(v);
#else
	fix16_t v = fix16_sin(b.i);
	return b3R32(v);
#endif
}

b3R32 b3R32::Atan2(const b3R32& a, const b3R32& b) {
#if defined(GNUFIXMATH)
	// TODO
	return b3R32(0);
#else
	fix16_t v = fix16_atan2(a.i, b.i);
	return b3R32(v);
#endif
}

// friend
// Compute sum of two vectors.
b3R32 operator+(const b3R32 a, const b3R32 b) {
#if defined(GNUFIXMATH)
	fixed_t v = fx_addx(a.i, b.i);
	return b3R32(v);
#else
	fix16_t v = fix16_sadd(a.i, b.i);
	return b3R32(v);
#endif
}

// Compute subtraction of two vectors.
b3R32 operator-(const b3R32 a, const b3R32 b) {
#if defined(GNUFIXMATH)
	fixed_t v = fx_subx(a.i, b.i);
	return b3R32(v);
#else
	fix16_t v = fix16_ssub(a.i, b.i);
	return b3R32(v);
#endif
}

b3R32 operator*(const b3R32 a, const b3R32 b) {
#if defined(GNUFIXMATH)
	fixed_t v = fx_mulx(a.i, b.i, 10);
	return b3R32(v);
#else
	fix16_t v = fix16_mul(a.i, b.i);
	return b3R32(v);
#endif
}

b3R32 operator*(const float a, const b3R32 b) {
#if defined(GNUFIXMATH)
	//TODO::
	//fixed_t v = fx_mulx(a.i, b.i, 10);
	return b3R32(0);
#else
	fix16_t a_ = fix16_from_float(a);
	fix16_t v = fix16_mul(a_, b.i);
	return b3R32(v);
#endif
}

b3R32 operator*(const double a, const b3R32 b) {
#if defined(GNUFIXMATH)
	// TODO
	return b3R32(0);
#else
	fix16_t a_ = fix16_from_dbl(a);
	fix16_t v = fix16_mul(a_, b.i);
	return b3R32(v);
#endif
}

b3R32 operator/(const b3R32 a, const b3R32 b) {
#if defined(GNUFIXMATH)
	fixed_t v = fx_divx(a.i, b.i, 10);
	return b3R32(v);
#else
	fix16_t v = fix16_div(a.i, b.i);
	return b3R32(v);
#endif
}

bool  operator==(const b3R32 a, const b3R32 b) {
	return (a.i == b.i);
}

bool  operator!=(const b3R32 a, const b3R32 b) {
	return (a.i != b.i);
}

bool  operator<(const b3R32 a, const b3R32 b) {
	return (a.i < b.i);
}

bool  operator<=(const b3R32 a, const b3R32 b) {
	return (a.i <= b.i);
}

bool  operator>(const b3R32 a, const b3R32 b) {
	return (a.i > b.i);
}

bool  operator>=(const b3R32 a, const b3R32 b) {
	return (a.i >= b.i);
}
