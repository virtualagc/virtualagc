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

extern void rfgets (agc_t *State, char *Buffer, int MaxSize, FILE * fp);

char* DbgGetCmdString(void)
{
	  strcpy(slast,sraw);

	  s[sizeof (s) - 1] = 0;
	  rfgets (Debugger.State, s, sizeof (s) - 1, FromFiles[NumFromFiles - 1]);

	  /* Use last command if just newline */
	  if (strlen(s) == 0) strcpy(s,slast);

	  return s;
}
void DbgProcessLog()
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

