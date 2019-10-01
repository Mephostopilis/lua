

SET(SKYNET_C ./lsha1.c ./lua-crypt.c)

include_directories(../lua/src)


IF(MSVC)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(skynet SHARED ${SKYNET_C})
set_target_properties(skynet PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(skynet PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)

target_link_libraries(skynet ../../xluatest/liblua)
add_dependencies(skynet liblua)