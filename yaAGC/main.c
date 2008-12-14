/*
  Copyright 2003-2005,2007 Ronald S. Burkey <info@sandroid.org>

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
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/index.html
  Mods:		04/05/03 RSB.	Began.
		10/20/03 RSB.	Added a fake times() function for WIN32.
		11/26/03 RSB.	Added the actual machine-cycle timing.
				(Previously, it just ran as fast as it could.
				Now, the machine cycles are about 11.7 us.)
				Began adding a primitive debugging capability.
		11/28/03 RSB.	Added a bunch of new debugging stuff.
		11/30/03 RSB.	Added interactively helting AGC-program
				execution (whether in --debug mode or not).
		05/01/04 RSB	--debug-dsky mode was fixed by adding the
				--debug mode.  Too bad I didn't test it.
		05/04/04 RSB	The disassembly of AD was reading ADD.
		05/05/04 RSB	In the debugger, added S and N as synonyms for
				STEP and NEXT.
		05/06/04 RSB	Now displays error for non-existent *.ini file.
				Now does a little bit to find *.bin and *.ini
				in the installation directory if not in the
				current directory.
		05/08/04 RSB	The disassembler now shows the opcodes for
				the "implied address codes" --- i.e., things
				like SQUARE in place of "MP A".  Also, the
				instructions are now shown as indexed.
				Corrected the starting cycle count used for
				timing in case the --resume file is used.
				The timing used in debugging was completely
				wrong, as it did not account for the time
				the debugger was paused for user input.
		05/09/04 RSB	Added the GETOCT command to the disassembler.
		05/10/04 RSB	Fixed bank-editing in --debug mode, hopefully.
		05/12/04 RSB	Added backtrace stuff.
		05/13/04 RSB	Corrected disassembly of superbanks.  Fixed
				the --debug command EDIT, which I apparently
				broke yesterday.
		05/14/04 RSB	Added interrupt-related --debug commands.
		05/17/04 RSB	Added INTERRUPTS ENABLE and INTERRUPTS DISABLE.
				... Changed to MASKOFF 0 and MASKON 0.
				Also changed INTERRUPT to INTON, added INTOFF,
				MASKON, and MASKOFF.
		05/31/04 RSB	Debugger now shows actual bank numbers in addition
				to just the contents of the EB and FB registers.
				Also, the debugger now correctly decodes overflow
				and shows the accumulator as a 16-bit register.
				For the DUMP, EDIT, DELETE, and BREAK debugger
				commands, erasable and fixed bank numbers are
				now taken from the EB or FB register if omitted.
				Socket info now shown in the debugger.
		06/02/04 RSB	In --debug, BREAK and DELETE didn't work
				properly in and around superbanks (nor did
				the breakpoint itself work).
		06/08/04 RSB	Added primitive watchpoints.
		06/11/04 RSB	Altered the sys/times.h include in WIN32.
		06/30/04 RSB	Implemented PATTERN.
		07/01/04 RSB	Enlarged the number of allowed breakpoints
				dramatically (32 -> 256), in order to
				account for the possibility of trapping
				upon executing a lot of different instruction
				types at once.  Also, accounted for a certain
				level of testing of FROMFILEs.  Fixed it so
				that COREDUMP and FROMFILE don't automatically
				convert filenames to upper case.  Added a
				comment command ("#") to --debug mode.
		07/12/04 RSB	Q is now 16 bits.
		07/15/04 RSB	Added the LOG command to --debug mode.
		07/15/04 RSB	Data now aligned at bit 0 rather than bit 1.
		07/19/04 RSB	Changed the WIN32 version of times from clock()
				to GetTickCount().  Added the --interlace
				option.  Adjusted the lengths of the debugging status
				messages to fit on the crippled Win32 command lines.
		07/20/04 RSB	Oops!  Apparently forgot to implement --port=N.
		08/01/04 RSB	The enormous CPU usage in --debug whilst waiting
				for a keystroke has been cut to almost nothing.
		08/09/04 RSB	Adapted to use a threaded model for keyboard input,
				so as to avoid the problem if getc() blocking on
				Win32.
		08/10/04 RSB	Split help screen from --debug mode into separate
				help topics.  This is partially just from good
				sense, but also partially because when I just
				printf the whole menu, it's truncated after some
				(presumably fixed) number of characters, and I don't
				feel like figuring out that problem.
		02/27/05 RSB	Added the license exception, as required by
				the GPL, for linking to Orbiter SDK libraries.
		05/14/05 RSB	Corrected website references.
		05/31/05 RSB	Added --debug-deda mode.
		07/05/05 RSB	Added autosave and autorestore of erasable memory.
		07/13/05 RSB	Fixed a possible issue of using too much CPU time
				in Win32.
		07/27/05 JMS    Added --symbtab argument and basic support for
                                symbolic debugging. New/exiting commands which
				can take symbols as arguments: break, print,
				whatis, list.
		07/28/05 JMS    Added "list" debug command which lists source. Also
		                if a symbol table is loaded, the source line is
				displayed when stepping through the code instead
				of a disassembly.
		07/30/05 JMS    Added "files" command to list source files. Some
                                better printing of breakpoints.
		08/17/05 RSB	Hopefully now correctly shows instruction when
				taken from B reg.
		08/20/05 RSB	The ability to delete breakpoints at a numerical
				address had been broken by the symbolic debugging.
				Now fixed.  However, fixed memory is somehow being
				overwritten; to debug that condition, I've added
				all the stuff associated with DEBUG_OVERWRITE_FIXED.
		08/21/05 RSB	Corrected calculation of fixed banks in
				GetFromZ.  Auto-detect "TC 0" when A=0 as an
				infinite loop.
		08/22/05 RSB	"unsigned long long" replaced by uint64_t.
		08/23/05 RSB	Added the debugging command "WATCH A V".
		10/13/05 RSB	Added "VIEW A".  Fixed "WATCH A" so that it could
				accept variable names in addition to numerical
				addresses.
		10/29/05 RSB	For VIEW, initialize value to an illegal
				number, so that the value is always displayed
				at least once.
		04/11/07 RSB	At some point (exactly when isn't clear), I messed
				up the calculation of the timing, which is supposed
				to be 64 bits, so that intermediate results were
				32 bit.  This caused the timing to fail after 4
				minutes of operation, because of integer wraparound.
				The symptom was that the AGC started running very
				fast, the CPU utilization shot up to the maximum,
				and LM_Simulator failed.  The 20060110 dev snapshot
				worked properly, for reasons I fail to understand.
		02/03/08 OH	Start adding GDB/MI interface
		08/23/08 OH Only support GDB/MI and not proprietary debugging
*/

//#define VERSION(x) #x

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
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
#include "agc_gdbmi.h"
#include "agc_help.h"
#include "agc_cli.h"
#include "agc_simulator.h"

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
char s[129], sraw[129], slast[129], s1[129], s2[129], s3[129], s4[129], s5[129];

/* Prompt String
 * Allow the prompt to be changed in gdb/mi mode
 */
char agcPrompt[16]="(agc) ";

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
 * Get the value stored at an address, as specified by a Breakpoint_t.
 */
int16_t GetWatch (agc_t * State, Breakpoint_t * bp)
{
  int Address12, vRegBB;
  Address12 = (bp->Address12 & 07777);
  vRegBB = (bp->vRegBB & 07777);
  int16_t Value = 0;

  /* First check if it is fixed erasable */
  if (Address12 <= 01377)
  {
  		Value = (State->Erasable[Address12 / 0400][Address12 & 0377]);
  }
  /* Check if it is Switched erasable */
  else if (Address12 <= 01777)
  {
    Value = (State->Erasable[vRegBB & 07][Address12 & 0377]);
  }

  /* Return value of address or default 0 */
  return (Value);
}


/*
 * Gets the value at the instruction pointer.  The INDEX is automatically added,
 * and the Extracode bit is used as the 16th bit.
 */
int GetFromZ (agc_t * State)
{
  int CurrentZ, Bank, Value;
  CurrentZ = (State->Erasable[0][RegZ] & 07777);

  // Print the address.
  if (CurrentZ < 01400)
  {
      Bank = CurrentZ / 0400;
      Value = State->Erasable[Bank][CurrentZ & 0377];
  }
  else if (CurrentZ >= 04000)
  {
      Bank = 2 + (CurrentZ - 04000) / 02000;
      Value = State->Fixed[Bank][CurrentZ & 01777];
  }
  else if (CurrentZ < 02000)
  {
      Bank = (7 & State->Erasable[0][RegBB]);
      Value = State->Erasable[Bank][CurrentZ & 0377];
  }
  else
  {
      Bank = (31 & (State->Erasable[0][RegBB] >> 10));
      if (0x18 == (Bank & 0x18) && (State->OutputChannel7 & 0100))
      {
			Bank += 0x08;
      }
      Value = State->Fixed[Bank][CurrentZ & 01777];
  }
  Value = OverflowCorrected(AddSP16
		       (SignExtend (Value), SignExtend (State->IndexValue)));
  Value = (Value & 077777);

  /* Extracode? */
  if (State->ExtraCode)  Value |= 0100000;

  /* Indexed? */
  if (State->IndexValue) Value |= 0200000;

  /* Positive overflow? */
  if (0040000 == (0140000 & State->Erasable[0][RegA])) Value |= 0400000;

  /* Negative overflow? */
  if (0100000 == (0140000 & State->Erasable[0][RegA])) Value |= 01000000;

  /* Sign of Accumulator */
  if (0 != (0100000 & State->Erasable[0][RegA])) Value |= 02000000;

  /* Signs of Accumulator and L disagree. */
  if (0 != (0100000 & (State->Erasable[0][RegL] ^ State->Erasable[0][RegA])))
  {
  		Value |= 04000000;
  }

  /* Inside of an ISR? */
  if (State->InIsr) Value |= 010000000;

  return (Value);
}

/*
 * My substitute for fgets, for use when stdin is unblocked.
 */
#define MAX_FROMFILES 11
static FILE *FromFiles[MAX_FROMFILES];
static int NumFromFiles = 1;

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
		      printf ("Keystroke source-file closed.\n");
		      if (NumFromFiles == 1)
		      {
		      	printf ("The keyboard has been reattached.\n> ");
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

static void catch_sig(int sig);
int BreakPending = 0;
char FuncName[128];

int main (int argc, char *argv[])
{
	FILE *LogFile = NULL;
	int LogCount = 0, LogLast = -1;
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
	NextKeycheck = times (&DummyTime);

	/* Parse the CLI options */
	Options = ParseCommandLineOptions(argc, argv);

	/* Initialize the Simulator and debugger if enabled
	* if the initialization fails or Options is NULL then the simulator will
	* return a non zero value and subsequently bail and exit the program */
	if (InitializeSimulator(Options)) return(1);

	/* Register the SIGINT to be handled by AGC Debugger */
	signal(SIGINT, catch_sig);

  /* Run the Simulation */
  while (1)
  {
      int Break;

      ExecuteSimulator();

      while (CycleCount < DesiredCycles)
	  {
		  int CurrentZ, CurrentBB;

		  // If we're in --debug-dsky mode, we don't want to do all of the
		  // --debug stuff, since we're not actually executing AGC code.
		  if (DebugDsky)
		  {
			  CycleCount += sysconf (_SC_CLK_TCK);
			  agc_engine (&State);
			  continue;
		  }

ShowDisassembly:
		  CurrentZ = State.Erasable[0][RegZ];
		  CurrentBB = (State.Erasable[0][RegBB] & 076007) |
					  (State.InputChannel[7] & 0100);
		  if (State.PendFlag) Break = 0;
		  else
		  {
			if (SingleStepCounter == 0)
			{
			  Break = 1;
			  if(RunState) printf ("Stepped.\n");
			}
			else
			{
				  int Value;
				  Value = GetFromZ (&State);

				  // Detect certain types of impending infinite loops.
				  if (!(Value & 0177777) && !State.Erasable[0][0])
					{
					  printf ("Infinite loop in AGC program will commence at next instruction.\n");
					  Break = DebugMode = 1;
					}
				  else
				  {
					  if (SingleStepCounter > 0) SingleStepCounter--;

					  Break = MonitorBreakpoints();
				  }
			}
		  }
          if (BreakPending)
          {
             BreakPending = 0;
             Break = 1;
          }
	  if (DebugMode && !Break)
	  {
	      if (RealTime >= NextKeycheck)
	        {
		  NextKeycheck = RealTime + KEYSTROKE_CHECK;
		  while (KeyboardBuffer == nbfgets (KeyboardBuffer, sizeof (KeyboardBuffer)))
		  {
		      //printf ("*** \"%s\" ***\n", KeyboardBuffer);
		      Break = 1;
		  }
	   }
	  }
	  if (DebugMode && Break)
	    {
	      extern int DebuggerInterruptMasks[11];
	      char *ss, OverflowChar, OverflowCharQ;
	      SingleStepCounter = -1;

	      DisplayInnerStackFrame();

	      while (1)
		{
		  if (DebugMode && NumFromFiles == 1)
		  {
		      // JMS: Tell the thread which is actually reading the input from
		      // stdin to actually go ahead and read. At this point, we know that
		      // the last debugging command has been processed.
		      printf("%s",agcPrompt);
		      fflush(stdout);
		      nbfgets_ready(agcPrompt);
		  }

		  strcpy(slast,sraw);

		  s[sizeof (s) - 1] = 0;
		  rfgets (&State, s, sizeof (s) - 1, FromFiles[NumFromFiles - 1]);

		  /* Use last command if just newline */
		  if (strlen(s) == 0) strcpy(s,slast);

		  // Normalize the strings by getting rid of leading, trailing
		  // or duplicated spaces.
		  i = sscanf (s, "%s%s%s%s%s", s1, s2, s3, s4, s5);
		  if (i == 1) strcpy (s, s1);
		  else if (i == 2)
		    sprintf (s, "%s %s", s1, s2);
		  else if (i == 3)
		    sprintf (s, "%s %s %s", s1, s2, s3);
		  else if (i == 4)
		    sprintf (s, "%s %s %s %s", s1, s2, s3, s4);
		  else if (i == 5)
		    sprintf (s, "%s %s %s %s %s", s1, s2, s3, s4, s5);
		  else s[0] = 0;

		  if (s[0] == '#' || s[0] == 0) continue;

		  strcpy (sraw, s);
		  RealTimeOffset +=
		    ((RealTime = times (&DummyTime)) - LastRealTime);
		  LastRealTime = RealTime;
		  for (ss = s; *ss; *ss = toupper (*ss), ss++);

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
				GetWatch (&State, &Breakpoints[j]);
			}
		      State.PendFlag = SingleStepCounter = 0;
		      Break = 1;
		      CycleCount = sysconf (_SC_CLK_TCK) * State.CycleCounter;
		      goto ShowDisassembly;
		    }

		  else
		  {
			  gdbmiResult result = gdbmiHandleCommand(&State, s , sraw );
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
				  case gdbmiCmdRun:
                      RunState = 1;
					  break;
				  case gdbmiCmdQuit:
					  return(0);
				  default:
					  fflush(stdout);
					  break;
			  }

			  if (result == gdbmiCmdRun) break;

//			  if ( result < gdbmiCmdDone )
//	            {
//	              // printf ("Undefined command: \"%s\". Try \"help\".\n", sraw );
//	            }
//	           else
//	           {
//
//
//	           	fflush(stdout);
//	           }
		  }
		}
	  }
	  if (LogFile != NULL)
	    {
	      int Bank, Address, NewLast;
	      Bank =
		077777 &
		(((State.Erasable[0][RegBB]) | State.OutputChannel7));
	      Address = 077777 & (State.Erasable[0][RegZ]);
	      NewLast = (Bank << 15) | Address;
	      if (NewLast != LogLast)
		{
		  LogLast = NewLast;
		  fprintf (LogFile, "%05o %05o\n", Bank, Address);
		  LogCount--;
		  if (LogCount <= 0)
		    {
		      fclose (LogFile);
		      LogFile = NULL;
		      printf ("Logging completed.\n");
		    }
		}
	    }
	  agc_engine (&State);
	  CycleCount += sysconf (_SC_CLK_TCK);
	}
    }

  return (0);
}

/* Catch the SIGINT Signal to stop running and return to debug mode */
static void catch_sig(int sig)
{
   BreakPending = 1; /* Make sure Break only happens when we want it */
   nbfgets_ready(agcPrompt);
   signal(sig, catch_sig);
}
