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
*/

//#define VERSION(x) #x

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include "yaAGC.h"
#include "agc_engine.h"
#ifdef GDBMI
#include "agc_gdbmi.h"
#include "agc_help.h"
#endif
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
FILE *rfopen (const char *Filename, const char *mode);

// The following line should be commented out for normal operation.  
// DEBUG_OVERWRITE_FIXED is for helping me find out how fixed memory is being
// overwritten.
//#define DEBUG_OVERWRITE_FIXED
#ifdef DEBUG_OVERWRITE_FIXED
static int16_t Fixed[40][02000];
static void
SaveFixed (agc_t *State)
{
  int i, j;
  for (i = 0; i < 40; i++)
    for (j = 0; j < 02000; j++)
      Fixed[i][j] = State->Fixed[i][j];
}
static int iChangeFixed, jChangeFixed;
static int
CheckFixed (agc_t *State)
{
  static int Skip = -1;
  Skip++;
  if (Skip >= 50)
    Skip = 0;
  if (Skip != 0)
    return (0);
  if (!memcmp (Fixed, State->Fixed, sizeof (Fixed)))
    return (0);
  for (iChangeFixed = 0; iChangeFixed < 40; iChangeFixed++)
    for (jChangeFixed = 0; jChangeFixed < 02000; jChangeFixed++)
      if (Fixed[iChangeFixed][jChangeFixed] != State->Fixed[iChangeFixed][jChangeFixed])
        return (1);
  return (0);
}
#else // DEBUG_OVERWRITE_FIXED
#define SaveFixed(x)
#endif // DEBUG_OVERWRITE_FIXED

// Here's a keyboard buffer
static char KeyboardBuffer[256];
char *nbfgets (char *Buffer, int Length);
void nbfsgets_ready (const char *prompt);

// Some buffers for strings.
char s[129], sraw[129], s1[129], s2[129], s3[129], s4[129], s5[129];

/* Prompt String
 * Allow the prompt to be changed in gdb/mi mode
 */
#ifdef GDBMI
char agcPrompt[16]="(agc) ";
#else
char* agcPrompt="> ";
#endif

// Time between checks for --debug keystrokes.
#define KEYSTROKE_CHECK (sysconf (_SC_CLK_TCK) / 4)

agc_t State;

#define MAX_BREAKPOINTS 256
#define PATTERN_SIZE 017777777
#define PAT "%08o"

#ifndef GDBMI
typedef struct
{
  int Address12;		// A 12-bit address.
  // RegBB is like the normal BB register, except that we also insert the superbank
  // bit into it.  In other words, it's like BB bitwise-ORred with channel 7.
  // For PATTERNs, Address12 is the value we're watching for, and vRegBB is the
  // mask we apply before comparing.
  int vRegBB;
  int WatchValue;
  // WatchBreak is interpreted as follows:
  //	0 for a breakpoint (i.e., stopping upon hitting a given address).
  //	1 for a watchpoint wherein the contents of a given address changes value.
  //	2 for a pattern (i.e., the next instruction code matches a pattern).
  //	3 for a watchpoint wherein a given value is written to a given address.
  //	4 for a watchpoint that displays a variable rather than halting.
  int WatchBreak;

  // If the "break <line>" is used, then Line will be set. If "break <symbol>"
  // is used, then Symbol will be set. If a memory address is given, then both
  // will be NULL.
  Symbol_t *Symbol;
  SymbolLine_t *Line;
}
Breakpoint_t;
#endif

#ifndef GDBMI
static Breakpoint_t Breakpoints[MAX_BREAKPOINTS];
static int NumBreakpoints = 0;
#else
Breakpoint_t Breakpoints[MAX_BREAKPOINTS];
int NumBreakpoints = 0;
#endif

// JMS: Variables pertaining to the symbol table loaded
int HaveSymbols = 0;                        // 1 if we have a symbol table
char SymbolFile[MAX_FILE_LENGTH + 1];       // The name of the symbol table file

// Holds whether we are in debug mode
int DebugMode = 0;
#ifdef GDBMI
int FullNameMode = 0;
int QuietMode = 0;
int RunState = 1;
#endif

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
// Get the value stored at an address, as specified by a Breakpoint_t.

int16_t GetWatch (agc_t * State, Breakpoint_t * bp)
{
  int Address12, vRegBB;
  Address12 = (bp->Address12 & 07777);
  vRegBB = (bp->vRegBB & 07777);
  if (Address12 <= 01377)	// Fixed erasable.
    return (State->Erasable[Address12 / 0400][Address12 & 0377]);
  else if (Address12 <= 01777)	// Switched erasable.
    return (State->Erasable[vRegBB & 07][Address12 & 0377]);
  else
    return (0);
}

//-----------------------------------------------------------------------------------
// We don't do a lot of checking here.  Too bad!  Maybe one day ....
// Even so, returns 0 on "success" and 1 on known error.

int
ParseCfg (agc_t *State, char *Filename)
{
  char s[129] = { 0 };
  int KeyCode, Channel, Value;
  char Logic;
  FILE *fin;
  fin = rfopen (Filename, "r");
  if (fin == NULL)
    return (1);
  while (NULL != fgets (s, sizeof (s) - 1, fin))
    {
      char *ss;
      for (ss = s; *ss; ss++)
        if (*ss == '\n' || *ss == '\r')
	  *ss = 0;
      if (4 ==
	  sscanf (s, "DEBUG %d %o %c %x", &KeyCode, &Channel, &Logic, &Value))
	{
	  if (Channel < 0 || Channel > 255)
	    continue;
	  if (Logic != '=' && Logic != '&' && Logic != '|' && Logic != '^')
	    continue;
	  if (Value != (Value & 0x7FFF))
	    continue;
	  if (KeyCode < 0 || KeyCode > 31)
	    continue;
	  if (NumDebugRules >= MAX_DEBUG_RULES)
	    break;
	  DebugRules[NumDebugRules].KeyCode = KeyCode;
	  DebugRules[NumDebugRules].Channel = Channel;
	  DebugRules[NumDebugRules].Logic = Logic;
	  DebugRules[NumDebugRules].Value = Value;
	  NumDebugRules++;
	}
      else if (!strcmp (s, "LMSIM"))
        CmOrLm = 0;
      else if (!strcmp (s, "CMSIM"))
        CmOrLm = 1;
    }
  fclose (fin);
  return (0);
}

//-----------------------------------------------------------------------------------
// Gets the value at the instruction pointer.  The INDEX is automatically added,
// and the Extracode bit is used as the 16th bit.

static int
GetFromZ (agc_t * State)
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
	Bank += 0x08;
      Value = State->Fixed[Bank][CurrentZ & 01777];
    }
  Value =
    OverflowCorrected (AddSP16
		       (SignExtend (Value), SignExtend (State->IndexValue)));
  Value = (Value & 077777);
  if (State->ExtraCode)
    Value |= 0100000;		// Extracode?
  if (State->IndexValue)
    Value |= 0200000;		// Indexed?
  if (0040000 == (0140000 & State->Erasable[0][RegA]))
    Value |= 0400000;		// Positive overflow?
  if (0100000 == (0140000 & State->Erasable[0][RegA]))
    Value |= 01000000;		// Negative overflow?
  if (0 != (0100000 & State->Erasable[0][RegA]))
    Value |= 02000000;		// Sign of Accumulator.
  if (0 != (0100000 & (State->Erasable[0][RegL] ^ State->Erasable[0][RegA])))
    Value |= 04000000;		// Signs of Accumulator and L disagree.
  if (State->InIsr)
    Value |= 010000000;		// Inside of an ISR?
  return (Value);
}

//-------------------------------------------------------------------------------
// Displays the current address and its contents.

static int sCurrentZ, sBank, sValue, sErasable, sFixed;
static char ShowAddressBuffer[17];

static char *
ShowAddressContents (agc_t *State)
{
  sErasable = sFixed = 0;
  sCurrentZ = (State->Erasable[0][RegZ] & 07777);
  // Print the address.
  if (sCurrentZ < 01400)
    {
      sErasable = 1;
      sprintf (ShowAddressBuffer, "   %05o ", sCurrentZ);
      sBank = sCurrentZ / 0400;
      sValue = State->Erasable[sBank][sCurrentZ & 0377];
    }
  else if (sCurrentZ >= 04000)
    {
      sFixed = 1;
      sprintf (ShowAddressBuffer, "   %05o ", sCurrentZ);
      sBank = 2 + (sCurrentZ - 04000) / 02000;
      sValue = State->Fixed[sBank][sCurrentZ & 01777];
    }
  else if (sCurrentZ < 02000)
    {
      sErasable = 1;
      sBank = 7 & State->Erasable[0][RegBB];
      sprintf (ShowAddressBuffer, "E%o,%05o ", sBank, 01400 + (sCurrentZ & 0377));
      sValue = State->Erasable[sBank][sCurrentZ & 0377];
    }
  else
    {
      sFixed = 1;
      sBank = 037 & (State->Erasable[0][RegBB] >> 10);
      if (sBank >= 030 && State->OutputChannel7 & 0100)
	sBank += 010;
      sprintf (ShowAddressBuffer, "%02o,%05o ", sBank, 02000 + (sCurrentZ & 01777));
      sValue = State->Fixed[sBank][sCurrentZ & 01777];
    }
  sValue &= 077777;
  // Print the octal value stored at the address.  
  sprintf (&ShowAddressBuffer[9], "%05o  ", sValue);
  return (ShowAddressBuffer);
}

//-----------------------------------------------------------------------------------
// Displays a disassembly of the current address.

void
Disassemble (agc_t * State)
{
  // Note that the following also sets all of the global variables like
  // sValue, etc.
  printf ("%s", ShowAddressContents (State));
  // Account for the index value.
  if (State->SubstituteInstruction)
    {
      sValue = (State->Erasable[0][RegBB] & 077777);
      printf ("sub\t");
    }
  else if (State->IndexValue != 0)
    {
      // The following calculation doesn't overflow-correct the instruction,
      // whereas the agc_engine DOES overflow-correct.
      if (0 == (040000 & State->IndexValue))
	sValue += (State->IndexValue & 077777);
      else
	sValue -= (~State->IndexValue & 077777);
      printf ("w/i:\t");
    }
  // Disassemble the instruction at the address.
  if (State->ExtraCode == 0)
    {
      if (sValue == 040000)
	printf ("COM\n");
      else if (sValue == 020001)
	printf ("DDOUBL\n");
      else if (sValue == 060000)
	printf ("DOUBLE\n");
      else if (sValue == 052006)
	printf ("DTCB\n");
      else if (sValue == 052005)
	printf ("DTCF\n");
      else if (sValue == 6)
	printf ("EXTEND\n");
      else if (sValue == 4)
	printf ("INHINT\n");
      else if (sFixed && sValue == sCurrentZ + 1 && sValue != 10000)
	printf ("NOOP\n");
      else if (sErasable && sValue == 030000)
	printf ("NOOP\n");
      else if (sValue == 054000)
	printf ("OVSK\n");
      else if (sValue == 3)
	printf ("RELINT\n");
      else if (sValue == 050017)
	printf ("RESUME\n");
      else if (sValue == 2)
	printf ("RETURN\n");
      else if (sValue == 054005)
	printf ("TCAA\n");
      else if (sValue == 1)
	printf ("XLQ\n");
      else if (sValue == 0)
	printf ("XXALQ\n");
      else if (sValue == 022007)
	printf ("ZL\n");
      else
	switch (sValue & 0x7000)
	  {
	  case 0x0000:
	    printf ("TC\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x1000:
	    if (0 == (sValue & 0x0C00))
	      printf ("CCS\t%04o\n", sValue & 0x3FF);
	    else
	      printf ("TCF\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x2000:
	    switch (sValue & 0x0C00)
	      {
	      case 0x000:
		printf ("DAS\t%04o\n", (sValue - 1) & 0x3FF);
		break;
	      case 0x400:
		printf ("LXCH\t%04o\n", sValue & 0x3FF);
		break;
	      case 0x800:
		printf ("INCR\t%04o\n", sValue & 0x3FF);
		break;
	      case 0xC00:
		printf ("ADS\t%04o\n", sValue & 0x3FF);
		break;
	      }
	    break;
	  case 0x3000:
	    printf ("CA\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x4000:
	    printf ("CS\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x5000:
	    switch (sValue & 0x0C00)
	      {
	      case 0x000:
		printf ("INDEX\t%04o\n", sValue & 0x3FF);
		break;
	      case 0x400:
		printf ("DXCH\t%04o\n", (sValue - 1) & 0x3FF);
		break;
	      case 0x800:
		printf ("TS\t%04o\n", sValue & 0x3FF);
		break;
	      case 0xC00:
		printf ("XCH\t%04o\n", sValue & 0x3FF);
		break;
	      }
	    break;
	  case 0x6000:
	    printf ("AD\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x7000:
	    printf ("MASK\t%04o\n", sValue & 0xFFF);
	    break;
	  }
    }
  else
    {
      if (sValue == 040001)
	printf ("DCOM\n");
      else if (sValue == 050017)
	printf ("RESUME\n");
      else if (sValue == 070000)
	printf ("SQUARE\n");
      else if (sValue == 022007)
	printf ("ZQ\n");
      else
	switch (sValue & 0x7000)
	  {
	  case 0x0000:
	    switch (sValue & 0x0E00)
	      {
	      case 0x0000:
		printf ("READ\t%03o\n", sValue & 0777);
		break;
	      case 0x0200:
		printf ("WRITE\t%03o\n", sValue & 0777);
		break;
	      case 0x0400:
		printf ("RAND\t%03o\n", sValue & 0777);
		break;
	      case 0x0600:
		printf ("WAND\t%03o\n", sValue & 0777);
		break;
	      case 0x0800:
		printf ("ROR\t%03o\n", sValue & 0777);
		break;
	      case 0x0A00:
		printf ("WOR\t%03o\n", sValue & 0777);
		break;
	      case 0x0C00:
		printf ("RXOR\t%03o\n", sValue & 0777);
		break;
	      case 0x0E00:
		printf ("EDRUPT\t%03o\n", sValue & 0777);
		break;
	      }
	    break;
	  case 0x1000:
	    if (0 == (sValue & 0x0C00))
	      printf ("DV\t%04o\n", sValue & 0x3FF);
	    else
	      printf ("BZF\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x2000:
	    switch (sValue & 0x0C00)
	      {
	      case 0x000:
		printf ("MSU\t%04o\n", sValue & 0x3FF);
		break;
	      case 0x400:
		printf ("QXCH\t%04o\n", sValue & 0x3FF);
		break;
	      case 0x800:
		printf ("AUG\t%04o\n", sValue & 0x3FF);
		break;
	      case 0xC00:
		printf ("DIM\t%04o\n", sValue & 0x3FF);
		break;
	      }
	    break;
	  case 0x3000:
	    printf ("DCA\t%04o\n", (sValue - 1) & 0xFFF);
	    break;
	  case 0x4000:
	    printf ("DCS\t%04o\n", (sValue - 1) & 0xFFF);
	    break;
	  case 0x5000:
	    printf ("INDEX\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x6000:
	    if (0 == (sValue & 0x0C00))
	      printf ("SU\t%04o\n", sValue & 0x3FF);
	    else
	      printf ("BZMF\t%04o\n", sValue & 0xFFF);
	    break;
	  case 0x7000:
	    printf ("MP\t%04o\n", sValue & 0xFFF);
	    break;
	  }
    }
}

//-----------------------------------------------------------------------------------
// Dump a memory range to the screen.  The memory range is specified by strings of 
// the following 6 types:
//      DUMP %o E%o,%o          N words of switched erasable
//      DUMP %o %o,%o           N words of common fixed
//      DUMP %o %o              N words of unswitched erasable or fixed-fixed.
//      DUMP %o C%o             N words from i/o channels.
//      DUMP E%o,%o             1 word of switched erasable
//      DUMP %o,%o              1 word of common fixed
//      DUMP %o                 1 word of unswitched erasable or fixed-fixed.
//      DUMP C%o                1 word from i/o channels.
//      DUMP                    Repeats last dump.
#ifndef GDBMI
static void
DumpMemory (agc_t * State, char *s)
{
  static int TypeLast = 0, iLast = 1, jLast = 0, kLast = 0;
  // i=N, j=banknum, k=offset.
  int i, j, k, Count = 0;
  if (!strcmp (s, "DUMP"))
    {
      i = iLast;
      j = jLast;
      k = kLast;
      if (TypeLast == 0)
	goto Type0;
      if (TypeLast == 1)
	goto Type1;
      if (TypeLast == 2)
	goto Type2;
      if (TypeLast == 3)
	goto Type3;
      iLast = jLast = kLast = 0;
      goto Type0;
    }
  else if (3 == sscanf (s, "DUMP%o E%o,%o", &i, &j, &k)
	   || ((i = 1), 2 == sscanf (s, "DUMP E%o,%o", &j, &k)))
    {
    Erasable:
    Type0:
      TypeLast = 0;
      iLast = i;
      jLast = j;
      kLast = k;
      if (j < 0 || j > 7)
	{
	  printf ("Illegal erasable bank number (%o).  Must be 0-7.\n", j);
	  return;
	}
      if (k < 01400 || k >= 02000)
	{
	  printf ("Illegal offset (%o).  Must be 1400-1777.\n", k);
	  return;
	}
      if (k + i > 02000)
	{
	  printf ("Range overflows bank.  Truncated to fit in the bank.\n");
	  i = 02000 - k;
	}
      if (i <= 0)
	{
	  printf ("Requested address range is empty.\n");
	  return;
	}
      for (; i > 0; i--, k++, Count++)
	{
	  if (Count == 0 || 0 == (k & 7))
	    printf ("E%o,%06o: ", j, k);
	  printf (" %05o", 0177777 & State->Erasable[j][k - 01400]);
	  if (7 == (7 & k))
	    printf ("\n");
	}
      if (0 != (7 & k))
	printf ("\n");
    }
  else if (3 == sscanf (s, "DUMP%o%o,%o", &i, &j, &k)
	   || ((i = 1), 2 == sscanf (s, "DUMP%o,%o", &j, &k)))
    {
    Fixed:
    Type1:
      TypeLast = 1;
      iLast = i;
      jLast = j;
      kLast = k;
      if (j < 0 || j > 043)
	{
	  printf ("Illegal common-fixed bank number (%o).  Must be 0-43.\n",
		  j);
	  return;
	}
      if (k < 02000 || k >= 04000)
	{
	  printf ("Illegal offset (%o).  Must be 2000-3777.\n", k);
	  return;
	}
      if (k + i > 04000)
	{
	  printf ("Range overflows bank.  Truncated to fit in the bank.\n");
	  i = 04000 - k;
	}
      if (i <= 0)
	{
	  printf ("Requested address range is empty.\n");
	  return;
	}
      for (; i > 0; i--, k++, Count++)
	{
	  if (Count == 0 || 0 == (k & 7))
	    printf ("%02o,%05o: ", j, k);
	  printf (" %06o", 0177777 & State->Fixed[j][k - 02000]);
	  if (7 == (7 & k))
	    printf ("\n");
	}
      if (0 != (7 & k))
	printf ("\n");
    }
  else if (2 == sscanf (s, "DUMP%o C%o", &i, &k)
	   || ((i = 1), 1 == sscanf (s, "DUMP C%o", &k)))
    {
    Type3:
      TypeLast = 3;
      iLast = i;
      jLast = j;
      kLast = k;
      if (k >= 0 && k <= 0777)
	{
	  if (k + i > 01000)
	    {
	      printf
		("Range overflows defined i/o channels.  Range truncated to fit.\n");
	      i = 01000 - k;
	    }
	  if (i <= 0)
	    {
	      printf ("Requested channel range is empty.\n");
	      return;
	    }
	  for (; i > 0; i--, k++, Count++)
	    {
	      if (Count == 0 || 0 == (k & 7))
		printf ("C%05o: ", k);
	      printf (" %06o", 0177777 & ReadIO (State, k));
	      if (7 == (7 & k))
		printf ("\n");
	    }
	  if (0 != (7 & k))
	    printf ("\n");
	}
      else
	{
	  printf ("I/O channel range not recognized.  Perhaps 000-0777?\n");
	  return;
	}
    }
  else if (2 == sscanf (s, "DUMP%o%o", &i, &k)
	   || ((i = 1), 1 == sscanf (s, "DUMP%o", &k)))
    {
    Type2:
      TypeLast = 2;
      iLast = i;
      jLast = j;
      kLast = k;
      if (k >= 0 && k <= 01377)
	{
	  // Note that I depend on a trick here, which is knowing that
	  // State.Erasable[0] butts up end-to-end with State.Erasable[1],
	  // which butts up end-to-end with State.Erasable[2].
	  // If this assumption isn't right, then dumps that span the 
	  // boundary at addresses 0400 or 01000 won't work right.
	  if (k + i > 01400)
	    {
	      printf
		("Range overflows bank.  Truncated to fit in the bank.\n");
	      i = 01400 - k;
	    }
	  if (i <= 0)
	    {
	      printf ("Requested address range is empty.\n");
	      return;
	    }
	  for (; i > 0; i--, k++, Count++)
	    {
	      if (Count == 0 || 0 == (k & 7))
		printf ("%05o: ", k);
	      printf (" %06o", 0177777 & State->Erasable[0][k]);
	      if (7 == (7 & k))
		printf ("\n");
	    }
	  if (0 != (7 & k))
	    printf ("\n");
	}
      else if (k >= 04000 && k <= 07777)
	{
	  // Note that I depend on a trick here, which is knowing that
	  // State.Fixed[3] butts up end-to-end with State.Fixed[2].
	  // If this assumption isn't right, then dumps that span the 
	  // boundary at address 06000 won't work right.
	  if (k + i > 010000)
	    {
	      printf
		("Range overflows bank.  Truncated to fit in the bank.\n");
	      i = 010000 - k;
	    }
	  if (i <= 0)
	    {
	      printf ("Requested address range is empty.\n");
	      return;
	    }
	  for (; i > 0; i--, k++, Count++)
	    {
	      if (Count == 0 || 0 == (k & 7))
		printf ("%05o: ", k);
	      printf (" %06o", 0177777 & State->Fixed[2][k - 04000]);
	      if (7 == (7 & k))
		printf ("\n");
	    }
	  if (0 != (7 & k))
	    printf ("\n");
	}
      else if (k >= 01400 && k <= 01777)
	{
	  j = (7 & (State->Erasable[0][RegEB] >> 8));
	  goto Erasable;
	}
      else if (k >= 02000 && k <= 03777)
	{
	  j = (037 & (State->Erasable[0][RegFB] >> 10));
	  if (j >= 030 && 0 != (0100 & State->OutputChannel7))
	    j += 010;
	  goto Fixed;
	}
      else
	{
	  printf
	    ("Memory range not recognized.  Perhaps 0000-01377 or 04000-07777?\n");
	  return;
	}
    }
  else
    {
      printf
	("The format of this command is \"DUMP N A\", where N is the number of words\n");
      printf ("and A is the starting address.  Examples of A are:\n");
      printf ("\t1234\t\tUnswitched erasable memory, 0-1377 octal.\n");
      printf ("\t4567\t\tCommon fixed memory, 4000-7777 octal.\n");
      printf
	("\tE4,1456\t\tSwitched erasable memory, banks E0-E7, offset 1400-1777 octal.\n");
      printf
	("\t12,2345\t\tFixed fixed memory, banks 0-43, offset 2000-3777 octal.\n");
      printf ("\tI123\t\tI/O channel, 000-777.\n");
    }
}
#endif /* Not GDBMI DumpMemory*/

//-----------------------------------------------------------------------------------
// Add a breakpoint.

#ifndef GDBMI
static void
AddBreakpoint (agc_t * State, char *s)
{
  int j, k, i, vRegBB, LineNumber;
  Symbol_t *Symbol = NULL;
  SymbolLine_t *Line = NULL;
  char Garbage[81], SymbolName[MAX_LABEL_LENGTH + 1];
  
  // If the symbol table is loaded, first see if it is a number, if so, then
  // it is a line number. If not, then try to lookup the symbol.
  if (HaveSymbols && (1 == sscanf (s, "BREAK %d%s", &LineNumber, Garbage)) &&
      (Line = ResolveLineNumber (LineNumber)))
    {
      // If we have the symbol table loaded and we can parse a line number out
      // of the break command and we can find that line number, then...
      k = Line->CodeAddress.SReg;

      // We will assume the line points to a fixed memory address, but flag
      // an error if not...
      if (Line->CodeAddress.Fixed)
	vRegBB = (Line->CodeAddress.FB << 10) | (Line->CodeAddress.Super << 7);
      else
	{
	  printf ("Line number points to erasable memory.\n");
	  return;
	}
    }
  else if (HaveSymbols && (1 == sscanf (s, "BREAK %s", SymbolName)) &&
	   (Symbol = ResolveSymbol (SymbolName, SYMBOL_LABEL)))
    {
      // If we have the symbol table loaded then try to see if the symbol can
      // be found, then...
      k = Symbol->Value.SReg;

      // We will assume the line points to a fixed memory address, but flag
      // an error if not...
      if (Symbol->Value.Fixed)
	vRegBB = ((Symbol->Value.FB & 037) << 10) | (Symbol->Value.Super << 7);
      else
	{
	  printf ("Symbol points to erasable memory.\n");
	  return;
	}
    }
  else if (2 == sscanf (s, "BREAK *E%o,%o", &j, &k))
    {
    Erasable:
      if (j < 0 || j > 7)
	{
	  printf ("Illegal erasable bank number (%o).  Must be 0-7.\n", j);
	  return;
	}
      if (k < 01400 || k >= 02000)
	{
	  printf ("Illegal offset (%o).  Must be 1400-1777.\n", k);
	  return;
	}
      vRegBB = j;
      if (j < 3)
	{
	  printf
	    ("Note that this breakpoint will NOT be hit on reaching the corresponding location\n");
	  printf
	    ("in unswitched-erasable.  Make a separate breakpoint for that, if desired.\n");
	}
    }
  else if (2 == sscanf (s, "BREAK *%o,%o", &j, &k))
    {
    Fixed:
      if (j < 0 || j > 043)
	{
	  printf ("Illegal common-fixed bank number (%o).  Must be 0-43.\n",
		  j);
	  return;
	}
      if (k < 02000 || k >= 04000)
	{
	  printf ("Illegal offset (%o).  Must be 2000-3777.\n", k);
	  return;
	}
      vRegBB = j << 10;
      if (j > 037)
	{
	  vRegBB = ((j - 010) << 10);
	  vRegBB |= 0100;
	}
      if (j == 2 || j == 3)
	{
	  printf
	    ("Note that this breakpoint will NOT be hit on reaching the corresponding location\n");
	  printf
	    ("in fixed-fixed memory.  Make a separate breakpoint for that, if desired.\n");
	}
    }
  else if (1 == sscanf (s, "BREAK *%o", &k))
    {
      if (k >= 0 && k <= 01377)
	{
	  printf
	    ("Note that this breakpoint will NOT be hit on reaching the corresponding location\n");
	  printf
	    ("in switched-erasable banks E0-E2.  Make a separate breakpoint for that, if desired.\n");
	}
      else if (k >= 04000 && k <= 07777)
	{
	  printf
	    ("Note that this breakpoint will NOT be hit on reaching the corresponding location\n");
	  printf
	    ("in common-fixed banks 02 or 03.  Make a separate breakpoint for that, if desired.\n");
	}
      else if (k >= 01400 && k <= 01777)
	{
	  j = (7 & (State->Erasable[0][RegEB] >> 8));
	  goto Erasable;
	}
      else if (k >= 02000 && k <= 03777)
	{
	  j = (037 & (State->Erasable[0][RegFB] >> 10));
	  if (j >= 030 && 0 != (0100 & State->OutputChannel7))
	    j += 010;
	  goto Fixed;
	}
      else
	{
	  printf
	    ("Memory range not recognized.  Perhaps 0000-01377 or 04000-07777?\n");
	  return;
	}
      vRegBB = 0;
    }
  else
    {
      printf ("The format of this command is \"BREAK L\", where L is a program label,\n");
      printf ("a line number in the current source file, or *A (with A being a memory\n");
      printf ("address).  Examples are:\n");
      printf ("\tPINBALL0\tProgram label PINBALL0.\n");
      printf ("\t10\t\tLine 10 of the current source-code file.\n");
      printf ("\t*1234\t\tUnswitched erasable memory, 0-1377 octal.\n");
      printf ("\t*4567\t\tCommon fixed memory, 4000-7777 octal.\n");
      printf ("\t*E4,1456\tSwitched erasable memory, banks E0-E7, offset 1400-1777 octal.\n");
      printf ("\t*12,2345\tFixed fixed memory, banks 0-43, offset 2000-3777 octal.\n");
      return;
    }
  for (i = 0; i < NumBreakpoints; i++)
    if (Breakpoints[i].Address12 == k && Breakpoints[i].vRegBB == vRegBB &&
	Breakpoints[i].WatchBreak == 0)
      {
	printf ("This breakpoint already exists.\n");
	return;
      }
  if (NumBreakpoints < MAX_BREAKPOINTS)
    {
      Breakpoints[NumBreakpoints].Address12 = k;
      Breakpoints[NumBreakpoints].vRegBB = vRegBB;
      Breakpoints[NumBreakpoints].WatchBreak = 0;
      Breakpoints[NumBreakpoints].Symbol = Symbol;
      Breakpoints[NumBreakpoints].Line = Line;
      NumBreakpoints++;
      printf ("Breakpoint added.\n");
    }
  else
    printf ("The maximum number of breakpoints is already defined.\n");
}
#endif /* END NOT GDBMI */ 

//-----------------------------------------------------------------------------------
// Add a watchpoint.
#ifndef GDBMI
static char AW_s[257];

static void
AddWatchpoint (agc_t * State, char *s)
{
  int j, k, i, vRegBB, WatchType, WatchValue = 0777777;
  Symbol_t *Symbol = NULL;
  char *ss;

  // JMS: First try to resolve the symbol if we are trying to break at label
  // instead of at an address. If the symbol is not found, then leave the
  // string along.
  if (!strncmp (s, "WATCH ", 6))
    ss = s + 6;
  else if (!strncmp (s, "VIEW ", 5))
    ss = s + 5;
  else 
    ss = NULL;
  i = 0;
  if (ss != NULL && strlen(ss) < sizeof (AW_s) - 1)
    i = sscanf (ss, "%s", AW_s);
  if (i != 0)
    Symbol = ResolveSymbol(AW_s, SYMBOL_VARIABLE | SYMBOL_REGISTER | SYMBOL_CONSTANT);
  if (Symbol != NULL && !Symbol->Value.Erasable)
    Symbol = NULL;
  if (Symbol != NULL)
    {
      // Redirect pointer s to a newly-created string stored in AW_s.
      for (ss = AW_s; *s != ' '; *ss++ = *s++);
      *ss++ = ' ';
      for (; *s == ' '; s++);
      for (; *s && *s != ' '; s++);
      if (1 == sscanf (s, "%o", &j))
        {
	  if (Symbol->Value.Banked) 
	    sprintf (ss, "E%o,%04o %05o", Symbol->Value.EB, Symbol->Value.SReg, j);
	  else
	    sprintf (ss, "%04o %05o", Symbol->Value.SReg, j);  
	}
      else
        {
	  if (Symbol->Value.Banked) 
	    sprintf (ss, "E%o,%04o", Symbol->Value.EB, Symbol->Value.SReg);
	  else
	    sprintf (ss, "%04o", Symbol->Value.SReg);  
	} 
      s = AW_s;
      //printf ("Input string converted to:  %s\n", s);
    }

  // At this point should have a string with symbols completely resolved.
  if (3 == sscanf (s, "WATCH E%o,%o%o", &j, &k, &WatchValue))
    {
    ErasableV:
      if (j < 0 || j > 7)
	{
	  printf ("Illegal erasable bank number (%o).  Must be 0-7.\n", j);
	  return;
	}
      if (k < 01400 || k >= 02000)
	{
	  printf ("Illegal offset (%o).  Must be 1400-1777.\n", k);
	  return;
	}
      WatchType = 3;
      vRegBB = j;
      if (j < 3)
	{
	  printf
	    ("Note that this watchpoint will be hit on reaching the corresponding location\n");
	  printf ("in unswitched-erasable.\n");
	}
    }
  else if (2 == sscanf (s, "WATCH %o%o", &k, &WatchValue))
    {
      if (k >= 0 && k <= 01377)
	{
	  printf
	    ("Note that this watchpoint will be hit on reaching the corresponding location\n");
	  printf ("in switched-erasable banks E0-E2.\n");
	}
      else if (k >= 04000 && k <= 07777)
	goto Illegal;
      else if (k >= 01400 && k <= 01777)
	{
	  j = (7 & (State->Erasable[0][RegEB] >> 8));
	  goto ErasableV;
	}
      else if (k >= 02000 && k <= 03777)
	goto Illegal;
      else
	goto Illegal;
      WatchType = 3;
      vRegBB = 0;
    }
  else if (2 == sscanf (s, "WATCH E%o,%o", &j, &k) ||
  	   2 == sscanf (s, "VIEW E%o,%o", &j, &k))
    {
    Erasable:
      if (j < 0 || j > 7)
	{
	  printf ("Illegal erasable bank number (%o).  Must be 0-7.\n", j);
	  return;
	}
      if (k < 01400 || k >= 02000)
	{
	  printf ("Illegal offset (%o).  Must be 1400-1777.\n", k);
	  return;
	}
      if (!strncmp (s, "VIEW", 4))
        WatchType = 4;
      else
        WatchType = 1;
      vRegBB = j;
      if (j < 3)
	{
	  printf
	    ("Note that this watchpoint will be hit on reaching the corresponding location\n");
	  printf ("in unswitched-erasable.\n");
	}
    }
  else if (1 == sscanf (s, "WATCH %o", &k) ||
  	   1 == sscanf (s, "VIEW %o", &k))
    {
      if (k >= 0 && k <= 01377)
	{
	  printf
	    ("Note that this watchpoint will be hit on reaching the corresponding location\n");
	  printf ("in switched-erasable banks E0-E2.\n");
	}
      else if (k >= 04000 && k <= 07777)
	goto Illegal;
      else if (k >= 01400 && k <= 01777)
	{
	  j = (7 & (State->Erasable[0][RegEB] >> 8));
	  goto Erasable;
	}
      else if (k >= 02000 && k <= 03777)
	goto Illegal;
      else
	{
	Illegal:
	  printf ("Memory range not recognized or illegal.\n");
	  return;
	}
      if (!strncmp (s, "VIEW", 4))
        WatchType = 4;
      else
        WatchType = 1;
      vRegBB = 0;
    }
  else
    {
      printf
	("The format of this command is \"WATCH A\", where A is an address in erasable memory,\n"
	 "or \"WATCH A V\", where V is an octal value.  The former simply waits for the value\n"
	 "stored at the address to change in any way whatever, while the latter waits for it to\n"
	 "change to a specific value.\n"
	 "Examples of A are:\n");
      printf ("\t1234\t\tUnswitched erasable memory, 0-1377 octal.\n");
      printf
	("\tE4,1456\t\tSwitched erasable memory, banks E0-E7, offset 1400-1777 octal.\n");
      printf ("Another variation is \"VIEW A\", which simply displays variables as they change,\n"
      	      "rather than interrupting execution.\n");
      return;
    }
  for (i = 0; i < NumBreakpoints; i++)
    if (Breakpoints[i].Address12 == k && Breakpoints[i].vRegBB == vRegBB &&
	Breakpoints[i].WatchBreak == WatchType)
      {
	printf ("This watchpoint already exists.\n");
	return;
      }
  if (NumBreakpoints < MAX_BREAKPOINTS)
    {
      Breakpoints[NumBreakpoints].Address12 = k;
      Breakpoints[NumBreakpoints].vRegBB = vRegBB;
      Breakpoints[NumBreakpoints].WatchBreak = WatchType;
      Breakpoints[NumBreakpoints].Symbol = Symbol;
      Breakpoints[NumBreakpoints].Line = NULL;
      if (WatchType == 1)
	Breakpoints[NumBreakpoints].WatchValue =
	  GetWatch (State, &Breakpoints[NumBreakpoints]);
      else
        Breakpoints[NumBreakpoints].WatchValue = WatchValue;
      NumBreakpoints++;
      printf ("Watchpoint added.\n");
    }
  else
    printf ("The maximum number of watchpoints is already defined.\n");
}
#endif /* END NOT GDBMI */

//----------------------------------------------------------------------------------------------
// Delete a breakpoint

#ifndef GDBMI
static 
void
DeleteBreakpoint (agc_t * State, char *s)
{
  int j, k, i, vRegBB;
  char Symbol[MAX_LABEL_LENGTH + 1];

  if (!strcmp (s, "DELETE"))
    {
      printf ("All breakpoints/watchpoints deleted.\n");
      NumBreakpoints = 0;
      return;
    }
  
  if (1 == sscanf (s, "DELETE %s", Symbol))
    {
      int SymbolFound = 0;
      // JMS: The case where we want to delete the symbol. Look for the
      // symbol in the breakpoint table
      for (i = 0; i < NumBreakpoints; i++)
	if (Breakpoints[i].Symbol != NULL &&
	    !strcmp(Breakpoints[i].Symbol->Name, Symbol))
	  {
	    SymbolFound = 1;
	    if (Breakpoints[i].WatchBreak)
	      printf ("Watchpoint deleted.\n");
	    else
	      printf ("Breakpoint deleted.\n");
	    NumBreakpoints--;
	    for (j = i; j < NumBreakpoints; j++)
	      Breakpoints[j] = Breakpoints[j + 1];
	    i--;
	  }
      if (SymbolFound)
        return;
    }

  if (2 == sscanf (s, "DELETE *E%o,%o", &j, &k))
    {
    Erasable:
      if (j < 0 || j > 7)
	{
	  printf ("Illegal erasable bank number (%o).  Must be 0-7.\n", j);
	  return;
	}
      if (k < 01400 || k >= 02000)
	{
	  printf ("Illegal offset (%o).  Must be 1400-1777.\n", k);
	  return;
	}
      vRegBB = j;
      if (j < 3)
	{
	  printf
	    ("Note that if there is a break/watch at the corresponding location\n");
	  printf
	    ("in unswitched-erasable memory, this will not delete it.  Do that separately.\n");
	}
    }
  else if (2 == sscanf (s, "DELETE *%o,%o", &j, &k))
    {
    Fixed:
      if (j < 0 || j > 043)
	{
	  printf ("Illegal common-fixed bank number (%o).  Must be 0-43.\n",
		  j);
	  return;
	}
      if (k < 02000 || k >= 04000)
	{
	  printf ("Illegal offset (%o).  Must be 2000-3777.\n", k);
	  return;
	}
      vRegBB = j << 10;
      if (j > 037)
	{
	  vRegBB = ((j - 010) << 10);
	  vRegBB |= 0100;
	}
      if (j == 2 || j == 3)
	{
	  printf
	    ("Note that if there is a break/watch at the corresponding location\n");
	  printf
	    ("in fixed-fixed memory, this will not delete it.  Do that separately.\n");
	}
    }
  else if (1 == sscanf (s, "DELETE *%o", &k))
    {
      if (k >= 0 && k <= 01377)
	{
	  printf
	    ("Note that if there is a break/watch at the corresponding location\n");
	  printf
	    ("in switched-erasable memory, this will not delete it.  Do that separately.\n");
	}
      else if (k >= 04000 && k <= 07777)
	{
	  printf
	    ("Note that if there is a break/watch at the corresponding location\n");
	  printf
	    ("in common-fixed memory, this will not delete it.  Do that separately.\n");
	}
      else if (k >= 01400 && k <= 01777)
	{
	  j = (7 & (State->Erasable[0][RegEB] >> 8));
	  goto Erasable;
	}
      else if (k >= 02000 && k <= 03777)
	{
	  j = (037 & (State->Erasable[0][RegFB] >> 10));
	  if (j >= 030 && 0 != (0100 & State->OutputChannel7))
	    j += 010;
	  goto Fixed;
	}
      else
	{
	  printf
	    ("Memory range not recognized.  Perhaps 0000-01377 or 04000-07777?\n");
	  return;
	}
      vRegBB = 0;
    }
  else
    {
      printf
	("The format of this command is \"DELETE S\", where S is symbol, or \"DELETE *A\",\n");
      printf ("where A is an address.  Examples of A are:\n");
      printf ("\t1234\t\tUnswitched erasable memory, 0-1377 octal.\n");
      printf ("\t4567\t\tCommon fixed memory, 4000-7777 octal.\n");
      printf
	("\tE4,1456\t\tSwitched erasable memory, banks E0-E7, offset 1400-1777 octal.\n");
      printf
	("\t12,2345\t\tFixed fixed memory, banks 0-43, offset 2000-3777 octal.\n");
      return;
    }
  for (i = 0; i < NumBreakpoints; i++)
    if (Breakpoints[i].Address12 == k && Breakpoints[i].vRegBB == vRegBB)
      {
	if (Breakpoints[i].WatchBreak)
	  printf ("Watchpoint deleted.\n");
	else
	  printf ("Breakpoint deleted.\n");
	NumBreakpoints--;
	for (j = i; j < NumBreakpoints; j++)
	  Breakpoints[j] = Breakpoints[j + 1];
	i--;
      }
}
#endif /* END NOT GDBMI BUILD */
//----------------------------------------------------------------------------------------------
// Change the value stored at a memory location or i/o channel.


#ifndef GDBMI /* Replaced by GDBMI SET VARIABLE */ 
static void
EditMemory (agc_t * State, char *s)
{
  int j, k, Value;
  if (3 == sscanf (s, "EDIT E%o,%o%o", &j, &k, &Value))
    {
    Erasable:
      if (j < 0 || j > 7)
	{
	  printf ("Illegal erasable bank number (%o).  Must be 0-7.\n", j);
	  return;
	}
      if (k < 01400 || k >= 02000)
	{
	  printf ("Illegal offset (%o).  Must be 1400-1777.\n", k);
	  return;
	}
      State->Erasable[j][k & 0377] = Value;
    }
  else if (3 == sscanf (s, "EDIT%o,%o%o", &j, &k, &Value))
    {
    Fixed:
      if (j < 0 || j > 043)
	{
	  printf ("Illegal common-fixed bank number (%o).  Must be 0-43.\n",
		  j);
	  return;
	}
      if (k < 02000 || k >= 04000)
	{
	  printf ("Illegal offset (%o).  Must be 2000-3777.\n", k);
	  return;
	}
      State->Fixed[j][k & 01777] = Value;
    }
  else if (2 == sscanf (s, "EDIT%o%o", &k, &Value))
    {
      if (k >= 0 && k <= 01377)
	{
	  State->Erasable[0][k] = Value;
	  // Must handle EB, FB, and BB registers specially.
	  if (k == RegEB)
	    {
	      State->Erasable[0][RegEB] &= 03400;
	      State->Erasable[0][RegBB] = (State->Erasable[0][RegBB] & ~7) |
		(State->Erasable[0][RegEB] >> 8);
	    }
	  else if (k == RegFB)
	    {
	      State->Erasable[0][RegFB] &= 076000;
	      State->Erasable[0][RegBB] =
		(State->Erasable[0][RegBB] & ~076000) | State->
		Erasable[0][RegFB];
	    }
	  else if (k == RegBB)
	    {
	      State->Erasable[0][RegFB] = 076000 & State->Erasable[0][RegBB];
	      State->Erasable[0][RegEB] =
		03400 & (State->Erasable[0][RegBB] << 8);
	    }
	}
      else if (k >= 04000 && k <= 07777)
	State->Fixed[2][k - 04000] = Value;
      else if (k >= 01400 && k <= 01777)
	{
	  j = (7 & (State->Erasable[0][RegEB] >> 8));
	  goto Erasable;
	}
      else if (k >= 02000 && k <= 03777)
	{
	  j = (037 & (State->Erasable[0][RegFB] >> 10));
	  if (j >= 030 && 0 != (0100 & State->OutputChannel7))
	    j += 010;
	  goto Fixed;
	}
      else
	{
	  printf
	    ("Memory range not recognized.  Perhaps 0000-01377 or 04000-07777?\n");
	  return;
	}
    }
  else if (2 == sscanf (s, "EDIT C%o%o", &k, &Value))
    {
      if (k >= 0 && k <= 0777)
	CpuWriteIO (State, k, Value);
      else
	{
	  printf ("I/O channel range not recognized.  Perhaps 000-0777?\n");
	  return;
	}
    }
  else
    {
      printf
	("The format of this command is \"EDIT A V\", where A is an address\n");
      printf ("and V is a 15-bit octal value.  Examples of A are:\n");
      printf ("\t1234\t\tUnswitched erasable memory, 0-1377 octal.\n");
      printf ("\t4567\t\tCommon fixed memory, 4000-7777 octal.\n");
      printf
	("\tE4,1456\t\tSwitched erasable memory, banks E0-E7, offset 1400-1777 octal.\n");
      printf
	("\t12,2345\t\tFixed fixed memory, banks 0-43, offset 2000-3777 octal.\n");
      printf ("\tI123\t\tI/O channel 000-777 octal.\n");
    }
}
#endif

//-----------------------------------------------------------------------------------
// My substitute for fgets, for use when stdin is unblocked.

#define MAX_FROMFILES 11
static FILE *FromFiles[MAX_FROMFILES];
static int NumFromFiles = 1;
//static char OutBuf[16384];

void
rfgets (agc_t *State, char *Buffer, int MaxSize, FILE * fp)
{
  int c, Count = 0;
  char *s;
  //static int FirstTime = 1;
  MaxSize--;
  while (1)
    {
      // While waiting for character input, continue to look for client connects
      // and disconnects.
      while ((fp != stdin && EOF == (c = fgetc (fp))) ||
            (fp == stdin && Buffer != (s = nbfgets (Buffer, MaxSize))))
	{
	  // If we have redirected console input, and the file of source data is
	  // exhausted, then reattach the console.
	  if (NumFromFiles > 1 && fp == FromFiles[NumFromFiles - 1])
	    {
	      NumFromFiles--;
	      printf ("Keystroke source-file closed.\n");
	      if (NumFromFiles == 1)
		printf ("The keyboard has been reattached.\n> ");
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
	  //if (FirstTime)
	  //  {
	  //    FirstTime = 0;
	  //    printf ("Non-blocking getchar.\n");
	  //  }
	  ChannelRoutine (State);
	}
      if (fp == stdin && s != NULL)
        return;
      Buffer[Count] = c;
      if (c == '\n' || Count >= MaxSize)
        {
	  Buffer[Count] = 0;
	  return;
	}
      Count++;
    }
}

//-----------------------------------------------------------------------------------
#ifdef GDBMI
static void catch_sigint(int sig);
int BreakPending = 0;
char FuncName[10];
#endif
  
int
main (int argc, char *argv[])
{
  FILE *LogFile = NULL;
  int LogCount = 0, LogLast = -1;
  char *RomImage = NULL, *CoreDump = NULL;
  int PatternValue, PatternMask;
  int i, j;
  struct tms DummyTime;
  clock_t NextCoreDump, DumpInterval;
  //char Symbol[129];
  //int k, n;
  //int16_t *WordPtr;
  clock_t RealTime, RealTimeOffset, LastRealTime, NextKeycheck;
  uint64_t /* unsigned long long */ CycleCount, DesiredCycles;

  // JMS: 07.28
  char FileName[MAX_FILE_LENGTH + 1];
  int LineNumber, LineNumberTo;
  char Dummy[MAX_FILE_LENGTH + 1];
  char SymbolName[129];
  Symbol_t *Symbol;
  
  //setvbuf (stdout, OutBuf, _IOLBF, sizeof (OutBuf));
  FromFiles[0] = stdin;
  NextKeycheck = times (&DummyTime);
  DumpInterval = 10 * sysconf (_SC_CLK_TCK);

#ifndef GDBMI
  printf ("Apollo Guidance Computer simulation, ver. " NVER ", built "
	  __DATE__ " " __TIME__ "\n" "Copyright (C) 2003-2005,2007 Ronald S. Burkey.\n"
	  "yaAGC is free software, covered by the GNU General Public License, and you are\n"
	  "welcome to change it and/or distribute copies of it under certain conditions.\n"
);
  printf ("Refer to http://www.ibiblio.org/apollo/index.html for additional information.\n");
#endif

  // Parse the command-line parameters.
  for (i = 1; i < argc; i++)
    {
      if (!strcmp (argv[i], "--help") || !strcmp (argv[i], "/?"))
	break;
      else if (!strncmp (argv[i], "--core=", 7))
	RomImage = &argv[i][7];
      else if (!strncmp (argv[i], "--resume=", 9))
	CoreDump = &argv[i][9];
      else if (1 == sscanf (argv[i], "--port=%d", &j))
        Portnum = j;
      else if (1 == sscanf (argv[i], "--dump-time=%d", &j))
        DumpInterval = j * sysconf (_SC_CLK_TCK);
      else if (!strcmp (argv[i], "--debug-dsky"))
	DebugDsky = 1;
      else if (!strcmp (argv[i], "--debug-deda"))
	DebugDeda = 1;
      else if (!strcmp (argv[i], "--cdu-log"))
        {
	  extern FILE *CduLog;
	  CduLog = fopen ("yaAGC.cdulog", "w");
	}
      else if (!strncmp (argv[i], "--cfg=", 6))
	{
	  if (ParseCfg (&State, &argv[i][6]))
	    {
	      RomImage = NULL;
	      printf
		("\n*** The switch %s refers to an unknown file. ***\n\n",
		 argv[i]);
	      break;
	    }
	}
#ifdef GDBMI
      else if (!strcmp (argv[i], "--fullname"))
        {
           FullNameMode = 1; /* Must use for Emacs debugger and KDbg */
        }
      else if (!strcmp (argv[i], "--quiet"))
        {
           QuietMode = 1; /* Must use for Codeblocks */
        }
#endif
      else if (!strcmp (argv[i], "--debug"))
	{
	  DebugMode = 1;
	  SingleStepCounter = 0;
#ifdef GDBMI
          RunState = 0;
#endif
	}
      else if (!strncmp (argv[i], "--symtab=", 9))
	{
	  strcpy(SymbolFile, &argv[i][9]);
	  HaveSymbols = 1;
	}
      else if (1 == sscanf (argv[i], "--interlace=%d", &j))
        SocketInterlaceReload = j;
    }
  if (argc == 1 || i < argc || (RomImage == NULL && !DebugDsky))
    {
      printf ("USAGE:\n"
	      "\tyaAGC --core=filename [OPTIONS]\n\n"
	      "The core filename is a binary image of the program,\n"
	      "constants, and so forth, that are supposed to be in\n"
	      "the AGC\'s core-rope memory.  Such a file can be\n"
	      "created from AGC assembly language using the yaYUL\n"
	      "assembler (if and when I write it) or from from an ASCII\n"
	      "represention of the binary image using the Oct2Bin\n"
	      "program.\n\n"
	      "OPTIONS:.\n"
	      "--port=n      Change the server port number (default=19697).\n"
	      "--debug-dsky  Rather than run the core program, go into DSKY-debug\n"
	      "              mode.  In this mode send pre-determined codes to\n"
	      "              the DSKY upon receiving DSKY keypresses.\n"
	      "--debug-deda  This mode runs the core program as usual, but also\n"
	      "              responds to messages from yaDEDA and generates fake\n"
	      "              messages to yaDEDA for testing purposes.\n"
	      "--cfg=file    The name of a configuration file.  Presently, the\n"
	      "              configuration files is used only for --debug-dsky\n"
	      "              mode.  It would typically be the same configuration\n"
	      "              file as used for yaDSKY.\n"
#ifdef GDBMI
	      "--debug       Use the GDB/MI debug interface to enable regular\n"
	      "              gdb cli interaction as well as gdb-front-ends.\n"
#else
	      "--debug       Halt before executing first instruction and enter\n"
	      "              Debugging mode.  The debugging mode is very primitive,\n"
	      "              but does allow you to set breakpoints in the AGC code,\n"
	      "              single-step AGC programs, examine or modify memory,\n"
	      "              and so forth.\n"
#endif
	      "--symtab=file The name of the symbol table file generated by yaYUL.\n"
	      "              If supplied, various debugging commands can take a\n"
	      "              symbol name as its argument.\n"
	      "--resume=file Use indicated file (previously created from the --debug\n"
	      "              mode\'s COREDUMP command) to initialize erasable memory,\n"
	      "              i/o channels, and hidden CPU state variables.  In\n"
	      "              effect, this allows you to take a snapshot of the AGC\n"
	      "              program and to resume its execution from that point,\n"
	      "              rather than always starting the AGC program with power-\n"
	      "              up defaults. The power-up default is to reload erasable\n"
	      "              memory with its contents at the prior power-down (from\n"
	      "              the file LM.core or CM.core), but not to restore the \n"
	      "              other state variables mentioned.  If you want a\n"
	      "              completely clean system, erase LM.core or CM.core.\n"
	      "              Alternately, if you want the state of the system to\n"
	      "              be identical to the state at last power-down, use \n"
	      "              --resume=LM.core or --resume=CM.core.\n"
	      "--interlace=N By default, yaAGC tries to read the socket interface\n"
	      "              by which it communicates with yaDSKY and other\n"
	      "              components between each %dth CPU instruction (N=%d).\n"
	      "              In theory, a value of N=1 provides the intention of \n"
	      "              obtaining maximum responsiveness, but on some slower\n"
	      "              computers, however, the overhead from these socket-\n"
	      "              interrogations actually slows the system down\n"
	      "              substantially.  The default value of N is intended\n"
	      "              to be a reasonable compromise that should work well\n"
	      "              on most computers.  With the --interlace option, you can\n"
	      "              fine-tune the system by setting the socket-checks\n"
	      "              to occur every N-th CPU instruction instead.\n"
	      "--dump-time=N By default, yaAGC saves the contents of erasable memory\n"
	      "              to disk (in the file LM.core or CM.core) every 10 seconds\n"
	      "              so that when yaAGC is next run it will (sort of)\n"
	      "              retained the contents of erasable memory.  You can change\n"
	      "              that interval to N seconds with this switch.\n"
	      "--cdu-log     Used only for debugging.  Causes a file called yaAGC.cdulog\n"
	      "              to be created, containing data related to the bandwidth-\n"
	      "              limiting of CDU inputs PCDU and MCDU.\n"
	      "Note that the core-rope image should be exactly 36 banks\n"
	      "(36x1024=36864 words, or 73728 bytes) in size.  Other sizes\n"
	      "may be accepted, but it is unclear what (if any) utility such\n"
	      "core-rope images would have.  (In particular, if the core-rope\n"
	      "is supposed to be for actual Luminary or Colossus software, then\n"
	      "the checksums of the missing memory banks would be incorrect, and\n"
	      "so the built-in self-test would fail.)\n" 
	      "\n", SocketInterlaceReload, SocketInterlaceReload);
      return (1);
    }

#ifdef GDBMI
    if (!QuietMode) gdbmiHandleShowVersion();

    /* Register the SIGINT to be handled by AGC Debugger */
    signal(SIGINT, catch_sigint);

    /* Debugging without symbols is strange */
    if (DebugMode == 1 && HaveSymbols != 1)
    {
       char* p;
       strcpy(SymbolFile,RomImage);
       p = SymbolFile + strlen(RomImage)-3;
       strcpy(p,"symtab");
       /* Needs a file exists check */
       HaveSymbols = 1;
    }
#endif

  // Initialize the simulation.
  if (!DebugDsky)
    {
      if (CoreDump == NULL)
        {
	  if (CmOrLm)
            i = agc_engine_init (&State, RomImage, "CM.core", 0);
	  else
            i = agc_engine_init (&State, RomImage, "LM.core", 0);
	}
      else
        i = agc_engine_init (&State, RomImage, CoreDump, 1);
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
	  printf ("Core-rope image file must have even size.\n");
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
    }

  //-----------------------------------------------------------------------
  // JMS: Initialization of the symbol table file is we have given a
  // --symtab command line argument
  //-----------------------------------------------------------------------
  if (HaveSymbols)
    {
      ResetSymbolTable ();
      if (!ReadSymbolTable(SymbolFile))
	HaveSymbols = 1;
      else
	HaveSymbols = 0;
    }

  // Other stuff may need to go here, to initialize the DSKY simulation and
  // the hardware-backend simulation.  At present, though, I'm not sure what
  // that stuff may be.


  // Run the simulated CPU.  Expecting to ACCURATELY cycle the simulation every 
  // 11.7 microseconds within Linux (or Win32) is a bit too much, I think.
  // (Not that it's really critical, as long as it looks right from the
  // user's standpoint.)  So I do a trick:  I just execute the simulation
  // often enough to keep up with real-time on the average.  AGC time is
  // measured as the number of machine cycles divided by AGC_PER_SECOND, 
  // while real-time is measured using the times() function.  What this mains
  // is that AGC_PER_SECOND AGC cycles are executed every CLK_TCK clock ticks.  
  // The timing is thus rather rough-and-ready (i.e., I'm sure it can be improved 
  // a lot).  It's good enough for me, for NOW, but I'd be happy to take suggestions 
  // for how to improve it in a reasonably portable way.
  RealTimeOffset = times (&DummyTime);	// The starting time of the program.
  NextCoreDump = RealTimeOffset + DumpInterval;
  CycleCount = State.CycleCounter * sysconf (_SC_CLK_TCK);	// Number of AGC cycles so far.
  RealTimeOffset -= (CycleCount + AGC_PER_SECOND / 2) / AGC_PER_SECOND;
  LastRealTime = ~0UL;
  SaveFixed (&State);			// For debugging.
  while (1)
    {
      int Break;
      RealTime = times (&DummyTime);
      if (RealTime != LastRealTime)
	{
	  //static int debug_count = 0;
	  //printf ("Here %d %lld %lld\n", debug_count++, CycleCount, DesiredCycles);
	  // Make a routine core dump.
	  if (RealTime >= NextCoreDump)
	    {
	      if (CmOrLm)
	        MakeCoreDump (&State, "CM.core");
              else
	        MakeCoreDump (&State, "LM.core");
	      NextCoreDump = RealTime + DumpInterval;
	    }
	  // Need to recalculate the number of AGC cycles we're supposed to
	  // have executed.  Notice the trick of multiplying both CycleCount
	  // and DesiredCycles by CLK_TCK, to avoid a long long division by CLK_TCK.
	  // This not only reduces overhead, but actually makes the calculation
	  // more exact.  A bit tricky to understand at first glance, though.
	  LastRealTime = RealTime;
	  //DesiredCycles = ((RealTime - RealTimeOffset) * AGC_PER_SECOND) / CLK_TCK;
	  //DesiredCycles = (RealTime - RealTimeOffset) * AGC_PER_SECOND;
	  // The calculation is done in the following funky way because if done as in
	  // the line above, the right-hand side will be done in 32-bit arithmetic
	  // on a 32-bit CPU, while the left-hand side is 64-bit, and so the calculation
	  // will overflow and fail after 4 minutes of operation.  Done the following
	  // way, the calculation will always be 64-bit.  Making AGC_PER_SECOND a ULL
	  // constant in agc_engine.h would fix it, but the Orbiter folk wouldn't
	  // be able to compile it.
	  DesiredCycles = RealTime;
	  DesiredCycles -= RealTimeOffset;
	  DesiredCycles *= AGC_PER_SECOND;
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
	  CurrentBB =
	    (State.Erasable[0][RegBB] & 076007) | (State.
						   InputChannel[7] & 0100);
	  if (State.PendFlag)
	    Break = 0;
	  else
	    {
	      if (SingleStepCounter == 0)
		{
		  Break = 1;
#ifndef GDBMI
		  printf ("Stepped.\n");
#endif
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
		      if (SingleStepCounter > 0)
			SingleStepCounter--;
		      for (Break = i = 0; i < NumBreakpoints; i++)
			if (Breakpoints[i].WatchBreak == 2
#ifdef GDBMI
                            && gdbmiCheckBreakpoint(&State,&Breakpoints[i])
#endif
                           )
			  {
			    // Pattern!
			    if (Breakpoints[i].Address12 ==
				(Value & Breakpoints[i].vRegBB))
			      {
				printf ("Hit pattern, Value=" PAT " Mask=" PAT
					".\n", Breakpoints[i].Address12,
					Breakpoints[i].vRegBB);
#ifdef GDBMI
                                gdbmiUpdateBreakpoint(&State,&Breakpoints[i]);
#endif				
                                Break = 1;
				break;
			      }
			  }
			else if (Breakpoints[i].WatchBreak == 0
#ifdef GDBMI
                                 && gdbmiCheckBreakpoint(&State,&Breakpoints[i])
#endif
                                )
			  {
			    int Address12, vRegBB;
			    int CurrentFB, vCurrentFB;
			    Address12 = Breakpoints[i].Address12;
			    if (Address12 != CurrentZ)
			      continue;

			    if (Address12 < 01400)
			      {
#ifndef GDBMI
				if (Breakpoints[i].Symbol != NULL)
				  printf ("Hit breakpoint %s at %05o.\n",
					  Breakpoints[i].Symbol->Name, Address12);
				else
				  printf ("Hit breakpoint at %05o.\n", Address12);
#else
              printf ("Breakpoint %d, %s () at %s:%d\n",i+1,
              			  gdbmiConstructFuncName(&Breakpoints[i].Line->CodeAddress,FuncName),
                       Breakpoints[i].Line->FileName,
                       Breakpoints[i].Line->LineNumber);
              gdbmiUpdateBreakpoint(&State,&Breakpoints[i]);
#endif
                                Break = 1;
				break;
			      }
			    if (Address12 >= 04000)
			      {
#ifndef GDBMI
				if (Breakpoints[i].Symbol != NULL)
				  printf ("Hit breakpoint %s at %05o.\n",
					  Breakpoints[i].Symbol->Name, Address12);
				else
				  printf ("Hit breakpoint at %05o.\n", Address12);
#else
              printf ("Breakpoint %d, %s () at %s:%d\n",i+1,
              			  gdbmiConstructFuncName(&Breakpoints[i].Line->CodeAddress,FuncName),
                       Breakpoints[i].Line->FileName,
                       Breakpoints[i].Line->LineNumber);
              gdbmiUpdateBreakpoint(&State,&Breakpoints[i]);
#endif
				Break = 1;
				break;
			      }

			    vRegBB = Breakpoints[i].vRegBB;
			    if (Address12 >= 01400 && Address12 < 02000 &&
				(vRegBB & 7) == (CurrentBB & 7))
			      {
				// JMS: I'm not convinced yet that we can have a
				// breakpoint in erasable memory that has a symbol
				if (Breakpoints[i].Symbol != NULL)
				  printf ("Hit breakpoint %s at E%o,%05o.\n",
					  Breakpoints[i].Symbol->Name,
					  CurrentBB & 7, Address12);
				else
				  printf ("Hit breakpoint at E%o,%05o.\n",
					  CurrentBB & 7, Address12);

#ifdef GDBMI
                                gdbmiUpdateBreakpoint(&State,&Breakpoints[i]);
#endif
				Break = 1;
				break;
			      }
			    CurrentFB = (CurrentBB >> 10) & 037;
			    if (CurrentFB >= 030 && (CurrentBB & 0100))
			      CurrentFB += 010;
			    vCurrentFB = (vRegBB >> 10) & 037;
			    if (vCurrentFB >= 030 && (vRegBB & 0100))
			      vCurrentFB += 010;
			    if (Address12 >= 02000 && Address12 < 04000 &&
				CurrentFB == vCurrentFB)
			      {
				int Bank;
				Bank = (CurrentBB >> 10) & 037;
				if (0 != (CurrentBB & 0100) && Bank >= 030)
				  Bank += 010;

				if (Breakpoints[i].Symbol != NULL)
				  printf ("Hit breakpoint %s at %02o,%05o.\n",
					  Breakpoints[i].Symbol->Name, Bank, Address12);
				else
				  printf ("Hit breakpoint at %02o,%05o.\n",
					  Bank, Address12);
#ifdef GDBMI
                                gdbmiUpdateBreakpoint(&State,&Breakpoints[i]);
#endif
				Break = 1;
				break;
			      }
			  }
			else if ((Breakpoints[i].WatchBreak == 1 &&
#ifdef GDBMI
                                  gdbmiCheckBreakpoint(&State,&Breakpoints[i]) &&
#endif
				  Breakpoints[i].WatchValue != GetWatch (&State,
									 &Breakpoints
									 [i])) ||
				  (Breakpoints[i].WatchBreak == 3 &&
				   Breakpoints[i].WatchValue == GetWatch (&State,
									 &Breakpoints
									 [i])))
			  {
			    int Address12, vRegBB, Before, After;
			    Address12 = Breakpoints[i].Address12;
			    Before = (Breakpoints[i].WatchValue & 077777);
			    After = (GetWatch (&State, &Breakpoints[i]) & 077777);
			    if (Address12 < 01400)
			      {
				if (Breakpoints[i].Symbol != NULL)
				  printf ("Hit watchpoint %s at %05o, %06o -> %06o.\n",
					  Breakpoints[i].Symbol->Name, Address12,
					  Before, After);
				else
				  printf ("Hit watchpoint at %05o, %06o -> %06o.\n",
					  Address12, Before, After);
				if (Breakpoints[i].WatchBreak == 1)
				  Breakpoints[i].WatchValue =
				    GetWatch (&State, &Breakpoints[i]);
#ifdef GDBMI
                                gdbmiUpdateBreakpoint(&State,&Breakpoints[i]);
#endif
                                Break = 1;
				break;
			      }
			    vRegBB = Breakpoints[i].vRegBB;
			    if (Address12 >= 01400 && Address12 < 02000 &&
				(vRegBB & 7) == (CurrentBB & 7))
			      {
				if (Breakpoints[i].Symbol == NULL)
				  printf
				    ("Hit watchpoint at E%o,%05o, %06o -> %06o.\n",
				     CurrentBB & 7, Address12, Before, After);
				else
				  printf
				    ("Hit watchpoint %s at E%o,%05o, %06o -> %06o.\n",
				     Breakpoints[i].Symbol->Name, CurrentBB & 7,
				     Address12, Before, After);

				if (Breakpoints[i].WatchBreak == 1)
				  Breakpoints[i].WatchValue =
				    GetWatch (&State, &Breakpoints[i]);
#ifdef GDBMI
                                gdbmiUpdateBreakpoint(&State,&Breakpoints[i]);
#endif				
                                Break = 1;
				break;
			      }
			 }
			else if ((Breakpoints[i].WatchBreak == 4 &&
#ifdef GDBMI
                                  gdbmiCheckBreakpoint(&State,&Breakpoints[i]) &&
#endif
                                  Breakpoints[i].WatchValue != GetWatch (&State,
									 &Breakpoints
									 [i])))
			  {
			    int Address12, vRegBB, Before, After;
			    Address12 = Breakpoints[i].Address12;
			    Before = (Breakpoints[i].WatchValue & 077777);
			    After = (GetWatch (&State, &Breakpoints[i]) & 077777);
			    if (Address12 < 01400)
			      {
				if (Breakpoints[i].Symbol != NULL)
				  printf ("%s=%06o\n", Breakpoints[i].Symbol->Name, After);
				else
				  printf ("(%05o)=%06o\n", Address12, After);
				Breakpoints[i].WatchValue = GetWatch (&State, &Breakpoints[i]);
			      }
			    else 
			      {
				vRegBB = Breakpoints[i].vRegBB;
				if (Address12 >= 01400 && Address12 < 02000 &&
				    (vRegBB & 7) == (CurrentBB & 7))
				  {
				    if (Breakpoints[i].Symbol == NULL)
				      printf ("(E%o,%05o)=%06o\n", CurrentBB & 7, Address12, After);
				    else
				      printf ("%s=%06o\n", Breakpoints[i].Symbol->Name, After);
				    Breakpoints[i].WatchValue = GetWatch (&State, &Breakpoints[i]);
				  }
			      }
			 }
		    }
		}
	    }
#ifdef DEBUG_OVERWRITE_FIXED
	  if (CheckFixed (&State))		// For debugging.
	    {
	      Break = 1;
	      printf ("Fixed memory at address 0%o,0%o has changed from 0%o to 0%o.\n",
	      	      iChangeFixed, jChangeFixed, Fixed[iChangeFixed][jChangeFixed],
		      State.Fixed[iChangeFixed][jChangeFixed]);
	    }
#endif
#ifdef GDBMI
          if (BreakPending)
          {
             BreakPending = 0;
             Break = 1;
          }
#endif
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
#ifndef GDBMI
	      for (i = j = 0; i < NumServers; i++)
		if (Clients[i].Socket != -1)
		  j++;
	      if (j > 0)
		{
		  int i;
		  printf ("Client sockets (%d/%d):", j, NumServers);
		  for (i = 0; i < NumServers; i++)
		    if (Clients[i].Socket != -1)
		      printf (" %d", Clients[i].Socket);
		  printf ("\n");
		}
	      printf
		("ACC=%06o \tL=%06o \tQ=%06o \tEB=%06o(E%o)\t" LB "FB=%06o(%02o)\tZ=%06o \tBB=%06o\n",
		 0177777 & State.Erasable[0][RegA],
		 0177777 & State.Erasable[0][RegL],
		 0177777 & State.Erasable[0][RegQ],
		 0177777 & State.Erasable[0][RegEB],
		 07 & (State.Erasable[0][RegEB] >> 8),
		 0177777 & State.Erasable[0][RegFB],
		 037 & (State.Erasable[0][RegFB] >> 10),
		 0177777 & State.Erasable[0][RegZ],
		 0177777 & State.Erasable[0][RegBB]);
	      printf
		("ARUPT=%06o\tLRUPT=%06o\tQRUPT=%06o\tZRUPT=%06o\t" LB "BBRUPT=%06o\t"
		 "BRUPT=%05o\tCHAN07=%05o\n",
		 0177777 & State.Erasable[0][RegARUPT],
		 0177777 & State.Erasable[0][RegLRUPT],
		 0177777 & State.Erasable[0][RegQRUPT],
		 0177777 & State.Erasable[0][RegZRUPT],
		 0177777 & State.Erasable[0][RegBBRUPT],
		 0177777 & State.Erasable[0][RegBRUPT],
		 0177777 & State.InputChannel[7]);
	      //if (State.PendFlag)
	      //  ss = "\tWORKING";
	      //else
	      //ss = " ";
	      printf
		("CYR=%06o\tSR=%06o\tCYL=%06o\tEDOP=%06o",
		 0177777 & State.Erasable[0][RegCYR],
		 0177777 & State.Erasable[0][RegSR],
		 0177777 & State.Erasable[0][RegCYL],
		 0177777 & State.Erasable[0][RegEDOP]);
#ifndef WIN32
	      printf
		("\t\t\tRealtime=%lu/%lu",
		 RealTime - RealTimeOffset, sysconf (_SC_CLK_TCK));
#endif		 
	      printf ("\n");
	      if (0040000 == (0140000 & State.Erasable[0][RegA]))
		OverflowChar = '+';
	      else if (0100000 == (0140000 & State.Erasable[0][RegA]))
		OverflowChar = '-';
	      else
		OverflowChar = '0';
	      if (0040000 == (0140000 & State.Erasable[0][RegQ]))
		OverflowCharQ = '+';
	      else if (0100000 == (0140000 & State.Erasable[0][RegQ]))
		OverflowCharQ = '-';
	      else
		OverflowCharQ = '0';
	      printf
		("Index=%05o\tExtend=%d\tInterrupts=%d\tOverflowAQ=%c%c\t" LB 
		 "ISR=%d\t\tCycles=%llu/85333",
		 077777 & State.IndexValue,
		 State.ExtraCode,
		 State.AllowInterrupt, OverflowChar, OverflowCharQ, State.InIsr, State.CycleCounter);
#ifdef WIN32
              if (State.CycleCounter < 10)
	        printf ("\t");
              if (State.CycleCounter < 1000000000)
	        printf ("\t");
	      printf
		("\tRealtime=%lu/%d",
		 RealTime - RealTimeOffset, sysconf (_SC_CLK_TCK));
#endif
	      printf ("\n");
#endif /* End GDBMI */

	      // JMS: 07.28
	      // If we have the symbol table, then print out the actual source,
	      // rather than just a disassembly
	      if (HaveSymbols)
		{
		  // Resolve the current program counter into an entry into
		  // the program line table. We pass in the current value of
		  // the Z register, but also need the BB register and the
		  // super-bank bit to resolve addresses.
		  int CurrentZ = State.Erasable[0][RegZ] & 07777;
		  int FB = 037 & (State.Erasable[0][RegBB] >> 10);
		  int SBB = (State.OutputChannel7 & 0100) ? 1 : 0;
		  SymbolLine_t *Line = ResolveLineAGC(CurrentZ, FB, SBB);

		  // There are several ways this can fail, and if either does we
		  // just want to disasemble: if we didn't find the line in the
		  // table or if ListSource() fails.
#ifndef GDBMI
		  if (Line == NULL || ListSourceLine (Line->FileName, Line->LineNumber,
						      ShowAddressContents (&State)))

		    Disassemble (&State);
#else
                  if (Line)
                  {
                     LoadSourceLine(Line->FileName, Line->LineNumber);
                     //if (RunState)
                     {
                        if (FullNameMode) gdbmiPrintFullNameContents(Line);
                        else Disassemble (&State);
                     }
                        
                     //printf("  %s:%d:%d:beg:0x%04x\n",
                       //  Line->FileName, Line->LineNumber,Line->LineNumber,
                        // gdbmiLinearFixedAddr(CurrentZ,FB,SBB));
                  }
#endif
		}
	      else
		  Disassemble (&State);
	      while (1)
		{
		  if (DebugMode && NumFromFiles == 1)
		    {
		      // JMS: Tell the thread which is actually reading the input from
		      // stdin to actually go ahead and read. At this point, we know that
		      // the last debugging command has been processed.
		      nbfgets_ready(agcPrompt);
#ifndef USE_READLINE
		      printf ("%s",agcPrompt);
#endif  // USE_READLINE
	              fflush(stdout);
		    }
		  s[sizeof (s) - 1] = 0;
		  rfgets (&State, s, sizeof (s) - 1, FromFiles[NumFromFiles - 1]);
		  // Normalize the strings by getting rid of leading, trailing
		  // or duplicated spaces.
		  i = sscanf (s, "%s%s%s%s%s", s1, s2, s3, s4, s5);
		  if (i == 1)
		    strcpy (s, s1);
		  else if (i == 2)
		    sprintf (s, "%s %s", s1, s2);
		  else if (i == 3)
		    sprintf (s, "%s %s %s", s1, s2, s3);
		  else if (i == 4)
		    sprintf (s, "%s %s %s %s", s1, s2, s3, s4);
		  else if (i == 5)
		    sprintf (s, "%s %s %s %s %s", s1, s2, s3, s4, s5);
		  else 
		    s[0] = 0;
		  //printf ("Command is \"%s\"\n", s);  
		  if (s[0] == '#')
		    continue;
		  if (s[0] == 0)
		    continue;
		  strcpy (sraw, s);
		  RealTimeOffset +=
		    ((RealTime = times (&DummyTime)) - LastRealTime);
		  LastRealTime = RealTime;
		  for (ss = s; *ss; *ss = toupper (*ss), ss++);
		    //if (*ss == '\n')
		    //  *ss = 0;
		  //for (ss = sraw; *ss; ss++)
		  //  if (*ss == '\n')
		  //    *ss = 0;
#ifdef GDBMI
		  if (gdbmiHelp(s) > 0) continue;
#else
		  if (!strcmp (s, "HELP"))
		    {
		      printf ("\n"
			      "Unless otherwise specified, all numbers are in octal notation.\n"
			      "Addresses are a single octal number (like 130 or 4655) when\n"
			      "referring to unswitched-erasable or fixed-fixed memory, are\n"
			      "octal pairs (like 23,2345) when referring to common-fixed memory,\n"
			      "or are octal pairs prefixed with E (like E5,1456) when referring\n"
			      "to switched-erasable memory.  Common-fixed memory banks in super-\n"
			      "bank 1 are referred to as banks 40, 41, 42, and 43 (octal).  When\n"
			      "referring to i/o channels rather than to memory, we prefix the \n"
			      "channel number by \'C\' (like C7).\n"
			      "\n"
			      "For information on specific topics, use one of the following:\n"
			      "\thelp backtrace\n"
			      "\thelp backtraces\n"
			      "\thelp break\n"
			      "\thelp breakpoints\n"
			      "\thelp cont\n"
			      "\thelp coredump\n"
			      "\thelp delete\n"
			      "\thelp dump\n"
			      "\thelp edit\n"
			      "\thelp files\n" // JMS: 07.30
			      "\thelp fromfile\n"
			      "\thelp getoct\n"
			      "\thelp interrupts\n"
			      "\thelp intoff\n"
			      "\thelp inton\n"
			      "\thelp list\n" // JMS: 07.28
			      "\thelp log\n"
			      "\thelp maskoff\n"
			      "\thelp maskon\n"
			      "\thelp pattern\n"
			      "\thelp print\n"
			      "\thelp quit\n"
			      "\thelp step\n"
			      "\thelp sym-dump\n"
			      "\thelp symbol-file\n"
			      "\thelp view\n"
			      "\thelp watch\n"
			      "\thelp whatis" "\n");
		      continue;
		    }
#endif /* GDBMI HELP */
		  else if (!strcmp (s, "HELP BACKTRACE"))
		    {
		      printf ("\n"
		              "backtrace N\n"
			      "\tJump to a given backtrace point, as identified by the\n"
			      "\tindex numbers shown in the \'backtraces\' command.\n"
			      "\tIndex 0 is the most recent backtrace point, index 1\n"
			      "\tthe next-most-recent, and so on.  This restores all\n"
			      "\terasable memory and i/o channels.  However, any\n"
			      "\tperipherals (such as a DSKY) will not necessarily\n"
			      "\treturn to their previous states.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP BACKTRACES"))
		    {
		      printf ("\n"
			      "backtraces\n"
			      "\tDisplays the most recent backtrace points.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP BREAK"))
		    {
		      printf ("\n"
		      	      "break A\n"
			      "\tSet a breakpoint at A, where A is:\n"
			      "\t  LABEL:    set a breakpoint at the label\n"
			      "\t  LINE:     set a breakpoint in the current file at a line number\n"
			      "\t  *ADDRESS: set a breakpoint at address A.  If an address requiring\n"
			      "\t            a bank number is used, but the bank number is omitted,\n"
			      "\t            the bank number is taken from the EB or FB register.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP BREAKPOINTS"))
		    {
		      printf ("\n"
			      "breakpoints\n"
			      "\tList the defined breakpoints, watchpoints, and patterns.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP CONT"))
		    {
		      printf ("\n"
			      "cont\n"
			      "\tContinue execution.  The program will continue executing\n"
			      "\tuntil a breakpoint is reached or, in Linux or (for versions\n"
			      "\t20040810 or later) Win32, until you hit the carriage-return\n"
			      "\tkey.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP COREDUMP"))
		    {
		      printf ("\n"
			      "coredump F\n"
			      "\tWrite a core-dump file to disk, using the filename F.\n"
			      "\tThe core-dump file can later be reloaded by running\n"
			      "\twith the --resume switch, causing the AGC program\n"
			      "\tto continue from exactly this point rather than from\n"
			      "\tthe beginning.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP DELETE"))
		    {
		      printf ("\n"
		              "delete [A]\n"
			      "\tDelete the breakpoint or watchpoint at address A.  If \n"
			      "\tA is omitted, all breakpoints and watchpoints are deleted.\n"
			      "\tIf an address requiring a bank number is used, but the bank\n"
			      "\tnumber is omitted,the bank number is taken from the EB or FB\n"
			      "\tregister.\n"
			      "\n"
			      "delete V M\n"
			      "\tDelete the pattern with value V and mask M.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP DUMP"))
		    {
		      printf ("\n"
			      "dump [N] A\n"
			      "\tDump values of N memory or i/o channel locations, from\n"
			      "\taddress A.  If N is omitted, it defaults to 1.  If an address\n"
			      "\trequiring a bank number is used, but the bank number is\n"
			      "\tomitted, the bank number is taken from the EB or FB register.\n"
			      "\n"
			      "dump\n"
			      "\tSimply repeat the last DUMP performed.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP EDIT"))
		    {
		      printf ("\n"
		              "edit A V\n"
			      "\tChange value of memory location or i/o channel A to V.\n"
			      "\tIf an address requiring a bank number is used, but the \n"
			      "\tbank number is omitted, the bank number is taken from the\n"
			      "\tEB or FB register.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP FILES"))
		    {
		      printf ("\n"
			      "files RegularExpression\n"
			      "\tDumps all of the source files whose names match the specified\n"
			      "\tregular expression.  For example,\n"
			      "\t\tfiles not           All files containing NOT.\n"
			      "\t\tfiles ^not          All files beginning with NOT.\n"
			      "\t\tfiles not$          All files ending with NOT.\n"
			      "\t\tfiles (^not)|(not$) Beginning or ending with NOT.\n"
			      "\tThe list is arbitrarily truncated after %d files.\n",
			      MAX_FILE_DUMP);
		      continue;
		    }
		  else if (!strcmp (s, "HELP FROMFILE"))
		    {
		      printf ("\n"
			      "fromfile F\n"
			      "\tStart taking debugger commands from a file with filename F\n"
			      "\trather than from the keyboard.  When the file is exhausted,\n"
			      "\tkeyboard control will be resumed.  The use I envisage for\n"
			      "\tthis is to set up a bunch of breakpoints or other initialization.\n"
			      "\tFROMFILE commands can be nested up to 10 levels.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP GETOCT"))
		    {
		      printf ("\n"
		              "The GETOCT command is used in two different ways, depending\n"
			      "on the nature of the expression it operates on.\n"
			      "\n"
			      "getoct Expression\n"
			      "\tConverts a numeric expression into the octal format\n"
			      "\tused by the AGC processor.  The expression types are\n"
			      "\tlimited to the following:\n"
			      "\t\tHexOrDecimal * HexOrDecimal\n"
			      "\t\tHexOrDecimal / HexOrDecimal\n"
			      "\tIn these expressions, spaces are significant.  By\n"
			      "\t\"HexOrDecimal\" is meant a hexadecimal number with\n"
			      "\tleading \"0x\", such as 0xF000, or else a decimal\n"
			      "\tnumber, which may including + or - signs, decimal\n"
			      "\tpoint, and exponential, such as -1.5E-3 or 16.\n"
			      "\n"
		              "getoct Expression\n"
			      "\tConverts a pair of octal numbers representing a single\n"
			      "\tnumeric value in the native format used by the AGC\n"
			      "\tprocessor to a more recognisable format.  The expression\n"
			      "\ttypes are limited to the following:\n"
			      "\t\tOctal Octal\n"
			      "\t\tOctal Octal * En * Bn\n"
			      "\tIn these expressions, spaces are significant.\n"
			      "\tBy \"Octal\" is meant any octal number, of 5 digits\n"
			      "\tor less, with or without a leading 0.  By \"En\" is \n"
			      "\tmeant something like E5 or E-3.  By \"Bn\" is meant\n"
			      "\tsomething like B5 or B-3. In both cases, the \"n\" part\n"
			      "\tof En or Bn is a decimal integer.  Notice that although\n"
			      "\ta large number of decimal places may be printed, the \n"
			      "\toriginal octal number only has (at most!) 28 significant\n"
			      "\tbits, and thus there are actually at most 9 significant\n"
			      "\tdecimal digits.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP INTERRUPTS"))
		    {
		      printf ("\n"
			      "interrupts\n"
			      "\tDisplay the active interrupt-service requests.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP INTOFF"))
		    {
		      printf ("\n"
			      "intoff N\n"
			      "\tClear interrupt-request N (1, 2, ..., 10).\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP INTON"))
		    {
		      printf ("\n"
			      "inton N\n"
			      "\tSet interrupt-request N (1, 2, ..., 10).\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP LOG"))
		    {
		      printf ("\n"
			      "log N\n"
			      "\tLog next N instructions to the file yaAGC.log.  The file\n"
			      "\tformat is very simple, and is only intended to be used\n"
			      "\tfor regression testing.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP LIST"))
		    {
		      printf ("\n"
			      "list\n"
			      "\tList displays lines in a source file. There are several\n"
			      "\tvariants of this command\n"
			      "\t  list FILENAME:LINENO, to list around a line number in a file\n"
			      "\t  list LABEL, to list beginning at a label\n"
			      "\t  list LINENO, to list around a line in the current file\n"
			      "\t  list FROM,TO, to list a range of lines\n"
			      "\t  list -, to list lines previous to the current listing\n"
			      "\t  list, to list the next set of lines\n" "\n"); 
		      continue;
		    }
		  else if (!strcmp (s, "HELP MASKOFF"))
		    {
		      printf ("\n"
			      "maskoff N\n"
			      "\tReset a mask within the debugger to re-allow interrupt\n"
			      "\tN (1, ..., 10).  If N=0, all interrupts are unmasked.\n" 
			      "\tIn other words, this command undoes what the MASKON\n"
			      "\tcommand does.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP MASKON"))
		    {
		      printf ("\n"
			      "maskon N\n"
			      "\tSet a mask within the debugger to disallow interrupt\n"
			      "\tN (1, ..., 10).  If N=0, all interrupts are masked.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP PATTERN"))
		    {
		      printf ("\n"
		              "pattern V M\n"
			      "\tSet a pattern with value V and mask M.  A \"pattern\"\n"
			      "\tis like a breakpoint, except that instead of halting\n"
			      "\tupon reaching a certain address, the program-halt occurs\n"
			      "\tupon reaching a certain value (V) at the program counter.\n"
			      "\tThe instruction stored at the program counter is logically\n"
			      "\tbitwise ANDed with the mask M before comparing it to V.\n"
			      "\tThis can be used (for example) to select a given instruction\n"
			      "\ttype.  V and M are both in octal.  Note that V and M are\n"
			      "\teach 32 bits, and the extra bits represent additional \n"
			      "\tconditions beyond the bare instruction code stored at the\n"
			      "\tprogram counter.  These bits are:\n"
			      "\t\t16th\tExtracode bit\n"
			      "\t\t17th\tThe INDEX is non-zero\n"
			      "\t\t18th\tAccumulator has + overflow\n"
			      "\t\t19th\tAccumulator has - overflow\n"
			      "\t\t20th\tSign of Accumulator is -\n"
			      "\t\t21st\tSigns of Accumulator and L mismatch\n"
			      "\t\t22nd\tWithin an interrupt\n"
			      "\t\tother\tZero\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP PRINT"))
		    {
		      printf ("\n"
		              "print S\n"
			      "\tPrints out the value of the symbol S\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP QUIT"))
		    {
		      printf ("\n"
		              "quit (or exit)\n"
			      "\tEnd the program.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP STEP"))
		    { 
		      printf ("\n"
			      "step [N] (or next [N])\n"
			      "\tStep through N instructions.  If omitted, N defaults to 1.\n"
			      "\tYou can also use just the first letter, as shorthand.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP SYM-DUMP"))
		    {
		      printf ("\n"
			      "sym-dump RegularExpression\n"
			      "\tDumps all of the symbols whose names match the specified\n"
			      "\tregular expression.  For example,\n"
			      "\t\tsym-dump not           All symbols containing NOT.\n"
			      "\t\tsym-dump ^not          All symbols beginning with NOT.\n"
			      "\t\tsym-dump not$          All symbols ending with NOT.\n"
			      "\t\tsym-dump (^not)|(not$) Beginning or ending with NOT.\n"
			      "\tThe list is arbitrarily truncated after %d symbols.\n",
			      MAX_SYM_DUMP);
		      continue;
		    }
		  else if (!strcmp (s, "HELP SYMBOL-FILE"))
		    {
		      printf ("\n"
			      "symbol-file FILE\n"
			      "\tLoads the FILE as the symbol table\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP WATCH"))
		    {
		      printf ("\n"
			      "watch A\n"
			      "\tHalt execution when the value at address A changes in any way.\n"
			      "\tThe break occurs AFTER the value is changed, but the\n"
			      "\t\"before\" and \"after\" values stored at the address\n"
			      "\tare displayed after execution stops.  The address\n"
			      "\tobviously has to be in erasable memory or i/o-channel memory.\n"
			      "\tNote that the value stored at the address has to CHANGE to\n"
			      "\ttrigger the break.\n");
		      printf ("Or:\n"
			      "watch A V\n"
			      "\tSame as above, but waits for the SPECIFIC value V to be written.\n" "\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP VIEW"))
		    {
		      printf ("\n"
			      "view A\n"
			      "\tThis is a variation of \"watch A\".  It differs only in that\n"
			      "\tit simply displays the values of variables as they change,\n"
			      "\trather than interrupting execution.\n");
		      continue;
		    }
		  else if (!strcmp (s, "HELP WHATIS"))
		    {
		      printf ("\n"
			      "whatis S\n"
			      "\tPrints information about the symbol S\n" "\n");
		      continue;
		    }
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
		      if (i >= 1)
		        SingleStepCounter = i - 1;
		      else
		        printf ("The step-count must be 1 or greater.\n");
		      break;
		    }
		  else if (!strcmp (s, "STEP") || !strcmp (s, "NEXT") ||
			   !strcmp (s, "S") || !strcmp (s, "N"))
		    {
#ifdef GDBMI
                      RunState = 1;
#endif
		      SingleStepCounter = 0;
		      break;
		    }
		  else if (!strcmp (s, "QUIT") || !strcmp (s, "EXIT"))
		    return (0);
		  else if (!strncmp (s, "GETOCT", 6))
		    {
		      // The following function is taken from CheckDec.c in the
		      // Luminary131 directory.
		      extern void CheckDec (char *s);
		      CheckDec (&s[6]);
		    }
#ifndef GDBMI
		  else if (!strncmp (s, "DUMP", 4))
		    DumpMemory (&State, s);
		  else if (!strncmp (s, "BREAK ", 6)) /* gdbmi: BREAK */
		    AddBreakpoint (&State, s);

		  else if (1 == sscanf (s, "PRINT %s", SymbolName)) /* gdbmi: PRINT */
		    {
		      // JMS: Attempt to resolve the symbol and pretend it is
		      // a DUMP command
		      if ((Symbol = ResolveSymbol(SymbolName, SYMBOL_VARIABLE | SYMBOL_REGISTER)))
			{
			  char AddressStr[64];
			  AddressPrintAGC (&Symbol->Value, AddressStr);
			  sprintf (s, "DUMP %s", AddressStr);
			  DumpMemory (&State, s);
			}
		      else
			printf("Symbol not found.\n");
		    }
#endif
		  // JMS: 07.28
		  else if (1 == sscanf (s, "WHATIS %s", SymbolName))
		    WhatIsSymbol (SymbolName, ARCH_AGC);

		  // JMS: 07.28
		  else if (!strcmp (s, "LIST -"))
		    {
		      // The case where we just want to backup and list
		      ListBackupSource ();
		    }
		  else if (2 == sscanf (s, "LIST %d,%d", &LineNumber, &LineNumberTo))
		    {
		      // This case where we want to list between two line numbers.
		      // sscanf seems to handle this case ok, unlike its inability
		      // to parse name:line. We leave the range checking for the
		      // ListSourceRange() routine.
		      ListSourceRange (LineNumber, LineNumberTo);
		    }
		  else if (1 == sscanf (s, "LIST %d", &LineNumber))
		    {
		      // The case where we want to list a file number in the
		      // currently opened file
		      ListSource (NULL, LineNumber);
		    }
		  else if (1 == sscanf (s, "LIST %s", Dummy))
		    {
		      char *Ptr, *TmpName;

		      // The case where we want to list a file number from a
		      // given file. We actually need to take the file name
		      // from the raw string to keep the case. I can't seem
		      // to figure out how to get sscanf() to recognize the
		      // colon so I need to do this painfully.
		      sscanf (sraw, "%s %s", Dummy, FileName);
		      TmpName = strtok(FileName, ":");

		      // If there is no ":" then we will assume we want to
		      // list a symbol (function), otherwise, we assume the
		      // debug command is of the form FILE:LINENUM.
		      if ((Ptr = strtok(NULL, ":")) != NULL)
			{
			  LineNumber = atoi(Ptr);
			  ListSource (TmpName, LineNumber);
			}
		      else
			{
			  // Try to resolve the symbol and then list the
			  // source for that symbol
			  if ((Symbol = ResolveSymbol(TmpName, SYMBOL_LABEL)) != NULL)
			    ListSource (Symbol->FileName, Symbol->LineNumber);
			  else
			    printf("Invalid symbol name.\n");
			}
		    }
#ifndef GDBMI
		  else if (!strcmp (s, "LIST")) /* gdbmi: LIST */
		    {
		      // The case where we just want to list the next several
		      // lines from the current position
		      ListSource (NULL, -1);
		    }
#endif
		  // JMS: 07.28 END
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
#ifndef GDBMI
		  else if (!strncmp (s, "WATCH ", 6) || /* gdbmi: WATCH */
		  			  !strncmp (s, "VIEW ", 5))
		    AddWatchpoint (&State, s);
#endif
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
#ifndef GDBMI
		  else if (!strncmp (s, "DELETE", 6)) /* gdbmi: DELETE */
		    DeleteBreakpoint (&State, s);
#endif
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
#ifndef GDBMI  
		  else if (!strncmp (s, "EDIT ", 5)) /* gdbmi: SET VARIABLE */
		    {
		      State.PendFlag = SingleStepCounter = 0;
		      Break = 1;
		      EditMemory (&State, s);
		      goto ShowDisassembly;
		    }
#endif
        else if (!strcmp (s, "CONT") || !strcmp (s, "RUN"))
		    {
#ifndef GDBMI
                      /* GDBMI uses Ctrl-C to break from cont. or run */
		      nbfgets_ready("");
#else
                      RunState = 1;
#endif
		      break;
		    }
		  else if (!strncmp (s, "COREDUMP ", 9))
		    MakeCoreDump (&State, &sraw[9]);
		  else if (!strcmp (s, "INTERRUPTS"))
		    {
		      if (!DebuggerInterruptMasks[0])
			printf ("The debugger is blocking all interrupts.\n");
		      else
			printf ("The debugger is allowing interrupts.\n");
		      printf ("Debugger interrupt mask:");
		      for (i = 1; i <= NUM_INTERRUPT_TYPES; i++)
			printf (" %d", !DebuggerInterruptMasks[i]);
		      printf ("\n");
		      printf ("Interrupt-request flags:");
		      for (i = 1; i <= NUM_INTERRUPT_TYPES; i++)
			printf (" %d", State.InterruptRequests[i]);
		      printf ("\n");
		      if (State.InIsr)
			printf ("In ISR #%d.\n", State.InterruptRequests[0]);
		      else
			printf ("Last ISR: #%d.\n",
				State.InterruptRequests[0]);
		    }
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
		    BacktraceDisplay (&State);
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
#ifndef GDBMI
		  else if (!strcmp (s, "BREAKPOINTS")) /* gdbmi: INFO BREAKPOINTS */
		    {
		      if (NumBreakpoints == 0)
			printf ("No breakpoint(s) are currently set.\n");
		      for (i = 0; i < NumBreakpoints; i++)
			{
			  int Address12, vRegBB;
			  if (Breakpoints[i].WatchBreak == 2)
			    {
			      printf ("Pattern #%d is value " PAT
				      " masked with " PAT, i + 1,
				      Breakpoints[i].Address12,
				      Breakpoints[i].vRegBB);
			    }
			  else
			    {
			      if (Breakpoints[i].WatchBreak == 3)
			        {
				  if (Breakpoints[i].Symbol != NULL)
				    printf ("Watchpoint #%d (%s) for value %05o is at address ",
					    i + 1, Breakpoints[i].Symbol->Name, 
					    Breakpoints[i].WatchValue);
				  else
				    printf ("Watchpoint #%d for value %05o is at address ",
					    i + 1, Breakpoints[i].WatchValue);
				}
			      else if (Breakpoints[i].WatchBreak == 4)
			        {
				  if (Breakpoints[i].Symbol != NULL)
				    printf ("Variable viewer #%d (%s) is at address ",
					    i + 1, Breakpoints[i].Symbol->Name);
				  else
				    printf ("Variable viewer #%d is at address ",
					    i + 1);
				}
			      else if (Breakpoints[i].WatchBreak)
			        {
				  if (Breakpoints[i].Symbol != NULL)
				    printf ("Watchpoint #%d (%s) is at address ",
					    i + 1, Breakpoints[i].Symbol->Name);
				  else
				    printf ("Watchpoint #%d is at address ",
					    i + 1);
				}
			      else
			        {
				  if (Breakpoints[i].Symbol != NULL)
				    printf ("Breakpoint #%d (%s) is at address ",
					    i + 1, Breakpoints[i].Symbol->Name);
				  else
				    printf ("Breakpoint #%d is at address ",
					    i + 1);
				}

			      Address12 = Breakpoints[i].Address12;
			      vRegBB = Breakpoints[i].vRegBB;
			      if (Address12 < 01400 || Address12 >= 04000)
				printf ("%05o", Address12);
			      else if (Address12 >= 01400
				       && Address12 < 02000)
				printf ("E%o,%05o", vRegBB & 7, Address12);
			      else if (Address12 >= 02000
				       && Address12 < 04000)
				{
				  int Bank;
				  Bank = (vRegBB >> 10) & 037;
				  if (0 != (vRegBB & 0100) && Bank >= 030)
				    Bank += 010;
				  printf ("%02o,%05o", Bank, Address12);
				}

			      // Print out the file,line if set for the breakpoint
			      if (HaveSymbols)
			        {
				  if (Breakpoints[i].Symbol != NULL)
				    printf(" in file %s:%d",
					   Breakpoints[i].Symbol->FileName,
					   Breakpoints[i].Symbol->LineNumber);
				  else if (Breakpoints[i].Line != NULL)
				    printf(" in file %s:%d",
					   Breakpoints[i].Line->FileName,
					   Breakpoints[i].Line->LineNumber);
				}
			    }
			  printf ("\n");
			}
		    }
#endif

#ifdef GDBMI
		  else if (gdbmiHandleCommand(&State, s , sraw ) == 0 ) 
	            {
	               //printf ("Undefined command: \"%s\". Try \"help\".\n", sraw );
	            }
#else
		  else
		    printf ("Illegal command.\n");
#endif
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
	  //CycleCount++;   
	  agc_engine (&State);
	  CycleCount += sysconf (_SC_CLK_TCK);
	}
    }

  return (0);
}

#ifdef GDBMI
/* Catch the SIGINT Signal to stop running and return to debug mode */
static void catch_sigint(int sig)
{
   BreakPending = 1; /* Make sure Break only happens when we want it */
   nbfgets_ready(agcPrompt);
}
#endif


#if 0
//----------------------------------------------------------------------------------------------
// The following is a nice little template that can be used for easily building functions that
// parse a debugger command line of the form "COMMAND ADDRESS".
static void
AddCOMMAND (agc_t * State, char *s)
{
  int j, k;
  if (2 == sscanf (s, "COMMAND E%o,%o", &j, &k))
    {
      if (j < 0 || j > 7)
	{
	  printf ("Illegal erasable bank number (%o).  Must be 0-7.\n", j);
	  return;
	}
      if (k < 01400 || k >= 02000)
	{
	  printf ("Illegal offset (%o).  Must be 1400-1777.\n", k);
	  return;
	}

    }
  else if (2 == sscanf (s, "COMMAND %o,%o", &j, &k))
    {
      if (j < 0 || j > 043)
	{
	  printf ("Illegal common-fixed bank number (%o).  Must be 0-43.\n",
		  j);
	  return;
	}
      if (k < 02000 || k >= 04000)
	{
	  printf ("Illegal offset (%o).  Must be 2000-3777.\n", k);
	  return;
	}

    }
  else if (1 == sscanf (s, "COMMAND %o", &k))
    {
      if (k >= 0 && k <= 01377)
	{

	}
      else if (k >= 04000 && k <= 07777)
	{

	}
      else
	{
	  printf
	    ("Memory range not recognized.  Perhaps 0000-01377 or 04000-07777?\n");
	  return;
	}
    }
  else
    {
      printf
	("The format of this command is \"COMMAND A\", where A is an address.  Examples of A are:\n");
      printf ("\t1234\t\tUnswitched erasable memory, 0-1377 octal.\n");
      printf ("\t4567\t\tCommon fixed memory, 4000-7777 octal.\n");
      printf
	("\tE4,1456\t\tSwitched erasable memory, banks E0-E7, offset 1400-1777 octal.\n");
      printf
	("\t12,2345\t\tFixed fixed memory, banks 0-43, offset 2000-3777 octal.\n");
    }
}
#endif // 0
