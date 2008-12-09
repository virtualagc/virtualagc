#ifndef AGC_DEBUG_H
#define AGC_DEBUG_H

#define MAX_BREAKPOINTS 256
#define PATTERN_SIZE 017777777
#define PAT "%08o"

#define BP_KEEP 'k'
#define BP_DELETE 'd'

typedef struct
{
  int Id;  // Breakpoint identifier
  int Hits; // Number of times hit
  char Enable; // Flag to track the enable status of the breakpoint
  char Disposition; // Breakpoint Disposition
  int Address12;                // A 12-bit address.
  // RegBB is like the normal BB register, except that we also insert the superbank
  // bit into it.  In other words, it's like BB bitwise-ORred with channel 7.
  // For PATTERNs, Address12 is the value we're watching for, and vRegBB is the
  // mask we apply before comparing.
  int vRegBB;
  int WatchValue;
  // WatchBreak is interpreted as follows:
  //    0 for a breakpoint (i.e., stopping upon hitting a given address).
  //    1 for a watchpoint wherein the contents of a given address changes value.
  //    2 for a pattern (i.e., the next instruction code matches a pattern).
  //    3 for a watchpoint wherein a given value is written to a given address.
  //    4 for a watchpoint that displays a variable rather than halting.
  int WatchBreak;

  // If the "break <line>" is used, then Line will be set. If "break <symbol>"
  // is used, then Symbol will be set. If a memory address is given, then both
  // will be NULL.
  Symbol_t *Symbol;
  SymbolLine_t *Line;
}
Breakpoint_t;

extern Breakpoint_t Breakpoints[MAX_BREAKPOINTS];
extern int NumBreakpoints;

extern int HaveSymbols;
extern char *SymbolFile;
extern int DebugMode;
extern int SingleStepCounter;

#endif

