/* inlines=4
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    OPT.PROCS/patch55.c
 * Purpose:     A C-language patch for CALL INLINE #5-8 in INT_TO_SCALAR
 *              procedure of the OPT pass of HAL/S-FC.
 * History:     2024-06-17 RSB  Created.
 *
 * Here's my analysis of the IBM 360 machine code being replaced by C:
 *
 * My interpretation of the IBM 360 machine code:
 *
 * CALL INLINE("2B",0,0);         SDR 0,0     Load FR0 with 0.0
 * CALL INLINE("58",1,0,FOR_DW);  L 1,FOR_DW  Load address of DW[0] into GR1.
 * CALL INLINE("6A",0,0,1,0);     AD 0,0(1)   Add (normalized) DW[0],DW[1] to FR0.
 * CALL INLINE("60",0,0,1,0);     STD 0,0(1)  Store FR0 into DW[0],DW[1]
 *
 * I.e., take a 2's-complement number from DW[1], convert it to an IBM hex
 * float, and put the result back into DW[0],DW[1].
 */

uint32_t msw, lsw, addressDW = getFIXED(mFOR_DW);
double N = getFIXED(addressDW + 4);
toFloatIBM(&msw, &lsw, N);
putFIXED(addressDW + 0, msw);
putFIXED(addressDW + 4, lsw);
