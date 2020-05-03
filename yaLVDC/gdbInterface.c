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
 * Filename:    gdbInterface.c
 * Purpose:     Provides a debugger interface for the LVDC/PTC emulator.
 *              in spite of the name, it's not necessarily a gdb-like
 *              interface, but I already have other functions and filenames
 *              with names like debug*, so I thought it would be prudent
 *              to name it more distinctly.
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2020-04-30 RSB  Began.
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "yaLVDC.h"

////////////////////////////////////////////////////////////////////////////////
// Utility functions.

// Create a descriptive string for a HOP constant, specified either by giving
// the constant itself, or else by module/sector/location if the constant is given
// as -1.  A char buffer[32] to store the string is one of the arguments.
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
static char lineBuffer[MAX_COMMAND_LENGTH], fields[MAX_COMMAND_FIELDS][MAX_COMMAND_LENGTH], lastLine[MAX_COMMAND_LENGTH];
int
parseCommand(void)
{
  int numFields = 0;
  char *s, *ss;

  // Get rid of any leading whitespace.
  for (s = lineBuffer; *s && isspace(*s); s++);
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
      for (; *s && isspace(*s); s++);
      if (!*s)
        goto done;

      // Again, fields[numFields] is the same length as lineBuffer,
      // so overflow is impossible.
      for (ss = fields[numFields]; *s && !isspace(*s); s++, ss++)
        *ss = *s;
      *ss = 0;
      numFields++;
    }

  done:;
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
enum commandTokens { ctSTEP, ctKILL, ctCONTINUE, ctHELP, ctNone };
typedef struct {
  enum commandTokens token;
  const char *string;
} commandAssociation_t;
commandAssociation_t commandAssociations[] = {
    { ctSTEP, "STEP" }, { ctKILL, "KILL" },{ ctCONTINUE, "CONTINUE" },
    { ctHELP, "HELP" },
    { ctNone, "" }
};
enum commandTokens
findCommandToken (void)
{
  int i, n = strlen(fields[0]);

  for (i = 0; commandAssociations[i].token != ctNone; i++)
    {
      if (!strncmp(fields[0], commandAssociations[i].string, n))
        break;
    }

  return (commandAssociations[i].token);
}

////////////////////////////////////////////////////////////////////////////////

// The top-level function in this file.  It assumes that the LVDC/PTC program
// has been paused.  Information about the current register values is printed,
// and a command is accepted from the user.

// The return value is 0 on success, non-zero on failure.
int
gdbInterface(unsigned long instructionCount, unsigned long cycleCount)
{
  int retVal = 1;
  hopStructure_t hs, hs2;
  char hopBuffer[32];
  size_t count;
  int value;

  // runNextN is a global variable telling the LVDC/PTC instruction emulator
  // how many instructions to emulate (-1 is unlimited) before pausing next,
  // so obviously we accept user commands until this becomes non-zero.
  while (runNextN <= 0)
    {
      int i, found = 0;
      enum commandTokens commandToken;

      // Display registers.
      printf("\n HOP = ");
      if (formHopDescription(state.hop, 0, 0, 0, hopBuffer, &hs))
        {
          printf("%s   VAL = %-5s", hopBuffer, "n/a");
        }
      else
        {
          printf("%s   VAL = ", hopBuffer);
          value = state.core[hs.im][hs.is][hs.s][hs.loc];
          if (value == -1)
            printf("%-5s", "empty");
          else
            printf("%05o", value);
        }

      // Search for the matching source line.
      if (state.core[hs.im][hs.is][hs.s][hs.loc] != -1)
        {
          for (i = 0; i < numSourceLines; i++)
            {
              if (sourceLines[i].module != hs.im)
                continue;
              if (sourceLines[i].sector != hs.is)
                continue;
              if (sourceLines[i].syllable != hs.s)
                continue;
              if (sourceLines[i].loc != hs.loc)
                continue;
              found = 1;
              break;
            }
          if (found == 0)
            printf("(source line not found)\n");
        }

      printf("   ACC = %09o", state.acc);
      if (ptc == 0)
        printf("  P-Q = %09o", state.pq);
      printf("\n");
      formHopDescription(-1, 0, 017, 0377, hopBuffer, &hs2);
      printf("(777)= %s", hopBuffer);
      formHopDescription(-1, 0, 017, 0376, hopBuffer, &hs2);
      printf("  (776)= %s\n", hopBuffer);
      formHopDescription(state.returnAddress, 0, 0, 0, hopBuffer, &hs2);
      printf(" RET = %s\n", hopBuffer);
      printf("Instructions: %lu", instructionCount);
      printf(", Cycles: %lu", cycleCount);
      printf(", Elapsed time: %f seconds", cycleCount * SECONDS_PER_CYCLE);
      if (found)
        printf(", Source line #: %d", sourceLines[i].lineNumber);
      else
        printf(", Source line not found");
      printf("\n");

      if (found)
        printf("%s\n", sourceLines[i].line);

      // Get a user command.
      printf("> ");
      fgets(lineBuffer, sizeof(lineBuffer), stdin);
      repeatLastCommand:;
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
        printf("HELP -- print this list of commands.\n");
        printf("KILL --- end the LVDC/PTC program emulation and exit.\n");
        printf("STEP [n] --- step n instructions, default n=1.\n");
        printf("CONTINUE --- step infinite n.\n");
        break;
      case ctKILL:
        lastLine[0] = 0;
        goto done;
      case ctSTEP:
        if (count == 1)
          runNextN = 1;
        else
          runNextN = atoi(fields[1]);
        strcpy(lastLine, lineBuffer);
        break;
      case ctCONTINUE:
        runNextN = INT_MAX;
        strcpy(lastLine, lineBuffer);
        break;
      default:
        lastLine[0] = 0;
        printf("Unknown command: %s\n", fields[0]);
        break;
      }
    }

  retVal = 0;
  done: ;
  return (retVal);
}
