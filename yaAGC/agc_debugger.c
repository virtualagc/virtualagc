/*
 * agc_debugger.c
 *
 *  Created on: Dec 5, 2008
 *      Author: MZ211D
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include "agc_cli.h"
#include "agc_engine.h"
#include "agc_symtab.h"
#include "agc_debug.h"
#include "agc_debugger.h"
#include "agc_gdbmi.h"
#include "agc_simulator.h"

extern int SymbolTableSize;
extern Symbol_t *SymbolTable;

static Debugger_t Debugger;
static Frame_t* Frames;

static char FuncName[128];
int LogCount = 0;
static int LogLast = -1;


// JMS: Variables pertaining to the symbol table loaded
int HaveSymbols = 0;    // 1 if we have a symbol table
char* SymbolFile;       // The name of the symbol table file

/* These globals will be deprecated when debugger is mature */
int DebugMode;
int RunState;

FILE *FromFiles[MAX_FROMFILES];
FILE *LogFile = NULL;

int NumFromFiles = 1;

#define INT_MAIN   0
#define INT_TIMER6 1
#define INT_TIMER5 2
#define INT_TIMER3 3
#define INT_TIMER4 4
#define INT_KEYBD1 5
#define INT_KEYBD2 6
#define INT_UPLINK 7
#define INT_DNLINK 8
#define INT_RADAR  9
#define INT_JOYSTK 10

static char s1[129], s2[129], s3[129], s4[129], s5[129];
static int BreakPending = 0;

/* Prompt String
 * Allow the prompt to be changed in gdb/mi mode
 */
char agcPrompt[16]="(agc) ";
char s[129], sraw[129], slast[129];

Breakpoint_t Breakpoints[MAX_BREAKPOINTS];
int NumBreakpoints = 0;

/*
 * My substitute for fgets, for use when stdin is unblocked.
 */
static void rfgets (agc_t *State, char *Buffer, int MaxSize, FILE * fp)
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


int DbgHasBreakEvent()
{
	int BreakFlag;

	if (Debugger.State->PendFlag) BreakFlag = 0;
	else
	{
		if (SingleStepCounter == 0)
		{
		  if(RunState) printf ("Stepped.\n");
		  BreakFlag = 1;
		}
		else
		{
			  int Value;
			  Value = DbgGetFromZ (Debugger.State);

			  /* Detect certain types of impending infinite loops. */
			  if (!(Value & 0177777) && !Debugger.State->Erasable[0][0])
				{
				  /* Infinite Loop break on next instruction */
				  BreakFlag = DebugMode = 1;
				}
			  else
			  {
				  if (SingleStepCounter > 0) SingleStepCounter--;
				  if (DebugMode) BreakFlag = DbgMonitorBreakpoints();
			  }
		}
	}
	if (BreakPending)
	{
	   BreakPending = 0;
	   BreakFlag = 1;
	}

	return BreakFlag;
}

/* Normalize data in s and return sraw pointer */
char* DbgNormalizeCmdString(char* s)
{
	int i;
	char *ss;

	/* Normalize the strings by getting rid of leading, trailing
	   or duplicated spaces. */
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

	strcpy (sraw, s);
	for (ss = s; *ss; *ss = toupper (*ss), ss++);

	return sraw;
}

/*
 * Get the value stored at an address, as specified by a Breakpoint_t.
 */
unsigned short DbgGetWatch (agc_t * State, Breakpoint_t * bp)
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
int DbgGetFromZ (agc_t * State)
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

/**
 * The Frames array is used to cache and look up the Frame Labels
 * when trying to display the frame trace or current location
 */
static Frame_t* DbgInitFrameData(void)
{
   int i;
   unsigned LinearAddr;

   if (Debugger.HaveSymbols)
   {
      char* FrameName = NULL;
      Symbol_t* Symbol;
      Frames = (Frame_t*)malloc(38912 * sizeof(Frame_t));

      if (Frames)
      {
         /* First Clean Frames */
         for (i=0;i<38912;i++)Frames[i].Name = NULL;

         /* Vecter Table Frames */
         Frames[0].Name   = "MAIN";
         Frames[4].Name   = "TIMER6";
         Frames[8].Name   = "TIMER5";
         Frames[12].Name  = "TIMER3";
         Frames[16].Name  = "TIMER4";
         Frames[20].Name  = "KEYBD1";
         Frames[24].Name  = "KEYBD2";
         Frames[28].Name  = "UPLINK";
         Frames[32].Name  = "DNLINK";
         Frames[36].Name  = "RADAR";
         Frames[40].Name  = "JOYSTK";

         /* First find all the Labels and Populate Frames */
         for (i=0;i<SymbolTableSize;i++)
         {
            Symbol = &SymbolTable[i];
            if (Symbol->Type == SYMBOL_LABEL)
            {
               LinearAddr = gdbmiLinearFixedAddr(Symbol->Value.SReg,
                             Symbol->Value.FB,Symbol->Value.Super);
               Frames[LinearAddr - 2048].Name = Symbol->Name;
            }
         }

	 /* Next Fill all the remaining Empty Frames */
         for (i=0;i<38912;i++)
         {
            if (Frames[i].Name != NULL) FrameName = Frames[i].Name;
            else Frames[i].Name = FrameName;
         }
      }
   }
   return (Frames);
}

char* DbgGetFrameNameByAddr(unsigned LinearAddr)
{
   char* FrameName = NULL;

   if (LinearAddr >= 2048 && LinearAddr < 40960)
      FrameName = Frames[LinearAddr - 2048].Name;

   return (FrameName);
}

/* Catch the SIGINT Signal to stop running and return to debug mode */
static void DbgCatchSignal(int sig)
{
   BreakPending = 1; /* Make sure Break only happens when we want it */
   nbfgets_ready(agcPrompt);
   signal(sig, DbgCatchSignal);
}

int DbgInitialize(Options_t* Options,agc_t* State)
{
	Debugger.Options = Options;
	Debugger.RunState = 0;
	Debugger.State = State;

	/* Will remove these variables when debugger is mature */
	SingleStepCounter = 0;
	DebugMode = 1;
	RunState = Debugger.RunState;

	/* if the symbolfile is provided load the symbol table */
	if (Options->symtab)
	{
		/* Set the old global vars */
		SymbolFile = Options->symtab;
		HaveSymbols = 1;

		/* Reset and attempt to load the symbol table */
		ResetSymbolTable ();
		if (ReadSymbolTable(Options->symtab)) HaveSymbols = 0; /* Default is 0 */

		/* In the future Have Symbols will only be used by the Debugger */
		Debugger.HaveSymbols = HaveSymbols;

		DbgInitFrameData();
	}

	/* setvbuf (stdout, OutBuf, _IOLBF, sizeof (OutBuf)); */
	FromFiles[0] = stdin;

	/* Allow a command file to be used with initial debugger commands */
	if (Options->fromfile > 0)
	{
		if (NumFromFiles < MAX_FROMFILES)
		{
			FromFiles[NumFromFiles] = fopen (Options->fromfile, "r");
			if (FromFiles[NumFromFiles] == NULL);
			else
				NumFromFiles++;
		}
	}

    /* Add the AGC starting point */
	BacktraceAdd (State, 0, 04000);

	/* Register the SIGINT to be handled by AGC Debugger */
	signal(SIGINT, DbgCatchSignal);

	return 0;
}

int DbgMonitorBreakpoints(void)
{
	int Break;
	int CurrentZ;
	int CurrentBB;
	int i;
	int Value;

	Value = DbgGetFromZ(Debugger.State);
	CurrentZ = Debugger.State->Erasable[0][RegZ];
	CurrentBB = (Debugger.State->Erasable[0][RegBB] & 076007)|
	            (Debugger.State->InputChannel[7] & 0100);

	for (Break = i = 0; i < NumBreakpoints; i++)
		if (Breakpoints[i].WatchBreak == 2 &&
			gdbmiCheckBreakpoint(Debugger.State,&Breakpoints[i]))
		{
			// Pattern!
			if (Breakpoints[i].Address12 == (Value & Breakpoints[i].vRegBB))
			{
				printf ("Hit pattern, Value=" PAT " Mask=" PAT
				".\n", Breakpoints[i].Address12,
				Breakpoints[i].vRegBB);
				gdbmiUpdateBreakpoint(Debugger.State,&Breakpoints[i]);
				Break = 1;
				break;
			}
		}
		else if (Breakpoints[i].WatchBreak == 0 &&
			     gdbmiCheckBreakpoint(Debugger.State,&Breakpoints[i]))
		{
			int Address12, vRegBB;
			int CurrentFB, vCurrentFB;
			Address12 = Breakpoints[i].Address12;
			if (Address12 != CurrentZ) continue;

			if (Address12 < 01400)
			{
				printf ("Breakpoint %d, %s () at %s:%d\n",i+1,
				 gdbmiConstructFuncName(Breakpoints[i].Line,FuncName,127),
				 Breakpoints[i].Line->FileName,Breakpoints[i].Line->LineNumber);
				gdbmiUpdateBreakpoint(Debugger.State,&Breakpoints[i]);
				Break = 1;
				break;
			}
			if (Address12 >= 04000)
			{
				printf ("Breakpoint %d, %s () at %s:%d\n",i+1,
				 gdbmiConstructFuncName(Breakpoints[i].Line,FuncName,127),
				 Breakpoints[i].Line->FileName,
				 Breakpoints[i].Line->LineNumber);
				gdbmiUpdateBreakpoint(Debugger.State,&Breakpoints[i]);
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
				  printf ("Hit breakpoint %s at E%o,%05o.\n",Breakpoints[i].Symbol->Name, CurrentBB & 7, Address12);
				else
				  printf("Hit breakpoint at E%o,%05o.\n",CurrentBB & 7,Address12);

				gdbmiUpdateBreakpoint(Debugger.State,&Breakpoints[i]);
				Break = 1;
				break;
			}

			CurrentFB = (CurrentBB >> 10) & 037;
			if (CurrentFB >= 030 && (CurrentBB & 0100)) CurrentFB += 010;

			vCurrentFB = (vRegBB >> 10) & 037;
			if (vCurrentFB >= 030 && (vRegBB & 0100)) vCurrentFB += 010;

			if (Address12 >= 02000 && Address12 < 04000 &&
			CurrentFB == vCurrentFB)
			{
				int Bank;

				Bank = (CurrentBB >> 10) & 037;
				if (0 != (CurrentBB & 0100) && Bank >= 030) Bank += 010;

				if (Breakpoints[i].Symbol != NULL)
				  printf ("Hit breakpoint %s at %02o,%05o.\n",
					  Breakpoints[i].Symbol->Name, Bank, Address12);
				else
				  printf ("Hit breakpoint at %02o,%05o.\n",
					  Bank, Address12);
				  gdbmiUpdateBreakpoint(Debugger.State,&Breakpoints[i]);
				Break = 1;
				break;
			}
		}
		else if ((Breakpoints[i].WatchBreak == 1 &&
				  gdbmiCheckBreakpoint(Debugger.State,&Breakpoints[i]) &&
			      Breakpoints[i].WatchValue != DbgGetWatch(Debugger.State,&Breakpoints[i])) ||
			     (Breakpoints[i].WatchBreak == 3 &&
			      Breakpoints[i].WatchValue == DbgGetWatch (Debugger.State,&Breakpoints[i])))
		  {
			int Address12, vRegBB, Before, After;
			Address12 = Breakpoints[i].Address12;
			Before = (Breakpoints[i].WatchValue & 077777);
			After = (DbgGetWatch (Debugger.State, &Breakpoints[i]) & 077777);
			if (Address12 < 01400)
			{
				if (Breakpoints[i].Symbol != NULL)
				  printf ("Hit watchpoint %s at %05o, %06o -> %06o.\n",
					  Breakpoints[i].Symbol->Name, Address12,Before, After);
				else
				  printf ("Hit watchpoint at %05o, %06o -> %06o.\n",
					  Address12, Before, After);

				if (Breakpoints[i].WatchBreak == 1)
				    Breakpoints[i].WatchValue = DbgGetWatch (Debugger.State, &Breakpoints[i]);

				gdbmiUpdateBreakpoint(Debugger.State,&Breakpoints[i]);
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
				  Breakpoints[i].WatchValue = DbgGetWatch (Debugger.State, &Breakpoints[i]);

				gdbmiUpdateBreakpoint(Debugger.State,&Breakpoints[i]);
				Break = 1;
				break;
			}
		 }
		else if ((Breakpoints[i].WatchBreak == 4 &&
				  gdbmiCheckBreakpoint(Debugger.State,&Breakpoints[i]) &&
				  Breakpoints[i].WatchValue != DbgGetWatch (Debugger.State,&Breakpoints[i])))
		{
			int Address12, vRegBB, Before, After;

			Address12 = Breakpoints[i].Address12;
			Before = (Breakpoints[i].WatchValue & 077777);
			After = (DbgGetWatch (Debugger.State, &Breakpoints[i]) & 077777);

			if (Address12 < 01400)
			{
				if (Breakpoints[i].Symbol != NULL)
				  printf ("%s=%06o\n", Breakpoints[i].Symbol->Name, After);
				else
				  printf ("(%05o)=%06o\n", Address12, After);
				Breakpoints[i].WatchValue = DbgGetWatch (Debugger.State, &Breakpoints[i]);
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

					Breakpoints[i].WatchValue = DbgGetWatch (Debugger.State, &Breakpoints[i]);
				}
			}
		}

	return (Break);
}

void DbgDisplayInnerFrame(void)
{
    // If we have the symbol table, then print out the actual source,
    // rather than just a disassembly
    if (Debugger.Options->symtab)
	{
		// Resolve the current program counter into an entry into
		// the program line table. We pass in the current value of
		// the Z register, but also need the BB register and the
		// super-bank bit to resolve addresses.
		int CurrentZ = Debugger.State->Erasable[0][RegZ] & 07777;
		int FB = 037 & (Debugger.State->Erasable[0][RegBB] >> 10);
		int SBB = (Debugger.State->OutputChannel7 & 0100) ? 1 : 0;

		/* Get the SymbolLine for the InnerFrame */
		SymbolLine_t *Line = ResolveLineAGC(CurrentZ, FB, SBB);

		// There are several ways this can fail, and if either does we
		// just want to disasemble: if we didn't find the line in the
		// table or if ListSource() fails.
		if (Line)
		{
			/* Load the actual Source Line */
			LoadSourceLine(Line->FileName, Line->LineNumber);
			if (RunState)
			{
			  if (Debugger.Options->fullname) gdbmiPrintFullNameContents(Line);
			  else Disassemble (Debugger.State);
			}
		}
	}
    else Disassemble (Debugger.State);
}

void DbgDisplayPrompt(void)
{
	  if (NumFromFiles == 1)
	  {
	      // JMS: Tell the thread which is actually reading the input from
	      // stdin to actually go ahead and read. At this point, we know that
	      // the last debugging command has been processed.
	      printf("%s",agcPrompt);
	      fflush(stdout);
	      nbfgets_ready(agcPrompt);
	  }
}

char* DbgGetCmdString(void)
{
	  strcpy(slast,sraw);

	  s[sizeof (s) - 1] = 0;
	  rfgets (Debugger.State, s, sizeof (s) - 1, FromFiles[NumFromFiles - 1]);

	  /* Use last command if just newline */
	  if (strlen(s) == 0) strcpy(s,slast);

	  return s;
}

static void DbgProcessLog()
{
	if (LogFile != NULL)
	{
	  int Bank, Address, NewLast;

	  Bank =
	077777 &
	(((Debugger.State->Erasable[0][RegBB]) | Debugger.State->OutputChannel7));
	  Address = 077777 & (Debugger.State->Erasable[0][RegZ]);
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

}

extern int DebuggerInterruptMasks[11];

int DbgExecute()
{
	char* s;
	char* sraw;
	int Break;
	int PatternValue, PatternMask;
	int i, j;
	char FileName[MAX_FILE_LENGTH + 1];
	int LineNumber, LineNumberTo;
	char Dummy[MAX_FILE_LENGTH + 1];
	char SymbolName[129];
	Symbol_t *Symbol;

	Break = DbgHasBreakEvent();

	if (Break && !DebugDsky)
	{

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

			RealTimeOffset +=((RealTime = times (&DummyTime)) - LastRealTime);
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
			else if (!strncmp (s, "COREDUMP ", 9))MakeCoreDump (Debugger.State, &sraw[9]);
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
			else if (Debugger.State->InterruptRequests[i])
				printf ("Interrupt %d already requested.\n", i);
			else
				{
				printf ("Interrupt %d request-flag set.\n", i);
				Debugger.State->InterruptRequests[i] = 1;
				}
			}
			else if (1 == sscanf (s, "INTOFF%d", &i))
			{
			if (i < 1 || i > NUM_INTERRUPT_TYPES)
				printf ("Only interrupt types 1 to %d are used.\n",
					NUM_INTERRUPT_TYPES);
			else if (!Debugger.State->InterruptRequests[i])
				printf ("Interrupt %d not requested.\n", i);
			else
				{
				printf ("Interrupt %d request-flag cleared.\n", i);
				Debugger.State->InterruptRequests[i] = 0;
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
			BacktraceDisplay (Debugger.State, MAX_BACKTRACE_POINTS);
			else if (1 == sscanf (s, "BACKTRACE%d", &i))
			{
			int j;
			if (0 != (j = BacktraceRestore (Debugger.State, i)))
				printf ("Error %d restoring backtrace point #%d.\n",
					j, i);
			else
				{
				printf ("Backtrace point #%d restored.\n", i);
				for (j = 0; j < NumBreakpoints; j++)
				if (Breakpoints[j].WatchBreak == 1 || Breakpoints[j].WatchBreak == 4)
				Breakpoints[j].WatchValue =
					DbgGetWatch (Debugger.State, &Breakpoints[j]);
				}
			Debugger.State->PendFlag = SingleStepCounter = 0;
			Break = 1;
			SimSetCycleCount(SIM_CYCLECOUNT_AGC);

			return (1);
			}

			else
			{
				GdbmiResult result = GdbmiHandleCommand(Debugger.State, s , sraw );
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
						// return(0);
						exit(0);
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

	return (0);
}