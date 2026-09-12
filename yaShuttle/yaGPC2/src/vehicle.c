/* See vehicle.h. */
#include "vehicle.h"

#include <stdio.h>
#include <string.h>

#include "bcenet_transport.h"
#include "deumodel.h"
#include "mmumodel.h"
#include "mtumodel.h"

void vehicle_init(Vehicle *v) {
    if (v == NULL) return;
    memset(v, 0, sizeof *v);
    for (int u = 0; u < 2; u++) v->mmuBus[u] = -1;
}

bool vehicle_multi(const Vehicle *v) { return v != NULL && v->nMachines > 1; }

void vehicle_note_time(Vehicle *v, double machineUs) {
    /* Monotone, and deliberately unlocked: it is a double written by whichever
     * machine is furthest ahead and read by the device models, and the worst a
     * lost update can do is leave the tape a word time behind for one pass. */
    if (v != NULL && machineUs > v->clockUs) v->clockUs = machineUs;
}

void vehicle_free(Vehicle *v) {
    if (v == NULL) return;
    /* The models report on the way out, as they did when the BatchRunner
     * owned them -- the reports are of the vehicle's devices, not of any one
     * computer, and with several machines only one set should be printed. */
    for (int u = 0; u < 2; u++) {
        if (v->mmu[u] == NULL) continue;
        mmumodel_report(v->mmu[u]);
        mmumodel_free(v->mmu[u]);
        v->mmu[u] = NULL;
    }
    if (v->deu != NULL) {
        deumodel_report(v->deu);
        deumodel_free(v->deu);
        v->deu = NULL;
    }
    for (int d = 0; d < v->nDeuExtra; d++) {
        if (v->deuExtra[d] == NULL) continue;
        fprintf(stderr, "deu%d (bus %d): ", d + 2, v->deuExtraBus[d]);
        deumodel_report(v->deuExtra[d]);
        deumodel_free(v->deuExtra[d]);
        v->deuExtra[d] = NULL;
    }
    v->nDeuExtra = 0;
    if (v->mtu != NULL) {
        mtumodel_report(v->mtu);
        mtumodel_free(v->mtu);
        v->mtu = NULL;
    }
    /* After the models: the transmit thread sends on the transport's own
     * sockets and would otherwise be doing so as they went. */
    if (v->transport != NULL) {
        bcenet_transport_free(v->transport);
        v->transport = NULL;
    }
    v->built = false;
}
