/* THE DEVICES BEHIND THE FORWARD AND AFT MDMs, AS A HEALTHY VEHICLE AT REST.
 *
 * mtumodel.c speaks for the forward (FF1-4, IUA 10, buses 20-23) and aft
 * (FA1-4, IUA 12, buses 14-17) MDMs, and until this module it answered every
 * channel read of theirs with zeros -- "an MDM with nothing wired to it".
 * Zeros are not neutral to the flight software: an RCS injector temperature
 * of 0 V is a leaking jet, a manifold reporting neither open nor closed is a
 * power failure, a jet commanded to fire that shows no chamber pressure is
 * failed off, and an IMU whose BITE word lacks its GOOD bit has failed.  So
 * PASS ran with its RCS and IMUs dead, which nothing that has been flown so
 * far could see.
 *
 * This module is what is wired to those channels on a vehicle that is AT
 * REST and HEALTHY: the IMUs operating and stationary, every RCS manifold
 * open, every injector warm, and every jet the computers fire answering with
 * chamber pressure.  No motion and no physics -- that is a later layer, which
 * will replace the constants here with the vehicle's state.
 *
 * Two entry points, both called by mtumodel.c under its lock:
 *   mdmdev_output()  the data words of a WRITE command the computers sent,
 *                    once the whole message has gone out;
 *   mdmdev_reply()   the words to answer a READ with, where this module
 *                    knows them.
 *
 * OFF unless YAGPC_MDM_DEVICES is set (1/on), until it is validated; with it
 * off every read is answered exactly as before. */
#ifndef YAGPC_MDMDEV_H
#define YAGPC_MDMDEV_H

#include <stdbool.h>
#include <stdint.h>

bool mdmdev_enabled(void);

/* A write to an MDM: busID the flight-critical bus (14-17 aft, 20-23 forward),
 * cmd the 24-bit command word, words its n data words.  sharedUs is the
 * vehicle's clock, or negative if there is none. */
void mdmdev_output(int busID, uint32_t cmd, const uint16_t *words, int n,
                   double sharedUs);

/* Fill out[0..n-1] with the answer to a read, and return true; or return
 * false, leaving the caller's own answer (zeros) in place. */
bool mdmdev_reply(int busID, uint32_t cmd, int n, uint16_t *out, double sharedUs);

/* One line of what was answered, for the end-of-run report. */
void mdmdev_report(void);

#endif
