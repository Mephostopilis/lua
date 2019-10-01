

set(MD5_C ./md5.c)

include_directories(../lua/src)

IF(MSVC)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(md5 SHARED ${MD5_C})
set_target_properties(md5 PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(md5 PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(md5 ../../xluatest/liblua)
ADD_DEPENDENCIES(md5 liblua)

#set(BUILD_USE_64BITS on)
