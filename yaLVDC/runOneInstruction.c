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
#include <string.h>
#include "yaLVDC.h"

//////////////////////////////////////////////////////////////////////////////

// Parse the fields of a HOP constant.  Return 0 on success, 1 on failure.
// The input hopConstant is in the form it resides in data memory ... i.e.,
// left-aligned at bit 27,  though the constant itself is 26 bits.
int
parseHopConstant (int hopConstant, hopStructure_t *hopStructure)
{
  int retVal = 1;

  if ((hopConstant & ~777577776) != 0)
    {
      pushErrorMessage ("Corrupted HOP constant", NULL);
      goto done;
    }
  hopStructure->im = ((hopConstant >> 26) & 1) | (hopConstant & 6);
  hopStructure->is = (hopConstant >> 3) & 017;
  hopStructure->s = (hopConstant >> 7) & 1;
  hopStructure->loc = (hopConstant >> 8) & 0377;
  hopStructure->dupdn = (hopConstant >> 17) & 1;
  hopStructure->dm = (hopConstant >> 18) & 7;
  hopStructure->ds = (hopConstant >> 21) & 017;
  hopStructure->ds = (hopConstant >> 25) & 1;

  retVal = 0;
  done: ;
  return (retVal);
}

// Inverse operation of parseHopConstant():  Namely, form a HOP constant from
// a hop structure.  I'm not going to bother yet with sanity checks on the
// input parameters, and therefore the function cannot yet fail.
int
formHopConstant (hopStructure_t *hopStructure, int *hopConstant)
{
  int retVal = 1;

  *hopConstant = (hopStructure->im & 06) | ((hopStructure->im & 1) << 26);
  *hopConstant |= hopStructure->is << 3;
  *hopConstant |= hopStructure->s << 7;
  *hopConstant |= hopStructure->loc << 8;
  *hopConstant |= hopStructure->dupdn << 17;
  *hopConstant |= hopStructure->dm << 18;
  *hopConstant |= hopStructure->ds << 21;
  *hopConstant |= hopStructure->dupin << 25;

  retVal = 0;
  //done: ;
  return (retVal);
}

//////////////////////////////////////////////////////////////////////////////
// Fetch a data word from core memory.  Because it is "data", we first try to
// fetch it from data memory, and only fall back to fetching it from
// instruction memory if that fails.  If that happens, we set a flag
// (dataFromInstructinMemory) so that the calling code can deal with it if
// appropriate, but it's not treated as an error.  If location is treated as
// empty in both data and instruction memory, however, it is treated as an
// error.

int
fetchData (int module, int residual, int sector, int loc, int16_t *data,
	   int *dataFromInstructionMemory)
{
  int retVal = 1;

  *dataFromInstructionMemory = 0;
  if (residual)
    sector = 017;
  *data = state.core[module][sector][2][loc];
  if (*data == -1)
    {
      int16_t fetch1, fetch0;
      fetch1 = state.core[module][sector][1][loc];
      fetch0 = state.core[module][sector][0][loc];
      if (fetch0 == -1 || fetch1 == -1)
	goto done;
      *data = (fetch1 << 12) + fetch0;
      *dataFromInstructionMemory = 1;
    }

  retVal = 0;
  done: ;
  return (retVal);
}

// And similarly, write a word to data memory.
int
storeData (int module, int residual, int sector, int loc, int16_t data,
	   int *dataOverwritesInstructionMemory)
{
  int retVal = 1;

  *dataOverwritesInstructionMemory = 0;
  if (residual)
    sector = 017;
  state.core[module][sector][2][loc] = data;
  if (state.core[module][sector][1][loc] != -1 || state.core[module][sector][0][loc] != -1)
    {
      state.core[module][sector][1][loc] = -1;
      state.core[module][sector][0][loc] = -1;
      *dataOverwritesInstructionMemory = 1;
    }

  retVal = 0;
  //done: ;
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
runOneInstruction (int *cyclesUsed)
{
  int retVal = 1;
  int cycleCount = 1, nextAddress;
  hopStructure_t hopStructure;
  uint16_t instruction;
  uint8_t op, operand, residual;

  // Set global variables providing background info on the emulation.
  dataFromInstructionMemory = 0;
  instructionFromDataMemory = 0;

  // Find current instruction address and data-sector environment.
  if (parseHopConstant (state.hop, &hopStructure))
    {
      pushErrorMessage ("Cannot interpret current instruction address", NULL);
      goto done;
    }
  nextAddress = hopStructure.loc;
  if (hopStructure.loc == 0377)
    nextAddress = -2;
  else
    nextAddress += 0400;

  // Fetch the instruction itself.  First try getting it from instruction
  // memory; if that fails, get it from data memory and set a flag
  // (instructionFromDataMemory) for optional use by the calling code.
  instruction =
      state.core[hopStructure.im][hopStructure.is][hopStructure.s][hopStructure.loc];
  if (instruction == -1)
    {
      int fetchedData;
      fetchedData =
	  state.core[hopStructure.im][hopStructure.is][2][hopStructure.loc];
      if (fetchedData == -1)
	{
	  pushErrorMessage ("Cannot fetch instruction from empty address",
			    NULL);
	  goto done;
	}
      instructionFromDataMemory = 1;
      if (hopStructure.s == 1)
	fetchedData = (fetchedData >> 12) & 077774;
      else
	fetchedData = fetchedData & 037776;
    }

  // Right-align the instruction to normalize it.  (Recall that instructions
  // in syllables 0 and 1 are aligned differently in our memory buffer.)
  if (hopStructure.s == 0)
    instruction = instruction >> 2;
  else
    instruction = instruction >> 1;

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

  // Execute the instruction.
  switch (op)
    {
    int16_t fetchedFromMemory;
  case 000:  // HOP
    if (fetchData (hopStructure.dm, residual, hopStructure.dm, operand,
		   &fetchedFromMemory, &dataFromInstructionMemory))
      {
	pushErrorMessage ("HOP to empty location", NULL);
	goto done;
      }
    state.hop = fetchedFromMemory;
    state.returnAddress = nextAddress;
    break;
  case 001:  // MPY

    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 002:  // SUB
    if (fetchData (hopStructure.dm, residual, hopStructure.dm, operand,
		   &fetchedFromMemory, &dataFromInstructionMemory))
      {
	pushErrorMessage ("Fetching data from empty location", NULL);
	goto done;
      }
    state.acc = (state.acc - fetchedFromMemory) & 0777777776;
    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 003:  // DIV

    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 004:  // TNZ
    if (state.acc == 0)
      state.hop = nextAddress;
    else
      {
	hopStructure.loc = operand;
	hopStructure.s = residual;
	if (formHopConstant (&hopStructure, &state.hop))
	  goto done;
      }
    state.returnAddress = -2;
    break;
  case 005:  // MPH

    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 006:  // AND
    if (fetchData (hopStructure.dm, residual, hopStructure.dm, operand,
		   &fetchedFromMemory, &dataFromInstructionMemory))
      {
	pushErrorMessage ("Fetching data from empty location", NULL);
	goto done;
      }
    state.acc &= fetchedFromMemory;
    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 007:  // ADD
    if (fetchData (hopStructure.dm, residual, hopStructure.dm, operand,
		   &fetchedFromMemory, &dataFromInstructionMemory))
      {
	pushErrorMessage ("Fetching data from empty location", NULL);
	goto done;
      }
    state.acc = (state.acc + fetchedFromMemory) & 0777777776;
    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 010:  // TRA
    hopStructure.loc = operand;
    hopStructure.s = residual;
    if (formHopConstant (&hopStructure, &state.hop))
      goto done;
    state.returnAddress = -2;
    break;
  case 011:  // XOR
    if (fetchData (hopStructure.dm, residual, hopStructure.dm, operand,
		   &fetchedFromMemory, &dataFromInstructionMemory))
      {
	pushErrorMessage ("Fetching data from empty location", NULL);
	goto done;
      }
    state.acc = (state.acc ^ fetchedFromMemory) & 0777777776;
    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 012:  // PIO

    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 013:  // STO
    storeData (hopStructure.dm, residual, hopStructure.dm, operand,
		   state.acc, &dataOverwritesInstructionMemory);
    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 014:  // TMI
    if (state.acc >= 0)
      state.hop = nextAddress;
    else
      {
	hopStructure.loc = operand;
	hopStructure.s = residual;
	if (formHopConstant (&hopStructure, &state.hop))
	  goto done;
      }
    state.returnAddress = -2;
    break;
  case 015:  // RSU
    if (fetchData (hopStructure.dm, residual, hopStructure.dm, operand,
		   &fetchedFromMemory, &dataFromInstructionMemory))
      {
	pushErrorMessage ("Fetching data from empty location", NULL);
	goto done;
      }
    state.acc = (fetchedFromMemory - state.acc) & 0777777776;
    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 016:  // CDS

    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 017:  // CLA
    if (fetchData (hopStructure.dm, residual, hopStructure.dm, operand,
		   &fetchedFromMemory, &dataFromInstructionMemory))
      {
	pushErrorMessage ("Fetching data from empty location", NULL);
	goto done;
      }
    state.acc = fetchedFromMemory;
    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 036:  // SHF

    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  case 076:  // EXM

    state.hop = nextAddress;
    state.returnAddress = -2;
    break;
  default:
    pushErrorMessage ("Implementation error", NULL);
    goto done;
  }

*cyclesUsed = cycleCount;
retVal = 0;
done: ;
return (retVal);
}
