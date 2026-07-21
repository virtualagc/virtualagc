#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#ifdef _WIN32
#include <io.h>
#define halmat_isatty _isatty
#else
#include <unistd.h>
#define halmat_isatty isatty
#endif

#include "debug.h"
#include "disasm.h"
#include "halmat.h"
#include "interp.h"
#include "literal.h"
#include "srcmap.h"
#include "state.h"
#include "symtab.h"

#define OP_MDEF_CONST 0x02B
#define OP_CDEF_CONST 0x02F
#define OP_FDEF_CONST 0x02C
#define OP_PDEF_CONST 0x02D

#define MAX_UNITS 64
#define MAX_DEVICE_MAPS 16

typedef struct {
    int device;
    const char *path;
    bool is_output;
} device_map_t;

typedef struct {
    int channel;
    int record_size;
    const char *path;
    char mode; /* 'I', 'O', or 'B' (input/output/both) -- see --raf's usage text */
} raf_map_t;

static void usage(const char *prog) {
    fprintf(stderr,
            "usage: %s [options] HALMAT_FILE\n"
            "       %s [options] @list\n"
            "options:\n"
            "  --disasm         disassemble only, do not execute\n"
            "  --litfile F      literal file (default: auto-discovered alongside HALMAT_FILE)\n"
            "  --memory F       memory-image file for string literals (default: auto-discovered)\n"
            "  --num-blanks N   blanks between WRITE items (default: 5, per USA003087 Sec. 12.2)\n"
            "  --debug          interactive gdb-subset debugger (see debug.h; single HALMAT_FILE only)\n"
            "  --opt            load optmat.bin (+ its companions) instead of halmat.bin\n"
            "                   (single-file mode: only changes companion auto-discovery,\n"
            "                   since HALMAT_FILE is given explicitly either way)\n"
            "  --py             load FILE1.bin (+ FILE2.bin/LIT_CHAR.bin, HAL_S_FC.py's own\n"
            "                   naming convention) instead of halmat.bin -- mutually exclusive\n"
            "                   with --opt. HAL_S_FC.py produces no COMMON*.out symbol table,\n"
            "                   so --debug's `print` and @list's EXTERNAL-COMPOOL linking are\n"
            "                   unavailable for --py units (accepted transparently, not an error)\n"
            "  --entry DIR      for @list: which directory is the executing PROGRAM unit\n"
            "                   (auto-detected if exactly one directory holds a PROGRAM)\n"
            "  --ddi N:PATH     map READ(N)/READALL(N) to PATH (default: device 5=stdin)\n"
            "  --ddo N:PATH     map WRITE(N) to PATH (default: device 6=stdout)\n"
            "  --raf=I,R,N,F    attach random-access file F to FILE(N,...) (class-0/FILE.md),\n"
            "                   record size R bytes; I is I/O/B (accepted, not enforced --\n"
            "                   matches the historical HAL/S-FC runtime option of the same\n"
            "                   name/shape). N is a separate device-number namespace from\n"
            "                   --ddi/--ddo/READ/WRITE -- reusing the same number is fine.\n"
            "  --color=WHEN     colorize --debug output: auto (default, TTY-detected),\n"
            "                   always, or never\n"
            "  --color-prompt=NAME    debugger prompt color (default: red)\n"
            "  --color-input=NAME     echoed debugger-input color (default: brown/yellow)\n"
            "  --color-stmt=NAME      HAL/S source-line color (default: green)\n"
            "  --color-default=NAME   everything else the debugger prints (default: black)\n"
            "                   NAME is one of black/red/green/yellow/blue/magenta/cyan/white\n"
            "                   (or brown, an alias for yellow)\n"
            "  --help           this message\n"
            "\n"
            "@list is a text file listing one HALSFC output directory per line, each\n"
            "holding a separately compiled HAL/S unit (see Plan.md's Phase 3 M6 notes).\n",
            prog, prog);
}

static bool file_exists(const char *path) {
    struct stat st;
    return stat(path, &st) == 0;
}

/* Companion-file auto-discovery, following the same directory-relative
 * convention unHALMAT.py uses for halmat.bin (litfile0.bin/COMMON0.out.*)
 * plus the plainer litfile.bin/COMMON0.out.bin naming the prebaked
 * Halmat/data/out_* fixtures happen to use. gzip'd memory images
 * (COMMON0.out.bin.gz) are decompressed on the fly by literal.c's
 * halmat_literal_load (via zlib, or a `gzip -dc` pipe fallback if zlib
 * wasn't available at build time) -- no manual gunzip needed. */
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

/* Opens every --ddi/--ddo mapping and wires it into `state` via
 * interp_set_device, tracking the opened FILE*s in `opened` (capped at
 * MAX_DEVICE_MAPS, one per mapping) so the caller can fclose them after
 * the run -- interp_set_device doesn't take ownership (state.h). Returns
 * false (with a message on stderr) if any path fails to open. */
static bool apply_device_maps(halmat_state_t *state, const device_map_t *maps, int num_maps,
                               FILE **opened, const char *prog) {
    for (int i = 0; i < num_maps; i++) {
        FILE *f = fopen(maps[i].path, maps[i].is_output ? "w" : "r");
        if (!f) {
            fprintf(stderr, "%s: cannot open '%s' for device %d\n", prog, maps[i].path, maps[i].device);
            return false;
        }
        opened[i] = f;
        interp_set_device(state, maps[i].device, f);
    }
    return true;
}

/* Opens every --raf mapping and wires it into `state` via
 * interp_set_raf_device (same non-owning-caller convention as
 * apply_device_maps). Opened read+write ("r+b") so a channel already
 * used for both FILE-write and FILE-read statements works without a
 * second flag -- matches the historical --raf option's own note that
 * mode is "always B" in practice. Falls back to creating the file
 * ("w+b") if it doesn't exist yet. */
static bool apply_raf_maps(halmat_state_t *state, const raf_map_t *maps, int num_maps,
                            FILE **opened, const char *prog) {
    for (int i = 0; i < num_maps; i++) {
        FILE *f = fopen(maps[i].path, "r+b");
        if (!f) f = fopen(maps[i].path, "w+b");
        if (!f) {
            fprintf(stderr, "%s: cannot open '%s' for --raf channel %d\n", prog, maps[i].path, maps[i].channel);
            return false;
        }
        opened[i] = f;
        interp_set_raf_device(state, maps[i].channel, f, maps[i].record_size);
    }
    return true;
}

static int run_single(const char *path, bool disasm, bool debug_mode, bool use_py, bool use_opt,
                       const char *litfile_opt, const char *memory_opt, int num_blanks,
                       const device_map_t *maps, int num_maps,
                       const raf_map_t *raf_maps, int num_raf_maps,
                       const debug_colors_t *colors) {
    halmat_program_t prog;
    char errbuf[512];
    if (!halmat_load(path, &prog, errbuf, sizeof(errbuf))) {
        fprintf(stderr, "yaHALMAT2: %s\n", errbuf);
        return 1;
    }

    if (disasm) {
        halmat_disasm_program(&prog, stdout);
        halmat_program_free(&prog);
        return 0;
    }

    char lit_buf[1024], mem_buf[1024];
    const char *lit_path = litfile_opt;
    const char *mem_path = memory_opt;

    /* Companion-file defaults, per confirmed convention: halmat.bin pairs
     * with litfile0.bin + COMMON0.out.bin.gz; optmat.bin (--opt) pairs
     * with litfile2.bin + COMMON2.out.bin.gz; FILE1.bin (--py, HAL_S_FC.py's
     * own naming) pairs with FILE2.bin + LIT_CHAR.bin, which is never
     * gzipped and carries no COMMON*.out symbol table at all. The plain
     * (non-.gz) litfile.bin/COMMON0.out.bin/COMMON2.out.bin fallbacks
     * remain for prebaked or manually-decompressed fixtures. Missing
     * companions are accepted transparently either way: have_literals/
     * have_symtab just stay false, degrading gracefully (blank string
     * literals, "no symbol table loaded" for --debug's `print`) rather
     * than erroring out. */
    if (!lit_path) {
        static const char *lit_candidates_py[] = {"FILE2.bin"};
        static const char *lit_candidates_opt[] = {"litfile2.bin"};
        static const char *lit_candidates_default[] = {"litfile0.bin", "litfile.bin"};
        bool found = use_py    ? find_companion(path, lit_candidates_py, 1, lit_buf, sizeof(lit_buf))
                     : use_opt ? find_companion(path, lit_candidates_opt, 1, lit_buf, sizeof(lit_buf))
                               : find_companion(path, lit_candidates_default, 2, lit_buf, sizeof(lit_buf));
        if (found) lit_path = lit_buf;
    }
    if (!mem_path) {
        static const char *mem_candidates_py[] = {"LIT_CHAR.bin"};
        static const char *mem_candidates_opt[] = {"COMMON2.out.bin.gz", "COMMON2.out.bin"};
        static const char *mem_candidates_default[] = {"COMMON0.out.bin.gz", "COMMON0.out.bin"};
        bool found = use_py    ? find_companion(path, mem_candidates_py, 1, mem_buf, sizeof(mem_buf))
                     : use_opt ? find_companion(path, mem_candidates_opt, 2, mem_buf, sizeof(mem_buf))
                               : find_companion(path, mem_candidates_default, 2, mem_buf, sizeof(mem_buf));
        if (found) mem_path = mem_buf;
    }

    halmat_literal_table_t literals;
    bool have_literals = false;
    if (lit_path) {
        if (!halmat_literal_load(lit_path, mem_path, &literals, errbuf, sizeof(errbuf))) {
            fprintf(stderr, "yaHALMAT2: %s\n", errbuf);
            halmat_program_free(&prog);
            return 1;
        }
        have_literals = true;
    }

    /* HAL_S_FC.py produces no COMMON*.out at all -- --debug's `print` and
     * MATRIX/VECTOR/ARRAY declared-dimension lookups (state.h's symtab
     * field) both just degrade gracefully without it (see this project's
     * established "transparently accept, don't display/use it" pattern
     * for every other optional companion file). Loaded unconditionally
     * now (previously only under --debug) since MATRIX/VECTOR arithmetic
     * needs it in ordinary (non-debugger) runs too. */
    halmat_symtab_t symtab;
    bool have_symtab = false;
    if (!use_py) {
        char sym_buf[1024];
        static const char *sym_candidates_opt[] = {"COMMON3.out"};
        static const char *sym_candidates_default[] = {"COMMON0.out"};
        bool found = use_opt ? find_companion(path, sym_candidates_opt, 1, sym_buf, sizeof(sym_buf))
                              : find_companion(path, sym_candidates_default, 1, sym_buf, sizeof(sym_buf));
        if (found) {
            char err2[256];
            have_symtab = halmat_symtab_load(sym_buf, &symtab, err2, sizeof(err2));
        }
    }

    /* pass1.rpt is HALSFC's PASS1 report -- its "STMT ... SOURCE ...
     * REVISION" section carries the HAL/S source text keyed by statement
     * number (srcmap.c), which --debug correlates against SMRK's
     * statement-number operand (state->current_stmt) to show source
     * alongside each instruction. Only relevant/loaded under --debug;
     * missing or unparseable degrades to instruction-only display like
     * every other optional companion file. */
    halmat_srcmap_t srcmap;
    bool have_srcmap = false;
    if (debug_mode) {
        char src_buf[1024];
        static const char *src_candidates[] = {"pass1.rpt"};
        if (find_companion(path, src_candidates, 1, src_buf, sizeof(src_buf))) {
            char err3[256];
            have_srcmap = halmat_srcmap_load(src_buf, &srcmap, err3, sizeof(err3));
        }
    }

    halmat_state_t state;
    interp_init(&state, &prog, have_literals ? &literals : NULL, num_blanks);
    if (have_symtab) interp_set_symtab(&state, &symtab);
    FILE *opened_devices[MAX_DEVICE_MAPS];
    if (!apply_device_maps(&state, maps, num_maps, opened_devices, "yaHALMAT2")) {
        interp_cleanup(&state);
        if (have_srcmap) halmat_srcmap_free(&srcmap);
        if (have_symtab) halmat_symtab_free(&symtab);
        if (have_literals) halmat_literal_free(&literals);
        halmat_program_free(&prog);
        return 1;
    }
    FILE *opened_raf[MAX_DEVICE_MAPS];
    if (!apply_raf_maps(&state, raf_maps, num_raf_maps, opened_raf, "yaHALMAT2")) {
        interp_cleanup(&state);
        for (int i = 0; i < num_maps; i++) fclose(opened_devices[i]);
        if (have_srcmap) halmat_srcmap_free(&srcmap);
        if (have_symtab) halmat_symtab_free(&symtab);
        if (have_literals) halmat_literal_free(&literals);
        halmat_program_free(&prog);
        return 1;
    }
    int rc = debug_mode ? debug_run(&state, have_symtab ? &symtab : NULL, have_srcmap ? &srcmap : NULL, colors, stdout)
                         : interp_run(&state, stdout);
    interp_cleanup(&state);
    for (int i = 0; i < num_maps; i++) fclose(opened_devices[i]);
    for (int i = 0; i < num_raf_maps; i++) fclose(opened_raf[i]);

    if (have_srcmap) halmat_srcmap_free(&srcmap);
    if (have_symtab) halmat_symtab_free(&symtab);
    if (have_literals) halmat_literal_free(&literals);
    halmat_program_free(&prog);
    return rc;
}

/* ---- Multi-unit linking (Plan.md Phase 3 M6) ----
 *
 * Scope: one executing PROGRAM (MDEF-headed) unit, plus any number of
 * data-only COMPOOL (CDEF-headed) auxiliary units providing EXTERNAL-
 * referenced values. Confirmed by compiling a real COMPOOL: it's a
 * trivial, non-looping/non-branching/non-task-spawning prologue (DECLARE
 * + optional INITIAL-value setup + CLOS), so each auxiliary unit is run
 * to completion once, in isolation, using the *unmodified* single-unit
 * interpreter -- no per-unit VAC/pc/task-scheduler plumbing is needed.
 * Its resulting values are then matched by name (via the compiler's own
 * COMMON*.out symbol table, symtab.c) against the PROGRAM unit's
 * EXTERNAL-flagged references, and seeded into the PROGRAM's SYT array
 * before it runs normally.
 *
 * Confirmed empirically (not primary-source-documented in USA003087):
 * the EXTERNAL flag (SYM_FLAGS bit 0x00100000) lands on the COMPOOL
 * BLOCK's own name in the referencing unit's symbol table (e.g. "POOL"),
 * not on the individual variables declared inside its EXTERNAL COMPOOL
 * template (e.g. "SHARED_X" carries identical flags whether declared
 * locally or via the template) -- so linking works by matching block
 * names first (confirming genuine linkage intent), then variable names
 * within that block.
 *
 * Not supported yet (documented limitation, not silently wrong):
 * multiple concurrently-*executing* PROGRAM units sharing live mutable
 * compool state (each would need to observe the others' writes in real
 * time, which needs the full per-unit VAC/scheduler plumbing this scope
 * deliberately avoids); ARRAY/MATRIX-typed EXTERNAL COMPOOL variables
 * (only plain INTEGER/SCALAR values are imported -- copying an element
 * buffer's ownership across the aux unit's interp_cleanup() safely needs
 * more than a struct copy, deferred until a test needs it). */

typedef enum { UNIT_MODE_HALMAT, UNIT_MODE_OPT, UNIT_MODE_PY } unit_mode_t;

typedef struct {
    char dir[900];
    halmat_program_t prog;
    halmat_literal_table_t literals;
    bool have_literals;
    halmat_symtab_t symtab;
    bool have_symtab;
} unit_t;

typedef struct {
    char name[128];
    halmat_syt_entry_t value;
} pending_import_t;

static bool find_leading_def(const halmat_program_t *prog, uint16_t *opcode_out, uint16_t *symbol_out) {
    for (size_t i = 0; i < prog->count && i < 5; i++) {
        uint16_t op = prog->instrs[i].opcode;
        if ((op == OP_MDEF_CONST || op == OP_CDEF_CONST || op == OP_FDEF_CONST || op == OP_PDEF_CONST) &&
            prog->instrs[i].operand_count >= 1) {
            *opcode_out = op;
            *symbol_out = prog->instrs[i].operands[0].data;
            return true;
        }
    }
    return false;
}

static const char *symtab_name_for_index(const halmat_symtab_t *t, size_t index) {
    for (size_t i = 0; i < t->count; i++) {
        if (t->entries[i].index == index) return t->entries[i].name;
    }
    return NULL;
}

static bool load_unit(const char *dir, unit_mode_t mode, unit_t *u, char *errbuf, size_t errbuf_size) {
    memset(u, 0, sizeof(*u));
    strncpy(u->dir, dir, sizeof(u->dir) - 1);

    const char *halmat_name = (mode == UNIT_MODE_OPT) ? "optmat.bin" : (mode == UNIT_MODE_PY) ? "FILE1.bin" : "halmat.bin";
    /* HAL_S_FC.py produces no COMMON*.out symbol table at all -- EXTERNAL
     * COMPOOL linking is unavailable for --py units, accepted
     * transparently (have_symtab just stays false) rather than erroring. */
    const char *sym_name = (mode == UNIT_MODE_PY) ? NULL : (mode == UNIT_MODE_OPT) ? "COMMON3.out" : "COMMON0.out";

    char halmat_path[1024];
    snprintf(halmat_path, sizeof(halmat_path), "%s/%s", dir, halmat_name);
    if (!halmat_load(halmat_path, &u->prog, errbuf, errbuf_size)) return false;

    /* Companion defaults per the same confirmed convention as run_single:
     * halmat.bin -> litfile0.bin + COMMON0.out.bin.gz; optmat.bin ->
     * litfile2.bin + COMMON2.out.bin.gz; FILE1.bin (--py) -> FILE2.bin +
     * LIT_CHAR.bin (never gzipped). Plain .bin fallbacks are kept for
     * prebaked/manually-decompressed fixtures. */
    char lit_buf[1024], mem_buf[1024];
    bool have_lit_path, have_mem_path;
    if (mode == UNIT_MODE_PY) {
        static const char *lit_c[] = {"FILE2.bin"};
        static const char *mem_c[] = {"LIT_CHAR.bin"};
        have_lit_path = find_companion(halmat_path, lit_c, 1, lit_buf, sizeof(lit_buf));
        have_mem_path = find_companion(halmat_path, mem_c, 1, mem_buf, sizeof(mem_buf));
    } else if (mode == UNIT_MODE_OPT) {
        static const char *lit_c[] = {"litfile2.bin"};
        static const char *mem_c[] = {"COMMON2.out.bin.gz", "COMMON2.out.bin"};
        have_lit_path = find_companion(halmat_path, lit_c, 1, lit_buf, sizeof(lit_buf));
        have_mem_path = find_companion(halmat_path, mem_c, 2, mem_buf, sizeof(mem_buf));
    } else {
        static const char *lit_c[] = {"litfile0.bin", "litfile.bin"};
        static const char *mem_c[] = {"COMMON0.out.bin.gz", "COMMON0.out.bin"};
        have_lit_path = find_companion(halmat_path, lit_c, 2, lit_buf, sizeof(lit_buf));
        have_mem_path = find_companion(halmat_path, mem_c, 2, mem_buf, sizeof(mem_buf));
    }

    if (have_lit_path) {
        if (!halmat_literal_load(lit_buf, have_mem_path ? mem_buf : NULL, &u->literals, errbuf, errbuf_size)) {
            halmat_program_free(&u->prog);
            return false;
        }
        u->have_literals = true;
    }
    if (sym_name) {
        char sym_path[1024];
        snprintf(sym_path, sizeof(sym_path), "%s/%s", dir, sym_name);
        if (file_exists(sym_path)) {
            u->have_symtab = halmat_symtab_load(sym_path, &u->symtab, errbuf, errbuf_size);
        }
    }
    return true;
}

static void free_unit(unit_t *u) {
    if (u->have_literals) halmat_literal_free(&u->literals);
    if (u->have_symtab) halmat_symtab_free(&u->symtab);
    halmat_program_free(&u->prog);
}

/* Cleans up every heap-allocated FUNCTION/PROCEDURE auxiliary state
 * created so far (see run_linked below) -- called on every early-return
 * error path, same as free_unit's own per-path repetition. Each entry
 * is individually malloc'd (not a `halmat_state_t[MAX_UNITS]` stack
 * array) since halmat_state_t itself is large (its own syt[]/vac[]
 * arrays), and MAX_UNITS (64) copies of it would risk overflowing a
 * constrained stack (Windows threads default to 1 MiB, per Plan.md's
 * cross-platform target -- the same concern VAC's container pointers
 * were already made heap-allocated for). */
static void free_ext_states(halmat_state_t **ext_states, int num_dirs) {
    for (int j = 0; j < num_dirs; j++) {
        if (ext_states[j]) {
            interp_cleanup(ext_states[j]);
            free(ext_states[j]);
            ext_states[j] = NULL;
        }
    }
}

static int run_linked(char **dirs, int num_dirs, unit_mode_t mode, const char *entry_dir,
                       bool disasm, int num_blanks, const device_map_t *maps, int num_maps) {
    if (num_dirs > MAX_UNITS) {
        fprintf(stderr, "yaHALMAT2: too many units in @list (max %d)\n", MAX_UNITS);
        return 1;
    }

    unit_t units[MAX_UNITS];
    char errbuf[512];
    for (int i = 0; i < num_dirs; i++) {
        if (!load_unit(dirs[i], mode, &units[i], errbuf, sizeof(errbuf))) {
            fprintf(stderr, "yaHALMAT2: %s: %s\n", dirs[i], errbuf);
            for (int j = 0; j < i; j++) free_unit(&units[j]);
            return 1;
        }
    }

    if (disasm) {
        for (int i = 0; i < num_dirs; i++) {
            printf("=== %s ===\n", dirs[i]);
            halmat_disasm_program(&units[i].prog, stdout);
        }
        for (int i = 0; i < num_dirs; i++) free_unit(&units[i]);
        return 0;
    }

    int primary = -1;
    for (int i = 0; i < num_dirs; i++) {
        uint16_t def_op, def_sym;
        bool has_def = find_leading_def(&units[i].prog, &def_op, &def_sym);
        if (entry_dir) {
            if (strcmp(units[i].dir, entry_dir) == 0) primary = i;
        } else if (has_def && def_op == OP_MDEF_CONST) {
            if (primary != -1) {
                fprintf(stderr, "yaHALMAT2: multiple PROGRAM units found (%s and %s); use --entry to select one\n",
                        units[primary].dir, units[i].dir);
                for (int j = 0; j < num_dirs; j++) free_unit(&units[j]);
                return 1;
            }
            primary = i;
        }
    }
    if (primary == -1) {
        fprintf(stderr, "yaHALMAT2: no PROGRAM unit found (or --entry didn't match any @list directory)\n");
        for (int j = 0; j < num_dirs; j++) free_unit(&units[j]);
        return 1;
    }

    /* Run every non-primary COMPOOL unit to completion, harvest any
     * values the primary EXTERNALLY references from it, by name (see
     * the comment above this function). A non-primary FDEF/PDEF
     * (FUNCTION/PROCEDURE) unit is instead kept persistently loaded --
     * not run to completion -- and matched by the same EXTERNAL-flag/
     * name convention, for the primary's own FCAL/PCAL to call into at
     * runtime via run_external_call() (interp.c). See
     * source-documentation/Multiple-file-problem.md for the motivating
     * case and design discussion. */
    pending_import_t imports[HALMAT_SYT_MAX];
    int import_count = 0;
    char wired_block_names[MAX_UNITS][128];
    int wired_count = 0;
    halmat_state_t *ext_states[MAX_UNITS] = {0};
    halmat_external_call_map_t ext_map[MAX_UNITS];
    int ext_map_count = 0;

    for (int i = 0; i < num_dirs; i++) {
        if (i == primary) continue;

        uint16_t def_op, def_sym;
        bool has_def = find_leading_def(&units[i].prog, &def_op, &def_sym);

        if (has_def && (def_op == OP_FDEF_CONST || def_op == OP_PDEF_CONST)) {
            ext_states[i] = malloc(sizeof(halmat_state_t));
            interp_init(ext_states[i], &units[i].prog, units[i].have_literals ? &units[i].literals : NULL, num_blanks);
            if (units[i].have_symtab) interp_set_symtab(ext_states[i], &units[i].symtab);

            if (units[i].have_symtab && units[primary].have_symtab) {
                const char *own_name = symtab_name_for_index(&units[i].symtab, def_sym);
                if (own_name && own_name[0]) {
                    /* A CALLed PROCEDURE's name can appear *twice* in the
                     * primary unit's own symtab: an unused "template"
                     * stub entry (carrying the EXTERNAL flag, from the
                     * `D INCLUDE TEMPLATE` prototype) plus a separate,
                     * actually-referenced call-site entry (the SYT index
                     * PCAL's own operand uses) that does NOT itself carry
                     * the flag -- confirmed via a real HALSFC compile's
                     * COMMON0.out (two SYMTAB records named DOUBLE_IT,
                     * only the unused one flagged 0x00100040). A plain
                     * halmat_symtab_find() (first-match-by-name) would
                     * silently wire the unused stub's index instead of
                     * the one PCAL actually reads, so instead: confirm
                     * EXTERNAL-ness via *any* matching entry, then wire
                     * *every* entry sharing this name (harmless even in
                     * the FUNCTION case, where there's normally just the
                     * one entry). */
                    bool flagged = false;
                    for (size_t k = 0; k < units[primary].symtab.count; k++) {
                        const halmat_symtab_entry_t *e = &units[primary].symtab.entries[k];
                        if (e->name[0] && strcmp(e->name, own_name) == 0 && (e->flags & HALMAT_SYM_FLAG_EXTERNAL)) {
                            flagged = true;
                            break;
                        }
                    }
                    if (flagged) {
                        if (wired_count < MAX_UNITS) {
                            strncpy(wired_block_names[wired_count], own_name, sizeof(wired_block_names[wired_count]) - 1);
                            wired_block_names[wired_count][sizeof(wired_block_names[wired_count]) - 1] = '\0';
                            wired_count++;
                        }
                        for (size_t k = 0; k < units[primary].symtab.count; k++) {
                            const halmat_symtab_entry_t *e = &units[primary].symtab.entries[k];
                            if (!e->name[0] || strcmp(e->name, own_name) != 0) continue;
                            if (ext_map_count < MAX_UNITS && e->index < HALMAT_SYT_MAX) {
                                ext_map[ext_map_count].local_syt = (uint16_t)e->index;
                                ext_map[ext_map_count].target_state = ext_states[i];
                                ext_map[ext_map_count].target_entry_syt = def_sym;
                                ext_map_count++;
                            }
                        }
                    }
                }
            }
            continue;
        }

        if (!has_def || def_op != OP_CDEF_CONST) {
            fprintf(stderr, "yaHALMAT2: %s: only COMPOOL/FUNCTION/PROCEDURE auxiliary units are supported (not the PROGRAM entry point)\n",
                    units[i].dir);
            free_ext_states(ext_states, num_dirs);
            for (int j = 0; j < num_dirs; j++) free_unit(&units[j]);
            return 1;
        }

        halmat_state_t aux;
        interp_init(&aux, &units[i].prog, units[i].have_literals ? &units[i].literals : NULL, num_blanks);
        if (units[i].have_symtab) interp_set_symtab(&aux, &units[i].symtab);
        interp_run(&aux, stdout);

        bool wired_in = false;
        if (units[i].have_symtab && units[primary].have_symtab) {
            const char *block_name = symtab_name_for_index(&units[i].symtab, def_sym);
            if (block_name && block_name[0]) {
                const halmat_symtab_entry_t *ref = halmat_symtab_find(&units[primary].symtab, block_name);
                wired_in = (ref != NULL) && (ref->flags & HALMAT_SYM_FLAG_EXTERNAL);
            }
        }

        if (wired_in) {
            const char *block_name = symtab_name_for_index(&units[i].symtab, def_sym);
            if (wired_count < MAX_UNITS) {
                strncpy(wired_block_names[wired_count], block_name, sizeof(wired_block_names[wired_count]) - 1);
                wired_block_names[wired_count][sizeof(wired_block_names[wired_count]) - 1] = '\0';
                wired_count++;
            }
            for (size_t k = 0; k < units[i].symtab.count; k++) {
                const char *name = units[i].symtab.entries[k].name;
                if (!name[0]) continue;
                if (strcmp(name, symtab_name_for_index(&units[i].symtab, def_sym)) == 0) continue; /* the block's own name */
                const halmat_symtab_entry_t *primary_ref = halmat_symtab_find(&units[primary].symtab, name);
                if (!primary_ref) continue;
                size_t aux_index = units[i].symtab.entries[k].index;
                if (aux_index >= HALMAT_SYT_MAX || primary_ref->index >= HALMAT_SYT_MAX) continue;
                if (import_count >= HALMAT_SYT_MAX) break;
                strncpy(imports[import_count].name, name, sizeof(imports[import_count].name) - 1);
                imports[import_count].value.type = aux.syt[aux_index].type;
                imports[import_count].value.value = aux.syt[aux_index].value;
                imports[import_count].value.scalar = aux.syt[aux_index].scalar;
                imports[import_count].value.elements = NULL; /* ARRAY/MATRIX EXTERNAL values not yet supported -- see comment above */
                imports[import_count].value.element_count = 0;
                import_count++;
            }
        }

        interp_cleanup(&aux);
    }

    /* Unresolved-external check: every EXTERNAL-flagged block name in the
     * primary's own symtab must have been matched to some auxiliary
     * unit above -- mirroring a normal linker's undefined-symbol error,
     * surfaced at startup rather than silently defaulting the reference
     * to zero at runtime. */
    if (units[primary].have_symtab) {
        bool unresolved = false;
        for (size_t k = 0; k < units[primary].symtab.count; k++) {
            if (!(units[primary].symtab.entries[k].flags & HALMAT_SYM_FLAG_EXTERNAL)) continue;
            const char *name = units[primary].symtab.entries[k].name;
            if (!name[0]) continue;
            bool found = false;
            for (int w = 0; w < wired_count; w++) {
                if (strcmp(wired_block_names[w], name) == 0) { found = true; break; }
            }
            if (!found) {
                fprintf(stderr, "yaHALMAT2: unresolved external '%s' (no @list unit defines this COMPOOL/FUNCTION/PROCEDURE)\n", name);
                unresolved = true;
            }
        }
        if (unresolved) {
            free_ext_states(ext_states, num_dirs);
            for (int j = 0; j < num_dirs; j++) free_unit(&units[j]);
            return 1;
        }
    }

    /* Seed the primary unit's EXTERNAL-flagged slots, then run it normally. */
    halmat_state_t primary_state;
    interp_init(&primary_state, &units[primary].prog,
                units[primary].have_literals ? &units[primary].literals : NULL, num_blanks);
    if (units[primary].have_symtab) interp_set_symtab(&primary_state, &units[primary].symtab);
    if (ext_map_count > 0) interp_set_external_units(&primary_state, ext_map, ext_map_count);

    for (int k = 0; k < import_count; k++) {
        const halmat_symtab_entry_t *primary_ref =
            units[primary].have_symtab ? halmat_symtab_find(&units[primary].symtab, imports[k].name) : NULL;
        if (!primary_ref) continue;
        primary_state.syt[primary_ref->index] = imports[k].value;
    }

    FILE *opened_devices[MAX_DEVICE_MAPS];
    if (!apply_device_maps(&primary_state, maps, num_maps, opened_devices, "yaHALMAT2")) {
        interp_cleanup(&primary_state);
        free_ext_states(ext_states, num_dirs);
        for (int j = 0; j < num_dirs; j++) free_unit(&units[j]);
        return 1;
    }
    int rc = interp_run(&primary_state, stdout);
    interp_cleanup(&primary_state);
    for (int i = 0; i < num_maps; i++) fclose(opened_devices[i]);
    free_ext_states(ext_states, num_dirs);

    for (int i = 0; i < num_dirs; i++) free_unit(&units[i]);
    return rc;
}

static bool read_list_file(const char *path, char dirs[][900], int *count, int max) {
    FILE *f = fopen(path, "r");
    if (!f) return false;
    char line[1024];
    *count = 0;
    while (fgets(line, sizeof(line), f) && *count < max) {
        size_t len = strlen(line);
        while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r' || line[len - 1] == ' ')) line[--len] = '\0';
        if (len == 0) continue;
        strncpy(dirs[*count], line, 899);
        (*count)++;
    }
    fclose(f);
    return true;
}

int main(int argc, char **argv) {
    bool disasm = false;
    bool debug_mode = false;
    const char *path = NULL;
    const char *litfile_opt = NULL;
    const char *memory_opt = NULL;
    const char *entry_opt = NULL;
    bool use_opt = false;
    bool use_py = false;
    int num_blanks = 5;
    device_map_t maps[MAX_DEVICE_MAPS];
    int num_maps = 0;
    raf_map_t raf_maps[MAX_DEVICE_MAPS];
    int num_raf_maps = 0;
    static char raf_paths[MAX_DEVICE_MAPS][1024];
    const char *color_when = "auto";
    const char *color_prompt_name = "red";
    const char *color_input_name = "brown";
    const char *color_stmt_name = "green";
    const char *color_default_name = "black";

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--disasm") == 0) {
            disasm = true;
        } else if (strcmp(argv[i], "--debug") == 0) {
            debug_mode = true;
        } else if (strcmp(argv[i], "--litfile") == 0 && i + 1 < argc) {
            litfile_opt = argv[++i];
        } else if (strcmp(argv[i], "--memory") == 0 && i + 1 < argc) {
            memory_opt = argv[++i];
        } else if (strcmp(argv[i], "--num-blanks") == 0 && i + 1 < argc) {
            num_blanks = atoi(argv[++i]);
        } else if (strcmp(argv[i], "--opt") == 0) {
            use_opt = true;
        } else if (strcmp(argv[i], "--py") == 0) {
            use_py = true;
        } else if (strcmp(argv[i], "--entry") == 0 && i + 1 < argc) {
            entry_opt = argv[++i];
        } else if ((strcmp(argv[i], "--ddi") == 0 || strcmp(argv[i], "--ddo") == 0) && i + 1 < argc) {
            bool is_output = (strcmp(argv[i], "--ddo") == 0);
            const char *arg = argv[++i];
            const char *colon = strchr(arg, ':');
            if (!colon) {
                fprintf(stderr, "%s: %s expects N:PATH (e.g. 7:input.txt)\n", argv[0], is_output ? "--ddo" : "--ddi");
                return 1;
            }
            if (num_maps >= MAX_DEVICE_MAPS) {
                fprintf(stderr, "%s: too many --ddi/--ddo mappings (max %d)\n", argv[0], MAX_DEVICE_MAPS);
                return 1;
            }
            maps[num_maps].device = atoi(arg);
            maps[num_maps].path = colon + 1;
            maps[num_maps].is_output = is_output;
            num_maps++;
        } else if (strncmp(argv[i], "--raf=", 6) == 0) {
            if (num_raf_maps >= MAX_DEVICE_MAPS) {
                fprintf(stderr, "%s: too many --raf mappings (max %d)\n", argv[0], MAX_DEVICE_MAPS);
                return 1;
            }
            char mode;
            int record_size, channel;
            char filename[1024];
            if (sscanf(argv[i], "--raf=%c,%d,%d,%1023[^\n\r]", &mode, &record_size, &channel, filename) != 4) {
                fprintf(stderr, "%s: --raf expects I,R,N,F (e.g. --raf=B,1024,1,data.bin)\n", argv[0]);
                return 1;
            }
            strncpy(raf_paths[num_raf_maps], filename, sizeof(raf_paths[num_raf_maps]) - 1);
            raf_paths[num_raf_maps][sizeof(raf_paths[num_raf_maps]) - 1] = '\0';
            raf_maps[num_raf_maps].channel = channel;
            raf_maps[num_raf_maps].record_size = record_size;
            raf_maps[num_raf_maps].path = raf_paths[num_raf_maps];
            raf_maps[num_raf_maps].mode = mode;
            num_raf_maps++;
        } else if (strncmp(argv[i], "--color=", 8) == 0) {
            color_when = argv[i] + 8;
        } else if (strncmp(argv[i], "--color-prompt=", 15) == 0) {
            color_prompt_name = argv[i] + 15;
        } else if (strncmp(argv[i], "--color-input=", 14) == 0) {
            color_input_name = argv[i] + 14;
        } else if (strncmp(argv[i], "--color-stmt=", 13) == 0) {
            color_stmt_name = argv[i] + 13;
        } else if (strncmp(argv[i], "--color-default=", 16) == 0) {
            color_default_name = argv[i] + 16;
        } else if (strcmp(argv[i], "--help") == 0) {
            usage(argv[0]);
            return 0;
        } else if (argv[i][0] == '-') {
            fprintf(stderr, "%s: unrecognized option '%s'\n", argv[0], argv[i]);
            usage(argv[0]);
            return 1;
        } else if (!path) {
            path = argv[i];
        } else {
            fprintf(stderr, "%s: only one HALMAT_FILE or @list argument is supported\n", argv[0]);
            return 1;
        }
    }

    if (!path) {
        usage(argv[0]);
        return 1;
    }

    debug_colors_t colors = {0};
    if (strcmp(color_when, "always") == 0) {
        colors.enabled = true;
    } else if (strcmp(color_when, "never") == 0) {
        colors.enabled = false;
    } else if (strcmp(color_when, "auto") == 0) {
        colors.enabled = halmat_isatty(1) != 0; /* fd 1 = stdout */
    } else {
        fprintf(stderr, "%s: --color expects auto, always, or never\n", argv[0]);
        return 1;
    }
    if (!debug_color_by_name(color_prompt_name, &colors.prompt_code) ||
        !debug_color_by_name(color_input_name, &colors.input_code) ||
        !debug_color_by_name(color_stmt_name, &colors.stmt_code) ||
        !debug_color_by_name(color_default_name, &colors.other_code)) {
        fprintf(stderr, "%s: --color-* names must be one of black/red/green/yellow/blue/magenta/cyan/white/brown\n", argv[0]);
        return 1;
    }

    if (use_opt && use_py) {
        fprintf(stderr, "%s: --opt and --py are mutually exclusive\n", argv[0]);
        return 1;
    }
    unit_mode_t mode = use_py ? UNIT_MODE_PY : use_opt ? UNIT_MODE_OPT : UNIT_MODE_HALMAT;

    if (path[0] == '@') {
        char dirs[MAX_UNITS][900];
        int num_dirs = 0;
        if (!read_list_file(path + 1, dirs, &num_dirs, MAX_UNITS)) {
            fprintf(stderr, "%s: cannot read list file '%s'\n", argv[0], path + 1);
            return 1;
        }
        if (num_dirs == 0) {
            fprintf(stderr, "%s: '%s' lists no directories\n", argv[0], path + 1);
            return 1;
        }
        char *dir_ptrs[MAX_UNITS];
        for (int i = 0; i < num_dirs; i++) dir_ptrs[i] = dirs[i];
        return run_linked(dir_ptrs, num_dirs, mode, entry_opt, disasm, num_blanks, maps, num_maps);
    }

    return run_single(path, disasm, debug_mode, use_py, use_opt, litfile_opt, memory_opt, num_blanks, maps, num_maps, raf_maps, num_raf_maps, &colors);
}
