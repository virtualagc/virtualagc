/*
  File GENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REG.c generated by
  XCOM-I, 2024-08-09 12:41:32.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REG (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (
      reentryGuard, "GENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REG");
  // IF ((OPTYPE&8) = 0) & (TYPE(OP1) ~= TYPE(OP2)) THEN (13211)
  if (1
      & (xAND (
          xEQ (xAND (COREHALFWORD (mOPTYPE), 8), 0),
          xNEQ (
              COREHALFWORD (
                  getFIXED (mIND_STACK)
                  + 73
                        * (COREHALFWORD (
                            mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                  + 50 + 2 * (0)),
              COREHALFWORD (
                  getFIXED (mIND_STACK)
                  + 73
                        * (COREHALFWORD (
                            mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP2))
                  + 50 + 2 * (0))))))
    // DO; (13212)
    {
    rs1:;
      // IF ~REG(OP1) THEN (13213)
      if (1
          & (xNOT (COREHALFWORD (
              getFIXED (mIND_STACK)
              + 73
                    * (COREHALFWORD (
                        mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
              + 46 + 2 * (0)))))
        // DO; (13214)
        {
        rs1s1:;
          // CALL EMITP(SLDL, REG(OP1), 0, SHCOUNT, 31); (13215)
          {
            putBITp (16, mGENERATExEMITPxINST, getBIT (8, mSLDL));
            putBITp (
                16, mGENERATExEMITPxXREG,
                getBIT (
                    16,
                    getFIXED (mIND_STACK)
                        + 73
                              * (COREHALFWORD (
                                  mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                        + 46 + 2 * (0)));
            putBITp (16, mGENERATExEMITPxINDEX, fixedToBit (32, (int32_t)(0)));
            putBITp (16, mGENERATExEMITPxFLAG, getBIT (8, mSHCOUNT));
            putBITp (16, mGENERATExEMITPxPTR, fixedToBit (32, (int32_t)(31)));
            GENERATExEMITP (0);
          }
          // USAGE(REG(OP1)+1) = 0; (13216)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (
                16,
                mUSAGE
                    + 2
                          * (xadd (
                              COREHALFWORD (
                                  getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                                  + 46 + 2 * (0)),
                              1)),
                bitRHS);
            bitRHS->inUse = 0;
          }
        es1s1:;
        } // End of DO block
      // ELSE (13217)
      else
        // CALL EMITP(SLL, REG(OP1), 0, SHCOUNT, 15); (13218)
        {
          putBITp (16, mGENERATExEMITPxINST, getBIT (8, mSLL));
          putBITp (
              16, mGENERATExEMITPxXREG,
              getBIT (
                  16,
                  getFIXED (mIND_STACK)
                      + 73
                            * (COREHALFWORD (
                                mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                      + 46 + 2 * (0)));
          putBITp (16, mGENERATExEMITPxINDEX, fixedToBit (32, (int32_t)(0)));
          putBITp (16, mGENERATExEMITPxFLAG, getBIT (8, mSHCOUNT));
          putBITp (16, mGENERATExEMITPxPTR, fixedToBit (32, (int32_t)(15)));
          GENERATExEMITP (0);
        }
    es1:;
    } // End of DO block
  // ELSE (13219)
  else
    // DO CASE (OPTYPE&8) ~= 0; (13220)
    {
    rs2:
      switch (xNEQ (xAND (COREHALFWORD (mOPTYPE), 8), 0))
        {
        case 0:
          // DO; (13222)
          {
          rs2s1:;
            // CALL EMITP(SLL, REG(OP1), 0, SHCOUNT, 15); (13222)
            {
              putBITp (16, mGENERATExEMITPxINST, getBIT (8, mSLL));
              putBITp (
                  16, mGENERATExEMITPxXREG,
                  getBIT (
                      16,
                      getFIXED (mIND_STACK)
                          + 73
                                * (COREHALFWORD (
                                    mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                          + 46 + 2 * (0)));
              putBITp (16, mGENERATExEMITPxINDEX,
                       fixedToBit (32, (int32_t)(0)));
              putBITp (16, mGENERATExEMITPxFLAG, getBIT (8, mSHCOUNT));
              putBITp (16, mGENERATExEMITPxPTR,
                       fixedToBit (32, (int32_t)(15)));
              GENERATExEMITP (0);
            }
            // IF ~REG(OP1) THEN (13223)
            if (1
                & (xNOT (COREHALFWORD (
                    getFIXED (mIND_STACK)
                    + 73
                          * (COREHALFWORD (
                              mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                    + 46 + 2 * (0)))))
              // USAGE(REG(OP1)+1) = 0; (13224)
              {
                int32_t numberRHS = (int32_t)(0);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (
                    16,
                    mUSAGE
                        + 2
                              * (xadd (
                                  COREHALFWORD (
                                      getFIXED (mIND_STACK)
                                      + 73
                                            * (COREHALFWORD (
                                                mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                                      + 46 + 2 * (0)),
                                  1)),
                    bitRHS);
                bitRHS->inUse = 0;
              }
          es2s1:;
          } // End of DO block
          break;
        case 1:
          // DO; (13226)
          {
          rs2s2:;
            // IF TYPE(OP1) ~= TYPE(OP2) THEN (13226)
            if (1
                & (xNEQ (
                    COREHALFWORD (
                        getFIXED (mIND_STACK)
                        + 73
                              * (COREHALFWORD (
                                  mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                        + 50 + 2 * (0)),
                    COREHALFWORD (
                        getFIXED (mIND_STACK)
                        + 73
                              * (COREHALFWORD (
                                  mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP2))
                        + 50 + 2 * (0)))))
              // DO; (13227)
              {
              rs2s2s1:;
                // CALL EMITP(SLDL, REG(OP1), 0, SHCOUNT, 15); (13228)
                {
                  putBITp (16, mGENERATExEMITPxINST, getBIT (8, mSLDL));
                  putBITp (
                      16, mGENERATExEMITPxXREG,
                      getBIT (
                          16,
                          getFIXED (mIND_STACK)
                              + 73
                                    * (COREHALFWORD (
                                        mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                              + 46 + 2 * (0)));
                  putBITp (16, mGENERATExEMITPxINDEX,
                           fixedToBit (32, (int32_t)(0)));
                  putBITp (16, mGENERATExEMITPxFLAG, getBIT (8, mSHCOUNT));
                  putBITp (16, mGENERATExEMITPxPTR,
                           fixedToBit (32, (int32_t)(15)));
                  GENERATExEMITP (0);
                }
                // USAGE(REG(OP1)+1) = 0; (13229)
                {
                  int32_t numberRHS = (int32_t)(0);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (
                      16,
                      mUSAGE
                          + 2
                                * (xadd (
                                    COREHALFWORD (
                                        getFIXED (mIND_STACK)
                                        + 73
                                              * (COREHALFWORD (
                                                  mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                                        + 46 + 2 * (0)),
                                    1)),
                      bitRHS);
                  bitRHS->inUse = 0;
                }
              es2s2s1:;
              } // End of DO block
            // ELSE (13230)
            else
              // DO; (13231)
              {
              rs2s2s2:;
                // CALL EMITP(SRDA, REG(OP1), 0, SHCOUNT, 1); (13232)
                {
                  putBITp (16, mGENERATExEMITPxINST, getBIT (8, mSRDA));
                  putBITp (
                      16, mGENERATExEMITPxXREG,
                      getBIT (
                          16,
                          getFIXED (mIND_STACK)
                              + 73
                                    * (COREHALFWORD (
                                        mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                              + 46 + 2 * (0)));
                  putBITp (16, mGENERATExEMITPxINDEX,
                           fixedToBit (32, (int32_t)(0)));
                  putBITp (16, mGENERATExEMITPxFLAG, getBIT (8, mSHCOUNT));
                  putBITp (16, mGENERATExEMITPxPTR,
                           fixedToBit (32, (int32_t)(1)));
                  GENERATExEMITP (0);
                }
                // USAGE(REG(OP1)) = 0; (13233)
                {
                  int32_t numberRHS = (int32_t)(0);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (
                      16,
                      mUSAGE
                          + 2
                                * (COREHALFWORD (
                                    getFIXED (mIND_STACK)
                                    + 73
                                          * (COREHALFWORD (
                                              mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                                    + 46 + 2 * (0))),
                      bitRHS);
                  bitRHS->inUse = 0;
                }
                // REG(OP1) = REG(OP1) + 1; (13234)
                {
                  int32_t numberRHS = (int32_t)(xadd (
                      COREHALFWORD (
                          getFIXED (mIND_STACK)
                          + 73
                                * (COREHALFWORD (
                                    mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                          + 46 + 2 * (0)),
                      1));
                  putBIT (
                      16,
                      getFIXED (mIND_STACK)
                          + 73
                                * (COREHALFWORD (
                                    mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                          + 46 + 2 * (0),
                      fixedToBit (16, numberRHS));
                }
                // USAGE(REG(OP1)) = 2; (13235)
                {
                  int32_t numberRHS = (int32_t)(2);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (
                      16,
                      mUSAGE
                          + 2
                                * (COREHALFWORD (
                                    getFIXED (mIND_STACK)
                                    + 73
                                          * (COREHALFWORD (
                                              mGENERATExGEN_CLASS6xINTEGER_MULTIPLYxSET_RESULT_REGxOP1))
                                    + 46 + 2 * (0))),
                      bitRHS);
                  bitRHS->inUse = 0;
                }
              es2s2s2:;
              } // End of DO block
          es2s2:;
          } // End of DO block
          break;
        }
    } // End of DO CASE block
  {
    reentryGuard = 0;
    return 0;
  }
}