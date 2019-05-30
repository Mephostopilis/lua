project(posix)

SET(POSIX_H ./unistd.h ./socket_cpoll.h ./semaphore.h ./sched.h ./pthread.h ./dlfcn.h ./atomicwin.h)
SET(POSIX_C ./atomicwin.c ./dlfcn.c ./unistd.c ./cpoll/cpoll.cpp)
SET(SYS_H ./sys/file.h ./sys/socket.h)
SET(NETINET_H ./netinet/in.h ./netinet/tcp.h)
SET(CPOLL_H ./cpoll/cpoll.h)
SET(CPOLL_CPP ./cpoll/cpoll.cpp)
SET(ARPA_H ./arpa/inet.h)
SET(SRC_DEF ../../../3rd/posix/posix.def)

include_directories(.)

ADD_DEFINITIONS(-DHAVE_STRUCT_TIMESPEC)

source_group("src" FILES ${POSIX_H} ${POSIX_C})
source_group("sys" FILES ${SYS_H})
source_group("netinet" FILES ${NETINET_H})
source_group("cpoll" FILES ${CPOLL_H} ${CPOLL_CPP})
source_group("arpa" FILES ${ARPA_H})

add_library(posix ${POSIX_H} ${POSIX_C} ${SYS_H} ${NETINET_H} ${CPOLL_H} ${CPOLL_CPP} ${ARPA_H})
IF(CMAKE_CL_64)
if(MSVC)
set_target_properties(posix PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ../../../bin/win64)
#WORKING_DIRECTORY(${CMAKE_CURRENT_SOURCE_DIR}/../..)  
target_link_libraries(posix ws2_32)
SET_TARGET_PROPERTIES(posix PROPERTIES LINK_FLAGS "/DEF:\"../../../3rd/posix/posix.def\"")
set_target_properties(posix PROPERTIES FOLDER "3rd")
endif()
ENDIF()


