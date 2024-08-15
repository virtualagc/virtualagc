/*
  File GENERATExENTER_CHAR_LIT.c generated by XCOM-I, 2024-08-09 12:41:32.
*/

#include "runtimeC.h"

int32_t
GENERATExENTER_CHAR_LIT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExENTER_CHAR_LIT");
  // IF LENGTH(STR) > RECORD_ALLOC(LIT_NDX) - LIT_CHAR_USED THEN (3656)
  if (1
      & (xGT (LENGTH (getCHARACTER (mGENERATExENTER_CHAR_LITxSTR)),
              xsubtract (
                  COREWORD (xadd (ADDR ("LIT_NDX", 0x80000000, NULL, 0), 8)),
                  getFIXED (mCOMM + 4 * 1)))))
    // CALL ERRORS(CLASS_BS,107); (3657)
    {
      putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_BS));
      putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(107)));
      ERRORS (0);
    }
  // LIT_CHAR_ADDR=COREWORD(ADDR(LIT_NDX)) + LIT_CHAR_USED; (3658)
  {
    int32_t numberRHS
        = (int32_t)(xadd (COREWORD (ADDR ("LIT_NDX", 0x80000000, NULL, 0)),
                          getFIXED (mCOMM + 4 * 1)));
    putFIXED (mCOMM + 4 * (0), numberRHS);
  }
  // XSIZE = LENGTH(STR) - 1; (3659)
  {
    int32_t numberRHS = (int32_t)(xsubtract (
        LENGTH (getCHARACTER (mGENERATExENTER_CHAR_LITxSTR)), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mGENERATExENTER_CHAR_LITxXSIZE, bitRHS);
    bitRHS->inUse = 0;
  }
  // TEMP = ADDR(LIT_MVC); (3660)
  {
    int32_t numberRHS = (int32_t)(-1);
    putFIXED (mGENERATExENTER_CHAR_LITxTEMP, numberRHS);
  }
  {   // (37) CALL INLINE( 88, 1, 0, STR);
    { /*
       * File:      patch37.c
       * For:       GENERATExENTER_CHAR_LIT.c
       * Notes:     1. Page references are from IBM "ESA/390 Principles of
       *               Operation", SA22-7201-08, Ninth Edition, June 2003.
       *            2. Labels are of the form p%d_%d, where the 1st number
       *               indicates the leading patch number of the block, and
       *               the 2nd is the byte offset of the instruction within
       *               within the block.
       *            3. Known-problematic translations are marked with the
       *               string  "* * * F I X M E * * *" (without spaces).
       * History:   2024-07-18 RSB  Auto-generated by XCOM-I --guess=....
       *                            Moved self-modifying part to patch41.c
       */

      p37_0:;
  // (37)       CALL INLINE("58", 1, 0, STR);                    /*  L   1,STR
  // */
  address360B = (mGENERATExENTER_CHAR_LITxSTR)&0xFFFFFF;
  // Type RX, p. 7-7:		L	1,mGENERATExENTER_CHAR_LITxSTR(0,0)
  detailedInlineBefore (37, "L	1,mGENERATExENTER_CHAR_LITxSTR(0,0)");
  GR[1] = COREWORD (address360B);
  detailedInlineAfter ();

p37_4:;
  // (38)       CALL INLINE("58", 2, 0, LIT_CHAR_ADDR);          /*  L
  // 2,LIT_CHAR_ADDR*/
  address360B = (mCOMM)&0xFFFFFF;
  // Type RX, p. 7-7:		L	2,mCOMM(0,0)
  detailedInlineBefore (38, "L	2,mCOMM(0,0)");
  GR[2] = COREWORD (address360B);
  detailedInlineAfter ();

p37_8:;
  // (39)       CALL INLINE("58", 3, 0, TEMP);                   /*  L   3,TEMP
  // */
  address360B = (mGENERATExENTER_CHAR_LITxTEMP)&0xFFFFFF;
  // Type RX, p. 7-7:		L	3,mGENERATExENTER_CHAR_LITxTEMP(0,0)
  detailedInlineBefore (39, "L	3,mGENERATExENTER_CHAR_LITxTEMP(0,0)");
  GR[3] = COREWORD (address360B);
  detailedInlineAfter ();

p37_12:;
// This, together with patch41.c, is self-modifying code best handled directly
// in patch41.c.
#if 0
      // (40)        CALL INLINE("D2", 0, 0, 3, 1, XSIZE);            /* MVC 1(0,3),XSIZE   */
      address360A = (GR[3] + 1) & 0xFFFFFF;
      address360B = (mGENERATExENTER_CHAR_LITxXSIZE) & 0xFFFFFF;
      // Type SS, p. 7-83:		MVC	1(0,3),mGENERATExENTER_CHAR_LITxXSIZE(0)
      detailedInlineBefore(40, "MVC	1(0,3),mGENERATExENTER_CHAR_LITxXSIZE(0)");
      mvc(address360A, address360B, 0);
      detailedInlineAfter();
#endif

p37_18:;
}
}
; // (38) CALL INLINE( 88, 2, 0, LIT_CHAR_ADDR);
; // (39) CALL INLINE( 88, 3, 0, TEMP);
; // (40) CALL INLINE( 210, 0, 0, 3, 1, XSIZE);
// LIT_MVC: (3665)
LIT_MVC
    : {   // (41) CALL INLINE( 210, 0, 0, 2, 0, 1, 0);
        { /*
           * File:      patch41.c
           * For:       GENERATExENTER_CHAR_LIT.c
           * Notes:     1. Page references are from IBM "ESA/390 Principles of
           *               Operation", SA22-7201-08, Ninth Edition, June 2003.
           *            2. Labels are of the form p%d_%d, where the 1st number
           *               indicates the leading patch number of the block, and
           *               the 2nd is the byte offset of the instruction within
           *               within the block.
           *            3. Known-problematic translations are marked with the
           *               string  "* * * F I X M E * * *" (without spaces).
           * History:   2024-07-18 RSB  Auto-generated by XCOM-I --guess=....
           *                            Fixed self-modification; see patch37.c.
           */

          p41_0:;
// (41)       CALL INLINE("D2", 0, 0, 2, 0, 1, 0);             /*  MVC
// 0(0,2),0(1)    */
address360A = (GR[2] + 0) & 0xFFFFFF;
address360B = (GR[1] + 0) & 0xFFFFFF;
// Type SS, p. 7-83:		MVC	0(0,2),0(1)
detailedInlineBefore (41, "MVC	0(0,2),0(1)");
mvc (address360A, address360B, memory[mGENERATExENTER_CHAR_LITxXSIZE]);
detailedInlineAfter ();

p41_6:;
}
}
// TEMP = SHL(XSIZE,24) | LIT_CHAR_ADDR; (3667)
{
  int32_t numberRHS
      = (int32_t)(xOR (SHL (BYTE0 (mGENERATExENTER_CHAR_LITxXSIZE), 24),
                       getFIXED (mCOMM + 4 * 0)));
  putFIXED (mGENERATExENTER_CHAR_LITxTEMP, numberRHS);
}
// LIT_CHAR_ADDR = LIT_CHAR_ADDR + XSIZE + 1; (3668)
{
  int32_t numberRHS = (int32_t)(xadd (
      xadd (getFIXED (mCOMM + 4 * 0), BYTE0 (mGENERATExENTER_CHAR_LITxXSIZE)),
      1));
  putFIXED (mCOMM + 4 * (0), numberRHS);
}
// LIT_CHAR_USED = LIT_CHAR_USED + XSIZE + 1; (3669)
{
  int32_t numberRHS = (int32_t)(xadd (
      xadd (getFIXED (mCOMM + 4 * 1), BYTE0 (mGENERATExENTER_CHAR_LITxXSIZE)),
      1));
  putFIXED (mCOMM + 4 * (1), numberRHS);
}
// RETURN TEMP; (3670)
{
  reentryGuard = 0;
  return getFIXED (mGENERATExENTER_CHAR_LITxTEMP);
}
}