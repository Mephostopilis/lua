SET(SRC 
	./lua-timesync.c
	./lua-ringbuf.c
	./ringbuf.h
	./ringbuf.c
)

if (MSVC)
list (APPEND SRC ./Win32_Interop/Win32_Time.c ./Win32_Interop/Win32_APIs.c)
endif()

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} SRC)

add_library(timesync SHARED ${SRC})
set_target_properties(timesync PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(timesync PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_include_directories(timesync PRIVATE ../lua/src)
if (MSVC)
	target_compile_definitions (timesync PRIVATE LUA_BUILD_AS_DLL _CRT_SECURE_NO_WARNINGS)
endif ()

target_link_libraries(timesync ../../liblua)