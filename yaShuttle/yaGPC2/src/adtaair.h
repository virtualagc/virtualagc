/* The air data transducer assemblies; see adtaair.c. */
#ifndef YAGPC_ADTAAIR_H
#define YAGPC_ADTAAIR_H

#include <stdint.h>

/* ADTA unit 1-4's six words (FF card 11 ch 0). */
void adta_words(int unit, uint16_t w[6]);
/* FF unit 1-4's DSCRT8 probe bits: 0x0020 deployed, 0x0010 stowed. */
uint16_t adta_probe_bits(int unit);

#endif
