project(socket)

include_directories(../lua/src)

set ( SOCKET_CORE luasocket.c timeout.c buffer.c io.c auxiliar.c compat.c options.c inet.c except.c select.c tcp.c udp.c)

if (MSVC)
    add_library(socket SHARED ${SOCKET_CORE} wsocket.c)
	target_compile_definitions (socket PRIVATE LUA_BUILD_AS_DLL _WINSOCK_DEPRECATED_NO_WARNINGS)
else (MSVC)
    add_library(socket SHARED ${SOCKET_CORE} usocket.c)
endif ()

#set_target_properties(socket PROPERTIES PREFIX "")
#set_target_properties(socket PROPERTIES SUFFIX ".so")
#set_target_properties(socket PROPERTIES FOLDER "lualib")
set_target_properties(socket PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY ../../xluatest
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest
	ARCHIVE_OUTPUT_DIRECTORY ../../xluatest
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest
    LIBRARY_OUTPUT_DIRECTORY ../../xluatest
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../xluatest
)

if (MSVC)
	target_link_libraries(socket ws2_32)
endif (MSVC)
target_link_libraries(socket ../../xluatest/liblua)

ADD_DEPENDENCIES(socket liblua)
