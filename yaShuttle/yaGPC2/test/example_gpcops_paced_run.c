/* example_gpcops_paced_run.c -- simplest-possible Shuttle-sim-style driver:
 * uses only the GpcOps abstraction (no yaGPC2-specific names), hard-coded
 * .fcm/symbols paths, no debugger -- and paces itself against real time,
 * running a small batch of instructions at full speed, then sleeping off
 * however far ahead of real time that batch put it (GpcState.elapsedTime
 * is in microseconds, per yaGpcIntegration.h's own comment), then
 * repeating. This is what an integrator embedding yaGPC2 (or yaHALMAT2,
 * unchanged except for swapping which GpcOps it points at) as one of
 * several GPC instances in a larger simulator would actually write.
 *
 * `Ops` (not a direct `yaGPC2_ops.foo()` call anywhere below) is the
 * point: swapping this example to drive yaHALMAT2 instead is nothing
 * more than changing FCM_PATH/SYMBOLS_PATH and this one line to
 * `const GpcOps *Ops = &yaHALMAT2_ops;` -- everything after it is unchanged.
 *
 * Stops on GpcEngineStatus rather than a fixed instruction/time budget --
 * this is what that status exists for: a driver written purely against
 * GpcOps otherwise has no way to know when a program has finished, and
 * calling the engine past that point decodes whatever memory follows as
 * garbage (confirmed directly while building an earlier version of this
 * example -- see yaGpcIntegration.h's GpcEngineFn comment).
 *
 * Not a unit test (nothing here asserts anything) -- built and run by
 * `make test` purely as a live compile+run smoke check that this example
 * keeps working as yaGpcIntegration.h evolves. Run standalone from the
 * repo root: build/test/example_gpcops_paced_run */
#ifdef _WIN32
#include <windows.h>
#else
#define _POSIX_C_SOURCE 200809L /* clock_gettime(), nanosleep() */
#include <time.h>
#endif
#include <stdio.h>

#include "yaGpcIntegration.h" /* ../yaGpcIntegration/ -- see -I in the Makefile/NMakefile */

#define FCM_PATH      "test/fixtures/hello.fcm"
#define SYMBOLS_PATH  "test/fixtures/hello-lnk101.json"
#define BATCH_SIZE    500 /* instructions run at full speed before re-checking the clock */

#ifdef _WIN32
/* clock_gettime()/CLOCK_MONOTONIC and nanosleep() are POSIX-only --
 * MSVC's headers don't declare them at all (_POSIX_C_SOURCE is a glibc
 * feature-test macro, not something MSVC honors), so this needs a
 * genuinely different implementation on Windows, not just a macro
 * workaround. Sleep()'s millisecond granularity is coarser than
 * nanosleep()'s -- fine for this example's own pacing, not something a
 * driver with tighter real-time requirements should copy as-is. */
static double now_us(void) {
    static LARGE_INTEGER freq;
    static int haveFreq;
    if (!haveFreq) {
        QueryPerformanceFrequency(&freq);
        haveFreq = 1;
    }
    LARGE_INTEGER counter;
    QueryPerformanceCounter(&counter);
    return (double)counter.QuadPart * 1e6 / (double)freq.QuadPart;
}

static void sleep_us(double us) {
    if (us > 0) Sleep((DWORD)(us / 1000.0));
}
#else
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
#endif

int main(void) {
    const GpcOps *Ops = &yaGPC2_ops; /* the only line that changes to drive yaHALMAT2 instead */

    /* No servicer, and NULL/NULL for output/input -- which, unlike
     * servicer's NULL (inert: no peripheral I/O at all), means "connect
     * HAL/S's conventional channel 6/5 to stdout/stdin, discard/EOF
     * every other channel" (see GpcOutputFn/GpcInputFn's own comments in
     * yaGpcIntegration.h). That's the whole reason hello.fcm's own
     * WRITE(6) output shows up on this example's stdout with no further
     * setup below. */
    GpcState state = {0};
    if (!Ops->initializer(&state, FCM_PATH, SYMBOLS_PATH, NULL, NULL, NULL, NULL, NULL)) {
        fprintf(stderr, "Failed to initialize from %s / %s\n", FCM_PATH, SYMBOLS_PATH);
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

    /* Before printing our own status line, not after -- release() may
     * flush one final buffered-but-not-yet-newline-terminated line of
     * the program's own output (see GpcReleaseFn's own comment), which
     * needs to reach stdout before this driver's own "stopped:" message,
     * not after it. */
    Ops->release(&state);

    fprintf(stderr, "stopped: %s (elapsedTime=%.2f us)\n", gpc_engine_status_message(status), state.elapsedTime);
    /* HALTED (-1..-3) is program-inherent termination; ERROR (-4..-9,
     * GPC_ENGINE_ERROR_INVALID_OPCODE and below) is an emulator fault. */
    return status <= GPC_ENGINE_ERROR_INVALID_OPCODE ? 1 : 0;
}
