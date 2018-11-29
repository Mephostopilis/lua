# cmake_minimum_required(VERSION 3.12)

project(fixmath)

include_directories(libfixmath)
include_directories(..)
include_directories(../lua/src)
include_directories(bounce/include)

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
	./bounce/include/bounce/collision/shapes/aabb3.h
	./bounce/include/bounce/collision/shapes/box_hull.h
	./bounce/include/bounce/collision/shapes/capsule.h
	./bounce/include/bounce/collision/shapes/grid_mesh.h
	./bounce/include/bounce/collision/shapes/hull.h
	./bounce/include/bounce/collision/shapes/mesh.h
	./bounce/include/bounce/collision/shapes/qhull.h
	./bounce/include/bounce/collision/shapes/sphere.h
	./bounce/include/bounce/common/math/b3r32.h
	./bounce/include/bounce/common/math/mat.h
	./bounce/include/bounce/common/math/mat22.h
	./bounce/include/bounce/common/math/mat33.h
	./bounce/include/bounce/common/math/mat44.h
	./bounce/include/bounce/common/math/math.h
	./bounce/include/bounce/common/math/quat.h
	./bounce/include/bounce/common/math/transform.h
	./bounce/include/bounce/common/math/vec2.h
	./bounce/include/bounce/common/math/vec3.h
	./bounce/include/bounce/common/math/vec4.h
	./bounce/include/bounce/common/time.h
	./bounce/include/bounce/common/settings.h
	./bounce/include/bounce/dynamics/shapes/hull_shape.h
	./bounce/include/bounce/dynamics/shapes/shape.h
	./bounce/include/bounce/dynamics/body.h
	./bounce/include/bounce/dynamics/contact_manager.h
	./bounce/include/bounce/dynamics/island.h
	./bounce/include/bounce/dynamics/joint_manager.h
	./bounce/include/bounce/dynamics/time_step.h
	./bounce/include/bounce/dynamics/world.h
	#./bounce/src/bounce/cloth/garment/garment_mesh.cpp 
	./bounce/src/bounce/cloth/cloth.cpp 
	./bounce/src/bounce/cloth/cloth_contact_solver.cpp 
	./bounce/src/bounce/cloth/cloth_mesh.cpp
	./bounce/src/bounce/cloth/cloth_solver.cpp 
	./bounce/src/bounce/cloth/force.cpp 
	./bounce/src/bounce/cloth/particle.cpp
	./bounce/src/bounce/cloth/spring_force.cpp
	./bounce/src/bounce/collision/gjk/gjk.cpp
	./bounce/src/bounce/collision/gjk/gjk_feature_pair.cpp
	./bounce/src/bounce/collision/sat/sat.cpp
	./bounce/src/bounce/collision/sat/sat_edge_and_hull.cpp
	./bounce/src/bounce/collision/sat/sat_vertex_and_hull.cpp
	./bounce/src/bounce/collision/shapes/hull.cpp
	./bounce/src/bounce/collision/shapes/qhull.cpp
	./bounce/src/bounce/collision/trees/dynamic_tree.cpp
	./bounce/src/bounce/collision/trees/static_tree.cpp
	./bounce/src/bounce/collision/broad_phase.cpp
	./bounce/src/bounce/collision/collision.cpp
	./bounce/src/bounce/common/math/b3r32.cpp
	./bounce/src/bounce/common/math/math.cpp
	./bounce/src/bounce/common/memory/block_pool.cpp
	./bounce/src/bounce/common/memory/stack_allocator.cpp
	./bounce/src/bounce/common/settings.cpp
	./bounce/src/bounce/dynamics/contacts/collide/clip.cpp
	./bounce/src/bounce/dynamics/contacts/collide/collide.cpp
	./bounce/src/bounce/dynamics/contacts/collide/collide_capsule_hull.cpp
	./bounce/src/bounce/dynamics/contacts/collide/collide_capsules.cpp
	./bounce/src/bounce/dynamics/contacts/collide/collide_hulls.cpp
	./bounce/src/bounce/dynamics/contacts/collide/collide_hulls_cache.cpp
	./bounce/src/bounce/dynamics/contacts/collide/collide_sphere_capsule.cpp
	./bounce/src/bounce/dynamics/contacts/collide/collide_sphere_hull.cpp
	./bounce/src/bounce/dynamics/contacts/collide/collide_spheres.cpp
	./bounce/src/bounce/dynamics/contacts/contact.cpp
	./bounce/src/bounce/dynamics/contacts/contact_cluster.cpp
	./bounce/src/bounce/dynamics/contacts/contact_solver.cpp
	./bounce/src/bounce/dynamics/contacts/convex_contact.cpp
	./bounce/src/bounce/dynamics/contacts/manifold.cpp
	./bounce/src/bounce/dynamics/contacts/mesh_contact.cpp
	./bounce/src/bounce/dynamics/joints/cone_joint.cpp
	./bounce/src/bounce/dynamics/joints/joint.cpp
	./bounce/src/bounce/dynamics/joints/joint_solver.cpp
	./bounce/src/bounce/dynamics/joints/mouse_joint.cpp
	./bounce/src/bounce/dynamics/joints/revolute_joint.cpp
	./bounce/src/bounce/dynamics/joints/sphere_joint.cpp
	./bounce/src/bounce/dynamics/joints/spring_joint.cpp
	./bounce/src/bounce/dynamics/joints/weld_joint.cpp
	./bounce/src/bounce/dynamics/shapes/capsule_shape.cpp
	./bounce/src/bounce/dynamics/shapes/hull_shape.cpp
	./bounce/src/bounce/dynamics/shapes/mesh_shape.cpp
	./bounce/src/bounce/dynamics/shapes/shape.cpp
	./bounce/src/bounce/dynamics/shapes/sphere_shape.cpp
	./bounce/src/bounce/dynamics/body.cpp
	./bounce/src/bounce/dynamics/contact_manager.cpp
	./bounce/src/bounce/dynamics/draw_world.cpp
	./bounce/src/bounce/dynamics/island.cpp
	./bounce/src/bounce/dynamics/joint_manager.cpp
	./bounce/src/bounce/dynamics/world.cpp
	./bounce/src/bounce/quickhull/qh_hull.cpp
	./bounce/src/bounce/rope/rope.cpp
	./bounce/lua-bounce.cpp
)

set (BOUNCELITE_CORE
	./bouncelite/Collision/b3BroadPhase.h 
	./bouncelite/Collision/b3DynamicAABBTree.h 
	./bouncelite/Collision/b3SAT.h
	./bouncelite/Collision/b3BroadPhase.cpp 
	./bouncelite/Collision/b3DynamicAABBTree.cpp 
	./bouncelite/Collision/b3SAT.cpp
	./bouncelite/Collision/Shapes/b3Hull.h 
	./bouncelite/Collision/Shapes/b3Polyhedron.h 
	./bouncelite/Collision/Shapes/b3Shape.h
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
	./libfixmath/fix16.c 
	./libfixmath/fix16_exp.c 
	./libfixmath/fix16_sqrt.c 
	./libfixmath/fix16_str.c 
	./libfixmath/fix16_trig.c 
	./libfixmath/fract32.c 
	./libfixmath/uint32.c
)

set (GNULIBFIXMATH_CORE
	fixmath/fix16.h
	fixmath/fix16.c 
	./bouncelite/Common/Math/libfixmath/fix16_exp.c ./bouncelite/Common/Math/libfixmath/fix16_sqrt.c ./bouncelite/Common/Math/libfixmath/fix16_str.c 
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

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} BOUNCE_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} BOUNCELITE_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LIBFIXEDPTMATH_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} MATH3D_CORE)

add_library(fixmath SHARED ${BOUNCELITE_CORE} ${LIBFIXEDPTMATH_CORE} ${MATH3D_CORE})
#target_compile_definitions(fixmath PRIVATE FIXEDPT B3_NO_PROFILE)
#target_compile_definitions(fixmath PRIVATE B3_NO_FIXMATH)
#target_compile_definitions(fixmath PRIVATE GNUFIXMATH)
target_compile_definitions(fixmath PRIVATE B3_DEBUG_R32)
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
