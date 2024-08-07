/*
  File _HOW_MUCH.c generated by XCOM-I, 2024-08-08 04:33:20.
*/

#include "runtimeC.h"

int32_t
_HOW_MUCH (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "_HOW_MUCH");
  // IF ANS=0 THEN (561)
  if (1 & (xEQ (getFIXED (m_HOW_MUCHxANS), 0)))
    // ANS=_DOPE_ALLOC(DOPE)/2 + 10; (562)
    {
      int32_t numberRHS = (int32_t)(xadd (
          xdivide (COREWORD (xadd (getFIXED (m_HOW_MUCHxDOPE), 8)), 2), 10));
      putFIXED (m_HOW_MUCHxANS, numberRHS);
    }
  // ANSMIN=ANS/2; (563)
  {
    int32_t numberRHS = (int32_t)(xdivide (getFIXED (m_HOW_MUCHxANS), 2));
    putFIXED (m_HOW_MUCHxANSMIN, numberRHS);
  }
  // ANSBYTES=_SPACE_ROUND(_DOPE_WIDTH(DOPE)*ANS); (564)
  {
    int32_t numberRHS = (int32_t)((
        putFIXED (
            m_SPACE_ROUNDxBYTES,
            xmultiply (COREHALFWORD (xadd (getFIXED (m_HOW_MUCHxDOPE), 4)),
                       getFIXED (m_HOW_MUCHxANS))),
        _SPACE_ROUND (0)));
    putFIXED (m_HOW_MUCHxANSBYTES, numberRHS);
  }
  // NSTRBYTES=FREELIMIT-FREEPOINT-FREESTRING_TRIGGER; (565)
  {
    int32_t numberRHS
        = (int32_t)(xsubtract (xsubtract (FREELIMIT (), FREEPOINT ()),
                               getFIXED (mFREESTRING_TRIGGER)));
    putFIXED (m_HOW_MUCHxNSTRBYTES, numberRHS);
  }
  // IF NSTRBYTES < 0 THEN (566)
  if (1 & (xLT (getFIXED (m_HOW_MUCHxNSTRBYTES), 0)))
    // NSTRBYTES=0; (567)
    {
      int32_t numberRHS = (int32_t)(0);
      putFIXED (m_HOW_MUCHxNSTRBYTES, numberRHS);
    }
  // IF ANSBYTES <= NSTRBYTES+FREEBYTES THEN (568)
  if (1
      & (xLE (getFIXED (m_HOW_MUCHxANSBYTES),
              xadd (getFIXED (m_HOW_MUCHxNSTRBYTES), getFIXED (mFREEBYTES)))))
    // RETURN ANS; (569)
    {
      reentryGuard = 0;
      return getFIXED (m_HOW_MUCHxANS);
    }
  // CALL _TAKE_BACK(ANSBYTES-NSTRBYTES-FREEBYTES); (570)
  {
    putFIXED (m_TAKE_BACKxNBYTES,
              xsubtract (xsubtract (getFIXED (m_HOW_MUCHxANSBYTES),
                                    getFIXED (m_HOW_MUCHxNSTRBYTES)),
                         getFIXED (mFREEBYTES)));
    _TAKE_BACK (0);
  }
  // IF ANSBYTES > NSTRBYTES + FREEBYTES THEN (571)
  if (1
      & (xGT (getFIXED (m_HOW_MUCHxANSBYTES),
              xadd (getFIXED (m_HOW_MUCHxNSTRBYTES), getFIXED (mFREEBYTES)))))
    // IF ~ ( ( COREWORD(DOPE+20) & 0x3000000 ) ^ = 0 ) THEN (572)
    if (1
        & (xNOT (xNEQ (
            xAND (COREWORD (xadd (getFIXED (m_HOW_MUCHxDOPE), 20)), 50331648),
            0))))
      // DO; (573)
      {
      rs1:;
        // FORCE_MAJOR=_TRUE; (574)
        {
          int32_t numberRHS = (int32_t)(1);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (1, mFORCE_MAJOR, bitRHS);
          bitRHS->inUse = 0;
        }
        // CALL COMPACTIFY; (575)
        COMPACTIFY (0);
        // NSTRBYTES=FREELIMIT-FREEPOINT-FREESTRING_TRIGGER; (576)
        {
          int32_t numberRHS
              = (int32_t)(xsubtract (xsubtract (FREELIMIT (), FREEPOINT ()),
                                     getFIXED (mFREESTRING_TRIGGER)));
          putFIXED (m_HOW_MUCHxNSTRBYTES, numberRHS);
        }
        // IF ANSBYTES > NSTRBYTES+FREEBYTES THEN (577)
        if (1
            & (xGT (getFIXED (m_HOW_MUCHxANSBYTES),
                    xadd (getFIXED (m_HOW_MUCHxNSTRBYTES),
                          getFIXED (mFREEBYTES)))))
          // ANS=((NSTRBYTES+FREEBYTES)/_DOPE_WIDTH(DOPE)) -1; (578)
          {
            int32_t numberRHS = (int32_t)(xsubtract (
                xdivide (xadd (getFIXED (m_HOW_MUCHxNSTRBYTES),
                               getFIXED (mFREEBYTES)),
                         COREHALFWORD (xadd (getFIXED (m_HOW_MUCHxDOPE), 4))),
                1));
            putFIXED (m_HOW_MUCHxANS, numberRHS);
          }
        // IF ANS < ANSMIN THEN (579)
        if (1
            & (xLT (getFIXED (m_HOW_MUCHxANS), getFIXED (m_HOW_MUCHxANSMIN))))
          // ANS=((NSTRBYTES+FREEBYTES+FREESTRING_TRIGGER
          // -FREESTRING_MIN))/_DOPE_WIDTH(DOPE)-1; (580)
          {
            int32_t numberRHS = (int32_t)(xsubtract (
                xdivide (
                    xsubtract (xadd (xadd (getFIXED (m_HOW_MUCHxNSTRBYTES),
                                           getFIXED (mFREEBYTES)),
                                     getFIXED (mFREESTRING_TRIGGER)),
                               getFIXED (mFREESTRING_MIN)),
                    COREHALFWORD (xadd (getFIXED (m_HOW_MUCHxDOPE), 4))),
                1));
            putFIXED (m_HOW_MUCHxANS, numberRHS);
          }
        // IF ANS < ANSMIN THEN (581)
        if (1
            & (xLT (getFIXED (m_HOW_MUCHxANS), getFIXED (m_HOW_MUCHxANSMIN))))
          // DO; (582)
          {
          rs1s1:;
            // OUTPUT='BI009 SEVERITY 3  NOT ENOUGH SPACE FOR INCREASED ' || '
            // ALLOCATION, GIVING UP.'; (583)
            {
              descriptor_t *stringRHS;
              stringRHS = cToDescriptor (
                  NULL, "BI009 SEVERITY 3  NOT ENOUGH SPACE FOR INCREASED  "
                        "ALLOCATION, GIVING UP.");
              OUTPUT (0, stringRHS);
              stringRHS->inUse = 0;
            }
            // CALL EXIT; (584)
            EXIT ();
          es1s1:;
          } // End of DO block
      es1:;
      } // End of DO block
  // RETURN ANS; (585)
  {
    reentryGuard = 0;
    return getFIXED (m_HOW_MUCHxANS);
  }
}
