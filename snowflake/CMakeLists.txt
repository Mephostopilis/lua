
file(GLOB SRC_LIST *.c)

SET(SRC_LIST 
	./lua-snowflake.c
)

if (MSVC)
list (APPEND SRC_LIST ./Win32_Interop/Win32_Time.c ./Win32_Interop/Win32_APIs.c)
endif()

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} SRC_LIST)

add_library(snowflake SHARED ${SRC_LIST})
#set_target_properties(chestnut PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
#set_target_properties(chestnut PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_include_directories(snowflake PRIVATE ../lua/src)
if (MSVC)
add_compile_options(snowflake PRIVATE LUA_BUILD_AS_DLL)
endif()
target_link_libraries(snowflake ../../liblua)
