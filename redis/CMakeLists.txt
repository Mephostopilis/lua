
SET(REDIS_H
	Win32_Interop/Win32_APIs.h
	Win32_Interop/Win32_Portability.h
	Win32_Interop/Win32_Time.h
	dict.h
	sds.h
	util.h
	xxhash.h
	zmalloc.h
	ringbuf.h
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
	ringbuf.c
	ringbuf_unittest.cc
)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} REDIS_H)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} REDIS_C)

add_executable(redis ${REDIS_H} ${REDIS_C})
target_compile_definitions(redis PRIVATE _XKEYCHECK_H XXH_INLINE_ALL REDIS_TEST)

set_target_properties(redis PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../..)
set_target_properties(redis PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../..)
set_target_properties(redis PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../..)
set_target_properties(redis PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../..)

target_include_directories(redis PRIVATE googletest/include)
target_link_libraries(redis ../../redis/googletest/Debug/gtestd ../../redis/googletest/Debug/gtest_maind)

