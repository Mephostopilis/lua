
set(PARSER_CORE
	http_parser.c
	http_parser.h
	lua-parser.c
)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} PARSER_CORE)

add_library(httpparser SHARED ${PARSER_CORE})
set_target_properties(httpparser PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../luaclib)
set_target_properties(httpparser PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../luaclib)
set_target_properties(httpparser PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(httpparser PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)

target_include_directories(httpparser PUBLIC ../lua/src)

if (MSVC)
target_compile_definitions(httpparser PRIVATE _CRT_SECURE_NO_WARNINGS)
target_compile_definitions(httpparser PRIVATE LUA_BUILD_AS_DLL)
endif()

#target_link_libraries(httpparser ../../googletest/Debug/gtestd ../../googletest/Debug/gtest_maind)
target_link_libraries(httpparser ../../liblua)

