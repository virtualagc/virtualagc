/* Black-box adapters wrapping yaGPC2's existing engine/debugger/
 * initializer entry points to the yaGpcIntegration.h GpcOps shape, so a
 * larger simulator can call yaGPC2 identically to yaHALMAT2 without
 * knowing which one it's talking to. None of this is used by the
 * standalone `gpc run` CLI path (main.c/run.c), which keeps calling
 * ap101_exec1()/debugger_hook()/ageharness_configure_from_opts()
 * directly as before. */
#include "gpcops.h"

#include <stdlib.h>

#include "ageharness.h"
#include "debugger.h"

static void yagpc2_engine(GpcState *state) {
    AGEHarness *age = (AGEHarness *)state->impl;
    ap101_exec1(&age->gpc);
    age->stepCount++;
    state->elapsedTime = age->gpc.cpu.elapsedTimeUs;
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
    return debugger_hook(dbg, age, nia, hw1, hw2, (long)age->stepCount);
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
