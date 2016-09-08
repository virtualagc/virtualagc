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
  unsigned u, flatAddress, bank, offset;
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
      if (!strcasecmp(command, "s") || !strcasecmp(command, "t"))
        {
          agc.instructionCountDown = 1;
          return;
        }
      if (2 == sscanf(command, "%c%u", &c, &u)
          && (c == 's' || c == 'S' || c == 't' || c == 'T'))
        {
          agc.instructionCountDown = u;
          return;
        }
      if (3 == sscanf(command, "%c%o,%o", &c, &bank, &offset))
        {
          if (bank < 040 && offset >= 06000 && offset <= 07777)
            {
              flatAddress = bank * 02000 + (offset & 01777);
              if (c == 'e' || c == 'E')
                {
                  goto examineMemory;
                }
            }
        }
      else if (2 == sscanf(command, "%c%o", &c, &flatAddress))
        {
          if (flatAddress < sizeof(agc.memory) / 2)
            {
              if (c == 'e' || c == 'E')
                {
                  int i;
                  examineMemory: ;
                  for (i = 0; i < 24 && flatAddress < sizeof(agc.memory) / 2;
                      i++, flatAddress++)
                    {
                      if (flatAddress < 06000)
                        printf("%04o:  %06o\n", flatAddress,
                            agc.memory[flatAddress]);
                      else
                        printf("%02o,%04o:  %06o\n", flatAddress / 02000,
                            06000 + (flatAddress % 02000), agc.memory[flatAddress]);
                    }
                  goto reprompt;
                }
            }
        }
      if (!strcasecmp(command, "q"))
        {
          exit(0);
        }
      if (*command)
        {
          printf("         c  --- continuous run\n");
          printf("    s or t  --- single step\n");
          printf("  sN or tN  --- N single steps\n");
          printf("eN or eB,O  --- examine memory at memory location\n");
          printf("         q  --- quit\n");
        }
    }
  for (u = 0; u < MAX_LINE_LENGTH; u++)
    printf("-");
  printf("\n");
  printf("MCT: %ld   Elapsed: %ld ms   Paused: %ld ms\n", agc.countMCT,
      (getTimeNanoseconds() - agc.startTimeNanoseconds) / 1000000,
      agc.pausedNanoseconds / 1000000);
  printf(
      "  A: %06o   IN0: %05o   OUT0: %05o     Bank: %03o   CYR: %05o   ZRUPT: %05o   TIME1: %06o\n",
      regA, regIN0, regOUT0, regBank, regCYR, regZRUPT, ctrTIME1);
  printf(
      "  Q: %06o   IN1: %05o   OUT1: %05o                  SR: %05o   BRUPT: %05o   TIME2: %06o\n",
      regQ, regIN1, regOUT1, regSR, regBRUPT, ctrTIME2);
  printf(
      "  Z: %06o   IN2: %05o   OUT2: %05o   Inhint: %-3d   CYL: %05o   ARUPT: %05o   TIME3: %06o\n",
      regZ, regIN2, regOUT2, regInhint, regCYL, regARUPT, ctrTIME3);
  printf(
      " LP: %06o   IN3: %05o   OUT3: %05o                  SL: %05o   QRUPT: %05o   TIME4: %06o\n",
      regLP, regIN3, regOUT3, regSL, regQRUPT, ctrTIME4);
  printf(
      "                           OUT4: %05o                              INDEX: %05o\n",
      regOUT4, agc.INDEX);

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
  reprompt:;
  printf("> "); // Re-prompt.
  fflush(stdout);
}
