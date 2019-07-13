# cmake_minimum_required(VERSION 3.12)

project(signal)

include_directories(../lua/src)

if (MSVC)
	add_definitions(-DLUA_BUILD_AS_DLL -D_SCL_SECURE_NO_WARNINGS)
endif (MSVC)

if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -fPIC")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra -fPIC")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
	# message (${CMAKE_C_FLAGS})
	# message (${CMAKE_CXX_FLAGS})
endif ()

set (LUAFILESYSTEM_CORE
	./lsignal.c
	./lsignal.h
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

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LUAFILESYSTEM_CORE)

add_library(signal SHARED ${LUAFILESYSTEM_CORE})
#target_compile_definitions(fixmath PRIVATE FIXEDPT B3_NO_PROFILE)
#target_compile_definitions(fixmath PRIVATE B3_NO_FIXMATH)
#target_compile_definitions(fixmath PRIVATE RP_NO_FIXMATH)
#target_compile_definitions(fixmath PRIVATE GNUFIXMATH)
#target_compile_definitions(fixmath PRIVATE B3_DEBUG_R32)
set_target_properties(signal
    PROPERTIES
    PREFIX ""
	RUNTIME_OUTPUT_DIRECTORY ../../xluatest
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../xluatest
	ARCHIVE_OUTPUT_DIRECTORY ../../xluatest
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../xluatest
	LIBRARY_OUTPUT_DIRECTORY ../../xluatest
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../xluatest
)
target_link_libraries(signal ws2_32 ../../xluatest/liblua)
