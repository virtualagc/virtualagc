/* The intercomputer bus queue's OVERFLOW POLICY (src/iccmodel.c, ledger
 * #193).
 *
 * Each (bus, receiving GPC) pair has a bounded FIFO, and reads are pull-
 * driven: words sit in it until the receiving BCE executes a receive.  A
 * computer that stops reading therefore fills its queue, and what happens
 * to the NEXT word decides whether it can ever recover.
 *
 * This models a wire, and a wire holds nothing.  The words standing in a
 * full queue are by definition the ones nobody read; the word arriving is
 * the live one.  So a full queue drops its OLDEST word and takes the
 * arrival.  Dropping the arrival instead -- which is what this did until
 * 2026-09-22 -- froze a non-reading receiver's queue full of dead words and
 * discarded every later broadcast at the door, so resuming reading returned
 * ancient traffic forever and the expiry at the read end only ever saw the
 * same stale head.
 *
 * Nothing exercised iccmodel.c at all before this; the defect was found by
 * reading the code, and the counters from the 3-CRT runs say the bound is
 * never approached while a receiver drains normally.  That makes a unit
 * test the only practical way to hold the policy in place -- a full-vehicle
 * run does not reach the case except when a computer has been voted out.
 *
 * The shared clock is deliberately left unset (iccmodel_note_shared_us is
 * never called), so at[] stays negative, no word has a judgeable age and
 * the expiry path cannot fire.  What is under test here is the bound, not
 * staleness. */
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "../src/iccmodel.h"

#define QUEUE 2048   /* ICC_QUEUE, which iccmodel.c keeps to itself */

static IccModel *m;
static int failures;

static void check(bool ok, const char *what, long got, long want) {
    if (ok) return;
    failures++;
    printf("FAIL [icc/%s]: %ld, expected %ld\n", what, got, want);
}

/* One word onto bus `bus` from GPC `from`.  A transfer is a command word
 * followed by data words; only the command word resets the position, so a
 * long run of data words is the cheapest way to fill a queue. */
static void xmit(int bus, int from, GpcServiceNumber svc, uint32_t word) {
    GpcServiceInput in;
    GpcServiceOutput out;
    memset(&in, 0, sizeof in);
    memset(&out, 0, sizeof out);
    in.busID = bus;
    in.in.word = word;
    iccmodel_service(m, from, svc, &in, &out);
}

/* Ask whether anything is waiting.  This is also how a computer ANNOUNCES
 * ITSELF: nothing is queued for one that has never touched the bus (see
 * icc_broadcast), and a real receiver's BCE polls continuously, so the
 * model sees it from the first millisecond. */
static bool poll_bus(int bus, int rx) {
    GpcServiceInput in;
    GpcServiceOutput out;
    memset(&in, 0, sizeof in);
    memset(&out, 0, sizeof out);
    in.busID = bus;
    iccmodel_service(m, rx, GPC_SVC_RECV_POLL, &in, &out);
    return out.out.poll.available;
}

/* Take one word, or report that there is none. */
static bool recv(int bus, int rx, uint32_t *word) {
    GpcServiceInput in;
    GpcServiceOutput out;
    memset(&in, 0, sizeof in);
    memset(&out, 0, sizeof out);
    in.busID = bus;
    iccmodel_service(m, rx, GPC_SVC_RECV_WORD, &in, &out);
    if (!out.out.recv.available) return false;
    *word = out.out.recv.word;
    return true;
}

int main(void) {
    const int bus = YAGPC_ICC_BUS_FIRST;
    const int tx = 1, rx = 2;
    const int extra = 500;            /* words sent past the bound */
    const int total = QUEUE + extra;

    m = iccmodel_create();
    if (m == NULL) {
        printf("FAIL [icc/create]: iccmodel_create returned NULL\n");
        return 1;
    }

    /* The receiver is in this vehicle, and says so by polling its bus.  The
     * empty poll is worth asserting on its own: a queue nobody has written
     * to must not claim a word is waiting. */
    check(poll_bus(bus, rx) == false, "empty queue offers nothing", 1, 0);

    /* One command word to open a transfer, then `total` data words, with
     * nobody on the far end reading.  Each data word carries its own index
     * in the low 16 bits so the words that survive can be named. */
    xmit(bus, tx, GPC_SVC_XMIT_CMD, 0x28007bu);
    for (int i = 0; i < total; i++)
        xmit(bus, tx, GPC_SVC_XMIT_WORD, (uint32_t)i);

    /* The queue is bounded, so the receiver holds exactly QUEUE words --
     * one of which is the command word that opened the transfer. */
    int held = 0;
    uint32_t first = 0, last = 0, w;
    while (recv(bus, rx, &w)) {
        if (held == 0) first = w;
        last = w;
        held++;
        if (held > QUEUE + extra + 8) break;   /* runaway guard */
    }
    check(held == QUEUE, "held", held, QUEUE);

    /* THE POINT.  What survived must be the NEWEST QUEUE words, so the last
     * word read is the last word sent.  Under drop-newest the reader would
     * instead have got the command word followed by data words 0.., i.e.
     * the oldest traffic, and the final 500 words would never have been
     * delivered at all. */
    check(last == (uint32_t)(total - 1), "newest word survived",
          (long)last, (long)(total - 1));

    /* And the oldest were the ones discarded.  QUEUE + extra + 1 words were
     * offered (the command word opening the transfer is one of them), so
     * extra + 1 were pushed off the front: the command word and data words
     * 0..extra-1.  The first word still held is therefore data word
     * `extra`. */
    check(first == (uint32_t)extra, "oldest words discarded",
          (long)first, (long)extra);

    /* A receiver that has caught up takes new traffic normally -- the case
     * the old policy could not reach, because its queue never emptied. */
    xmit(bus, tx, GPC_SVC_XMIT_WORD, 0xbeefu);
    bool got = recv(bus, rx, &w);
    check(got && w == 0xbeefu, "recovers after draining", got ? (long)w : -1,
          (long)0xbeefu);

    iccmodel_free(m);

    if (failures == 0) {
        printf("%d/%d icc queue checks passed\n", 5, 5);
        return 0;
    }
    printf("%d icc queue check(s) failed\n", failures);
    return 1;
}
