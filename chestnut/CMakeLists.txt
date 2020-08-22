
file(GLOB SRC_LIST *.c)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} SRC_LIST)

add_library(chestnut SHARED ${CHESTNUT_H} ${SRC_LIST})
#set_target_properties(chestnut PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
#set_target_properties(chestnut PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_include_directories(chestnut PRIVATE ../lua/src)
if (MSVC)
add_compile_options(chestnut PRIVATE LUA_BUILD_AS_DLL)
endif()
target_link_libraries(chestnut ../../liblua)
ADD_DEPENDENCIES(chestnut lua)