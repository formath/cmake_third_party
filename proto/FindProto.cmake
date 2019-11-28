# - Find Proto
# 
# Copyright (c) 2019 jinpengliu@163.com
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# This module finds if Proto is installed and determines where the
# executables are. It sets the following variables:
#
#  PROTO_FOUND : boolean            - system has Proto
#  PROTO_LIBRARIES : list(filepath) - the libraries needed to use Proto
#  PROTO_INCLUDE_DIRS : list(path)  - the Proto include directories
#
#
# You can also specify its components:
#
#  find_package(Proto)
#

get_filename_component(PROTOBUF_LIB_PATH ${PROTOBUF_LIBRARY} DIRECTORY)
message("PROTOBUF_LIBRARY: " ${PROTOBUF_LIBRARY})
message("PROTOBUF_LIB_PATH: " ${PROTOBUF_LIB_PATH})
message("PROTOC_BINARY: " ${PROTOC_BINARY})

include(FindPackageHandleStandardArgs)

macro(DO_FIND_PB)
  set(PB_SOURCES "")
  set(PB_HEADERS "")
	file(GLOB PROTOS  ${CMAKE_CURRENT_SOURCE_DIR}/proto/*.proto)
  message("PROTO FILES: " ${PROTOS})
  foreach(proto ${PROTOS})
    message("start to find proto file: " ${proto})
    get_filename_component(PROTO_NAME ${proto} NAME_WE)
    get_filename_component(PROTO_PATH ${proto} DIRECTORY)

    set(PROTO_HEADER "${PROTO_NAME}.pb.h")
    set(PROTO_SRC    "${PROTO_NAME}.pb.cc")
	  find_file(PROTO_HEADER_DIR ${PROTO_HEADER}
		  PATHS ${CMAKE_CURRENT_SOURCE_DIR}
		  )
	  find_file(PROTO_SRC_DIR ${PROTO_SRC}
      PATHS ${CMAKE_CURRENT_SOURCE_DIR}
      )
	  FIND_PACKAGE_HANDLE_STANDARD_ARGS(Proto DEFAULT_MSG
		  PROTO_HEADER_DIR PROTO_SRC_DIR
		  )
    list(APPEND PB_SOURCES ${PROTO_PATH}/${PROTO_SRC})
    list(APPEND PB_HEADERS ${PROTO_PATH}/${PROTO_HEADER})
  endforeach()
endmacro()

macro(DO_COMPILE_PB)
  set(PB_SOURCES "")
  set(PB_HEADERS "")
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

    list(APPEND PB_SOURCES ${PROTO_PATH}/${PROTO_SRC})
    list(APPEND PB_HEADERS ${PROTO_PATH}/${PROTO_HEADER})
  endforeach()
endmacro()

if(NOT PROTO_FOUND)
	DO_FIND_PB()
endif()
if(NOT PROTO_FOUND)
	DO_COMPILE_PB()
endif()
