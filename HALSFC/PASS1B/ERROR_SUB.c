/*
  File ERROR_SUB.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

jmp_buf jbERROR_SUBxBAD_ERROR_SUB;

int32_t
ERROR_SUB (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "ERROR_SUB");
  int setjmpInitialize = 1;
  if (setjmpInitialize)
    {
      goto BAD_ERROR_SUB;
    setjmpInitialized:
      setjmpInitialize = 0;
    }
  // TEMP=PTR(MP+2); (7370)
  {
    descriptor_t *bitRHS = getBIT (16, mPTR + 2 * xadd (getFIXED (mMP), 2));
    int32_t numberRHS;
    numberRHS = bitToFixed (bitRHS);
    putFIXED (mTEMP, numberRHS);
    bitRHS->inUse = 0;
  }
  // FIXV(MP)= 16383; (7371)
  {
    int32_t numberRHS = (int32_t)(16383);
    putFIXED (mFIXV + 4 * (getFIXED (mMP)), numberRHS);
  }
  // LOC_P(TEMP)= 255; (7372)
  {
    int32_t numberRHS = (int32_t)(255);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mLOC_P + 2 * (getFIXED (mTEMP)), bitRHS);
    bitRHS->inUse = 0;
  }
  // IF PSEUDO_FORM(TEMP)~=0 THEN (7373)
  if (1 & (xNEQ (BYTE0 (mPSEUDO_FORM + 1 * getFIXED (mTEMP)), 0)))
    // DO; (7374)
    {
    rs1:;
      // BAD_ERROR_SUB: (7375)
      if (0)
        {
        BAD_ERROR_SUB:
          if (setjmpInitialize)
            {
              if (!setjmp (jbERROR_SUBxBAD_ERROR_SUB))
                goto setjmpInitialized;
            }
        }
      // CALL ERROR(CLASS_RE,MODE); (7376)
      {
        putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_RE));
        putBITp (8, mERRORxNUM, getBIT (16, mERROR_SUBxMODE));
        ERROR (0);
      }
      // RETURN; (7377)
      {
        reentryGuard = 0;
        return 0;
      }
    es1:;
    } // End of DO block
  // PSEUDO_FORM(TEMP)=XIMD; (7378)
  {
    descriptor_t *bitRHS = getBIT (8, mXIMD);
    putBIT (8, mPSEUDO_FORM + 1 * (getFIXED (mTEMP)), bitRHS);
    bitRHS->inUse = 0;
  }
  // IF MODE=2 THEN (7379)
  if (1 & (xEQ (COREHALFWORD (mERROR_SUBxMODE), 2)))
    // DO; (7380)
    {
    rs2:;
      // IF INX(TEMP)~=2 THEN (7381)
      if (1 & (xNEQ (COREHALFWORD (mINX + 2 * getFIXED (mTEMP)), 2)))
        // GO TO BAD_ERROR_SUB; (7382)
        goto BAD_ERROR_SUB;
      // IF PSEUDO_LENGTH(TEMP)~=0 THEN (7383)
      if (1 & (xNEQ (COREHALFWORD (mPSEUDO_LENGTH + 2 * getFIXED (mTEMP)), 0)))
        // GO TO BAD_ERROR_SUB; (7384)
        goto BAD_ERROR_SUB;
      // IF VAL_P(TEMP)~=1 THEN (7385)
      if (1 & (xNEQ (COREHALFWORD (mVAL_P + 2 * getFIXED (mTEMP)), 1)))
        // GO TO BAD_ERROR_SUB; (7386)
        goto BAD_ERROR_SUB;
      // XSET 14; (7387)
      {
        int32_t numberRHS = (int32_t)(xOR (COREHALFWORD (mSTMT_TYPE), 14));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mSTMT_TYPE, bitRHS);
        bitRHS->inUse = 0;
      }
      // LOC_P(TEMP)=ERROR_SS_FIX(1); (7388)
      {
        descriptor_t *bitRHS = (putFIXED (mERROR_SUBxERROR_SS_FIXxLOC, 1),
                                ERROR_SUBxERROR_SS_FIX (0));
        putBIT (16, mLOC_P + 2 * (getFIXED (mTEMP)), bitRHS);
        bitRHS->inUse = 0;
      }
      // FIXV(MP)=ERROR_SS_FIX(2)|SHL(LOC_P(TEMP),6); (7389)
      {
        int32_t numberRHS = (int32_t)(xOR (
            bitToFixed ((putFIXED (mERROR_SUBxERROR_SS_FIXxLOC, 2),
                         ERROR_SUBxERROR_SS_FIX (0))),
            SHL (COREHALFWORD (mLOC_P + 2 * getFIXED (mTEMP)), 6)));
        putFIXED (mFIXV + 4 * (getFIXED (mMP)), numberRHS);
      }
    es2:;
    } // End of DO block
  // ELSE (7390)
  else
    // DO; (7391)
    {
    rs3:;
      // XSET 15; (7392)
      {
        int32_t numberRHS = (int32_t)(xOR (COREHALFWORD (mSTMT_TYPE), 15));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mSTMT_TYPE, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF INX(TEMP)>2 THEN (7393)
      if (1 & (xGT (COREHALFWORD (mINX + 2 * getFIXED (mTEMP)), 2)))
        // GO TO BAD_ERROR_SUB; (7394)
        goto BAD_ERROR_SUB;
      // DO CASE INX(TEMP); (7395)
      {
      rs3s1:
        switch (COREHALFWORD (mINX + 2 * getFIXED (mTEMP)))
          {
          case 0:
              // ; (7397)
              ;
            break;
          case 1:
            // DO; (7398)
            {
            rs3s1s1:;
              // IF PSEUDO_LENGTH(TEMP)>0 THEN (7398)
              if (1
                  & (xGT (COREHALFWORD (mPSEUDO_LENGTH + 2 * getFIXED (mTEMP)),
                          0)))
                // GO TO BAD_ERROR_SUB; (7399)
                goto BAD_ERROR_SUB;
              // IF ~VAL_P(TEMP) THEN (7400)
              if (1 & (xNOT (COREHALFWORD (mVAL_P + 2 * getFIXED (mTEMP)))))
                // GO TO BAD_ERROR_SUB; (7401)
                goto BAD_ERROR_SUB;
              // LOC_P(TEMP)=ERROR_SS_FIX(1); (7402)
              {
                descriptor_t *bitRHS
                    = (putFIXED (mERROR_SUBxERROR_SS_FIXxLOC, 1),
                       ERROR_SUBxERROR_SS_FIX (0));
                putBIT (16, mLOC_P + 2 * (getFIXED (mTEMP)), bitRHS);
                bitRHS->inUse = 0;
              }
              // FIXV(MP)=SHL(LOC_P(TEMP),6)| 63; (7403)
              {
                int32_t numberRHS = (int32_t)(xOR (
                    SHL (COREHALFWORD (mLOC_P + 2 * getFIXED (mTEMP)), 6),
                    63));
                putFIXED (mFIXV + 4 * (getFIXED (mMP)), numberRHS);
              }
            es3s1s1:;
            } // End of DO block
            break;
          case 2:
            // DO; (7405)
            {
            rs3s1s2:;
              // IF PSEUDO_LENGTH(TEMP)~=0 THEN (7405)
              if (1
                  & (xNEQ (
                      COREHALFWORD (mPSEUDO_LENGTH + 2 * getFIXED (mTEMP)),
                      0)))
                // GO TO BAD_ERROR_SUB; (7406)
                goto BAD_ERROR_SUB;
              // IF VAL_P(TEMP)~=1 THEN (7407)
              if (1 & (xNEQ (COREHALFWORD (mVAL_P + 2 * getFIXED (mTEMP)), 1)))
                // GO TO BAD_ERROR_SUB; (7408)
                goto BAD_ERROR_SUB;
              // LOC_P(TEMP)=ERROR_SS_FIX(1); (7409)
              {
                descriptor_t *bitRHS
                    = (putFIXED (mERROR_SUBxERROR_SS_FIXxLOC, 1),
                       ERROR_SUBxERROR_SS_FIX (0));
                putBIT (16, mLOC_P + 2 * (getFIXED (mTEMP)), bitRHS);
                bitRHS->inUse = 0;
              }
              // FIXV(MP)=ERROR_SS_FIX(2)|SHL(LOC_P(TEMP),6); (7410)
              {
                int32_t numberRHS = (int32_t)(xOR (
                    bitToFixed ((putFIXED (mERROR_SUBxERROR_SS_FIXxLOC, 2),
                                 ERROR_SUBxERROR_SS_FIX (0))),
                    SHL (COREHALFWORD (mLOC_P + 2 * getFIXED (mTEMP)), 6)));
                putFIXED (mFIXV + 4 * (getFIXED (mMP)), numberRHS);
              }
            es3s1s2:;
            } // End of DO block
            break;
          }
      } // End of DO CASE block
      // MODE=-SYT_ARRAY(BLOCK_SYTREF(NEST)); (7411)
      {
        int32_t numberRHS = (int32_t)(xminus (COREHALFWORD (
            getFIXED (mSYM_TAB)
            + 34 * (COREHALFWORD (mBLOCK_SYTREF + 2 * getFIXED (mNEST))) + 20
            + 2 * (0))));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mERROR_SUBxMODE, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO WHILE MODE>ON_ERROR_PTR; (7412)
      while (1
             & (xGT (COREHALFWORD (mERROR_SUBxMODE),
                     COREHALFWORD (mON_ERROR_PTR))))
        {
          // MODE=MODE-1; (7413)
          {
            int32_t numberRHS
                = (int32_t)(xsubtract (COREHALFWORD (mERROR_SUBxMODE), 1));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mERROR_SUBxMODE, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF FIXV(MP)=EXT_ARRAY(MODE) THEN (7414)
          if (1
              & (xEQ (getFIXED (mFIXV + 4 * getFIXED (mMP)),
                      COREHALFWORD (mEXT_ARRAY
                                    + 2 * COREHALFWORD (mERROR_SUBxMODE)))))
            // MODE=0; (7415)
            {
              int32_t numberRHS = (int32_t)(0);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mERROR_SUBxMODE, bitRHS);
              bitRHS->inUse = 0;
            }
        } // End of DO WHILE block
      // IF MODE>0 THEN (7416)
      if (1 & (xGT (COREHALFWORD (mERROR_SUBxMODE), 0)))
        // DO; (7417)
        {
        rs3s3:;
          // IF ON_ERROR_PTR=EXT_ARRAY_PTR THEN (7418)
          if (1
              & (xEQ (COREHALFWORD (mON_ERROR_PTR),
                      getFIXED (mEXT_ARRAY_PTR))))
            // CALL ERROR(CLASS_RE,3); (7419)
            {
              putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_RE));
              putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(3)));
              ERROR (0);
            }
          // ELSE (7420)
          else
            // DO; (7421)
            {
            rs3s3s1:;
              // ON_ERROR_PTR=ON_ERROR_PTR-1; (7422)
              {
                int32_t numberRHS
                    = (int32_t)(xsubtract (COREHALFWORD (mON_ERROR_PTR), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mON_ERROR_PTR, bitRHS);
                bitRHS->inUse = 0;
              }
              // EXT_ARRAY(ON_ERROR_PTR)=FIXV(MP); (7423)
              {
                int32_t numberRHS
                    = (int32_t)(getFIXED (mFIXV + 4 * getFIXED (mMP)));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mEXT_ARRAY + 2 * (COREHALFWORD (mON_ERROR_PTR)),
                        bitRHS);
                bitRHS->inUse = 0;
              }
            es3s3s1:;
            } // End of DO block
        es3s3:;
        } // End of DO block
    es3:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
