# - Find Sparsehash
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

set(SPARSEHASH_ROOT_DIR ${CMAKE_BINARY_DIR}/sparsehash)
set(SPARSEHASH_USE_STATIC_LIBS false)

# Set the library prefix and library suffix properly.
if(SPARSEHASH_USE_STATIC_LIBS)
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

macro(DO_FIND_SPARSEHASH_SYSTEM)
	find_path(SPARSEHASH_INCLUDE_DIR sparsehash/sparse_hash_set
		PATHS /usr/local/include /usr/include
		)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Sparsehash DEFAULT_MSG
		SPARSEHASH_INCLUDE_DIR
		)
	set(SPARSEHASH_INCLUDE_DIRS ${SPARSEHASH_INCLUDE_DIR})
	mark_as_advanced(SPARSEHASH_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_SPARSEHASH_ROOT)
	if(NOT SPARSEHASH_ROOT_DIR)
		message(STATUS "SPARSEHASH_ROOT_DIR is not defined, using binary directory.")
		set(SPARSEHASH_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_path(SPARSEHASH_INCLUDE_DIR sparsehash/sparse_hash_set ${SPARSEHASH_ROOT_DIR}/include)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Sparsehash DEFAULT_MSG
		SPARSEHASH_INCLUDE_DIR
		)
	set(SPARSEHASH_INCLUDE_DIRS ${SPARSEHASH_INCLUDE_DIR})
	mark_as_advanced(SPARSEHASH_INCLUDE_DIRS)
endmacro()

macro(DO_FIND_SPARSEHASH_DOWNLOAD)
	set(SPARSEHASH_MAYBE_STATIC)
	if(SPARSEHASH_USE_STATIC_LIBS)
		set(SPARSEHASH_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Sparsehash
		GIT_REPOSITORY git@github.com:sparsehash/sparsehash.git
		GIT_TAG master
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND ./configure --prefix=${SPARSEHASH_ROOT_DIR}
		BUILD_COMMAND make
		BUILD_IN_SOURCE true
		INSTALL_COMMAND make install
		INSTALL_DIR ${SPARSEHASH_ROOT_DIR}
		)

	ExternalProject_Get_Property(Sparsehash INSTALL_DIR)
	set(SPARSEHASH_INCLUDE_DIR ${INSTALL_DIR}/include)
	
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Sparsehash DEFAULT_MSG
		SPARSEHASH_INCLUDE_DIR
		)
	set(SPARSEHASH_INCLUDE_DIRS ${SPARSEHASH_INCLUDE_DIR})
	mark_as_advanced(SPARSEHASH_INCLUDE_DIRS)
endmacro()

if(NOT SPARSEHASH_FOUND)
	DO_FIND_SPARSEHASH_ROOT()
endif()

if(NOT SPARSEHASH_FOUND)
	DO_FIND_SPARSEHASH_SYSTEM()
endif()

if(NOT SPARSEHASH_FOUND)
	DO_FIND_SPARSEHASH_DOWNLOAD()
endif()
