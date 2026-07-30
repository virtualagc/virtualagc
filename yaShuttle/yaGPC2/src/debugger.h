/* Interactive gdb-style debugger for yaGPC2, ported from
 * ~/donschmidt/nsts-sim-gpc/gpc/cmd_debug.coffee's GPCDebugger class (the
 * same porting relationship this project's other subsystems all use —
 * see debugger-planner.md). Adapted from the CoffeeScript original's
 * async readline/Command(commander.js)-tree REPL to a single blocking
 * stdin read loop, matching the synchronous style
 * run.c's own interactive mode already uses (see run.c's header comment
 * on batchrunner_run_interactive) — same observable behavior for a
 * single-threaded CLI tool.
 *
 * All debugger state and logic lives in this file and debugger.c —
 * kept isolated from the rest of yaGPC2 per the user's explicit request,
 * integrated through the single debugger_hook() call in run.c's shared
 * batchrunner_step(). */
#ifndef YAGPC_DEBUGGER_H
#define YAGPC_DEBUGGER_H

#include <stdbool.h>
#include <stdint.h>

#include "ageharness.h"
#include "opts.h"

/* Opaque: session/REPL state (breakpoints, step-mode, htrace flag,
 * recent-instruction ring buffer), not simulator state -- deliberately
 * kept separate from AGEHarness/Options/BatchRunner, per the user's
 * requirement that the AP-101S state be passed in rather than owned
 * here. */
typedef struct Debugger Debugger;

Debugger *debugger_create(const Options *opts);
void debugger_free(Debugger *dbg);

/* True when the debugger's 'trace'/'htrace' toggle is on -- run.c ORs
 * this into its own --trace-driven per-instruction line printing so
 * 'htrace' reuses the existing trace-line formatting/diffing rather than
 * duplicating it here (that logic needs the post-execution register
 * diff, which isn't available yet at debugger_hook()'s call site). */
bool debugger_wants_trace(const Debugger *dbg);

/* Called once per instruction, immediately before ap101_exec1() and
 * before the HalUCP trap check -- the single integration point between
 * yaGPC2 proper and the debugger. May block reading commands from
 * stdin. Returns true to proceed with executing the instruction at nia
 * (hw1/hw2 already fetched by the caller); a false return is reserved for
 * a future stop-the-loop path -- Stage 1 never returns false ('quit'
 * exits the process directly, matching the CoffeeScript original). */
bool debugger_hook(Debugger *dbg, AGEHarness *age, uint32_t nia, uint32_t hw1, uint32_t hw2, long step);

#endif
