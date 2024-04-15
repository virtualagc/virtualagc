/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    runtimeC.c
 * Purpose:     This is runtime data and functions for the C code produced
 *              by the XPL/I-to-C translator XCOM-I.py.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-03-28 RSB  Began.
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
#include <sys/time.h> // For gettimeofday().

// `nextBuffer` is sort of a cut-rate memory-management system for builtins
// that return string values.  In order to avoid having to allocate new memory
// for such outputs, we instead maintain a circular array of string_t's, and
// each call to a builtin that returns a string simply uses the next string_t
// in that array.  The reason this is okay, is that functions returning strings
// are invoked only in the context of expressions, and the number of function
// calls an expression can make isn't very large, in a practical sense.
// So we can just make the circular array very large and not
// worry about it.  I hope.  (Not that allocating memory for the outputs of the
// builtins would be a problem, but there's no mechanism for freeing that
// memory afterward.)
#define MAX_BUFFS 1024
static char *
nextBuffer(void)
{
  static string_t buffers[MAX_BUFFS];
  static int currentBuffer;
  char *returnValue = buffers[currentBuffer++];
  if (currentBuffer >= MAX_BUFFS)
    currentBuffer = 0;
  *returnValue = 0;     // Clear the string.
  return returnValue;
}

// Global variables extern'd in runtimeC.h:
int outUTF8 = 0;
FILE *DD_INS[DD_MAX] = { NULL };
FILE *DD_OUTS[DD_MAX] = { NULL };
FILE *COMMON_OUT = NULL;

// Starting time of the program run, more or less.
struct timeval startTime;

// Memory-management stuff.
static uint32_t freepoint = FREE_POINT;

int
parseCommandLine(int argc, char **argv)
{
  int i, returnValue = 0;
  FILE *COMMON_IN = NULL;
  gettimeofday(&startTime, NULL);
  DD_INS[0] = DD_INS[1] = stdin;
  DD_OUTS[0] = DD_OUTS[1] = stdout;
  for (i = 1; i < argc; i++)
    {
      int lun;
      char filename[1024];
      if (!strcmp("--utf8", argv[i]))
        outUTF8 = 1;
      else if (2 == sscanf(argv[i], "--ddi=%d,%s", &lun, filename))
        {
          if (lun < 0 || lun >= DD_MAX)
            {
              fprintf(stderr, "Input logical unit number %d is out of range.\n",
                  lun);
              returnValue = -1;
            }
          else
            {
              DD_INS[lun] = fopen(filename, "r");
              if (DD_INS[lun] == NULL)
                {
                  fprintf(stderr, "Cannot open file %s for reading on unit %d\n",
                      filename, lun);
                  returnValue = -1;
                }
            }
        }
      else if (2 == sscanf(argv[i], "--ddo=%d,%s", &lun, filename))
        {
          if (lun < 0 || lun >= DD_MAX)
            {
              fprintf(stderr, "Output logical unit number %d is out of range.\n", lun);
              returnValue = -1;
            }
          else
            {
              DD_OUTS[lun] = fopen(filename, "w");
              if (DD_OUTS[lun] == NULL)
                {
                  fprintf(stderr, "Cannot create file %s for writing on unit %d\n",
                      filename, lun);
                  returnValue = -1;
                }
            }
        }
      else if (1 == sscanf(argv[i], "--commoni=%s", filename))
        {
          COMMON_IN = fopen(filename, "r");
          if (COMMON_IN == NULL)
            {
              fprintf(stderr, "Unable to open %s to read COMMON\n", filename);
              exit(1);
            }
        }
      else if (1 == sscanf(argv[i], "--commono=%s", filename))
        {
          COMMON_OUT = fopen(filename, "w");
          if (COMMON_OUT == NULL)
            {
              fprintf(stderr, "Unable to open %s to write COMMON\n", filename);
              exit(1);
            }
        }
      else if (!strcmp("--help", argv[i]))
        {
          printf("\n");
          printf("This is a C program created by translated by XCOM-I.py\n");
          printf("from source-code files in the XPL/I language.\n");
          printf("\n");
          printf("Usage:\n");
          printf("        %s [OPTIONS]\n", argv[0]);
          printf("\n");
          printf("The available OPTIONS are:\n");
          printf("--help      Displays this menu and then immediately exits.\n");
          printf("--utf8      By default, any non-ASCII symbols for the\n");
          printf("            U.S. cent sign and the logical-NOT symbol\n");
          printf("            are translated to the ASCII characters ` and ~\n");
          printf("            respectively, and will appear that way if\n");
          printf("            output when this program is run.  If that\n");
          printf("            is disturbing, you can try using the --utf8\n");
          printf("            to try outputs in UTF-8 encoding instead.\n");
          printf("--ddi=N,F   Attach filename F to the logical unit number\n");
          printf("            N, for use with the INPUT(N) XPL built-in.\n");
          printf("            By default, 0 and 1 are attached to stdin.\n");
          printf("            N can range from 0 through 9.\n");
          printf("--ddo=N,F   Attach filename F to the logical unit number\n");
          printf("            N, for use with the OUTPUT(N) XPL built-in.\n");
          printf("            By default, 0 and 1 are attached to stdout.\n");
          printf("            N can range from 0 through 9.\n");
          printf("--commoni=F Name of the file from which to read the\n");
          printf("            initial values for COMMON memory at startup.\n");
          printf("            By default, COMMON is not initialized.\n");
          printf("--commono=F Name of the file to which data from COMMON\n");
          printf("            is written upon program termination.  By\n");
          printf("            default, the file COMMON.out is used.\n");
          printf("\n");
          returnValue = 1;
        }
      else
        {
          printf("Unknown command-line switch %s. Try --help.\n", argv[i]);
          returnValue = -1;
        }
    }
  if (COMMON_IN != NULL)
    {
      if (NON_COMMON_BASE > COMMON_BASE)
        {
          int status = readCOMMON(COMMON_IN);
          if (status < 0)
            {
              fprintf(stderr, "Severe error reading COMMON.\n");
              exit(1);
            }
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
      fprintf(COMMON_OUT, ";\tSaved XPL COMMON block, generated by XCOM-I\n");
    }
  return returnValue;
}

int32_t
getFIXED(uint32_t address)
{
  int32_t value;
  // Convert from big-endian to native format.
  value = memory[address++];
  value = (value << 8) | memory[address++];
  value = (value << 8) | memory[address++];
  value = (value << 8) | memory[address++];
  return value;
}

void
putFIXED(uint32_t address, int32_t value)
{
  memory[address++] = (value >> 24) & 0xFF;
  memory[address++] = (value >> 16) & 0xFF;
  memory[address++] = (value >> 8) & 0xFF;
  memory[address++] = value & 0xFF;
}

/*
uint32_t
getBIT(uint32_t address)
{
  return (uint32_t) getFIXED(address);
}

void
putBIT(uint32_t address, uint32_t value)
{
  putFIXED(address, (int32_t) value);
}
*/

// The table below was adapted from the table of the same name in
// the Virtual AGC source tree.  The table is indexed on the numeric
// codes of the ASCII charactgers. It contains the EBCDIC numeric
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
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, /*              */
  0x40, 0x5A, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D, /*  !"#$%&'     */
  0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61, /* ()*+,-./     */
  0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, /* 01234567     */
  0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F, /* 89:;<=>?     */
  0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, /* @ABCDEFG     */
  0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, /* HIJKLMNO     */
  0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, /* PQRSTUVW     */
  0xE7, 0xE8, 0xE9, 0xBA, 0xE0, 0xBB, 0x5F, 0x6D, /* XYZ[\]^_     */
  0x4A, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, /* `abcdefg     */
  0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, /* hijklmno     */
  0x97, 0x98, 0x99, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, /* pqrstuvw     */
  0xA7, 0xA8, 0xA9, 0xC0, 0x6A, 0xD0, 0x5F, 0x40  /* xyz{|}~      */
};

// The inverse of `asciiToEbcdic` above, in which the ASCII equivalent
// character is given for each printable EBCDIC code.  It performs
// the substitution of the U.S. cent character to ` and the logical-NOT
// symbol to ~, a explained above.  It was generated from the table above
// using the one-time-use program invertEbcdicTable.py.
static char ebcdicToAscii[256] = {
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '`', '.', '<', '(', '+', ' ',
  '&', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '!', '$', '*', ')', ';', '~',
  '-', '/', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '|', ',', '%', '_', '>', '?',
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ':', '#', '@', '\'', '=', '"',
  ' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '[', ']', ' ', ' ', ' ', ' ',
  '{', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', ' ', ' ', ' ', ' ', ' ', ' ',
  '}', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', ' ', ' ', ' ', ' ', ' ', ' ',
  '\\', ' ', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', ' ', ' ', ' ', ' ', ' ', ' ',
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' ', ' ', ' ', ' ', ' ', ' '
};

char *
getCHARACTER(uint32_t address)
{
  char *returnValue = nextBuffer();
  uint32_t descriptor;
  size_t length;
  uint32_t index;
  descriptor = (uint32_t) getFIXED(address);
  length = ((descriptor >> 24) & 0xFF) + 1;
  index = descriptor & 0xFFFFFF;
#if NULL_STRING_METHOD == 0
  if (length == 1 && memory[index] == 0) // Empty string?
    {
      *returnValue = 0;
      return returnValue;
    }
#elif NULL_STRING_METHOD == 1
  if (descriptor == 0) // Empty string?
    {
      *returnValue = 0;
      return returnValue;
    }
#else
#error Implementation error: NULL_STRING_METHOD.
#endif
  if (index + length <= MEMORY_SIZE)
    {
      uint8_t c;
      char *s = returnValue;
      while (1)
        {
          if (length <= 0)
            {
              *s = 0;
              break;
            }
          length--;
          c = memory[index++];
          *s++ = ebcdicToAscii[c];
        }
      return returnValue;
    }
  return NULL;
}

void
putCHARACTER(uint32_t address, char *str)
{
  size_t length;
  uint32_t index, descriptor, oldLength, newDescriptor;
  descriptor = (uint32_t) getFIXED(address);
  oldLength = ((descriptor >> 24) & 0xFF) + 1;
  index = descriptor & 0xFFFFFF;
  length = strlen(str);
#if NULL_STRING_METHOD == 0
  if (length == 0)
    {
      putFIXED(address, index);
      memory[index] = 0;
      return;
    }
#elif NULL_STRING_METHOD == 1
  if (length == 0)
    {
      putFIXED(address, 0);
      return;
    }
#else
#error Implementation error: NULL_STRING_METHOD.
#endif
  if (length > 256) { // Shouldn't be possible.
    length = 256;
    str[length] = 0;
  }
  if (length > oldLength)
    {
      // The string we're saving is longer than the string we're overwriting.
      // We need to move it higher in the free-memory area.
      index = freepoint;
      putFIXED(address, ((length - 1) << 24) | index);
      freepoint += length;
      if (freepoint > FREE_LIMIT)
        COMPACTIFY(); // Will abort the program upon failure.
    }
  descriptor = ((length - 1) << 24) | index;
  putFIXED(address, (int32_t) descriptor);
  if (index + length <= MEMORY_SIZE)
    {
      char c, *s = str;
      while (1)
        {
          c = *s++;
          if (c == 0)
            break;
          memory[index++] = asciiToEbcdic[(int) c];
        }
    }
}

char *
fixedToCharacter(int32_t i) {
  char *returnString = nextBuffer();
  sprintf(returnString, "%d", i);
  return returnString;
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
  return ~i1 ^ 1;
}

int32_t
xOR(int32_t i1, int32_t i2) {
  return i1 | i2;
}

int32_t
xAND(int32_t i1, int32_t i2){
  return i1 & i2;
}

// Various string-comparison functions follow.

// Used by `xsXXX` functions, and not expected to be called directly.
enum stringRelation_t { EQ, NEQ, LT, GT, LE, GE };
int32_t
stringRelation(enum stringRelation_t relation, char *s1, char *s2) {
  int comparison = 0; // -1 for <, 0 for =, 1 for >.
  int l1 = strlen(s1), l2 = strlen(s2);
  if (l1 > l2)
    comparison = 1;
  else if (l1 < l2)
    comparison = -1;
  else
    while (*s1 != 0)
      {
        int e1 = asciiToEbcdic[*s1++], e2 = asciiToEbcdic[*s2++];
        if (e1 > e2) { comparison = 1; break; }
        else if (e1 < e2) { comparison = -1; break; }
      }
  if (relation == EQ) return comparison == 0;
  if (relation == NEQ) return comparison != 0;
  if (relation == LT) return comparison == -1;
  if (relation == GT) return comparison == 1;
  if (relation == LE) return comparison != 1;
  if (relation == GE) return comparison != -1;
  return 0; // Shouldn't happen.
}
int32_t
xsEQ(char *s1, char *s2) {
  return stringRelation(EQ, s1, s2);
}
int32_t
xsLT(char *s1, char *s2) {
  return stringRelation(LT, s1, s2);
}
int32_t
xsGT(char *s1, char *s2) {
  return stringRelation(GT, s1, s2);
}
int32_t
xsNEQ(char *s1, char *s2) {
  return stringRelation(NEQ, s1, s2);
}
int32_t
xsLE(char *s1, char *s2) {
  return stringRelation(LE, s1, s2);
}
int32_t
xsGE(char *s1, char *s2) {
  return stringRelation(GE, s1, s2);
}

char *
xsCAT(char *s1, char *s2) {
  int length;
  char *s, *returnString = nextBuffer();
  strcpy(returnString, s1);
  length = strlen(returnString);
  if (length < MAX_XPL_STRING)
    {
      s = &returnString[length]; // Where s2 can be copied to.
      length = MAX_XPL_STRING - length; // Available space for s2.
      strncpy(s, s2, length);
    }
  returnString[MAX_XPL_STRING] = 0;
  return returnString;
}

/*
The following function replaces the XPL constructs
    OUTPUT(fileNumber) = string
    OUTPUT = string      , which is shorthand for OUTPUT(0)=string.
The carriage-control characters for fileNumber 1 may be
the so-called ANSI control characters:
    '_'    Single space the line and print
    '0'    Double space the line and print
    '-'    Triple space the line and print
    '+'    Do not space the line and print (but does return carriage to left!)
    '1'    Form feed
    'H'    Heading line.
    '2'    Subheading line.
    ...    Others
*/
string_t headingLine = "";
string_t subHeadingLine = "";
int pageCount = 0;
int LINE_COUNT = 0;
int linesPerPage = 59;  // Should get this from LINECT parameter.
#define MAX_QUEUE 10
void
OUTPUT(uint32_t lun, char *string) {
  char ansi = ' '; // ANSI carriage-control character.
  char *s = string; // Printable character data.
  FILE *fp;
  int i;
  if (lun < 0 || lun >= DD_MAX || DD_OUTS[lun] == NULL)
    {
      fprintf(stderr, "Output file %d has not been assigned.\n", lun);
      exit(1);
    }
  fp = DD_OUTS[lun];
  string_t queue[MAX_QUEUE]; // SYSPRINT line-queue for current page.
  int linesInQueue = 0;
  if (lun <= 1) // SYSPRINT
    {
      if (lun == 1)
        {
          ansi = string[0];
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
          // need to advance to the next line.
          strcpy(queue[linesInQueue++], "");
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
                fprintf(fp, "\n\f");
              pageCount++;
              LINE_COUNT = 0;
              if (strlen(headingLine) > 0)
                fprintf(fp, "%s     PAGE %d\n", headingLine, pageCount);
              else
                fprintf(fp, "PAGE %d\n", pageCount);
              LINE_COUNT++;
              if (strlen(subHeadingLine) > 0)
                {
                  printf("%s\n", subHeadingLine);
                  LINE_COUNT++;
                }
              if (LINE_COUNT > 0)
                {
                  fprintf(fp, "\n");
                  LINE_COUNT++;
                }
            }
          if (outUTF8)
            {
              char c, *s, *s0;
              for (s = s0 = queue[i]; *s != 0; s++)
                if (*s == '`' || *s == '~')
                  {
                    c = *s;
                    *s = 0;
                    if (s > s0)
                      fprintf(fp, "%s", s0);
                    s0 = s + 1;
                    if (c == '`') fprintf(fp, "¢");
                    else if (c == '~') fprintf(fp, "¬");
                  }
              if (s > s0)
                fprintf(fp, "%s", s);
            }
          else
            fprintf(fp, "%s", queue[i]);
          if (i < linesInQueue - 1)
            {
              fprintf(fp, "\n");
              LINE_COUNT++;
            }
        }
    }
  else
    {
      fprintf(fp, "%s\n", string);
    }
}

#define MAX_INPUTS 128
char *
INPUT(uint32_t lun) {
  char *s;
  FILE *fp;
  if (lun < 0 || lun >= DD_MAX || DD_INS[lun] == NULL)
    {
      fprintf(stderr, "Input file %d has not been assigned.\n", lun);
      exit(1);
    }
  fp = DD_INS[lun];
  s = nextBuffer();
  if (fgets(s, sizeof(string_t), fp) == NULL) // End of file.
    {
      // McKeeman doesn't define how to detect an end-of-file on INPUT,
      // but sample program 6.18.4 detects it by finding an empty string.
      s[0] = 0;
      return s;
    }
  s[strcspn(s, "\r\n")] = 0; // Strip off carriage-returns and/or line-feeds.
  return s;
}

uint32_t
LENGTH(char *s) {
  return strlen(s);
}

char *
SUBSTR(char *s, uint32_t start, uint32_t length) {
  char *returnValue = nextBuffer();
  int len = strlen(s) - start;
  if (len > 0)
    {
      if (length > len)
        length = len;
      strncpy(returnValue, &s[start], length);
      returnValue[length] = 0;
    }
  return returnValue;
}

char *
bSUBSTR2(char *s, uint32_t start) {
  return SUBSTR(s, start, strlen(s) - start);
}

uint8_t
BYTE(char *s, uint32_t index){
  return asciiToEbcdic[s[index]];
}

uint8_t
bBYTE1(char *s) {
  return BYTE(s, 0);
}

uint32_t
SHL(uint32_t value, uint32_t shift) {
  return value << shift;
}

uint32_t
SHR(uint32_t value, uint32_t shift) {
  return value >> shift;
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

// Look up the `memoryMap` entry associated with a given address.  Returns
// either a pointer to the record, or else NULL if not found.
static memoryMapEntry_t *
lookupAddress(uint32_t address)
{
  memoryMapEntry_t key, *found;
  key.address = address;
  found = bsearch(&key, memoryMap, NUM_SYMBOLS,
                  sizeof(memoryMapEntry_t), cmpAddresses);
  return found;
}

// Look up the `memoryMap` entry associated with a given variable name.
// Returns either a pointer to the record, or else NULL if not found.
static memoryMapEntry_t *
lookupVariable(char *symbol)
{
  memoryMapEntry_t **found, key, *keyp = &key;
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

// MONITOR functions.

// In general, new memory is allocated at `FREEPOINT`, and `FREEPOINT` is then
// incremented by `n`, leaving a hole if the based variable previously had
// some memory allocated to it.  However, we can check to see if the BASED
// variable was previously butted up against `FREEPOINT`, and can adjust the
// size of the allocated block by moving `FREEPOINT` without creating a hole.
// Note that new allocation is supposed to be cleared to 0.  I'm not sure what
// is supposed to happen, though, if I'm just increasing the size of an
// already-allocated block.  Note that `n` is expected to be an integral
// multiple of the record size of the BASED variable, though the function will
// not fail if not.
uint32_t
MONITOR6(uint32_t address, uint32_t n) {
  memoryMapEntry_t *found;
  uint32_t start, end;

  found = lookupAddress(address);
  if (found == NULL)
    return 1;
  if (strcmp(found->datatype, "BASED"))
    return 1;
  start = getFIXED(address);
  end = start + found->allocated;
  if (n <= found->allocated)
    {
      // To make an already-allocated block smaller, we can just mark it as
      // being smaller.
      found->allocated = n;
      found->numElements = n / found->recordSize;
      if (freepoint == end)
        freepoint = start + n;
      return 0;
    }
  if (freepoint + n > FREE_LIMIT)
    COMPACTIFY();
  if (freepoint + n > FREE_LIMIT)
    return 1;
  start = getFIXED(address);
  end = start + found->allocated;
  if (end == freepoint)
    {
      freepoint = start + n;
      found->allocated = n;
      found->numElements = n / found->recordSize;
      for (; end < freepoint; end++)
        memory[end] = 0;
      return 0;
    }
  putFIXED(address, freepoint);
  for (end = freepoint + n; freepoint < end; freepoint++)
    memory[freepoint] = 0;
  found->allocated = n;
  found->numElements = n / found->recordSize;
  return 0;
}

uint32_t
MONITOR7(uint32_t address, uint32_t n) {
  memoryMapEntry_t *found;

  found = lookupAddress(address);
  if (found == NULL)
    return 1;
  if (strcmp(found->datatype, "BASED"))
    return 1;
  if (n > found->allocated)
    n = found->allocated;
  if (freepoint == getFIXED(address) + found->allocated)
    freepoint -= n;
  found->allocated -= n;
  found->numElements -= n / found->recordSize;
  return 0;
}

uint32_t
MONITOR18(void) {
  struct timeval currentTime;
  gettimeofday(&currentTime, NULL);
  uint32_t t;
  return 1000000 * (currentTime.tv_sec - startTime.tv_sec) +
                   (currentTime.tv_usec - startTime.tv_usec);
}

uint32_t
MONITOR21(void) {
  return FREE_LIMIT - freepoint;
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
  gettimeofday(&tv, NULL);
  struct tm *timeStruct = gmtime(&tv.tv_sec);
  return timeStruct->tm_hour * 360000 +
         timeStruct->tm_min  * 6000 +
         timeStruct->tm_sec  * 100 +
         tv.tv_usec / 10000;
}

#endif

uint32_t
DATE(void) {
  time_t t = time(NULL);
  struct tm *timeStruct = gmtime(&t);
  return 1000 * timeStruct->tm_year + timeStruct->tm_yday;
}

// Because I'm lazy, `yisleap` and `get_yday` came directly from the web, as-is:
// https://stackoverflow.com/questions/19377396/c-get-day-of-year-from-date.
// Note that it considers January 1 to be day 1, whereas `gmtime` computes
// it as 0.  McKeeman doesn't document it, so I use 0 and must subtract 1 from
// what `get_yday` computes.
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
  return 1000 * (yyyy - 1900) + dayOfYear - 1;
}

uint32_t
COREBYTE(uint32_t address) {
  if (address + 1 <= MEMORY_SIZE)
    return memory[address];
  fprintf(stderr, "Memory overflow COREBYTE(0x%X) read\n", address);
  exit(1);
}

void
COREBYTE2(uint32_t address, uint32_t value) {
  if (address + 1 <= MEMORY_SIZE)
    memory[address] = value & 0xFF;
    return;
  fprintf(stderr, "Memory overflow COREWORD(0x%X) write\n", address);
  exit(1);
}

uint32_t
COREWORD(uint32_t address) {
  if (address + 4 <= MEMORY_SIZE)
    return getFIXED(address);
  fprintf(stderr, "Memory overflow COREWORD(0x%X) read\n", address);
  exit(1);
}

void
COREWORD2(uint32_t address, uint32_t value) {
  if (address + 4 <= MEMORY_SIZE)
    putFIXED(address, value);
    return;
  fprintf(stderr, "Memory overflow COREWORD(0x%X) write\n", address);
  exit(1);
}

// Note that the lookup of variable names required in `ADDR` depends on the
// presence of the metadata in the `memoryMap` array, as sorted by symbols
// `memoryMapBySymbol`.
uint32_t
ADDR(char *bVar, int32_t bIndex, char *fVar, int32_t fIndex) {
  memoryMapEntry_t *found;
  static int mapInitialized = 0;
  if (!mapInitialized)
    {
      // In point of fact, XCOM-I has already sorted `memoryMapBySymbol`.
      // However, it's possible for the run-time computer to have a different
      // environment setup, with a different collating order, than the
      // compile-time computer.  If that happens, then binary searches will
      // no longer work properly.  Consequently, we sort it again at run-time,
      // guaranteeing matching collation.
      mapInitialized = 1;
      qsort(&memoryMapBySymbol, NUM_SYMBOLS,
            sizeof(memoryMapEntry_t *), cmpMapSymbols);
    }
  if (bVar != NULL) // BASED variable.
    {
      int i, j;
      uint32_t address;
      basedField_t *basedField;
      found = lookupVariable(bVar);
      if (found == NULL)
        {
          fprintf(stderr, "ADDR(%s) not found\n", bVar);
          exit(1);
        }
      if (bIndex == 0x80000000 && fVar == NULL && fIndex == 0) {
          // This special case returns just the address of a BASED
          // variable's pointer to the beginning of its memory
          // allocation.
          return found->address;
      }
      address = getFIXED(found->address);       // -> beginning of alloc.
      address += bIndex * found->recordSize;    // -> beginning of record.
      if (fVar == NULL) // No field specified.
        return address;
      // Look for the specific field in the record (and the specific
      // index into it), to update the address and return it.
      for (i = 0, basedField = found->basedFields;
           i < found->numFieldsInRecord;
           i++, basedField++)
        {
          int numElements = basedField->numElements;
          if (numElements == 0)
            numElements = 1;
          if (!strcmp(fVar, basedField->symbol))
            {
              if (fIndex >= numElements)
                break;
              address += 4 * fIndex;
              return address;
            }
          else
            address += 4 * numElements;
        }

      fprintf(stderr, "Could not find the specified BASED variable field.\n");
      exit(1);
    }
  else
    {

      found = lookupVariable(fVar);
      if (found == NULL)
        {
          fprintf(stderr, "ADDR(%s) not found\n", fVar);
          exit(1);
        }
      return found->address + 4 * fIndex;
    }
  return 0;
}

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

// Ignoring records at first, and packing only strings and BASED.
void
COMPACTIFY(void)
{
  int i;
  int numAllocations = 0;
  struct allocated_t *allocations;

  // The first step is to form an array containing the relevant characteristics
  // of all the memory chunks allocated in free memory.  These characteristics
  // are the positions and sizes in free memory, plus pointers back to the
  // "string descriptors" so that they can be repaired after packing.  The
  // metadata we need to determine which variables are relevant etc. are in
  // the `memoryMap` array.  More space is allocated to `allocations` than we
  // probably need, but it's correct in the worst-case (which is that every
  // variable is BASED).
  allocations = calloc( (FREE_BASE - COMMON_BASE) / 4,
                        sizeof(struct allocated_t) );
  for (i = 0; i < NUM_SYMBOLS; i++)
    {
      int numElements, address, descriptor, k;
      if (!strcmp(memoryMap[i].datatype, "BASED"))
        {
          address = memoryMap[i].address;
          allocations[numAllocations].address = address;
          allocations[numAllocations].saddress = getFIXED(address);
          allocations[numAllocations].length = memoryMap[i].allocated;
          allocations[numAllocations].symbol = memoryMap[i].symbol;
          allocations[numAllocations].index = 0;
          allocations[numAllocations].datatype = memoryMap[i].datatype;
          numAllocations++;
        }
      else if (!strcmp(memoryMap[i].datatype, "CHARACTER"))
        {
          numElements = memoryMap[i].numElements;
          if (numElements == 0)
            numElements = 1;
          address = memoryMap[i].address;
          for (k = 0; k < numElements; k++, address += 4)
            {
              descriptor = getFIXED(address);
#if NULL_STRING_METHOD == 1
              if (descriptor == 0) // Empty string, no allocation
                continue;
#endif
              allocations[numAllocations].saddress = descriptor & 0xFFFFFF;
              allocations[numAllocations].length = ((descriptor >> 24) & 0xFF) + 1;
              allocations[numAllocations].address = address;
              allocations[numAllocations].symbol = memoryMap[i].symbol;
              allocations[numAllocations].index = k;
              allocations[numAllocations].datatype = memoryMap[i].datatype;
              numAllocations++;
            }
        }
    }
  if (numAllocations == 0)
    return;

  // Sort the `allocations` into order of increasing allocation address. That'll
  // let us find all of the holes.
  qsort(allocations, numAllocations, sizeof(struct allocated_t), cmpAllocations);

  // Let's find all of the holes and deal with them as we find them.
  for (i = 0; i < numAllocations; i++)
    {
      int expected, actual, lengthToMove;
      if (i == 0)
        expected = FREE_BASE;
      else
        expected = allocations[i - 1].saddress + allocations[i - 1].length;
      actual = allocations[i].saddress;
      if (actual > expected)
        {
          int whereDescriptor = allocations[i].address, descriptor;
          // Move the data downward to fill the hole (just for this allocation).
          lengthToMove = allocations[i].length;
          if (actual + lengthToMove > FREE_LIMIT)
            lengthToMove = FREE_LIMIT - actual;
          bcopy(&memory[actual], &memory[expected], lengthToMove);
          allocations[i].saddress = expected;
          // Fix the entry for the variable.  Note that the following works
          // for either CHARACTER or for BASED, since the MSB of a pointer
          // (which is what's stored at the BASED variable) is always 0.
          descriptor = (getFIXED(whereDescriptor) & 0xFF000000) | expected;
          putFIXED(whereDescriptor, descriptor);

        }
    }

  // Finally, fix FREEPOINT
  freepoint = allocations[numAllocations - 1].saddress +
              allocations[numAllocations - 1].length;

  if (1)
    {
      // Let's look at what we've got so far.
      for (i = 0; i < numAllocations; i++)
        {
          printf("%06X %3d %s(%d) @%06X\n", allocations[i].saddress,
              allocations[i].length,
              allocations[i].symbol, allocations[i].index, allocations[i].address);
        }
      printf("FREELIMIT = %06X\n", freepoint);
    }

  free(allocations);
}

void
printMemoryMap(char *msg) {
  int i;
  printf("\n%s\n", msg);
  for (i = 0; i < NUM_SYMBOLS; i++)
    {
      int j;
      int address = memoryMap[i].address;
      char *symbol = memoryMap[i].symbol;
      char *datatype = memoryMap[i].datatype;
      if (!strcmp(datatype, "BASED"))
        {
          int numRecords = memoryMap[i].allocated / memoryMap[i].recordSize;
          uint32_t raddress = getFIXED(address);
          printf("%06X: BASED     %s = %06X\n", address, symbol,
                 getFIXED(address));
          for (j = 0; j < numRecords; j++)
            {
              int k;
              int numFieldsInRecord = memoryMap[i].numFieldsInRecord;
              basedField_t *basedField = memoryMap[i].basedFields;
              for (k = 0; k < numFieldsInRecord; k++, basedField++)
                {
                  int n, numElements = basedField->numElements, vector = 1;
                  if (numElements == 0)
                    {
                      vector = 0;
                      numElements = 1;
                    }
                  for (n = 0; n < numElements; n++, raddress += 4)
                    {
                      char *fieldName = basedField->symbol, *s;
                      printf("        %06X: BASED %s %s(%d)", raddress,
                             basedField->datatype, symbol, j);
                      if (strlen(fieldName) != 0)
                        {
                          printf(".%s", fieldName);
                          if (vector)
                            printf("(%d)", n);
                        }
                      if (!strcmp(basedField->datatype, "CHARACTER"))
                        {
                          uint32_t descriptor = getFIXED(raddress);
                          if (descriptor == 0)
                            printf(" = \"%s\"", "");
                          else
                            printf(" = \"%s\" @%06X", getCHARACTER(raddress),
                                   0xFFFFFF & getFIXED(raddress));
                        }
                      else if (!strcmp(basedField->datatype, "FIXED"))
                        printf(" = %d", getFIXED(raddress));
                      else if (!strcmp(basedField->datatype, "BIT"))
                        printf(" = %u", getFIXED(raddress));
                      printf("\n");
                    }
                }
            }
        }
      else
        {
          int numElements = memoryMap[i].numElements;
          if (numElements == 0)
            {
              if (!strcmp(datatype, "CHARACTER"))
                {
                  uint32_t descriptor = getFIXED(address);
                  uint32_t saddress = descriptor & 0xFFFFFF;
                  if (descriptor == 0)
                    {
                      printf("%06X: CHARACTER %s = \"%s\"\n", address,
                             symbol, getCHARACTER(address));
                    }
                  else
                    {
                      printf("%06X: CHARACTER %s = \"%s\" @%06X\n",
                             address, symbol, getCHARACTER(address), saddress);
                    }
                }
              else if (!strcmp(datatype, "FIXED"))
                {
                  printf("%06X: FIXED     %s = %d\n", address, symbol,
                      getFIXED(address));
                }
              else if (!strcmp(datatype, "BIT"))
                {
                  printf("%06X:       BIT %s = %u\n", address, symbol,
                      getFIXED(address));
                }
            }
          for (j = 0; j < numElements; j++)
            {
              int k = address + 4 * j;
              if (!strcmp(datatype, "CHARACTER"))
                {
                  uint32_t descriptor = getFIXED(k);
                  uint32_t saddress = descriptor & 0xFFFFFF;
                  if (descriptor == 0)
                    {
                      printf("%06X: CHARACTER %s(%u) = \"%s\"\n", k, symbol,
                          j, getCHARACTER(k));
                    }
                  else
                    {
                      printf("%06X: CHARACTER %s(%u) = \"%s\" @%06X\n", k, symbol,
                          j, getCHARACTER(k), saddress);
                    }
                }
              else if (!strcmp(datatype, "FIXED"))
                {
                  printf("%06X: FIXED     %s(%u) = %d\n", k, symbol,
                      j, getFIXED(k));
                }
              else if (!strcmp(datatype, "BIT"))
                {
                  printf("%06X:       BIT %s(%u) = %u\n", k, symbol,
                      j, getFIXED(k));
                }
            }
        }
    }
}

/*
 * Format of a COMMON file:  A sequence of ASCII lines, each of which
 * consists of fields delimited by tabs.  The first field in each line
 * is a single character, interpreted as follows:
 *      ;       A comment, to be discarded upon reading the COMMON file.
 *      +       A non-BASED variable.
 *      -       A BASED variable.
 *      .       A field of a BASED variable.
 * Comment lines have only 2 fields (the leading ';' and the body of
 * the comment), while all other lines have 5 fields:
 *      1.      The leading character, described above.
 *      2.      The name of the variable or the field.  Note that a
 *              BASED variable *not* declared with a *RECORD* has a
 *              single field whose name is the empty string, whereas
 *              BASED RECORD variables have some number (presumably
 *              > 1) of fields whose names are *not* empty strings.
 *      3.      The index, considering the variable or the field to be
 *              subscripted.  (If not subscripted, the index is 0.)
 *      4.      The datatype:  "FIXED", "BIT", "CHARACTER", or "BASED".
 *              The datatype of a BASED variable is always "BASED", while
 *              the datatype of a field of a BASED variable is always
 *              "FIXED", "BIT", or "CHARACTER.  Note that there is
 *              no other distinction between the treatment of "BIT" and
 *              "FIXED".
 *      5.      For datatype "BASED", the number of bytes currently
 *              allocated.  For "FIXED" or "BIT", the current value of
 *              the variable as a 0-filled 8-digit hexadecimal number.
 *              For "CHARACTER", a string, delimited by single quotes.
 *              Note that the delimiters are merely for convenience of
 *              human-readability, and are discarded upon reading the
 *              COMMON file; the character string itself may contain
 *              single-quote characters or tab characters as-is without
 *              any special escaping or other trickery.
 * There is some redundancy among this data -- for example, there's
 * no real need for a datatype=BASED field when the leading field is
 * '+' -- but ... too bad!
 */
int
writeCOMMON(FILE *fp) {
  int i, j, k, address, numElements, allocated, based = 0;
  char *datatype, *symbol;
  if (fp == NULL)
    return 1;
  for (i = 0; i < NUM_SYMBOLS; i++)
    {
      address = memoryMap[i].address;
      datatype = memoryMap[i].datatype;
      if (!strcmp(datatype, "BASED"))
        {
          if (address >= NON_COMMON_BASE)
            continue;
          address = getFIXED(address);
          based = 1;
        }
      numElements = memoryMap[i].numElements;
      if (numElements == 0 && strcmp(datatype, "BASED"))
        numElements = 1;
      allocated = memoryMap[i].allocated;
      symbol = memoryMap[i].symbol;
      for (j = 0; j < numElements; j++)
        {
          if (!based && address >= NON_COMMON_BASE) // Past end of COMMON.
            break;
          if (!strcmp(datatype, "CHARACTER"))
            {
              fprintf(fp, "-\t%s\t%d\t%s\t", symbol, j, datatype);
              fprintf(fp, "'%s'\n", getCHARACTER(address));
              address += 4;
            }
          else if (!strcmp(datatype, "FIXED") || !strcmp(datatype, "BIT"))
            {
              fprintf(fp, "-\t%s\t%d\t%s\t", symbol, j, datatype);
              fprintf(fp, "%08X\n", getFIXED(address));
              address += 4;
            }
          else if (!strcmp(datatype, "BASED"))
            {
              int numFieldsInRecord = memoryMap[i].numFieldsInRecord;
              basedField_t *basedField = memoryMap[i].basedFields;
              fprintf(fp, "+\t%s\t%d\t%s\t", symbol, j, datatype);
              fprintf(fp, "%d\n", allocated);
              for (k = 0; k < numFieldsInRecord; k++, basedField++)
                {
                  char *basedSymbol = basedField->symbol,
                      *basedDatatype = basedField->datatype;
                  int n, oBasedNumElements = basedField->numElements;
                  int basedNumElements = oBasedNumElements;
                  if (oBasedNumElements == 0)
                    basedNumElements = 1;
                  for (n = 0; n < basedNumElements; n++, address += 4)
                    {
                      fprintf(fp, ".\t%s\t%d\t%s\t", basedSymbol, n,
                          basedDatatype);
                      if (!strcmp(basedDatatype, "FIXED") ||
                          !strcmp(basedDatatype, "BIT"))
                        fprintf(fp, "%08X\n", getFIXED(address));
                      else if (!strcmp(basedDatatype, "CHARACTER"))
                        fprintf(fp, "'%s'\n", getCHARACTER(address));
                      else
                        fprintf(fp, "\n");
                    }
                }
            }
        }
    }

  return 0;
}

#if 0
int
readCOMMON(FILE *fp) {
  uint32_t i, index, address, value;
  char buffer[sizeof(string_t) + 100];
  string_t symbol, string;
  fscanf(fp, "%*[^\n]\n"); // Skip the first line from the file, without saving.
  for (i = 0; i < NUM_SYMBOLS; i++)
    {
      if (NULL == fgets(buffer, sizeof(buffer), fp))
        return 1;
      if (4 == sscanf(buffer, "%s %d %X CHARACTER '%[^\n]\n", symbol, &index,
                      &address, string)) {
          string[strlen(string) - 1] = 0; // Get rid of trailing quote.
          putCHARACTER(address, string);
          continue;
      }
      if (4 == sscanf(buffer, "%s %d %X FIXED %X\n", symbol, &index,
                      &address, &value)) {
          putFIXED(address, value);
          continue;
      }
      if (4 == sscanf(buffer, "%s %d %X BIT %X\n", symbol, &index,
                      &address, &value)) {
          putFIXED(address, value);
          continue;
      }
      return -1; // Corrupted
    }
  if (NULL != fgets(buffer, sizeof(buffer), fp))
    return 2;
  return 0;
}
#endif

int
readCOMMON(FILE *fp) {
  char line[1024];
  int index, ivalue, fieldIndex, allocated;
  char svalue[sizeof(string_t) + 100];
  string_t symbol, field;

  // Read the COMMON file and process it line by line.
  while (NULL != fgets(line, sizeof(line), fp))
    {
      if (line[0] == ';') // A comment?
        continue;
      if (3 == sscanf(line, "-\t%s\t%d\tCHARACTER\t'%[^\n\r]",
                      field, &fieldIndex, svalue))
        {
          svalue[strlen(svalue) - 1] = 0; // Get rid of trailing '
          putCHARACTER(ADDR(NULL, 0, field, fieldIndex), svalue);
        }
      else if (3 == sscanf(line, "-\t%s\t%d\tFIXED\t%X",
                      field, &fieldIndex, &ivalue))
          putFIXED(ADDR(NULL, 0, field, fieldIndex), ivalue);
      else if (3 == sscanf(line, "-\t%s\t%d\tBIT\t%X",
                      field, &fieldIndex, &ivalue))
          putFIXED(ADDR(NULL, 0, field, fieldIndex), ivalue);
      else if (3 == sscanf(line, "+\t%s\t%d\tBASED\t%d",
                      symbol, &index, &allocated))
        {
          if (index == 0)
            MONITOR6(ADDR(symbol, 0x80000000, NULL, 0), allocated);
        }
      else if (3 == sscanf(line, ".\t%s\t%d\tCHARACTER\t'%[^\n\r]",
                      field, &fieldIndex, svalue))
        {
          svalue[strlen(svalue) - 1] = 0; // Get rid of trailing '
          putCHARACTER(ADDR(symbol, index, field, fieldIndex), svalue);
        }
      else if (3 == sscanf(line, ".\t%s\t%d\tFIXED\t%X",
                      field, &fieldIndex, &ivalue))
          putFIXED(ADDR(symbol, index, field, fieldIndex), ivalue);
      else if (3 == sscanf(line, ".\t%s\t%d\tBIT\t%X",
                      field, &fieldIndex, &ivalue))
          putFIXED(ADDR(symbol, index, field, fieldIndex), ivalue);
      else if (1 == sscanf(line, ".\t\t0\tCHARACTER\t'%[^\n\r]",
                      svalue))
        {
          svalue[strlen(svalue) - 1] = 0; // Get rid of trailing '
          putCHARACTER(ADDR(symbol, index, NULL, 0), svalue);
        }
      else if (1 == sscanf(line, ".\t\t0\tFIXED\t%X",
                      &ivalue))
          putFIXED(ADDR(symbol, index, NULL, 0), ivalue);
      else if (1 == sscanf(line, ".\t\t0\tBIT\t%X",
                      &ivalue))
          putFIXED(ADDR(symbol, index, NULL, 0), ivalue);
      else
        {
          fprintf(stderr, "Unrecognized COMMON: %s", line);
          return -1;
        }
    }
  printMemoryMap("--- COMMON ---");
  return 0;
}



// Some test code.
#if 0
int outUTF8;
FILE *DD_INS[DD_MAX];
FILE *DD_OUTS[DD_MAX];
typedef char string_t[MAX_XPL_STRING + 1];
uint8_t memory[MEMORY_SIZE];

int
main(void) {
  printf("%s\n", __DATE__);
  printf("%d %d\n", DATE(), DATE_OF_GENERATION());
  return 0;
}
#endif
