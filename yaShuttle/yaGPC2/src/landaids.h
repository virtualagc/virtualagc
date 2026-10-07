/* The landing aids PASS reads through the forward MDMs: the MSBLS (MLS) and
 * the radar altimeters.  See landaids.c. */
#ifndef YAGPC_LANDAIDS_H
#define YAGPC_LANDAIDS_H

#include <stdint.h>

/* MSBLS unit 1-3's three words (azimuth, elevation, range), FF card 11 ch 1. */
void landaids_mls(int unit, uint16_t w[3]);
/* FF unit 1-3's seven-word TACAN/RA read, card 0 ch 0: radar altimeter 1-2
 * in word 5 (index 4), its power in word 6; the TACAN words read zero. */
void landaids_tacan_ra(int unit, uint16_t w[7]);

#endif
