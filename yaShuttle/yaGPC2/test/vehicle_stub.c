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
