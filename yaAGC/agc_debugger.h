/*
 * agc_debugger.h
 *
 *  Created on: Dec 2, 2008
 *      Author: MZ211D
 */

#ifndef AGC_DEBUGGER_H_
#define AGC_DEBUGGER_H_

#define MAX_FROMFILES 11

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
extern int NumFromFiles;

extern int DbgInitialize(Options_t* Options,agc_t* State);
extern void DbgExecuteDebugger(void);
extern void DbgDisplayInnerFrame(void);
extern int DbgMonitorBreakpoints(void);

#endif /* AGC_DEBUGGER_H_ */
