/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   pattern.h
 * Purpose:    The regular expressions of the AP-101S grammar, written out as
 *             matchers.
 * Contact:    info@sandroid.org
 *
 * WHY NOT A REGULAR-EXPRESSION LIBRARY.  The grammar uses thirty-four distinct
 * patterns and every one of them is a character class with a quantifier, plus
 * a single negative lookbehind.  Writing them out is a few dozen lines, has no
 * dependency to install on three platforms, and is considerably faster than
 * any library call in what is the parser's innermost loop.  The regular
 * expression each one implements is quoted above it, and the numbering matches
 * the `patN` names the translator emits into parser_asm.c.
 *
 * ONE THING IS NOT OBVIOUS.  TatSu matches with `cre.match(self.text, pos)`
 * rather than against a slice, so a lookbehind SEES THE TEXT BEFORE `pos`.
 * The `identifier` pattern relies on that -- it is what stops `&ABC` from
 * being read as the identifier `ABC` -- and matching against a slice instead
 * would quietly change the language.
 */

#ifndef ASM101SA_PATTERN_H
#define ASM101SA_PATTERN_H

#include "peg.h"

ptrdiff_t pat0 (const char *t, size_t len, size_t pos);
ptrdiff_t pat1 (const char *t, size_t len, size_t pos);
ptrdiff_t pat2 (const char *t, size_t len, size_t pos);
ptrdiff_t pat3 (const char *t, size_t len, size_t pos);
ptrdiff_t pat4 (const char *t, size_t len, size_t pos);
ptrdiff_t pat5 (const char *t, size_t len, size_t pos);
ptrdiff_t pat6 (const char *t, size_t len, size_t pos);
ptrdiff_t pat7 (const char *t, size_t len, size_t pos);
ptrdiff_t pat8 (const char *t, size_t len, size_t pos);
ptrdiff_t pat9 (const char *t, size_t len, size_t pos);
ptrdiff_t pat10 (const char *t, size_t len, size_t pos);
ptrdiff_t pat11 (const char *t, size_t len, size_t pos);
ptrdiff_t pat12 (const char *t, size_t len, size_t pos);
ptrdiff_t pat13 (const char *t, size_t len, size_t pos);
ptrdiff_t pat14 (const char *t, size_t len, size_t pos);
ptrdiff_t pat15 (const char *t, size_t len, size_t pos);
ptrdiff_t pat16 (const char *t, size_t len, size_t pos);
ptrdiff_t pat17 (const char *t, size_t len, size_t pos);
ptrdiff_t pat18 (const char *t, size_t len, size_t pos);
ptrdiff_t pat19 (const char *t, size_t len, size_t pos);
ptrdiff_t pat20 (const char *t, size_t len, size_t pos);
ptrdiff_t pat21 (const char *t, size_t len, size_t pos);
ptrdiff_t pat22 (const char *t, size_t len, size_t pos);
ptrdiff_t pat23 (const char *t, size_t len, size_t pos);
ptrdiff_t pat24 (const char *t, size_t len, size_t pos);
ptrdiff_t pat25 (const char *t, size_t len, size_t pos);
ptrdiff_t pat26 (const char *t, size_t len, size_t pos);
ptrdiff_t pat27 (const char *t, size_t len, size_t pos);
ptrdiff_t pat28 (const char *t, size_t len, size_t pos);
ptrdiff_t pat29 (const char *t, size_t len, size_t pos);
ptrdiff_t pat30 (const char *t, size_t len, size_t pos);
ptrdiff_t pat31 (const char *t, size_t len, size_t pos);
ptrdiff_t pat32 (const char *t, size_t len, size_t pos);
ptrdiff_t pat33 (const char *t, size_t len, size_t pos);

#endif /* ASM101SA_PATTERN_H */
