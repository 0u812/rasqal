/* -*- Mode: c; c-basic-offset: 2 -*-
 *
 * win32_config.h - Rasqal WIN32 hard-coded config
 *
 * $Id$
 *
 * Copyright (C) 2004-2005, David Beckett http://purl.org/net/dajobe/
 * Institute for Learning and Research Technology http://www.ilrt.bristol.ac.uk/
 * University of Bristol, UK http://www.bristol.ac.uk/
 * 
 * This package is Free Software and part of Redland http://librdf.org/
 * 
 * It is licensed under the following three licenses as alternatives:
 *   1. GNU Lesser General Public License (LGPL) V2.1 or any newer version
 *   2. GNU General Public License (GPL) V2 or any newer version
 *   3. Apache License, V2.0 or any newer version
 * 
 * You may not use this file except in compliance with at least one of
 * the above three licenses.
 * 
 * See LICENSE.html or LICENSE.txt at the top of this package for the
 * complete terms and further detail along with the license texts for
 * the licenses in COPYING.LIB, COPYING and LICENSE-2.0.txt respectively.
 * 
 */


#ifndef WIN32_CONFIG_H
#define WIN32_CONFIG_H


#ifdef __cplusplus
extern "C" {
#endif

#define WIN32_LEAN_AND_MEAN 1

/* getopt is not in standard win32 C library - define if we have it */
/* #define HAVE_GETOPT_H 1 */

#define HAVE_STDLIB_H 1

#define HAVE_STRICMP 1

/* MS names for these functions */
#define vsnprintf _vsnprintf
#define snprintf _snprintf
#define access _access
#define stricmp _stricmp
#define strnicmp _strnicmp

#define HAVE_C99_VSNPRINTF 1

/* for access() which is POSIX but doesn't seem to have the defines in VC */
#ifndef R_OK
#define R_OK 4
#endif

/* __func__ doesn't exist in Visual Studio 6 */
#define __func__ ""

/* 
 * Defines that come from config.h
 */

/* Release version as a decimal */
#define RASQAL_VERSION_DECIMAL 907

/* Major version number */
#define RASQAL_VERSION_MAJOR 0

/* Minor version number */
#define RASQAL_VERSION_MINOR 9

/* Release version number */
#define RASQAL_VERSION_RELEASE 7

/* Version number of package */
#define VERSION "0.9.7"

#include <windows.h>
#include <io.h>
#include <memory.h>

/* bison: output uses ERROR in an enum which breaks if this is defined */
#ifdef ERROR
#undef ERROR
#endif

/* flex: const is available */
#define YY_USE_CONST

#undef RASQAL_INLINE
#define RASQAL_INLINE

/* Building RDQL query */
#define RASQAL_QUERY_RDQL 1

/* Building SPARQL query */
#define RASQAL_QUERY_SPARQL 1


#ifdef __cplusplus
}
#endif

#endif
