project(md5)

SET(MD5_C ./md5.c)

include_directories(.)
include_directories(../lua/src)

ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
IF(MSVC)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(md5 SHARED ${MD5_C})
IF(CMAKE_CL_64)
IF(MSVC)
set_target_properties(md5 PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(md5 PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
ENDIF(MSVC)
ELSE(CMAKE_CL_64)
IF(MSVC)
set_target_properties(md5 PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(md5 PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
ENDIF(MSVC)
ENDIF(CMAKE_CL_64)
target_link_libraries(md5 ../../xluatest/liblua)
ADD_DEPENDENCIES(md5 lua)

#ADD_DEPENDENCIES(md5 bson)
#set(BUILD_USE_64BITS on)
