/* Two-instance independence smoke test for the yaGpcIntegration.h contract
 * (yaGpcOps.c): drives two separately-initialized yaHALMAT2_ops instances
 * of the same program with a deliberately uneven step interleaving and
 * confirms neither leaks state into the other. interp_step() is a safe
 * no-op once a state is halted (interp.c: "if (state->halted) return
 * true;"), so it's fine to keep calling engine() on an already-finished
 * instance for pacing purposes -- that's what makes the two instances'
 * own call counts differ even though both run the identical, fully
 * deterministic program to the same total number of *productive* steps.
 *
 * Usage: gpc_smoke_test HALMAT_BIN_PATH
 * Exit 0 on success, 1 with a diagnostic on stderr on any failure. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "interp.h"
#include "yaGpcIntegration.h"
#include "yaGpcOps.h"

static char *slurp(FILE *f, long *out_len) {
    if (fseek(f, 0, SEEK_END) != 0) return NULL;
    long len = ftell(f);
    if (len < 0 || fseek(f, 0, SEEK_SET) != 0) return NULL;
    char *buf = malloc((size_t)len + 1);
    if (!buf) return NULL;
    size_t n = fread(buf, 1, (size_t)len, f);
    buf[n] = '\0';
    if (out_len) *out_len = (long)n;
    return buf;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s halmat.bin\n", argv[0]);
        return 1;
    }
    const char *program_path = argv[1];

    GpcState gpcA, gpcB;
    memset(&gpcA, 0, sizeof(gpcA));
    memset(&gpcB, 0, sizeof(gpcB));
    gpcA.gpcID = 1;
    gpcA.emulator = GPC_EMULATOR_HALMAT;
    gpcB.gpcID = 2;
    gpcB.emulator = GPC_EMULATOR_HALMAT;

    if (!yaHALMAT2_ops.initializer(&gpcA, program_path, NULL, NULL, NULL)) {
        fprintf(stderr, "FAIL: gpcA initializer failed\n");
        return 1;
    }
    if (!yaHALMAT2_ops.initializer(&gpcB, program_path, NULL, NULL, NULL)) {
        fprintf(stderr, "FAIL: gpcB initializer failed\n");
        return 1;
    }

    if (gpcA.impl == gpcB.impl) {
        fprintf(stderr, "FAIL: gpcA.impl == gpcB.impl (%p) -- instances are not independent\n", gpcA.impl);
        return 1;
    }

    FILE *outA = tmpfile();
    FILE *outB = tmpfile();
    if (!outA || !outB) {
        fprintf(stderr, "FAIL: tmpfile() failed\n");
        return 1;
    }
    interp_set_device((halmat_state_t *)gpcA.impl, 6, outA);
    interp_set_device((halmat_state_t *)gpcB.impl, 6, outB);

    /* Deliberately uneven: one engine(&gpcA) call per two engine(&gpcB)
     * calls, every loop iteration, regardless of either instance's own
     * halted state (safe no-op once halted -- see file header comment).
     * Bounded iteration count so a regression that breaks halting can't
     * hang the test forever. */
    long callsA = 0, callsB = 0;
    long iterations = 0;
    const long max_iterations = 1000000;
    for (;;) {
        bool haltedA = ((halmat_state_t *)gpcA.impl)->halted;
        bool haltedB = ((halmat_state_t *)gpcB.impl)->halted;
        if (haltedA && haltedB) break;
        if (++iterations > max_iterations) {
            fprintf(stderr, "FAIL: exceeded %ld iterations without both instances halting\n", max_iterations);
            return 1;
        }
        yaHALMAT2_ops.engine(&gpcA);
        callsA++;
        yaHALMAT2_ops.engine(&gpcB);
        callsB++;
        yaHALMAT2_ops.engine(&gpcB);
        callsB++;
    }

    halmat_state_t *stateA = (halmat_state_t *)gpcA.impl;
    halmat_state_t *stateB = (halmat_state_t *)gpcB.impl;

    if (stateA->exit_code != 0) {
        fprintf(stderr, "FAIL: gpcA exit_code = %d, expected 0\n", stateA->exit_code);
        return 1;
    }
    if (stateB->exit_code != 0) {
        fprintf(stderr, "FAIL: gpcB exit_code = %d, expected 0\n", stateB->exit_code);
        return 1;
    }
    if (callsA == callsB) {
        fprintf(stderr, "FAIL: callsA == callsB == %ld -- interleaving was not actually uneven\n", callsA);
        return 1;
    }
    if (stateA->virtual_time != stateB->virtual_time) {
        fprintf(stderr, "FAIL: virtual_time diverged between instances (A=%lld, B=%lld) -- "
                        "identical deterministic programs must reach the same total tick cost "
                        "regardless of interleaving; this points at shared/global state\n",
                (long long)stateA->virtual_time, (long long)stateB->virtual_time);
        return 1;
    }
    if (gpcA.elapsedTime != (double)stateA->virtual_time) {
        fprintf(stderr, "FAIL: gpcA.elapsedTime (%f) != stateA->virtual_time (%lld)\n",
                gpcA.elapsedTime, (long long)stateA->virtual_time);
        return 1;
    }
    if (gpcB.elapsedTime != (double)stateB->virtual_time) {
        fprintf(stderr, "FAIL: gpcB.elapsedTime (%f) != stateB->virtual_time (%lld)\n",
                gpcB.elapsedTime, (long long)stateB->virtual_time);
        return 1;
    }
    long long final_virtual_time = (long long)stateA->virtual_time; /* captured before release() frees stateA/stateB */

    /* A WRITE's final line for a device stays buffered in device_mech
     * until something flushes it (interp.c) -- release() does this (via
     * interp_cleanup()) as part of tearing the instance down, matching
     * main.c's own run_single(), which always calls interp_cleanup()
     * before closing its device files. Going through GpcOps here rather
     * than calling yaHALMAT2's own interp_cleanup() directly is the whole
     * point of issue #79/#80 -- a driver written only against
     * yaGpcIntegration.h's types must be able to do this. Safe to call
     * now since exit_code/virtual_time/elapsedTime were already captured
     * above; release() leaves *state unspecified and gpcA.impl/gpcB.impl
     * NULL afterward. */
    yaHALMAT2_ops.release(&gpcA);
    yaHALMAT2_ops.release(&gpcB);
    if (gpcA.impl != NULL || gpcB.impl != NULL) {
        fprintf(stderr, "FAIL: release() did not set state->impl = NULL\n");
        return 1;
    }
    fflush(outA);
    fflush(outB);
    long lenA, lenB;
    char *bufA = slurp(outA, &lenA);
    char *bufB = slurp(outB, &lenB);
    if (!bufA || !bufB) {
        fprintf(stderr, "FAIL: could not read back tmpfile() output\n");
        return 1;
    }
    static const char expected[] = "          6               5\n";
    if (lenA != lenB || memcmp(bufA, bufB, (size_t)lenA) != 0) {
        fprintf(stderr, "FAIL: gpcA and gpcB output differ\n  A: %s  B: %s\n", bufA, bufB);
        return 1;
    }
    if (strcmp(bufA, expected) != 0) {
        fprintf(stderr, "FAIL: output does not match known-good repeat fixture\n  expected: %s  actual:   %s\n",
                expected, bufA);
        return 1;
    }
    free(bufA);
    free(bufB);

    printf("PASS: gpc_smoke_test (callsA=%ld callsB=%ld virtual_time=%lld)\n",
           callsA, callsB, final_virtual_time);
    return 0;
}
