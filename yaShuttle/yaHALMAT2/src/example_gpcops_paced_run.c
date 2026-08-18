/* example_gpcops_paced_run.c -- simplest-possible Shuttle-sim-style driver:
 * uses only the GpcOps abstraction (no yaHALMAT2-specific names), hard-coded
 * .bin/symbols paths, no debugger -- and paces itself against real time,
 * running a small batch of instructions at full speed, then sleeping off
 * however far ahead of real time that batch put it (GpcState.elapsedTime
 * is in microseconds, per yaGpcIntegration.h's own comment), then
 * repeating. This is what an integrator embedding yaHALMAT2 (or yaGPC2,
 * unchanged except for swapping which GpcOps it points at) as one of
 * several GPC instances in a larger simulator would actually write.
 *
 * This is yaHALMAT2's copy of yaGPC2's own test/example_gpcops_paced_run.c
 * -- verbatim except for FCM_PATH/SYMBOLS_PATH, the #include path, and
 * this file's own `Ops` line, exactly as intended: proof that the two
 * emulators really are interchangeable behind GpcOps, not just in theory.
 *
 * `Ops` (not a direct `yaHALMAT2_ops.foo()` call anywhere below) is the
 * point: swapping this example to drive yaGPC2 instead is nothing
 * more than changing FCM_PATH/SYMBOLS_PATH and this one line to
 * `const GpcOps *Ops = &yaGPC2_ops;` -- everything after it is unchanged.
 *
 * Stops on GpcEngineStatus rather than a fixed instruction/time budget --
 * this is what that status exists for: a driver written purely against
 * GpcOps otherwise has no way to know when a program has finished, and
 * calling the engine past that point runs into undefined behavior
 * (confirmed directly while building yaGPC2's own earlier version of this
 * example -- see yaGpcIntegration.h's GpcEngineFn comment).
 *
 * Not a unit test (nothing here asserts anything) -- built and run purely
 * as a live compile+run smoke check that this example keeps working as
 * yaGpcIntegration.h evolves. Run standalone from src/: ./example_gpcops_paced_run */
#define _POSIX_C_SOURCE 200809L /* clock_gettime(), nanosleep() */
#include <stdio.h>
#include <time.h>

#include "yaGpcIntegration.h"

/* An optmat.bin (not halmat.bin) -- built from HELLO.hal via HALSFC's
 * default (optimizing) pass, alongside its own litfile2.bin/
 * COMMON2.out.bin.gz companions in the same directory (tests/fixtures/
 * hello/), same convention yaGPC2's own hello.fcm fixture follows.
 * yaHALMAT2_initializer() (yaGpcOps.c) infers the optmat.bin companion set
 * from this exact filename. SYMBOLS_PATH is NULL: yaHALMAT2's own entry
 * point comes from the HALMAT program itself, not a linker/symbols file
 * (yaGpcIntegration.h's own comment on GpcInitializerFn's symbolsPath). */
#define FCM_PATH      "tests/fixtures/hello/optmat.bin"
#define SYMBOLS_PATH  NULL
#define BATCH_SIZE    500 /* instructions run at full speed before re-checking the clock */

static double now_us(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec * 1e6 + (double)ts.tv_nsec / 1e3;
}

static void sleep_us(double us) {
    struct timespec req;
    req.tv_sec = (time_t)(us / 1e6);
    req.tv_nsec = (long)(us - (double)req.tv_sec * 1e6) * 1000L;
    nanosleep(&req, NULL);
}

int main(void) {
    const GpcOps *Ops = &yaHALMAT2_ops; /* the only line that changes to drive yaGPC2 instead */

    /* No servicer, and NULL/NULL for output/input -- which, unlike
     * servicer's NULL (inert: no peripheral I/O at all), means "connect
     * HAL/S's conventional channel 6/5 to stdout/stdin, discard/EOF
     * every other channel" (see GpcOutputFn/GpcInputFn's own comments in
     * yaGpcIntegration.h). That's the whole reason HELLO.hal's own
     * WRITE(6) output shows up on this example's stdout with no further
     * setup below. */
    GpcState state = {0};
    if (!Ops->initializer(&state, FCM_PATH, SYMBOLS_PATH, 0.0, NULL, NULL, NULL, NULL, NULL)) { /* startEpochSeconds=0.0: deterministic epoch anchor for this demo */
        fprintf(stderr, "Failed to initialize from %s\n", FCM_PATH);
        return 1;
    }

    double wallStartUs = now_us();
    GpcEngineStatus status = GPC_ENGINE_RUNNING;

    /* status >= GPC_ENGINE_RUNNING (i.e. not negative) means "keep calling
     * engine()" -- that covers both 0 (running) and 1000+N (a HAL/S
     * runtime warning fired but execution continued normally on its own).
     * Only a negative status is terminal. */
    while (status >= GPC_ENGINE_RUNNING) {
        for (int i = 0; i < BATCH_SIZE && status >= GPC_ENGINE_RUNNING; i++) {
            status = Ops->engine(&state);
            if (status > GPC_ENGINE_RUNNING) fprintf(stderr, "warning: %s\n", gpc_engine_status_message(status));
        }

        double wallElapsedUs = now_us() - wallStartUs;
        double aheadUs = state.elapsedTime - wallElapsedUs;
        if (aheadUs > 0) sleep_us(aheadUs);
    }

    fprintf(stderr, "stopped: %s (elapsedTime=%.2f us)\n", gpc_engine_status_message(status), state.elapsedTime);

    Ops->release(&state);
    /* HALTED (-1..-3) is program-inherent termination; ERROR (-4..-9,
     * GPC_ENGINE_ERROR_INVALID_OPCODE and below) is an emulator fault. */
    return status <= GPC_ENGINE_ERROR_INVALID_OPCODE ? 1 : 0;
}
