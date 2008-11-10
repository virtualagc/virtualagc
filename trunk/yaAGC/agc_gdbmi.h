#ifndef AGC_GDBMI_H
#define AGC_GDBMI_H

#include "agc_debug.h"

#define GDBMI_MAX_CUSTOM_CMDS 32
#define GDBMI_MAX_CUSTOM_ARGS 10

typedef struct
{
   char* Command;
   char* Arguments[GDBMI_MAX_CUSTOM_ARGS];
} CustomCommand_t;

/**
 * typde definiyion to tell the simulator what action to take
 */
typedef enum
{
	gdbmiCmdUnhandled,
	gdbmiCmdError,
	gdbmiCmdDone,
	gdbmiCmdNext,
	gdbmiCmdStep,
	gdbmiCmdContinue,
	gdbmiCmdRun,
	gdbmiCmdQuit = 0xfe,
} gdbmiResult;


extern gdbmiResult gdbmiHandleCommand(agc_t* , char*, char* );
extern void gdbmiPrintFullNameContents(SymbolLine_t *Line);
extern int gdbmiCheckBreakpoint(agc_t *State, Breakpoint_t* gdbmi_bp);
extern void gdbmiUpdateBreakpoint(agc_t *State, Breakpoint_t* gdbmi_bp);
extern void gdbmiHandleDelete(agc_t *State , char* s, char* r);

#define GDBMI_FUNC(f) gdbmiResult gdbmi ## f(agc_t *State , char* s, char* sraw)
#define GDBMI_CALL(f,i) if(gdbmi_status == gdbmiCmdUnhandled)gdbmi_status = gdbmi ## f (State,s+i,sraw+i)

extern int gdbmi_sigint;
extern char SymbolFile[];
extern char* SourcePathName;

#endif
