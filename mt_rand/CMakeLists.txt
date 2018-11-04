project(mtrand)

SET(MTRAND_H ./mt_rand.h)
SET(MTRAND_C ./mt_rand.c ./lua-mtrand.c)

include_directories(.)
include_directories(../lua/src)

ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
IF(MSVC)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(mtrand SHARED ${MTRAND_H} ${MTRAND_C})
set_target_properties(mtrand PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
set_target_properties(mtrand PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
target_link_libraries(mtrand ../../bin/liblua)
ADD_DEPENDENCIES(mtrand lua)
