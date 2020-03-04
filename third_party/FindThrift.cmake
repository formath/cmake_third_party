# - Find Thrift
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

set(THRIFT_ROOT_DIR ${CMAKE_BINARY_DIR}/glog)
set(THRIFT_USE_STATIC_LIBS true)

# Set the library prefix and library suffix properly.
if(THRIFT_USE_STATIC_LIBS)
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

macro(DO_FIND_THRIFT_SYSTEM)
	find_path(THRIFT_INCLUDE_DIR thrift/Thrift.h 
		PATHS /usr/local/include /usr/include
		)
	message("THRIFT_INCLUDE_DIR: " ${THRIFT_INCLUDE_DIR})
	find_library(THRIFT_LIBRARY
		NAMES thrift
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	message("THRIFT_LIBRARY: " ${THRIFT_LIBRARY})
	find_library(THRIFTNB_LIBRARY
		NAMES thriftnb
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	message("THRIFTNB_LIBRARY: " ${THRIFTNB_LIBRARY})
	find_program(THRIFT_BINARY
		NAMES thrift
		PATHS /usr/local/bin /usr/bin
		)
	message("THRIFT_BINARY: " ${THRIFT_BINARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Thrift DEFAULT_MSG
		THRIFT_INCLUDE_DIR THRIFT_LIBRARY THRIFTNB_LIBRARY THRIFT_BINARY
		)
	list(APPEND THRIFT_LIBRARIES ${THRIFT_LIBRARY} ${THRIFTNB_LIBRARY})
	set(THRIFT_INCLUDE_DIRS ${THRIFT_INCLUDE_DIR})
	get_filename_component(THRIFT_LIB_DIR ${THRIFT_LIBRARY} DIRECTORY)
	set(THRIFT_LIB_DIRS ${THRIFT_LIB_DIR})
	mark_as_advanced(THRIFT_LIBRARIES THRIFT_INCLUDE_DIRS THRIFT_LIB_DIRS)
endmacro()

macro(DO_FIND_THRIFT_ROOT)
	if(NOT THRIFT_ROOT_DIR)
		message(STATUS "THRIFT_ROOT_DIR is not defined, using binary directory.")
		set(THRIFT_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_path(THRIFT_INCLUDE_DIR thrift/Thrift.h ${THRIFT_ROOT_DIR}/include)
	message("THRIFT_INCLUDE_DIR: " ${THRIFT_INCLUDE_DIR})
	find_library(THRIFT_LIBRARY thrift HINTS ${THRIFT_ROOT_DIR}/lib)
	message("THRIFT_LIBRARY: " ${THRIFT_LIBRARY})
	find_library(THRIFTNB_LIBRARY
		NAMES thriftnb
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	message("THRIFTNB_LIBRARY: " ${THRIFTNB_LIBRARY})
	find_program(THRIFT_BINARY
		NAMES thrift
		PATHS /usr/local/bin /usr/bin
		)
	message("THRIFT_BINARY: " ${THRIFT_BINARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Thrift DEFAULT_MSG
		THRIFT_INCLUDE_DIR THRIFT_LIBRARY THRIFTNB_LIBRARY THRIFT_BINARY
		)
	list(APPEND THRIFT_LIBRARIES ${THRIFT_LIBRARY} ${THRIFTNB_LIBRARY})
	set(THRIFT_INCLUDE_DIRS ${THRIFT_INCLUDE_DIR})
	get_filename_component(THRIFT_LIB_DIR ${THRIFT_LIBRARY} DIRECTORY)
	set(THRIFT_LIB_DIRS ${THRIFT_LIB_DIR})
	mark_as_advanced(THRIFT_LIBRARIES THRIFT_INCLUDE_DIRS THRIFT_LIB_DIRS)
endmacro()

macro(DO_FIND_THRIFT_DOWNLOAD)
	set(THRIFT_MAYBE_STATIC)
	if(THRIFT_USE_STATIC_LIBS)
		set(THRIFT_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Thrift
		GIT_REPOSITORY git@github.com:thrift/thrift.git
		GIT_TAG master
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND ./autogen.sh && ./configure --prefix=${THRIFT_ROOT_DIR}
		BUILD_COMMAND make
		BUILD_IN_SOURCE true
		INSTALL_COMMAND make install
		INSTALL_DIR ${THRIFT_ROOT_DIR}
		)

	ExternalProject_Get_Property(Thrift INSTALL_DIR)
	set(THRIFT_INCLUDE_DIR ${INSTALL_DIR}/include)
	message("THRIFT_INCLUDE_DIR: " ${THRIFT_INCLUDE_DIR})
	set(THRIFT_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}thrift${LIBRARY_SUFFIX})
	message("THRIFT_LIBRARY: " ${THRIFT_LIBRARY})
	set(THRIFTNB_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}thriftnb${LIBRARY_SUFFIX})
	message("THRIFTNB_LIBRARY: " ${THRIFTNB_LIBRARY})
	set(THRIFT_BINARY ${INSTALL_DIR}/bin/thrift)
	message("THRIFT_LIBRARY: " ${THRIFT_LIBRARY})

	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Thrift DEFAULT_MSG
		THRIFT_INCLUDE_DIR THRIFT_LIBRARY THRIFTNB_LIBRARY THRIFT_BINARY
		)
	list(APPEND THRIFT_LIBRARIES ${THRIFT_LIBRARY} ${THRIFTNB_LIBRARY})
	set(THRIFT_INCLUDE_DIRS ${THRIFT_INCLUDE_DIR})
	get_filename_component(THRIFT_LIB_DIR ${THRIFT_LIBRARY} DIRECTORY)
	set(THRIFT_LIB_DIRS ${THRIFT_LIB_DIR})
	mark_as_advanced(THRIFT_LIBRARIES THRIFT_INCLUDE_DIRS THRIFT_LIB_DIRS)
endmacro()

if(NOT THRIFT_FOUND)
	DO_FIND_THRIFT_ROOT()
endif()

if(NOT THRIFT_FOUND)
	DO_FIND_THRIFT_SYSTEM()
endif()

#if(NOT THRIFT_FOUND)
#	DO_FIND_THRIFT_DOWNLOAD()
#endif()
