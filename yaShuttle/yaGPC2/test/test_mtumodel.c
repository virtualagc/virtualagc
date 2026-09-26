/* THE TIMING UNIT AS THE OTHER COMPUTERS ON THE BUS HEAR IT (ledger #210).
 *
 * In a redundant set every member issues the same read of the timing unit:
 * the one whose MIA transmitter is enabled sends the command and the rest
 * listen (FIOPRMPG's '#RDLI 6').  A Listen-Mode BCE DISCARDS every word it is
 * handed until it sees one bearing command sync and its own IUA (iop.c's
 * bce_take_words, BCE Principles of Operation 4.1), and it waits for that
 * word indefinitely -- no time-out runs until it arrives.
 *
 * So a listener that is never echoed the command does not merely read late:
 * it throws the whole transfer away, stays armed for ever, and the MSC finds
 * that BCE busy at every look.  The commander meanwhile reads the unit
 * perfectly.  Two computers then disagree about the clock on every read, and
 * the disagreement grows with the number of reads -- which is why the change
 * that made the unit readable at all was what broke a five-computer vehicle
 * four seconds after its OPS 901 transition.
 *
 * The cause was one line: the echo was decided by 'this reader has no words
 * pending', evaluated AFTER the reply had been built, and building the timing
 * unit's reply sets every reader's count to seven.  The condition was
 * therefore FALSE for every listener on every MTU read.  It is a one-line
 * mistake that costs a redundant set, it was invisible in a run log, and it
 * is what this file is for.
 */
/* setenv, which -std=c11 alone does not declare. */
#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../src/mtumodel.h"
#include "../src/busword.h"

static struct MtuModel *m;
static double clk;
static int failures;

/* iua 10, the forward MDM, and FIOMTURD's own field: 'MTU READ - MDM FF01
 * CARD=03 CHANNEL=01'. */
#define MTU_READ  ((10u << 19) | 0x024C26u)
/* FIONSP1P, the NSP's power-discrete read through the same MDM -- the exact
 * command, from the bus-program survey (fc-bus-survey.py), not a function
 * code.  It was written here as (0x132 << 9), which is 526400 and is
 * FIOPFC17: a different device that happens to share a function code.  The
 * model used to answer by function code and so answered both; it now answers
 * by command, and this constant had to become right. */
#define NSP_READ  0x526420u

static void check(bool ok, const char *what) {
    if (ok) return;
    failures++;
    printf("FAIL [mtumodel/%s]\n", what);
}

static void command(int gpc, int bus, uint32_t cmd) {
    GpcServiceInput in;
    GpcServiceOutput out;
    memset(&in, 0, sizeof in);
    memset(&out, 0, sizeof out);
    in.busID = bus;
    in.in.word = cmd;
    mtumodel_service_as(m, gpc, GPC_SVC_XMIT_CMD, &in, &out);
}

/* One word, as a BCE would take it: poll, then read.  Returns 0 when the bus
 * is silent for this computer. */
static int word(int gpc, int bus, uint32_t *w) {
    GpcServiceInput in;
    GpcServiceOutput out;
    memset(&in, 0, sizeof in);
    memset(&out, 0, sizeof out);
    in.busID = bus;
    mtumodel_service_as(m, gpc, GPC_SVC_RECV_POLL, &in, &out);
    if (!out.out.poll.available) return 0;
    memset(&out, 0, sizeof out);
    mtumodel_service_as(m, gpc, GPC_SVC_RECV_WORD, &in, &out);
    if (!out.out.recv.available) return 0;
    *w = out.out.recv.word;
    return 1;
}

/* Everything this computer can take now: how many words, how many of them
 * carried command sync, and the first data word. */
static void drain(int gpc, int bus, int *words, int *syncs, uint32_t *first) {
    uint32_t w;
    *words = *syncs = 0;
    *first = 0xffffffffu;
    while (*words < 80 && word(gpc, bus, &w)) {
        if (w & YAGPC_BUSWORD_CMD_SYNC) (*syncs)++;
        else if (*first == 0xffffffffu) *first = w;
        (*words)++;
    }
}

/* Take exactly n words and throw them away -- a receive that is under way. */
static void partial(int gpc, int bus, int n) {
    uint32_t w;
    while (n-- > 0 && word(gpc, bus, &w)) { }
}

int main(void) {
    int words, syncs;
    uint32_t first, firstAgain;

    /* THE TEST SETS ITS OWN SWITCH.  The forward and aft MDMs are off by
     * default (see mtumodel.c); the NSP check below needs them on, and a
     * test that depends on the environment it is run in is a test that
     * quietly stops testing.  It must be set before the model reads it,
     * which envcache does once. */
    setenv("YAGPC_FC_MDM", "1", 1);

    m = mtumodel_create();
    mtumodel_set_clock(m, &clk);

    /* ---- THE UNIT HAS ONE CLOCK, AND IT RUNS -------------------------- */
    /* A real timing unit has one oscillator and its three accumulators are
     * three taps off it.  This model used to be handed whichever COMPUTER was
     * calling, so accumulator 1 came from GPC1's clock and accumulator 2 from
     * GPC2's, and FPMMTURM's comparison of the three was really a comparison
     * of three computers' clocks.  It now takes the vehicle's shared clock --
     * and "no shared clock" has to be NEGATIVE, because zero is a perfectly
     * good shared time meaning the start of the run. */
    {
        uint32_t a[8], bwords[8];
        int na = 0, nb = 0;
        /* ON A BUS OF ITS OWN: every reader is given every reply on a bus,
         * so a check that leaves readers holding undrained words changes what
         * the next check sees -- a reader still draining is deliberately not
         * echoed the next command. */
        clk = 1000000.0;                  /* one second */
        command(1, 14, MTU_READ);
        while (na < 7 && word(1, 14, &a[na])) na++;
        clk = 61000000.0;                 /* one minute later */
        command(1, 14, MTU_READ);
        while (nb < 7 && word(1, 14, &bwords[nb])) nb++;
        check(na == 7 && nb == 7, "the unit answers seven words each time");
        check(na == 7 && nb == 7 && (a[1] != bwords[1]),
              "and its time ADVANCES -- a unit reporting a fixed time is a "
              "model that was never told what time it is");
    }

    /* ---- A LISTENER IS SHOWN THE COMMAND, THEN THE WORDS --------------- */
    clk = 1000000.0;
    command(1, 20, MTU_READ);
    drain(1, 20, &words, &syncs, &first);
    check(words == 7, "the commander takes the unit's seven words");
    check(syncs == 0, "and is not echoed its own command");

    drain(2, 20, &words, &syncs, &first);
    check(syncs == 1, "a listener IS echoed the command, or it discards the lot");
    check(words == 8, "and then takes the same seven words");

    drain(3, 20, &words, &syncs, &firstAgain);
    check(syncs == 1 && words == 8, "every listener, not just the first");
    check(first == firstAgain, "and all of them get the SAME words");

    /* Nothing is left over for anyone. */
    drain(2, 20, &words, &syncs, &first);
    check(words == 0, "a drained listener takes nothing more");

    /* ---- A COMMAND FOR A BOX BEHIND THE SAME MDM ----------------------- */
    /* ASK FOR A DEFINITE NUMBER, as a BCE does: the model no longer holds a
     * count for these, it answers while the transfer lasts (see mdmOpen), so
     * "take everything" is not a thing a reader can do. */
    command(1, 20, NSP_READ);
    {
        uint32_t w1 = 0xffffffffu, w2 = 0xffffffffu;
        int got = word(2, 20, &w1) + word(2, 20, &w2);
        check(got == 2, "an NSP read reaches a listener as well");
        check((w1 & YAGPC_BUSWORD_CMD_SYNC) != 0,
              "the command first, or a Listen-Mode receive discards the lot");
        check(w2 == 0, "and it reads zero: the NSP is not powered");
    }

    /* ---- A NEW COMMAND ENDS THE LAST TRANSACTION, FOR EVERYONE --------- */
    /* THE RULE, AND IT IS bcenet_framer.c's: on a command every listener's
     * queue is cleared and the command word pushed, unconditionally --
     *     ob->recvHead = ob->recvCount = 0;
     *     queue_push(ob, busID, &marked, 1, true);
     * -- because a new command ends the last transaction on the wire.  That
     * is the only listener delivery in this tree that works across several
     * computers, and it is now this model's too.
     *
     * THIS TEST USED TO ASSERT THE OPPOSITE: that a reader part way through a
     * receive is NOT handed a command sync, on the grounds that one arriving
     * mid-receive is Table 1.2's Sync Error.  That reasoning is sound and the
     * rule built on it was still wrong, because withholding the echo LATCHES
     * the listener -- a Listen-Mode BCE stores nothing until it sees a sync,
     * so one that is not echoed can never drain, so it is "draining" for
     * ever.  Measured: 0 echoes in ten reads.  Losing the tail of one
     * transfer costs one transfer; latching costs all of them. */
    clk = 2000000.0;
    command(1, 21, MTU_READ);
    partial(2, 21, 4);                    /* the sync and three words */
    clk = 3000000.0;
    command(1, 21, MTU_READ);             /* while it is still draining */
    drain(2, 21, &words, &syncs, &first);
    check(syncs == 1, "the new command reaches it even mid-receive");
    check(words == 8, "and it gets that transfer whole, from the command word");

    /* ...and a reader that took NOTHING from the last one is in exactly the
     * same position: no reader can be starved by having ignored a transfer. */
    clk = 4000000.0;
    command(1, 17, MTU_READ);
    clk = 5000000.0;
    command(1, 17, MTU_READ);
    drain(3, 17, &words, &syncs, &first);
    check(syncs == 1 && words == 8,
          "a reader that ignored the last transfer is not starved of the next");

    /* ---- THE COMMANDER IS NEVER PASSED OVER ---------------------------- */
    clk = 5000000.0;
    command(1, 22, MTU_READ);
    partial(1, 22, 3);
    clk = 6000000.0;
    command(1, 22, MTU_READ);
    drain(1, 22, &words, &syncs, &first);
    check(words == 7, "a commander always gets the read it just issued");

    mtumodel_free(m);

    if (failures == 0) {
        printf("23/23 timing-unit bus checks passed\n");
        return 0;
    }
    printf("%d timing-unit bus check(s) failed\n", failures);
    return 1;
}
