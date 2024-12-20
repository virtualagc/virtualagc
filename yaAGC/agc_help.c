#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#ifdef WIN32
#include <winsock2.h>
#include <windows.h>
#include <sys/time.h>
#define LB "\r\n"
#else
#include <time.h>
#include <sys/times.h>
#define LB ""
#endif
#include "agc_help.h"

#define gdbmiHelpDone() gdbmi_status++
static int gdbmi_status;



static void gdbmiPrintHelpInfo(void)
{
	printf("info breakpoints -- Status of user-settable breakpoints\n");
	printf("info constants -- All constants or those matching REGEXP\n");
	printf("info line -- Core addresses of the code for a source line\n");
	printf("info target -- Display target information\n");
	printf("info files -- Like \"info target\"\n");
	printf("info functions -- All functions or those matching REGEXP\n");
	printf("info registers -- List of registers and contents\n");
	printf("info all-registers -- List of all registers and contents\n");
	printf("info channels -- List of channels and contents\n");
	printf("info io_registers -- List of I/O registers and contents\n");
	printf("info threads -- IDs of currently known threads\n");
	printf("info interrupts -- Show active interrupt\n");
	printf("info source -- Information about the current source file\n");
	printf("info sources -- All source files or those matching REGEXP\n");
	printf("info stack -- Backtrace of the stack\n");
	printf("info variables -- All variables or those matching REGEXP\n");
}

static void gdbmiPrintHelpShow(void)
{
	printf("show version -- Show what version of yaAGC this is\n");
}

static void gdbmiPrintHelpSet(void)
{
	printf("set prompt -- Set agc's prompt\n");
	printf("set var -- assign value to variable or dereferenced address\n");
}

static void gdbmiPrintHelpBreakpoints(void)
{
	printf("break -- Set breakpoint at specified line\n");
	printf("delete -- Delete some breakpoints\n");
	printf("tbreak -- Set a temporary breakpoint\n");
	printf("disable -- Disable some breakpoints\n");
	printf("enable -- Enable some breakpoints\n");
	printf("watch -- Set a watchpoint\n");
}

static void gdbmiPrintHelpData(void)
{
	printf("disassemble -- Disassemble a specified section of memory\n");
	printf("inspect -- Same as \"print\" command\n");
	printf("print -- Print value of expression EXP\n");
	printf("output -- Like \"print\" but no history and no newline\n");
	printf("x -- Examine memory: x/FMT ADDRESS\n");
}

static void gdbmiPrintHelpRunning(void)
{
	printf("step -- Step program until it reaches a different source line\n");
	printf("next -- Step program\n");
	printf("cont -- Continue program being debugged\n");
	printf("run -- Start debugged program\n");
	printf("quit -- Exit agc\n");
}

static void gdbmiPrintHelpFiles(void)
{
	printf("list -- List specified function or line\n");
}

static void gdbmiPrintHelpStack(void)
{
	printf("bt -- Print backtrace of all stack frames\n");
	printf("where -- Print backtrace of all stack frames\n");
}

static void gdbmiPrintHelpObscure(void)
{
	printf("log -- Log instructions to a log file\n");
	printf("getoct -- Converts EXP into octal value\n");
	printf("inton -- Set interrupt request\n");
	printf("intoff -- Clear interrupt request\n");
}

static void gdbmiPrintHelpSetVar(char* s)
{
printf("\
Set the VAR to a value.\n\
VAR can be a symbol (e.g. MPAC) or a dereferenced ADDRESS.\n\
ADDRESS can be a pseudo linear address (e.g. 0x6c or 0154) or you can\n\
use the AGC native address format and specify the bank and octal value.\n\
\n\
Examples setting values for the Multi Purpose Accumulator:\n\
  set MPAC=9\n\
  set *0x6c=8\n\
  set *0154=7\n\
  set *E0,1554=6\n");
  gdbmiHelpDone();  
}

static void gdbmiHandleHelpSet(char* s)
{
	if (!strncmp(s," VAR",4)) gdbmiPrintHelpSetVar(s+4);
	else {
	  printf("List of set subcommands:\n\n");
	  gdbmiPrintHelpSet();
	  printf("\n");
	}
	gdbmiHelpDone();
}

static void gdbmiHandleHelpBreakpoints(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpBreakpoints();
	printf("\n");
	gdbmiHelpDone();
}

static void gdbmiHandleHelpData(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpData();
	printf("\n");
	gdbmiHelpDone();
}

static void gdbmiHandleHelpRunning(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpRunning();
	printf("\n");
	gdbmiHelpDone();
}

static void gdbmiHandleHelpInfo(char* s)
{
	printf("List of info subcommands:\n\n");
	gdbmiPrintHelpInfo();
	printf("\n");
	gdbmiHelpDone();
}

static void gdbmiHandleHelpFiles(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpFiles();
	printf("\n");
	gdbmiHelpDone();
}

static void gdbmiHandleHelpStack(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpStack();
	printf("\n");
	gdbmiHelpDone();
}
/*
static void gdbmiHandleHelpObscure(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpObscure();
	printf("\n");
	gdbmiHelpDone();
}
*/

/**
 * This function prints a summary of all commands supported with a short
 * synopsis.
 */
void gdbmiHandleHelpAll(char* s)
{
	gdbmiPrintHelpInfo();
	gdbmiPrintHelpSet();
	gdbmiPrintHelpBreakpoints();
	gdbmiPrintHelpData();
	gdbmiPrintHelpFiles();
	gdbmiPrintHelpRunning();
	gdbmiPrintHelpStack();
	gdbmiPrintHelpObscure();
        gdbmiPrintHelpShow();
	gdbmiHelpDone();
}

void gdbmiHandleHelpDefine(char* s)
{
printf("\
Define a new command name.  Command name is argument.\n\
Definition appears on following lines, one command per line.\n\
End with a line of just \"end\".\n\
");
  gdbmiHelpDone();
}

void gdbmiHandleHelpX(char* s)
{
printf("\
Examine memory: x/FMT ADDRESS.\n\
ADDRESS is an expression for the memory address to examine,\n\
which can be a pseudo linear address (e.g. 0x6c or 0154) or you can\n\
use the AGC native address format and specify the bank and octal value.\n\
FMT is a repeat count followed by a format letter and a size letter.\n\
Format letters are o(octal), x(hex), d(decimal)\n\
Size letters are b(byte), h(halfword), w(word).\n\
The specified number of objects of the specified size are printed\n\
according to the format.\n\
\n\
Defaults for format and size letters are those previously used.\n\
Default count is 1.  \n\
\n\
Examples to examine the Multi Purpose Accumulator:\n\
  x/1 E0,1554\n\
  x/1 0154\n\
  x/1 0x6c\n\
  x/1 &MPAC\n");
  gdbmiHelpDone();
}

void gdbmiHandleHelpPrint(char* s)
{
printf("\
Print the value of symbol EXP.\n\
EXP can be a symbol (e.g. MPAC or &MPAC) or a dereferenced ADDRESS.\n\
ADDRESS can be a pseudo linear address (e.g. 0x6c or 0154) or you can\n\
use the AGC native address format and specify the bank and octal value.\n\
\n\
EXP may be preceded with /FMT, where FMT is a format letter\n\
but no count or size letter (see \"x\" command). Without the \n\
format letter, the default is octal.\n\n\
Format letters are the usual\n\
(o)ctal, he(x)adecimal, (d)ecimal, (u)nsigned, (t)wo base (i.e. binary)\n\
and (f)loat. When decimal is selected yaAGC will use ones complement\n\
implementation.\n\n\
The AGC uses both Single Precision (SP) and (DP) instructions.\n\
To specify how to print the float number an extension is added to\n\
the FMT field to select the printing style. The printing style can be any\n\
of the \"NOUN SCALES AND FORMATS\" (e.g. K for time in 1/100 of a sec).\n\
In addition there is SP and DP for general single and double precision\n\
printing. To use the extension use \"print/f:<scalar_type>\n\
\n\
Examples of EXP with or without formatting:\n\
  print/d MPAC\n\
  print/x &MPAC\n\
  print *0x6c\n\
  print *0154\n\
  print *E0,1554\n\
  print/f:K TIME2\n\n\
");

  gdbmiHelpDone();
}

void gdbmiHandleHelpOutput(char* s)
{
printf("\
Like \"print\" but don't put in value history and don't print newline.\n\
This is useful in user-defined commands.\n\
");

  gdbmiHelpDone();
}

/**
 * This function prints a summary of all commands supported with a short
 * synopsis.
 */
void gdbmiHandleHelpBreak(char* s)
{
  gdbmiHelpDone();
}


/** This function handles the basic help command and parses for arguments of
 * help. If no arguments are found the default help information is printed.
 */
void gdbmiHandleHelp(char* s)
{
	if (!strncmp(s," ALL",4)) gdbmiHandleHelpAll(s+4);
	else if (!strncmp(s," INFO",5)) gdbmiHandleHelpInfo(s+5);
	else if (!strncmp(s," SET",4)) gdbmiHandleHelpSet(s+4);
	else if (!strncmp(s," BREAK",6)) gdbmiHandleHelpBreak(s+6);
	else if (!strncmp(s," BREAKPOINTS",12)) gdbmiHandleHelpBreakpoints(s+12);
	else if (!strncmp(s," DATA",5)) gdbmiHandleHelpData(s+5);
	else if (!strncmp(s," RUNNING",8)) gdbmiHandleHelpRunning(s+8);
	else if (!strncmp(s," FILES",6)) gdbmiHandleHelpFiles(s+6);
	else if (!strncmp(s," STACK",6)) gdbmiHandleHelpStack(s+6);
	else if (!strncmp(s," DEFINE",7)) gdbmiHandleHelpDefine(s+7);
	else if (!strncmp(s," X",2)) gdbmiHandleHelpX(s+2);
	else if (!strncmp(s," PRINT",6)) gdbmiHandleHelpPrint(s+6);
	else if (!strncmp(s," OUTPUT",7)) gdbmiHandleHelpOutput(s+7);
}
/**
 * This is the main entry function to handle help related commands. Only the
 * case insensitive command string is passed for parsing.
 */
int GdbmiHelp(char* s)
{
	gdbmi_status = 0;

	if (!strncmp(s,"HELP",4)) {
	  gdbmiHandleHelp(s+4);
	  if (gdbmi_status == 0) legacyHelp(s);
	  if (gdbmi_status == 0) {
printf("\
List of classes of commands:\n\n\
all -- List all commands\n\
breakpoints -- Making program stop at certain points\n\
data -- Examining data\n\
files -- Specifying and examining files\n\
running -- Running the program\n\
stack -- Examining the stack\n\
obscure -- Obscure features\n\n\
Type \"help\" followed by a class name for a list of commands in that class.\n\
Type \"help\" followed by command name for full documentation.\n\
Command name abbreviations are allowed if unambiguous.\n\
");
	  gdbmiHelpDone();
	  }
	}
	return gdbmi_status;
}

int legacyHelp(char* s)
{
	//gdbmi_status = 0;

	if (!strcmp (s, "HELP BACKTRACE"))
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
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP BACKTRACES"))
	{
	  printf ("\n"
		  "backtraces\n"
		  "\tDisplays the most recent backtrace points.\n" "\n");
	  gdbmiHelpDone();
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
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP BREAKPOINTS"))
	{
	  printf ("\n"
		  "breakpoints\n"
		  "\tList the defined breakpoints, watchpoints, and patterns.\n" "\n");
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP CONT"))
	{
	  printf ("\n"
		  "cont\n"
		  "\tContinue execution.  The program will continue executing\n"
		  "\tuntil a breakpoint is reached or, in Linux or (for versions\n"
		  "\t20040810 or later) Win32, until you hit the carriage-return\n"
		  "\tkey.\n" "\n");
	  gdbmiHelpDone();
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
	  gdbmiHelpDone();
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
	  gdbmiHelpDone();
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
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP EDIT"))
	{
	  printf ("\n"
			  "edit A V\n"
		  "\tChange value of memory location or i/o channel A to V.\n"
		  "\tIf an address requiring a bank number is used, but the \n"
		  "\tbank number is omitted, the bank number is taken from the\n"
		  "\tEB or FB register.\n" "\n");
	  gdbmiHelpDone();
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
		  "\tThe list is arbitrarily truncated after 25 files.\n");
	  gdbmiHelpDone();
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
	  gdbmiHelpDone();
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
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP INTERRUPTS"))
	{
	  printf ("\n"
		  "interrupts\n"
		  "\tDisplay the active interrupt-service requests.\n" "\n");
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP INTOFF"))
	{
	  printf ("\n"
		  "intoff N\n"
		  "\tClear interrupt-request N (1, 2, ..., 10).\n" "\n");
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP INTON"))
	{
	  printf ("\n"
		  "inton N\n"
		  "\tSet interrupt-request N (1, 2, ..., 10).\n" "\n");
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP LOG"))
	{
	  printf ("\n"
		  "log N\n"
		  "\tLog next N instructions to the file yaAGC.log.  The file\n"
		  "\tformat is very simple, and is only intended to be used\n"
		  "\tfor regression testing.\n" "\n");
	  gdbmiHelpDone();
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
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP MASKOFF"))
	{
	  printf ("\n"
		  "maskoff N\n"
		  "\tReset a mask within the debugger to re-allow interrupt\n"
		  "\tN (1, ..., 10).  If N=0, all interrupts are unmasked.\n"
		  "\tIn other words, this command undoes what the MASKON\n"
		  "\tcommand does.\n" "\n");
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP MASKON"))
	{
	  printf ("\n"
		  "maskon N\n"
		  "\tSet a mask within the debugger to disallow interrupt\n"
		  "\tN (1, ..., 10).  If N=0, all interrupts are masked.\n" "\n");
	  gdbmiHelpDone();
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
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP PRINT"))
	{
	  printf ("\n"
			  "print S\n"
		  "\tPrints out the value of the symbol S\n");
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP QUIT"))
	{
	  printf ("\n"
			  "quit (or exit)\n"
		  "\tEnd the program.\n" "\n");
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP STEP"))
	{
	  printf ("\n"
		  "step [N] (or next [N])\n"
		  "\tStep through N instructions.  If omitted, N defaults to 1.\n"
		  "\tYou can also use just the first letter, as shorthand.\n" "\n");
	  gdbmiHelpDone();
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
		  "\tThe list is arbitrarily truncated after 25 symbols.\n");
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP SYMBOL-FILE"))
	{
	  printf ("\n"
		  "symbol-file FILE\n"
		  "\tLoads the FILE as the symbol table\n" "\n");
	  gdbmiHelpDone();
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
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP VIEW"))
	{
	  printf ("\n"
		  "view A\n"
		  "\tThis is a variation of \"watch A\".  It differs only in that\n"
		  "\tit simply displays the values of variables as they change,\n"
		  "\trather than interrupting execution.\n");
	  gdbmiHelpDone();
	}
	else if (!strcmp (s, "HELP WHATIS"))
	{
	  printf ("\n"
		  "whatis S\n"
		  "\tPrints information about the symbol S\n" "\n");
	  gdbmiHelpDone();
	}

	return gdbmi_status;
}
