# - Find Gflags
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
# This module finds if Gflags is installed and determines where the
# executables are. It sets the following variables:
#
#  GFLAGS_FOUND : boolean            - system has Gflags
#  GFLAGS_LIBRARIES : list(filepath) - the libraries needed to use Gflags
#  GFLAGS_INCLUDE_DIRS : list(path)  - the Gflags include directories
#
# If Gflags is not found, this module downloads it according to the
# following variables:
#
#  GFLAGS_ROOT_DIR : path                - the Path where Gflags will be installed on
#  GFLAGS_REQUESTED_VERSION : string     - the Gflags version to be downloaded
#
# You can also specify its components:
#
#  find_package(Gflags)
#
#
# You can also specify its behavior:
#
#  GFLAGS_USE_STATIC_LIBS : boolean (default: ON)

set(GFLAGS_ROOT_DIR ${CMAKE_BINARY_DIR}/gflags)
set(GFLAGS_USE_STATIC_LIBS true)

# Set the library prefix and library suffix properly.
if(GFLAGS_USE_STATIC_LIBS)
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

macro(DO_FIND_GFLAGS_SYSTEM)
	find_path(GFLAGS_INCLUDE_DIR gflags/gflags.h
		PATHS /usr/local/include /usr/include
		)
	message("GFLAGS_INCLUDE_DIR: " ${GFLAGS_INCLUDE_DIR})
	find_library(GFLAGS_LIBRARY
		NAMES gflags
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	message("GFLAGS_LIBRARY: " ${GFLAGS_LIBRARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Gflags DEFAULT_MSG
		GFLAGS_INCLUDE_DIR GFLAGS_LIBRARY
		)
	set(GFLAGS_LIBRARIES ${GFLAGS_LIBRARY})
	set(GFLAGS_INCLUDE_DIRS ${GFLAGS_INCLUDE_DIR})
	mark_as_advanced(GFLAGS_LIBRARIES GFLAGS_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_GFLAGS_ROOT)
	if(NOT GFLAGS_ROOT_DIR)
		message(STATUS "GFLAGS_ROOT_DIR is not defined, using binary directory.")
		set(GFLAGS_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_path(GFLAGS_INCLUDE_DIR gflags/gflags.h ${GFLAGS_ROOT_DIR}/include)
	message("GFLAGS_INCLUDE_DIR: " ${GFLAGS_INCLUDE_DIR})
	find_library(GFLAGS_LIBRARY gflags HINTS ${GFLAGS_ROOT_DIR}/lib)
	message("GFLAGS_LIBRARY: " ${GFLAGS_LIBRARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Gflags DEFAULT_MSG
		GFLAGS_INCLUDE_DIR GFLAGS_LIBRARY
		)
	set(GFLAGS_LIBRARIES ${GFLAGS_LIBRARY})
	set(GFLAGS_INCLUDE_DIRS ${GFLAGS_INCLUDE_DIR})
	mark_as_advanced(GFLAGS_LIBRARIES GFLAGS_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_GFLAGS_DOWNLOAD)
	set(GFLAGS_MAYBE_STATIC)
	if(GFLAGS_USE_STATIC_LIBS)
		set(GFLAGS_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Gflags
		URL https://github.com/gflags/gflags/archive/v2.2.1.zip
		URL_HASH SHA256=4e44b69e709c826734dbbbd5208f61888a2faf63f239d73d8ba0011b2dccc97a
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND cmake -DCMAKE_INSTALL_PREFIX=${GFLAGS_ROOT_DIR} -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=ON -DGFLAGS_NAMESPACE=google .
		BUILD_COMMAND make
		BUILD_IN_SOURCE true
		INSTALL_COMMAND make install
		INSTALL_DIR ${GFLAGS_ROOT_DIR}
		)

	ExternalProject_Get_Property(Gflags INSTALL_DIR)
	set(GFLAGS_INCLUDE_DIR ${INSTALL_DIR}/include)
	message("GFLAGS_INCLUDE_DIR: " ${GFLAGS_INCLUDE_DIR})
	set(GFLAGS_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}gflags${LIBRARY_SUFFIX})
	message("GFLAGS_LIBRARY: " ${GFLAGS_LIBRARY})

	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Gflags DEFAULT_MSG
		GFLAGS_INCLUDE_DIR GFLAGS_LIBRARY
		)
	set(GFLAGS_LIBRARIES ${GFLAGS_LIBRARY})
	set(GFLAGS_INCLUDE_DIRS ${GFLAGS_INCLUDE_DIR})
	mark_as_advanced(GFLAGS_LIBRARIES GFLAGS_INCLUDE_DIRS)
endmacro()

if(NOT GFLAGS_FOUND)
	DO_FIND_GFLAGS_ROOT()
endif()

if(NOT GFLAGS_FOUND)
	DO_FIND_GFLAGS_SYSTEM()
endif()

if(NOT GFLAGS_FOUND)
	DO_FIND_GFLAGS_DOWNLOAD()
endif()
