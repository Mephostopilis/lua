project(xluasocket)
SET(XLUASOCKET_H
	posix/dlfcn.h
	posix/unistd.h
	Win32_Interop/Win32_APIs.h
	Win32_Interop/win32_cpoll.h
	Win32_Interop/Win32_dlfcn.h
	Win32_Interop/Win32_Extras.h
	Win32_Interop/Win32_PThread.h
	Win32_Interop/Win32_ThreadControl.h
	Win32_Interop/Win32_Time.h
	atomic.h
	dict.h
	log.h
	message_queue.h
	protoc.h
	ringbuf.h
	rwlock.h
	simplethread.h
	skynet_timer.h
	socket_info.h
	socket_poll.h
	socket_server.h
	spinlock.h
	util.h
	write_buffer.h 
	xxhash.c
	xluaconf.h
)
IF(UNIX)
set(XLUASOCKET_H socket_epoll.h)
ENDIF()

SET(XLUASOCKET_C
	posix/unistd.c
	Win32_Interop/Win32_APIs.c
	Win32_Interop/win32_cpoll.c
	Win32_Interop/Win32_dlfcn.c
	Win32_Interop/Win32_Extras.c
	Win32_Interop/Win32_PThread.c
	Win32_Interop/Win32_ThreadControl.c
	Win32_Interop/Win32_Time.c
	dict.c
	log.c
	lxluasocket.c 
	message_queue.c
	ringbuf.c
	skynet_timer.c
	socket_server.c
	util.c
	write_buffer.c
	zmalloc.c
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

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} XLUASOCKET_H)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} XLUASOCKET_C)

add_library(xluasocket SHARED ${XLUASOCKET_H} ${XLUASOCKET_C})
target_include_directories(xluasocket PRIVATE ../lua/src)
if (WIN32)
	target_include_directories(xluasocket PRIVATE posix)
	target_compile_definitions(xluasocket PRIVATE LUA_BUILD_AS_DLL XLUASOCKET)
endif ()
set_target_properties(xluasocket PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(xluasocket PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(xluasocket PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(xluasocket PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(xluasocket ../../xluatest/liblua)
ADD_DEPENDENCIES(xluasocket liblua)
