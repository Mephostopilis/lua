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
	./lsignal.c
	./lsignal.h
)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LUAFILESYSTEM_CORE)

add_library(signal SHARED ${LUAFILESYSTEM_CORE})
#target_compile_definitions(fixmath PRIVATE FIXEDPT B3_NO_PROFILE)
#target_compile_definitions(fixmath PRIVATE B3_NO_FIXMATH)
#target_compile_definitions(fixmath PRIVATE RP_NO_FIXMATH)
#target_compile_definitions(fixmath PRIVATE GNUFIXMATH)
#target_compile_definitions(fixmath PRIVATE B3_DEBUG_R32)
set_target_properties(signal
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
target_link_libraries(signal ws2_32 ../../xluatest/liblua)
