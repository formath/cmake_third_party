cmake_minimum_required(VERSION 3.0.2)
project(cmake_third_party VERSION 1.0)

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

# main code include path
include_directories(
  ${BOOST_INCLUDE_DIRS}
  ${CITYHASH_INCLUDE_DIRS}
  ${GFLAGS_INCLUDE_DIRS}
  ${GLOG_INCLUDE_DIRS}
  )

# main target
add_executable(hello hello.cc)
target_link_libraries(
  hello 
  ${BOOST_LIBRARIES}
  ${CITYHASH_LIBRARIES}
  ${GFLAGS_LIBRARIES}
  ${GLOG_LIBRARIES}
  )
