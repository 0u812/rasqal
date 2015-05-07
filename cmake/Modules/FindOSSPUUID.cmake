# Modified from: https://code.google.com/p/opencollada/source/browse/trunk/Externals/cmake-modules/FindOSSPUUID.cmake?r=779

# Try to find the OSSP UUID library
# Once done this will define
#
# OSSPUUID_FOUND - system has the OSSPUUID library
# OSSPUUID_INCLUDE_DIR - the OSSPUUID include directory
# OSSPUUID_LIBRARIES - The libraries needed to use OSSPUUID
# OSSPUUID_VERSION - The version of OSSPUUID
#
# Copyright (c) 2015, J Kyle Medley, github.com/0u812
# Copyright (c) 2006, Alexander Neundorf, <neundorf@kde.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.

if (OSSPUUID_INCLUDE_DIR AND OSSPUUID_LIBRARY)
  # Already in cache, be silent
  set(OSSPUUID_FIND_QUIETLY TRUE)
endif (OSSPUUID_INCLUDE_DIR AND OSSPUUID_LIBRARY)

# Check for pcre-config
find_program(OSSPUUID_CONFIG uuid-config)

if(OSSPUUID_CONFIG)
  execute_process(COMMAND ${OSSPUUID_CONFIG} --version OUTPUT_VARIABLE OSSPUUID_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REGEX REPLACE ".*([0-9]+)\\.([0-9]+)\\.([0-9]+).*" "\\1.\\2.\\3" OSSPUUID_VERSION ${OSSPUUID_VERSION})
  execute_process(COMMAND ${OSSPUUID_CONFIG} --libdir OUTPUT_VARIABLE OSSPUUID_LIBDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND ${OSSPUUID_CONFIG} --includedir OUTPUT_VARIABLE OSSPUUID_INCLUDE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND ${OSSPUUID_CONFIG} --libs OUTPUT_VARIABLE OSSPUUID_LIB_NAMES OUTPUT_STRIP_TRAILING_WHITESPACE)

  string(REGEX REPLACE "-l([^ ]+)[ ]*" "\\1;" OSSPUUID_LIB_NAMES ${OSSPUUID_LIB_NAMES})

  # Search for all libraries
  set(OSSPUUID_LIBRARIES "")
  foreach(libname ${OSSPUUID_LIB_NAMES})
    find_library(${libname}_LIBRARY NAMES ${libname} HINTS ${OSSPUUID_LIBDIR})
    if(${libname}_LIBRARY)
      list(APPEND OSSPUUID_LIBRARIES ${${libname}_LIBRARY})
    endif()

    mark_as_advanced(${libname}_LIBRARY)
  endforeach()

else()

  if (NOT WIN32)
    # use pkg-config to get the directories and then use these values
    # in the FIND_PATH() and FIND_LIBRARY() calls
    find_package(PkgConfig)
    pkg_check_modules(PC_OSSPUUID QUIET ossp-uuid)
    set(OSSPUUID_DEFINITIONS ${PC_OSSPUUID_CFLAGS_OTHER})
  endif()

  find_path(OSSPUUID_INCLUDE_DIR uuid.h
  HINTS ${PC_OSSPUUID_INCLUDEDIR} ${PC_OSSPUUID_INCLUDE_DIRS})

  find_library(OSSPUUID_LIBRARY NAMES ossp-uuid HINTS ${PC_OSSPUUID_LIBDIR} ${PC_OSSPUUID_LIBRARY_DIRS})

  set(OSSPUUID_LIBRARIES ${OSSPUUID_LIBRARY})

endif()

include(FindPackageHandleStandardArgs)

if(OSSPUUID_VERSION)
  find_package_handle_standard_args( OSSPUUID
    FOUND_VAR OSSPUUID_FOUND
    REQUIRED_VARS OSSPUUID_INCLUDE_DIR OSSPUUID_LIBRARIES
    VERSION_VAR OSSPUUID_VERSION)
else()
  find_package_handle_standard_args( OSSPUUID
    FOUND_VAR OSSPUUID_FOUND
    REQUIRED_VARS OSSPUUID_INCLUDE_DIR OSSPUUID_LIBRARIES )
endif()

mark_as_advanced(OSSPUUID_INCLUDE_DIR OSSPUUID_LIBRARIES OSSPUUID_LIBRARIES OSSPUUID_CONFIG)

