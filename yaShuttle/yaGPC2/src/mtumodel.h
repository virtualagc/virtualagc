/* An in-process Master Timing Unit.
 *
 * PASS initialises its own clock from the MTU.  AIBGPCLO does
 *
 *     IF CZ2B_DIA1$(TFCMID;14) = OFF THEN      (IOP terminate B off)
 *        DIO(AIBV_MTU_RD);
 *        DIO(AIBV_MTU_RD);
 *     END;
 *     TIME_MGT(AIBV_INIT_CLK);                 (initialise this GPC's clock)
 *
 * and FPMMTURM ("MTU REDUNDANCY MANAGEMENT (SVC 32)", whose first stated
 * function is "PRIMARY GPC INITIALIZATION OF RUNTIME") converts what those
 * reads returned, via FPMMTUFX, into the two values FCOS keeps its time in:
 * TCVTSWCH, microseconds within the current half hour, and TCVTSWCM, the
 * count of elapsed half hours.
 *
 * With nothing answering on the bus those reads returned garbage, and the
 * conversion turned it into 48 half hours -- PASS believed 24 hours had
 * elapsed after 100 seconds of run, measured on BOTH IPL paths.  Everything
 * PASS schedules by time is computed against that clock.
 *
 * The unit is device 22 on BCE 20, 21 and 22 -- FIOCBLKS' own table:
 *     FIO22020  DC X'00041416'   HW 4 / BCE 20 / NON EIU / MTU
 *     FIO22021  DC X'00041516'   HW 4 / BCE 21 / NON EIU / MTU
 *     FIO22022  DC X'00041616'   HW 4 / BCE 22 / NON EIU / MTU
 *     FIOCF003  DC H'22'         DEVICE ID (MTU ALL)
 */
#ifndef YAGPC_MTUMODEL_H
#define YAGPC_MTUMODEL_H

#include <stdbool.h>

#include "yaGpcIntegration.h"

struct MtuModel;

struct MtuModel *mtumodel_create(void);
void mtumodel_free(struct MtuModel *m);

/* The MTU reports elapsed time, so it needs the same simulated clock the
 * rest of the machine runs on. */
void mtumodel_set_clock(struct MtuModel *m, const double *clockUs);
/* The wall-clock time the simulated clock's zero stands for, in Unix epoch
 * seconds -- the CPU's dateTimeAnchorEpochSec, which --date-time-epoch sets
 * and which otherwise is the host's time at start-up.  With it the unit
 * reports that plus elapsed time as LOCAL day-of-year/hh:mm:ss, the time
 * base DATE() and CLOCKTIME() already use; without it, elapsed time from
 * day 0, as before. */
void mtumodel_set_epoch(struct MtuModel *m, const double *epochSec);

/* Simulated microseconds of the time of day that the calling computer's own
 * clock does not contain: whatever its real-time pacer wrote off while the
 * computer was held in HALT, or stopped by a debugger.  The timing unit is a
 * separate box that kept running, so its time of day includes that time
 * while the computer's elapsed time -- GPCIPL's clock -- rightly does not.
 * Set per call, like the clock.  NULL = none. */
void mtumodel_set_clock_offset(struct MtuModel *m, const double *offsetUs);

/* THE VEHICLE'S SHARED CLOCK, in simulated microseconds, or negative when
 * there is none (a single machine, or one held in reset with no place in the
 * group's frame).  run.c's router_shared_us.
 *
 * WHY THE UNIT NEEDS IT.  A real timing unit has ONE oscillator, and its
 * three accumulators are three taps off it.  This model was given whichever
 * COMPUTER happened to be calling -- mtumodel_set_clock(br->mtu, br->clockUs)
 * -- so accumulator 1, read by GPC1 on bus 20, came from GPC1's clock while
 * accumulator 2, read by GPC2 on bus 21, came from GPC2's.  FPMMTURM then
 * compares the three, which is a comparison of three computers' clocks
 * wearing a timing unit's name.  The mass memory model has been given the
 * shared clock from the start (mmumodel_service_as takes it as an argument);
 * this one never was. */
void mtumodel_set_shared_us(struct MtuModel *m, double sharedUs);

/* How many words the commanding BCE has armed a receive for, or -1 for none
 * -- run.c gets it from iop_bce_armed_words, which explains why.  Set per
 * call, like the clock. */
void mtumodel_set_armed_words(struct MtuModel *m, int words);

/* The buses this model services, as a bit per bus number.
 *
 * WHY IT IS A FUNCTION AND NOT A NUMBER IN run.c.  Those buses have to be
 * marked for Listen Mode, because this model shows a listener the commander's
 * command word and a Listen-Mode BCE waits for one before it starts timing
 * out data.  The mask in run.c was written when this model answered only
 * 20-22 and was NOT extended when it took over 14-17 and 23 -- so listeners
 * there never awaited a command, timed out on the message time-out instead,
 * were retried, and took a word every 40 ms where the ones on 20-22 take one
 * every 33 us (ledger #131-#133 is the same defect on the ICC buses).
 * Deriving it here means the two cannot drift apart again. */
uint32_t mtumodel_bus_mask(void);

/* True for the buses this unit answers on (20, 21, 22). */
bool mtumodel_owns_bus(int busID);

void mtumodel_service(void *ctx, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out);
/* The same, for a caller that names itself: each computer on a bus has its
 * own copy of the reply, and a listener is shown the commander's command
 * word first, marked command sync (busword.h).  gpcId 0 is an unnamed
 * caller, which is what mtumodel_service passes. */
void mtumodel_service_as(struct MtuModel *m, int gpcId, GpcServiceNumber svc,
                         const GpcServiceInput *in, GpcServiceOutput *out);

void mtumodel_report(struct MtuModel *m);

/* THE UNIT'S PENDING REPLIES IN A CAPTURE.  A machine that had asked the
 * timing unit for the time and not yet collected the answer resumes waiting
 * for words that were never kept.  Small, and the same shape as the other
 * two (see iccmodel.h). */
bool mtumodel_dump(const struct MtuModel *m, const char *path);
bool mtumodel_load(struct MtuModel *m, const char *path);

#endif
