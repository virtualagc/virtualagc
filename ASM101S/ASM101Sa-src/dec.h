/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   dec.h
 * Purpose:    As much of Python's `decimal` module as ibmHex.py uses.
 * Contact:    info@sandroid.org
 *
 * WHY A DECIMAL TYPE IS NEEDED AT ALL.  `toFloatIBM` converts a constant as
 * WRITTEN -- `DC D'0.232830643653869628E-9'` -- into IBM hexadecimal floating
 * point, and it does so in decimal deliberately:  ibmHex.py's own comment says
 * the string form is better "because if the value has already been converted
 * to a Python float, it may no longer be able to correctly match all
 * significant digits".  Doing the arithmetic in `double` instead changes the
 * last bit of some constants, and that constant is one of them -- the original
 * build has 3910000000000000 for it.
 *
 * The context is 20 significant digits, which is what ibmHex.py sets, with
 * Python's default ROUND_HALF_EVEN for arithmetic.  Only the operations that
 * file performs are implemented:  construction from a decimal string and from
 * a double (exactly, as Decimal(float) is), multiplication, division,
 * comparison, negation, and rounding to an integer with ROUND_HALF_UP.
 */

#ifndef ASM101SA_DEC_H
#define ASM101SA_DEC_H

#include "common.h"

/* Room for the widest intermediate that arises:  a 20-digit value times the
   exact decimal expansion of a scale factor of 2**-n, which for the scale
   modifiers this corpus uses is well under a hundred digits.  The margin is
   large because overflowing it silently would be a wrong constant. */
#define DEC_MAX_DIGITS 512
#define DEC_PRECISION 20

typedef struct
{
  int sign;                        /* 1 for negative */
  int nd;                          /* significant digits held; 0 means zero */
  int exp;                         /* value = +/- D * 10**exp */
  unsigned char d[DEC_MAX_DIGITS]; /* most significant digit first */
} Dec;

void dec_zero (Dec *r);
/* Exact, as Decimal(str) is.  Accepts an optional sign, digits, an optional
   fraction and an optional `E` exponent.  Returns 0 if the text is not a
   number. */
int dec_from_string (Dec *r, const char *s);
/* Exact, as Decimal(float) is:  a double is a dyadic rational and has a finite
   decimal expansion. */
void dec_from_double (Dec *r, double x);
void dec_from_int (Dec *r, uint64_t n);
/* 2**n, exactly. */
void dec_pow2 (Dec *r, int n);

int dec_is_zero (const Dec *a);
int dec_cmp (const Dec *a, const Dec *b); /* -1, 0, 1 */
void dec_neg (Dec *r);

/* Rounded to DEC_PRECISION significant digits, ROUND_HALF_EVEN. */
void dec_mul (Dec *r, const Dec *a, const Dec *b);
void dec_div (Dec *r, const Dec *a, const Dec *b);

/* `x.to_integral_value(rounding=ROUND_HALF_UP)`, then int().  Returns 0 and
   sets *ok to 0 if the value will not fit in 64 bits. */
uint64_t dec_to_integral_half_up (const Dec *a, int *ok);

#endif /* ASM101SA_DEC_H */
