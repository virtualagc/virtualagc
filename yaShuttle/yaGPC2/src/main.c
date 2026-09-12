/* yaGPC2 — C port of `gpc run` (AP-101 GPC batch simulator). */
#include "opts.h"
#include "run.h"
#include "vehicle.h"

int main(int argc, char **argv) {
    Options opts;
    opts_parse(argc, argv, &opts);

    /* The peripherals belong to the vehicle, not to any one computer: two
     * mass memory units, one timing unit, the display units, one set of bus
     * sockets.  The machines borrow them.  See vehicle.h. */
    Vehicle vehicle;
    vehicle_init(&vehicle);

    BatchRunner runner;
    batchrunner_init(&runner, &opts, &vehicle);

    int code = (opts.interactive || opts.debug) ? batchrunner_run_interactive(&runner) : batchrunner_run(&runner);

    batchrunner_free(&runner);
    vehicle_free(&vehicle);
    return code;
}
