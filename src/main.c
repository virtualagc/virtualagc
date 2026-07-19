#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "disasm.h"
#include "halmat.h"
#include "interp.h"
#include "literal.h"
#include "state.h"

static void usage(const char *prog) {
    fprintf(stderr,
            "usage: %s [options] HALMAT_FILE\n"
            "options:\n"
            "  --disasm         disassemble only, do not execute\n"
            "  --litfile F      literal file (default: auto-discovered alongside HALMAT_FILE)\n"
            "  --memory F       memory-image file for string literals (default: auto-discovered)\n"
            "  --num-blanks N   blanks between WRITE items (default: 5, per USA003087 Sec. 12.2)\n"
            "  --help           this message\n",
            prog);
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

int main(int argc, char **argv) {
    bool disasm = false;
    const char *path = NULL;
    const char *litfile_opt = NULL;
    const char *memory_opt = NULL;
    int num_blanks = 5;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--disasm") == 0) {
            disasm = true;
        } else if (strcmp(argv[i], "--litfile") == 0 && i + 1 < argc) {
            litfile_opt = argv[++i];
        } else if (strcmp(argv[i], "--memory") == 0 && i + 1 < argc) {
            memory_opt = argv[++i];
        } else if (strcmp(argv[i], "--num-blanks") == 0 && i + 1 < argc) {
            num_blanks = atoi(argv[++i]);
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
            fprintf(stderr, "%s: only one HALMAT file supported so far (multi-file linking is M6)\n", argv[0]);
            return 1;
        }
    }

    if (!path) {
        usage(argv[0]);
        return 1;
    }

    halmat_program_t prog;
    char errbuf[512];
    if (!halmat_load(path, &prog, errbuf, sizeof(errbuf))) {
        fprintf(stderr, "%s: %s\n", argv[0], errbuf);
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
        /* COMMON0.out.bin.gz not auto-attached: this loader doesn't
         * decompress gzip yet (Plan.md M2/M3 follow-up). String
         * literals degrade to blanks if only the .gz variant exists. */
    }

    halmat_literal_table_t literals;
    bool have_literals = false;
    if (lit_path) {
        if (!halmat_literal_load(lit_path, mem_path, &literals, errbuf, sizeof(errbuf))) {
            fprintf(stderr, "%s: %s\n", argv[0], errbuf);
            halmat_program_free(&prog);
            return 1;
        }
        have_literals = true;
    }

    halmat_state_t state;
    interp_init(&state, &prog, have_literals ? &literals : NULL, num_blanks);
    int rc = interp_run(&state, stdout);
    interp_cleanup(&state);

    if (have_literals) halmat_literal_free(&literals);
    halmat_program_free(&prog);
    return rc;
}
