/*
  File VM_DETAG.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

int32_t
VM_DETAG (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "VM_DETAG");
  // IF C_TRACE THEN (2368)
  if (1 & (bitToFixed (getBIT (8, mC_TRACE))))
    // OUTPUT= 'VM_DETAG: '||LOOP_HEAD||' TO '||LOOP_END; (2369)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (xsCAT (xsCAT (cToDescriptor (NULL, "VM_DETAG: "),
                                 bitToCharacter (getBIT (16, mLOOP_HEAD))),
                          cToDescriptor (NULL, " TO ")),
                   bitToCharacter (getBIT (16, mLOOP_END)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // INX= LOOP_HEAD + NO_OPERANDS(LOOP_HEAD) +1; (2370)
  {
    int32_t numberRHS
        = (int32_t)(xadd (xadd (COREHALFWORD (mLOOP_HEAD),
                                bitToFixed ((putBITp (16, mNO_OPERANDSxPTR,
                                                      getBIT (16, mLOOP_HEAD)),
                                             NO_OPERANDS (0)))),
                          1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mVM_DETAGxINX, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE INX ~= LOOP_END; (2371)
  while (1 & (xNEQ (COREHALFWORD (mVM_DETAGxINX), COREHALFWORD (mLOOP_END))))
    {
      // IF LOOPY(INX) & (OPR(INX) & TAG_BIT) ~= 0 THEN (2372)
      if (1
          & (xAND (
              (putBITp (16, mLOOPYxPTR, getBIT (16, mVM_DETAGxINX)),
               LOOPY (0)),
              xNEQ (xAND (getFIXED (mOPR + 4 * COREHALFWORD (mVM_DETAGxINX)),
                          getFIXED (mTAG_BIT)),
                    0))))
        // DO; (2373)
        {
        rs1s1:;
          // INX2 = INX + NO_OPERANDS(INX) +1; (2374)
          {
            int32_t numberRHS = (int32_t)(xadd (
                xadd (COREHALFWORD (mVM_DETAGxINX),
                      bitToFixed ((putBITp (16, mNO_OPERANDSxPTR,
                                            getBIT (16, mVM_DETAGxINX)),
                                   NO_OPERANDS (0)))),
                1));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mVM_DETAGxINX2, bitRHS);
            bitRHS->inUse = 0;
          }
          // DO WHILE INX2 ~= LOOP_END; (2375)
          while (1
                 & (xNEQ (COREHALFWORD (mVM_DETAGxINX2),
                          COREHALFWORD (mLOOP_END))))
            {
              // DO FOR I = INX2+1 TO INX2+NO_OPERANDS(INX2); (2376)
              {
                int32_t from53, to53, by53;
                from53 = xadd (COREHALFWORD (mVM_DETAGxINX2), 1);
                to53
                    = xadd (COREHALFWORD (mVM_DETAGxINX2),
                            bitToFixed ((putBITp (16, mNO_OPERANDSxPTR,
                                                  getBIT (16, mVM_DETAGxINX2)),
                                         NO_OPERANDS (0))));
                by53 = 1;
                for (putBIT (16, mVM_DETAGxI, fixedToBit (16, from53));
                     bitToFixed (getBIT (16, mVM_DETAGxI)) <= to53; putBIT (
                         16, mVM_DETAGxI,
                         fixedToBit (16, bitToFixed (getBIT (16, mVM_DETAGxI))
                                             + by53)))
                  {
                    // IF ~TERMINAL(I) & SHR(OPR(I),16)=INX & ~SHR(OPR(I),3)
                    // THEN (2377)
                    if (1
                        & (xAND (
                            xAND (xNOT (bitToFixed (
                                      (putBITp (16, mTERMINALxPTR,
                                                getBIT (16, mVM_DETAGxI)),
                                       TERMINAL (0)))),
                                  xEQ (SHR (getFIXED (mOPR
                                                      + 4
                                                            * COREHALFWORD (
                                                                mVM_DETAGxI)),
                                            16),
                                       COREHALFWORD (mVM_DETAGxINX))),
                            xNOT (SHR (
                                getFIXED (mOPR
                                          + 4 * COREHALFWORD (mVM_DETAGxI)),
                                3)))))
                      // DO; (2378)
                      {
                      rs1s1s1s1s1:;
                        // OPR(INX) = OPR(INX) & ~TAG_BIT; (2379)
                        {
                          int32_t numberRHS = (int32_t)(xAND (
                              getFIXED (mOPR
                                        + 4 * COREHALFWORD (mVM_DETAGxINX)),
                              xNOT (getFIXED (mTAG_BIT))));
                          putFIXED (mOPR + 4 * (COREHALFWORD (mVM_DETAGxINX)),
                                    numberRHS);
                        }
                        // IF C_TRACE THEN (2380)
                        if (1 & (bitToFixed (getBIT (8, mC_TRACE))))
                          // OUTPUT = 'DETAGGED: '||INX||' ,REF: '||I; (2381)
                          {
                            descriptor_t *stringRHS;
                            stringRHS = xsCAT (
                                xsCAT (
                                    xsCAT (cToDescriptor (NULL, "DETAGGED: "),
                                           bitToCharacter (
                                               getBIT (16, mVM_DETAGxINX))),
                                    cToDescriptor (NULL, " ,REF: ")),
                                bitToCharacter (getBIT (16, mVM_DETAGxI)));
                            OUTPUT (0, stringRHS);
                            stringRHS->inUse = 0;
                          }
                        // GO TO DETAGGED; (2382)
                        goto DETAGGED;
                      es1s1s1s1s1:;
                      } // End of DO block
                  }
              } // End of DO for-loop block
              // INX2 = INX2 + NO_OPERANDS(INX2) +1; (2383)
              {
                int32_t numberRHS = (int32_t)(xadd (
                    xadd (COREHALFWORD (mVM_DETAGxINX2),
                          bitToFixed ((putBITp (16, mNO_OPERANDSxPTR,
                                                getBIT (16, mVM_DETAGxINX2)),
                                       NO_OPERANDS (0)))),
                    1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mVM_DETAGxINX2, bitRHS);
                bitRHS->inUse = 0;
              }
            } // End of DO WHILE block
        // DETAGGED: (2384)
        DETAGGED:;
        es1s1:;
        } // End of DO block
      // ELSE (2385)
      else
        // IF OPOP(INX)=ADLP & SHR(OPR(INX+1),8) THEN (2386)
        if (1
            & (xAND (
                xEQ (bitToFixed (
                         (putBITp (16, mOPOPxPTR, getBIT (16, mVM_DETAGxINX)),
                          OPOP (0))),
                     COREHALFWORD (mADLP)),
                SHR (getFIXED (mOPR
                               + 4 * xadd (COREHALFWORD (mVM_DETAGxINX), 1)),
                     8))))
          // RETURN; (2387)
          {
            reentryGuard = 0;
            return 0;
          }
      // INX = INX + NO_OPERANDS(INX) +1; (2388)
      {
        int32_t numberRHS = (int32_t)(xadd (
            xadd (COREHALFWORD (mVM_DETAGxINX),
                  bitToFixed ((putBITp (16, mNO_OPERANDSxPTR,
                                        getBIT (16, mVM_DETAGxINX)),
                               NO_OPERANDS (0)))),
            1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mVM_DETAGxINX, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
