#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "debug.h"
#include "halmat.h"
#include "interp.h"
#include "literal.h"
#include "symtab.h"
#include "yaGpcIntegration.h"

static bool file_exists(const char *path) {
    struct stat st;
    return stat(path, &st) == 0;
}

/* Same companion-file convention as main.c's own find_companion()/
 * run_single() (not exported from there, so duplicated here rather than
 * modifying main.c, which stays untouched per this integration's own
 * additive-only constraint). */
static bool find_companion(const char *halmat_path, const char *const *candidates,
                            size_t num_candidates, char *out, size_t out_size) {
    const char *slash = strrchr(halmat_path, '/');
    size_t dir_len = slash ? (size_t)(slash - halmat_path + 1) : 0;

    for (size_t i = 0; i < num_candidates; i++) {
        if (dir_len + strlen(candidates[i]) + 1 > out_size) continue;
        memcpy(out, halmat_path, dir_len);
        strcpy(out + dir_len, candidates[i]);
        if (file_exists(out)) return true;
    }
    return false;
}

/* Deliberately interp_step() only, never interp_run()/interp_run_burst()/
 * interp_run_signal() -- those have their own real-time pacing (including
 * interp_run_signal()'s process-wide POSIX timer), which doesn't work
 * correctly with multiple independently-driven instances in one process.
 *
 * Maps interp_step()'s outcome onto GpcEngineStatus (yaGpcIntegration.h):
 *  - state->send_error_pending (set at the two AERROR/SEND ERROR firing
 *    sites in interp.c -- arithmetic_error_should_apply_fixup, OP_ERSE) is
 *    checked first and, if set, wins outright. An AERROR never halts by
 *    itself (execution continues normally, per the contract's own comment
 *    on GPC_ENGINE_WARNING_HAL_S_ERROR_BASE), so this and the halted/
 *    running checks below are mutually exclusive in practice -- checking
 *    it first just keeps that explicit rather than assumed. Cleared
 *    immediately after being read (one-shot).
 *  - interp_step()'s own return value, not just state->halted, decides
 *    RUNNING vs. stopped: interp_step() returns false on every path that
 *    did real forward-progress work this call (see its own header comment
 *    in interp.c) and true on every path that stopped early -- including
 *    scheduler exhaustion (sched_pick_next()==-1), which is the ONE path
 *    that returns true WITHOUT setting state->halted. That asymmetry is
 *    exactly what distinguishes GPC_ENGINE_HALTED_STARVED from
 *    GPC_ENGINE_RUNNING here -- no separate interp.c-side flag was needed
 *    for this one; interp_step()'s existing return convention already
 *    encodes it.
 *  - Otherwise, state->halt_reason (set at every halted=true site that
 *    warrants its own GpcEngineStatus code -- state.h/interp.c) maps
 *    directly. Everything not explicitly categorized (~480 of the ~490
 *    total fail() call sites) stays HALMAT_HALT_REASON_FAIL_GENERIC ->
 *    GPC_ENGINE_ERROR_INTERNAL, a deliberate catch-all, not an oversight
 *    (see the relay's own explicit scoping-down instruction). */
static GpcEngineStatus yaHALMAT2_engine(GpcState *gpcState) {
    halmat_state_t *state = (halmat_state_t *)gpcState->impl;
    bool stopped = interp_step(state, stdout);
    gpcState->elapsedTime = (double)state->virtual_time;

    if (state->send_error_pending) {
        state->send_error_pending = false;
        return (GpcEngineStatus)(GPC_ENGINE_WARNING_HAL_S_ERROR_BASE + state->last_error_member);
    }
    if (!stopped) return GPC_ENGINE_RUNNING;
    if (!state->halted) return GPC_ENGINE_HALTED_STARVED;

    switch (state->halt_reason) {
        case HALMAT_HALT_REASON_NORMAL: return GPC_ENGINE_HALTED_NORMAL;
        case HALMAT_HALT_REASON_UNHANDLED_EOF: return GPC_ENGINE_HALTED_UNHANDLED_EOF;
        case HALMAT_HALT_REASON_INVALID_OPCODE: return GPC_ENGINE_ERROR_INVALID_OPCODE;
        case HALMAT_HALT_REASON_BOUNDS: return GPC_ENGINE_ERROR_BOUNDS;
        case HALMAT_HALT_REASON_STACK_DEPTH: return GPC_ENGINE_ERROR_STACK_DEPTH;
        case HALMAT_HALT_REASON_UNDEFINED_CALL: return GPC_ENGINE_ERROR_UNDEFINED_CALL;
        case HALMAT_HALT_REASON_FAIL_GENERIC:
        case HALMAT_HALT_REASON_NONE:
        default:
            return GPC_ENGINE_ERROR_INTERNAL;
    }
}

/* elapsedTime is re-synced here too, not just in the engine adapter, since
 * step/next/continue/run all advance virtual_time along paths that never
 * go through yaHALMAT2_engine().
 *
 * dstate->frames[0] is bound here rather than at creation time: unlike the
 * old (pre-issue-#79) yaHALMAT2_debugger_state_create(), which took the
 * halmat_state_t pointer, symtab, label, units, colors, and out directly, the contract's
 * GpcDebuggerStateCreateFn only takes an optional sourceMapPath -- there is
 * no other parameter slot for any of those. So the outermost debug frame
 * is (re-)synced to gpcState->impl on every call instead: cheap, handles
 * first-use lazily (frame_count starts at 0 from debuggerStateCreate's own
 * memset), and also covers dbgState being reused across a different
 * GpcState over one debugging session (yaGpcIntegration.h's own comment on
 * GpcDebuggerStateDestroyFn). No symtab/label/units/colors are available
 * this way, so print/backtrace/step-into-a-different-unit degrade exactly
 * the way they already do whenever main.c itself has no companion file for
 * them -- not a new failure mode, just a narrower one than the CLI's own
 * --debug gets when it calls debug_run() directly. */
static bool yaHALMAT2_debugger(GpcState *gpcState, void *dbgState) {
    debugger_state_t *dstate = (debugger_state_t *)dbgState;
    if (dstate->frame_count == 0) {
        memset(&dstate->frames[0], 0, sizeof(dstate->frames[0]));
        dstate->frame_count = 1;
    }
    dstate->frames[0].state = (halmat_state_t *)gpcState->impl;
    bool keep_going = debug_run_command(dstate);
    gpcState->elapsedTime = (double)dstate->frames[0].state->virtual_time;
    return keep_going;
}

/* halmat_state MUST be the first member: interp_init() stores state->prog
 * as a bare, non-owned pointer, so the halmat_program_t must outlive
 * halmat_state_t. GpcState.impl is contractually exactly halmat_state_t*
 * (not a wrapper), so the adapter recovers the companion prog/literals/
 * symtab via this struct's first-member/whole-struct pointer
 * interconvertibility. */
typedef struct {
    halmat_state_t state;
    halmat_program_t prog;
    halmat_literal_table_t literals;
    bool have_literals;
    halmat_symtab_t symtab;
    bool have_symtab;
    GpcServicerFn servicer;    /* stored, not yet wired to anything -- see
                                 * yaHALMAT2_initializer()'s own comment */
    void *servicerCtx;
    bool owns_input_tmpfile;  /* true iff devices[5] is a tmpfile() this adapter created (input_fn active) and must fclose() in release() */
} yaHALMAT2_instance_t;

/* symbolsPath is yaGPC2-only (establishes its start address from a linker/
 * symbols JSON file); yaHALMAT2's entry point comes from the HALMAT program
 * itself, so it's accepted for signature uniformity and ignored.
 *
 * Beyond halmat_load()+interp_init(), this also auto-discovers the literal
 * table (litfile0.bin/litfile.bin + COMMON0.out.bin.gz/.bin) and symbol
 * table (COMMON0.out) alongside programPath, exactly like main.c's own
 * run_single() does for the CLI's plain-HALMAT_FILE case. This isn't
 * optional convenience the way it first looked when this adapter was
 * scoped as "just halmat_load()+interp_init()": QUAL_LIT operands cover
 * every literal constant a HALMAT program has, not only CHARACTER string
 * data, so *any* program with a numeric literal -- essentially all of
 * them -- fails immediately ("literal index N out of range") without it;
 * the symtab is similarly required for MATRIX/VECTOR arithmetic even in
 * ordinary non-debug runs (see run_single()'s own comment on this in
 * main.c). Device maps/RAF maps/pacing config remain deliberately not
 * auto-discovered -- those really are CLI-only concerns with no
 * standalone-Shuttle-sim analogue. Missing companions degrade gracefully
 * (blank string literals, no MATRIX/VECTOR symbol lookup) exactly as they
 * do for the CLI, rather than failing.
 *
 * servicer/servicerCtx: stored on the instance but not wired to anything
 * yet. yaHALMAT2 has no HAL/S-level construct for vehicle discrete/analog
 * I/O at all (confirmed by exhaustive search across interp.c, state.h, and
 * every reengineered-documentation/ doc including STATUS.md -- a plain
 * absence, not a documented gap) -- READ/WRITE/RDAL are ordinary channel
 * I/O, out of scope for the servicer. So there is currently no call site
 * to route these through, the same open question flagged since the
 * original relay. Accepting and storing them now (rather than ignoring
 * outright, the way symbolsPath is) costs nothing and means a future
 * HAL/S I/O construct just needs a call site added here, not a signature
 * change.
 *
 * output/input/ioCtx: wired directly into state->output_fn/input_fn/
 * output_ctx/input_ctx (state.h) -- see interp.c's device_emit_line()
 * (output) and device_input_refill() (input) for how those actually get
 * used. Deliberately scoped to HAL/S's two conventional channels only:
 * output covers channel 6 (interp_init()'s own default already gives it
 * a valid devices[6]=stdout, so dm_finalize_line's output_fn branch never
 * needs to touch a device slot at all); input covers channel 5, whose
 * devices[5] is replaced here with an empty tmpfile() that
 * device_input_refill() grows on demand by calling input_fn -- when
 * input is NULL, devices[5] is simply left as interp_init()'s own
 * real-stdin default, exactly matching the contract's own NULL-fallback
 * description for free. WRITE/READ against any OTHER channel is
 * unchanged from before this relay -- still fails loudly if unmapped,
 * same as the CLI -- NOT the "discards every other channel"/"reports
 * immediate EOF on every other channel" default yaGpcIntegration.h
 * describes; GpcInitializerFn has no way to map additional channels at
 * all yet, so there's nothing to route those through regardless. Flagged
 * as a known, deliberate scope gap rather than silently left
 * unmentioned. */
static bool yaHALMAT2_initializer(GpcState *gpcState, const char *programPath, const char *symbolsPath,
                                   GpcServicerFn servicer, void *servicerCtx, GpcOutputFn output, GpcInputFn input,
                                   void *ioCtx) {
    (void)symbolsPath;
    char errbuf[512];
    yaHALMAT2_instance_t *inst = malloc(sizeof(*inst));
    if (!inst) return false;
    inst->servicer = servicer;
    inst->servicerCtx = servicerCtx;
    inst->owns_input_tmpfile = false;
    if (!halmat_load(programPath, &inst->prog, errbuf, sizeof(errbuf))) {
        fprintf(stderr, "yaHALMAT2: %s\n", errbuf);
        free(inst);
        return false;
    }

    char lit_buf[1024], mem_buf[1024];
    static const char *lit_candidates[] = {"litfile0.bin", "litfile.bin"};
    static const char *mem_candidates[] = {"COMMON0.out.bin.gz", "COMMON0.out.bin"};
    const char *lit_path = find_companion(programPath, lit_candidates, 2, lit_buf, sizeof(lit_buf)) ? lit_buf : NULL;
    const char *mem_path = find_companion(programPath, mem_candidates, 2, mem_buf, sizeof(mem_buf)) ? mem_buf : NULL;
    inst->have_literals = false;
    if (lit_path) {
        if (!halmat_literal_load(lit_path, mem_path, &inst->literals, errbuf, sizeof(errbuf))) {
            fprintf(stderr, "yaHALMAT2: %s\n", errbuf);
            halmat_program_free(&inst->prog);
            free(inst);
            return false;
        }
        inst->have_literals = true;
    }

    char sym_buf[1024];
    static const char *sym_candidates[] = {"COMMON0.out"};
    inst->have_symtab = false;
    if (find_companion(programPath, sym_candidates, 1, sym_buf, sizeof(sym_buf))) {
        char sym_err[256];
        inst->have_symtab = halmat_symtab_load(sym_buf, &inst->symtab, sym_err, sizeof(sym_err));
    }

    interp_init(&inst->state, &inst->prog, inst->have_literals ? &inst->literals : NULL, 5); /* num_blanks=5, matching main.c's own CLI default */
    if (inst->have_symtab) interp_set_symtab(&inst->state, &inst->symtab);
    inst->state.output_fn = output;
    inst->state.output_ctx = ioCtx;
    inst->state.input_fn = input;
    inst->state.input_ctx = ioCtx;
    if (input) {
        FILE *tmp = tmpfile();
        if (tmp) {
            inst->state.devices[5] = tmp;
            inst->owns_input_tmpfile = true;
        }
        /* else: tmpfile() failed (rare, system-level) -- degrade to
         * devices[5] staying interp_init()'s own real-stdin default
         * rather than failing the whole initializer over it. */
    }
    gpcState->impl = &inst->state;
    gpcState->elapsedTime = 0.0;
    return true;
}

/* Frees the halmat_state_t/halmat_program_t/literal-table/symbol-table
 * bundle yaHALMAT2_initializer() allocates, after first calling
 * interp_cleanup() -- which, beyond freeing interp.c's own dynamically
 * allocated per-state buffers, also flushes each device's still-buffered
 * final WRITE line (the exact bug class fixed on yaGPC2's side as issue
 * #80). Skipping that flush would silently drop a program's last line of
 * output whenever a driver tears an instance down instead of letting it
 * run to its own HALT/EOF. gpcState->impl is set NULL afterward, matching
 * yaGpcIntegration.h's own GpcReleaseFn contract. */
static void yaHALMAT2_release(GpcState *gpcState) {
    yaHALMAT2_instance_t *inst = (yaHALMAT2_instance_t *)gpcState->impl; /* first-member cast, same trick the initializer's own gpcState->impl assignment relies on */
    if (!inst) return;
    interp_cleanup(&inst->state);
    if (inst->owns_input_tmpfile) fclose(inst->state.devices[5]); /* the tmpfile() yaHALMAT2_initializer() created for input_fn -- devices[] itself is otherwise never owned/closed here (state.h) */
    if (inst->have_symtab) halmat_symtab_free(&inst->symtab);
    if (inst->have_literals) halmat_literal_free(&inst->literals);
    halmat_program_free(&inst->prog);
    free(inst);
    gpcState->impl = NULL;
}

/* sourceMapPath (pass1.rpt's HAL/S source-line correlation, in main.c's
 * own terms) isn't wired up here -- same "ignore the parameter this
 * emulator doesn't use yet" treatment yaGPC2 gives GpcInitializerFn's
 * symbolsPath, per yaGpcIntegration.h's own comment on this field.
 * Everything else debug_run_init() used to take (halmat_state_t*, symtab,
 * label, units, colors, out) has no counterpart in this reduced create
 * signature either -- see yaHALMAT2_debugger()'s own comment for how
 * those get bound (or default) instead. */
static void *yaHALMAT2_debuggerStateCreate(const char *sourceMapPath) {
    (void)sourceMapPath;
    debugger_state_t *dstate = malloc(sizeof(*dstate));
    if (!dstate) return NULL;
    memset(dstate, 0, sizeof(*dstate));
    dstate->last_stmt_shown = -2; /* sentinel: interp_current_stmt_for_next() never returns less than -1 */
    dstate->out = stdout; /* no per-instance output stream in the contract -- shared stdout, matching every other yaHALMAT2 default */
    return dstate;
}

static void yaHALMAT2_debuggerStateDestroy(void *dbgState) {
    free(dbgState);
}

const GpcOps yaHALMAT2_ops = { yaHALMAT2_engine, yaHALMAT2_debugger, yaHALMAT2_initializer,
                                yaHALMAT2_release, yaHALMAT2_debuggerStateCreate, yaHALMAT2_debuggerStateDestroy };
