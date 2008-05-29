#ifndef AGC_GDBMI_H
#define AGC_GDBMI_H

#include "agc_debug.h"

extern int gdbmiHandleCommand(agc_t* , char*, char* ); 
extern void gdbmiPrintFullNameContents(SymbolLine_t *Line);
extern int gdbmiCheckBreakpoint(agc_t *State, Breakpoint_t* gdbmi_bp);
extern void gdbmiUpdateBreakpoint(agc_t *State, Breakpoint_t* gdbmi_bp);
extern void gdbmiHandleDelete(agc_t *State , char* s, char* sraw);

#define GDBMI_MAX_CUSTOM_CMDS 32
#define GDBMI_MAX_CUSTOM_ARGS 10

typedef struct
{
   char* Command;
   char* Arguments[GDBMI_MAX_CUSTOM_ARGS];
} CustomCommand_t;

extern int gdbmi_sigint;
extern char SymbolFile[];
extern char* SourcePathName;

#endif
