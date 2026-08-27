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

/* Hands the model the emulated clock (&cpu.elapsedTimeUs), which is what
 * lets a read behave like a transfer down a wire instead of a handover of
 * a whole array: a word is on the bus for one word time and then it is
 * gone, and the blocks have real gaps between them.  Without this the
 * model still works, but nothing the bus program does can miss a word --
 * and missing words on purpose is exactly how the flight software skips
 * the unused tail of a partial block.  See the pacing comment in
 * mmumodel.c.  Pass NULL to go back to the unpaced behaviour. */
void mmumodel_set_clock(MmuModel *m, const double *clockUs);

/* Which BCE this unit answers on: 18 for MM1, 19 for MM2. */
int mmumodel_bus(const MmuModel *m);

/* The GpcServicerFn the emulator installs; ctx is the MmuModel. */
void mmumodel_service(void *ctx, GpcServiceNumber serviceNumber,
                      const GpcServiceInput *input, GpcServiceOutput *output);

/* Drive this unit's READY discrete onto the bus, so a crew panel (or
 * anything else listening) can see what the tape is doing -- MM1 READY is
 * register A bit 6, MM2 bit 7.  The unit is ready when it is not moving
 * data: nothing left to hand over from a read, no write in progress.
 *
 * Safe and cheap to call often, which it must be: a discrete is a level
 * and subscribers drop one they stop hearing about, so this republishes on
 * a timer as well as on a change.  A no-op unless --discretes opened the
 * bus.
 *
 * This is for observers.  What the flight software reads is still the
 * value iop.c derives from the channel, which is why nothing about the
 * boot changes when this is on -- see iop_mm_ready(). */
void mmumodel_publish_ready(MmuModel *m);

/* Counters in the shape the real unit's own report prints, so the two can
 * be compared directly. */
void mmumodel_report(const MmuModel *m);

#endif
