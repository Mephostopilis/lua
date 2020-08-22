# cmake_minimum_required(VERSION 3.12)

if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -fPIC")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra -fPIC")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
	# message (${CMAKE_C_FLAGS})
	# message (${CMAKE_CXX_FLAGS})
endif ()

set (SIGNAL_CORE
	./lsignal.c
	./lsignal.h
)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} SIGNAL_CORE)

add_library(signal SHARED ${SIGNAL_CORE})
set_target_properties(signal
    PROPERTIES
    PREFIX ""
	RUNTIME_OUTPUT_DIRECTORY ../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../luaclib
	LIBRARY_OUTPUT_DIRECTORY ../../luaclib
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../luaclib
)
target_include_directories(signal PUBLIC ../lua/src)
target_link_libraries(signal ws2_32 ../../liblua)
if (MSVC)
	target_compile_definitions(signal PRIVATE LUA_BUILD_AS_DLL _SCL_SECURE_NO_WARNINGS)
endif (MSVC)