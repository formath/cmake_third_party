###################################
# https://stackoverflow.com/questions/28346530/cmake-automatic-boost-download-and-build-if-not-found
###################################

# - Find Boost
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

if(NOT Boost_FIND_COMPONENTS)
	message(FATAL_ERROR "No COMPONENTS specified for Boost")
endif()

set(BOOST_ROOT_DIR ${CMAKE_BINARY_DIR}/boost)
set(BOOST_USE_STATIC_LIBS false)

# Set the library prefix and library suffix properly.
if(BOOST_USE_STATIC_LIBS)
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

# Create a list(string) for the build command (e.g. --with-program_options;--with-system)
# and assigns it to BOOST_COMPONENTS_FOR_BUILD
foreach(component ${Boost_FIND_COMPONENTS})
	list(APPEND BOOST_COMPONENTS_FOR_BUILD --with-${component})
endforeach()

# Create a string for the first component (e.g. boost_program_options)
# and assigns it to Boost_FIND_COMPONENTS
list(GET Boost_FIND_COMPONENTS 0 BOOST_FIRST_COMPONENT)
set(BOOST_FIRST_COMPONENT "boost_${BOOST_FIRST_COMPONENT}")

include(FindPackageHandleStandardArgs)

macro(DO_FIND_BOOST_SYSTEM)
	find_path(BOOST_INCLUDE_DIR boost/config.hpp
		PATHS /usr/local/include /usr/include
		)
  message("BOOST_INCLUDE_DIR: " ${BOOST_INCLUDE_DIR})
	find_library(BOOST_LIBRARY
		NAMES ${BOOST_FIRST_COMPONENT}
		PATHS /usr/local/lib /usr/local/lib64 /usr/lib /usr/lib64
		)
  message("BOOST_LIBRARY: " ${BOOST_LIBRARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Boost DEFAULT_MSG
		BOOST_INCLUDE_DIR BOOST_LIBRARY
		)
	set(BOOST_LIBRARIES ${BOOST_LIBRARY})
	set(BOOST_INCLUDE_DIRS ${BOOST_INCLUDE_DIR})
	get_filename_component(BOOST_LIB_DIR ${BOOST_LIBRARY} DIRECTORY)
	set(BOOST_LIB_DIRS ${BOOST_LIB_DIR})
	mark_as_advanced(BOOST_LIBRARIES BOOST_INCLUDE_DIRS BOOST_LIB_DIRS)
endmacro()

macro(DO_FIND_BOOST_ROOT)
	if(NOT BOOST_ROOT_DIR)
		message(STATUS "BOOST_ROOT_DIR is not defined, using binary directory.")
		set(BOOST_ROOT_DIR ${CURRENT_CMAKE_BINARY_DIR} CACHE PATH "")
	endif()

	find_path(BOOST_INCLUDE_DIR boost/config.hpp ${BOOST_ROOT_DIR}/include)
  message("BOOST_INCLUDE_DIR: " ${BOOST_INCLUDE_DIR})
	find_library(BOOST_LIBRARY ${BOOST_FIRST_COMPONENT} HINTS ${BOOST_ROOT_DIR}/lib)
  message("BOOST_LIBRARY: " ${BOOST_LIBRARY})
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Boost DEFAULT_MSG
		BOOST_INCLUDE_DIR BOOST_LIBRARY
		)
	set(BOOST_LIBRARIES ${BOOST_LIBRARY})
	set(BOOST_INCLUDE_DIRS ${BOOST_INCLUDE_DIR})
	get_filename_component(BOOST_LIB_DIR ${BOOST_LIBRARY} DIRECTORY)
	set(BOOST_LIB_DIRS ${BOOST_LIB_DIR})
	mark_as_advanced(BOOST_LIBRARIES BOOST_INCLUDE_DIRS BOOST_LIB_DIRS)
endmacro()

macro(DO_FIND_BOOST_DOWNLOAD)
	set(BOOST_MAYBE_STATIC)
	if(BOOST_USE_STATIC_LIBS)
		set(BOOST_MAYBE_STATIC "link=static")
	endif()

	include(ExternalProject)
	ExternalProject_Add(
		Boost
		URL https://dl.bintray.com/boostorg/release/1.71.0/source/boost_1_71_0.tar.gz
    URL_HASH SHA256=96b34f7468f26a141f6020efb813f1a2f3dfb9797ecf76a7d7cbd843cc95f5bd
		UPDATE_COMMAND ""
		CONFIGURE_COMMAND ./bootstrap.sh --prefix=${BOOST_ROOT_DIR}
		BUILD_COMMAND ./b2 ${BOOST_MAYBE_STATIC} --prefix=${BOOST_ROOT_DIR} ${BOOST_COMPONENTS_FOR_BUILD} install
		BUILD_IN_SOURCE true
		INSTALL_COMMAND ""
		INSTALL_DIR ${BOOST_ROOT_DIR}
		)

	ExternalProject_Get_Property(Boost INSTALL_DIR)
	set(BOOST_INCLUDE_DIR ${INSTALL_DIR}/include)
  message("BOOST_INCLUDE_DIR: " ${BOOST_INCLUDE_DIR})
  set(BOOST_LIBRARY "")
  foreach(component ${Boost_FIND_COMPONENTS})
    list(APPEND BOOST_LIBRARY ${INSTALL_DIR}/lib/${LIBRARY_PREFIX}boost_${component}${LIBRARY_SUFFIX})
    list(APPEND BOOST_LIBRARY " ")
  endforeach()
  message("BOOST_LIBRARY: " ${BOOST_LIBRARY})

	FIND_PACKAGE_HANDLE_STANDARD_ARGS(Boost DEFAULT_MSG
		BOOST_INCLUDE_DIR BOOST_LIBRARY
		)
  set(BOOST_LIBRARIES ${BOOST_LIBRARY})
  set(BOOST_INCLUDE_DIRS ${BOOST_INCLUDE_DIR})
  get_filename_component(BOOST_LIB_DIR ${BOOST_LIBRARY} DIRECTORY)
  set(BOOST_LIB_DIRS ${BOOST_LIB_DIR})
  mark_as_advanced(BOOST_LIBRARIES BOOST_INCLUDE_DIRS BOOST_LIB_DIRS)
endmacro()

if(NOT BOOST_FOUND)
	DO_FIND_BOOST_ROOT()
endif()

if(NOT BOOST_FOUND)
	DO_FIND_BOOST_SYSTEM()
endif()

if(NOT BOOST_FOUND)
	DO_FIND_BOOST_DOWNLOAD()
endif()
