# cmake_minimum_required(VERSION 3.12)

project(libfixmath)

include_directories(include)

if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -fPIC")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra -fPIC")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
	# message (${CMAKE_C_FLAGS})
	# message (${CMAKE_CXX_FLAGS})
endif ()
set (LIBFIXEDPTMATH_H ./include/fixmath.h ./include/fixmath_impl.h ./include/fixmath_arch.h ./include/fixmath_ver.h ./include/fixmath_macro.h)
set (LIBFIXEDPTMATH_C ./src/fixmath.c ./src/fixmath_impl.c ./src/fixmath_str.c ./src/fixmath_ver.c)

add_library(libfixmath STATIC ${LIBFIXEDPTMATH_H} ${LIBFIXEDPTMATH_C})
target_compile_definitions(libfixmath PRIVATE FIXEDPT)
set_target_properties(libfixmath
    PROPERTIES
    PREFIX ""
	RUNTIME_OUTPUT_DIRECTORY ../..
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../..
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ../..
	ARCHIVE_OUTPUT_DIRECTORY ../../..
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../..
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../..
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../..
)
