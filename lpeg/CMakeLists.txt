project(lpeg)

file(GLOB LPEG_H *.h)
aux_source_directory(. LPEG_C)

include_directories(../src)

ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
IF(MSVC)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(lpeg SHARED ${LPEG_H} ${LPEG_C})
IF(CMAKE_CL_64)
IF(MSVC)
set_target_properties(lpeg PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
set_target_properties(lpeg PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
ENDIF()
ELSE(CMAKE_CL_64)
IF(MSVC)
set_target_properties(lpeg PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
set_target_properties(lpeg PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
ENDIF()
ENDIF(CMAKE_CL_64)
target_link_libraries(lpeg ../../bin/liblua)
#ADD_DEPENDENCIES(lpeg sproto)

#set(BUILD_USE_64BITS on)
