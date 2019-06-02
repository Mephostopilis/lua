
project(hexmap)
SET(hexmap_core
	#bh_wp.h
	#binheap.h
	#hexmap.cpp
	#hexmap.h
	#hexmap_unittest.cc
	quadtree.c
	quadtree.h
	quadtree_unittest.cc
)

macro(source_group_by_dir proj_dir source_files)
    if(MSVC OR APPLE)
        get_filename_component(sgbd_cur_dir ${proj_dir} ABSOLUTE)
        foreach(sgbd_file ${${source_files}})
			get_filename_component(sgbd_abs_file ${sgbd_file} ABSOLUTE)
            file(RELATIVE_PATH sgbd_fpath ${sgbd_cur_dir} ${sgbd_abs_file})
            string(REGEX REPLACE "\(.*\)/.*" \\1 sgbd_group_name ${sgbd_fpath})
            string(COMPARE EQUAL ${sgbd_fpath} ${sgbd_group_name} sgbd_nogroup)
            string(REPLACE "/" "\\" sgbd_group_name ${sgbd_group_name})
            if(sgbd_nogroup)
                set(sgbd_group_name "\\")
            endif(sgbd_nogroup)
            source_group(${sgbd_group_name} FILES ${sgbd_file})
        endforeach(sgbd_file)
    endif(MSVC OR APPLE)
endmacro(source_group_by_dir)

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
set_target_properties(hexmap PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(hexmap PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(hexmap PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(hexmap PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(hexmap ../../googletest/Debug/gtestd ../../googletest/Debug/gtest_maind)
