/* inlines=2,0
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch13.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #13-14 in
 *                         EMITSTRING module of HAL/S-FC PASS2.
 * History:     2024-06-18 RSB  Created.
 */

#ifdef PFS
/* Here's my analysis of the IBM 360 machine code being replaced by C:
 *
 * CALL INLINE("58", 1, 0, STRING)              Loads the descriptor for STRING
 *                                              into GR1.
 * CALL INLINE("D2", 0, 255, TEMPSTRING, 1, 0)  I think this may move 256
 *                                              bytes from the string data of
 *                                              STRING to TEMPSTRING.
 */

uint32_t sourceADDR = getFIXED(mEMITSTRINGxSTRING) & 0xFFFFFF;
uint32_t destADDR = getFIXED(mEMITSTRINGxTEMPSTRING) & 0xFFFFFF;
memmove(&memory[destADDR], &memory[sourceADDR], 256);

#endif // PFS
