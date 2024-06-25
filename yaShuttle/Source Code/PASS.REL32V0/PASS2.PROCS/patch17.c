/* inlines=1,0
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch17.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #17-17 in
 *                         INTEGERIZABLE procedure of GENERATE module of
 *                         HAL/S-FC PASS2.
 * History:     2024-06-19 RSB  Created.
 */

#ifdef PFS

// CALL INLINE("58",1,0,FOR_DW);  /* L  1,DW     */
GR[1] = getFIXED(mFOR_DW);

// CALL INLINE("68", 0, 0, 1, 0); /* LD 0,0(0,1) */
FR[0] = fromFloatIBM(getFIXED(GR[1]), getFIXED(GR[1] + 4));

#endif // PFS
