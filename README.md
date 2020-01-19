# cmake third party

## Functionality
### common third dependencies
* boost
* protobuf
* gflags
* glog
* cityhash
* adding other packages ...

### find package
* first search package in local machine
* if not exist, download package and build

### compile pb
* automatically compile proto files when building

## Build this project as a demo
```
mkdir cmake_build_tmp && cd cmake_build_tmp
cmake ..
make
./hello --logtostderr=1
```

## Usage this project in your project
* copy `third_party` to your project
* load third dependency cmake file in your `CMakeLists.txt`
  ```
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
  ```

* `proto` auto compile
  ```
  # compile pb
  include(proto/CMakeLists.txt)
  set_source_files_properties(${PB_SOURCES} ${PB_HEADERS} PROPERTIES GENERATED TRUE)

  # add pb dependency
  add_dependencies(your_target ${PB_TARGETS})
  ```