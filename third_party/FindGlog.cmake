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

set(GLOG_ROOT_DIR ${CMAKE_BINARY_DIR}/glog)
set(GLOG_USE_STATIC_LIBS false)

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
	message("GLOG_INCLUDE_DIR: " ${GLOG_INCLUDE_DIR})
	find_library(GLOG_LIBRARY
		NAMES glog
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
	message("GLOG_LIBRARY: " ${GLOG_LIBRARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Glog DEFAULT_MSG
		GLOG_INCLUDE_DIR GLOG_LIBRARY
		)
	set(GLOG_LIBRARIES ${GLOG_LIBRARY})
	set(GLOG_INCLUDE_DIRS ${GLOG_INCLUDE_DIR})
	get_filename_component(GLOG_LIB_DIR ${GLOG_LIBRARY} DIRECTORY)
	set(GLOG_LIB_DIRS ${GLOG_LIB_DIR})
	mark_as_advanced(GLOG_LIBRARIES GLOG_INCLUDE_DIRS GLOG_LIB_DIRS)
endmacro()

macro(DO_FIND_GLOG_ROOT)
	if(NOT GLOG_ROOT_DIR)
		message(STATUS "GLOG_ROOT_DIR is not defined, using binary directory.")
		set(GLOG_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_path(GLOG_INCLUDE_DIR glog/logging.h ${GLOG_ROOT_DIR}/include)
	message("GLOG_INCLUDE_DIR: " ${GLOG_INCLUDE_DIR})
	find_library(GLOG_LIBRARY glog HINTS ${GLOG_ROOT_DIR}/lib)
	message("GLOG_LIBRARY: " ${GLOG_LIBRARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Glog DEFAULT_MSG
		GLOG_INCLUDE_DIR GLOG_LIBRARY
		)
	set(GLOG_LIBRARIES ${GLOG_LIBRARY})
	set(GLOG_INCLUDE_DIRS ${GLOG_INCLUDE_DIR})
	get_filename_component(GLOG_LIB_DIR ${GLOG_LIBRARY} DIRECTORY)
	set(GLOG_LIB_DIRS ${GLOG_LIB_DIR})
	mark_as_advanced(GLOG_LIBRARIES GLOG_INCLUDE_DIRS GLOG_LIB_DIRS)
endmacro()

macro(DO_FIND_GLOG_DOWNLOAD)
	set(GLOG_MAYBE_STATIC)
	if(GLOG_USE_STATIC_LIBS)
		set(GLOG_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Glog
		URL https://github.com/google/glog/archive/v0.3.5.zip
		URL_HASH SHA256=267103f8a1e9578978aa1dc256001e6529ef593e5aea38193d31c2872ee025e8
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND ./configure --prefix=${GLOG_ROOT_DIR}
		BUILD_COMMAND make
		BUILD_IN_SOURCE true
		INSTALL_COMMAND make install
		INSTALL_DIR ${GLOG_ROOT_DIR}
		)

	#export CPPFLAGS="-I${GFLAGS_ROOT_DIR}/include" && export LDFLAGS="-L${GFLAGS_ROOT_DIR}/lib" 
	ExternalProject_Get_Property(Glog INSTALL_DIR)
	set(GLOG_INCLUDE_DIR ${INSTALL_DIR}/include)
	message("GLOG_INCLUDE_DIR: " ${GLOG_INCLUDE_DIR})
	set(GLOG_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}glog${LIBRARY_SUFFIX})
	message("GLOG_LIBRARY: " ${GLOG_LIBRARY})

	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Glog DEFAULT_MSG
		GLOG_INCLUDE_DIR GLOG_LIBRARY
		)
	set(GLOG_LIBRARIES ${GLOG_LIBRARY})
	set(GLOG_INCLUDE_DIRS ${GLOG_INCLUDE_DIR})
	get_filename_component(GLOG_LIB_DIR ${GLOG_LIBRARY} DIRECTORY)
	set(GLOG_LIB_DIRS ${GLOG_LIB_DIR})
	mark_as_advanced(GLOG_LIBRARIES GLOG_INCLUDE_DIRS GLOG_LIB_DIRS)
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
