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

set (BOUNCE_CORE
	./bounce/src/bounce/cloth/cloth.cpp ./bounce/src/bounce/cloth/cloth_contact_solver.cpp ./bounce/src/bounce/cloth/mesh.cpp
	./bounce/src/bounce/cloth/cloth_solver.cpp ./bounce/src/bounce/cloth/force.cpp ./bounce/src/bounce/cloth/particle.cpp
	./bounce/src/bounce/cloth/spring_force.cpp
	./bounce/lua-bounce.cpp
)

set (BOUNCELITE_CORE
	./bouncelite/Collision/b3BroadPhase.h ./bouncelite/Collision/b3DynamicAABBTree.h ./bouncelite/Collision/b3SAT.h
	./bouncelite/Collision/b3BroadPhase.cpp ./bouncelite/Collision/b3DynamicAABBTree.cpp ./bouncelite/Collision/b3SAT.cpp
	./bouncelite/Collision/Shapes/b3Hull.h ./bouncelite/Collision/Shapes/b3Polyhedron.h ./bouncelite/Collision/Shapes/b3Shape.h
	./bouncelite/Collision/Shapes/b3Hull.cpp ./bouncelite/Collision/Shapes/b3Polyhedron.cpp ./bouncelite/Collision/Shapes/b3Shape.cpp
	./bouncelite/Common/b3Time.h ./bouncelite/Common/b3Settings.h
	./bouncelite/Common/b3Time.cpp ./bouncelite/Common/b3Settings.cpp
	./bouncelite/Common/Math/b3r32.h ./bouncelite/Common/Math/b3r32.cpp
	./bouncelite/Common/Math/b3Vec3.h ./bouncelite/Common/Math/b3Quaternion.h ./bouncelite/Common/Math/b3Mat33.h
	./bouncelite/Common/Memory/b3BlockAllocator.h ./bouncelite/Common/Memory/b3StackAllocator.h
	./bouncelite/Common/Memory/b3BlockAllocator.cpp ./bouncelite/Common/Memory/b3StackAllocator.cpp
	./bouncelite/Dynamics/b3World.h ./bouncelite/Dynamics/b3Island.h ./bouncelite/Dynamics/b3Body.h
	./bouncelite/Dynamics/b3World.cpp ./bouncelite/Dynamics/b3Island.cpp ./bouncelite/Dynamics/b3Body.cpp
	./bouncelite/Dynamics/Joints/b3JointGraph.cpp ./bouncelite/Dynamics/Joints/b3JointSolver.cpp ./bouncelite/Dynamics/Joints/b3MouseJoint.cpp
	./bouncelite/Dynamics/Joints/b3RevoluteJoint.cpp ./bouncelite/Dynamics/Joints/b3SphericalJoint.cpp
	./bouncelite/Dynamics/Contacts/b3ContactGraph.cpp ./bouncelite/Dynamics/Contacts/b3ContactSolver.cpp
	./bouncelite/lua-bouncelite.cpp
)

set (LIBFIXEDPTMATH_CORE
	./libfixmath/fix16.h
	./libfixmath/fix16.c ./libfixmath/fix16_exp.c ./libfixmath/fix16_sqrt.c ./libfixmath/fix16_str.c 
	./libfixmath/fix16_trig.c ./libfixmath/fract32.c ./libfixmath/uint32.c
)

set (GNULIBFIXMATH_CORE
	fixmath/fix16.h
	fixmath/fix16.c ./bouncelite/Common/Math/libfixmath/fix16_exp.c ./bouncelite/Common/Math/libfixmath/fix16_sqrt.c ./bouncelite/Common/Math/libfixmath/fix16_str.c 
	./bouncelite/Common/Math/libfixmath/fix16_trig.c ./bouncelite/Common/Math/libfixmath/fract32.c ./bouncelite/Common/Math/libfixmath/uint32.c
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

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} BOUNCELITE_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LIBFIXEDPTMATH_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} MATH3D_CORE)

add_library(fixmath SHARED ${BOUNCELITE_CORE} ${LIBFIXEDPTMATH_CORE} ${MATH3D_CORE})
target_compile_definitions(fixmath PRIVATE FIXEDPT B3_NO_PROFILE)
target_compile_definitions(fixmath PRIVATE B3_NO_FIXMATH)
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
