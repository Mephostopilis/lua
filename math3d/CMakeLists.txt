
SET(MATH3D_C fastmath.h linalg.c linalg.h math3d.c math3d.h mathadapter.c math3dfunc.cpp math3dfunc.h refstack.h testadapter.c util.h)

add_library(math3d SHARED ${MATH3D_C})
target_compile_definitions(math3d PRIVATE LUA_BUILD_AS_DLL)
target_include_directories(math3d PRIVATE ../lua/src)
target_include_directories(math3d PRIVATE glm)
set_target_properties(math3d PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(math3d PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
target_link_libraries(math3d ../../liblua)
