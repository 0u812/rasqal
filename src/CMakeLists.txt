# rasqal/src/CMakeLists.txt
#
# CMake build system for the Rasqal RDF query language library
#
# Copyright (C) 2015, J Kyle Medley, github.com/0u812
# Copyright (C) 2003-2010, David Beckett http://www.dajobe.org/
# Copyright (C) 2003-2005, University of Bristol, UK http://www.bristol.ac.uk/
#
# This package is Free Software and part of Redland http://librdf.org/
#
# It is licensed under the following three licenses as alternatives:
#   1. GNU Lesser General Public License (LGPL) V2.1 or any newer version
#   2. GNU General Public License (GPL) V2 or any newer version
#   3. Apache License, V2.0 or any newer version
#
# You may not use this file except in compliance with at least one of
# the above three licenses.
#
# See LICENSE.html or LICENSE.txt at the top of this package for the
# complete terms and further detail along with the license texts for
# the licenses in COPYING.LIB, COPYING and LICENSE-2.0.txt respectively.
#

set(RASQAL_SOURCES
  rasqal_algebra.c
  rasqal_expr.c rasqal_expr_evaluate.c
  rasqal_expr_datetimes.c rasqal_expr_numerics.c rasqal_expr_strings.c
  rasqal_general.c rasqal_query.c rasqal_query_results.c
  rasqal_engine.c rasqal_raptor.c rasqal_literal.c rasqal_formula.c
  rasqal_graph_pattern.c rasqal_map.c rasqal_feature.c
  rasqal_result_formats.c rasqal_xsd_datatypes.c rasqal_decimal.c
  rasqal_datetime.c rasqal_rowsource.c rasqal_format_sparql_xml.c
  rasqal_variable.c rasqal_rowsource_empty.c rasqal_rowsource_union.c
  rasqal_rowsource_rowsequence.c rasqal_query_transform.c rasqal_row.c
  rasqal_engine_algebra.c rasqal_triples_source.c
  rasqal_rowsource_triples.c rasqal_rowsource_filter.c
  rasqal_rowsource_sort.c rasqal_engine_sort.c
  rasqal_rowsource_project.c rasqal_rowsource_join.c
  rasqal_rowsource_graph.c rasqal_rowsource_distinct.c
  rasqal_rowsource_groupby.c rasqal_rowsource_aggregation.c
  rasqal_rowsource_having.c rasqal_rowsource_slice.c
  rasqal_rowsource_bindings.c rasqal_rowsource_service.c
  rasqal_row_compatible.c rasqal_format_table.c rasqal_query_write.c
  rasqal_format_json.c rasqal_format_sv.c rasqal_format_html.c
  rasqal_format_rdf.c
  rasqal_rowsource_assignment.c rasqal_update.c
  rasqal_triple.c rasqal_data_graph.c rasqal_prefix.c
  rasqal_solution_modifier.c rasqal_projection.c rasqal_bindings.c
  rasqal_service.c
  rasqal_dataset.c
  rasqal_random.c
  rasqal_digest.c
  rasqal_iostream.c
  rasqal_regex.c
  snprintf.c
  rasqal_double.c
  rasqal_ntriples.c
  rasqal_results_compare.c
  ssort.h)

if(RASQAL_QUERY_SPARQL)
  set(SPARQL_PARSER_SRC_FILES sparql_lexer.c sparql_lexer.h
    sparql_parser.c sparql_parser.h sparql_common.h)

  set(RASQAL_SOURCES ${RASQAL_SOURCES} ${SPARQL_PARSER_SRC_FILES})

  set_source_files_properties(${SPARQL_PARSER_SRC_FILES} PROPERTIES GENERATED TRUE)

  # SPARQL lexer/parser generation

  # Generate the SPARQL lexer
  add_custom_target(sparql_flex_tgt DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/sparql_lexer.t)
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/sparql_lexer.t
    COMMAND ${FLEX_EXECUTABLE} -o ${CMAKE_CURRENT_BINARY_DIR}/sparql_lexer.t ${CMAKE_CURRENT_SOURCE_DIR}/sparql_lexer.l
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/sparql_lexer.l)

  add_custom_target(sparql_lexer_tgt DEPENDS sparql_flex_tgt)
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/sparql_lexer.c
    COMMAND ${PERL_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/fix-flex.pl ${CMAKE_CURRENT_BINARY_DIR}/sparql_lexer.t > ${CMAKE_CURRENT_BINARY_DIR}/sparql_lexer.c
    DEPENDS sparql_flex_tgt)

  # Generate the sparql parser
  add_custom_target(sparql_tables_tgt DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.tab.c)
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.tab.c
    COMMAND ${BISON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/sparql_parser.y
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/sparql_parser.y)

  add_custom_target(sparql_parser_tgt DEPENDS sparql_tables_tgt ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.c ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.h)
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.c
    COMMAND ${PERL_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/fix-bison.pl ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.tab.c > ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.c
    DEPENDS sparql_tables_tgt)
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.h COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.tab.h ${CMAKE_CURRENT_BINARY_DIR}/sparql_parser.h)
endif()

if(STRCASECMP)
  set(RASQAL_SOURCES ${RASQAL_SOURCES} strcasecmp.c)
endif()

if(TIMEGM)
  set(RASQAL_SOURCES ${RASQAL_SOURCES} timegm.c)
endif()

if(GETTIMEOFDAY)
  set(RASQAL_SOURCES ${RASQAL_SOURCES} gettimeofday.c)
endif()

if(RASQAL_SORT)
  set(RASQAL_SOURCES ${RASQAL_SOURCES} rasqal_sort.c)
endif()

if(RASQAL_DIGEST_INTERNAL)
  set(RASQAL_SOURCES ${RASQAL_SOURCES} rasqal_digest_md5.c rasqal_digest_sha1.c)
endif()

include_directories(${RASQAL_CORE_INCLUDES})

# Git version info

set(RASQAL_SOURCES ${RASQAL_SOURCES} git-version.h)

set_source_files_properties(git-version.h PROPERTIES GENERATED TRUE)

configure_file(git-version.h.in git-version.h @ONLY)

# libsv

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DSV_CONFIG")
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../libsv)

# libmtwist

if(RANDOM_ALGO_MTWIST)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DMTWIST_CONFIG")
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../libmtwist)
endif()

# Build the Rasqal shared library
if(RASQAL_BUILD_SHARED_LIB)
  add_library(rasqal SHARED ${RASQAL_SOURCES})

  target_link_libraries(rasqal raptor2 sv ${RASQAL_EXTERNAL_LIBS})
  if(RANDOM_ALGO_MTWIST)
    target_link_libraries(rasqal mtwist)
  endif()

  set_target_properties (rasqal
    PROPERTIES
    VERSION ${RASQAL_VERSION})
endif()

# Build the Rasqal static library
if(RASQAL_BUILD_STATIC_LIB)
  add_library(rasqal-static SHARED ${RASQAL_SOURCES})

  target_link_libraries(rasqal-static ${RASQAL_EXTERNAL_LIBS})

  set_target_properties (rasqal-static
    PROPERTIES
    VERSION ${RASQAL_VERSION})
endif()

# ** Tests ** ------------------------------

if(RASQAL_QUERY_SPARQL)
  add_executable(sparql_lexer_test sparql_lexer.c)
  add_test(NAME sparql_lexer_test COMMAND sparql_lexer_test)
  set_target_properties(sparql_lexer_test PROPERTIES COMPILE_FLAGS "-DSTANDALONE")
  target_link_libraries(sparql_lexer_test rasqal)
endif()