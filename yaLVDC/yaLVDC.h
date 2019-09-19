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
 * Filename:    yaLVDC.h
 * Purpose:     Common header for yaLVDC.c and friends.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-18 RSB  Began.
 */

#ifndef yaLVDC_h
#define yaLVDC_h

#include <stdint.h>

///////////////////////////////////////////////////////////////////////
// Function prototypes and any global variables that go with them.

// See parseCommandLineArguments.c
#define MAX_PROGRAMS 5
char *assemblyBasenames[MAX_PROGRAMS];
char *coreRopeFilename;
int
parseCommandLineArguments(int argc, char *argv[]);

// See readAssemblies.c
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
int rope[8][16][3][256];
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


#endif // yaLVDC_h
