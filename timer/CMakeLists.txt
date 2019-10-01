

SET(TIMER_C ./timer.c)

#include_directories(.)
include_directories(../lua/src)


IF(MSVC)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

IF(CMAKE_CL_64)
ENDIF()

add_library(timer SHARED ${TIMER_C})
set_target_properties(timer PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(timer PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(timer ../../xluatest/liblua)
ADD_DEPENDENCIES(timer liblua)

#set(BUILD_USE_64BITS on)
