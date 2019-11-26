cmake_minimum_required(VERSION 3.0.2)
project(cmake_third_party VERSION 1.0)

# boost
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/third_party)
set(BOOST_REQUESTED_VERSION 1.61)
set(BOOST_ROOT_DIR third_party/tmp/boost)
#find_package(Boost COMPONENTS system program_options)

# cityhash
set(CITYHASH_REQUESTED_VERSION 1.1.1)
set(CITYHASH_ROOT_DIR /opt/meituan/liujinpeng02/git/cmake_third_party/build/Cityhash-prefix/src/Cityhash)
find_package(Cityhash)

# gflags
#add_subdirectory(third_party/gflags-2.2.1)
set(GFLAGS_REQUESTED_VERSION 2.2.1)
set(GFLAGS_ROOT_DIR /opt/meituan/liujinpeng02/git/cmake_third_party/build/Gflags-prefix/src/Gflags)
find_package(Gflags)

# glog
#add_subdirectory(third_party/glog-0.3.5)
set(GLOG_REQUESTED_VERSION 0.3.5)
set(GLOG_USE_STATIC_LIBS false)
set(GLOG_ROOT_DIR /opt/meituan/liujinpeng02/git/cmake_third_party/build/Glog-prefix/src/Glog)
find_package(Glog)

include_directories(
  ${BOOST_INCLUDE_DIRS}
  ${CITYHASH_INCLUDE_DIRS}
  ${GLOG_INCLUDE_DIRS}
  ${GFLAGS_INCLUDE_DIRS}
  )

add_executable(hello hello.cc)
target_link_libraries(
  hello 
  ${CITYHASH_LIBRARIES}
  ${GLOG_LIBRARIES}
  ${GFLAGS_LIBRARIES}
  )
