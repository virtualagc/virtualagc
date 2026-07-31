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
#include "trace.h"

/* Snapshot/execute/diff/print, gated on age->htraceWanted (set by
 * yagpc2_debugger(), below) -- self-contained here so any driver using
 * yaGPC2_ops gets working 'htrace' output without having to know
 * anything about register snapshotting or trace-line formatting itself.
 * Uses trace_format_line() (src/trace.c), the one trace-line formatter
 * that's already public and decoupled from both Debugger and
 * BatchRunner -- this is *not* byte-identical to the CLI's own --debug
 * trace lines (that one, run.c's private batchrunner_format_trace_line(),
 * has its own section-offset formatting and 'set width' wrapping that
 * this doesn't reproduce), but it does include the same elapsed-time
 * field via TraceLineOpts.elapsedTimeUs. */
static void yagpc2_engine(GpcState *state) {
    AGEHarness *age = (AGEHarness *)state->impl;
    bool wantTrace = age->htraceWanted;

    uint32_t nia = 0, hw1 = 0, hw2 = 0;
    char disasm[256] = "";
    int instrLen = 1;
    RegSnapshot before;
    if (wantTrace) {
        nia = psw_get_nia(&age->gpc.cpu.psw);
        hw1 = mcm_get16(&age->gpc.cpu.mainStorage, nia);
        hw2 = mcm_get16(&age->gpc.cpu.mainStorage, nia + 1);
        instr_to_str(hw1, hw2, disasm, sizeof disasm);
        DInstr v;
        const InstrDesc *d = instr_decode(hw1, hw2, &v);
        instrLen = d ? d->pb.origLen : 1;
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

        TraceLineOpts opts = {
            .color = &TRACE_COLOR_PLAIN,
            .sym = age->sym.loaded ? &age->sym : NULL,
            .stepWidth = 5,
            .niaWidth = 6,
            .elapsedTimeUs = &age->gpc.cpu.elapsedTimeUs,
        };
        char line[2400];
        trace_format_line(line, sizeof line, stepNum, nia, hw1, hw2, disasm, instrLen, filtered, filteredCount, &opts);
        printf("%s\n", line);
    }
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
     * it -- its own REPL can dispatch 'htrace on'/'off' mid-call, same
     * reasoning as debugger_wants_htrace()'s own header comment. */
    age->htraceWanted = debugger_wants_htrace(dbg);
    return cont;
}

static bool yagpc2_initializer(GpcState *state, const char *programPath, const char *symbolsPath) {
    AGEHarness *age = malloc(sizeof(AGEHarness));
    if (!ageharness_init_minimal(age, programPath, symbolsPath)) {
        free(age);
        return false;
    }
    state->impl = age;
    state->emulator = GPC_EMULATOR_YAGPC2;
    state->elapsedTime = age->gpc.cpu.elapsedTimeUs;
    return true;
}

const GpcOps yaGPC2_ops = {
    .engine = yagpc2_engine,
    .debugger = yagpc2_debugger,
    .initializer = yagpc2_initializer,
};
