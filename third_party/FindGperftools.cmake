# - Find Gperftools
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

set(GPERFTOOLS_ROOT_DIR ${CMAKE_BINARY_DIR}/gperftools)
set(GPERFTOOLS_USE_STATIC_LIBS false)

# Set the library prefix and library suffix properly.
if(GPERFTOOLS_USE_STATIC_LIBS)
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

macro(DO_FIND_GPERFTOOLS_SYSTEM)
	find_path(GPERFTOOLS_INCLUDE_DIR gperftools/tcmalloc.h
		PATHS /usr/local/include /usr/include
		)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Gperftools DEFAULT_MSG
		GPERFTOOLS_INCLUDE_DIR
		)
	set(GPERFTOOLS_INCLUDE_DIRS ${GPERFTOOLS_INCLUDE_DIR})
	mark_as_advanced(GPERFTOOLS_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_GPERFTOOLS_ROOT)
	if(NOT GPERFTOOLS_ROOT_DIR)
		message(STATUS "GPERFTOOLS_ROOT_DIR is not defined, using binary directory.")
		set(GPERFTOOLS_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_path(GPERFTOOLS_INCLUDE_DIR gperftools/tcmalloc.h ${GPERFTOOLS_ROOT_DIR}/include)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Gperftools DEFAULT_MSG
		GPERFTOOLS_INCLUDE_DIR
		)
	set(GPERFTOOLS_INCLUDE_DIRS ${GPERFTOOLS_INCLUDE_DIR})
	mark_as_advanced(GPERFTOOLS_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_GPERFTOOLS_DOWNLOAD)
	set(GPERFTOOLS_MAYBE_STATIC)
	if(GPERFTOOLS_USE_STATIC_LIBS)
		set(GPERFTOOLS_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Gperftools
		GIT_REPOSITORY git@github.com:gperftools/gperftools.git
		GIT_TAG master
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND ./autogen.sh && ./configure --prefix=${GPERFTOOLS_ROOT_DIR}
		BUILD_COMMAND make
		BUILD_IN_SOURCE true
		INSTALL_COMMAND make install
		INSTALL_DIR ${GPERFTOOLS_ROOT_DIR}
		)

	ExternalProject_Get_Property(Gperftools INSTALL_DIR)
	set(GPERFTOOLS_INCLUDE_DIR ${INSTALL_DIR}/include)
	
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Gperftools DEFAULT_MSG
		GPERFTOOLS_INCLUDE_DIR
		)
	set(GPERFTOOLS_INCLUDE_DIRS ${GPERFTOOLS_INCLUDE_DIR})
	mark_as_advanced(GPERFTOOLS_INCLUDE_DIRS)
endmacro()

if(NOT GPERFTOOLS_FOUND)
	DO_FIND_GPERFTOOLS_ROOT()
endif()

if(NOT GPERFTOOLS_FOUND)
	DO_FIND_GPERFTOOLS_SYSTEM()
endif()

if(NOT GPERFTOOLS_FOUND)
	DO_FIND_GPERFTOOLS_DOWNLOAD()
endif()
