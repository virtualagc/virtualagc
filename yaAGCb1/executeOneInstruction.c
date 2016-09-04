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
 */

#include <stdio.h>
#include <time.h>
#include "yaAGCb1.h"

// Write a value to an erasable address, with or without "editing".
// If the specified address is in fixed memory, return without doing
// anything.  If the value needs one, it is assumed to already have
// a UC bit.
void
writeToErasableOrRegister(uint16_t flatAddress, uint16_t value, int withEditing)
{
  if (flatAddress >= 04)
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

void
executeOneInstruction(void)
{
  int instruction;
  uint16_t flatAddress, opcode, operand, dummy, fetchedFromOperand,
      fetchedFromOperandSignExtended, fetchedOperandOverflow;

  numMCT = 2;

  // Various preliminary stuff that it's just useful to do for any
  // instruction.
  flatAddress = (regZ< 06000) ? regZ : flatten(regBank, regZ);
  // Increment Z to next location.
  lastZ = regZ;
  incrementZ(1);
  lastINDEX = agc.INDEX;
  // I believe this generates the correct UC bit and sign bit.
  if ((agc.INDEX & 040000) == 0)
    instruction = agc.memory[flatAddress] + agc.INDEX;
  else
    instruction = agc.memory[flatAddress] - (077777 & ~agc.INDEX);
  instruction &= 0177777;

  resumeFromInterrupt:;


  agc.INDEX = 0;
  opcode = instruction & 0170000;
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
  if (opcode == 000000) /* TC */
    {
      // Recall that Q, Z, and the instruction we generated above are
      // correctly set up vis-a-vis the 16th bit.
      regQ= regZ;
      regZ= instruction;
      numMCT = 1;
    }
  else if (opcode == 010000) /* CCS */
    {
      if (operand >= 06000) implementationError("CCS accessing fixed memory.");
      else
        {
          uint16_t K;
          // Arrange to jump.  Recall that Z already points to the next
          // instruction.
          K = (operand >= 04) ? fetchedFromOperand : fixUcForWriting(fetchedFromOperand);
          if (K == 000000) incrementZ(1); // +0
          else if (0 == (K & 040000)) incrementZ(0); // >0
          else if (K == 077777) incrementZ(3); // -0
          else incrementZ(2); // < 0
          // Compute the "diminished absolute value" of c(K).
          if (0 != (K & 040000)) K = -(~K); // Absolute value.
          if (K > 1)
            K--;
          regA = K;
        }
    }
  else if (opcode == 020000) /* INDEX */
    {
      if (operand == 016) regInhint = 0;
      else if (operand == 017) regInhint = 1;
      else if (operand == 025) implementationError("Unimplemented operand RESUME");
      else agc.INDEX = fetchedFromOperand;
    }
  else if (opcode == 030000) /* XCH (erasable) or CAF (fixed). */
    {
      writeToErasableOrRegister(operand, fixUcForWriting(regA), 0);
      regA = fetchedFromOperandSignExtended;
    }
  else if (opcode == 040000) /* CS. */
    {
      regA = (~fetchedFromOperandSignExtended) & 0177777;
    }
  else if (opcode == 050000) /* TS. */
    {
      if (operand >= 06000) implementationError("TS accessing fixed memory.");
      else
        {
          if (fetchedOperandOverflow == 0000000 || fetchedOperandOverflow == 0140000)
            {
              // No overflow.
              writeToErasableOrRegister(operand, regA, 0);
            }
          else
            {
              // Overflow.
              incrementZ(1);
              if (0 & (fetchedOperandOverflow & 0100000)) regA = 0000001;// Positive overflow.
              else regA = 0177776;// Negative overflow;
            }
        }
    }
  else if (opcode == 060000) /* AD. */
    {
      // FIXME Not sure what's supposed to happen if A already has
      // overflowed.  For now, let's make sure it hasn't.
      int term1, term2, sum;
      entrySubtraction:;
      term1 = fixUcForWriting(regA);
      if ((term1 & 040000) != 0) term1 = -(~term1);
      term2 = fetchedFromOperand;
      if ((term2 & 040000) != 0) term2 = -(~term2);
      sum = term1 + term2;
      if (sum < 0 ) sum = (~(-sum)) & 0177777;
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
    }
  else if (opcode == 070000) /* MASK. */
    {
      regA &= fetchedFromOperandSignExtended;
    }
  else if (opcode == 0100000) /* MP */
    {
      numMCT = 10;

      implementationError("MP not implemented yet.");
    }
  else if (opcode == 0110000) /* DV */
    {
      numMCT = 18;

      implementationError("DV not implemented yet.");
    }
  else if (opcode == 0120000) /* SU */
    {
      numMCT += 2;
      fetchedFromOperand = (~fetchedFromOperand) & 077777;
      goto entrySubtraction;
    }
  else
    {
      char message[64];
      sprintf (message, "Unimplemented opcode %06o", opcode);
      implementationError(message);
    }

  agc.countMCT += numMCT;
}

