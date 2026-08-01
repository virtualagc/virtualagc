/* Black-box adapters wrapping yaGPC2's existing engine/debugger/
 * initializer entry points to the yaGpcIntegration.h GpcOps shape, so a
 * larger simulator can call yaGPC2 identically to yaHALMAT2 without
 * knowing which one it's talking to. None of this is used by the
 * standalone `gpc run` CLI path (main.c/run.c), which keeps calling
 * ap101_exec1()/debugger_hook()/ageharness_configure_from_opts()
 * directly as before. */
#include "gpcops.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ageharness.h"
#include "cpu_instr.h"
#include "debugger.h"
#include "halucp.h"
#include "opts.h"
#include "trace.h"

/* Snapshot/execute/diff/print, gated on age->htraceWanted (set by
 * yagpc2_debugger(), below) -- self-contained here so any driver using
 * yaGPC2_ops gets working 'htrace' output without having to know
 * anything about register snapshotting or trace-line formatting itself.
 * Uses trace_format_debug_line() (src/trace.c) -- the same single
 * implementation run.c's own --debug trace lines use (via
 * batchrunner_format_trace_line(), now a thin wrapper around it) -- so
 * this is byte-identical to the CLI's own htrace output, including
 * section+offset formatting and 'set width' wrapping (age->htraceLineWidth,
 * also set by yagpc2_debugger() below).
 *
 * Also where GpcEngineStatus gets decided (see yaGpcIntegration.h's own
 * comment on it): decodes before executing -- same pre-check run.c's
 * batchrunner_step() already does -- so a decode failure is reported as
 * GPC_ENGINE_ERROR without ever calling ap101_exec1(), rather than
 * silently no-op'ing the way cpu_exec1() does internally on its own
 * (that no-op path is documented there as unreachable from `gpc run`
 * specifically because run.c's own pre-check already keeps it from
 * happening -- not a guarantee this entry point can rely on, since a
 * driver can call engine() on a halted or off-the-end instance).
 * Post-execution: the AP-101S wait-state bit means a normal/expected
 * program termination (GPC_ENGINE_HALTED); halUCP.svcTrapped set
 * *without* wait-state means an unrecognized SVC was hit without the
 * program actually halting (GPC_ENGINE_ERROR) -- the exact "ran into
 * garbage" case that motivated adding this in the first place. */
static GpcEngineStatus yagpc2_engine(GpcState *state) {
    AGEHarness *age = (AGEHarness *)state->impl;

    uint32_t nia = psw_get_nia(&age->gpc.cpu.psw);
    uint32_t hw1 = mcm_get16(&age->gpc.cpu.mainStorage, nia);
    uint32_t hw2 = mcm_get16(&age->gpc.cpu.mainStorage, nia + 1);
    DInstr v;
    const InstrDesc *d = instr_decode(hw1, hw2, &v);
    if (!d) return GPC_ENGINE_ERROR;

    bool wantTrace = age->htraceWanted;
    char disasm[256] = "";
    int instrLen = d->pb.origLen;
    RegSnapshot before;
    if (wantTrace) {
        instr_to_str(hw1, hw2, disasm, sizeof disasm);
        ageharness_snapshot_regs(age, &before);
    }

    int stepNum = age->stepCount;
    ap101_exec1(&age->gpc);
    age->stepCount++;
    state->elapsedTime = age->gpc.cpu.elapsedTimeUs;

    if (wantTrace) {
        RegSnapshot after;
        ageharness_snapshot_regs(age, &after);
        RegChange changes[REG_SNAPSHOT_MAX_CHANGES];
        int changeCount = ageharness_diff_regs(&before, &after, changes);
        RegChange filtered[REG_SNAPSHOT_MAX_CHANGES];
        int filteredCount = 0;
        for (int i = 0; i < changeCount; i++) {
            if (strcmp(changes[i].name, "NIA") != 0) filtered[filteredCount++] = changes[i];
        }

        char line[2400];
        trace_format_debug_line(line, sizeof line, stepNum, nia, hw1, hw2, disasm, instrLen, filtered, filteredCount,
                                 age->sym.loaded ? &age->sym : NULL, &age->gpc.cpu.elapsedTimeUs, age->htraceLineWidth);
        printf("%s\n", line);
    }

    if (psw_get_wait_state(&age->gpc.cpu.psw)) return GPC_ENGINE_HALTED;
    if (age->halUCP.svcTrapped) return GPC_ENGINE_ERROR;
    return GPC_ENGINE_RUNNING;
}

/* Derives the nia/hw1/hw2/step debugger_hook() itself needs from
 * *state, mirroring run.c's batchrunner_step() pre-fetch exactly (see
 * that function's own nia/hw1/hw2 lines) -- the one piece of decode
 * duplication this adapter can't avoid, since debugger_hook()'s
 * richer signature is yaGPC2-specific and isn't part of the black-box
 * GpcDebuggerFn contract. */
static bool yagpc2_debugger(GpcState *state, void *dbgState) {
    AGEHarness *age = (AGEHarness *)state->impl;
    Debugger *dbg = (Debugger *)dbgState;
    uint32_t nia = psw_get_nia(&age->gpc.cpu.psw);
    uint32_t hw1 = mcm_get16(&age->gpc.cpu.mainStorage, nia);
    uint32_t hw2 = mcm_get16(&age->gpc.cpu.mainStorage, nia + 1);
    bool cont = debugger_hook(dbg, age, nia, hw1, hw2, (long)age->stepCount);
    /* Consult again after debugger_hook() returns, not just before calling
     * it -- its own REPL can dispatch 'htrace on'/'off'/'set width' mid-
     * call, same reasoning as debugger_wants_htrace()'s own header comment. */
    age->htraceWanted = debugger_wants_htrace(dbg);
    age->htraceLineWidth = debugger_line_width(dbg);
    return cont;
}

static bool yagpc2_initializer(GpcState *state, const char *programPath, const char *symbolsPath,
                                GpcServicerFn servicer, void *servicerCtx) {
    AGEHarness *age = malloc(sizeof(AGEHarness));
    if (!ageharness_init_minimal(age, programPath, symbolsPath)) {
        free(age);
        return false;
    }
    if (servicer) ap101_set_servicer(&age->gpc, servicer, servicerCtx);
    state->impl = age;
    state->emulator = GPC_EMULATOR_YAGPC2;
    state->elapsedTime = age->gpc.cpu.elapsedTimeUs;
    return true;
}

/* Counterpart to yagpc2_initializer(): flushes any output still buffered
 * but not yet newline-terminated (same reasoning as run.c's own
 * halucp_flush_all_pending() call sites -- a driver releasing an
 * instance is another way a program's session can end besides its own
 * HALT/EOF), then frees everything the initializer allocated. */
static void yagpc2_release(GpcState *state) {
    AGEHarness *age = (AGEHarness *)state->impl;
    if (!age) return;
    halucp_flush_all_pending(&age->halUCP);
    ageharness_free(age);
    free(age);
    state->impl = NULL;
}

/* opts is otherwise all-defaults (calloc'd Debugger: htrace off, no
 * breakpoints) -- matching debugger_create()'s only three fields read
 * (trace/sourceMap/breakAddr), all zero/NULL here except sourceMap. A
 * driver that wants an initial breakpoint or htrace-on-at-startup sets
 * them via the debugger's own commands after creation, same as any
 * interactive user would. */
static void *yagpc2_debugger_state_create(const char *sourceMapPath) {
    Options opts = {0};
    opts.sourceMap = (char *)sourceMapPath; /* debugger_create() only reads this -- see sourcemap_load()'s const char* param */
    return debugger_create(&opts);
}

static void yagpc2_debugger_state_destroy(void *dbgState) {
    debugger_free((Debugger *)dbgState);
}

const GpcOps yaGPC2_ops = {
    .engine = yagpc2_engine,
    .debugger = yagpc2_debugger,
    .initializer = yagpc2_initializer,
    .release = yagpc2_release,
    .debuggerStateCreate = yagpc2_debugger_state_create,
    .debuggerStateDestroy = yagpc2_debugger_state_destroy,
};
