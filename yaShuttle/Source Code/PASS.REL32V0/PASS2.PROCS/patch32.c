/*
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch32.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #32-36 in
 *                         INTEGERIZABLE procedure of GENERATE module of
 *                         HAL/S-FC PASS2.
 * History:     2024-06-19 RSB  Created.
 */

// CALL INLINE("58", 1, 0, ADDR_FIXER);         /* L    1,ADDR_FIXER */ 02104000
GR[1] = COREWORD(mADDR_FIXER);

// CALL INLINE("6E", 0, 0, 1, 0);               /* AW   0,0(0,1)     */ 02104500
FR[0] = fromFloatIBM(COREWORD(GR[1]), 0); // The precision doesn't seem right.

// CALL INLINE("58",1,0,FOR_DW);             /* L   1,DW   */           02105000
GR[1] = COREWORD(mFOR_DW);

// CALL INLINE("60", 0, 0, 1, 8);            /* STD 0,8(0,1)      */    02105500
toFloatIBM((uint32_t *) &memory[GR[1] + 8],  // DW[2]
           (uint32_t *) &memory[GR[1] + 12], // DW[3]
           FR[0]);                           // FR0 -> DW[2],DW[3].

// CALL INLINE("70", 2, 0, 1, 8);             /* STE 2,8(0,1)     */    02106000
uint32_t dummy;
toFloatIBM((uint32_t *) &memory[GR[1] + 8],  // DW[2]
           &dummy,
           FR[2]);                           // MSW of FR2 -> DW[2].
