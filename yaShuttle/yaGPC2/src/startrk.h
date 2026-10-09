/* THE STAR TRACKERS: the -Z (ST1, behind FF1) and -Y (ST2, behind FF3)
 * image-dissector trackers, as the flight software's star tracker SOP sees
 * them through their MDM serial channel, FF card 3 channel 2 -- three data
 * words read (FIOFFIC5, X'24C42') and one command word written (FIOHO203,
 * X'20C40'), both at 6.25 Hz.  See startrk.c for the sources.
 *
 * Driven by mdmdev.c, which owns the MDMs; ON with YAGPC_MDM_DEVICES and
 * YAGPC_VEHDYN, since a tracker needs the truth vehicle's attitude to see
 * anything. */
#ifndef YAGPC_STARTRK_H
#define YAGPC_STARTRK_H

#include <stdbool.h>
#include <stdint.h>

/* The tracker behind forward MDM u: 1 (-Z) for FF1, 2 (-Y) for FF3, else 0. */
int startrk_unit(int ffUnit);

/* The three data words, at vehicle time t (s). */
void startrk_read(int k, uint16_t w[3], double t);

/* The command word, as the computers wrote it, at vehicle time t. */
void startrk_command(int k, uint16_t cmd, double t);

/* The hardwired side, from the panel (panel O6): the tracker's POWER switch
 * and whether its door is fully open.  Until a panel says otherwise both
 * trackers are powered with their doors open -- how they spend a mission
 * after the post-insertion checklist. */
void startrk_hardware(int k, bool powered, bool doorOpen, double t);

/* A session capture: the trackers' state as numbers; and back, with the
 * captured vehicle time tCap rebased to 0 as vehdyn does. */
int startrk_save(double *b, int max);
void startrk_load(const double *b, int n, double tCap);

void startrk_report(void);

/* For the tests: the star tracker k is locked on (0 none, -1 the self-test
 * light, STARTRK_LOCKED_TARGET the rendezvous target), and the Sun's M50
 * unit vector at vehicle time t. */
#define STARTRK_LOCKED_TARGET (-2)
int startrk_test_locked(int k);
void startrk_test_sun(double t, double u[3]);
/* For the tests: where tracker k would see vehdyn's first target at vehicle
 * time t -- H and V (deg, the centroid of its light, no noise), its
 * magnitude, range (m) and phase angle (deg) -- returning its NORAD id, or
 * 0 when it is not to be seen (shadowed, behind the Earth, behind the
 * tracker); and a Lambert sphere's light centroid at a phase angle, in
 * radii from its centre toward the Sun. */
int startrk_test_target(int k, double t, double hv[2], double *mag, double *rangeM, double *phaseDeg);
double startrk_test_centroid(double phaseDeg);

#endif
