# rasqal/CMakeLists.txt
#
# This file is the root of the Rasqal CMake build system
#
# Authors:
# * J Kyle Medley
#

cmake_minimum_required(VERSION 3.2)

set(RASQAL_VERSION_MAJOR  0)
set(RASQAL_VERSION_MINOR  9)
set(RASQAL_VERSION_RELEASE  34)

SET(VERSION "${RASQAL_VERSION_MAJOR}.${RASQAL_VERSION_MINOR}.${RASQAL_VERSION_RELEASE}")
MATH(EXPR RASQAL_VERSION_DECIMAL "${RASQAL_VERSION_MAJOR} * 10000 + ${RASQAL_VERSION_MINOR} * 100 + ${RASQAL_VERSION_RELEASE}")

project(Rasqal C)

# To include generated files
set(CMAKE_INCLUDE_CURRENT_DIR 1)

if(NOT EXISTS "${CMAKE_SOURCE_DIR}/src/rasqal_general.c")
  # Wrong source dir - bail
  error(FATAL "src/rasqal_general.c not found within source directory - wrong source path specified?")
endif()

configure_file(
  src/rasqal_config_cmake.h.in
  src/rasqal_config.h
  @ONLY
)

set(FLEX_MIN_VERSION 2.5.19)
set(FLEX_REC_VERSION 2.5.36)

find_package(FLEX ${FLEX_MIN_VERSION} REQUIRED)

execute_process(COMMAND ${FLEX_EXECUTABLE} --version OUTPUT_VARIABLE FLEX_VERSION_DEC)
string(REGEX REPLACE "[\\w]* ([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\1" FLEX_VERSION_DEC1 ${FLEX_VERSION_DEC})
string(REGEX REPLACE "[\\w]* ([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\2" FLEX_VERSION_DEC2 ${FLEX_VERSION_DEC})
string(REGEX REPLACE "[\\w]* ([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\3" FLEX_VERSION_DEC3 ${FLEX_VERSION_DEC})
MATH(EXPR FLEX_VERSION_DECIMAL "${FLEX_VERSION_DEC1} * 10000 + ${FLEX_VERSION_DEC2} * 100 + ${FLEX_VERSION_DEC3}")

message(STATUS "
################################################################
Rasqal Configuration Summary
################################################################

    http://librdf.org/rasqal/

    Configured on host $ENV{COMPUTERNAME} ${HOSTNAME}
      host OS                   ${CMAKE_SYSTEM_NAME}
      host architecture         ${CMAKE_SYSTEM_PROCESSOR}

    General flags:
      CC                        ${CMAKE_C_COMPILER}
      CXX (not used)            ${CMAKE_CXX_COMPILER}
      CFLAGS                    ${CMAKE_C_FLAGS}
      CXXFLAGS                  ${CMAKE_CXX_FLAGS}
      LDFLAGS                   ${CMAKE_EXE_LINKER_FLAGS}

    Installation prefix:        ${CMAKE_INSTALL_PREFIX}

    Dependencies (packages marked with *** are required):
    "
)

message( "  *** Flex                        ${FLEX_EXECUTABLE}")