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

static int gdbmi_status;


static void gdbmiPrintHelpInfo()
{
	printf("info breakpoints -- Status of user-settable breakpoints\n");
	printf("info line -- Core addresses of the code for a source line\n");
	printf("info target -- Display target information\n");
   printf("info files -- Like \"info target\"\n");
	printf("info registers -- List of registers and contents\n");
	printf("info all-registers -- List of all registers and contents\n");
	printf("info channels -- List of channels and contents\n");	
	printf("info io_registers -- List of I/O registers and contents\n");
   printf("info threads -- IDs of currently known threads\n");
   printf("info stack -- Backtrace of the stack\n");
	printf("info interrupts -- Show active interrupt\n");
	printf("info source -- Information about the current source file\n");
	printf("info sources -- Source files in the program\n");
}

static void gdbmiPrintHelpShow()
{
   printf("show version -- Show what version of yaAGC this is\n");
}

static void gdbmiPrintHelpSet()
{
		printf("set prompt -- Set agc's prompt\n");				
		printf("set variable -- assign result to variable or address\n");				
}

static void gdbmiPrintHelpBreakpoints()
{
		printf("break -- Set breakpoint at specified line\n");				
		printf("delete -- Delete some breakpoints\n");				
		printf("tbreak -- Set a temporary breakpoint\n");
		printf("disable -- Disable some breakpoints\n");
		printf("enable -- Enable some breakpoints\n");
		printf("watch -- Set a watchpoint\n");
}

static void gdbmiPrintHelpData()
{
		printf("disassemble -- Disassemble a specified section of memory\n");				
		printf("inspect -- Same as \"print\" command\n");				
		printf("print -- Print value of expression EXP\n");
                printf("output -- Like \"print\" but no history and no newline\n");
		printf("x -- Examine memory: x/FMT ADDRESS\n");
}

static void gdbmiPrintHelpRunning()
{
		printf("step -- Step program until it reaches a different source line\n");				
		printf("next -- Step program\n");				
		printf("cont -- Continue program being debugged\n");
		printf("run -- Start debugged program\n");
		printf("quit -- Exit agc\n");
}

static void gdbmiPrintHelpFiles()
{
		printf("list -- List specified function or line\n");				
}

static void gdbmiPrintHelpStack()
{
		printf("bt -- Print backtrace of all stack frames\n");				
		printf("where -- Print backtrace of all stack frames\n");				
}

static void gdbmiPrintHelpObscure()
{
		printf("log -- Log instructions to a log file\n");				
		printf("getoct -- Converts EXP into octal value\n");
		printf("inton -- Set interrupt request\n");
		printf("intoff -- Clear interrupt request\n");			
}

static void gdbmiHandleHelpSet(char* s)
{
	printf("List of set subcommands:\n\n");
	gdbmiPrintHelpSet();
	printf("\n");
	gdbmi_status++;
}

static void gdbmiHandleHelpBreakpoints(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpBreakpoints();
	printf("\n");
	gdbmi_status++;
}

static void gdbmiHandleHelpData(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpData();
	printf("\n");
	gdbmi_status++;
}

static void gdbmiHandleHelpRunning(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpRunning();
	printf("\n");
	gdbmi_status++;
}

static void gdbmiHandleHelpInfo(char* s)
{
	printf("List of info subcommands:\n\n");
	gdbmiPrintHelpInfo();
	printf("\n");
	gdbmi_status++;
}

static void gdbmiHandleHelpFiles(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpFiles();
	printf("\n");
	gdbmi_status++;
}

static void gdbmiHandleHelpStack(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpStack();
	printf("\n");
	gdbmi_status++;
}

static void gdbmiHandleHelpObscure(char* s)
{
	printf("List of commands:\n\n");
	gdbmiPrintHelpObscure();
	printf("\n");
	gdbmi_status++;
}


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
	gdbmi_status++;
}

void gdbmiHandleHelpDefine(char* s)
{
printf("\
Define a new command name.  Command name is argument.\n\
Definition appears on following lines, one command per line.\n\
End with a line of just \"end\".\n\
");	
	gdbmi_status++;
}


/**
 * This function prints a summary of all commands supported with a short
 * synopsis.
 */
void gdbmiHandleHelpBreak(char* s)
{
	gdbmi_status++;
}


/** This function handles the basic help command and parses for arguments of 
 * help. If no arguments are found the default help information is printed.
 */
int gdbmiHandleHelp(char* s)
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
	else
	{
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
	}
}
/**
 * This is the main entry function to handle help related commands. Only the 
 * case insensitive command string is passed for parsing.
 */
int gdbmiHelp(char* s)
{
	gdbmi_status = 0;
	
	if (!strncmp(s,"HELP",4)) gdbmiHandleHelp(s+4);
	return gdbmi_status;	
}

