/*
  File GENERATExSTRUCTURE_ADVANCE.c generated by XCOM-I, 2024-08-09 12:41:32.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExSTRUCTURE_ADVANCE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExSTRUCTURE_ADVANCE");
  // IF STRUCT_REF(REF) > 0 THEN (7796)
  if (1
      & (xGT (
          COREHALFWORD (mGENERATExSTRUCT_REF
                        + 2 * COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)),
          0)))
    // GO TO RE_ENTER; (7797)
    goto RE_ENTER;
  // STRUCT_REF(REF), A(REF) = STRUCT_TEMPL(REF); (7798)
  {
    descriptor_t *bitRHS = getBIT (
        16, mGENERATExSTRUCT_TEMPL
                + 2 * COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF));
    putBIT (16,
            mGENERATExSTRUCT_REF
                + 2 * (COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)),
            bitRHS);
    putBIT (16,
            mGENERATExSTRUCTURE_ADVANCExA
                + 2 * (COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (SYT_LOCK#(A(REF))& 128) ~= 0 THEN (7799)
  if (1
      & (xNEQ (
          xAND (BYTE0 (getFIXED (mSYM_TAB)
                       + 34
                             * (COREHALFWORD (
                                 mGENERATExSTRUCTURE_ADVANCExA
                                 + 2
                                       * COREHALFWORD (
                                           mGENERATExSTRUCTURE_ADVANCExREF)))
                       + 31 + 1 * (0)),
                128),
          0)))
    // DO CASE REF; (7800)
    {
    rs1:
      switch (COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF))
        {
        case 0:
          // SYT_LINK2(A(REF)) = 0; (7802)
          {
            int32_t numberRHS = (int32_t)(0);
            putBIT (16,
                    getFIXED (mSYM_TAB)
                        + 34
                              * (COREHALFWORD (
                                  mGENERATExSTRUCTURE_ADVANCExA
                                  + 2
                                        * COREHALFWORD (
                                            mGENERATExSTRUCTURE_ADVANCExREF)))
                        + 26 + 2 * (0),
                    fixedToBit (16, numberRHS));
          }
          break;
        case 1:
          // SYT_DIMS(A(REF)) = 0; (7803)
          {
            int32_t numberRHS = (int32_t)(0);
            putBIT (16,
                    getFIXED (mSYM_TAB)
                        + 34
                              * (COREHALFWORD (
                                  mGENERATExSTRUCTURE_ADVANCExA
                                  + 2
                                        * COREHALFWORD (
                                            mGENERATExSTRUCTURE_ADVANCExREF)))
                        + 18 + 2 * (0),
                    fixedToBit (16, numberRHS));
          }
          break;
        }
    } // End of DO CASE block
  // DO FOREVER; (7803)
  while (1 & (1))
    {
      // DO WHILE DESCENDENT(A(REF), REF) > 0; (7804)
      while (
          1
          & (xGT (
              bitToFixed ((
                  putBITp (
                      16, mGENERATExDESCENDENTxXLOC,
                      getBIT (16,
                              mGENERATExSTRUCTURE_ADVANCExA
                                  + 2
                                        * COREHALFWORD (
                                            mGENERATExSTRUCTURE_ADVANCExREF))),
                  putBITp (16, mGENERATExDESCENDENTxREF,
                           getBIT (16, mGENERATExSTRUCTURE_ADVANCExREF)),
                  GENERATExDESCENDENT (0))),
              0)))
        {
          // A(REF) = KIN; (7805)
          {
            descriptor_t *bitRHS = getBIT (16, mKIN);
            putBIT (16,
                    mGENERATExSTRUCTURE_ADVANCExA
                        + 2 * (COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
        } // End of DO WHILE block
      // RET = A(REF); (7806)
      {
        descriptor_t *bitRHS = getBIT (
            16, mGENERATExSTRUCTURE_ADVANCExA
                    + 2 * COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF));
        putBIT (16, mGENERATExSTRUCTURE_ADVANCExRET, bitRHS);
        bitRHS->inUse = 0;
      }
      // REF = 0; (7807)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mGENERATExSTRUCTURE_ADVANCExREF, bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN RET; (7808)
      {
        reentryGuard = 0;
        return getBIT (16, mGENERATExSTRUCTURE_ADVANCExRET);
      }
    // RE_ENTER: (7809)
    RE_ENTER:
      // A(REF) = SUCCESSOR(A(REF), REF); (7810)
      {
        descriptor_t *bitRHS
            = (putBITp (
                   16, mGENERATExSUCCESSORxXLOC,
                   getBIT (16,
                           mGENERATExSTRUCTURE_ADVANCExA
                               + 2
                                     * COREHALFWORD (
                                         mGENERATExSTRUCTURE_ADVANCExREF))),
               putBITp (16, mGENERATExSUCCESSORxREF,
                        getBIT (16, mGENERATExSTRUCTURE_ADVANCExREF)),
               GENERATExSUCCESSOR (0));
        putBIT (16,
                mGENERATExSTRUCTURE_ADVANCExA
                    + 2 * (COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // IF A(REF) < 0 THEN (7811)
      if (1
          & (xLT (COREHALFWORD (
                      mGENERATExSTRUCTURE_ADVANCExA
                      + 2 * COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)),
                  0)))
        // DO; (7812)
        {
        rs2s2:;
          // A(REF) = -A(REF); (7813)
          {
            int32_t numberRHS = (int32_t)(xminus (COREHALFWORD (
                mGENERATExSTRUCTURE_ADVANCExA
                + 2 * COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF))));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16,
                    mGENERATExSTRUCTURE_ADVANCExA
                        + 2 * (COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // IF A(REF) = STRUCT_REF(REF) THEN (7814)
          if (1
              & (xEQ (
                  COREHALFWORD (
                      mGENERATExSTRUCTURE_ADVANCExA
                      + 2 * COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)),
                  COREHALFWORD (
                      mGENERATExSTRUCT_REF
                      + 2 * COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)))))
            // DO; (7815)
            {
            rs2s2s1:;
              // STRUCT_REF(REF), REF = 0; (7816)
              {
                int32_t numberRHS = (int32_t)(0);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (
                    16,
                    mGENERATExSTRUCT_REF
                        + 2 * (COREHALFWORD (mGENERATExSTRUCTURE_ADVANCExREF)),
                    bitRHS);
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mGENERATExSTRUCTURE_ADVANCExREF, bitRHS);
                bitRHS->inUse = 0;
              }
              // RETURN 0; (7817)
              {
                reentryGuard = 0;
                return fixedToBit (32, (int32_t)(0));
              }
            es2s2s1:;
            } // End of DO block
          // GO TO RE_ENTER; (7818)
          goto RE_ENTER;
        es2s2:;
        } // End of DO block
    }     // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}