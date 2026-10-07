/* THE MASTER EVENTS CONTROLLERS: MEC1 and MEC2, IUAs 18 and 20 on FC5-8
 * (buses 14-17), through which the GPCs arm and fire the pyrotechnics --
 * SRB ignition, the T-0 umbilical, SRB separation, the ET umbilical and ET
 * separation.  Commands only: PASS reads nothing back (PCR 42206).  See
 * mecmodel.c. */
#ifndef YAGPC_MECMODEL_H
#define YAGPC_MECMODEL_H

#include <stdbool.h>
#include <stdint.h>

enum MecEvent { MEC_T0_UMB = 0, MEC_SRM_IGN, MEC_SRB_SEP, MEC_ET_UMB, MEC_ET_SEP, MEC_NEVENTS };

/* Whether this command on this bus is for a MEC; how many data words follow. */
bool mec_owns(int busID, uint32_t cmd);
int mec_words(uint32_t cmd);

/* Every command to a MEC as it goes out (the master reset has no words),
 * and a write's words once they have come. */
void mec_note_command(int busID, uint32_t cmd, double t);
void mec_command(int busID, uint32_t cmd, const uint16_t *w, int n, double t);

/* Whether an event's pyros are armed, and when it fired (< 0: not yet). */
bool mec_armed(enum MecEvent e);
double mec_fired_at(enum MecEvent e);

int mec_save(double *b, int max);
void mec_load(const double *b, int n, double tCap);
void mec_report(void);

#endif
