# - Find Libevent
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

set(LIBEVENT_ROOT_DIR ${CMAKE_BINARY_DIR}/glog)
set(LIBEVENT_USE_STATIC_LIBS true)

# Set the library prefix and library suffix properly.
if(LIBEVENT_USE_STATIC_LIBS)
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

macro(DO_FIND_LIBEVENT_SYSTEM)
	find_library(LIBEVENT_LIBRARY
		NAMES event
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	message("LIBEVENT_LIBRARY: " ${LIBEVENT_LIBRARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Thrift DEFAULT_MSG
		LIBEVENT_LIBRARY
		)
	list(APPEND LIBEVENT_LIBRARIES ${LIBEVENT_LIBRARY})
	get_filename_component(LIBEVENT_LIB_DIR ${LIBEVENT_LIBRARY} DIRECTORY)
	set(LIBEVENT_LIB_DIRS ${LIBEVENT_LIB_DIR})
	mark_as_advanced(LIBEVENT_LIBRARIES LIBEVENT_LIB_DIRS)
endmacro()

macro(DO_FIND_LIBEVENT_ROOT)
	if(NOT LIBEVENT_ROOT_DIR)
		message(STATUS "LIBEVENT_ROOT_DIR is not defined, using binary directory.")
		set(LIBEVENT_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_library(LIBEVENT_LIBRARY event HINTS ${LIBEVENT_ROOT_DIR}/lib)
	message("LIBEVENT_LIBRARY: " ${LIBEVENT_LIBRARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Thrift DEFAULT_MSG
		LIBEVENT_LIBRARY
		)
	list(APPEND LIBEVENT_LIBRARIES ${LIBEVENT_LIBRARY})
	get_filename_component(LIBEVENT_LIB_DIR ${LIBEVENT_LIBRARY} DIRECTORY)
	set(LIBEVENT_LIB_DIRS ${LIBEVENT_LIB_DIR})
	mark_as_advanced(LIBEVENT_LIBRARIES LIBEVENT_LIB_DIRS)
endmacro()

macro(DO_FIND_LIBEVENT_DOWNLOAD)
	set(LIBEVENT_MAYBE_STATIC)
	if(LIBEVENT_USE_STATIC_LIBS)
		set(LIBEVENT_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Thrift
		GIT_REPOSITORY git@github.com:event/event.git
		GIT_TAG master
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND ./autogen.sh && ./configure --prefix=${LIBEVENT_ROOT_DIR}
		BUILD_COMMAND make
		BUILD_IN_SOURCE true
		INSTALL_COMMAND make install
		INSTALL_DIR ${LIBEVENT_ROOT_DIR}
		)

	ExternalProject_Get_Property(Thrift INSTALL_DIR)
	set(LIBEVENT_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}event${LIBRARY_SUFFIX})
	message("LIBEVENT_LIBRARY: " ${LIBEVENT_LIBRARY})

	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Thrift DEFAULT_MSG
		LIBEVENT_LIBRARY
		)
	list(APPEND LIBEVENT_LIBRARIES ${LIBEVENT_LIBRARY})
	get_filename_component(LIBEVENT_LIB_DIR ${LIBEVENT_LIBRARY} DIRECTORY)
	set(LIBEVENT_LIB_DIRS ${LIBEVENT_LIB_DIR})
	mark_as_advanced(LIBEVENT_INCLUDE_DIRS LIBEVENT_LIB_DIRS)
endmacro()

if(NOT LIBEVENT_FOUND)
	DO_FIND_LIBEVENT_ROOT()
endif()

if(NOT LIBEVENT_FOUND)
	DO_FIND_LIBEVENT_SYSTEM()
endif()

#if(NOT LIBEVENT_FOUND)
#	DO_FIND_LIBEVENT_DOWNLOAD()
#endif()
