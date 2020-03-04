cmake_minimum_required(VERSION 3.0.2)

get_filename_component(PROTOBUF_LIB_PATH ${PROTOBUF_LIBRARY} DIRECTORY)
message("PROTOBUF_LIBRARY: " ${PROTOBUF_LIBRARY})
message("PROTOBUF_LIB_PATH: " ${PROTOBUF_LIB_PATH})
message("PROTOC_BINARY: " ${PROTOC_BINARY})

file(GLOB PROTOS  ${CMAKE_CURRENT_SOURCE_DIR}/proto/*.proto)
foreach(proto ${PROTOS})
  message("start to compile proto file: " ${proto})
  get_filename_component(PROTO_NAME ${proto} NAME_WE)
  get_filename_component(PROTO_PATH ${proto} DIRECTORY)

  set(PROTO_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/proto/gen-cpp/${PROTO_NAME}.pb.h")
  set(PROTO_SRC    "${CMAKE_CURRENT_SOURCE_DIR}/proto/gen-cpp/${PROTO_NAME}.pb.cc")

  add_custom_command(
    OUTPUT ${PROTO_SRC} ${PROTO_HEADER}
    COMMAND LIBRARY_PATH=${PROTOBUF_LIB_PATH} ${PROTOC_BINARY}
    ARGS --cpp_out ${CMAKE_CURRENT_SOURCE_DIR}/proto --python_out ${CMAKE_CURRENT_SOURCE_DIR}/proto -I${PROTO_PATH} ${proto}
    WORKING_DIRECTORY "./"
    DEPENDS "${proto}"
    )
  message("compiled proto file: " ${PROTO_HEADER} " " ${PROTO_SRC})

  set("COMPILE_PB_TARGET_${PROTO_NAME}" "COMPILE_${PROTO_NAME}")
  add_custom_target("COMPILE_PB_TARGET_${PROTO_NAME}" ALL
    DEPENDS ${PROTO_HEADER} ${PROTO_SRC})

  list(APPEND PB_SOURCES ${PROTO_PATH}/${PROTO_SRC})
  list(APPEND PB_HEADERS ${PROTO_PATH}/${PROTO_HEADER})
  list(APPEND PB_TARGETS "COMPILE_PB_TARGET_${PROTO_NAME}")
endforeach()