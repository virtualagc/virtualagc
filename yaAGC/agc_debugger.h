/*
  Original Copyright 2003-2006,2009 Ronald S. Burkey <info@sandroid.org>
  Modified Copyright 2008,2016 Onno Hommes <ohommes@alumni.cmu.edu>
  
  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  In addition, as a special exception, permission is given to
  link the code of this program with the Orbiter SDK library (or with 
  modified versions of the Orbiter SDK library that use the same license as 
  the Orbiter SDK library), and distribute linked combinations including 
  the two. You must obey the GNU General Public License in all respects for 
  all of the code used other than the Orbiter SDK library. If you modify 
  this file, you may extend this exception to your version of the file, 
  but you are not obligated to do so. If you do not wish to do so, delete 
  this exception statement from your version. 
 
  Filename:	agc_debugger.h
  Purpose:	This header contains the debugger interface definitions
  Contact:	Onno Hommes <ohommes@alumni.cmu.edu>
  Reference:	http://www.ibiblio.org/apollo
  Mods:         12/02/08 OH.	Began rework
                08/04/16 OH     Fixed the GPL statement and old user-id
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
extern int DbgGetFrameNameOffsetByAddr(unsigned LinearAddr);
extern unsigned DbgGetCurrentProgramCounter(void);
extern void DbgDeleteBreakpoint(int bp);
extern void DbgUpdateBreakpoint(Breakpoint_t* bp);
extern int DbgCheckBreakpoint(Breakpoint_t* bp);
extern SymbolLine_t* DbgResolveCurrentLine(void);


#endif /* AGC_DEBUGGER_H_ */
