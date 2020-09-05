set(SKYNET_C ./lsha1.c ./lua-crypt.c)

add_library(skynet SHARED ${SKYNET_C})
set_target_properties(skynet PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(skynet PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_include_directories(skynet PRIVATE ../lua/src)
target_link_libraries(skynet ../../liblua)

IF(MSVC)
target_compile_definitions(skynet PRIVATE LUA_BUILD_AS_DLL)
ENDIF()