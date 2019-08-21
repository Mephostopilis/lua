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
#include <assert.h>

b3R32::b3R32()
{
    _i = 0;
    _f = 0.0f;
}

b3R32::b3R32(const short int& b)
{
    _i = fix16_from_int(b);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
}

b3R32::b3R32(const int& b)
{
    _i = fix16_from_int(b);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
}

b3R32::b3R32(const long long& b)
{
    int32_t b_ = (int32_t)b;
    _i = fix16_from_int(b_);
}

b3R32::b3R32(const unsigned int& b)
{
    _i = fix16_from_int(b);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
}

b3R32::b3R32(const unsigned long long& b)
{
    int32_t b_ = (int32_t)b;
    _i = fix16_from_int(b_);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
}

b3R32::b3R32(const float& b)
{
    _i = fix16_from_float(b);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
}

b3R32::b3R32(const double& b)
{
    fix16_t i = fix16_from_dbl(b);
    if (i < 0) {
        assert(i > fix16_minimum);
    }
    if (i > 0) {
        assert(i < fix16_maximum);
    }
    _i = i;
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
}

b3R32::b3R32(const b3R32& b)
{
    _i = b._i;
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
}

b3R32& b3R32::operator=(b3R32 const& b)
{
    _i = b._i;
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
}

b3R32& b3R32::operator=(int const& b)
{
    _i = fix16_from_int(b);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
}

b3R32& b3R32::operator=(long long const& b)
{
    _i = fix16_from_int(b);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
}

b3R32& b3R32::operator=(float const& b)
{
    _i = fix16_from_float(b);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
}

b3R32& b3R32::operator=(double const& b)
{
    _i = fix16_from_float(b);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
}

// Add this vector with another vector.
b3R32& b3R32::operator+=(const b3R32& b)
{
#if defined(GNUFIXMATH)
    i = fx_addx(i, b.i);
    return (*this);
#else
    _i = fix16_sadd(_i, b._i);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
#endif
}

b3R32& b3R32::operator+=(b3R32& b)
{
#if defined(GNUFIXMATH)
    i = fx_addx(i, b.i);
    return (*this);
#else
    _i = fix16_sadd(_i, b._i);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
#endif
}

// Subtract this vector from another vector.
b3R32& b3R32::operator-=(const b3R32& b)
{
#if defined(GNUFIXMATH)
    i = fx_subx(i, b.i);
    return (*this);
#else
    _i = fix16_ssub(_i, b._i);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
#endif
}

b3R32& b3R32::operator-=(b3R32& b)
{
#if defined(GNUFIXMATH)
    i = fx_subx(i, b.i);
    return (*this);
#else
    _i = fix16_ssub(_i, b._i);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
#endif
}

// Multiply this vector by a scalar.
b3R32& b3R32::operator*=(const b3R32& b)
{
#if defined(GNUFIXMATH)
    i = fx_mulx(i, b.i, 10);
    return (*this);
#else
    _i = fix16_smul(_i, b._i);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
#endif
}

b3R32& b3R32::operator*=(b3R32& b)
{
#if defined(GNUFIXMATH)
    i = fx_mulx(i, b.i, 10);
    return (*this);
#else
    _i = fix16_smul(_i, b._i);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
#endif
}

// Multiply this vector by a scalar.
b3R32& b3R32::operator/=(const b3R32& b)
{
#if defined(GNUFIXMATH)
    i = fx_divx(i, b.i, 10);
    return (*this);
#else
    _i = fix16_smul(_i, b._i);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
#endif
}

b3R32& b3R32::operator++()
{
#if defined(GNUFIXMATH)
    i = fx_addx(i, 1);
    return (*this);
#else
    _i = fix16_sadd(_i, fix16_one);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
#endif
}

b3R32& b3R32::operator++(int)
{
#if defined(GNUFIXMATH)
    i = fx_addx(i, 1);
    return (*this);
#else
    _i = fix16_sadd(_i, fix16_one);
#if defined(B3_DEBUG_R32)
    _f = fix16_to_float(_i);
#endif
    return (*this);
#endif
}

b3R32::operator bool() const
{
    return (_i > 0);
}

b3R32::operator int() const
{
    return fix16_to_int(_i);
}

b3R32::operator long long() const
{
    return fix16_to_int(_i);
}

b3R32::operator float() const
{
    return fix16_to_float(_i);
}

b3R32::operator double() const
{
    return fix16_to_dbl(_i);
}

// Set to the zero vector.
void b3R32::setZero()
{
    _i = 0;
}

// Set from a triple.
void b3R32::set(int v)
{
    _i = v;
    _f = fix16_from_int(_i);
}

b3R32 b3R32::sqrt(const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t i = fx_sqrtx(b.i, 10);
    return b3R32(i);
#else
    fix16_t v = fix16_sqrt(b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 b3R32::sin(const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_sinx(b.i, 10);
    return b3R32(v);
#else
    fix16_t v = fix16_sin(b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 b3R32::cos(const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_cosx(b.i, 10);
    return b3R32(v);
#else
    fix16_t v = fix16_cos(b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 b3R32::acos(const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_cosx(b.i, 10);
    return b3R32(v);
#else
    fix16_t v = fix16_acos(b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 b3R32::atan2(const b3R32& a, const b3R32& b)
{
#if defined(GNUFIXMATH)
    // TODO
    return b3R32(0);
#else
    fix16_t v = fix16_atan2(a._i, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 b3R32::abs(const b3R32& a)
{
    fix16_t v = fix16_abs(a._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
}

b3R32 b3R32::pow(const b3R32& a, const b3R32& b)
{
    int n = fix16_to_int(b._i);
    b3R32 v = a;
    for (size_t i = 2; i <= n; i++) {
        v = v * v;
    }
    return v;
}

b3R32 b3R32::max(const b3R32& a, const b3R32& b)
{
    fix16_t v = fix16_max(a._i, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_from_int(v);
    return r;
}

b3R32 b3R32::min(const b3R32& a, const b3R32& b)
{
    fix16_t v = fix16_min(a._i, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_from_int(v);
    return r;
}

b3R32 b3R32::fromInt(int i)
{
    return b3R32(i);
}

b3R32 b3R32::fromFlt32(float f)
{
    return b3R32(f);
}

b3R32 b3R32::fromFlt64(double f)
{
    return b3R32(f);
}

//float b3R32::ToFloat32(int32_t i) {
//	return fix16_to_float(i);
//}
//
//double b3R32::ToFloat64(int32_t i) {
//	return fix16_to_dbl(i);
//}

b3R32 b3R32::maximum()
{
    b3R32 r;
    r._i = fix16_maximum;
    r._f = fix16_to_float(fix16_maximum);
    return r;
}

b3R32 b3R32::minimum()
{
    b3R32 r;
    r._i = fix16_minimum;
    r._f = fix16_to_float(fix16_minimum);
    return r;
}

b3R32 b3R32::pi()
{
    b3R32 r;
    r._i = fix16_pi;
    r._f = fix16_to_float(fix16_pi);
    return r;
}

b3R32 b3R32::e()
{
    b3R32 r;
    r._i = fix16_e;
    r._f = fix16_to_float(fix16_e);
    return r;
}

b3R32 b3R32::one()
{
    b3R32 r;
    r._i = fix16_one;
    r._f = fix16_to_float(fix16_e);
    return r;
}

b3R32 b3R32::zero()
{
    b3R32 r;
    r._i = 0;
    r._f = 0;
    return r;
}

b3R32 b3R32::epsilon()
{
    b3R32 r;
    r._i = 0;
    r._f = 0;
    return r;
}

// friend
// Negate a vector.
b3R32 operator-(const b3R32& a)
{
#if defined(GNUFIXMATH)
    fixed_t i = fx_subx(0, a.i);
    return b3R32(i);
#else
    fix16_t v = fix16_ssub(0, a._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

// Compute sum of two vectors.
b3R32 operator+(const b3R32& a, const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_addx(a.i, b.i);
    return b3R32(v);
#else
    fix16_t v = fix16_sadd(a._i, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 operator+(const b3R32& a, const int& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_addx(a.i, b.i);
    return b3R32(v);
#else
    fix16_t b_ = fix16_from_int(b);
    fix16_t v = fix16_sadd(a._i, b_);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

// Compute subtraction of two vectors.
b3R32 operator-(const b3R32& a, const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_subx(a.i, b.i);
    return b3R32(v);
#else
    fix16_t v = fix16_ssub(a._i, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 operator-(const int& a, const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_subx(a.i, b.i);
    return b3R32(v);
#else
    fix16_t a_ = fix16_from_int(a);
    fix16_t v = fix16_ssub(a_, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 operator*(const b3R32& a, const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_mulx(a.i, b.i, 10);
    return b3R32(v);
#else
    fix16_t v = fix16_smul(a._i, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 operator*(const float& a, const b3R32& b)
{
#if defined(GNUFIXMATH)
    //TODO::
    //fixed_t v = fx_mulx(a.i, b.i, 10);
    return b3R32(0);
#else
    fix16_t a_ = fix16_from_float(a);
    fix16_t v = fix16_smul(a_, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 operator*(const double& a, const b3R32& b)
{
#if defined(GNUFIXMATH)
    // TODO
    return b3R32(0);
#else
    fix16_t a_ = fix16_from_dbl(a);
    fix16_t v = fix16_smul(a_, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 operator/(const b3R32& a, const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_divx(a.i, b.i, 10);
    return b3R32(v);
#else
    fix16_t v = fix16_sdiv(a._i, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 operator/(const float& a, const b3R32& b)
{
#if defined(GNUFIXMATH)
    fixed_t v = fx_divx(a.i, b.i, 10);
    return b3R32(v);
#else
    fix16_t a_ = fix16_from_float(a);
    fix16_t b_ = b._i;
    fix16_t v = fix16_sdiv(a_, b_);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
#endif
}

b3R32 operator%(const b3R32& a, const b3R32& b)
{
    fix16_t v = fix16_mod(a._i, b._i);
    b3R32 r;
    r._i = v;
    r._f = fix16_to_float(v);
    return r;
}

bool operator==(const b3R32& a, const b3R32& b)
{
    return (a._i == b._i);
}

bool operator!=(const b3R32& a, const b3R32& b)
{
    return (a._i != b._i);
}

bool operator<(const b3R32& a, const b3R32& b)
{
    return (a._i < b._i);
}

bool operator<(const int& a, const b3R32& b)
{
    fix16_t a_ = fix16_from_int(a);
    return (a_ < b._i);
}

bool operator<(const b3R32& a, const int& b)
{
    fix16_t b_ = fix16_from_int(b);
    return (a._i < b_);
}

bool operator<=(const b3R32& a, const b3R32& b)
{
    return (a._i <= b._i);
}

bool operator<=(const b3R32& a, const int& b)
{
    fix16_t b_ = fix16_from_int(b);
    return (a._i <= b_);
}

bool operator>(const b3R32& a, const b3R32& b)
{
    return (a._i > b._i);
}

bool operator>(const b3R32& a, const int& b)
{
    fix16_t b_ = fix16_from_int(b);
    return (a._i > b_);
}

bool operator>=(const b3R32& a, const b3R32& b)
{
    return (a._i >= b._i);
}

bool operator>=(const b3R32& a, const int& b)
{
    fix16_t b_ = fix16_from_int(b);
    return (a._i >= b_);
}
bool operator>=(const b3R32& a, const long long& b)
{
    fix16_t b_ = fix16_from_int(b);
    return (a._i >= b_);
}