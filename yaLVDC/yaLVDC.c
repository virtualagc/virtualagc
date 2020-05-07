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

breakpoint_t breakpoints[MAX_BREAKPOINTS];
int numBreakpoints = 0;

//////////////////////////////////////////////////////////////////////////////
// Cross-platform stuff.
//
// For timekeeping:  Provides *NIX-style functions times() and
// sysconf(_SC_CLK_TCK) for measuring time passage, and use sleepMilliseconds()
// to sleep for a while.
//
// For detecting a keypress:  Provides DOS-style function kbhit() (from conio.h,
// which Linux doesn't have).

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

#include <conio.h>

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

// Return 0 if no keyboard key pressed, non-zero otherwise.
#include <termios.h>
#include <fcntl.h>
int
kbhit(void)
{
  struct termios oldt, newt;
  int ch;
  int oldf;

  tcgetattr(STDIN_FILENO, &oldt);
  newt = oldt;
  newt.c_lflag &= ~(ICANON | ECHO);
  tcsetattr(STDIN_FILENO, TCSANOW, &newt);
  oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
  fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

  ch = getchar();

  tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
  fcntl(STDIN_FILENO, F_SETFL, oldf);

  if (ch != EOF)
    {
      ungetc(ch, stdin);
      return 1;
    }

  return 0;
}

#endif

//////////////////////////////////////////////////////////////////////////////
// Main program.

int
main(int argc, char *argv[])
{
  int retVal = 1;
  clock_t startingTime, currentTime, pausedTime = 0;
  double cyclesPerTick;
  unsigned long cycleCount = 0, nextSnapshot, snapshotIntervalCycles = 5.0
      / SECONDS_PER_CYCLE;
  struct tms TmsStruct;
  unsigned long instructionCount = 0;

  // Setup and initialization.
  if (parseCommandLineArguments(argc, argv))
    goto done;

  ServerBaseSocket = EstablishSocket(PortNum, MAX_LISTENERS);
  if (ServerBaseSocket == -1)
    {
      printf("Cannot establish networking socket for virtual wiring.\n");
      goto done;
    }
  connectCheck();

  if (0)
    {
      restart: ;
      runStepN = 0;
      inNextNotStep = 0;
      inNextHop = 0;
      pausedTime = 0;
      cycleCount = 0;
      instructionCount = 0;
    }
  nextSnapshot = cycleCount + snapshotIntervalCycles;

  // Note that readCore() must occur after readAssemblies(), since if present,
  // the core-memory file overrides the core-memory image from the assembler.
  if (readAssemblies())
    goto done;
  if (coldStart == 0)
    if (readCore())
        goto done;
  // Some optional printouts for debugging.
  dPrintouts();
  fflush(stdout);
  state.hopSaver = 0;

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
      hopStructure_t hs;

      // Save a snapshot, if appropriate.
      if (cycleCount >= nextSnapshot)
        {
          nextSnapshot += snapshotIntervalCycles;
          printf("Saving emulation snapshot.\n");
          writeCore();
        }

      // The emulator emulates LVDC/PTC instructions just as fast as it can,
      // until it catches up with real time in terms of the number of instructions
      // it is supposed to have executed.  "Real time" doesn't include the
      // time spent paused at the debugger interface.  So if yaLVDC has been
      // running for an hour, but has spent 59 minutes waiting for user input
      // at the debugging interface, only 1 minute of "real time" has passed,
      // and the number of instruction emulated is appropriate for 1 minute.
      currentTime = times(&TmsStruct);
      targetCycles = (currentTime - startingTime - pausedTime) * cyclesPerTick;
      while (cycleCount < targetCycles)
        {
          int cyclesUsed = 0;
          breakpoint_t *breakpoint;
          // Check if a breakpoint hit.
          if (!parseHopConstant(state.hop, &hs))
            {
              int i;
              // Note that the search is made from the end of the breakpoint list
              // downward:  i.e., the most-recently added breakpoint is found if
              // there are two breakpoints at the same address.  I thought this would
              // be helpful for something I ended up not using it for.
              for (i = 0, breakpoint = &breakpoints[numBreakpoints - 1];
                  i < numBreakpoints; i++, breakpoint--)
                if (breakpoint->module == hs.im && breakpoint->sector == hs.is
                    && breakpoint->syllable == hs.s
                    && breakpoint->location == hs.loc)
                  {
                    runStepN = 0;
                    break;
                  }
              if (i >= numBreakpoints)
                breakpoint = NULL;
            }
          // Doing NEXT?
          if (runStepN > 0 && inNextNotStep)
            {
              entryNext: ;
              // If we've just returned after a HOP/TRA/TNZ/TMI subroutine in a NEXT,
              // detect our poor-man's breakpoint and clean up.
              if (inNextHop && inNextHopIM == hs.im && inNextHopIS == hs.is
                  && inNextHopS == hs.s && inNextHopLOC == hs.loc)
                {
                  inNextHop = 0;
                  runStepN--; // Wasn't decremented after last instruction because of inNextHop.
                }
              if (!inNextHop && runStepN > 0)
                {
                  int instruction, op, a9, a81, dataFromInstructionMemory,
                      instructiond;
                  hopStructure_t hsd;
                  int32_t destHopConstant;
                  // What we have to do now, if the current instruction is a transfer
                  // instruction (HOP, TRA, TNZ, or TMI), is to analyze it to
                  // determine if the target destination is a subroutine.  We do
                  // that by detecting STO 776 or STO 776 at the target destination
                  // of the transfer.  If so, then we mark ourselves as being inNextHop
                  // and set a poor-man's breakpoint to detect the eventual return.
                  // If not, though, we can just treat the transfer instruction like any
                  // other, for NEXT purposes.
                  instruction = state.core[hs.im][hs.is][hs.s][hs.loc];
                  if (instruction == -1)
                    goto badNext;
                  op = instruction & 017;
                  if (op == 000 || op == 010 || op == 004 || op == 014) // Is indeed a HOP, TRA, TNZ, or TMI instruction.
                    {
                      a9 = (instruction >> 4) & 1;
                      a81 = (instruction >> 5) & 0377;
                      if (op == 000) // HOP
                        {
                          // Fetch the HOP constant pointed to by the instruction's operand.
                          if (fetchData(hs.dm, a9, hs.ds, a81, &destHopConstant,
                              &dataFromInstructionMemory))
                            goto badNext;
                          // Now fetch the first instruction from the destination of the HOP.
                          if (parseHopConstant(destHopConstant, &hsd))
                            goto badNext;
                          instructiond =
                              state.core[hsd.im][hsd.is][hsd.s][hsd.loc];
                        }
                      else
                        // TRA, TNZ, or TMI
                        instructiond = state.core[hs.im][hs.is][a9][a81];
                      if (instructiond == -1)
                        goto badNext;
                      // Is the destination instruction a STO 776 or STO 777?
                      if (instructiond == 017733 || instructiond == 017773)
                        {
                          // Yes!  Set up our poor-man's breakpoint for the
                          // instruction immediately following the HOP.
                          inNextHop = 1;
                          inNextHopIM = hs.im;
                          inNextHopIS = hs.is;
                          inNextHopS = hs.s;
                          inNextHopLOC = hs.loc + 1;
                        }
                    }
                }
              if (0)
                {
                  badNext: ;
                  printf("Failed to fetch or analyze instruction.\n");
                  runStepN = 0;
                }
            }
          if (runStepN <= 0)
            {
              clock_t start, end;
              inNextNotStep = 0;
              inNextHop = 0;
              start = times(&TmsStruct);
              if (gdbInterface(instructionCount, cycleCount, breakpoint))
                goto done;
              end = times(&TmsStruct);
              pausedTime += (end - start);
              // If we selected NEXT, it would normally be fine to just
              // fall through right here, but if the current instruction
              // is a HOP to a subroutine, we'd have no way to detect that,
              // so we have to spaghetti our way to the analysis code for
              // detecting that special case.
              if (runStepN > 0 && inNextNotStep)
                goto entryNext;
            }
          if (!runOneInstruction(&cyclesUsed))
            {
              cycleCount += cyclesUsed;
              instructionCount++;
            }
          if (processInterruptsAndIO())
            goto done;
          if (runStepN > 0) // Number of instructions remaining.
            {
              // If a key hit at the keyboard, pause the emulation.
              // Otherwise, update counters.
              if (kbhit())
                {
                  runStepN = 0;
                  getchar(); // Eliminate the keypress.
                }
              else if (runStepN != INT_MAX && !inNextHop)
                runStepN--;
            }
          if (state.restart)
            goto restart;
        }

      // Sleep for a little to avoid hogging 100% CPU time.  The amount
      // we choose doesn't really matter, as long as it's short.  This
      // is not a delay between instructions; rather, it is a delay
      // that's applied every time the loop above catches up with real time.
      sleepMilliseconds(10);
    }

  retVal = 0;
  done: ;
  return (retVal);
}
