project(config)

set( CONFIG_H 
	./csv.h 
	./strhtable.h 
	./value_t.h
	./desk_manager_t.h
	./data_manager_t.h
)
SET( CONFIG_C 
	./lua-config.cpp 
	./csv.cpp 
	./strhtable.cpp 
	./value_t.cpp
	./desk_manager_t.cpp
	./data_manager_t.cpp
)

include_directories(../lua/src)

add_definitions(-DLUA_BUILD_AS_DLL)

add_library(config SHARED ${CONFIG_H} ${CONFIG_C})
set_target_properties(config PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(config PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(config ../../xluatest/liblua)
add_dependencies(config lua)
