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

#include "yaGpcIntegration.h"

struct MtuModel;

struct MtuModel *mtumodel_create(void);
void mtumodel_free(struct MtuModel *m);

/* The MTU reports elapsed time, so it needs the same simulated clock the
 * rest of the machine runs on. */
void mtumodel_set_clock(struct MtuModel *m, const double *clockUs);

/* True for the buses this unit answers on (20, 21, 22). */
bool mtumodel_owns_bus(int busID);

void mtumodel_service(void *ctx, GpcServiceNumber svc,
                      const GpcServiceInput *in, GpcServiceOutput *out);

void mtumodel_report(struct MtuModel *m);

#endif
