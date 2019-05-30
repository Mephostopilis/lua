project(skynettimer)

SET(SKYNET_C 
	posix/win/timeutils.c
	lua-timer.c 
	skynet_timer.c)

include_directories(../lua/src)

IF(MSVC)
include_directories(posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(skynettimer SHARED ${SKYNET_C})
set_target_properties(skynettimer PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(skynettimer PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(skynettimer ../../xluatest/liblua)
ADD_DEPENDENCIES(skynettimer liblua)

#set(BUILD_USE_64BITS on)
