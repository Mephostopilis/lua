
aux_source_directory(. RAPIDJSON_C)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} RAPIDJSON_C)

include_directories(include)
include_directories(../lua/src)

IF(MSVC)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)	
ENDIF()

add_library(rapidjson SHARED ${RAPIDJSON_C})
set_target_properties(rapidjson PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(rapidjson PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_link_libraries(rapidjson ../../liblua)
ADD_DEPENDENCIES(rapidjson liblua)


