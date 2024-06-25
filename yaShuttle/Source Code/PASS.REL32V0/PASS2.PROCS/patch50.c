/* inlines=3,0
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch50.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #50-52 in
 *                         OBJECT_GENERATOR module of HAL/S-FC PASS2.
 * History:     2024-06-18 RSB  Created.
 */

#ifdef PFS
/* Here's my analysis of the IBM 360 machine code being replaced by C:
 *
 * CALL INLINE ("58",2,0,DUMMY);    Loads a string descriptor stored at `DUMMY`
 *                                  into GR2.
 * CALL INLINE ("41",1,0,COLUMN);   Loads the address of `COLUMN` (an array of
 *                                  80 bytes) into GR1.
 * CALL INLINE ("D2",2,6,1,32,2,0); I think this may move 33 bytes from the string
 *                                  data for which `DUMMY` holds the descriptor,
 *                                  to `COLUMN(6)`.  I don't know what the
 *                                  leading parameter of 2 does.
 */

uint32_t sourceADDR = getFIXED(mDUMMY) & 0xFFFFFF;
uint32_t destADDR = 6 + mOBJECT_GENERATORxCOLUMN;
memmove(&memory[destADDR], &memory[sourceADDR], 33);

#endif // PFS
