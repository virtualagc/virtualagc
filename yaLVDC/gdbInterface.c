/*
 * Copyright 2020 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    gdbInterface.c
 * Purpose:     Provides a debugger interface for the LVDC/PTC emulator.
 *              in spite of the name, it's not necessarily a gdb-like
 *              interface, but I already have other functions and filenames
 *              with names like debug*, so I thought it would be prudent
 *              to name it more distinctly.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2020-04-30 RSB  Began.
 *              2020-05-21 RSB  Fixed arguments for DISASSEMBLE.
 *              2023-07-16 MAS  Fixed handling of SI and NI.
 *              2023-08-08 RSB  Fixed elapsed time.
 *              2023-08-22 RSB  Added MULTIPLIER.
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "yaLVDC.h"

////////////////////////////////////////////////////////////////////////////////
// Utility functions.

// Create a descriptive string for a HOP constant, specified either by giving
// the constant itself, or else by module/sector/location if the constant is
// given as -1.  A char buffer[32] to store the string is one of the arguments.
// Returns 0 if successful, 1 otherwise.  The string is still created in
// case of failure.
static int
formHopDescription(int hopConstant, int module, int sector, int location,
    char *buffer, hopStructure_t *hs)
{
  if (hopConstant == -1)
    {
      if (module < 0 || module > 7 || sector < 0 || sector > 017 || location < 0
          || location > 0377)
        {
          sprintf(buffer, "????????? (%-19s)", "illegal address");
          return (1);
        }
      if (state.core[module][sector][2][location] == -1)
        {
          sprintf(buffer, "????????? (%-19s)", "empty address");
          return (1);
        }
      hopConstant = state.core[module][sector][2][location];
    }
  if (parseHopConstant(hopConstant, hs))
    {
      sprintf(buffer, "%09o (%-19s)", hopConstant, "invalid HOP constant");
      return (1);
    }
  sprintf(buffer, "%09o (ADR=%o-%02o-%o-%03o/%o-%02o)", hopConstant, hs->im,
      hs->is, hs->s, hs->loc, hs->dm, hs->ds);
  return (0);
}

// Parse an input line into fields.  The first field is the command, and it
// is any number of alphabetic characters, upper or lower case, and is
// automatically converted to upper case.  The second field, if any,
// needn't be separated from the first one if its 1st character is non-alphabetic.
// Otherwise, all fields are delimited by whitespace.  The return value is
// the number of fields found, or -1 if error.
#define MAX_COMMAND_FIELDS 10
#define MAX_COMMAND_LENGTH 128
static char lineBuffer[MAX_COMMAND_LENGTH],
    fields[MAX_COMMAND_FIELDS][MAX_COMMAND_LENGTH],
    lastLine[MAX_COMMAND_LENGTH];
int
parseCommand(void)
{
  int numFields = 0;
  char *s, *ss;

  // Get rid of any leading whitespace.
  for (s = lineBuffer; *s && isspace(*s); s++)
    ;
  if (!*s)
    goto done;

  // Parse first field. Note that it cannot be longer than fields[0], since
  // fields[0] is itself as large as the input line buffer.
  for (ss = fields[numFields]; *s && isalpha(*s); s++, ss++)
    *ss = toupper(*s);
  *ss = 0;
  numFields++;

  // Now parse all remaining fields.
  while (*s)
    {
      // Get rid of any leading whitespace.
      for (; *s && isspace(*s); s++)
        ;
      if (!*s)
        goto done;

      // Again, fields[numFields] is the same length as lineBuffer,
      // so overflow is impossible.
      for (ss = fields[numFields]; *s && !isspace(*s); s++, ss++)
        *ss = *s;
      *ss = 0;
      numFields++;
    }

  done: ;
  return (numFields);
}

// Associate command strings with command tokens.  A token is returned
// for the first valid command for which the input command is a leading
// substring.  For example, ctSTEP is returned if the input command
// is S, ST, STE, or STEP.  The token ctNone is returned if the input
// command doesn't match anything.  Because these abbreviations may not
// be unique, the commandAssociations[] array is ordered in terms of
// priority for the abbreviations.  For example, "STEP" comes first
// because it's more-important than other commands beginning with "S",
// and we want to make sure that "S" is an abbreviation for "STEP" rather
// than some other S-command.
enum commandTokens
{
  ctSTEP,
  ctNEXT,
  ctDELETE,
  ctCONTINUE,
  ctJUMP,
  ctGOTO,
  ctLIST,
  ctDISASSEMBLE,
  ctX,
  ctCLEAR,
  ctBREAK,
  ctTBREAK,
  ctBACKTRACE,
  ctINFO,
  ctRUN,
  ctQUIT,
  ctSET,
  ctSHOW,
  ctPANEL,
  ctHELP,
  ctMULTIPLIER,
  ctNone
};
typedef struct
{
  enum commandTokens token;
  const char *string;
  const char *syntax;
  const char *description;
} commandAssociation_t;
commandAssociation_t commandAssociations[] =
      {
        { ctSTEP, "STEPI", "STEPI [n]", "Step n instructions, default n=1." },
        { ctSTEP, "SI", "SI [n]", "Same as STEPI." },
        { ctNEXT, "NEXTI", "NEXTI [n]", "Next n instructions, w/o entry." },
        { ctNEXT, "NI", "NI [n]", "Same as NEXTI." },
        { ctDELETE, "DELETE", "DELETE", "Delete all breakpoints." },
        { ctDELETE, "DELETE", "DELETE n", "Delete breakpoint n." },
        { ctCONTINUE, "CONTINUE", "CONTINUE", "Continue running emulation." },
        { ctJUMP, "JUMP", "JUMP *address M-SS",
            "Jump to code-memory address and assign DM/DS as M-SS and run." },
        { ctJUMP, "JUMP", "JUMP [asm:]name",
            "Jump. Operand is symbolic name of a HOP constant in data memory." },
        { ctJUMP, "JUMP", "JUMP [asm:]name M-SS",
            "Jump to symbol in code memory and assign DM/DS as M-SS." },
        { ctJUMP, "JUMP", "JUMP octal",
            "Jump using literal octal HOP constant. Note that JUMP 0 is a restart." },
        { ctGOTO, "GOTO", "GOTO ...",
            "Same as JUMP, except pause rather than run." },
        { ctLIST, "LIST", "LIST", "List following block of source code." },
        { ctLIST, "LIST", "LIST -", "List preceding block source code." },
        { ctLIST, "LIST", "LIST [asm:]n", "List source block at line #n." },
        { ctLIST, "LIST", "LIST [asm:]name",
            "List source block at function." },
        { ctDISASSEMBLE, "DISASSEMBLE", "DISASSEMBLE",
            "Disassemble next LISTSIZE instructions in current HOP environment." },
        { ctDISASSEMBLE, "DISASSEMBLE", "DISASSEMBLE - D-TT",
            "Disassemble preceding LISTSIZE instructions; D-TT is starting DM/DS." },
        { ctDISASSEMBLE, "DISASSEMBLE", "DISASSEMBLE M-SS-Y-LLL EEE D-TT",
            "Disassemble from code address M-SS-Y-LLL to EEE using data sector D-TT." },
        { ctX, "X", "X[/[n][b|d|o]] address", "Show n words at address." },
        { ctX, "X", "X[/[n][b|d|o]] &[asm:]name", "Show n words at name." },
        { ctCLEAR, "CLEAR", "CLEAR [asm:]name",
            "Delete breakpoint at function." },
        { ctCLEAR, "CLEAR", "CLEAR [asm:]number",
            "Delete breakpoint at line #." },
        { ctCLEAR, "CLEAR", "CLEAR *address",
            "Delete breakpoint at address." },
        { ctBREAK, "BREAK", "BREAK [asm:]name",
            "Set breakpoint at function." },
        { ctBREAK, "BREAK", "BREAK [asm:]number",
            "Set breakpoint at line #." },
        { ctBREAK, "BREAK", "BREAK *address", "Set breakpoint at address." },
        { ctTBREAK, "TBREAK", "TBREAK ...", "Same as BREAK, but temporary." },
        { ctBACKTRACE, "BACKTRACE", "BACKTRACE [n]",
            "Show last n backtraces, default=20." },
        { ctBACKTRACE, "BACKTRACE", "BT [n]", "Same as BACKTRACE." },
        { ctINFO, "INFO", "INFO ASSEMBLIES", "List all loaded assemblies." },
        { ctINFO, "INFO", "INFO BREAKPOINTS", "List all breakpoints." },
        { ctINFO, "INFO", "INFO BREAK", "List all breakpoint numbers." },
        { ctRUN, "RUN", "RUN", "Reboot the LVDC/PTC emulation." },
        { ctQUIT, "QUIT", "QUIT", "Quit the LVDC/PTC emulator." },
        { ctSET, "SET", "SET LISTSIZE n", "Sets default size used for LIST." },
        { ctSET, "SET", "SET name = n", "Store value n in variable name." },
        { ctSET, "SET", "SET *address = n",
            "Store value n at memory address." },
        { ctSHOW, "SHOW", "SHOW LISTSIZE", "Show current size for LIST." },
        { ctPANEL, "PANEL", "PANEL",
            "Resume full control by PTC front panel." },
        { ctMULTIPLIER, "MULTIPLIER", "MULTIPLIER n",
            "(Don't use.) Temporarily set clock multiplier to n; reverts at next breakpoint."},
        { ctHELP, "HELP", "HELP", "Print this list of commands." },
        { ctNone, "" } };
enum commandTokens
findCommandToken(void)
{
  int i, n = strlen(fields[0]);

  for (i = 0; commandAssociations[i].token != ctNone; i++)
    {
      if (!strncasecmp(fields[0], commandAssociations[i].string, n))
        break;
    }

  return (commandAssociations[i].token);
}

// Find the assembly, given its name (from the --assembly switch).
// The return value is NULL if there is no match.
assembly_t *
findAssemblyByName(char *assemblyName)
{
  int i;
  if (numAssemblies <= 0 || assemblyName == NULL)
    return (NULL);
  for (i = 0; i < numAssemblies; i++)
    if (!strcmp(assemblies[i].name, assemblyName))
      return (&assemblies[i]);
  return (NULL);
}

// Find a name in the symbol table.  Accepts names of the form assembly:symbol
// or just symbol.  Returns a pointer to the symbol-table entry or to NULL
// if not found.  If the input assemblyName is missing, then all
// assemblies are searched, but only the first match found is returned.
assembly_t *symbolAssembly;
symbol_t *
findSymbol(char *symbolName, int code)
{
  int i, start = 0, end = numAssemblies;
  char *assemblyName = NULL, *ss;
  assembly_t *assembly = assemblies;
  symbol_t *symbol = NULL;

  symbolAssembly = NULL;

  ss = strstr(symbolName, ":");
  if (ss != NULL)
    {
      *ss = 0;
      assemblyName = symbolName;
      symbolName = ss + 1;
    }
  if (assemblyName != NULL)
    {
      assembly = findAssemblyByName(assemblyName);
      *ss = ':';
      if (assembly == NULL)
        {
          printf("No such assembly.\n");
          return (NULL);
        }
      start = assembly - assemblies;
      end = start + 1;
    }
  for (; start < end; start++, assembly++)
    for (i = 0; i < assembly->numSymbols; i++)
      if (!strcasecmp(symbolName, assembly->symbols[i].name)
          && ((code && assembly->symbols[i].syllable < 2)
              || (!code && assembly->symbols[i].syllable == 2)))
        {
          if (symbol == NULL)
            {
              symbol = &assembly->symbols[i];
              symbolAssembly = assembly;
            }
          else
            printf("Symbol specification is not unique.\n");
        }
  return (symbol);
}

// Find an address in the symbol table.  Returns a pointer to
// the symbol-table entry or to NULL if not found.  The assembly
// in which it was found is in the global symbolAssembly variable.
symbol_t *
findSymbolByAddress(int module, int sector, int syllable, int location)
{
  int i, j;
  assembly_t *assembly;
  symbol_t *symbol;

  for (j = 0, assembly = assemblies; j < numAssemblies; j++, assembly++)
    for (i = 0, symbol = assembly->symbols; i < assembly->numSymbols;
        i++, symbol++)
      if (module == symbol->module && sector == symbol->sector
          && syllable == symbol->syllable && location == symbol->loc)
        {
          symbolAssembly = assembly;
          return (symbol);
        }

  symbolAssembly = NULL;
  return (NULL);
}

symbol_t *
findSymbolByDataAddress(int module, int sector, int residual, int location)
{
  if (!residual)
    return (findSymbolByAddress(module, sector, 2, location));
  else if (ptc)
    return (findSymbolByAddress(0, 017, 2, location));
  else
    return (findSymbolByAddress(module, 017, 2, location));
}

// Find a line number in the source table.  Return a pointer to the source-table
// entry or NULL if not found.  The lineNumber string can include an assembly
// name.
assembly_t *lineNumberAssembly;
sourceLine_t *
findLineNumber(char *lineNumberString)
{
  int i, start = 0, end = numAssemblies, lineNumber;
  char *ss, *assemblyName = NULL;
  assembly_t *assembly = assemblies;
  sourceLine_t *sourceLine = NULL;

  lineNumberAssembly = NULL;

  ss = strstr(lineNumberString, ":");
  if (ss != NULL)
    {
      *ss = 0;
      assemblyName = lineNumberString;
      lineNumber = atoi(ss + 1);
      *ss = ':';
    }
  else
    lineNumber = atoi(lineNumberString);
  if (assemblyName != NULL)
    {
      assembly = findAssemblyByName(assemblyName);
      if (assembly == NULL)
        {
          printf("No such assembly.\n");
          return (NULL);
        }
      start = assembly - assemblies;
      end = start + 1;
    }

  for (; start < end; start++, assembly++)
    for (i = 0; i < assembly->numSourceLines; i++)
      if (assembly->sourceLines[i].lineNumber == lineNumber)
        {
          if (sourceLine == NULL)
            {
              sourceLine = &assembly->sourceLines[i];
              lineNumberAssembly = assembly;
            }
          else
            printf("Source line-number specification is not unique.\n");
        }
  return (sourceLine);

}

// Print block of source-code lines.  The start and end parameters
// are not line numbers, but are indexes into the sourceLine_t array.
void
printSourceBlock(assembly_t *assembly, int start, int end)
{
  int i, j;
  int module, sector, syllable, location, assembled, dm, ds;
  sourceLine_t *sourceLine;
  char c;
  breakpoint_t *breakpoint;
  if (start < 0)
    start = 0;
  if (end > assembly->numSourceLines)
    end = assembly->numSourceLines;
  printf("Assembly %s:\n", assembly->name);
  for (i = start, sourceLine = &assembly->sourceLines[start]; i < end;
      i++, sourceLine++)
    {
      module = sourceLine->module;
      sector = sourceLine->sector;
      syllable = sourceLine->syllable;
      location = sourceLine->loc;
      assembled = sourceLine->assembled;
      dm = sourceLine->dm;
      ds = sourceLine->ds;
      c = ' ';
      for (j = 0, breakpoint = breakpoints; j < numBreakpoints;
          j++, breakpoint++)
        if (module == breakpoint->module && sector == breakpoint->sector
            && syllable == breakpoint->syllable
            && location == breakpoint->location)
          {
            c = '*';
            break;
          }
      printf("%6d:%c  %o-%02o-%o-%03o %o-%02o %05o   %s\n",
          assembly->sourceLines[i].lineNumber, c, module, sector, syllable,
          location, dm, ds, assembled, assembly->sourceLines[i].line);
    }
}

// Parse an input address string.
enum addressType_t
{
  atCode, atData, atPio, atCio, atPrs, atNone
};
enum addressType_t
parseInputAddress(char *string, int *module, int *sector, int *syllable,
    int *location)
{
  char s[256];

  //if (!strcasecmp(string, "PRS"))
  //  return (atPrs);
  if (4
      == sscanf(string, "%o-%o-%o-%o%s", module, sector, syllable, location, s))
    return (atCode);
  if (3 == sscanf(string, "%o-%o-%o%s", module, sector, location, s))
    return (atData);
  if (strlen(string) > 3 && 1 == sscanf(&string[3], "-%o%s", location, s))
    {
      if (!strncasecmp(string, "PIO", 3))
        return (atPio);
      else if (!strncasecmp(string, "CIO", 3))
        return (atCio);
      else if (!strncasecmp(string, "PRS", 3))
        return (atPrs);
    }
  return (atNone);
}

// Convert an integer to binary.  The output buffer must be
// padTo+1 bytes or longer.  Returns 0 on success or 1 on failure.
int
toBinary(int value, int padTo, char *buffer)
{
  buffer[padTo] = 0;
  while (padTo > 0)
    {
      padTo--;
      if ((value & 1) == 0)
        buffer[padTo] = '0';
      else
        buffer[padTo] = '1';
      value = value >> 1;
    }
  return (value != 0);
}

// Format a value fetched from code or data memory, or PIO/CIO port.
char formattedFetchedValue[64];
void
formatFetchedValue(int value, char type /* o, d, or b */,
    int size /* 0 for code, 1 or anything else */, int syllable /* 0, 1, 2 */)
{
  strcpy(formattedFetchedValue, "unknown");
  if (value == -1 && size)
    sprintf(formattedFetchedValue, "empty data location");
  else if (value == -1 && !size)
    sprintf(formattedFetchedValue, "empty code location");
  else if (type == 'o' && size)
    sprintf(formattedFetchedValue, "%09o (%09o)", value, value << 1);
  else if (type == 'o' && !size)
    sprintf(formattedFetchedValue, "%05o (%05o)", value,
        value << (syllable ? 2 : 1));
  else if (type == 'd')
    {
      if (size && (value & 0200000000) != 0)
        value = -(value & 0177777777);
      sprintf(formattedFetchedValue, "%d", value);
    }
  else if (type == 'b')
    {
      int numBits = 26;
      if (!size)
        numBits = 13;
      toBinary(value, numBits, formattedFetchedValue);
    }
}

assembly_t *assemblySourceLineByAddress;
int
findSourceLineByAddress(int module, int sector, int syllable, int location)
{

  assemblySourceLineByAddress = NULL;

  // Search for the matching source line.  We check both the spec'd
  // syllable and syllable "2" (a data word spanning both syllables
  // 0 and 1) for emptiness, because the self-modifying nature of the
  // code sometimes blurs the lines.

  if (state.core[module][sector][syllable][location] != -1
      || state.core[module][sector][2][location] != -1)
    {
      int i;
      assembly_t *assembly;
      int assemblyNumber;
      for (assemblyNumber = 0, assembly = assemblies;
          assemblyNumber < numAssemblies; assemblyNumber++, assembly++)
        {
          for (i = 0; i < assembly->numSourceLines; i++)
            {
              if (assembly->sourceLines[i].module != module)
                continue;
              if (assembly->sourceLines[i].sector != sector)
                continue;
              if (assembly->sourceLines[i].syllable != syllable)
                continue;
              if (assembly->sourceLines[i].loc != location)
                continue;
              assemblySourceLineByAddress = assembly;
              return (i);
            }
        }
    }
  return (-1);
}

// The disassembly process works as follows.  First, setupDisassembly()
// is used to setup up the state of the process properly.  It can be
// set up either with a hopStructure_t, or else (if the pointer to the
// structure is NULL), a HOP constant.  That setup sets the instruction
// sector, the starting instruction address, and the starting data
// sector.  Actually performing the dissasembly is to successively
// use the disassemble() function, which not only disassembles the
// current instruction, but also sets the state properly for the next
// instruction.  The range of instructions disassembled has to reside
// in a single sector.
struct
{
  int valid;
  int error;
  int im, is, s, loc, dm, ds;
} disassemblyState =
  { 0 };
int
setupDisassembly(uint32_t hop, hopStructure_t *hs)
{
  hopStructure_t hsl;
  disassemblyState.valid = 0;
  disassemblyState.error = 0;
  if (hs == NULL)
    {
      hs = &hsl;
      if (parseHopConstant(hop, hs))
        return (1);
    }
  else
    {
      memcpy(&hsl, hs, sizeof(hopStructure_t));
      hs = &hsl;
    }
  if (hs->im < 0 || hs->im > 7)
    return (1);
  disassemblyState.im = hs->im;
  if (hs->is < 0 || hs->is > 017)
    return (1);
  disassemblyState.is = hs->is;
  if (hs->s < 0 || hs->s > 1)
    return (1);
  disassemblyState.s = hs->s;
  if (hs->loc < 0 || hs->loc > 0377)
    return (1);
  disassemblyState.loc = hs->loc;
  if (hs->dm < 0 || hs->dm > 7)
    return (1);
  disassemblyState.dm = hs->dm;
  if (hs->ds < 0 || hs->ds > 017)
    return (1);
  disassemblyState.ds = hs->ds;
  disassemblyState.valid = 1;
  return (0);
}
char *
disassemble(void)
{
  static char lineBuffer[256];
  char *opcode, *lhs, operandString[128];
  uint16_t instruction;
  uint8_t op, operand, a8, a9, a91;
  hopStructure_t hsc;
  symbol_t *lhsSymbol = NULL, *operandSymbol = NULL;
  int isHopOperand = 0, isUsualOperand = 0, isTraOperand = 0, isLiteralOperand =
      0, originalInhibit = inhibitFetchMessages;
  int m = 0, n = 0;

  inhibitFetchMessages = 1;

  if (!disassemblyState.valid)
    {
      m += sprintf(&lineBuffer[m], "(disassembly process not initialized)");
      goto error;
    }

  m += sprintf(&lineBuffer[m], "%o-%02o-%o-%03o %o-%02o ", disassemblyState.im,
      disassemblyState.is, disassemblyState.s, disassemblyState.loc,
      disassemblyState.dm, disassemblyState.ds);
  if (disassemblyState.loc > 0377)
    {
      m += sprintf(&lineBuffer[m], "(address past end of sector)");
      goto error;
    }

  lhsSymbol = findSymbolByAddress(disassemblyState.im, disassemblyState.is,
      disassemblyState.s, disassemblyState.loc);
  if (lhsSymbol == NULL)
    lhs = "";
  else
    lhs = lhsSymbol->name;

  if (fetchInstruction(disassemblyState.im, disassemblyState.is,
      disassemblyState.s, disassemblyState.loc, &instruction,
      &instructionFromDataMemory))
    {
      m += sprintf(&lineBuffer[m], "(no instruction at current address)");
      goto error;
    }
  m += sprintf(&lineBuffer[m], "%05o   ", instruction);

  // Parse instruction into fields.
  op = instruction & 017;
  a9 = (instruction >> 4) & 1;
  operand = (instruction >> 5) & 0377;
  a8 = (operand >> 7) & 1;
  a91 = (a9 << 8) | operand;

  // Execute the instruction.
  if (op == 000)
    {
      opcode = "HOP";
      isHopOperand = 1;
    }
  else if (!ptc && op == 001)
    {
      opcode = "MPY";
      isUsualOperand = 1;
    }
  else if (!ptc && op == 005)
    {
      opcode = "MPH";
      isUsualOperand = 1;
    }
  else if (ptc && op == 001)
    {
      opcode = "PRS";
      isLiteralOperand = 1;
    }
  else if (ptc && op == 005)
    {
      opcode = "CIO";
      isLiteralOperand = 1;
    }
  else if (op == 002)
    {
      opcode = "SUB";
      isUsualOperand = 1;
    }
  else if (!ptc && op == 003)
    {
      opcode = "DIV";
      isUsualOperand = 1;
    }
  else if (op == 004)
    {
      opcode = "TNZ";
      isTraOperand = 1;
    }
  else if (op == 006)
    {
      opcode = "AND";
      isUsualOperand = 1;
    }
  else if (op == 007)
    {
      opcode = "ADD";
      isUsualOperand = 1;
    }
  else if (op == 010)
    {
      opcode = "TRA";
      isTraOperand = 1;
    }
  else if ((!ptc && op == 011) || (ptc && op == 015))
    {
      opcode = "XOR";
      isUsualOperand = 1;
    }
  else if (op == 012)
    {
      opcode = "PIO";
      isLiteralOperand = 1;
    }
  else if (op == 013)
    {
      opcode = "STO";
      isUsualOperand = 1;
    }
  else if (op == 014)
    {
      opcode = "TMI";
      isTraOperand = 1;
    }
  else if ((!ptc && op == 015) || (ptc && op == 003))
    {
      opcode = "RSU";
      isUsualOperand = 1;
    }
  else if (ptc && op == 016 && a8 == 1)
    {
      opcode = "CDS";
      disassemblyState.dm = (operand >> 4) & 1;
      disassemblyState.ds = operand & 0xF;
      sprintf(operandString, "%o,%o", disassemblyState.dm, disassemblyState.ds);
    }
  else if (!ptc && op == 016 && a8 == 0 && a9 == 0)
    {
      opcode = "CDS";
      disassemblyState.dm = (operand >> 1) & 7;
      disassemblyState.ds = (operand >> 4) & 0xF;
      sprintf(operandString, "%o,%o", disassemblyState.dm, disassemblyState.ds);
    }
  else if (ptc && op == 016 && a8 == 0)
    {
      if ((operand & 0100) == 0)
        opcode = "SHL";
      else
        opcode = "SHR";
      switch (operand & 077)
        {
      case 001:
        strcpy(operandString, "1");
        break;
      case 002:
        strcpy(operandString, "2");
        break;
      case 004:
        strcpy(operandString, "3");
        break;
      case 010:
        strcpy(operandString, "4");
        break;
      case 020:
        strcpy(operandString, "5");
        break;
      case 030:
        strcpy(operandString, "6");
        break;
      default:
        strcpy(operandString, "(illegal value)");
        break;
        }
    }
  else if (!ptc && op == 016 && a8 == 0 && a9 == 1)
    {
      switch (operand)
        {
      case 000:
        opcode = "SHF";
        strcpy(operandString, "0");
        break;
      case 001:
        opcode = "SHR";
        strcpy(operandString, "1");
        break;
      case 002:
        opcode = "SHR";
        strcpy(operandString, "2");
        break;
      case 020:
        opcode = "SHL";
        strcpy(operandString, "1");
        break;
      case 040:
        opcode = "SHL";
        strcpy(operandString, "2");
        break;
      default:
        opcode = "SHF";
        strcpy(operandString, "(illegal value)");
        break;
        }
    }
  else if (!ptc && op == 016 && a8 == 1 && a9 == 1)
    {
      opcode = "EXM";
      sprintf(operandString, "%o,%o,%o", (instruction >> 4) & 7,
          (operand >> 4) & 1, operand & 0xF);
    }
  else if (op == 017)
    {
      opcode = "CLA";
      isUsualOperand = 1;
    }
  else
    {
      sprintf(lineBuffer, "(cannot disassemble value %05o)", instruction);
      goto error;
    }

  // Additional formatting of operand, by instruction type.
  if (isHopOperand)
    {
      symbol_t *operandSymbol = NULL, *hopSymbol = NULL;
      int hopValueMissing = 1, hopValue = -1, hopValueCorrupt = 1;

      operandSymbol = findSymbolByDataAddress(disassemblyState.dm,
          disassemblyState.ds, a9, operand);
      hopValueMissing = fetchData(disassemblyState.dm, a9, disassemblyState.ds,
          operand, &hopValue, &dataFromInstructionMemory);
      if (!hopValueMissing)
        {
          hopValueCorrupt = parseHopConstant(hopValue, &hsc);
          if (!hopValueCorrupt)
            hopSymbol = findSymbolByAddress(hsc.im, hsc.is, hsc.s, hsc.loc);
        }

      // To format the output operand, work downward from
      // most-preferable case to least-preferable case.
      n = 0;
      if (hopSymbol != NULL)
        n += sprintf(&operandString[n], "%s (destination), ", hopSymbol->name);
      else if (!hopValueCorrupt)
        n += sprintf(&operandString[n], "%o-%02o-%o-%03o (destination), ",
            hsc.im, hsc.is, hsc.s, hsc.loc);
      else if (hopValueMissing)
        n += sprintf(&operandString[n], "Missing HOP value, ");
      else
        n += sprintf(&operandString[n], "Corrupt HOP value, ");
      if (operandSymbol != NULL)
        n += sprintf(&operandString[n], "%s (operand)", operandSymbol->name);
      else if (a9 == 0)
        n += sprintf(&operandString[n], "%o-%02o-%03o (operand)",
            disassemblyState.dm, disassemblyState.ds, operand);
      else if (ptc)
        n += sprintf(&operandString[n], "0-17-%03o (operand)", operand);
      else
        n += sprintf(&operandString[n], "%o-17-%03o (operand)",
            disassemblyState.dm, operand);
    }
  else if (isUsualOperand)
    {
      int value;
      // The "usual operand" is a data location, possibly in the residual sector.
      operandSymbol = findSymbolByDataAddress(disassemblyState.dm,
          disassemblyState.ds, a9, operand);
      n = 0;
      if (operandSymbol != NULL)
        {
          char *prefix;
          if (isdigit(operandSymbol->name[0]))
            prefix = "=O";
          else
            prefix = "";
          n += sprintf(&operandString[n], "%s%s", prefix, operandSymbol->name);
        }
      else if (a9 == 0)
        n += sprintf(&operandString[n], "%o-%02o-%03o", disassemblyState.dm,
            disassemblyState.ds, operand);
      else if (ptc)
        n += sprintf(&operandString[n], "0-17-%03o", operand);
      else
        n += sprintf(&operandString[n], "%o-17-%03o", disassemblyState.dm,
            operand);
      if (fetchData(disassemblyState.dm, a9, disassemblyState.ds, operand,
          &value, &dataFromInstructionMemory))
        n += sprintf(&operandString[n], ", memory location is empty");
      else
        n += sprintf(&operandString[n], ", stored value = %09o", value);
    }
  else if (isTraOperand)
    {
      operandSymbol = findSymbolByAddress(disassemblyState.is,
          disassemblyState.im, a9, operand);
      if (operandSymbol == NULL)
        sprintf(operandString, "%o-%0o-%o-%03o", disassemblyState.im,
            disassemblyState.is, a9, operand);
      else
        strcpy(operandString, operandSymbol->name);
    }
  else if (isLiteralOperand)
    {
      sprintf(operandString, "%03o", a91);
    }

  m += sprintf(&lineBuffer[m], "%-8s%-8s%s", lhs, opcode, operandString);
  if (0)
    {
      error: ;
      disassemblyState.error = 1;
    }
  disassemblyState.loc++;
  inhibitFetchMessages = originalInhibit;
  return (lineBuffer);
}

////////////////////////////////////////////////////////////////////////////////

// The top-level function in this file.  It assumes that the LVDC/PTC program
// has been paused.  Information about the current register values is printed,
// and a command is accepted from the user.

// The return value is 0 on success, non-zero on failure.
int
gdbInterface(unsigned long instructionCount, unsigned long cycleCount,
    breakpoint_t *breakpoint)
{
  int retVal = 1;
  hopStructure_t hs, hs2;
  char hopBuffer[32];
  size_t count;
  int value, lineIndexInAssembly;
  static int listSize = 20;

  // runNextN is a global variable telling the LVDC/PTC instruction emulator
  // how many instructions to emulate (-1 is unlimited) before pausing next,
  // so obviously we accept user commands until this becomes non-zero.
  while (panelPause || runStepN <= 0)
    {
      int i, j, found = 0;
      enum commandTokens commandToken;
      assembly_t *assembly;

      // Print breakpoint information.
      if (breakpoint != NULL)
        {
          if (clockMultiplier != parmClockMultiplier)
            {
              printf("Restoring clock multiplier to its normal value.\n");
              clockMultiplier = parmClockMultiplier;
              setCpuTiming();
            }
          printf("Hit breakpoint #%ld at address %o-%02o-%o-%03o",
              breakpoint - breakpoints, breakpoint->module, breakpoint->sector,
              breakpoint->syllable, breakpoint->location);
          switch (breakpoint->whichType)
            {
          case 0:
            printf(" due to name match %s.\n", breakpoint->name);
            break;
          case 1:
            printf(" due to source line-number match %d.\n",
                breakpoint->number);
            break;
          case 2:
            printf(" due to address match.\n");
            break;
          default:
            printf(".\n");
            }
          if (breakpoint->temporary)
            {
              int i = breakpoint - breakpoints;
              if (i < numBreakpoints - 1)
                memmove(&breakpoints[i], &breakpoints[i + 1],
                    (numBreakpoints - i - 1) * sizeof(breakpoint_t));
              numBreakpoints--;
              printf("Temporary breakpoint deleted.\n");
            }
        }

      nextCommand: ;
      if (panelPause)
        printf(
            "\n*** CPU is paused by PTC panel ... no instructions will execute. ***\n");

      // Display registers.
      printf("\n HOP = ");
      if (formHopDescription(state.hop, 0, 0, 0, hopBuffer, &hs))
        {
          printf("%s   VAL = %-5s", hopBuffer, "n/a");
        }
      else
        {
          uint16_t instruction;
          printf("%s   VAL = ", hopBuffer);
          if (fetchInstruction(hs.im, hs.is, hs.s, hs.loc, &instruction,
              &instructionFromDataMemory))
            {
              printf("%-5s", "empty");
              value = -1;
            }
          else
            {
              value = instruction;
              printf("%05o", value);
            }
        }

      // Search for the matching source line.
      lineIndexInAssembly = findSourceLineByAddress(hs.im, hs.is, hs.s, hs.loc);
      found = (lineIndexInAssembly != -1);
      if (found)
        assembly = assemblySourceLineByAddress;

      printf("   ACC = %09o", state.acc);
      if (ptc == 0)
        printf("  P-Q = %09o", state.pq);
      printf("\n");
      formHopDescription(-1, 0, 017, 0377, hopBuffer, &hs2);
      printf("(777)= %s", hopBuffer);
      formHopDescription(-1, 0, 017, 0376, hopBuffer, &hs2);
      printf("  (776)= %s\n", hopBuffer);
      formHopDescription(state.hopSaver, 0, 0, 0, hopBuffer, &hs2);
      if (ptc)
        {
          //printf(" TYP = %d ", state.busyCountTypewriter);
          //printf(" CNT = %d ", typewriterCharsInLine);
          printf(" PRT = %d ", state.busyCountPrinter);
          printf("  CNT = %d ", state.prsParityDelayCount);
          printf("  PR1 = %09o ", state.prsDelayedParity[1]);
          printf("  PR2 = %09o ", state.prsDelayedParity[2]);
          printf("  PR3 = %09o ", state.prsDelayedParity[3]);
          printf("  CCB = %d ", state.busyCountCarriagePrinter);
          printf("  CB = %09o ", state.cio210CarrBusy);
          //printf("  264 = %09o ", state.cio264Buffer);

          printf(" INT = %09o", state.cio[0154]);
          printf("  INH = %09o", state.interruptInhibitLatches);
          printf("  INB = %d\n", state.masterInterruptLatch);
        }
      else
        {
          printf(" INT = %09o", state.pio[0137]);
          printf("  INB = %d\n", state.masterInterruptLatch);
        }
      printf(" RET = %s\n", hopBuffer);
      printf("Instructions: %lu", instructionCount);
      printf(", Cycles: %lu", cycleCount);
      printf(", Time: %f seconds\n", cycleCount * SECONDS_PER_CYCLE);
      if (found)
        {
          printf("Source line: ");
          if (numAssemblies > 1)
            printf("%s:", assembly->name);
          printf("%d\n", assembly->sourceLines[lineIndexInAssembly].lineNumber);
        }
      else
        printf("Source line not found\n");

      if (found)
        {
          sourceLine_t *sourceLine = &assembly->sourceLines[lineIndexInAssembly];
          if (value != sourceLine->assembled)
            {
              printf("Code in memory (%05o) has changed from load (%05o).\n",
                  value, sourceLine->assembled);
              printf("From source:\t%o-%02o-%o-%03o %o-%02o %05o   %s\n",
                  sourceLine->module, sourceLine->sector, sourceLine->syllable,
                  sourceLine->loc, sourceLine->dm, sourceLine->ds,
                  sourceLine->assembled, sourceLine->line);
              goto mustDisassemble;
            }
          else
            printf("%o-%02o-%o-%03o %o-%02o %05o   %s\n", sourceLine->module,
                sourceLine->sector, sourceLine->syllable, sourceLine->loc,
                sourceLine->dm, sourceLine->ds, sourceLine->assembled,
                sourceLine->line);
        }
      else
        {
          printf("From source:\t(not found)\n");
          mustDisassemble: ;
          setupDisassembly(state.hop, NULL);
          printf("Disassembled:\t%s\n", disassemble());
        }

      //nextCommand: ;

      // Get a user command.
      printf("\n> ");
      fgets(lineBuffer, sizeof(lineBuffer), stdin);
      printf("\n");
      repeatLastCommand: ;
      count = parseCommand();
      if (count < 1)
        {
          if (lastLine[0])
            {
              strcpy(lineBuffer, lastLine);
              goto repeatLastCommand;
            }
          continue;
        }
      commandToken = findCommandToken();
      switch (commandToken)
        {
      case ctHELP:
        lastLine[0] = 0;
        for (i = j = 0; commandAssociations[i].token != ctNone; i++)
          if (strlen(commandAssociations[i].syntax) > j)
            j = strlen(commandAssociations[i].syntax);
        printf("Available commands:\n");
        for (i = 0; commandAssociations[i].token != ctNone; i++)
          printf("  %-*s   %s\n", j, commandAssociations[i].syntax,
              commandAssociations[i].description);
        printf("\nNotes:\n");
        printf(" 1. Commands are not case sensitive.\n");
        printf(" 2. Command abbreviations (like S for STEP) are accepted.\n");
        printf(" 3. An empty command sometimes repeats previous command.\n");
        printf(" 4. Addresses have the following formats:\n");
        printf("    * Code memory:  M-SS-Y-LLL, where M is memory module\n");
        printf("      (0-7), SS is sector (00-17 octal), Y is syllable\n");
        printf("      (0 or 1), and LLL is offset within the sector\n");
        printf("      (000-377 octal).\n");
        printf("    * Data memory:  M-SS-LLL, where M is the memory module\n");
        printf("      (0-7), SS is the sector (00-17 octal), and LLL is the\n");
        printf("      offset within the sector (000-377 octal).\n");
        printf("    * PIO port:  PIO-LLL, where LLL is the port number\n");
        printf("      (000-777 octal).\n");
        printf("    * CIO port:  CIO-LLL, where LLL is the port number\n");
        printf("      (000-777 octal).\n");
        printf(
            "    * PRS port:  PRS-LLL, where LLL is the PRS operand number\n");
        printf("      (000-777 octal).\n");
        printf(" 5. Source line numbers (decimal) come from the input .src\n");
        printf("    file, not from the original .lvdc source-code file.\n");
        printf(" 6. A free-running emulation can be paused by hitting any\n");
        printf("    key on the keyboard.\n");
        printf(" 7. If optional assembly names ([asm:]) are omitted, then\n");
        printf("    all loaded assemblies are searched, even though naming\n");
        printf("    conflicts may occur.  Only the first match encountered\n");
        printf("    is affected by the command.\n");
        printf(" 8. For commands like \"SET ... = n\", the number n is hex\n");
        printf("    if it has leading 0x, octal if it merely has leading\n");
        printf("    0, and decimal otherwise.\n");
        printf(" 9. All data displayed from memory or written to memory does\n");
        printf("    NOT include parity bits or locations for parity bits.\n");
        goto nextCommand;
      case ctPANEL:
        if (!ptc)
          {
            printf("Not emulating PTC; no PTC front panel available.\n");
            goto nextCommand;
          }
        retVal = 0;
        goto done;
      case ctBACKTRACE:
        {
          int i, n = 20, numBacktraces = (firstEmptyBacktrace
              - firstUsedBacktrace) % MAX_BACKTRACES;
          printf("Recent HOP, TRA, TNZ, or TMI control transfers:\n");
          if (count > 1)
            n = atoi(fields[1]);
          if (n > MAX_BACKTRACES - 1)
            n = MAX_BACKTRACES - 1;
          //printf("%d %d %d %d\n", firstEmptyBacktrace, firstUsedBacktrace, numBacktraces, n);
          if (n > numBacktraces)
            n = numBacktraces;
          if (n == 0)
            {
              printf("\t(none)\n");
              goto nextCommand;
            }
          i = (firstEmptyBacktrace - n) % MAX_BACKTRACES;
          for (i = (firstEmptyBacktrace - n) % MAX_BACKTRACES;
              i != firstEmptyBacktrace; i = NEXT_BACKTRACE(i))
            {
              backtrace_t *backtrace = &backtraces[i];
              char buffer[32], *mnemonic;
              hopStructure_t hs;
              symbol_t *symbol;
              switch (backtrace->fromInstruction & 017)
                {
              case 000:
                mnemonic = "HOP";
                break;
              case 004:
                mnemonic = "TNZ";
                break;
              case 010:
                mnemonic = "TRA";
                break;
              case 014:
                mnemonic = "TMI";
                break;
              default:
                mnemonic = "TBD";
                break;
                }
              formHopDescription(backtrace->fromWhere, 0, 0, 0, buffer, &hs);
              symbol = findSymbolByAddress(hs.im, hs.is, hs.s, hs.loc);
              printf(
                  "\tCycle count = %lu, Instruction count = %lu, from instruction %05o (%s) at %s",
                  backtrace->cycleCount, backtrace->instructionCount,
                  backtrace->fromInstruction, mnemonic, buffer);
              if (symbol != NULL)
                printf(" (%s)", symbol->name);
              formHopDescription(backtrace->toWhere, 0, 0, 0, buffer, &hs);
              symbol = findSymbolByAddress(hs.im, hs.is, hs.s, hs.loc);
              printf(" to %s", buffer);
              if (symbol != NULL)
                printf(" (%s)", symbol->name);
              printf(".\n");
            }
        }
        goto nextCommand;
      case ctRUN:
        if (coldStart)
          {
            printf("Because the --cold-start command-line switch was used,\n");
            printf("this will restore the emulation to a clean start state,\n");
            printf("including all registers, memory, i/o ports, and so on.\n");
          }
        else
          {
            printf("Because the --cold-start command-line switch was not\n");
            printf("used, this will restore the state of the emulation from\n");
            printf("the most-recently created snapshot file (yaLVDC.core).\n");
            printf("If your desire is instead to have a completely clean\n");
            printf("startup, exit yaLVDC and rerun it with --cold-start.\n");
            printf("Or, manually delete the core file before proceeding.\n");
          }
        printf("Are you sure?  Input Y to proceed, anything else to cancel: ");
        fgets(lineBuffer, sizeof(lineBuffer), stdin);
        printf("\n");
        if (toupper(lineBuffer[0]) == 'Y')
          {
            state.restart = 1;
            printf("Restoring state, restarting emulation.\n");
            retVal = 0;
            goto done;
          }
        else
          printf("*** Canceled ***\n");
        goto nextCommand;
      case ctX:
        if (count == 2 || (count >= 3 && fields[1][0] == '/'))
          {
            int module, sector, syllable, location, printCount = 1;
            char formatType = 'o', ss[256], *adrField;
            enum addressType_t at;
            if (count >= 3 && fields[1][0] == '/')
              {
                adrField = fields[2];
                if (2
                    != sscanf(fields[1], "/%d%c%s", &printCount, &formatType,
                        ss))
                  {
                    formatType = 'o';
                    if (1 != sscanf(fields[1], "/%d%s", &printCount, ss))
                      {
                        printCount = 1;
                        if (1 != sscanf(fields[1], "/%c%s", &formatType, ss))
                          {
                            printf("Unrecognized format %s\n", fields[1]);
                            break;
                          }
                      }
                  }
                if (formatType != 'b' && formatType != 'd' && formatType != 'o')
                  {
                    printf("Unrecognized format %s\n", fields[1]);
                    break;
                  }
              }
            else
              adrField = fields[1];
            if (adrField[0] == '&')
              {
                symbol_t *symbol;
                symbol = findSymbol(adrField + 1, 1);
                if (symbol != NULL)
                  {
                    at = atCode;
                    module = symbol->module;
                    sector = symbol->sector;
                    syllable = symbol->syllable;
                    location = symbol->loc;
                  }
                else
                  {
                    symbol = findSymbol(adrField + 1, 0);
                    if (symbol != NULL)
                      {
                        at = atData;
                        module = symbol->module;
                        sector = symbol->sector;
                        syllable = 2;
                        location = symbol->loc;
                      }
                  }
              }
            else
              at = parseInputAddress(adrField, &module, &sector, &syllable,
                  &location);
            for (; printCount > 0; printCount--)
              {
                switch (at)
                  {
                case atCode:
                  if (module < 0 || module > 7 || sector < 0 || sector > 017
                      || syllable < 0 || syllable > 1 || location < 0
                      || location > 0377)
                    goto badAddressX;
                  formatFetchedValue(
                      state.core[module][sector][syllable][location],
                      formatType, 0, syllable);
                  printf("%o-%02o-%o-%03o: %s\n", module, sector, syllable,
                      location, formattedFetchedValue);
                  location++;
                  break;
                case atData:
                  if (module < 0 || module > 7 || sector < 0 || sector > 017
                      || location < 0 || location > 0377)
                    goto badAddressX;
                  formatFetchedValue(state.core[module][sector][2][location],
                      formatType, 1, 2);
                  printf("%o-%02o-%03o: %s\n", module, sector, location,
                      formattedFetchedValue);
                  location++;
                  break;
                case atPio:
                  if (location < 0 || location > 0777)
                    goto badAddressX;
                  formatFetchedValue(state.pio[location], formatType, 1, 2);
                  printf("PIO-%03o: %s\n", location, formattedFetchedValue);
                  location++;
                  break;
                case atCio:
                  if (location < 0 || location > 0777)
                    goto badAddressX;
                  formatFetchedValue(state.cio[location], formatType, 1, 2);
                  printf("CIO-%03o: %s\n", location, formattedFetchedValue);
                  location++;
                  break;
                case atPrs:
                  if (location < 0 || location > 0777)
                    goto badAddressX;
                  formatFetchedValue(state.prs[location], formatType, 1, 2);
                  printf("PRS-%03o: %s\n", location, formattedFetchedValue);
                  break;
                default:
                  printf("Unrecognized format\n");
                  break;
                  }
              }
          }
        else
          printf("Unrecognized command\n");
        if (0)
          {
            badAddressX: ;
            printf("Nonexistent address.\n");
          }
        goto nextCommand;
      case ctSET:
        {
          int assignment = 0;
          if (count > 1)
            {
              if (!strcasecmp(fields[1], "variable") || fields[1][0] == '*')
                assignment = 1;
              else if (isalpha(fields[1][0])
                  && (strstr(fields[1], "=") != NULL
                      || (count > 2 && strstr(fields[2], "=") != NULL)))
                assignment = 1;
            }
          if (count >= 3 && !strcasecmp(fields[1], "listsize"))
            listSize = atoi(fields[2]);
          else if (assignment)
            {
              // At this point, we know that the command can't be anything _other_
              // than an assignment of a value to a variable or a memory location,
              // but we don't know that is actually valid wither in format or data.
              int start = 1, intValue, overflow, conflict = 0;
              char *equal, *destination, *value, *format, dummy[256];
              int module, sector, syllable, location;
              int32_t *destinationPointer;
              enum addressType_t at;
              if (!strcasecmp(fields[start], "variable")) // fields[1] literally "variable".
                start++; // ... so the assignment begins at fields[2].
              if (start >= count)
                goto badSetCommand;
              // Because we don't know whether/how the '=' is surrounded by spaces,
              // nor even that the '=' is present, the value and the destination for
              // the assignment may be spread out over fields[start], fields[start+1],
              // and fields[start+2].  Consequently, we to do some parsing to find
              // the fields we need and verify the format.
              destination = fields[start];
              equal = strstr(fields[start], "=");
              if (equal != NULL) // fields[start] includes the "=".
                {
                  *equal = 0;
                  if (equal[1] != 0)
                    value = equal + 1;
                  else
                    value = fields[start + 1];
                }
              else if (fields[start + 1][0] != '=')
                goto badSetCommand;
              else
                {
                  if (fields[start + 1][1] != 0)
                    value = &fields[start + 1][1];
                  else if (start + 2 >= count)
                    goto badSetCommand;
                  else
                    value = fields[start + 2];
                }
              // The strings named "destination" and "value" are now set.
              // Parse the value to determine its format, and convert it
              // to an integer.
              if (!strncasecmp(value, "0x", 2))
                {
                  value += 2;
                  format = "%x%s";
                }
              else if (value[0] == '0')
                format = "%o%s";
              else
                format = "%d%s";
              if (1 != sscanf(value, format, &intValue, dummy))
                goto badSetCommand;

              // Determine the address at which to store the value.
              at = atNone;
              if (destination[0] == '*')
                {
                  at = parseInputAddress(destination + 1, &module, &sector,
                      &syllable, &location);
                }
              else
                {
                  symbol_t *symbol;
                  symbol = findSymbol(destination, 0);
                  if (symbol != NULL)
                    {
                      at = atData;
                      module = symbol->module;
                      sector = symbol->sector;
                      syllable = 2;
                      location = symbol->loc;
                    }
                  else
                    {
                      symbol = findSymbol(destination, 1);
                      if (symbol != NULL)
                        {
                          at = atCode;
                          module = symbol->module;
                          sector = symbol->sector;
                          syllable = symbol->syllable;
                          location = symbol->loc;
                        }
                    }
                }
              if (at == atNone)
                goto badSetCommand;
              // Range checks.
              if (at == atCode || at == atData)
                if ((ptc && module > 1) || module < 0 || module > 7
                    || sector < 0 || sector > 017 || syllable < 0
                    || syllable > 2 || location < 0 || location > 0377)
                  {
                    printf("Code or data memory address out of range.\n");
                    goto badSetCommand;
                  }
              if (at == atPio && (location < 0 || location > 0777))
                {
                  printf("PIO port out of range.\n");
                  goto badSetCommand;
                }
              if (at == atCio && (location < 0 || location > 0777))
                {
                  printf("CIO port out of range.\n");
                  goto badSetCommand;
                }
              if (at == atCode)
                {
                  overflow = intValue & ~017777;
                  if (overflow != 0)
                    {
                      printf("Value out of range.\n");
                      goto badSetCommand;
                    }
                }
              else
                {
                  overflow = intValue & ~0377777777;
                  if (overflow != 0 && overflow != ~0377777777)
                    {
                      printf("Value out of range.\n");
                      goto badSetCommand;
                    }
                  intValue &= 0377777777;
                }
              // Sanity clause.
              conflict = 0;
              switch (at)
                {
              case atCode:
                printf(
                    "Note that the destination address is in code memory.\n");
                destinationPointer =
                    &state.core[module][sector][syllable][location];
                if (state.core[module][sector][2][location] != -1)
                  {
                    conflict = 1;
                    printf(
                        "Note that this will conflict with data memory contents.\n");
                  }
                break;
              case atData:
                destinationPointer = &state.core[module][sector][2][location];
                if (state.core[module][sector][0][location] != -1
                    || state.core[module][sector][1][location] != -1)
                  {
                    conflict = 1;
                    printf(
                        "Note that this will conflict with code memory contents.\n");
                  }
                break;
              case atPio:
                destinationPointer = &state.pio[location];
                state.pioChange = location;
                break;
              case atCio:
                destinationPointer = &state.cio[location];
                state.cioChange = location;
                break;
              case atPrs:
                destinationPointer = &state.prs[location];
                state.prsChange = location;
              default:
                break;
                }
              if (conflict || at == atCode)
                {
                  printf(
                      "Are you sure? Input Y to continue, anything else to cancel: ");
                  fgets(lineBuffer, sizeof(lineBuffer), stdin);
                  printf("\n");
                  if (toupper(lineBuffer[0]) != 'Y')
                    {
                      printf("*** Canceled ***\n");
                      goto nextCommand;
                    }
                }
              // Perform the assignment.
              if (*destinationPointer == -1)
                printf("Overwriting empty location with %09o.\n", intValue);
              else
                printf("Overwriting value %09o with %09o.\n",
                    *destinationPointer, intValue);
              *destinationPointer = intValue;
              if (at == atPio || at == atCio || at == atPrs)
                processInterruptsAndIO();
            }
          else
            printf("Unrecognized SET command.\n");
        }
        if (0)
          {
            badSetCommand: ;
            printf("Illegal SET command.\n");
          }
        goto nextCommand;
      case ctSHOW:
        if (count >= 2 && !strcasecmp(fields[1], "listsize"))
          printf("Default block size for LIST is %d lines.\n", listSize);
        goto nextCommand;
      case ctDISASSEMBLE:
        if (count >= 3 || count < 2)
          {
            int im = hs.im, is = hs.is, s = hs.s, startloc = hs.loc, endloc,
                dm = hs.dm, ds = hs.ds, warn = 1;
            if (count == 3 && strcmp(fields[1], "-")
                && 2 == sscanf(fields[2], "%o-%o", &dm, &ds) && dm <= 7
                && ds <= 017)
              {
                endloc = startloc - 1;
                startloc -= listSize;
                if (startloc < 0)
                  startloc = 0;
                if (endloc < 0)
                  endloc = 0;
              }
            else if (count == 1)
              {
                warn = 0;
                endloc = startloc + listSize - 1;
                if (endloc > 0377)
                  endloc = 0377;
              }
            else if (count >= 4
                && 4
                    == sscanf(fields[1], "%o-%o-%o-%o", &im, &is, &s, &startloc)
                && 1 == sscanf(fields[2], "%o", &endloc)
                && 2 == sscanf(fields[3], "%o-%o", &dm, &ds) && im <= 7
                && is <= 017 && s <= 1 && startloc <= 0377 && endloc <= 0377
                && dm <= 7 && ds <= 017)
              {
              }
            else
              {
                printf("Invalid arguments.\n");
                goto nextCommand;
              }
            if (warn)
              printf("Disassembling (note: starting DM/DS not known):\n");
            else
              printf("Disassembling:\n");
            if (endloc < startloc)
              printf("\t(empty address range)\n");
            else
              {
                hopStructure_t dhs;
                dhs.im = im;
                dhs.is = is;
                dhs.s = s;
                dhs.loc = startloc;
                dhs.dm = dm;
                dhs.ds = ds;
                if (setupDisassembly(-1, &dhs))
                  printf("Unable to set up disassembly.\n");
                else
                  for (; startloc <= endloc; startloc++)
                    {
                      printf("%10s%s\n", "", disassemble());
                    }
              }
          }
        goto nextCommand;
      case ctLIST:
        {
          char *colon = NULL;
          if (count > 1)
            colon = strstr(fields[1], ":");
          if (count == 1 && found)
            printSourceBlock(assembly, lineIndexInAssembly,
                lineIndexInAssembly + listSize);
          else if (count < 2)
            {
            }
          else if (!strcmp(fields[1], "-") && found)
            printSourceBlock(assembly, lineIndexInAssembly - listSize,
                lineIndexInAssembly);
          else if ((colon == NULL && isdigit(fields[1][0]))
              || (colon != NULL && isdigit(colon[1])))
            {
              sourceLine_t *sourceLine;
              sourceLine = findLineNumber(fields[1]);
              if (sourceLine == NULL)
                printf("Line number not found.\n");
              else
                printSourceBlock(lineNumberAssembly,
                    sourceLine - lineNumberAssembly->sourceLines,
                    sourceLine - lineNumberAssembly->sourceLines + listSize);
            }
          else if ((colon == NULL && isalpha(fields[1][0]))
              || (colon != NULL && isalpha(colon[1])))
            {
              symbol_t *symbol;
              symbol = findSymbol(fields[1], 1);
              if (symbol == NULL)
                printf("Symbol not found.\n");
              else
                {
                  int index = findSourceLineByAddress(symbol->module,
                      symbol->sector, symbol->syllable, symbol->loc);
                  printSourceBlock(assemblySourceLineByAddress, index,
                      index + listSize);
                }
            }
          else
            printf("Unrecognized command.\n");
        }
        goto nextCommand;
      case ctQUIT:
        lastLine[0] = 0;
        goto done;
      case ctNEXT:
      case ctSTEP:
        inNextNotStep = (commandToken == ctNEXT);
        inNextHop = 0;
        if (count == 1)
          runStepN = 1;
        else
          runStepN = atoi(fields[1]);
        strcpy(lastLine, lineBuffer);
        break;
      case ctCONTINUE:
        runStepN = INT_MAX;
        strcpy(lastLine, lineBuffer);
        break;
      case ctINFO:
        if (count >= 2)
          {
            int i;
            breakpoint_t *breakpoint;
            assembly_t *assembly;
            if (!strcasecmp(fields[1], "assemblies"))
              {
                if (numAssemblies <= 0)
                  printf("No assemblies are loaded.\n");
                else
                  for (i = 0, assembly = assemblies; i < numAssemblies;
                      i++, assembly++)
                    printf(
                        "Assembly %s, %d symbols, %d source lines, %d code words, %d data words.\n",
                        assembly->name, assembly->numSymbols,
                        assembly->numSourceLines, assembly->codeWords,
                        assembly->dataWords);
              }
            else if (!strcasecmp(fields[1], "breakpoints"))
              {
                if (numBreakpoints <= 0)
                  printf("No breakpoints are set.\n");
                for (i = 0, breakpoint = breakpoints; i < numBreakpoints;
                    i++, breakpoint++)
                  {
                    printf("Breakpoint (%s) at %o-%02o-%o-%03o",
                        breakpoint->temporary ? "temporary" : "permanent",
                        breakpoint->module, breakpoint->sector,
                        breakpoint->syllable, breakpoint->location);
                    switch (breakpoint->whichType)
                      {
                    case 0:
                      printf(", name match %s.\n", breakpoint->name);
                      break;
                    case 1:
                      printf(", source line-number match %d.\n",
                          breakpoint->number);
                      break;
                    case 2:
                      printf(", address match.\n");
                      break;
                    default:
                      printf(".\n");
                      }
                  }
              }
            else if (!strcasecmp(fields[1], "break"))
              {
                if (numBreakpoints <= 0)
                  printf("No breakpoints are set.\n");
                for (i = 0, breakpoint = breakpoints; i < numBreakpoints;
                    i++, breakpoint++)
                  {
                    printf("%d: %o-%02o-%o-%03o (%s)\n", i, breakpoint->module,
                        breakpoint->sector, breakpoint->syllable,
                        breakpoint->location,
                        breakpoint->temporary ? "temporary" : "permanent");
                  }
              }
            else
              printf("Unrecognized INFO option.\n");
          }
        goto nextCommand;
      case ctBREAK:
      case ctCLEAR:
      case ctTBREAK:
        if (count >= 2)
          {
            int i, is, im, s, loc, ok = 0, whichType;
            char *colon;
            breakpoint_t *breakpoint;

            colon = strstr(fields[1], ":");
            if (colon == NULL && fields[1][0] == '*')
              {
                whichType = 2;
                if (4
                    != sscanf(&fields[1][1], "%o-%o-%o-%o", &im, &is, &s, &loc)
                    || (s != 1 && s != 0))
                  printf("Not a location in code memory.\n");
                else
                  ok = 1;
              }
            else if ((colon == NULL && isdigit(fields[1][0]))
                || (colon != NULL && isdigit(colon[1])))
              {
                sourceLine_t *sourceLine;
                whichType = 1;
                sourceLine = findLineNumber(fields[1]);
                if (sourceLine != NULL)
                  {
                    im = sourceLine->module;
                    is = sourceLine->sector;
                    s = sourceLine->syllable;
                    loc = sourceLine->loc;
                    ok = 1;
                  }
                else
                  printf("Line number not found.\n");
              }
            else if ((colon == NULL && isalpha(fields[1][0]))
                || (colon != NULL && isalpha(colon[1])))
              {
                symbol_t *symbol;
                whichType = 0;
                symbol = findSymbol(fields[1], 1);
                if (symbol != NULL)
                  {
                    im = symbol->module;
                    is = symbol->sector;
                    s = symbol->syllable;
                    loc = symbol->loc;
                    ok = 1;
                  }
                else
                  printf("Symbol not found.\n");
              }
            else
              printf("Breakpoint type not recognized.\n");
            // If an address has been determined at which the breakpoint is
            // desired ...
            if (ok)
              {
                // Find existing breakpoint, if any.
                for (i = 0, breakpoint = breakpoints; i < numBreakpoints;
                    i++, breakpoint++)
                  if (im == breakpoint->module && is == breakpoint->sector
                      && s == breakpoint->syllable
                      && loc == breakpoint->location)
                    {
                      if (commandToken == ctCLEAR)
                        {
                          if (i < numBreakpoints - 1)
                            memmove(&breakpoints[i], &breakpoints[i + 1],
                                (numBreakpoints - i - 1)
                                    * sizeof(breakpoint_t));
                          numBreakpoints--;
                          printf("Breakpoint #%d deleted.\n", i);
                        }
                      else if (breakpoint->temporary && commandToken == ctBREAK)
                        {
                          breakpoint->temporary = 0;
                          printf(
                              "Existing breakpoint changed from temporary to permanent\n");
                        }
                      else if (!breakpoint->temporary
                          && commandToken == ctTBREAK)
                        {
                          breakpoint->temporary = 1;
                          printf(
                              "Existing breakpoint changed from permanent to temporary\n");
                        }
                      else
                        printf("Breakpoint already exists.\n");
                      ok = 0;
                      break;
                    }
              }
            if (ok && commandToken != ctCLEAR)
              {
                // If the breakpoint doesn't already exist ...
                if (i >= numBreakpoints)
                  {
                    if (numBreakpoints >= MAX_BREAKPOINTS)
                      printf("The breakpoint table is full already.\n");
                    else
                      {
                        breakpoints[i].module = im;
                        breakpoints[i].sector = is;
                        breakpoints[i].syllable = s;
                        breakpoints[i].location = loc;
                        breakpoints[i].whichType = whichType;
                        breakpoints[i].temporary = (commandToken == ctTBREAK);
                        if (whichType == 1)
                          breakpoints[i].number = atoi(fields[1]);
                        if (whichType == 0)
                          strcpy(breakpoints[i].name, fields[1]);
                        numBreakpoints++;
                      }
                  }
              }
          }
        goto nextCommand;
      case ctJUMP:
      case ctGOTO:
        {
          int hop, dm, ds;
          hopStructure_t hs;
          char c;
          symbol_t *symbol = NULL;
          if (count == 2)
            {
              if (1 == sscanf(fields[1], "%o%c", &hop, &c) && hop >= 0
                  && hop <= 0400000000)
                goto foundJump;
              else if (isalpha(fields[1][0]))
                {
                  symbol = findSymbol(fields[1], 0);
                  if (symbol == NULL)
                    {
                      printf("Symbol not found in data memory.\n");
                      goto nextCommand;
                    }
                  if (fetchData(symbol->module, 0, symbol->sector, symbol->loc, &hop, &dataFromInstructionMemory))
                    {
                      printf("Cannot fetch value of HOP constant from memory.\n");
                      goto nextCommand;
                    }
                  goto foundJump;
                }
            }
          else if (count == 3 && 2 == sscanf(fields[2], "%o-%o%c", &dm, &ds, &c))
            {
              if (fields[1][0] == '*')
                {
                  int module, sector, syllable, location;
                  if (4 == sscanf(fields[1], "*%o-%o-%o-%o%c", &module, &sector, &syllable, &location, &c))
                    {
                      hs.im = module;
                      hs.is = sector;
                      hs.s = syllable;
                      hs.loc = location;
                      goto hopDescriptionFound;
                    }
                }
              else if (isalpha(fields[1][0]))
                {
                  symbol = findSymbol(fields[1], 1);
                  if (symbol == NULL)
                    {
                      printf("Symbol not found in code memory.\n");
                      goto nextCommand;
                    }
                  hs.im = symbol->module;
                  hs.is = symbol->sector;
                  hs.s = symbol->syllable;
                  hs.loc = symbol->loc;
                  hopDescriptionFound:;
                  hs.dm = dm;
                  hs.ds = ds;
                  hs.dupdn = 0;
                  hs.dupin = 0;
                  if (formHopConstant(&hs, &hop))
                    {
                      printf("Cannot form HOP constant.\n");
                      goto nextCommand;
                    }
                  goto foundJump;
                }
            }
          printf("Illegal syntax.\n");
          goto nextCommand;
          foundJump: ;
          state.hop = hop;
          if (commandToken == ctJUMP)
            {
              runStepN = INT_MAX;
              break;
            }
          else
            goto nextCommand;
        }
      case ctDELETE:
        if (count < 2)
          {
            numBreakpoints = 0;
            printf("All breakpoints deleted.\n");
          }
        else
          {
            i = atoi(fields[1]);
            if (i >= 0 && i < numBreakpoints)
              {
                if (i < numBreakpoints - 1)
                  memmove(&breakpoints[i], &breakpoints[i + 1],
                      (numBreakpoints - i - 1) * sizeof(breakpoint_t));
                numBreakpoints--;
                printf("Breakpoint #%d deleted.\n", i);
              }
          }
        goto nextCommand;
      case ctMULTIPLIER:
        if (count > 1)
          {
            int n;
            n = atoi(fields[1]);
            if (n > 1)
              {
                printf("Temporarily changing clock multiplier to %d.\n", n);
                clockMultiplier = n;
                setCpuTiming();
              }
          }
        goto nextCommand;
      default:
        lastLine[0] = 0;
        printf("Unknown command: %s\n", fields[0]);
        goto nextCommand;
        }
    }

  retVal = 0;
  done: ;
  return (retVal);
}
