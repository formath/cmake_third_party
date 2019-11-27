cmake_minimum_required(VERSION 3.0.2)
project(cmake_third_party VERSION 1.0)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# third party dependencies cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/third_party)

# boost
find_package(Boost COMPONENTS system program_options)

# cityhash
find_package(Cityhash)

# gflags
find_package(Gflags)

# glog
find_package(Glog)

# protobuf
find_package(Protobuf)

# compile pb
# TODO: how to make proro build running first?
#include(${CMAKE_CURRENT_SOURCE_DIR}/proto/CMakeLists.txt)
#compile_pb()
file(GLOB PROTOS  ${CMAKE_CURRENT_SOURCE_DIR}/proto/*.proto)
foreach(proto ${PROTOS})
  message("start to compile proto file: " ${proto})
  get_filename_component(PROTO_NAME ${proto} NAME_WE)
  get_filename_component(PROTO_PATH ${proto} DIRECTORY)

  set(PROTO_HEADER "${PROTO_NAME}.pb.h")
  set(PROTO_SRC    "${PROTO_NAME}.pb.cc")
  message("hhhaedb: " ${PROTO_PATH})

  add_custom_command(
    OUTPUT ${PROTO_SRC} ${PROTO_HEADER}
    COMMAND LIBRARY_PATH=${PROTOBUF_LIB_PATH} ${PROTOC_BINARY}
    ARGS --cpp_out ${PROTO_PATH} -I${PROTO_PATH} ${proto}
    WORKING_DIRECTORY "./"
    DEPENDS "${proto}"
    )
  message("compiled proto file: " ${PROTO_HEADER} " " ${PROTO_SRC})

  list(APPEND PB_SOURCES ${PROTO_PATH}/${PROTO_SRC})
  list(APPEND PB_HEADERS ${PROTO_PATH}/${PROTO_HEADER})
endforeach()

# main code include path
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${BOOST_INCLUDE_DIRS}
  ${CITYHASH_INCLUDE_DIRS}
  ${GFLAGS_INCLUDE_DIRS}
  ${GLOG_INCLUDE_DIRS}
  ${PROTOBUF_INCLUDE_DIRS}
  )

# main target
add_executable(hello hello.cc ${PB_SOURCES})
target_link_libraries(
  hello 
  ${BOOST_LIBRARIES}
  ${CITYHASH_LIBRARIES}
  ${GFLAGS_LIBRARIES}
  ${GLOG_LIBRARIES}
  ${PROTOBUF_LIBRARIES}
  )
