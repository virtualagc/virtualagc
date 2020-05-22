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
backtrace_t backtraces[MAX_BACKTRACES];
int runStepN = 0; // # of emulation steps left to run until pausing. INT_MAX is unlimited.
int runNextN = 0;
int inNextNotStep, inNextHop, inNextHopIM, inNextHopIS, inNextHopS,
    inNextHopLOC;
// For interaction with PTC control panel, if any.  Here are the specific
// interpretations for panelPause:
//      0 = not paused by panel; i.e., free-running until a remotely-commanded
//          comparison is hit, etc.
//      1 = a remotely-commanded single step is pending.
//      2 = a fully-paused state has just been entered.  (Therefore, statuses can
//          be reported to the panel.
//      3 = a fully-paused state continues.  (Therefore, no statuses are to be
//          reported to the panel.
//      4 = Transition from paused to running state.  That transition can be
//          reported to the panel.
int panelPause = 0;
int panelPatternDataAddress = 0;
int panelPatternInstructionAddress = 0;
int panelPatternDataValue = 0;
int panelComparisonModeData = 1;
int cpuIsRunning = 0;
int cpuCurrentAddressData = -1;
int cpuCurrentAddressInstruction = -1;
int cpuCurrentValueData = -1;
int cpuCurrentAccumulator = -1;

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

int firstUsedBacktrace = 0, firstEmptyBacktrace = 0;
void
addBacktrace(int16_t fromInstruction, int32_t fromWhere, int32_t toWhere,
    unsigned long cycleCount, unsigned long instructionCount)
{
  backtrace_t *backtrace = &backtraces[firstEmptyBacktrace];
  backtrace->fromInstruction = fromInstruction;
  backtrace->fromWhere = fromWhere;
  backtrace->toWhere = toWhere;
  backtrace->cycleCount = cycleCount;
  backtrace->instructionCount = instructionCount;
  firstEmptyBacktrace = NEXT_BACKTRACE(firstEmptyBacktrace);
  if (firstUsedBacktrace == firstEmptyBacktrace)
    firstUsedBacktrace = NEXT_BACKTRACE(firstUsedBacktrace);
}

//////////////////////////////////////////////////////////////////////////////
// Main program.

int clockDivisor = 1;
int
main(int argc, char *argv[])
{
  int retVal = 1;
  clock_t startingTime, currentTime, pausedTime = 0, panelPauseTime = 0;
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
      printf("Resetting ...\n");
      runStepN = 0;
      inNextNotStep = 0;
      inNextHop = 0;
      pausedTime = 0;
      cycleCount = 0;
      instructionCount = 0;
      firstUsedBacktrace = 0;
      firstEmptyBacktrace = 0;
      if (panelPause == 0)
        panelPause = 4;
      else if (panelPause == 3)
        panelPause = 2;
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

  cyclesPerTick = 1.0 / (SECONDS_PER_CYCLE * sysconf(_SC_CLK_TCK))
      / clockDivisor;
  startingTime = times(&TmsStruct);
  if (ptc)
    state.hop = 0;
  else
    state.hop = state.core[0][0][2][0];

  // Emulation.
  while (1)
    {
      int cyclesUsed = 0;
      clock_t start, end;
      // Sleep for a little to avoid hogging 100% CPU time.  The amount
      // we choose doesn't really matter, as long as it's short.  This
      // is not a delay between instructions; rather, it is a delay
      // that's applied every time the loop above catches up with real time.
      sleepMilliseconds(10);

      if (panelPause)
        {
          if (0)
            {
              startPanelPause: ;
              panelPauseTime = times(&TmsStruct);
            }
          // See the comments where panelPause is allocated to understand
          // the difference between states panelPause = 0,1,2,3,4.
          // If a single step was remotely commanded, then take care of
          // it.
          if (panelPause == 1)
            {
              if (!runOneInstruction(&cyclesUsed))
                {
                  if (state.lastHop != -1)
                    addBacktrace(state.lastInstruction, state.lastHop,
                        state.hop, cycleCount, instructionCount);
                  cycleCount += cyclesUsed;
                  instructionCount++;
                }
              panelPause = 2;
            }
          if (processInterruptsAndIO())
            goto done;
          if (panelPause == 2)
            panelPause = 3;
          if (panelPause == 4)
            {
              panelPause = 0;
              pausedTime += times(&TmsStruct) - panelPauseTime;
            }
          else
            {
              // If a key hit at the keyboard, we can still force entry
              // into the yaLVDC local debugger, in spite of being under
              // the control of the panel.
              if (kbhit())
                {
                  getchar(); // Eliminate the keypress.
                  if (gdbInterface(instructionCount, cycleCount, NULL))
                    goto done;
                }
            }
          if (state.restart)
            goto restart;
        }
      else
        {
          unsigned long targetCycles;
          hopStructure_t hs;

          // Save a snapshot, if appropriate.
          if (cycleCount >= nextSnapshot)
            {
              nextSnapshot += snapshotIntervalCycles;
              //printf("Saving emulation snapshot.\n");
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
          targetCycles = (currentTime - startingTime - pausedTime)
              * cyclesPerTick;
          while (cycleCount < targetCycles)
            {
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
                    if (breakpoint->module == hs.im
                        && breakpoint->sector == hs.is
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
                          uint16_t instruction16;
                          a9 = (instruction >> 4) & 1;
                          a81 = (instruction >> 5) & 0377;
                          if (op == 000) // HOP
                            {
                              // Fetch the HOP constant pointed to by the instruction's operand.
                              if (fetchData(hs.dm, a9, hs.ds, a81,
                                  &destHopConstant, &dataFromInstructionMemory))
                                goto badNext;
                              // Now fetch the first instruction from the destination of the HOP.
                              if (parseHopConstant(destHopConstant, &hsd))
                                goto badNext;
                              if (fetchInstruction(hsd.im, hsd.is, hsd.s,
                                  hsd.loc, &instruction16,
                                  &instructionFromDataMemory))
                                instructiond = -1;
                              else
                                instructiond = instruction16;
                            }
                          else
                            {
                              // TRA, TNZ, or TMI
                              if (fetchInstruction(hs.im, hs.is, a9, a81,
                                  &instruction16, &instructionFromDataMemory))
                                instructiond = -1;
                              else
                                instructiond = instruction16;
                            }
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
                  if (state.lastHop != -1)
                    addBacktrace(state.lastInstruction, state.lastHop,
                        state.hop, cycleCount, instructionCount);
                  cycleCount += cyclesUsed;
                  instructionCount++;
                }
              if (processInterruptsAndIO())
                goto done;
              if (panelPause)
                goto startPanelPause;
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
        }
    }

  retVal = 0;
  done: ;
  return (retVal);
}
