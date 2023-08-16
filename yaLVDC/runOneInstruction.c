/*
 * Copyright 2019,2020 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    runOneInstruction.c
 * Purpose:     Emulates one instruction for yaLVDC.c, using the global state
 * 		structure. Also provides various related utility functions that
 * 		I think might be useful for an LVDC debugger.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-20 RSB  Began.
 *              2020-06-05 RSB  Fixes for various bugs discovered in running
 *                              self-test procedures from the PAST program:
 *                              1)  SHL instructions were producing results
 *                                  >26 bits in ACC, causing subsequent TMI
 *                                  or TNZ instructions to fail.
 *                              2)  A side effect of PRS sourced from memory
 *                                  is supposed to be that the data goes into
 *                                  ACC.
 *                              3)  Assigned "spare" CIO 175 as an input port
 *                                  rather than an output port.
 *              2023-07-16 MAS  Fixes for various bugs affecting only the LVDC:
 *                              1)  CDS should not require A8 to be 0.
 *                              2)  MPH was not loading the accumulator with PQ.
 *                              3)  MPH/MPY were producing incorrect results;
 *                                  they have been replaced with a simple
 *                                  implementation of the algorithm used by the
 *                                  LVDC.
 *              2023-07-28 MAS  More LVDC fixes:
 *                              1)  MPY and DIV now continuously update PQR util
 *                                  they are complete.
 *                              2)  The partial product of the multiplicand with
 *                                  the lower 12 bits of the accumulator available
 *                                  the second instruction after MPY is scaled
 *                                  differently from the final product. This
 *                                  difference is now accounted for.
 *                              3)  Scaling in DIV has been corrected to produce
 *                                  correct results.
 *              2023-07-29 MAS  Replaced the implementation of DIV with a simulation
 *                              of the non-restoring division algorithm implemented
 *                              by the hardware. This was necessary to achieve
 *                              consistent agreement with hardware simulation
 *                              division results.
 *              2023-07-30 MAS  Corrected various bugs in the implementation of EXM.
 *              2023-08-01 MAS  Lots of changes related to PIO and interrupts.
 *                              1)  The automatic HOP save now stores a HOP constant
 *                                  with a LOC of 0 unless a branch was taken, in
 *                                  which case the pre-branch nextLOC is used.
 *                              2)  TRA, TMI, and TNZ no longer inhibit interrupts
 *                                  for one cycle.
 *                              3)  EXM no longer uses the interrupt inhibit feature
 *                                  because although it *does* inhibit interrupts
 *                                  for one instruction, the current EXM implementation
 *                                  forces both cycles to occur in the same call to
 *                                  runOneInstruction().
 *                              4)  The one-cycle interrupt inhibit has been changed
 *                                  to a counter, which is now used by HOP, MPY,
 *                                  MPH, and DIV.
 *                              5)  Interrupts are now delayed by one cycle from
 *                                  when they were first detected.
 *                              6)  Interrupts now force a real HOP instruction to
 *                                  happen. The same mechanism that was being used
 *                                  for EXM is now also used for this forced HOP
 *                                  instruction.
 *                              7)  Bits 8 and 9 of LVDA PIO instructions are no
 *                                  longer used in channel selection (they only
 *                                  determine if the accumulator or memory are the
 *                                  source of the data being sent to the LVDA).
 *              2023-08-02 MAS  Moved PQR countdown to the start of runOneInstruction
 *                              and positioned the reenterForEXM label such that both
 *                              this countdown and the interrupt inhibit one are
 *                              re-executed for EXM's second cycle.
 *              2023-08-05 RSB  Moved PIO logging from processInterruptsAndIO.c
 *                              to here.  I was obliged to change the internal
 *                              variable cycleCount in the runOneInstruction()
 *                              function to deltaCycleCount, because I needed
 *                              to use the global variable cycleCount (same
 *                              name!) for logging.
 *              2023-08-07 RSB  Now automatically flushes the pioLogFile, if
 *                              there's any output pending and it has been
 *                              12K cycles since the last PIO.
 *              2023-08-08 RSB  Restored operation of PIO virtual wire, which
 *                              had been broken.
 *              2023-08-16 RSB  Better error message for instruction from
 *                              empty address.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "yaLVDC.h"

// Different fields of an LVDC/PTC data word.
#define signMask        0200000000
#define dataWordMask    0377777777

//#define DEBUG_A_LOT

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

  if ((!ptc && (hopConstant & 0100000) != 0)
      || (ptc && (hopConstant & 03300003) != 0))
    {
      //pushErrorMessage("Corrupted HOP constant", NULL);
      goto done;
    }
  hopStructure->im = ((hopConstant >> 25) & 1) | ((hopConstant << 1) & 6);
  hopStructure->is = (hopConstant >> 2) & 017;
  hopStructure->s = (hopConstant >> 6) & 1;
  hopStructure->loc = (hopConstant >> 7) & 0377;
  hopStructure->dupdn = (hopConstant >> 16) & 1;
  hopStructure->dm = (hopConstant >> 17) & 7;
  hopStructure->ds = (hopConstant >> 20) & 017;
  hopStructure->dupin = (hopConstant >> 24) & 1;

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
  *hopConstant = ((hopStructure->im >> 1) & 03)
      | ((hopStructure->im & 1) << 25);
  if (hopStructure->is > 017)
    goto done;
  *hopConstant |= hopStructure->is << 2;
  if (hopStructure->s > 1)
    goto done;
  *hopConstant |= hopStructure->s << 6;
  if (hopStructure->loc > 0377)
    goto done;
  *hopConstant |= hopStructure->loc << 7;
  if (hopStructure->dupdn > 1)
    goto done;
  *hopConstant |= hopStructure->dupdn << 16;
  if (hopStructure->dm > 7)
    goto done;
  *hopConstant |= hopStructure->dm << 17;
  if (hopStructure->ds > 017)
    goto done;
  *hopConstant |= hopStructure->ds << 20;
  if (hopStructure->dupin > 1)
    goto done;
  *hopConstant |= hopStructure->dupin << 24;

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

int inhibitFetchMessages = 0;
int
fetchData(int module, int residual, int sector, int loc, int *data,
    int32_t *dataFromInstructionMemory)
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
      // Note that fetching data from a completely-empty location
      // may be an error (or perhaps not?), but that fetching from a
      // partially-empty location is not, since the LVDC/PTC code
      // is self-modifying, and may need to do that to modify the
      // code.  But regardless, we can't actually treat it as an
      // error when operating with the PTC panel, because it's
      // very disruptive to suddenly drop into the native debugger.
      if (fetch0 == -1 && fetch1 == -1)
        {
          if (!inhibitFetchMessages)
            printf("Fetching data from empty location %o-%02o-%03o\n", module,
                sector, loc);
          if (!ptc)
            {
              runStepN = 0;
              goto done;
            }
          *data = 0;
        }
      else
        {
          if (fetch0 == -1)
            fetch0 = 0;
          if (fetch1 == -1)
            fetch1 = 0;
          *data = (fetch1 << 13) + fetch0;
          *dataFromInstructionMemory = 1;
        }
    }

#ifdef DEBUG_A_LOT
  printf("Fetched %09o from %o-%02o-%03o\n", *data, module, sector, loc);
#endif

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
// state.hopSaver is used instead if appropriate.  This happens if the
// preceding instruction was a HOP, and thus state.hopSaver holds the
// return address of the HOP.
int
storeData(int module, int residual, int sector, int loc, int data,
    int32_t *dataOverwritesInstructionMemory)
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
      else if (loc == 0376 || loc == 0377)
        data = state.hopSaver;
      if (ptc)
        module = 0;
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

#ifdef DEBUG_A_LOT
  printf("Stored  %09o to %o-%02o-%03o\n", data, module, sector, loc);
#endif

  retVal = 0;
  //done: ;
  return (retVal);
}

// Fetch the instruction itself.  First try getting it from instruction
// memory; if that fails, get it from data memory and set a flag
// (instructionFromDataMemory) for optional use by the calling code.
int
fetchInstruction(int module, int sector, int syllable, int loc,
    uint16_t *instruction, int *instructionFromDataMemory)
{
  int retVal = 1, fetchedData;
  *instructionFromDataMemory = 0;
  fetchedData = state.core[module][sector][syllable][loc];
  if (fetchedData == -1)
    {
      fetchedData = state.core[module][sector][2][loc];
      if (fetchedData == -1)
        {
          if (!inhibitFetchMessages)
            printf("Cannot fetch instruction from empty address %o-%02o-%o-%03o.\n",
                module, sector, syllable, loc);
          goto done;
        }
      *instructionFromDataMemory = 1;
      if (syllable == 1)
        fetchedData = fetchedData >> 13;
      fetchedData &= 017777;
    }

  *instruction = fetchedData;
  retVal = 0;
  done: ;
  return (retVal);
}

// Sign-extend an LVDC/PTC data word to a native signed integer, for computations.
int
convertDataWordToNative(int dataWord)
{
  if ((signMask & dataWord) != 0)
    {
      // This method assumes that the target computer running the
      // LVDC/PTC emulator uses 2's-complement arithmetic.
      dataWord |= ~dataWordMask;
    }
  return dataWord;
}
// Truncate a native signed integer to an LVDC/PTC data word.
int
convertNativeToDataWord(int integer)
{
  // This method assumes that the target computer running the
  // LVDC/PTC emulator uses 2's-complement arithmetic.
  return (integer & dataWordMask);
}

// Calculate the delta 1 term for multiplication
int64_t
mpyDelta1(int multiplier, int multiplicand)
{
  uint8_t bits = multiplier & 07;
  switch (bits)
    {
  case 01:
  case 02:
    return 2 * multiplicand;
  case 03:
    return 4 * multiplicand;
  case 04:
    return -4 * multiplicand;
  case 05:
  case 06:
    return -2 * multiplicand;
  default:
    return 0;
    }
}

// Calculate the delta 2 term for multiplication
int64_t
mpyDelta2(int multiplier, int multiplicand)
{
  uint8_t bits = (multiplier >> 2) & 07;
  switch (bits)
    {
  case 01:
  case 02:
    return 8 * multiplicand;
  case 03:
    return 16 * multiplicand;
  case 04:
    return -16 * multiplicand;
  case 05:
  case 06:
    return -8 * multiplicand;
  default:
    return 0;
    }
}

void
checkForInterrupts(void)
{
  // Check if an interrupt has been triggered.
  if (state.masterInterruptLatch == 0)
    {
      // Interrupt detection happens in a few stages in the LVDA (and
      // presumably also the PTC). Once an interrupt bit has been set,
      // it must first make it past an inhibit mask. If this happens,
      // an "interrupt has occurred" bit is sent into a delay line.
      // This bit emerges 1 LVDC/PTC instruction cycle later, at which
      // point the interrupt latch INTC is set. The output of this latch
      // is applied to the processor, which will handle it as soon as
      // temporary global interrupt inhibits (via HOP, EXM, MPY, MPH, or
      // DIV instructions) are lifted.
      if (ptc)
        {
          int i, intLatch, intInhibit;
          intLatch = state.cio[0154];
          intInhibit = state.interruptInhibitLatches;
          for (i = 0; i < 16;
              i++, intLatch = intLatch << 1, intInhibit = intInhibit >> 1)
            if ((intLatch & 0200000000) != 0 && (intInhibit & 1) == 0)
              break;
          if (i < 16)
            {
              // Send an interrupt bit into the delay line.
              state.masterInterruptLatch = 1;
              state.pendingInterruptIndex = i;
              //printf("Interrupt %d.\n", i + 1);
            }
        }
      else // LVDC
        {
          if (state.pio[0137] & ~(state.pio[072] << 1))
            {
              // Send an interrupt bit into the delay line.
              state.masterInterruptLatch = 1;
              state.pendingInterruptIndex = 0;
            }
        }
    }
  else if (state.masterInterruptLatch == 1)
    {
      // Interrupt bit has emerged from the delay line, and INTC has
      // been set. Trigger an interrupt as soon as possible.
      if (state.inhibitInterruptCycles == 0)
        {
          state.masterInterruptLatch = 2;
          state.pendingInstruction.nextHop = state.hop;
          state.pendingInstruction.pending = 1;
          state.pendingInstruction.pendingHop = state.pendingInstruction.nextHop;
          state.pendingInstruction.instruction = 000020 |
              (state.pendingInterruptIndex << 5);
        }
    }

}

//////////////////////////////////////////////////////////////////////////////
// The top-level function in this file.  Emulates a single instruction.

// The return value is 0 on success, non-zero on failure.  The cyclesUsed
// argument is used to report the number of computer cycles actually used while
// emulating the instruction, which is usually 1.
int instructionFromDataMemory = 0;
int dataFromInstructionMemory = 0;
int dataOverwritesInstructionMemory = 0;
int pioFlushCount = -1;
int
runOneInstruction(int *cyclesUsed)
{
  int retVal = 1;
  int deltaCycleCount = 1, saveLOC, nextLOC, nextS, isHOP = 0;
  int64_t dummy;  // For multiplication intermediate result.
  hopStructure_t hopStructure, rawHopStructure, rawestHopStructure;
  uint16_t instruction, operand9;
  uint8_t op, operand, residual, a8, a9;
  int32_t fetchedFromMemory;

  if (pioFlushCount == 0)
    {
      fflush(pioLogFile);
      pioFlushCount = -1;
    }
  else if (pioFlushCount > 0)
    pioFlushCount -= 1;

  // If we changes any of state.pio[], state.cio[], or state.prs, then
  // the following state.xxxChange variables will be set accordingly to
  // indicate to external code that some action is needed before emulating
  // the next CPU instruction.
  state.pioChange = -1;
  state.cioChange = -1;
  state.prsChange = -1;
  state.lastHop = -1;
  state.riLastHOP = state.hop;
  if (state.busyCountPlotter)
    {
      state.busyCountPlotter--;
      if (!state.busyCountPlotter)
        state.bbPlotter = 0;
    }
  if (state.busyCountPrinter /* && (state.cio[0210] & 035) == 0*/)
    {
      state.busyCountPrinter--;
      if (!state.busyCountPrinter)
        {
          state.bbPrinter = 0;
        };
    }
  if (state.busyCountCarriagePrinter && (state.cio[0210] & 4) == 0)
    {
      state.busyCountCarriagePrinter--;
      if (!state.busyCountCarriagePrinter)
        {
          state.cio210CarrBusy = 0;
        };
    }
  if (state.busyCountTypewriter && (state.cio[0210] & 5) == 0)
    {
      state.busyCountTypewriter--;
      if (!state.busyCountTypewriter)
        {
          if (state.caseChange)
            {
              //printf("CASE %09o %09o %09o ", state.cio[0154], state.currentCaseInterrupt, state.currentTypewriterInterrupt);
              state.caseChange = 0;
              //state.cio[0154] &= ~state.currentCaseInterrupt;
              state.cio[0154] |= state.currentTypewriterInterrupt;
              //printf("-> %09o\n", state.cio[0154]);
              state.busyCountTypewriter = CASE_CHANGE_BUSY_CYCLES;
              dPrintoutsTypewriter("R1I CASE CHANGE");
            }
          else
            {
              state.bbTypewriter = 0;
              dPrintoutsTypewriter("R1I READY");
            }
        }
    }

  state.ai3Shifter = (state.ai3Shifter << 1) & 0377777777;

  // The following relates to how to report back a PRS instruction check-parity
  // bit on the interrupt latch, via a CIO 154.  I'm not sure how this should
  // interact with the regular CIO or PIO instructions for altering the interrupt
  // latch, nor if the data should be available indefinitely.
  if (state.prsParityDelayCount < 3)
    state.prsParityDelayCount++;

  // Set global variables providing background info on the emulation.
  reenterForEXM: ;
  if (state.inhibitInterruptCycles > 0)
    state.inhibitInterruptCycles--;
  dataFromInstructionMemory = 0;
  instructionFromDataMemory = 0;

  if (state.mpyDivCount > 0)
    {
      // Copy ongoing MPY/DIV results into PQ
      state.mpyDivCount--;
      if (state.mpyDivCount > 0)
        state.pq = state.pqPend1;
      else
        state.pq = state.pqPend2;
    }

  if (state.pendingInstruction.pending)
    {
      state.pendingInstruction.pending = 0;
      state.hop = state.pendingInstruction.pendingHop;
      if (parseHopConstant(state.hop, &hopStructure))
        {
          printf("Cannot interpret current instruction address (HOP=%09o)\n",
              state.hop);
          runStepN = 0;
          goto done;
        }
      if (parseHopConstant(state.pendingInstruction.nextHop, &rawHopStructure))
        {
          printf("Cannot interpret next instruction address (HOP=%09o)\n",
              state.pendingInstruction.nextHop);
          runStepN = 0;
          goto done;
        }
      nextLOC = rawHopStructure.loc;
      nextS = rawHopStructure.s;
      instruction = state.pendingInstruction.instruction;
    }
  else
    {
      // Find current instruction address and data-sector environment, by parsing
      // the HOP register to find its various fields.
      if (parseHopConstant(state.hop, &hopStructure))
        {
          //pushErrorMessage("Cannot interpret current instruction address", NULL);
          printf("Cannot interpret current instruction address (HOP=%09o)\n",
              state.hop);
          runStepN = 0;
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

      if (fetchInstruction(hopStructure.im, hopStructure.is, hopStructure.s,
          hopStructure.loc, &instruction, &instructionFromDataMemory))
        goto done;
    }
  memcpy(&rawestHopStructure, &rawHopStructure, sizeof(hopStructure_t));
  state.riLastInstruction = instruction;

  // Parse instruction into fields.
  state.lastInstruction = instruction;
  op = instruction & 017;
  a9 = (instruction >> 4) & 1;
  operand = (instruction >> 5) & 0377;
  a8 = (operand >> 7) & 1;
  residual = a9;
  operand9 = operand | (a9 << 8);

  // Execute the instruction.
  if (op == 000)
    {
      // HOP
      isHOP = 1;
      state.inhibitInterruptCycles = 1;
      if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
          &fetchedFromMemory, &dataFromInstructionMemory))
        {
          //pushErrorMessage("HOP to empty location", NULL);
          printf("HOP to empty location\n");
          runStepN = 0;
          goto done;
        }
#ifdef DEBUG_A_LOT
      printf("HOP %o-%02o-%o-%02o %09o\n", hopStructure.dm, residual, hopStructure.ds, operand, fetchedFromMemory);
#endif
      state.lastHop = state.hop;
      state.hop = fetchedFromMemory;
      saveLOC = nextLOC;
    }
  else if (!ptc && (op == 001 || op == 005))
    {
      // MPY or MPH
      // The actual LVDC had a pretty complex behavior with this instruction,
      // in that the full 26-bit result would become available 4 cycles later,
      // but after 2 cycles you could fetch the partial product of the
      // multiplicand with the lower 12 bits of the accumulator. This product
      // is formed as if these 12 bits were shifted up to be the most significant
      // bits of the accumulator rather than their real position.
      if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
          &fetchedFromMemory, &dataFromInstructionMemory))
        goto done;

      // The following is a simple implementation of the algorithm used by
      // the LVDC for multiplication. This is done instead of using native
      // multiplication because the latter sometimes produces off-by-one
      // results from this approach, presumably due to differences in
      // precision.
      int multiplier = (state.acc >> 1) & ~1;
      int multiplicand = convertDataWordToNative(fetchedFromMemory) & ~3;
      dummy = 0;
      for (uint8_t i = 0; i < 6; i++)
        {
          dummy += mpyDelta2(multiplier, multiplicand) +
                   mpyDelta1(multiplier, multiplicand);
          dummy >>= 4;
          multiplier >>= 4;
          if (i == 2)
            state.pqPend1 = dummy & dataWordMask;
        }
      state.pqPend2 = dummy & dataWordMask;

      // MPH stops execution for five cycles, and automatically loads PQ
      // into the accumulator at the end.
      if (op == 005)
        {
          deltaCycleCount = 5;
          state.mpyDivCount = 1;
          state.acc = state.pqPend2;
          // A slight quirk of MPY is that even though it completed in
          // five cycles, interrupts are inhibited for one more cycle after
          // it completes. In other words, an interrupt can never come in
          // immediately following an MPH instruction.
          state.inhibitInterruptCycles = 1;
        }
      else
        {
          state.mpyDivCount = 4;
          state.inhibitInterruptCycles = 5;
        }
    }
  else if (ptc && op == 001)
    {
      // PRS
      // Within runOneInstruction(), we don't actually perform any actions on
      // the basis of this instruction, other than to access the variable
      // state.prs, and to set the variable state.prsChange to 1 to indicate
      // that state.prs has been written to.  The calling code must
      // interrogate these values in between instructions and take whatever
      // larger action is required.
      int data, location;
      if (residual == 0 || (residual == 1 && operand <= 0373))
        {
          if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
              &fetchedFromMemory, &dataFromInstructionMemory))
            goto done;
          data = fetchedFromMemory;
          state.acc = data;
        }
      else if (residual == 1 && operand == 0374)
        {
          // I don't really know what a "group mark word" is supposed to be,
          // but in researching the BA8421 encoding, I found that the character
          // 077 in BA421 _may_ be a group mark.
          data = 077;
        }
      else if (residual == 1 && operand == 0375)
        data = state.acc;
      else
        goto done;
      location = operand | (residual << 8);
      state.prs[location] = data;
      state.prsChange = location;
      state.cio264Buffer = state.cio[0264];
      state.lastWasPrinter = 1;
    }
  else if (ptc && op == 005)
    {
      // CIO
      // Within runOneInstruction(), we don't actually perform any actions on
      // the basis of this instruction, other than to access the array
      // state.cio[], and to set the variable state.cioChange to indicate
      // which array element (if any) has been written to.  The calling code must
      // interrogate these values in between instructions and take whatever
      // larger action is required.

      // The following is based on Figure 2-11 in the PTC documentation.  CIO 175
      // does not appear at all in the documentation, but the PAST program calls it
      // and 155, 161, 165, and 171 "spares".  It "tests" these spares by executing
      // them and then by testing that CIO 175 has put 0 into ACC.  On the basis of
      // this rather slim data, I infer that 175 is a spare input port while the others
      // are spare outputs.
      if (operand9 == 0154 || operand9 == 0214 || operand9 == 0220
          || operand9 == 0175)
        {
          // The "gate" is needed only for reading PROG REG A, in which the lowest
          // 9 bits are gated by bit written out on CIO 210 to the discrete outputs.
          // When 1, those bits cause the corresponding bits on CIO 210 to be read
          // back as 1, but when 0 gates in other signals on CIO 210, including the
          // PRINTER/PLOTTER/TYPEWRITER BUSY bits.
          state.acc = state.cio[operand9];
          if (operand9 == 0214)
            {
              state.acc |= state.progRegA17_22 | state.bbPrinter
                  | state.bbPlotter | state.bbTypewriter;
              if ((state.cio[0210] & 8) != 0)
                state.acc |= 1;
              if ((state.cio[0210] & 16) != 0)
                state.acc |= 1;
              dPrintoutsTypewriter("RI CIO 214");
            }
          else if (operand9 == 0154)
            {
              if (state.lastWasPrinter)
                state.acc |= state.cio210CarrBusy;
              else
                state.acc |= state.cio210CarrBusy & ~0000400000;
              if (state.prsParityDelayCount > 0
                  && state.prsParityDelayCount < 4)
                {
                  state.acc = (state.acc & ~0002000000)
                      | state.prsDelayedParity[state.prsParityDelayCount];
                }
              // Has parity-check bit been set for CIO 264 since last PRS?
              // This is purely ad hoc ... i.e., empirically determined by looking
              // at the results of self-tests using PAST source code. It is
              // undoubtedly bogus.
              if ((state.cio264Buffer & 02) != 0 && (state.cio[0210] & 4) == 0)
                {
                  if (printerOctalMode)
                    state.acc |= 0000400000 | ((state.cio264Buffer & 3) << 24);
                  else
                    state.acc |= 0100000000;
                  //state.cio264Buffer &= ~2;
                }
            }
        }
      else
        {
          state.cioChange = operand9;
          // Note that for many CIO operations, it is the operation itself which
          // is significant, and not the specific info in ACC.  In other words,
          // the instruction above is often sufficient, and the instruction below
          // is often irrelevant.  However, there's no harm in the instruction
          // below, so we can keep it in all cases.
          state.cio[operand9] = state.acc;
        }
      if (operand == 0001)
        state.acc = state.ai3Shifter;
    }
  else if (op == 002)
    {
      // SUB
      if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
          &fetchedFromMemory, &dataFromInstructionMemory))
        goto done;
      state.acc = convertNativeToDataWord(
          convertDataWordToNative(state.acc)
              - convertDataWordToNative(fetchedFromMemory));
    }
  else if (!ptc && op == 003)
    {
      // DIV
      if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
          &fetchedFromMemory, &dataFromInstructionMemory))
        goto done;

      // The LVDC implements a form of non-restoring division, with a "sign
      // shortcut". The hardware actually does this two bits at a time by
      // predicting the sign of the next remainder, but it is simplest
      // to simulate it by calculating one bit a time. Once the quotient
      // is fully formed, its sign bit is complemented to obtain the
      // final result. The nature of this algorithm leads to some slightly-
      // off results (e.g. 000000000 / 377777777 = 377777774), so it must
      // be directly simulated rather than using native host processor
      // division.
      int remainder = convertDataWordToNative(state.acc);
      int divisor = convertDataWordToNative(fetchedFromMemory);
      int quotient = 0;

      for (uint8_t i = 0; i < 24; i++)
        {
          if ((remainder >= 0 && divisor >= 0) || (remainder < 0 && divisor < 0))
            {
              quotient = (quotient | 1) << 1;
              remainder = (remainder << 1) - divisor;
            }
          else
            {
              quotient = quotient << 1;
              remainder = (remainder << 1) + divisor;
            }
        }

      quotient = (quotient << 1) ^ 0200000000;

      state.pqPend1 = 0;
      state.pqPend2 = convertNativeToDataWord(quotient);
      state.mpyDivCount = 8;
      state.inhibitInterruptCycles = 8;
    }
  else if (op == 004)
    {
      // TNZ
      if (state.acc != 0)
        {
          saveLOC = nextLOC;
          nextLOC = operand;
          nextS = residual;
          state.lastHop = state.hop;
        }
    }
  else if (op == 006)
    {
      // AND
      if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
          &fetchedFromMemory, &dataFromInstructionMemory))
        goto done;
      state.acc &= fetchedFromMemory;
    }
  else if (op == 007)
    {
      // ADD
      if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
          &fetchedFromMemory, &dataFromInstructionMemory))
        {
          printf("Failed\n");
          goto done;
        }
      state.acc = convertNativeToDataWord(
          convertDataWordToNative(state.acc)
              + convertDataWordToNative(fetchedFromMemory));
    }
  else if (op == 010)
    {
      // TRA
      saveLOC = nextLOC;
      nextLOC = operand;
      nextS = residual;
      state.lastHop = state.hop;
    }
  else if ((!ptc && op == 011) || (ptc && op == 015))
    {
      // XOR
      if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
          &fetchedFromMemory, &dataFromInstructionMemory))
        goto done;
      state.acc = state.acc ^ fetchedFromMemory;
    }
  else if (op == 012)
    {
      // PIO
      // Within runOneInstruction(), we don't actually perform any actions on
      // the basis of this instruction, other than to access the array
      // state.pio[], and to set the variable state.pioChange to indicate
      // which array element (if any) has been written to.  The calling code must
      // interrogate these values in between instructions and take whatever
      // larger action is required.

      // Determine direction of data flow.  If the least-significant 2 bits of
      // the operand9 are 11, then the data flows into the accumulator.
      // Otherwise, the accumulator or memory is the source of the data.
      if ((operand9 & 3) == 3)
        state.acc = state.pio[operand9];
      else
        {
          int sourceValue;
          // Bits 8-9 only determine the source of data being sent to
          // the LVDA.
          if (ptc)
            state.pioChange = operand9;
          else
            state.pioChange = operand & 0177;
          state.pioChangeFull = operand9;
          if (!a8) // Source is the accumulator
            sourceValue = state.acc;
          else // Source is memory.
            {
              if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
                  &fetchedFromMemory, &dataFromInstructionMemory))
                fetchedFromMemory = 0;
              sourceValue = fetchedFromMemory;
            }
          state.pio[state.pioChange] = sourceValue;
          if (pioLogFile != NULL && (pioLogFlags & 1) != 0)
            {
              int discard = 0;
              // Can change discard to non-zero here if there are pioLogFlags
              // asking to reject some channels or values.
              if (discard == 0)
                {
                  if (-1 == fprintf(pioLogFile,
                                                  "%lu\t>\t%03o\t%09o\t%09o\n",
                                                  cycleCount,
                                                  state.pioChangeFull,
                                                  state.pio[006],
                                                  sourceValue))
                    {
                      fclose(pioLogFile);
                      pioLogFile = NULL;
                      pioLogFlags = 0;
                    }
                  else
                    pioFlushCount = 12000;
                }
            }


        }
    }
  else if (op == 013)
    {
      // STO
      storeData(hopStructure.dm, residual, hopStructure.ds, operand, state.acc,
          &dataOverwritesInstructionMemory);
    }
  else if (op == 014)
    {
      // TMI
      // Since the accumulator is only 26 bits, it won't fill the int32_t
      // it's stored in, and hence we can't just check if it's negative.
      // However, it's stored in 2's-complement form, and if we assume that the
      // CPU running the emulator is also 2's-complement (which has been a good
      // assumption for at least the last 40 years), we can simply check its
      // most-significant (26th) bit.
      if ((state.acc & signMask) != 0)
        {
          saveLOC = nextLOC;
          nextLOC = operand;
          nextS = residual;
          state.lastHop = state.hop;
        }
    }
  else if ((!ptc && op == 015) || (ptc && op == 003))
    {
      // RSU
      if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
          &fetchedFromMemory, &dataFromInstructionMemory))
        goto done;
      state.acc = convertNativeToDataWord(
          convertDataWordToNative(fetchedFromMemory)
              - convertDataWordToNative(state.acc));
    }
  else if (ptc && op == 016 && a8 == 1)
    {
      // CDS
      rawHopStructure.dm = (operand >> 4) & 1;
      rawHopStructure.ds = operand & 017;
#ifdef DEBUG_A_LOT
      printf("CDS %o,%02o\n", rawHopStructure.dm, rawHopStructure.ds);
#endif
    }
  else if (!ptc && op == 016 && a9 == 0)
    {
      // CDS
      rawHopStructure.dm = (operand >> 1) & 07;
      rawHopStructure.ds = (operand >> 4) & 017;
      rawHopStructure.dupdn = operand & 1;
    }
  else if (ptc && op == 016 && a8 == 0)
    {
      int direction = operand & 0100;
      int sign = state.acc & signMask;
#ifdef DEBUG_A_LOT
      printf("Shift %03o\n", operand);
#endif
      if (direction)
        {
          switch (operand & 077)
            {
          case 001:
            state.acc = sign | (state.acc >> 1);
            break;
          case 002:
            state.acc = sign | (sign >> 1) | (state.acc >> 2);
            break;
          case 004:
            state.acc = sign | (sign >> 1) | (sign >> 2) | (state.acc >> 3);
            break;
          case 010:
            state.acc = sign | (sign >> 1) | (sign >> 2) | (sign >> 3)
                | (state.acc >> 4);
            break;
          case 020:
            state.acc = sign | (sign >> 1) | (sign >> 2) | (sign >> 3)
                | (sign >> 4) | (state.acc >> 5);
            break;
          case 040:
            state.acc = sign | (sign >> 1) | (sign >> 2) | (sign >> 3)
                | (sign >> 4) | (sign >> 5) | (state.acc >> 6);
            break;
          default:
            //pushErrorMessage("Illegal SHF instruction", NULL);
            printf("Illegal SHF instruction\n");
            goto done;
            }
        }
      else
        {
          switch (operand & 077)
            {
          case 001:
            state.acc = state.acc << 1;
            break;
          case 002:
            state.acc = state.acc << 2;
            break;
          case 004:
            state.acc = state.acc << 3;
            break;
          case 010:
            state.acc = state.acc << 4;
            break;
          case 020:
            state.acc = state.acc << 5;
            break;
          case 040:
            state.acc = state.acc << 6;
            break;
          default:
            //pushErrorMessage("Illegal SHF instruction", NULL);
            printf("Illegal SHF instruction\n");
            goto done;
            }
          state.acc = state.acc & 0377777777;
        }
    }
  else if (!ptc && op == 016 && a8 == 0 && a9 == 1)
    {
      // SHF
      int sign = state.acc & signMask;
#ifdef DEBUG_A_LOT
      printf("Shift %03o\n", operand);
#endif
      switch (operand)
        {
      case 000:
        state.acc = 0;
        break;
      case 001:
        state.acc = sign | (state.acc >> 1);
        break;
      case 002:
        state.acc = sign | (sign >> 1) | (state.acc >> 2);
        break;
      case 020:
        state.acc = state.acc << 1;
        break;
      case 040:
        state.acc = state.acc << 2;
        break;
      default:
        //pushErrorMessage("Illegal SHF instruction", NULL);
        printf("Illegal SHF instruction\n");
        goto done;
        }
      state.acc = state.acc & 0377777777;
    }
  else if (!ptc && op == 016 && a8 == 1 && a9 == 1)
    {
      // EXM
      const uint8_t locs[] =
        { 0200, 0240, 0300, 0340 };
      const uint8_t secs[] =
        { 004, 014, 005, 015, 006, 016, 007, 017 };
      int syllable, modBits, dsIndex;
      uint8_t loc;
      hopStructure_t pendingHop;
      // Isolate the modifier bits (A1-A4), syllable (A5), and location
      // index (A6-A7) from the EXM instruction.
      modBits = operand & 017;
      syllable = (operand >> 4) & 1;
      loc = locs[(operand >> 5) & 3];
      // Fetch the instruction being targeted by the EXM.
      if (fetchInstruction(hopStructure.dm, 017, syllable, loc,
          &instruction, &instructionFromDataMemory))
        goto done;
      // Determine the data sector for the modified instruction from
      // its address bits A2, A1, and A9.
      dsIndex = (instruction >> 4) & 7;
      // OR in the modifier bits, after first masking out bits A9,
      // A1, and A2 (the former is always 0 in the modified instruction,
      // and the latter two are directly replaced by the EXM).
      instruction = (instruction & ~0160) | (modBits << 5);
      state.pendingInstruction.instruction = instruction;
      rawHopStructure.loc = nextLOC;
      rawHopStructure.s = nextS;
      if (formHopConstant(&rawHopStructure, &state.pendingInstruction.nextHop))
        goto done;
      pendingHop.im = hopStructure.dm;
      pendingHop.is = 017;
      pendingHop.s = syllable;
      pendingHop.loc = loc;
      pendingHop.dm = hopStructure.dm;
      pendingHop.ds = secs[dsIndex];
      pendingHop.dupdn = hopStructure.dupdn;
      pendingHop.dupin = hopStructure.dupin;
      if (formHopConstant(&pendingHop, &state.pendingInstruction.pendingHop))
        goto done;
      state.pendingInstruction.pending = 1;
      // We're just going to jump back up to the start of this function
      // to executed the modified instruction.  Because all the info
      // for doing this is in the state.pendingInstruction structure, we could
      // instead exit the function normally and count on the parent code
      // to just call runOneInstruction() again later.  The problem is
      // that I'm not sure how all that affects stuff the parent code is
      // doing (such as the debugger interface), so for right now I'm
      // taking the simpler route of not returning until after the modified
      // instruction is executed.  But if all the details were worked out,
      // I think exiting the function normally would be better.
      // Note also that while EXM inhibits interrupts for 1 cycle, we do
      // not need to set inhibitInterruptCycles since we're forcing the
      // next cycle to immediately happen without exiting.
      deltaCycleCount++;
      goto reenterForEXM;
    }
  else if (op == 017)
    {
      // CLA
      if (fetchData(hopStructure.dm, residual, hopStructure.ds, operand,
          &fetchedFromMemory, &dataFromInstructionMemory))
        goto done;
      state.acc = fetchedFromMemory;
    }
  else
    {
      //pushErrorMessage("Implementation error", NULL);
      printf("Implementation error\n");
      runStepN = 0;
      goto done;
    }

  rawHopStructure.loc = nextLOC;
  rawHopStructure.s = nextS;
  if (!isHOP)
    {
      if (formHopConstant(&rawHopStructure, &state.hop))
        goto done;
    }
  // The automatic HOP save circuit constructs an *almost* complete
  // HOP constant every cycle. Every part except the LOC is guaranteed
  // to be present. The LOC is only included if HOP, TRA, TMI, or TNZ
  // caused a branch above (each of which set saveLOC to nextLOC before
  // applying the effects of the branch). Otherwise, the LOC field is
  // simply 0.
  rawestHopStructure.loc = saveLOC;
  if (formHopConstant(&rawestHopStructure, &state.hopSaver))
    state.hopSaver = -1;

  *cyclesUsed = deltaCycleCount;
  state.rtcDivider += deltaCycleCount;
  retVal = 0;
  done: ;
  return (retVal);
}
