
set(PARSER_CORE
	http_parser.c
	http_parser.h
)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} PARSER_CORE)

add_executable(httpparser ${PARSER_CORE})
target_compile_definitions(httpparser PRIVATE _CRT_SECURE_NO_WARNINGS)
target_include_directories(httpparser PRIVATE ../googletest/include)
set_target_properties(httpparser PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(httpparser PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(httpparser PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(httpparser PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(httpparser ../../googletest/Debug/gtestd ../../googletest/Debug/gtest_maind)

