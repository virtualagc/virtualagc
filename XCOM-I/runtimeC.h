/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    runtimeC.h
 * Purpose:     Header for runtimeC.c.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-03-28 RSB  Began.
 *              2024-05-23 RSB  Reworked so that descriptor_t replaces string_t,
 *                              bit_t, and lots of char*.
 */

#ifndef RUNTIMEC_H
#define RUNTIMEC_H

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <math.h>
#include "inline360.h"

#define MAX_XPL_STRING 256
#if 0
typedef char string_t[MAX_XPL_STRING];
typedef struct {
  uint16_t bitWidth;
  uint16_t numBytes;
  uint8_t bytes[MAX_XPL_STRING];
} bit_t;
#else
/*
 * `descriptor_t` is a C datatype used for any XPL CHARACTER or BIT variable
 * while being manipulated by C code (versus its form in the `memory` array).
 * Note that while called "descriptor_t", it's also used for BIT(<=32).
 * The `type` field also indicates the encoding in `memory`:
 *      ddCHARACTER    Converted into EBCDIC when placed into `memory`.
 *                     Converted to ASCII when pulled from `memory`.
 *      ddBIT          Not converted when placed into or pulled from `memory`.
 * (Replaces both former `string_t` and `bit_t` datatypes.  The advantage over
 * them is that it includes both the encoding and it allows CHARACTER to have
 * embedded NUL characters; the latter is important, though the latter isn't.)
 */
enum descriptorDatatype_t { ddCHARACTER, ddBIT };
typedef struct {
  enum descriptorDatatype_t type;
  uint16_t numBytes; // Number of bytes of stored data.
  uint16_t bitWidth; // Number of bits (0 for CHARACTER).
  uint8_t bytes[MAX_XPL_STRING+2]; // The data itself.
  int32_t address; // Address from which was loaded, or -1 if none.
  uint8_t inUse; // 0 if available for reuse.
} descriptor_t;
typedef char sbuf_t[MAX_XPL_STRING + 1];
#endif

#include "configuration.h"
#include "procedures.h"
#include "arguments.h"

// The macro `RETURN();` can be used in place of `return;`, while
// `RETURN(something);` can be used in place of `return something;`.  The
// advantage is that it takes `REENTRY_GUARD` into account.  This is really
// useful just in C-language patches for CALL INLINE statements.
#ifdef REENTRY_GUARD
#define RETURN(...) return ((reentryGuard = 0), (__VA_ARGS__))
#else
#define RETURN(...) return (__VA_ARGS__)
#endif

extern int outUTF8;
// "Device control blocks" for sequential files and PDS.  These have nothing
// to do with IBM 360 DCBs.
#define DCB_MAX 10
#define PDS_MEMBER_SIZE 8
#define MAX_PDS_RECORDS 32
#define PDS_RECORD_SIZE 1680
#define PDS_BUFFER_SIZE (MAX_PDS_RECORDS * PDS_RECORD_SIZE)
typedef char pdsPartname_t[PDS_MEMBER_SIZE + 1];
typedef struct {
  FILE *fp;             // Pointer to the open file, if appropriate.
  sbuf_t filename;      // Name of the open sequential file or PDS folder.
  uint8_t redirection;  // Redirection from one device number to another.
  uint8_t upperCase;    // 1 = translate to upper case, 0 (default) = don't.
  uint8_t ebcdic;       // 0 (default) = translate ebcdic/ascii, 1 = don't.
  uint8_t pds;          // 1 if PDS, 0 if sequential.
  uint8_t existed;      // 1 if PDS member existed before stow, 0 if not.
  char *extra;          // Optional line to prefix to first INPUT operation.
  pdsPartname_t member; // Last selected PDS member name.
  char buffer[PDS_BUFFER_SIZE]; // PDS output buffer.
  int bufferLength;     // Current data size in PDS output buffer.
  char fileFlags[4];    // Flags for `fopen`.
} DCB_t;
extern DCB_t DCB_INS[DCB_MAX];
extern DCB_t DCB_OUTS[DCB_MAX];

/*
extern FILE *DD_INS[DCB_MAX];
extern sbuf_t DD_INS_FILENAMES[DCB_MAX];
extern uint8_t DD_INS_UPPERCASE[DCB_MAX];
extern int PDS_INS[DCB_MAX];
extern pdsPartname_t DD_INS_PARTNAMES[DCB_MAX];
extern int DD_INS_redirection[DCB_MAX];
extern FILE *DD_OUTS[DCB_MAX];
extern sbuf_t DD_OUTS_FILENAMES[DCB_MAX];
extern int PDS_OUTS[DCB_MAX];
extern pdsPartname_t DD_OUTS_PARTNAMES[DCB_MAX];
extern int DD_OUTS_EXISTED[DCB_MAX];
extern int DD_OUTS_redirection[DCB_MAX];
typedef struct {
  int length;
  char buffer[PDS_BUFFER_SIZE];
} PDS_BUF_t;
extern PDS_BUF_t PDS_OUTS_BUFFERS[DCB_MAX];
*/
extern FILE *COMMON_OUT;

typedef struct {
  uint32_t optionsCode;
  char *name;
  char *defaultValue;
  char *synonym;
  char *negatedName;
  char *negatedSynonym;
} type1_t;

typedef struct {
  char *name;
  char *defaultValue;
  char *synonym;
} type2_t;

extern descriptor_t type1Actual[MAX_TYPE1];
extern descriptor_t type2Actual[MAX_TYPE2];
typedef struct {
  int numParms1;
  int numPrintable;
  int numParms2;
  type1_t type1[MAX_TYPE1];
  type2_t type2[MAX_TYPE2];
} optionsProcessor_t;
extern optionsProcessor_t *optionsProcessor, *USEROPT;

#ifdef DEBUGGING_AID

void
printMemoryMap(char *msg, int start, int end);

extern int bitBits;

descriptor_t *
bitToRadix(descriptor_t *b);

char *
getXPL(char *identifier);

void
printXPL(char *identifier);

descriptor_t *
rawGetXPL(char *base, int baseIndex, char *field, int fieldIndex);

char *
g0(char *identifier, memoryMapEntry_t *me);

char *
g(char *identifier); // For interactive debugging.

#ifdef IS_PASS2
void
checkoutPASS2(void);
#endif

#endif // DEBUGGING_AID

int
guardReentry(int reentryGuard, char *functionName);

// Some functions that are perhaps useful for CALL INLINE or for running
// the C code in a debugger.

void abend(const char *fmt, ...);

// Returns an empty string.
#define MAX_BUFFS 1024
descriptor_t *
nextBuffer(void);
// Count the number of buffers allocated.
int countBuffers(void);

descriptor_t *
asciiToDescriptor(char *c);

// "Print" a C string to a new or existing descriptor_t.
descriptor_t *
cToDescriptor(descriptor_t *descriptor, const char *fmt, ...);

uint32_t
makeDescriptor(descriptor_t *descriptor);

char *
descriptorToAscii(descriptor_t *descriptor);

// "Convert" a BIT to a CHARACTER. For long bit-strings, this copies the
// descriptor_t object and changes its type field; for bitWidth <= 32,
// it's a conversion from a binary representation of an integer to a decimal
// representation thereof.
descriptor_t *
bitToCharacter(descriptor_t *bit);

memoryMapEntry_t *
lookupAddress(uint32_t address);

memoryMapEntry_t *
lookupFloor(uint32_t address);

memoryMapEntry_t *
lookupVariable(char *symbol);

// Returns -1 on failure, 0 on success, 1 to request an immediate termination.
int
parseCommandLine(int argc, char **argv);

// XPL variables are *not* translated as C variables.  Rather, they are
// translated as sequences of bytes in the following buffer.
#define MEMORY_SIZE (1 << 24)
extern uint8_t memory[MEMORY_SIZE];

// Data related to random-access files, as manipulated by the XPL
// `FILE` built-in function.  "File numbers" 1 through 9 are available;
// file number 0 is unused.  Each file number can have an assigned
// input file and/or output file, or neither, and the input file can be
// the same or different than the output file.  These files are assigned,
// opened (or created, if necessary) in accordance to the command-line
// parameters (--raf) of the compiled executable.  By default, no
// random-access files are available.
#define MAX_RANDOM_ACCESS_FILES 10
#define INPUT_RANDOM_ACCESS 0
#define OUTPUT_RANDOM_ACCESS 1
typedef struct {
  FILE *fp;
  int recordSize;
  sbuf_t filename;
} randomAccessFile_t;
extern randomAccessFile_t randomAccessFiles[2][MAX_RANDOM_ACCESS_FILES];
void // Corresponding to `FILE(fileNumber, recordNumber) = buffer;`
lFILE(uint32_t fileNumber, uint32_t recordNumber, uint32_t address);
void // Corresponding to `buffer = FILE(fileNumber, recordNumber);`
rFILE(uint32_t address, uint32_t fileNumber, uint32_t recordNumber);
void // Corresponding to `FILE(...) = FILE(...);`
bFILE(uint32_t devL, uint32_t recL, uint32_t devR, uint32_t recR);

// Read XPL `FIXED` data from memory as a C `int`.  No checking for address
// overflow is performed and no errors are therefore possible.
int32_t
getFIXED(uint32_t address);

// Write a C `int` to memory as XPL `FIXED`.  No checking for address
// overflow is performed and no errors are therefore possible.
void
putFIXED(uint32_t address, int32_t value);

// Same for XPL `BIT` types.  If the `address` parameter for `getBIT`
// or `putBIT` can be found using `lookupAddress` (in runtimeC.c.), then the
// bitWidth can be determined by the lookup, and the `bitWidth` parameter can
// be set to 0.  Otherwise, `bitWidth` must be set.  This particularly comes
// into play with `BASED` variables, because the `address` parameter is the
// address of the array element, and there's no way to work backward from that
// to get the `BASED` variable it's associated with.
descriptor_t *
getBIT(uint32_t bitWidth, uint32_t address);
void
putBIT(uint32_t bitWidth, uint32_t address, descriptor_t *value);
void
putBITp(uint32_t bitWidth, uint32_t address, descriptor_t *value);

#if 0
char *
STRING(uint32_t address);
#endif

uint32_t
STRING_GT(descriptor_t *s1, descriptor_t *s2);

// Same for XPL `CHARACTER` type.
descriptor_t *
getCHARACTERd(uint32_t descriptor);
descriptor_t *
getCHARACTER(uint32_t address);
void
putCHARACTER(uint32_t address, descriptor_t *s);
void
putCHARACTERp(uint32_t address, descriptor_t *s);

// Convert a FIXED to a CHARACTER.
descriptor_t *
fixedToCharacter(int32_t i);

// Convert a BIT(1) through BIT(32) to FIXED.
int32_t
bitToFixed(descriptor_t *value);

// Convert FIXED to BIT(32).
descriptor_t *
fixedToBit(int32_t bitWidth, int32_t value);

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
#ifndef xOR
int32_t
xOR(int32_t i1, int32_t i2);
#endif // xOR
#ifndef xAND
int32_t
xAND(int32_t i1, int32_t i2);
#endif // xAND

int32_t
xsEQ(descriptor_t *s1, descriptor_t *s2);
int32_t
xsLT(descriptor_t *s1, descriptor_t *s2);
int32_t
xsGT(descriptor_t *s1, descriptor_t *s2);
int32_t
xsNEQ(descriptor_t *s1, descriptor_t *s2);
int32_t
xsLE(descriptor_t *s1, descriptor_t *s2);
int32_t
xsGE(descriptor_t *s1, descriptor_t *s2);

descriptor_t *
xsCAT(descriptor_t *s1, descriptor_t *s2);

// Built-in functions.  I've adapted the code for most or all of these from my
// previous manual port of HAL/S-FC PASS1 from XPL/I to Python.  Some of them,
// such as `OUTPUT`, are considerably extended from the XPL built-in of the
// same name as documented in McKeeman.

extern sbuf_t headingLine;
extern sbuf_t subHeadingLine;
extern int pageCount;
extern int LINE_COUNT;
extern memoryMapEntry_t *foundRawADDR;
extern int linesPerPage;
extern int watchpoint;
void
OUTPUT(uint32_t lun, descriptor_t *msg);

descriptor_t *
INPUT(uint32_t lun);

uint32_t
LENGTH(descriptor_t *string);

descriptor_t *
SUBSTR(descriptor_t *s, int32_t start, int32_t end);

descriptor_t *
SUBSTR2(descriptor_t *s, int32_t start);

// Note that BYTE and BYTE1 auto-convert from EBCDIC to the native character
// coding (presumably ASCII), because they're intended to operate on data
// from CHARACTER variables.  BYTE2 performs no such conversion, because it's
// intended to operate on the data of BIT variables.

uint8_t
BYTE0(uint32_t address);

uint8_t
BYTE(descriptor_t *s, uint32_t index);

uint8_t
BYTE1(descriptor_t *s);

uint8_t
BYTEliteral(char *s, uint32_t index);

uint8_t
BYTE1literal(char *s);

void
lBYTEc(uint32_t address, int32_t index, char c);

void
lBYTEb(uint32_t address, int32_t index, uint8_t b);

//uint8_t
//BYTE2(descriptor_t *b, uint32_t index);

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

void
MONITOR0(uint32_t dev);

uint32_t
MONITOR1(uint32_t dev, descriptor_t *name);

uint32_t
MONITOR2(uint32_t dev, descriptor_t *name);

void
MONITOR3(uint32_t dev);

void
MONITOR4(uint32_t dev, uint32_t recsize);

void
MONITOR5(int32_t address);

// Stuff for MONITOR6, 7, and 21.
typedef struct
{
  int based;        // 24-bit address in `memory` of dope vector of associated
                    // BASED variable, or -1 if none.
  uint32_t address; // Starting address in `memory` of the allocation.
  uint32_t size;    // Size in bytes of the allocation.
} allocation_t;
#define MAX_ALLOCATIONS 256
extern allocation_t allocations[MAX_ALLOCATIONS];
extern uint32_t numAllocations;

void
printAllocations(void);

uint32_t
MONITOR6a(uint32_t based, uint32_t n, int clear);

uint32_t
MONITOR6(uint32_t based, uint32_t n);

uint32_t
MONITOR7(uint32_t based, uint32_t n);

void
MONITOR8(uint32_t dev, uint32_t filenum);

void
toFloatIBM(uint32_t *msw, uint32_t *lsw, double d);

double
fromFloatIBM(uint32_t msw, uint32_t lsw);

uint32_t
MONITOR9(uint32_t op);

uint32_t
MONITOR10(descriptor_t *fpstring);

void
MONITOR11(void);

descriptor_t *
MONITOR12(uint32_t precision);

uint32_t
MONITOR13(descriptor_t *name);

uint32_t
MONITOR14(uint32_t n, uint32_t a);

uint32_t
MONITOR15(void);

extern uint32_t flags16;
void
MONITOR16(uint32_t n);

extern char *programNamePassedToMonitor;
void
MONITOR17(descriptor_t *name);

uint32_t
MONITOR18(void);

uint32_t
MONITOR19(uint32_t *addresses, uint32_t *sizes);

void
MONITOR20(uint32_t *addresses, uint32_t *sizes);

uint32_t
MONITOR21(void);

// This is MONITOR(22, n1)
uint32_t
MONITOR22(uint32_t n1);

// This is MONITOR(22, 0, n2)
uint32_t
MONITOR22A(uint32_t n2);

descriptor_t *
MONITOR23(void);

extern int32_t fileNumber31;
void
MONITOR31(int32_t n, int32_t recnum);

uint32_t
MONITOR32(void);

uint32_t
COREBYTE(uint32_t address);

void
COREBYTE2(uint32_t address, uint32_t value);

uint32_t
COREWORD(uint32_t address);

void
COREWORD2(uint32_t address, uint32_t value);

int16_t
COREHALFWORD(uint32_t address);

void
COREHALFWORD2(uint32_t address, int32_t value);

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
// There is one special case: IR-182-1 p. 13-3 tells us that in the one specific
// case of a BASED variable (say, `bVar`) used as a parameter for
// `ADDR`, `bVar` and `bVar[0]` don't behave the same.  Rather,
// `ADDR(bVar[0])` (i.e.,
//             bVar    0       NULL    0
// in the table above) would give us the expected address of the data for
// `basedVariable`, whereas `ADDR(bVar)` would instead give us the
// address of the *pointer* to the data area.  The table above, as-is, provides
// no way to handle this special case.  For that, we'll use the following:
//
//  bVar  80000000  NULL   0             Returns address of data-pointer for bVar
//
// In the parameters for `ADDR`, I make no distinction between
// DECLARE / COMMON / ARRAY / COMMON ARRAY, nor any distinction between
// BASED / COMMON BASED.  (There may or may not be an internal distinction
// between DECLARE and ARRAY; it depends on the final implementation of
// ARRAY, which at this writing is identical to DECLARE.)
uint32_t
ADDR(char *bVar, int32_t bIndex, char *fVar, int32_t fIndex);
int
rawADDR(char *bVar, int32_t bIndex, char *fVar, int32_t fIndex);

/* *Not* defined in runtimeC.c.  However, because XPL treats it like a built-in
 * code that uses it prior to the definition won't have a forward declaration.
 * So we declare it here. */
int32_t
COMPACTIFY(int reset);
//void
//RECORD_LINK(void);

// Functions for reading COMMON from a file, or writing COMMON to a file.

// Returns 0 on success or 1 on failure.
int
writeCOMMON(FILE *fp);

// Returns:
//     -1       Failure.
//      0       Full success.
//      1       Partial success: File was shorter than expected.
//      2       Partial success: File was longer than expected.
// In the current implementation, I don't actually have a good way to deal
// with the latter two cases, so the 3rd case always returns 0 and the 4th
// case aborts.
int
readCOMMON(FILE *fp);

uint32_t
FREEPOINT(void);

void
FREEPOINT2(uint32_t value);

void
TRACE(void);

void
UNTRACE(void);

uint32_t
TIME_OF_GENERATION(void);

uint32_t
FREELIMIT(void);

void
FREELIMIT2(uint32_t address);

extern int32_t freeBase;
int32_t
FREEBASE(void);

void
FREEBASE2(int32_t);

void
EXIT(void);

void
LINK(void);

extern char parmField[1024];
descriptor_t *
PARM_FIELD(void);

uint32_t
DESCRIPTOR(uint32_t index);

void
DESCRIPTOR2(uint32_t index, uint32_t descriptor);

uint32_t
NDESCRIPT(void);

int32_t
ABS(int32_t value);

uint32_t
XPL_COMPILER_VERSION(uint32_t index);

void
debugInline(int inlineCounter);

extern int traceInlineEnable;
extern int detailedInlineEnable;
#ifdef TRACE_INLINES
void
traceInline(char *msg);
void
detailedInlineBefore(int inlineCounter, char *instruction);
void
detailedInlineAfter(void);
#else
#define traceInline(x)
#define detailedInlineBefore(x, y)
#define detailedInlineAfter()
#endif

#endif // RUNTIMEC_H
