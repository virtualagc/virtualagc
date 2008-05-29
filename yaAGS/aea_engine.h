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

  Filename:	aea_engine.h
  Purpose:	Header file for AGS/AEA emulator engine.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/yaAGS.html
  Mods:		2005-02-13 RSB	Began adapting from corresponding AGC file.
  		2005-05-31 RSB	Added DebugDeda.
		2005-06-02 RSB	Basically now rewriting this from scratch.
				I'm just not comfortable adapting from 
				AGC.
		2005-06-04 RSB	... continued.
		2005-08-13 RSB	Added the extern "C" stuff, as well as
				the ags_clientdata field in ags_t.
		2005-08-22 RSB	"unsigned long long" replaced by uint64_t.
*/

#ifndef AEA_ENGINE_H
#define AEA_ENGINE_H

#include "../yaAGC/agc_engine.h"
#include <time.h>

#ifdef __cplusplus
extern "C" {
#endif

// The following is used to get the int32_t datatype.
#ifdef WIN32
typedef int int32_t;
#endif

//----------------------------------------------------------------------------
// Constants.

// All instruction timings of AEA CPU instructions are small integral multiples of
// 1/1.024 microseconds.  We therefore base our timing on this time quantum.
// Note that the following constant is unsigned long long.
#define AEA_PER_SECOND (1024000ULL)

#define MEM_SIZE 010000
// The i/o registers are at addresses 02000+2^n and 06000+2^n, though not all 
// of them are used.  Specifically, we recognize the following 16 i/o register
// addresses.
//	02001, 02002, 02004, 02010, 02020, 02040, 02100, 02200,
//	06001, 06002, 06004, 06010, 06020, 06040, 06100, 06200
// The usage (in an ags_t structure as below) is OutputPorts[IO_0xxxx] or
// InputPorts[IO_0xxxx].
enum RegOffset_t { 
  IO_2001 = 0, IO_2002, IO_2004, IO_2010, IO_2020, IO_2040,
  IO_2100, IO_2200, IO_6001, IO_6002, IO_6004, IO_6010,
  IO_6020, IO_6040, IO_6100, IO_6200, IO_ODISCRETES, NUM_IO
};

#define MAX_AGS_BACKTRACES 50

// Time between checks for --debug keystrokes.
#define KEYSTROKE_CHECK_AGS (sysconf (_SC_CLK_TCK) / 4)

//---------------------------------------------------------------------------
// Data types.

// Each instance of the AGS/AEA CPU simulation has a data structure of type ags_t
// that contains the CPU's internal states, the complete memory space, and any
// other little handy items needed to track execution by the CPU.

typedef struct
{
  // CPU internal registers.
  int ProgramCounter;
  int Accumulator;
  int Quotient;
  int Index;
  int Overflow;
  int Halt;
  // The following variable counts the total number of clock cycles since
  // CPU-startup.  A 64-bit integer is used.
  uint64_t /* unsigned long long */ CycleCounter;
  uint64_t /* unsigned long long */ Next20msSignal;
  // All memory -- registers, RAM, and ROM -- is 18-bit.
  int32_t Memory[MEM_SIZE];
  // There are also "input/output channels".  Output channels are acted upon
  // immediately, but input channels are buffered from asynchronous data.
  int32_t OutputPorts[NUM_IO];
  int32_t InputPorts[NUM_IO];
  // The following pointer is present for whatever use the Orbiter
  // integration squad wants.  The Virtual AGC code proper doesn't use it
  // in any way.
  void *ags_clientdata;
} ags_t;

#ifdef AEA_ENGINE_C
//static Client_t DefaultClients[DEFAULT_MAX_CLIENTS];
//static int DefaultSockets[DEFAULT_MAX_CLIENTS];
int DebugModeAGS = 0;
ags_t BacktracesAGS[MAX_AGS_BACKTRACES];
int NumBacktracesAGS = 0, LatestBacktraceAGS = -1;
clock_t RealTimeAGS, RealTimeOffsetAGS, LastRealTimeAGS, NextKeycheckAGS;
#else //AEA_ENGINE_C
extern int DebugModeAGS;
extern ags_t BacktracesAGS[MAX_AGS_BACKTRACES];
extern int NumBacktracesAGS, LatestBacktraceAGS;
extern clock_t RealTimeAGS, RealTimeOffsetAGS, LastRealTimeAGS, NextKeycheckAGS;
#endif //AEA_ENGINE_C

//---------------------------------------------------------------------------
// Function prototypes.

int aea_engine (ags_t * State);
int aea_engine_init (ags_t * State, const char *RomImage, const char *CoreDump);
void MakeCoreDumpAGS (ags_t * State, const char *CoreDump);
void ChannelOutputAGS (int Type, int Data);
int ChannelInputAGS (ags_t * State);
void DebuggerHookAGS (ags_t *State);
void UpdateAeaPeripheralConnect (void *AeaState, Client_t *Client);
int SignExtendAGS (int i);
void ListBacktracesAGS (void);
void RegressToBacktraceAGS (ags_t *State, int BacktraceNumber);
char *ShowAddressContentsAGS (ags_t *State);

#ifdef __cplusplus
}
#endif

#endif // AEA_ENGINE_H
