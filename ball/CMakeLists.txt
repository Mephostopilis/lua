project(ball)
SET(BALL_CORE
	components/IndexComponent.cpp
    components/IndexComponent.h
	components/PhysXComponent.cpp
	components/PhysXComponent.h
	components/PositionComponent.cpp
	components/PositionComponent.h
	EntitasPP/ComponentTypeId.cpp
	EntitasPP/ComponentTypeId.h
	EntitasPP/Entity.cpp
	EntitasPP/Entity.h
	EntitasPP/Group.cpp
	EntitasPP/Group.h
	EntitasPP/GroupEventType.h
	EntitasPP/GroupObserver.cpp
	EntitasPP/GroupObserver.h
	EntitasPP/IComponent.h
	EntitasPP/ISystem.h
	EntitasPP/Matcher.cpp
	EntitasPP/Pool.cpp
	EntitasPP/Pool.h
	EntitasPP/ReactiveSystem.cpp
	EntitasPP/SystemContainer.cpp
#	hexmap/hexmap.cpp
	systems/EventSystem.cpp
	systems/GenPathSystem.cpp
	systems/IndexSystem.cpp
	systems/JoinSystem.cpp
	systems/LogSystem.cpp
#	systems/MapSystem.cpp
	systems/MoveSystem.cpp
	systems/PhysXSystem.cpp
	lua-ball.cpp
	Systems.cpp
	Systems.h
)

macro(source_group_by_dir proj_dir source_files)
    if(MSVC OR APPLE)
        get_filename_component(sgbd_cur_dir ${proj_dir} ABSOLUTE)
        foreach(sgbd_file ${${source_files}})
			get_filename_component(sgbd_abs_file ${sgbd_file} ABSOLUTE)
            file(RELATIVE_PATH sgbd_fpath ${sgbd_cur_dir} ${sgbd_abs_file})
            string(REGEX REPLACE "\(.*\)/.*" \\1 sgbd_group_name ${sgbd_fpath})
            string(COMPARE EQUAL ${sgbd_fpath} ${sgbd_group_name} sgbd_nogroup)
            string(REPLACE "/" "\\" sgbd_group_name ${sgbd_group_name})
            if(sgbd_nogroup)
                set(sgbd_group_name "\\")
            endif(sgbd_nogroup)
            source_group(${sgbd_group_name} FILES ${sgbd_file})
        endforeach(sgbd_file)
    endif(MSVC OR APPLE)
endmacro(source_group_by_dir)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} BALL_CORE)

add_library(ball SHARED ${BALL_CORE})
target_include_directories(ball PRIVATE ../lua/src)
target_include_directories(ball PRIVATE 3rd)
target_include_directories(ball PRIVATE 3rd/PhysX/include)
target_include_directories(ball PRIVATE 3rd/PxShared/include)
IF(MSVC)
#target_compile_definitions(ball PRIVATE LUA_BUILD_AS_DLL XLUASOCKET)
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
endif ()

set_target_properties(ball PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(ball PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(ball PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(ball PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(ball ../../xluatest/liblua)
target_link_libraries(ball ../../ball/3rd/PhysX/lib/vc14win32/PhysX3DEBUG_x86)
target_link_libraries(ball ../../ball/3rd/PhysX/lib/vc14win32/PhysX3ExtensionsDEBUG)
ADD_DEPENDENCIES(ball liblua)

