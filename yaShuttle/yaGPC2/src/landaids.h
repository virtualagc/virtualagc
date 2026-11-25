/* The landing aids PASS reads through the forward MDMs: the MSBLS (MLS) and
 * the radar altimeters.  See landaids.c. */
#ifndef YAGPC_LANDAIDS_H
#define YAGPC_LANDAIDS_H

#include <stdint.h>

/* MSBLS unit 1-3's three words (azimuth, elevation, range), FF card 11 ch 1. */
void landaids_mls(int unit, uint16_t w[3]);
/* FF unit 1-3's seven-word TACAN/RA read, card 0 ch 0: the TACAN's bearing and
 * range (words 1-4), the radar altimeter 1-2 in word 5, the discretes in word
 * 6 (TACAN power only when the navaids file has TACAN stations) and the
 * control register read back in word 7.  See landaids.c. */
void landaids_tacan_ra(int unit, uint16_t w[7]);
/* the GPC's write to FF unit 1-3's TACAN control register and antenna word
 * (FIOHO205, X'200C1'): what the unit is tuned to */
void landaids_tacan_command(int unit, uint16_t ctrl, uint16_t ant);

#endif
