project(redis)
SET(REDIS_H
	Win32_Interop/Win32_APIs.h
	Win32_Interop/Win32_Portability.h
	Win32_Interop/Win32_Time.h
	dict.h
	sds.h
	util.h
	xxhash.h
	zmalloc.h
)
SET(REDIS_C
	Win32_Interop/Win32_APIs.c
	Win32_Interop/Win32_Time.c
	dict.c
	dict_unittest.cc
	sds.c
	sds_unittest.cc
	util.c
	util_unittest.cc
	xxhash.c
	zmalloc.c	
	zmalloc_unittest.cc
)

SET(RINGBUG_UNITTEST_H ./ringbuf.h ./write_buffer.h)
set(RINGBUG_UNITTEST_C ./ringbuf_unittest.cc ./ringbuf.c ./write_buffer.c)

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

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} REDIS_H)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} REDIS_C)

add_executable(redis ${REDIS_H} ${REDIS_C})
target_compile_definitions(redis PRIVATE _XKEYCHECK_H XXH_INLINE_ALL REDIS_TEST)
target_include_directories(redis PRIVATE ../googletest/include)
set_target_properties(redis PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(redis PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(redis PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(redis PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(redis ../../googletest/Debug/gtestd ../../googletest/Debug/gtest_maind)

