/* THE THREE MAIN ENGINES, as the GPCs see them through their Engine
 * Interface Units: EIU1/2/3 (center, left, right) at IUAs 17, 23 and 24 on
 * the flight-critical buses FC5-8 (buses 14-17).  See eiumodel.c for the
 * sources and the rules the flight software holds the engines to.
 *
 * mtumodel.c hands this model the reads addressed to an EIU and mdmdev.c the
 * command words written to one. */
#ifndef YAGPC_EIUMODEL_H
#define YAGPC_EIUMODEL_H

#include <stdbool.h>
#include <stdint.h>

/* The engine (1-3) this read or write on this bus is for, or 0. */
int eiu_engine(int busID, uint32_t cmd);

/* A read: how many words this EIU answers on this bus (0: it does not --
 * an EIU sends its primary data only on its MIA1 bus and its secondary only
 * on MIA4, bus 17); and the words. */
int eiu_read_words(int busID, uint32_t cmd, int armed);
bool eiu_reply(int busID, uint32_t cmd, int n, uint16_t *out, double t);

/* The command write (FIOHO107, two words: command and BCH), as it comes on
 * any of the four buses. */
bool eiu_is_command(uint32_t cmd);
void eiu_command(int busID, uint32_t cmd, const uint16_t *w, int n, double t);

/* An engine's chamber pressure (% of rated) at time t, for the vehicle and
 * the displays; 0 when not running. */
double eiu_pc_percent(int engine, double t);

/* A session capture: the engines' state as numbers; and back, rebased. */
int eiu_save(double *b, int max);
void eiu_load(const double *b, int n, double tCap);

void eiu_report(void);

#endif
