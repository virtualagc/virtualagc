/*
 * Copyright 2016 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * In addition, as a special exception, Ronald S. Burkey gives permission to
 * link the code of this program with the Orbiter SDK library (or with
 * modified versions of the Orbiter SDK library that use the same license as
 * the Orbiter SDK library), and distribute linked combinations including
 * the two. You must obey the GNU General Public License in all respects for
 * all of the code used other than the Orbiter SDK library. If you modify
 * this file, you may extend this exception to your version of the file,
 * but you are not obligated to do so. If you do not wish to do so, delete
 * this exception statement from your version.
 *
 * Filename:    fromYaAGC.c
 * Purpose:     Various little utility functions from yaAGC, which I've
 *              copied into yaAGCb1 for the sole purpose of being able
 *              to use the yaAGC MP and DV instructions unchanged without
 *              have to trouble myself with actual thought.  There's
 *              undoubtedly overlap with functionality already in yaAGCb1,
 *              but I don't care about that as of yet.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-09 RSB  Adapted from yaAGC/agc_engine.c.
 */

#include "yaAGCb1.h"

// Adds two sign-extended SP values.  The result may contain overflow.
uint16_t
AddSP16 (uint16_t Addend1, uint16_t Addend2)
{
  int Sum;
  Sum = Addend1 + Addend2;
  if (Sum & 0200000)
    {
      Sum += AGC_P1;
      Sum &= 0177777;
    }
  return (Sum);
}

// Absolute value of an SP value.

int16_t
SignExtend(int16_t Word)
{
  return ((Word & 077777) | ((Word << 1) & 0100000));
}

// Absolute value of an SP value.
int16_t
AbsSP (int16_t Value)
{
  if (040000 & Value)
    return (077777 & ~Value);
  return (Value);
}


//-----------------------------------------------------------------------------
// Convert an AGC-formatted word to CPU-native format.

int
agc2cpu (int Input)
{
  if (0 != (040000 & Input))
    return (-(037777 & ~Input));
  else
    return (037777 & Input);
}

//-----------------------------------------------------------------------------
// Convert a native CPU-formatted word to AGC format. If the input value is
// out of range, it is truncated by discarding high-order bits.

int
cpu2agc (int Input)
{
  if (Input < 0)
    return (077777 & ~(-Input));
  else
    return (077777 & Input);
}

//-----------------------------------------------------------------------------
// Double-length versions of the same.

int
agc2cpu2 (int Input)
{
  if (0 != (02000000000 & Input))
    return (-(01777777777 & ~Input));
  else
    return (01777777777 & Input);
}

int
cpu2agc2 (int Input)
{
  if (Input < 0)
    return (03777777777 & ~(01777777777 & (-Input)));
  else
    return (01777777777 & Input);
}


int16_t
OverflowCorrected(int Value)
{
  return ((Value & 037777) | ((Value >> 1) & 040000));
}

// Here are functions to convert a DP into a more-decent 1's-
// complement format in which there's not an extra sign-bit to contend with.
// (In other words, a 29-bit format in which there's a single sign bit, rather
// than a 30-bit format in which there are two sign bits.)  And vice-versa.
// The DP value consists of two adjacent SP values, MSW first and LSW second,
// and we're given a pointer to the second word.  The main difficulty here
// is dealing with the case when the two SP words don't have the same sign,
// and making sure all of the signs are okay when one or more words are zero.
// A sign-extension is added a la the normal accumulator.

int
SpToDecent (int16_t * LsbSP)
{
  int16_t Msb, Lsb;
  int Value, Complement;
  Msb = LsbSP[-1];
  Lsb = *LsbSP;
  if (Msb == AGC_P0 || Msb == AGC_M0)   // Msb is zero.
    {
      // As far as the case of the sign of +0-0 or -0+0 is concerned,
      // we follow the convention of the DV instruction, in which the
      // overall sign is the sign of the less-significant word.
      Value = SignExtend (Lsb);
      if (Value & 0100000)
        Value |= ~0177777;
      return (07777777777 & Value);     // Eliminate extra sign-ext. bits.
    }
  // If signs of Msb and Lsb words don't match, then make them match.
  if ((040000 & Lsb) != (040000 & Msb))
    {
      if (Lsb == AGC_P0 || Lsb == AGC_M0)       // Lsb is zero.
        {
          // Adjust sign of Lsb to match Msb.
          if (0 == (040000 & Msb))
            Lsb = AGC_P0;
          else
            Lsb = AGC_M0;       // 2005-08-17 RSB.  Was "Msb".  Oops!
        }
      else                      // Lsb is not zero.
        {
          // The logic will be easier if the Msb is positive.
          Complement = (040000 & Msb);
          if (Complement)
            {
              Msb = (077777 & ~Msb);
              Lsb = (077777 & ~Lsb);
            }
          // We now have Msb positive non-zero and Lsb negative non-zero.
          // Subtracting 1 from Msb is equivalent to adding 2**14 (i.e.,
          // 0100000, accounting for the parity) to Lsb.  An additional 1
          // must be added to account for the negative overflow.
          Msb--;
          Lsb = ((Lsb + 040000 + AGC_P1) & 077777);
          // Restore the signs, if necessary.
          if (Complement)
            {
              Msb = (077777 & ~Msb);
              Lsb = (077777 & ~Lsb);
            }
        }
    }
  // We now have an Msb and Lsb of the same sign; therefore,
  // we can simply juxtapose them, discarding the sign bit from the
  // Lsb.  (And recall that the 0-position is still the parity.)
  Value = (03777740000 & (Msb << 14)) | (037777 & Lsb);
  // Also, sign-extend for further arithmetic.
  if (02000000000 & Value)
    Value |= 04000000000;
  return (Value);
}

void
DecentToSp(int Decent, int16_t * LsbSP)
{
  int Sign;
  Sign = (Decent & 04000000000);
  *LsbSP = (037777 & Decent);
  if (Sign)
    *LsbSP |= 040000;
  LsbSP[-1] = OverflowCorrected(0177777 & (Decent >> 14));     // Was 13.
}
