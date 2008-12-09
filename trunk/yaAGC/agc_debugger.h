/*
 * agc_debugger.h
 *
 *  Created on: Dec 2, 2008
 *      Author: MZ211D
 */

#ifndef AGC_DEBUGGER_H_
#define AGC_DEBUGGER_H_

typedef struct
{
	int RunState;
	int SingleStepCounter;
	int HaveSymbols;
	Options_t* Options;
	agc_t* State;
} Debugger_t;

extern int InitializeDebugger(Options_t* Options,agc_t* State);
extern void ExecuteDebugger(void);
extern void DisplayInnerStackFrame(void);
extern int MonitorBreakpoints(void);

#endif /* AGC_DEBUGGER_H_ */
