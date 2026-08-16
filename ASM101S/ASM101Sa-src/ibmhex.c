/*
 * License:    The author (Ron Burkey) declares that this program is in the
 *             Public Domain, and may be used or modified in any desired
 *             manner.
 * Filename:   ibmhex.c
 * Purpose:    IBM hexadecimal floating-point conversion.
 * Contact:    info@sandroid.org
 */

#include "ibmhex.h"

static Dec twoTo56, twoTo52, sixteen, one;
static int ready = 0;

static void
setup (void)
{
  if (ready)
    return;
  ready = 1;
  dec_pow2 (&twoTo56, 56);
  dec_pow2 (&twoTo52, 52);
  dec_from_int (&sixteen, 16);
  dec_from_int (&one, 1);
}

void
toFloatIBM (const char *text, const Dec *scale, uint32_t *mswOut,
            uint32_t *lswOut)
{
  Dec d;
  int s = 0;
  int e;
  uint64_t f;
  int ok;

  setup ();
  *mswOut = 0xFF000000u;
  *lswOut = 0u;

  if (!dec_from_string (&d, text))
    return;
  dec_mul (&d, &d, scale != NULL ? scale : &one);
  if (dec_is_zero (&d))
    {
      *mswOut = 0u;
      *lswOut = 0u;
      return;
    }
  /* Make the value positive but keep the sign as a bit flag. */
  if (d.sign)
    {
      s = 1;
      d.sign = 0;
    }
  /* Shift left far enough that the fraction becomes an integer. */
  dec_mul (&d, &d, &twoTo56);
  /* Find the exponent, biased by 64, as a power of sixteen. */
  e = 64;
  while (dec_cmp (&d, &twoTo52) < 0)
    {
      e -= 1;
      dec_mul (&d, &d, &sixteen);
    }
  while (dec_cmp (&d, &twoTo56) >= 0)
    {
      e += 1;
      dec_div (&d, &d, &sixteen);
    }
  if (e < 0)
    e = 0;
  if (e > 127)
    return;
  f = dec_to_integral_half_up (&d, &ok);
  if (!ok)
    return;
  /*
   * ROUNDING CAN CARRY OUT OF THE FRACTION.  A value that normalises to just
   * under 2**56 rounds up to exactly 2**56, and `f >> 32` is then 0x1000000 --
   * one bit above the 24-bit fraction field -- which the OR below would carry
   * straight into the EXPONENT.  The result looks almost right, which is what
   * makes it nasty:  the exponent comes out one too high and the fraction
   * comes out zero.
   *
   * DCICYC's `DC D'0.232830643653869628E-9'` is that case.  Renormalising by
   * one HEXADECIMAL digit is the correct correction, the exponent being a
   * power of sixteen.
   */
  if (f >= ((uint64_t) 1 << 56))
    {
      f /= 16;
      e += 1;
      if (e > 127)
        return;
    }
  *mswOut = ((uint32_t) s << 31) | ((uint32_t) e << 24)
            | (uint32_t) (f >> 32);
  *lswOut = (uint32_t) (f & 0xFFFFFFFFu);
}

uint32_t
roundFloatIBMShort (uint32_t msw, uint32_t lsw)
{
  uint32_t s, e, f;
  if (lsw < 0x80000000u)
    return msw;
  s = msw & 0x80000000u;
  e = (msw >> 24) & 0x7Fu;
  f = (msw & 0xFFFFFFu) + 1u;
  if (f > 0xFFFFFFu)
    {
      /* The carry out of a 24-bit fraction is a shift of one hexadecimal
         digit, not one bit, the exponent being a power of sixteen. */
      f >>= 4;
      e += 1;
      if (e > 127)
        return 0xFF000000u;
    }
  return s | (e << 24) | f;
}
