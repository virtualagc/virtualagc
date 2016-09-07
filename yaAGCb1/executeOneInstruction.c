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
 * Filename:    executeOneInstruction.c
 * Purpose:     Executes a single instruction on the virtual AGC.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-03 RSB  Wrote.
 *              2016-09-04 RSB  Fixed a bug in CCS decrementing.
 */

#include <stdio.h>
#include <time.h>
#include "yaAGCb1.h"

//---------------------------------------------------
// Various auxiliary functions used for MP,
// copied from yaAGC.  Probably some duplicates of
// other stuff that's already here, but I'm just
// doing quick-and-dirty right now, so I'm not
// troubling myself to figure it out.
static int
SignExtend(int16_t Word)
{
  return ((Word & 077777) | ((Word << 1) & 0100000));
}
// Convert an AGC-formatted word to CPU-native format.
static int
agc2cpu(int Input)
{
  if (0 != (040000 & Input))
    return (-(037777 & ~Input));
  else
    return (037777 & Input);
}
static int
cpu2agc2(int Input)
{
  if (Input < 0)
    return (03777777777 & ~(01777777777 & (-Input)));
  else
    return (01777777777 & Input);
}
static int16_t
OverflowCorrected(int Value)
{
  return ((Value & 037777) | ((Value >> 1) & 040000));
}
static void
DecentToSp(int Decent, int16_t * LsbSP)
{
  int Sign;
  Sign = (Decent & 04000000000);
  *LsbSP = (037777 & Decent);
  if (Sign)
    *LsbSP |= 040000;
  LsbSP[-1] = OverflowCorrected(0177777 & (Decent >> 14));     // Was 13.
}
//---------------------------------------------------

// Write a value to an erasable address, with or without "editing".
// If the specified address is in fixed memory, return without doing
// anything.  If the value needs one, it is assumed to already have
// a UC bit.
void
writeToErasableOrRegister(uint16_t flatAddress, uint16_t value)
{
  if (flatAddress >= 04 && !(flatAddress >= 035 && flatAddress <= 040))
    value &= 077777;
  if (&regBank== &agc.memory[flatAddress]) agc.memory[flatAddress] = value & 037;
  else if (flatAddress < 02000) agc.memory[flatAddress] = value;
}

static int numMCT;
static uint16_t lastINDEX = 0;
static uint16_t lastZ = 0;
void
implementationError(char *message)
{
  agc.instructionCountDown = 1;
  printf("*** Implementation error: %s ***\n", message);
  numMCT = 0;
  regZ= lastZ;
  agc.INDEX = lastINDEX;
}

void
incrementZ(uint16_t increment)
{
  regZ= (regZ & 06000) + ((regZ + increment) & 01777);
}

uint16_t
fixUcForWriting(uint16_t valueFromAthroughLP)
{
  return (valueFromAthroughLP & 037777) | ((valueFromAthroughLP & 0100000) >> 1);
}

int
incTimerCheckOverflow(uint16_t *timer)
{
  agc.countMCT += 1;
  (*timer) = (037777 & *timer) + 1;
  if (*timer == 040000)
    {
      *timer = 0100000;
      return (1);
    }
  return (0);
}

// There had been a discrepancy with Pultorak, in which if A has
// overflow, then an overflow bit gets written back to the operand
// location, assuming it happens to be writable and have a useful 16th
// bit (of which the only examples I know right now are TIME1-4).
// It kind of makes sense to me in terms of the control pulses,
// but ....  At any rate, for now at least, let's duplicate this
// behavior.
void
overflowWriteFix(uint16_t operand)
{
  // Does the operand have 16 bits?
  if (operand >= 035 && operand <= 040)
    {
      // Copy the 16th bit from regA.
      agc.memory[operand] = (agc.memory[operand] & 077777) | (regA& 0100000);
    }
}

void
edit(uint16_t flatAddress)
{
#if 1
  if (flatAddress == 020)
    {
      regCYR = ((regCYR & 1) << 14) | ((regCYR & 077777) >> 1);
    }
  else if (flatAddress == 021)
    {
      regSR = (regSR & 040000) | (regSR >> 1);
    }
  else if (flatAddress == 022)
    {
      regCYL= ((regCYL & 040000) >> 14) | ((regCYL << 1) & 077777);
    }
  else if (flatAddress == 023)
    {
      regSL = ((regSL << 1) & 0077776) | ((regSL & 0100000) >> 15);
    }
  return;
#else
  // If table 3-2 on p. 3-3 of R-393 is to be believed, this editing behaves
  // only marginally as one might expect.
  if (flatAddress >= 020 && flatAddress <= 023)
    {
      uint16_t before, SG, UC, B14, B1;
      before = agc.memory[flatAddress];
      SG = before & 0100000;
      UC = before & 0040000;
      B14 = before & 0020000;
      B1 = before & 1;
      if (flatAddress == 020)
        agc.memory[flatAddress] = ((before >> 1) & 017777) | (B1 << 14)
            | (SG >> 2);
      else if (flatAddress == 021)
        agc.memory[flatAddress] = ((before >> 1) & 017777) | SG | (SG >> 2)
            | UC;
      else if (flatAddress == 022)
        agc.memory[flatAddress] = ((before << 1) & 037776) | (B14 << 2)
            | (SG >> 15) | UC;
      else if (flatAddress == 023)
        agc.memory[flatAddress] = ((before << 1) & 037776) | SG | (SG >> 15)
            | UC;
    }
#endif
}

void
executeOneInstruction(FILE *logFile)
{
  int instruction;
  int16_t term1, term2, sum;
  uint16_t flatAddress, opcode, operand, extracode, dummy, fetchedFromOperand,
      fetchedFromOperandSignExtended, fetchedOperandOverflow;
  static uint16_t lastInstruction = 0;

  numMCT = 2;

  retry: ;
  // Various preliminary stuff that it's just useful to do for any
  // instruction.
  flatAddress = (regZ< 06000) ? regZ : flatten(regBank, regZ);
  // Increment Z to next location.
  lastZ = regZ;
  incrementZ(1);
  lastINDEX = agc.INDEX;
  /*
   instruction = agc.memory[flatAddress] + agc.INDEX;
   if (instruction & 0100000) // Account for 1's complement.
   instruction++;
   */
  term1 = agc.memory[flatAddress];
  if (flatAddress < 4)
    term1 = fixUcForWriting(term1);
  term2 = SignExtend(agc.INDEX);
  // Special case:  note that x + -x = -0.
  if (term1 == ~term2)
    sum = 0177777;
  else
    {
      if ((term1 & 040000) != 0)
        term1 = -(~(term1 | ~077777));
      if ((term2 & 040000) != 0)
        term2 = -(~term2);
      sum = term1 + term2;
      if (sum < 0)
        sum = ~(-sum);
    }
  instruction = sum;
  instruction &= 0177777;

  // Prioritized interrupt vectors.
  extracode = instruction & 0100000;
  opcode = instruction & 0070000;
  if (!regInhint&& !agc.INTERRUPTED && 0100000 != (0140000 & regA) && 0040000 != (0140000 & regA)
  && !extracode)
    {
      uint16_t interruptVector = 0;

      // Test for interrupt triggers.
      if (0100000 & ctrTIME3)// T3RUPT
      interruptVector = 02000;
      else if (regIN2 & 077600)// ERRUPT -- 8 fail bits in IN2.
      interruptVector = 02004;
      else if (0100000 & ctrTIME4)// DSRUPT
      interruptVector = 02010;
      else if (0)// KEYRUPT
      interruptVector = 02014;
      else if (0)// UPRUPT
      interruptVector = 02020;
      else if (0)// DOWNRUPT
      interruptVector = 02024;

      // Vector to the interrupt if necessary.
      if (interruptVector != 0)
        {
          agc.countMCT += 3;
          agc.INTERRUPTED = 1;
          regZRUPT = regZ;
          regBRUPT = instruction;
          regZ = interruptVector;
          goto retry;
        }
    }
  resumeFromInterrupt: ;
  agc.B = instruction;
  if (0 == (agc.B & 0100000))
    agc.B |= (agc.B & 040000) << 1;
  if (logFile != NULL)
    logAGC(logFile, lastZ);

  lastInstruction = instruction;
  agc.INDEX = 0;
  extracode = instruction & 0100000;
  opcode = instruction & 0070000;
  operand = instruction & 007777;
  if (operand < 06000)
    fetchedFromOperand = agc.memory[operand];
  else
    fetchedFromOperand = agc.memory[flatten(regBank, operand)];
  if (operand < 04) // Already has a UC bit.
    fetchedFromOperandSignExtended = fetchedFromOperand;
  else
    fetchedFromOperandSignExtended = ((fetchedFromOperand & 040000) << 1)
        | (fetchedFromOperand & 077777);
  fetchedOperandOverflow = fetchedFromOperandSignExtended & 0140000;

  //printf("flatAddress=%05o, memory=%05o, index=%05o, instruction=%05o, opcode=%05o, operand=%05o, fetchedFromOperand=%05o\n",
  //    flatAddress, agc.memory[flatAddress], lastINDEX, instruction, opcode, operand, fetchedFromOperand);

  // Now execute the stuff specific to the opcode.
  if (opcode == 0000000) /* TC */
    {
      uint16_t oldZ;
      // Recall that Q, Z, and the instruction we generated above are
      // correctly set up vis-a-vis the 16th bit.  The conditional is to
      // prevent Q from being overwritten in case the instruction is "TC Q"
      // ("RETURN"). This is a special case described on p. 3-9 of R-393.
      // R-393 says that "TC Q" takes 2 MCT; Pultorak says 1 MCT; I believe
      // Pultorak.
      numMCT = 1;
      if (instruction != 1)
        {
          regQ= regZ;
          numMCT = 1;
        }
      regZ= operand;
    }
  else if (opcode == 010000 && !extracode) /* CCS */
    {
      if (operand >= 02000) implementationError("CCS accessing fixed memory.");
      else
        {
          uint16_t K;
          // Arrange to jump.  Recall that Z already points to the next
          // instruction.
          K = (operand >= 04) ? fetchedFromOperand : fixUcForWriting(fetchedFromOperand);
          if (K == 000000) incrementZ(1);// +0
          else if (0 == (K & 040000)) incrementZ(0);// >0
          else if (K == 077777) incrementZ(3);// -0
          else incrementZ(2);// < 0
          // Compute the "diminished absolute value" of c(K).
          if (0 != (K & 040000)) K = (~K) & 037777;// Absolute value.
          if (K >= 1)
          K--;
          regA = K;
          edit(operand);
        }
    }
  else if (opcode == 020000 && !extracode) /* INDEX */
    {
      if (operand == 016) regInhint = 0;
      else if (operand == 017) regInhint = 1;
      else if (operand == 025) implementationError("Unimplemented operand RESUME");
      else agc.INDEX = fetchedFromOperand;
    }
  else if (opcode == 030000 && !extracode) /* XCH (erasable) or CAF (fixed). */
    {
      if (operand == 020 && operand <= 023)
        {
          agc.memory[operand] = fixUcForWriting(regA) /* | ((fetchedFromOperand & 0040000) << 1)*/;
          edit(operand);
          regA = fetchedFromOperandSignExtended;
        }
      else
        {
          // Cannot actually write to regIN
          if (operand < 04 || operand > 07)
          writeToErasableOrRegister(operand, fixUcForWriting(regA));
          regA = fetchedFromOperandSignExtended;
          overflowWriteFix(operand);
        }
    }
  else if (opcode == 0040000) /* CS. */
    {
      regA = (~fetchedFromOperandSignExtended) & 0177777;
      overflowWriteFix(operand);
    }
  else if (opcode == 0050000) /* TS. */
    {
      if (operand >= 02000) implementationError("TS accessing fixed memory.");
      else
        {
          uint16_t aOverflowBits;
          int value;
          aOverflowBits = regA & 0140000;
          // If writing the maximum positive value to TIME1-TIME4, apparently
          // the overflow is supposed to be set.  This is per Pultorak, but I
          // don't find any actual documentation about it.  Solarium does refer
          // to this as a "pseudo-interrupt", but as to whether it means this
          // or just means "as soon as possible" is hard to day.
          if (operand >= 020 && operand <= 023)
            {
              agc.memory[operand] = regA;
              edit(operand);
            }
          else
            {
              value = fixUcForWriting(regA);
              if (operand >= 035 && operand <= 040 && value == 037777) value = 0137777;
              writeToErasableOrRegister(operand, value);
            }
          if (aOverflowBits == 0100000 || aOverflowBits == 0040000)
            {
              // Overflow.
              incrementZ(1);
              if (0 & (fetchedOperandOverflow & 0100000)) regA = 0000001;// Positive overflow.
              else regA = 0177776;// Negative overflow;
            }
          if (operand == 026 /*ARUPT*/)
            {
              // In writing to ARUPT, we always set overflow.  Or at least, Pultorak
              // does.  I suppose this may be an indicator that an interrupt is in
              // progress, since interrupts can't be triggered while there's overflow
              // in A.  Whatever.  I use agc.INTERRUPTED for this condition, since
              // otherwise there's a theoretical race condition.
              if (regARUPT & 040000)
              regARUPT &= ~0100000;
              else
              regARUPT |= 0100000;
            }
        }
    }
  else if (opcode == 060000) /* AD. */
    {
      // FIXME Not sure what's supposed to happen if A already has
      // overflowed.  For now, let's make sure it hasn't.
      int16_t term1, term2, sum;
      entrySubtraction:;
      term1 = fixUcForWriting(regA);
      term2 = fetchedFromOperandSignExtended;
      // Special case:  note that x + -x = -0.
      if (term1 == ~term2) sum = 0177777;
      else
        {
          if ((term1 & 040000) != 0) term1 = -(~(term1 | ~077777));
          if ((term2 & 040000) != 0) term2 = -(~term2);
          sum = term1 + term2;
          if (sum < 0 ) sum = ~(-sum);
        }
      regA = sum;
      if ((sum & 0140000) == 0040000) // Positive overflow
        {
          numMCT++;
          ctrOVCTR = (ctrOVCTR + 1) & 077777;
          if (ctrOVCTR == 077777) ctrOVCTR = 0; // Convert -0 to +0.
        }
      else if ((sum & 0140000) == 0100000) // Negative overflow
        {
          numMCT++;
          if (ctrOVCTR == 0) ctrOVCTR = 077777; // Convert +0 to -0.
          ctrOVCTR = (ctrOVCTR - 1) & 077777;
        }
      overflowWriteFix(operand);
    }
  else if (opcode == 070000) /* MASK. */
    {
      regA &= fetchedFromOperandSignExtended;
    }
  else if (opcode == 010000 && extracode) /* MP */
    {
      numMCT = 8;

      // Unlike almost everything else in this program, this is adapted
      // (copied) from the original Block 2 yaAGC.

      // For MP A (i.e., SQUARE) the accumulator is NOT supposed to
      // be overflow-corrected.  I do it anyway, since I don't know
      // what it would mean to carry out the operation otherwise.
      // Fix later if it causes a problem.
      // FIX ME: Accumulator is overflow-corrected before SQUARE.
      int16_t MsWord, LsWord, Operand16, OtherOperand16;
      int Product;
      Operand16 = fixUcForWriting(regA);
      OtherOperand16 = fetchedFromOperandSignExtended;
      if (OtherOperand16 == AGC_P0 || OtherOperand16 == AGC_M0)
      MsWord = LsWord = AGC_P0;
      else if (Operand16 == AGC_P0 || Operand16 == AGC_M0)
        {
          if ((Operand16 == AGC_P0 && 0 != (040000 & OtherOperand16)) ||
              (Operand16 == AGC_M0 && 0 == (040000 & OtherOperand16)))
          MsWord = LsWord = AGC_M0;
          else
          MsWord = LsWord = AGC_P0;
        }
      else
        {
          int16_t WordPair[2];
          Product =
          agc2cpu (SignExtend (Operand16)) *
          agc2cpu (SignExtend (OtherOperand16));
          Product = cpu2agc2 (Product);
          // Sign-extend, because it's needed for DecentToSp.
          if (02000000000 & Product)
          Product |= 004000000000;
          // Convert back to DP.
          DecentToSp (Product, &WordPair[1]);
          MsWord = WordPair[0];
          LsWord = WordPair[1];
        }
      regA = SignExtend (MsWord);
      regLP = SignExtend (LsWord);
    }
  else if (opcode == 020000 && extracode) /* DV */
    {
      numMCT = 18;

      implementationError("DV not implemented yet.");
    }
  else if (opcode == 030000 && extracode) /* SU */
    {
      // R-393 says that SU takes 2 more MCT than AD, but the control-pulse
      // sequences it lists for SU don't support that notion.
      //numMCT += 2;
      fetchedFromOperandSignExtended = ~fetchedFromOperand;
      fetchedFromOperand = fetchedFromOperandSignExtended & 077777;
      goto entrySubtraction;
    }
  else
    {
      char message[64];
      sprintf (message, "Unimplemented opcode %05o (%06o)", opcode, extracode);
      implementationError(message);
    }

  agc.countMCT += numMCT;

  /*
   * Update regTIME1-4.  When TIME1 overflows it increments
   * TIME2.  TIME1,3,4 counts up every 10 ms.,
   * i.e., every 1024000/12/100 MCT = 2560/3 MCT.  The starting count is
   * set to half of this, for no particular reason.
   */
    {
// Pultorak's simulator was counting 10 times too fast after first ported.
// The constant PULTORAK was a speed-up factor I was using to match him
// until I was sure I could/should fix his program, which I have now done,
// so it's now safe to set the speed-up to 1 now.
//#define PULTORAK 10
#define PULTORAK 1
      static int nextTimerIncrement = 1280;
      int overflow = 0;
      if (agc.countMCT * 3 * PULTORAK > nextTimerIncrement)
        {
          nextTimerIncrement += 2560;
          if (incTimerCheckOverflow(&ctrTIME1))
          incTimerCheckOverflow (&ctrTIME2);
          incTimerCheckOverflow(&ctrTIME3);
          incTimerCheckOverflow(&ctrTIME4);
        }

    }
}

