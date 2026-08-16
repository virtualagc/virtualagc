/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   common.h
 * Purpose:    Platform shims and common includes for the C port of ASM101S.
 * Contact:    info@sandroid.org
 * Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
 *
 * Everything here exists so that the rest of the port can be written once and
 * built by gcc, clang and MSVC without #ifdef clutter spread through it.
 */

#ifndef ASM101SA_COMMON_H
#define ASM101SA_COMMON_H

#if defined(_MSC_VER)
/* MSVC objects to the C standard library's own functions on principle. */
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS 1
#endif
#endif

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * WHY 64 BITS IS ENOUGH, given that Python's integers are unbounded.
 *
 * A symbol's value is a 28-bit hashcode shifted left by 36 plus a small
 * offset, so the largest is (2**28-1) << 36 = 2**64 - 2**36, which fits an
 * unsigned 64-bit word exactly and overflows a signed one.  Everything the
 * assembler does with such a value is either a mask against a 64-bit constant
 * -- and masking ignores any bits above 64, so Python and two's-complement C
 * agree -- or a difference between two values in the SAME section, where the
 * hashcodes cancel and the true result is small.  A difference across sections
 * is a malformed expression in the source, and wraps to a multiple of 2**36
 * that no range test admits, exactly as the unbounded value does.
 *
 * The arithmetic is therefore done on uint64_t, where wrapping is defined, and
 * reinterpreted as int64_t for comparisons.  `-fwrapv` is passed as well, so
 * that a stray signed operation cannot become undefined behaviour.
 */
typedef int64_t asmint;
typedef uint64_t asmuint;

#define ASM_ADD(a, b) ((asmint)((asmuint)(a) + (asmuint)(b)))
#define ASM_SUB(a, b) ((asmint)((asmuint)(a) - (asmuint)(b)))
#define ASM_MUL(a, b) ((asmint)((asmuint)(a) * (asmuint)(b)))
#define ASM_NEG(a) ((asmint)(0u - (asmuint)(a)))
#define ASM_AND(a, b) ((asmint)((asmuint)(a) & (asmuint)(b)))

#define HASHCODE_MASK ((asmint)0xFFFFFFF000000000ULL)

#if defined(_WIN32)
#define PATH_SEPARATOR '\\'
#define PATH_SEPARATOR_STR "\\"
#else
#define PATH_SEPARATOR '/'
#define PATH_SEPARATOR_STR "/"
#endif

#if defined(__GNUC__) || defined(__clang__)
#define ASM_NORETURN __attribute__((noreturn))
#define ASM_PRINTF(fmt, first) __attribute__((format(printf, fmt, first)))
#else
#define ASM_NORETURN
#define ASM_PRINTF(fmt, first)
#endif

/* Fatal, unrecoverable internal error.  Never used for anything the source
   being assembled can provoke; those are diagnosed against the line. */
ASM_NORETURN void fatal(const char *fmt, ...);

#endif /* ASM101SA_COMMON_H */
