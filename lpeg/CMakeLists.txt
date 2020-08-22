file(GLOB LPEG_H *.h)
file(GLOB LPEG_C *.c)

IF(MSVC)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

add_library(lpeg SHARED ${LPEG_H} ${LPEG_C})
set_target_properties(lpeg PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(lpeg PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_include_directories(lpeg PRIVATE ../../lua/src)
target_link_libraries(lpeg ../../liblua)
ADD_DEPENDENCIES(lpeg liblua)
