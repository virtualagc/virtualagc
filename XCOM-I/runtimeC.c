/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    runtimeC.c
 * Purpose:     This is runtime data and functions for the C code produced
 *              by the XPL/I-to-C translator XCOM-I.py.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-03-28 RSB  Began.
 *              2024-05-23 RSB  Reworked so that descriptor_t replaces string_t,
 *                              bit_t, and lots of char*.
 *              2024-06-19 RSB  Split off some functions not used in "production"
 *                              into debuggingAid.c.
 *
 * The functions herein are documented in runtimeC.h.
 *
 * For any given XPL/I program, XCOM-I.py outputs a single C source-code file
 * that's supposed to be the equivalent (possibly with manual tweaking) of the
 * original program.  That translation to C relies on this source-code file,
 * and the two C source-code files should should be compiled or linked together.
 *
 * Unfortunately, I'm as steeped in the assumptions about how my computing
 * environment (x86) works as the original Shuttle developers were about their
 * computing environment (IBM S/360), so while I *suspect* that my assumptions
 * will remain valid into the future, there's no guarantee of that, and
 * failure of some of my assumptions may affect the code in this file at some
 * point in the future.
 */

#include "runtimeC.h"
#include <time.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <math.h>
#include <ctype.h>

#ifdef _MSC_VER
// If the compiler identifies itself as Visual Studio C, then reenable the
// stuff I had added and then disabled for it.
#define _CL_
#endif

// Anything conditionally compiled with _CL_ was put in because I thought
// it would be nice to compile using the normal Windows C compiler (cl).
// While I did manage to get it to compile, it didn't work afterward, so I've
// segregated all of that nonsense with _CL_ to make it unreachable.  In other
// words, ignore everything inside of an #ifdef _CL_, forever and ever! If you
// want to compile for Windows, use Msys, Mingw, or some other non-MS approach.
// Or figure out how to solve it for me, because I'm no longer going to waste
// my time on it.
#ifdef _CL_

#if defined(_WIN32) && !defined(__MINGW32__)
	// All the stuff here was just cut-and-pasted from googling "windows
	// replacement for (whatever)".
	#include <stdarg.h>
	#define F_OK 0
	#define strcasecmp _stricmp

	// MSVC defines this in winsock2.h!?
	typedef struct timeval {
		long tv_sec;
		long tv_usec;
	} timeval;

	int gettimeofday(struct timeval * tp, struct timezone * tzp)
	{
		struct timespec ts;
		timespec_get(&ts, TIME_UTC);
		tp->tv_sec = ts.tv_sec;
		tp->tv_usec = ts.tv_nsec / 1000;
		return 0;
	}
#else
	#include <unistd.h>
#endif
#if !defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__)
#include <sys/time.h> // For gettimeofday().
#endif
#if !defined(_WIN32) && !defined(__CYGWIN__)
// Linux or Mac.
#include <execinfo.h> // For backtraces.
#endif

#else // not _CL_

#include <unistd.h>
#include <sys/time.h>
#if !defined(_WIN32) && !defined(__CYGWIN__) && !defined(__MINGW32__)
#include <execinfo.h>
#endif

#endif

//---------------------------------------------------------------------------
// Global variables.

// Extern'd in runtimeC.h or configuration.h:
int outUTF8 = 0;
DCB_t DCB_INS[DCB_MAX];
DCB_t DCB_OUTS[DCB_MAX];
FILE *COMMON_OUT = NULL;
randomAccessFile_t randomAccessFiles[2][MAX_RANDOM_ACCESS_FILES] = { { NULL } };

// Starting time of the program run, more or less.
struct timeval startTime;

// Memory-management stuff.
static uint32_t freepoint = FREE_POINT;
static uint32_t freelimit = FREE_LIMIT;

char parmField[1024] = "";
int linesPerPage = 59;
memoryMapEntry_t *foundRawADDR = NULL; // Set only by `rawADDR`.
int showBacktrace = 0;
int watchpoint = -1;

// The table below was adapted from the table of the same name in
// the Virtual AGC source tree.  The table is indexed on the numeric
// codes of the ASCII characters. It contains the EBCDIC numeric
// code for each *printable* ASCII character, with non-printable
// characters being translated to an EBCDIC space character.
// There are two exceptions, however, in that the ASCII ` (EBCDIC
// 0x79) and ASCII ~ (EBCDIC 0xA1) are assigned the EBCDIC codes
// for the U.S. cent sign EBCDIC 0x4A) and the logical-NOT symbol
// (EBCDIC 0x5F).  This reflects the fact that the latter two
// characters are always replaced internally within XCOM-I by the
// former two, because the latter two are not representable in
// ASCII and would presumably require multi-byte UTF-8 replacements,
// which is a potential complication I don't care to worry about.
// There were also a couple of differences from the EBCDIC table
// in the Wikipedia article of the same name, so I've changed those
// to match Wikipedia.
static uint8_t asciiToEbcdic[128] = {
  0x00, 0x01, 0x02, 0x03, 0x37, 0x2d, 0x2e, 0x2f,
  0x16, 0x05, 0x25, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
  0x10, 0x11, 0x12, 0x13, 0x3c, 0x3d, 0x32, 0x26, /*              */
  0x18, 0x19, 0x3f, 0x27, 0x1c, 0x1d, 0x1e, 0x1f, /*              */
  0x40, 0x5A, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D, /*  !"#$%&'     */
  0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61, /* ()*+,-./     */
  0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, /* 01234567     */
  0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F, /* 89:;<=>?     */
  0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, /* @ABCDEFG     */
  0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, /* HIJKLMNO     */
  0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, /* PQRSTUVW     */
  0xE7, 0xE8, 0xE9, 0xBA, 0xFE, 0xBB, 0x5F, 0x6D, /* XYZ[\]^_     */
  0x4A, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, /* `abcdefg     */
  0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, /* hijklmno     */
  0x97, 0x98, 0x99, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, /* pqrstuvw     */
  0xA7, 0xA8, 0xA9, 0xC0, 0x4F, 0xD0, 0x5F, 0x07  /* xyz{|}~      */
};

descriptor_t *
asciiToDescriptor(char *c) {
  descriptor_t *descriptor = nextBuffer();
  uint8_t *s = descriptor->bytes;
  descriptor->numBytes = strlen(c);
  while (*c)
    *s++ = asciiToEbcdic[*c++];
  *s = 0;
  return descriptor;
}

// "Print" a C string to a new or existing descriptor_t.
#ifdef __clang__
__attribute__((__format__ (__printf__, 2, 3)))
#endif
descriptor_t *
cToDescriptor(descriptor_t *descriptor, const char *fmt, ...) {
  if (descriptor == NULL)
    descriptor = nextBuffer();
  if (fmt == NULL)
    return descriptor;
  va_list args;
  va_start(args, fmt);
  descriptor->numBytes =
      vsnprintf(descriptor->bytes, sizeof(descriptor->bytes), fmt, args);
  va_end(args);
  for (char *s = descriptor->bytes; *s; s++)
    *s = asciiToEbcdic[*s];
  descriptor->type = ddCHARACTER;
  descriptor->bitWidth = 0;
  return descriptor;
}

// Construct a string descriptor for a descriptor_t not yet in `memory`.
// We use a technique here similar to nextBuffer().  There's a reserved
// area in `memory` that we can use for a circular buffer of slightly-persistent
// string data, without performing any allocations, assuming that the data will
// be stale enough to reuse if we ever have to wrap around to it.  It's
// necessary that it be within `memory` rather than in C memory, because we
// need to be able to form string descriptors to point to it.  It starts
// at &memory[PRIVATE_MEMORY] and is PRIVATE_MEMORY_SIZE bytes long.
uint32_t
makeDescriptor(descriptor_t *descriptor) {
  static int nextPrivate = 0; /* 0 to PRIVATE_DATA_SIZE-1 */
  uint32_t returnValue = 0; /* default is NUL string */
  if (descriptor->numBytes > 0)
    {
      uint32_t next = nextPrivate + descriptor->numBytes,
               now = PRIVATE_MEMORY + nextPrivate;
      if (next > PRIVATE_MEMORY_SIZE)
        {
          nextPrivate = 0;
          next = descriptor->numBytes;
        }
      memmove(&memory[now], descriptor->bytes, descriptor->numBytes);
      returnValue = ((descriptor->numBytes - 1) << 24) | now;
      nextPrivate = next;
    }
  return returnValue;
}

// The "inverse" (in spirit) of `asciiToEbcdic` above, in which the ASCII
// equivalent character is given for each printable EBCDIC code.  It performs
// the substitution of the U.S. cent character to ` and the logical-NOT
// symbol to ~, a explained above.  It was generated from the table above
// using the one-time-use program invertEbcdicTable.py.
// Note: It would be nice if both `asciiToEbcdic` and `ebcdicToAscii` were
// 256 bytes, and inverses of each other, even if half the entries in the
// latter had to be invented, but that's impossible because of the way
// ~,^ map to logical-NOT and ` maps to U.S. cent.  I.e., the mapping isn't
// 1-to-1.  It's just too dodgy trying to make it work.
static char ebcdicToAscii[256] = {
  '\x00', '\x01', '\x02', '\x03', ' '   , '\x09', ' '   , '\x7F',
  ' '   , ' '   , ' '   , '\x0B', '\x0C', '\x0D', '\x0E', '\x0F',
  '\x10', '\x11', '\x12', '\x13', ' '   , ' '   , '\x08', ' '   ,
  '\x18', '\x19', ' '   , ' '   , '\x1C', '\x1D', '\x1E', '\x1F',
  ' '   , ' '   , ' '   , ' '   , ' '   , '\x0A', '\x17', '\x1B',
  ' '   , ' '   , ' '   , ' '   , ' '   , '\x05', '\x06', '\x07',
  ' '   , ' '   , '\x16', ' '   , ' '   , ' '   , ' '   , '\x04',
  ' '   , ' '   , ' '   , ' '   , '\x14', '\x15', ' '   , '\x1A',
  ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , '`'   , '.'   , '<'   , '('   , '+'   , '|'   ,
  '&'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , '!'   , '$'   , '*'   , ')'   , ';'   , '~'   ,
  '-'   , '/'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , ' '   , ','   , '%'   , '_'   , '>'   , '?'   ,
  ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , ':'   , '#'   , '@'   , '\''  , '='   , '"'   ,
  ' '   , 'a'   , 'b'   , 'c'   , 'd'   , 'e'   , 'f'   , 'g'   ,
  'h'   , 'i'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , 'j'   , 'k'   , 'l'   , 'm'   , 'n'   , 'o'   , 'p'   ,
  'q'   , 'r'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , 's'   , 't'   , 'u'   , 'v'   , 'w'   , 'x'   ,
  'y'   , 'z'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , '['   , ']'   , ' '   , ' '   , ' '   , ' '   ,
  '{'   , 'A'   , 'B'   , 'C'   , 'D'   , 'E'   , 'F'   , 'G'   ,
  'H'   , 'I'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  '}'   , 'J'   , 'K'   , 'L'   , 'M'   , 'N'   , 'O'   , 'P'   ,
  'Q'   , 'R'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , 'S'   , 'T'   , 'U'   , 'V'   , 'W'   , 'X'   ,
  'Y'   , 'Z'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  '0'   , '1'   , '2'   , '3'   , '4'   , '5'   , '6'   , '7'   ,
  '8'   , '9'   , ' '   , ' '   , ' '   , ' '   , '\\'  , ' '
};

char *
descriptorToAscii(descriptor_t *descriptor) {
  descriptor_t *returnValue = nextBuffer();
  uint8_t *c = returnValue->bytes, *s = descriptor->bytes;
  if (descriptor->type == ddCHARACTER)
    {
      while (*s)
        {
          *c++ = ebcdicToAscii[*s++];
          returnValue->numBytes++;
        }
      *c = 0;
    }
  else if (descriptor->numBytes > 32)
    returnValue->numBytes = sprintf(returnValue->bytes, "(long bitstring)");
  else
    {
      int32_t value = bitToFixed(descriptor);
      returnValue->numBytes = sprintf(returnValue->bytes, "%d", value);
    }
  return returnValue->bytes;
}

optionsProcessor_t COMPOPT_PFS = {
  32 /* numParms1 */,
  20 /* numPrintable */,
  13 /* numParms2 */,
  { /* type1 */
    { 0x00000001, "DUMP", "NODUMP", "DP", "NODUMP", "NDP" },
    { 0x00000002, "LISTING2", "NOLISTING2", "L2", "NOLISTING2", "NL2" },
    { 0x00000004, "LIST", "NOLIST", "L", "NOLIST", "NL" },
    { 0x00000008, "TRACE", "TRACE", "TR", "NOTRACE", "NTR" },
    { 0x00000040, "VARSYM", "NOVARSYM", "VS", "NOVARSYM", "NVS" },
    { 0x00400000, "DECK", "NODECK", "D", "NODECK", "ND" },
    { 0x00000800, "TABLES", "TABLES", "TBL", "NOTABLES", "NTBL" },
    { 0x00008000, "TABLST", "NOTABLST", "TL", "NOTABLST", "NTL" },
    { 0x00100000, "ADDRS", "NOADDRS", "A", "NOADDRS", "NA" },
    { 0x00080000, "SRN", "NOSRN", NULL, "NOSRN", NULL },
    { 0x00800000, "SDL", "NOSDL", NULL, "NOSDL", NULL },
    { 0x00001000, "TABDMP", "NOTABDMP", "TBD", "NOTABDMP", "NTBD" },
    { 0x00000400, "ZCON", "ZCON", "Z", "NOZCON", "NZ" },
    { 0x00040000, "HALMAT", "NOHALMAT", "HM", "NOHALMAT", "NHM" },
    { 0x02000000, "REGOPT", "NOREGOPT", "R", "NOREGOPT", "NR" },
    { 0x04000000, "MICROCODE", "MICROCODE", "MC", "NOMICROCODE", "NMC" },
    { 0x00002000, "SREF", "NOSREF", "SR", "NOSREF", "NSR" },
    { 0x20000000, "QUASI", "NOQUASI", "Q", "NOQUASI", "NQ" },
    { 0x00000010, "TEMPLATE", "NOTEMPLATE", "TP", "NOTEMPLATE", "NTP" },
    { 0x00000080, "HIGHOPT", "NOHIGHOPT", "HO", "NOHIGHOPT", "NHO" },
    { 0x00010000, "PARSE", "NOPARSE", "P", "NOPARSE", "NP" },
    { 0x00020000, "LSTALL", "NOLSTALL", "LA", "NOLSTALL", "NLA" },
    { 0x00200000, "LFXI", "LFXI", NULL, "NOLFXI", NULL },
    { 0x00000020, "X1", "NOX1", NULL, "NOX1", NULL },
    { 0x00000100, "X4", "NOX4", NULL, "NOX4", NULL },
    { 0x00000200, "X5", "NOX5", NULL, "NOX5", NULL },
    { 0x00004000, "XA", "NOXA", NULL, "NOXA", NULL },
    { 0x01000000, "X6", "NOX6", NULL, "NOX6", NULL },
    { 0x08000000, "XB", "NOXB", NULL, "NOXB", NULL },
    { 0x10000000, "XC", "NOXC", NULL, "NOXC", NULL },
    { 0x40000000, "XE", "NOXE", NULL, "NOXE", NULL },
    { 0x80000000, "XF", "NOXF", NULL, "NOXF", NULL }
  },
  { /* type2 */
    { "TITLE", NULL, "T" },
    { "LINECT", "59", "LC" },
    { "PAGES", "2500", "P" },
    { "SYMBOLS", "200", "SYM" },
    { "MACROSIZE", "500", "MS" },
    { "LITSTRINGS", "2000", "LITS" },
    { "COMPUNIT", "0", "CU" },
    { "XREFSIZE", "2000", "XS" },
    { "CARDTYPE", NULL, "CT" },
    { "LABELSIZE", "1200", "LBLS" },
    { "DSR", "1", NULL },
    { "BLOCKSUM", "400", "BS" },
    { "MFID", NULL, NULL }
  }
};

optionsProcessor_t COMPOPT_BFS = {
  32 /* numParms1 */,
  21 /* numPrintable */,
  13 /* numParms2 */,
  { /* type1 */
    { 0x00000001, "DUMP", "NODUMP", "DP", "NODUMP", "NDP" },
    { 0x00000002, "LISTING2", "NOLISTING2", "L2", "NOLISTING2", "NL2" },
    { 0x00000004, "LIST", "NOLIST", "L", "NOLIST", "NL" },
    { 0x00000008, "TRACE", "TRACE", "TR", "NOTRACE", "NTR" },
    { 0x00000040, "VARSYM", "NOVARSYM", "VS", "NOVARSYM", "NVS" },
    { 0x00400000, "DECK", "NODECK", "D", "NODECK", "ND" },
    { 0x00000800, "TABLES", "TABLES", "TBL", "NOTABLES", "NTBL" },
    { 0x00008000, "TABLST", "NOTABLST", "TL", "NOTABLST", "NTL" },
    { 0x00100000, "ADDRS", "NOADDRS", "A", "NOADDRS", "NA" },
    { 0x00080000, "SRN", "NOSRN", NULL, "NOSRN", NULL },
    { 0x00800000, "SDL", "NOSDL", NULL, "NOSDL", NULL },
    { 0x00001000, "TABDMP", "NOTABDMP", "TBD", "NOTABDMP", "NTBD" },
    { 0x00000400, "ZCON", "ZCON", "Z", "NOZCON", "NZ" },
    { 0x00040000, "HALMAT", "NOHALMAT", "HM", "NOHALMAT", "NHM" },
    { 0x02000000, "SCAL", "SCAL", "SC", "NOSCAL", "NSC" },
    { 0x04000000, "MICROCODE", "MICROCODE", "MC", "NOMICROCODE", "NMC" },
    { 0x00002000, "SREF", "NOSREF", "SR", "NOSREF", "NSR" },
    { 0x20000000, "QUASI", "NOQUASI", "Q", "NOQUASI", "NQ" },
    { 0x40000000, "REGOPT", "NOREGOPT", "R", "NOREGOPT", "NR" },
    { 0x00000010, "TEMPLATE", "NOTEMPLATE", "TP", "NOTEMPLATE", "NTP" },
    { 0x00000080, "HIGHOPT", "NOHIGHOPT", "HO", "NOHIGHOPT", "NHO" },
    { 0x00010000, "PARSE", "NOPARSE", "P", "NOPARSE", "NP" },
    { 0x00020000, "LSTALL", "NOLSTALL", "LA", "NOLSTALL", "NLA" },
    { 0x00200000, "LFXI", "LFXI", NULL, "NOLFXI", NULL },
    { 0x00000020, "X1", "NOX1", NULL, "NOX1", NULL },
    { 0x00000100, "X4", "NOX4", NULL, "NOX4", NULL },
    { 0x00000200, "X5", "NOX5", NULL, "NOX5", NULL },
    { 0x00004000, "XA", "NOXA", NULL, "NOXA", NULL },
    { 0x01000000, "X6", "NOX6", NULL, "NOX6", NULL },
    { 0x08000000, "XB", "NOXB", NULL, "NOXB", NULL },
    { 0x10000000, "XC", "NOXC", NULL, "NOXC", NULL },
    { 0x8000000, "XF", "NOXF", NULL, "NOXF", NULL }
  },
  { /* type2 */
    { "TITLE", NULL, "T" },
    { "LINECT", "59", "LC" },
    { "PAGES", "2500", "P" },
    { "SYMBOLS", "200", "SYM" },
    { "MACROSIZE", "500", "MS" },
    { "LITSTRINGS", "2000", "LITS" },
    { "COMPUNIT", "0", "CU" },
    { "XREFSIZE", "2000", "XS" },
    { "CARDTYPE", NULL, "CT" },
    { "LABELSIZE", "1200", "LBLS" },
    { "DSR", "1", NULL },
    { "BLOCKSUM", "400", "BS" },
    { "OLDTPL", NULL, NULL }
  }
};

optionsProcessor_t COMPOPT_360 = {
  32 /* numParms1 */,
  17 /* numPrintable */,
  12 /* numParms2 */,
  { /* type1 */
    { 0x00000001, "DUMP", "NODUMP", "DP", "NODUMP", "NDP" },
    { 0x00000002, "LISTING2", "NOLISTING2", "L2", "NOLISTING2", "NL2" },
    { 0x00000004, "LIST", "NOLIST", "L", "NOLIST", "NL" },
    { 0x00000008, "TRACE", "TRACE", "TR", "NOTRACE", "NTR" },
    { 0x00400000, "DECK", "NODECK", "D", "NODECK", "ND" },
    { 0x00000800, "TABLES", "TABLES", "TBL", "NOTABLES", "NTBL" },
    { 0x00008000, "TABLST", "NOTABLST", "TL", "NOTABLST", "NTL" },
    { 0x00100000, "ADDRS", "NOADDRS", "A", "NOADDRS", "NA" },
    { 0x00080000, "SRN", "NOSRN", NULL, "NOSRN", NULL },
    { 0x00800000, "SDL", "NOSDL", NULL, "NOSDL", NULL },
    { 0x00001000, "TABDMP", "NOTABDMP", "TBD", "NOTABDMP", "NTBD" },
    { 0x00000400, "ZCON", "ZCON", "Z", "NOZCON", "NZ" },
    { 0x00040000, "FCDATA", "NOFCDATA", "FD", "NOFCDATA", "NFD" },
    { 0x02000000, "SCAL", "SCAL", "SC", "NOSCAL", "NSC" },
    { 0x04000000, "MICROCODE", "MICROCODE", "MC", "NOMICROCODE", "NMC" },
    { 0x00002000, "SREF", "NOSREF", "SR", "NOSREF", "NSR" },
    { 0x20000000, "QUASI", "NOQUASI", "Q", "NOQUASI", "NQ" },
    { 0x00010000, "PARSE", "NOPARSE", "P", "NOPARSE", "NP" },
    { 0x00020000, "LSTALL", "NOLSTALL", "LA", "NOLSTALL", "NLA" },
    { 0x00200000, "LFXI", "LFXI", NULL, "NOLFXI", NULL },
    { 0x00000010, "X0", "NOX0", NULL, "NOX0", NULL },
    { 0x00000020, "X1", "NOX1", NULL, "NOX1", NULL },
    { 0x00000040, "X2", "NOX2", NULL, "NOX2", NULL },
    { 0x00000080, "X3", "NOX3", NULL, "NOX3", NULL },
    { 0x00000100, "X4", "NOX4", NULL, "NOX4", NULL },
    { 0x00000200, "X5", "NOX5", NULL, "NOX5", NULL },
    { 0x00004000, "XA", "NOXA", NULL, "NOXA", NULL },
    { 0x01000000, "X6", "NOX6", NULL, "NOX6", NULL },
    { 0x08000000, "XB", "NOXB", NULL, "NOXB", NULL },
    { 0x10000000, "XC", "NOXC", NULL, "NOXC", NULL },
    { 0x40000000, "XE", "NOXE", NULL, "NOXE", NULL },
    { 0x80000000, "XF", "NOXF", NULL, "NOXF", NULL }
  },
  { /* type2 */
    { "TITLE", NULL, "T" },
    { "LINECT", "59", "LC" },
    { "PAGES", "250", "P" },
    { "SYMBOLS", "200", "SYM" },
    { "MACROSIZE", "500", "MS" },
    { "LITSTRINGS", "2000", "LITS" },
    { "COMPUNIT", "0", "CU" },
    { "XREFSIZE", "2000", "XS" },
    { "CARDTYPE", NULL, "CT" },
    { "LABELSIZE", "1200", "LBLS" },
    { "DSR", "1", NULL },
    { "BLOCKSUM", "400", "BS" }
  }
};

optionsProcessor_t LISTOPT = {
  25 /* numParms1 */,
  4 /* numPrintable */,
  4 /* numParms2 */,
  { /* type1 */
    { 0x00008000, "TABLST", "NOTABLST", "TL", "NOTABLST", "NTL" },
    { 0x00001000, "TABDMP", "NOTABDMP", "TBD", "NOTABDMP", "NTBD" },
    { 0x00000020, "ALL", "NOALL", NULL, "NOALL", NULL },
    { 0x00000040, "BRIEF", "NOBRIEF", NULL, "NOBRIEF", NULL },
    { 0x00000080, "X3", "NOX3", NULL, "NOX3", NULL },
    { 0x00000100, "X4", "NOX4", NULL, "NOX4", NULL },
    { 0x00000200, "X5", "NOX5", NULL, "NOX5", NULL },
    { 0x01000000, "X6", "NOX6", NULL, "NOX6", NULL },
    { 0x20000000, "X7", "NOX7", NULL, "NOX7", NULL },
    { 0x40000000, "X8", "NOX8", NULL, "NOX8", NULL },
    { 0x00000001, "X9", "NOX9", NULL, "NOX9", NULL },
    { 0x00004000, "XA", "NOXA", NULL, "NOXA", NULL },
    { 0x00000004, "XD", "NOXD", NULL, "NOXD", NULL },
    { 0x00000002, "XE", "NOXE", NULL, "NOXE", NULL },
    { 0x80000000, "XF", "NOXF", NULL, "NOXF", NULL },
    { 0x00000400, "XG", "NOXG", NULL, "NOXG", NULL },
    { 0x00002000, "XH", "NOXH", NULL, "NOXH", NULL },
    { 0x00000002, "XI", "NOXI", NULL, "NOXI", NULL },
    { 0x00010000, "XJ", "NOXJ", NULL, "NOXJ", NULL },
    { 0x00040000, "XK", "NOXK", NULL, "NOXK", NULL },
    { 0x00080000, "XL", "NOXL", NULL, "NOXL", NULL },
    { 0x00100000, "XM", "NOXM", NULL, "NOXM", NULL },
    { 0x00200000, "XN", "NOXN", NULL, "NOXN", NULL },
    { 0x00400000, "XO", "NOXO", NULL, "NOXO", NULL },
    { 0x00800000, "XP", "NOXP", NULL, "NOXP", NULL }
  },
  { /* type2 */
    { "TITLE", NULL, "T" },
    { "LINECT", "59", "LC" },
    { "PAGES", "10000", "P" },
    { "LIST", "1", "L" }
  }
};

optionsProcessor_t MONOPT = {
  3 /* numParms1 */,
  3 /* numPrintable */,
  5 /* numParms2 */,
  { /* type1 */
    { 0x00000001, "DUMP", "NODUMP", "DP", "NODUMP", "NDP" },
    { 0x00000002, "LISTING2", "NOLISTING2", "L2", "NOLISTING2", "NL2" },
    { 0x00000004, "ALTER", "NOALTER", NULL, "NOALTER", NULL }
  },
  { /* type2 */
    { "LINECT", "59", "LC" },
    { "PAGES", "250", "P" },
    { "MIN", "50000", NULL },
    { "MAX", "5000000", NULL },
    { "FREE", "14336", NULL }
  }
};

descriptor_t type1Actual[MAX_TYPE1];
descriptor_t type2Actual[MAX_TYPE2];
optionsProcessor_t *optionsProcessor = NULL;

//---------------------------------------------------------------------------
// Utility functions.

#define BT_BUF_SIZE 100

// The backtrace is available in Linux and (I've read) Mac OS.  It's not
// available in Windows, at least not with the same execinfo.h mechanism.
void
printBacktrace(void)
{
#ifdef _EXECINFO_H
  int j, nptrs;
  void *buffer[BT_BUF_SIZE];
  char **strings;
  nptrs = backtrace(buffer, BT_BUF_SIZE);
  strings = backtrace_symbols(buffer, nptrs);
  if (strings != NULL)
    {
      fprintf(stderr, "Backtrace:\n");
      for (j = 0; j < nptrs; j++)
        fprintf(stderr, "\t%s\n", strings[j]);
    }
  free(strings);
#endif
}

#ifndef _CL_
__attribute__((noreturn))
#endif
void
abend(const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  printf("\n");
  fflush(stdout);
  vfprintf(stderr, fmt, args);
  va_end(args);
  fprintf(stderr, "\n");
  if (showBacktrace)
    printBacktrace();
  exit(1);
}

// Try to match a string to a Type 1 PARM field.  Returns 1 if found, 0 if not.
int
matchType1(char *parm) {
  int i, len;
  for (i = 0; i < optionsProcessor->numParms1; i++)
    {
      len = strlen(optionsProcessor->type1[i].name);
      if (!strncmp(parm, optionsProcessor->type1[i].name, len) &&
          (parm[len] == ',' || parm[len] == 0))
        {
          cToDescriptor(&type1Actual[i], "%s", optionsProcessor->type1[i].name);
          break;
        }
      if (optionsProcessor->type1[i].synonym != NULL)
        {
          len = strlen(optionsProcessor->type1[i].synonym);
          if (!strncmp(parm, optionsProcessor->type1[i].synonym, len) &&
              (parm[len] == ',' || parm[len] == 0))
            {
              cToDescriptor(&type1Actual[i], "%s", optionsProcessor->type1[i].name);
              break;
            }
        }
      len = strlen(optionsProcessor->type1[i].negatedName);
      if (!strncmp(parm, optionsProcessor->type1[i].negatedName, len) &&
          (parm[len] == ',' || parm[len] == 0))
        {
          cToDescriptor(&type1Actual[i], "%s",
              optionsProcessor->type1[i].negatedName);
          break;
        }
      if (optionsProcessor->type1[i].negatedSynonym != NULL)
        {
          len = strlen(optionsProcessor->type1[i].negatedSynonym);
          if (!strncmp(parm, optionsProcessor->type1[i].negatedSynonym, len) &&
              (parm[len] == ',' || parm[len] == 0))
            {
              cToDescriptor(&type1Actual[i], "%s",
                      optionsProcessor->type1[i].negatedName);
              break;
            }
        }
    }
  if (i >= optionsProcessor->numParms1) // Not found.
    return 0;
  return 1;
}
int
matchType2(char *parm) {
  int i, len;
  char *s, *ss, *buffer;
  for (i = 0; i < optionsProcessor->numParms2; i++)
    {
      len = strlen(optionsProcessor->type2[i].name);
      if (!strncmp(parm, optionsProcessor->type2[i].name, len))
        {
          s = parm + len + 1;
          break;
        }
      if (optionsProcessor->type2[i].synonym == NULL)
        continue;
      len = strlen(optionsProcessor->type2[i].synonym);
      if (!strncmp(parm, optionsProcessor->type2[i].synonym, len))
        {
          s = parm + len + 1;
          break;
        }
    }
  if (i >= optionsProcessor->numParms2)
    return 0; // not found.
  if (parm[len] != '=')
    return 0;
  // The candidate is pointed to by `s`.
  buffer = malloc(MAX_XPL_STRING);
  ss = strstr(s, ",");
  if (ss == NULL)
    strcpy(buffer, s);
  else
    strncpy(buffer, s, ss - s);
  cToDescriptor(&type2Actual[i], "%s", buffer);
  return 1;
}

void
parseParmField(int print) {
  sbuf_t parm;
  char *s, *ss;
  int i;
  uint32_t OPTIONS_CODE = 0, address;
  for (i = 0; i < optionsProcessor->numParms1; i++)
    cToDescriptor(&type1Actual[i], "%s", optionsProcessor->type1[i].defaultValue);
  for (i = 0; i < optionsProcessor->numParms2; i++)
    cToDescriptor(&type2Actual[i], optionsProcessor->type2[i].defaultValue);
  // Note that in principle, if there's a TITLE parameter, then it could
  // contain commas, so we have to watch out for that in parsing the
  // parameter field.  Let's go ahead and split on the commas, and then
  // fix it up afterward if necessary.
  for (s = parmField; s != NULL && *s != 0; ((s = strchr(s, ','))==NULL)?NULL:(++s))
    {
      int i;
      strncpy(parm, s, sizeof(parm));
      // Is it any of the expected patterns for parameter types?
      if (parm[0] == '$')
        continue;
      if (matchType1(parm))
        continue;
      if (matchType2(parm))
        continue;
      abend("Unrecognized PARM field: Parameter = %s", parm);
    }
  if (print)
    {
      for (i = 0; i < optionsProcessor->numParms1; i++)
        printf("%s\n", descriptorToAscii(&type1Actual[i]));
      for (i = 0; i < optionsProcessor->numParms2; i++)
        if (type2Actual[i].numBytes == 0)
          printf("%s = NULL\n", optionsProcessor->type2[i].name);
        else
          printf("%s = %s\n", optionsProcessor->type2[i].name,
              descriptorToAscii(&type2Actual[i]));
    }
  // If we've gotten here, then the PARM field has been parsed, and the
  // arrays `type1Actual` and `type2Actual` have been updated with the new
  // settings, while `type2Names` contains the names of the Type 2 parameters.
  // We need to interpret the Type 1 settings as bit-flags in OPTIONS_CODE.
  for (i = 0; i < optionsProcessor->numParms1; i++)
    if (strncmp(descriptorToAscii(&type1Actual[i]), "NO", 2)) // Not NO?
      OPTIONS_CODE |= optionsProcessor->type1[i].optionsCode;

  // Finally, we can update the XPL memory (for MONITOR(13)) which holds the
  // `CON`, `PRO`, `TYPE2`, `VALS`, and `NPVALS` arrays.
  putFIXED(WHERE_MONITOR_13, OPTIONS_CODE);
  address = getFIXED(WHERE_MONITOR_13 + 4); // Address of CON
  for (i = 0; i < optionsProcessor->numPrintable; i++)
    putCHARACTER(address + 4 * i, &type1Actual[i]);
  address = getFIXED(WHERE_MONITOR_13 + 8); // Address of PRO
  for (i = 0; i < optionsProcessor->numPrintable; i++)
    {
      char *buf = descriptorToAscii(&type1Actual[i]);
      sbuf_t buf2;
      if (!strncmp(buf, "NO", 2))
        strcpy(&buf2[0], buf + 2);
      else
        sprintf(&buf2[0], "NO%s", buf);
      putCHARACTER(address + 4 * i, asciiToDescriptor(&buf2[0]));
    }
  address = getFIXED(WHERE_MONITOR_13 + 12); // Address of TYPE2
  for (i = 0; i < optionsProcessor->numParms2; i++)
    putCHARACTER(address + 4 * i,
                 cToDescriptor(NULL, optionsProcessor->type2[i].name));
  address = getFIXED(WHERE_MONITOR_13 + 16); // Address of VALS
  for (i = 0; i < optionsProcessor->numParms2; i++)
    if (i == 0 || i == 8 || i == 12)
      {
        if (type2Actual[i].numBytes == 0)
          putFIXED(address + 4 * i, 0);
        else
          putCHARACTER(address + 4 * i, &type2Actual[i]);
      }
    else
      putFIXED(address + 4 * i, atoi(descriptorToAscii(&type2Actual[i])));
  address = getFIXED(WHERE_MONITOR_13 + 20); // Address of NPVALS
  for (i = optionsProcessor->numPrintable; i < optionsProcessor->numParms1; i++)
    putCHARACTER(address + 4 * i, &type1Actual[i]);
}

// Doesn't just parse the command line, but also performs some other
// initialization.
int
parseCommandLine(int argc, char **argv)
{
  int i, j, returnValue = 0, numArgs;
  char translation;
  FILE *COMMON_IN = NULL;
  gettimeofday(&startTime, NULL);

#ifdef NUM_INITIALIZED
  extern uint8_t memoryInitializer[NUM_INITIALIZED];
  memcpy(memory, memoryInitializer, NUM_INITIALIZED);
#endif

  // Default setup of INPUT/OUTPUT DCBs.
  for (i = 0; i < DCB_MAX; i++)
    {
      memset(&DCB_INS[i], 0, sizeof(DCB_t));
      memset(&DCB_OUTS[i], 0, sizeof(DCB_t));
      DCB_INS[i].redirection = i;
      DCB_OUTS[i].redirection = i;
      strcpy(DCB_INS[i].fileFlags, "rt");
      strcpy(DCB_OUTS[i].fileFlags, "wt");
    }
  DCB_INS[0].fp = DCB_INS[1].fp = stdin;
  DCB_OUTS[0].fp = DCB_OUTS[1].fp = stdout;

  for (i = 1; i < argc; i++)
    {
      int n, lun, recordSize;
      char c, c1, c2, filename[1024];
      n = 0;
      if (!strcmp("--utf8", argv[i]))
        outUTF8 = 1;
      else if (1 == sscanf(argv[i], "--watch=%d", &j))
        watchpoint = j;
      else if (2 == sscanf(argv[i], "--extra=%d,%c", &lun, &c))
        {
          if (lun < 0 || lun >= DCB_MAX)
            {
              fprintf(stderr, "Input logical unit number %d is out of range.\n",
                  lun);
              returnValue = -1;
            }
          DCB_INS[lun].extra = 1 + strstr(argv[i], ",");
        }
      else if (2 <= (n = sscanf(argv[i], "--ddi=%d,%[^,],%c,%c", &lun, filename, &c1, &c2)) ||
               2 <= (n = sscanf(argv[i], "--pdsi=%d,%[^,],%c", &lun, filename, &c1)))
        {
          if (lun < 0 || lun >= DCB_MAX)
            {
              fprintf(stderr, "Input logical unit number %d is out of range.\n",
                  lun);
              returnValue = -1;
            }
          else
            {
              int len = strlen(filename);
              char *pfilename = DCB_INS[lun].filename;
              if ((n >= 4 && c2 == 'U') || (n >= 3 && c1 == 'U'))
                DCB_INS[lun].upperCase = 1;
              if ((n >= 4 && c2 == 'E') || (n >= 3 && c1 == 'E'))
                {
                  DCB_INS[lun].ebcdic = 1;
                  strcpy(DCB_INS[lun].fileFlags, "rb");
                }
              if ((n >= 4 && c2 != 'U' && c2 != 'E') ||
                  (n >= 3 && c1 != 'U' && c1 != 'E'))
                abend("Unknown --ddi/pdsi option");
              strcpy(pfilename, filename);
              if (argv[i][2] == 'd')
                {
                  DCB_INS[lun].fp = fopen(pfilename, DCB_INS[lun].fileFlags);
                  if (DCB_INS[lun].fp == NULL)
                    abend("Cannot open file %s for reading on unit %d\n",
                          pfilename, lun);
                }
              else
                {
                  strcpy(DCB_INS[lun].member, "");
                  DCB_INS[lun].pds = 1;
                }
            }
        }
      else if (2 <= (n = sscanf(argv[i], "--ddo=%d,%[^,],%c",
                                      &lun, filename, &c)) ||
               2 <= (n = sscanf(argv[i], "--pdso=%d,%[^,],%c",
                                      &lun, filename, &c)))
        {
          if (lun < 0 || lun >= DCB_MAX)
            {
              fprintf(stderr, "Output logical unit number %d is out of range.\n", lun);
              returnValue = -1;
            }
          else
            {
              if (n >= 3)
                {
                  if (c == 'E')
                    {
                      DCB_OUTS[lun].ebcdic = 1;
                      strcpy(DCB_OUTS[lun].fileFlags, "wb");
                    }
                  else
                    abend("Unknown --ddo/pdso option %c", c);
                }
              strcpy(DCB_OUTS[lun].filename, filename);
              if (argv[i][2] == 'd')
                {
                  DCB_OUTS[lun].fp = fopen(filename, DCB_OUTS[lun].fileFlags);
                  if (DCB_OUTS[lun].fp == NULL)
                    {
                      fprintf(stderr, "Cannot create file %s for writing on unit %d\n",
                          filename, lun);
                      returnValue = -1;
                    }
                }
              else
                DCB_OUTS[lun].pds = 1;
            }
        }
      else if (4 == sscanf(argv[i], "--raf=%c,%d,%d,%[^\n\r]", &c,
                           &recordSize, &lun, filename))
        {
          randomAccessFile_t *ri, *ro;
          if (lun < 1 || lun >= MAX_RANDOM_ACCESS_FILES)
            abend("Illegal device number");
          if (c == 'I' || c == 'i')
            {
              ri = &randomAccessFiles[INPUT_RANDOM_ACCESS][lun];
              if (ri->fp != NULL)
                abend("Input file already attached");
              ri->fp = fopen(filename, "rb");
              if (ri->fp == NULL)
                abend("Cannot open input file for reading");
              ri->recordSize = recordSize;
              strncpy(ri->filename, filename, sizeof(sbuf_t));
            }
          else if (c == 'O' || c == 'o')
            {
              ro = &randomAccessFiles[OUTPUT_RANDOM_ACCESS][lun];
              if (ro->fp != NULL)
                abend("Output file already attached");
              ro->fp = fopen(filename, "ab");
              if (ro->fp == NULL)
                abend("Cannot open output file for writing");
              ro->recordSize = recordSize;
              strncpy(ro->filename, filename, sizeof(sbuf_t));
            }
          else if (c == 'B' || c == 'b')
            {
              ri = &randomAccessFiles[INPUT_RANDOM_ACCESS][lun];
              ro = &randomAccessFiles[OUTPUT_RANDOM_ACCESS][lun];
              if (ri->fp != NULL)
                abend("Input file already attached");
              if (ro->fp != NULL)
                abend("Output file already attached");
              ro->fp = fopen(filename, "rb+");
              if (ro->fp == NULL)
                ro->fp = fopen(filename, "wb+");
              if (ro->fp == NULL)
                abend("Cannot open i/o file for read/write");
              ro->recordSize = recordSize;
              strncpy(ro->filename, filename, sizeof(sbuf_t));
              ri->fp = ro->fp;
              ri->recordSize = recordSize;
              strcpy(ri->filename, ro->filename);
            }
          else
            abend("Illegal i/o spec");
        }
      else if (1 == sscanf(argv[i], "--commoni=%s", filename))
        {
          COMMON_IN = fopen(filename, "r");
          if (COMMON_IN == NULL)
            abend("Unable to open COMMON input file");
        }
      else if (1 == sscanf(argv[i], "--commono=%s", filename))
        {
          COMMON_OUT = fopen(filename, "w");
          if (COMMON_OUT == NULL)
            abend("Unable to open COMMON output file");
        }
      else if (!strncmp(argv[i], "--parm=", 7))
        {
          char *s;
          strcpy(parmField, &argv[i][7]);
        }
      else if (!strcmp(argv[i], "--backtrace"))
        showBacktrace = 1;
      else if (!strcmp("--eng=fp", argv[i]))
        {
          // Test of the IBM float conversions.  Note that aside from showing that
          // toFloatIBM() and fromFloatIBM() are inverses, it also reproduces the
          // known value 100 -> 0x42640000,0x00000000.
          int32_t s, e;
          uint32_t msw, lsw;
          double x, y;
          for (s = -1; s < 2; s += 2)
            {
              for (e = -10; e <= 10; e++)
                {
                  x = s * pow(10, e);
                  toFloatIBM(&msw, &lsw, x);
                  y = fromFloatIBM(msw, lsw);
                  printf("%24.10lf 0x%08x,0x%08x %.10lf\n", x, msw, lsw, y);
                }
            }
          exit(0);
        }
      else if (!strcmp("--eng=pf", argv[i]))
        {
          while (1)
            {
              sbuf_t line;
              printf("PARM field > ");
              fgets(line, sizeof(line), stdin);
              line[strlen(line)-1] = 0;
              strcpy(parmField, line);
              parseParmField(1);
              printf("\n");
            }
        }
      else if (!strcmp ("--trace-inlines", argv[i]))
        traceInlineEnable = 1;
      else if (!strcmp("--detailed-inlines", argv[i]))
        {
          detailedInlineEnable = 1;
          traceInlineEnable = 1;
        }
      else if (!strcmp("--help", argv[i]))
        {
          printf("\n");
          printf("Usage:\n");
          printf("        %s [OPTIONS]\n", APP_NAME);
          printf("\n");
          printf("The available OPTIONS are:\n");
          printf("--help        Displays this menu and then immediately exits.\n");
          printf("--utf8        By default, any non-ASCII symbols for the\n");
          printf("              U.S. cent sign and the logical-NOT symbol\n");
          printf("              are translated to the ASCII characters ` and ~\n");
          printf("              respectively, and will appear that way if\n");
          printf("              output when this program is run.  If that\n");
          printf("              is disturbing, you can try using the --utf8\n");
          printf("              to try outputs in UTF-8 encoding instead.\n");
          printf("--ddi=N,F[,U][,E] Attach filename F to the logical unit number\n");
          printf("              N, for use with the INPUT(N) XPL built-in.\n");
          printf("              By default, 0 and 1 are attached to stdin.\n");
          printf("              N can range from 0 through 9. If the optional\n");
          printf("              \",U\" is present, it causes all input to be\n");
          printf("              silently converted to upper case.  The \"U\"\n");
          printf("              is literal.  If the optional literal E is\n");
          printf("              present, then the input is treated as EBCDIC.\n");
          printf("--ddo=N,F[,E] Attach filename F to the logical unit number\n");
          printf("              N, for use with the OUTPUT(N) XPL built-in.\n");
          printf("              By default, 0 and 1 are attached to stdout.\n");
          printf("              N can range from 0 through 9.  The optional\n");
          printf("              literal E indicates that the output is EBCDIC\n");
          printf("              or binary.\n");
          printf("--pdsi=N,F[,E] Same as --ddi, but for a PDS file.\n");
          printf("--pdso=N,F[,E] Same as --ddo, but for a PDS file.\n");
          printf("--raf=I,R,N,F Attach filename F to device number N, for use\n");
          printf("              with the FILE(N) XPL built-in.  R is the\n");
          printf("              record size associated with the random-access\n");
          printf("              file, such as 3600.  I is one of the following:\n");
          printf("              'I' (for Input), 'O' (for Output), or 'B' (for\n");
          printf("              Both input and output).  N is 1 through 9.\n");
          printf("              By default, no random-access files are attached.\n");
          printf("--commoni=F   Name of the file from which to read the\n");
          printf("              initial values for COMMON memory at startup.\n");
          printf("              By default, COMMON is not initialized.\n");
          printf("              Note that COMMON is a feature of XPL/I, and\n");
          printf("              hence is disabled for standard XPL programs.\n");
          printf("--commono=F   Name of the file to which data from COMMON\n");
          printf("              is written upon program termination.  By\n");
          printf("              default, the file COMMON.out is used.\n");
          printf("              Note that COMMON is a feature of XPL/I, and\n");
          printf("              hence is disabled for standard XPL programs.\n");
          printf("--parm=S      Specifies a PARM FIELD such as would originally\n");
          printf("              have been provided in JCL.\n");
          printf("--backtrace   If available, print a backtrace upon abend.\n");
          printf("              (Not presently functional in Windows.\n");
          printf("--trace-inlines If available, trace execution of patched\n");
          printf("              blocks of CALL INLINE statements.\n");
          printf("--detailed-inlines Expanded trace message for CALL INLINE\n");
          printf("              statements; automatically sets --trace-inlines.\n");
          printf("--extra=N,L   L represents a string and N represents a device\n");
          printf("              number for INPUT(N).  This option causes the\n");
          printf("              string L to be returned upon the *first* use of\n");
          printf("              INPUT(N), which subsequently reverts to providing\n");
          printf("              lines for the actual input file number N.  For\n");
          printf("              debugging purposes, this is useful for feeding \n");
          printf("              in so-called \"control toggles\" that would\n");
          printf("              ordinarily be provided in program comments, since\n");
          printf("              it eliminates the need to modify the source code\n");
          printf("              being compiled.  For example,\n");
          printf("                   --extra=2,'/* $E $S */'\n");
          printf("              would cause emitted IBM 360 codes to be\n");
          printf("              interlisted with XPL source code in the printout,\n");
          printf("              and symbol tables to be printed after each\n");
          printf("              PROCEDURE, for the XCOM of 'A Compiler Generator'.\n");
          printf("              Whereas\n");
          printf("                   --extra=0,'/* $E $S */'\n");
          printf("              would do the same, but only beginning with the\n");
          printf("              main source-code file, skipping the library file.\n");
          printf("              Other (or no) toggles might be applicable for other\n");
          printf("              XPL compilers.\n");
          printf("--watch=A     (Default none.)  Causes a message to be printed\n");
          printf("              whenever the value of memory[A] changes.\n");
          printf("\n");
          returnValue = 1;
        }
      else
        {
          printf("Unknown command-line switch %s. Try --help.\n", argv[i]);
          returnValue = -1;
        }
    }
  //parseParmField(0); // Parse the PARM-field string.
  if (COMMON_IN != NULL)
    {
      if (NON_COMMON_BASE > COMMON_BASE)
        {
          int status = readCOMMON(COMMON_IN);
          if (status < 0)
            abend("Severe error reading COMMON.");
          else if (status == 1)
            fprintf(stderr, "COMMON file smaller than expected.\n");
          else if (status == 2)
            fprintf(stderr, "COMMON file was larger than expected.\n");
        }
      else
        fprintf(stderr, "This program has no COMMON block.\n");
      fclose(COMMON_IN);
      COMMON_IN = NULL;
    }
#ifndef STANDARD_XPL
  if (COMMON_OUT == NULL)
    { FILE *fp;
      COMMON_OUT = fopen("COMMON.out", "w");
      // My intention is that COMMON_OUT won't be written to until the program
      // terminates.  But there seems to be a bug in glibc (or somewhere), so
      // that if I delay writing to COMMON_OUT until then, there's an error
      // that looks like this:
      //        aout: malloc.c:2617: sysmalloc: Assertion `(old_top == initial_top (av) && old_size == 0) || ((unsigned long) (old_size) >= MINSIZE && prev_inuse (old_top) && ((unsigned long) old_end & (pagesize - 1)) == 0)' failed.
      //        Aborted (core dumped)
      // Yikes!  I've accidentally found that if I immediately output to the
      // file, there's no such error.  Hence the following otherwise completely
      // unnecessary line.
      fprintf(COMMON_OUT,
              ";\tXPL/I COMMON block output by `%s` (generated by XCOM-I)\n",
              APP_NAME);
    }
#endif
  return returnValue;
}

/*
 * `nextBuffer` is sort of a cut-rate memory-management system for built-ins
 * that return CHARACTER values or BIT values.  In order to avoid having to
 * allocate new memory for such output, or more importantly to free such
 * memory later, we instead maintain a circular array of buffers, and
 * each call to a built-in that returns a string or a BIT simply uses the next
 * buffer in that array.  The reason this is okay is that functions returning
 * strings or BITs are invoked only in the context of expressions, and the
 * number of function calls an expression can make isn't very large. So we can
 * just make the circular array very large and not worry about it.  I hope.
 *
 * Later ... I was so, so wrong!  It's true that if you think of a simple
 * expression like S = S0 || S1 || ... || SN that it can use up very few
 * buffers.  But suppose, say, you had a procedure P() that had two parameters
 * which were CHARACTER or BIT(>32).  And supposed you used two functions that
 * returned CHARACTER or BIT(>32) as the parameters:
 *      CALL P(bitFunction1(), bitFunction2();
 * When this executes, bitFunction2() will execute first, returning a
 * descriptor_t * which just sits around doing nothing while bitFunction1()
 * executes.  If bitFunction1() itself calls nextBuffer() lots of times, because
 * perhaps it's printing a big report, then nextBuffer() may wrap around and hit
 * the returned descriptor_t * from bitFunction2() before bitFunction1() ever
 * returns.
 *
 * Unfortunately, this is not merely theoretical, because it actually happens
 * in printing the symbol table for HAL/S-FC PASS1, causing "random" errors in
 * the symbol-table printout, depending on how big MAX_BUFFS is.  1024 is
 * definitely too small!  I'm increasing MAX_BUFFS tremendously to account for
 * it temporarily, but the entire nextBuffer system needs to be rethought and
 * fixed. But I find that LISTING2 is even more sensitive to this problem than
 * symbol-table printout, even MAX_BUFFS as large as 100000 don't fix it.
 * ***FIXME***
 */
static descriptor_t buffers[MAX_BUFFS];
static int currentBuffer;
descriptor_t *
nextBuffer(void)
{
  descriptor_t *returnValue = NULL;
  int start = currentBuffer;
  while (0 && buffers[currentBuffer].inUse)
    {
      currentBuffer++;
      if (currentBuffer >= MAX_BUFFS)
        currentBuffer = 0;
      if (currentBuffer == start)
        abend("No more free buffers.");
    }
  returnValue = &(buffers[currentBuffer++]);
  if (currentBuffer >= MAX_BUFFS)
    currentBuffer = 0;
  returnValue->type = ddCHARACTER;
  returnValue->numBytes = 0;
  returnValue->bitWidth = 0;
  returnValue->bytes[0] = 0;
  returnValue->address = -1;
  returnValue->inUse = 1;
  return returnValue;
}

int
countBuffers(void) {
  int i, count = 0;
  for (i = 0; i <= MAX_BUFFS; i++)
    if (buffers[i].inUse)
      count++;
  return count;
}

descriptor_t *
bitToCharacter(descriptor_t *bit) {
  if (bit->bitWidth > 32)
    {
      descriptor_t *returnValue = nextBuffer();
      memmove(returnValue, bit, sizeof(descriptor_t));
      return returnValue;
    }
  return fixedToCharacter(bitToFixed(bit));
}

// Used only by `lookupAddress`.
static int
cmpAddresses(const void *e1, const void *e2)
{
  return ((memoryMapEntry_t *) e1)->address -
         ((memoryMapEntry_t *) e2)->address;
}

// Used only by `lookupVariable` and `ADDR`.
static int
cmpMapSymbols(const void *e1, const void *e2) {
  return strcasecmp((*(memoryMapEntry_t **) e1)->symbol,
                    (*(memoryMapEntry_t **) e2)->symbol);
}
static int
cmpString(const void *e1, const void *e2) {
  return strcasecmp(*(char **) e1, *(char **) e2);
}

// Look up the `memoryMap` entry associated with a given address.  Returns
// either a pointer to the record, or else NULL if not found.
memoryMapEntry_t *
lookupAddress(uint32_t address)
{
  memoryMapEntry_t key, *found;
  key.address = address;
  found = bsearch(&key, memoryMap, NUM_SYMBOLS,
                  sizeof(memoryMapEntry_t), cmpAddresses);
  return found;
}

// Similar to `loopupAddress`, but we're looking for the entry with the given
// address, or failing that, the closest address smaller than that.  We're
// guaranteed that there are no duplicates.  It's a curious omission, but there
// seems to be no library function in C for this kind of a commonly-desired
// search, so we have to roll our own binary search.
memoryMapEntry_t *
lookupFloor(uint32_t address)
{
  int start = 0, end = NUM_SYMBOLS, current;
  memoryMapEntry_t *found;
  while (end > start + 1)
    {
      current = (start + end) / 2;
      found = &memoryMap[current];
      if (found->address == address)
        return found;
      if (found->address > address)
        end = current;
      else
        start = current;
    }
  return &memoryMap[start];
}

// Look up the `memoryMap` entry associated with a given variable name.
// Returns either a pointer to the record, or else NULL if not found.
memoryMapEntry_t *
lookupVariable(char *symbol)
{
  memoryMapEntry_t **found, key, *keyp = &key;
  static int mapInitialized = 0;
  if (!mapInitialized)
    {
      // In point of fact, XCOM-I has already sorted `memoryMapBySymbol`.
      // However, it's possible this C program on the run-time computer to
      // have a different sorting order than XCOM-I.py did on the compile-time
      // computer.  (Or even on the *same* computer, in my experience!)
      // If that happens, then binary searches will no longer work properly.
      // Consequently, we sort it again now, at run-time, guaranteeing
      // matching collation.
      mapInitialized = 1;
      qsort(&memoryMapBySymbol, NUM_SYMBOLS,
            sizeof(memoryMapEntry_t *), cmpMapSymbols);
      qsort(&mangledLabels, NUM_MANGLED, sizeof(char *), cmpString);
    }
  // Note that since `memoryMapBySymbol` contains pointers to
  // `memoryMapEntry_t`, then the key for the binary search must
  // also be a pointer to a memoryMapEntry_t.
  strcpy(key.symbol, symbol);
  found = bsearch(&keyp, &memoryMapBySymbol, NUM_SYMBOLS,
                  sizeof(memoryMapEntry_t *), cmpMapSymbols);
  if (found == NULL)
    return NULL;
  return *found;
}

//---------------------------------------------------------------------------
// Runtime-library functions.

int32_t
getFIXED(uint32_t address)
{
  int32_t value;
  // Convert from big-endian to native format.
  value = memory[address++];
  value = (value << 8) | memory[address++];
  value = (value << 8) | memory[address++];
  value = (value << 8) | memory[address];
  return value;
}

void
putFIXED(uint32_t address, int32_t value)
{
  memory[address++] = (value >> 24) & 0xFF;
  memory[address++] = (value >> 16) & 0xFF;
  memory[address++] = (value >> 8) & 0xFF;
  memory[address] = value & 0xFF;
}

descriptor_t *
getBIT(uint32_t bitWidth, uint32_t address)
{
  descriptor_t *value = nextBuffer();
  uint32_t numBytes;
  if (bitWidth == 0)
    {
      memoryMapEntry_t *memoryMapEntry = lookupFloor(address);
      if (memoryMapEntry == NULL)
        abend("Implementation error: getBIT address not found");
      bitWidth = memoryMapEntry->bitWidth;
    }
  numBytes = (bitWidth + 7) / 8;
  if (numBytes == 3) // BIT(17) through BIT(24) uses 4 bytes.
    numBytes = 4;
  if (bitWidth > 32)
    {
      uint32_t descriptor;
      descriptor = getFIXED(address);
      if (numBytes - 1 != descriptor >> 24)
        abend("Implementation error: getBIT width mismatch, "
              "bitWidth=%d, numBytes=%d, descriptor=(%d,%06X)",
              bitWidth, numBytes, descriptor>>24, descriptor&0xFFFFFF);
      address = descriptor & 0xFFFFFF;
      value->address = address;
    }
  value->type = ddBIT;
  value->bitWidth = bitWidth;
  value->numBytes = numBytes;
  memmove(value->bytes, &memory[address], numBytes);
  return value;
}

// Like `putBIT`, but for saving values of parameters.  See `putCHARACTERp`.
void
putBITp(uint32_t bitWidth, uint32_t address, descriptor_t *value)
{
  if (bitWidth > 32 && value->address > 0)
    putCHARACTERp(address, value);
  else
    putBIT(bitWidth, address, value);
}

void
putBIT(uint32_t bitWidth, uint32_t address, descriptor_t *value)
{
  uint32_t numBytes, destAddress;
  //uint32_t maskWidth, maskAddress = address;
  if (bitWidth == 0)
    {
      memoryMapEntry_t *memoryMapEntry = lookupFloor(address);
      if (memoryMapEntry == NULL)
        abend("Implementation error: putBIT address not found");
      bitWidth = memoryMapEntry->bitWidth;
    }
  numBytes = (bitWidth + 7) / 8;
  if (numBytes == 3) // BIT(17) through BIT(24) uses 4 bytes.
    {
      //maskAddress++;
      numBytes = 4;
    }
  if (bitWidth > 32)
    {
      uint32_t descriptor;
      descriptor = getFIXED(address);
      if ((value->numBytes - 1) != descriptor >> 24)
        {
          fflush(stdout);
          fprintf(stderr,
              "Implementation error: putBIT(%d,0x%06X), BIT width mismatch, getFIXED(0x%06X)==0x%08X.\n",
              bitWidth, address, address, descriptor);
        }
      destAddress = freepoint;
      putFIXED(address, ((numBytes - 1) << 24) | destAddress);
      freepoint += numBytes;
      if (freepoint > freelimit)
        {
          COMPACTIFY(0); // Will abort the program upon failure.
          descriptor = getFIXED(address);
          destAddress = descriptor & 0xFFFFFF;
        }
    }
  else
    destAddress = address;
  //maskWidth = bitWidth % 8;
  while (numBytes > value->numBytes)
    {
      memory[destAddress++] = 0;
      numBytes--;
      //maskWidth = 0;
    }
  memmove(&memory[destAddress], &value->bytes[value->numBytes - numBytes], numBytes);
  /*
  if (maskWidth)
    {
      if (bitWidth <= 32)
        memory[maskAddress] &= (1 << maskWidth) - 1;
      else
        memory[address + numBytes - 1] &= ~((1 << maskWidth) - 1);
    }
  if (maskAddress == address + 1)
    memory[address] = 0;
  */
}

uint32_t
STRING_GT(descriptor_t *s1, descriptor_t *s2) {
  uint8_t blank = BYTE1literal(" ");
  int i, b1, b2, len1 = s1->numBytes, len2 = s2->numBytes, len;
  len = len1;
  if (len2 > len)
    len = len2;
  for (i = 0; i < len; i++)
    {
      if (i < len1)
        b1 = BYTE(s1, i);
      else
        b1 = blank;
      if (i < len2)
        b2 = BYTE(s2, i);
      else
        b2 = blank;
      if (b1 > b2)
        return 1;
      if (b1 < b2)
        return 0;
    }
  // Strings were the same.
  return 0;
}

descriptor_t *
getCHARACTERd(uint32_t descriptor)
{
  descriptor_t *returnValue = nextBuffer();
  uint16_t numBytes;
  uint32_t address;
  int i;
  if (descriptor != 0) // Empty string?
    {
      numBytes = ((descriptor >> 24) & 0xFF) + 1;
      returnValue->numBytes = numBytes;
      address = descriptor & 0xFFFFFF;
      returnValue->address = address;
      for (i = 0; i < numBytes; i++)
        {
          //returnValue->bytes[i] = ebcdicToAscii[memory[address + i]];
          returnValue->bytes[i] = memory[address + i];
        }
      // A NUL terminator isn't logically necessary, but will be lots more
      // convenient for consumers of string data.  The buffer is big enough
      // to hold it.
      returnValue->bytes[numBytes] = 0;
    }
  return returnValue;
}

descriptor_t *
getCHARACTER(uint32_t address) {
  return getCHARACTERd(getFIXED(address));
}

// Like putCHARACTER(), except for saving procedure parameters.  the difference
// is that if possible it overwrites just the in-memory descriptor, giving
// the procedure the possibility of using the original string in-place.
void
putCHARACTERp(uint32_t address, descriptor_t *s) {
  if (s->numBytes > 0 && s->address >= 0)
    {
      uint32_t descriptor;
      descriptor = ((s->numBytes - 1) << 24) | (s->address & 0xFFFFFF);
      putFIXED(address, descriptor);
    }
  else
    putCHARACTER(address, s);
}

void
putCHARACTER(uint32_t address, descriptor_t *str)
{
#ifdef REENTRY_GUARD
  static int reentryGuard = 0;
  reentryGuard = guardReentry(reentryGuard, "putCHARACTER");
#endif
  size_t length;
  uint32_t index, descriptor, newDescriptor;
  descriptor = (uint32_t) getFIXED(address);
  index = descriptor & 0xFFFFFF;
  length = str->numBytes;
  if (length == 0)
    {
      putFIXED(address, 0);
#ifdef REENTRY_GUARD
      reentryGuard = 0;
#endif
      return;
    }
  if (length > 256) { // Shouldn't be possible.
    length = 256;
    str->numBytes = length;
  }
  // Allocate space for the string.  My original code here only allocated
  // space if the new string was longer than the old, simply saving the string
  // in-place if it was short enough.  However, there's a problem with that:
  // If the procedure internally manipulates one of its CHARACTER parameters,
  // then we'd be overwriting the string that had been assigned to that
  // parameter last, which we don't want.  None of my regression-test XPL files
  // nor XCOM3 nor XCOM45 did that, so I never detected the problem; but
  // HAL/S-FC does it.
  index = freepoint;
  putFIXED(address, ((length - 1) << 24) | index);
  freepoint += length;
  if (freepoint > freelimit)
    {
      COMPACTIFY(0); // Will abort the program upon failure.
      descriptor = getFIXED(address);
      index = descriptor & 0xFFFFFF;
    }
  if (index + length <= MEMORY_SIZE)
    {
      char c, *s = str->bytes;
      for (; length > 0; length--, s++, index++)
        {
          c = *s;
          memory[index] = c;
        }
    }
#ifdef REENTRY_GUARD
  reentryGuard = 0;
#endif
  return;
}

descriptor_t *
fixedToCharacter(int32_t i) {
  int j = i;
  return cToDescriptor(NULL, "%d", j);
}

// Convert a BIT(1) through BIT(32) to FIXED.  As near as I can figure (see
// ps. 137 and 139 of McKeenan), BIT(1) through BIT(15) are treated as unsigned,
// whereas BIT(16) is sign-extended.  I don't actually see that BIT(17) through
// BIT(32) are converted at all ... but I do anyway, sign-extending them.
// As for BIT(33) and up, it appears to me that what's desired in those cases
// is the descriptor, but I have no way to supply it from the provided
// parameters.  That'll have to be handled upstream from here.
int32_t
bitToFixed(descriptor_t *value)
{
  int32_t numBytes, bitWidth, dirWidth;
  uint8_t *bytes;
  bitWidth = value->bitWidth;
  numBytes = value->numBytes;
  bytes = value->bytes;
  if (numBytes == 1)
    return bytes[0];
  if (numBytes == 2)
    {
      int16_t word = (bytes[0] << 8) | bytes[1];
      if ((word & 0x8000) != 0)
        word |= 0xFFFF0000;
      return word;
    }
  if (numBytes == 4)
    return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  abend("Conversion of BIT(%d) to FIXED not implemented", bitWidth);
  return 0; // Can't get to here.
}

descriptor_t *
fixedToBit(int32_t bitWidth, int32_t value)
{
  descriptor_t *buffer = nextBuffer();
  uint32_t numBytes;
  uint8_t *bytes = buffer->bytes;
  buffer->bitWidth = bitWidth;
  numBytes = (bitWidth + 7) / 8;
  if (numBytes == 3)
    numBytes = 4;
  buffer->numBytes = numBytes;
  if (numBytes == 1)
    {
      bytes[0] = value & 0xFF;
      return buffer;
    }
  if (numBytes == 2)
    {
      bytes[0] = (value >> 8) & 0xFF;
      bytes[1] = value & 0xFF;
      return buffer;
    }
  if (numBytes == 4)
    {
      bytes[0] = (value >> 24) & 0xFF;
      bytes[1] = (value >> 16) & 0xFF;
      bytes[2] = (value >> 8) & 0xFF;
      bytes[3] = value & 0xFF;
      return buffer;
    }
  abend("Conversion of FIXED to BIT(%d) not implemented", bitWidth);
  return buffer; // Can't get to here.
}

int32_t
xadd(int32_t i1, int32_t i2)
{
  return i1 + i2;
}

int32_t
xsubtract(int32_t i1, int32_t i2)
{
  return i1 - i2;
}

int32_t
xminus(int32_t i)
{
  return -i;
}

int32_t
xmultiply(int32_t i1, int32_t i2)
{
  return i1 * i2;
}

int32_t
xdivide(int32_t i1, int32_t i2)
{
  if (i2 == 0)
    abend("Division by zero detected");
  return i1 / i2;
}

int32_t
xmod(int32_t i1, int32_t i2)
{
  return i1 % i2;
}

int32_t
xEQ(int32_t i1, int32_t i2)
{
  return i1 == i2;
}

int32_t
xLT(int32_t i1, int32_t i2) {
  return i1 < i2;
}

int32_t
xGT(int32_t i1, int32_t i2) {
  return i1 > i2;
}

int32_t
xNEQ(int32_t i1, int32_t i2) {
  return i1 != i2;
}

int32_t
xLE(int32_t i1, int32_t i2) {
  return i1 <= i2;
}

int32_t
xGE(int32_t i1, int32_t i2) {
  return i1 >= i2;
}

int32_t
xNOT(int32_t i1) {
  return ~i1;
}

#ifndef xOR
int32_t
xOR(int32_t i1, int32_t i2) {
  return i1 | i2;
}
#endif // xOR

#ifndef xAND
int32_t
xAND(int32_t i1, int32_t i2){
  return i1 & i2;
}
#endif // xAND

// Various string-comparison functions follow.

// Used by `xsXXX` functions, and not expected to be called directly.
enum stringRelation_t { EQ, NEQ, LT, GT, LE, GE };
int32_t
stringRelation(enum stringRelation_t relation,
               descriptor_t *d1,
               descriptor_t *d2) {
  int comparison = 0; // -1 for <, 0 for =, 1 for >.
  uint8_t *s1 = d1->bytes, *s2 = d2->bytes;
  int l1 = d1->numBytes, l2 = d2->numBytes;
  if (l1 > l2)
    comparison = 1;
  else if (l1 < l2)
    comparison = -1;
  else
    for (; l1 > 0; l1--, s1++, s2++)
      {
        uint8_t e1 = *s1, e2 = *s2;
        if (e1 > e2) { comparison = 1; break; }
        else if (e1 < e2) { comparison = -1; break; }
      }
  if (relation == EQ) return comparison == 0;
  if (relation == NEQ) return comparison != 0;
  if (relation == LT) return comparison == -1;
  if (relation == GT) return comparison == 1;
  if (relation == LE) return comparison != 1;
  if (relation == GE) return comparison != -1;
  return 0; // Shouldn't ever get to here.
}
int32_t
xsEQ(descriptor_t *s1, descriptor_t *s2) {
  return stringRelation(EQ, s1, s2);
}
int32_t
xsLT(descriptor_t *s1, descriptor_t *s2) {
  return stringRelation(LT, s1, s2);
}
int32_t
xsGT(descriptor_t *s1, descriptor_t *s2) {
  return stringRelation(GT, s1, s2);
}
int32_t
xsNEQ(descriptor_t *s1, descriptor_t *s2) {
  return stringRelation(NEQ, s1, s2);
}
int32_t
xsLE(descriptor_t *s1, descriptor_t *s2) {
  return stringRelation(LE, s1, s2);
}
int32_t
xsGE(descriptor_t *s1, descriptor_t *s2) {
  return stringRelation(GE, s1, s2);
}

descriptor_t *
xsCAT(descriptor_t *s1, descriptor_t *s2) {
  int length;
  descriptor_t *returnString = nextBuffer();
  memmove(returnString->bytes, s1->bytes, s1->numBytes);
  memmove(&returnString->bytes[s1->numBytes], s2->bytes, s2->numBytes);
  returnString->numBytes = s1->numBytes + s2->numBytes;
  returnString->bytes[returnString->numBytes] = 0; // A convenience terminator.
  return returnString;
}

// Sometimes strings for printing are prepared with unprintable control
// characters in them.  I convert those transparently to spaces, since
// I've found empirically that that's what's needed to not mess up the
// columnar alignment.  (It's still messed up, but just not so badly.)
static char *
uncontrol(char *original) {
  static sbuf_t buf;
  char *s, *ss;
  for (s = original, ss = buf; *s; s++)
    if (*s >= 0x20 && *s <= 0x7F)
      *ss++ = *s;
    else
      *ss++ = ' ';
  *ss = 0;
  return buf;
}

/*
The following function replaces the XPL constructs
    OUTPUT(fileNumber) = string
    OUTPUT = string      , which is shorthand for OUTPUT(0)=string.
The carriage-control characters for fileNumber 1 may be
the so-called ANSI control characters:
    ' '    Single space the line and print
    '0'    Double space the line and print
    '-'    Triple space the line and print
    '+'    Do not space the line and print (but does return carriage to left!)
    '1'    Form feed
    'H'    Heading line.
    '2'    Subheading line.
    ...    Others
*/
sbuf_t headingLine = "";
sbuf_t subHeadingLine = "";
int pageCount = 0;
int LINE_COUNT = 0;
int pendingNewline = 0;
#define MAX_QUEUE 10
void
OUTPUT(uint32_t lun, descriptor_t *string) {
  char ansi = ' '; // ANSI carriage-control character.
  char *ss, *s = descriptorToAscii(string); // Printable character data.
  FILE *fp;
  int i;
  if (lun < 0 || lun >= DCB_MAX || (DCB_OUTS[lun].fp == NULL && !DCB_OUTS[lun].pds))
    abend("Output file has not been assigned: Device = %d", lun);
  lun = DCB_OUTS[lun].redirection;
  fp = DCB_OUTS[lun].fp;
  sbuf_t queue[MAX_QUEUE]; // SYSPRINT line-queue for current page.
  for (i = 0; i < strlen(s); i++)
    if (s[i] == 0xF0)
      fprintf(stderr, "***DEBUG*** Line '%s' has illegal 0xF0\n", s);
  int linesInQueue = 0;
  if (lun <= 1) // SYSPRINT
    {
      if (lun == 1)
        {
          ansi = *s;
          if (*s == 0) // Account for a possible empty string.
            ansi = ' ';
          else
            s += 1;
        }
      if (ansi == '_')
        {}
      else if (ansi == ' ')
        strcpy(queue[linesInQueue++], "");
      else if (ansi == '0')
        {
          strcpy(queue[linesInQueue++], "");
          strcpy(queue[linesInQueue++], "");
        }
      else if (ansi == '-')
        {
          strcpy(queue[linesInQueue++], "");
          strcpy(queue[linesInQueue++], "");
          strcpy(queue[linesInQueue++], "");
        }
      else if (ansi == '+')
        {
          // This should overstrike the line.  I.e., it's like a carriage return
          // without a line feed.  But I have no actual way to do that, so we
          // need to advance to the next line.  Carats just work better than
          // underscores in these overstrikes (in my opinion).
          strcpy(queue[linesInQueue++], "");
          for (ss = s; *ss; ss++)
            if (*ss == '_')
              *ss = '^';
        }
      else if (ansi == '1')
        LINE_COUNT = linesPerPage;
      else if (ansi == 'H')
        {
          strcpy(headingLine, s);
          return;
        }
      else if (ansi == '2')
        {
          strcpy(subHeadingLine, s);
          return;
        }
      strcpy(queue[linesInQueue++], s);
      for (i = 0; i < linesInQueue; i++)
        {
          if (LINE_COUNT == 0 || LINE_COUNT >= linesPerPage)
            {
              if (pageCount > 0)
                {
                  fprintf(fp, "\n\f");
                  fprintf(fp, "----------------------------------------");
                  fprintf(fp, "----------------------------------------");
                  fprintf(fp, "----------------------------------------");
                  fprintf(fp, "------------------------------\n");
                  pendingNewline = 0;
                }
              pageCount++;
              LINE_COUNT = 0;
              if (strlen(headingLine) > 0)
                {
                  fprintf(fp, "%s     PAGE %d\n", headingLine, pageCount);
                  pendingNewline = 0;
                }
              else
                {
                  fprintf(fp, "PAGE %d\n", pageCount);
                  pendingNewline = 0;
                }
              LINE_COUNT++;
              if (strlen(subHeadingLine) > 0)
                {
                  printf("%s\n", subHeadingLine);
                  pendingNewline = 0;
                  LINE_COUNT++;
                }
              if (LINE_COUNT > 0)
                {
                  fprintf(fp, "\n");
                  pendingNewline = 0;
                  LINE_COUNT++;
                }
            }
          if (outUTF8)
            {
              char c, *s, *s0;
              for (s = s0 = uncontrol(queue[i]); *s != 0; s++)
                if (*s == '`' || *s == '~')
                  {
                    c = *s;
                    *s = 0;
                    if (s > s0)
                      {
                        fprintf(fp, "%s", s0);
                        pendingNewline = 1;
                      }
                    s0 = s + 1;
                    if (c == '`')
                      {
                        fprintf(fp, "¢");
                        pendingNewline = 1;
                      }
                    else if (c == '~')
                      {
                        fprintf(fp, "¬");
                        pendingNewline = 1;
                      }
                  }
              if (s > s0)
                {
                  fprintf(fp, "%s", s);
                  pendingNewline = 1;
                }
            }
          else
            {
              // There are circumstances (namely, when printing version codes
              // from templates retrieved from the template library) that
              // control codes which *apparently* were discarded by the
              // contemporary line printers appear in the string.  I have no
              // way to fully deal with these, given that they were in EBCDIC
              // while at this point we're working with an ASCII string, but
              // I can try:
              fprintf(fp, "%s", uncontrol(queue[i]));
              pendingNewline = 1;
            }
          if (i < linesInQueue - 1)
            {
              fprintf(fp, "\n");
              pendingNewline = 0;
              LINE_COUNT++;
            }
        }
    }
  else
    {
      if (DCB_OUTS[lun].pds)
        {
          // Output to a PDS is buffered until the stow operation by MONITOR(1).
          DCB_t *dcb = &DCB_OUTS[lun];
          int length = string->numBytes;
          if (dcb->bufferLength + length > PDS_BUFFER_SIZE)
            abend("Overflow of PDS buffer %d", lun);
          if (DCB_OUTS[lun].ebcdic)
            {
              strncpy(&dcb->buffer[dcb->bufferLength], string->bytes, length);
              dcb->bufferLength += length;
            }
          else
            dcb->bufferLength += sprintf(&dcb->buffer[dcb->bufferLength], "%s\n", s);
        }
      else
        {
          // Output to a sequential file is immediate.
          if (DCB_OUTS[lun].ebcdic)
            fwrite(string->bytes, string->numBytes, 1, fp);
          else
            fprintf(fp, "%s\n", uncontrol(s));
        }
      pendingNewline = 0;
    }
  fflush(fp);
}

#define MAX_INPUTS 128
//sbuf_t lastInput0 = "";
descriptor_t *
INPUT(uint32_t lun) {
  descriptor_t *returnValue = nextBuffer();
  int i;
  char *s, *ss;
  FILE *fp;
  if (lun >= DCB_MAX)
    abend("Input device number out of range: Device = %d", lun);
  lun = DCB_INS[lun].redirection;
  if (DCB_INS[lun].extra != NULL)
    {
      s = DCB_INS[lun].extra;
      DCB_INS[lun].extra = NULL;
      return cToDescriptor(returnValue, "%-80s", s);
    }
  fp = DCB_INS[lun].fp;
  if (fp == NULL)
    abend("Input file not open for reading: Device = %d", lun);
  s = returnValue->bytes;
  if (DCB_INS[lun].ebcdic)
    {
      returnValue->numBytes = fread(returnValue->bytes, 1, 80, fp);
      if (returnValue->numBytes > 0)
        while (returnValue->numBytes < 80)
          returnValue->bytes[returnValue->numBytes++] = 0x40;
    }
  else // ASCII
    {
      if (fgets(s, sizeof(returnValue->bytes), fp) == NULL) // End of file.
        {
          // McKeeman doesn't define how to detect an end-of-file on INPUT,
          // but sample program 6.18.4 detects it by finding an empty string.
          // XCOM certainly expects an empty return on INPUT(2) at the end of file.
          // XCOM seems to expect that INPUT will silently reject all cards
          // with a non-blank in column 1, but doesn't seem to care whether
          // it does that or not, so I don't.
          returnValue->numBytes = 0;
          return returnValue;
        }
      s[strcspn(s, "\r\n")] = 0; // Strip off carriage-returns and/or line-feeds.
      if (DCB_INS[lun].upperCase)
        {
          // Convert to upper case.
          for (ss = s; *ss; ss++)
            *ss = toupper(*ss);
        }
      // Fix U.S. cent and logical-NOT UTF-8.
      while (NULL != (ss = strstr(s, "\xC2\xA2")))
        {
          *ss = '`';
          memmove(ss+1, ss+2, strlen(ss+2) + 1);
        }
      while (NULL != (ss = strstr(s, "\xC2\xAC")))
        {
          *ss = '~';
          memmove(ss+1, ss+2, strlen(ss+2) + 1);
        }
      // Since input is expected to be arriving on punch-cards, we want to
      // pad all input lines to be at least 80 characters.  This isn't
      // normally significant, but for a legacy compiler like XCOM.xpl or
      // SKELETON.xpl it is.
      for (i = strlen(s); i < 80; i++)
        s[i] = ' ';
      s[i] = 0;
      returnValue->numBytes = strlen(s);
      for (s = returnValue->bytes; *s; s++)
        *s = asciiToEbcdic[*s];
    }
  return returnValue;
}

uint32_t
LENGTH(descriptor_t *s) {
  return s->numBytes;
}

/*
void
errorSUBSTR(descriptor_t *s, int32_t start, int32_t length)
{
  fflush(stdout);
  fprintf(stderr, "\nSUBSTR('%s', %d, %d) error\n",
          descriptorToAscii(s), start, length);
  exit(1); //***DEBUG***
}
*/

// From the way SUBSTR() is used in the LITDUMP module, it's clear
// that if ne2 is specified, then the function always returns exactly
// ne2 characters, padded with blanks if past the end of the input
// string.  I.e., ne2 is *not* the max number of characters to return.
// However, from the behavior in TRUNCATE() of the SYTDUMP module, it
// does appear that the string is shorter when ne < 0, though it's
// unclear exactly what the behavior is supposed to be then.
descriptor_t *
SUBSTR(descriptor_t *s, int32_t start, int32_t length) {
  descriptor_t *returnValue = nextBuffer();
  int len = s->numBytes - start, rawLength = length;
  if (start < 0 || len <= 0 || length <= 0) // Return empty string.
    return returnValue;
  if (start < 0)
    {
      start = 0;
      len = s->numBytes - start;
    }
  if (len < 0)
    len = 0;
  if (length > len)
    length = len;
  if (length > 0)
    {
      strncpy(returnValue->bytes, &s->bytes[start], length);
      returnValue->bytes[length] = 0;
      returnValue->numBytes = length;
    }
  while (length < rawLength) // Pad to the desired length.
    {
      returnValue->bytes[length++] = 0x40; // EBCDIC space.
      returnValue->bytes[length] = 0;
      returnValue->numBytes = length;
    }
  return returnValue;
}

descriptor_t *
SUBSTR2(descriptor_t *s, int32_t start) {
  return SUBSTR(s, start, s->numBytes - start);
}

uint8_t
BYTE0(uint32_t address) {
  return memory[address];
}

uint8_t
BYTE(descriptor_t *s, uint32_t index){
  if (index >= s->numBytes)
    {
      //fprintf(stderr, "BYTE retrieving past end of string (%d >= %d)\n",
      //                index, (int) strlen(s));
      //printBacktrace();
      return 0;
    }
  if (s->type == ddCHARACTER)
    {
      return s->bytes[index];
    }
  else // s->type == ddBIT
    return s->bytes[index];
}

uint8_t
BYTE1(descriptor_t *s) {
  return BYTE(s, 0);
}

uint8_t
BYTEliteral(char *s, uint32_t index) {
  if (index >= strlen(s))
    return 0;
  return s[index];
}

uint8_t
BYTE1literal(char *s) {
  return BYTEliteral(s, 0);
}

// `address` is the address of a string descriptor, including bit-strings.
// `index` is an index into the string data. `c` or `b` is the character or
// byte to write to memory.
void
lBYTEc(uint32_t address, int32_t index, char c) {
  uint32_t descriptor = getFIXED(address);
  address = (descriptor & 0xFFFFFF) + index;
  if (address >= FREE_LIMIT)
    abend("BYTE address out of range of memory");
  memory[address] = c;
}

void
lBYTEb(uint32_t address, int32_t index, uint8_t b) {
  uint32_t descriptor = getFIXED(address);
  address = (descriptor & 0xFFFFFF) + index;
  if (address >= FREE_LIMIT)
    abend("BYTE address out of range of memory");
  memory[address] = b;
}

/* Superseded now that descriptor_t has replaced bit_t
uint8_t
BYTE2(bit_t *b, uint32_t index) {
  if (index >= b->numBytes)
    return 0;
  return b->bytes[index];
}
*/

uint32_t
SHL(uint32_t value, uint32_t shift) {
  return value << shift;
}

uint32_t
SHR(uint32_t value, uint32_t shift) {
  return value >> shift;
}

// MONITOR functions.

void
MONITOR0(uint32_t dev) {
  if (dev >= DCB_MAX)
    return;
  dev = DCB_OUTS[dev].redirection;
  if (DCB_OUTS[dev].fp == NULL)
    return;
  fflush(DCB_OUTS[dev].fp);
  fclose(DCB_OUTS[dev].fp);
  DCB_OUTS[dev].fp = NULL;
}

uint32_t
MONITOR1(uint32_t dev, descriptor_t *name) {
  int lenFile, lenPart;
  int existed;
  char *path = NULL, *cname;
  DCB_t *dcb;
  if (dev >= DCB_MAX)
    abend("Output device number out of range: Device number = %d >= %d",
          dev, DCB_MAX);
  dev = DCB_OUTS[dev].redirection;
  dcb = &DCB_OUTS[dev];
  if (DCB_OUTS[dev].fp != NULL)
    {
      fflush(DCB_OUTS[dev].fp);
      fclose(DCB_OUTS[dev].fp);
      DCB_OUTS[dev].fp = NULL;
    }
  if (strlen(DCB_OUTS[dev].filename) == 0)
    abend("Attempt to use unassigned PDS file for output: Device number = %d", dev);
  lenFile = strlen(DCB_OUTS[dev].filename);
  //if (mkdir(DCB_OUTS[dev].filename, 0777) < 0)
  //  abend("Unable to create PDS; note that PDS is implemented as a folder: "
  //        "Device number %d, PDS = '%s'", dev, DCB_OUTS[dev].filename);
#ifdef __MINGW32__
  mkdir(DCB_OUTS[dev].filename);
#else
  mkdir(DCB_OUTS[dev].filename, 0777);
#endif
  lenPart = name->numBytes;
  cname = descriptorToAscii(name);
  for (; lenPart > 0 && isspace(cname[lenPart - 1]); cname[--lenPart] = 0);
  if (lenPart < 1 || lenPart > PDS_MEMBER_SIZE)
    abend("PDS partitions must have names from 1-8 characters long: "
          "Device number %d, PDS = '%s', part = '%s'",
          dev, DCB_OUTS[dev].filename, cname);
  path = malloc(lenFile + lenPart + 2);
  if (path == NULL)
    abend("Out of memory in MONITOR(1)");
  sprintf(path, "%s/%s", DCB_OUTS[dev].filename, cname);
  strcpy(DCB_OUTS[dev].member, cname);
  existed = DCB_OUTS[dev].existed;
  DCB_OUTS[dev].existed = (access(path, F_OK) == 0); // Partition already exists?
  DCB_OUTS[dev].fp = fopen(path, DCB_OUTS[dev].fileFlags);
  free(path);
  if (DCB_OUTS[dev].fp == NULL)
    abend("Cannot open PDS partition for OUTPUT: Device number %d, PDS = '%s'",
          dev, DCB_OUTS[dev].filename);
  if (dcb->bufferLength > 0)
    {
      int numRecords = (dcb->bufferLength + PDS_RECORD_SIZE - 1) / PDS_RECORD_SIZE;
      if (numRecords != fwrite(dcb->buffer, PDS_RECORD_SIZE, numRecords, DCB_OUTS[dev].fp))
        abend("PDS write error to PDS %s member %s on device %d",
              DCB_OUTS[dev].filename, cname, dev);
    }
  dcb->bufferLength = 0;
  fflush(DCB_OUTS[dev].fp);
  fclose(DCB_OUTS[dev].fp);
  DCB_OUTS[dev].fp = NULL;
  return existed;
}

uint32_t
MONITOR2(uint32_t dev, descriptor_t *name) {
  int lenFile, lenPart, i;
  char *path = NULL, *cname;
  if (dev >= DCB_MAX)
    abend("Input device number out of range: Device number %d >= %d", dev, DCB_MAX);
  dev = DCB_INS[dev].redirection;
  if (DCB_INS[dev].fp != NULL)
    {
      fclose(DCB_INS[dev].fp);
      DCB_INS[dev].fp = NULL;
    }
  if (strlen(DCB_INS[dev].filename) == 0)
    abend("Attempt to use unassigned PDS file for input: Device number %d", dev);
  lenFile = strlen(DCB_INS[dev].filename);
  lenPart = name->numBytes;
  cname = descriptorToAscii(name);
  for (; lenPart > 0 && isspace(cname[lenPart - 1]); cname[--lenPart] = 0);
  if (lenPart < 1 || lenPart > PDS_MEMBER_SIZE)
    abend("PDS partitions must have names from 1-8 characters long: "
          "Device number %d, PDS = '%s', part = '%s'",
          dev, DCB_INS[dev].filename, cname);
  path = malloc(lenFile + lenPart + 2);
  if (path == NULL)
    abend("Out of memory in MONITOR(2)");
  sprintf(path, "%s/%s", DCB_INS[dev].filename, cname);
  strcpy(DCB_INS[dev].member, cname);
  DCB_INS[dev].fp = fopen(path, DCB_INS[dev].fileFlags);
  free(path);
  if (DCB_INS[dev].fp == NULL)
    {
      return 1;
    }
  return 0;
}

void
MONITOR3(uint32_t dev) {
  if (dev >= DCB_MAX)
    return;
  dev = DCB_INS[dev].redirection;
  if (DCB_INS[dev].fp == NULL)
    return;
  fclose(DCB_INS[dev].fp);
  DCB_INS[dev].fp = NULL;
}

void
MONITOR4(uint32_t dev, uint32_t recsize) {
  if (dev >= MAX_RANDOM_ACCESS_FILES)
    abend("Device number for FILE() too large");
  randomAccessFiles[OUTPUT_RANDOM_ACCESS][dev].recordSize = recsize;
}

int dwAddress = -1;
void
MONITOR5(int32_t address) {
  if (address < 0 || address >= MEMORY_SIZE - 14 * 4)
    abend("MONITOR(5) address overflows physical memory");
  dwAddress = address;
}

// Memory management via MONITOR 6, 7, and 21 is so simple-minded that it's
// practically brain-dead.  `allocations` is a list of dope vectors for
// which allocations have been made.  They are arranged so that the allocated
// blocks are in ascending order.  There are no gaps.  If a block needs
// to be grown or shrunk, then all of the blocks above it are pushed up or
// down.  Searches are linear.  Efficient?  No!  Will anyone ever notice?  No!
// (I think.)

allocation_t allocations[MAX_ALLOCATIONS] = { { 0 } };
uint32_t numAllocations = 0;

// A function for debugging.
void
printAllocations(void) {
  int i;
  fprintf(stderr, "%d/%d blocks allocated.\n", numAllocations, MAX_ALLOCATIONS);
  for (i = 0; i < numAllocations; i++)
    fprintf(stderr, "\t%06X %06X %06X (%06X)\n", allocations[i].based,
                           allocations[i].address,
                           allocations[i].address + allocations[i].size - 1,
                           allocations[i].size);
}

uint32_t
MONITOR6a(uint32_t based, uint32_t n, int clear) {
  allocation_t *f;
  int found, i, remaining = MONITOR21(), used = sizeof(memory) - remaining;
  int newAddress;

  //fprintf(stderr, "MONITOR(6, 0x%06X, 0x%06X)\n", based, n); // ***DEBUG***
  //printAllocations();

  if (remaining < n)
    {
      abend("MONITOR(6, 0x%06X, 0x%06X) failed", based, n);
      return 1;
    }
  for (found = 0; found < numAllocations; found++)
    if (allocations[found].based == based)
      break;

  f = &allocations[found];
  if (found == numAllocations)
    {
      // We're going to need to allocate a new block.  Can we?
      if (numAllocations >= MAX_ALLOCATIONS)
        {
          abend("MONITOR(6, 0x%06X, 0x%06X) failed", based, n);
          return 1; // No!
        }
      f->based = based;
      if (numAllocations == 0)
        newAddress = 0;
      else
        newAddress = allocations[found - 1].address + allocations[found - 1].size;
      f->address = newAddress;
      f->size = n;
      numAllocations++;
    }
  else
    {
      // We're going to be extending an existing block.
      for (i = found + 1; i < numAllocations; i++)
        allocations[i].address += n;
      f->size += n;
      newAddress = f->address + f->size;
    }
  // Make room for the new allocation and clear it.
  if (newAddress < used)
    memmove(&memory[newAddress + n], &memory[newAddress], used - newAddress);
  if (clear)
    memset(&memory[newAddress], 0, n);
  // Fix up the dope vector indicated by the function parameter.
  putFIXED(based, f->address);
  if (based >= memoryRegions[4].start && based <= memoryRegions[4].end)
    putFIXED(based + 8, f->size / COREHALFWORD(based + 4)); // # recs allocated.

  //printAllocations(); // ***DEBUG***
  return 0;
}

uint32_t
MONITOR6(uint32_t based, uint32_t n) {
  return MONITOR6a(based, n, 1);
}

uint32_t
MONITOR7(uint32_t based, uint32_t n) {
  int found, i, remaining = MONITOR21(), used = sizeof(memory) - remaining;

  //fprintf(stderr, "MONITOR(7, 0x%06X, 0x%06X)\n", based, n); // ***DEBUG***
  //printAllocations();

  // Find the associated block.
  for (i = 0, found = -1; i < numAllocations; i++)
    if (allocations[i].based == based)
      {
        found = i;
        break;
      }
  if (found == -1)
    {
      // None of the allocated blocks is associated with the given `based`.
      // There's another possibility, though, given the way actual code uses
      // `MONITOR(7)`, and that's that the address pointed to by `based` is
      // within an allocated block.  Let's check out that possibility.
      uint32_t address = getFIXED(based);
      for (i = 0; i < numAllocations; i++)
        {
          allocation_t *f;
          uint32_t end;
          f = &allocations[i];
          end = address + n;
          if (address >= f->address && end <= f->address + f->size)
            {
              found = i;
              break;
            }
        }
      if (found == -1)
        {
          abend("MONITOR(7, 0x%06X, 0x%06X) failed", based, n);
          return 1;
        }
    }
  if (allocations[found].size < n)
    return 1;
  i = allocations[found].address + allocations[found].size;
  memmove(&memory[i - n], &memory[i], used - i);
  allocations[found].size -= n;
  for (i = found + 1; i < numAllocations; i++)
    allocations[i].address -= n;

  //printAllocations(); // ***DEBUG***
  return 0;
}

void
MONITOR8(uint32_t dev, uint32_t filenum) {
  if (dev >= DCB_MAX)
    abend("Device number in MONITOR(8, 0x%X, 0x%X) is out of range", dev, filenum);
  if ((filenum & 0xFF) >= DCB_MAX)
    abend("File number in MONITOR(8, 0x%X, 0x%X) is out of range", dev, filenum);
  if (0 != (filenum & ~0xFF))
    DCB_OUTS[dev].redirection = filenum & 0xFF;
  else
    DCB_INS[dev].redirection = filenum;
}

//----------------------------------------------------------------------------
// For conversion to/from IBM hexadecimal floating point

#define twoTo56 (1LL << 56)
#define twoTo52 (1LL << 52)

// Convert a integer or floating point to IBM double-precision float.
// Returns as a pair (msw,lsw), each of which are 32-bit integers,
// or (0xff000000,0x00000000) on error.
void
toFloatIBM(uint32_t *msw, uint32_t *lsw, double d) {
  int s; // The sign: 1 if negative, 0 if non-negative.
  int e; // Exponent.
  uint64_t f;
  if (d == 0)
    {
      *msw = 0x00000000;
      *lsw = 0x00000000;
      return;
    }
  // Make x positive but preserve the sign as a bit flag.
  if (d < 0)
    {
      s = 1;
      d = -d;
    }
  else
      s = 0;
  // Shift left by 24 bits.
  d *= twoTo56;
  // Find the exponent (biased by 64) as a power of 16:
  e = 64;
  while (d < twoTo52)
    {
      e -= 1;
      d *= 16;
    }
  while (d >= twoTo56)
    {
      e += 1;
      d /= 16;
    }
  if (e < 0)
      e = 0;
  if (e > 127)
    {
      *msw = 0xff000000;
      *lsw = 0x00000000;
      return;
    }
  // x should now be in the right range, so lets just turn it into an integer.
  f = llround(d);
  // Convert to a more-significant and less-significant 32-word:
  *msw = (s << 31) | (e << 24) | ((f >> 32) & 0xffffffff);
  *lsw = f & 0xffffffff;
  return;
}

// Inverse of toFloatIBM(): Converts more-significant and less-significant
// 32-bit words of an IBM DP float to a C double.
double
fromFloatIBM(uint32_t msw, uint32_t lsw) {
    int s; // sign
    int e; // exponent
    long long int f;
    double x;
    s = (msw >> 31) & 1;
    e = ((msw >> 24) & 0x7f) - 64;
    f = ((msw & 0x00ffffffLL) << 32) | (lsw & 0xffffffff);
    x = f * pow(16, e) / twoTo56;
    if (s != 0)
        x = -x;
    return x;
}

//----------------------------------------------------------------------------

uint32_t
MONITOR9(uint32_t op) {
  /*
   * This is a bit confusing, so let me try to summarize my understanding of
   * it.  There are no built-in floating-point operations in XPL nor
   * (apparently) in the 360 CPU, so they're handled in a roundabout way via
   * the MONITOR(5,...) and MONITOR(9,...) calls.  MONITOR(5) sets up a
   * working array in which to hold floating-point operands and results.
   * The values are stored in IBM DP floating-point format, each of which
   * requires two 32-bit words, one for the most-significant part and one for
   * the less-significant part.  The first two entries in the working area
   * specified by MONITOR(5) comprise operand0 (and the result), while the
   * second two entries comprise operand1 (if needed).
   *
   * Although the result of the operation is placed in DW[0],DW[1], I believe
   * that a side effect is that it's also left in IBM 360 CPU floating-point
   * register FR0.
   */
  double operand0, operand1;
  uint32_t msw, lsw, address;
  if (dwAddress == -1)
    abend("No CALL MONITOR(5) prior to CALL MONITOR(9)");
  address = dwAddress;
  // Get operands from the defined working area, and convert them
  // from IBM floating point to Python floats.
  operand0 = fromFloatIBM(getFIXED(address), getFIXED(address + 4));
  if (op < 6)
    operand1 = fromFloatIBM(getFIXED(address + 8), getFIXED(address + 12));
  // Perform the binary operations.
  if (op == 1)
    operand0 += operand1;
  else if (op == 2)
    operand0 -= operand1;
  else if (op == 3)
    operand0 *= operand1;
  else if (op == 4)
    {
      if (operand1 == 0)
        abend("Floating-point divide by zero");
      operand0 /= operand1;
    }
  else if (op == 5)
    {
      if (operand0 == 0 && operand1 == 0)
        abend("Zero to the power zero");
      operand0 = pow(operand0, operand1);
    }
  /*
   * Or perform the unary operations, which are all trig functions.
   * Unfortunately, the documentation doesn't specify the angular
   * units.  I assume they're radians.
   */
  else if (op == 6)
    operand0 = sin(operand0);
  else if (op == 7)
    operand0 = cos(operand0);
  else if (op == 8)
    operand0 = tan(operand0);
  else if (op == 9)
    operand0 = exp(operand0);
  else if (op == 10)
    operand0 = log(operand0);
  else if (op == 11)
    operand0 = sqrt(operand0);
  else
    return 1;
  // Convert the result back to IBM floats, and store in working area.
  FR[0] = operand0;
  toFloatIBM(&msw, &lsw, operand0);
  putFIXED(address, msw);
  putFIXED(address + 4, lsw);
  return 0;
}

uint32_t
MONITOR10(descriptor_t *fpstring) {
  char *s;
  uint32_t msw, lsw, address;
  if (dwAddress == -1)
    abend("Needed CALL MONITOR(5) prior to CALL MONITOR(10)");
  address = dwAddress;
  s = descriptorToAscii(fpstring);
  FR[0] = atof(s);
  toFloatIBM(&msw, &lsw, FR[0]);
  putFIXED(address, msw);
  putFIXED(address + 4, lsw);
  return 0;
}

void
MONITOR11(void) {
  // A No-op, supposedly.
  abend("Unsupported MONITOR(11)");
}

descriptor_t *
MONITOR12(uint32_t precision) {
  double value;
  char *fpFormat;
  sbuf_t s;
  char *ss;
  uint32_t address;
  if (dwAddress == -1)
    abend("CALL MONITOR(5) must precede CALL MONITOR(12)");
  address = dwAddress;
  value = fromFloatIBM(getFIXED(address), getFIXED(address + 4));
  /*
   * The "standard" HAL format for floating-point numbers is described on
   * p. 8-3 of "Programming in HAL/S", though unfortunately the number of
   * significant digits provided for SP vs DP is not specified and is simply
   * said to be implementation dependent.  To summarize the format:
   *     0.0:        Printed as " 0.0" (notice the leading space)
   *     Positive:   Printed as " d.ddd...E±ee"
   *     Negative:   Printed as "-d.ddd...E±ee"
   * Given that 2**24 = 16777216 (8 digits) and 2**56 = 72057594037927936
   * (17 digits), it should be the case that SP and DP are *fully* accurate
   * only to 7 digits and 16 digits respectively.  Moreover, there is always
   * exactly 1 digit (non-zero) to the left of the decimal point.  Therefore,
   * for SP and DP, it would be reasonable to have 6 and 15 digits to the
   * right of the decimal point respectively.
   */
  if (value == 0.0)
    return cToDescriptor(NULL, " 0.0");
  if (precision == 0)
    fpFormat = "%+2.6e";
  else
    fpFormat = "%+2.15e";
  sprintf(s, fpFormat, value);
  if (s[0] == '+')
    s[0] = ' ';
  ss = strstr(s, "e");
  if (ss != NULL)
    *ss = 'E';
  return asciiToDescriptor(s);
}

void
stripEol(char *s) {
  for (; *s; s++)
    if (*s == '\r' || *s == '\n')
      {
        *s = 0;
        return;
      }
}

optionsProcessor_t *USEROPT = NULL;
uint32_t
MONITOR13(descriptor_t *namep) {
  // First get rid of trailing spaces in the `name`.
  char *s, *name = descriptorToAscii(namep);
  FILE *f;

  for (s = name; *s != 0 && !isspace(*s); s++);
  *s = 0;
  if (strlen(name) == 0)
    {
      // In this case, reload the last set of parameters processed, which have
      // been saved in a file.
      f = fopen("monitor13.parms", "r");
      if (f == NULL)
        abend("File monitor13.parms not found for MONITOR(13, 0)");
      fgets(name, sizeof(sbuf_t), f);
      stripEol(name);
      fgets(parmField, sizeof(parmField), f);
      stripEol(parmField);
      fclose(f);
    }
  if (!strcmp(name, "COMPOPT"))
    {
#ifdef PFS
      optionsProcessor = &COMPOPT_PFS;
#elif defined(BFS)
      optionsProcessor = &COMPOPT_BFS;
#else
      abend("MONITOR(13, 'COMPOPT ') requires XCOM-I --cond=P or --cond=B.");
#endif
    }
  else if (!strcmp(name, "LISTOPT"))
    optionsProcessor = &LISTOPT;
  else if (!strcmp(name, "MONOPT"))
    optionsProcessor = &MONOPT;
  else if (!strcmp(name, "USEROPT"))
    {
      if (USEROPT == NULL)
        abend("No options processor named USEROPT has been provided");
      optionsProcessor = USEROPT;
    }
  else
    abend("Unrecognized options processor for MONITOR(13): "
          "Options processor '%s'", name);
  parseParmField(0);
  // Save the parameters in a file.
  f = fopen("monitor13.parms", "w");
  fprintf(f, "%s\n", name);
  fprintf(f, "%s\n", parmField);
  fclose(f);
  return WHERE_MONITOR_13;
}

uint32_t
MONITOR14(uint32_t n, uint32_t a) {
  abend("MONITOR(14) not yet implemented");
  return 0; // `abend` doesn't return; this just avoids a compiler complaint.
}

uint32_t
MONITOR15(void) {
  fflush(stdout);
  fprintf(stderr, "FYI: MONITOR(15) only partially implemented\n");
  fflush(stderr);
  return 0xF0F00000;
}

uint32_t flags16;
void
MONITOR16(uint32_t n) {
  if (0 != (0x80000000 & n))
    flags16 |= n & 0x7FFFFFFF;
  else
    flags16 = n;
}

// I don't know what this is supposed to be used for yet.
char *programNamePassedToMonitor = "";
void
MONITOR17(descriptor_t *name) {
  programNamePassedToMonitor = descriptorToAscii(name);
}

uint32_t
MONITOR18(void) {
  struct timeval currentTime;
  gettimeofday(&currentTime, NULL);
  return (1000000 * (currentTime.tv_sec - startTime.tv_sec) +
               currentTime.tv_usec - startTime.tv_usec) / 10000;
}

uint32_t
MONITOR19(uint32_t *addresses, uint32_t *sizes) {
  abend("MONITOR(19) not yet implemented");
  return 0; // `abend` doesn't return; this just avoids a compiler complaint.
}

void
MONITOR20(uint32_t *addresses, uint32_t *sizes) {
  abend("MONITOR(20) not yet implemented");
}

uint32_t
MONITOR21(void) {
  allocation_t *last;
  int used;
  if (numAllocations == 0)
    used = 0;
  else
    used = allocations[numAllocations - 1].address +
           allocations[numAllocations - 1].size;
  return sizeof(memory) - used;
}

uint32_t
MONITOR22(uint32_t n1) {
  static int notShownYet = 1;
  if (notShownYet)
    {
      notShownYet = 0;
      fflush(stdout);
      fprintf(stderr, "\nFYI: MONITOR(22,n) not yet implemented\n");
      fflush(stderr);
    }
  return 0;
}

uint32_t
MONITOR22A(uint32_t n2) {
  static int notShownYet = 1;
  if (notShownYet)
    {
      notShownYet = 0;
      fflush(stdout);
      fprintf(stderr, "FYI: MONITOR(22,0,n) not yet implemented\n");
      fflush(stderr);
    }
  return 0;
}

descriptor_t *
MONITOR23(void) {
  return getCHARACTER(WHERE_MONITOR_23);
}

int32_t fileNumber31 = 2;
void
MONITOR31(int32_t n, int32_t recnum) {
  if (recnum < 0)
    {
      if (n > 0)
        fileNumber31 = n; // Set default file number.
      else
        return; // Wait for read operation to complete ... no need, it's complete!
    }
  else
    {
      if (n < 0) // Wait for read operation to complete ... no need, it's complete!
        n &= 0x00FFFFFF;
      rFILE(n, fileNumber31, recnum);
    }
}

uint32_t
MONITOR32(void) {
  return 4096; // From OS/VS2.
}

#if 0

// Reduced (1-second only) precision.
uint32_t
TIME(void) {
  time_t t = time(NULL);
  struct tm *timeStruct = gmtime(&t);
  return timeStruct->tm_hour * 360000 +
         timeStruct->tm_min * 6000 +
         timeStruct->tm_sec * 100;
}

#else

// Centisecond precision (as specified in McKeeman).
uint32_t
TIME(void) {
  struct timeval tv;
  time_t t;
  gettimeofday(&tv, NULL);
  t = tv.tv_sec;
  struct tm *timeStruct = localtime(&t);
  return timeStruct->tm_hour * 360000 +
         timeStruct->tm_min  * 6000 +
         timeStruct->tm_sec  * 100 +
         tv.tv_usec / 10000;
}

#endif

// See comment for `yisleap` below.
uint32_t
DATE(void) {
  time_t t = time(NULL);
  struct tm *timeStruct = localtime(&t);
  return 1000 * timeStruct->tm_year + (timeStruct->tm_yday + 1);
}

#if 0
  // Because I'm lazy, `yisleap` and `get_yday` came directly from the web, as-is:
  // https://stackoverflow.com/questions/19377396/c-get-day-of-year-from-date.
  // Note that it considers January 1 to be day 1, whereas `gmtime` computes
  // it as 0.  McKeeman doesn't document it, but I notice that HAL/S-FC is one
  // day off if 0 is used, so I leave it at 1.
  int yisleap(int year)
  {
      return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
  int get_yday(int mon, int day, int year)
  {
      static const int days[2][13] = {
          {0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334},
          {0, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335}
      };
      int leap = yisleap(year);

      return days[leap][mon] + day;
  }

  static char *Mmms[13] = {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
                           "Aug", "Sep", "Oct", "Nov", "Dec"};
  uint32_t
  DATE_OF_GENERATION(void) {
    char Mmm[4];
    int mm, dd, yyyy, dayOfYear;
    int n;
    sscanf(__DATE__, "%s %d %d", Mmm, &dd, &yyyy);
    for (mm = 1; mm < 13; mm++)
      if (!strcmp(Mmm, Mmms[mm]))
        break;
    dayOfYear = get_yday(mm, dd, yyyy);
    return 1000 * (yyyy - 1900) + dayOfYear;
  }

  uint32_t
  TIME_OF_GENERATION(void) {
    int h, m, s;
    sscanf(__TIME__, "%d:%d:%d", &h, &m, &s);
    return 360000 * h + 6000 * m + 100 * s;
  }
#else
  uint32_t
  DATE_OF_GENERATION(void) {
    return XCOM_I_START_DATE;
  }

  uint32_t
  TIME_OF_GENERATION(void) {
    return XCOM_I_START_TIME;
  }
#endif

uint32_t
COREBYTE(uint32_t address) {
  if (address + 1 <= MEMORY_SIZE)
    return memory[address];
  abend("COREBYTE read address overflows memory");
  return 0;
}

void
COREBYTE2(uint32_t address, uint32_t value) {
  if (address + 1 <= MEMORY_SIZE)
    {
      memory[address] = value & 0xFF;
      return;
    }
  abend("COREBYTE write address overflows memory");
}

uint32_t
COREWORD(uint32_t address) {
  if (address + 4 <= MEMORY_SIZE)
    return getFIXED(address);
  abend("COREWORD read address overflows memory");
  return 0;
}

void
COREWORD2(uint32_t address, uint32_t value) {
  if (address + 4 <= MEMORY_SIZE)
    {
      putFIXED(address, value);
      return;
    }
  abend("COREWORD write address overflows memory");
}

int16_t
COREHALFWORD(uint32_t address) {
  if (address + 2 <= MEMORY_SIZE)
    return (memory[address] << 8) | memory[address + 1];
  abend("COREHALFWORD read address overflows memory");
  return 0;
}

void
COREHALFWORD2(uint32_t address, int32_t value) {
  if (address + 2 <= MEMORY_SIZE)
    {
      memory[address] = (value >> 8) & 0xFF;
      memory[address + 1] = value & 0xFF;
      return;
    }
  abend("COREHALFWORD write address overflows memory");
}

// Like `rawADDR` except that it aborts upon error.
uint32_t
ADDR(char *bVar, int32_t bIndex, char *fVar, int32_t fIndex) {
  int address = rawADDR(bVar, bIndex, fVar, fIndex);
  if (address == -1)
    abend("ADDR() not found for BASED: bVar=%s, bIndex=%d, fVar=%s, fIndex=%d",
          bVar, bIndex, fVar, fIndex);
  if (address == -2)
    abend("Could not find the specified BASED variable field: "
          "bVar=%s, bIndex=%d, fVar=%s, fIndex=%d",
          bVar, bIndex, fVar, fIndex);
  if (address == -3)
    {
      // This could have been a lookup of a LABEL, supporting an INLINE.  If so,
      // it's not an error.
      char *label = bsearch(&fVar, mangledLabels, NUM_MANGLED, sizeof(char *),
                            cmpString);
      if (label != NULL)
        {
          //fprintf(stderr, "FYI: Lookup ADDR(%s)\n", fVar);
          return 0;
        }
      abend("ADDR() not found: bVar=%s, bIndex=%d, fVar=%s, fIndex=%d",
            bVar, bIndex, fVar, fIndex);
    }
  return address;
}

// Returns the address, or else a negative number upon error.
int rawADDR(char *bVar, int32_t bIndex, char *fVar, int32_t fIndex) {
  if (bVar != NULL) // BASED variable.
    {
      int i, j;
      uint32_t address;
      const basedField_t *basedField;
      //if (bVar != NULL && fVar != NULL && !strcmp(bVar, "MACRO_TEXTS"))
      //  fprintf(stderr, "\n***DEBUG***\n");
      foundRawADDR = lookupVariable(bVar);
      if (foundRawADDR == NULL)
        return -1;
      if (bIndex == 0x80000000 && (fVar == NULL || *fVar == 0) && fIndex == 0) {
          // This special case returns just the address of a BASED
          // variable's pointer to the beginning of its memory
          // allocation.
          return foundRawADDR->address;
      }
      address = getFIXED(foundRawADDR->address);       // -> beginning of alloc.
      address += bIndex * foundRawADDR->recordSize;    // -> beginning of record.
      if (fVar == NULL || *fVar == 0 || !strcmp(fVar, "(blank)")) // No field specified.
        return address;
      // Look for the specific field in the record (and the specific
      // index into it), to update the address and return it.
      for (i = 0, basedField = foundRawADDR->basedFields;
           i < foundRawADDR->numFieldsInRecord;
           i++, basedField++)
        {
          int numElements = basedField->numElements;
          if (numElements == 0)
            numElements = 1;
          if (!strcmp(fVar, basedField->symbol))
            {
              if (fIndex >= numElements)
                break;
              address += basedField->dirWidth * fIndex;
              return address;
            }
          else
            address += basedField->dirWidth * numElements;
        }
      return -2;
    }
  else
    {

      foundRawADDR = lookupVariable(fVar);
      if (foundRawADDR == NULL)
        return -3;
      return foundRawADDR->address + foundRawADDR->dirWidth * fIndex;
    }
}

// The `FILE` built-in.  There are two versions, one for the RHS of assignments
// (`rFILE`) and one for the LHS of assignments (`lFILE`).  McKeeman isn't
// clear on how flexible statements like
//      buffer = FILE(i, j);
//      FILE(i, j) = buffer;
// Can there be multiple buffers on the LHS?  What are the constraints on
// `buffer`?  For example, could we use `FILE` to load the test data into a
// `CHARACTER`?  Having looked though the available XPL and XPL/I source code,
// I'm going to assume that only these two simplistic forms
// can be used (i.e., that there can be only a single buffer on the LHS).
// It further appears to me that the `buffer` is always one of the following:
//      A subscripted BIT(8), BIT(16), BIT(32), or FIXED
// or
//      A BASED variable, presumably with no CHARACTER fields
// So I assume that the data is always transferred to/from `ADDR(buffer)` for
// a non-based variable, or `ADDR(buffer(0))` (i.e., `getFIXED(ADDR(buffer))`)
// for a BASED variable. The determination of BASED vs non-BASED cannot be
// made by the `lFILE` and `rFILE` functions, and must be made by the calling
// software to provide the correct address for `buffer`.

void
lFILE(uint32_t fileNumber, uint32_t recordNumber, uint32_t address)
{
  FILE *fp;
  int position, returnedValue, recordSize;
  if (fileNumber < 1 || fileNumber >= MAX_RANDOM_ACCESS_FILES)
    abend("Bad FILE number (%d)", fileNumber);
  fp = randomAccessFiles[OUTPUT_RANDOM_ACCESS][fileNumber].fp;
  recordSize = randomAccessFiles[OUTPUT_RANDOM_ACCESS][fileNumber].recordSize;
  position = recordSize * recordNumber;
  if (fp == NULL)
    abend("FILE %d not open for writing", fileNumber);
  if (fseek(fp, position, SEEK_SET) < 0)
    abend("Cannot seek to specified offset in FILE %d", fileNumber);
  returnedValue = fwrite(&memory[address], recordSize, 1, fp);
  fflush(fp);
  if (returnedValue != 1)
    abend("Failed to write enough bytes to FILE %d", fileNumber);
}

void
rFILE(uint32_t address, uint32_t fileNumber, uint32_t recordNumber)
{
  FILE *fp;
  int position, returnedValue, recordSize;
  if (fileNumber < 1 || fileNumber >= MAX_RANDOM_ACCESS_FILES)
    abend("Bad FILE number (%d)", fileNumber);
  fp = randomAccessFiles[OUTPUT_RANDOM_ACCESS][fileNumber].fp;
  recordSize = randomAccessFiles[OUTPUT_RANDOM_ACCESS][fileNumber].recordSize;
  position = recordSize * recordNumber;
  if (fp == NULL)
    abend("FILE %d not open for reading", fileNumber);
  if (fseek(fp, position, SEEK_SET) < 0)
    abend("Cannot seek to specified offset in FILE %d", fileNumber);
  returnedValue = fread(&memory[address], recordSize, 1, fp);
  if (returnedValue != 1)
    abend("Failed to read desired number of bytes from FILE %d", fileNumber);
}

void
bFILE(uint32_t devL, uint32_t recL, uint32_t devR, uint32_t recR) {
  static uint8_t *buffer = NULL;
  static int bufSize = 0;
  FILE *fpR, *fpL;
  int returnedValue, recsizeL, recsizeR, posL, posR, recsize;
  if (devL < 1 || devL >= MAX_RANDOM_ACCESS_FILES)
    abend("Bad left-hand FILE number %d", devL);
  if (devR < 1 || devR >= MAX_RANDOM_ACCESS_FILES)
    abend("Bad right-hand FILE number %d", devR);
  fpL = randomAccessFiles[OUTPUT_RANDOM_ACCESS][devL].fp;
  fpR = randomAccessFiles[OUTPUT_RANDOM_ACCESS][devR].fp;
  recsizeL = randomAccessFiles[OUTPUT_RANDOM_ACCESS][devL].recordSize;
  recsizeR = randomAccessFiles[OUTPUT_RANDOM_ACCESS][devR].recordSize;
  posL = recsizeL * recL;
  posR = recsizeR * recR;
  if (fpL == NULL)
    abend("Left-hand FILE %d not open for writing", devL);
  if (fpR == NULL)
    abend("Right-hand FILE %d not open for reading", devR);
  if (fseek(fpL, posL, SEEK_SET) < 0)
    abend("Cannot seek to desired offset in left-hand FILE %d", devL);
  if (fseek(fpR, posR, SEEK_SET) < 0)
    abend("Cannot seek to desired offset in right-hand FILE %d", devR);
  recsize = recsizeL;
  if (recsizeR > recsizeL)
    recsize = recsizeR;
  if (recsize < bufSize)
    {
      free(buffer);
      buffer = calloc(1, recsize);
      bufSize = recsize;
    }
  returnedValue = fread(buffer, recsizeR, 1, fpR);
  if (returnedValue != 1)
    abend("Failed to read specified number of bytes from FILE %d", devR);
  returnedValue = fwrite(buffer, recsizeL, 1, fpL);
  fflush(fpL);
  if (returnedValue != 1)
    abend("Failed to write specified number of bytes to FILE %d", devL);
}

/*
void
RECORD_LINK(int reset) {
}
*/

// A function for comparing struct allocated_t objects (see COMPACTIFY below),
// for sorting them into order of increasing allocation address.
// `allocated_t` gives the characteristics of an object (string or record)
// allocated in free memory.
struct allocated_t {
  int saddress; // Address of allocation in free memory.
  int length; // Size of the allocation in free memory.
  int address; // Address of the associated variable in non-free memory.
  char *datatype; // Just for debugging.
  char *symbol; // Just for debugging.
  int index; // Just for debugging.
};
int
cmpAllocations(const void *e1, const void *e2)
{
  struct allocated_t *a1, *a2;
  a1 = (struct allocated_t *) e1;
  a2 = (struct allocated_t *) e2;
  return a1->saddress - a2->saddress;
}

/*
 * Format of a COMMON file:  A sequence of ASCII lines, each of which
 * consists of fields delimited by tabs.  The first field in each line
 * is a single character, interpreted as follows:
 *      ;       A comment, to be discarded upon reading the COMMON file.
 *      +       A non-BASED variable.
 *      /       A BASED variable.
 *      .       A field of the preceding BASED variable.
 *      :       Internal state of the XCOM-I runtime library.
 * Comment lines have only 2 fields (the leading ';' and the body of
 * the comment).  XCOM-I internal-state lines have the leading ':' and as
 * many fields as needed; presently, that's only the dwAddress.  All other
 * lines have 5 fields:
 *      1.      The leading character, described above.
 *      2.      The name of the variable or the field.  Note that a
 *              BASED variable *not* declared with a *RECORD* has a
 *              single field whose name is the empty string, whereas
 *              BASED RECORD variables have some number (presumably
 *              > 1) of fields whose names are *not* empty strings.
 *      3.      The array index of the variable or the field to be
 *              subscripted.  (If not subscripted, the index is 0.)
 *      4.      The datatype:  "FIXED", "BIT", "CHARACTER", or "BASED".
 *              The datatype of a BASED variable is always "BASED", while
 *              the datatype of a field of a BASED variable is always
 *              "FIXED", "BIT", or "CHARACTER.  Note that there is
 *              no other distinction between the treatment of "BIT" and
 *              "FIXED".
 *      5.      * For datatype "BASED":  For the *first* record of a BASED,
 *                the fields of the dope vector, in hexadecimal, separated by
 *                spaces (not tabs!).  Only a couple are really needed, I think,
 *                but I include them all in case I'm wrong.  For *subsequent*
 *                records, there's no reason to redundantly repeat the identical
 *                info, so this 5th field is just an empty string.
 *              * For "FIXED", the current value as a 4-digit hexadecimal number.
 *              * For "BIT", the bytes (in hexadecimal) from the descriptor_t object.
 *              * For "CHARACTER", a an ASCII string, delimited by single quotes.
 *                Note that the delimiters are merely for convenience of
 *                human-readability, and are discarded upon reading the
 *                COMMON file; the character string itself may contain
 *                single-quote characters or tab characters as-is without
 *                any special escaping or other trickery.
 * Note that fields (i.e., anything bracketed by tab characters) that would
 * otherwise be completely empty (i.e., just two adjacent tabs, or else tabs
 * adjacent to the line start or line end) are instead given as the literal
 * "(blank)" -- e.g. <tab>(blank)<tab>.  That's because it turns out that
 * if you try to use `scanf` with something like
 *      scanf("...\t%s\%t...", ..., s, ....)
 * it can't detect an empty string.
 * There is some redundancy among this data -- for example, there's
 * no real need for a datatype=BASED field when the leading field is
 * '+' -- but ... too bad!
 */

#ifndef STANDARD_XPL
// Writes just one "entry" from the `memoryMap` to the COMMON file.  However,
// the function is recursive in the sense that if the entry being written is
// from a `BASED` record, the function manufactures memoryMapEntry_t elements
// (from basedField_t elements) and then calls itself.
void
writeEntryCOMMON(FILE *fp, memoryMapEntry_t *entry, int isField, char *parent) {
  char prefix = isField ? '.' : '+', *datatype = entry->datatype,
       *symbol = entry->symbol;
  int i, numElements = entry->numElements, address = entry->address,
      dirWidth = entry->dirWidth, numFieldsInRecord = entry->numFieldsInRecord,
      common = entry->common, bitWidth = entry->bitWidth;
  const basedField_t *basedField;
  sbuf_t dopeVector;

  if (symbol == NULL || *symbol == 0)
    symbol = "(blank)";

#ifdef ORIGINAL_BASED_THINKING
  // A number of library variables are in COMMON, but I reject them.  Why?
  // The library is devoted to memory management, and its variables being in
  // COMMON is based on the false notion that the variables it is managing are
  // still in memory upon program start, in the same locations as for the
  // preceding program.  This is certainly not true in the modern
  // implementation.  But this is a kludge, since there's nothing to say that
  // the library couldn't have something other than memory management in it.
  if (!common || entry->library)
    return;
#else
  if (!common)
    return;
#endif

  if (!strcmp(datatype, "BASED"))
    {
      prefix = '/';
      sprintf(dopeVector, "%08X %04X %04X %08X %08X %08X %08X %04X %04X",
          i = COREWORD(address),
          dirWidth = COREHALFWORD(address + 4),
          COREHALFWORD(address + 6),
          COREWORD(address + 8),
          numElements = COREWORD(address + 12),
          COREWORD(address + 16),
          COREWORD(address + 20),
          COREHALFWORD(address + 24),
          COREHALFWORD(address + 26)
      );
      address = i;
      if (numElements == 0)
        {
          fprintf(fp, "%c\t%s\t%d\t%s\t", prefix, symbol, 0, datatype);
          fprintf(fp, "%s\n", dopeVector);
          strcpy(dopeVector, "(blank)");
          return;
        }
    }
  else
    {
      if (numElements == 0)
        numElements = 1;
    }
  if (numFieldsInRecord == 0)
    numFieldsInRecord = 1;

  for (i = 0; i < numElements; i++, address += dirWidth)
    {
      fprintf(fp, "%c\t%s\t%d\t%s\t", prefix, symbol, i, datatype);
      if (!strcmp(datatype, "BASED"))
        {
          int k;
          fprintf(fp, "%s\n", dopeVector);
          strcpy(dopeVector, "(blank)");
          for (k = 0, basedField = entry->basedFields;
               k < numFieldsInRecord;
               k++, basedField++)
            {
              // We have to manufacture a memoryMapEntry_t object for each
              // field, and then reenter `writeEntryCOMMON` to process that
              // field.
              memoryMapEntry_t field = { 0 };
              strcpy(field.symbol, basedField->symbol);
              field.address = address + basedField->offset;
              strcpy(field.datatype, basedField->datatype);
              field.numElements = basedField->numElements;
              field.dirWidth = basedField->dirWidth;
              field.bitWidth = basedField->bitWidth;
              field.common = 1;
              field.numFieldsInRecord = 0;
              field.basedFields = NULL;
              writeEntryCOMMON(fp, &field, 1, symbol);
            }
        }
      else if (!strcmp(datatype, "CHARACTER"))
        fprintf(fp, "'%s'\n", descriptorToAscii(getCHARACTER(address)));
      else if (!strcmp(datatype, "FIXED"))
          fprintf(fp, "%08X\n", getFIXED(address));
      else if (!strcmp(datatype, "BIT"))
        {
          descriptor_t *d = getBIT(bitWidth, address);
          int j;
          for (j = 0; j < d->numBytes; j++)
            fprintf(fp, "%02X", d->bytes[j]);
          fprintf(fp, "\n");
        }
      else if (isField)
        abend("Unknown datatype '%s' for field %s.'%s' in writeCOMMON", datatype, parent, symbol);
      else
        abend("Unknown datatype '%s' for symbol '%s' in writeCOMMON", datatype, symbol);
    }
}
#endif // STANDARD_XPL

// Write entire COMMON file.
int
writeCOMMON(FILE *fp) {
  if (fp == NULL)
    return 1;
#ifndef STANDARD_XPL
  int i;
  fprintf(fp, ":\t%d\n", dwAddress);
  for (i = 0; i < NUM_SYMBOLS; i++)
    writeEntryCOMMON(fp, &memoryMap[i], 0, "(root)");
#endif
  return 0;
}

int
readCOMMON(FILE *fp) {
#ifndef STANDARD_XPL
  int32_t _ALLOCATE_SPACE(int reset);
  char line[1024], prefix, svalue[sizeof(sbuf_t) + 100], *bVar;
  sbuf_t symbol, field, lastBased = "";
  int index, ivalue, fieldIndex, allocated, lastBasedIndex, bIndex,
      dopeVectorAddress;
  memoryMapEntry_t *basedMemoryMapEntry;
  descriptor_t *descriptor;

  // Read the COMMON file and process it line by line.
  while (NULL != fgets(line, sizeof(line), fp))
    {
      if (line[0] == ';') // A comment?
        continue;
      if (line[0] == ':') // Internal state?
        {
          if (1 == sscanf(line, ":\t%d", &dwAddress))
            continue;
          else
            abend("Unrecognized line in COMMON: %s", line);
        }
      if (3 == sscanf(line, "/\t%s\t%d\tBASED\t%[^\n\r]",
                      field, &fieldIndex, svalue))
        {
          int address, recordSize, ndescriptors, allocated, used,
              link, flags, globalFactor, groupFactor;
          svalue[strlen(svalue)] = 0;
          strcpy(lastBased, field);
          lastBasedIndex = fieldIndex;
          basedMemoryMapEntry = lookupVariable(lastBased);
          if (fieldIndex == 0)
            {
              dopeVectorAddress = ADDR(field, 0x80000000, 0, 0);
              if (9 != sscanf(svalue,
                            "%08X %04X %04X %08X %08X %08X %08X %04X %04X",
                            &address, &recordSize, &ndescriptors, &allocated,
                            &used, &link, &flags, &globalFactor, &groupFactor))
                abend("Mismatched COMMON: %s", line);
#ifdef ORIGINAL_BASED_THINKING
              if (allocated > 0)
                {
                  putFIXED(m_ALLOCATE_SPACExDOPE, dopeVectorAddress);
                  putFIXED(m_ALLOCATE_SPACExHIREC, allocated - 1);
                  _ALLOCATE_SPACE(0);
                }
              COREWORD2(dopeVectorAddress + 12, used);
              COREWORD2(dopeVectorAddress + 20, flags);
#else
              COREWORD2(dopeVectorAddress + 0, address);
              COREHALFWORD2(dopeVectorAddress + 4, recordSize);
              COREHALFWORD2(dopeVectorAddress + 6, ndescriptors);
              COREWORD2(dopeVectorAddress + 8, allocated);
              COREWORD2(dopeVectorAddress + 12, used);
              COREWORD2(dopeVectorAddress + 16, link);
              COREWORD2(dopeVectorAddress + 20, flags);
              COREHALFWORD2(dopeVectorAddress + 24, globalFactor);
              COREHALFWORD2(dopeVectorAddress + 26, groupFactor);
              if (freelimit > address - 512)
                freelimit = address - 512;
#endif
            }
          // Nothing else to do, since this line in the COMMON file is really
          // just a delimiter between the BASED's records.
          continue;
        }
      prefix = line[0];
      if (prefix == 0 || prefix == '\n' || prefix == '\r')
        continue;
      if (prefix == '+')
        {
          bVar = NULL;
          bIndex = 0;
        }
      else if (prefix == '.')
        {
          bVar = lastBased;
          bIndex = lastBasedIndex;
        }
      else
        abend("Unknown prefix in COMMON record: %s", line);
      if (4 == sscanf(line, "%c\t%s\t%d\tCHARACTER\t'%[^\n\r]",
                      &prefix, field, &fieldIndex, svalue))
        {
          svalue[strlen(svalue) - 1] = 0; // Get rid of trailing '
          if (!strcmp(field, "(blank)"))
            field[0] = 0;
          putCHARACTER(ADDR(bVar, bIndex, field, fieldIndex),
                       asciiToDescriptor(svalue));
        }
      else if (4 == sscanf(line, "%c\t%s\t%d\tFIXED\t%X",
                      &prefix, field, &fieldIndex, &ivalue))
        {
          if (!strcmp(field, "(blank)"))
            field[0] = 0;
          putFIXED(ADDR(bVar, bIndex, field, fieldIndex), ivalue);
        }
      else if (4 == sscanf(line, "%c\t%s\t%d\tBIT\t%[^\n\r]",
                      &prefix, field, &fieldIndex, svalue))
        {
          uint32_t address, numBytes, i;
          memoryMapEntry_t *memoryMapEntry;
          char *s, s3[3];
          if (!strcmp(field, "(blank)"))
            field[0] = 0;
          descriptor = nextBuffer();
          descriptor->type = ddBIT;
          descriptor->address = 0;
          address = ADDR(bVar, bIndex, field, fieldIndex);
          if (bVar == NULL)
            descriptor->bitWidth = lookupVariable(field)->bitWidth;
          else
            {
              basedField_t *basedField = basedMemoryMapEntry->basedFields;
              descriptor->bitWidth = 0;
              for (i = 0;
                   i < basedMemoryMapEntry->numFieldsInRecord;
                   i++, basedField++)
                if (!strcmp(field, basedField->symbol))
                  {
                    descriptor->bitWidth = basedField->bitWidth;
                    break;
                  }
              if (descriptor->bitWidth == 0)
                abend("In COMMON, %s.%s not found", bVar, field);
            }
          numBytes = (descriptor->bitWidth + 7) / 8;
          if (numBytes == 3)
            numBytes = 4;
          descriptor->numBytes = numBytes;
          if (2 * numBytes != strlen(svalue))
            abend("BIT width mismatch in COMMON %s", field);
          s3[2] = 0;
          for (i = 0, s = svalue; i < numBytes; i++)
            {
              s3[0] = *s++;
              s3[1] = *s++;
              descriptor->bytes[i] = strtol(s3, NULL, 16);
            }
          putBIT(descriptor->bitWidth, address, descriptor);
        }
    }
#endif // STANDARD_XPL
  return 0;
}

uint32_t
FREEPOINT(void) {
  return freepoint;
}

void
FREEPOINT2(uint32_t value) {
  freepoint = value;
}

void
TRACE(void) {
  // Intentionally empty.
}

void
UNTRACE(void) {
  // Intentionally empty.
}

uint32_t
FREELIMIT(void) {
  return freelimit;
}

/*
 * This is used by Intermetrics's `COMPACTIFY` to extend the upward limit of
 * free memory. However, that's meaningless in terms of how XCOM-I manages
 * memory, so I'm not sure what to do about it.
 */
void
FREELIMIT2(uint32_t address) {
  freelimit = address;
}

int32_t freeBase = FREE_BASE;
int32_t
FREEBASE(void) {
  return freeBase;
}

void
FREEBASE2(int32_t value) {
  freeBase = value;
}

void
EXIT(void) {
  OUTPUT(0, nextBuffer());
  exit(10);
}

void
LINK(void) {
#ifndef STANDARD_XPL
  writeCOMMON(COMMON_OUT);
#endif
  //OUTPUT(0, nextBuffer());
  //if (LINE_COUNT) printf("\n");
  exit(0);
}

descriptor_t *
PARM_FIELD(void) {
  return cToDescriptor(NULL, parmField);
}

uint32_t
DESCRIPTOR(uint32_t index) {
  return getFIXED(memoryRegions[3].start + 4 * index);
}

void
DESCRIPTOR2(uint32_t index, uint32_t descriptor) {
  putFIXED(memoryRegions[3].start + 4 * index, descriptor);
}

uint32_t
NDESCRIPT(void) {
  return (memoryRegions[3].end - memoryRegions[3].start) / 4;
}

int32_t
ABS(int32_t value) {
  if (value == 0x80000000)
    return 0x7FFFFFFF;
  else
    return abs(value);
}

uint32_t
XPL_COMPILER_VERSION(uint32_t index){
  if (index == 0)
    return MAJOR_VERSION;
  else if (index == 1)
    return MINOR_VERSION;
  abend("Bad index (%d) for XPL compiler version", index);
  return 0; // `abend` doesn't return; this just avoids a compiler complaint.
}

void
debugInline(int inlineCounter) {
  fprintf(stderr, "FYI: CALL INLINE %d\n", inlineCounter);
}

/*
 * The `guardReentry` function detects (surprise!) reentry of a procedure,
 * which is not allowed in XPL.  Use it like so:  Near the top of the procedure,
 * put this:
 *      static int reentryGuard = 0;
 *      reentryGuard = guardReentry(reentryGuard, "...function name...");
 * Wherever the procedure has a `return ...;`, replace it with
 *      { reentryGuard = 0; return ...; }
 * (Including at the ends of procedures with no explicit `return`.)
 * This code is added automatically in the C code generated by XCOM-I, but
 * needs to be added explicitly in patch files (always, for the `return`
 * statements) and in runtime-library functions (for functions that might
 * conceivably reenter).  The principal cause of worry was functions that
 * use `putCHARACTER`, which might call `COMPACTIFY`, which might fail, which
 * might try to use an error routine that uses `putCHARACTER`.  In fact, I
 * don't think this actually can occur, but that was my motivating concern.
 */
sbuf_t lastWatchFunction = "(Initial)";
int lastWatchValue = -1;
int
guardReentry(int reentryGuard, char *functionName) {
  if (reentryGuard)
    abend("Illegal reentry of function %s", functionName);
  if (watchpoint != -1)
    {
      uint8_t value = memory[watchpoint];
      if (value != lastWatchValue)
        fprintf(stderr, "\nWatchpoint (%d 0x%X) change: %d (%s) != %d (%s)\n",
                  watchpoint, watchpoint,
                  value, functionName, lastWatchValue, lastWatchFunction);
      lastWatchValue = value;
      strcpy(lastWatchFunction, functionName);
    }
  return 1;
}

int traceInlineEnable = 0;
int detailedInlineEnable = 0;
#ifdef TRACE_INLINES
void
traceInline(char *msg) {
  if (traceInlineEnable)
    {
      fprintf(stdout, "\nTrace INLINE: %s", msg);
      fflush(stdout);
    }
}

void
detailedInlineBefore(int inlineCounter, char *instruction) {
  if (detailedInlineEnable)
    {
      fprintf(stdout, "\n");
      fprintf(stdout, "\nCALL INLINE %d:", inlineCounter);
      detailedInlineAfter();
      fprintf(stdout, "\n\t\tExecute:\t\t%s", instruction);
      fflush(stdout);
    }
}

void
detailedInlineAfter(void) {
  int i, value;
  if (detailedInlineEnable)
    {
      for (i = 0; i < 16; i++)
        {
          if (0 == i % 4)
            fprintf(stdout, "\n");
          fprintf(stdout, "  GR%02d=%08X(%-11d)", i, GR[i], GR[i]);
        }
      for (i = 0; i < 16; i++)
        {
          if (0 == i % 4)
            fprintf(stdout, "\n");
          fprintf(stdout, "  FR%02d=%-21F", i, FR[i]);
        }
      fprintf(stdout, "\n");
      if (address360A >=0 && address360A <= 0x1000000-4)
        {
          value = COREWORD(address360A);
          fprintf(stdout, "  A=%06X (A)=%08X(%-11d)", address360A, value, value);
        }
      else
        fprintf(stdout, "  A=%06X (A)=%21s", address360A, "(out of range)");
      if (address360B >=0 && address360B <= 0x1000000-4)
        {
          value = COREWORD(address360B);
          fprintf(stdout, "  B=%06X (B)=%08X(%-11d)", address360B, value, value);
        }
      else
        fprintf(stdout, "  B=%06X (B)=%21s", address360B, "(out of range)");
      fprintf(stdout, "  CC=%d", CC);
      fflush(stdout);
    }
}
#endif // TRACE_INLINES

// Some test code.
#if 0
int outUTF8;
FILE *DCB_INS[DCB_MAX];
FILE *DCB_OUTS[DCB_MAX];
typedef char sbuf_t[MAX_XPL_STRING + 1];
uint8_t memory[MEMORY_SIZE];

int
main(void) {
  printf("%s\n", __DATE__);
  printf("%d %d\n", DATE(), DATE_OF_GENERATION());
  return 0;
}
#endif
