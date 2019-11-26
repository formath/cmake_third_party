###################################
# https://gist.github.com/Manu343726/ae02bff2b0097525045a37a7c10303c9
###################################

cmake_minimum_required(VERSION 3.4)
project(MyProject)

if(NOT MY_PROJECT_PROTOBUF_VERSION)
    set(MY_PROJECT_PROTOBUF_VERSION 2.6.1)
endif()

option(MY_PROJECT_SHARED_LIBS "Build proto modules as shared libraries" OFF)

message(STATUS "Google Protocol Buffers version: ${MY_PROJECT_PROTOBUF_VERSION}")

if(MY_PROJECT_SHARED_LIBS)
    message(STATUS "Building proto modules as SHARED libraries")
else()
    message(STATUS "Building proto modules as SHARED libraries")
endif()

include(ExternalProject)

# Downloads and builds a given protobuf version, generating a protobuf target
# with the include dir and binaries imported
macro(configure_protobuf VERSION)
    if(VERSION VERSION_LESS 3.0.0)
        set(protobufPackage "protobuf-${VERSION}.zip")
    else()
        set(protobufPackage "protobuf-cpp-${VERSION}.zip")
    endif()
    set(protobufPackageUrl "https://github.com/google/protobuf/releases/download/v${VERSION}/${protobufPackage}")
    set(protobufExternal protobuf-external)

    ExternalProject_Add(${protobufExternal}
        URL "${protobufPackageUrl}"
        CONFIGURE_COMMAND
            <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
        BUILD_COMMAND ${MAKE}
    )

    set(protobufBinaryDir  "${CMAKE_BINARY_DIR}/${protobufExternal}-prefix/bin")
    set(protobufLibraryDir "${CMAKE_BINARY_DIR}/${protobufExternal}-prefix/lib")
    set(protobufCompiler   "${protobufBinaryDir}/protoc")

    if(MY_PROJECT_SHARED_LIBS)
        set(protobufLibrary "${protobufLibraryDir}/libprotobuf.so")
    else()
        set(protobufLibrary "${protobufLibraryDir}/libprotobuf.a")
    endif()

    set(protobufIncludeDir "${CMAKE_BINARY_DIR}/${protobufExternal}-prefix/include")

    if(MY_PROJECT_SHARED_LIBS)
        set(libType SHARED)
    else()
        set(libType STATIC)
    endif()

    add_library(protobuf_imported ${libType} IMPORTED)
    add_dependencies(protobuf_imported ${protobufExternal})
    set_target_properties(protobuf_imported PROPERTIES
        IMPORTED_LOCATION "${protobufLibrary}"
    )

    add_library(protobuf INTERFACE)
    target_include_directories(protobuf INTERFACE "${protobufIncludeDir}")
    target_link_libraries(protobuf INTERFACE protobuf_imported)
endmacro()

#
# Use as follows:
#
# protobuf_generate_cpp(MyProtosLib myproto.proto myotherproto.proto)
#
# It generates a library target called "MyProtosLib" with the generated C++ code,
# and linked to the downloaded protobuf distribution
function(protobuf_generate_cpp LIBRARY)
    set(PROTOS ${ARGN})

    foreach(proto ${PROTOS})
        get_filename_component(PROTO_NAME "${proto}" NAME_WE)

        set(PROTO_HEADER "${PROTO_NAME}.pb.h")
        set(PROTO_SRC    "${PROTO_NAME}.pb.cc")

        message(STATUS "Protobuf ${proto} -> ${PROTO_SRC} ${PROTO_HEADER}")

        add_custom_command(
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${PROTO_SRC}"
                   "${CMAKE_CURRENT_BINARY_DIR}/${PROTO_HEADER}"
                   COMMAND LIBRARY_PATH=${protobufLibraryDir} ${protobufCompiler}
            ARGS --cpp_out ${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/${proto}
            WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${proto}"
            COMMENT "${proto} -> ${PROTO_SRC} ${PROTO_HEADER}"
        )

        list(APPEND SOURCES "${CMAKE_CURRENT_BINARY_DIR}/${PROTO_SRC}")
        list(APPEND HEADERS "${CMAKE_CURRENT_BINARY_DIR}/${PROTO_HEADER}")
    endforeach()



    if(MY_PROJECT_SHARED_LIBS)
        set(libType SHARED)
    else()
        set(libType)
    endif()

    add_library(${LIBRARY} ${libType} ${SOURCES} ${HEADERS})
    target_compile_options(${LIBRARY} PRIVATE -std=c++11)
    target_link_libraries(${LIBRARY} PUBLIC protobuf)
    target_include_directories(${LIBRARY} PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
endfunction()

configure_protobuf(${MY_PROJECT_PROTOBUF_VERSION})
