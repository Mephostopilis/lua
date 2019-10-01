

set(XLOGGERD_HOST_CORE
	lua-host.c 
	xlog.h
	xlogger_message.h
	xloggerdd.h
	xloggerdd.c
)

include_directories(../../3rd)
include_directories(../../3rd/lua)
include_directories(../../skynet-src)
include_directories(../lua/src)
IF(MSVC)
	#include_directories(../../3rd/pthread-win32/include)
	include_directories(../../skynet-src/posix)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC)
ELSE(MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall -fPIC --shared")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -fPIC --shared")
    set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF()

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} XLOGGERD_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} XLOGGERD_HOST_CORE)

add_library(xlog SHARED ${XLOGGERD_HOST_CORE})
set_target_properties(xlog PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY ../../xluatest
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest
	ARCHIVE_OUTPUT_DIRECTORY ../../xluaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest
    LIBRARY_OUTPUT_DIRECTORY ../../xluaclib
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../xluaclib
)
target_link_libraries(xlog ../../xluatest/liblua)
add_dependencies(xlog liblua)
