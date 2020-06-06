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
extern int clockDivisor;
extern int inhibitFetchMessages;
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
extern breakpoint_t breakpoints[MAX_BREAKPOINTS];
extern int numBreakpoints;
typedef struct
{
  int32_t fromWhere;
  int32_t toWhere;
  unsigned long cycleCount;
  unsigned long instructionCount;
  int16_t fromInstruction;
} backtrace_t;
// A circular buffer for backtraces.  If firstEmptyBacktrace == firstUsedBacktrace,
// then the buffer is empty, so it can hold up to MAX_BACKTRACES-1 entries.
// When adding a new one, if the buffer is already full then the oldest one
// is silently deleted.  Yes, it would be preferable instead of a circular buffer
// to unroll as subroutines were returned from, but that's beyond my ability to
// analyze, given the nature of the code.
#define MAX_BACKTRACES 101
extern backtrace_t backtraces[MAX_BACKTRACES];
extern int firstUsedBacktrace, firstEmptyBacktrace;
extern int runStepN; // # of emulation steps left to run until pausing. INT_MAX is unlimited.
extern int runNextN;
extern int inNextNotStep, inNextHop, inNextHopIM, inNextHopIS, inNextHopS,
    inNextHopLOC;
#define NEXT_BACKTRACE(n) (((n) + 1) % MAX_BACKTRACES)
void
addBacktrace(int16_t fromInstruction, int32_t fromWhere, int32_t toWhere,
    unsigned long cycleCount, unsigned long instructionCount);
// CPU/Panel status/commands.
extern int panelPause;
extern int panelPatternDataAddress;
extern int panelPatternDM, panelPatternDS, panelPatternDLOC;
extern int panelPatternInstructionAddress;
extern int panelPatternDataValue;
extern int panelDisplayModePlus;
extern int panelDisplaySelect;
extern int panelAddressCompare;
extern int panelModeControl;
extern int cpuIsRunning;
extern int cpuCurrentAddressData;
extern int cpuCurrentAddressInstruction;
extern int cpuCurrentValueData;
extern int cpuCurrentAccumulator;

// See parseCommandLineArguments.c
extern char *coreFilename;
extern int ptc;
extern int coldStart;

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
  int32_t hopSaver; // otherwise known as the "HOP saver" register.
  int32_t core[8][16][3][256];
  int32_t pio[01000];
  int32_t cio[01000]; // PTC only.
  int32_t prs[01000]; // PTC only.
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
  // The following is normally -1, but is set by runOneInstruction()
  // to the address of a HOP, TRA, TMI, or TNZ if it causes a jump
  // to an instruction that's out of sequence.
  int32_t lastHop;
  int16_t lastInstruction;
  // Counters used for faking up busy signals for printer, plotter, typewriter.
  int busyCountPlotter;
  int busyCountPrinter;
  int busyCountTypewriter;
  int interruptInhibitLatches;
  int masterInterruptLatch;
  int gateProgRegA;
} state_t;
extern state_t state;
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
  uint16_t assembled;
  uint8_t dm;
  uint8_t ds;
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
extern assembly_t assemblies[MAX_ASSEMBLIES];
extern int numAssemblies;
extern int freezeAssemblies;
int
readAssemblies(void);
int
cmpSourceByAddress(const void *r1, const void *r2);
int
cmpSymbolsByAddress(const void *r1, const void *r2);

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
extern int instructionFromDataMemory;
extern int dataFromInstructionMemory;
extern int dataOverwritesInstructionMemory;
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
int
fetchInstruction(int module, int sector, int syllable, int loc,
    uint16_t *instruction, int *instructionFromDataMemory);

// See gdbInterface.c
int
gdbInterface(unsigned long instructionCount, unsigned long cycleCount,
    breakpoint_t *breakpoint);

// See processInterruptsAndIO.c
int
processInterruptsAndIO(void);

// See virtualWire.c
// Socket stuff.
#define MAX_LISTENERS 7
extern int ServerBaseSocket;
extern int PortNum;
extern int virtualWireErrorCodes;
// Functions.
int
InitializeSocketSystem(void);
void
UnblockSocket(int SocketNum);
int
EstablishSocket(unsigned short portnum, int MaxClients);
int
CallSocket(char *hostname, unsigned short portnum);
void
connectCheck(void);
int
pendingVirtualWireActivity(void);

#endif // yaLVDC_h
