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

int
parseCommandLine(int argc, char **argv)
{
  extern uint32_t sizeOfCommon, sizeOfNonCommon; // from main.c
  int i, returnValue = 0;
  FILE *COMMON_IN = NULL;
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
          COMMON_IN = fopen(filename, "rb");
        }
      else if (1 == sscanf(argv[i], "--commono=%s", filename))
        {
          COMMON_OUT = fopen(filename, "wb");
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
          printf("--ddo=N,F   Attach filename F to the logical unit number\n");
          printf("            N, for use with the OUTPUT(N) XPL built-in.\n");
          printf("            By default, 0 and 1 are attached to stdout.\n");
          printf("--commoni=F Name of the file from which to read the\n");
          printf("            initial values for COMMON memory at startup.\n");
          printf("            By default, COMMON is not initialized.\n");
          printf("--commono=F Name of the file to which data from COMMON\n");
          printf("            is written upon program termination.  By\n");
          printf("            default, COMMON.out.\n");
          printf("\n");
          returnValue = 1;
        }
      else
        {
          printf("Unknown command-line switch %s. Try --help.\n", argv[i]);
          returnValue = -1;
        }
    }
  if (COMMON_OUT == NULL)
    COMMON_OUT = fopen("COMMON.out", "wb");
  if (COMMON_IN != NULL)
    {
      if (sizeOfCommon > 0)
        {
          int length = fread(memory, sizeOfCommon, 1, COMMON_IN);
          if (length < sizeOfCommon)
            fprintf(stderr,
                "Warning: COMMON file (%d) smaller than COMMON block (%d).\n",
                length, sizeOfCommon);
          fseek(COMMON_IN, 0, SEEK_END);
          length = ftell(COMMON_IN);
          if (length > sizeOfCommon)
            fprintf(stderr,
                "Warning: COMMON file (%d) larger than COMMON block (%d).\n",
                length, sizeOfCommon);
        }
      fclose(COMMON_IN);
      COMMON_IN = NULL;
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
  size_t length;
  uint32_t index, descriptor;
  char *returnValue = nextBuffer();
  descriptor = (uint32_t) getFIXED(address);
  length = (descriptor >> 24) & 0xFF;
  index = descriptor & 0xFFFFFF;
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
  uint32_t index, descriptor;
  descriptor = (uint32_t) getFIXED(address);
  index = descriptor & 0xFFFFFF;
  length = strlen(str);
  if (length > 255) { // Shouldn't be possible.
    length = 255;
    str[length] = 0;
  }
  descriptor = (length << 24) | index;
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
        ;
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

// In case the header file sys/time.h isn't available (to provide the
// `gettimeofday` function), change the "#if 0" below to "#if 1".

#include <time.h>

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

#include <sys/time.h>

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
