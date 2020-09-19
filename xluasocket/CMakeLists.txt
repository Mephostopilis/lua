
SET(XLUASOCKET_H
	array.h
	atomic.h
	message_queue.h
	rwlock.h
	simplethread.h
	skynet_timer.h
	socket_info.h
	socket_poll.h
	socket_server.h
	spinlock.h
	xluaconf.h
	platform.h
	protoc.h
)

SET(XLUASOCKET_C
	lxluasocket.c 
	message_queue.c
	skynet_timer.c
	socket_server.c
	lua-timesync.c
)

IF(UNIX)
list (APPEND XLUASOCKET_H socket_epoll.h)
ELSE()

list (APPEND XLUASOCKET_H
	Win32_Interop/Win32_APIs.h
	Win32_Interop/Win32_dlfcn.h
	Win32_Interop/Win32_Error.h
	Win32_Interop/Win32_Extras.h
	Win32_Interop/Win32_PThread.h
	Win32_Interop/Win32_ThreadControl.h
	Win32_Interop/Win32_Time.h
	cpoll/win32_cpoll.h
	cpoll/dict.h
	cpoll/util.h
	cpoll/zmalloc.h
)
list (APPEND XLUASOCKET_C
	Win32_Interop/Win32_APIs.c
	
	Win32_Interop/Win32_dlfcn.c
	Win32_Interop/Win32_Error.c
	Win32_Interop/Win32_Extras.c
	Win32_Interop/Win32_PThread.c
	Win32_Interop/Win32_ThreadControl.c
	Win32_Interop/Win32_Time.c
	Win32_Interop/Win32_CStd.c
	cpoll/win32_cpoll.c
	cpoll/util.c
	cpoll/xxhash.c
	cpoll/zmalloc.c
	cpoll/dict.c
)
ENDIF()

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} XLUASOCKET_H)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} XLUASOCKET_C)

add_library(xluasocket SHARED ${XLUASOCKET_H} ${XLUASOCKET_C})
set_target_properties(xluasocket PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../luaclib)
set_target_properties(xluasocket PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../luaclib)
set_target_properties(xluasocket PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(xluasocket PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_include_directories(xluasocket PRIVATE ../lua/src)
if (WIN32)
	target_include_directories(xluasocket PRIVATE posix)
	target_compile_definitions(xluasocket PRIVATE LUA_BUILD_AS_DLL _CRT_SECURE_NO_WARNINGS)
endif ()
#target_compile_definitions(xluasocket PRIVATE XLUA)
#target_compile_definitions(xluasocket PRIVATE -std=c11)
target_compile_features(xluasocket PUBLIC cxx_std_11)
target_link_libraries(xluasocket ../../liblua)
