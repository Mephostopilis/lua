project(config)

SET(CONFIG_C ./config.cpp ./csv.cpp ./strhtable.cpp ./value_t.cpp)

include_directories(../lua/src)

add_definitions(-DLUA_BUILD_AS_DLL)

add_library(config SHARED ${CONFIG_C})
set_target_properties(config PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
set_target_properties(config PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
target_link_libraries(config ../../bin/liblua)
add_dependencies(config lua)
