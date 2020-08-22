SET(TIMER_C 
	./lua-timesync.c
	./lua-pack.c
	./ringbuf.c
)

add_library(timesync SHARED ${TIMER_C})
set_target_properties(timesync PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(timesync PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_link_libraries(timesync ../../liblua)
target_include_directories(timesync PRIVATE ../lua/src)
ADD_DEPENDENCIES(timesync liblua)

if (MSVC)
	target_compile_definitions (timesync PRIVATE LUA_BUILD_AS_DLL)
endif ()
