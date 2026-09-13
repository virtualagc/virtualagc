/* THE INTERCOMPUTER BUS, between machines in one process.
 *
 * Bus 24 is the one bus that is not a peripheral's: it is how the computers
 * tell each other what they are doing.  The inter-GPC DISCRETES carry a
 * three-bit sync code and nothing else, so everything with content -- each
 * GPC's current OPS, its common-set and redundant-set masks, its copy of
 * every other GPC's discrete input A -- travels here, redundancy-managed by
 * FCMDSCRM into CZ2BDIA, and DM6OPS reads exactly that when it works out
 * which computers are available to receive a memory configuration.
 *
 * Measured: with nothing carrying it, two computers that IPL, load, and sync
 * with each other perfectly still cannot form a set.  GPC1 transitions to
 * OPS 2 alone and GPC2 is never included, with no fault message, because
 * GPC1 has no way to learn that GPC2 exists beyond its sync code.
 *
 * This is a WIRE, not a device: a word one computer transmits is delivered
 * to every other computer's receive queue on the same bus, and to nobody
 * else.  No peripheral answers, because none is there -- on the vehicle the
 * subscribers are the other GPCs.
 */
#ifndef YAGPC_ICCMODEL_H
#define YAGPC_ICCMODEL_H

#include <stdbool.h>
#include <stdint.h>

#include "yaGpcIntegration.h"

typedef struct IccModel IccModel;

/* Bus 24, the intercomputer bus (BCENET_IP_BUS). */
#define YAGPC_ICC_BUS 24

IccModel *iccmodel_create(void);
void iccmodel_free(IccModel *m);

/* Serve one bus-24 transaction for the named computer.  Transmitted words go
 * to every OTHER computer's queue; receives take from this computer's own. */
void iccmodel_service(IccModel *m, int gpcId, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out);

void iccmodel_report(const IccModel *m);

#endif
