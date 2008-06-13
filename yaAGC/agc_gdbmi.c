#include <stdlib.h>
#include <stdio.h>
#include "yaAGC.h"
#include "agc_engine.h"
#include "agc_debug.h"
#include "agc_gdbmi.h"
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

extern char agcPrompt[16];
extern char nbPrompt[16];
extern int HaveSymbols;
extern int FullNameMode;
extern int Break;
extern int RunState;

static int gdbmi_break_id = 0;
static int gdbmi_status;
static int cli_argc;
static char* cli_arg;

static char FileName[MAX_FILE_LENGTH+1];
static char AW_s[257];

static CustomCommand_t gdbmiCustomCmds[32];

const char disp_keep[5] = "keep";
const char disp_delete[4] = "del";

static char * gdbmiBasename (const char *name)
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

void gdbmiDisassemble(agc_t *State,unsigned start_linear,unsigned end_linear)
{
   
}

Address_t gdbmiNativeAddr(unsigned linear_addr)
{
   Address_t agc_addr;

   if (linear_addr > 0117777)
   {
      agc_addr.Invalid = 1;
      agc_addr.Address = 0;
   }
   else if (linear_addr > 07777) /* Must be Common Fixed */
   {
      agc_addr.Banked = 1;
      agc_addr.Unbanked = 0;
      agc_addr.Address = 1;
      agc_addr.Invalid = 0;
      agc_addr.Fixed = 1;
      agc_addr.Erasable = 0;
      agc_addr.FB = (linear_addr - 010000)/02000;
      agc_addr.SReg = (linear_addr - agc_addr.FB * 02000) - 06000;
      if ( agc_addr.FB > 037) /* Do we need to set the Extension Bit */
      {
        agc_addr.FB = agc_addr.FB - 010;
        agc_addr.Super = 01;
      }
      else agc_addr.Super = 0;
   }
   else if (linear_addr > 03777) /* Must be Fixed Fixed */
   {
      agc_addr.Banked = 0;
      agc_addr.Unbanked = 1;
      agc_addr.Address = 1;
      agc_addr.Invalid = 0;
      agc_addr.Fixed = 1;
      agc_addr.Erasable = 0;
      agc_addr.FB = linear_addr/02000; /* Allows for faster Value access later */
      agc_addr.Super = 0;
      agc_addr.SReg = linear_addr;
   }
   else /* Map to Eraseable memory */
   {
      agc_addr.Banked = 1;
      agc_addr.Unbanked = 0;
      agc_addr.Address = 1;
      agc_addr.Invalid = 0;
      agc_addr.Fixed = 0;
      agc_addr.Erasable = 1;
      agc_addr.EB = linear_addr/0400; /* Allows for faster Value access later */
      agc_addr.SReg = linear_addr - agc_addr.EB * 0400 + 01400;
   }
   return agc_addr;
}


/**
 * Return the Virtual Linear Pseudo address. According to
 * AGC Memo #9 page 5. with the exception of Fixed banked
 * 02 and 03; I kept linear address 014000-017777 this
 * whay you can still notice you were dealing with a banked
 * address. However the value for address 04000 and 14000
 * will give you the same result.
 */
unsigned gdbmiLinearAddr(Address_t *agc_addr)
{
   unsigned gdbmi_addr = 0;

   if (agc_addr->SReg < 01400) /* Must be Unbanked Eraseable */
   {
      gdbmi_addr = agc_addr->SReg;
   }
   else if (agc_addr->SReg < 02000) /* Must be  Banked Eraseable */
   {
      gdbmi_addr = agc_addr->EB*0400 + agc_addr->SReg - 01400;
   }
   else if (agc_addr->SReg < 04000) /* Must be Banked fixed memory */
   {
      gdbmi_addr = 06000 + (agc_addr->FB + agc_addr->Super*010) * 02000 + agc_addr->SReg;
   }
   else if (agc_addr->SReg < 07777) /* Must be fixed fixed */
   {
      gdbmi_addr = agc_addr->SReg;
   }
   else /* Invalid Address */
   {
      gdbmi_addr = 0xffff;
   }
   
   return gdbmi_addr;
}

unsigned gdbmiLinearFixedAddr(unsigned agc_sreg,unsigned agc_fb,unsigned agc_super)
{
   Address_t agc_addr;
   
   agc_addr.Fixed = 1;
   agc_addr.Unbanked = 1;
   agc_addr.SReg = agc_sreg;
   agc_addr.FB = agc_fb;
   agc_addr.Super = agc_super;
   
   return gdbmiLinearAddr(&agc_addr);
}

unsigned short gdbmiGetValueByAddress(agc_t *State, unsigned gdbmi_addr)
{
   Address_t agc_addr;
   unsigned short Value = 0;

   /* if in Eraseable use Eraseable value */
   agc_addr=gdbmiNativeAddr(gdbmi_addr);
   if (agc_addr.Erasable == 1)
   {
      Value = State->Erasable[agc_addr.EB][agc_addr.SReg - 01400];
   }
   else /* Must be fixed memory */
   {
      if (agc_addr.Unbanked == 1) /* Check for Fixed Fixed */
      {
         /* remember the FB should already be fine (see gdbmiNativeAddr */
         Value = State->Fixed[agc_addr.FB][agc_addr.SReg - 04000];
      }
      else /* This is Common Fixed */
      {
         Value = State->Fixed[agc_addr.FB + agc_addr.Super*010][agc_addr.SReg - 02000];
      }
   }

   return Value;
}

void gdbmiSetValueByAddress(agc_t *State,unsigned gdbmi_addr,unsigned short value)
{
	Address_t agc_addr;
	agc_addr = gdbmiNativeAddr(gdbmi_addr);

   if (agc_addr.Erasable == 1)
   {
      State->Erasable[agc_addr.EB][agc_addr.SReg - 01400] = value;
   }
   else /* Must be fixed memory */
   {
      if (agc_addr.Unbanked == 1) /* Check for Fixed Fixed */
      {
         /* remember the FB should already be fine (see gdbmiNativeAddr */
        State->Fixed[agc_addr.FB][agc_addr.SReg - 04000] = value;
      }
      else /* This is Common Fixed */
      {
        State->Fixed[agc_addr.FB+agc_addr.Super*010][agc_addr.SReg-02000]=value;
      }
   }	
}

char* gdbmiConstructFuncName(Address_t* agc_addr,char* s)
{
   if (agc_addr->Banked == 1)
   { 
       sprintf(s,"<%02o+%04o>",
               agc_addr->FB+8*agc_addr->Super,
               agc_addr->SReg);
   }
   else
   {
     sprintf(s,"<XX+%04o>",agc_addr->SReg);
   }
   
   return s;
}

int gdbmiCheckBreakpoint(agc_t *State, Breakpoint_t* gdbmi_bp)
{
   int Result = 0;
   
   if (gdbmi_bp->Enable == 'y') Result = 1;
   
   return Result;
}

void gdbmiUpdateBreakpoint(agc_t *State, Breakpoint_t* gdbmi_bp)
{
   char s[5];
   
   gdbmi_bp->Hits++;
   
   if (gdbmi_bp->Disposition == BP_DELETE)
      sprintf(s," %d",gdbmi_bp->Id);
      gdbmiHandleDelete(State,s,s);
}

/* Hanlde the break GDB/CLI command */
void gdbmiHandleBreak(agc_t *State , char* s, char* sraw,char disp)
{
   int j, k, i, vRegBB, LineNumber;
   Symbol_t *Symbol = NULL;
   SymbolLine_t *Line = NULL;
   char Garbage[81], SymbolName[MAX_LABEL_LENGTH + 1],*cli_char;
   unsigned gdbmiAddress = 0;
   Address_t agc_addr;
   char* p;
   

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
      

      /* If fullpath name is given remove that since symtab only stores that once
       * in the symbol file (i.e. SourcePathName) */
//      if (!strncmp(sraw,SourcePathName,strlen(SourcePathName)))
//      {
//         sraw+=strlen(SourcePathName)+1;
//         s+=strlen(SourcePathName)+1;
//      }
			sraw = gdbmiBasename(sraw);
			s=gdbmiBasename(s);

   	/* First replace ":" with space */
   	if (cli_char = strstr(sraw,":")) *cli_char = ' '; /* replace colon with space */
     
      if (HaveSymbols && 
         (2 == sscanf (sraw, "%s %d", &FileName, &LineNumber)) &&
         (Line = (SymbolLine_t*) ResolveFileLineNumber(FileName, LineNumber)))
      {
         gdbmiAddress = gdbmiLinearAddr(&Line->CodeAddress);
       
      }
      else if (HaveSymbols && (1 == sscanf (s, "%d", &LineNumber)) &&
             (Line = ResolveLineNumber (LineNumber)))
      {
          gdbmiAddress = gdbmiLinearAddr(&Line->CodeAddress);
       
      }
      else if (HaveSymbols && (1 == sscanf (s, "%s", SymbolName)) &&
             (Symbol = ResolveSymbol (SymbolName, SYMBOL_LABEL)))
      {
         gdbmiAddress = gdbmiLinearAddr(&Symbol->Value);
      }
      else if (1 == sscanf (s, "*0X%x", &gdbmiAddress));
      else
      {
         /* Insert error message not help */
         printf ("Illegal syntax for break.\n");
         return;
      }
   }
   else /* Default Break point is current address */
   {
      gdbmiAddress = gdbmiLinearFixedAddr(
             State->Erasable[0][RegZ] & 07777,
             037 & (State->Erasable[0][RegBB] >> 10),
             (State->OutputChannel7 & 0100) ? 1 : 0);
   }
   
   if (gdbmiAddress < 04000)
   {
      printf ("Line number points to erasable memory.\n");
      return;
   }

   agc_addr = gdbmiNativeAddr(gdbmiAddress);
   vRegBB = ((agc_addr.FB << 10) | (agc_addr.Super << 7));
   
   if (Line == NULL)
      Line = ResolveLineAGC (agc_addr.SReg,agc_addr.FB,agc_addr.Super);
   
   for (i = 0; i < NumBreakpoints; i++)
      if (Breakpoints[i].Address12 == agc_addr.SReg && Breakpoints[i].vRegBB == vRegBB &&
          Breakpoints[i].WatchBreak == 0)
   {
      printf ("This breakpoint already exists.\n");
      return;
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
   ++gdbmi_status;
}

void gdbmiHandleWatch (agc_t * State, char *s, char* sraw)
{
   int j, k, i, vRegBB, WatchType, WatchValue = 0777777;
   Symbol_t *Symbol = NULL;
   char *ss;
   unsigned gdbmi_address;
   Address_t agc_addr;

   if (strlen(sraw))
      Symbol = ResolveSymbol(sraw, SYMBOL_VARIABLE | SYMBOL_REGISTER | SYMBOL_CONSTANT);
   
   if (Symbol != NULL && !Symbol->Value.Erasable) Symbol = NULL;
   if (Symbol != NULL)
   {
      /* Get linear address for display */
      gdbmi_address = gdbmiLinearAddr(&Symbol->Value);

      /* Watch Type 3 = for value, Watch type 1 for any change */
      agc_addr = gdbmiNativeAddr(gdbmi_address); 
   
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
      return;
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
               GetWatch (State, &Breakpoints[NumBreakpoints]);
      else
         Breakpoints[NumBreakpoints].WatchValue = WatchValue;
      NumBreakpoints++;
      if (Symbol) 
         printf ("Hardware watchpoint %d: %s\n",gdbmi_break_id,Symbol->Name);
   }
   else
      printf ("The maximum number of watchpoints is already defined.\n");
   
   ++gdbmi_status;
}

void gdbmiHandleShowVersion()
{
   printf ("Apollo Guidance Computer simulation, ver. " NVER ", built "
         __DATE__ " " __TIME__ "\n" "Copyright (C) 2003-2005,2007 Ronald S. Burkey.\n"
         "yaAGC is free software, covered by the GNU General Public License, and you are\n"
         "welcome to change it and/or distribute copies of it under certain conditions.\n"
          );
   printf ("Refer to http://www.ibiblio.org/apollo/index.html for additional information.\n");

   ++gdbmi_status;
}


void gdbmiHandleInfoRegisters(agc_t *State , char* s, char* sraw)
{
  
   int cli_argc = 0;
   if (strlen(s)>1)
   {
      cli_argc++;
      cli_arg = ++s;
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

   ++gdbmi_status;
}

void gdbmiHandleInfoBreakpoints(agc_t *State , char* s, char* sraw)
{
   int i;
   unsigned gdbmiAddress=0;
   char* disposition;
   
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
            printf ("0x%04x", gdbmiLinearFixedAddr(Address12,0,0));
         else if (Address12 >= 02000 && Address12 < 04000)
         {
            int Bank;
            Bank = (vRegBB >> 10) & 037;
            if (0 != (vRegBB & 0100) && Bank >= 030) Bank += 010;
            printf ("0x%04x", gdbmiLinearFixedAddr(Address12,Bank,0));
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
   ++gdbmi_status;
}

void gdbmiPrintFullNameContents(SymbolLine_t *Line)
{
   /* Need OS Seperator */
#ifdef WIN32
   printf("\032\032%s\\%s:%d:%d:beg:0x%04x\n",SourcePathName,
          Line->FileName, Line->LineNumber,Line->LineNumber,
          gdbmiLinearFixedAddr(Line->CodeAddress.SReg,
                               Line->CodeAddress.FB,
                               Line->CodeAddress.Super)); 
#else
   printf("\032\032%s/%s:%d:%d:beg:0x%04x\n",SourcePathName,
          Line->FileName, Line->LineNumber,Line->LineNumber,
          gdbmiLinearFixedAddr(Line->CodeAddress.SReg,
                               Line->CodeAddress.FB,
                               Line->CodeAddress.Super));
#endif
}

void gdbmiHandleInfoLine(agc_t *State , char* s, char* sraw)
{
   int LineNumber;
   SymbolLine_t *Line = NULL;
   char *cli_char = NULL;
   
   if (*s == ' ')
   {
      cli_char = strstr(sraw,":");
      *cli_char = ' ';
      
      if (2 == sscanf (sraw+1, "%s %d", &FileName, &LineNumber))
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
      printf("Line %d of \"%s\" starts at address 0x%04x <_%05o>\n",
             Line->LineNumber,Line->FileName,
             gdbmiLinearAddr(&Line->CodeAddress),Line->CodeAddress.SReg);
      printf("   and ends at 0x%04x <_%05o>.\n",
             gdbmiLinearAddr(&Line->CodeAddress),Line->CodeAddress.SReg);
      if (FullNameMode) gdbmiPrintFullNameContents(Line);
   }
   ++gdbmi_status;
}

void gdbmiHandleInfoTarget(agc_t *State , char* s, char* sraw)
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
   ++gdbmi_status;
}

void gdbmiHandleInfoChannels(agc_t *State , char* s, char* sraw)
{
	int chx;
	unsigned value;
	int select = -1;
	
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

void gdbmiHandleInfoIoRegisters(agc_t *State , char* s, char* sraw)
{
	int io_select = 0;
	int i;
	unsigned value;

	if (strlen(s++) > 1) io_select = 1;
	
	for (i=0;i< NUM_IO_REGS;i++)
	{
		if (io_select == 0 || !strcmp(s,io_registers[i].name))
		{
			value = 0177777 & State->Erasable[0][io_registers[i].offset];
			printf("%s\t\t0x%04x\t%u\n",io_registers[i].name,value,value);
		}
	}
}

void gdbmiHandleInfoAllRegisters(agc_t *State , char* s, char* sraw)
{
	gdbmiHandleInfoRegisters(State,s,sraw);
	gdbmiHandleInfoIoRegisters(State,s,sraw);
}

void gdbmiHandleInfoProgram(agc_t *State , char* s, char* sraw)
{
   printf("\tUsing the running image of child process 0.\n");
   printf("Program stopped at 0x%04x.\n",gdbmiLinearFixedAddr(
          State->Erasable[0][RegZ] & 07777,
          037 & (State->Erasable[0][RegBB] >> 10),
                 (State->OutputChannel7 & 0100) ? 1 : 0));
   printf("It stopped after being stepped.\n");
}

void gdbmiHandleInfo(agc_t *State , char* s, char* sraw)
{
   if (!strncmp (s, "ALL-REGISTERS",13)) 
      gdbmiHandleInfoAllRegisters(State,s+13,sraw+13);
   else if (!strncmp (s, "REGISTERS",9))
      gdbmiHandleInfoRegisters(State,s+9,sraw+9);
   else if (!strcmp (s, "BREAKPOINTS"))
      gdbmiHandleInfoBreakpoints(State,s,sraw);
   else if (!strncmp (s, "LINE",4))
      gdbmiHandleInfoLine(State,s+4,sraw+4);
   else if (!strncmp (s, "TARGET",6))
      gdbmiHandleInfoTarget(State,s+6,sraw+6);
   else if (!strncmp (s, "FILES",6))
      gdbmiHandleInfoTarget(State,s+6,sraw+6);
   else if (!strncmp (s, "CHANNELS",8))
      gdbmiHandleInfoChannels(State,s+8,sraw+8);
   else if (!strncmp (s, "IO_REGISTERS",12))
      gdbmiHandleInfoIoRegisters(State,s+12,sraw+12);
   else if (!strncmp (s, "PROGRAM",7))
      gdbmiHandleInfoProgram(State,s+7,sraw+7);
}

void gdbmiHandleSetPrompt(agc_t *State , char* s, char* sraw)
{
   strncpy(agcPrompt,sraw,15);
   strncpy(nbPrompt,agcPrompt,15);
   ++gdbmi_status;
}

int gdbmiString2Num(char* s, int* Num)
{
	int Result = -1;
	
	if (1 == sscanf (s, "0X%x",Num)) Result = 0;
	else if (1 == sscanf (s, "0%o",Num)) Result = 0;
	else if (1 == sscanf (s, "%d",Num)) Result = 0;
	return Result;
}
	

/** This function parses the expression for setting a value in memory
 */
void gdbmiHandleSetVariable(agc_t *State , char* s, char* sraw)
{
	int gdbmi_addr,gdbmi_val;
	char *operand1,*operand2;
   Symbol_t *Symbol = NULL;
	
	operand1 = s;
	operand2 = strstr(s,"=");
	*operand2 = (char)0;
	operand2++;
	
	/* Set value using address */
	if (operand1[0] == '*')
	{
		if (gdbmiString2Num(++operand1,&gdbmi_addr) == 0)
			if (gdbmiString2Num(operand2,&gdbmi_val) == 0)
				gdbmiSetValueByAddress(State,gdbmi_addr,(unsigned short)gdbmi_val);
	}
	else /* Must be a symbol */
	{
      Symbol = ResolveSymbol(operand1, SYMBOL_VARIABLE);
   	if (Symbol != NULL && 
   		!Symbol->Value.Erasable) Symbol = NULL;
   	
 	   if (Symbol != NULL)
   	{
     		/* Get linear address for display */
     		gdbmi_addr = gdbmiLinearAddr(&Symbol->Value);
			if (gdbmiString2Num(operand2,&gdbmi_val) == 0)
				gdbmiSetValueByAddress(State,gdbmi_addr,(unsigned short)gdbmi_val);
		}
	}
   ++gdbmi_status;
}

void gdbmiHandleSet(agc_t *State , char* s, char* sraw)
{
   if (!strncmp(s, "PROMPT ",7)) 
      gdbmiHandleSetPrompt(State,s+7,sraw+7);
   else if (!strncmp(s, "CONFIRM ",8)); /* Ignore for now */
   else if (!strncmp(s, "WIDTH ",6)); /* Ignore for now */
   else if (!strncmp(s, "HEIGHT ",7)); /* Ignore for now */   
   else if (!strncmp(s, "BREAKPOINT ",11)); /* Ignore for now */   
   else if (!strncmp(s, "PRINT ",6)); /* Ignore for now */   
   else if (!strncmp(s, "UNWINDONSIGNAL ",15)); /* Ignore for now */   
   else if (!strncmp(s, "DISASSEMBLY-FLAVOR ",19)); /* Ignore for now */   
   else if (!strncmp(s, "DEBUGEVENTS ",12)); /* Ignore for now */   
   else if (!strncmp(s, "VARIABLE ",9))
   	gdbmiHandleSetVariable(State,s+9,sraw+9);
   else 
  	gdbmiHandleSetVariable(State,s,sraw);
  		
   ++gdbmi_status;
}


void gdbmiHandleDisassemble(agc_t *State , char* s, char* sraw)
{
   unsigned gdbmiFromAddr,gdbmiToAddr;
   Address_t agc_addr;
   char funcname[10];
    
   if (*sraw == ' ')
   {      
      if (2 == sscanf (sraw+1, "0x%x 0x%x", &gdbmiFromAddr, &gdbmiToAddr))
      {
         while (gdbmiFromAddr <= gdbmiToAddr)
         {
            agc_addr = gdbmiNativeAddr(gdbmiFromAddr);
            printf("0x%04x %s:\t0x%04x\n",
                    gdbmiFromAddr,
                    gdbmiConstructFuncName(&agc_addr,funcname),
                    gdbmiGetValueByAddress(State,gdbmiFromAddr));
            ++gdbmiFromAddr;
         }
      }
   }
}

void gdbmiHandleDefine(agc_t *State , char* s, char* sraw)
{
   char* gdbmi_custom;
   char gdbmi_element[256];
   unsigned cmd_idx;
   unsigned arg_idx;
   
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
   ++gdbmi_status;
}

void gdbmiHandleList(agc_t *State , char* s, char* sraw)
{
   ListSource (NULL, -1);
   ++gdbmi_status;
}

void gdbmiHandleBacktrace(agc_t *State , char* s, char* sraw)
{
   BacktraceDisplay(State);
   ++gdbmi_status;
}

void gdbmiHandleDelete(agc_t *State , char* s, char* sraw)
{
   int gdbmi_breakpoint = 0;
   int i,j;
   
   if (strlen(s) == 0) NumBreakpoints = 0;
   else
   {
      s++;
      sraw++;
      if (1 == sscanf (s, "%d", &gdbmi_breakpoint))
      {
         for (i = 0; i < NumBreakpoints; i++)
            if (Breakpoints[i].Id == gdbmi_breakpoint)
            {
                  NumBreakpoints--;
                  for (j = i; j < NumBreakpoints; j++)
                  {
                     Breakpoints[j] = Breakpoints[j + 1];
                  }
                  //i--;
                  break;
            }
      }
   }
   ++gdbmi_status;
}


void gdbmiHandleDisable(agc_t *State , char* s, char* sraw)
{
   int gdbmi_breakpoint = 0;
   int i,j;

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
   ++gdbmi_status;
}

void gdbmiHandleEnable(agc_t *State , char* s, char* sraw)
{
   int gdbmi_breakpoint = 0;
   int i,j;

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
   ++gdbmi_status;
}

void gdbmiHandleDumpMemory(agc_t *State , char* s, char* sraw)
{
   unsigned start_addr,end_addr,gdbmi_addr;
   unsigned short value;
   char filename[256];
   FILE* target;
   
   if (3 == sscanf (sraw, "%s 0x%x 0x%x", &filename,&start_addr,&end_addr))
   {
      if (end_addr >= start_addr && start_addr >= 0 && end_addr < 0114000)
      {
         target = fopen(filename,"w");
         if (target != NULL)
         {
            for (gdbmi_addr=start_addr;gdbmi_addr<=end_addr;gdbmi_addr++)
            {
               value = gdbmiGetValueByAddress(State,gdbmi_addr);
               fwrite(&value,2,1,target);
            }
            fclose(target);
         }
      }
   }
   ++gdbmi_status;
}

void gdbmiHandleRestoreMemory(agc_t *State , char* s, char* sraw)
{
   unsigned start_addr,end_addr,gdbmi_addr;
   unsigned short value;
   char filename[256];
   FILE* source;
   
   end_addr = 0114000;
   if (3 >= sscanf (sraw, "%s 0x%x 0x%x", &filename,&start_addr,&end_addr))
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
               gdbmiSetValueByAddress(State,gdbmi_addr++,value);
            }
            fclose(source);
         }
      }
   }
   ++gdbmi_status;
}


void gdbmiHandleDump(agc_t *State , char* s, char* sraw)
{
   if (!strncmp(s,"MEMORY ",7))
        gdbmiHandleDumpMemory(State,s+7,sraw+7);
}

void gdbmiHandleShow(agc_t *State , char* s, char* sraw)
{
  if (!strncmp(s," VERSION",8))
         gdbmiHandleShowVersion(State,s+8,sraw+8);
}

void gdbmiHandleStart(agc_t *State , char* s, char* sraw)
{
   RunState = 1;
   ++gdbmi_status;
}


void gdbmiHandleWhatIs(agc_t *State , char* s, char* sraw)
{
   /* All types will be considered unsigned */
   printf("type = unsigned\n");
   ++gdbmi_status;
}


void gdbmiHandlePrint(agc_t *State , char* s, char* sraw)
{
   int AddrFlag = 0;
   char* SymbolName;
   Symbol_t *Symbol = NULL;
   Address_t *agc_addr;
   unsigned gdbmi_addr;

   if (strlen(s) > 1)
   {
      /* we have an expression */
      SymbolName = ++sraw;
      if (*SymbolName == '&')
      {
      	 AddrFlag++;
      	 SymbolName++;
      }
      
      /* I like to also see values of constants eventhough the default 
         agc implementation did not do  this */
      if (Symbol = ResolveSymbol(SymbolName, SYMBOL_VARIABLE | SYMBOL_REGISTER | SYMBOL_CONSTANT))
      {
         agc_addr = &Symbol->Value;
         gdbmi_addr = gdbmiLinearAddr(agc_addr);
         
         if (AddrFlag)
         	printf("$1 = 0x%x\n",gdbmi_addr);
         else
         	printf("$1 = %d\n",gdbmiGetValueByAddress(State,gdbmi_addr));
      }
   }
   ++gdbmi_status;
}

void gdbmiHandleOutput(agc_t *State , char* s, char* sraw)
{
   int AddrFlag = 0;
   char* SymbolName;
   Symbol_t *Symbol = NULL;
   Address_t *agc_addr;
   unsigned gdbmi_addr;

   if (strlen(s) > 1)
   {
      /* we have an expression */
      SymbolName = ++sraw;
      if (*SymbolName == '&')
      {
         AddrFlag++;
         SymbolName++;
      }
      
      /* I like to also see values of constants eventhough the default 
      agc implementation did not do  this */
      if (Symbol = ResolveSymbol(SymbolName, SYMBOL_VARIABLE | SYMBOL_REGISTER | SYMBOL_CONSTANT))
      {
         agc_addr = &Symbol->Value;
         gdbmi_addr = gdbmiLinearAddr(agc_addr);
         
         if (AddrFlag)
            printf("0x%x",gdbmi_addr);
         else
            printf("%d",gdbmiGetValueByAddress(State,gdbmi_addr));
      }
   }
   ++gdbmi_status;
}

void gdbmiHandleExamine(agc_t *State , char* s, char* sraw)
{
   int i;
   int gdbmi_count = 1; /* Default 1 count */
   int gdbmi_addr = 0;
   int gdbmi_value = 0;
   char gdbmi_format = 'x';
   char gdbmi_size = 'w';
   char* gdbmi_space = NULL;
   char* gdbmi_addr_str = NULL;
   int gdbmi_apl = 4; /* default 8 addresses per line */ 
   Address_t agc_addr;
   
   /* Do we see arguments */
   if (strlen(s) > 1)
   {
      /* Is there a format Specifier */
      if (s = strstr(s,"/"))
      {
         gdbmi_count = (int)strtol(++s,&s,0);
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
		gdbmi_addr = strtol(gdbmi_space+1,0,0);

		if (gdbmi_count)
      {
         /* Print first lead in addess */
         printf("0x%07x:",gdbmi_addr);
         
         for(i=1;i<=gdbmi_count;i++)
         {  
            //agc_addr = gdbmiNativeAddr(gdbmi_addr);
            gdbmi_value = gdbmiGetValueByAddress(State,gdbmi_addr);
            if (gdbmi_size == 'w')
            {
            	gdbmi_value = (gdbmi_value << 16) | 
            			gdbmiGetValueByAddress(State,++gdbmi_addr);
            } 
            
            switch (gdbmi_size)
            {
               case 'h':
                  printf("\t0x%04x",(unsigned short)gdbmi_value);
                  gdbmi_addr++;
                  break;
               case 'b':
                  printf("\t0x%02x\t0x%02x",
                         (unsigned char)((gdbmi_value >> 8) & 0xff),
                         (unsigned char)(gdbmi_value & 0xff));
                  gdbmi_addr++;
                  break;
               default:
                  printf("\t0x%08x",(unsigned)gdbmi_value);
                  gdbmi_addr++;
                  break;
            }
   
            /* Do we need an address lead inprinted */
            if ((i % gdbmi_apl ) == 0 && i < gdbmi_count) printf("\n0x%07x:",gdbmi_addr);
         }
         printf("\n");
      }
   }
   ++gdbmi_status;
}


static void gdbmiHandleCommandLineInterface(agc_t *State , char* s, char* r)
{
   cli_argc = 0;
   cli_arg = NULL;
   char *ss;
   
   /* Ensure command s is in uppercase */
   for (ss = s; *ss; *ss = toupper (*ss), ss++);

        if (!strncmp(s,"INFO ",5)) gdbmiHandleInfo(State,s+5,r+5);
   else if (!strncmp(s,"SET ",4)) gdbmiHandleSet(State,s+4,r+4);
   else if (!strncmp(s,"START",5)) gdbmiHandleStart(State,s+5,r+5);
   else if (!strncmp(s,"SHOW",4)) gdbmiHandleShow(State,s+4,r+4);
   else if (!strncmp(s,"BREAK",5)) gdbmiHandleBreak(State,s+5,r+5,BP_KEEP);
   else if (!strncmp(s,"TBREAK",6)) gdbmiHandleBreak(State,s+6,r+6,BP_DELETE);
   else if (!strncmp(s,"WATCH ",6)) gdbmiHandleWatch(State,s+6,r+6);
   else if (!strncmp(s,"DISASSEMBLE",11)) gdbmiHandleDisassemble(State,s+11,r+11);
   else if (!strncmp(s,"DEFINE ",7)) gdbmiHandleDefine(State,s+7,r+7);
   else if (!strncmp(s,"LIST ",4)) gdbmiHandleList(State,s+4,r+4);
   else if (!strncmp(s,"WHERE",5)) gdbmiHandleBacktrace(State,s+5,r+5);
   else if (!strncmp(s,"WHATIS",6)) gdbmiHandleWhatIs(State,s+6,r+6);
   else if (!strncmp(s,"BT",2)) gdbmiHandleBacktrace(State,s+2,r+2);
   else if (!strncmp(s,"PRINT",5)) gdbmiHandlePrint(State,s+5,r+5);
   else if (!strncmp(s,"OUTPUT",6)) gdbmiHandleOutput(State,s+6,r+6);
   else if (!strncmp(s,"DUMP ",5)) gdbmiHandleDump(State,s+5,r+5);
   else if (!strncmp(s,"RESTORE ",8)) gdbmiHandleRestoreMemory(State,s+8,r+8);
   else if (!strncmp(s,"DELETE BREAKPOINTS",18)) gdbmiHandleDelete(State,s+18,r+18);
   else if (!strncmp(s,"DELETE",6)) gdbmiHandleDelete(State,s+6,r+6);
   else if (!strncmp(s,"DISABLE ",8)) gdbmiHandleDisable(State,s+8,r+8);
   else if (!strncmp(s,"ENABLE ",7)) gdbmiHandleEnable(State,s+7,r+7);
   else if (!strncmp(s,"P",1)) gdbmiHandlePrint(State,s+1,r+1);
   else if (!strncmp(s,"B",1)) gdbmiHandleBreak(State,s+1,r+1,BP_KEEP);
   else if (!strncmp(s,"D",6)) gdbmiHandleDelete(State,s+1,r+1);
   else if (!strncmp(s,"X",1)) gdbmiHandleExamine(State,s+1,r+1);
   else if (!strncmp(s,"KDBG_INFOLINEMAIN",17))
   {
      gdbmiHandleList(State,s+17,r+17);
      gdbmiHandleInfoLine(State,s+17,r+17);
   }
}

static void gdbmiHandleCustom(agc_t *State , char* s, char* sraw)
{
   char *arg_s,*arg_sraw,*ss;
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
                  gdbmiHandleCommandLineInterface(State,arg_s,arg_sraw);
                  free(arg_s);
               }
            }
            break;
         }
      }
   }
}

void gdbmiHandleMachineInterface(agc_t *State , char* s, char* sraw)
{
}

int gdbmiHandleCommand(agc_t *State , char* s, char* sraw)
{
   gdbmi_status = 0;
   
   /* Handle Basic GDB Command Line Options */ 
   if (gdbmi_status == 0) gdbmiHandleCommandLineInterface(State,s,sraw);

   /* Use the new GDB/MI Capabilities */
   if (gdbmi_status == 0) gdbmiHandleMachineInterface(State,s,sraw);
   
   /* Execute Custom Commands */
   if (gdbmi_status == 0) gdbmiHandleCustom(State,s,sraw);

   return gdbmi_status;
}

