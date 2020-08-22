
SET(RANDOM_C ./random.c)

include_directories(../lua/src)

IF(MSVC)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(random SHARED ${RANDOM_C})
set_target_properties(random PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(random PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_link_libraries(random ../../liblua)
ADD_DEPENDENCIES(random liblua)

#ADD_DEPENDENCIES(random bson)
#set(BUILD_USE_64BITS on)
