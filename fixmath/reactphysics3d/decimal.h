/********************************************************************************
* ReactPhysics3D physics library, http://www.reactphysics3d.com                 *
* Copyright (c) 2010-2019 Daniel Chappuis                                       *
*********************************************************************************
*                                                                               *
* This software is provided 'as-is', without any express or implied warranty.   *
* In no event will the authors be held liable for any damages arising from the  *
* use of this software.                                                         *
*                                                                               *
* Permission is granted to anyone to use this software for any purpose,         *
* including commercial applications, and to alter it and redistribute it        *
* freely, subject to the following restrictions:                                *
*                                                                               *
* 1. The origin of this software must not be misrepresented; you must not claim *
*    that you wrote the original software. If you use this software in a        *
*    product, an acknowledgment in the product documentation would be           *
*    appreciated but is not required.                                           *
*                                                                               *
* 2. Altered source versions must be plainly marked as such, and must not be    *
*    misrepresented as being the original software.                             *
*                                                                               *
* 3. This notice may not be removed or altered from any source distribution.    *
*                                                                               *
********************************************************************************/

#ifndef REACTPHYSICS3D_DECIMAL_H
#define	REACTPHYSICS3D_DECIMAL_H

#if !defined(RP_NO_FIXMATH)
#include "b3r32.h"
#endif

/// ReactPhysiscs3D namespace
namespace reactphysics3d {
#if defined(RP_NO_FIXMATH)
#if defined(IS_DOUBLE_PRECISION_ENABLED)   // If we are compiling for double precision
    using decimal = double;
#else                                   // If we are compiling for single precision
    using decimal = float;
#endif
	inline decimal rpAbs(decimal x) {
		return std::fabs(x);
	}

	inline decimal rpSqrt(decimal x) {
		return std::sqrt(x);
	}

	inline decimal rpSin(decimal x) {
		return std::sin(x);
	}

	inline decimal rpCos(decimal x) {
		return std::cos(x);
	}

	inline decimal rpAcos(decimal x) {
		return std::acos(x);
	}

	inline decimal rpTan2(decimal a, decimal b) {
		return std::atan2(a, b);
	}

	inline decimal rpPow(decimal a, decimal b) {
		return pow(a, b);
	}

	inline decimal rpFmod(decimal a, decimal b) {
		return fmod(a, b);
	}

#else
	
	typedef b3R32 decimal;

	inline decimal rpAbs(decimal x) {
		return decimal::abs(x);
	}

	inline decimal rpSqrt(decimal x) {
		return decimal::sqrt(x);
	}

	inline decimal rpSin(decimal x) {
		return decimal::sin(x);
	}

	inline decimal rpCos(decimal x) {
		return decimal::cos(x);
	}

	inline decimal rpAcos(decimal x) {
		return decimal::acos(x);
	}

	inline decimal rpATan2(decimal a, decimal b) {
		return decimal::atan2(a, b);
	}

	inline decimal rpPow(decimal a, decimal b) {
		return decimal::pow(a, b);
	}

	inline decimal rpFmod(decimal a, decimal b) {
		return a % b;
	}

	inline decimal rpMax(decimal a, decimal b) {
		return decimal::max(a, b);
	}
	
#endif

}

#endif

