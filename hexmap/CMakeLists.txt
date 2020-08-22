
set(hexmap_core
	#bh_wp.h
	#binheap.h
	#hexmap.cpp
	#hexmap.h
	#hexmap_unittest.cc
	quadtree.c
	quadtree.h
	quadtree_unittest.cc
)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} hexmap_core)

IF(UNIX)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF()


add_executable(hexmap ${hexmap_core} )
target_compile_definitions(hexmap PRIVATE _XKEYCHECK_H XXH_INLINE_ALL REDIS_TEST)
target_include_directories(hexmap PRIVATE ../googletest/include)
set_target_properties(hexmap PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../..)
set_target_properties(hexmap PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../..)
set_target_properties(hexmap PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../..)
set_target_properties(hexmap PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../..)
target_link_libraries(hexmap ../../googletest/Debug/gtestd ../../googletest/Debug/gtest_maind)
