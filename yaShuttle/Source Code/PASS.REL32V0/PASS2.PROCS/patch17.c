/*
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch17.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #17-17 in
 *                         INTEGERIZABLE procedure of GENERATE module of
 *                         HAL/S-FC PASS2.
 * History:     2024-06-19 RSB  Created.
 */

#ifdef PFS
/* Here's my analysis of the IBM 360 machine code being replaced by C:
 *
 * CALL INLINE("58",1,0,FOR_DW);  [ L  1,DW     ]  Load address of DW[0] into
 *                                                 register GR1.
 * CALL INLINE("68", 0, 0, 1, 0); [ LD 0,0(0,1) ]  Load values of DW[0],DW[1]
 *                                                 into float register FR0.
 *
 * FR0 will be accessed by patch19, I think.
 */

GR[1] = getFIXED(mFOR_DW);
FR[0] = fromFloatIBM(getFIXED(GR[1]), getFIXED(GR[1] + 4));

#endif // PFS
