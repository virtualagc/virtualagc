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
          sprintf(buffer, "%-30s", "illegal address");
          return (1);
        }
      if (state.core[module][sector][2][location] == -1)
        {
          sprintf(buffer, "%-30s", "empty address");
          return (1);
        }
      hopConstant = state.core[module][sector][2][location];
    }
  if (parseHopConstant(hopConstant, hs))
    {
      sprintf(buffer, "%-30s", "invalid HOP constant");
      return (1);
    }
  sprintf(buffer, "%09o (ADR=%o-%02o-%o-%03o/%o-%02o", hopConstant, hs->im, hs->is,
      hs->s, hs->loc, hs->dm, hs->ds);
  return (0);
}

////////////////////////////////////////////////////////////////////////////////

// The top-level function in this file.  It assumes that the LVDC/PTC program
// has been paused.  Information about the current register values is printed,
// and a command is accepted from the user.

// The return value is 0 on success, non-zero on failure.
int
gdbInterface(unsigned long instructionCount)
{
  int retVal = 1;
  hopStructure_t hs;
  char lineBuffer[128], fields[3][sizeof(lineBuffer)], hopBuffer[32], c;
  size_t count;
  int value;

  // runNextN is a global variable telling the LVDC/PTC instruction emulator
  // how many instructions to emulate (-1 is unlimited) before pausing next,
  // so obviously we accept user commands until this becomes non-zero.
  while (runNextN == 0)
    {

      // Display registers.
      printf("\nHOP=");
      if (formHopDescription(state.hop, 0, 0, 0, hopBuffer, &hs))
        {
          printf("%s VAL=%-5s)", hopBuffer, "n/a");
        }
      else
        {
          printf("%s VAL=", hopBuffer);
          value = state.core[hs.im][hs.is][hs.s][hs.loc];
          if (value == -1)
            printf("%-5s)", "empty");
          else
            printf("%05o)", value);
        }
      printf("  ACC=%09o", state.acc);
      c = formHopDescription(-1, 0, 17, 0377, hopBuffer, &hs) ? ' ' : ')';
      printf("  (777)=%s%c", hopBuffer, c);
      c = formHopDescription(-1, 0, 17, 0376, hopBuffer, &hs) ? ' ' : ')';
      printf("  (776)=%s%c", hopBuffer, c);
      if (ptc == 0)
        printf("  PQ=%09o", state.pq);
      printf("\n");

      printf("%12lu: ", instructionCount);

      // Search for the matching source line.
      if (state.core[hs.im][hs.is][hs.s][hs.loc] != -1)
        {
          int i, found = 0;
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
              printf("%s\n", sourceLines[i].line);
              found = 1;
              break;
            }
          if (found == 0)
            printf("(source line not found)\n");
        }

      // Get a user command.
      printf("> ");
      fgets(lineBuffer, sizeof(lineBuffer), stdin);
      count = sscanf(lineBuffer, "%s%s%s", fields[0], fields[1], fields[2]);
      // Parse the command.
      if (count < 1)
        continue;
      if (!strcasecmp(fields[0], "help"))
        {
          printf("Only the following gdb commands are implemented so far:\n");
          printf("KILL --- stop LVDC/PTC program execution\n");
          printf("S [n] --- step n instructions, default n=1.\n");
          printf("STEP [n] --- same as S [n].\n");
        }
      else if (!strcasecmp(fields[0], "kill"))
        goto done;
      else if (count <= 2
          && (!strcasecmp(fields[0], "s") || !strcasecmp(fields[0], "step")))
        {
          if (count == 1)
            runNextN = 1;
          else
            runNextN = atoi(fields[1]);
        }
      else
        {
          printf("Unimplemented command.\n");
        }
    }

  retVal = 0;
  done: ;
  return (retVal);
}
