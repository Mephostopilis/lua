
file(GLOB LIBLUA_H ./*.h)
set(LIBLUA_C 
	lapi.c
	lcode.c
	lctype.c
	ldebug.c 
	ldo.c
	ldump.c
	lfunc.c
	lgc.c
	llex.c
	lmem.c
	lobject.c
	lopcodes.c
	lparser.c
	lstate.c
	lstring.c
	ltable.c
	ltm.c
	lundump.c
	lvm.c
	lzio.c
	lauxlib.c
	lbaselib.c
	lbitlib.c 
	lcorolib.c
	ldblib.c 
	liolib.c 
	lmathlib.c
	loslib.c
	lstrlib.c
	ltablib.c 
	lutf8lib.c
	loadlib.c
	linit.c
)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LIBLUA_H)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LIBLUA_C)
add_library(liblua SHARED ${LIBLUA_H} ${LIBLUA_C})
target_compile_definitions(liblua PRIVATE LUA_BUILD_AS_DLL)
#set_target_properties(liblua PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../../xluatest)
#set_target_properties(liblua PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../../xluatest)
#set_target_properties(liblua PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../xluatest)
#set_target_properties(liblua PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../xluatest)


set(LUA_C ./lua.c)
add_executable(lua ${LUA_C})
set_target_properties(lua PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../../xluatest)
set_target_properties(lua PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../../xluatest)
set_target_properties(lua PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../xluatest)
set_target_properties(lua PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../xluatest)
target_link_libraries(lua ../../../xluatest/liblua)
ADD_DEPENDENCIES(lua liblua)
