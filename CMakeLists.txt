# rasqal/CMakeLists.txt
#
# This file is the root of the Rasqal CMake build system
#
# Authors:
# * J Kyle Medley
#

cmake_minimum_required(VERSION 3.2)

# Path to find-modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

set(RASQAL_VERSION_MAJOR  0)
set(RASQAL_VERSION_MINOR  9)
set(RASQAL_VERSION_RELEASE  34)

set(VERSION "${RASQAL_VERSION_MAJOR}.${RASQAL_VERSION_MINOR}.${RASQAL_VERSION_RELEASE}")
math(EXPR RASQAL_VERSION_DECIMAL "${RASQAL_VERSION_MAJOR} * 10000 + ${RASQAL_VERSION_MINOR} * 100 + ${RASQAL_VERSION_RELEASE}")

project(Rasqal C)

set(ENABLE_FULL_RPATH 1 CACHE BOOL "Full rpath in linking phase (makes lib paths hardcoded)")

# http://www.cmake.org/Wiki/CMake_RPATH_handling
if(ENABLE_FULL_RPATH)
  set(CMAKE_SKIP_BUILD_RPATH  FALSE)

  set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

  list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
  if("${isSystemDir}" STREQUAL "-1")
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
  endif("${isSystemDir}" STREQUAL "-1")
endif()

# To include generated files
set(CMAKE_INCLUDE_CURRENT_DIR 1)

if(NOT EXISTS "${CMAKE_SOURCE_DIR}/src/rasqal_general.c")
  # Wrong source dir - bail
  error(FATAL "src/rasqal_general.c not found within source directory - wrong source path specified?")
endif()

# ** Flex/Bison **

# Recruit flex (http://flex.sourceforge.net/)

set(FLEX_MIN_VERSION 2.5.19)
set(FLEX_REC_VERSION 2.5.36)

find_package(FLEX ${FLEX_MIN_VERSION} REQUIRED)

execute_process(COMMAND ${FLEX_EXECUTABLE} --version OUTPUT_VARIABLE FLEX_VERSION_DEC)
string(REGEX REPLACE "[\\w]* ([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\1" FLEX_VERSION_DEC1 ${FLEX_VERSION_DEC})
string(REGEX REPLACE "[\\w]* ([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\2" FLEX_VERSION_DEC2 ${FLEX_VERSION_DEC})
string(REGEX REPLACE "[\\w]* ([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\3" FLEX_VERSION_DEC3 ${FLEX_VERSION_DEC})
math(EXPR FLEX_VERSION_DECIMAL "${FLEX_VERSION_DEC1} * 10000 + ${FLEX_VERSION_DEC2} * 100 + ${FLEX_VERSION_DEC3}")

# Recruit GNU Bison ver 3 or later (http://www.gnu.org/software/bison/)
# Note: if you have Bison v<3 on your system and CMake finds it first, you will
# have to pass -DBISON_EXECUTABLE=/path/to/bison-3.0 to CMake on the command line
find_package(BISON 3 REQUIRED)

# Recruit Perl 5
find_package(Perl 5 REQUIRED)

include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckFunctionExists)

# Check standard headers
CHECK_INCLUDE_FILE(errno.h    HAVE_ERRNO_H)
CHECK_INCLUDE_FILE(stddef.h   HAVE_STDDEF_H)
CHECK_INCLUDE_FILE(stdlib.h   HAVE_STDLIB_H)
CHECK_INCLUDE_FILE(stdint.h   HAVE_STDINT_H)
CHECK_INCLUDE_FILE(unistd.h   HAVE_UNISTD_H)
CHECK_INCLUDE_FILE(string.h   HAVE_STRING_H)
CHECK_INCLUDE_FILE(strings.h  HAVE_STRINGS_H)
CHECK_INCLUDE_FILE(getopt.h   HAVE_GETOPT_H)
CHECK_INCLUDE_FILE(regex.h    HAVE_REGEX_H)
CHECK_INCLUDE_FILE(sys/time.h HAVE_SYS_TIME_H)
CHECK_INCLUDE_FILE(time.h     HAVE_TIME_H)
CHECK_INCLUDE_FILE(math.h     HAVE_MATH_H)
CHECK_INCLUDE_FILE(limits.h   HAVE_LIMITS_H)
CHECK_INCLUDE_FILE(float.h    HAVE_FLOAT_H)

CHECK_INCLUDE_FILES("sys/time.h;time.h" TIME_WITH_SYS_TIME)

set(RASQAL_LIBTOOL_VERSION "3:0:0")

CHECK_FUNCTION_EXISTS(strcasecmp  HAVE_STRCASECMP)
CHECK_FUNCTION_EXISTS(getopt      HAVE_GETOPT)
CHECK_FUNCTION_EXISTS(timegm      HAVE_TIMEGM)

CHECK_FUNCTION_EXISTS(access HAVE_ACCESS)
CHECK_FUNCTION_EXISTS(_access HAVE__ACCESS)
CHECK_FUNCTION_EXISTS(getopt_long HAVE_GETOPT_LONG)
CHECK_FUNCTION_EXISTS(gettimeofday HAVE_GETTIMEOFDAY)

CHECK_FUNCTION_EXISTS(isascii    HAVE_ISASCII)
CHECK_FUNCTION_EXISTS(setjmp     HAVE_SETJMP)
CHECK_FUNCTION_EXISTS(snprintf   HAVE_SNPRINTF)
CHECK_FUNCTION_EXISTS(_snprintf  HAVE__SNPRINTF)
CHECK_FUNCTION_EXISTS(stat       HAVE_STAT)
CHECK_FUNCTION_EXISTS(strcasecmp HAVE_STRCASECMP)
CHECK_FUNCTION_EXISTS(stricmp    HAVE_STRICMP)
CHECK_FUNCTION_EXISTS(_stricmp   HAVE__STRICMP)
CHECK_FUNCTION_EXISTS(strtok_r   HAVE_STRTOK_R)
CHECK_FUNCTION_EXISTS(vasprintf  HAVE_VASPRINTF)
CHECK_FUNCTION_EXISTS(vsnprintf  HAVE_VSNPRINTF)
# Windows only version
CHECK_FUNCTION_EXISTS(gettimeofday HAVE_GETTIMEOFDAY)

# Set to true when Raptor and Rasqal are being built together
set(IMPORT_RAPTOR_TARGET FALSE)

# ** Raptor **
# Import raptor as a target
find_package(Raptor2 2.0.15 REQUIRED CONFIG)

# For diagnostics only
get_property(RAPTOR_LOCATION TARGET raptor2 PROPERTY LOCATION)

# ** Jing **

find_program(JING jing)
if(NOT JING STREQUAL "JING-NOTFOUND")
  set(HAVE_JING TRUE)
endif(NOT JING STREQUAL "JING-NOTFOUND")

# ** PCRE **
find_package(PCRE 3.9)

if(PCRE_FOUND)
  set(WITH_PCRE TRUE CACHE BOOL "Enable features which use Perl-compatible regular expressions")
  set(RASQAL_REGEX_PCRE TRUE)
  include_directories(${PCRE_INCLUDE_DIR})
else()
  set(WITH_PCRE FALSE CACHE BOOL "Enable features which use Perl-compatible regular expressions")
endif()

# NOTE: CMake build system currently does not support use of POSIX regex library

# ** Digest library **

find_package(MHASH)

find_package(GCrypt)

if(MHASH_FOUND)
  set(RASQAL_DIGEST_MHASH TRUE)
  include_directories(${MHASH_INCLUDE_DIR})
elseif(GCRYPT_FOUND)
  set(RASQAL_DIGEST_GCRYPT TRUE)
  include_directories(${GCRYPT_INCLUDE_DIRS})
else()
  set(RASQAL_DIGEST_INTERNAL TRUE)
endif()

configure_file(
  src/rasqal_config_cmake.h.in
  src/rasqal_config.h
  @ONLY
)

# ** UUID libraries **


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
message( "  *** Bison                       ${BISON_EXECUTABLE}")
message( "  *** Perl                        ${PERL_EXECUTABLE}")
message( "    * Jing                        ${JING}")
message( "  *** Raptor                      ${RAPTOR_LOCATION}")
message( "  *** Raptor includes             ${Raptor2_INCLUDE_DIR}")
message( "    * Using PCRE?                 ${WITH_PCRE}")
if(WITH_PCRE)
  message( "    *** PCRE libs                   ${PCRE_LIBRARIES}")
  message( "    *** PCRE includes               ${PCRE_INCLUDE_DIR}")
endif()