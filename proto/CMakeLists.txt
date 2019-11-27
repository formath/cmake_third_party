cmake_minimum_required(VERSION 3.0.2)

get_filename_component(PROTOBUF_LIB_PATH ${PROTOBUF_LIBRARY} DIRECTORY)
message("PROTOBUF_LIBRARY: " ${PROTOBUF_LIBRARY})
message("PROTOBUF_LIB_PATH: " ${PROTOBUF_LIB_PATH})
message("PROTOC_BINARY: " ${PROTOC_BINARY})

macro(compile_pb)
  file(GLOB PROTOS  ${CMAKE_CURRENT_SOURCE_DIR}/proto/*.proto)
  foreach(proto ${PROTOS})
    message("start to compile proto file: " ${proto})
    get_filename_component(PROTO_NAME ${proto} NAME_WE)
    get_filename_component(PROTO_PATH ${proto} DIRECTORY)

    set(PROTO_HEADER "${PROTO_NAME}.pb.h")
    set(PROTO_SRC    "${PROTO_NAME}.pb.cc")

    add_custom_command(
      OUTPUT ${PROTO_SRC} ${PROTO_HEADER}
      COMMAND LIBRARY_PATH=${PROTOBUF_LIB_PATH} ${PROTOC_BINARY}
      ARGS --cpp_out ${PROTO_PATH} -I${PROTO_PATH} ${proto}
      WORKING_DIRECTORY "./"
      DEPENDS "${proto}"
      )
    message("compiled proto file: " ${PROTO_HEADER} " " ${PROTO_SRC})

    #add_custom_target(run ALL
    #  DEPENDS ${PROTO_HEADER} ${PROTO_SRC})

    list(APPEND PB_SOURCES ${PROTO_PATH}/${PROTO_SRC})
    list(APPEND PB_HEADERS ${PROTO_PATH}/${PROTO_HEADER})
  endforeach()
endmacro()
