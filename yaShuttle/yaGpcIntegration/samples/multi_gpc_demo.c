/* multi_gpc_demo.c -- runs one yaGPC2 instance and one yaHALMAT2 instance
 * concurrently in the same process (interleaved single-stepping, no
 * threads needed -- GpcEngineFn is deliberately synchronous/one-step-
 * per-call), each routed through the same GpcOutputFn with a distinct
 * ioCtx carrying its own gpcID. Demonstrates two things at once:
 *
 *   1. A real, non-default GpcOutputFn -- prefix_output() below, not
 *      just accepting NULL's built-in stdout default like paced_run.c
 *      does.
 *   2. Genuine mixed-emulator-type multi-instance operation: the actual
 *      Shuttle-sim scenario this whole contract exists for (GPC1-GPC5
 *      as any mix of yaGPC2 and yaHALMAT2), not just "either one alone."
 *
 * Run from this directory: ./multi_gpc_demo */
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "yaGpcIntegration.h"

typedef struct {
    int gpcID;
    bool atLineStart; /* true until the first byte of the next line prints */
} PrefixCtx;

/* Prefixes each printed *line* (not each callback -- text can arrive in
 * more than one fragment before a line's terminating "\n", e.g. yaGPC2's
 * own HalUCP calls this once for buffered text and once more for "\n"
 * itself; printing "[GPCn] " on every call would prefix mid-line too) --
 * atLineStart tracks whether the next byte written starts a fresh line,
 * updated from whether this call's text itself ends in "\n". Only
 * channel 6 (HAL/S's conventional output device) is handled -- see
 * GpcOutputFn's own NULL-default comment for why that's the one that
 * matters here. */
static void prefix_output(void *ioCtx, int channel, const char *text) {
    if (channel != 6 || text[0] == '\0') return;
    PrefixCtx *ctx = (PrefixCtx *)ioCtx;
    if (ctx->atLineStart) printf("[GPC%d] ", ctx->gpcID);
    fputs(text, stdout);
    ctx->atLineStart = text[strlen(text) - 1] == '\n';
}

int main(void) {
    PrefixCtx ctx1 = {.gpcID = 1, .atLineStart = true};
    PrefixCtx ctx3 = {.gpcID = 3, .atLineStart = true};

    GpcState gpc1 = {.gpcID = 1};
    GpcState gpc3 = {.gpcID = 3};

    if (!yaGPC2_ops.initializer(&gpc1, "../yaGPC2/test/fixtures/hello.fcm",
                                 "../yaGPC2/test/fixtures/hello-lnk101.json", NULL, NULL, prefix_output, NULL,
                                 &ctx1)) {
        fprintf(stderr, "failed to initialize GPC1 (yaGPC2)\n");
        return 1;
    }
    if (!yaHALMAT2_ops.initializer(&gpc3, "../yaHALMAT2/src/tests/fixtures/hello/optmat.bin", NULL, NULL, NULL,
                                    prefix_output, NULL, &ctx3)) {
        fprintf(stderr, "failed to initialize GPC3 (yaHALMAT2)\n");
        yaGPC2_ops.release(&gpc1);
        return 1;
    }

    /* Simple round-robin single-step, no pacing (see paced_run.c for
     * that) -- keeping this demo focused on the callback/multi-instance
     * point, not duplicating the pacing logic. */
    GpcEngineStatus s1 = GPC_ENGINE_RUNNING, s3 = GPC_ENGINE_RUNNING;
    while (s1 >= GPC_ENGINE_RUNNING || s3 >= GPC_ENGINE_RUNNING) {
        if (s1 >= GPC_ENGINE_RUNNING) s1 = yaGPC2_ops.engine(&gpc1);
        if (s3 >= GPC_ENGINE_RUNNING) s3 = yaHALMAT2_ops.engine(&gpc3);
    }

    yaGPC2_ops.release(&gpc1);
    yaHALMAT2_ops.release(&gpc3);

    fprintf(stderr, "GPC1 (yaGPC2):    %s\n", gpc_engine_status_message(s1));
    fprintf(stderr, "GPC3 (yaHALMAT2): %s\n", gpc_engine_status_message(s3));

    return 0;
}
