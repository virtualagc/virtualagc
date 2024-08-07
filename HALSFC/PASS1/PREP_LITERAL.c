/*
  File PREP_LITERAL.c generated by XCOM-I, 2024-08-08 04:31:11.
*/

#include "runtimeC.h"

int32_t
PREP_LITERAL (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PREP_LITERAL");
  // IF EXP_OVERFLOW THEN (6001)
  if (1 & (bitToFixed (getBIT (1, mEXP_OVERFLOW))))
    // DO; (6002)
    {
    rs1:;
      {   // (57) CALL INLINE( 88,1,0,ADDR_FIXED_LIMIT);
        { // File:      patch57.c
          // For:       PREP_LITERAL.c
          // Notes:     1. Page references are from IBM "ESA/390 Principles of
          //               Operation", SA22-7201-08, Ninth Edition, June 2003.
          //            2. Labels are of the form p%d_%d, where the 1st number
          //               indicates the leading patch number of the block, and
          //               the 2nd is the byte offset of the instruction within
          //               within the block.
          //            3. Known-problematic translations are marked with the
          //               string  "* * * F I X M E * * *" (without spaces).
          // History:   2024-07-17 RSB  Auto-generated by XCOM-I --guess=....
          //                            Inspected.

          p57_0:;
      // (57)          CALL INLINE("58",1,0,ADDR_FIXED_LIMIT); /* L
      // 1,ADDR_FIXED_LIMIT*/
      address360B = (mADDR_FIXED_LIMIT)&0xFFFFFF;
      // Type RX, p. 7-7:		L	1,mADDR_FIXED_LIMIT(0,0)
      detailedInlineBefore (57, "L	1,mADDR_FIXED_LIMIT(0,0)");
      GR[1] = COREWORD (address360B);
      detailedInlineAfter ();

    p57_4:;
      // (58)          CALL INLINE("68",6,0,1,0);       /* LD 6,0(0,1)   */
      address360B = (GR[1] + 0) & 0xFFFFFF;
      // Type RX, p. 9-10:		LD	6,0(0,1)
      detailedInlineBefore (58, "LD	6,0(0,1)");
      FR[6]
          = fromFloatIBM (COREWORD (address360B), COREWORD (address360B + 4));
      detailedInlineAfter ();

    p57_8:;
    }
}; // (58) CALL INLINE( 104,6,0,1,0);
// NOT_EXACT: (6005)
NOT_EXACT:
// VALUE = -1; (6006)
{
  int32_t numberRHS = (int32_t)(-1);
  putFIXED (mVALUE, numberRHS);
}
// TOKEN = CPD_NUMBER; (6007)
{
  int32_t numberRHS = (int32_t)(getFIXED (mCPD_NUMBER));
  putFIXED (mTOKEN, numberRHS);
}
// GO TO SAVE_NUMBER; (6008)
goto SAVE_NUMBER;
es1:;
} // End of DO block
// TEMP1 = ADDR(NOT_EXACT); (6009)
{
  int32_t numberRHS = (int32_t)(-2);
  putFIXED (mPREP_LITERALxTEMP1, numberRHS);
}
{   // (59) CALL INLINE( 88, 1, 0, ADDR_FIXED_LIMIT);
  { // File:      patch59.c
    // For:       PREP_LITERAL.c
    // Notes:     1. Page references are from IBM "ESA/390 Principles of
    //               Operation", SA22-7201-08, Ninth Edition, June 2003.
    //            2. Labels are of the form p%d_%d, where the 1st number
    //               indicates the leading patch number of the block, and
    //               the 2nd is the byte offset of the instruction within
    //               within the block.
    //            3. Known-problematic translations are marked with the
    //               string  "* * * F I X M E * * *" (without spaces).
    // History:   2024-07-17 RSB  Auto-generated by XCOM-I --guess=....
    //                            Inspected.

    p59_0:;
// (59)       CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);       /* L
// 1,ADDR_LIMIT */
address360B = (mADDR_FIXED_LIMIT)&0xFFFFFF;
// Type RX, p. 7-7:		L	1,mADDR_FIXED_LIMIT(0,0)
detailedInlineBefore (59, "L	1,mADDR_FIXED_LIMIT(0,0)");
GR[1] = COREWORD (address360B);
detailedInlineAfter ();

p59_4:;
// (60)       CALL INLINE("58", 2, 0, TEMP1);                  /* L   2,TEMP1
// */
address360B = (mPREP_LITERALxTEMP1)&0xFFFFFF;
// Type RX, p. 7-7:		L	2,mPREP_LITERALxTEMP1(0,0)
detailedInlineBefore (60, "L	2,mPREP_LITERALxTEMP1(0,0)");
GR[2] = COREWORD (address360B);
detailedInlineAfter ();

p59_8:;
// (61)       CALL INLINE("28", 6, 0);                         /* LDR 6,0 */
// Type RR, p. 9-10:		LDR	6,0
detailedInlineBefore (61, "LDR	6,0");
// Where does the value of FR[0] come from?  Not from anywhere in
// `PREP_LITERAL`!  `PREP_LITERAL` is called from `SCAN`, immediately after
// `MONITOR(10, INTERNAL_BCD)`.  That must leave FR[0] populated as a
// side-effect.
FR[6] = FR[0];
detailedInlineAfter ();

p59_10:;
// (62)       CALL INLINE("20", 0, 0);                         /* LPDR 0,0 */
// Type RR, p. 18-17:		LPDR	0,0
detailedInlineBefore (62, "LPDR	0,0");
scratchd = fabs (FR[0]);
setCCd ();
FR[0] = scratchd;
detailedInlineAfter ();

p59_12:;
// (63)       CALL INLINE("69", 0, 0, 1, 0);                   /* CD  0,0(,1)
// */
address360B = (GR[1] + 0) & 0xFFFFFF;
// Type RX, p. 18-10:		CD	0,0(0,1)
detailedInlineBefore (63, "CD	0,0(0,1)");
scratchd = FR[0];
scratchd -= fromFloatIBM (COREWORD (address360B), COREWORD (address360B + 4));
setCCd ();
detailedInlineAfter ();

p59_16:;
// (64)       CALL INLINE("07", 2, 2);                         /* BHR 2 */ Type
// RR, p. 7-17:		BCR	2,2
detailedInlineBefore (64, "BCR	2,2");
mask360 = 2;
if ((CC == 0 && (mask360 & 8) != 0) || (CC == 1 && (mask360 & 4) != 0)
    || (CC == 2 && (mask360 & 2) != 0) || (CC == 3 && (mask360 & 1) != 0))
  switch (GR[2])
    {
    case -1:
      goto SAVE_NUMBER;
    case -2:
      goto NOT_EXACT;
    default:
      abend ("Branch address must be a label in this procedure");
    }
detailedInlineAfter ();

p59_18:;
// (65)       CALL INLINE("2B", 4, 4);                         /* SDR 4,4 */
// Type RR, p. 18-23:		SDR	4,4
detailedInlineBefore (65, "SDR	4,4");
scratchd = FR[4] - FR[4];
setCCd ();
FR[4] = scratchd;
detailedInlineAfter ();

p59_20:;
// (66)       CALL INLINE("28", 2, 0);                         /* LDR 2,0 */
// Type RR, p. 9-10:		LDR	2,0
detailedInlineBefore (66, "LDR	2,0");
FR[2] = FR[0];
detailedInlineAfter ();

p59_22:;
// (67)       CALL INLINE("58", 1, 0, ADDR_FIXER);             /* L
// 1,ADDR_FIXER */
address360B = (mADDR_FIXER)&0xFFFFFF;
// Type RX, p. 7-7:		L	1,mADDR_FIXER(0,0)
detailedInlineBefore (67, "L	1,mADDR_FIXER(0,0)");
GR[1] = COREWORD (address360B);
detailedInlineAfter ();

p59_26:;
// (68)       CALL INLINE("6E", 0, 0, 1, 0);                   /* AW  0,0(,1)
// */
address360B = (GR[1] + 0) & 0xFFFFFF;
// Type RX, p. 18-10:		AW	0,0(0,1)
detailedInlineBefore (68, "AW	0,0(0,1)");
aw (0, address360B);
detailedInlineAfter ();

p59_30:;
// (69)       CALL INLINE("58",1,0,TABLE_ADDR);
address360B = (mTABLE_ADDR)&0xFFFFFF;
// Type RX, p. 7-7:		L	1,mTABLE_ADDR(0,0)
detailedInlineBefore (69, "L	1,mTABLE_ADDR(0,0)");
GR[1] = COREWORD (address360B);
detailedInlineAfter ();

p59_34:;
// (70)       CALL INLINE("60", 0, 0, 1, 0);                   /* STD 0,0(,1)
// */
address360B = (GR[1] + 0) & 0xFFFFFF;
// Type RX, p. 9-11:		STD	0,0(0,1)
detailedInlineBefore (70, "STD	0,0(0,1)");
std (0, address360B);
detailedInlineAfter ();

p59_38:;
// (71)       CALL INLINE("2A", 0, 4);                         /* ADR 0,4 */
// Type RR, p. 18-8:		ADR	0,4
detailedInlineBefore (71, "ADR	0,4");
scratchd = FR[0] + FR[4];
setCCd ();
FR[0] = scratchd;
detailedInlineAfter ();

p59_40:;
// (72)       CALL INLINE("2B", 2, 0);                         /* SDR 2,0 */
// Type RR, p. 18-23:		SDR	2,0
detailedInlineBefore (72, "SDR	2,0");
scratchd = FR[2] - FR[0];
setCCd ();
FR[2] = scratchd;
detailedInlineAfter ();

p59_42:;
// (73)       CALL INLINE("07", 7, 2);                         /* BNER 2 */
// Type RR, p. 7-17:		BCR	7,2
detailedInlineBefore (73, "BCR	7,2");
mask360 = 7;
if ((CC == 0 && (mask360 & 8) != 0) || (CC == 1 && (mask360 & 4) != 0)
    || (CC == 2 && (mask360 & 2) != 0) || (CC == 3 && (mask360 & 1) != 0))
  switch (GR[2])
    {
    case -1:
      goto SAVE_NUMBER;
    case -2:
      goto NOT_EXACT;
    default:
      abend ("Branch address must be a label in this procedure");
    }
detailedInlineAfter ();

p59_44:;
// (74)       CALL INLINE("58", 2, 0, 1, 4);                   /* L   2,4(,1)
// */
address360B = (GR[1] + 4) & 0xFFFFFF;
// Type RX, p. 7-7:		L	2,4(0,1)
detailedInlineBefore (74, "L	2,4(0,1)");
GR[2] = COREWORD (address360B);
detailedInlineAfter ();

p59_48:;
// (75)       CALL INLINE("50", 2, 0, VALUE);                  /* ST  2,VALUE
// */
address360B = (mVALUE)&0xFFFFFF;
// Type RX, p. 7-122:		ST	2,mVALUE(0,0)
detailedInlineBefore (75, "ST	2,mVALUE(0,0)");
COREWORD2 (address360B, GR[2]);
detailedInlineAfter ();

p59_52:;
}
}
; // (60) CALL INLINE( 88, 2, 0, TEMP1);
; // (61) CALL INLINE( 40, 6, 0);
; // (62) CALL INLINE( 32, 0, 0);
; // (63) CALL INLINE( 105, 0, 0, 1, 0);
; // (64) CALL INLINE( 7, 2, 2);
; // (65) CALL INLINE( 43, 4, 4);
; // (66) CALL INLINE( 40, 2, 0);
; // (67) CALL INLINE( 88, 1, 0, ADDR_FIXER);
; // (68) CALL INLINE( 110, 0, 0, 1, 0);
; // (69) CALL INLINE( 88,1,0,TABLE_ADDR);
; // (70) CALL INLINE( 96, 0, 0, 1, 0);
; // (71) CALL INLINE( 42, 0, 4);
; // (72) CALL INLINE( 43, 2, 0);
; // (73) CALL INLINE( 7, 7, 2);
; // (74) CALL INLINE( 88, 2, 0, 1, 4);
; // (75) CALL INLINE( 80, 2, 0, VALUE);
// SAVE_NUMBER: (6027)
SAVE_NUMBER
    : {   // (76) CALL INLINE( 88,1,0,TABLE_ADDR);
        { // File:      patch76.c
          // For:       PREP_LITERAL.c
          // Notes:     1. Page references are from IBM "ESA/390 Principles of
          //               Operation", SA22-7201-08, Ninth Edition, June 2003.
          //            2. Labels are of the form p%d_%d, where the 1st number
          //               indicates the leading patch number of the block, and
          //               the 2nd is the byte offset of the instruction within
          //               within the block.
          //            3. Known-problematic translations are marked with the
          //               string  "* * * F I X M E * * *" (without spaces).
          // History:   2024-07-17 RSB  Auto-generated by XCOM-I --guess=....
          //                            Inspected.

          p76_0:;
// (76)       CALL INLINE("58",1,0,TABLE_ADDR);
address360B = (mTABLE_ADDR)&0xFFFFFF;
// Type RX, p. 7-7:		L	1,mTABLE_ADDR(0,0)
detailedInlineBefore (76, "L	1,mTABLE_ADDR(0,0)");
GR[1] = COREWORD (address360B);
detailedInlineAfter ();

p76_4:;
// (77)       CALL INLINE("60",6,0,1,0);          /* STD 6,0(0,1)   */
address360B = (GR[1] + 0) & 0xFFFFFF;
// Type RX, p. 9-11:		STD	6,0(0,1)
detailedInlineBefore (77, "STD	6,0(0,1)");
std (6, address360B);
detailedInlineAfter ();

p76_8:;
}
}
; // (77) CALL INLINE( 96,6,0,1,0);
// SYT_INDEX=SAVE_LITERAL(1,TABLE_ADDR); (6030)
{
  int32_t numberRHS = (int32_t)((
      putBITp (16, mSAVE_LITERALxTYPE, fixedToBit (32, (int32_t)(1))),
      putFIXED (mSAVE_LITERALxVAL, getFIXED (mTABLE_ADDR)), SAVE_LITERAL (0)));
  putFIXED (mSYT_INDEX, numberRHS);
}
{
  reentryGuard = 0;
  return 0;
}
}
