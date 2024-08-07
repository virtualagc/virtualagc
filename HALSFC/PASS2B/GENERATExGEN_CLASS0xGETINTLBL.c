/*
  File GENERATExGEN_CLASS0xGETINTLBL.c generated by XCOM-I, 2024-08-08
  04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xGETINTLBL (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExGEN_CLASS0xGETINTLBL");
  // PTR = GET_STACK_ENTRY; (11163)
  {
    int32_t numberRHS = (int32_t)(GENERATExGET_STACK_ENTRY (0));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExGEN_CLASS0xGETINTLBLxPTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE LABEL# >= RECORD_TOP(STMTNUM); (11164)
  while (1
         & (xGE (COREHALFWORD (mGENERATExGEN_CLASS0xGETINTLBLxLABELp),
                 xsubtract (COREWORD (xadd (
                                ADDR ("STMTNUM", 0x80000000, NULL, 0), 12)),
                            1))))
    {
      // DO ; (11165)
      {
      rs1s1:;
        // IF COREWORD ( ADDR ( STMTNUM ) + 12 ) >= COREWORD ( ADDR ( STMTNUM )
        // + 8 ) THEN (11166)
        if (1
            & (xGE (
                COREWORD (xadd (ADDR ("STMTNUM", 0x80000000, NULL, 0), 12)),
                COREWORD (xadd (ADDR ("STMTNUM", 0x80000000, NULL, 0), 8)))))
          // CALL _NEEDMORE_SPACE ( ADDR ( STMTNUM )  ) ; (11167)
          {
            putFIXED (m_NEEDMORE_SPACExDOPE,
                      ADDR ("STMTNUM", 0x80000000, NULL, 0));
            _NEEDMORE_SPACE (0);
          }
        // COREWORD ( ADDR ( STMTNUM ) + 12 ) = COREWORD ( ADDR ( STMTNUM ) +
        // 12 ) + 1 ; (11168)
        {
          int32_t numberRHS = (int32_t)(xadd (
              COREWORD (xadd (ADDR ("STMTNUM", 0x80000000, NULL, 0), 12)), 1));
          COREWORD2 (xadd (ADDR ("STMTNUM", 0x80000000, NULL, 0), 12),
                     numberRHS);
        }
      es1s1:;
      } // End of DO block
    }   // End of DO WHILE block
  // IF LABEL_ARRAY(LABEL#) = 0 THEN (11169)
  if (1
      & (xEQ (COREHALFWORD (
                  getFIXED (mSTMTNUM)
                  + 2 * (COREHALFWORD (mGENERATExGEN_CLASS0xGETINTLBLxLABELp))
                  + 0 + 2 * (0)),
              0)))
    // LABEL_ARRAY(LABEL#) = GETSTATNO; (11170)
    {
      descriptor_t *bitRHS = GETSTATNO (0);
      putBIT (16,
              getFIXED (mSTMTNUM)
                  + 2 * (COREHALFWORD (mGENERATExGEN_CLASS0xGETINTLBLxLABELp))
                  + 0 + 2 * (0),
              bitRHS);
      bitRHS->inUse = 0;
    }
  // VAL(PTR) = LABEL_ARRAY(LABEL#); (11171)
  {
    descriptor_t *bitRHS = getBIT (
        16, getFIXED (mSTMTNUM)
                + 2 * (COREHALFWORD (mGENERATExGEN_CLASS0xGETINTLBLxLABELp))
                + 0 + 2 * (0));
    putFIXED (getFIXED (mIND_STACK)
                  + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xGETINTLBLxPTR))
                  + 12 + 4 * (0),
              bitToFixed (bitRHS));
    bitRHS->inUse = 0;
  }
  // LOC(PTR) = LABEL#; (11172)
  {
    descriptor_t *bitRHS = getBIT (16, mGENERATExGEN_CLASS0xGETINTLBLxLABELp);
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xGETINTLBLxPTR)) + 40
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // FORM(PTR) = FLNO; (11173)
  {
    descriptor_t *bitRHS = getBIT (8, mFLNO);
    putBIT (16,
            getFIXED (mIND_STACK)
                + 73 * (COREHALFWORD (mGENERATExGEN_CLASS0xGETINTLBLxPTR)) + 32
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN PTR; (11174)
  {
    reentryGuard = 0;
    return COREHALFWORD (mGENERATExGEN_CLASS0xGETINTLBLxPTR);
  }
}
