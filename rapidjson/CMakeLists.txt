
aux_source_directory(. RAPIDJSON_C)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} RAPIDJSON_C)

add_library(rapidjson SHARED ${RAPIDJSON_C})
set_target_properties(rapidjson PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(rapidjson PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_include_directories(rapidjson PRIVATE ../lua/src)
target_include_directories(rapidjson PRIVATE include)

if (MSVC)
	target_compile_definitions (rapidjson PRIVATE LUA_BUILD_AS_DLL)
endif ()

target_link_libraries(rapidjson ../../liblua)

