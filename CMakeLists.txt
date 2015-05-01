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

if(NOT EXISTS "${CMAKE_SOURCE_DIR}/src/rasqal_general.c")
  # Wrong source dir - bail
  error(FATAL "src/rasqal_general.c not found within source directory - wrong source path specified?")
endif()

configure_file(
  src/rasqal_config_cmake.h.in
  src/rasqal_config.h
  @ONLY
)