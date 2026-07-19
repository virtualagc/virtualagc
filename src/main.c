#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "disasm.h"
#include "halmat.h"

static void usage(const char *prog) {
    fprintf(stderr, "usage: %s [--disasm] HALMAT_FILE\n", prog);
}

int main(int argc, char **argv) {
    bool disasm = false;
    const char *path = NULL;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--disasm") == 0) {
            disasm = true;
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
    } else {
        fprintf(stderr, "%s: loaded %zu instructions from '%s'; interpreter not yet implemented (M2/M4)\n",
                argv[0], prog.count, path);
    }

    halmat_program_free(&prog);
    return 0;
}
