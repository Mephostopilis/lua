# cmake_minimum_required(VERSION 3.12)

include_directories(../lua/src)

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

set (LUAFILESYSTEM_CORE
	./lfs.c
	./lfs.h
)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LUAFILESYSTEM_CORE)

add_library(lfs SHARED ${LUAFILESYSTEM_CORE})
set_target_properties(lfs
    PROPERTIES
    PREFIX ""
	RUNTIME_OUTPUT_DIRECTORY ../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../luaclib
	LIBRARY_OUTPUT_DIRECTORY ../../luaclib
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../luaclib
)
target_link_libraries(lfs ws2_32 ../../liblua)
