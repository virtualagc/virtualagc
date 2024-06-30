/* inlines=4,0
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch56.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #56-59 in
 *                         OBJECT_GENERATOR module of HAL/S-FC PASS2.
 * History:     2024-06-17 RSB  Created.
 */

#ifdef PFS

// CALL INLINE ("58",1,0,S1);       /* LOAD DESCRIPTOR */
GR[1] = getFIXED(mOBJECT_GENERATORxS1);

// CALL INLINE ("41",2,0,COLUMN);   /* ADDRESS OF RECEIVING FIELD */
GR[2] = mOBJECT_GENERATORxCOLUMN;

// CALL INLINE ("D2",0,3,2,76,1,0); /* MVC 76(4,2);,0(1); */
memmove(&memory[76 + GR[2]], &memory[GR[1] & 0xFFFFFF], 4);

#endif // PFS
