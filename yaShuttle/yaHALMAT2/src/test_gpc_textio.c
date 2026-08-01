/* Verifies WRITE/READ actually flow through GpcOutputFn/GpcInputFn
 * end-to-end, purely via the GpcOps surface (yaHALMAT2_ops.initializer's
 * output/input parameters + yaHALMAT2_ops.engine()) -- not by reaching
 * into interp_set_device()/state->devices[] directly, and not just
 * checking that the program halts. Exactly the class of gap
 * RELAY-TO-YAHALMAT2-TextIO.txt's own section 3 flagged: a real,
 * independently-existing bug on yaGPC2's side (yagpc2_engine() bypassing
 * halucp_check_trap(), so WRITE/READ silently executed as raw object
 * code) that nothing in that project's existing test suite caught,
 * because every test there only checked GpcEngineStatus transitions,
 * never actual WRITE content.
 *
 * Uses tests/hal/test_add154.hal (READ(5) A, ARRAY(100) SCALAR; WRITE(6)
 * the running total) -- already has a known-good stdin/expected-output
 * pair from run_read_fixture.sh's own add154 line, reused here verbatim
 * but fed through GpcInputFn/GpcOutputFn instead of real stdin/stdout.
 *
 * Usage: gpc_textio_test HALMAT_BIN_PATH
 * Exit 0 on success, 1 with a diagnostic on stderr on any failure. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "yaGpcIntegration.h"

typedef struct {
    char out_buf[256];
    size_t out_len;
    int out_last_channel;
    bool in_provided;
} textio_ctx_t;

static void capture_output(void *ioCtx, int channel, const char *text) {
    textio_ctx_t *ctx = (textio_ctx_t *)ioCtx;
    ctx->out_last_channel = channel;
    size_t n = strlen(text);
    if (ctx->out_len + n < sizeof(ctx->out_buf)) {
        memcpy(ctx->out_buf + ctx->out_len, text, n);
        ctx->out_len += n;
        ctx->out_buf[ctx->out_len] = '\0';
    }
}

/* One line, then EOF -- test_add154.hal's own single `READ(5) A;` (a
 * whole ARRAY(100) SCALAR) consumes exactly this one line: the
 * terminating ';' leaves every unread element at its INITIAL(0), which
 * is also what the program's own DO FOR ... UNTIL A(I)=0 loop uses to
 * find the end of the real data (read_array_early_termination_stale_
 * iobuf, interp.c) -- so this single-line answer is a complete,
 * correct input for the whole program, exercising device_input_refill()
 * exactly once. */
static bool provide_input(void *ioCtx, int channel, char *buf, size_t bufSize) {
    textio_ctx_t *ctx = (textio_ctx_t *)ioCtx;
    if (channel != 5 || ctx->in_provided) return false;
    ctx->in_provided = true;
    snprintf(buf, bufSize, "-3.95, -17.31, -9.93, 572.35, -250, +1.10, -.45, +7.50;");
    return true;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s halmat.bin\n", argv[0]);
        return 1;
    }

    textio_ctx_t ctx;
    memset(&ctx, 0, sizeof(ctx));

    GpcState gpc;
    memset(&gpc, 0, sizeof(gpc));
    gpc.gpcID = 1;
    gpc.emulator = GPC_EMULATOR_HALMAT;

    if (!yaHALMAT2_ops.initializer(&gpc, argv[1], NULL, NULL, NULL, capture_output, provide_input, &ctx)) {
        fprintf(stderr, "FAIL: initializer failed\n");
        return 1;
    }

    GpcEngineStatus status = GPC_ENGINE_RUNNING;
    long iterations = 0;
    const long max_iterations = 1000000;
    while (status >= 0) {
        if (++iterations > max_iterations) {
            fprintf(stderr, "FAIL: exceeded %ld iterations without halting\n", max_iterations);
            return 1;
        }
        status = yaHALMAT2_ops.engine(&gpc);
    }

    if (status != GPC_ENGINE_HALTED_NORMAL) {
        fprintf(stderr, "FAIL: final status = %s (%d), expected HALTED_NORMAL\n",
                gpc_engine_status_message(status), (int)status);
        return 1;
    }
    if (!ctx.in_provided) {
        fprintf(stderr, "FAIL: input callback was never invoked -- READ did not route through GpcInputFn\n");
        return 1;
    }

    /* This program's one and only WRITE is also the last line ever
     * written to device 6 -- per device_mech's own "last line stays
     * open/buffered" contract (state.h), that line is only flushed (and
     * so only reaches GpcOutputFn) by interp_cleanup(), called here via
     * release(). Checking the captured output before this point would
     * see nothing yet, not a bug in the routing itself. */
    yaHALMAT2_ops.release(&gpc);
    if (gpc.impl != NULL) {
        fprintf(stderr, "FAIL: release() did not set state->impl = NULL\n");
        return 1;
    }

    if (ctx.out_last_channel != 6) {
        fprintf(stderr, "FAIL: output callback's last channel = %d, expected 6\n", ctx.out_last_channel);
        return 1;
    }
    static const char expected[] = "TOTAL IS       9.8930933E+02\n";
    if (strcmp(ctx.out_buf, expected) != 0) {
        fprintf(stderr, "FAIL: captured output mismatch\n  expected: %s  actual:   %s\n", expected, ctx.out_buf);
        return 1;
    }

    printf("PASS: gpc_textio_test (captured via GpcOutputFn: %s)", ctx.out_buf);
    return 0;
}
