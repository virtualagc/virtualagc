/* inlines=3
 * This is a C-language patch for CALL INLINEs #78-81 in STAB_HDR.xpl, as
 * used by XCOM-I in building PASS1 of HAL/S-FC.
 *
 * I believe that this moves 8 bytes from S to NODE_H(SRN_INX).
 */

uint32_t srn_inx = COREHALFWORD(mSTAB_HDRxSRN_INX);
uint32_t node_h_address = getFIXED(mSTAB_HDRxNODE_H);
uint8_t *dest = &memory[node_h_address + srn_inx];
uint8_t *source = &memory[getFIXED(mS) & 0xFFFFFF];

memmove(dest, source, 8);

