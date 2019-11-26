cmake_minimum_required(VERSION 3.0.2)
project(cmake_third_party VERSION 1.0)

# third party dependencies cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/third_party)

# boost
find_package(Boost COMPONENTS system program_options)
message("boost include path: " ${BOOST_INCLUDE_DIRS})
message("boost lib path: " ${BOOST_LIBRARIES})

# cityhash
find_package(Cityhash)
message("cityhash include path: " ${CITYHASH_INCLUDE_DIRS})
message("cityhash lib path: " ${CITYHASH_LIBRARIES})

# gflags
find_package(Gflags)
message("gflags include path: " ${GFLAGS_INCLUDE_DIRS})
message("gflags lib path: " ${GFLAGS_LIBRARIES})

# glog
find_package(Glog)
message("glog include path: " ${GLOG_INCLUDE_DIRS})
message("glog lib path: " ${GLOG_LIBRARIES})

include_directories(
  ${BOOST_INCLUDE_DIRS}
  ${CITYHASH_INCLUDE_DIRS}
  ${GFLAGS_INCLUDE_DIRS}
  ${GLOG_INCLUDE_DIRS}
  )

add_executable(hello hello.cc)
target_link_libraries(
  hello 
  ${BOOST_LIBRARIES}
  ${CITYHASH_LIBRARIES}
  ${GFLAGS_LIBRARIES}
  ${GLOG_LIBRARIES}
  )
