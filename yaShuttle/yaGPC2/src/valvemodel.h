/* THE MAIN PROPULSION VALVES AND THE VENT DOORS, driven by the GPCs' own
 * discrete output commands and reporting their positions on the discrete
 * inputs the launch sequence and the separation sequences check.  See
 * valvemodel.c. */
#ifndef YAGPC_VALVEMODEL_H
#define YAGPC_VALVEMODEL_H

#include <stdbool.h>
#include <stdint.h>

/* Where the commands are read: the net state of an MDM's output channel
 * (mdm 'F' or 'A', unit 1-4, DOH card, channel). */
void valve_set_output_source(uint16_t (*fn)(char mdm, int unit, unsigned card, unsigned ch));

/* Move every valve and door to vehicle time t under the commands now set. */
void valve_update(double t);

/* OR the position indications into an input read's words: 'A' the FA HFE
 * read (54 words), 'F' the FF discretes (13 words, DSCRT1-13). */
void valve_inputs(char mdm, int unit, uint16_t *w, int nw);

int valve_save(double *b, int max);
void valve_load(const double *b, int n);
void valve_report(void);

#endif
