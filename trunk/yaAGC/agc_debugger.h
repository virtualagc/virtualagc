/*
 * agc_debugger.h
 *
 *  Created on: Dec 2, 2008
 *      Author: MZ211D
 */

#ifndef AGC_DEBUGGER_H_
#define AGC_DEBUGGER_H_

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

extern unsigned short DbgGetWatch (agc_t * State, Breakpoint_t * bp);
extern int DbgGetFromZ (agc_t * State);
extern int DbgInitialize(Options_t* Options,agc_t* State);
extern void DbgExecuteDebugger(void);
extern void DbgDisplayInnerFrame(void);
extern int DbgMonitorBreakpoints(void);
extern char* DbgNormalizeCmdString(char* s);
extern int DbgHasBreakEvent(void);
extern void DbgProcessLog(void);
extern void DbgDisplayPrompt(void);
char* DbgGetCmdString(void);

#endif /* AGC_DEBUGGER_H_ */
