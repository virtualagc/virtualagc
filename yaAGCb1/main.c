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
 * Filename:    main.c
 * Purpose:     The main() program of the Block 1 simulator.
 * Compiler:    GNU gcc.
 * Contact:     Ron Burkey <info@sandroid.org>
 * Reference:   http://www.ibiblio.org/apollo/index.html
 * Mods:        2016-09-03 RSB  Began.
 *              2016-09-04 RSB  Added --log.
 */

#include <stdio.h>
#include <string.h>
#include "yaAGCb1.h"

#define MAX_LOG_EXTRAS 10
int numLogExtras = 0;
uint16_t logExtras[MAX_LOG_EXTRAS];
uint16_t defaultErasable = 0;
int loggingOn = 1;

int
main(int argc, char *argv[])
{
  int i, j, startingAddress = 02030, startState = 0;
  char *ropeFile = "Solarium055.bin", *listingFile = "Solarium055.lst",
      *padFile = "Solarium055.pad";
  char command[128];
  FILE *logFile = NULL;

  // Parse the command line.
  for (i = 1; i < argc; i++)
    {
      if (!strncmp(argv[i], "--rope=", 7))
        ropeFile = &argv[i][7];
      else if (!strncmp(argv[i], "--listing=", 10))
        listingFile = &argv[i][10];
      else if (!strncmp(argv[i], "--pads=", 7))
        padFile = &argv[i][7];
      else if (1 == (sscanf(argv[i], "--go=%o", &j)) && j >= 02000 && j < 06000)
        startingAddress = j;
      else if (!strcmp(argv[i], "--run"))
        startState = -1;
      else if (!strncmp(argv[i], "--log=", 6))
        {
          logFile = fopen(&argv[i][6], "w");
          if (logFile == NULL)
            printf("Could not create log file %s\n", &argv[i][6]);
        }
      else if (1 == sscanf(argv[i], "--extra=%o", &j))
        {
          if (numLogExtras < MAX_LOG_EXTRAS && j >= 0 && j < MEMORY_SIZE)
            logExtras[numLogExtras++] = j;
          else
            printf("Illegal %s\n", argv[i]);
        }
      else if (!strcmp(argv[i], "--zero"))
        defaultErasable = 0;
      else if (!strcmp(argv[i], "--uninit"))
        defaultErasable = 0166666;
      else if (1 == sscanf(argv[i], "--port=%d", &j))
        Portnum = j;
      else if (1
          == sscanf(argv[i], "--width=%d",
              &j) && j >= MIN_LINE_LENGTH && j <= MAX_LINE_LENGTH)
        maxDisplayedLineLength = j;
      else if (1 == sscanf(argv[i], "--context=%d", &j))
        maxDisplayedContext = j;
      else
        {
          printf("Usage:\n");
          printf("\tyaAGCb1 [OPTIONS]\n");
          printf("The available OPTIONS are:\n");
          printf(
              "--rope=F     Specify name of a rope file (default Solarium055.bin).\n");
          printf(
              "--pads=F     Specify name of a pad-load file (default Solarium055.pad).\n");
          printf(
              "--listing=F  Specify name of a listing file (default Solarium055.lst).\n");
          printf("--go=OCTAL   Specify program entry point (default 02030).\n");
          printf(
              "--run        By default, the simulation starts up in a paused state.\n");
          printf(
              "             The --run switch starts it in a free-running state.\n");
          printf("--log=F      Log to a file.\n");
          printf(
              "--extra=OCT  In the --log file, add the value at the address OCT\n");
          printf("             to the log.  There can be up to %d of these.\n",
          MAX_LOG_EXTRAS);
          printf(
              "--zero       At power-up, initialize erasable 060-01777 to 0,\n");
          printf("             This is the default.\n");
          printf(
              "--uninit     At power-up, initialize erasable 060-01777 to 0166666,\n");
          printf("             rather than the default 0.\n");
          printf(
              "--port=P     Start listening on ports P through P+9. P defaults to 19671.\n");
          printf(
              "--width=N    Set initial value  of the displayed length of source-code\n");
          printf("             lines.  Default=%d, min=%d, max=%d.\n",
              maxDisplayedLineLength, MIN_LINE_LENGTH, MAX_LINE_LENGTH);
          printf(
              "--context=N  Set initial size of source-line context.  Default is %d.\n",
              maxDisplayedContext);
          return (1);
        }
    }

  // Load the rope.
  i = loadYul(ropeFile);
  if (i == 0)
    printf("Rope file %s loaded.\n", ropeFile);
  else
    {
      printf("Rope file %s not found or other error loading it.\n", ropeFile);
      return (1);
    }

  // Load the pads.
  i = loadPads(padFile);
  if (i == 0)
    printf("Pad-load file %s loaded.\n", padFile);
  else
    {
      printf("Pad-load file %s not found or other error loading it.\n",
          padFile);
      return (1);
    }

  // Load the program listing into memory.
  i = bufferTheListing(listingFile);
  if (i == 0)
    printf("Program listing %s loaded.\n", listingFile);
  else if (i == 1)
    printf("Program listing %s too big, partially loaded.\n", listingFile);
  else
    printf("Program listing %s not found or other error loading it.\n",
        listingFile);

  // Initialize the virtual AGC, which otherwise has its entire contents 0 (other than
  // the rope just loaded).
  regZ= 02030; // Starting address.
  agc.startTimeNanoseconds = getTimeNanoseconds();
  agc.instructionCountDown = startState; // Set either 0 (paused) or -1 (free running) at the start.

  // Run the virtual AGC.
  if (agc.instructionCountDown == 0)
    {
      agc.startOfPause = agc.startTimeNanoseconds;
      processConsoleDebuggingCommand(NULL);
    }
  else
    {
      printf("> "); // Visible prompt for user input (but that happens in the background, so don't wait).
      fflush(stdout); // Make sure the prompt gets printed.
    }
  while (1) // Runs forever.
    {
      sleepNanoseconds(BILLION / 10); // Sleep 0.1 seconds, so as not to peg the CPU usage.

      // Handle server stuff for socket connections used for i/o channel
      // communications.
      ChannelRoutine(&agc);

      // Execute as many virtual AGC instructions as needed to catch up to real time.
      while (agc.instructionCountDown
          && agc.countMCT
              < (getTimeNanoseconds() - agc.startTimeNanoseconds
                  - agc.pausedNanoseconds) / mctNanoseconds)
        {
          ChannelInput(&agc);
          if (executeOneInstruction(loggingOn ? logFile : NULL))
            goto pause;
          if (agc.instructionCountDown != 0)
            {
              if (agc.instructionCountDown > 0)
                {
                  agc.instructionCountDown--;
                  if (agc.instructionCountDown == 1)
                    agc.instructionCountDown = 0;
                }
              if (agc.instructionCountDown == 0)
                {
                  pause: ;
                  agc.startOfPause = getTimeNanoseconds();
                  processConsoleDebuggingCommand(NULL);
                }
            }
        }

      // Has the user entered something at the keyboard?  There's a background thread checking
      // for that.  If so, drop into console debugging mode to do something about the user's
      // input, and then proceed with the simulation.
      if (NULL != nbfgets(command, sizeof(command)))
        {
          int discardCommand;
          discardCommand = agc.instructionCountDown;
          if (agc.instructionCountDown) // Not already paused?
            agc.startOfPause = getTimeNanoseconds();
          agc.instructionCountDown = 0; // Pause now!
          processConsoleDebuggingCommand((discardCommand ? NULL : command));
          if (agc.instructionCountDown) // Get out of pause mode?
            agc.pausedNanoseconds += getTimeNanoseconds() - agc.startOfPause;
        }
    }

#ifndef SOLARIS
  return (0);
#endif
}
