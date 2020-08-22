SET(TIMER_C ./timer.c)

add_library(timer SHARED ${TIMER_C})
set_target_properties(timer PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(timer PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_link_libraries(timer ../../liblua)
target_include_directories(timer PRIVATE ../lua/src)
ADD_DEPENDENCIES(timer liblua)

if (MSVC)
	target_compile_definitions (timer PRIVATE LUA_BUILD_AS_DLL)
endif ()
