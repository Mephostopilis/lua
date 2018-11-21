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

#ifndef __B3_R32_H__
#define __B3_R32_H__

#include <stdint.h>

struct b3R32;

// Negate a vector.
b3R32 operator-(const b3R32& a);

// Compute sum of two vectors.
b3R32 operator+(const b3R32 a, const b3R32 b);
b3R32 operator-(const b3R32 a, const b3R32 b);
b3R32 operator*(const b3R32 a, const b3R32 b);
b3R32 operator*(const float a, const b3R32 b);
b3R32 operator*(const double a, const b3R32 b);
b3R32 operator/(const b3R32 a, const b3R32 b);
bool  operator==(const b3R32 a, const b3R32 b);
bool  operator!=(const b3R32 a, const b3R32 b);
bool  operator<(const b3R32 a, const b3R32 b);
bool  operator<=(const b3R32 a, const b3R32 b);
bool  operator>(const b3R32 a, const b3R32 b);
bool  operator>=(const b3R32 a, const b3R32 b);

struct b3R32 {
	b3R32();
	b3R32(const b3R32 &b);
	b3R32(const int16_t b);
	b3R32(const int32_t b);
	b3R32(const uint32_t b);
	b3R32(const uint64_t b);
	b3R32(const float b);
	b3R32(const double b);
	
	

	// Assing other vector to this vector.
	b3R32& operator=(const b3R32& b) {
		i = b.i;
		return(*this);
	}

	// Add this vector with another vector.
	b3R32& operator+=(const b3R32& b);
	b3R32& operator+=(b3R32& b);

	// Subtract this vector from another vector.
	b3R32& operator-=(const b3R32& b);
	b3R32&  operator-=(b3R32& b);

	// Multiply this vector by a scalar.
	b3R32& operator*=(const b3R32& b);
	b3R32& operator*=(b3R32& b);

	// Multiply this vector by a scalar.
	b3R32& operator/=(const b3R32& b);

	//prefix ++ : increment and fetch
	b3R32 & operator++();

	//postfix ++ : fetch and increment
	b3R32 & operator++(int);

	operator bool();
	operator int32_t();

	// Set to the zero vector.
	void SetZero();

	void Set(int32_t v);

	friend b3R32 operator-(const b3R32& a);
	friend b3R32 operator+(const b3R32 a, const b3R32 b);
	friend b3R32 operator-(const b3R32 a, const b3R32 b);
	friend b3R32 operator*(const b3R32 a, const b3R32 b);
	friend b3R32 operator*(const float a, const b3R32 b);
	friend b3R32 operator*(const double a, const b3R32 b);
	friend b3R32 operator/(const b3R32 a, const b3R32 b);
	friend bool  operator==(const b3R32 a, const b3R32 b);
	friend bool  operator!=(const b3R32 a, const b3R32 b);
	friend bool  operator<(const b3R32 a, const b3R32 b);
	friend bool  operator<=(const b3R32 a, const b3R32 b);
	friend bool  operator>(const b3R32 a, const b3R32 b);
	friend bool  operator>=(const b3R32 a, const b3R32 b);

	static b3R32 Sqrt(const b3R32& b);
	static b3R32 Sin(const b3R32& b);
	static b3R32 Cos(const b3R32& b);
	static b3R32 Atan2(const b3R32& a, const b3R32& b);

	static b3R32 max;
	static b3R32 min;
	static b3R32 pi;
	static b3R32 e;
	static b3R32 one;
	static b3R32 zero;

private:
	int32_t i;
};

#endif
