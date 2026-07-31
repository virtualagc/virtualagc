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
#include "yaGpcOps.h"

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
 * correctly with multiple independently-driven instances in one process. */
static void yaHALMAT2_engine(GpcState *gpcState) {
    halmat_state_t *state = (halmat_state_t *)gpcState->impl;
    interp_step(state, stdout);
    gpcState->elapsedTime = (double)state->virtual_time;
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
 * do for the CLI, rather than failing. */
static bool yaHALMAT2_initializer(GpcState *gpcState, const char *programPath, const char *symbolsPath) {
    (void)symbolsPath;
    char errbuf[512];
    yaHALMAT2_instance_t *inst = malloc(sizeof(*inst));
    if (!inst) return false;
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
