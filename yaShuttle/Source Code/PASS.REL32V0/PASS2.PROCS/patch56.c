/*
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch56.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #56-59 in
 *                         OBJECT_GENERATOR module of HAL/S-FC PASS2.
 * History:     2024-06-17 RSB  Created.
 */

#ifdef PFS
/* Here's my analysis of the IBM 360 machine code being replaced by C:
 *
 * CALL INLINE ("58",1,0,S1);       [LOAD DESCRIPTOR]  Loads the value of `S1`
 *                                  into GR1.  Note that this will be a string
 *                                  descriptor.
 * CALL INLINE ("41",2,0,COLUMN);   [ADDRESS OF RECEIVING FIELD]  Loads the
 *                                  address of `COLUMN` into GR2.
 * CALL INLINE ("D2",0,3,2,76,1,0); [MVC 76(4,2);,0(1);] 77 bytes are moved
 *                                  from the address stored in `S1` into
 *                                  `COLUMN` starting at column 3.
 *                                  (`COLUMN` is an 80-byte array.)
 */

// CALL INLINE ("58",1,0,S1);       /* LOAD DESCRIPTOR */
GR[1] = getFIXED(mOBJECT_GENERATORxS1);

// CALL INLINE ("41",2,0,COLUMN);   /* ADDRESS OF RECEIVING FIELD */
GR[2] = mOBJECT_GENERATORxCOLUMN;

// CALL INLINE ("D2",0,3,2,76,1,0); /* MVC 76(4,2);,0(1); */
memmove(&memory[GR[2] + 3], &memory[GR[1] & 0xFFFFFF], 77);

#endif // PFS
