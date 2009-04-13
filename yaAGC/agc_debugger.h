/*
 * agc_debugger.h
 *
 *  Created on: Dec 2, 2008
 *      Author: MZ211D
 */

#ifndef AGC_DEBUGGER_H_
#define AGC_DEBUGGER_H_

#include "agc_cli.h"
#include "agc_debug.h"

#define MAX_FROMFILES 11

/* Time between checks for --debug keystrokes. */
#define KEYSTROKE_CHECK (sysconf (_SC_CLK_TCK) / 4)

#define MAX_BREAKPOINTS 256
#define PATTERN_SIZE 017777777
#define PAT "%08o"


typedef struct
{
	int RunState;
	int SingleStepCounter;
	int HaveSymbols;
	Options_t* Options;
	agc_t* State;
} Debugger_t;

typedef struct
{
	char* Name;
}Frame_t;

extern FILE *FromFiles[MAX_FROMFILES];
extern FILE *LogFile;
extern int NumFromFiles;
extern char agcPrompt[16];
extern int LogCount;

extern unsigned short DbgGetWatch (agc_t* State, Breakpoint_t * bp);
extern int DbgGetFromZ (agc_t * State);
extern int DbgInitialize(Options_t* Options,agc_t* State);
extern void DbgDisplayInnerFrame(void);
extern int DbgMonitorBreakpoints(void);
extern char* DbgNormalizeCmdString(char* s);
extern int DbgHasBreakEvent(void);
extern void DbgDisplayPrompt(void);
extern void DbgDisplayVersion(void);
extern int DbgExecute(void);
extern char* DbgGetCmdString(void);
extern Address_t DbgNativeAddr(unsigned linear_addr);
extern unsigned DbgLinearAddr(Address_t *agc_addr);
extern unsigned DbgLinearFixedAddr(unsigned agc_sreg,unsigned agc_fb,unsigned agc_super);
extern unsigned short DbgGetValueByAddress(unsigned gdbmi_addr);
extern void DbgSetValueByAddress(unsigned gdbmi_addr,unsigned short value);
extern void DbgSetRunState(void);
extern unsigned DbgLinearAddrFromAddrStr(char* addr_str);




#endif /* AGC_DEBUGGER_H_ */
