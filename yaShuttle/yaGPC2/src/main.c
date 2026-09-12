/* yaGPC2 — C port of `gpc run` (AP-101 GPC batch simulator). */
#include <stdio.h>
#include <stdlib.h>

#ifdef HAVE_PTHREADS
#include <pthread.h>
#endif

#include "opts.h"
#include "run.h"
#include "vehicle.h"

#define MAX_GPCS 5

/* --gpcs: "1", "1,2,3", "1-3,5".  Returns how many computers were named, or
 * -1 on a malformed list.  Duplicates collapse and the result is sorted, so
 * "3,1,1-2" and "1-3" are the same vehicle. */
static int parse_gpcs(const char *spec, int *out) {
    bool want[MAX_GPCS + 1] = {false};
    const char *p = spec;
    while (*p != '\0') {
        char *end = NULL;
        long lo = strtol(p, &end, 10);
        if (end == p) return -1;
        long hi = lo;
        if (*end == '-') {
            p = end + 1;
            hi = strtol(p, &end, 10);
            if (end == p) return -1;
        }
        if (lo < 1 || hi > MAX_GPCS || lo > hi) return -1;
        for (long g = lo; g <= hi; g++) want[g] = true;
        p = (*end == ',') ? end + 1 : end;
        if (*end != ',' && *end != '\0') return -1;
    }
    int n = 0;
    for (int g = 1; g <= MAX_GPCS; g++)
        if (want[g]) out[n++] = g;
    return n;
}

#ifdef HAVE_PTHREADS
static void *run_one(void *arg) {
    BatchRunner *r = (BatchRunner *)arg;
    /* The return code of a machine that stopped on its own is carried back
     * through the runner rather than the thread, so a joiner does not have to
     * unpack a void*. */
    r->exitCode = batchrunner_run(r);
    return NULL;
}
#endif

int main(int argc, char **argv) {
    Options opts;
    opts_parse(argc, argv, &opts);

    /* WHICH COMPUTERS.  --gpcs names a set; --gpc-id names one, which is what
     * every existing command line says. */
    int gpcs[MAX_GPCS];
    int nGpc;
    if (opts.gpcs != NULL && *opts.gpcs != '\0') {
        nGpc = parse_gpcs(opts.gpcs, gpcs);
        if (nGpc <= 0) {
            fprintf(stderr, "--gpcs: expected a list of 1-5 such as "
                            "\"1\", \"1,2,3\" or \"1-3,5\", got \"%s\"\n",
                    opts.gpcs);
            return 1;
        }
    } else {
        long v = 1;
        if (opts.gpcId != NULL && *opts.gpcId != '\0') {
            char *end = NULL;
            v = strtol(opts.gpcId, &end, 10);
            if (end == NULL || *end != '\0' || v < 1 || v > MAX_GPCS) {
                fprintf(stderr, "--gpc-id: expected 1-5, got \"%s\"\n",
                        opts.gpcId);
                return 1;
            }
        }
        gpcs[0] = (int)v;
        nGpc = 1;
    }

    /* The debugger and the interactive REPL drive ONE machine from stdin and
     * exit out of the middle of the run loop; neither is meaningful, or safe,
     * with several. */
    if (nGpc > 1 && (opts.interactive || opts.debug)) {
        fprintf(stderr, "--gpcs with more than one computer cannot be combined "
                        "with --interactive or --debug\n");
        return 1;
    }

    /* The peripherals belong to the vehicle, not to any one computer: two
     * mass memory units, one timing unit, the display units, one set of bus
     * sockets.  The machines borrow them.  See vehicle.h. */
    Vehicle vehicle;
    vehicle_init(&vehicle);

    BatchRunner runners[MAX_GPCS];
    for (int i = 0; i < nGpc; i++)
        batchrunner_init(&runners[i], &opts, &vehicle, gpcs[i]);

    int code = 0;
    if (nGpc == 1) {
        code = (opts.interactive || opts.debug)
                   ? batchrunner_run_interactive(&runners[0])
                   : batchrunner_run(&runners[0]);
    } else {
#ifdef HAVE_PTHREADS
        /* ONE THREAD PER COMPUTER.  They are independent machines sharing
         * peripherals, not a lockstep set -- each paces itself to the wall
         * clock through its own RTPacer, which is what keeps them in step
         * with real time and so with each other. */
        pthread_t th[MAX_GPCS];
        fprintf(stderr, "vehicle: %d GPCs --", nGpc);
        for (int i = 0; i < nGpc; i++) fprintf(stderr, " GPC%d", gpcs[i]);
        fprintf(stderr, ", one thread each\n");
        for (int i = 0; i < nGpc; i++) {
            if (pthread_create(&th[i], NULL, run_one, &runners[i]) != 0) {
                fprintf(stderr, "GPC%d: cannot start its thread\n", gpcs[i]);
                return 1;
            }
        }
        for (int i = 0; i < nGpc; i++) {
            pthread_join(th[i], NULL);
            if (runners[i].exitCode != 0 && code == 0)
                code = runners[i].exitCode;
        }
#else
        fprintf(stderr, "--gpcs with more than one computer needs threads, "
                        "which this build does not have\n");
        return 1;
#endif
    }

    for (int i = 0; i < nGpc; i++) batchrunner_free(&runners[i]);
    vehicle_free(&vehicle);
    return code;
}
