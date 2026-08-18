/* Standalone helper for test/bcenet_smoke.sh's receive-direction check --
 * not a unit test in its own right (no assertions of its own; the shell
 * script greps its stdout). Exercises bcenet_transport_recv() (layer 3)
 * directly, in isolation from the CPU/BCE instruction pipeline, since a
 * batch (non-interactive, non-paced) yaGPC2 run completes too fast to
 * reliably race an external sender within one process's lifetime -- see
 * bcenet_smoke.sh's own header comment. Polls for up to 5 seconds. */
#define _DEFAULT_SOURCE /* usleep() under -std=c11's strict mode */
#include <stdio.h>
#include <unistd.h>

#include "../src/bcenet_transport.h"

int main(void) {
    BceNetTransport *t = bcenet_transport_create();
    if (!bcenet_transport_open_bus(t, 6)) {
        fprintf(stderr, "open_bus(6) failed\n");
        return 1;
    }
    uint16_t words[64];
    size_t count = 0;
    for (int i = 0; i < 100; i++) {
        /* isShuttleBus=false: matches how nsts-sim-gpc's own
         * com/lru.civet actually constructs its buses (2-arg
         * `new Bus(name, busConfig[name])`, no IUA-prefix framing) --
         * see bcenet_framer.c's own header comment on the bug this
         * mismatch caused. */
        if (bcenet_transport_recv(t, 6, 1, false, words, 64, &count)) {
            printf("RECEIVED %zu words:", count);
            for (size_t j = 0; j < count; j++) printf(" 0x%04x", words[j]);
            printf("\n");
            bcenet_transport_free(t);
            return 0;
        }
        usleep(50000);
    }
    printf("TIMEOUT\n");
    bcenet_transport_free(t);
    return 1;
}
