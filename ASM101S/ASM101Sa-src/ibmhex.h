/*
 * License:    The author (Ron Burkey) declares that this program is in the
 *             Public Domain, and may be used or modified in any desired
 *             manner.
 * Filename:   ibmhex.h
 * Purpose:    Conversion from a constant as written to System/360 hexadecimal
 *             floating point.
 * Contact:    info@sandroid.org
 *
 * The format, per "IBM hexadecimal floating-point":
 *     SEEEEEEE FFFFFFFF FFFFFFFF ... FFFFFFFF
 * where S is the sign, E the exponent as a power of SIXTEEN biased by 64, and
 * F an unsigned fraction whose leftmost bit is one half.  Single precision is
 * the same with three fraction bytes.  Zero is all zeroes.
 */

#ifndef ASM101SA_IBMHEX_H
#define ASM101SA_IBMHEX_H

#include "common.h"
#include "dec.h"

/* Convert the constant TEXT -- as the source wrote it, not as a double --
   optionally scaled, to IBM double precision.  Returns the pair (msw, lsw), or
   (0xFF000000, 0) if it cannot be represented.  `scale` may be NULL for 1. */
void toFloatIBM (const char *text, const Dec *scale, uint32_t *msw,
                 uint32_t *lsw);

/* Round a double-precision result to short (E) precision.  A short constant
   keeps only the top 24 bits of the fraction, and the original assembler
   ROUNDS the rest rather than truncating it. */
uint32_t roundFloatIBMShort (uint32_t msw, uint32_t lsw);

#endif /* ASM101SA_IBMHEX_H */
