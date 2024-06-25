/* inlines=3,0
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch53.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #53-55 in
 *                         the OBJECT_GENERATOR module of HAL/S-FC PASS2.
 * History:     2024-06-19 RSB  Created.
 *
 * Note that the INLINEs are identical to patch50.c.
 */

#ifdef PFS

// CALL INLINE("58",2,0,DUMMY);     Mnemonic "L".
GR[2] = getFIXED(mDUMMY);

// CALL INLINE("41",1,0,COLUMN);    Mnemonic "LA".
GR[1] = mOBJECT_GENERATORxCOLUMN;

// CALL INLINE("D2",2,6,1,32,2,0);  Mnemonic "MVC".
memmove (&memory[6 + GR[1]], &memory[GR[2] & 0xFFFFFF], 33);

#endif // PFS
