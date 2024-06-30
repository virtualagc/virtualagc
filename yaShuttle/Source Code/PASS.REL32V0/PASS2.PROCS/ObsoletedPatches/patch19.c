/* inlines=13,0
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch19.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #19-31 in
 *                         INTEGERIZABLE procedure of GENERATE module of
 *                         HAL/S-FC PASS2.
 * History:     2024-06-19 RSB  Created.
 */

#ifdef PFS

// CALL INLINE("28", 2, 0);                   /* LDR 2,0          */    02097000
FR[2] = FR[0];

// CALL INLINE("20", 0, 0);                   /* LPDR 0,0         */    02097500
FR[0] = fabs(FR[0]);

// CALL INLINE("2B", 4, 4);                   /* SDR 4,4          */    02098000
FR[4] -= FR[4]; // I think this is to clear the least-significant word prior to
                // the next instruction.  It's not needed.

// CALL INLINE("78", 4, 0, FLT_NEGMAX);       /* LE 4,FLT_NEGMAX  */    02098500
FR[4] = fromFloatIBM(COREWORD(mGENERATExINTEGERIZABLExFLT_NEGMAX), 0);

// CALL INLINE("58", 2, 0, TEMP1);              /* L   2,TEMP1   */     02099000
GR[2] = COREWORD(mGENERATExINTEGERIZABLExTEMP1);
// Note that TEMP1 contains the address of the program label LIT_NEGMAX.

// CALL INLINE("29", 4, 2);                   /* CDR 4,2          */    02099500
double comparison = FR[4] - FR[2];

// CALL INLINE("07", 8, 2);                   /* BCR 8,2          */    02100000
if (comparison < 0) // I think this may be a a test for equality, but ...
  goto LIT_NEGMAX;

// CALL INLINE("58", 1, 0, ADDR_ROUNDER);       /* L    1,ADDR_ROUNDR*/ 02100500
GR[1] = COREWORD(mADDR_ROUNDER);

// CALL INLINE("6A", 0, 0, 1, 0);               /* AD   0,0(0,1)     */ 02101000
FR[0] += fromFloatIBM(COREWORD(GR[1]), 0);

// CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);   /* L    1,ADDR__LIMIT*/ 02101500
GR[1] = COREWORD(mADDR_FIXED_LIMIT);

// CALL INLINE("58", 2, 0, TEMP);               /* L    2,TEMP       */ 02102000
GR[2] = COREWORD(mGENERATExINTEGERIZABLExTEMP);
// Note that TEMP contains the address of the program label NO_INTEGER.

// CALL INLINE("69", 0, 0, 1, 0);               /* CD   0,0(0,1)     */ 02102500
comparison = FR[0] - fromFloatIBM(COREWORD(GR[1]), 0);

// CALL INLINE("07", 2, 2);                     /* BCR  2,2          */ 02103000
if (comparison > 0)
  goto NO_INTEGER;

#endif // PFS
