# - Find Protobuf
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
# This module finds if Protobuf is installed and determines where the
# executables are. It sets the following variables:
#
#  PROTOBUF_FOUND : boolean            - system has Protobuf
#  PROTOBUF_LIBRARIES : list(filepath) - the libraries needed to use Protobuf
#  PROTOBUF_INCLUDE_DIRS : list(path)  - the Protobuf include directories
#  PROTOC_BINARY : filepath  - the protoc binary
#
# If Protobuf is not found, this module downloads it according to the
# following variables:
#
#  PROTOBUF_ROOT_DIR : path                - the Path where Protobuf will be installed on
#  PROTOBUF_REQUESTED_VERSION : string     - the Protobuf version to be downloaded
#
# You can also specify its components:
#
#  find_package(Protobuf)
#
#
# You can also specify its behavior:
#
#  PROTOBUF_USE_STATIC_LIBS : boolean (default: OFF)

set(PROTOBUF_ROOT_DIR ${CMAKE_BINARY_DIR}/glog)
set(PROTOBUF_USE_STATIC_LIBS true)

# Set the library prefix and library suffix properly.
if(PROTOBUF_USE_STATIC_LIBS)
	set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_STATIC_LIBRARY_PREFIX})
	set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX})
	set(LIBRARY_PREFIX ${CMAKE_STATIC_LIBRARY_PREFIX})
	set(LIBRARY_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
else()
	set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_SHARED_LIBRARY_PREFIX})
	set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_SHARED_LIBRARY_SUFFIX})
	set(LIBRARY_PREFIX ${CMAKE_SHARED_LIBRARY_PREFIX})
	set(LIBRARY_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
endif()

include(FindPackageHandleStandardArgs)

macro(DO_FIND_PROTOBUF_SYSTEM)
	find_path(PROTOBUF_INCLUDE_DIR google/protobuf/message.h
		PATHS /usr/local/include /usr/include
		)
	message("PROTOBUF_INCLUDE_DIR: " ${PROTOBUF_INCLUDE_DIR})
	find_library(PROTOBUF_LIBRARY
		NAMES protobuf
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	message("PROTOBUF_LIBRARY: " ${PROTOBUF_LIBRARY})
	find_library(PROTOBUF_LITE_LIBRARY
		NAMES protobuf-lite
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	message("PROTOBUF_LITE_LIBRARY: " ${PROTOBUF_LITE_LIBRARY})
	find_program(PROTOC_BINARY
		NAMES protoc
		PATHS /usr/local/bin /usr/bin
		)
	message("PROTOC_BINARY: " ${PROTOC_BINARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Protobuf DEFAULT_MSG
		PROTOBUF_INCLUDE_DIR PROTOBUF_LIBRARY PROTOBUF_LITE_LIBRARY PROTOC_BINARY
		)
	list(APPEND PROTOBUF_LIBRARIES ${PROTOBUF_LIBRARY} ${PROTOBUF_LITE_LIBRARY})
	set(PROTOBUF_INCLUDE_DIRS ${PROTOBUF_INCLUDE_DIR})
	mark_as_advanced(PROTOBUF_LIBRARIES PROTOBUF_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_PROTOBUF_ROOT)
	if(NOT PROTOBUF_ROOT_DIR)
		message(STATUS "PROTOBUF_ROOT_DIR is not defined, using binary directory.")
		set(PROTOBUF_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_path(PROTOBUF_INCLUDE_DIR google/protobuf/message.h ${PROTOBUF_ROOT_DIR}/include)
	message("PROTOBUF_INCLUDE_DIR: " ${PROTOBUF_INCLUDE_DIR})
	find_library(PROTOBUF_LIBRARY protobuf HINTS ${PROTOBUF_ROOT_DIR}/lib)
	message("PROTOBUF_LIBRARY: " ${PROTOBUF_LIBRARY})
	find_library(PROTOBUF_LITE_LIBRARY
		NAMES protobuf-lite
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	message("PROTOBUF_LITE_LIBRARY: " ${PROTOBUF_LITE_LIBRARY})
	find_program(PROTOC_BINARY
		NAMES protoc
		PATHS /usr/local/bin /usr/bin
		)
	message("PROTOC_BINARY: " ${PROTOC_BINARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Protobuf DEFAULT_MSG
		PROTOBUF_INCLUDE_DIR PROTOBUF_LIBRARY PROTOBUF_LITE_LIBRARY PROTOC_BINARY
		)
	list(APPEND PROTOBUF_LIBRARIES ${PROTOBUF_LIBRARY} ${PROTOBUF_LITE_LIBRARY})
	set(PROTOBUF_INCLUDE_DIRS ${PROTOBUF_INCLUDE_DIR})
	mark_as_advanced(PROTOBUF_LIBRARIES PROTOBUF_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_PROTOBUF_DOWNLOAD)
	set(PROTOBUF_MAYBE_STATIC)
	if(PROTOBUF_USE_STATIC_LIBS)
		set(PROTOBUF_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Protobuf
		URL https://github.com/protocolbuffers/protobuf/archive/v3.11.0.tar.gz
		URL_HASH SHA256=6d356a6279cc76d2d5c4dfa6541641264b59eae0bc96b852381361e3400d1f1c
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND ./autogen.sh && ./configure --prefix=${PROTOBUF_ROOT_DIR}
		BUILD_COMMAND make
		BUILD_IN_SOURCE true
		INSTALL_COMMAND make install
		INSTALL_DIR ${PROTOBUF_ROOT_DIR}
		)

	ExternalProject_Get_Property(Protobuf INSTALL_DIR)
	set(PROTOBUF_INCLUDE_DIR ${INSTALL_DIR}/include)
	message("PROTOBUF_INCLUDE_DIR: " ${PROTOBUF_INCLUDE_DIR})
	set(PROTOBUF_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}protobuf${LIBRARY_SUFFIX})
	message("PROTOBUF_LIBRARY: " ${PROTOBUF_LIBRARY})
	set(PROTOBUF_LITE_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}protobuf-lite${LIBRARY_SUFFIX})
	message("PROTOBUF_LITE_LIBRARY: " ${PROTOBUF_LITE_LIBRARY})
	set(PROTOC_BINARY ${INSTALL_DIR}/bin/protoc)
	message("PROTOBUF_LIBRARY: " ${PROTOBUF_LIBRARY})

	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Protobuf DEFAULT_MSG
		PROTOBUF_INCLUDE_DIR PROTOBUF_LIBRARY PROTOBUF_LITE_LIBRARY PROTOC_BINARY
		)
	list(APPEND PROTOBUF_LIBRARIES ${PROTOBUF_LIBRARY} ${PROTOBUF_LITE_LIBRARY})
	set(PROTOBUF_INCLUDE_DIRS ${PROTOBUF_INCLUDE_DIR})
	mark_as_advanced(PROTOBUF_LIBRARIES PROTOBUF_INCLUDE_DIRS)
endmacro()

if(NOT PROTOBUF_FOUND)
	DO_FIND_PROTOBUF_ROOT()
endif()

if(NOT PROTOBUF_FOUND)
	DO_FIND_PROTOBUF_SYSTEM()
endif()

if(NOT PROTOBUF_FOUND)
	DO_FIND_PROTOBUF_DOWNLOAD()
endif()
