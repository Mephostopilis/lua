project(libbase)

#file(GLOB BASE_H ./base/*.h)
#file(GLOB BASE_C ./base/*.c)
#file(GLOB ENTITASPP_C ./EntitasPP/*.cpp)
file(GLOB XLOG_H ./xlog/*.h)
#file(GLOB XLOG_C ./xlog/*.c)

include_directories(.)
include_directories(../3rd/lua)
include_directories(../skynet-src)

IF(MSVC)
include_directories(../3rd/posix)
#ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)

#source_group("base" FILES ${BASE_H} ${BASE_C})
#source_group("entitas" FILES ${ENTITASPP_C})
source_group("xlog" FILES ${XLOG_H})

ELSE(MSVC)
ADD_DEFINITIONS(-DUSE_SKYNET)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

# target
add_library(libbase ${XLOG_H})

IF(MSVC)
set_target_properties(libbase PROPERTIES FOLDER "base")
IF(CMAKE_CL_64)
set_target_properties(libbase PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin/win64)
target_link_libraries(libbase ../../../bin/win64/strawberry)
ENDIF(CMAKE_CL_64)

ELSE(MSVC)
#target_link_libraries(libbase ../../../bin/linux/strawberry)
ENDIF()

ADD_DEPENDENCIES(libbase strawberry)
