/*
  Copyright 2008 Onno Hommes:1

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

  In addition, as a special exception, permission is granted to
  link the code of this program with the Orbiter SDK library (or with
  modified versions of the Orbiter SDK library that use the same license as
  the Orbiter SDK library), and distribute linked combinations including
  the two. You must obey the GNU General Public License in all respects for
  all of the code used other than the Orbiter SDK library. If you modify
  this file, you may extend this exception to your version of the file,
  but you are not obligated to do so. If you do not wish to do so, delete
  this exception statement from your version.

  Filename:	agc_gdbmi.c
  Purpose:	This is module covers the gdb/mi subsystem of yaAGC and enables
  		yaAGC to be debugged in a Graphical Debugger front-end to gdb.

  Compiler:	GNU gcc.
  Contact:	Onno Hommes
  Reference:	http://virtualagc.googlecode.com
  Mods:		01/01/08 OH		Began work.
			06/08/09 OH		Added info variables,functions and fixed
							Showing source line when not using -fullname.
			06/14/09 OH		Add the gdb style disassemble command
			07/01/09 OH		Convert to command tables to prepare for machine
							independence and change to GNU formating
*/

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "yaAGC.h"
#include "agc_engine.h"
#include "agc_symtab.h"
#include "agc_debug.h"
#include "agc_debugger.h"
#include "agc_disassembler.h"
#include "agc_gdbmi.h"
#include <string.h>
#include <unistd.h>
#ifdef WIN32
#include <windows.h>
#include <sys/time.h>
#include "regex.h"
#define LB "\r\n"
#else
#include <time.h>
#include <sys/times.h>
#include <regex.h>
#define LB ""
#endif


//#define VERSION(x) #x

extern char agcPrompt[16];
extern char nbPrompt[16];
extern int HaveSymbols;
extern int FullNameMode;
extern int Break;
extern int DebuggerInterruptMasks[11];
extern char* CurrentSourceFile;
extern int SymbolTableSize;
extern Symbol_t *SymbolTable;

extern char SourceFiles[MAX_NUM_FILES][MAX_FILE_LENGTH];
extern int NumberFiles;
extern SymbolLine_t* FindLastLineMain(void);

extern void CheckDec (char *s);
extern char* DbgGetFrameNameByAddr(unsigned LinearAddress);

static int gdbmi_break_id = 0;
static int gdbmi_status;
//static int cli_argc;
static char* cli_arg;

static char FileName[MAX_FILE_LENGTH+1];

static agc_t* State;
static char* s;
static char* sraw;

static CustomCommand_t gdbmiCustomCmds[32];

const char disp_keep[5] = "keep";
const char disp_delete[4] = "del";

char*
GdbmiStringToUpper(char* str)
{
   char* ss;

   /* Ensure command s is in uppercase */
   for (ss = str; *ss; *ss = toupper (*ss), ss++);

   return (str);
}

/**
Adjust the command string pointer with the value given.
*/
static inline void
GdbmiAdjustCmdPtr(int i)
{
   s += i;
   sraw += i;
}

GdbmiResult
GdbmiParseConsoleCommands(GdbmiCommands_t* CmdTable)
{
	int i=-1;
	int CmdLength;
	GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

	while(CmdTable[++i].Command)
	{
		CmdLength = strlen(CmdTable[i].Command);
		if (!strncmp(s,CmdTable[i].Command,CmdLength))
		{
			GdbmiStat = CmdTable[i].Handler(CmdLength);
			break;
		}
	}
	return (GdbmiStat);
}


static char *
GdbmiBasename (const char *name)
{
  const char *base;

#if defined (HAVE_DOS_BASED_FILE_SYSTEM)
  /* Skip over the disk name in MSDOS pathnames. */
  if (ISALPHA (name[0]) && name[1] == ':')
    name += 2;
#endif

  for (base = name; *name; name++)
    {
      if (*name == '/' || *name == '\\')
	{
	  base = name + 1;
	}
    }
  return (char *) base;
}

void GdbmiDisassemble(agc_t *State,unsigned start_linear,unsigned end_linear)
{

}

void
GdbmiDisplayBreakpointForLine(SymbolLine_t* Line,int BreakpointId)
{
   unsigned LinearAddress = DbgLinearAddr(&Line->CodeAddress);

   printf ("Breakpoint %d, %s () at %s:%d\n",BreakpointId,
	 DbgGetFrameNameByAddr(LinearAddress),
	 Line->FileName,Line->LineNumber);
}

/* Handle the break GDB/CLI command */
static GdbmiResult
GdbmiHandleAllBreak(int j,char disp)
{
   int i, vRegBB, LineNumber;
   Symbol_t *Symbol = NULL;
   SymbolLine_t *Line = NULL;
   char SymbolName[MAX_LABEL_LENGTH + 1],*cli_char;
   unsigned gdbmiAddress = 0;
   Address_t agc_addr;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(j);

   if (strlen(s) > 0) /* Do we have an argument */
   {
      s++;sraw++; /* Skip space */

      /* Remove Enclosing Double Quotes */
      if (sraw[0] == '\"')
      {
         ++sraw;++s;
         if (sraw[strlen(sraw)-1] == '\"')
         {
            sraw[strlen(sraw)-1] = 0;
            s[strlen(s)-1]=0;
         }
      }

      sraw = GdbmiBasename(sraw);
      s=GdbmiBasename(s);

      /* First replace ":" with space !!FIX to prevent DOS disk separator!! */
      cli_char = strstr(sraw,":");
      if (cli_char) *cli_char = ' '; /* replace colon with space */

      if (HaveSymbols &&
         (2 == sscanf (sraw, "%s %d", FileName, &LineNumber)) &&
         (Line = (SymbolLine_t*) ResolveFileLineNumber(FileName, LineNumber)))
      {
         gdbmiAddress = DbgLinearAddr(&Line->CodeAddress);

      }
      else if (HaveSymbols && (1 == sscanf (s, "%d", &LineNumber)) &&
             (Line = ResolveLineNumber (LineNumber)))
      {
          gdbmiAddress = DbgLinearAddr(&Line->CodeAddress);

      }
      else if (HaveSymbols && (1 == sscanf (s, "%s", SymbolName)) &&
             (Symbol = ResolveSymbol (SymbolName, SYMBOL_LABEL)))
      {
         gdbmiAddress = DbgLinearAddr(&Symbol->Value);
      }
      else if (1 == sscanf (s, "*0X%x", &gdbmiAddress));
      else
      {
         /* Insert error message not help */
         printf ("Illegal syntax for break.\n");
         return (GdbmiCmdDone);
      }
   }
   else /* Default Break point is current address */
   {
      gdbmiAddress = DbgLinearFixedAddr(
             State->Erasable[0][RegZ] & 07777,
             037 & (State->Erasable[0][RegBB] >> 10),
             (State->OutputChannel7 & 0100) ? 1 : 0);
   }

   if (gdbmiAddress < 04000)
   {
      printf ("Line number points to erasable memory.\n");
      return (GdbmiCmdDone);
   }

   agc_addr = DbgNativeAddr(gdbmiAddress);
   vRegBB = ((agc_addr.FB << 10) | (agc_addr.Super << 7));

   if (Line == NULL)
      Line = ResolveLineAGC (agc_addr.SReg,agc_addr.FB,agc_addr.Super);

   for (i = 0; i < NumBreakpoints; i++)
      if (Breakpoints[i].Address12 == agc_addr.SReg && Breakpoints[i].vRegBB == vRegBB &&
          Breakpoints[i].WatchBreak == 0)
   {
      printf ("This breakpoint already exists.\n");
      return (GdbmiCmdDone);
   }
   if (NumBreakpoints < MAX_BREAKPOINTS)
   {
      Breakpoints[NumBreakpoints].Id = ++gdbmi_break_id;
      Breakpoints[NumBreakpoints].Hits = 0;
      Breakpoints[NumBreakpoints].Enable = 'y';
      Breakpoints[NumBreakpoints].Disposition = disp;
      Breakpoints[NumBreakpoints].Address12 = agc_addr.SReg;
      Breakpoints[NumBreakpoints].vRegBB = vRegBB;
      Breakpoints[NumBreakpoints].WatchBreak = 0;
      Breakpoints[NumBreakpoints].Symbol = Symbol;
      Breakpoints[NumBreakpoints].Line = Line;
      NumBreakpoints++;
      if (Line)
         printf ("Breakpoint %d at 0x%04x: file %s, line %d.\n",
              NumBreakpoints,gdbmiAddress,Line->FileName,Line->LineNumber);
   }
   else
      printf ("The maximum number of breakpoints is already defined.\n");

   // FIX ME
   return (GdbmiCmdDone);
}

/* Handle the temporary break GDB/CLI command */
static GdbmiResult
GdbmiHandleTmpBrk(int i)
{
	return (GdbmiHandleAllBreak(i,BP_DELETE));
}

/* Handle the normal break GDB/CLI command */
static GdbmiResult
GdbmiHandleNormBrk(int i)
{
	return (GdbmiHandleAllBreak(i,BP_KEEP));
}

static GdbmiResult
GdbmiHandleWatch (int j)
{
   int k, i, vRegBB, WatchType, WatchValue = 0777777;
   Symbol_t *Symbol = NULL;
   unsigned gdbmi_address;
   Address_t agc_addr;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(j);

   if (strlen(sraw))
      Symbol = ResolveSymbol(sraw, SYMBOL_VARIABLE | SYMBOL_REGISTER | SYMBOL_CONSTANT);

   if (Symbol != NULL && !Symbol->Value.Erasable) Symbol = NULL;
   if (Symbol != NULL)
   {
      /* Get linear address for display */
      gdbmi_address = DbgLinearAddr(&Symbol->Value);

      /* Watch Type 3 = for value, Watch type 1 for any change */
      agc_addr = DbgNativeAddr(gdbmi_address);

      WatchType = 1;
      vRegBB = agc_addr.EB;
      k = agc_addr.SReg;
      WatchValue = State->Erasable[vRegBB][k];
   }

   for (i = 0; i < NumBreakpoints; i++)
      if (Breakpoints[i].Address12 == k && Breakpoints[i].vRegBB == vRegBB &&
          Breakpoints[i].WatchBreak == WatchType)
   {
      printf ("This watchpoint already exists.\n");
      return(GdbmiCmdDone);
   }

   if (NumBreakpoints < MAX_BREAKPOINTS)
   {
      Breakpoints[NumBreakpoints].Id = ++gdbmi_break_id;
      Breakpoints[NumBreakpoints].Hits = 0;
      Breakpoints[NumBreakpoints].Enable = 'y';
      Breakpoints[NumBreakpoints].Disposition = BP_KEEP;
      Breakpoints[NumBreakpoints].Address12 = k;
      Breakpoints[NumBreakpoints].vRegBB = vRegBB;
      Breakpoints[NumBreakpoints].WatchBreak = WatchType;
      Breakpoints[NumBreakpoints].Symbol = Symbol;
      Breakpoints[NumBreakpoints].Line = NULL;
      if (WatchType == 1)
         Breakpoints[NumBreakpoints].WatchValue =
               DbgGetWatch (State, &Breakpoints[NumBreakpoints]);
      else
         Breakpoints[NumBreakpoints].WatchValue = WatchValue;
      NumBreakpoints++;
      if (Symbol)
         printf ("Hardware watchpoint %d: %s\n",gdbmi_break_id,Symbol->Name);
   }
   else
      printf ("The maximum number of watchpoints is already defined.\n");

   return(GdbmiCmdDone);
}

void
GdbmiHandleShowVersion(void)
{
	DbgDisplayVersion();
}


static GdbmiResult
GdbmiHandleInfoRegisters(int i)
{

   int cli_argc = 0;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   if (strlen(s)>1)
   {
      cli_argc++;
      cli_arg = s + 1;
   }

   /* Print the requested register contents */
   if (!cli_argc || !strcmp(cli_arg,"A"))
      printf("A\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegA],
             0177777 & State->Erasable[0][RegA]);
   if (!cli_argc || !strcmp(cli_arg,"L"))
      printf("L\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegL],
             0177777 & State->Erasable[0][RegL]);
   if (!cli_argc || !strcmp(cli_arg,"Q"))
      printf("Q\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegQ],
             0177777 & State->Erasable[0][RegQ]);
   if (!cli_argc || !strcmp(cli_arg,"EB"))
      printf("EB\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegEB],
             0177777 & State->Erasable[0][RegEB]);
   if (!cli_argc || !strcmp(cli_arg,"FB"))
      printf("FB\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegFB],
             0177777 & State->Erasable[0][RegFB]);
   if (!cli_argc || !strcmp(cli_arg,"Z"))
      printf("Z\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegZ],
             0177777 & State->Erasable[0][RegZ]);
   if (!cli_argc || !strcmp(cli_arg,"BB"))
      printf("BB\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegBB],
             0177777 & State->Erasable[0][RegBB]);
   if (!cli_argc || !strcmp(cli_arg,"ARUPT"))
      printf("ARUPT\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegARUPT],
             0177777 & State->Erasable[0][RegARUPT]);
   if (!cli_argc || !strcmp(cli_arg,"LRUPT"))
      printf("LRUPT\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegLRUPT],
             0177777 & State->Erasable[0][RegLRUPT]);
   if (!cli_argc || !strcmp(cli_arg,"QRUPT"))
      printf("QRUPT\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegQRUPT],
             0177777 & State->Erasable[0][RegQRUPT]);
   if (!cli_argc || !strcmp(cli_arg,"ZRUPT"))
      printf("ZRUPT\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegZRUPT],
             0177777 & State->Erasable[0][RegZRUPT]);
   if (!cli_argc || !strcmp(cli_arg,"BBRUPT"))
      printf("BBRUPT\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegBBRUPT],
             0177777 & State->Erasable[0][RegBBRUPT]);
   if (!cli_argc || !strcmp(cli_arg,"BRUPT"))
      printf("BRUPT\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegBRUPT],
             0177777 & State->Erasable[0][RegBRUPT]);
   if (!cli_argc || !strcmp(cli_arg,"CHAN07"))
      printf("CHAN07\t\t0x%04x\t%d\n",
             0177777 & State->InputChannel[7],
             0177777 & State->InputChannel[7]);
   if (!cli_argc || !strcmp(cli_arg,"CYR"))
      printf("CYR\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegCYR],
             0177777 & State->Erasable[0][RegCYR]);
   if (!cli_argc || !strcmp(cli_arg,"SR"))
      printf("SR\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegSR],
             0177777 & State->Erasable[0][RegSR]);
   if (!cli_argc || !strcmp(cli_arg,"CYL"))
      printf("CYL\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegCYL],
             0177777 & State->Erasable[0][RegCYL]);
   if (!cli_argc || !strcmp(cli_arg,"EDOP"))
      printf("EDOP\t\t0x%04x\t%d\n",
             0177777 & State->Erasable[0][RegEDOP],
             0177777 & State->Erasable[0][RegEDOP]);
   if (!cli_argc || !strcmp(cli_arg,"INDEX"))
      printf("INDEX\t\t0x%04x\t%d\n",
             0177777 & State->IndexValue,
             0177777 & State->IndexValue);
   if (!cli_argc || !strcmp(cli_arg,"EXTEND"))
      printf("EXTEND\t\t0x%04x\t%d\n",
             0177777 & State->ExtraCode,
             0177777 & State->ExtraCode);
   if (!cli_argc || !strcmp(cli_arg,"IRQMSK"))
      printf("IRQMSK\t\t0x%04x\t%d\n",
             0177777 & State->AllowInterrupt,
             0177777 & State->AllowInterrupt);
   if (!cli_argc || !strcmp(cli_arg,"ISR"))
      printf("ISR\t\t0x%04x\t%d\n",
             0177777 & State->InIsr,
             0177777 & State->InIsr);

   return(GdbmiCmdDone);
}

GdbmiResult
GdbmiHandleInfoBreakpoints(int j)
{
   int i;
   char* disposition;

   /* No CmdPtr adjust ment necessary so ignore input */

   if (NumBreakpoints == 0)
      printf ("No breakpoints or watchpoints.\n");
   else
      printf ("Num\tType\t\tDisp\tEnb\tAddress\tWhat\n");

   for (i = 0; i < NumBreakpoints; i++)
   {
         int Address12, vRegBB;

         if (Breakpoints[i].Disposition == BP_KEEP)disposition=(char*)disp_keep;
         else disposition = (char*)disp_delete;

         if (Breakpoints[i].WatchBreak > 0)
         {
            if (Breakpoints[i].Symbol != NULL)
            {
                 printf ("%d\thw watchpoint\t%s\t%c\t        %s",
                       Breakpoints[i].Id,
                       disposition,
                       Breakpoints[i].Enable,
                       Breakpoints[i].Symbol->Name);
            }
         }
         else
         {
            printf ("%d\tbreakpoint\t%s\t%c\t",
                    Breakpoints[i].Id,
                    disposition,
                    Breakpoints[i].Enable);
         }

         Address12 = Breakpoints[i].Address12;
         vRegBB = Breakpoints[i].vRegBB;
         if (Address12 < 01400 || Address12 >= 04000)
            printf ("0x%04x", DbgLinearFixedAddr(Address12,0,0));
         else if (Address12 >= 02000 && Address12 < 04000)
         {
            int Bank;
            Bank = (vRegBB >> 10) & 037;
            if (0 != (vRegBB & 0100) && Bank >= 030) Bank += 010;
            printf ("0x%04x", DbgLinearFixedAddr(Address12,Bank,0));
         }

         // Print out the file,line if set for the breakpoint
         if (HaveSymbols)
         {
            if (Breakpoints[i].Symbol != NULL && !Breakpoints[i].WatchBreak)
               printf("  in file %s:%d",
                      Breakpoints[i].Symbol->FileName,
                      Breakpoints[i].Symbol->LineNumber);
            else if (Breakpoints[i].Line != NULL && !Breakpoints[i].WatchBreak)
               printf("  in file %s:%d",
                      Breakpoints[i].Line->FileName,
                      Breakpoints[i].Line->LineNumber);
         }
      printf ("\n");
      if (Breakpoints[i].Hits == 1)
         printf("\tbreakpoint already hit %d time\n",Breakpoints[i].Hits);
      else if (Breakpoints[i].Hits > 1)
         printf("\tbreakpoint already hit %d times\n",Breakpoints[i].Hits);
   }
   return(GdbmiCmdDone);
}

void
GdbmiPrintFullNameFrame(SymbolLine_t *Line)
{
   /* Need OS Seperator */
#ifdef WIN32
   printf("\032\032%s\\%s:%d:%d:beg:0x%04x\n",SourcePathName,
          Line->FileName, Line->LineNumber,Line->LineNumber,
          DbgLinearFixedAddr(Line->CodeAddress.SReg,
                               Line->CodeAddress.FB,
                               Line->CodeAddress.Super));
#else
   printf("\032\032%s/%s:%d:%d:beg:0x%04x\n",SourcePathName,
          Line->FileName, Line->LineNumber,Line->LineNumber,
          DbgLinearFixedAddr(Line->CodeAddress.SReg,
                               Line->CodeAddress.FB,
                               Line->CodeAddress.Super));
#endif
}

static char* CurrentFileName = 0;

void
GdbmiPrintSourceFrame(SymbolLine_t *Line)
{
	if (CurrentFileName == 0 || strcmp(CurrentFileName,Line->FileName))
	{
		/* Looks like a source file switch print the file info */
		unsigned Address = DbgLinearAddr(&Line->CodeAddress);
		printf("%s () at %s:%d\n",
				DbgGetFrameNameByAddr(Address),
				Line->FileName,
				Line->LineNumber);
		CurrentFileName = Line->FileName;
	}
	ListSourceLine(Line->FileName,Line->LineNumber,0);
}


GdbmiResult
GdbmiHandleInfoLine(int i)
{
   int LineNumber;
   SymbolLine_t *Line = NULL;
   char *cli_char = NULL;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   if (*s == ' ')
   {
      cli_char = strstr(sraw,":");
      *cli_char = ' ';

      if (2 == sscanf (sraw+1, "%s %d", FileName, &LineNumber))
      {
         Line = (SymbolLine_t*)ResolveFileLineNumber(FileName,LineNumber);
      }
   }
   else
   {
      int CurrentZ = State->Erasable[0][RegZ] & 07777;
      int FB = 037 & (State->Erasable[0][RegBB] >> 10);
      int SBB = (State->OutputChannel7 & 0100) ? 1 : 0;
      Line = ResolveLineAGC(CurrentZ, FB, SBB);
   }

   if (Line)
   {
      unsigned Addr = DbgLinearAddr(&Line->CodeAddress);
      char* FrameName = DbgGetFrameNameByAddr(Addr);
      printf("Line %d of \"%s\" starts at address 0x%04x <%s>\n",
             Line->LineNumber,Line->FileName,
             Addr,FrameName);
      printf("   and ends at 0x%04x <%s>.\n",
             Addr,FrameName);
      if (FullNameMode) GdbmiPrintFullNameFrame(Line);
   }
	return(GdbmiCmdDone);
}

GdbmiResult
GdbmiHandleInfoTarget(int i)
{
   printf("Symbols from \"%s\".\n",SymbolFile);
   printf("Local exec file:\n");
   printf("\tfile type ropes-agc.\n");
   printf("\tEntry point: 0x0800\n");
   printf("\t0x0000 - 0x02ff is .unswitched_eraseable\n");
   printf("\t0x0300 - 0x07ff is .switched_eraseable\n");
   printf("\t0x0800 - 0x0fff is .fixed_fixed\n");
   printf("\t0x1000 - 0x17ff is .common_fixed\n");
   printf("\t0x1800 - 0x1fff is .fixed_fixed\n");
   printf("\t0x2000 - 0x6fff is .common_fixed\n");
   printf("\t0x7000 - 0x9fff is .super_bank\n");

   return(GdbmiCmdDone);
}

GdbmiResult
GdbmiHandleInfoChannels(int i)
{
	int chx;
	unsigned value;
	int select = -1;

	/* Adjust the CmdPtr to point to the next token */
	GdbmiAdjustCmdPtr(i);

	/* Check for a channel argument */
	if (strlen(s) > 0)
	{
		select = strtol(s,0,0);
	}
	for (chx=0;chx<NUM_CHANNELS;chx++)
	{
		value = ReadIO(State,chx);
		if (select < 0 || select == chx)
		{
		printf("CHAN%o\t0x%04x %5d\n",chx,value,value);
		}
	}
	return(GdbmiCmdDone);
}

typedef struct io_regs_tag
{
	char name[8];
	int offset;
} t_io_regs;

#define NUM_IO_REGS 23
const t_io_regs io_registers[NUM_IO_REGS] =
{
	{"CDUX",032},
	{"CDUY",033},
	{"CDUZ",034},
	{"OPTY",035},
	{"OPTX",036},
	{"PIPAX",037},
	{"PIPAY",040},
	{"PIPAZ",041},
	{"RHCP",042},
	{"RHCY",043},
	{"RHCR",044},
	{"INLINK",045},
	{"RNRAD",046},
	{"GYROCMD",047},
	{"CDUXCMD",050},
	{"CDUYCMD",051},
	{"CDUZCMD",052},
	{"OPTYCMD",053},
	{"OPTXCMD",054},
	{"THRUST",055},
	{"LEMONM",056},
	{"OUTLINK",057},
	{"ALTM",060}
};

static GdbmiResult
GdbmiHandleInfoIoRegisters(int j)
{
	int io_select = 0;
	int i;
	unsigned value;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(j);

	if (strlen(s++) > 1) io_select = 1;

	for (i=0;i< NUM_IO_REGS;i++)
	{
		if (io_select == 0 || !strcmp(s,io_registers[i].name))
		{
			value = 0177777 & State->Erasable[0][io_registers[i].offset];
			printf("%s\t\t0x%04x\t%u\n",io_registers[i].name,value,value);
		}
	}

	return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleInfoAllRegisters(int i)
{
   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   GdbmiHandleInfoRegisters(0);
   GdbmiHandleInfoIoRegisters(0);

   return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleInfoProgram(int i)
{
   printf("\tUsing the running image of child process 0.\n");
   printf("Program stopped at 0x%04x.\n",DbgLinearFixedAddr(
          State->Erasable[0][RegZ] & 07777,
          037 & (State->Erasable[0][RegBB] >> 10),
                 (State->OutputChannel7 & 0100) ? 1 : 0));
   printf("It stopped after being stepped.\n");

   return(GdbmiCmdDone);
}



/**
 * Display the thread summaries of all currently known threads
 * If no ISR is active only one thread the default execution
 * thread will be shown. If an ISR is running (only one can run
 * at a time then both the ISR as well as the default execution
 * thread will be shown. With the ISR marked as the active thread
 */
static GdbmiResult
GdbmiHandleInfoThreads(int i)
{
   SymbolLine_t* Line = NULL;
   char threadName[10] = "main";
   unsigned LinearAddress;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   /* Check if we are dealing with 2 threads (i.e. in an ISR) */
   if (State->InIsr)
   {
      /* Determine the thread name to be verbose when showing info */
      switch(State->InterruptRequests[0])
      {
         case 1:
            strcpy(threadName,"TIMER6");
            break;
         case 2:
            strcpy(threadName,"TIMER5");
            break;
         case 3:
            strcpy(threadName,"TIMER3");
            break;
         case 4:
            strcpy(threadName,"TIMER4");
            break;
         case 5:
            strcpy(threadName,"KEYBD1");
            break;
         case 6:
            strcpy(threadName,"KEYBD2");
            break;
         case 7:
            strcpy(threadName,"UPLINK");
            break;
         case 8:
            strcpy(threadName,"DNLINK");
            break;
         case 9:
            strcpy(threadName,"RADAR");
            break;
         case 10:
            strcpy(threadName,"JOYSTK");
            break;
         default:
            strcpy(threadName,"MAIN");
            break;
      }

      /* Get  head of the stack of ISR thread */
      Line = DbgResolveCurrentLine();
      if (Line)
      {
    	 LinearAddress = DbgLinearAddr(&Line->CodeAddress);
         printf("* 2 thread %d (%s)\t0x%04x in %s ()\n",
               State->InterruptRequests[0],
               threadName,
               LinearAddress,
               DbgGetFrameNameByAddr(LinearAddress)
               );
         printf("    at %s:%d\n",Line->FileName,Line->LineNumber);
      }

      Line = FindLastLineMain();
      if (Line)
      {
         LinearAddress = DbgLinearAddr(&Line->CodeAddress);
         printf("  1 thread 0 (MAIN)\t0x%04x in %s ()\n",
               LinearAddress,DbgGetFrameNameByAddr(LinearAddress));
      }
   }
   else
   {
      Line = DbgResolveCurrentLine();
      if (Line)
      {
         LinearAddress = DbgLinearAddr(&Line->CodeAddress);
         printf("* 1 thread 0 (MAIN)\t0x%04x in %s ()\n",
                LinearAddress,DbgGetFrameNameByAddr(LinearAddress));
         printf("    at %s:%d\n",Line->FileName,Line->LineNumber);
      }
   }
   return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleBacktrace(int i)
{
   int LimitList = MAX_BACKTRACE_POINTS;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   sscanf (s, "%d", &LimitList);
   BacktraceDisplay(State,LimitList);
   return(GdbmiCmdDone);
}

//Current source file is main.c
//Compilation directory is C:/Code/virtualagc/yaAGC/
//Located in C:/Code/virtualagc/yaAGC/main.c
//Contains 1733 lines.
//Source language is c.
//Compiled with stabs debugging format.
static GdbmiResult
GdbmiHandleInfoSource(int i)
{
	printf("Current source file is %s\n",CurrentSourceFile);
	printf("Compilation directory is %s\n",SourcePathName);
#ifdef WIN32
	printf("Located in %s\\%s\n",SourcePathName,CurrentSourceFile);
#else
	printf("Located in %s/%s\n",SourcePathName,CurrentSourceFile);
#endif
	printf("Source language is assembler.\n");
	printf("Compiled with proprietary debugging format.\n");
	return(GdbmiCmdDone);
}

/**
Display the list of source files for which symbols are loaded.
Since the list can be quite long the command allows for a pattern
to be passed to reduce the output list in console mode.
*/
static GdbmiResult
GdbmiHandleInfoSources(int i)
{
   int j;
   regex_t preg;
   int UsePattern = 0;
   int Match = 0;
   GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   /* Check if a pattern search is used */
   if (strlen(s) > 0)
   {
	GdbmiAdjustCmdPtr(1);

	j = regcomp (&preg, sraw, REG_ICASE | REG_NOSUB | REG_EXTENDED);
        if (j)
        {
           printf ("Illegal regular-expression.\n");
           regfree (&preg);
           GdbmiStat = GdbmiCmdError;
        }
	else UsePattern = 1;
   }

   if (GdbmiStat != GdbmiCmdError)
   {
      printf("Source files for which symbols have been read in:\n\n");

      /* Loop through and print out the file names */
      for (j = 0; j < NumberFiles; j++)
      {
         Match = 0;

         if (UsePattern)
         {
            if (0 == regexec (&preg, SourceFiles[j], 0, NULL, 0))
            {
               Match = 1;
            }
         }
         else Match = 1;

         if (Match)
         {
#ifdef WIN32
	    printf("%s\\%s\n", SourcePathName, SourceFiles[j]);
#else
	    printf("%s/%s\n", SourcePathName, SourceFiles[j]);
#endif
         }
      }
      fflush (stdout);
      if (UsePattern) regfree (&preg);

      GdbmiStat = GdbmiCmdUnhandled;
   }

   return GdbmiStat;
}

static GdbmiResult
GdbmiHandleInfoInterrupts(int j)
{
	int i;

	GdbmiAdjustCmdPtr(j);

	if (!DebuggerInterruptMasks[0]) printf ("All interrupts are blocked.\n");
	else printf ("Interrupts are allowed.\n");

	printf ("Debugger interrupt mask:");
	for (i = 1; i <= NUM_INTERRUPT_TYPES; i++)
	   printf (" %d", !DebuggerInterruptMasks[i]);

	printf ("\nInterrupt-request flags:");
	for (i = 1; i <= NUM_INTERRUPT_TYPES; i++)
		printf (" %d", State->InterruptRequests[i]);

	if (State->InIsr) printf ("\nIn ISR #%d.\n", State->InterruptRequests[0]);
	else printf ("\nLast ISR: #%d.\n",State->InterruptRequests[0]);

	return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleInfoSymbols(int i,int type)
{
   int j;
   regex_t preg;
   int UsePattern = 0;
   int Match = 0;
   char* LastFileName = (char*)0;

   GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

   GdbmiAdjustCmdPtr(i);

   /* Check if a pattern search is used */
   if (strlen(s) > 0)
   {
	GdbmiAdjustCmdPtr(1);

	j = regcomp (&preg, sraw, REG_ICASE | REG_NOSUB | REG_EXTENDED);
        if (j)
        {
           printf ("Illegal regular-expression.\n");
           regfree (&preg);
           GdbmiStat = GdbmiCmdError;
        }
	else UsePattern = 1;
   }

   if (GdbmiStat != GdbmiCmdError)
   {
      if (UsePattern)
      {
         if (type == SYMBOL_VARIABLE)
            printf("All variables matching regular expression \"%s\":\n",sraw);
         else if (type == SYMBOL_CONSTANT)
            printf("All constants matching regular expression \"%s\":\n",sraw);
         else if (type == SYMBOL_LABEL)
            printf("All functions matching regular expression \"%s\":\n",sraw);
      }
      else
      {
         if (type == SYMBOL_VARIABLE)
            printf("All defined variables:\n");
         else if (type == SYMBOL_CONSTANT)
            printf("All defined constants:\n");
         else if (type == SYMBOL_LABEL)
            printf("All defined functions:\n");
      }

      LastFileName = SymbolTable[0].FileName;

      // Loop through and print out the entire symbol table
      for (j = 0; j < SymbolTableSize; j++)
      {
         Match = 0;

         if (UsePattern)
         {
            if (0 == regexec (&preg, SymbolTable[j].Name, 0, NULL, 0))
            {
               Match = 1;
            }
         }
         else Match = 1;

         if (Match)
         {
              if (SymbolTable[j].Type == type)
              {

                 if (strcmp(LastFileName,SymbolTable[j].FileName))
                 {
                     LastFileName = SymbolTable[j].FileName;
                     printf("\nFile %s:\n",LastFileName);
                 }

                 if (type == SYMBOL_VARIABLE)
                     printf ("var %s;\n",SymbolTable[j].Name);
                 else if (type == SYMBOL_CONSTANT)
                     printf ("const %s;\n",SymbolTable[j].Name);
                 else if (type == SYMBOL_LABEL)
                     printf ("func %s();\n",SymbolTable[j].Name);
              }
         }
         fflush (stdout);
       }
       if (UsePattern) regfree (&preg);
       printf("\n");
   }

   return GdbmiStat;
}

static GdbmiResult
GdbmiHandleInfoVariables(int i)
{
    return GdbmiHandleInfoSymbols(i,SYMBOL_VARIABLE);
}

static GdbmiResult
GdbmiHandleInfoConstants(int i)
{
    return GdbmiHandleInfoSymbols(i,SYMBOL_CONSTANT);
}

static GdbmiResult
GdbmiHandleInfoFunctions(int i)
{
    return GdbmiHandleInfoSymbols(i,SYMBOL_LABEL);
}

GdbmiCommands_t GdbmiConsoleInfoCommands[18] =
{
   {"ALL-REGISTERS", GdbmiHandleInfoAllRegisters},
   {"REGISTERS", GdbmiHandleInfoRegisters},
   {"BREAKPOINTS", GdbmiHandleInfoBreakpoints},
   {"LINE", GdbmiHandleInfoLine},
   {"TARGET", GdbmiHandleInfoTarget},
   {"FILES", GdbmiHandleInfoTarget},
   {"CHANNELS", GdbmiHandleInfoChannels},
   {"IO_REGISTERS", GdbmiHandleInfoIoRegisters},
   {"PROGRAM", GdbmiHandleInfoProgram},
   {"STACK", GdbmiHandleBacktrace},
   {"THREADS", GdbmiHandleInfoThreads},
   {"INTERRUPTS", GdbmiHandleInfoInterrupts},
   {"SOURCES", GdbmiHandleInfoSources},
   {"VARIABLES", GdbmiHandleInfoVariables},
   {"FUNCTIONS", GdbmiHandleInfoFunctions},
   {"CONSTANTS", GdbmiHandleInfoConstants},
   {"SOURCE", GdbmiHandleInfoSource},
   {0,0}
};


static GdbmiResult
GdbmiHandleInfo(int i)
{
   GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   /* Parse and Execute Commands */
   GdbmiStat = GdbmiParseConsoleCommands(GdbmiConsoleInfoCommands);

   /* During the new construct transition allow both fbk's*/
   if (GdbmiStat == GdbmiCmdUnhandled) GdbmiStat = gdbmi_status;

   return(GdbmiStat);
}


static GdbmiResult
GdbmiHandleSetPrompt(int i)
{
   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   strncpy(agcPrompt,sraw,15);
   strncpy(nbPrompt,agcPrompt,15);

   return(GdbmiCmdDone);
}

int
GdbmiString2Num(char* s, unsigned* Num)
{
	int Result = -1;

	if (1 == sscanf (s, "0X%x",Num)) Result = 0;
	else if (1 == sscanf (s, "0%o",Num)) Result = 0;
	else if (1 == sscanf (s, "%d",Num)) Result = 0;
	return Result;
}


/** This function parses the expression for setting a value in memory
 */
static GdbmiResult
GdbmiHandleSetVariable(int i)
{
   unsigned gdbmi_addr,gdbmi_val;
   char *operand1,*operand2;
   Symbol_t *Symbol = NULL;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   operand1 = s;
   operand2 = strstr(s,"=");
   *operand2++ = (char)0;

   /* Set value using address */
   if (operand1[0] == '*')
   {
	   gdbmi_addr = DbgLinearAddrFromAddrStr(++operand1);
	   if ((gdbmi_addr != ~0) && (GdbmiString2Num(operand2,&gdbmi_val) == 0))
			DbgSetValueByAddress(gdbmi_addr,(unsigned short)gdbmi_val);
   }
   else /* Must be a symbol */
   {
	Symbol = ResolveSymbol(operand1, SYMBOL_VARIABLE);
        if (Symbol != NULL &&
		!Symbol->Value.Erasable) Symbol = NULL;

		if (Symbol != NULL)
	{
		/* Get linear address for display */
		gdbmi_addr = DbgLinearAddr(&Symbol->Value);
			if (GdbmiString2Num(operand2,&gdbmi_val) == 0)
				DbgSetValueByAddress(gdbmi_addr,(unsigned short)gdbmi_val);
	}
   }
   return (GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleSet(int i)
{
   GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   if (!strncmp(s, "PROMPT ",7)) GdbmiStat = GdbmiHandleSetPrompt(7);
   else if (!strncmp(s, "CONFIRM ",8)) GdbmiStat = GdbmiCmdDone; /* Ignore for now */
   else if (!strncmp(s, "WIDTH ",6)) GdbmiStat = GdbmiCmdDone; /* Ignore for now */
   else if (!strncmp(s, "HEIGHT ",7)) GdbmiStat = GdbmiCmdDone; /* Ignore for now */
   else if (!strncmp(s, "BREAKPOINT ",11)) GdbmiStat = GdbmiCmdDone; /* Ignore for now */
   else if (!strncmp(s, "PRINT ",6)) GdbmiStat = GdbmiCmdDone; /* Ignore for now */
   else if (!strncmp(s, "UNWINDONSIGNAL ",15)) GdbmiStat = GdbmiCmdDone; /* Ignore for now */
   else if (!strncmp(s, "DISASSEMBLY-FLAVOR ",19)) GdbmiStat = GdbmiCmdDone; /* Ignore for now */
   else if (!strncmp(s, "DEBUGEVENTS ",12)) GdbmiStat = GdbmiCmdDone; /* Ignore for now */
   else if (!strncmp(s, "VARIABLE ",9)) GdbmiStat = GdbmiHandleSetVariable(9);
   else	GdbmiStat = GdbmiHandleSetVariable(0);

  return(GdbmiStat);
}

/**
 * This function implements the console command disassemble (a.k.a. disas)
 * Without USER arguments it displays a block of disassembled code around the
 * current program counter. If the USER provided the start and end addresses
 * then the debugger will dump a disassemble from the start address (inclusive)
 * to the end address (exclusive).
 */
static GdbmiResult
GdbmiHandleDisassemble(int i)
{
   unsigned gdbmiFromAddr,gdbmiToAddr;
   Address_t agc_addr;
   SymbolLine_t* Line = NULL;
   GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   /* Determine if the USER provided Address arguments */
   if (*sraw == ' ')
   {
      if (2 == sscanf (sraw+1, "0x%x 0x%x", &gdbmiFromAddr, &gdbmiToAddr))
      {
         while (gdbmiFromAddr <= gdbmiToAddr)
         {
            agc_addr = DbgNativeAddr(gdbmiFromAddr);
            Line = ResolveLineAGC(agc_addr.SReg,agc_addr.FB,agc_addr.Super);
            if (Line)
            {
               printf("0x%04x %s:\t0x%04x\n",
                    gdbmiFromAddr,
                    DbgGetFrameNameByAddr(gdbmiFromAddr),
                    DbgGetValueByAddress(gdbmiFromAddr));
            }
         }
         GdbmiStat = GdbmiCmdDone;
      }
      GdbmiStat = GdbmiCmdError;
   }
   else /* No arguments */
   {
	   Disassemble(State);
	   GdbmiStat = GdbmiCmdDone;

   }

   return (GdbmiStat);
}

static GdbmiResult
GdbmiHandleDefine(int i)
{
   char* gdbmi_custom;
   char gdbmi_element[256];
   unsigned cmd_idx;
   unsigned arg_idx;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   gdbmi_custom = s;
   gdbmi_element[0] = (char)0;

   if (strlen(gdbmi_custom) > 0 )
   {
      for(cmd_idx=0;
          cmd_idx<GDBMI_MAX_CUSTOM_CMDS;
          cmd_idx++)
      {
         if (gdbmiCustomCmds[cmd_idx].Command == NULL) break;
      }

      if (cmd_idx < GDBMI_MAX_CUSTOM_CMDS)
      {
         gdbmiCustomCmds[cmd_idx].Command = strdup(gdbmi_custom);

         printf("Type commands for definition of \"%s\".\n",sraw);
         printf("End with a line saying just \"end\".\n");

         arg_idx = 0;

         while (1)
         {
            //printf(">");
            //gets((char*)gdbmi_element);
            nbfgets_ready(">");
            fflush(stdout);
            while ( nbfgets (gdbmi_element, 256) == 0);

            if (strcmp(gdbmi_element,"end"))
               gdbmiCustomCmds[cmd_idx].Arguments[arg_idx++] = strdup(gdbmi_element);
            else
            {
               gdbmiCustomCmds[cmd_idx].Arguments[arg_idx] = NULL;
               break;
            }
         }
      }
   }
   return (GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleList(int i)
{
   int LineNumber, LineNumberTo;
   char Dummy[MAX_FILE_LENGTH + 1];
   char* FileName;
   char* LineStr;
   Symbol_t *Symbol;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   /* Is this just the list command */
   if (!strcmp(s,""))ListSource (NULL, -1);
   /* Do we want to just backup and list */
	else if (!strcmp (s, " -"))ListBackupSource ();
	else if (2 == sscanf (s, " %d,%d", &LineNumber, &LineNumberTo))
	{
      /* This case where we want to list between two line numbers.
       * sscanf seems to handle this case ok, unlike its inability
       * to parse name:line. We leave the range checking for the
       * ListSourceRange() routine.*/
      ListSourceRange (LineNumber, LineNumberTo);
	}
   else if (1 == sscanf (s, " %d", &LineNumber))
	{
	   /* The case where we want to list a file number in the
		 * currently opened file */
	   ListSource (NULL, LineNumber);
	}
	else if (1 == sscanf (sraw, " %s", Dummy))
	{
      /* The case where we want to list a file number from a
       * given file. We actually need to take the file name
       * from the raw string to keep the case. I can't seem
       * to figure out how to get sscanf() to recognize the
       * colon so I need to do this painfully. */
      FileName=strtok(Dummy,":");
      LineStr=strtok(NULL,":");
      if (LineStr) LineNumber = atoi(LineStr);

      /* If there is no ":" then we will assume we want to
       * list a symbol (function), otherwise, we assume the
       * debug command is of the form FILE:LINENUM. */
      if (LineStr !=NULL && (FileName != NULL))
      {
      	 ListSource (FileName, LineNumber);
      }
	   else
		{
		  /* Try to resolve the symbol and then list the
		   * source for that symbol*/
		  if (FileName && (Symbol = ResolveSymbol(FileName,SYMBOL_LABEL)) != NULL)
		  {
		  	 printf("%s:\n",Symbol->FileName);
		    ListSource (Symbol->FileName, Symbol->LineNumber);
		  }
		  else printf("Function or Symbol not defined.\n");
		}
	}

   return(GdbmiCmdDone);
}

GdbmiResult
GdbmiHandleDelete(int i)
{
   int gdbmi_breakpoint = 0;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   if (strlen(s) == 0) NumBreakpoints = 0;
   else
   {
      s++;
      sraw++;
      if (1 == sscanf (s, "%d", &gdbmi_breakpoint))
      {
    	  DbgDeleteBreakpoint(gdbmi_breakpoint);
      }
   }
   return(GdbmiCmdDone);
}


static GdbmiResult
GdbmiHandleDisable(int j)
{
   int gdbmi_breakpoint = 0;
   int i;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(j);

   if (strlen(s) > 0) /* There must be an argument */
   {
      if (1 == sscanf (s, "%d", &gdbmi_breakpoint))
      {
         for (i = 0; i < NumBreakpoints; i++)
            if (Breakpoints[i].Id == gdbmi_breakpoint)
            {
               Breakpoints[i].Enable = 'n';
               break;
            }
      }
   }
   return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleEnable(int j)
{
   int gdbmi_breakpoint = 0;
   int i;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(j);

   if (strlen(s) > 0) /* There must be an argument */
   {
      if (1 == sscanf (s, "%d", &gdbmi_breakpoint))
      {
         for (i = 0; i < NumBreakpoints; i++)
            if (Breakpoints[i].Id == gdbmi_breakpoint)
         {
            Breakpoints[i].Enable = 'y';
            break;
         }
      }
   }
   return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleRun(int i)
{
   printf("[New Thread 11]\n");
   printf("[Switching to Thread 11]\n");

   return(GdbmiCmdRun);
}

static GdbmiResult
GdbmiHandleDumpMemory(int i)
{
   unsigned start_addr,end_addr,gdbmi_addr;
   unsigned short value;
   char filename[256];
   FILE* target;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   if (3 == sscanf (sraw, "%s 0x%x 0x%x", filename,&start_addr,&end_addr))
   {
      if (end_addr >= start_addr && start_addr >= 0 && end_addr < 0114000)
      {
         target = fopen(filename,"w");
         if (target != NULL)
         {
            for (gdbmi_addr=start_addr;gdbmi_addr<=end_addr;gdbmi_addr++)
            {
               value = DbgGetValueByAddress(gdbmi_addr);
               fwrite(&value,2,1,target);
            }
            fclose(target);
         }
      }
   }
   return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleRestoreMemory(int i)
{
   unsigned start_addr,end_addr,gdbmi_addr;
   unsigned short value;
   char filename[256];
   FILE* source;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   end_addr = 0114000;
   if (3 >= sscanf (sraw, "%s 0x%x 0x%x", filename,&start_addr,&end_addr))
   {
      if (start_addr >= 0 && start_addr < 0114000)
      {
      	gdbmi_addr = start_addr;
         source = fopen(filename,"r");
         if (source != NULL)
         {
            while(fread(&value,2,1,source) &&
                  gdbmi_addr < end_addr )
            {
               DbgSetValueByAddress(gdbmi_addr++,value);
            }
            fclose(source);
         }
      }
   }
   return(GdbmiCmdDone);
}


static GdbmiResult
GdbmiHandleDump(int i)
{
	GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

	/* Adjust the CmdPtr to point to the next token */
	GdbmiAdjustCmdPtr(i);

   if (!strncmp(s,"MEMORY ",7)) GdbmiStat = GdbmiHandleDumpMemory(7);

   return (GdbmiStat);
}

static GdbmiResult
GdbmiHandleShow(int i)
{
   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   if (!strncmp(s," VERSION",8)) GdbmiHandleShowVersion();

   return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleStart(int i)
{
	DbgSetRunState();
	return(GdbmiCmdDone);
}


static GdbmiResult
GdbmiHandleWhatIs(int i)
{
   /* All types will be considered unsigned */
   printf("type = unsigned\n");
   return(GdbmiCmdDone);
}


static GdbmiResult
GdbmiHandlePrint(int i)
{
   int AddrFlag = 0;
   char* AddrStr;
   Symbol_t *Symbol = NULL;
   Address_t *agc_addr;
   unsigned gdbmi_addr;


   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   if (strlen(s) > 1)
   {
      /* we have an expression */
	   AddrStr = ++sraw;
      if (*AddrStr == '&')
      {
      	 AddrFlag++;
      	 AddrStr++;
      }

      /* I like to also see values of constants eventhough the default
         agc implementation did not do  this */
      Symbol = ResolveSymbol(AddrStr, SYMBOL_VARIABLE | SYMBOL_REGISTER | SYMBOL_CONSTANT);
      if (Symbol)
      {
         agc_addr = &Symbol->Value;
         gdbmi_addr = DbgLinearAddr(agc_addr);

         if (AddrFlag)
         	printf("$1 = 0x%x\n",gdbmi_addr);
         else
         	printf("$1 = %d\n",DbgGetValueByAddress(gdbmi_addr));
      }
      else
      {
    	  if (*AddrStr == '*')
    	  {
    		  gdbmi_addr = DbgLinearAddrFromAddrStr(++AddrStr);
    		  printf("$1 = %d\n",DbgGetValueByAddress(gdbmi_addr));
    	  }
    	  else printf("$1 = %s\n",sraw);
      }
   }
   return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleOutput(int i)
{
   int AddrFlag = 0;
   char* AddrStr;
   Symbol_t *Symbol = NULL;
   Address_t *agc_addr;
   unsigned gdbmi_addr;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   if (strlen(s) > 1)
   {
      /* we have an expression */
	   AddrStr = ++sraw;
      if (*AddrStr == '&')
      {
         AddrFlag++;
         AddrStr++;
      }

      /* I like to also see values of constants eventhough the default
      agc implementation did not do  this */
      Symbol = ResolveSymbol(AddrStr, SYMBOL_VARIABLE | SYMBOL_REGISTER | SYMBOL_CONSTANT);
      if (Symbol)
      {
         agc_addr = &Symbol->Value;
         gdbmi_addr = DbgLinearAddr(agc_addr);

         if (AddrFlag)
            printf("0x%x",gdbmi_addr);
         else
            printf("%d",DbgGetValueByAddress(gdbmi_addr));
      }
      else
      {
    	  if (*AddrStr == '*')
    	  {
    		  gdbmi_addr = DbgLinearAddrFromAddrStr(++AddrStr);
    		  printf("%d",DbgGetValueByAddress(gdbmi_addr));
    	  }
    	  else printf("%s",sraw);
      }
   }
   return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleExamine(int j)
{
   int i;
   int gdbmi_count = 1; /* Default 1 count */
   unsigned gdbmi_addr = 0;
   int gdbmi_value = 0;
   char gdbmi_format = 'x';
   char gdbmi_size = 'w';
   char* gdbmi_space = NULL;
   char* invalid_char = NULL;
   int gdbmi_apl = 4; /* default 8 addresses per line */
   GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(j);

   /* Do we see arguments */
   if (s && (strlen(s) > 1))
   {
      /* Is there a format Specifier */
      if ((s = strstr(s,"/")))
      {
         gdbmi_count = (int)strtol(++s,&invalid_char,0);
      }

      /* We already skipped the first space if it existed
       * So look for the space in front of the address */
      gdbmi_space=strstr(s," ");

      /* Look for size and format specifiers */
      while (s < gdbmi_space)
      {
      	if (strstr(s,"W"))
      		{gdbmi_size = 'w';gdbmi_apl = 4;}
      	else if (strstr(s,"B"))
      		{gdbmi_size = 'b';gdbmi_apl = 4;} /* do 2 bytes at a time */
      	else if (strstr(s,"H"))
      		{gdbmi_size = 'h';gdbmi_apl = 8;}
      	else if (strstr(s,"X")) gdbmi_format = 'x';
      	else if (strstr(s,"O")) gdbmi_format = 'o';
      	else if (strstr(s,"D")) gdbmi_format = 'd';
      	++s;
      }

      /* Get linear address */
      gdbmi_addr = DbgLinearAddrFromAddrStr(++gdbmi_space);

      if ((gdbmi_count > 0) && (gdbmi_addr != ~0))
      {
         /* Print first lead in address */
         printf("0x%07x:",gdbmi_addr);

         for(i=1;i<=gdbmi_count;i++)
         {
            //agc_addr = gdbmiNativeAddr(gdbmi_addr);
            gdbmi_value = DbgGetValueByAddress(gdbmi_addr);
            if (gdbmi_size == 'w')
            {
            	gdbmi_value = (gdbmi_value << 16) |
            			DbgGetValueByAddress(++gdbmi_addr);
            }

            switch (gdbmi_size)
            {
               case 'h':
                  printf("\t0x%04x",(unsigned short)gdbmi_value);
                  ++gdbmi_addr;
                  break;
               case 'b':
                  printf("\t0x%02x\t0x%02x",
                         (unsigned char)((gdbmi_value >> 8) & 0xff),
                         (unsigned char)(gdbmi_value & 0xff));
                  ++gdbmi_addr;
                  break;
               default:
                  printf("\t0x%08x",(unsigned)gdbmi_value);
                  ++gdbmi_addr;
                  break;
            }

            /* Do we need an address lead inprinted */
            if ((i % gdbmi_apl ) == 0 && i < gdbmi_count) printf("\n0x%07x:",gdbmi_addr);
         }
         printf("\n");
      }
      else printf("Invalid number \"%s\"\n",gdbmi_space);
   }
   return (GdbmiStat);
}

static GdbmiResult
GdbmiHandleGetOct(int i)
{
   CheckDec(s);
   return(GdbmiCmdDone);
}

static GdbmiResult
GdbmiHandleQuit(int i)
{
   return(GdbmiCmdQuit);
}

/**
 * GDB/MI Root Table of Commands and associated handlers.
 */
GdbmiCommands_t GdbmiConsoleRootCommands[33] =
{
   {"INFO ", GdbmiHandleInfo},
   {"SET ", GdbmiHandleSet},
   {"START", GdbmiHandleStart},
   {"SHOW", GdbmiHandleShow},
   {"BREAK", GdbmiHandleNormBrk},
   {"TBREAK", GdbmiHandleTmpBrk},
   {"PRINT", GdbmiHandlePrint},
   {"WHERE", GdbmiHandleBacktrace},
   {"BT", GdbmiHandleBacktrace},
   {"WATCH", GdbmiHandleWatch},
   {"DISASSEMBLE", GdbmiHandleDisassemble},
   {"DISAS", GdbmiHandleDisassemble},
   {"DEFINE", GdbmiHandleDefine},
   {"LIST", GdbmiHandleList},
   {"GETOCT", GdbmiHandleGetOct},
   {"WHATIS", GdbmiHandleWhatIs},
   {"OUTPUT", GdbmiHandleOutput},
   {"DUMP", GdbmiHandleDump},
   {"RESTORE", GdbmiHandleRestoreMemory},
   {"DELETE BREAKPOINTS", GdbmiHandleDelete},
   {"DELETE", GdbmiHandleDelete},
   {"DISABLE", GdbmiHandleDisable},
   {"ENABLE", GdbmiHandleEnable},
   {"QUIT", GdbmiHandleQuit},
   {"EXIT", GdbmiHandleQuit},
   {"CONT", GdbmiHandleRun},
   {"RUN", GdbmiHandleRun},
   {"P", GdbmiHandlePrint},
   {"B", GdbmiHandleNormBrk},
   {"D", GdbmiHandleDelete},
   {"X", GdbmiHandleExamine},
   {0,0}
};


static GdbmiResult
GdbmiConsoleInterpreter(int i)
{
   GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

   /* Adjust the CmdPtr to point to the next token */
   GdbmiAdjustCmdPtr(i);

   /* Ensure command s is in uppercase */
   GdbmiStringToUpper(s);

   /* Parse and Execute Commands */
   GdbmiStat = GdbmiParseConsoleCommands(GdbmiConsoleRootCommands);

   /* Special Case KDbg defined command hard coded for now */
   if (!strncmp(s,"KDBG_INFOLINEMAIN",17))
   {
      GdbmiHandleList(17);
      GdbmiStat = GdbmiHandleInfoLine(17);
   }
   else gdbmi_status = GdbmiCmdError;

   if (GdbmiStat == GdbmiCmdUnhandled) GdbmiStat = gdbmi_status;

   return(GdbmiStat);
}

static GdbmiResult
GdbmiHandleCustom(int i)
{
   char *arg_s,*arg_sraw;
   unsigned cmd_idx;
   unsigned arg_idx;

   for(cmd_idx=0;cmd_idx<GDBMI_MAX_CUSTOM_CMDS;cmd_idx++)
   {
      if (gdbmiCustomCmds[cmd_idx].Command)
      {
         if (strncmp(gdbmiCustomCmds[cmd_idx].Command,
             sraw,
             strlen(gdbmiCustomCmds[cmd_idx].Command)))
         {
            ++gdbmi_status;

            for(arg_idx=0;arg_idx<GDBMI_MAX_CUSTOM_ARGS;arg_idx++)
            {
               arg_sraw = gdbmiCustomCmds[cmd_idx].Arguments[arg_idx];
               if (arg_sraw)arg_s = strdup(arg_sraw);
               else break;

               if (arg_s)
               {
            	   GdbmiInterpreter(State,arg_s,arg_sraw);
                  free(arg_s);
               }
            }
            break;
         }
      }
   }

   return(GdbmiCmdDone);
}

/**
 * This function is the entry point for the high level GDBMI interaction
 * For now it is just a stub until the code will work with full GDB/MI
 */
GdbmiResult
GdbmiHandleMachineInterface(int i)
{
   return(GdbmiCmdUnhandled);
}

/**
 * This function is the main entry into the GDBMI command handler. It requires
 * the state of the AGC machine as well as the Command string and the raw
 * version of the command string.
 * \param a pointer to the AGC state machine
 * \param the command string
 * \param the raw command string
 */
GdbmiResult
GdbmiInterpreter(agc_t *agc_state , char* dbg_s, char* dbg_sraw)
{
   GdbmiResult GdbmiStat = GdbmiCmdUnhandled;

   /* Set the static GDBMI values and avoid passing around */
   State = agc_state;
   s     = dbg_s;
   sraw  = dbg_sraw;

   /* Handle Basic GDB Command Line Options */
   GdbmiStat = GdbmiConsoleInterpreter(0);
   gdbmi_status = 0;

   /* Use the new GDB/MI Capabilities */
   if (GdbmiStat == GdbmiCmdUnhandled) GdbmiStat = GdbmiHandleMachineInterface(0);

   /* Executed Custom defined Debug Commands */
   if (GdbmiStat == GdbmiCmdUnhandled) GdbmiStat = GdbmiHandleCustom(0);

   if (GdbmiStat == GdbmiCmdUnhandled && gdbmi_status > 0)
	   GdbmiStat = GdbmiCmdDone;

   return(GdbmiStat);
}

