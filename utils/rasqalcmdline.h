/* -*- Mode: c; c-basic-offset: 2 -*-
 *
 * rasqalcmdline.h - Rasqal command line utility functions
 *
 * Copyright (C) 2013, David Beckett http://www.dajobe.org/
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

#ifndef RASQAL_CMDLINE_H
#define RASQAL_CMDLINE_H

unsigned char* rasqal_cmdline_read_file_fh(const char* program, FILE* fh, const char* filename, const char* label, size_t* len_p);

unsigned char* rasqal_cmdline_read_file_string(const char* program, const char* filename,  const char* label, size_t* len_p);

#endif