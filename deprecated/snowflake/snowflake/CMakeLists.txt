project(snowflake)

SET(SNOWFLAKE_C ./rand.c ./snowflake.c ./lua-snowflake.c)

include_directories(.)
include_directories(../src)

ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
IF(MSVC)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(snowflake SHARED ${SKYNET_C})
set_target_properties(snowflake PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
set_target_properties(snowflake PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
target_link_libraries(snowflake ../../bin/liblua)
ADD_DEPENDENCIES(snowflake lua)
