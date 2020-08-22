
file(GLOB SPROTO_H *.h)
file(GLOB SPROTO_C *.c)

if(MSVC)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
endif()

add_library(sproto SHARED ${SPROOT_H} ${SPROTO_C})
set_target_properties(sproto PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(sproto PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_include_directories(sproto PRIVATE ../lua/src)
#target_include_directories(sproto PRIVATE .)
target_link_libraries(sproto ../../liblua)
add_dependencies(sproto liblua)

