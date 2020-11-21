
SET(recastnavigation_src
	lua-navigation.cpp
	NFCNavigationModule.h
	NFCNavigationModule.cpp
)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} recastnavigation_src)

add_library(recastnavigation SHARED ${recastnavigation_src})
target_include_directories(recastnavigation PRIVATE ../lua/src)
target_include_directories(recastnavigation PRIVATE Detour/Include)
target_include_directories(recastnavigation PRIVATE DetourCrowd/Include)
target_include_directories(recastnavigation PRIVATE DetourTileCache/Include)
target_include_directories(recastnavigation PRIVATE Recast/Include)
IF(MSVC)
target_compile_definitions(recastnavigation PRIVATE LUA_BUILD_AS_DLL)
target_compile_definitions(recastnavigation PRIVATE PX_SUPPORT_PVD PX_ENABLE_ASSERTS)
target_compile_options(recastnavigation PRIVATE /MDd)

#set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
endif ()

set_target_properties(recastnavigation PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../luaclib)
set_target_properties(recastnavigation PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../luaclib)
set_target_properties(recastnavigation PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(recastnavigation PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_link_libraries(recastnavigation ../../liblua)
target_link_libraries(recastnavigation ../../Detour-d)
target_link_libraries(recastnavigation ../../DetourCrowd-d)
target_link_libraries(recastnavigation ../../DetourTileCache-d)
target_link_libraries(recastnavigation ../../Recast-d)
