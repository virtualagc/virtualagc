/*
  Copyright 2005,2009 Ronald S. Burkey <info@sandroid.org>
  
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

  Filename:	DebuggerHookAGS.c
  Purpose:	This function is called by aea_engine() in order to 
  		implement the interactive debugger.
  Compiler:	GNU gcc.
  Contact:	Ron Burkey <info@sandroid.org>
  Reference:	http://www.ibiblio.org/apollo/yaAGS.html
  Mode:		2005-06-05 RSB	This is an improved version of the 
  				yaAGC debugger, in that it is built into
				aea_engine rather than into the main
				program.
		2005-06-09 RSB	Fixed a bunch of stuff related to i/o
				addresses.
		2005-06-11 RSB	Added the DISASSEMBLE command.
		2005-06-14 RSB	Added "EDIT PC".
		2005-06-18 RSB	Windows-dependent stuff added.
		2005-07-13 RSB	Fixed a possible issue of using too much CPU time
				in Win32.
		2009-02-28 RSB	Bypass some compiler warnings on 64-bit
				machines.
*/

#include "yaAEA.h"
#include "aea_engine.h"
#include "agc_symtab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#ifdef WIN32
#include <windows.h>
#include <sys/time.h>
#define LB "\r\n"
#else
#include <time.h>
#include <sys/times.h>
#define LB ""
#endif

#ifdef WIN32
struct tms {
  clock_t tms_utime;  /* user time */
  clock_t tms_stime;  /* system time */
  clock_t tms_cutime; /* user time of children */
  clock_t tms_cstime; /* system time of children */
};
extern clock_t times (struct tms *p);
#define _SC_CLK_TCK (1000)
#define sysconf(x) (x)
#endif // WIN32

static int DebugStopCounter = -1;

#define MAX_BREAKPOINTS_AGS 64
typedef struct {
  // Type is
  //	0	for breakpoints.
  //	1	for memory watchpoints (change)
  //	2	for input-port watch (change)
  //	3	for output-port watch (change)
  //	4	for "patterns".
  int Type;
  int Address;
  int Value;

  // If the "break <line>" is used, then Line will be set. If "break <symbol>"
  // is used, then Symbol will be set. If a memory address is given, then both
  // will be NULL.
  Symbol_t *Symbol;
  SymbolLine_t *Line;
} Breakpoint_t;
static Breakpoint_t Breakpoints[MAX_BREAKPOINTS_AGS];
static int NumBreakpointsAGS = 0;
static char BreakCause[128];

static const char *Opcodes[32] = {
  "???", "???", "DVP", "MPY", 
  "STO", "STQ", "LDQ", "???", 
  "CLA", "ADD", "SUB", "MPR",
  "CLZ", "ADZ", "SUZ", "MPZ",
  "TRA", "TIX", "TOV", "TMI",
  "AXT", "LLS", "LRS", "ALS",
  "COM", "ABS", "INP", "OUT",
  "DLY", "TSQ", "???", "???"
};

// Buffer for keyboard input.
static char s[257], sraw[257];

// Some external definitions from mainAGS.c
extern int HaveSymbolsAGS;
extern char SymbolFileAGS[MAX_FILE_LENGTH + 1];

// A function that converts i/o addresses like 2020 to constants like IO_2020.
// Returns -1 on error, or the constant's value otherwise.  We use the special
// (otherwise unused) i/o address for the fictitious discrete-output register
// we use internally in aea_engine.
static const int PowersOfTwo[8] = {
  01, 02, 04, 010, 020, 040, 0100, 0200
};
static int
TranslateIoAddress (int RawAddress)
{
  int Address, i, LowAddress;
  if (RawAddress == 0)
    return (IO_ODISCRETES);
  LowAddress = (RawAddress & 0377);
  Address = (RawAddress & 07400);
  if (Address == 02000)
    Address = IO_2001;
  else if (Address == 06000)
    Address = IO_6001;
  else
    return (-1);
  for (i = 0; i < 8; i++)
    if (PowersOfTwo[i] == LowAddress)
      return (Address + i);
  return (-1);
}

//-----------------------------------------------------------------------------------
// My substitute for fgets, for use when stdin is unblocked.

#define MAX_FROMFILES 11
static FILE *FromFiles[MAX_FROMFILES];
static int NumFromFiles = 1;

static void
rfgetsAGS (ags_t *State, char *Buffer, int MaxSize, FILE * fp)
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
          ChannelRoutineGeneric (State, UpdateAeaPeripheralConnect);
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

//----------------------------------------------------------------------------
// Adds a breakpoint or a watchpoint.

void
AddBreakWatch (int Type, int Address, int Value, Symbol_t *Symbol, SymbolLine_t *Line)
{
  if (NumBreakpointsAGS >= MAX_BREAKPOINTS_AGS)
    {
      printf ("Max break/watch points (%d) defined already.\n", MAX_BREAKPOINTS_AGS);
      return;
    }
  Breakpoints[NumBreakpointsAGS].Type = Type;
  Breakpoints[NumBreakpointsAGS].Address = Address;
  Breakpoints[NumBreakpointsAGS].Value = Value;
  Breakpoints[NumBreakpointsAGS].Symbol = Symbol;
  Breakpoints[NumBreakpointsAGS].Line = Line;
  NumBreakpointsAGS++;    
}

// Deletes a breakpoint or watchpoint

void
DeleteBreakWatch (int Type, int Address)
{
  int i;
  for (i = 0; i < NumBreakpointsAGS; i++)
    if (Breakpoints[i].Type == Type && Breakpoints[i].Address == Address)
      {
        printf ("Breakpoint and/or watchpoint(s) deleted\n");
        for (NumBreakpointsAGS--; i < NumBreakpointsAGS; i++)
	  Breakpoints[i] = Breakpoints[i + 1];
	return;
      }
   //printf ("Breakpoint or watchpoint not found.\n");
}

// Dump memory or i/o space.

static int LastAddress = 0, LastN = 1, LastType = 1;

void
DumpAGS (ags_t *State)
{
  int CountOnLine = 0;
  int i;
  int Address;
  Address = LastAddress;
  for (i = 0; i < LastN; i++)
    {
      if (CountOnLine == 0)
        {
	  if (LastType == 2)
	    printf ("I");
	  else if (LastType == 3)
	    printf ("O");
	  printf ("0%04o:", Address);
	}
      if (LastType == 1)
        printf ("\t0%06o", State->Memory[Address++]);
      else if (LastType == 2)
        printf ("\t0%06o", State->InputPorts[Address++]);
      else if (LastType == 3)
        printf ("\t0%06o", State->OutputPorts[Address++]);
      CountOnLine++;
      if (CountOnLine >= 8 || 0 == (Address & 7))
        {
	  printf ("\n");
	  CountOnLine = 0;
	}
    }
  if (CountOnLine)
    printf ("\n");
}

//----------------------------------------------------------------------------
// Disassemble

void
DisassembleAGS (ags_t *State, int Address, int Count)
{
  int i, j, k;
  if (Count > 010000)
    Count = 010000;
  for (k = 0; k < Count; k++)
    {
      j = Address + k;
      if (j < 0 || j > 07777)
        continue;
      printf ("0%04o  0%06o\t", j, State->Memory[j]);
      i = ((State->Memory[j] >> 13) & 037);	// Opcode
      printf ("%s", Opcodes[i]);
      if (i != 031 && i != 030)		// If not ABS or COM, print operand.
	{
	  printf ("\t0%04o", State->Memory[j] & 07777);
	  // The next bit displays the index register as an increment to the address,
	  // as a courtesy.  It turns out that only opcodes from 000 to 036 can be
	  // indexed, and those from 040 to 076 cannot be.  Since i contains the 
	  // opcode divided by 2, the purpose of the condition "i < 020" should be
	  // obvious.
	  if (0 != (State->Memory[j] & 010000) && i < 020)
	    printf (",1\t[0%04o]", State->Index | (State->Memory[j] & 07777));
	}
      printf ("\n");
    }
}

//----------------------------------------------------------------------------
// Handles all "help" commands for the debugger. Takes the command string as
// an argument.
static void
HelpAGS (char *s)
{
  if (!strcmp (s, "HELP"))
    {
      printf ("\n"
	      "Unless otherwise specified, all numbers are in octal notation.\n"
	      "Addresses are a single octal number (like 130 or 4655). Input\n"
	      "ports are prefixed with I (like I1, I5) and output ports are\n"
	      "prefixed with O (like O2, O4).\n"
	      "\n"
	      "For information on specific topics, use one of the following:\n"
	      "\thelp backtrace\n"
	      "\thelp backtraces\n"
	      "\thelp break\n"
	      "\thelp breakpoints\n"
	      "\thelp cont\n"
	      "\thelp cont-til-new\n"
	      "\thelp delete\n"
	      "\thelp disassemble\n"
	      "\thelp dump\n"
	      "\thelp edit\n"
	      "\thelp files\n"
	      "\thelp list\n"
	      "\thelp pattern\n"
	      "\thelp print\n"
	      "\thelp quit\n"
	      "\thelp step\n"
	      "\thelp sym-dump\n"
	      "\thelp symbol-file\n"
	      "\thelp watch\n"
	      "\thelp whatis" "\n");
    }
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
    }
  else if (!strcmp (s, "HELP BACKTRACES"))
    {
      printf ("\n"
	      "backtraces\n"
	      "\tDisplays the most recent backtrace points.\n" "\n");
    }
  else if (!strcmp (s, "HELP BREAK"))
    {
      printf ("\n"
	      "break A\n"
	      "\tSet a breakpoint at A, where A is:\n"
	      "\t  LABEL:    set a breakpoint at the label\n"
	      "\t  LINE:     set a breakpoint in the current file at a line number\n"
	      "\t  *ADDRESS: set a breakpoint at address A.\n" "\n");
    }
  else if (!strcmp (s, "HELP BREAKPOINTS"))
    {
      printf ("\n"
	      "breakpoints\n"
	      "\tList the defined breakpoints, watchpoints, and patterns.\n" "\n");
    }
  else if (!strcmp (s, "HELP CONT"))
    {
      printf ("\n"
	      "cont\n"
	      "\tContinue execution.  The program will continue executing\n"
	      "\tuntil a breakpoint is reached or, in Linux or (for versions\n"
	      "\t20040810 or later) Win32, until you hit the carriage-return\n"
	      "\tkey.\n" "\n");
    }
  else if (!strcmp (s, "HELP CONT-TIL-NEW"))
    {
      printf ("\n"
	      "cont-til-new\n"
	      "\tContinue execution until a new type of instruction is reached.\n"
	      "\n");
    }
  else if (!strcmp (s, "HELP DELETE"))
    {
      printf ("\n"
	      "delete [A]\n"
	      "\tDelete the breakpoint or watchpoint at address A.  If \n"
	      "\tA is omitted, all breakpoints and watchpoints are deleted.\n"
	      "\n"
	      "delete V M\n"
	      "\tDelete the pattern with value V and mask M.\n" "\n");
    }
  else if (!strcmp (s, "HELP DISASSEMBLE"))
    {
      printf ("\n"
	      "disassemble [A] <N>\n"
	      "\tDisassemble N instructions beginning at address A. If\n"
	      "\tN is ommitted, only a single instruction is displayed\n"
	      "\n");
    }
  else if (!strcmp (s, "HELP DUMP"))
    {
      printf ("\n"
	      "dump [N] A\n"
	      "\tDump values of N memory or i/o channel locations, from\n"
	      "\taddress A.  If N is omitted, it defaults to 1.\n"
	      "\n"
	      "dump\n"
	      "\tSimply repeat the last DUMP performed.\n" "\n");
    }
  else if (!strcmp (s, "HELP EDIT"))
    {
      printf ("\n"
	      "edit [A] V\n"
	      "\tChange value of memory location or i/o channel A to V.\n"
	      "\tSpecial cases of the EDIT command include:\n"
	      "\tEDIT A V: Sets the Accumulator register to V\n"
	      "\tEDIT Q V: Sets the Quotient register to V\n"
	      "\tEDIT OVERFLOW V: Sets the Overflow register to V\n"
	      "\tEDIT INDEX V: Sets the Index register to V\n"
	      "\tEDIT HALT V: Sets the Halt register to V\n"
	      "\tEDIT PC V: Sets the Program Counter to V\n" "\n");
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
	      "\ttype.  V and M are both in octal.\n" "\n");
    }
  else if (!strcmp (s, "HELP PRINT"))
    {
      printf ("\n"
	      "print S\n"
	      "\tPrints out the value of the symbol S\n");
    }
  else if (!strcmp (s, "HELP QUIT"))
    {
      printf ("\n"
	      "quit (or exit)\n"
	      "\tEnd the program.\n" "\n");
    }
  else if (!strcmp (s, "HELP STEP"))
    { 
      printf ("\n"
	      "step [N] (or next [N])\n"
	      "\tStep through N instructions.  If omitted, N defaults to 1.\n"
	      "\tYou can also use just the first letter, as shorthand.\n" "\n");
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
    }
  else if (!strcmp (s, "HELP SYMBOL-FILE"))
    {
      printf ("\n"
	      "symbol-file FILE\n"
	      "\tLoads the FILE as the symbol table\n" "\n");
    }
  else if (!strcmp (s, "HELP WATCH"))
    {
      printf ("\n"
	      "watch A\n"
	      "\tHalt execution when a value is written to the address A.\n"
	      "\tThe break occurs AFTER the value is changed, but the\n"
	      "\t\"before\" and \"after\" values stored at the address\n"
	      "\tare displayed after execution stops.  The address\n"
	      "\tobviously has to be in erasable memory or i/o-channel memory.\n"
	      "\tNote that the value stored at the address has to CHANGE to\n"
	      "\ttrigger the break.\n" "\n");
    }
  else if (!strcmp (s, "HELP WHATIS"))
    {
      printf ("\n"
	      "whatis S\n"
	      "\tPrints information about the symbol S\n" "\n");
    }
}

//----------------------------------------------------------------------------

static unsigned long InstructionCounts[0100] = { 0 };

void
DebuggerHookAGS (ags_t *State)
{
  int i, j, k, Stop = 0;
  static int StopForNewInstructionType = 0, DisassembleCount = 24;
  struct tms TimeStruct;
  clock_t StoppedAt;
  char FileName[MAX_FILE_LENGTH + 1];
  int LineNumber, LineNumberTo;
  char Dummy[MAX_FILE_LENGTH + 1];
  char SymbolName[129];
  Symbol_t *Symbol;
  SymbolLine_t *Line;
  char Garbage[81];
  
  if (!DebugModeAGS)		// If not in debugging mode, just return.
    return;
  // Collect instruction-type counts.
  i = ((State->Memory[State->ProgramCounter] >> 12) & 077);
  InstructionCounts[i]++;
  if (InstructionCounts[i] == 0)	// Overflow in the count?
    InstructionCounts[i]--;
  if (StopForNewInstructionType && InstructionCounts[i] == 1)
    {
      StopForNewInstructionType = 0;
      Stop = 1;
      strcpy (BreakCause, "previously-unused instruction type.");
    }  
  // Check the various possible conditions for halting execution.  
  if (DebugModeAGS == 2)	// Halt immediately on startup?
    {
      FromFiles[0] = stdin;
      Stop = 1;
      DebugModeAGS = 1;
      strcpy (BreakCause, "program loaded.");
    }
  if (DebugStopCounter > 0)	// Halt if spec'd # of instructions executed.
    DebugStopCounter--;
  if (!Stop)
    {
      if (RealTimeAGS >= NextKeycheckAGS)
	{
	  NextKeycheckAGS = RealTimeAGS + KEYSTROKE_CHECK_AGS;
	  while (s == nbfgets (s, sizeof (s)))
	    {
	      Stop = 1;
	      strcpy (BreakCause, "keypress.");
	    }
	}
    }
  if (!Stop && DebugStopCounter == 0)
    {
      DebugStopCounter = -1;
      Stop = 1;
      strcpy (BreakCause, "step count reached.");
    }
  for (i = 0; !Stop && i < NumBreakpointsAGS; i++)
    switch (Breakpoints[i].Type)
      {
      case 0:		// Breakpoint.
        Stop |= (State->ProgramCounter == Breakpoints[i].Address);

	// If we have symbol for the breakpoint, then print is
	if (Breakpoints[i].Symbol)
	  sprintf (BreakCause, "breakpoint (%s).", Breakpoints[i].Symbol->Name);
	else
	  strcpy (BreakCause, "breakpoint.");
	break;
      case 1:		// Memory watchpoint (change)
        Stop |= (State->Memory[Breakpoints[i].Address] != Breakpoints[i].Value);
	sprintf (BreakCause, "watched memory location 0%o changed from 0%o to 0%o.",
	         Breakpoints[i].Address, Breakpoints[i].Value, 
		 State->Memory[Breakpoints[i].Address]);
	Breakpoints[i].Value = State->Memory[Breakpoints[i].Address];
	break;
      case 2:		// Input-port watchpoint (change)
        Stop |= (State->InputPorts[Breakpoints[i].Address] != Breakpoints[i].Value);
	sprintf (BreakCause, "watched input port 0%o changed from 0%o to 0%o.",
	         Breakpoints[i].Address, Breakpoints[i].Value, 
		 State->InputPorts[Breakpoints[i].Address]);
	Breakpoints[i].Value = State->InputPorts[Breakpoints[i].Address];
	break;
      case 3:		// Output-port watchpoint (change)
        Stop |= (State->OutputPorts[Breakpoints[i].Address] != Breakpoints[i].Value);
	sprintf (BreakCause, "watched output port 0%o changed from 0%o to 0%o.",
	         Breakpoints[i].Address, Breakpoints[i].Value, 
		 State->OutputPorts[Breakpoints[i].Address]);
	Breakpoints[i].Value = State->OutputPorts[Breakpoints[i].Address];
	break;
      case 4:		// Pattern.
        // Note that Breakpoints[i].Value is the mask and Breakpoints[i].Address is the 
	// pattern we're looking for.
        Stop |= (0 == (Breakpoints[i].Value & (Breakpoints[i].Address ^ State->Memory[State->ProgramCounter])));
	break;
      }	
  // If none of the stop-conditions held, then return.
  if (!Stop)
    return;
    
Redraw:
  printf ("\n");
  printf ("Stopped because %s\n", BreakCause);
  // Print registers.
  printf ("A=0%06o\tQ=0%06o\tOverflow=%d\tIndex=%03o\tHalted=%d\nIcount=%lu\tCycles=" FORMAT_64U "\n",
	  State->Accumulator, State->Quotient, State->Overflow, State->Index,
	  State->Halt, 
	  InstructionCounts[077 & (State->Memory[State->ProgramCounter] >> 12)],
	  State->CycleCounter);

  // If we have the symbol table, then print out the actual source,
  // rather than just a disassembly
  if (HaveSymbolsAGS)
    {
      // Resolve the current program counter into an entry into
      // the program line table.
      SymbolLine_t *Line = ResolveLineAGS (State->ProgramCounter);
      
      // There are several ways this can fail, and if either does we
      // just want to disasemble: if we didn't find the line in the
      // table or if ListSource() fails.
      if (Line == NULL || ListSourceLine (Line->FileName, Line->LineNumber,
					  ShowAddressContentsAGS (State)))
	DisassembleAGS (State, State->ProgramCounter, 1);
    }
  else
    {
      // Print disassembly of the instruction.
      DisassembleAGS (State, State->ProgramCounter, 1);
    }
  
  // Now do our interactive thing.
  while (1)
    {
      char *ss;
#ifdef USE_READLINE
      nbfgets_ready ("> ");
#else
      printf ("> ");
#endif // USE_READLINE

      // Get input from the user or a macro-file.
      StoppedAt = times (&TimeStruct);
      rfgetsAGS (State, s, sizeof (s) - 1, stdin);
      RealTimeOffsetAGS += times (&TimeStruct) - StoppedAt;
      while (isspace (s[0]))	// Get rid of leading spaces.
        strcpy (&s[0], &s[1]); 
      strcpy (sraw, s);
      for (ss = s; *ss; ss++)
        {
	  // Turn to upper case, get rid of multiple spaces and
	  // end-of-line linefeed.
	  while (isspace (*ss) && isspace (ss[1]))
	    strcpy (ss, ss + 1);
	  *ss = toupper (*ss);
	  if (*ss == '\n')
	    *ss = 0;
	}
      //printf ("\"%s\"\n", s);
      // Parse the input and do stuff with it.
      if (*s == '#')
        continue;
      else if (!strncmp (s, "HELP", 4))
	{
	  HelpAGS (s);
	  continue;
	}
      else if (1 == sscanf (s, "STEP%o", &i) || 1 == sscanf (s, "NEXT%o", &i))
	{
	  if (i >= 1)
	    DebugStopCounter = i;
	  else
	    printf ("The step-count must be 1 or greater.\n");
	  break;
	}
      else if (!strcmp (s, "STEP") || !strcmp (s, "NEXT") ||
	       !strcmp (s, "S") || !strcmp (s, "N"))
	{
	  DebugStopCounter = 1;
	  break;
	}
      else if (!strcmp (s, "QUIT") || !strcmp (s, "EXIT"))
	exit (0);
      else if (HaveSymbolsAGS && (1 == sscanf (s, "BREAK %d%s", &LineNumber, Garbage)) &&
	       (Line = ResolveLineNumber (LineNumber)))
	AddBreakWatch (0, Line->CodeAddress.SReg & 07777, 0, NULL, Line);
      else if (HaveSymbolsAGS && (1 == sscanf (s, "BREAK %s", SymbolName)) &&
	       (Symbol = ResolveSymbol (SymbolName, SYMBOL_LABEL)))
	AddBreakWatch (0, Symbol->Value.SReg & 07777, 0, Symbol, NULL);
      else if (1 == sscanf (s, "BREAK *%o", &i))
        AddBreakWatch (0, i, 0, NULL, NULL);
      else if (1 == sscanf (s, "WATCH %s", SymbolName) &&
	       (Symbol = ResolveSymbol(SymbolName, SYMBOL_VARIABLE | SYMBOL_REGISTER)))
	AddBreakWatch (0, Symbol->Value.SReg & 07777, 0, Symbol, NULL);
      else if (1 == sscanf (s, "WATCH%o", &i))
        AddBreakWatch (1, i, State->Memory[i], NULL, NULL);
      else if (1 == sscanf (s, "WATCH I%o", &i))
        {
	  j = TranslateIoAddress (i);
	  if (j == -1)
	    printf ("0%o is not a supported i/o address.\n", i);
	  else   
            AddBreakWatch (2, j, State->InputPorts[j], NULL, NULL);
	}
      else if (1 == sscanf (s, "WATCH O%o", &i))
        {
	  j = TranslateIoAddress (i);
	  if (j == -1)
	    printf ("0%o is not a supported i/o address.\n", i);
	  else   
            AddBreakWatch (3, j, State->OutputPorts[j], NULL, NULL);
	}
      else if (2 == sscanf (s, "PATTERN %o %o", &i, &j))
        AddBreakWatch (4, i, j, NULL, NULL);
      else if (!strcmp (s, "CONT"))
	{
#ifdef USE_READLINE
	  // If we are using the readline library for command
	  // entry then tell it to start looking for characters
	  // again, but do not print a prompt.
	  nbfgets_ready ("");
#endif // USE_READLINE
	  break;
	}
      else if (!strcmp (s, "CONT-TIL-NEW"))
        {
	  StopForNewInstructionType = 1;
          break;
	}
      else if (1 == sscanf (s, "DELETE%o", &i))
        {
          DeleteBreakWatch (0, i);
	  DeleteBreakWatch (1, i);
	}
      else if (1 == sscanf (s, "DELETE I%o", &i))
        DeleteBreakWatch (2, TranslateIoAddress (i));
      else if (1 == sscanf (s, "DELETE O%o", &i))
        DeleteBreakWatch (3, TranslateIoAddress (i));
      else if (!strcmp (s, "DELETE"))
        NumBreakpointsAGS = 0;
      else if (!strcmp (s, "BREAKPOINTS"))
        {
	  if (NumBreakpointsAGS == 0)
	    printf ("No breakpoints or watchpoints are defined.\n");
	  else
	    {
	      for (i = 0; i < NumBreakpointsAGS; i++)
	        {
		  //printf ("%2d: ", i);
		  switch (Breakpoints[i].Type)
		    {
		    case 0:
		      printf ("Breakpoint");

		      // If we have a symbol, then print it
		      if (Breakpoints[i].Symbol)
			printf(" (%s)", Breakpoints[i].Symbol->Name);

		      j = Breakpoints[i].Address;
		      printf (" at address 0%04o", j);

		      // Print out the file,line if set for the breakpoint
		      if (Breakpoints[i].Symbol != NULL)
			printf (" in file %s:%d",
				Breakpoints[i].Symbol->FileName,
				Breakpoints[i].Symbol->LineNumber);
		      else if (Breakpoints[i].Line != NULL)
			printf (" in file %s:%d",
				Breakpoints[i].Line->FileName,
				Breakpoints[i].Line->LineNumber);
		      printf ("\n");
		      break;
		    case 1:
		      printf ("Memory watchpoint");
		      j = Breakpoints[i].Address;

		      // If there is a symbol, the print it
		      if (Breakpoints[i].Symbol)
			printf(" (%s)", Breakpoints[i].Symbol->Name);

		      printf (" at address 0%04o.\n", j);
		      break;
		    case 2:
		      printf ("Input watchpoint");
		      j = Breakpoints[i].Address;
		      if (j >= IO_2001 && j <= IO_2200)
		        j = 02000 + (1 << (j - IO_2001));
		      else if (j >= IO_6001 && j <= IO_6200)
		        j = 06000 + (1 << (j - IO_6001));
		      else
		        j = -1;
		      printf (" at address 0%04o.\n", j);
		      break;
		    case 3:
		      printf ("Output watchpoint");
		      j = Breakpoints[i].Address;
		      if (j == IO_ODISCRETES)
		        j = 0;
		      else if (j >= IO_2001 && j <= IO_2200)
		        j = 02000 + (1 << (j - IO_2001));
		      else if (j >= IO_6001 && j <= IO_6200)
		        j = 06000 + (1 << (j - IO_6001));
		      else
		        j = -1;
		      printf (" at address 0%04o.\n", j);
		      break;
		    case 4:
		      printf ("Pattern 0%011o with mask 0%011o.\n",
		      	      Breakpoints[i].Address,
			      Breakpoints[i].Value);
		      break;
		    }
		}
	    }
	}
      else if (!strcmp (s, "DUMP"))
        DumpAGS (State);
      else if (2 == sscanf (s, "DUMP%o%o", &i, &j))
        {
	  LastType = 1;
	  LastN = i;
	  LastAddress = j;
	  DumpAGS (State);
	}
      else if (1 == sscanf (s, "DUMP%o", &j))
        {
	  LastType = 1;
	  LastN = 1;
	  LastAddress = j;
	  DumpAGS (State);
	}
      else if (1 == sscanf (s, "DUMP I%o", &j))
        {
	  i = TranslateIoAddress (j);
	  if (i == -1)
	    printf ("0%o is not a supported i/o address.\n", j);
	  else
	    {
	      LastType = 2;
	      LastN = 1;
	      LastAddress = i;
	      DumpAGS (State);
	    }
	}
      else if (1 == sscanf (s, "DUMP O%o", &j))
        {
	  i = TranslateIoAddress (j);
	  if (i == -1)
	    printf ("0%o is not a supported i/o address.\n", j);
	  else
	    {
	      LastType = 3;
	      LastN = 1;
	      LastAddress = i;
	      DumpAGS (State);
	    }
	}
      else if (2 == sscanf (s, "EDIT%o%o", &i, &j))
        {
	  if (i < 0 || i > 07777)
	    printf ("Address o%o out of range.\n", i);
	  else
	    State->Memory[i] = (j & 0777777);
	}
      else if (2 == sscanf (s, "EDIT I%o %o", &i, &j))
        {
	  k = TranslateIoAddress (i);
	  if (k == -1)
	    printf ("I/O address o%o is not supported.\n", i);
	  else
	    State->InputPorts[k] = (j & 0777777);
	}
      else if (2 == sscanf (s, "EDIT O%o %o", &i, &j))
        {
	  extern void Output (ags_t *State, int AddressField, int Value);
 	  if (i == 0)
	    {
	      State->OutputPorts[IO_ODISCRETES] = (j & 0777777);
              ChannelOutputAGS (040, j & 0777777);
	    }
	  else
	    Output (State, i, j);
	}
      else if (1 == sscanf (s, "EDIT A %o", &j))
        {
	  if (j < 0 || j > 0777777)
	    printf ("Value out of range.\n");
	  else 
	    State->Accumulator = j;
	    goto Redraw;
	}
      else if (1 == sscanf (s, "EDIT Q %o", &j))
        {
	  if (j < 0 || j > 0777777)
	    printf ("Value out of range.\n");
	  else 
	    State->Quotient = j;
	    goto Redraw;
	}
      else if (1 == sscanf (s, "EDIT OVERFLOW %o", &j))
        {
	  if (j < 0 || j > 1)
	    printf ("Value out of range.\n");
	  else 
	    State->Overflow = j;
	    goto Redraw;
	}
      else if (1 == sscanf (s, "EDIT INDEX %o", &j))
        {
	  if (j < 0 || j > 7)
	    printf ("Value out of range.\n");
	  else 
	    State->Index = j;
	    goto Redraw;
	}
      else if (1 == sscanf (s, "EDIT HALT %o", &j))
        {
	  if (j < 0 || j > 1)
	    printf ("Value out of range.\n");
	  else 
	    State->Halt = j;
	    goto Redraw;
	}
      else if (1 == sscanf (s, "EDIT PC %o", &j))
        {
	  if (j < 0 || j > 07777)
	    printf ("Value out of range.\n");
	  else 
	    State->ProgramCounter = j;
	    goto Redraw;
	}
      else if (!strcmp (s, "BACKTRACES"))
	ListBacktracesAGS ();
      else if (1 == sscanf (s, "BACKTRACE%d", &i))
        {
	  RegressToBacktraceAGS (State, i);
	  goto Redraw;
	}
      else if (2 == sscanf (s, "DISASSEMBLE%o%o", &i, &j))
        {
	  DisassembleCount = i;
	  DisassembleAGS (State, j, DisassembleCount);
	}
      else if (1 == sscanf (s, "DISASSEMBLE%o", &j))
        DisassembleAGS (State, j, DisassembleCount);
      else if (!strcmp (s, "DISASSEMBLE"))
        DisassembleAGS (State, State->ProgramCounter, DisassembleCount);	
      else if (!strcmp (s, "COUNTS"))
        {
	  for (i = 0; i < 32; i++)
	    printf ("%02o:\t%s\t%lu\t\t%02o:\t%s,1\t%lu\n",
	              2 * i, Opcodes[i], InstructionCounts[2 * i], 
		      2 * i + 1, Opcodes[i], InstructionCounts[2 * i + 1]);
	}
      else if (1 == sscanf (s, "PRINT %s", SymbolName))
	{
	  // Attempt to resolve the symbol and pretend it is
	  // a DUMP command
	  if (HaveSymbolsAGS &&
	      (Symbol = ResolveSymbol(SymbolName, SYMBOL_VARIABLE | SYMBOL_REGISTER)))
	    {
	      LastType = 1;
	      LastN = 1;
	      LastAddress = Symbol->Value.SReg & 07777;
	      DumpAGS (State);
	    }
	  else
	    printf ("Symbol not found.\n");
	}
      else if (1 == sscanf (s, "WHATIS %s", SymbolName))
	WhatIsSymbol (SymbolName, ARCH_AGS);
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
      else if (!strcmp (s, "LIST"))
	{
	  // The case where we just want to list the next several
	  // lines from the current position
	  ListSource (NULL, -1);
	}
      else if (!strncmp (s, "SYMBOL-FILE", 11))
	{
	  char Dummy[12];
	  
	  // We need to use the raw formatted string because
	  // we need to preserve case for the file name
	  if (2 == sscanf (sraw, "%s %s", Dummy, SymbolFileAGS))
	    {
	      ResetSymbolTable ();
	      if (!ReadSymbolTable(SymbolFileAGS))
		HaveSymbolsAGS = 1;
	      else
		HaveSymbolsAGS = 0;
	    }
	}
      else if (1 == sscanf (s, "SYM-DUMP%s", SymbolName))
	{
	  // Dumps the symbols to the screen
	  if (HaveSymbolsAGS)
	    DumpSymbols (SymbolName, ARCH_AGS);
	  else
	    printf ("No symbol table loaded.\n");
	}
      else if (1 == sscanf (s, "FILES%s", FileName))
	{
	  // Dumps the files to the screen
	  if (HaveSymbolsAGS)
	    DumpFiles (FileName);
	  else
	    printf ("No symbol table loaded.\n");
	}
      else
        printf ("Unrecognized command \"%s\".\n", s);
  }
}

