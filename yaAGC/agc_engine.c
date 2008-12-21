/*
  Copyright 2003-2005 Ronald S. Burkey <info@sandroid.org>

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

  In addition, as a special exception, Ronald S. Burkey gives permission to
  link the code of this program with the Orbiter SDK library (or with
  modified versions of the Orbiter SDK library that use the same license as
  the Orbiter SDK library), and distribute linked combinations including
  the two. You must obey the GNU General Public License in all respects for
  all of the code used other than the Orbiter SDK library. If you modify
  this file, you may extend this exception to your version of the file,
  but you are not obligated to do so. If you do not wish to do so, delete
  this exception statement from your version.

  Filename:	agc_engine.c
  Purpose:	This is the main engine for binary simulation of the Apollo AGC
  		computer.  It is separate from the Display/Keyboard (DSKY)
		simulation and Apollo hardware simulation, though compatible
		with them.  The executable binary may be created using the
		yayul (Yet Another YUL) assembler.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		04/05/03 RSB.	Began.
  		08/20/03 RSB.	Now bitmasks are handled on input channels.
		11/26/03 RSB.	Up to now, a pseudo-linear space was used to
				model internal AGC memory.  This was simply too
				tricky to work with, because it was too hard to
				understand the address conversions that were
				taking place.  I now use a banked model much
				closer to the true AGC memory map.
		11/28/03 RSB.	Added code for a bunch of instruction types,
				and fixed a bunch of bugs.
		11/29/03 RSB.	Finished out all of the instruction types.
				Still a lot of uncertainty if Overflow
				and/or editing has been handled properly.
				Undoubtedly many bugs.
		05/01/04 RSB	Now makes sure that in --debug-dsky mode
				doesn't execute any AGC code (since there
				isn't any loaded anyhow).
		05/03/04 RSB	Added a workaround for "TC Q".  It's not
				right, but it has to be more right than
				what was there before.
		05/04/04 RSB	Fixed a bug in CS, where the unused bit
				could get set and thereforem mess up
				later comparisons.  Fixed an addressing bug
				(was 10-bit but should have been 12-bit) in
				the AD instruction.  DCA was completely
				messed up (still don't know about overflow).
		05/05/04 RSB	INDEX'ing was messed up because the pending
				index was zeroed before being completely
				used up.  Fixed the "CCS A" instruction.
				Fixed CCS in the case of negative compare-
				values.
		05/06/04 RSB	Added rfopen.  The operation of "DXCH L"
				(which is ambiguous in the docs but actually
				used --- at Luminary131 address 33,03514) ---
				has been redefined in accordance with the
				Luminary program's comments.  Adjusted
				"CS A" and "CA A", though I don't actually
				think they work differently.  Fixed a
				potential divide-by-0 in DV.
		05/10/04 RSB	Fixed up i/o channel operations so that they
				properly use AGC-formatted integers rather
				than the simulator's native-format integers.
		05/12/04 RSB	Added the data collection for backtraces.
		05/13/04 RSB	Corrected calculation of the superbank address.
		05/14/04 RSB	Added interrupt service and hopefully fixed the
				RESUME instruction.  Fixed a bunch of instructions
				(but not all, since I couldn't figure out how to
				consistently do it) that modify the Z register.
		05/15/04 RSB	Repaired the interrupt vector and the RESUME
				instruction, so that they do not automatically
				save/restore A, L, Q, and BB to/from
				ARUPUT, LRUPT, QRUPT, and BBRUPT.  The ISR
				is supposed to do that itself, if it wants
				it done. And (sigh!) the RESUME instruction
				wasn't working, but was treated as INDEX 017.
		05/17/04 RSB	Added MasterInterruptEnable.  Added updates of
				timer-registers TIME1 and TIME2, of TIME3 and
				TIME4, and of SCALER1 and SCALER2.
		05/18/04 RSB	The mask used for writing to channel 7 have
				changed from 0100 to 0160, because the
				Luminary131 source (p.59) claims that bits
				5-7 are used.  I don't know what bits 5-6
				are for, though.
		05/19/04 RSB	I'm beginning to grasp now what to do for
				overflow.  The AD instruction (in which
				overflow was messed up) and the TS instruction
				(which was completely bollixed) have hopefully
				been fixed now.
		05/30/04 RSB	Now have a spec to work from (my assembly-
				language manual).  Working to bring this code
				up to v0.50 of the spec.
		05/31/04 RSB	The instruction set has basically been completely
				rewritten.
		06/01/04 RSB	Corrected the indexing of instructions
				for negative indices.  Oops!  The instruction
				executed on RESUME was taken from BBRUPT
				instead of BRUPT.
		06/02/04 RSB	Found that I was using an unsigned datatype
				for EB, FB, and BB, thus causing comparisons of
				them to registers to fail.  Now autozero the
				unused bits of EB, FB, and BB.
		06/04/04 RSB	Separated ServerStuff function from agc_engine
				function.
		06/05/04 RSB	Fixed the TCAA, ZQ, and ZL instructions.
		06/11/04 RSB	Added a definition for uint16_t in Win32.
		06/30/04 RSB	Made SignExtend, AddSP16, and
				OverflowCorrected non-static.
		07/02/04 RSB	Fixed major bug in SU instruction, in which it
				not only used the wrong value, but overwrote
				the wrong location.
		07/04/04 RSB	Fixed bug (I hope) in converting "decent"
				to "DP".  The DAS instruction did not leave the
				proper values in the A,L registers.
		07/05/04 RSB	Changed DXCH to do overflow-correction on the
				accumulator.  Also, the special cases "DXCH A"
				and "DXCH L" were being checked improperly
				before, and therefore were not treated
				properly.
		07/07/04 RSB	Some cases of DP arithmetic with the MS word
				or LS word being -0 were fixed.
		07/08/04 RSB	CA and CS fixed to re-edit after doing their work.
				Instead of using the overflow-corrected
				accumulator, BZF and BZMF now use the complete
				accumulator.  Either positive or negative
				overflow blocks BZF, while positive overflow
				blocks BZMF.
		07/09/04 RSB	The DAS instruction has been completely rewritten
				to alter the relative signs of the output.
				Previously they were normalized to be identical,
				and this is wrong.  In the DV instruction, the
				case of remainder==0 needed to be fixed up to
				distinguish between +0 and -0.
		07/10/04 RSB	Completely replaced MSU.  And ... whoops! ...
				forgot to inhibit interrupts while the
				accumulator contains overflow.  The special
				cases "DCA L" and "DCS L" have been addressed.
				"CCS A" has been changed similarly to BZF and
				BZMF w.r.t. overflow.
		07/12/04 RSB	Q is now 16 bits.
		07/15/04 RSB	Pretty massive rewrites:  Data alignment changed
				to bit 0 rather than 1.  All registers at
				addresses less than REG16 are now 16 bits,
				rather than just A and Q.
		07/17/04 RSB	The final contents of L with DXCH, DCA, and
				DCS are now overflow-corrected.
		07/19/04 RSB	Added SocketInterlace/Reload.
		08/12/04 RSB	Now account for output ports that are latched
				externally, and for updating newly-attached
				peripherals with current i/o-port values.
		08/13/04 RSB	The Win32 version of yaAGC now recognizes when
				socket-disconnects have occurred, and allows
				the port to be reused.
		08/18/04 RSB	Split off all socket-related stuff into
				SocketAPI.c, so that a cleaner API could be
				available for integrators.
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		05/14/05 RSB	Corrected website references.
		05/15/05 RSB	Oops!  The unprogrammed counter increments were
				hooked up to i/o space rather than to
				erasable.  So incoming counter commands were
				ignored.
		06/11/05 RSB	Implemented the fictitious output channel 0177
				used to make it easier to implement an
				emulation of the gyros.
		06/12/05 RSB	Fixed the CounterDINC function to emit a
				POUT, MOUT, or ZOUT, as it is supposed to.
		06/16/05 RSB	Implemented IMU CDU drive output pulses.
		06/18/05 RSB	Fixed PINC/MINC at +0 to -1 and -0 to +1
				transitions.
		06/25/05 RSB	Fixed the DOWNRUPT interrupt requests.
		06/30/05 RSB	Hopefully fixed fine-alignment, by making
				the gyro torquing depend on the GYROCTR
				register as well as elapsed time.
		07/01/05 RSB	Replaced the gyro-torquing code, to
				avoid simulating the timing of the
				3200 pps. pulses, which was conflicting
				somehow with the timing Luminary wanted
				to impose.
		07/02/05 RSB	OPTXCMD & OPTYCMD.
		07/04/05 RSB	Fix for writes to channel 033.
		08/17/05 RSB	Fixed an embarrassing bug in SpToDecent,
				thanks to Christian Bucher.
		08/20/05 RSB	I no longer allow interrupts when the
				program counter is in the range 0-060.
				I do this principally to guard against the
				case Z=0,1,2, since I'm not sure that all of
				the AGC code saves registers properly in this
				case.  Now I inhibit interrupts prior to
				INHINT, RELINT, and EXTEND (as we're supposed
				to), as well as RESUME (as we're not supposed
				to).  The intent of the latter is to take
				care of problems that occur when EDRUPT is used.
				(Specifically, an interrupt can occur between
				RELINT and RESUME after an EDRUPT, and this
				messes up the return address in ZRUPT used by
				the RESUME.)
		08/21/05 RSB	Removed the interrupt inhibition from the
				address range 0-060, because it prevented
				recovery from certain conditions.
		08/28/05 RSB	Oops!  Had been using PINC sequences on
				TIME6 rather than DINC sequences.
		10/05/05 RSB	FIFOs were introduced for PCDU or MCDU
				commands on the registers CDUX, CDUY, CDUZ.
				The purpose of these FIFOs is to make sure
				that CDUX, CDUY, CDUZ are updated at no
				more than an 800 cps rate, in order to
				avoid problems with the Kalman filter in the
				DAP, which is otherwise likely to reject
				counts that change too quickly.
		10/07/05 RSB	FIFOs changed from 800 cps to either 400 cps
				("low rate") or 6400 cps ("high rate"),
				depending on the variable CduHighRate.
				At the moment, CduHighRate is stuck at 0,
				because we've worked out no way to plausibly
				change it.
		11/13/05 RSB	Took care of auto-adjust buffer timing for
				high-rate and low-rate CDU counter updates.
				PCDU/MCDU commands 1/3 are slow mode, and
				PCDU/MCDU commands 021/023 are fast mode.
		02/26/06 RSB	Oops!  This wouldn't build under Win32 because
				of the lack of an int32_t datatype.  Fixed.

  The technical documentation for the Apollo Guidance & Navigation (G&N) system,
  or more particularly for the Apollo Guidance Computer (AGC) may be found at
  http://hrst.mit.edu/hrs/apollo/public.  That is, to the extent that the
  documentation exists online it may be found there.  I'm sure -- or rather
  HOPE -- that there's more documentation at NASA and MIT than has been made
  available yet.  I personally had no knowledge of the AGC, other than what
  I had seen in the movie "Apollo 13" and the HBO series "From the Earth to
  the Moon", before I conceived this project last night at midnight and
  started doing web searches.  So, bear with me; it's a learning experience!

  Also at hrst.mit.edu are the actual programs for the Command Module (CM) and
  Lunar Module (LM) AGCs.  Or rather, what's there are scans of 1700-page
  printouts of assembly-language listings of SOME versions of those programs.
  (Respectively, called "Colossus" and "Luminary".)  I'll worry about how to
  get those into a usable version only after I get the CPU simulator working!

  What THIS file contains is basicly a pure simulation of the CPU, without any
  input and output as such.  (I/O, to the DSKY or to CM or LM hardware
  simulations occurs through the mechanism of sockets, and hence the DSKY
  front-end and hardware back-end simulations may be implemented as complete
  stand-alone programs and replaced at will.)  There is a single globally
  interesting function, called agc_engine, which is intended to be called once
  per AGC instruction cycle -- i.e., every 11.7 microseconds.  (Yes, that's
  right, the CPU clock speed was a little over 85 KILOhertz.  That's a factor
  that obviously makes the simulation much easier!)  The function may be called
  more or less often than this, to speed up or slow down the apparent passage
  of time.

  This function is intended to be completely portable, so that it may be run in
  a PC environment (Microsoft Windows) or in any *NIX environment, or indeed in
  an embedded target if anybody should wish to create an actual physical
  replacement for an AGC.  Also, multiple copies of the simulation may be run
  on the same PC -- for example to simulation a CM and LM simultaneously.
*/

#define AGC_ENGINE_C
//#include <errno.h>
//#include <stdlib.h>
#include <stdio.h>
#ifdef WIN32
typedef unsigned short uint16_t;
typedef int int32_t;
#endif
#include "yaAGC.h"
#include "agc_engine.h"
#include "agc_symtab.h"

// If COARSE_SMOOTH is 1, then the timing of coarse-alignment (in terms of
// bursting and separation of bursts) is according to the Delco manual.
// However, since the simulated IMU has no physical inertia, it adjusts
// instantly (and therefore jerkily).  The COARSE_SMOOTH constant creates
// smaller bursts, and therefore smoother FDAI motion.  Normally, there are
// 192 pulses in a burst.  In the simulation, there are 192/COARSE_SMOOTH
// pulses in a burst.  COARSE_SMOOTH should be in integral divisor of both
// 192 and of 50*1024.  This constrains it to be any power of 2, up to 64.
#define COARSE_SMOOTH 8

// Some helpful macros for manipulating registers.
#define c(Reg) State->Erasable[0][Reg]
#define IsA(Address) ((Address) == RegA)
#define IsL(Address) ((Address) == RegL)
#define IsQ(Address) ((Address) == RegQ)
#define IsEB(Address) ((Address) == RegEB)
#define IsZ(Address) ((Address) == RegZ)
#define IsReg(Address,Reg) ((Address) == (Reg))

// Some helpful constants in parsing the "address" field from an instruction
// or from the Z register.
#define SIGNAL_00   000000
#define SIGNAL_01   002000
#define SIGNAL_10   004000
#define SIGNAL_11   006000
#define SIGNAL_0011 001400
#define MASK9       000777
#define MASK10      001777
#define MASK12      007777

// Some numerical constant, in AGC format.
#define AGC_P0 ((int16_t) 0)
#define AGC_M0 ((int16_t) 077777)
#define AGC_P1 ((int16_t) 1)
#define AGC_M1 ((int16_t) 077776)

// Here are arrays which tell (for each instruction, as determined by the
// uppermost 5 bits of the instruction) how many extra machine cycles are
// needed to execute the instruction.  (In other words, the total number of
// machine cycles for the instruction, minus 1.) The opcode and quartercode
// are taken into account.  There are two arrays -- one for normal
// instructions and one for "extracode" instructions.
static const int InstructionTiming[32] = {
  0, 0, 0, 0,			// Opcode = 00.
  1, 0, 0, 0,			// Opcode = 01.
  2, 1, 1, 1,			// Opcode = 02.
  1, 1, 1, 1,			// Opcode = 03.
  1, 1, 1, 1,			// Opcode = 04.
  1, 2, 1, 1,			// Opcode = 05.
  1, 1, 1, 1,			// Opcode = 06.
  1, 1, 1, 1			// Opcode = 07.
};

// Note that the following table does not properly handle the EDRUPT or
// BZF/BZMF instructions, and extra delay may need to be added specially for
// those cases.  The table figures 2 MCT for EDRUPT and 1 MCT for BZF/BZMF.
static const int ExtracodeTiming[32] = {
  1, 1, 1, 1,			// Opcode = 010.
  5, 0, 0, 0,			// Opcode = 011.
  1, 1, 1, 1,			// Opcode = 012.
  2, 2, 2, 2,			// Opcode = 013.
  2, 2, 2, 2,			// Opcode = 014.
  1, 1, 1, 1,			// Opcode = 015.
  1, 0, 0, 0,			// Opcode = 016.
  2, 2, 2, 2			// Opcode = 017.
};

// A way, for debugging, to disable interrupts. The 0th entry disables
// everything if 0.  Entries 1-10 disable individual interrupts.
int DebuggerInterruptMasks[11] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };

//-----------------------------------------------------------------------------
// Stuff for doing structural coverage analysis.  Yes, I know it could be done
// much more cleverly.

int CoverageCounts = 0;			// Increment coverage counts is != 0.
unsigned ErasableReadCounts[8][0400];
unsigned ErasableWriteCounts[8][0400];
unsigned ErasableInstructionCounts[8][0400];
unsigned FixedAccessCounts[40][02000];
unsigned IoReadCounts[01000];
unsigned IoWriteCounts[01000];

// For debugging the CDUX,Y,Z inputs.
FILE *CduLog = NULL;


//-----------------------------------------------------------------------------
// Functions for reading or writing from/to i/o channels.  The reason we have
// to provide a function for this rather than accessing the i/o-channel buffer
// directly is that the L and Q registers appear in both memory and i/o space,
// at the same addresses.

int
ReadIO (agc_t * State, int Address)
{
  if (Address < 0 || Address > 0777)
    return (0);
  if (CoverageCounts)
    IoReadCounts[Address]++;
  if (Address == RegL || Address == RegQ)
    return (State->Erasable[0][Address]);
  return (State->InputChannel[Address]);
}

void
WriteIO (agc_t * State, int Address, int Value)
{
  // The value should be in AGC format.
  Value &= 077777;
  if (Address < 0 || Address > 0777)
    return;
  if (CoverageCounts)
    IoWriteCounts[Address]++;
  if (Address == RegL || Address == RegQ)
    State->Erasable[0][Address] = Value;

  // 2005-07-04 RSB.  The necessity for this was pointed out by Mark
  // Grant via Markus Joachim.  Although channel 033 is an input channel,
  // the CPU writes to it from time to time, to "reset" bits 11-15 to 1.
  // Apparently, these are latched inputs, and this resets the latches.
  if (Address == 033)
    Value = (State->InputChannel[Address] | 076000);

  State->InputChannel[Address] = Value;
  if (Address == 010)
    {
      // Channel 10 is converted externally to the CPU into up to 16 ports,
      // by means of latching relays.  We need to capture this data.
      State->OutputChannel10[(Value >> 11) & 017] = Value;
    }
}

void
CpuWriteIO (agc_t * State, int Address, int Value)
{
  static int Downlink = 0;
  WriteIO (State, Address, Value);
  ChannelOutput (State, Address, Value & 077777);
  // 2005-06-25 RSB.  DOWNRUPT stuff.  I assume that the 20 ms. between
  // downlink transmissions is due to the time needed for transmitting,
  // so I don't interrupt at a regular rate,  Instead, I make sure that
  // there are 20 ms. between transmissions
  if (Address == 034)
    Downlink |= 1;
  else if (Address == 035)
    Downlink |= 2;
  if (Downlink == 3)
    {
      //State->InterruptRequests[8] = 1;	// DOWNRUPT.
      State->DownruptTimeValid = 1;
      State->DownruptTime = State->CycleCounter + (AGC_PER_SECOND / 50);
      Downlink = 0;
    }
}

//-----------------------------------------------------------------------------
// This function does all of the processing associated with converting a
// 12-bit "address" as used within instructions or in the Z register, to a
// pointer to the actual word in the simulated memory.  In other words, here
// we take memory bank-selection into account.

static int16_t *
FindMemoryWord (agc_t * State, int Address12)
{
  //int PseudoAddress;
  int AdjustmentEB, AdjustmentFB;

  // Get rid of the parity bit.
  Address12 = Address12;

  // Make sure the darn thing really is 12 bits.
  Address12 &= 07777;

  // It should be noted as far as unswitched-erasable and common-fixed memory
  // is concerned, that the following rules actually do result in continuous
  // block of memory that don't have problems in crossing bank boundaries.
  if (Address12 < 00400)	// Unswitched-erasable.
    return (&State->Erasable[0][Address12 & 00377]);
  else if (Address12 < 01000)	// Unswitched-erasable (continued).
    return (&State->Erasable[1][Address12 & 00377]);
  else if (Address12 < 01400)	// Unswitched-erasable (continued).
    return (&State->Erasable[2][Address12 & 00377]);
  else if (Address12 < 02000)	// Switched-erasable.
    {
      // Recall that the parity bit is accounted for in the shift below.
      AdjustmentEB = (7 & (c (RegEB) >> 8));
      return (&State->Erasable[AdjustmentEB][Address12 & 00377]);
    }
  else if (Address12 < 04000)	// Fixed-switchable.
    {
      AdjustmentFB = (037 & (c (RegFB) >> 10));
      // Account for the superbank bit.
      if (030 == (AdjustmentFB & 030) && (State->OutputChannel7 & 0100) != 0)
	AdjustmentFB += 010;
      return (&State->Fixed[AdjustmentFB][Address12 & 01777]);
    }
  else if (Address12 < 06000)	// Fixed-fixed.
    return (&State->Fixed[2][Address12 & 01777]);
  else				// Fixed-fixed (continued).
    return (&State->Fixed[3][Address12 & 01777]);
}

// Same thing, basically, but for collecting coverage data.
#if 0
static void
CollectCoverage (agc_t * State, int Address12, int Read, int Write, int Instruction)
{
  int AdjustmentEB, AdjustmentFB;

  if (!CoverageCounts)
    return;

  // Get rid of the parity bit.
  Address12 = Address12;

  // Make sure the darn thing really is 12 bits.
  Address12 &= 07777;

  if (Address12 < 00400)	// Unswitched-erasable.
    {
      AdjustmentEB = 0;
      goto Erasable;
    }
  else if (Address12 < 01000)	// Unswitched-erasable (continued).
    {
      AdjustmentEB = 1;
      goto Erasable;
    }
  else if (Address12 < 01400)	// Unswitched-erasable (continued).
    {
      AdjustmentEB = 2;
      goto Erasable;
    }
  else if (Address12 < 02000)	// Switched-erasable.
    {
      // Recall that the parity bit is accounted for in the shift below.
      AdjustmentEB = (7 & (c (RegEB) >> 8));
    Erasable:
      Address12 &= 00377;
      if (Read)
        ErasableReadCounts[AdjustmentEB][Address12]++;
      if (Write)
        ErasableWriteCounts[AdjustmentEB][Address12]++;
      if (Instruction)
        ErasableInstructionCounts[AdjustmentEB][Address12]++;
    }
  else if (Address12 < 04000)	// Fixed-switchable.
    {
      AdjustmentFB = (037 & (c (RegFB) >> 10));
      // Account for the superbank bit.
      if (030 == (AdjustmentFB & 030) && (State->OutputChannel7 & 0100) != 0)
	AdjustmentFB += 010;
    Fixed:
      FixedAccessCounts[AdjustmentFB][Address12 & 01777]++;
    }
  else if (Address12 < 06000)	// Fixed-fixed.
    {
      AdjustmentFB = 2;
      goto Fixed;
    }
  else				// Fixed-fixed (continued).
    {
      AdjustmentFB = 3;
      goto Fixed;
    }
  return;
}
#endif //0

//-----------------------------------------------------------------------------
// Assign a new value to "erasable" memory, performing editing as necessary
// if the destination address is one of the 4 editing registers.  The value to
// be written is a properly formatted AGC value in D1-15.  The difference between
// Assign and AssignFromPointer is simply that Assign needs a memory bank number
// and an offset into that bank, while AssignFromPointer simply uses a pointer
// directly to the simulated memory location.

static int NextZ;

static void
Assign (agc_t * State, int Bank, int Offset, int Value)
{
  if (Bank < 0 || Bank >= 8)
    return;			// Non-erasable memory.
  if (Offset < 0 || Offset >= 0400)
    return;
  if (CoverageCounts)
    ErasableWriteCounts[Bank][Offset]++;
  if (Bank == 0)
    {
      switch (Offset)
	{
	case RegZ:
	  NextZ = Value & 07777;
	  break;
	case RegCYR:
	  Value &= 077777;
	  if (0 != (Value & 1))
	    Value = (Value >> 1) | 040000;
	  else
	    Value = (Value >> 1);
	  break;
	case RegSR:
	  Value &= 077777;
	  if (0 != (Value & 040000))
	    Value = (Value >> 1) | 040000;
	  else
	    Value = (Value >> 1);
	  break;
	case RegCYL:
	  Value &= 077777;
	  if (0 != (Value & 040000))
	    Value = (Value << 1) + 1;
	  else
	    Value = (Value << 1);
	  break;
	case RegEDOP:
	  Value &= 077777;
	  Value = ((Value >> 7) & 0177);
	  break;
	case RegZERO:
	  Value = AGC_P0;
	  break;
	default:
	  // No editing of the Value is needed in this case.
	  break;
	}
      if (Offset >= REG16 || (Offset >= 020 && Offset <= 023))
	State->Erasable[0][Offset] = Value & 077777;
      else
	State->Erasable[0][Offset] = Value & 0177777;
    }
  else
    State->Erasable[Bank][Offset] = Value & 077777;
}

static void
AssignFromPointer (agc_t * State, int16_t * Pointer, int Value)
{
  int Address;
  Address = Pointer - State->Erasable[0];
  if (Address >= 0 && Address < 04000)
    {
      Assign (State, Address / 0400, Address & 0377, Value);
      return;
    }
}

//-----------------------------------------------------------------------------
// Compute the "diminished absolute value".  The input data and output data
// are both in AGC 1's-complement format.

static int16_t
dabs (int16_t Input)
{
  if (0 != (040000 & Input))
    Input = 037777 & ~Input;	// Input was negative, but now is positive.
  if (Input > 1)		// "diminish" it if >1.
    Input--;
  else
    Input = AGC_P0;
  return (Input);
}

// Same, but for 16-bit registers.
static int
odabs (int Input)
{
  if (0 != (0100000 & Input))
    Input = (0177777 & ~Input);	// Input was negative, but now is positive.
  if (Input > 1)		// "diminish" it if >1.
    Input--;
  else
    Input = AGC_P0;
  return (Input);
}

//-----------------------------------------------------------------------------
// Convert an AGC-formatted word to CPU-native format.

static int
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

static int
cpu2agc (int Input)
{
  if (Input < 0)
    return (077777 & ~(-Input));
  else
    return (077777 & Input);
}

//-----------------------------------------------------------------------------
// Double-length versions of the same.

static int
agc2cpu2 (int Input)
{
  if (0 != (02000000000 & Input))
    return (-(01777777777 & ~Input));
  else
    return (01777777777 & Input);
}

static int
cpu2agc2 (int Input)
{
  if (Input < 0)
    return (03777777777 & ~(01777777777 & (-Input)));
  else
    return (01777777777 & Input);
}

//----------------------------------------------------------------------------
// Here is a small suite of functions for converting back and forth between
// 15-bit SP values and 16-bit accumulator values.

#if 0

// Gets the full 16-bit value of the accumulator (plus parity bit).

static int
GetAccumulator (agc_t * State)
{
  int Value;
  Value = State->Erasable[0][RegA];
  Value &= 0177777;
  return (Value);
}

// Gets the full 16-bit value of Q (plus parity bit).

static int
GetQ (agc_t * State)
{
  int Value;
  Value = State->Erasable[0][RegQ];
  Value &= 0177777;
  return (Value);
}

// Store a 16-bit value (plus parity) into the accumulator.

static void
PutAccumulator (agc_t * State, int Value)
{
  c (RegA) = (Value & 0177777);
}

// Store a 16-bit value (plus parity) into Q.

static void
PutQ (agc_t * State, int Value)
{
  c (RegQ) = (Value & 0177777);
}

#endif // 0

// Returns +1, -1, or +0 (in SP) format, on the basis of whether an
// accumulator-style "16-bit" value (really 17 bits including parity)
// contains overflow or not.  To do this for the accumulator itself,
// use ValueOverflowed(GetAccumulator(State)).

static int16_t
ValueOverflowed (int Value)
{
  switch (Value & 0140000)
    {
    case 0040000:
      return (AGC_P1);
    case 0100000:
      return (AGC_M1);
    default:
      return (AGC_P0);
    }
}

// Return an overflow-corrected value from a 16-bit (plus parity ) SP word.
// This involves just moving bit 16 down to bit 15.

int16_t OverflowCorrected (int Value)
{
  return ((Value & 037777) | ((Value >> 1) & 040000));
}

// Sign-extend a 15-bit SP value so that it can go into the 16-bit (plus parity)
// accumulator.

int
SignExtend (int16_t Word)
{
  return ((Word & 077777) | ((Word << 1) & 0100000));
}

//-----------------------------------------------------------------------------
// Here are functions to convert a DP into a more-decent 1's-
// complement format in which there's not an extra sign-bit to contend with.
// (In other words, a 29-bit format in which there's a single sign bit, rather
// than a 30-bit format in which there are two sign bits.)  And vice-versa.
// The DP value consists of two adjacent SP values, MSW first and LSW second,
// and we're given a pointer to the second word.  The main difficulty here
// is dealing with the case when the two SP words don't have the same sign,
// and making sure all of the signs are okay when one or more words are zero.
// A sign-extension is added a la the normal accumulator.

static int
SpToDecent (int16_t * LsbSP)
{
  int16_t Msb, Lsb;
  int Value, Complement;
  Msb = LsbSP[-1];
  Lsb = *LsbSP;
  if (Msb == AGC_P0 || Msb == AGC_M0)	// Msb is zero.
    {
      // As far as the case of the sign of +0-0 or -0+0 is concerned,
      // we follow the convention of the DV instruction, in which the
      // overall sign is the sign of the less-significant word.
      Value = SignExtend (Lsb);
      if (Value & 0100000)
	Value |= ~0177777;
      return (07777777777 & Value);	// Eliminate extra sign-ext. bits.
    }
  // If signs of Msb and Lsb words don't match, then make them match.
  if ((040000 & Lsb) != (040000 & Msb))
    {
      if (Lsb == AGC_P0 || Lsb == AGC_M0)	// Lsb is zero.
	{
	  // Adjust sign of Lsb to match Msb.
	  if (0 == (040000 & Msb))
	    Lsb = AGC_P0;
	  else
	    Lsb = AGC_M0;	// 2005-08-17 RSB.  Was "Msb".  Oops!
	}
      else			// Lsb is not zero.
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

static void
DecentToSp (int Decent, int16_t * LsbSP)
{
  int Sign;
  Sign = (Decent & 04000000000);
  *LsbSP = (037777 & Decent);
  if (Sign)
    *LsbSP |= 040000;
  LsbSP[-1] = OverflowCorrected (0177777 & (Decent >> 14));	// Was 13.
}

// Adds two sign-extended SP values.  The result may contain overflow.
int
AddSP16 (int Addend1, int Addend2)
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

static int16_t
AbsSP (int16_t Value)
{
  if (040000 & Value)
    return (077777 & ~Value);
  return (Value);
}

// Check if an SP value is negative.

//static int
//IsNegativeSP (int16_t Value)
//{
//  return (0 != (0100000 & Value));
//}

// Negate an SP value.

static int16_t
NegateSP (int16_t Value)
{
  return (077777 & ~Value);
}

//-----------------------------------------------------------------------------
// The following are various operations performed on counters, as defined
// in Savage & Drake (E-2052) 1.4.8.  The functions all return 0 normally,
// and return 1 on overflow.

#include <stdio.h>
static int TrapPIPA = 0;

// 1's-complement increment
int
CounterPINC (int16_t * Counter)
{
  int16_t i;
  int Overflow = 0;
  i = *Counter;
  if (i == 037777)
    {
      Overflow = 1;
      i = AGC_P0;
    }
  else
    {
      Overflow = 0;
      if (TrapPIPA)
        printf ("PINC: %o", i);
      i = ((i + 1) & 077777);
      if (TrapPIPA)
        printf (" %o", i);
      if (i == AGC_P0)	// Account for -0 to +1 transition.
        i++;
      if (TrapPIPA)
        printf (" %o\n", i);
    }
  *Counter = i;
  return (Overflow);
}

// 1's-complement decrement, but only of negative integers.
int
CounterMINC (int16_t * Counter)
{
  int16_t i;
  int Overflow = 0;
  i = *Counter;
  if (i == (int16_t) 040000)
    {
      Overflow = 1;
      i = AGC_M0;
    }
  else
    {
      Overflow = 0;
      if (TrapPIPA)
        printf ("MINC: %o", i);
      i = ((i - 1) & 077777);
      if (TrapPIPA)
        printf (" %o", i);
      if (i == AGC_M0)	// Account for +0 to -1 transition.
        i--;
      if (TrapPIPA)
        printf (" %o\n", i);
    }
  *Counter = i;
  return (Overflow);
}

// 2's-complement increment.
int
CounterPCDU (int16_t * Counter)
{
  int16_t i;
  int Overflow = 0;
  i = *Counter;
  if (i == (int16_t) 077777)
    Overflow = 1;
  i++;
  i &= 077777;
  *Counter = i;
  return (Overflow);
}

// 2's-complement decrement.
int
CounterMCDU (int16_t * Counter)
{
  int16_t i;
  int Overflow = 0;
  i = *Counter;
  if (i == 0)
    Overflow = 1;
  i--;
  i &= 077777;
  *Counter = i;
  return (Overflow);
}

// Diminish increment.
int
CounterDINC (agc_t *State, int CounterNum, int16_t * Counter)
{
  //static int CountTIME6 = 0;
  int RetVal = 0;
  //int IsTIME6, FlushTIME6;
  int16_t i;
  //IsTIME6 = (Counter == &c (RegTIME6));
  //FlushTIME6 = 0;
  i = *Counter;
  if (i == AGC_P0 || i == AGC_M0)	// Zero?
    {
      // Emit a ZOUT.
      if (CounterNum != 0)
        ChannelOutput (State, 0x80 | CounterNum, 017);
    }
  else if (040000 & i)			// Negative?
    {
      i++;
      if (i == AGC_M0)
        {
          RetVal = -1;
	  //if (IsTIME6)
	  //  FlushTIME6 = 1;
	}
      //else if (IsTIME6)
      //  {
      //    CountTIME6--;
      //    if (CountTIME6 <= -160)
      //      FlushTIME6 = 1;
      //  }
      // Emit a MOUT.
      if (CounterNum != 0)
        ChannelOutput (State, 0x80 | CounterNum, 016);
    }
  else					// Positive?
    {
      i--;
      if (i == AGC_P0)
        {
          RetVal = 1;
	  //if (IsTIME6)
	  //  FlushTIME6 = 1;
	}
      //else if (IsTIME6)
      //  {
      //    CountTIME6++;
      //    if (CountTIME6 >= 160)
      //      FlushTIME6 = 1;
      //  }
      // Emit a POUT.
      if (CounterNum != 0)
        ChannelOutput (State, 0x80 | CounterNum, 015);
    }
  *Counter = i;
  //if (FlushTIME6 && CountTIME6)
  //  {
  //    ChannelOutput (State, 0165, CountTIME6);
  //    CountTIME6 = 0;
  //  }
  return (RetVal);
}

// Left-shift increment.
int
CounterSHINC (int16_t * Counter)
{
  int16_t i;
  int Overflow = 0;
  i = *Counter;
  if (020000 & i)
    Overflow = 1;
  i = (i << 1) & 037777;
  *Counter = i;
  return (Overflow);
}

// Left-shift and add increment.
int
CounterSHANC (int16_t * Counter)
{
  int16_t i;
  int Overflow = 0;
  i = *Counter;
  if (020000 & i)
    Overflow = 1;
  i = ((i << 1) + 1) & 037777;
  *Counter = i;
  return (Overflow);
}

// Pinch hits for the above in setting interrupt requests with INCR,
// AUG, and DIM instructins.  The docs aren't very forthcoming as to
// which counter registers are affected by this ... but still.

static void
InterruptRequests (agc_t * State, int16_t Address10, int Sum)
{
  if (ValueOverflowed (Sum) == AGC_P0)
    return;
  if (IsReg (Address10, RegTIME1))
    CounterPINC (&c (RegTIME2));
  else if (IsReg (Address10, RegTIME6))
    State->InterruptRequests[1] = 1;
  else if (IsReg (Address10, RegTIME5))
    State->InterruptRequests[2] = 1;
  else if (IsReg (Address10, RegTIME3))
    State->InterruptRequests[3] = 1;
  else if (IsReg (Address10, RegTIME4))
    State->InterruptRequests[4] = 1;
}

//-------------------------------------------------------------------------------
// The case of PCDU or MCDU triggers being applied to the CDUX,Y,Z counters
// presents a special problem.  The AGC expects these triggers to be
// applied at a certain fixed rate.  The DAP portion of Luminary or Colossus
// applies a digital filter to the counts, in order to eliminate electrical
// noise, as well as noise caused by vibration of the spacecraft.  Therefore,
// if the simulated IMU applies PCDU/MCDU triggers too fast, the digital
// filter in the DAP will simply reject the count, and therefore the spacecraft's
// orientation cannot be measured by the DAP.  Consequently, we have to
// fake up a kind of FIFO on the triggers to the CDUX,Y,Z counters so that
// we can increment or decrement the counters at no more than the fixed rate.
// (Conversely, of course, the simulated IMU has to be able to supply the
// triggers *at least* as fast as the fixed rate.)
//
// Actually, there are two different fixed rates for PCDU/MCDU:  400 counts
// per second in "slow mode", and 6400 counts per second in "fast mode".
//
// *** FIXME! All of the following junk will need to move to agc_t, and will
//     somehow have to be made compatible with backtraces. ***
// The way the FIFO works is that it can hold an ordered set of + counts and
// - counts.  For example, if it held 7,-5,10, it would mean to apply 7 PCDUs,
// followed by 5 MCDUs, followed by 10 PCDUs.  If there are too many sign-changes
// buffered, triggers will be transparently dropped.
#define MAX_CDU_FIFO_ENTRIES 128
#define NUM_CDU_FIFOS 3			// Increase to 5 to include OPTX, OPTY.
#define FIRST_CDU 032
typedef struct {
  int Ptr;				// Index of next entry being pulled.
  int Size;				// Number of entries.
  int IntervalType;			// 0,1,2,0,1,2,...
  uint64_t NextUpdate;			// Cycle count at which next counter update occurs.
  int32_t Counts[MAX_CDU_FIFO_ENTRIES];
} CduFifo_t;
static CduFifo_t CduFifos[NUM_CDU_FIFOS];// For registers 032, 033, and 034.
static int CduChecker = 0;		// 0, 1, ..., NUM_CDU_FIFOS-1, 0, 1, ...

// Here's an auxiliary function to add a count to a CDU FIFO.  The only allowed
// increment types are:
//	001	PCDU "slow mode"
//	003	MCDU "slow mode"
//	021	PCDU "fast mode"
//	023	MCDU "fast mode"
// Within the FIFO, we distinguish these cases as follows:
//	001	Upper bits = 00
//	003	Upper bits = 01
//	021	Upper bits = 10
//	023	Upper bits = 11
// The least-significant 30 bits are simply the absolute value of the count.
static void
PushCduFifo (agc_t *State, int Counter, int IncType)
{
  CduFifo_t *CduFifo;
  int Next, Interval;
  int32_t Base;
  if (Counter < FIRST_CDU || Counter >= FIRST_CDU + NUM_CDU_FIFOS)
    return;
  switch (IncType)
    {
    case 1:
      Interval = 213;
      Base = 0x00000000;
      break;
    case 3:
      Interval = 213;
      Base = 0x40000000;
      break;
    case 021:
      Interval = 13;
      Base = 0x80000000;
      break;
    case 023:
      Interval = 13;
      Base = 0xC0000000;
      break;
    default:
      return;
    }
  if (CduLog != NULL)
    fprintf (CduLog, "< %Ld %o %02o\n", State->CycleCounter, Counter, IncType);
  CduFifo = &CduFifos[Counter - FIRST_CDU];
  // It's a little easier if the FIFO is completely empty.
  if (CduFifo->Size == 0)
    {
      CduFifo->Ptr = 0;
      CduFifo->Size = 1;
      CduFifo->Counts[0] = Base + 1;
      CduFifo->NextUpdate = State->CycleCounter + Interval;
      CduFifo->IntervalType = 1;
      return;
    }
  // Not empty, so find the last entry in the FIFO.
  Next = CduFifo->Ptr + CduFifo->Size - 1;
  if (Next >= MAX_CDU_FIFO_ENTRIES)
    Next -= MAX_CDU_FIFO_ENTRIES;
  // Last entry has different sign from the new data?
  if ((CduFifo->Counts[Next] & 0xC0000000) != Base)
    {
      // The sign is different, so we have to add a new entry to the
      // FIFO.
      if (CduFifo->Size >= MAX_CDU_FIFO_ENTRIES)
        {
	  // No place to put it, so drop the data.
	  return;
	}
      CduFifo->Size++;
      Next++;
      if (Next >= MAX_CDU_FIFO_ENTRIES)
        Next -= MAX_CDU_FIFO_ENTRIES;
      CduFifo->Counts[Next] = Base + 1;
      return;
    }
  // Okay, add in the new data to the last FIFO entry.  The sign is assured
  // to be compatible.  The size of the FIFO doesn't increase. We also don't
  // bother to check for arithmetic overflow, since only the wildest IMU
  // failure could cause it.
  CduFifo->Counts[Next]++;
}

// Here's an auxiliary function to perform the next available PCDU or MCDU
// from a CDU FIFO, if it is time to do so.  We only check one of the CDUs
// each time around (in order to preserve proper cycle counts), so this function
// must be called at at least an 6400*NUM_CDU_FIFO cps rate.  Returns 0 if no
// counter was updated, non-zero if a counter was updated.
static int
ServiceCduFifo (agc_t *State)
{
  int Count, RetVal = 0, HighRate, DownCount;
  CduFifo_t *CduFifo;
  int16_t *Ch;
  // See if there are any pending PCDU or MCDU counts we need to apply.  We only
  // check one of the CDUs, and the CDU to check is indicated by CduChecker.
  CduFifo = &CduFifos[CduChecker];

  if (CduFifo->Size > 0 && State->CycleCounter >= CduFifo->NextUpdate)
    {
      // Update the counter.
      Ch = &State->Erasable[0][CduChecker + FIRST_CDU];
      Count = CduFifo->Counts[CduFifo->Ptr];
      HighRate = (Count & 0x80000000);
      DownCount = (Count & 0x40000000);
      if (DownCount)
        {
          CounterMCDU (Ch);
	  if (CduLog != NULL)
	    fprintf (CduLog, ">\t\t%Ld %o 03\n", State->CycleCounter, CduChecker + FIRST_CDU);
	}
      else
        {
          CounterPCDU (Ch);
	  if (CduLog != NULL)
	    fprintf (CduLog, ">\t\t%Ld %o 01\n", State->CycleCounter, CduChecker + FIRST_CDU);
	}
      Count--;
      // Update the FIFO.
      if (0 != (Count & ~0xC0000000))
        CduFifo->Counts[CduFifo->Ptr] = Count;
      else
        {
	  // That FIFO entry is exhausted.  Remove it from the FIFO.
	  CduFifo->Size--;
	  CduFifo->Ptr++;
	  if (CduFifo->Ptr >= MAX_CDU_FIFO_ENTRIES)
	    CduFifo->Ptr = 0;
	}
      // And set next update time.
      // Set up for next update time.  The intervals is are of the form
      // x, x, y, depending on whether CduIntervalType is 0, 1, or 2.
      // This is done because with a cycle type of 1024000/12 cycles per
      // second, the exact CDU update times don't fit on exact cycle
      // boundaries, but every 3rd CDU update does hit a cycle boundary.
      if (CduFifo->NextUpdate == 0)
        CduFifo->NextUpdate = State->CycleCounter;
      if (CduFifo->IntervalType < 2)
	{
	  if (HighRate)
	    CduFifo->NextUpdate += 13;
	  else
	    CduFifo->NextUpdate += 213;
	  CduFifo->IntervalType++;
	}
      else
	{
	  if (HighRate)
	    CduFifo->NextUpdate += 14;
	  else
	    CduFifo->NextUpdate += 214;
	  CduFifo->IntervalType = 0;
	}
      // Return an indication that a counter was updated.
      RetVal = 1;
    }

  CduChecker++;
  if (CduChecker >= NUM_CDU_FIFOS)
    CduChecker = 0;

  return (RetVal);
}

//----------------------------------------------------------------------------
// This function is used to update the counter registers on the basis of
// commands received from the outside world.

void
UnprogrammedIncrement (agc_t *State, int Counter, int IncType)
{
  int16_t *Ch;
  int Overflow = 0;
  Counter &= 0x7f;
  Ch = &State->Erasable[0][Counter];
  if (CoverageCounts)
    ErasableWriteCounts[0][Counter]++;
  switch (IncType)
    {
    case 0:
      //TrapPIPA = (Counter >= 037 && Counter <= 041);
      Overflow = CounterPINC (Ch);
      break;
    case 1:
    case 021:
      // For the CDUX,Y,Z counters, push the command into a FIFO.
      if (Counter >= FIRST_CDU && Counter < FIRST_CDU + NUM_CDU_FIFOS)
        PushCduFifo (State, Counter, IncType);
      else
        Overflow = CounterPCDU (Ch);
      break;
    case 2:
      //TrapPIPA = (Counter >= 037 && Counter <= 041);
      Overflow = CounterMINC (Ch);
      break;
    case 3:
    case 023:
      // For the CDUX,Y,Z counters, push the command into a FIFO.
      if (Counter >= FIRST_CDU && Counter < FIRST_CDU + NUM_CDU_FIFOS)
        PushCduFifo (State, Counter, IncType);
      else
        Overflow = CounterMCDU (Ch);
      break;
    case 4:
      Overflow = CounterDINC (State, Counter, Ch);
      break;
    case 5:
      Overflow = CounterSHINC (Ch);
      break;
    case 6:
      Overflow = CounterSHANC (Ch);
      break;
    default:
      break;
    }
  if (Overflow)
    {
      // On some counters, overflow is supposed to cause
      // an interrupt.  Take care of setting the interrupt request here.

    }
  TrapPIPA = 0;
}

//----------------------------------------------------------------------------
// Function handles the coarse-alignment output pulses for one IMU CDU drive axis.
// It returns non-0 if a non-zero count remains on the axis, 0 otherwise.

static int
BurstOutput (agc_t *State, int DriveBitMask, int CounterRegister, int Channel)
{
  static int CountCDUX = 0, CountCDUY = 0, CountCDUZ = 0;  // In target CPU format.
  int DriveCount = 0, DriveBit, Direction = 0, Delta, DriveCountSaved;
  if (CounterRegister == RegCDUXCMD)
    DriveCountSaved = CountCDUX;
  else if (CounterRegister == RegCDUYCMD)
    DriveCountSaved = CountCDUY;
  else if (CounterRegister == RegCDUZCMD)
    DriveCountSaved = CountCDUZ;
  else
    return (0);
  // Driving this axis?
  DriveBit = (State->InputChannel[014] & DriveBitMask);
  // If so, we must retrieve the count from the counter register.
  if (DriveBit)
    {
      DriveCount = State->Erasable[0][CounterRegister];
      State->Erasable[0][CounterRegister] = 0;
    }
  // The count may be negative.  If so, normalize to be positive and set the
  // direction flag.
  Direction = (040000 & DriveCount);
  if (Direction)
    {
      DriveCount ^= 077777;
      DriveCountSaved -= DriveCount;
    }
  else
    DriveCountSaved += DriveCount;
  if (DriveCountSaved < 0)
    {
      DriveCountSaved = -DriveCountSaved;
      Direction = 040000;
    }
  else
    Direction = 0;
  // Determine how many pulses to output.  The max is 192 per burst.
  Delta = DriveCountSaved;
  if (Delta >= 192 / COARSE_SMOOTH)
    Delta = 192 / COARSE_SMOOTH;
  // If the count is non-zero, pulse it.
  if (Delta > 0)
    {
      ChannelOutput (State, Channel, Direction | Delta);
      DriveCountSaved -= Delta;
    }
  if (Direction)
    DriveCountSaved = -DriveCountSaved;
  if (CounterRegister == RegCDUXCMD)
    CountCDUX = DriveCountSaved;
  else if (CounterRegister == RegCDUYCMD)
    CountCDUY = DriveCountSaved;
  else if (CounterRegister == RegCDUZCMD)
    CountCDUZ = DriveCountSaved;
  return (DriveCountSaved);
}

//-----------------------------------------------------------------------------
// Execute one machine-cycle of the simulation.  Use agc_engine_init prior to
// the first call of agc_engine, to initialize State, and then call agc_engine
// thereafter every (simulated) 11.7 microseconds.
//
// Returns:
//      0 -- success
// I'm not sure if there are any circumstances under which this can fail ...

// Note on addressing of bits within words:  The MIT docs refer to bits
// 1 through 15, with 1 being the least-significant, and 15 the most
// significant.  A 16th bit, the (odd) parity bit, would be bit 0 in this
// scheme.  Now, we're probably not going to use the parity bit in our
// simulation -- I haven't fully decided this at the time I'm writing
// this note -- so we have a choice of whether to map the 15 bits that ARE
// used to D0-14 or to D1-15.  I'm going to choose the latter, even though
// it requires slightly more processing, in order to conform as obviously
// as possible to the MIT docs.

#define SCALER_OVERFLOW 160
#define SCALER_DIVIDER 3
static int ScalerCounter = 0;

// Fine-alignment.
// The gyro needs 3200 pulses per second, and therefore counts twice as
// fast as the regular 1600 pps counters.
#define GYRO_OVERFLOW 160
#define GYRO_DIVIDER (2 * 3)
static unsigned GyroCount = 0;
static unsigned OldChannel14 = 0, GyroTimer = 0;

// Coarse-alignment.
// The IMU CDU drive emits bursts every 600 ms.  Each cycle is
// 12/1024000 seconds long.  This happens to mean that a burst is
// emitted every 51200 CPU cycles, but we multiply it out below
// to make it look pretty
#define IMUCDU_BURST_CYCLES ((600 * 1024000) / (1000 * 12 * COARSE_SMOOTH))
static uint64_t ImuCduCount = 0;
static unsigned ImuChannel14 = 0;

int
agc_engine (agc_t * State)
{
  int i, j;
  static int Count = 0;
  uint16_t ProgramCounter, Instruction, OpCode, QuarterCode, sExtraCode;
  int16_t *WhereWord;
  uint16_t Address12, Address10, Address9;
  int ValueK, KeepExtraCode = 0;
  //int Operand;
  int16_t Operand16;
  int16_t CurrentEB, CurrentFB, CurrentBB;
  uint16_t ExtendedOpcode;
  int Overflow, Accumulator;
  //int OverflowQ, Qumulator;

  sExtraCode = 0;

  // For DOWNRUPT
  if (State->DownruptTimeValid && State->CycleCounter >= State->DownruptTime)
    {
      State->InterruptRequests[8] = 1;	// Request DOWNRUPT
      State->DownruptTimeValid = 0;
    }

  State->CycleCounter++;

  //----------------------------------------------------------------------
  // The following little thing is useful only for debugging yaDEDA with
  // the --debug-deda command-line switch.  It just outputs the contents
  // of the address that was specified by the DEDA at 1/2 second intervals.
  if (DedaMonitor && State->CycleCounter >= DedaWhen)
    {
      int16_t Data;
      Data = State->Erasable[0][DedaAddress];
      DedaWhen = State->CycleCounter + 1024000 / 24;	// 1/2 second.
      ShiftToDeda (State, (DedaAddress >> 6) & 7);
      ShiftToDeda (State, (DedaAddress >> 3) & 7);
      ShiftToDeda (State, DedaAddress & 7);
      ShiftToDeda (State, 0);
      ShiftToDeda (State, (Data >> 12) & 7);
      ShiftToDeda (State, (Data >> 9) & 7);
      ShiftToDeda (State, (Data >> 6) & 7);
      ShiftToDeda (State, (Data >> 3) & 7);
      ShiftToDeda (State, Data & 7);
    }

  //----------------------------------------------------------------------
  // Update the thingy that determines when 1/1600 second has passed.
  // 1/1600 is the basic timing used to drive timer registers.  1/1600
  // second happens to be 160/3 machine cycles.

  ScalerCounter += SCALER_DIVIDER;

  //-------------------------------------------------------------------------

  // Handle server stuff for socket connections used for i/o channel
  // communications.  Stuff like listening for clients we only do
  // every once and a while---nominally, every 100 ms.  Actually
  // processing input data is done every cycle.
  if (Count == 0)
    ChannelRoutine (State);
  Count = ((Count + 1) & 017777);

  // Get data from input channels.  Return immediately if a unprogrammed
  // counter-increment was performed.
  if (ChannelInput (State))
    return (0);

  // If in --debug-dsky mode, don't want to take the chance of executing
  // any AGC code, since there isn't any loaded anyway.
  if (DebugDsky)
    return (0);

  //----------------------------------------------------------------------
  // This stuff takes care of extra CPU cycles used by some instructions.

  // A little extra delay, needed sometimes after branch instructions that
  // don't always take the same amount of time.
  if (State->ExtraDelay)
    {
      State->ExtraDelay--;
      return (0);
    }

  // If an instruction that takes more than one clock-cycle is in progress,
  // we simply return.  We don't do any of the actual computations for such
  // an instruction until the last clock cycle for it is reached.
  // (Except for a few weird cases dealt with by ExtraDelay as above.)
  if (State->PendFlag && State->PendDelay > 0)
    {
      State->PendDelay--;
      return (0);
    }

  //----------------------------------------------------------------------
  // Take care of any PCDU or MCDU operations that are lingering in CDU
  // FIFOs.
  if (ServiceCduFifo (State))
    {
      // A CDU counter was serviced, so a cycle was used up, and we must
      // return.
      return (0);
    }

  //----------------------------------------------------------------------
  // Here we take care of counter-timers.  There is a basic 1/1600 second
  // clock that is used to drive the timers.  1/1600 second happens to
  // be SCALER_OVERFLOW/SCALER_DIVIDER machine cycles, and the variable
  // ScalerCounter has already been updated the correct number of
  // multiples of SCALER_DIVIDER.  Note that incrementing a timer register
  // takes 1 machine cycle.

  // This can only iterate once, but I use 'while' just in case.
  while (ScalerCounter >= SCALER_OVERFLOW)
    {
      // First, update SCALER1 and SCALER2.
      ScalerCounter -= SCALER_OVERFLOW;
      if (CounterPINC (&State->InputChannel[ChanSCALER1]))
	{
	  State->ExtraDelay++;
	  CounterPINC (&State->InputChannel[ChanSCALER2]);
	}
      // Check whether there was a pulse into bit 5 of SCALER1.
      // If so, the 10 ms. timers TIME1 and TIME3 are updated.
      // Recall that the registers are in AGC integer format,
      // and therefore are actually shifted left one space.
      if (0 == (017 & State->InputChannel[ChanSCALER1]))
	{
	  State->ExtraDelay++;
	  if (CounterPINC (&c (RegTIME1)))
	    {
	      State->ExtraDelay++;
	      CounterPINC (&c (RegTIME2));
	    }
	  State->ExtraDelay++;
	  if (CounterPINC (&c (RegTIME3)))
	    State->InterruptRequests[3] = 1;
	  // I have very little data about what TIME5 is supposed to do.
	  // From the table on p. 1-64 of Savage & Drake, I assume
	  // it works just like TIME3.
	  State->ExtraDelay++;
	  if (CounterPINC (&c (RegTIME5)))
	    State->InterruptRequests[2] = 1;
	}
      // TIME4 is the same as TIME3, but 5 ms. out of phase.
      if (010 == (017 & State->InputChannel[ChanSCALER1]))
	{
	  State->ExtraDelay++;
	  if (CounterPINC (&c (RegTIME4)))
	    State->InterruptRequests[4] = 1;
	}
      // I'm not sure if TIME6 is supposed to count when the T6 RUPT
      // is disabled or not.  For the sake of argument, I'll assume
      // that it is.  Nor am I sure how many bits this counter has.
      // I'll assume 14.  Nor if it's out of phase with SCALER1.
      // Nor ... well, you get the idea.
      State->ExtraDelay++;
      if (CounterDINC (State, 0, &c (RegTIME6)))
	if (040000 & State->InputChannel[013])
	  State->InterruptRequests[1] = 1;
      // Return, so as to account for the time occupied by updating the
      // counters.
      return (0);
    }

  //----------------------------------------------------------------------
  // Same principle as for the counter-timers (above), but for handling
  // the 3200 pulse-per-second fictitious register 0177 I use to support
  // driving the gyro.

#ifdef GYRO_TIMING_SIMULATED
  // Update the 3200 pps gyro pulse counter.
  GyroTimer += GYRO_DIVIDER;
  while (GyroTimer >= GYRO_OVERFLOW)
    {
      GyroTimer -= GYRO_OVERFLOW;
      // We get to this point 3200 times per second.  We increment the
      // pulse count only if the GYRO ACTIVITY bit in channel 014 is set.
      if (0 != (State->InputChannel[014] & 01000) &&
          State->Erasable[0][RegGYROCTR] > 0)
	{
          GyroCount++;
	  State->Erasable[0][RegGYROCTR]--;
	  if (State->Erasable[0][RegGYROCTR] == 0)
	    State->InputChannel[014] &= ~01000;
	}
    }

  // If 1/4 second (nominal gyro pulse count of 800 decimal) or the gyro
  // bits in channel 014 have changed, output to channel 0177.
  i = (State->InputChannel[014] & 01740);  // Pick off the gyro bits.
  if (i != OldChannel14 || GyroCount >= 800)
    {
      j = ((OldChannel14 & 0740) << 6) | GyroCount;
      OldChannel14 = i;
      GyroCount = 0;
      ChannelOutput (State, 0177, j);
    }
#else // GYRO_TIMING_SIMULATED
#define GYRO_BURST 800
#define GYRO_BURST2 1024
  if (0 != (State->InputChannel[014] & 01000))
    if (0 != State->Erasable[0][RegGYROCTR])
      {
        // If any torquing is still pending, do it all at once before
	// setting up a new torque counter.
        while (GyroCount)
	  {
	    j = GyroCount;
	    if (j > 03777)
	      j = 03777;
	    ChannelOutput (State, 0177, OldChannel14 | j);
	    GyroCount -= j;
	  }
	// Set up new torque counter.
	GyroCount = State->Erasable[0][RegGYROCTR];
	State->Erasable[0][RegGYROCTR] = 0;
	OldChannel14 = ((State->InputChannel[014] & 0740) << 6);
	GyroTimer = GYRO_OVERFLOW * GYRO_BURST - GYRO_DIVIDER;
      }
  // Update the 3200 pps gyro pulse counter.
  GyroTimer += GYRO_DIVIDER;
  while (GyroTimer >= GYRO_BURST * GYRO_OVERFLOW)
    {
      GyroTimer -= GYRO_BURST * GYRO_OVERFLOW;
      if (GyroCount)
        {
	  j = GyroCount;
	  if (j > GYRO_BURST2)
	    j = GYRO_BURST2;
	  ChannelOutput (State, 0177, OldChannel14 | j);
	  GyroCount -= j;
	}
    }
#endif // GYRO_TIMING_SIMULATED

  //----------------------------------------------------------------------
  // ... and somewhat similar principles for the IMU CDU drive for
  // coarse alignment.

#if 0
  i = (State->InputChannel[014] & 070000);	// Check IMU CDU drive bits.
  if (ImuChannel14 == 0 && i != 0)		// If suddenly active, start drive.
    ImuCduCount = IMUCDU_BURST_CYCLES;
  if (i != 0 && ImuCduCount >= IMUCDU_BURST_CYCLES)	// Time for next burst.
    {
      // Adjust the cycle counter.
      ImuCduCount -= IMUCDU_BURST_CYCLES;
      // Determine how many pulses are wanted on each axis this burst.
      ImuChannel14 = BurstOutput (State, 040000, RegCDUXCMD, 0174);
      ImuChannel14 |= BurstOutput (State, 020000, RegCDUYCMD, 0175);
      ImuChannel14 |= BurstOutput (State, 010000, RegCDUZCMD, 0176);
    }
  else
    ImuCduCount++;
#else // 0
  i = (State->InputChannel[014] & 070000);	// Check IMU CDU drive bits.
  if (ImuChannel14 == 0 && i != 0)		// If suddenly active, start drive.
    ImuCduCount = State->CycleCounter - IMUCDU_BURST_CYCLES;
  if (i != 0 && (State->CycleCounter - ImuCduCount) >= IMUCDU_BURST_CYCLES) // Time for next burst.
    {
      // Adjust the cycle counter.
      ImuCduCount += IMUCDU_BURST_CYCLES;
      // Determine how many pulses are wanted on each axis this burst.
      ImuChannel14 = BurstOutput (State, 040000, RegCDUXCMD, 0174);
      ImuChannel14 |= BurstOutput (State, 020000, RegCDUYCMD, 0175);
      ImuChannel14 |= BurstOutput (State, 010000, RegCDUZCMD, 0176);
    }
#endif // 0

  //----------------------------------------------------------------------
  // Finally, stuff for driving the optics shaft & trunnion CDUs.  Nothing
  // fancy like the fine-alignment and coarse-alignment stuff above.
  // Just grab the data from the counter and dump it out the appropriate
  // fictitious port as a giant lump.

  if (State->Erasable[0][RegOPTX] && 0 != (State->InputChannel[014] & 02000))
    {
      ChannelOutput (State, 0172, State->Erasable[0][RegOPTX]);
      State->Erasable[0][RegOPTX] = 0;
    }
  if (State->Erasable[0][RegOPTY] && 0 != (State->InputChannel[014] & 04000))
    {
      ChannelOutput (State, 0171, State->Erasable[0][RegOPTY]);
      State->Erasable[0][RegOPTY] = 0;
    }

  //----------------------------------------------------------------------
  // Okay, here's the stuff that actually has to do with decoding instructions.

  // Store the current value of several registers.
  CurrentEB = c (RegEB);
  CurrentFB = c (RegFB);
  CurrentBB = c (RegBB);
  // Reform 16-bit accumulator and test for overflow in accumulator.
  Accumulator = c (RegA) & 0177777;
  Overflow = (ValueOverflowed (Accumulator) != AGC_P0);
  //Qumulator = GetQ (State);
  //OverflowQ = (ValueOverflowed (Qumulator) != AGC_P0);

  // After each instruction is executed, the AGC's Z register is updated to
  // indicate the next instruction to be executed.
  ProgramCounter = c (RegZ);
  // However, since the Z register contains only 12 bits, the address has to
  // be massaged to get a 16-bit address.
  WhereWord = FindMemoryWord (State, ProgramCounter);

  // Fetch the instruction itself.
  //Instruction = *WhereWord;
  if (State->SubstituteInstruction)
    {
      Instruction = c (RegBRUPT);
      if (0100000 & Instruction)
        sExtraCode = 1;
      Instruction &= 077777;
    }
  else
    {
      // The index is sometimes positive and sometimes negative.  What to
      // do if the result has overflow, I can't say.  I arbitrarily
      // overflow-correct it.
      sExtraCode = State->ExtraCode;
      Instruction =
	OverflowCorrected (AddSP16
			   (SignExtend (State->IndexValue),
			    SignExtend (*WhereWord)));
      Instruction &= 077777;
      // Handle interrupts.
      if (DebuggerInterruptMasks[0] &&
	  !State->InIsr && State->AllowInterrupt && !State->ExtraCode &&
	  State->IndexValue == 0 && !State->PendFlag && !Overflow &&
	  ValueOverflowed (c (RegL)) == AGC_P0 &&
	  ValueOverflowed (c (RegQ)) == AGC_P0 &&
	  //ProgramCounter > 060 &&
	  Instruction != 3 && Instruction != 4 && Instruction != 6)
	{
	  int i, j;
	  // We use the InterruptRequests array slightly oddly.  Since the
	  // interrupts are numbered 1 to 10 (NUM_INTERRUPT_TYPES), we begin
	  // indexing the array at 1, so that entry 0 does not hold an
	  // interrupt request.  Instead, we use entry 0 to tell the last
	  // interrupt type that occurred.  In searches, we begin one up from
	  // the last interrupt, and then wrap around.  This keeps the same
	  // interrupt from happening over and over to the exclusion of all
	  // other interrupts.  (I have no clue as to whether the AGC actually
	  // did this or not.)  Moreover, I assume interrupt vectoring takes
	  // one additional machine cycle.  Don't really know, however.
	  // Search for the next interrupt request.
	  i = State->InterruptRequests[0];	// Last interrupt serviced.
	  if (i == 0)
	    i = State->InterruptRequests[0] = NUM_INTERRUPT_TYPES;	// Initialization.
	  j = i;		// Ending point.
	  do
	    {
	      i++;		// Index at which to start searching.
	      if (i > NUM_INTERRUPT_TYPES)
		i = 1;
	      if (State->InterruptRequests[i] && DebuggerInterruptMasks[i])
		{
		  BacktraceAdd (State, i, 04000 + 4 * i);
		  // Clear the interrupt request.
		  State->InterruptRequests[i] = 0;
		  State->InterruptRequests[0] = i;
		  // Set up the return stuff.
		  c (RegZRUPT) = ProgramCounter;
		  c (RegBRUPT) = Instruction;
		  // Vector to the interrupt.
		  State->InIsr = 1;
		  NextZ = 04000 + 4 * i;
		  goto AllDone;
		}
	    }
	  while (i != j);
	}
    }

  //State->IndexValue = AGC_P0;         // Do AFTER the deley below.
  OpCode = Instruction & ~MASK12;
  QuarterCode = Instruction & ~MASK10;
  Address12 = Instruction & MASK12;
  Address10 = Instruction & MASK10;
  Address9 = Instruction & MASK9;

  // Add delay for multi-MCT instructions.  Works for all instructions
  // except EDRUPT, BZF, and BZMF.  For those, an extra cycle is added
  // AFTER executing the instruction -- not because it's more logically
  // correct, just because it's easier.
  if (!State->PendFlag)
    {
      int i;
      i = QuarterCode >> 10;
      if (State->ExtraCode)
	i = ExtracodeTiming[i];
      else
	i = InstructionTiming[i];
      if (i)
	{
	  State->PendFlag = 1;
	  State->PendDelay = i;
	  return (0);
	}
    }
  else
    State->PendFlag = 0;

  // Now that the index value has been used, get rid of it.
  State->IndexValue = AGC_P0;
  // And similarly for the substitute instruction from a RESUME.
  State->SubstituteInstruction = 0;

  // Compute the next value of the instruction pointer.  I haven't found
  // any explanation so far as to what happens if the pointer is already at
  // the end of a memory block, so I don't know if it's supposed to roll to
  // the next pseudo-address, or wrap to the beginning of the bank, or what.
  // My assumption is that the programmer (or assembler, perhaps) simply
  // wasn't supposed to allow this to happen.  (In fixed memory, this is
  // literally true, since the bank terminates with a bugger word rather than
  // with an instruction, so the issue is only what happens in erasable
  // memory.)  As a first cut, therefore, I simply increment the thing without
  // checking for a problem.  (The increment is by 2, since bit 0 is the
  // parity and the address only starts at bit 1.)
  NextZ = 1 + c (RegZ);
  // I THINK that the Z register is updated before the instruction executes,
  // which is important if you have an instruction that directly accesses
  // the value in Z.  (I deduce this from descriptions of the TC register,
  // which imply that the contents of Z is directly transferred into Q.)
  c (RegZ) = NextZ;

  // Parse the instruction.  Refer to p.34 of 1689.pdf for an easy
  // picture of what follows.
  ExtendedOpcode = Instruction >> 9;	//2;
  if (sExtraCode)
    ExtendedOpcode |= 0100;
  switch (ExtendedOpcode)
    {
    case 000:			// TC.
    case 001:
    case 002:
    case 003:
    case 004:
    case 005:
    case 006:
    case 007:
      // TC instruction (1 MCT).
      ValueK = Address12;	// Convert AGC numerical format to native CPU format.
      if (ValueK == 3)		// RELINT instruction.
	State->AllowInterrupt = 1;
      else if (ValueK == 4)	// INHINT instruction.
	State->AllowInterrupt = 0;
      else if (ValueK == 6)	// EXTEND instruction.
	{
	  State->ExtraCode = 1;
	  // Normally, ExtraCode will be reset when agc_engine is finished.
	  // We inhibit that behavior with this flag.
	  KeepExtraCode = 1;
	}
      else
	{
	  BacktraceAdd (State, 0, Address12);
	  if (ValueK != RegQ)	// If not a RETURN instruction ...
	    c (RegQ) = 0177777 & NextZ;
	  NextZ = Address12;
	}
      break;
    case 010:			// CCS.
    case 011:
      // CCS instruction (2 MCT).
      // Figure out where the data is stored, and fetch it.
      if (Address10 < REG16)
	{
	  Operand16 = OverflowCorrected (0177777 & c (Address10));
	  c (RegA) = odabs (0177777 & c (Address10));
	}
      else			// K!=accumulator.
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  Operand16 = *WhereWord & 077777;
	  // Compute the "diminished absolute value", and save in accumulator.
	  c (RegA) = dabs (Operand16);
	}
      AssignFromPointer (State, WhereWord, Operand16);
      // Now perform the actual comparison and jump on the basis
      // of it.  There's no explanation I can find as to what
      // happens if we're already at the end of the memory bank,
      // so I'll just pretend that that can't happen.  Note,
      // by the way, that if the Operand is > +0, then NextZ
      // is already correct, and in the other cases we need to
      // increment it by 2 less because NextZ has already been
      // incremented.
      if (Address10 < REG16
	  && ValueOverflowed (0177777 & c (Address10)) == AGC_P1)
	NextZ += 0;
      else if (Address10 < REG16
	       && ValueOverflowed (0177777 & c (Address10)) == AGC_M1)
	NextZ += 2;
      else if (Operand16 == AGC_P0)
	NextZ += 1;
      else if (Operand16 == AGC_M0)
	NextZ += 3;
      else if (0 != (Operand16 & 040000))
	NextZ += 2;
      break;
    case 012:			// TCF.
    case 013:
    case 014:
    case 015:
    case 016:
    case 017:
      BacktraceAdd (State, 0, Address12);
      // TCF instruction (1 MCT).
      NextZ = Address12;
      // THAT was easy ... too easy ...
      break;
    case 020:			// DAS.
    case 021:
      //DasInstruction:
      // DAS instruction (3 MCT).
      {
	// We add the less-significant words (as SP values), and thus
	// the sign of the lower word of the output does not necessarily
	// match the sign of the upper word.
	int Msw, Lsw;
	if (IsL (Address10))	// DDOUBL
	  {
	    Lsw = AddSP16 (0177777 & c (RegL), 0177777 & c (RegL));
	    Msw = AddSP16 (Accumulator, Accumulator);
	    if ((0140000 & Lsw) == 0040000)
	      Msw = AddSP16 (Msw, AGC_P1);
	    else if ((0140000 & Lsw) == 0100000)
	      Msw = AddSP16 (Msw, SignExtend (AGC_M1));
	    Lsw = OverflowCorrected (Lsw);
	    c (RegA) = 0177777 & Msw;
	    c (RegL) = 0177777 & SignExtend (Lsw);
	    break;
	  }
	WhereWord = FindMemoryWord (State, Address10);
	if (Address10 < REG16)
	  Lsw = AddSP16 (0177777 & c (RegL), 0177777 & c (Address10));
	else
	  Lsw = AddSP16 (0177777 & c (RegL), SignExtend (*WhereWord));
	if (Address10 < REG16 + 1)
	  Msw = AddSP16 (Accumulator, 0177777 & c (Address10 - 1));
	else
	  Msw = AddSP16 (Accumulator, SignExtend (WhereWord[-1]));

	if ((0140000 & Lsw) == 0040000)
	  Msw = AddSP16 (Msw, AGC_P1);
	else if ((0140000 & Lsw) == 0100000)
	  Msw = AddSP16 (Msw, SignExtend (AGC_M1));
	Lsw = OverflowCorrected (Lsw);

	if ((0140000 & Msw) == 0100000)
	  c (RegA) = SignExtend (AGC_M1);
	else if ((0140000 & Msw) == 0040000)
	  c (RegA) = AGC_P1;
	else
	  c (RegA) = AGC_P0;
	c (RegL) = AGC_P0;
	// Save the results.
	if (Address10 < REG16)
	  c (Address10) = SignExtend (Lsw);
	else
	  AssignFromPointer (State, WhereWord, Lsw);
	if (Address10 < REG16 + 1)
	  c (Address10 - 1) = Msw;
	else
	  AssignFromPointer (State, WhereWord - 1, OverflowCorrected (Msw));
      }
      break;
    case 022:			// LXCH.
    case 023:
      // "LXCH K" instruction (2 MCT).
      if (IsL (Address10))
	break;
      if (IsReg (Address10, RegZERO))	// ZL
	c (RegL) = AGC_P0;
      else if (Address10 < REG16)
	{
	  Operand16 = c (RegL);
	  c (RegL) = c (Address10);
	  if (Address10 >= 020 && Address10 <= 023)
	    AssignFromPointer (State, WhereWord,
			       OverflowCorrected (0177777 & Operand16));
	  else
	    c (Address10) = Operand16;
	  if (Address10 == RegZ)
	    NextZ = c (RegZ);
	}
      else
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  Operand16 = *WhereWord;
	  AssignFromPointer (State, WhereWord,
			     OverflowCorrected (0177777 & c (RegL)));
	  c (RegL) = SignExtend (Operand16);
	}
      break;
    case 024:			// INCR.
    case 025:
      // INCR instruction (2 MCT).
      {
	int Sum;
	WhereWord = FindMemoryWord (State, Address10);
	if (Address10 < REG16)
	  c (Address10) = AddSP16 (AGC_P1, 0177777 & c (Address10));
	else
	  {
	    Sum = AddSP16 (AGC_P1, SignExtend (*WhereWord));
	    AssignFromPointer (State, WhereWord, OverflowCorrected (Sum));
	    InterruptRequests (State, Address10, Sum);
	  }
      }
      break;
    case 026:			// ADS.  Reviewed against Blair-Smith.
    case 027:
      // ADS instruction (2 MCT).
      {
	WhereWord = FindMemoryWord (State, Address10);
	if (IsA (Address10))
	  Accumulator = AddSP16 (Accumulator, Accumulator);
	else if (Address10 < REG16)
	  Accumulator = AddSP16 (Accumulator, 0177777 & c (Address10));
	else
	  Accumulator = AddSP16 (Accumulator, SignExtend (*WhereWord));
	c (RegA) = Accumulator;
	if (IsA (Address10))
	  ;
	else if (Address10 < REG16)
	  c (Address10) = Accumulator;
	else
	  AssignFromPointer (State, WhereWord,
			     OverflowCorrected (Accumulator));
      }
      break;
    case 030:			// CA
    case 031:
    case 032:
    case 033:
    case 034:
    case 035:
    case 036:
    case 037:
      if (IsA (Address12))	// NOOP
	break;
      if (Address12 < REG16)
	{
	  c (RegA) = c (Address12);;
	  break;
	}
      WhereWord = FindMemoryWord (State, Address12);
      c (RegA) = SignExtend (*WhereWord);
      AssignFromPointer (State, WhereWord, *WhereWord);
      break;
    case 040:			// CS
    case 041:
    case 042:
    case 043:
    case 044:
    case 045:
    case 046:
    case 047:
      if (IsA (Address12))	// COM
	{
	  c (RegA) = ~Accumulator;;
	  break;
	}
      if (Address12 < REG16)
	{
	  c (RegA) = ~c (Address12);
	  break;
	}
      WhereWord = FindMemoryWord (State, Address12);
      c (RegA) = SignExtend (NegateSP (*WhereWord));
      AssignFromPointer (State, WhereWord, *WhereWord);
      break;
    case 050:			// INDEX
    case 051:
      if (Address10 == 017)
	goto Resume;
      if (Address10 < REG16)
	State->IndexValue = OverflowCorrected (c (Address10));
      else
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  State->IndexValue = *WhereWord;
	}
      break;
    case 0150:			// INDEX (continued)
    case 0151:
    case 0152:
    case 0153:
    case 0154:
    case 0155:
    case 0156:
    case 0157:
      if (Address12 == 017 << 1)
	{
	Resume:
	  if (State->InIsr)
	    BacktraceAdd (State, 255, c (RegZRUPT));
	  else
	    BacktraceAdd (State, 0, c (RegZRUPT));
	  NextZ = c (RegZRUPT);
	  State->InIsr = 0;
#ifdef ALLOW_BSUB
	  State->SubstituteInstruction = 1;
#endif
	}
      else
	{
	  if (Address12 < REG16)
	    State->IndexValue = OverflowCorrected (c (Address12));
	  else
	    {
	      WhereWord = FindMemoryWord (State, Address12);
	      State->IndexValue = *WhereWord;
	    }
	  KeepExtraCode = 1;
	}
      break;
    case 052:			// DXCH
    case 053:
      // Remember, in the following comparisons, that the address is pre-incremented.
      if (IsL (Address10))
	{
	  c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
	  break;
	}
      WhereWord = FindMemoryWord (State, Address10);
      // Topmost word.
      if (Address10 < REG16)
	{
	  Operand16 = c (Address10);
	  c (Address10) = c (RegL);
	  c (RegL) = Operand16;
	  if (Address10 == RegZ)
	    NextZ = c (RegZ);
	}
      else
	{
	  Operand16 = SignExtend (*WhereWord);
	  AssignFromPointer (State, WhereWord, OverflowCorrected (c (RegL)));
	  c (RegL) = Operand16;
	}
      c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
      // Bottom word.
      if (Address10 < REG16 + 1)
	{
	  Operand16 = c (Address10 - 1);
	  c (Address10 - 1) = c (RegA);
	  c (RegA) = Operand16;
	  if (Address10 == RegZ + 1)
	    NextZ = c (RegZ);
	}
      else
	{
	  Operand16 = SignExtend (WhereWord[-1]);
	  AssignFromPointer (State, WhereWord - 1,
			     OverflowCorrected (c (RegA)));
	  c (RegA) = Operand16;
	}
      break;
    case 054:			// TS
    case 055:
      if (IsA (Address10))	// OVSK
	{
	  if (Overflow)
	    NextZ += AGC_P1;
	}
      else if (IsZ (Address10))	// TCAA
	{
	  NextZ = (077777 & Accumulator);
	  if (Overflow)
	    c (RegA) = SignExtend (ValueOverflowed (Accumulator));
	}
      else			// Not OVSK or TCAA.
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  if (Address10 < REG16)
	    c (Address10) = Accumulator;
	  else
	    AssignFromPointer (State, WhereWord,
			       OverflowCorrected (Accumulator));
	  if (Overflow)
	    {
	      c (RegA) = SignExtend (ValueOverflowed (Accumulator));
	      NextZ += AGC_P1;
	    }
	}
      break;
    case 056:			// XCH
    case 057:
      if (IsA (Address10))
	break;
      if (Address10 < REG16)
	{
	  c (RegA) = c (Address10);
	  c (Address10) = Accumulator;
	  if (Address10 == RegZ)
	    NextZ = c (RegZ);
	  break;
	}
      WhereWord = FindMemoryWord (State, Address10);
      c (RegA) = SignExtend (*WhereWord);
      AssignFromPointer (State, WhereWord, OverflowCorrected (Accumulator));
      break;
    case 060:			// AD
    case 061:
    case 062:
    case 063:
    case 064:
    case 065:
    case 066:
    case 067:
      if (IsA (Address12))	// DOUBLE
	Accumulator = AddSP16 (Accumulator, Accumulator);
      else if (Address12 < REG16)
	Accumulator = AddSP16 (Accumulator, 0177777 & c (Address12));
      else
	{
	  WhereWord = FindMemoryWord (State, Address12);
	  Accumulator = AddSP16 (Accumulator, SignExtend (*WhereWord));
	  AssignFromPointer (State, WhereWord, *WhereWord);
	}
      c (RegA) = Accumulator;
      break;
    case 070:			// MASK
    case 071:
    case 072:
    case 073:
    case 074:
    case 075:
    case 076:
    case 077:
      if (Address12 < REG16)
	c (RegA) = Accumulator & c (Address12);
      else
	{
	  c (RegA) = OverflowCorrected (Accumulator);
	  WhereWord = FindMemoryWord (State, Address12);
	  c (RegA) = SignExtend (c (RegA) & *WhereWord);
	}
      break;
    case 0100:			// READ
      if (IsL (Address9) || IsQ (Address9))
	c (RegA) = c (Address9);
      else
	c (RegA) = SignExtend (ReadIO (State, Address9));
      break;
    case 0101:			// WRITE
      if (IsL (Address9) || IsQ (Address9))
	c (Address9) = Accumulator;
      else
	CpuWriteIO (State, Address9, OverflowCorrected (Accumulator));
      break;
    case 0102:			// RAND
      if (IsL (Address9) || IsQ (Address9))
	c (RegA) = (Accumulator & c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 &= ReadIO (State, Address9);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
    case 0103:			// WAND
      if (IsL (Address9) || IsQ (Address9))
	c (RegA) = c (Address9) = (Accumulator & c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 &= ReadIO (State, Address9);
	  CpuWriteIO (State, Address9, Operand16);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
    case 0104:			// ROR
      if (IsL (Address9) || IsQ (Address9))
	c (RegA) = (Accumulator | c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 |= ReadIO (State, Address9);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
    case 0105:			// WOR
      if (IsL (Address9) || IsQ (Address9))
	c (RegA) = c (Address9) = (Accumulator | c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 |= ReadIO (State, Address9);
	  CpuWriteIO (State, Address9, Operand16);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
    case 0106:			// RXOR
      if (IsL (Address9) || IsQ (Address9))
	c (RegA) = (Accumulator ^ c (Address9));
      else
	{
	  Operand16 = OverflowCorrected (Accumulator);
	  Operand16 ^= ReadIO (State, Address9);
	  c (RegA) = SignExtend (Operand16);
	}
      break;
    case 0107:			// EDRUPT
      //State->InIsr = 0;
      //State->SubstituteInstruction = 1;
      //if (State->InIsr)
      //  State->InterruptRequests[State->InterruptRequests[0]] = 0;
      c (RegZRUPT) = c (RegZ);
      State->InIsr = 1;
      BacktraceAdd (State, 0, 0);
#if 0
      if (State->InIsr)
        {
	  static int Count = 0;
	  printf ("EDRUPT w/ ISR %d\n", ++Count);
	}
      else
        {
	  static int Count = 0;
	  printf ("EDRUPT w/o ISR %d\n", ++Count);
	}
#endif // 0
      NextZ = 0;
      break;
    case 0110:			// DV
    case 0111:
      {
	int16_t AccPair[2], AbsA, AbsL, AbsK, Div16;
	int Dividend, Divisor, Quotient, Remainder;
	if (IsA (Address10))
	  {
	    Div16 = OverflowCorrected (Accumulator);
	    WhereWord = &Div16;
	  }
	else if (Address10 < REG16)
	  {
	    Div16 = OverflowCorrected (c (Address10));
	    WhereWord = &Div16;
	  }
	else
	  WhereWord = FindMemoryWord (State, Address10);
	// Fetch the values;
	AccPair[0] = OverflowCorrected (Accumulator);
	AccPair[1] = c (RegL);
	Dividend = SpToDecent (&AccPair[1]);
	DecentToSp (Dividend, &AccPair[1]);
	// Check boundary conditions.
	AbsA = AbsSP (AccPair[0]);
	AbsL = AbsSP (AccPair[1]);
	AbsK = AbsSP (*WhereWord);
	if (AbsA > AbsK || (AbsA == AbsK && AbsL != AGC_P0))
	  {
	    long random (void);
	    //printf ("Acc=%06o L=%06o\n", Accumulator, c(RegL));
	    //printf ("A,K,L=%06o,%06o,%06o abs=%06o,%06o,%06o\n",
	    //  AccPair[0],*WhereWord,AccPair[1],AbsA,AbsK,AbsL);
	    // The divisor is smaller than the dividend.  In this case,
	    // we return "total nonsense".
	    c (RegL) = (0777777 & random ());
	    c (RegA) = (0177777 & random ());
	  }
	else if (AbsA == AbsK && AbsL == AGC_P0)
	  {
	    // The divisor is equal to the dividend.
	    if (AccPair[0] == *WhereWord)	// Signs agree?
	      {
		Operand16 = 037777;	// Max positive value.
		c (RegL) = SignExtend (*WhereWord);
	      }
	    else
	      {
		Operand16 = (077777 & ~037777);	// Max negative value.
		c (RegL) = SignExtend (*WhereWord);
	      }
	    c (RegA) = SignExtend (Operand16);
	  }
	else
	  {
	    // The divisor is larger than the dividend.  Okay to actually divide!
	    // Fortunately, the sign conventions agree with those of the normal
	    // C operators / and %, so all we need to do is to convert the
	    // 1's-complement values to native CPU format to do the division,
	    // and then convert back afterward.  Incidentally, we know we
	    // aren't dividing by zero, since we know that the divisor is
	    // greater (in magnitude) than the dividend.
	    Dividend = agc2cpu2 (Dividend);
	    Divisor = agc2cpu (*WhereWord);
	    Quotient = Dividend / Divisor;
	    Remainder = Dividend % Divisor;
	    c (RegA) = SignExtend (cpu2agc (Quotient));
	    if (Remainder == 0)
	      {
		// In this case, we need to make an extra effort, because we
		// might need -0 rather than +0.
		if (Dividend >= 0)
		  c (RegL) = AGC_P0;
		else
		  c (RegL) = SignExtend (AGC_M0);
	      }
	    else
	      c (RegL) = SignExtend (cpu2agc (Remainder));
	  }
      }
      break;
    case 0112:			// BZF
    case 0113:
    case 0114:
    case 0115:
    case 0116:
    case 0117:
      //Operand16 = OverflowCorrected (Accumulator);
      //if (Operand16 == AGC_P0 || Operand16 == AGC_M0)
      if (Accumulator == 0 || Accumulator == 0177777)
	{
	  BacktraceAdd (State, 0,Address12);
	  NextZ = Address12;
	}
      break;
    case 0120:			// MSU
    case 0121:
      {
	unsigned ui, uj;
	int diff;
	WhereWord = FindMemoryWord (State, Address10);
	if (Address10 < REG16)
	  {
	    ui = 0177777 & Accumulator;
	    uj = 0177777 & c (Address10);
	  }
	else
	  {
	    ui = (077777 & OverflowCorrected (Accumulator));
	    uj = (077777 & *WhereWord);
	  }
	diff = ui - uj;
	if (diff < 0)
	  diff--;
	if (IsQ (Address10))
	  c (RegA) = 0177777 & diff;
	else
	  {
	    Operand16 = (077777 & diff);
	    c (RegA) = SignExtend (Operand16);
	  }
	if (Address10 >= 020 && Address10 <= 023)
	  AssignFromPointer (State, WhereWord, *WhereWord);
      }
      break;
    case 0122:			// QXCH
    case 0123:
      if (IsQ (Address10))
	break;
      if (IsReg (Address10, RegZERO))	// ZQ
	c (RegQ) = AGC_P0;
      else if (Address10 < REG16)
	{
	  Operand16 = c (RegQ);
	  c (RegQ) = c (Address10);
	  c (Address10) = Operand16;
	  if (Address10 == RegZ)
	    NextZ = c (RegZ);
	}
      else
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  Operand16 = OverflowCorrected (c (RegQ));
	  c (RegQ) = SignExtend (*WhereWord);
	  AssignFromPointer (State, WhereWord, Operand16);
	}
      break;
    case 0124:			// AUG
    case 0125:
      {
	int Sum;
	int Operand16, Increment;
	WhereWord = FindMemoryWord (State, Address10);
	if (Address10 < REG16)
	  Operand16 = c (Address10);
	else
	  Operand16 = SignExtend (*WhereWord);
	Operand16 &= 0177777;
	if (0 == (0100000 & Operand16))
	  Increment = AGC_P1;
	else
	  Increment = SignExtend (AGC_M1);
	Sum = AddSP16 (0177777 & Increment, 0177777 & Operand16);
	if (Address10 < REG16)
	  c (Address10) = Sum;
	else
	  {
	    AssignFromPointer (State, WhereWord, OverflowCorrected (Sum));
	    InterruptRequests (State, Address10, Sum);
	  }
      }
      break;
    case 0126:			// DIM
    case 0127:
      {
	int Sum;
	int Operand16, Increment;
	WhereWord = FindMemoryWord (State, Address10);
	if (Address10 < REG16)
	  Operand16 = c (Address10);
	else
	  Operand16 = SignExtend (*WhereWord);
	Operand16 &= 0177777;
	if (Operand16 == AGC_P0 || Operand16 == SignExtend (AGC_M0))
	  break;
	if (0 == (0100000 & Operand16))
	  Increment = SignExtend (AGC_M1);
	else
	  Increment = AGC_P1;
	Sum = AddSP16 (0177777 & Increment, 0177777 & Operand16);
	if (Address10 < REG16)
	  c (Address10) = Sum;
	else
	  AssignFromPointer (State, WhereWord, OverflowCorrected (Sum));
      }
      break;
    case 0130:			// DCA
    case 0131:
    case 0132:
    case 0133:
    case 0134:
    case 0135:
    case 0136:
    case 0137:
      if (IsL (Address12))
	{
	  c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
	  break;
	}
      WhereWord = FindMemoryWord (State, Address12);
      // Do topmost word first.
      if (Address12 < REG16)
	c (RegL) = c (Address12);
      else
	c (RegL) = SignExtend (*WhereWord);
      c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
      // Now do bottom word.
      if (Address12 < REG16 + 1)
	c (RegA) = c (Address12 - 1);
      else
	c (RegA) = SignExtend (WhereWord[-1]);
      if (Address12 >= 020 && Address12 <= 023)
	AssignFromPointer (State, WhereWord, WhereWord[0]);
      if (Address12 >= 020 + 1 && Address12 <= 023 + 1)
	AssignFromPointer (State, WhereWord - 1, WhereWord[-1]);
      break;
    case 0140:			// DCS
    case 0141:
    case 0142:
    case 0143:
    case 0144:
    case 0145:
    case 0146:
    case 0147:
      if (IsL (Address12))	// DCOM
	{
	  c (RegA) = ~Accumulator;
	  c (RegL) = ~c (RegL);
	  c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
	  break;
	}
      WhereWord = FindMemoryWord (State, Address12);
      // Do topmost word first.
      if (Address12 < REG16)
	c (RegL) = ~c (Address12);
      else
	c (RegL) = ~SignExtend (*WhereWord);
      c (RegL) = SignExtend (OverflowCorrected (c (RegL)));
      // Now do bottom word.
      if (Address12 < REG16 + 1)
	c (RegA) = ~c (Address12 - 1);
      else
	c (RegA) = ~SignExtend (WhereWord[-1]);
      if (Address12 >= 020 && Address12 <= 023)
	AssignFromPointer (State, WhereWord, WhereWord[0]);
      if (Address12 >= 020 + 1 && Address12 <= 023 + 1)
	AssignFromPointer (State, WhereWord - 1, WhereWord[-1]);
      break;
      // For 0150..0157 see the INDEX instruction above.
    case 0160:			// SU
    case 0161:
      if (IsA (Address10))
	Accumulator = SignExtend (AGC_M0);
      else if (Address10 < REG16)
	Accumulator = AddSP16 (Accumulator, 0177777 & ~c (Address10));
      else
	{
	  WhereWord = FindMemoryWord (State, Address10);
	  Accumulator =
	    AddSP16 (Accumulator, SignExtend (NegateSP (*WhereWord)));
	  AssignFromPointer (State, WhereWord, *WhereWord);
	}
      c (RegA) = Accumulator;
      break;
    case 0162:			// BZMF
    case 0163:
    case 0164:
    case 0165:
    case 0166:
    case 0167:
      //Operand16 = OverflowCorrected (Accumulator);
      //if (Operand16 == AGC_P0 || IsNegativeSP (Operand16))
      if (Accumulator == 0 || 0 != (Accumulator & 0100000))
	{
	  BacktraceAdd (State, 0, Address12);
	  NextZ = Address12;
	}
      break;
    case 0170:			// MP
    case 0171:
    case 0172:
    case 0173:
    case 0174:
    case 0175:
    case 0176:
    case 0177:
      {
	// For MP A (i.e., SQUARE) the accumulator is NOT supposed to
	// be oveflow-corrected.  I do it anyway, since I don't know
	// what it would mean to carry out the operation otherwise.
	// Fix later if it causes a problem.
	// FIX ME: Accumulator is overflow-corrected before SQUARE.
	int16_t MsWord, LsWord, OtherOperand16;
	int Product;
	WhereWord = FindMemoryWord (State, Address12);
	Operand16 = OverflowCorrected (Accumulator);
	if (Address12 < REG16)
	  OtherOperand16 = OverflowCorrected (c (Address12));
	else
	  OtherOperand16 = *WhereWord;
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
	c (RegA) = SignExtend (MsWord);
	c (RegL) = SignExtend (LsWord);
      }
      break;
    default:
      // Isn't possible to get here, but still ...
      //printf ("Unrecognized instruction %06o.\n", Instruction);
      break;
    }

AllDone:
  // All done!
  if (!State->PendFlag)
    {
      c (RegZERO) = AGC_P0;
      State->InputChannel[7] = State->OutputChannel7 &= 0160;
      c (RegZ) = NextZ;
      if (!KeepExtraCode)
	State->ExtraCode = 0;
      // Values written to EB and FB are automatically mirrored to BB,
      // and vice versa.
      if (CurrentBB != c (RegBB))
	{
	  c (RegFB) = (c (RegBB) & 076000);
	  c (RegEB) = (c (RegBB) & 07) << 8;
	}
      else if (CurrentEB != c (RegEB) || CurrentFB != c (RegFB))
	c (RegBB) = (c (RegFB) & 076000) | ((c (RegEB) & 03400) >> 8);
      c (RegEB) &= 03400;
      c (RegFB) &= 076000;
      c (RegBB) &= 076007;
    }
  return (0);
}

