#ifndef AGC_GDBMI_H
#define AGC_GDBMI_H

#include "agc_debug.h"

#define GDBMI_MAX_CUSTOM_CMDS 32
#define GDBMI_MAX_CUSTOM_ARGS 10

/**
 * typde definiyion to tell the simulator what action to take
 */
typedef enum
{
	GdbmiCmdUnhandled,
	GdbmiCmdError,
	GdbmiCmdDone,
	GdbmiCmdNext,
	GdbmiCmdStep,
	GdbmiCmdContinue,
	GdbmiCmdRun,
	GdbmiCmdQuit = 0xfe,
} GdbmiResult;

typedef struct
{
   char* Command;
   char* Arguments[GDBMI_MAX_CUSTOM_ARGS];
} CustomCommand_t;

typedef struct
{
	char* Command;
	GdbmiResult (*Handler)(int);
} GdbmiCommands_t;

extern void GdbmiDisplayBreakpointForLine(SymbolLine_t* Line,int BreakpointId );
extern GdbmiResult GdbmiInterpreter(agc_t* , char*, char* );
extern void GdbmiPrintFullNameContents(SymbolLine_t *Line);
extern GdbmiResult GdbmiHandleDelete(int k);
void GdbmiPrintFullNameFrame(SymbolLine_t *Line);
void GdbmiPrintSourceFrame(SymbolLine_t *Line);

//#define GDBMI_FUNC(f) GdbmiResult gdbmi ## f(agc_t *State , char* s, char* sraw)
//#define GDBMI_CALL(f,i) if(gdbmi_status == gdbmiCmdUnhandled)gdbmi_status = gdbmi ## f (State,s+i,sraw+i)

extern int gdbmi_sigint;
extern char* SymbolFile;
extern char* SourcePathName;

#endif
