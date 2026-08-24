/* A display unit (DEU) modelled in process, standing in for the real one
 * on the far end of the DK bus.
 *
 * Why this exists
 * ---------------
 * The real display unit is a separate process reached over UDP multicast,
 * which makes every run of it nondeterministic: datagrams can be dropped,
 * delivery is on wall-clock time, and the peer's own scheduling shows up
 * in our timings.  That is fine for demonstrating the thing works and
 * useless for finding out why it does not, because two runs are never
 * comparable and neither is a run of ours against a run of the reference.
 *
 * This is the same unit with the wire taken out: the same command
 * decode, the same transfer accumulation, the same poll response, and
 * the same rule for when a load completes -- ported from
 * nsts-sim-gpc/meds/deuUnit.coffee and meds/deuProto.coffee -- but
 * answering synchronously, in the same call, with no socket, no drops
 * and no pacing.
 *
 * What it is for
 * --------------
 * Deciding one question: with a peripheral that cannot lose anything and
 * answers instantly, does GPCIPL finish loading the display?  If it does,
 * the transport is still what stands between us and a working display.
 * If it does not, the fault is ours and the transport is exonerated.
 *
 * It is a diagnostic, not a peripheral.  It has no keyboard, draws
 * nothing, and models only what the load path exercises. */
#ifndef YAGPC_DEUMODEL_H
#define YAGPC_DEUMODEL_H

#include <stdbool.h>
#include <stdint.h>

#include "yaGpcIntegration.h"

typedef struct DeuModel DeuModel;

/* busID is the BCE the unit answers on -- 6 is DK1, which is where the
 * display the flight software IPLs actually sits. */
DeuModel *deumodel_create(int busID);
void deumodel_free(DeuModel *d);

/* The GpcServicerFn the emulator installs; ctx is the DeuModel. */
void deumodel_service(void *ctx, GpcServiceNumber serviceNumber, const GpcServiceInput *input,
                      GpcServiceOutput *output);

/* One line of counters in the same shape the real unit's harness prints,
 * so the two can be compared directly. */
void deumodel_report(const DeuModel *d);

#endif
