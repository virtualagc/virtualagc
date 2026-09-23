/* Starting the bus transport's transmit thread exactly once, however many
 * computers open a bus at the same moment (src/bcenet_transport.c, ledger
 * #205).
 *
 * THE DEFECT THIS HOLDS SHUT.  bcenet_transport_open_bus is called from
 * EVERY machine's own emulation thread, as that machine opens its first bus,
 * and the thread was started by an unguarded "test the flag, then create,
 * then set the flag".  Two computers opening their first bus together both
 * saw the flag clear and both created a transmit thread; t->txThread then
 * held only the second handle, so bcenet_transport_free joined that one and
 * ORPHANED the first.  The orphan went on reading t->txStop out of the
 * transport for the rest of the run, and when free(t) released it the next
 * read was of memory that had gone -- SIGSEGV inside tx_thread_main, at the
 * same instruction every time, with the main thread already inside exit()
 * flushing stdio.  Seven of those between 2026-09-21 and 2026-09-22, and not
 * one of them appeared in any log of ours; they were found in the system
 * journal.
 *
 * WHAT IS ACTUALLY CHECKED.  An orphaned thread cannot be seen from outside
 * -- that is the whole difficulty -- so the test does not try to count
 * threads.  It opens a bus from many threads at once, which is the race, and
 * then frees the transport, which is where the orphan died.  Run normally
 * that is a smoke test; run under ThreadSanitizer it is a real one, because
 * the unguarded flag is a data race TSan names outright.  The Makefile
 * builds it both ways: `make test` runs the plain one, and
 * `make tsan-bcenet` is the one that would have caught this.
 *
 * It opens REAL SOCKETS, so a machine that forbids them makes this a skip
 * rather than a failure. */
/* pthread_barrier_* are POSIX 2001 and hidden by a strict -std=c11. */
#define _POSIX_C_SOURCE 200809L

#include <stdio.h>

#ifdef HAVE_PTHREADS
#include <pthread.h>
#endif

#include "../src/bcenet_transport.h"

#define THREADS 8

static BceNetTransport *g_t;
static int g_opened;

#ifdef HAVE_PTHREADS
static pthread_barrier_t g_start;

/* Every thread opens a DIFFERENT bus, so they contend only over starting
 * the transmit thread -- which is the thing under test -- and not over one
 * bus slot. */
static void *opener(void *arg) {
    int busID = (int)(long)arg;
    pthread_barrier_wait(&g_start);      /* all at once, or there is no race */
    if (bcenet_transport_open_bus(g_t, busID, 1)) {
        __atomic_add_fetch(&g_opened, 1, __ATOMIC_SEQ_CST);
    }
    return NULL;
}
#endif

int main(void) {
#ifndef HAVE_PTHREADS
    printf("SKIP [bcenet/txthread]: this build has no threads\n");
    return 0;
#else
    g_t = bcenet_transport_create(1);
    if (g_t == NULL) {
        printf("FAIL [bcenet/txthread]: cannot create a transport\n");
        return 1;
    }

    pthread_t th[THREADS];
    pthread_barrier_init(&g_start, NULL, THREADS);
    int made = 0;
    for (int i = 0; i < THREADS; i++) {
        /* Buses 6..13: display and payload, well inside the valid range. */
        if (pthread_create(&th[i], NULL, opener, (void *)(long)(6 + i)) == 0)
            made++;
        else
            break;
    }
    if (made != THREADS) {
        for (int i = 0; i < made; i++) pthread_join(th[i], NULL);
        printf("SKIP [bcenet/txthread]: could not start %d threads\n", THREADS);
        bcenet_transport_free(g_t);
        return 0;
    }
    for (int i = 0; i < THREADS; i++) pthread_join(th[i], NULL);
    pthread_barrier_destroy(&g_start);

    if (g_opened == 0) {
        printf("SKIP [bcenet/txthread]: no bus would open (sockets not "
               "available here), so the race was never reached\n");
        bcenet_transport_free(g_t);
        return 0;
    }

    /* AND NOW THE PART THAT CRASHED: free it.  A transmit thread the free
     * did not know about is still looping on t->txStop, and this is the
     * instant that memory goes. */
    bcenet_transport_free(g_t);
    g_t = NULL;

    printf("1/1 bcenet transmit-thread checks passed (%d of %d buses opened "
           "concurrently, transport freed without crashing)\n",
           g_opened, THREADS);
    return 0;
#endif
}
