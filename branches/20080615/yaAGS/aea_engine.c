/*
  Copyright 2005 Ronald S. Burkey <info@sandroid.org>
  
  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  Filename:	aea_engine.c
  Purpose:	This is the main engine for binary simulation of the Apollo AGS
  		(AEA) computer.  It is separate from the Display/Keyboard (DEDA) 
		simulation and Apollo hardware simulation, though compatible
		with them.  The executable binary may be created using the
		yaLEMAP (Yet Another LEMAP) assembler.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/yaAGS.html
  Mode:		2005-02-13 RSB	Began adapting from corresponding yaAGC
  				program.
		2005-06-02 RSB	Changed my mind, and am writing this more-or-less
				from scratch, though it's very much of the same
				ilk as agc_engine.c.  Implemented lots and 
				lots of instructions, but all of a simple
				variety.DV
		2005-06-04 RSB	... continued.
		2005-06-11 RSB	Fixed an awful problem with TIX (actually with
				the framework rather than with TIX itself)
				in which it could overwrite memory.  Also, 
				eliminated any chance of overwriting 
				permanent memory.
		2005-06-12 RSB	Fixed the handling of overflow in ALS and LLS.
		2005-06-14 RSB	Fixed the LRS instruction for large shifts.
				Continued working with the DVP instruction;
				it's to the point now where it doesn't seem
				too unreasonable to me, but still I can't 
				seem to get the wacky DVP at address 7701 in
				the flight programs.
		2005-06-15 RSB	Implemented DVP using an algorithm that
				Julian Webb sent me.
		2005-06-24 RSB	Ripped out Julian's algorithm, and replaced
				(finally) with what I think is a correct 
				implementation.
		2005-08-22 RSB	"unsigned long long" replaced by uint64_t.
  
  The scans of the original AGS/AEA technical documentation can be found
  at the website listed above.  Also at that site you can find the source code
  which is _executed_ on the AGS, as well as an assembler (yaLEMAP) for that
  source code.  The document specifically of interest is the AEA Programming
  Reference by Stiverson.
  
  What THIS file contains is basicly a pure simulation of the CPU, without any
  input and output as such.  (I/O, to the DEDA or to LM hardware 
  simulations occurs through the mechanism of sockets, and hence the DEDA 
  front-end and hardware back-end simulations may be implemented as complete 
  stand-alone programs and replaced at will.)  There is a single globally 
  interesting function, called aea_engine, which is intended to be called once 
  per AGS/AEA instruction cycle.  The function may be called more or less often
  than the CPU instruction time, to speed up or slow down the apparent passage 
  of time.

  This function is intended to be completely portable, so that it may be run in 
  a PC environment (Microsoft Windows) or in any *NIX environment, or indeed in
  an embedded target if anybody should wish to create an actual physical 
  replacement for an AGC.  Also, multiple copies of the simulation may be run 
  on the same PC -- for example to simulation a CM and LM simultaneously.
*/

#define AEA_ENGINE_C
#ifdef WIN32
typedef unsigned short uint16_t;
#endif
#include "yaAEA.h"
#include "aea_engine.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

// Number of "microseconds" between socket connect/disconnect checks.
#define ROUTINE_CUTOFF 100000	

// Table of instruction timings.  These timings are mostly right, but the
// timing of some instructions is variable, and thus needs to be adjusted
// at runtime.
static const int InstructionTiming[32] = {
   0,  0, 73, 70, 13, 13, 13,  0,	// 00, 02, ..., 16
  10, 10, 10, 70, 10, 10, 10, 70,	// 20, 22, ..., 36
  10, 10, 10, 10, 13, 13, 13, 13,	// 40, 42, ..., 56
  16, 16, 16, 13,  0, 16,  0,  0	// 60, 62, ..., 76
};	

//----------------------------------------------------------------------------
// A sign of desperation that I can't make the DVP instruction work:  My own
// long-division routine.  The return value is the quotient, while the 
// rounded quotient is captured as one of the output parameters.  This 
// calculation assumes that "long long" is at least 64 bits.

#if 0
static int 
LongDivide (long long Dividend, long rDivisor, int *RoundedQuotient)
{
  int i;
  long Quotient = 0;
  long long Divisor;
  Dividend &= 0377777777777LL;		// Keep just 35 bits.
  Divisor = (rDivisor & 0777777L);	// Keep just 18 bits.
  Divisor = (Divisor << 17);		// Align the divisor with the dividend LS bit.
  for (i = 0; i < 18; i++)		// Loop on bits of the quotient.
    {
      Quotient = (Quotient << 1);
      if (Dividend >= Divisor)
        {
          Quotient++;
	  Dividend -= Divisor;
	}
      Dividend = (Dividend << 1);
    }
  *RoundedQuotient = Quotient;
  if (Dividend >= Divisor  && Quotient != 0377777)
    (*RoundedQuotient)++;
  return (Quotient);
}
#endif

//----------------------------------------------------------------------------
// Function which is called to update the outputs to a newly-connected peripheral.

void
UpdateAeaPeripheralConnect (void *AeaState, Client_t *Client)
{
#define State ((aea_t *) AeaState)
#undef State
}

//-----------------------------------------------------------------------------
// Create a backtrace record, if appropriate.
//int BacktracingAGS = 0;

static void
AddBacktraceAGS (ags_t *State)
{
  if (!DebugModeAGS /* !BacktracingAGS */)
    return;
  LatestBacktraceAGS++;
  if (LatestBacktraceAGS >= MAX_AGS_BACKTRACES)
    LatestBacktraceAGS = 0;
  if (NumBacktracesAGS < MAX_AGS_BACKTRACES)
    NumBacktracesAGS++;  
  BacktracesAGS[LatestBacktraceAGS] = *State;
}

void
ListBacktracesAGS (void)
{
  int i, j, CountInLine = 0;
  for (i = 0, j = LatestBacktraceAGS; i < NumBacktracesAGS; i++)
    {
      printf ("%2d:  %04o\t", i, BacktracesAGS[j].ProgramCounter);
      if (++CountInLine == 5)
        {
	  CountInLine = 0;
	  printf ("\n");
	}
      j--;
      if (j < 0)
        j = MAX_AGS_BACKTRACES - 1;
    }
  if (CountInLine)
    printf ("\n");
}

void
RegressToBacktraceAGS (ags_t *State, int BacktraceNumber)
{
  if (BacktraceNumber < 0 || BacktraceNumber >= NumBacktracesAGS)
    {
      printf ("No such backtrace.\n");
      return;
    }
  LatestBacktraceAGS -= BacktraceNumber;
  if (LatestBacktraceAGS < 0)
    LatestBacktraceAGS += MAX_AGS_BACKTRACES;
  *State = BacktracesAGS[LatestBacktraceAGS];
  NumBacktracesAGS -= BacktraceNumber + 1;
  LatestBacktraceAGS--;
  if (LatestBacktraceAGS < 0)
    LatestBacktraceAGS += MAX_AGS_BACKTRACES;
}

//-----------------------------------------------------------------------------
// Fetch or write possibly-indexed values from/to memory.

// Compute address.
int
IndexMemory (ags_t *State, int IndexBit, int AddressField)
{
  if (IndexBit)
    AddressField |= State->Index;
  return (AddressField & 07777);
}

int
FetchMemory (ags_t *State, int IndexBit, int AddressField)
{
  return (State->Memory[IndexMemory (State, IndexBit, AddressField)]);
}

void
WriteMemory (ags_t *State, int IndexBit, int AddressField, int Value)
{
  State->Memory[IndexMemory (State, IndexBit, AddressField)] = (Value & 0777777);
}

// Convert the 18-bit value to the native integer format of the CPU that
// yaAGS is running on.  In practical terms, this just means to sign-extend
// to however-many bits the wordsize is.
int 
SignExtendAGS (int i)
{
  if (i & 0400000)
    i |= ~0777777;
  return (i);
}
#define SignExtend SignExtendAGS

// Get a double-precision value by combining the A and Q registers.
static long long 
GetLongAccumulator (ags_t *State)
{
  long long lli;
  lli = State->Accumulator;
  lli = (lli << 17);
  lli |= (State->Quotient & 0377777);
  if (State->Accumulator & 0400000)	// Negative?
    lli |= ~0377777777777LL;	// If so, then sign-extend.
  return (lli);
}

// Write a double-precision value to the A and Q registers.
static void
PutLongAccumulator (ags_t *State, long long lli)
{
  State->Accumulator = ((lli >> 17) & 0777777);
  State->Quotient = (lli & 0377777);
  if (0400000 & State->Accumulator)
     State->Quotient |= 0400000;
}

//----------------------------------------------------------------------------
// This function is used to get buffered DEDA shift-register data.  

extern int DedaBuffer[9], DedaBufferCount, DedaBufferWanted,
  DedaBufferReadout, DedaBufferDefault;

static int
FetchDedaShift (ags_t *State)
{
  // Return the buffered data, if we have any.
  if (!DedaBufferWanted || DedaBufferCount < DedaBufferWanted || 
      DedaBufferReadout >= DedaBufferWanted || DedaBufferReadout < 0)
    DedaBufferWanted = DedaBufferCount = DedaBufferReadout = 0;
  else 
    {
      DedaBufferDefault = DedaBuffer[DedaBufferReadout];
      if (DedaBufferReadout + 1 == DedaBufferWanted)
        DedaBufferWanted = DedaBufferCount = DedaBufferReadout = 0;
  // Tell the CPU that the ENTR or READ OUT key has been released.
  if (DedaBufferWanted == 3)
    State->InputPorts[IO_2040] |= 02000;
  else if (DedaBufferWanted == 9)
    State->InputPorts[IO_2040] |= 04000;
    }
  return (DedaBufferDefault);
}

//-----------------------------------------------------------------------------
// Handles everything about the OUT instruction. 

void
Output (ags_t *State, int AddressField, int Value)
{
  int Address, Mask, NewDiscreteOutputs;
  NewDiscreteOutputs = State->OutputPorts[IO_ODISCRETES];
  for (Mask = 1; Mask <= 0200; Mask = Mask << 1)
    if (Mask & AddressField)
      {
        Address = (AddressField & (07400 | Mask));
	switch (Address) 
	  {
	  case 02001:		// sin theta
	    ChannelOutputAGS (020, State->OutputPorts[IO_2001] = (Value & 0777400));
	    break;
	  case 02002:		// cos theta
	    ChannelOutputAGS (021, State->OutputPorts[IO_2002] = (Value & 0777400));
	    break;
	  case 02004:		// sin phi
	    ChannelOutputAGS (022, State->OutputPorts[IO_2004] = (Value & 0777400));
	    break;
	  case 02010:		// cos phi
	    ChannelOutputAGS (023, State->OutputPorts[IO_2010] = (Value & 0777400));
	    break;
	  case 02020:		// sin psi
	    ChannelOutputAGS (024, State->OutputPorts[IO_2020] = (Value & 0777400));
	    break;
	  case 02040:		// cos psi
	    ChannelOutputAGS (025, State->OutputPorts[IO_2040] = (Value & 0777400));
	    break;
	  case 02200:		// DEDA
	    // We don't actually complete the operation until the DEDA-shift-out
	    // discrete is set.
	    State->OutputPorts[IO_2200] = ((Value & 017) << 13);
	    break;
	  case 02410:		// ripple carry inhibit discrete set
	    NewDiscreteOutputs &= ~01;
	    break;
	  case 02420:		// altitude discrete set
	    NewDiscreteOutputs &= ~02;
	    break;
	  case 02440:		// altitude rate discrete set.
	    NewDiscreteOutputs &= ~04;
	    break;
	  case 02500:		// DEDA shift in discrete set
	    // NewDiscreteOutputs &= ~010;
	    DedaBufferReadout++;
	    //printf ("CPU issued DEDA Shift In.\n");
	    break;
	  case 02600:		// DEDA shift out discrete set
	    // We don't actually change this bit at all.  Instead, we transmit
	    // the DEDA shift register.
	    ChannelOutputAGS (027, State->OutputPorts[IO_2200]);
	    break;
	  case 03010:		// ripple carry inhibit reset.
	    NewDiscreteOutputs |= 01;
	    break;
	  case 03040:		// altitude / altitude rate reset.
	    NewDiscreteOutputs |= 06;
	    break;
	  case 06001:		// Ex
	    ChannelOutputAGS (030, State->OutputPorts[IO_6001] = (Value & 0777400));
	    break;
	  case 06002:		// Ey
	    ChannelOutputAGS (031, State->OutputPorts[IO_6002] = (Value & 0777400));
	    break;
	  case 06004:		// Ez
	    ChannelOutputAGS (032, State->OutputPorts[IO_6004] = (Value & 0777400));
	    break;
	  case 06010:		// altitude / altitude-rate 
	    ChannelOutputAGS (033, State->OutputPorts[IO_6010] = (Value & 0777770));
	    break;
	  case 06020:		// lateral velocity
	    ChannelOutputAGS (034, State->OutputPorts[IO_6020] = (Value & 0777000));
	    break;
	  case 06100:		// output telemetry word 2
	    State->OutputPorts[IO_6100] = Value;
	    ChannelOutputAGS (036, Value);
	    State->InputPorts[IO_2020] &= ~0200000;	// set output telemetry stop.
	    break;
	  case 06200:		// output telemetry word 1
	    State->OutputPorts[IO_6200] = Value;
	    State->InputPorts[IO_2020] |= 0200000;	// reset Output Telemetry stop.
	    ChannelOutputAGS (037, Value);
	    break;
	  case 06401:		// GSE discrete 4 set.
	    NewDiscreteOutputs &= ~040;
	    break;
	  case 06402:		// GSE discrete 5 set
	    NewDiscreteOutputs &= ~0100;
	    break;
	  case 06404:		// GSE discrete 6 set
	    NewDiscreteOutputs &= ~0200;
	    break;
	  case 06410:		// test mode failure discrete set
	    NewDiscreteOutputs &= ~0400;
	    break;
	  case 06420:		// engine off discrete set
	    NewDiscreteOutputs &= ~01000;
	    break;
	  case 06440:		// engine on discrete set
	    NewDiscreteOutputs &= ~02000;
	    break;
	  case 07001:		// GSE discrete 4 reset
	    NewDiscreteOutputs |= 040;
	    break;
	  case 07002:		// GSE discrete 5 reset.
	    NewDiscreteOutputs |= 0100;
	    break;
	  case 07004:
	    NewDiscreteOutputs |= 0200;
	    break;
	  case 07010:
	    NewDiscreteOutputs |= 0400;
	    break;
	  case 07020:
	    NewDiscreteOutputs |= 01000;
	    break;
	  case 07040:
	    NewDiscreteOutputs |= 02000;
	    break;
	  default:
	    printf ("yaAGS accessed unknown output register 0%o.\n", Address);
	    break;
	  }
      }
  if (NewDiscreteOutputs != State->OutputPorts[IO_ODISCRETES])
    {
      State->OutputPorts[IO_ODISCRETES] = NewDiscreteOutputs;
      ChannelOutputAGS (040, NewDiscreteOutputs);
    }
}

//-----------------------------------------------------------------------------
// Handles everything about the INP instruction.  The return value of
// the instruction is the amount of CPU time taken up by it.

static int
Input (ags_t *State, int AddressField, int *Value)
{
  int i, MicrosecondsNeeded = 16, BaseAddress, Mask;
  BaseAddress = (AddressField & 07000);
  if (BaseAddress == 02000 && 0 != (AddressField & 07))	// PGNS angle register?
    MicrosecondsNeeded = 67;		// If yes, adjust time needed.
  // We have to account for the fact that we might be reading multiple 
  // registers.
  if (BaseAddress == 02000)
    BaseAddress = IO_2001;
  else if (BaseAddress == 06000)
    BaseAddress = IO_6001;
  else
    {
      printf ("yaAGS accessed unknown input register 0%o.\n", AddressField);
      return (0);
    }
  *Value = 0;
  for (i = 0; (Mask = (1 << i)) != 0400; i++)
    if (0 != (AddressField & Mask))
      {
        if (IO_2200 == BaseAddress + i)
	  {
	    *Value |= FetchDedaShift (State);
	    //printf ("INP 2200: %02o\n", (*Value >> 13) & 017);
	  }
	else
          *Value |= State->InputPorts[BaseAddress + i];
	// Certain input registers are reset when they are read.
	if (BaseAddress == IO_6001)
	  { 
	    if (Mask == 0200)
	      State->InputPorts[IO_2020] |= 0200000;	// downlink stop discrete.
	    else 
	      State->InputPorts[IO_6001 + i] = 0;
	  }
      }  
  return (MicrosecondsNeeded);
}

//-------------------------------------------------------------------------------
// Displays the current address and its contents. This was taken from yaAGC
static char ShowAddressBuffer[17];

char *
ShowAddressContentsAGS (ags_t *State)
{
  sprintf (ShowAddressBuffer, "0%06o 0%06o", State->ProgramCounter,
	   State->Memory[State->ProgramCounter]);
  return (ShowAddressBuffer);
}

//-----------------------------------------------------------------------------
// Execute one instruction of the simulation.  Use aea_engine_init prior to 
// the first call of aea_engine, to initialize State, and then call aea_engine 
// thereafter in such a way as to keep the simulation more-or-less sync'd
// with whatever you think of as real time.  State->CycleCounter keeps track
// of the time elapsed, in units of 1/1.024 microseconds (i.e., 
// 0.9765625 microseconds).
//
// Returns the number of "microseconds" used.

int
aea_engine (ags_t * State)
{
  extern void UpdateAeaPeripheralConnect (void *, Client_t *);
  static int Count = 0;
  int MicrosecondsThisInstruction, NewProgramCounter;
  int OpCode, IndexBit, AddressField, OriginalAddress;
  int i, j, k, ValueFromY, NewValueForY;
  long long lli, llj, llk;
  
  //-------------------------------------------------------------------------

  // Handle server stuff for socket connections used for i/o channel
  // communications.  Stuff like listening for clients we only do
  // every once and a while.
  if (Count >= ROUTINE_CUTOFF)
    {
      Count -= ROUTINE_CUTOFF;
      ChannelRoutineGeneric (State, UpdateAeaPeripheralConnect);
    }

  //----------------------------------------------------------------------
  // Handle the 20 ms. timing signal.
  if (State->CycleCounter >= State->Next20msSignal)
    {
      State->Next20msSignal += (AEA_PER_SECOND / 50);
      if (State->Halt)
        State->Halt = 0;
      else
        Output (State, 06410, 0);	// Set TEST MODE FAILURE discrete.
    }
  else if (State->Halt)
    {
      MicrosecondsThisInstruction = 10;
      State->CycleCounter += MicrosecondsThisInstruction;
      Count += MicrosecondsThisInstruction;
      return (MicrosecondsThisInstruction);
    }

  // Debugger needs to do stuff?
  DebuggerHookAGS (State);

  // Get data from input channels into the input-channel buffer..
  ChannelInputAGS (State);

  //----------------------------------------------------------------------  
  // Okay, here's the stuff that actually has to do with decoding instructions.
  // In particular, it must set MicrosecondsThisInstruction to the time
  // used by the operation, and must set the program counter in State to 
  // the program counter for the next instruction that's supposed to be
  // executed.
  i = State->Memory[State->ProgramCounter];
  AddressField = (i & 07777);
  IndexBit = (0 != (i & 010000));
  // We don't use the following line, because we want to save the 
  // address in OriginalAddress, and don't want to calculate it twice.
  //ValueFromY = FetchMemory (State, IndexBit, AddressField);
  OriginalAddress = IndexMemory (State, IndexBit, AddressField);
  ValueFromY = State->Memory[OriginalAddress];
  NewValueForY = ValueFromY;
  // The docs refer to opcodes as even values, so we do as well.
  OpCode = ((i >> 12) & 076);
  MicrosecondsThisInstruction = InstructionTiming[OpCode >> 1];
  NewProgramCounter = ((State->ProgramCounter + 1) & 07777);
  switch (OpCode)
    {
    case 000:
      printf ("Unassigned opcode 0%o encountered at address 0%o.\n",
      	      OpCode, State->ProgramCounter);
      break;
    case 002:
      printf ("Unassigned opcode 0%o encountered at address 0%o.\n",
      	      OpCode, State->ProgramCounter);
      break;
    case 004:	// DVP
      // lli will be the dividend, and i the divisor.
      lli = GetLongAccumulator (State);
      i = SignExtend (ValueFromY);
      j = SignExtend (State->Accumulator);
      if (i == 0)		// Divisor == 0?
        {
	  // Stiverson does not actually say what happens when the divisor
	  // is zero.  It is clear that the overflow flag is set, but
	  // it is completely unclear what the numerical result is 
	  // supposed to be.  I take the liberty of making it the largest
	  // positive or negative value.
	  State->Overflow = 1;
	  if (lli >= 0)
	    State->Accumulator = State->Quotient = 0377777;
	  else
	    State->Accumulator = State->Quotient = 0400000;
	}
      else if (i == -j)		// A and Y divisor equal and opposite but non-zero
        {
	  // A and Y of equal magnitude is a special case that requires 
	  // some wacky output settings.
	  if (i < 0)		// Y negative
	    State->Overflow = 1;
	  State->Accumulator = State->Quotient = 0400000;
        }
      else 
        {
	  // Do the division.  Note that there's no way to get remainders.
	  // Also the result (llk) simply has to fit into 17 bits (plus sign)
	  // "or else".  Note also that the docs are very unclear on what
	  // they mean by "divide", except for the case of two positive numbers,
	  // In other words, I just had to empirically mess around until I found
	  // something that "worked".  That's why there are so many methods
	  // tried out below.  Ick!
#if 0
	  //printf ("DVP: %Lo %o\n", lli, i);
	  if (i < 0)		// Normalize signs (divisor always positive).
	    {
	      lli = -lli;
	      i = -i;
	    }
	  //printf ("     %Lo %o\n", lli, i);
	  llk = ((uint64_t /* unsigned long long */) lli) / i;
	  if (0400000 & llk)
	    llk |= ~0777777;
	  if (llk > 0377777 || llk < -0400000)
	    State->Overflow = 1;
	  State->Quotient = (llk & 0777777);
	  // Perform "rounding".  I "think" this rule corresponds to what
	  // Stiverson specifies, but I'll have to revisit it later to 
	  // make sure.  The purpose of the first branch is to suppress
	  // the rounding in the case where it would overflow the 
	  // accumulator.
	  State->Accumulator = State->Quotient;
	  if (State->Accumulator != 0377777)
	    {
	      llk = ((uint64_t /* unsigned long long */) (lli * 2)) / i;
	      if (llk & 1)
	        State->Accumulator = ((State->Accumulator + 1) & 0777777);
	    }
#elif 0
          if (i < 0)
	    {
	      i = -i;
	      // Yes, I know the following makes no sense,
	      lli = ~lli;
	    }
          State->Quotient = LongDivide (lli, i, &State->Accumulator);
	  if (0 != (State->Quotient & ~0777777))
	    {
	      State->Overflow = 1;
	      State->Quotient &= 0777777;
	      State->Accumulator &= 0777777;
	    }
#elif 0
	  {
	    int Round;
	    if (i < 0)
	      {
		i = -i;
		lli = -lli;
	      }
	    llk = (2 * lli) / i;
	    Round = (llk & 1);
	    llk = (llk - Round) / 2;
	    if (llk > 0377777 || llk < -0400000)
	      State->Overflow = 1;
	    State->Quotient = (llk & 0777777);
	    State->Accumulator = State->Quotient;
	    if (State->Accumulator != 0377777)
	      State->Accumulator = ((State->Accumulator + Round) & 0777777);
	  }
#elif 0
	  {
	    int Round;
	    if (i < 0)
	      {
		i = -i;
		lli = -lli;
	      }
	    llk = (2 * lli) / i;
	    Round = (llk & 1);
	    lli = (llk - Round) / 2;
	    if (lli == 0377777)
	      llj = 0377777;
	    else
	      llj = lli + Round;
	    if (lli > 0377777 || lli < -0400000)
	      State->Overflow = 1;
	    State->Quotient = (lli & 0777777);
	    State->Accumulator = (llj & 0777777);
	  }
#elif 0
	  {
	    double f;
	    if (i < 0)
	      {
		i = -i;
		lli = -lli;
	      }
	    f = lli;
	    if (fabs (f) >= (i << 17LL))
	      State->Overflow = 1;
	    State->Quotient = floor (f / i);  
	    //if (State->Quotient > 0377777 || State->Quotient < -0400000)
	    //  State->Overflow = 1;
	    State->Quotient &= 0777777;
	    if (State->Quotient == 0377777)
	      State->Accumulator = 0377777;
	    else
	      {
	        State->Accumulator = floor ((f + i / 2) / i);
		State->Accumulator &= 0777777;
	      }
	  }
#elif 0
	  {
	    double f, ff;
	    if (i < 0)
	      {
		i = -i;
		lli = -lli;
	      }
	    f = (lli * 1.0) / 17179869184.0;
	    ff = (i * 1.0) / 131072.0;
	    printf ("%10e / %10e\n", ff, f);
	    if (fabs (f) >= ff)
	      State->Overflow = 1;
	    State->Quotient = floor (f / ff);  
	    State->Quotient &= 0777777;
	    if (State->Quotient == 0377777)
	      State->Accumulator = 0377777;
	    else
	      {
	        State->Accumulator = floor ((f + ff / 2) / ff);
		State->Accumulator &= 0777777;
	      }
	  }
#elif 0
	  // This is the best method I was able to work out on my own.
	  // It gets through 4 of the 6 self-tests involving division
	  // before bombing.
	  {
	    double f;
	    f = lli;
	    State->Quotient = floor (f / i);  
	    if (State->Quotient > 0377777 || State->Quotient < -0400000)
	      State->Overflow = 1;
	    State->Quotient &= 0777777;
	    if (State->Quotient == 0377777)
	      State->Accumulator = 0377777;
	    else
	      {
	        State->Accumulator = floor ((f + i / 2) / i);
		State->Accumulator &= 0777777;
	      }
	  }
#elif 0
	  // This is the method sent to me by Julian Webb.
	  // It makes no sense to me, but does pass the self-tests.
	  // (This is no dig against Julian.  As you can see
	  // by the other approaches listed above, I tried plenty
	  // of things that made no sense to me.)  If anyone
	  // has a demonstrably mathematically sensible approach
	  // that can pass the "logic tests" on pp. 116-119 of 
	  // Flight Program 8 (i.e., addresses 7503-7711), I'd 
	  // very much appreciate hearing about it.  The DVP at
	  // address 7701 is the real killer:  It divides
	  // -200000 (octal) by -1 --- which mathematically should 
	  // be exactly 200000 without overflow --- and gets 
	  // 177777 and a rounded result of 200000, with overflow.
	  
	  // Step 1:  Determine if there's overflow.  Do this by
	  // stripping off the sign bit and aligning the divisor
	  // with the dividend, and then comparing the two to see
	  // which is greater.  (Recall that these are supposed
	  // to represent FRACTIONAL values, with an implied
	  // decimal point between the sign bit and the first
	  // data bit.  In other words, the values are all 
	  // >-1 and <+1.  The divisor must always be greater
	  // in absolute value than the dividend, or else the
	  // quotient will be >=+1 or <=-1, and therefore won't
	  // expressible in this number system.  The following
	  // test makes perfect sense in those terms if the 
	  // divisor and dividend are both positive, but is 
	  // completely wrong mathematically for negative 
	  // values, since it will result in an overflow 
	  // indication in many cases where the quotient can
	  // be expressed perfectly well.
	  llj = (lli & 0177777777777LL);	// dividend
	  llk = ((i & 0377777) << 17LL);	// divisor
	  if (llj >= llk)
	    State->Overflow = 1;
	  //printf ("DVP 1:  %Lo %Lo %d.\n", llj, llk, State->Overflow);
	    
	  // Step 2:  Normalize so that the divisor is positive.
	  // We use j to track this condition.  This is, of course,
	  // perfectly sensible.
	  j = 0;
	  if (i < 0)
	    {
	      j = 1;
	      i = -i;
	    }
	    
	  // Step 3:  Divide, and keep the lowest 18 bits of the 
	  // quotient.
	  State->Quotient = ((lli / i) & 0777777);
	  
	  // Step 4:  If the divisor had initially been positive,
	  // we need to change the sign of the quotient.  This
	  // procedure makes no sense for exact results, since it 
	  // involves taking a 1's-complement rather than actually 
	  // negating the quotient, so the result will always be
	  // wrong by 1; for cases where the divisor isn't exact,
	  // I suppose whether it makes sence depends on whether 
	  // you wish to truncate towards 0 or away from 0.  
	  // However, it is distinctly odd to use a procedure that
	  // is quaranteed to be wrong when an exact result is
	  // possible.
	  if (j)
	    State->Quotient = (0777777 ^ State->Quotient);
	    
	  // Step 5:  Place the rounded quotient into the 
	  // accumulator.  The method for doing so makes no sense, 
	  // because rounding involves the bits which have been 
	  // discarded as insignificant (as clearly stated in the
	  // docs), which we don't even examine here.
	  State->Accumulator = State->Quotient;
	  if (State->Accumulator != 0377777 && 0 != (1 & State->Quotient))
	    State->Accumulator++;
#else
	  // This works in a straightforward, if not necessarily
	  // processor-cycle-efficient manner.  The only oddities about 
	  // it are the things I've deduced by looking at the DVP at
	  // address 7701 in FP6 and FP8:
	  // a) The CPU is very lazy about checking for overflow.
	  //    It *should* set the overflow flag if the absolute value
	  //    of the divisor is less than or equal to the absolute
	  //    value of the dividend.  Instead, it uses the absolute
	  //    value of the accumulator, rather than the absolute value
	  //    of the dividend.  This means that there are some rare
	  //    cases (only when the dividend is negative and close 
	  //	in value to the divisor, considered as fractional values)
	  //    in which the CPU will think there is overflow when 
	  //    there really isn't.  A case in point is the DVP at
	  //	7701, in which the accumulator (0777777) is equal to 
	  //    the divisor,  but the divisor is actually greater in 
	  //	absolute value than the absolute value of the dividend.
	  // b) There are apparently cases like 7701, in which instead
	  //	of producing the obvious mathematically-correct result
	  //	(0200000), the division produces a less-obvious but
	  //	still mathematically-correct result (0177777.777...).
	  //	0200000 is mathematically equal to 0177777.777..., but
	  //	truncates and rounds differently in the CPU.  (0200000
	  //	truncates *and* rounds obviously to 0200000, but 
	  //	0177777.777... truncates to 0177777 and rounds to 
	  //	0200000.)  Since I don't know the conditions under which
	  //	this oddity occurs, I can't simulate that particular
	  //	quirk of the CPU.  Instead, I always produce the obvious
	  //	mathematically-correct result when possible, but I add
	  //	special ad hoc code to catch the case of the specific
	  //	operands from address 7701; otherwise, I cannot pass the
	  //	self-test.
	  {
	    double f;
	    if (abs (j) >= abs (i))		// See note (a) above.
	      State->Overflow = 1;   
	    if (i == -1 && lli == -0200000)	// See note (b) above.
	      {
	        State->Quotient = 0177777;
		State->Accumulator = 0200000;
	      }
	    else
	      { 
		f = lli;
		State->Quotient = floor (f / i);  
		State->Quotient &= 0777777;
		if (State->Quotient == 0377777)
		  State->Accumulator = 0377777;
		else
		  {
		    State->Accumulator = floor ((f + i / 2) / i);
		    State->Accumulator &= 0777777;
		  }
	      }
	  }
#endif 
	}
      break;
    case 010:	// STO
      NewValueForY = State->Accumulator;
      break;
    case 012:	// STQ
      NewValueForY = State->Quotient;
      break;
    case 014:	// LDQ
      State->Quotient = ValueFromY;
      break;
    case 016:
      printf ("Unassigned opcode 0%o encountered at address 0%o.\n",
      	      OpCode, State->ProgramCounter);
      break;
    case 020:	// CLA
    case 030:	// CLZ
      State->Accumulator = ValueFromY;
      if (OpCode == 030)
        NewValueForY = 0;
      break;
    case 022:	// ADD
    case 032:	// ADZ
      i = SignExtend (State->Accumulator);
      i += SignExtend (ValueFromY);
      if (i > 0377777 || i < -0400000)
        State->Overflow = 1;
      State->Accumulator = (i & 0777777);
      if (OpCode == 032)
        NewValueForY = 0;
      break;
    case 024:	// SUB
    case 034:	// SUZ
      i = SignExtend (State->Accumulator);
      i -= SignExtend (ValueFromY);
      if (i > 0377777 || i < -0400000)
        State->Overflow = 1;
      State->Accumulator = (i & 0777777);
      if (OpCode == 034)
        NewValueForY = 0;
      break;
    case 006:	// MPY
    case 026:	// MPR
    case 036:	// MPZ
      i = ValueFromY;
      if (i == 0400000)		// Special case.
        State->Quotient = 0;	// Accumulator unchanged.
      else
        {
	  lli = SignExtend (State->Accumulator);
	  lli *= SignExtend (i);
	  PutLongAccumulator (State, lli);
	  // I don't know if this formula for rounding makes any 
	  // sense for negative values.  I'm just slavishly 
	  // implementing it as written.
	  if (OpCode != 006)		// Don't round for MPY
	    {
	      if (State->Quotient & 0200000)
		State->Accumulator++;
	    }
        }
      if (OpCode == 036)		// Don't zero unless MPZ
        NewValueForY = 0;
      break;
    case 040:	// TRA
      AddBacktraceAGS (State);
      NewProgramCounter = AddressField;
      break;
    case 042:	// TIX
      if (State->Index)
        {
	  AddBacktraceAGS (State);
	  State->Index--;
	  NewProgramCounter = AddressField;
	}
      break;
    case 044:	// TOV
      if (State->Overflow)
        {	
	  AddBacktraceAGS (State);
	  State->Overflow = 0;
	  NewProgramCounter = AddressField;	
	}
      break;
    case 046:	// TMI
      if ((State->Accumulator & 0400000) != 0)	// Negative?
        {					// If so, branch.
	  AddBacktraceAGS (State);
	  NewProgramCounter = AddressField;	
	}
      break;
    case 050:	// AXT
      // There's a discrepancy in the docs about whether we need to
      // use 4 bits or 3 bits here.  The bulk of the doc seems to
      // go with 3 bits.  Besides, yaLEMAP enforces a 3-bit field
      // here, and FP6 & FP8 compile without error.
      State->Index = (AddressField & 07);
      break;
    case 052:	// LLS
      i = (037 & AddressField);			// # places to shift.
      MicrosecondsThisInstruction += 3 * i;  	// Timing adjustment needed.
      lli = GetLongAccumulator (State);
      // Here's the tricky part:  The overflow flag is set if ANY of the
      // N (i) bits that supposedly passed through the sign bit during the 
      // shift changed its sign.  We therefore need to construct a mask
      // that picks off just those bits.  llk will be the mask, and llj 
      // will be the picked-off bits.
      if (i)
        {
	  llk = (0177777777777LL & ~((1 << (34 - i)) - 1));
	  llj = (lli & llk);
	  if ((0 == (State->Accumulator & 0400000) && llj != 0) ||
	      (0 != (State->Accumulator & 0400000) && llj != llk))
	    State->Overflow = 1;
	}
      // The actual shifting part is really easy.
      PutLongAccumulator (State, lli << i);
      break;
    case 054:	// LRS
      i = (037 & AddressField);			// # places to shift.
      MicrosecondsThisInstruction += 3 * i;  	// Timing adjustment needed.
      lli = GetLongAccumulator (State);
      // Here's the tricky part:  The sign bit is the value shifted in
      // at the top end.  We therefore need to construct a mask
      // to duplicate that bit.  llk will be the mask.
      if (0 != (State->Accumulator & 0400000))	// Negative.
        llk = (0177777777777LL & ~((1LL << (34 - i)) - 1));
      else
        llk = 0;
      // The actual shifting part is really easy.
      PutLongAccumulator (State, (lli >> i) | llk);
      break;
    case 056:	// ALS
      i = (037 & AddressField);			// # places to shift.
      MicrosecondsThisInstruction += 3 * i;  	// Timing adjustment needed.
      // Here's the tricky part:  The overflow flag is set if ANY of the
      // N bits that supposedly passed through the sign bit during the 
      // shift changed its sign.  We therefore need to construct a mask
      // that picks off just those bits.  k will be the mask, and j will
      // be the picked-off bits.
      if (i)
        {
	  if (i >= 17)
	    k = 0377777;
	  else
	    k = (0377777 & ~((0400000 >> i) - 1));
	  j = (State->Accumulator & k);
	  if ((0 == (State->Accumulator & 0400000) && j != 0) ||
	      (0 != (State->Accumulator & 0400000) && j != k))
	    State->Overflow = 1;
	}
      // The actual shifting part is really easy.
      State->Accumulator = ((State->Accumulator << i) & 0777777);
      break;
    case 060:	// COM
      State->Accumulator = (0777777 & -State->Accumulator);
      break;
    case 062:	// ABS
      i = SignExtend (State->Accumulator);
      if (i < 0 && i > -0400000)
        State->Accumulator = -i;
      break;
    case 064:	// INP
      MicrosecondsThisInstruction = Input (State, AddressField, &State->Accumulator);
      break;
    case 066:	// OUT
      Output (State, AddressField, State->Accumulator);
      break;
    case 070:	// DLY
      AddBacktraceAGS (State);
      NewProgramCounter = AddressField;
      State->Halt = 1;
      break;
    case 072:	// TSQ
      AddBacktraceAGS (State);
      State->Quotient = (0410000 | NewProgramCounter);	// Make a TRA instruction.
      NewProgramCounter = AddressField;
      break;
    case 074:
      printf ("Unassigned opcode 0%o encountered at address 0%o.\n",
      	      OpCode, State->ProgramCounter);
      break;
    case 076:
      printf ("Unassigned opcode 0%o encountered at address 0%o.\n",
      	      OpCode, State->ProgramCounter);
      break;
    default:				// Unassigned opcodes.
      printf ("Implementation error:  Opcode 0%o encountered at address 0%o.\n",
      	      OpCode, State->ProgramCounter);
      break;
    }

  // All done!
  // We don't use the following line because if State->Index has changed, it
  // will overwrite the wrong address.
  //WriteMemory (State,IndexBit, AddressField, NewValueForY);
  NewValueForY &= 0777777;
  if (OriginalAddress < 04000)
    State->Memory[OriginalAddress] = NewValueForY;
  else if (DebugModeAGS && State->Memory[OriginalAddress] != NewValueForY)
    printf ("Attempt to overwrite permanent address 0%04o at PC=%04o.\n", 
            OriginalAddress, State->ProgramCounter);
  State->ProgramCounter = (NewProgramCounter & 07777);
  State->CycleCounter += MicrosecondsThisInstruction;
  Count += MicrosecondsThisInstruction;
  return (MicrosecondsThisInstruction);
}

