# - Find Glog
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
# This module finds if Glog is installed and determines where the
# executables are. It sets the following variables:
#
#  GLOG_FOUND : boolean            - system has Glog
#  GLOG_LIBRARIES : list(filepath) - the libraries needed to use Glog
#  GLOG_INCLUDE_DIRS : list(path)  - the Glog include directories
#
# If Glog is not found, this module downloads it according to the
# following variables:
#
#  GLOG_ROOT_DIR : path                - the Path where Glog will be installed on
#  GLOG_REQUESTED_VERSION : string     - the Glog version to be downloaded
#
# You can also specify its components:
#
#  find_package(Glog)
#
#
# You can also specify its behavior:
#
#  GLOG_USE_STATIC_LIBS : boolean (default: ON)


set(GLOG_USE_STATIC_LIBS true)

# Set the library prefix and library suffix properly.
if(GLOG_USE_STATIC_LIBS)
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

macro(DO_FIND_GLOG_SYSTEM)
	find_path(GLOG_INCLUDE_DIR glog/logging.h
		PATHS /usr/local/include /usr/include
		)
	find_library(GLOG_LIBRARY
		NAMES glog
		PATHS /usr/local/lib /usr/lib
		)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Glog DEFAULT_MSG
		GLOG_INCLUDE_DIR GLOG_LIBRARY
		)
	set(GLOG_LIBRARIES ${GLOG_LIBRARY})
	set(GLOG_INCLUDE_DIRS ${GLOG_INCLUDE_DIR})
	mark_as_advanced(GLOG_LIBRARIES GLOG_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_GLOG_ROOT)
	if(NOT GLOG_ROOT_DIR)
		message(STATUS "GLOG_ROOT_DIR is not defined, using binary directory.")
		set(GLOG_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_path(GLOG_INCLUDE_DIR city.h ${GLOG_ROOT_DIR}/include)
	find_library(GLOG_LIBRARY glog HINTS ${GLOG_ROOT_DIR}/lib)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Glog DEFAULT_MSG
		GLOG_INCLUDE_DIR GLOG_LIBRARY
		)
	set(GLOG_LIBRARIES ${GLOG_LIBRARY})
	set(GLOG_INCLUDE_DIRS ${GLOG_INCLUDE_DIR})
	mark_as_advanced(GLOG_LIBRARIES GLOG_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_GLOG_DOWNLOAD)
	if(NOT GLOG_REQUESTED_VERSION)
		message(FATAL_ERROR "GLOG_REQUESTED_VERSION is not defined.")
	endif()

	string(REPLACE "." "_" GLOG_REQUESTED_VERSION_UNDERSCORE ${GLOG_REQUESTED_VERSION})

	set(GLOG_MAYBE_STATIC)
	if(GLOG_USE_STATIC_LIBS)
		set(GLOG_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Glog
		URL https://github.com/google/glog/archive/v${GLOG_REQUESTED_VERSION}.zip
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND ./autogen.sh && ./configure --prefix=${GLOG_ROOT_DIR}
		BUILD_COMMAND make
		BUILD_IN_SOURCE true
		INSTALL_COMMAND make install
		INSTALL_DIR ${GLOG_ROOT_DIR}
		)

	ExternalProject_Get_Property(Glog INSTALL_DIR)
	set(GLOG_INCLUDE_DIRS ${INSTALL_DIR}/include)
	set(GLOG_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}glog${LIBRARY_SUFFIX}))

	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Glog DEFAULT_MSG
		GLOG_INCLUDE_DIR GLOG_LIBRARY
		)
	set(GLOG_LIBRARIES ${GLOG_LIBRARY})
	set(GLOG_INCLUDE_DIRS ${GLOG_INCLUDE_DIR})
	mark_as_advanced(GLOG_LIBRARIES GLOG_INCLUDE_DIRS)
endmacro()

if(NOT GLOG_FOUND)
	DO_FIND_GLOG_ROOT()
endif()

if(NOT GLOG_FOUND)
	DO_FIND_GLOG_SYSTEM()
endif()

if(NOT GLOG_FOUND)
	DO_FIND_GLOG_DOWNLOAD()
endif()
