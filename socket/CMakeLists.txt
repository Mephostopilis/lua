
set ( SOCKET_CORE luasocket.c timeout.c buffer.c io.c auxiliar.c compat.c options.c inet.c except.c select.c tcp.c udp.c)

if (MSVC)
    add_library(socket SHARED ${SOCKET_CORE} wsocket.c)
	target_compile_definitions (socket PRIVATE LUA_BUILD_AS_DLL _WINSOCK_DEPRECATED_NO_WARNINGS _CRT_SECURE_NO_WARNINGS)
else (MSVC)
    add_library(socket SHARED ${SOCKET_CORE} usocket.c)
endif ()

#set_target_properties(socket PROPERTIES PREFIX "")
#set_target_properties(socket PROPERTIES SUFFIX ".so")
#set_target_properties(socket PROPERTIES FOLDER "lualib")
set_target_properties(socket PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY ../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib
    LIBRARY_OUTPUT_DIRECTORY ../../luaclib
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../luaclib
)
target_include_directories(socket PRIVATE ../lua/src)
target_link_libraries(socket ../../liblua)
if (MSVC)
	target_link_libraries(socket ws2_32)
endif (MSVC)
add_dependencies(socket liblua)
