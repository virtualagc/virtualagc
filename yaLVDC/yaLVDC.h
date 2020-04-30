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

///////////////////////////////////////////////////////////////////////
// Function prototypes and any global variables that go with them.

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
#define DEBUG_SYMBOLS_BY_NAME 	2
#define DEBUG_SOURCE_LINES 	4
#define DEBUG_CORE		8

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

// See parseCommandLineArguments.c
#define MAX_PROGRAMS 5
char *assemblyBasenames[MAX_PROGRAMS];
char *coreFilename;
int ptc;
int coldStart;
int runNextN; // # of LVDC/PTC instructions left to run until pausing. -1 is unlimited.
int
parseCommandLineArguments(int argc, char *argv[]);

// See readAssemblies.c
// Note that state_t contains just persistent values ... i.e., stuff in the CPU
// that I expect to be stored in ferrite cores, and thus to survive a power
// cycle, because the emulator will periodically write it out to a persistence
// file that will be reread at startup.  So if there's non-persistent state
// stuff, it needs to be handled using some other mechanism than state_t.
typedef struct {
  int32_t hop;
  int32_t acc;
  int32_t pq;
  int32_t returnAddress; // -2 except immediately after a HOP instruction.
  int32_t core[8][16][3][256];
  int32_t pio[512];
  int32_t cio[01000]; // PTC only.
} state_t;
state_t state;
typedef struct {
  char name[10];
  uint8_t module;
  uint8_t sector;
  uint8_t syllable; // 0,1 instructions, 2 data.
  uint8_t loc;
} symbol_t;
symbol_t *symbols;
symbol_t *symbolsByName;
int numSymbols;
int numSymbolsByName;
typedef struct {
  char *line;
  uint8_t module;
  uint8_t sector;
  uint8_t syllable; // 0,1 instructions, 2 data.
  uint8_t loc;
} sourceLine_t;
sourceLine_t *sourceLines;
int numSourceLines;
int
readAssemblies(char *assemblyNames[], int maxAssemblies);
int
cmpSourceByAddress (const void *r1, const void *r2);
int
cmpSymbolsByAddress (const void *r1, const void *r2);
int
cmpSymbolsByName (const void *r1, const void *r2);

// See pushErrorMessage.c
#define MAX_ERROR_MESSAGES 32
char *errorMessageStack[MAX_ERROR_MESSAGES];
int numErrorMessages;
int
pushErrorMessage (char *part1, char *part2);

// See readWriteCore.c
int
readCore (void);
int
writeCore (void);

// See runOneInstruction.c
typedef struct {
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
runOneInstruction (int *cyclesUsed);
int
parseHopConstant (int hopConstant, hopStructure_t *hopStructure);
int
formHopConstant (hopStructure_t *hopStructure, int *hopConstant);
int
fetchData (int module, int residual, int sector, int loc, int16_t *data,
	   int *dataFromInstructionMemory);
int
storeData (int module, int residual, int sector, int loc, int16_t data,
	   int *dataOverwritesInstructionMemory);

// See gdbInterface.c
int
gdbInterface (void);

#endif // yaLVDC_h
