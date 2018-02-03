file(GLOB navigation_ROOT_Cpp *.cpp)
file(GLOB navigation_ROOT_Hpp *.hpp)
file(GLOB navigation_ROOT_H *.h)

include_directories(../src)
add_library(navigation SHARED ${navigation_ROOT_Cpp} ${navigation_ROOT_H} ${navigation_ROOT_Hpp})
add_definitions(-DNF_NONCLIENT_BUILD -D_CRT_SECURE_NO_WARNINGS)
add_definitions(-DLUA_BUILD_AS_DLL)
#set_target_properties( navigation PROPERTIES OUTPUT_NAME_DEBUG "navigation_d")

if( WIN32 )
    set_target_properties( navigation PROPERTIES PREFIX "")
endif()

set_target_properties( navigation PROPERTIES
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin
	LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../bin)
	
if(UNIX)
	if (CMAKE_BUILD_TYPE MATCHES "Release")
		target_link_libraries(navigation )
	else()
		target_link_libraries(navigation )
	endif()
else()
	target_link_libraries(navigation ../../bin/liblua)
	ADD_DEPENDENCIES(navigation lua)
endif()

