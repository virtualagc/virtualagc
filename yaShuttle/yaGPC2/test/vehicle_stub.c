/* The unit tests link the IOP without the vehicle.  iop.c reaches the
 * vehicle in one place only -- the shared-clock stamp on its
 * YAGPC_XMITENA_TRACE line -- and pulling in vehicle.c for that would drag
 * the ICC, DEU, BCE-network and JSON code in behind it.  A test IOP has no
 * vehicle, so this is never called with a real one. */
#include "../src/vehicle.h"

double vehicle_shared_us(const Vehicle *v, int gpcId) {
    (void)v;
    (void)gpcId;
    return 0.0;
}

/* vehicle_multi() decides whether the display-bus guard in
 * iop_recv_from_cpu applies at all -- one computer driving several displays
 * is ordinary when it is the only computer there.  A test IOP has no
 * vehicle, so the answer is normally "no"; test_iop_dkbuses.c sets this to
 * exercise the guard without building a vehicle. */
bool yagpc_test_vehicle_multi = false;

bool vehicle_multi(const Vehicle *v) {
    (void)v;
    return yagpc_test_vehicle_multi;
}
