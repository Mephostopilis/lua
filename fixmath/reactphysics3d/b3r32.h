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

struct b3R32;

// Negate a vector.
b3R32 operator-(const b3R32& a);
b3R32 operator+(const b3R32& a, const b3R32& b);
b3R32 operator+(const b3R32& a, const int& b);
b3R32 operator-(const b3R32& a, const b3R32& b);
b3R32 operator-(const int& a, const b3R32& b);
b3R32 operator*(const b3R32& a, const b3R32& b);
b3R32 operator*(const float& a, const b3R32& b);
b3R32 operator*(const double& a, const b3R32& b);
b3R32 operator/(const b3R32& a, const b3R32& b);
b3R32 operator/(const float& a, const b3R32& b);
b3R32 operator%(const b3R32& a, const b3R32& b);
bool  operator==(const b3R32& a, const b3R32& b);
bool  operator!=(const b3R32& a, const b3R32& b);
bool  operator<(const b3R32& a, const b3R32& b);
bool  operator<(const int & a, const b3R32& b);
bool  operator<(const b3R32& a, const int& b);
bool  operator<=(const b3R32& a, const b3R32& b);
bool  operator<=(const b3R32& a, const int& b);
bool  operator>(const b3R32& a, const b3R32& b);
bool  operator>(const b3R32& a, const int& b);
bool  operator>=(const b3R32& a, const b3R32& b);
bool  operator>=(const b3R32& a, const int & b);
bool  operator>=(const b3R32& a, const long long & b);

struct b3R32 {
	b3R32();
	b3R32(const short int & b);
	b3R32(const int & b);
	b3R32(const long long & b);
	b3R32(const unsigned int & b);
	b3R32(const unsigned long long & b);
	b3R32(const float & b);
	b3R32(const double & b);
	b3R32(const b3R32 &b);

	// Assing other vector to this vector.
	b3R32& operator=(b3R32 const & b);
	b3R32& operator=(int const & b);
	b3R32& operator=(long long const & b);
	b3R32& operator=(float const & b);
	b3R32& operator=(double const & b);

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

	operator bool() const;
	operator int() const;
	operator long long() const;
	operator float() const;
	operator double() const;

	// Set to the zero vector.
	void setZero();
	void set(int v);

	static b3R32 sqrt(const b3R32& b);
	static b3R32 sin(const b3R32& b);
	static b3R32 cos(const b3R32& b);
	static b3R32 acos(const b3R32& b);
	static b3R32 atan2(const b3R32& a, const b3R32& b);
	static b3R32 abs(const b3R32& a);
	static b3R32 pow(const b3R32& a, const b3R32& b);
	static b3R32 max(const b3R32& a, const b3R32& b);
	static b3R32 min(const b3R32& a, const b3R32& b);
	static b3R32 fromInt(int);
	static b3R32 fromFlt32(float);
	static b3R32 fromFlt64(double);
	/*static float ToFloat32(int32_t i);
	static double ToFloat64(int32_t i);*/
	// 常量
	static b3R32 maximum();
	static b3R32 minimum();
	static b3R32 pi();
	static b3R32 e();
	static b3R32 one();
	static b3R32 zero();
	static b3R32 epsilon();

	friend b3R32 operator-(const b3R32& a);
	friend b3R32 operator+(const b3R32& a, const b3R32& b);
	friend b3R32 operator+(const b3R32& a, const int& b);
	friend b3R32 operator-(const b3R32& a, const b3R32& b);
	friend b3R32 operator-(const int& a, const b3R32& b);
	friend b3R32 operator*(const b3R32& a, const b3R32& b);
	friend b3R32 operator*(const float& a, const b3R32& b);
	friend b3R32 operator*(const double& a, const b3R32& b);
	friend b3R32 operator/(const b3R32& a, const b3R32& b);
	friend b3R32 operator/(const float& a, const b3R32& b);
	friend b3R32 operator%(const b3R32& a, const b3R32& b);
	friend bool  operator==(const b3R32& a, const b3R32& b);
	friend bool  operator!=(const b3R32& a, const b3R32& b);
	friend bool  operator<(const b3R32& a, const b3R32& b);
	friend bool  operator<(const int & a, const b3R32& b);
	friend bool  operator<(const b3R32& a, const int& b);
	friend bool  operator<=(const b3R32& a, const b3R32& b);
	friend bool  operator<=(const b3R32& a, const int& b);
	friend bool  operator>(const b3R32& a, const b3R32& b);
	friend bool  operator>(const b3R32& a, const int& b);
	friend bool  operator>=(const b3R32& a, const b3R32& b);
	friend bool  operator>=(const b3R32& a, const int & b);
	friend bool  operator>=(const b3R32& a, const long long & b);

	int   _i;
	float _f;
};

#endif
