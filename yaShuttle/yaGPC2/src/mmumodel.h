/* A mass memory unit modelled in process, standing in for the one on the
 * far end of the MM bus.
 *
 * Why this exists
 * ---------------
 * The mass memory has been a separate process reached over UDP multicast,
 * which makes every run of it nondeterministic: delivery is on wall-clock
 * time, two OS processes are scheduled independently, and the peer's own
 * pacing shows up in our timings.  Chasing FCMBOOT's load-block checksum
 * ran straight into that -- two identical invocations disagreed about how
 * far the bootstrap even got, and turning on --trace, --debug or merely
 * --verbose changed the outcome again.  A fault you cannot reproduce is a
 * fault you cannot bisect.
 *
 * This is the same unit with the wire taken out: the same command decode,
 * the same position model, the same block sequencing and the same status
 * latching -- ported from nsts-sim-gpc/mmu/mmu.coffee, mmu/mmuConf.coffee
 * and mmu/volume.coffee -- but answering synchronously, in the same call,
 * with no socket, no drops and no pacing.  Run it twice and it does the
 * same thing.
 *
 * It reads the same .mmv volume files the real unit does, so the tape
 * under test is identical either way.
 *
 * What it is and is not
 * ---------------------
 * It is a second implementation of somebody else's device.  Only the
 * CoffeeScript one is authoritative, and the two can drift.  A clean run
 * here says that this emulator and the flight software agree with OUR
 * model of a mass memory; it does not say the real unit works, and it
 * cannot catch a place where we have misread the device.  Keep the
 * networked configuration as the thing that actually has to work, and use
 * this to make failures reproducible while they are being chased -- the
 * same division of labour deumodel.c already has for the display.
 */
#ifndef YAGPC_MMUMODEL_H
#define YAGPC_MMUMODEL_H

#include <stdbool.h>
#include <stdint.h>

#include "yaGpcIntegration.h"

typedef struct MmuModel MmuModel;

/* unit is 1 or 2, which fixes the bus: MM1 is BCE 18, MM2 is BCE 19.
 * volumePath may be NULL for a blank tape.  Returns NULL if the volume
 * cannot be read, having said why on stderr. */
MmuModel *mmumodel_create(int unit, const char *volumePath);
void mmumodel_free(MmuModel *m);

/* Which BCE this unit answers on: 18 for MM1, 19 for MM2. */
int mmumodel_bus(const MmuModel *m);

/* The GpcServicerFn the emulator installs; ctx is the MmuModel. */
void mmumodel_service(void *ctx, GpcServiceNumber serviceNumber,
                      const GpcServiceInput *input, GpcServiceOutput *output);

/* Counters in the shape the real unit's own report prints, so the two can
 * be compared directly. */
void mmumodel_report(const MmuModel *m);

#endif
