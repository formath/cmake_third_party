# - Find Cityhash
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
# This module finds if Cityhash is installed and determines where the
# executables are. It sets the following variables:
#
#  CITYHASH_FOUND : boolean            - system has Cityhash
#  CITYHASH_LIBRARIES : list(filepath) - the libraries needed to use Cityhash
#  CITYHASH_INCLUDE_DIRS : list(path)  - the Cityhash include directories
#
# If Cityhash is not found, this module downloads it according to the
# following variables:
#
#  CITYHASH_ROOT_DIR : path                - the Path where Cityhash will be installed on
#  CITYHASH_REQUESTED_VERSION : string     - the Cityhash version to be downloaded
#
# You can also specify its components:
#
#  find_package(Cityhash)
#
#
# You can also specify its behavior:
#
#  CITYHASH_USE_STATIC_LIBS : boolean (default: OFF)

set(CITYHASH_ROOT_DIR ${CMAKE_BINARY_DIR}/cityhash)
set(CITYHASH_USE_STATIC_LIBS false)

# Set the library prefix and library suffix properly.
if(CITYHASH_USE_STATIC_LIBS)
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

macro(DO_FIND_CITYHASH_SYSTEM)
	find_path(CITYHASH_INCLUDE_DIR city.h
		PATHS /usr/local/include /usr/include
		)
	find_library(CITYHASH_LIBRARY
		NAMES cityhash
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Cityhash DEFAULT_MSG
		CITYHASH_INCLUDE_DIR CITYHASH_LIBRARY
		)
	set(CITYHASH_LIBRARIES ${CITYHASH_LIBRARY})
	set(CITYHASH_INCLUDE_DIRS ${CITYHASH_INCLUDE_DIR})
	mark_as_advanced(CITYHASH_LIBRARIES CITYHASH_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_CITYHASH_ROOT)
	if(NOT CITYHASH_ROOT_DIR)
		message(STATUS "CITYHASH_ROOT_DIR is not defined, using binary directory.")
		set(CITYHASH_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_path(CITYHASH_INCLUDE_DIR city.h ${CITYHASH_ROOT_DIR}/include)
	find_library(CITYHASH_LIBRARY cityhash HINTS ${CITYHASH_ROOT_DIR}/lib)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Cityhash DEFAULT_MSG
		CITYHASH_INCLUDE_DIR CITYHASH_LIBRARY
		)
	set(CITYHASH_LIBRARIES ${CITYHASH_LIBRARY})
	set(CITYHASH_INCLUDE_DIRS ${CITYHASH_INCLUDE_DIR})
	mark_as_advanced(CITYHASH_LIBRARIES CITYHASH_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_CITYHASH_DOWNLOAD)
	set(CITYHASH_MAYBE_STATIC)
	if(CITYHASH_USE_STATIC_LIBS)
		set(CITYHASH_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Cityhash
		URL https://github.com/formath/cityhash/archive/1.1.1.tar.gz
		URL_HASH SHA256=01dd4080050dc5fbd806c4c66b5f09f9b86fb9ba73e4f1076ba31e907ac58f84
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND ./configure --prefix=${CITYHASH_ROOT_DIR}
		BUILD_COMMAND make all
		BUILD_IN_SOURCE true
		INSTALL_COMMAND make install
		INSTALL_DIR ${CITYHASH_ROOT_DIR}
		)

	ExternalProject_Get_Property(Cityhash INSTALL_DIR)
	set(CITYHASH_INCLUDE_DIR ${INSTALL_DIR}/include)
	set(CITYHASH_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}cityhash${LIBRARY_SUFFIX})
	
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Cityhash DEFAULT_MSG
		CITYHASH_INCLUDE_DIR CITYHASH_LIBRARY
		)
	set(CITYHASH_LIBRARIES ${CITYHASH_LIBRARY})
	set(CITYHASH_INCLUDE_DIRS ${CITYHASH_INCLUDE_DIR})
	mark_as_advanced(CITYHASH_LIBRARIES CITYHASH_INCLUDE_DIRS)
endmacro()

if(NOT CITYHASH_FOUND)
	DO_FIND_CITYHASH_ROOT()
endif()

if(NOT CITYHASH_FOUND)
	DO_FIND_CITYHASH_SYSTEM()
endif()

if(NOT CITYHASH_FOUND)
	DO_FIND_CITYHASH_DOWNLOAD()
endif()
