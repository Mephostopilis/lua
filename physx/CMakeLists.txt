﻿
SET(BALL_CORE
	lua-ball.cpp
)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} BALL_CORE)

add_library(physx SHARED ${BALL_CORE})
target_include_directories(physx PRIVATE ../lua/src)
target_include_directories(physx PRIVATE 3rd/PhysX-4.1/physx/include)
target_include_directories(physx PRIVATE 3rd/physX-4.1/pxshared/include)
IF(MSVC)
target_compile_definitions(physx PRIVATE LUA_BUILD_AS_DLL)
target_compile_definitions(physx PRIVATE PX_SUPPORT_PVD PX_ENABLE_ASSERTS)
target_compile_options(physx PRIVATE /MTd)

#set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
endif ()

set_target_properties(physx PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../luaclib)
set_target_properties(physx PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../luaclib)
set_target_properties(physx PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(physx PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_link_libraries(physx ../../liblua)
target_link_libraries(physx ../../PhysXCommon_64)
target_link_libraries(physx ../../PhysX_64)
target_link_libraries(physx ../../PhysXCooking_64)
target_link_libraries(physx ../../PhysXExtensions_static_64)
target_link_libraries(physx ../../PhysXPvdSDK_static_64)
target_link_libraries(physx ../../PhysXFoundation_64)
