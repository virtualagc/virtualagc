/*
 * Copyright 2019 Ronald S. Burkey <info@sandroid.org>
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
 * Filename:    yaLVDC.c
 * Purpose:     Emulator for LVDC CPU
 * Compiler:    GNU gcc.
 * Reference:   http://www.ibibio.org/apollo
 * Mods:        2019-09-18 RSB  I originally intended to add LVDC-emulation
 * 				capability the the yaOBC program, but I'm
 * 				just too lazy and would prefer to write it
 * 				from scratch.
 */

#include <stdio.h>
#include "yaLVDC.h"

//////////////////////////////////////////////////////////////////////////////
// Cross-platform timekeeping stuff.  Use *NIX-style functions times() and
// sysconf(_SC_CLK_TCK) for measuring time passage, and use sleepMilliseconds()
// to sleep for a while.  Note that sleepMilliseconds(0) actually does nothing,
// and does not relinquish any control.

#ifdef WIN32

#include <windows.h>
struct tms
  {
    clock_t tms_utime; /* user time */
    clock_t tms_stime; /* system time */
    clock_t tms_cutime; /* user time of children */
    clock_t tms_cstime; /* system time of children */
  };
#define _SC_CLK_TCK (1000)
#define sysconf(x) (x)
#define times(p) (clock_t)GetTickCount ()

void
sleepMilliseconds(unsigned Milliseconds)
{
  if (Milliseconds == 0)
    return;
  Sleep (Milliseconds);
}

#else // *NIX.

#include <unistd.h>
#include <time.h>
#include <sys/times.h>
void
sleepMilliseconds(unsigned Milliseconds)
{
  struct timespec Req, Rem;
  if (Milliseconds == 0)
    return;
  Req.tv_sec = Milliseconds / 1000;
  Req.tv_nsec = (Milliseconds % 1000) * 1000 * 1000; // 10 milliseconds.
  nanosleep(&Req, &Rem);
}

#endif

//////////////////////////////////////////////////////////////////////////////
// Main program.

// Length of an LVDC CPU's "computer cycle".
#define SECONDS_PER_CYCLE (168.0/2048000) // About 82us.
double cyclesPerTick;

int
main (int argc, char *argv[])
{
  int retVal = 1;
  int i;
  clock_t startingTime, currentTime;
  unsigned long cycleCount = 0;
  struct tms TmsStruct;
  unsigned long instructionCount = 0;

  // Setup and initialization.
  if (parseCommandLineArguments (argc, argv))
    goto done;
  // Note that readCore() must occur after readAssemblies(), since if present,
  // the core-memory file overrides the core-memory image from the assembler.
  if (readAssemblies (assemblyBasenames, MAX_PROGRAMS))
    goto done;
  if (coldStart == 0)
    if (readCore())
      goto done;
  dPrintouts(); // Some optional printouts for debugging.
  fflush(stdout);

  cyclesPerTick = 1.0 / (SECONDS_PER_CYCLE * sysconf(_SC_CLK_TCK));
  startingTime = times(&TmsStruct);
  if (ptc)
    state.hop = 0;
  else
    state.hop = state.core[0][0][2][0];

  // Emulation.
  while (1)
    {
      unsigned long targetCycles;

      currentTime = times(&TmsStruct);
      targetCycles = (currentTime - startingTime) * cyclesPerTick;
      while (cycleCount < targetCycles)
	{
	  int cyclesUsed = 0;
	  if (runNextN == 0)
	    if (gdbInterface (instructionCount))
	      goto done;
	  if (!runOneInstruction(&cyclesUsed))
	    cycleCount += cyclesUsed;
	  if (processPIO() || processCIO() || processPRS())
	    goto done;
	  if (processInterrupts())
	    goto done;
	  if (runNextN > 0)
	    {
	      instructionCount++;
	      runNextN--;
	    }
	}

      // Sleep for a little to avoid hogging 100% CPU time.  The amount
      // we choose doesn't really matter.
      sleepMilliseconds(10);
    }

  retVal = 0;
  done: ;
  for (i = 0; i < numErrorMessages; i++)
  fprintf (stderr, "%s\n", errorMessageStack[i]);
  return (retVal);
}
