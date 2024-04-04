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

// Command-line variables.
extern int outUTF8;
#define DD_MAX 9
extern FILE *DD_INS[DD_MAX];
extern FILE *DD_OUTS[DD_MAX];
extern FILE *COMMON_OUT;

// Returns -1 on failure, 0 on success, 1 to request an immediate termination.
int
parseCommandLine(int argc, char **argv);

#define MAX_XPL_STRING 255
typedef char string_t[MAX_XPL_STRING + 1];

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

// Same for XPL `CHARACTER` type.  In XPL, `CHARACTER` is represented by
// a 32-bit "descriptor", in which 8 bits are the string length
// and 24 bits are the address of the sequence of character data in memory.
// In C, we'll use `char` buffers of length 256 to hold the string data,
// nul-terminated, and hope that none of the XPL strings (which are *not*
// nul-terminated) include any NUL characters.  The XPL character data is
// encoded in EBCDIC, and the utility functions below translate automatically
// between EBCDIC and the native C format.  Note that in this
// implementation, `CHARACTER` strings (both descriptors *and* data) are in
// fixed locations in simulated memory, and only the lengths and data can
// change during execution.  Note that `getCHARACTER` has a circular buffer
// of string_t buffers that it uses to return values on successive calls.
// This buffer is chosen to be large enough that it's unlikely any of them
// will be rewritten before their results are used.
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


#endif // RUNTIMEC_H
