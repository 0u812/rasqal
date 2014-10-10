#!/usr/bin/perl
#
# Format output generated by flex 2.5.31
#
# Usage:
#  flex -o$output $input
#  perl fix-flex $output > $tmp
#  mv $tmp $output
#
# (C) Copyright 2004-2014 Dave Beckett http://www.dajobe.org/
# (C) Copyright 2004 University of Bristol
#

my $line_offset = 1; # #line directives always refer to the NEXT line

print <<'EOT';
#ifdef HAVE_CONFIG_H
#include <rasqal_config.h>
#endif

#ifdef WIN32
#include <win32_rasqal_config.h>
#endif

EOT
$line_offset += 8; # added 8 lines above to output

my $debug = 0;

# Lexer symbol prefix such as 'turtle_lexer_'
my $prefix = undef;
# Current function or undef if out of function
my $cur_function = undef;
# State for current function for rules to use.
my(%fn_state);

while(<>) {
  # find lexer prefix
  if(!defined($prefix) && /^void\s*(.+?)restart\s*\(.*;$/) {
    $prefix = $1;
    warn "$.: Lexer prefix $prefix\n"
	if $debug > 0;
  }

  # Remove generated yy_fatal_error declaration and definition to avoid warnings about unused/non-defined static function
  # declaration
  if(/^static void yy_fatal_error\s*\(.*\)\s*\;\s*$/) {
    $line_offset--; # skipped 1 line
    next;
  }
  # definition
  if(/^static void yy_fatal_error\s*\(.*\)\s*[^\;]\s*$/) {
    do {
      $_=<>;
      $line_offset--; # skipped 1 line
    } while(!/^}/);
    $line_offset--; # skipped 1 line
    next;
  }

  # Replace calls to yy_fatal_error("msg", yyscanner) to YY_FATAL_ERROR("msg") macro
  s/(^\s*)yy_fatal_error\s*\(\s*(\".*\")\s*,\s*yyscanner\s*\)/$1YY_FATAL_ERROR($2)/;

  # flex has %option nounistd however it does not work in 2.5.31
  # It is safe to add yet another wrapper. 
  if(m%^(\#include \<unistd.h\>)$%) {
    $_=<<"EOT";
#ifndef YY_NO_UNISTD_H
$1
#endif
EOT
    $line_offset += 2; # added 2 lines to output
  }

  # Fix .[ch] line references because we have added lines to it
  my $line = $. + $line_offset;
  s/^#line \d+ (\".*\.[ch]\")/#line $line $1/;

  # Fix signed / unsigned comparison gcc 4.x warning:
  #   int n : in the macro YY_INPUT definition
  #   (size_t)num_to_read : which is silly since num_to_read is an int!
  s/yyg->yy_n_chars, \(size_t\) num_to_read \)/yyg->yy_n_chars, num_to_read \)/;


  # Match prefixed functions and a couple of static ones starting yy_
  if(!defined($cur_function) && /^.*?((?:${prefix}|yy_)\w+)\s+\((.*)$/) {
    my($f,$rest)=($1,$2);
    if($rest !~ /;$/) {
      $cur_function=$1;
      warn "$.: Now in $cur_function: $_\n"
	  if $debug > 1;
      %fn_state=();
    }
  } elsif(defined($cur_function) && /^\}/) {
    warn "$.: End of $cur_function\n"
	if $debug > 1;
    $cur_function = undef;
    %fn_state=();
  }

  # Fix declaration of signed 'i' operating over range of yy_size_t
  if($cur_function eq $prefix."_scan_bytes") {
    s/int i;/yy_size_t i;/;
  }

  # Add $prefix_cleanup() call at the end of $prefix_lex_destroy()
  # find the start of lex_destroy function definition and capture prefix
  # look for lexer_free(yyscanner, yyscanner) statement within the function and place the cleanup call before it
  if($cur_function eq $prefix."lex_destroy") {
    if(/(^\s*)(${prefix}free\s*\(\s*yyscanner\s*,\s*yyscanner\s*\)\s*\;)\s*$/) {
      $_=<<"EOT";
$1/* clean up leaks if any before freeing yyscanner */
$1${prefix}cleanup(yyscanner);
$1$2
EOT
      $line_offset += 2; # added 2 lines to output
    }
  }

  if($cur_function eq $prefix."_switch_to_buffer" ||
     $cur_function eq $prefix."restart" ||
     $cur_function eq $prefix."push_buffer_state") {
    if(!exists($fn_state{'seen_ensure'})) {
      s%(^\s*if\s*\(\s*!\s*)YY_CURRENT_BUFFER(\s*\)\s*\{.*$)%${1}yyg->yy_buffer_stack${2}%;
      if(m%^\s*${prefix}ensure_buffer_stack\s*\(%) {
	$fn_state{'seen_ensure'} = 1;
      }
    } else {
      # In condition with whitespace
      s%(\s+)YY_CURRENT_BUFFER(\s+)%${1}YY_CURRENT_BUFFER_LVALUE${2}%;
      # In parameter or condition
      s%([,\(])YY_CURRENT_BUFFER([,\)])%${1}YY_CURRENT_BUFFER_LVALUE${2}%;
    }
  }

  if($cur_function eq 'yy_get_next_buffer') {
    if(!exists($fn_state{'seen_yyinput'}) &&
       m%^\s*YY_INPUT\(%) {
      $fn_state{'seen_yyinput'} = 1;
    } elsif(exists($fn_state{'seen_yyinput'})) {
      # Remove dead code after YY_INPUT - which is a return NULL
      s%^\s*YY_CURRENT_BUFFER_LVALUE->yy_n_chars\s*=\s*yyg->yy_n_chars;%%;
    }
  }

  if($cur_function eq $prefix.'pop_buffer_state') {
    # Change last if use of YY_CURRENT_BUFFER macro to unconditional value
    s%^(\s*if \(\s*)YY_CURRENT_BUFFER(\s*\)\s*\{.*)$%${1}YY_CURRENT_BUFFER_LVALUE${2}%;
  }

  print;
}