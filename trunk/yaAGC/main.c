/*
  Copyright 2003-2005,2007 Ronald S. Burkey <info@sandroid.org>
            2008-2009      Onno Hommes

  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  In addition, as a special exception, Ronald S. Burkey gives permission to
  link the code of this program with the Orbiter SDK library (or with
  modified versions of the Orbiter SDK library that use the same license as
  the Orbiter SDK library), and distribute linked combinations including
  the two. You must obey the GNU General Public License in all respects for
  all of the code used other than the Orbiter SDK library. If you modify
  this file, you may extend this exception to your version of the file,
  but you are not obligated to do so. If you do not wish to do so, delete
  this exception statement from your version.

  Filename:	main.c
  Purpose:	A top-level program for running the AGC simulation\
  		in a PC environment.
  Compiler:	GNU gcc.
  Contact:	Onno Hommes <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:	04/05/03 RSB	Began the AGC project
		02/03/08 OH		Start adding GDB/MI interface
		08/23/08 OH 	Only support GDB/MI and not proprietary debugging
		03/12/09 OH		Complete re-write of the main function
*/

//#define VERSION(x) #x

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#ifdef WIN32
#include <windows.h>
#include <sys/time.h>
#define LB "\r\n"
#else
#include <time.h>
#include <sys/times.h>
#define LB ""
#endif
#include <ctype.h>

#include "yaAGC.h"
#include "agc_engine.h"
#include "agc_symtab.h"
#include "agc_gdbmi.h"
#include "agc_help.h"
#include "agc_cli.h"
#include "agc_simulator.h"
#include "agc_debugger.h"

FILE *rfopen (const char *Filename, const char *mode);

/* The following line should be commented out for normal operation.
 * DEBUG_OVERWRITE_FIXED is for helping me find out how fixed memory is being
 * overwritten.
 * #define DEBUG_OVERWRITE_FIXED
 */

// Here's a keyboard buffer
static char KeyboardBuffer[256];
char *nbfgets (char *Buffer, int Length);
void nbfsgets_ready (const char *prompt);

// Some buffers for strings.
//extern char s[129], sraw[129], slast[129];

/* Time between checks for --debug keystrokes. */
#define KEYSTROKE_CHECK (sysconf (_SC_CLK_TCK) / 4)

extern agc_t State;

#define MAX_BREAKPOINTS 256
#define PATTERN_SIZE 017777777
#define PAT "%08o"


Breakpoint_t Breakpoints[MAX_BREAKPOINTS];
int NumBreakpoints = 0;


// Holds whether we are in debug mode
extern int DebugMode;
extern int RunState;

#ifdef WIN32
struct tms {
  clock_t tms_utime;  /* user time */
  clock_t tms_stime;  /* system time */
  clock_t tms_cutime; /* user time of children */
  clock_t tms_cstime; /* system time of children */
};

//clock_t times (struct tms *p)
//{
//  return (GetTickCount ());
//}

#define _SC_CLK_TCK (1000)
#define sysconf(x) (x)
#endif // WIN32



/*
 * My substitute for fgets, for use when stdin is unblocked.
 */
//#define MAX_FROMFILES 11
//static FILE *FromFiles[MAX_FROMFILES];
//int NumFromFiles = 1;

void rfgets (agc_t *State, char *Buffer, int MaxSize, FILE * fp)
{
  int c, Count = 0;
  char *s;

  MaxSize--;

  while (1)
  {
      /* While waiting for character input, continue to look for client connects
       * and disconnects.
       */
      while ((fp != stdin && EOF == (c = fgetc (fp))) ||
            (fp == stdin && Buffer != (s = nbfgets (Buffer, MaxSize))))
		{
		  /* If we have redirected console input, and the file of source data is
		   * exhausted, then reattach the console.
		   */
		  if (NumFromFiles > 1 && fp == FromFiles[NumFromFiles - 1])
		  {
		      NumFromFiles--;
		      //printf ("Keystroke source-file closed.\n");
		      if (NumFromFiles == 1)
		      {
		      //	printf ("The keyboard has been reattached.\n> ");
		      }
		      fclose (fp);
		      fp = FromFiles[NumFromFiles - 1];
		  }
		  else
		  {
#ifdef WIN32
		      Sleep (10);
#else
		      struct timespec req, rem;
		      req.tv_sec = 0;
		      req.tv_nsec = 10000000;
		      nanosleep (&req, &rem);
#endif // WIN32
		  }

		  ChannelRoutine (State);
	   }

	   if (fp == stdin && s != NULL) return;

	   Buffer[Count] = c;
	   if (c == '\n' || Count >= MaxSize)
	   {
		  Buffer[Count] = 0;
		  return;
		}
      Count++;
   }
}

char FuncName[128];

int main (int argc, char *argv[])
{
	char* s;
	char* sraw;
	int PatternValue, PatternMask;
	int i, j;
	char FileName[MAX_FILE_LENGTH + 1];
	int LineNumber, LineNumberTo;
	char Dummy[MAX_FILE_LENGTH + 1];
	char SymbolName[129];
	Symbol_t *Symbol;
	Options_t *Options;

	/* setvbuf (stdout, OutBuf, _IOLBF, sizeof (OutBuf)); */
	FromFiles[0] = stdin;

	/* Parse the CLI options */
	Options = ParseCommandLineOptions(argc, argv);

	/* Initialize the Simulator and debugger if enabled
	* if the initialization fails or Options is NULL then the simulator will
	* return a non zero value and subsequently bail and exit the program */
	if (InitializeSimulator(Options)) return(1);

	if (Options->version)return(0);

  /* Run the Simulation */
  while (1)
  {
      int Break;

      ExecuteSimulator();

      while (CycleCount < DesiredCycles)
	  {
		  int CurrentZ, CurrentBB;


ShowDisassembly:
		  CurrentZ = State.Erasable[0][RegZ];
		  CurrentBB = (State.Erasable[0][RegBB] & 076007) |
					  (State.InputChannel[7] & 0100);

		  Break = DbgHasBreakEvent();

		  if (DebugMode && Break && !DebugDsky)
	    {
	      extern int DebuggerInterruptMasks[11];
	      // char OverflowChar, OverflowCharQ;
	      SingleStepCounter = -1;

	      DbgDisplayInnerFrame();

	      while (1)
		{
	      /* Display the AGC prompt */
	      DbgDisplayPrompt();

	      /* Read the Command String */
	      s = DbgGetCmdString();

		  /* Get rid of leading,trailing or duplicated spaces but keep backup */
		  sraw = DbgNormalizeCmdString(s);

		  RealTimeOffset +=
		    ((RealTime = times (&DummyTime)) - LastRealTime);
		  LastRealTime = RealTime;

		  if (s[0] == '#' || s[0] == 0) continue;

		  if (gdbmiHelp(s) > 0) continue;
		  else if (legacyHelp(s) > 0) continue;
		  else if (1 == sscanf (s, "LOG%d", &i))
		    {
		      if (LogFile != NULL)
			printf ("Logging is already in progress.\n");
		      else
			{
			  LogFile = fopen ("yaAGC.log", "w");
			  if (LogFile == NULL)
			    printf ("The log file cannot be created.\n");
			  else if (i < 1)
			    {
			      printf ("Log count out of range.\n");
			      fclose (LogFile);
			      LogFile = NULL;
			    }
			  else
			    LogCount = i;
			}
		    }
		  else if (!strncmp (s, "FROMFILE ", 9))
		    {
		      if (NumFromFiles < MAX_FROMFILES)
			{
			  FromFiles[NumFromFiles] = fopen (&sraw[9], "r");
			  if (FromFiles[NumFromFiles] == NULL)
			    printf ("Cannot open keystroke file \"%s\".\n",
				    &sraw[9]);
			  else
			    {
			      NumFromFiles++;
			      printf ("Now taking keystrokes from \"%s\".\n",
				      &sraw[9]);
			    }
			}
		      else
			printf
			  ("Too many nested FROMFILE commands, discarding \"%s\".\n",
			   &sraw[9]);
		    }
		  else if (1 == sscanf (s, "STEP%o", &i)
			   || 1 == sscanf (s, "NEXT%o", &i))
		    {
		    	RunState=1;
		      if (i >= 1)
		        SingleStepCounter = i - 1;
		      else
		        printf ("The step-count must be 1 or greater.\n");
		      break;
		    }
		  else if (!strcmp (s, "STEP") || !strcmp (s, "NEXT") ||
			   !strcmp (s, "S") || !strcmp (s, "N"))
		    {
            RunState = 1;
		      SingleStepCounter = 0;
		      break;
		    }
//		  else if (!strcmp (s, "QUIT") || !strcmp (s, "EXIT"))
//		    return (0);
		  else if (!strncmp (s, "SYMBOL-FILE", 11))
		    {
		      char Dummy[12];

		      // JMS: We need to use the raw formatted string because
		      // we need to preserve case for the file name
		      if (2 == sscanf (sraw, "%s %s", Dummy, SymbolFile))
			{
			  ResetSymbolTable ();
			  if (!ReadSymbolTable(SymbolFile))
			    HaveSymbols = 1;
			  else
			    HaveSymbols = 0;
			}
		    }
		  else if (1 == sscanf (s, "SYM-DUMP%s", SymbolName))
		    {
		      // JMS: Dumps the symbols to the screen
		      if (HaveSymbols)
			DumpSymbols (SymbolName, ARCH_AGC);
		      else
			printf ("No symbol table loaded.\n");
		    }
		  else if (1 == sscanf (s, "FILES%s", FileName))
		    {
		      // JMS: 07.30
		      // Dumps the files to the screen
		      if (HaveSymbols)
			DumpFiles (FileName);
		      else
			printf ("No symbol table loaded.\n");
		    }
		  else if (2 == sscanf (s, "DELETE%o%o", &i, &j))
		    {
		      PatternValue = (i & PATTERN_SIZE);
		      PatternMask = (j & PATTERN_SIZE);
		      for (i = 0; i < NumBreakpoints; i++)
			if (Breakpoints[i].WatchBreak == 2 &&
			    Breakpoints[i].Address12 == PatternValue &&
			    Breakpoints[i].vRegBB == PatternMask)
			  {
			    printf ("Pattern " PAT "," PAT
				    " has been deleted.\n", PatternValue,
				    PatternMask);
			    NumBreakpoints--;
			    for (; i < NumBreakpoints; i++)
			      Breakpoints[i] = Breakpoints[i + 1];
			    i = -1;
			    break;
			  }
		      if (i != -1)
			printf ("Pattern not found.\n");
		    }
		  else if (2 == sscanf (s, "PATTERN%o%o", &i, &j))
		    {
		      PatternValue = (i & PATTERN_SIZE);
		      PatternMask = (j & PATTERN_SIZE);
		      // First, see if the pattern has already been defined.
		      for (i = 0; i < NumBreakpoints; i++)
			if (Breakpoints[i].WatchBreak == 2 &&
			    Breakpoints[i].Address12 == PatternValue &&
			    Breakpoints[i].vRegBB == PatternMask)
			  {
			    printf
			      ("This pattern has already been defined.\n");
			    break;
			  }
		      if (i == NumBreakpoints)
			{
			  if (NumBreakpoints >= MAX_BREAKPOINTS)
			    printf
			      ("The maximum number of breakpoints/watchpoints/"
			       "patterns has already been reached.\n");
			  else
			    {
			      printf ("Setting pattern " PAT "," PAT ".\n",
				      PatternValue, PatternMask);
			      Breakpoints[NumBreakpoints].WatchBreak = 2;
			      Breakpoints[NumBreakpoints].Address12 =
				PatternValue;
			      Breakpoints[NumBreakpoints].Symbol = NULL;
			      Breakpoints[NumBreakpoints].Line = NULL;
			      Breakpoints[NumBreakpoints].vRegBB =
				PatternMask;
			      NumBreakpoints++;
			    }
			}
		    }
//        else if (!strcmp (s, "CONT") || !strcmp (s, "RUN"))
//		    {
//                      /* Only print the thread info if debugevents are on */
//                      RunState = 1;
//		      break;
//		    }
		  else if (!strncmp (s, "COREDUMP ", 9))MakeCoreDump (&State, &sraw[9]);
//		  else if (!strcmp (s, "INTERRUPTS"))
//		    {
//		      if (!DebuggerInterruptMasks[0])
//			printf ("The debugger is blocking all interrupts.\n");
//		      else
//			printf ("The debugger is allowing interrupts.\n");
//		      printf ("Debugger interrupt mask:");
//		      for (i = 1; i <= NUM_INTERRUPT_TYPES; i++)
//			printf (" %d", !DebuggerInterruptMasks[i]);
//		      printf ("\n");
//		      printf ("Interrupt-request flags:");
//		      for (i = 1; i <= NUM_INTERRUPT_TYPES; i++)
//			printf (" %d", State.InterruptRequests[i]);
//		      printf ("\n");
//		      if (State.InIsr)
//			printf ("In ISR #%d.\n", State.InterruptRequests[0]);
//		      else
//			printf ("Last ISR: #%d.\n",
//				State.InterruptRequests[0]);
//		    }
		  else if (1 == sscanf (s, "INTON%d", &i))
		    {
		      if (i < 1 || i > NUM_INTERRUPT_TYPES)
			printf ("Only interrupt types 1 to %d are used.\n",
				NUM_INTERRUPT_TYPES);
		      else if (State.InterruptRequests[i])
			printf ("Interrupt %d already requested.\n", i);
		      else
			{
			  printf ("Interrupt %d request-flag set.\n", i);
			  State.InterruptRequests[i] = 1;
			}
		    }
		  else if (1 == sscanf (s, "INTOFF%d", &i))
		    {
		      if (i < 1 || i > NUM_INTERRUPT_TYPES)
			printf ("Only interrupt types 1 to %d are used.\n",
				NUM_INTERRUPT_TYPES);
		      else if (!State.InterruptRequests[i])
			printf ("Interrupt %d not requested.\n", i);
		      else
			{
			  printf ("Interrupt %d request-flag cleared.\n", i);
			  State.InterruptRequests[i] = 0;
			}
		    }
		  else if (1 == sscanf (s, "MASKON%d", &i))
		    {
		      if (i < 0 || i > NUM_INTERRUPT_TYPES)
			printf ("Only interrupt types 0 to %d are used.\n",
				NUM_INTERRUPT_TYPES);
		      else
			DebuggerInterruptMasks[i] = 0;
		    }
		  else if (1 == sscanf (s, "MASKOFF%d", &i))
		    {
		      if (i < 0 || i > NUM_INTERRUPT_TYPES)
			printf ("Only interrupt types 0 to %d are used.\n",
				NUM_INTERRUPT_TYPES);
		      else
			DebuggerInterruptMasks[i] = 1;
		    }
		  else if (!strcmp (s, "BACKTRACES"))
                     BacktraceDisplay (&State, MAX_BACKTRACE_POINTS);
		  else if (1 == sscanf (s, "BACKTRACE%d", &i))
		    {
		      int j;
		      if (0 != (j = BacktraceRestore (&State, i)))
			printf ("Error %d restoring backtrace point #%d.\n",
				j, i);
		      else
			{
			  printf ("Backtrace point #%d restored.\n", i);
			  for (j = 0; j < NumBreakpoints; j++)
			    if (Breakpoints[j].WatchBreak == 1 || Breakpoints[j].WatchBreak == 4)
			      Breakpoints[j].WatchValue =
				DbgGetWatch (&State, &Breakpoints[j]);
			}
		      State.PendFlag = SingleStepCounter = 0;
		      Break = 1;
		      CycleCount = sysconf (_SC_CLK_TCK) * State.CycleCounter;
		      goto ShowDisassembly;
		    }

		  else
		  {
			  GdbmiResult result = GdbmiHandleCommand(&State, s , sraw );
			  switch (result)
			  {
//				  case gdbmiCmdUnhandled:
//					  break;
//				  case gdbmiCmdError:
//					  break;
//				  case gdbmiCmdDone:
//					  fflush(stdout);
//					  break;
////				  case gdbmiCmdNext:
////				  case gdbmiCmdStep:
////			          RunState = 1;
////					  SingleStepCounter = 0;
////					  break;
//				  case gdbmiCmdContinue:
				  case GdbmiCmdRun:
                      RunState = 1;
					  break;
				  case GdbmiCmdQuit:
					  return(0);
				  default:
					  fflush(stdout);
					  break;
			  }

			  if (result == GdbmiCmdRun) break;

//			  if ( result < gdbmiCmdDone )
//	            {
//	              printf ("Undefined command: \"%s\". Try \"help\".\n", sraw );
//	            }
//	           else
//	           {
//
//
//	           	fflush(stdout);
//	           }
		  }
		}

		  DbgProcessLog();
	  }

		  SimExecuteEngine();

		  CycleCount += sysconf (_SC_CLK_TCK);
	  }
   }

  return (0);
}


