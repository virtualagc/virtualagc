/* inlines=3,0
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch68.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #68-70 in
 *                         EMIT_ESD_CARDS function of OBJECT_GENERATOR module
 *                         of HAL/S-FC PASS2.
 * History:     2024-06-18 RSB  Created.
 */

#ifdef PFS
/* Here's my analysis of the IBM 360 machine code being replaced by C:
 *
 * CALL INLINE ("58",2,0,S1);       Loads the descriptor of `S1` into GR2.
 * CALL INLINE ("58",1,0,TEMP);     Loads the contents of `TEMP` into GR1.
 *                                  Note that `TEMP` contains an address.
 * CALL INLINE ("D2",0,7,1,0,2,0);  MVC 0(7,1);,0(2);  I think this moves 1
 *                                  byte from 7 bytes past the address pointed
 *                                  to by `TEMP1`to the first byte of string
 *                                  data for S1.
 */

uint32_t destADDR = getFIXED(mOBJECT_GENERATORxS1) & 0xFFFFFF;
uint32_t sourceADDR = 7 + getFIXED(mOBJECT_GENERATORxEMIT_ESD_CARDSxTEMP);
memory[destADDR] = memory[sourceADDR];

#endif // PFS
