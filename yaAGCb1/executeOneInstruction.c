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
 *              2016-09-09 RSB  Lots of fixes, particularly backing out
 *                              stuff that I was trying (pointlessly) to
 *                              fix discrepancies with yaAGC-Block1 that
 *                              were actually due to yaAGC-Block1 sticking
 *                              parity bits on everything. All the
 *                              instructions implemented now, though I've
 *                              had no way to test DV so far.
 *              2016-09-27 RSB  Hooked up DSRUPT.
 *              2021-08-07 RSB  Fixed a bunch of errors identified by
 *                              running SELF-CHECK in Solarium:
 *                              * AD and INDEX now edit their arguments
 *                              * SL no longer shifts into bit 14
 *                              * DV now sets LP to either 140001 or 140000
 *                                depending on inputs.
 *                              * DV with negative numerators now works.
 *                              * DV of equal-magnitude numbers now sets
 *                                A and Q correctly.
 *                              * CCS and SU now respect overflow.
 *                              * TS A now preserves the value of A on
 *                                overflow.
 */

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "yaAGCb1.h"

// Only for my primitive debugging facility that I'm using
// during initial development.
int breaksOrWatches[MAX_BREAKS_OR_WATCHES];
int numBreaksOrWatches = 0;

// Write a value to an erasable address.
void
writeToErasableOrRegister(uint16_t flatAddress, uint16_t value)
{
  if (flatAddress >= 04 /*&& !(flatAddress >= 035 && flatAddress <= 040)*/)
    value &= 077777;
  if (&regBank== &agc.memory[flatAddress]) agc.memory[flatAddress] = value & 076000;
  else if (flatAddress < 02000) agc.memory[flatAddress] = value;
  if (flatAddress >= 010 && flatAddress <= 014) // OUT0-4
    ChannelOutput(&agc, flatAddress, value);
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
  (*timer)++;
  if (*timer == 040000)
    {
      *timer = 0;
      return (1);
    }
  return (0);
}

void
edit(uint16_t flatAddress)
{
  if (flatAddress == 03)
    {
      uint16_t b1 = regLP & 1;
      regLP = ((regLP >> 1) & 017777) | (b1 << 15) | (b1 << 14);
    }
  else if (flatAddress == 020)
    {
      regCYR= ((regCYR & 1) << 14) | ((regCYR & 077777) >> 1);
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
      regSL = ((regSL << 1) & 0037776) | ((regSL & 0100000) >> 15);
    }
  return;
}

// Returns 0 normally, but 1 if a breakpoint or watchpoint was
// encountered, so that nothing was actually done.
int
executeOneInstruction(FILE *logFile)
{
  int instruction, i;
  int16_t term1, term2, sum;
  uint16_t flatAddress, opcode, operand, extracode, dummy, fetchedFromOperand,
      fetchedFromOperandSignExtended, fetchedOperandOverflow;
  static uint16_t lastInstruction = 0;

  numMCT = 2;

  retry: ;
  // Various preliminary stuff that it's just useful to do for any
  // instruction.
  flatAddress = (regZ< 06000) ? regZ : flatten(regBank, regZ);
#if 0
  term1 = agc.memory[flatAddress];
  if (flatAddress < 4)
  term1 = fixUcForWriting(term1);
  term2 = SignExtend(agc.INDEX);
  // Special case:  note that x + -x = -0.
  if (077777 & term1 == 077777 & ~term2)
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
#else
  sum = AddSP16(SignExtend(agc.INDEX),
      (flatAddress < 4) ?
          agc.memory[flatAddress] : SignExtend(agc.memory[flatAddress]));
#endif
  instruction = sum;
  instruction &= 0177777;
  if (agc.instructionCountDown != 1) // Breakpoints in my primitive debugging facility in initial development.
    {
      uint16_t flatOperandAddress;
      flatOperandAddress = instruction & 007777;
      if (flatOperandAddress >= 06000)
        flatOperandAddress = flatten(regBank, operand);
      for (i = 0; i < numBreaksOrWatches; i++)
        {
          if (breaksOrWatches[i] == BREAK_UININITIALIZED
              && flatOperandAddress < 02000
              && agc.memory[flatOperandAddress] == defaultErasable
              && (instruction & 070000) != 050000)
            {
              agc.instructionCountDown = 0;
              return (1);
            }
          else if (breaksOrWatches[i] >= 0)
            {
              if (breaksOrWatches[i] == flatAddress
                  || breaksOrWatches[i] == flatOperandAddress)
                {
                  agc.instructionCountDown = 0;
                  return (1);
                }
            }
          else if (agc.countMCT >= -breaksOrWatches[i])
            {
              agc.instructionCountDown = 0;
              return (1);
            }
        }
    }
  // Increment Z to next location.
  lastZ = regZ;
  incrementZ(1);
  lastINDEX = agc.INDEX;

  resumeFromInterrupt: ;
  agc.B = instruction;
  if (0 == (agc.B & 0100000))
    agc.B |= (agc.B & 040000) << 1;
  if (logFile != NULL && loggingOn)
    logAGC(logFile, lastZ);
  lastInstruction = instruction;
  agc.INDEX = 0;
  extracode = instruction & 0100000;
  opcode = instruction & 0070000;
  operand = instruction & 007777;

  // Prioritized interrupt vectors.
  if (!regInhint&& !agc.INTERRUPTED && 0100000 != (0140000 & regA) && 0040000 != (0140000 & regA)
  && !extracode)
    {
      uint16_t interruptVector = 0;

      // Test for interrupt triggers.
      if (agc.overflowedTIME3)// T3RUPT
        {
          interruptVector = 02000;
          agc.overflowedTIME3 = 0;
        }

      if (!interruptVector && 0 != (regIN2 & 077600)) // ERRUPT -- 8 fail bits in IN2.
        {
          interruptVector = 02004;
        }

      if (!interruptVector && agc.overflowedTIME4)  // DSRUPT
        {
          interruptVector = 02010;
          agc.overflowedTIME4 = 0;
        }

      if (!interruptVector && 0 != (regIN0 & 040))  // KEYRUPT
        {
          interruptVector = 02014;
          regIN0 &= ~040;
          printf("KEYRUPT\n");
        }

      if (!interruptVector && agc.uplinkReady)  // UPRUPT
        {
          agc.uplinkReady = 0;
          interruptVector = 02020;
          printf("UPRUPT\n");
        }

      if (!interruptVector && agc.downlinkReady)  // DOWNRUPT
        {
          agc.downlinkReady = 0;
          interruptVector = 02024;
          //printf("DSRUPT\n");
        }

      // Vector to the interrupt if necessary.
      if (interruptVector != 0)
        {
          agc.ruptFlatAddress = flatAddress;
          agc.ruptLastINDEX = lastINDEX;
          agc.ruptLastZ = lastZ;
          agc.countMCT += 3;
          agc.INTERRUPTED = 1;
          regZRUPT = regZ;
          regBRUPT = instruction;
          regZ = interruptVector;
          goto retry;
        }
    }

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
          K = fetchedFromOperandSignExtended;
          if (K == 000000) incrementZ(1);// +0
          else if (0 == (K & 0100000)) incrementZ(0);// >0
          else if (K == 0177777) incrementZ(3);// -0
          else incrementZ(2);// < 0
          // Compute the "diminished absolute value" of c(K).
          if (0 != (K & 0100000)) K = (~K) & 0177777;// Absolute value.
          if (K >= 1) K--;
          regA = K;
          edit(operand);
        }
    }
  else if (opcode == 020000 && !extracode) /* INDEX */
    {
      if (operand == 016) regInhint = 0;
      else if (operand == 017) regInhint = 1;
      else if (operand == 025)
        {
          if (!agc.INTERRUPTED)
          implementationError("RESUME without RUPT.\n");
          flatAddress = agc.ruptFlatAddress;
          lastINDEX = agc.ruptLastINDEX;
          lastZ = agc.ruptLastZ;
          agc.INTERRUPTED = 0;
          regZ = regZRUPT;
          instruction = regBRUPT;
          agc.countMCT += 2;
          goto resumeFromInterrupt;
        }
      else agc.INDEX = fetchedFromOperand;
      edit(operand);
    }
  else if (opcode == 030000 && !extracode) /* XCH (erasable) or CAF (fixed). */
    {
      if (operand >= 020 && operand <= 023)
        {
          agc.memory[operand] = fixUcForWriting(regA);
          regA = fetchedFromOperandSignExtended;
          edit(operand);
        }
      else if (operand < 04)
        {
          // Full 16-bit.
          agc.memory[operand] = regA;
          edit(operand);
          regA = fetchedFromOperand;
        }
      else
        {
          // Cannot actually write to regIN
          if (operand < 04 || operand > 07) writeToErasableOrRegister(operand, fixUcForWriting(regA));
          regA = fetchedFromOperandSignExtended;
        }
    }
  else if (opcode == 0040000) /* CS. */
    {
      regA = (~fetchedFromOperandSignExtended) & 0177777;
      edit(operand);
    }
  else if (opcode == 0050000) /* TS. */
    {
      if (operand >= 02000) implementationError("TS accessing fixed memory.");
      else
        {
          uint16_t aOverflowBits;
          int value;
          aOverflowBits = regA & 0140000;
          if (operand < 04 || (operand >= 020 && operand <= 023))
            {
              agc.memory[operand] = regA;
              edit(operand);
            }
          else
            {
              value = fixUcForWriting(regA);
              writeToErasableOrRegister(operand, value);
            }
          if (aOverflowBits == 0100000 || aOverflowBits == 0040000)
            {
              // Overflow.
              incrementZ(1);
              if (operand != 00)
                {
                    if (aOverflowBits == 0040000) regA = 0000001;// Positive overflow.
                    else regA = 0177776;// Negative overflow;
                }
            }
        }
    }
  else if (opcode == 060000) /* AD. */
    {
      // FIXME Not sure what's supposed to happen if A already has
      // overflowed.
      int16_t term1, term2, sum;
      entrySubtraction:;
      sum = AddSP16 (regA, (flatAddress < 4) ? fetchedFromOperand : fetchedFromOperandSignExtended);
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
      edit(operand);
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

        {
          int32_t numerator, denominator, quotient, remainder, sign = 1, numeratorSign = 1;
          numerator = fixUcForWriting(regA) << 14;
          if (0 != (0100000 & regA)) numerator |= 034000037777;
          denominator = (int16_t) ((operand < 4) ? fetchedFromOperand : fetchedFromOperandSignExtended);
          if (numerator < 0)
            {
              numeratorSign = -1;
              sign = -sign;
              numerator = ~numerator;
            }
          if (denominator < 0)
            {
              sign = -sign;
              denominator = ~denominator;
            }
          if ((numerator >> 14) == denominator)
            {
              regQ = ~denominator;
              regA = (sign > 0) ? 037777 : 0140000;
            }
          else
            {
              quotient = numerator / denominator;
              remainder = numerator % denominator;
              if (quotient > 037777)
                quotient = 037777;
              if (sign < 0)
                quotient = ~quotient;
              regA = quotient;
              regQ = ~remainder;
            }
          if (sign > 0)
            regLP = 1;
          else
            {
              if (numeratorSign > 0)
                regLP = 0140000;
              else
                regLP = 0140001;
            }
        }
    }
  else if (opcode == 030000 && extracode) /* SU */
    {

      // R-393 says that SU takes 2 more MCT than AD, but the control-pulse
      // sequences it lists for SU don't support that notion.
      //numMCT += 2;
      fetchedFromOperandSignExtended = ~fetchedFromOperandSignExtended;
      fetchedFromOperand = fetchedFromOperandSignExtended & 0177777;
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
   * set to half of this, for no particular reason.  John's original code
   * counted 10X too fast for some reason.
   */
    {
      static uint64_t nextTimerIncrement = 1280;
      //int overflow = 0;
      if (agc.countMCT * 3 > nextTimerIncrement)
        {
          nextTimerIncrement += 2560;
          if (incTimerCheckOverflow(&ctrTIME1))
            {
              incTimerCheckOverflow (&ctrTIME2);
            }
          agc.overflowedTIME3 |= incTimerCheckOverflow(&ctrTIME3);
          agc.overflowedTIME4 |= incTimerCheckOverflow(&ctrTIME4);
          if ((ctrTIME1 % 4) == 0  && 0 == (regOUT1 & 01000))
            agc.downlinkReady = 1;
        }

    }

  return (0);
}

