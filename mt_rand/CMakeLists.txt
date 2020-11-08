SET(MTRAND_C ./mt_rand.c)

add_library(mtrand SHARED ${MTRAND_C})
set_target_properties(mtrand PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(mtrand PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_include_directories(mtrand PRIVATE ../lua/src)
if (MSVC)
target_compile_definitions(mtrand PRIVATE _CRT_SECURE_NO_WARNINGS)
target_compile_definitions(mtrand PRIVATE LUA_BUILD_AS_DLL)
endif()

target_link_libraries(mtrand ../../liblua)