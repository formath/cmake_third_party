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
include(proto/CMakeLists.txt)

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
add_dependencies(hello COMPILE_PB)
