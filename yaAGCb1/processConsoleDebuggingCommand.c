/*
 * Copyright 2016 Ronald S. Burkey <info@sandroid.org>
 *
 * This file is part of yaAGC.
 *
 * yaAGC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
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
 * Filename:    processConsoleDebuggingCommand.c
 * Purpose:     Process a user command (virtual AGC is idle).
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-03 RSB  Wrote.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "yaAGCb1.h"

void
processConsoleDebuggingCommand(char *command)
{
  unsigned u, flatAddress;
  int index;
  char c, *s;

  if (command != NULL)
    {
      s = strstr(command, "\n");
      if (s != NULL)
        *s = 0;
      if (!strcasecmp(command, "c"))
        {
          agc.instructionCountDown = -1;
          return;
        }
      if (!strcasecmp(command, "s"))
        {
          agc.instructionCountDown = 1;
          return;
        }
      if (2 == sscanf(command, "%c%u", &c, &u) && (c == 's' || c == 'S'))
        {
          agc.instructionCountDown = u;
          return;
        }
      if (!strcasecmp(command, "q"))
        {
          exit(0);
        }
      if (*command)
        {
          printf("c  --- continuous run\n");
          printf("s  --- single step\n");
          printf("sN --- N single steps\n");
          printf("q  --- quit\n");
        }
    }
  for (u = 0; u < MAX_LINE_LENGTH; u++)
    printf("-");
  printf("\n");
  printf("MCT: %ld   Elapsed: %ld ms   Paused: %ld ms\n", agc.countMCT,
      (getTimeNanoseconds() - agc.startTimeNanoseconds) / 1000000,
      agc.pausedNanoseconds / 1000000);
  printf(
      "  A: %05o   IN0: %05o   OUT0: %05o     Bank: %03o   CYR: %05o   ZRUPT: %05o\n",
      regA, regIN0, regOUT0, regBank, regCYR, regZRUPT);
  printf(
      "  Q: %05o   IN1: %05o   OUT1: %05o   Relint: %-3d    SR: %05o   BRUPT: %05o\n",
      regQ, regIN1, regOUT1, regRelint, regSR, regBRUPT);
  printf(
      "  Z: %05o   IN2: %05o   OUT2: %05o   Inhint: %-3d   CYL: %05o   ARUPT: %05o\n",
      regZ, regIN2, regOUT2, regInhint, regCYL, regARUPT);
  printf(
      " LP: %05o   IN3: %05o   OUT3: %05o                  SL: %05o   QRUPT: %05o\n",
      regLP, regIN3, regOUT3, regSL, regQRUPT);
  printf("                          OUT4: %05o\n", regOUT4);

  if (regZ< 06000)
  flatAddress = regZ;
  else
  flatAddress = flatten(regBank, regZ);
  index = listingAddresses[flatAddress];
  if (index >= 0)
    {
      int i, start, end, context = 5;

      start = index - context;
      if (start < 0)
        start = 0;
      end = index + context;
      if (end >= MEMORY_SIZE)
        end = MEMORY_SIZE - 1;
      for (i = start; i <= end; i++)
        {
          printf("%c%s\n", (i == index) ? '>' : ' ', bufferedListing[i]);
        }
    }
  printf("> "); // Re-prompt.
  fflush(stdout);
}
