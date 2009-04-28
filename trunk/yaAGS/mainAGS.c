/*
  Copyright 2003-2005,2009 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	mainAGS.c
  Purpose:	A top-level program for running the AGS simulation
  		in a PC environment. 
  Compiler:	GNU gcc.
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
		06/01/05 RSB	Began adapting from corresponding yaAGC program.
		06/05/05 RSB	Added --debug mode.
		07/13/05 RSB	Fixed a possible issue of using too much CPU time
				in Win32.
		08/02/05 JMS    Added symbolic debugging.
		08/22/05 RSB	"unsigned long long" replaced by uint64_t.
		03/17/09 RSB	Corrected the --help entry for loading the symtab.
		03/18/09 RSB	Added some necessary goofiness to allow proper usage
				when linking statically to the Win32 pthreads library.
				Added --debug-deda.
*/

//#define VERSION(x) #x

#include <stdio.h>
#include "aea_engine.h"
#include "agc_symtab.h"
#include "yaAEA.h"
#include <string.h>
#include <unistd.h>
#ifdef WIN32
#include <pthread.h>
#include <windows.h>
#include <sys/time.h>
#define LB "\r\n"
#else
#include <time.h>
#include <sys/times.h>
#define LB ""
#endif
#include <ctype.h>
FILE *rfopen (const char *Filename, const char *mode);

// Some buffers for strings.
char s[129], sraw[129], s1[129], s2[129], s3[129], s4[129], s5[129];

ags_t State;

// Variables pertaining to the symbol table loaded
int HaveSymbolsAGS = 0;                        // 1 if we have a symbol table
char SymbolFileAGS[MAX_FILE_LENGTH + 1];       // The name of the symbol table file

//-----------------------------------------------------------------------------------
#ifdef WIN32
struct tms {
  clock_t tms_utime;  /* user time */
  clock_t tms_stime;  /* system time */
  clock_t tms_cutime; /* user time of children */
  clock_t tms_cstime; /* system time of children */
};
clock_t times (struct tms *p)
{
  return (GetTickCount ());
}
#define _SC_CLK_TCK (1000)
#define sysconf(x) (x)
#endif // WIN32

//-----------------------------------------------------------------------------------

int
main (int argc, char *argv[])
{
  char *RomImage = NULL, *CoreDump = NULL;
  int i;
  struct tms DummyTime;

  //int k, n;
  //int16_t *WordPtr;
  uint64_t /* unsigned long long */ CycleCount, DesiredCycles;

#ifdef PTW32_STATIC_LIB
  // You wouldn't need this if I had compiled pthreads_w32 as a DLL.
  pthread_win32_process_attach_np ();
#endif  

  Portnum = 19897;
  //setvbuf (stdout, OutBuf, _IOLBF, sizeof (OutBuf));
  NextKeycheckAGS = times (&DummyTime);

  printf ("LM Abort Guidance System simulation, ver. " NVER ", built "
	  __DATE__ " " __TIME__ "\n" "(c)2005,2009 Ronald S. Burkey.\n");
  printf ("Refer to http://www.ibiblio.org/apollo for additional information.\n");

  // Parse the command-line parameters.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp (argv[i], "--help") || !strcmp (argv[i], "/?"))
	break;
      else if (!strncmp (argv[i], "--core=", 7))
	RomImage = &argv[i][7];
      else if (!strcmp (argv[i], "--debug"))
        DebugModeAGS = 2;
      else if (!strcmp (argv[i], "--debug-deda"))
        DebugDeda = 1;
      else if (!strncmp (argv[i], "--symtab=", 9))
	{
	  strcpy(SymbolFileAGS, &argv[i][9]);
	  HaveSymbolsAGS = 1;
	}
      else 
        {
	  printf ("Unknown option: \"%s\"\n", argv[i]);
	  break;
	}
    }
  if (argc == 1 || i < argc || RomImage == NULL)
    {
      printf ("USAGE:\n"
	      "\tyaAGS --core=filename [OPTIONS]\n\n"
	      "The core filename is a binary image of the program,\n"
	      "constants, and so forth, that are supposed to be in\n"
	      "the AEA\'s core-rope memory.  Such a file can be\n"
	      "created from AGS assembly language using the yaLEMAP\n"
	      "assembler.\n"
	      "OPTIONS:.\n"
	      "--help                Shows this screen and exits.\n"
	      "--debug               Enter debug mode.\n"
	      "--debug-deda          Print messages showing how input\n"
	      "                      data from the DEDA is parsed.\n"
	      "--symtab=filename     Load symbol table from file.\n");
      return (1);
    }
  DebugMode = DebugModeAGS;

  //-----------------------------------------------------------------------
  // Initialization of the symbol table file if we have given a
  // --symtab command line argument
  //-----------------------------------------------------------------------
  if (HaveSymbolsAGS)
    {
      ResetSymbolTable ();
      if (!ReadSymbolTable(SymbolFileAGS))
	HaveSymbolsAGS = 1;
      else
	HaveSymbolsAGS = 0;
    }

  // Initialize the simulation.
  i = aea_engine_init (&State, RomImage, CoreDump);
  switch (i)
    {
    case 0:
      break;
    case 1:
      printf ("Specified core-rope image file not found.\n");
      break;
    case 2:
      printf ("Core-rope image larger than core memory.\n");
      break;
    case 3:
      printf ("Core-rope image file must size a multiple of 4.\n");
      break;
    case 5:
      printf ("Core-rope image file read error.\n");
      break;
    default:
      printf ("Initialization implementation error.\n");
      break;
    }
  if (i != 0)
    return (1);

  // Run the simulated CPU.  Expecting to ACCURATELY cycle the simulation every 
  // few microseconds within Linux (or Win32) is a bit too much, I think.
  // (Not that it's really critical, as long as it looks right from the
  // user's standpoint.)  So I do a trick:  I just execute the simulation
  // often enough to keep up with real-time on the average.  AGS time is
  // measured as the number of machine cycles divided by AEA_PER_SECOND, 
  // while real-time is measured using the times() function.  What this means
  // is that AEA_PER_SECOND AGC cycles are executed every CLK_TCK clock ticks.  
  // The timing is thus rather rough-and-ready (i.e., I'm sure it can be improved 
  // a lot).  It's good enough for me, for NOW, but I'd be happy to take suggestions 
  // for how to improve it in a reasonably portable way.
  RealTimeOffsetAGS = times (&DummyTime);	// The starting time of the program.
  CycleCount = State.CycleCounter * sysconf (_SC_CLK_TCK);	// Number of AEA cycles so far.
  RealTimeOffsetAGS -= (CycleCount + AEA_PER_SECOND / 2) / AEA_PER_SECOND;
  LastRealTimeAGS = ~0UL;
  while (1)
    {
      RealTimeAGS = times (&DummyTime);
      if (RealTimeAGS != LastRealTimeAGS)
	{
	  // Need to recalculate the number of AEA cycles we're supposed to
	  // have executed.  Notice the trick of multiplying both CycleCount
	  // and DesiredCycles by CLK_TCK, to avoid a long long division by CLK_TCK.
	  // This not only reduces overhead, but actually makes the calculation
	  // more exact.  A bit tricky to understand at first glance, though.
	  LastRealTimeAGS = RealTimeAGS;
	  DesiredCycles = (RealTimeAGS - RealTimeOffsetAGS) * AEA_PER_SECOND;
	}
      else
        {
#ifdef WIN32
	  Sleep (10);	    
#else // WIN32
	  struct timespec req, rem;
	  req.tv_sec = 0;
	  req.tv_nsec = 10000000;
	  nanosleep (&req, &rem);
#endif // WIN32
	}
      // Execute as many AEA CPU instructions as needed to catch up with real time.
      while (CycleCount < DesiredCycles)
	{
	  CycleCount += aea_engine (&State) * sysconf (_SC_CLK_TCK);
	}
    }

#ifdef PTW32_STATIC_LIB
  // You wouldn't need this if I had compiled pthreads_w32 as a DLL.
  pthread_win32_process_detach_np ();
#endif  

  return (0);
}

