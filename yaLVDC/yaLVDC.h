/*
 * Copyright 2019-20 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    yaLVDC.h
 * Purpose:     Common header for yaLVDC.c and friends.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-18 RSB  Began.
 *              2020-04-29 RSB  Added the --ptc switch.
 */

#ifndef yaLVDC_h
#define yaLVDC_h

#include <stdint.h>
#include <limits.h>

///////////////////////////////////////////////////////////////////////
// Function prototypes and any global variables that go with them.

// Length of an LVDC CPU's "computer cycle".
#define SECONDS_PER_CYCLE (168.0/2048000) // About 82us.

// See debug.c
// (Note that debug.c relates to debugging yaLVDC and not to the
// features yaLVDC itself contains for debugging LVDC code.)
// The idea here is that there's a set of flags which determine which
// features of debug.c are active, and which are not.  If DEBUG_FLAGS
// is set to DEBUG_NONE, then all debugging code is inactive.  If it
// is set to a bitwise-OR of the various flags, then just that
// combination of features is active.  Using DEBUG_NONE will be the
// normal case after yaLVDC is fully developed.
#define DEBUG_NONE		0
#define DEBUG_SYMBOLS 		1
#define DEBUG_SOURCE_LINES 	2
#define DEBUG_CORE		4

#define DEBUG_FLAGS DEBUG_NONE
#if DEBUG_FLAGS != DEBUG_NONE
#define DEBUG
#endif

#ifdef DEBUG
void
dPrintouts (void);
#else
#define dPrintouts()
#endif

// See yaLVDC.c
#define MAX_SYMBOL_LENGTH 10
typedef struct
{
  int temporary; // 0=permanent, 1=temporary.
  int module;
  int sector;
  int syllable;
  int location;
  char name[MAX_SYMBOL_LENGTH];
  int number;
  int whichType;        // 0=name, 1=number, 2=address.
} breakpoint_t;
#define MAX_BREAKPOINTS 50
breakpoint_t breakpoints[MAX_BREAKPOINTS];
int numBreakpoints;

// See parseCommandLineArguments.c
char *coreFilename;
int ptc;
int coldStart;
int runStepN; // # of emulation steps left to run until pausing. INT_MAX is unlimited.
int inNextNotStep, inNextHop, inNextHopIM, inNextHopIS, inNextHopS, inNextHopLOC;

int
parseCommandLineArguments(int argc, char *argv[]);

// See readAssemblies.c
// Note that state_t contains just persistent values ... i.e., stuff in the CPU
// that I expect to be stored in ferrite cores, and thus to survive a power
// cycle, because the emulator will periodically write it out to a persistence
// file that will be reread at startup.  So if there's non-persistent state
// stuff, it needs to be handled using some other mechanism than state_t.
typedef struct
{
  int restart;
  int32_t hop;
  int32_t acc;
  int32_t pq;
  int32_t returnAddress; // -2 except immediately after a HOP instruction.
  int32_t core[8][16][3][256];
  int32_t pio[512];
  int32_t cio[01000]; // PTC only.
  int32_t prs; // PTC only.
  struct
  {
    int pending; // True or False, if last instruction was EXM or not.
    int32_t nextHop; // HOP constant for next instruction (as if no pending EXM-modified instruction).
    int32_t pendingHop; // HOP constant for the pending EXM-modified instruction.
    int16_t pendingInstruction; // the EXM-modified instruction.
  } pendingEXM; // LVDC only.
  // The following three are reset at the start of a runOneInstruction()
  // invocation, but changed if the associated pio[], cio[], or prs
  // change during the runOneInstruction().  That's because
  // runOneInstruction() itself does not do anything other than to change
  // those values, without performed any of the explicit actions they're
  // associated with in peripheral space, so it has to convey that some
  // action is necessary by external code.
  int pioChange;
  int cioChange;
  int prsChange;
} state_t;
state_t state;
typedef struct
{
  char name[MAX_SYMBOL_LENGTH];
  uint8_t module;
  uint8_t sector;
  uint8_t syllable; // 0,1 instructions, 2 data.
  uint8_t loc;
} symbol_t;
typedef struct
{
  char *line;
  uint8_t module;
  uint8_t sector;
  uint8_t syllable; // 0,1 instructions, 2 data.
  uint8_t loc;
  int lineNumber;
} sourceLine_t;
#define MAX_ASSEMBLIES 16
typedef struct
{
  char *name;
  symbol_t *symbols;
  int numSymbols;
  sourceLine_t *sourceLines;
  int numSourceLines;
  int codeWords;
  int dataWords;
} assembly_t;
assembly_t assemblies[MAX_ASSEMBLIES];
int numAssemblies;
int freezeAssemblies;
int
readAssemblies(void);
int
cmpSourceByAddress(const void *r1, const void *r2);
int
cmpSymbolsByAddress(const void *r1, const void *r2);

// See pushErrorMessage.c
#define MAX_ERROR_MESSAGES 32
char *errorMessageStack[MAX_ERROR_MESSAGES];
int numErrorMessages;
int
pushErrorMessage(char *part1, char *part2);

// See readWriteCore.c
int
readCore(void);
int
writeCore(void);

// See runOneInstruction.c
typedef struct
{
  uint8_t im;
  uint8_t is;
  uint8_t s;
  uint8_t loc;
  uint8_t dm;
  uint8_t ds;
  uint8_t dupin;
  uint8_t dupdn;
} hopStructure_t;
int instructionFromDataMemory;
int dataFromInstructionMemory;
int dataOverwritesInstructionMemory;
int
runOneInstruction(int *cyclesUsed);
int
parseHopConstant(int hopConstant, hopStructure_t *hopStructure);
int
formHopConstant(hopStructure_t *hopStructure, int *hopConstant);
int
fetchData(int module, int residual, int sector, int loc, int32_t *data,
    int *dataFromInstructionMemory);
int
storeData(int module, int residual, int sector, int loc, int32_t data,
    int *dataOverwritesInstructionMemory);

// See gdbInterface.c
int
gdbInterface(unsigned long instructionCount, unsigned long cycleCount,
    breakpoint_t *breakpoint);

// See processPIO.c
int
processPIO(void);

// See processCIO.c
int
processCIO(void);

// See processPRS.c
int
processPRS(void);

// See processInterrupts.c
int
processInterrupts(void);

#endif // yaLVDC_h
