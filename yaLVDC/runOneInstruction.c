/*
 * Copyright 2019 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * yaAGC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with yaAGC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Filename:    runOneInstruction.c
 * Purpose:     Emulates one instruction for yaLVDC.c, using the global state
 * 		structure. Also provides various related utility functions that
 * 		I think might be useful for an LVDC debugger.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-20 RSB  Began.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "yaLVDC.h"

//////////////////////////////////////////////////////////////////////////////

// Parse the fields of a HOP constant.  Return 0 on success, 1 on failure.
// The input hopConstant is in the form it resides in data memory ... i.e.,
// left-aligned at bit 27,  though the constant itself is 26 bits.  Returns
// 0 on success, 1 on failure, the latter of which can occur if the input
// hopConstant isn't formatted correctly.
int
parseHopConstant(int hopConstant, hopStructure_t *hopStructure)
{
  int retVal = 1;

  if ((hopConstant & ~0777577776) != 0)
    {
      //pushErrorMessage("Corrupted HOP constant", NULL);
      printf ("Corrupted HOP constant %09o\n", hopConstant >> 1);
      goto done;
    }
  hopStructure->im = ((hopConstant >> 26) & 1) | (hopConstant & 6);
  hopStructure->is = (hopConstant >> 3) & 017;
  hopStructure->s = (hopConstant >> 7) & 1;
  hopStructure->loc = (hopConstant >> 8) & 0377;
  hopStructure->dupdn = (hopConstant >> 17) & 1;
  hopStructure->dm = (hopConstant >> 18) & 7;
  hopStructure->ds = (hopConstant >> 21) & 017;
  hopStructure->dupin = (hopConstant >> 25) & 1;

  retVal = 0;
  done: ;
  return (retVal);
}

// Inverse operation of parseHopConstant():  Namely, form a HOP constant from
// a hop structure.  Returns 0 on success and 1 on failure.
int
formHopConstant(hopStructure_t *hopStructure, int *hopConstant)
{
  int retVal = 1;

  if (hopStructure->im > 7)
    goto done;
  *hopConstant = (hopStructure->im & 06) | ((hopStructure->im & 1) << 26);
  if (hopStructure->is > 017)
    goto done;
  *hopConstant |= hopStructure->is << 3;
  if (hopStructure->s > 1)
    goto done;
  *hopConstant |= hopStructure->s << 7;
  if (hopStructure->loc > 0377)
    goto done;
  *hopConstant |= hopStructure->loc << 8;
  if (hopStructure->dupdn > 1)
    goto done;
  *hopConstant |= hopStructure->dupdn << 17;
  if (hopStructure->dm > 7)
    goto done;
  *hopConstant |= hopStructure->dm << 18;
  if (hopStructure->ds > 017)
    goto done;
  *hopConstant |= hopStructure->ds << 21;
  if (hopStructure->dupin > 1)
    goto done;
  *hopConstant |= hopStructure->dupin << 25;

  retVal = 0;
  done: ;
  return (retVal);
}

//////////////////////////////////////////////////////////////////////////////
// Fetch a data word from core memory.  Because it is "data", we first try to
// fetch it from data memory, and only fall back to fetching it from
// instruction memory if that fails.  (Recall that in our internal structures
// we pretend there's a separate "instruction memory" and "data memory" space,
// even though physically the same.)  If that happens, we set a flag
// (dataFromInstructinMemory) so that the calling code can deal with it if
// appropriate, but it's not treated as an error.  If location is treated as
// empty in both data and instruction memory, however, it is treated as an
// error.
//
// Note that address 0775 is treated as a special case, since the data comes
// from the CPU's PQ register rather than from memory.

int
fetchData(int module, int residual, int sector, int loc, int16_t *data,
    int *dataFromInstructionMemory)
{
  int retVal = 1;

  *dataFromInstructionMemory = 0;

  if (residual)
    {
      if (!ptc && loc == 0375)
        {
          *data = state.pq;
          return (0);
        }
      sector = 017;
      if (ptc)
        module = 0;
    }
  *data = state.core[module][sector][2][loc];
  if (*data == -1)
    {
      int16_t fetch1, fetch0;
      fetch1 = state.core[module][sector][1][loc];
      fetch0 = state.core[module][sector][0][loc];
      if (fetch0 == -1 || fetch1 == -1)
        {
          //pushErrorMessage("Fetching data from empty location", NULL);
          printf ("Fetching data from empty location %o-%02o-%03o\n", module, sector, loc);
          runNextN = 0;
          goto done;
        }
      *data = (fetch1 << 12) + fetch0;
      *dataFromInstructionMemory = 1;
    }

  retVal = 0;
  done: ;
  return (retVal);
}

// And similarly, write a word to data memory.  If there's already something
// in that address of "instruction memory" (which is physically the same space),
// get rid of what's in instruction and set a flag (dataOverwritesInstructionMemory)
// to tell the calling software that's what happened (in case it's interested
// in that info).
//
// Note that addresses 0775, 0776, and 0777 are treated as special cases.  For
// 0775, the data destination is the CPU's PQ register rather than memory.
// For 0776 or 0777, the data from the function argument is overridden and
// state.returnAddress is used instead if appropriate.  This happens if the
// preceding instruction was a HOP, and thus state.returnAddress holds the
// return address of the HOP.
int
storeData(int module, int residual, int sector, int loc, int16_t data,
    int *dataOverwritesInstructionMemory)
{
  int retVal = 1;

  *dataOverwritesInstructionMemory = 0;

  if (residual)
    {
      if (loc == 0375)
        {
          state.pq = data;
          return (0);
        }
      else if (state.returnAddress != -2 && (loc == 0376 || loc == 0377))
        data = state.returnAddress;
      sector = 017;
    }
  state.core[module][sector][2][loc] = data;
  if (state.core[module][sector][1][loc] != -1
      || state.core[module][sector][0][loc] != -1)
    {
      state.core[module][sector][1][loc] = -1;
      state.core[module][sector][0][loc] = -1;
      *dataOverwritesInstructionMemory = 1;
    }

  retVal = 0;
  //done: ;
  return (retVal);
}

// Fetch the instruction itself.  First try getting it from instruction
// memory; if that fails, get it from data memory and set a flag
// (instructionFromDataMemory) for optional use by the calling code.
int
fetchInstruction(int module, int residual, int sector, int syllable, int loc,
    uint16_t *instruction, int *instructionFromDataMemory)
{
  int retVal = 1;
  *instructionFromDataMemory = 0;
  if (residual)
    sector = 017;
  *instruction = state.core[module][sector][syllable][loc];
  if (*instruction == -1)
    {
      int fetchedData;
      fetchedData = state.core[module][sector][2][loc];
      if (fetchedData == -1)
        {
          //pushErrorMessage("Cannot fetch instruction from empty address", NULL);
          printf ("Cannot fetch instruction from empty address\n");
          goto done;
        }
      *instructionFromDataMemory = 1;
      if (syllable == 1)
        *instruction = (fetchedData >> 12) & 077774;
      else
        *instruction = fetchedData & 037776;
    }
  // Right-align the instruction to normalize it.  (Recall that instructions
  // in syllables 0 and 1 are aligned differently in our memory buffer.)
  if (syllable == 0)
    *instruction = *instruction >> 1;
  else
    *instruction = *instruction >> 2;

  retVal = 0;
  done: ;
  return (retVal);
}

//////////////////////////////////////////////////////////////////////////////
// The top-level function in this file.  Emulates a single instruction.

// The return value is 0 on success, non-zero on failure.  The cyclesUsed
// argument is used to report the number of computer cycles actually used while
// emulating the instruction, which is usually 1.
int instructionFromDataMemory = 0;
int dataFromInstructionMemory = 0;
int dataOverwritesInstructionMemory = 0;
int
runOneInstruction(int *cyclesUsed)
{
  int retVal = 1;
  int cycleCount = 1, nextLOC, nextS, isHOP = 0;
  int64_t dummy;  // For multiplication intermediate result.
  hopStructure_t hopStructure, rawHopStructure;
  uint16_t instruction;
  uint8_t op, operand, residual;
  int16_t fetchedFromMemory;
  int modOperand = 0;

  // Set global variables providing background info on the emulation.
  dataFromInstructionMemory = 0;
  instructionFromDataMemory = 0;

  // Find current instruction address and data-sector environment, by parsing
  // the HOP register to find its various fields.
  if (parseHopConstant(state.hop, &hopStructure))
    {
      //pushErrorMessage("Cannot interpret current instruction address", NULL);
      printf ("Cannot interpret current instruction address (HOP=%09o)\n", state.hop >> 1);
      runNextN = 0;
      goto done;
    }
  memcpy(&rawHopStructure, &hopStructure, sizeof(hopStructure_t));
  // What would the next instruction location be in the normal course of events?
  // Only the LOC field of the HOP constant is involved, but we'll track the S
  // field as well, to facilitate working with TRA, TNZ, and TMI later.
  nextLOC = hopStructure.loc;
  nextS = hopStructure.s;
  if (hopStructure.loc != 0377)
    nextLOC += 1;

  if (fetchInstruction(hopStructure.im, 0, hopStructure.is, hopStructure.s,
      hopStructure.loc, &instruction, &instructionFromDataMemory))
    goto done;

  // If this instruction turns out to be an EXM, it means that we'll have to
  // repeat all the steps below for the instruction EXM will want to execute,
  // so an EXM will end up just jumping back to here.
  if (0)
    {
      const uint8_t dss[] =
        { 004, 014, 005, 015, 006, 016, 007, 017 };
      reenterForEXM: ;
      cycleCount += 1;
      // Note that hopStructure is used for executing the instruction, but
      // not for generating the hopConstant beyond this one instruction, so
      // we can change it temporarily here without side effects.
      hopStructure.ds = dss[(instruction >> 4) & 7];
    }

  // Parse instruction into fields.
  op = instruction & 017;
  residual = (instruction >> 4) & 1;
  operand = (instruction >> 5) & 0377;
  if (op == 016)
    {
      op = instruction & 037;
      residual = 0;
    }
  if (op == 036)
    {
      op = op | ((instruction >> 7) & 040);
      operand = operand & 0177;
      residual = 0;
    }
  operand = (operand & ~3) | modOperand;
  modOperand = 0;

  // Execute the instruction.
  switch (op)
    {
  case 000:  // HOP
    isHOP = 1;
    if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
        &fetchedFromMemory, &dataFromInstructionMemory))
      {
        //pushErrorMessage("HOP to empty location", NULL);
        printf ("HOP to empty location\n");
        runNextN = 0;
        goto done;
      }
    state.hop = fetchedFromMemory;
    break;
  case 001:  // MPY
  case 005:  // MPH
    // The actual LVDC had a pretty complex behavior with this instruction,
    // in that the full 26-bit result would become available 4 cycles later,
    // but after 2 cycles you could fetch the less-significant word of the
    // result from PQ.  At least at first, I'm not going to implement it that
    // way, and I'll just provide the full result in PQ immediately.  I don't
    // see a problem with doing that.
    if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
        &fetchedFromMemory, &dataFromInstructionMemory))
      goto done;
    // Recall that only the most-significant 24 bits of the multiplicands
    // are used by the CPU, and that the data is left-aligned at bit 27.
    // The variable called "dummy" is 64-bit, and so is big enough to hold
    // the 54-bit result temporarily.
    dummy = (fetchedFromMemory & 0777777770) * (state.acc & 0777777770);
    state.pq = (dummy >> 27LL) & 0777777776;
    if (op == 005)
      cycleCount = 5;
    break;
  case 002:  // SUB
    if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
        &fetchedFromMemory, &dataFromInstructionMemory))
      goto done;
    state.acc = (state.acc - fetchedFromMemory) & 0777777776;
    break;
  case 003:  // DIV
    // This operation divides a 26-bit value in the accumulator by a
    // 24(?) bit value from memory, producing a 24-bit quotient in PQ.
    // I left align the value from the accumulator in a 64-bit int first,
    // to get the signs right.
    dummy = state.acc;
    dummy = dummy << 37;
    if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
        &fetchedFromMemory, &dataFromInstructionMemory))
      goto done;
    dummy /= (fetchedFromMemory & 0777777770) << 10;
    state.pq = (dummy >> 10) & 0777777770;
    break;
  case 004:  // TNZ
    if (state.acc != 0)
      {
        nextLOC = operand;
        nextS = residual;
      }
    break;
  case 006:  // AND
    if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
        &fetchedFromMemory, &dataFromInstructionMemory))
      goto done;
    state.acc &= fetchedFromMemory;
    break;
  case 007:  // ADD
    if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
        &fetchedFromMemory, &dataFromInstructionMemory))
      goto done;
    state.acc = (state.acc + fetchedFromMemory) & 0777777776;
    break;
  case 010:  // TRA
    nextLOC = operand;
    nextS = residual;
    break;
  case 011:  // XOR
    if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
        &fetchedFromMemory, &dataFromInstructionMemory))
      goto done;
    state.acc = (state.acc ^ fetchedFromMemory) & 0777777776;
    break;
  case 012:  // PIO
    // Determine direction of data flow.  If the least-significant 2 bits of
    // the operand are 11, then the data flows into the accumulator.
    // Otherwise, the accumulator is the source of the data.
    // Obviously, the operation involves more than simply manipulating the
    // pio[] array's data, but that's a starting point.
    if ((operand & 3) == 3)
      {
        state.acc = state.pio[operand];
      }
    else
      {
        state.pio[operand] = state.acc;
      }
    break;
  case 013:  // STO
    storeData(hopStructure.dm, residual, hopStructure.ds, operand, state.acc,
        &dataOverwritesInstructionMemory);
    break;
  case 014:  // TMI
    // Since the accumulator is only 27 bits, it won't fill the int32_t
    // it's stored in, and hence we can't just check if it's negative.
    // However, it's stored in 2's-complement form, and if we assume that the
    // CPU running the emulator is also 2's-complement (which has been a good
    // assumption for at least the last 40 years), we can simply check its
    // most-significant (27th) bit.
    if ((state.acc & 0400000000) != 0)
      {
        nextLOC = operand;
        nextS = residual;
      }
    break;
  case 015:  // RSU
    if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
        &fetchedFromMemory, &dataFromInstructionMemory))
      goto done;
    state.acc = (fetchedFromMemory - state.acc) & 0777777776;
    break;
  case 016:  // CDS
    rawHopStructure.dm = (operand >> 1) & 07;
    rawHopStructure.ds = (operand >> 4) & 017;
    rawHopStructure.dupdn = operand & 1;
    break;
  case 017:  // CLA
    if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
        &fetchedFromMemory, &dataFromInstructionMemory))
      goto done;
    state.acc = fetchedFromMemory;
    break;
  case 036:  // SHF
    switch (operand)
      {
    case 000:
      state.acc = 0;
      break;
    case 001:
      state.acc = state.acc >> 1;
      break;
    case 002:
      state.acc = state.acc >> 2;
      break;
    case 020:
      state.acc = state.acc << 1;
      break;
    case 040:
      state.acc = state.acc << 2;
      break;
    default:
      //pushErrorMessage("Illegal SHF instruction", NULL);
      printf ("Illegal SHF instruction\n");
      goto done;
      }
    break;
  case 076:  // EXM
    {
      const uint8_t locs[] =
        { 0200, 0240, 0300, 0340 };
      int syllable;
      uint8_t loc;
      modOperand = operand & 017;
      syllable = (operand >> 4) & 1;
      loc = locs[(operand >> 5) & 3];
      if (fetchInstruction(hopStructure.im, 1, hopStructure.is, syllable, loc,
          &instruction, &instructionFromDataMemory))
        goto done;
      goto reenterForEXM;
    }
  default:
    //pushErrorMessage("Implementation error", NULL);
    printf ("Implementation error\n");
    runNextN = 0;
    goto done;
    }

  // Fix up state.hop and state.returnAddress for the next instruction.
  rawHopStructure.loc = nextLOC;
  rawHopStructure.s = nextS;
  if (isHOP)
    {
      // state.hop has already been set, above.
      if (formHopConstant(&rawHopStructure, &state.returnAddress))
        goto done;
    }
  else
    {
      if (formHopConstant(&rawHopStructure, &state.hop))
        goto done;
      state.returnAddress = -2;
    }

  *cyclesUsed = cycleCount;
  retVal = 0;
  done: ;
  return (retVal);
}
