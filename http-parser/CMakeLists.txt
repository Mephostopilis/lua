project(httpparser)
SET(PARSER_CORE
	http_parser.c
	http_parser.h
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

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} PARSER_CORE)

add_executable(httpparser ${PARSER_CORE})
target_compile_definitions(httpparser PRIVATE _CRT_SECURE_NO_WARNINGS)
target_include_directories(httpparser PRIVATE ../googletest/include)
set_target_properties(httpparser PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(httpparser PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../xluatest)
set_target_properties(httpparser PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
set_target_properties(httpparser PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../xluatest)
target_link_libraries(httpparser ../../googletest/Debug/gtestd ../../googletest/Debug/gtest_maind)

