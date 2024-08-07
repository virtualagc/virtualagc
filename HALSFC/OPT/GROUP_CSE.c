/*
  File GROUP_CSE.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
GROUP_CSE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GROUP_CSE");
  // TOP,INX = NODE(INX) &  65535; (2180)
  {
    int32_t numberRHS = (int32_t)(xAND (
        getFIXED (mNODE + 4 * COREHALFWORD (mGROUP_CSExINX)), 65535));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGROUP_CSExTOP, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGROUP_CSExINX, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF ~NONCOMMUTATIVE THEN (2181)
  if (1 & (xNOT (BYTE0 (mNONCOMMUTATIVE))))
    // DO; (2182)
    {
    rs1:;
      // A_INX = 1; (2183)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mA_INX, bitRHS);
        bitRHS->inUse = 0;
      }
      // ADD(1) = INX; (2184)
      {
        descriptor_t *bitRHS = getBIT (16, mGROUP_CSExINX);
        putBIT (16, mADD + 2 * (1), bitRHS);
        bitRHS->inUse = 0;
      }
      // DO WHILE A_INX > 0; (2185)
      while (1 & (xGT (COREHALFWORD (mA_INX), 0)))
        {
          // TEMP = ADD(A_INX); (2186)
          {
            descriptor_t *bitRHS
                = getBIT (16, mADD + 2 * COREHALFWORD (mA_INX));
            putBIT (16, mGROUP_CSExTEMP, bitRHS);
            bitRHS->inUse = 0;
          }
          // A_INX = A_INX - 1; (2187)
          {
            int32_t numberRHS
                = (int32_t)(xsubtract (COREHALFWORD (mA_INX), 1));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mA_INX, bitRHS);
            bitRHS->inUse = 0;
          }
          // DO FOR K = TEMP + 1 TO LAST_OPERAND(TEMP); (2188)
          {
            int32_t from51, to51, by51;
            from51 = xadd (COREHALFWORD (mGROUP_CSExTEMP), 1);
            to51 = bitToFixed (
                (putBITp (16, mLAST_OPERANDxPTR, getBIT (16, mGROUP_CSExTEMP)),
                 LAST_OPERAND (0)));
            by51 = 1;
            for (putBIT (16, mGROUP_CSExK, fixedToBit (16, from51));
                 bitToFixed (getBIT (16, mGROUP_CSExK)) <= to51;
                 putBIT (16, mGROUP_CSExK,
                         fixedToBit (16, bitToFixed (getBIT (16, mGROUP_CSExK))
                                             + by51)))
              {
                // IF ~TERMINAL(K,1) THEN (2189)
                if (1
                    & (xNOT (bitToFixed ((
                        putBITp (16, mTERMINALxPTR, getBIT (16, mGROUP_CSExK)),
                        putBITp (8, mTERMINALxTAG,
                                 fixedToBit (32, (int32_t)(1))),
                        TERMINAL (0))))))
                  // DO; (2190)
                  {
                  rs1s1s1s1:;
                    // LAST = LAST_OP(TOP - 1); (2191)
                    {
                      int32_t numberRHS = (int32_t)((
                          putBITp (
                              16, mLAST_OPxPTR,
                              fixedToBit (
                                  32, (int32_t)(xsubtract (
                                          COREHALFWORD (mGROUP_CSExTOP), 1)))),
                          LAST_OP (0)));
                      descriptor_t *bitRHS;
                      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                      putBIT (16, mGROUP_CSExLAST, bitRHS);
                      bitRHS->inUse = 0;
                    }
                    // PTR = SHR(OPR(K),16); (2192)
                    {
                      int32_t numberRHS = (int32_t)(SHR (
                          getFIXED (mOPR + 4 * COREHALFWORD (mGROUP_CSExK)),
                          16));
                      descriptor_t *bitRHS;
                      bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                      putBIT (16, mGROUP_CSExPTR, bitRHS);
                      bitRHS->inUse = 0;
                    }
                    // CALL BUMP_ADD(PTR); (2193)
                    {
                      putBITp (16, mBUMP_ADDxPTR, getBIT (16, mGROUP_CSExPTR));
                      BUMP_ADD (0);
                    }
                    // IF LAST = PTR THEN (2194)
                    if (1
                        & (xEQ (COREHALFWORD (mGROUP_CSExLAST),
                                COREHALFWORD (mGROUP_CSExPTR))))
                      // TOP = LAST; (2195)
                      {
                        descriptor_t *bitRHS = getBIT (16, mGROUP_CSExLAST);
                        putBIT (16, mGROUP_CSExTOP, bitRHS);
                        bitRHS->inUse = 0;
                      }
                    // ELSE (2196)
                    else
                      // DO; (2197)
                      {
                      rs1s1s1s1s1:;
                        // PTR2 = LAST_OPERAND(PTR) + 1; (2198)
                        {
                          int32_t numberRHS = (int32_t)(xadd (
                              bitToFixed (
                                  (putBITp (16, mLAST_OPERANDxPTR,
                                            getBIT (16, mGROUP_CSExPTR)),
                                   LAST_OPERAND (0))),
                              1));
                          descriptor_t *bitRHS;
                          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                          putBIT (16, mGROUP_CSExPTR2, bitRHS);
                          bitRHS->inUse = 0;
                        }
                        // CALL MOVE_LIMB(PTR,PTR2,TOP - PTR2,0,1); (2199)
                        {
                          putBITp (16, mMOVE_LIMBxLOW,
                                   getBIT (16, mGROUP_CSExPTR));
                          putBITp (16, mMOVE_LIMBxHIGH,
                                   getBIT (16, mGROUP_CSExPTR2));
                          putBITp (
                              16, mMOVE_LIMBxBIG,
                              fixedToBit (
                                  32, (int32_t)(xsubtract (
                                          COREHALFWORD (mGROUP_CSExTOP),
                                          COREHALFWORD (mGROUP_CSExPTR2)))));
                          putBITp (8, mMOVE_LIMBxQUICK_MOVE,
                                   fixedToBit (32, (int32_t)(0)));
                          putBITp (8, mMOVE_LIMBxRELOCATE_ADD,
                                   fixedToBit (32, (int32_t)(1)));
                          MOVE_LIMB (0);
                        }
                        // TOP = PTR + TOP - PTR2; (2200)
                        {
                          int32_t numberRHS = (int32_t)(xsubtract (
                              xadd (COREHALFWORD (mGROUP_CSExPTR),
                                    COREHALFWORD (mGROUP_CSExTOP)),
                              COREHALFWORD (mGROUP_CSExPTR2)));
                          descriptor_t *bitRHS;
                          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                          putBIT (16, mGROUP_CSExTOP, bitRHS);
                          bitRHS->inUse = 0;
                        }
                      es1s1s1s1s1:;
                      } // End of DO block
                  es1s1s1s1:;
                  } // End of DO block
              }
          } // End of DO for-loop block
        }   // End of DO WHILE block
      // HALMAT_NODE_START = TOP; (2201)
      {
        descriptor_t *bitRHS = getBIT (16, mGROUP_CSExTOP);
        putBIT (16, mHALMAT_NODE_START, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // RETURN INX; (2202)
  {
    reentryGuard = 0;
    return COREHALFWORD (mGROUP_CSExINX);
  }
}
