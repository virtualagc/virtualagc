/* THE GROUND'S LAUNCH PROCESSING SYSTEM, as the GPCs see it on the launch
 * data bus: LB1/LB2, buses 12 and 13, interface unit address 17.  See
 * lpsmodel.c for the protocol and its sources.
 *
 * mtumodel.c owns buses 12 and 13 (as it does the flight-critical buses) and
 * hands this model the transactions addressed to the ground; mdmdev.c passes
 * it the words a GPC transmits.  Countdown commands arrive as text datagrams
 * on port base + LPS_OFFSET (crewscript.py's 'lps' verb). */
#ifndef YAGPC_LPSMODEL_H
#define YAGPC_LPSMODEL_H

#include <stdbool.h>
#include <stdint.h>

#define LPS_OFFSET 108

/* Whether this command, on this bus, is addressed to the ground. */
bool lps_owns(int busID, uint32_t cmd);

/* Every command addressed to the ground, read or not, as it goes out --
 * the STATUS and WAVE-OFF commands carry their meaning in the command word. */
void lps_note_command(uint32_t cmd);

/* A read: how many words the ground answers this command with (0: none),
 * given the receive the commanding BCE armed; and the words themselves. */
int lps_read_words(uint32_t cmd, int armed);
bool lps_reply(uint32_t cmd, int n, uint16_t *out);

/* A TRANSMISSION ENABLE: how many words follow the command, and the words
 * once they have all come. */
bool lps_is_transmit(uint32_t cmd);
int lps_transmit_words(uint32_t cmd);
void lps_write(uint32_t cmd, const uint16_t *w, int n);

/* The countdown commands' socket, port base + LPS_OFFSET. */
void lps_open(int portBase);

/* PASS GMT seconds now (day of year x 86400 + seconds of day, as the GPC's
 * own clock counts), or a negative number when unknown -- for 'gmtlo +N'. */
void lps_set_gmt_source(double (*now)(void));

/* For the tests: queue a command line as the socket would. */
void lps_command_line(const char *line);

/* Whether the ground has sent GO FOR AUTO SEQUENCE: from then the onboard
 * sequence has the vehicle (valvemodel.c lets go of what the ground held). */
bool lps_auto_sequence_given(void);

/* The countdown's state for a capture: what the ground has said so far. */
int lps_save(double *b, int max);
void lps_load(const double *b, int n);

void lps_report(void);

#endif
