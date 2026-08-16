/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   pyutil.h
 * Purpose:    The handful of Python behaviours the port has to reproduce
 *             exactly, rather than approximately, because the assembler's
 *             output depends on them.
 * Contact:    info@sandroid.org
 *
 * These are not conveniences.  Each one is here because C's nearest equivalent
 * differs in a way that shows up in the object code or the listing:
 *
 *   py_round        Python rounds half to EVEN.  C's round() rounds half away
 *                   from zero, so `DC F'0.5'` and every scaled constant whose
 *                   product lands exactly on a half would differ.
 *   py_div_trunc    Assembler division truncates toward zero and yields zero
 *                   for a zero divisor (GC28-6514-8 p.28).  C's / traps on a
 *                   zero divisor.
 *   py_float_repr   `str(x)` of a float appears in diagnostics.
 *   py_center/ljust The listing's headings are built with str.center() and
 *                   "%-Ns", and a heading that is one column off is a
 *                   difference in every page of the output.
 *   py_isdigit      str.isdigit() is false for the empty string, where a naive
 *                   loop returns true -- and `expression.isdigit()` decides
 *                   whether a token is a number or a symbol name.
 */

#ifndef ASM101SA_PYUTIL_H
#define ASM101SA_PYUTIL_H

#include "common.h"

/*---------------------------------------------------------------------------
 * A growable string, used everywhere the original builds text with `+=` or
 * `"".join`.  It allocates with malloc/realloc and is released explicitly;
 * `sb_take` hands the finished text to the main arena.
 */
typedef struct
{
  char *s;
  size_t len;
  size_t cap;
} StrBuf;

void sb_init (StrBuf *b);
void sb_free (StrBuf *b);
void sb_clear (StrBuf *b);
void sb_addn (StrBuf *b, const char *s, size_t n);
void sb_add (StrBuf *b, const char *s);
void sb_addc (StrBuf *b, char c);
void sb_addf (StrBuf *b, const char *fmt, ...) ASM_PRINTF (2, 3);
/* Copy the contents into the main arena and free the buffer. */
char *sb_take (StrBuf *b);
/* Copy the contents into the main arena, leaving the buffer usable. */
char *sb_dup (const StrBuf *b);

/*---------------------------------------------------------------------------
 * Numbers
 */
asmint py_round (double x);           /* round-half-to-even, as Python's round() */
asmint py_div_trunc (asmint a, asmint b);
/* Python's `//` and `%`, which FLOOR rather than truncate.  The difference
   shows up wherever a displacement goes negative:  -7 // 2 is -4 in Python and
   -3 in C, and -7 % 2 is 1 in Python and -1 in C. */
asmint py_floordiv (asmint a, asmint b);
asmint py_mod (asmint a, asmint b);
/* Python's str()/repr() of a float: the shortest decimal that round-trips. */
void py_float_repr (char *out, size_t outSize, double x);
/* strtod restricted to what a source constant may look like. */
double py_atof (const char *s);
/* int(s) with the given base; returns 0 and sets *ok=0 on failure. */
asmint py_atoi_base (const char *s, int base, int *ok);
/* int(s) for an optionally-signed decimal string, whole-string. */
int py_parse_int (const char *s, asmint *out);

/*---------------------------------------------------------------------------
 * Strings.  All of these return main-arena storage.
 */
int py_isdigit (const char *s);        /* str.isdigit(), false for "" */
int py_isdigit_n (const char *s, size_t n);
char *py_ljust (const char *s, size_t width);
char *py_rjust (const char *s, size_t width, char fill);
char *py_center (const char *s, size_t width);
char *py_rstrip (const char *s);
char *py_lstrip (const char *s);
char *py_strip (const char *s);
char *py_rstrip_chars (const char *s, const char *chars);
char *py_upper (const char *s);
char *py_replace (const char *s, const char *from, const char *to);
char *py_format (const char *fmt, ...) ASM_PRINTF (1, 2);
char *py_concat (const char *a, const char *b);
char *py_substr (const char *s, size_t start, size_t len);
char *py_repeat (const char *s, size_t n);
int py_startswith (const char *s, const char *prefix);
int py_endswith (const char *s, const char *suffix);
const char *py_find (const char *s, const char *needle);
/* Split on runs of whitespace, discarding empties, as str.split() with no
   argument.  Returns the number of fields; fields are main-arena strings. */
size_t py_split_ws (const char *s, char ***fields);
/* Split on a single character, keeping empties, as str.split(c). */
size_t py_split_char (const char *s, char c, char ***fields);

#endif /* ASM101SA_PYUTIL_H */
