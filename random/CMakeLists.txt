project(random)

SET(RANDOM_C ./random.c)

include_directories(.)
include_directories(../lua-5.3.5/src)

ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
IF(MSVC)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(random SHARED ${RANDOM_C})
IF(CMAKE_CL_64)
IF(MSVC)
set_target_properties(random PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
set_target_properties(random PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
ENDIF(MSVC)
ELSE(CMAKE_CL_64)
IF(MSVC)
set_target_properties(random PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
set_target_properties(random PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
ENDIF(MSVC)
ENDIF(CMAKE_CL_64)
target_link_libraries(random ../../bin/liblua)
ADD_DEPENDENCIES(random lua)

#ADD_DEPENDENCIES(random bson)
#set(BUILD_USE_64BITS on)
