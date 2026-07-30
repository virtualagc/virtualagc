/* yaGPC2 — C port of `gpc run` (AP-101 GPC batch simulator). */
#include "opts.h"
#include "run.h"

int main(int argc, char **argv) {
    Options opts;
    opts_parse(argc, argv, &opts);

    BatchRunner runner;
    batchrunner_init(&runner, &opts);

    int code = (opts.interactive || opts.debug) ? batchrunner_run_interactive(&runner) : batchrunner_run(&runner);

    batchrunner_free(&runner);
    return code;
}
