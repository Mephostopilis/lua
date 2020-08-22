
aux_source_directory(. SRC_LIST)
list(REMOVE_ITEM SRC_LIST ./test.cpp)
message(STATUS ${SRC_LIST})



add_library(kcp SHARED ${SRC_LIST})
set_target_properties(kcp PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(kcp PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_link_libraries(kcp ../../liblua)
target_link_libraries(kcp legacy_stdio_definitions)
target_include_directories(kcp PUBLIC ../lua/src)
ADD_DEPENDENCIES(kcp liblua)

if (MSVC)
	target_compile_definitions(signal PRIVATE LUA_BUILD_AS_DLL)
endif (MSVC)