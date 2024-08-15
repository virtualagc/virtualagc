/*
  File GENERATExMOD_GET_OPERAND.c generated by XCOM-I, 2024-08-09 12:39:31.
*/

#include "runtimeC.h"

descriptor_t *
GENERATExMOD_GET_OPERAND (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExMOD_GET_OPERAND");
  // VAC_FLAG,NAME_OP_FLAG,REMOTE_RECVR,SUBSTRUCT_FLAG=FALSE; (8750)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExVAC_FLAG, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExNAME_OP_FLAG, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExREMOTE_RECVR, bitRHS);
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (1, mGENERATExSUBSTRUCT_FLAG, bitRHS);
    bitRHS->inUse = 0;
  }
  // PTR = 0; (8751)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExMOD_GET_OPERANDxPTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL DECODEPIP(OP,0); (8752)
  {
    putBITp (16, mGENERATExDECODEPIPxOP,
             getBIT (16, mGENERATExMOD_GET_OPERANDxOP));
    putBITp (16, mGENERATExDECODEPIPxN, fixedToBit (32, (int32_t)(0)));
    GENERATExDECODEPIP (0);
  }
  // DO CASE TAG1; (8753)
  {
  rs1:
    switch (COREHALFWORD (mTAG1))
      {
      case 0:
          // ; (8755)
          ;
        break;
      case 1:
        // DO; (8756)
        {
        rs1s1:;
          // PTR=GET_STACK_ENTRY; (8756)
          {
            int32_t numberRHS = (int32_t)(GENERATExGET_STACK_ENTRY (0));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mGENERATExMOD_GET_OPERANDxPTR, bitRHS);
            bitRHS->inUse = 0;
          }
          // FORM(PTR)=SYM; (8757)
          {
            descriptor_t *bitRHS = getBIT (8, mSYM);
            putBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 32 + 2 * (0),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // IF (SYT_FLAGS(OP1) & NAME_FLAG)~=0 THEN (8758)
          if (1
              & (xNEQ (
                  xAND (getFIXED (getFIXED (mSYM_TAB)
                                  + 34 * (COREHALFWORD (mOP1)) + 8 + 4 * (0)),
                        getFIXED (mNAME_FLAG)),
                  0)))
            // NAME_OP_FLAG=TRUE; (8759)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mGENERATExNAME_OP_FLAG, bitRHS);
              bitRHS->inUse = 0;
            }
          // LOC(PTR),LOC2(PTR)=OP1; (8760)
          {
            descriptor_t *bitRHS = getBIT (16, mOP1);
            putBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 40 + 2 * (0),
                    bitRHS);
            putBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 42 + 2 * (0),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // TYPE(PTR)=SYT_TYPE(OP1); (8761)
          {
            descriptor_t *bitRHS
                = getBIT (8, getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mOP1))
                                 + 32 + 1 * (0));
            putBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 50 + 2 * (0),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // IF SYT_ARRAY(OP1) ~= 0 THEN (8762)
          if (1
              & (xNEQ (COREHALFWORD (getFIXED (mSYM_TAB)
                                     + 34 * (COREHALFWORD (mOP1)) + 20
                                     + 2 * (0)),
                       0)))
            // ARRAY_FLAG = TRUE; (8763)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mARRAY_FLAG, bitRHS);
              bitRHS->inUse = 0;
            }
          // IF CHECK_REMOTE(PTR) THEN (8764)
          if (1
              & (bitToFixed (
                  (putBITp (16, mGENERATExCHECK_REMOTExOP,
                            getBIT (16, mGENERATExMOD_GET_OPERANDxPTR)),
                   GENERATExCHECK_REMOTE (0)))))
            // REMOTE_RECVR = TRUE ; (8765)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mGENERATExREMOTE_RECVR, bitRHS);
              bitRHS->inUse = 0;
            }
          // IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D) THEN (8766)
          if (1
              & (xAND (
                  BYTE0 (mDATA_REMOTE),
                  xEQ (
                      bitToFixed ((
                          putBITp (
                              16, mCSECT_TYPExPTR,
                              getBIT (
                                  16,
                                  getFIXED (mIND_STACK)
                                      + 73
                                            * (COREHALFWORD (
                                                mGENERATExMOD_GET_OPERANDxPTR))
                                      + 40 + 2 * (0))),
                          putBITp (16, mCSECT_TYPExOP,
                                   getBIT (16, mGENERATExMOD_GET_OPERANDxPTR)),
                          CSECT_TYPE (0))),
                      6))))
            // REMOTE_RECVR = TRUE; (8767)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mGENERATExREMOTE_RECVR, bitRHS);
              bitRHS->inUse = 0;
            }
        es1s1:;
        } // End of DO block
        break;
      case 2:
          // ; (8769)
          ;
        break;
      case 3:
        // DO; (8770)
        {
        rs1s2:;
          // PTR=FETCH_VAC(OP1,-1); (8770)
          {
            descriptor_t *bitRHS
                = (putBITp (16, mGENERATExFETCH_VACxOP, getBIT (16, mOP1)),
                   putBITp (16, mGENERATExFETCH_VACxN,
                            fixedToBit (32, (int32_t)(-1))),
                   GENERATExFETCH_VAC (0));
            putBIT (16, mGENERATExMOD_GET_OPERANDxPTR, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF CHECK_REMOTE(PTR) THEN (8771)
          if (1
              & (bitToFixed (
                  (putBITp (16, mGENERATExCHECK_REMOTExOP,
                            getBIT (16, mGENERATExMOD_GET_OPERANDxPTR)),
                   GENERATExCHECK_REMOTE (0)))))
            // REMOTE_RECVR = TRUE; (8772)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mGENERATExREMOTE_RECVR, bitRHS);
              bitRHS->inUse = 0;
            }
          // IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D) THEN (8773)
          if (1
              & (xAND (
                  BYTE0 (mDATA_REMOTE),
                  xEQ (
                      bitToFixed ((
                          putBITp (
                              16, mCSECT_TYPExPTR,
                              getBIT (
                                  16,
                                  getFIXED (mIND_STACK)
                                      + 73
                                            * (COREHALFWORD (
                                                mGENERATExMOD_GET_OPERANDxPTR))
                                      + 40 + 2 * (0))),
                          putBITp (16, mCSECT_TYPExOP,
                                   getBIT (16, mGENERATExMOD_GET_OPERANDxPTR)),
                          CSECT_TYPE (0))),
                      6))))
            // REMOTE_RECVR = TRUE; (8774)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mGENERATExREMOTE_RECVR, bitRHS);
              bitRHS->inUse = 0;
            }
        es1s2:;
        } // End of DO block
        break;
      case 4:
        // DO; (8776)
        {
        rs1s3:;
          // SAVCTR=CTR; (8776)
          {
            descriptor_t *bitRHS = getBIT (16, mCTR);
            putBIT (16, mGENERATExMOD_GET_OPERANDxSAVCTR, bitRHS);
            bitRHS->inUse = 0;
          }
          // CTR=OP1; (8777)
          {
            descriptor_t *bitRHS = getBIT (16, mOP1);
            putBIT (16, mCTR, bitRHS);
            bitRHS->inUse = 0;
          }
          // CALL DECODEPIP(1,1); (8778)
          {
            putBITp (16, mGENERATExDECODEPIPxOP,
                     fixedToBit (32, (int32_t)(1)));
            putBITp (16, mGENERATExDECODEPIPxN, fixedToBit (32, (int32_t)(1)));
            GENERATExDECODEPIP (0);
          }
          // IF TAG1=SYM THEN (8779)
          if (1 & (xEQ (COREHALFWORD (mTAG1), BYTE0 (mSYM))))
            // DO; (8780)
            {
            rs1s3s1:;
              // PTR=GET_STACK_ENTRY; (8781)
              {
                int32_t numberRHS = (int32_t)(GENERATExGET_STACK_ENTRY (0));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mGENERATExMOD_GET_OPERANDxPTR, bitRHS);
                bitRHS->inUse = 0;
              }
              // LOC(PTR)=OP1; (8782)
              {
                descriptor_t *bitRHS = getBIT (16, mOP1);
                putBIT (
                    16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 40 + 2 * (0),
                    bitRHS);
                bitRHS->inUse = 0;
              }
              // TYPE(PTR)=SYT_TYPE(OP1); (8783)
              {
                descriptor_t *bitRHS = getBIT (
                    8, getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mOP1)) + 32
                           + 1 * (0));
                putBIT (
                    16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 50 + 2 * (0),
                    bitRHS);
                bitRHS->inUse = 0;
              }
              // FORM(PTR)=SYM; (8784)
              {
                descriptor_t *bitRHS = getBIT (8, mSYM);
                putBIT (
                    16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 32 + 2 * (0),
                    bitRHS);
                bitRHS->inUse = 0;
              }
              // OP2,LOC2(PTR)=SYT_DIMS(OP1); (8785)
              {
                descriptor_t *bitRHS = getBIT (
                    16, getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mOP1)) + 18
                            + 2 * (0));
                putBIT (16, mOP2, bitRHS);
                putBIT (
                    16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 42 + 2 * (0),
                    bitRHS);
                bitRHS->inUse = 0;
              }
              // IF SYT_ARRAY(OP1) ~= 0 THEN (8786)
              if (1
                  & (xNEQ (COREHALFWORD (getFIXED (mSYM_TAB)
                                         + 34 * (COREHALFWORD (mOP1)) + 20
                                         + 2 * (0)),
                           0)))
                // ARRAY_FLAG = TRUE; (8787)
                {
                  int32_t numberRHS = (int32_t)(1);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (1, mARRAY_FLAG, bitRHS);
                  bitRHS->inUse = 0;
                }
            es1s3s1:;
            } // End of DO block
          // ELSE (8788)
          else
            // DO; (8789)
            {
            rs1s3s2:;
              // PTR=FETCH_VAC(OP1,-1); (8790)
              {
                descriptor_t *bitRHS
                    = (putBITp (16, mGENERATExFETCH_VACxOP, getBIT (16, mOP1)),
                       putBITp (16, mGENERATExFETCH_VACxN,
                                fixedToBit (32, (int32_t)(-1))),
                       GENERATExFETCH_VAC (0));
                putBIT (16, mGENERATExMOD_GET_OPERANDxPTR, bitRHS);
                bitRHS->inUse = 0;
              }
              // SUBSTRUCT_FLAG=TRUE; (8791)
              {
                int32_t numberRHS = (int32_t)(1);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (1, mGENERATExSUBSTRUCT_FLAG, bitRHS);
                bitRHS->inUse = 0;
              }
            es1s3s2:;
            } // End of DO block
          // DO OP=2 TO POPNUM(CTR); (8792)
          {
            int32_t from96, to96, by96;
            from96 = 2;
            to96 = (putBITp (16, mPOPNUMxCTR, getBIT (16, mCTR)), POPNUM (0));
            by96 = 1;
            for (putBIT (16, mGENERATExMOD_GET_OPERANDxOP,
                         fixedToBit (16, from96));
                 bitToFixed (getBIT (16, mGENERATExMOD_GET_OPERANDxOP))
                 <= to96;
                 putBIT (16, mGENERATExMOD_GET_OPERANDxOP,
                         fixedToBit (16, bitToFixed (getBIT (
                                             16, mGENERATExMOD_GET_OPERANDxOP))
                                             + by96)))
              {
                // CALL DECODEPIP(OP,1); (8793)
                {
                  putBITp (16, mGENERATExDECODEPIPxOP,
                           getBIT (16, mGENERATExMOD_GET_OPERANDxOP));
                  putBITp (16, mGENERATExDECODEPIPxN,
                           fixedToBit (32, (int32_t)(1)));
                  GENERATExDECODEPIP (0);
                }
                // LOC2(PTR)=OP1; (8794)
                {
                  descriptor_t *bitRHS = getBIT (16, mOP1);
                  putBIT (
                      16,
                      getFIXED (mIND_STACK)
                          + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                          + 42 + 2 * (0),
                      bitRHS);
                  bitRHS->inUse = 0;
                }
                // IF ~SUBSTRUCT_FLAG THEN (8795)
                if (1 & (xNOT (BYTE0 (mGENERATExSUBSTRUCT_FLAG))))
                  // INX_CON(PTR)=INX_CON(PTR) + SYT_ADDR(OP1); (8796)
                  {
                    int32_t numberRHS = (int32_t)(xadd (
                        getFIXED (getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExMOD_GET_OPERANDxPTR))
                                  + 4 + 4 * (0)),
                        getFIXED (getFIXED (mSYM_TAB)
                                  + 34 * (COREHALFWORD (mOP1)) + 4
                                  + 4 * (0))));
                    putFIXED (getFIXED (mIND_STACK)
                                  + 73
                                        * (COREHALFWORD (
                                            mGENERATExMOD_GET_OPERANDxPTR))
                                  + 4 + 4 * (0),
                              numberRHS);
                  }
                // IF OP = POPNUM(CTR) THEN (8797)
                if (1
                    & (xEQ (COREHALFWORD (mGENERATExMOD_GET_OPERANDxOP),
                            (putBITp (16, mPOPNUMxCTR, getBIT (16, mCTR)),
                             POPNUM (0)))))
                  // DO; (8798)
                  {
                  rs1s3s3s1:;
                    // IF (SYT_FLAGS(OP1) & REMOTE_FLAG)~=0 THEN (8799)
                    if (1
                        & (xNEQ (xAND (getFIXED (getFIXED (mSYM_TAB)
                                                 + 34 * (COREHALFWORD (mOP1))
                                                 + 8 + 4 * (0)),
                                       getFIXED (mREMOTE_FLAG)),
                                 0)))
                      // REMOTE_RECVR=TRUE; (8800)
                      {
                        int32_t numberRHS = (int32_t)(1);
                        descriptor_t *bitRHS;
                        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                        putBIT (1, mGENERATExREMOTE_RECVR, bitRHS);
                        bitRHS->inUse = 0;
                      }
                    // IF DATA_REMOTE & (CSECT_TYPE(LOC(PTR),PTR)=LOCAL#D) THEN
                    // (8801)
                    if (1
                        & (xAND (
                            BYTE0 (mDATA_REMOTE),
                            xEQ (
                                bitToFixed ((
                                    putBITp (
                                        16, mCSECT_TYPExPTR,
                                        getBIT (
                                            16,
                                            getFIXED (mIND_STACK)
                                                + 73
                                                      * (COREHALFWORD (
                                                          mGENERATExMOD_GET_OPERANDxPTR))
                                                + 40 + 2 * (0))),
                                    putBITp (
                                        16, mCSECT_TYPExOP,
                                        getBIT (
                                            16,
                                            mGENERATExMOD_GET_OPERANDxPTR)),
                                    CSECT_TYPE (0))),
                                6))))
                      // REMOTE_RECVR = TRUE; (8802)
                      {
                        int32_t numberRHS = (int32_t)(1);
                        descriptor_t *bitRHS;
                        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                        putBIT (1, mGENERATExREMOTE_RECVR, bitRHS);
                        bitRHS->inUse = 0;
                      }
                  es1s3s3s1:;
                  } // End of DO block
                // IF (SYT_FLAGS(OP1) & NAME_FLAG)~= 0 THEN (8803)
                if (1
                    & (xNEQ (xAND (getFIXED (getFIXED (mSYM_TAB)
                                             + 34 * (COREHALFWORD (mOP1)) + 8
                                             + 4 * (0)),
                                   getFIXED (mNAME_FLAG)),
                             0)))
                  // NAME_OP_FLAG=TRUE; (8804)
                  {
                    int32_t numberRHS = (int32_t)(1);
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (1, mGENERATExNAME_OP_FLAG, bitRHS);
                    bitRHS->inUse = 0;
                  }
              }
          } // End of DO for-loop block
          // IF ~(NAME_OP_FLAG | SUBSTRUCT_FLAG) THEN (8805)
          if (1
              & (xNOT (xOR (BYTE0 (mGENERATExNAME_OP_FLAG),
                            BYTE0 (mGENERATExSUBSTRUCT_FLAG)))))
            // INX_CON(PTR) = INX_CON(PTR) + SYT_CONST(LOC2(PTR)); (8806)
            {
              int32_t numberRHS = (int32_t)(xadd (
                  getFIXED (
                      getFIXED (mIND_STACK)
                      + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR)) + 4
                      + 4 * (0)),
                  getFIXED (getFIXED (mP2SYMS)
                            + 12
                                  * (COREHALFWORD (
                                      getFIXED (mIND_STACK)
                                      + 73
                                            * (COREHALFWORD (
                                                mGENERATExMOD_GET_OPERANDxPTR))
                                      + 42 + 2 * (0)))
                            + 0 + 4 * (0))));
              putFIXED (
                  getFIXED (mIND_STACK)
                      + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR)) + 4
                      + 4 * (0),
                  numberRHS);
            }
          // CTR=SAVCTR; (8807)
          {
            descriptor_t *bitRHS
                = getBIT (16, mGENERATExMOD_GET_OPERANDxSAVCTR);
            putBIT (16, mCTR, bitRHS);
            bitRHS->inUse = 0;
          }
          // OP1=LOC2(PTR); (8808)
          {
            descriptor_t *bitRHS = getBIT (
                16, getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 42 + 2 * (0));
            putBIT (16, mOP1, bitRHS);
            bitRHS->inUse = 0;
          }
          // TYPE(PTR)=SYT_TYPE(OP1); (8809)
          {
            descriptor_t *bitRHS
                = getBIT (8, getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mOP1))
                                 + 32 + 1 * (0));
            putBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 50 + 2 * (0),
                    bitRHS);
            bitRHS->inUse = 0;
          }
          // COLUMN(PTR) = SYT_DIMS(OP1) &  255; (8810)
          {
            int32_t numberRHS = (int32_t)(xAND (
                COREHALFWORD (getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mOP1))
                              + 18 + 2 * (0)),
                255));
            putBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 24 + 2 * (0),
                    fixedToBit (16, numberRHS));
          }
          // ROW(PTR) = SHR(SYT_DIMS(OP1), 8); (8811)
          {
            int32_t numberRHS = (int32_t)(SHR (
                COREHALFWORD (getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mOP1))
                              + 18 + 2 * (0)),
                8));
            putBIT (16,
                    getFIXED (mIND_STACK)
                        + 73 * (COREHALFWORD (mGENERATExMOD_GET_OPERANDxPTR))
                        + 48 + 2 * (0),
                    fixedToBit (16, numberRHS));
          }
          // IF SYT_ARRAY(OP1) ~= 0 THEN (8812)
          if (1
              & (xNEQ (COREHALFWORD (getFIXED (mSYM_TAB)
                                     + 34 * (COREHALFWORD (mOP1)) + 20
                                     + 2 * (0)),
                       0)))
            // ARRAY_FLAG = TRUE; (8813)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mARRAY_FLAG, bitRHS);
              bitRHS->inUse = 0;
            }
        es1s3:;
        } // End of DO block
        break;
      case 5:
        // VAC_FLAG=TRUE; (8815)
        {
          int32_t numberRHS = (int32_t)(1);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (1, mGENERATExVAC_FLAG, bitRHS);
          bitRHS->inUse = 0;
        }
        break;
      case 6:
          // ; (8816)
          ;
        break;
      case 7:
          // ; (8817)
          ;
        break;
      case 8:
          // ; (8818)
          ;
        break;
      }
  } // End of DO CASE block
  // RETURN PTR; (8818)
  {
    reentryGuard = 0;
    return getBIT (16, mGENERATExMOD_GET_OPERANDxPTR);
  }
}