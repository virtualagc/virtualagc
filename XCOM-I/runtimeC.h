/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    runtimeC.h
 * Purpose:     Header for runtimeC.c.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-03-28 RSB  Began.
 */

#ifndef RUNTIMEC_H
#define RUNTIMEC_H

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "configuration.h"

// Command-line variables.
extern int outUTF8;
#define DD_MAX 9
extern FILE *DD_INS[DD_MAX];
extern FILE *DD_OUTS[DD_MAX];
extern FILE *COMMON_OUT;

// Returns -1 on failure, 0 on success, 1 to request an immediate termination.
int
parseCommandLine(int argc, char **argv);

#define MAX_XPL_STRING 256
typedef char string_t[MAX_XPL_STRING];

// XPL variables are *not* translated as C variables.  Rather, they are
// translated as sequences of bytes in the following buffer.
#define MEMORY_SIZE (1 << 24)
extern uint8_t memory[MEMORY_SIZE];

// Read XPL `FIXED` data from memory as a C `int`.  No checking for address
// overflow is performed and no errors are therefore possible.
int32_t
getFIXED(uint32_t address);

// Write a C `int` to memory as XPL `FIXED`.  No checking for address
// overflow is performed and no errors are therefore possible.
void
putFIXED(uint32_t address, int32_t value);

/*
// Same for XPL `BIT` type.  Note that only `BIT(1)` through `BIT(32)` is
// supported, and if longer `BIT(n)` is needed, then some modification is
// needed.
uint32_t
getBIT(uint32_t address);
void
putBIT(uint32_t address, uint32_t value);
*/

// Same for XPL `CHARACTER` type.
char *
getCHARACTER(uint32_t address);
void
putCHARACTER(uint32_t address, char *s);

// Convert a FIXED to a CHARACTER.
char *
fixedToCharacter(int32_t i);

// Functions to perform various kinds of arithmetic.
int32_t
xadd(int32_t i1, int32_t i2);
int32_t
xsubtract(int32_t i1, int32_t i2);
int32_t
xminus(int32_t i);
int32_t
xmultiply(int32_t i1, int32_t i2);
int32_t
xdivide(int32_t i1, int32_t i2);
int32_t
xmod(int32_t i1, int32_t i2);
int32_t
xEQ(int32_t i1, int32_t i2);
int32_t
xLT(int32_t i1, int32_t i2);
int32_t
xGT(int32_t i1, int32_t i2);
int32_t
xNEQ(int32_t i1, int32_t i2);
int32_t
xLE(int32_t i1, int32_t i2);
int32_t
xGE(int32_t i1, int32_t i2);
int32_t
xNOT(int32_t i1);
int32_t
xOR(int32_t i1, int32_t i2);
int32_t
xAND(int32_t i1, int32_t i2);

int32_t
xsEQ(char *s1, char *s2);
int32_t
xsLT(char *s1, char *s2);
int32_t
xsGT(char *s1, char *s2);
int32_t
xsNEQ(char *s1, char *s2);
int32_t
xsLE(char *s1, char *s2);
int32_t
xsGE(char *s1, char *s2);

char *
xsCAT(char *s1, char *s2);

// Built-in functions.  I've adapted the code for most or all of these from my
// previous manual port of HAL/S-FC PASS1 from XPL/I to Python.  Some of them,
// such as `OUTPUT`, are considerably extended from the XPL built-in of the
// same name as documented in McKeeman.

extern string_t headingLine;
extern string_t subHeadingLine;
extern int pageCount;
extern int LINE_COUNT;
extern int linesPerPage;
void
OUTPUT(uint32_t lun, char *msg);

char *
INPUT(uint32_t lun);

uint32_t
LENGTH(char *string);

char *
SUBSTR(char *s, uint32_t start, uint32_t end);

char *
bSUBSTR2(char *s, uint32_t start);

uint8_t
BYTE(char *s, uint32_t index);

uint8_t
bBYTE1(char *s);

uint32_t
SHL(uint32_t value, uint32_t shift);

uint32_t
SHR(uint32_t value, uint32_t shift);

//      TIME=NumberOfCentisecondsSinceMidnight
// Otherwise, same comments as for `DATE` above.
uint32_t
TIME(void);

// XPL's DATE built-in "variable" is modeled as a function.
//      DATE = (1000*(year-1900))+DayOfTheYear
// The time-zone isn't specified, so I use UTC.
uint32_t
DATE(void);

uint32_t
DATE_OF_GENERATION(void);

// Allocate `n` bytes in the free-memory area (i.e., between FREEPOINT and
// FREELIMIT in `memory`), compacting if necessary, and storing the address
// of the allocated memory at the memory address indicated by `address`, which
// *should* only be the address of a BASED variable as obtained by ADDR(var).
// The address and amount are preserved (with the help of `memoryMap`), and
// thus the allocation can itself be moved later by `COMPACTIFY` if necessary.
// Returns 0 on success, 1 otherwise.
uint32_t
MONITOR6(uint32_t address, uint32_t n);

// Frees memory allocated by `MONITOR6`, and the same comments mostly apply.
// The value stored at `address`, however, is not changed by `MONITOR7`, and
// in most cases should probably should be modified by the user afterward to
// avoid confusion, conventionally to the value `UNALLOCATED`.  However,
// `MONITOR7` does automatically fix `memoryMap` to say that 0 bytes have been
// allocated, so even if the `address` isn't changed, it doesn't affect the
// validity of a later `COMPACTIFY`.
//
// I'm not actually sure what it means to free `n` bytes if `n` wasn't the
// amount originally allocated.  I'm assuming that it means to just remove `n`
// bytes from the end of the allocation.
uint32_t
MONITOR7(uint32_t address, uint32_t n);

uint32_t
MONITOR18(void);

// I find no calls to MONITOR function 19 or 20 in HAL/S-FC, and don't intend
// to bother implementing them.  If they were to be implemented, I'd do it
// as a loop of calls to MONITOR 6 or MONITOR 7.

// There's a CALL to MONITOR(21) only in SPACELIB.  Since I'm not supporting
// SPACELIB, I see no real reason to implement function 21 ... but it's so
// darned easy, let's do it anyway.
uint32_t
MONITOR21(void);

uint32_t
COREBYTE(uint32_t address);

void
COREBYTE2(uint32_t address, uint32_t value);

uint32_t
COREWORD(uint32_t address);

void
COREWORD2(uint32_t address, uint32_t value);

// Gets the address of any variable, subscripted or non-subscripted,
// BASED or non-BASED, RECORD or non-RECORD, as follows:
//
//  bVar  bIndex    fVar   fIndex        Declaration
//  ----  ------    ----   ------        -----------
//  NULL  0         var    0             DECLARE var type;
//  NULL  0         var    index         DECLARE var(size) type;
//  bVar  bIndex    NULL   0             BASED bVar type;
//  bVar  bIndex    field  0             BASED bVar RECORD field type;
//  bVar  bIndex    field  fIndex        BASED bVar RECORD field(size) type;
//
// In the parameters for `ADDR`, I make no distinction between
// DECLARE / COMMON / ARRAY / COMMON ARRAY, nor any distinction between
// BASED / COMMON BASED.  (There may or may not be an internal distinction
// between DECLARE and ARRAY; it depends on the final implementation of
// ARRAY, which at this writing is identical to DECLARE.)
uint32_t
ADDR(char *bVar, int32_t bIndex, char *fVar, int32_t fIndex);

void
COMPACTIFY(void);

// A function possibly useful for debugging memory management.
void
printMemoryMap(char *msg);

// Functions for reading COMMON from a file, or writing COMMON to a file.

// Returns 0 on success or 1 on failure.
int
writeCOMMON(FILE *fp);

// Returns:
//     -1       Failure.
//      0       Full success.
//      1       Partial success: File was shorter than expected.
//      2       Partial success: File was longer than expected.
int
readCOMMON(FILE *fp);

#endif // RUNTIMEC_H
