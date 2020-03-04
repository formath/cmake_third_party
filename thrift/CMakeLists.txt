cmake_minimum_required(VERSION 3.0.2)

get_filename_component(THRIFT_LIB_PATH ${THRIFT_LIBRARY} DIRECTORY)
message("THRIFT_LIBRARY: " ${THRIFT_LIBRARY})
message("THRIFT_LIB_PATH: " ${THRIFT_LIB_PATH})
message("THRIFT_BINARY: " ${THRIFT_BINARY})

file(GLOB THRIFT_FILES  ${CMAKE_CURRENT_SOURCE_DIR}/thrift/*.thrift)
foreach(thrift_file ${THRIFT_FILES})
  message("start to compile thrift file: " ${thrift_file})
  get_filename_component(THRIFT_NAME ${thrift_file} NAME_WE)
  get_filename_component(THRIFT_PATH ${thrift_file} DIRECTORY)

  set(THRIFT_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/thrift/gen-cpp/${THRIFT_NAME}_types.h")
  set(THRIFT_SRC    "${CMAKE_CURRENT_SOURCE_DIR}/thrift/gen-cpp/${THRIFT_NAME}_types.cpp")

  add_custom_command(
    OUTPUT ${THRIFT_SRC} ${THRIFT_HEADER}
    COMMAND LIBRARY_PATH=${THRIFT_LIB_PATH} ${THRIFT_BINARY}
    ARGS --gen py --gen cpp -r -o ${CMAKE_CURRENT_SOURCE_DIR}/thrift ${thrift_file}
    WORKING_DIRECTORY "./"
    DEPENDS "${thrift_file}"
    )
  message("compiled thrift file: " ${THRIFT_HEADER} " " ${THRIFT_SRC})

  set("COMPILE_THRIFT_TARGET_${THRIFT_NAME}" "COMPILE_${THRIFT_NAME}")
  add_custom_target("COMPILE_THRIFT_TARGET_${THRIFT_NAME}" ALL
    DEPENDS ${THRIFT_HEADER} ${THRIFT_SRC})

  list(APPEND THRIFT_SOURCES ${THRIFT_SRC})
  list(APPEND THRIFT_HEADERS ${THRIFT_HEADER})
endforeach()