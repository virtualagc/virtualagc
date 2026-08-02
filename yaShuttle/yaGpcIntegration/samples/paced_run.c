/* paced_run.c -- the canonical, genuinely emulator-agnostic "simplest
 * possible" GpcOps driver. Unlike the per-repo copies in
 * yaGPC2/test/example_gpcops_paced_run.c and
 * yaHALMAT2/src/example_gpcops_paced_run.c (which each hardcode their
 * own emulator, and exist so each repo can regression-test its own
 * library standalone, without needing its sibling to be present at
 * all) -- this one picks the emulator at *runtime*, from argv, which is
 * what actually demonstrates the point of the shared GpcOps contract:
 * one process, either (or, per multi_gpc_demo.c in this same directory,
 * both at once) emulator, chosen by nothing more than which GpcOps
 * vtable a pointer aims at.
 *
 * Runs a small batch of instructions at full speed, then sleeps off
 * however far ahead of real time that batch put it (GpcState.elapsedTime
 * is in microseconds, per yaGpcIntegration.h's own comment), then
 * repeats -- and stops on GpcEngineStatus rather than a fixed
 * instruction/time budget, since a driver written purely against GpcOps
 * otherwise has no way to know when a program has finished (see
 * yaGpcIntegration.h's GpcEngineFn comment for the real, confirmed gap
 * this status exists to close).
 *
 * Usage: paced_run <yagpc2|yahalmat2> [program-path] [symbols-path]
 * With no program-path, runs each emulator's own "hello world" fixture
 * (paths below assume the usual sibling-repo layout this whole
 * directory assumes elsewhere). symbols-path is yaGPC2-only (a linker
 * JSON providing the entry point -- see GpcInitializerFn's own comment);
 * yaHALMAT2 ignores it, since a HALMAT file's entry point is
 * self-contained. */
#ifdef _WIN32
#include <windows.h>
#else
#define _POSIX_C_SOURCE 200809L /* clock_gettime(), nanosleep() */
#include <time.h>
#endif
#include <stdio.h>
#include <string.h>

#include "yaGpcIntegration.h"

#define BATCH_SIZE 500 /* instructions run at full speed before re-checking the clock */

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

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s <yagpc2|yahalmat2> [program-path] [symbols-path]\n", argv[0]);
        return 2;
    }

    const GpcOps *Ops;
    const char *programPath;
    const char *symbolsPath = NULL;

    if (strcmp(argv[1], "yagpc2") == 0) {
        Ops = &yaGPC2_ops;
        programPath = (argc > 2) ? argv[2] : "../yaGPC2/test/fixtures/hello.fcm";
        symbolsPath = (argc > 3) ? argv[3] : "../yaGPC2/test/fixtures/hello-lnk101.json";
    } else if (strcmp(argv[1], "yahalmat2") == 0) {
        Ops = &yaHALMAT2_ops;
        programPath = (argc > 2) ? argv[2] : "../yaHALMAT2/src/tests/fixtures/hello/optmat.bin";
        symbolsPath = (argc > 3) ? argv[3] : NULL;
    } else {
        fprintf(stderr, "unknown emulator '%s' -- expected yagpc2 or yahalmat2\n", argv[1]);
        return 2;
    }

    /* No servicer, and NULL/NULL for output/input -- which means
     * "connect HAL/S's conventional channel 6/5 to stdout/stdin,
     * discard/EOF every other channel" (see GpcOutputFn/GpcInputFn's
     * own comments in yaGpcIntegration.h). That's the whole reason a
     * program's own WRITE(6) output shows up here with no further setup. */
    GpcState state = {0};
    if (!Ops->initializer(&state, programPath, symbolsPath, NULL, NULL, NULL, NULL, NULL)) {
        fprintf(stderr, "Failed to initialize %s from %s\n", argv[1], programPath);
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

    Ops->release(&state);

    fprintf(stderr, "stopped (%s): %s (elapsedTime=%.2f us)\n", argv[1], gpc_engine_status_message(status),
            state.elapsedTime);

    /* HALTED (-1..-3) is program-inherent termination; ERROR (-4..-9,
     * GPC_ENGINE_ERROR_INVALID_OPCODE and below) is an emulator fault. */
    return status <= GPC_ENGINE_ERROR_INVALID_OPCODE ? 1 : 0;
}
