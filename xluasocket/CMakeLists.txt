
SET(XLUASOCKET_H
	posix/dlfcn.h
	posix/unistd.h
	Win32_Interop/Win32_APIs.h
	Win32_Interop/win32_cpoll.h
	Win32_Interop/Win32_dlfcn.h
	Win32_Interop/Win32_Error.h
	Win32_Interop/Win32_Extras.h
	Win32_Interop/Win32_PThread.h
	Win32_Interop/Win32_ThreadControl.h
	Win32_Interop/Win32_Time.h
	atomic.h
	dict.h
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
	xluaconf.h
	zmalloc.h
)
IF(UNIX)
set(XLUASOCKET_H socket_epoll.h)
ENDIF()

SET(XLUASOCKET_C
	posix/unistd.c
	Win32_Interop/Win32_APIs.c
	Win32_Interop/win32_cpoll.c
	Win32_Interop/Win32_dlfcn.c
	Win32_Interop/Win32_Error.c
	Win32_Interop/Win32_Extras.c
	Win32_Interop/Win32_PThread.c
	Win32_Interop/Win32_ThreadControl.c
	Win32_Interop/Win32_Time.c
	dict.c
	lua-timesync.c
	lxluasocket.c 
	message_queue.c
	ringbuf.c
	skynet_timer.c
	socket_server.c
	util.c
	xxhash.c
	zmalloc.c
)

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
