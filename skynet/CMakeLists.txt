project(skynet)

SET(SKYNET_C ./lsha1.c ./lua-crypt.c)

include_directories(.)
include_directories(../lua/src)

ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
IF(MSVC)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(skynet SHARED ${SKYNET_C})
IF(CMAKE_CL_64)
IF(MSVC)
set_target_properties(skynet PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
set_target_properties(skynet PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
ENDIF(MSVC)
ELSE(CMAKE_CL_64)
IF(MSVC)
set_target_properties(skynet PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
set_target_properties(skynet PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
ENDIF(MSVC)
ENDIF(CMAKE_CL_64)
target_link_libraries(skynet ../../bin/liblua)
ADD_DEPENDENCIES(skynet lua)

#ADD_DEPENDENCIES(skynet bson)
#set(BUILD_USE_64BITS on)
