# cmake_minimum_required(VERSION 3.12)

project(fixmath)

include_directories(libfixmath)
include_directories(..)
include_directories(../lua/src)

if (MSVC)
	add_definitions(-DLUA_BUILD_AS_DLL)
endif (MSVC)

if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -fPIC")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra -fPIC")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
	# message (${CMAKE_C_FLAGS})
	# message (${CMAKE_CXX_FLAGS})
endif ()

set (BOUNCE_R32 ./bounce/Common/Math/b3r32.h ./bounce/Common/Math/b3r32.cpp)

set (BOUNCE_CORE
	./bounce/Collision/b3BroadPhase.h ./bounce/Collision/b3DynamicAABBTree.h ./bounce/Collision/b3SAT.h
	./bounce/Collision/b3BroadPhase.cpp ./bounce/Collision/b3DynamicAABBTree.cpp ./bounce/Collision/b3SAT.cpp
	./bounce/Collision/Shapes/b3Hull.h ./bounce/Collision/Shapes/b3Polyhedron.h ./bounce/Collision/Shapes/b3Shape.h
	./bounce/Collision/Shapes/b3Hull.cpp ./bounce/Collision/Shapes/b3Polyhedron.cpp ./bounce/Collision/Shapes/b3Shape.cpp
	./bounce/Common/b3Time.h ./bounce/Common/b3Settings.h
	./bounce/Common/b3Time.cpp ./bounce/Common/b3Settings.cpp
	./bounce/Common/Math/b3Vec3.h ./bounce/Common/Math/b3Quaternion.h ./bounce/Common/Math/b3Mat33.h
	./bounce/Common/Memory/b3BlockAllocator.h ./bounce/Common/Memory/b3StackAllocator.h
	./bounce/Common/Memory/b3BlockAllocator.cpp ./bounce/Common/Memory/b3StackAllocator.cpp
	./bounce/Dynamics/b3World.h ./bounce/Dynamics/b3Island.h ./bounce/Dynamics/b3Body.h
	./bounce/Dynamics/b3World.cpp ./bounce/Dynamics/b3Island.cpp ./bounce/Dynamics/b3Body.cpp
	./bounce/Dynamics/Joints/b3JointGraph.cpp ./bounce/Dynamics/Joints/b3JointSolver.cpp ./bounce/Dynamics/Joints/b3MouseJoint.cpp
	./bounce/Dynamics/Joints/b3RevoluteJoint.cpp ./bounce/Dynamics/Joints/b3SphericalJoint.cpp
	./bounce/Dynamics/Contacts/b3ContactGraph.cpp ./bounce/Dynamics/Contacts/b3ContactSolver.cpp
	./bounce/lua-bounce.cpp
)

set (LIBFIXEDPTMATH_CORE
	./libfixmath/fix16.h
	./libfixmath/fix16.c ./libfixmath/fix16_exp.c ./libfixmath/fix16_sqrt.c ./libfixmath/fix16_str.c 
	./libfixmath/fix16_trig.c ./libfixmath/fract32.c ./libfixmath/uint32.c
)

set (GNULIBFIXMATH_CORE
	fixmath/fix16.h
	fixmath/fix16.c ./bounce/Common/Math/libfixmath/fix16_exp.c ./bounce/Common/Math/libfixmath/fix16_sqrt.c ./bounce/Common/Math/libfixmath/fix16_str.c 
	./bounce/Common/Math/libfixmath/fix16_trig.c ./bounce/Common/Math/libfixmath/fract32.c ./bounce/Common/Math/libfixmath/uint32.c
)

set (MATH3D_CORE ./math3d/fixedptmath3d.h ./math3d/lua-fixedptmath.c)

macro(source_group_by_dir proj_dir source_files)
    if(MSVC OR APPLE)
        get_filename_component(sgbd_cur_dir ${proj_dir} ABSOLUTE)
        foreach(sgbd_file ${${source_files}})
			get_filename_component(sgbd_abs_file ${sgbd_file} ABSOLUTE)
            file(RELATIVE_PATH sgbd_fpath ${sgbd_cur_dir} ${sgbd_abs_file})
            string(REGEX REPLACE "\(.*\)/.*" \\1 sgbd_group_name ${sgbd_fpath})
            string(COMPARE EQUAL ${sgbd_fpath} ${sgbd_group_name} sgbd_nogroup)
            string(REPLACE "/" "\\" sgbd_group_name ${sgbd_group_name})
            if(sgbd_nogroup)
                set(sgbd_group_name "\\")
            endif(sgbd_nogroup)
            source_group(${sgbd_group_name} FILES ${sgbd_file})
        endforeach(sgbd_file)
    endif(MSVC OR APPLE)
endmacro(source_group_by_dir)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} BOUNCE_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} BOUNCE_R32)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LIBFIXEDPTMATH_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} MATH3D_CORE)

add_library(fixmath SHARED ${BOUNCE_CORE} ${BOUNCE_R32} ${LIBFIXEDPTMATH_CORE} ${MATH3D_CORE})
target_compile_definitions(fixmath PRIVATE FIXEDPT B3_NO_PROFILE)
#target_compile_definitions(fixmath PRIVATE GNUFIXMATH)
set_target_properties(fixmath
    PROPERTIES
    PREFIX ""
	RUNTIME_OUTPUT_DIRECTORY ../../xluatest
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../xluatest
	ARCHIVE_OUTPUT_DIRECTORY ../../xluatest
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../xluatest
	LIBRARY_OUTPUT_DIRECTORY ../../xluatest
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../xluatest
)
target_link_libraries(fixmath ws2_32 ../../xluatest/liblua)
