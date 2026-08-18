/* Black-box adapters wrapping yaGPC2's existing engine/debugger/
 * initializer entry points to the yaGpcIntegration.h GpcOps shape, so a
 * larger simulator can call yaGPC2 identically to yaHALMAT2 without
 * knowing which one it's talking to. None of this is used by the
 * standalone `gpc run` CLI path (main.c/run.c), which keeps calling
 * ap101_exec1()/debugger_hook()/ageharness_configure_from_opts()
 * directly as before. */
#include "yaGpcIntegration.h"

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
 * comment on the full code list): decodes before executing -- same
 * pre-check run.c's batchrunner_step() already does -- so a decode
 * failure is reported as GPC_ENGINE_ERROR_INVALID_OPCODE without ever
 * calling ap101_exec1(), rather than silently no-op'ing the way
 * cpu_exec1() does internally on its own (that no-op path is documented
 * there as unreachable from `gpc run` specifically because run.c's own
 * pre-check already keeps it from happening -- not a guarantee this
 * entry point can rely on, since a driver can call engine() on a halted
 * or off-the-end instance). Post-execution, in priority order:
 *   1. A SEND ERROR fired on exactly this instruction (HalUCP's one-shot
 *      sendErrorPending, read and cleared here -- lastErrGroup/lastErrNum
 *      alone can't tell a fresh one from a stale one several instructions
 *      old) -> GPC_ENGINE_WARNING_HAL_S_ERROR_BASE + errNum. Doesn't halt;
 *      execution already continued normally.
 *   2. The AP-101S wait-state bit is set -> a normal/expected program
 *      termination, unless HalUCP.haltedOnUnhandledEof says otherwise
 *      (both halt the CPU identically; that flag is the only way to
 *      tell them apart from outside).
 *   3. HalUCP.svcTrapped set *without* wait-state -> an unrecognized SVC
 *      was hit without the program actually halting
 *      (GPC_ENGINE_ERROR_UNHANDLED_TRAP) -- the exact "ran into garbage"
 *      case that motivated adding all of this in the first place. */
static GpcEngineStatus yagpc2_engine(GpcState *state) {
    AGEHarness *age = (AGEHarness *)state->impl;

    uint32_t nia = psw_get_nia(&age->gpc.cpu.psw);
    uint32_t hw1 = mcm_get16(&age->gpc.cpu.mainStorage, nia);
    uint32_t hw2 = mcm_get16(&age->gpc.cpu.mainStorage, nia + 1);
    DInstr v;
    const InstrDesc *d = instr_decode(hw1, hw2, &v);
    if (!d) return GPC_ENGINE_ERROR_INVALID_OPCODE;

    bool wantTrace = age->htraceWanted;
    char disasm[256] = "";
    int instrLen = d->pb.origLen;
    RegSnapshot before;
    if (wantTrace) {
        instr_to_str(hw1, hw2, disasm, sizeof disasm);
        ageharness_snapshot_regs(age, &before);
    }

    /* Real, pre-existing gap this whole embedding surface had from the
     * start, only actually surfaced once something (the output/input
     * contract work) finally checked WRITE/READ content instead of just
     * "does it eventually halt": ap101_exec1() does NOT itself intercept
     * HalUCP's WRITE/READ/control-statement traps -- run.c's own
     * batchrunner_step() calls halucp_check_trap() as a separate step
     * immediately before ap101_exec1(), and this adapter never did,
     * meaning every WRITE/READ statement silently executed as bare
     * (non-intercepted) AP-101S object code instead of being emulated at
     * all. Confirmed directly: without this, hello.fcm (which the real
     * CLI prints ~25 lines of "HELLO, WORLD!"/"RON BURKEY SAYS..." for)
     * produced zero output through this engine, even with a working
     * outputCallback wired up -- the callback was simply never reached. */
    if (age->halUCP.active && halucp_is_trap_addr(&age->halUCP, nia)) {
        halucp_check_trap(&age->halUCP, nia);
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

    if (age->halUCP.sendErrorPending) {
        age->halUCP.sendErrorPending = false;
        return (GpcEngineStatus)(GPC_ENGINE_WARNING_HAL_S_ERROR_BASE + age->halUCP.lastErrNum);
    }
    if (psw_get_wait_state(&age->gpc.cpu.psw)) {
        return age->halUCP.haltedOnUnhandledEof ? GPC_ENGINE_HALTED_UNHANDLED_EOF : GPC_ENGINE_HALTED_NORMAL;
    }
    if (age->halUCP.svcTrapped) return GPC_ENGINE_ERROR_UNHANDLED_TRAP;
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

/* Built-in defaults for GpcInitializerFn's output/input parameters (see
 * their own comments in yaGpcIntegration.h for exactly what NULL means
 * for each) -- resolved once here at init time so yagpc2_engine()'s
 * shims below never need a NULL check themselves.
 *
 * Channels 6/5 are HAL/S's own conventional output/input pair (already
 * hardcoded elsewhere in this codebase, not invented here -- see
 * run.c's prompt_and_provide_input()/interactive_input_cb(), which
 * special-case exactly these two channel numbers the same way). Every
 * other channel discards on output / reports immediate EOF on input,
 * same as a channel nothing was ever configured for. */
static void default_output(void *ioCtx, int channel, const char *text) {
    (void)ioCtx;
    if (channel != 6) return;
    fputs(text, stdout);
}

static bool default_input(void *ioCtx, int channel, char *buf, size_t bufSize) {
    (void)ioCtx;
    if (channel != 5) return false;
    if (!fgets(buf, (int)bufSize, stdin)) return false;
    size_t len = strlen(buf);
    if (len > 0 && buf[len - 1] == '\n') {
        buf[--len] = '\0';
        if (len > 0 && buf[len - 1] == '\r') buf[--len] = '\0'; /* CRLF-terminated source */
    }
    return true;
}

/* Bridges HalUCP's outputCallback shape to GpcOutputFn -- pure
 * forwarding, channel/text already exactly match. */
static void gpcops_output_shim(void *ctx, const char *text, int channel) {
    AGEHarness *age = (AGEHarness *)ctx;
    age->ioOutput(age->ioCtx, channel, text);
}

/* Bridges HalUCP's inputCallback (a notify-only "I need a line for this
 * channel now" signal, iocode omitted -- see GpcInputFn's own comment on
 * why the contract stays at the channel-number level) to GpcInputFn's
 * synchronous pull, then completes the read immediately via
 * halucp_provide_input()/halucp_provide_eof() -- exactly the same
 * synchronous notify-then-immediately-answer-back pattern run.c's own
 * batchrunner_input_cb() already uses against IOHost, just delegating
 * "how do I get a line for this channel" to the driver-supplied
 * GpcInputFn instead of iohost_read_input_line(). */
static void gpcops_input_shim(void *ctx, int channel, int iocode) {
    (void)iocode;
    AGEHarness *age = (AGEHarness *)ctx;
    char buf[512];
    if (age->ioInput(age->ioCtx, channel, buf, sizeof buf)) {
        halucp_provide_input(&age->halUCP, buf);
    } else {
        halucp_provide_eof(&age->halUCP);
    }
}

static bool yagpc2_initializer(GpcState *state, const char *programPath, const char *symbolsPath,
                                double startEpochSeconds, GpcServicerFn servicer, void *servicerCtx,
                                GpcOutputFn output, GpcInputFn input, void *ioCtx) {
    AGEHarness *age = malloc(sizeof(AGEHarness));
    if (!ageharness_init_minimal(age, programPath, symbolsPath, startEpochSeconds)) {
        free(age);
        return false;
    }
    if (servicer) ap101_set_servicer(&age->gpc, servicer, servicerCtx);

    age->ioOutput = output ? output : default_output;
    age->ioInput = input ? input : default_input;
    age->ioCtx = ioCtx;
    age->halUCP.cbCtx = age;
    age->halUCP.outputCallback = gpcops_output_shim;
    age->halUCP.inputCallback = gpcops_input_shim;

    state->impl = age;
    state->emulator = GPC_EMULATOR_YAGPC2;
    state->elapsedTime = age->gpc.cpu.elapsedTimeUs;
    state->startEpochSeconds = age->gpc.cpu.dateTimeAnchorEpochSec;
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
