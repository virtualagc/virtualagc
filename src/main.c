#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "debug.h"
#include "disasm.h"
#include "halmat.h"
#include "interp.h"
#include "literal.h"
#include "state.h"
#include "symtab.h"

#define OP_MDEF_CONST 0x02B
#define OP_CDEF_CONST 0x02F

#define MAX_UNITS 64

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
            "  --opt            for @list: load optmat.bin (+ its companions) instead of halmat.bin\n"
            "  --entry DIR      for @list: which directory is the executing PROGRAM unit\n"
            "                   (auto-detected if exactly one directory holds a PROGRAM)\n"
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
 * (COMMON0.out.bin.gz) aren't decompressed by this loader yet -- gunzip
 * them first; see Plan.md M2/M3 for the deferred zlib-dependency follow-up. */
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

static int run_single(const char *path, bool disasm, bool debug_mode, const char *litfile_opt,
                       const char *memory_opt, int num_blanks) {
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

    if (!lit_path) {
        static const char *lit_candidates[] = {"litfile0.bin", "litfile.bin"};
        if (find_companion(path, lit_candidates, 2, lit_buf, sizeof(lit_buf))) {
            lit_path = lit_buf;
        }
    }
    if (!mem_path) {
        static const char *mem_candidates[] = {"COMMON0.out.bin"};
        if (find_companion(path, mem_candidates, 1, mem_buf, sizeof(mem_buf))) {
            mem_path = mem_buf;
        }
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

    halmat_symtab_t symtab;
    bool have_symtab = false;
    if (debug_mode) {
        char sym_buf[1024];
        static const char *sym_candidates[] = {"COMMON0.out"};
        if (find_companion(path, sym_candidates, 1, sym_buf, sizeof(sym_buf))) {
            char err2[256];
            have_symtab = halmat_symtab_load(sym_buf, &symtab, err2, sizeof(err2));
        }
    }

    halmat_state_t state;
    interp_init(&state, &prog, have_literals ? &literals : NULL, num_blanks);
    int rc = debug_mode ? debug_run(&state, have_symtab ? &symtab : NULL, stdout)
                         : interp_run(&state, stdout);
    interp_cleanup(&state);

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
        if ((op == OP_MDEF_CONST || op == OP_CDEF_CONST) && prog->instrs[i].operand_count >= 1) {
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

static bool load_unit(const char *dir, bool use_opt, unit_t *u, char *errbuf, size_t errbuf_size) {
    memset(u, 0, sizeof(*u));
    strncpy(u->dir, dir, sizeof(u->dir) - 1);

    char halmat_path[1024];
    snprintf(halmat_path, sizeof(halmat_path), "%s/%s", dir, use_opt ? "optmat.bin" : "halmat.bin");
    if (!halmat_load(halmat_path, &u->prog, errbuf, errbuf_size)) return false;

    char lit_path[1024], mem_path[1024], sym_path[1024];
    snprintf(lit_path, sizeof(lit_path), "%s/%s", dir, use_opt ? "litfile2.bin" : "litfile0.bin");
    snprintf(mem_path, sizeof(mem_path), "%s/%s", dir, use_opt ? "COMMON2.out.bin" : "COMMON0.out.bin");
    snprintf(sym_path, sizeof(sym_path), "%s/%s", dir, use_opt ? "COMMON3.out" : "COMMON0.out");

    if (file_exists(lit_path)) {
        if (!halmat_literal_load(lit_path, file_exists(mem_path) ? mem_path : NULL, &u->literals, errbuf, errbuf_size)) {
            halmat_program_free(&u->prog);
            return false;
        }
        u->have_literals = true;
    }
    if (file_exists(sym_path)) {
        u->have_symtab = halmat_symtab_load(sym_path, &u->symtab, errbuf, errbuf_size);
    }
    return true;
}

static void free_unit(unit_t *u) {
    if (u->have_literals) halmat_literal_free(&u->literals);
    if (u->have_symtab) halmat_symtab_free(&u->symtab);
    halmat_program_free(&u->prog);
}

static int run_linked(char **dirs, int num_dirs, bool use_opt, const char *entry_dir,
                       bool disasm, int num_blanks) {
    if (num_dirs > MAX_UNITS) {
        fprintf(stderr, "yaHALMAT2: too many units in @list (max %d)\n", MAX_UNITS);
        return 1;
    }

    unit_t units[MAX_UNITS];
    char errbuf[512];
    for (int i = 0; i < num_dirs; i++) {
        if (!load_unit(dirs[i], use_opt, &units[i], errbuf, sizeof(errbuf))) {
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

    /* Run every non-primary (COMPOOL) unit to completion, harvest any
     * values the primary EXTERNALLY references from it, by name. */
    pending_import_t imports[HALMAT_SYT_MAX];
    int import_count = 0;
    char wired_block_names[MAX_UNITS][128];
    int wired_count = 0;

    for (int i = 0; i < num_dirs; i++) {
        if (i == primary) continue;

        uint16_t def_op, def_sym;
        if (!find_leading_def(&units[i].prog, &def_op, &def_sym) || def_op != OP_CDEF_CONST) {
            fprintf(stderr, "yaHALMAT2: %s: only COMPOOL auxiliary units are supported (not the PROGRAM entry point)\n",
                    units[i].dir);
            for (int j = 0; j < num_dirs; j++) free_unit(&units[j]);
            return 1;
        }

        halmat_state_t aux;
        interp_init(&aux, &units[i].prog, units[i].have_literals ? &units[i].literals : NULL, num_blanks);
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
                fprintf(stderr, "yaHALMAT2: unresolved external '%s' (no @list unit defines this COMPOOL)\n", name);
                unresolved = true;
            }
        }
        if (unresolved) {
            for (int j = 0; j < num_dirs; j++) free_unit(&units[j]);
            return 1;
        }
    }

    /* Seed the primary unit's EXTERNAL-flagged slots, then run it normally. */
    halmat_state_t primary_state;
    interp_init(&primary_state, &units[primary].prog,
                units[primary].have_literals ? &units[primary].literals : NULL, num_blanks);

    for (int k = 0; k < import_count; k++) {
        const halmat_symtab_entry_t *primary_ref =
            units[primary].have_symtab ? halmat_symtab_find(&units[primary].symtab, imports[k].name) : NULL;
        if (!primary_ref) continue;
        primary_state.syt[primary_ref->index] = imports[k].value;
    }

    int rc = interp_run(&primary_state, stdout);
    interp_cleanup(&primary_state);

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
    int num_blanks = 5;

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
        } else if (strcmp(argv[i], "--entry") == 0 && i + 1 < argc) {
            entry_opt = argv[++i];
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
        return run_linked(dir_ptrs, num_dirs, use_opt, entry_opt, disasm, num_blanks);
    }

    return run_single(path, disasm, debug_mode, litfile_opt, memory_opt, num_blanks);
}
