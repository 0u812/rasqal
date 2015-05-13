# Origin: https://code.google.com/p/opencollada/source/browse/trunk/Externals/cmake-modules/FindPCRE.cmake?r=779

# - Try to find the PCRE regular expression library
# Once done this will define
#
# PCRE_FOUND - system has the PCRE library
# PCRE_INCLUDE_DIR - the PCRE include directory
# PCRE_LIBRARIES - The libraries needed to use PCRE
# PCRE_VERSION - The version of PCRE
# PCRE_FLAGS   - Defined if pcre-config is available, missing otherwise
#
# Copyright (c) 2015, J Kyle Medley, github.com/0u812
# Copyright (c) 2006, Alexander Neundorf, <neundorf@kde.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the COPYING-CMAKE-SCRIPTS file at https://code.google.com/p/opencollada.

if (PCRE_INCLUDE_DIR AND PCRE_PCREPOSIX_LIBRARY AND PCRE_PCRE_LIBRARY)
  # Already in cache, be silent
  set(PCRE_FIND_QUIETLY TRUE)
endif (PCRE_INCLUDE_DIR AND PCRE_PCREPOSIX_LIBRARY AND PCRE_PCRE_LIBRARY)

# Check for pcre-config
find_program(PCRE_CONFIG pcre-config)

if(PCRE_CONFIG)
  execute_process(COMMAND ${PCRE_CONFIG} --version OUTPUT_VARIABLE PCRE_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND ${PCRE_CONFIG} --cflags OUTPUT_VARIABLE PCRE_FLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

mark_as_advanced(PCRE_CONFIG)

if (NOT WIN32)
  # use pkg-config to get the directories and then use these values
  # in the FIND_PATH() and FIND_LIBRARY() calls
  find_package(PkgConfig)
  pkg_check_modules(PC_PCRE QUIET libpcre)
  set(PCRE_DEFINITIONS ${PC_PCRE_CFLAGS_OTHER})
endif (NOT WIN32)

find_path(PCRE_INCLUDE_DIR pcre.h
HINTS ${PC_PCRE_INCLUDEDIR} ${PC_PCRE_INCLUDE_DIRS}
PATH_SUFFIXES pcre)

find_library(PCRE_PCRE_LIBRARY NAMES pcre HINTS ${PC_PCRE_LIBDIR} ${PC_PCRE_LIBRARY_DIRS})

find_library(PCRE_PCREPOSIX_LIBRARY NAMES pcreposix HINTS ${PC_PCRE_LIBDIR} ${PC_PCRE_LIBRARY_DIRS})

include(FindPackageHandleStandardArgs)

if(NOT WIN32)
  if(PCRE_VERSION)
    find_package_handle_standard_args( PCRE
      FOUND_VAR PCRE_FOUND
      REQUIRED_VARS PCRE_INCLUDE_DIR PCRE_PCRE_LIBRARY PCRE_PCREPOSIX_LIBRARY
      VERSION_VAR PCRE_VERSION)
  else()
    find_package_handle_standard_args( PCRE
      FOUND_VAR PCRE_FOUND
      REQUIRED_VARS PCRE_INCLUDE_DIR PCRE_PCRE_LIBRARY PCRE_PCREPOSIX_LIBRARY )
  endif()

  mark_as_advanced(PCRE_INCLUDE_DIR PCRE_LIBRARIES PCRE_PCREPOSIX_LIBRARY PCRE_PCRE_LIBRARY)
  set(PCRE_LIBRARIES ${PCRE_PCRE_LIBRARY} ${PCRE_PCREPOSIX_LIBRARY})
else()
  if(PCRE_VERSION)
    find_package_handle_standard_args( PCRE
      FOUND_VAR PCRE_FOUND
      REQUIRED_VARS PCRE_INCLUDE_DIR PCRE_PCRE_LIBRARY )
  else()
    find_package_handle_standard_args( PCRE
      FOUND_VAR PCRE_FOUND
      REQUIRED_VARS PCRE_INCLUDE_DIR PCRE_PCRE_LIBRARY
      VERSION_VAR PCRE_VERSION)
  endif()

  set(PCRE_LIBRARIES ${PCRE_PCRE_LIBRARY} )
  mark_as_advanced(PCRE_INCLUDE_DIR PCRE_LIBRARIES PCRE_PCRE_LIBRARY)
endif()