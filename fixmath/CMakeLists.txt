# cmake_minimum_required(VERSION 3.12)



include_directories(.)
include_directories(../lua/src)
include_directories(libfixmath)
include_directories(reactphysics3d/include)
#include_directories(bounce/include)

if (MSVC)
	add_definitions(-DLUA_BUILD_AS_DLL -D_SCL_SECURE_NO_WARNINGS)
endif (MSVC)

if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -fPIC")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra -fPIC")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
	# message (${CMAKE_C_FLAGS})
	# message (${CMAKE_CXX_FLAGS})
endif ()

set (LIBFIXEDPTMATH_CORE
	./libfixmath/fix16.h
	./libfixmath/fix16.c 
	./libfixmath/fix16_exp.c 
	./libfixmath/fix16_sqrt.c 
	./libfixmath/fix16_str.c 
	./libfixmath/fix16_trig.c 
	./libfixmath/fract32.c 
	./libfixmath/uint32.c
)

set (MATH3D_CORE ./math3d/fixedptmath3d.h ./math3d/lua-fixedptmath.c)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LIBFIXEDPTMATH_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} MATH3D_CORE)

add_library(fixmath SHARED ${LIBFIXEDPTMATH_CORE} ${MATH3D_CORE})
#target_compile_definitions(fixmath PRIVATE FIXEDPT B3_NO_PROFILE)
#target_compile_definitions(fixmath PRIVATE B3_NO_FIXMATH)
#target_compile_definitions(fixmath PRIVATE RP_NO_FIXMATH)
#target_compile_definitions(fixmath PRIVATE GNUFIXMATH)
target_compile_definitions(fixmath PRIVATE B3_DEBUG_R32)
set_target_properties(fixmath PROPERTIES PREFIX "")
target_link_libraries(fixmath ws2_32 ../../liblua)
