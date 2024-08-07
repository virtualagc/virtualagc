/*
  File CHECK_CONSISTENCY.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

int32_t
CHECK_CONSISTENCY (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "CHECK_CONSISTENCY");
  // IF (ATTRIBUTES & CONSTANT_FLAG) ~= 0 THEN (9200)
  if (1 & (xNEQ (xAND (getFIXED (mATTRIBUTES), 4096), 0)))
    // IF (ATTRIBUTES & LOCK_FLAG) ~= 0 THEN (9201)
    if (1 & (xNEQ (xAND (getFIXED (mATTRIBUTES), 1), 0)))
      // DO; (9202)
      {
      rs1:;
        // CALL ERROR(CLASS_DL, 2); (9203)
        {
          putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DL));
          putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(2)));
          ERROR (0);
        }
        // ATTRIBUTES=ATTRIBUTES&(~LOCK_FLAG); (9204)
        {
          int32_t numberRHS
              = (int32_t)(xAND (getFIXED (mATTRIBUTES), 4294967294));
          putFIXED (mATTRIBUTES, numberRHS);
        }
        // ATTR_MASK=ATTR_MASK&(~LOCK_FLAG); (9205)
        {
          int32_t numberRHS
              = (int32_t)(xAND (getFIXED (mATTR_MASK), 4294967294));
          putFIXED (mATTR_MASK, numberRHS);
        }
      es1:;
      } // End of DO block
  // IF (ATTRIBUTES & AUTO_FLAG) ~= 0 THEN (9206)
  if (1 & (xNEQ (xAND (getFIXED (mATTRIBUTES), 256), 0)))
    // IF ((SYT_FLAGS(BLOCK_SYTREF(NEST)) & REENTRANT_FLAG)~=0)  &
    // ~NAME_IMPLIED THEN (9207)
    if (1
        & (xAND (xNEQ (xAND (getFIXED (getFIXED (mSYM_TAB)
                                       + 34
                                             * (COREHALFWORD (
                                                 mBLOCK_SYTREF
                                                 + 2 * getFIXED (mNEST)))
                                       + 8 + 4 * (0)),
                             2),
                       0),
                 xNOT (BYTE0 (mNAME_IMPLIED)))))
      // IF (ATTRIBUTES & REMOTE_FLAG) ~= 0 THEN (9208)
      if (1 & (xNEQ (xAND (getFIXED (mATTRIBUTES), 128), 0)))
        // DO; (9209)
        {
        rs2:;
          // CALL ERROR(CLASS_DA, 15); (9210)
          {
            putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DA));
            putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(15)));
            ERROR (0);
          }
          // ATTRIBUTES=ATTRIBUTES&(~REMOTE_FLAG); (9211)
          {
            int32_t numberRHS
                = (int32_t)(xAND (getFIXED (mATTRIBUTES), 4294967167));
            putFIXED (mATTRIBUTES, numberRHS);
          }
          // ATTR_MASK=ATTR_MASK&(~REMOTE_FLAG); (9212)
          {
            int32_t numberRHS
                = (int32_t)(xAND (getFIXED (mATTR_MASK), 4294967167));
            putFIXED (mATTR_MASK, numberRHS);
          }
        es2:;
        } // End of DO block
  // IF TYPE <= MAJ_STRUC THEN (9213)
  if (1 & (xLE (getFIXED (mTYPE), 10)))
    // DO; (9214)
    {
    rs3:;
      // IF TYPE = MAJ_STRUC THEN (9215)
      if (1 & (xEQ (getFIXED (mTYPE), 10)))
        // IF N_DIM ~= 0 THEN (9216)
        if (1 & (xNEQ (getFIXED (mN_DIM), 0)))
          // DO; (9217)
          {
          rs3s1:;
            // CALL ERROR(CLASS_DA, 26); (9218)
            {
              putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DA));
              putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(26)));
              ERROR (0);
            }
            // N_DIM = 0; (9219)
            {
              int32_t numberRHS = (int32_t)(0);
              putFIXED (mN_DIM, numberRHS);
            }
            // ATTRIBUTES = ATTRIBUTES & (~ARRAY_FLAG); (9220)
            {
              int32_t numberRHS
                  = (int32_t)(xAND (getFIXED (mATTRIBUTES), 4294959103));
              putFIXED (mATTRIBUTES, numberRHS);
            }
          es3s1:;
          } // End of DO block
      // J = FALSE; (9221)
      {
        int32_t numberRHS = (int32_t)(0);
        putFIXED (mJ, numberRHS);
      }
      // IF (ATTRIBUTES & ILL_ATTR(TYPE)) ~= 0 THEN (9222)
      if (1
          & (xNEQ (xAND (getFIXED (mATTRIBUTES),
                         getFIXED (mILL_ATTR + 4 * getFIXED (mTYPE))),
                   0)))
        // DO; (9223)
        {
        rs3s2:;
          // J = TRUE; (9224)
          {
            int32_t numberRHS = (int32_t)(1);
            putFIXED (mJ, numberRHS);
          }
          // ATTRIBUTES=ATTRIBUTES&(~ILL_ATTR(TYPE)); (9225)
          {
            int32_t numberRHS = (int32_t)(xAND (
                getFIXED (mATTRIBUTES),
                xNOT (getFIXED (mILL_ATTR + 4 * getFIXED (mTYPE)))));
            putFIXED (mATTRIBUTES, numberRHS);
          }
          // ATTR_MASK=ATTR_MASK&(~ILL_ATTR(TYPE)); (9226)
          {
            int32_t numberRHS = (int32_t)(xAND (
                getFIXED (mATTR_MASK),
                xNOT (getFIXED (mILL_ATTR + 4 * getFIXED (mTYPE)))));
            putFIXED (mATTR_MASK, numberRHS);
          }
        es3s2:;
        } // End of DO block
      // IF TYPE = 0 THEN (9227)
      if (1 & (xEQ (getFIXED (mTYPE), 0)))
        // IF (ATTRIBUTES & LATCHED_FLAG) ~= 0 THEN (9228)
        if (1 & (xNEQ (xAND (getFIXED (mATTRIBUTES), 131072), 0)))
          // IF (ATTRIBUTES & ILL_LATCHED_ATTR) ~= 0 | (ATTRIBUTES2 &
          // NONHAL_FLAG) ~= 0 THEN (9229)
          if (1
              & (xOR (xNEQ (xAND (getFIXED (mATTRIBUTES),
                                  getFIXED (mILL_LATCHED_ATTR)),
                            0),
                      xNEQ (xAND (getFIXED (mATTRIBUTES2), 1), 0))))
            // DO; (9230)
            {
            rs3s3:;
              // J = TRUE; (9231)
              {
                int32_t numberRHS = (int32_t)(1);
                putFIXED (mJ, numberRHS);
              }
              // ATTRIBUTES=ATTRIBUTES&(~ILL_LATCHED_ATTR); (9232)
              {
                int32_t numberRHS
                    = (int32_t)(xAND (getFIXED (mATTRIBUTES),
                                      xNOT (getFIXED (mILL_LATCHED_ATTR))));
                putFIXED (mATTRIBUTES, numberRHS);
              }
              // ATTRIBUTES2=ATTRIBUTES2&(~NONHAL_FLAG); (9233)
              {
                int32_t numberRHS
                    = (int32_t)(xAND (getFIXED (mATTRIBUTES2), 4294967294));
                putFIXED (mATTRIBUTES2, numberRHS);
              }
              // ATTR_MASK=ATTR_MASK&(~ILL_LATCHED_ATTR); (9234)
              {
                int32_t numberRHS
                    = (int32_t)(xAND (getFIXED (mATTR_MASK),
                                      xNOT (getFIXED (mILL_LATCHED_ATTR))));
                putFIXED (mATTR_MASK, numberRHS);
              }
            es3s3:;
            } // End of DO block
      // IF J THEN (9235)
      if (1 & (getFIXED (mJ)))
        // CALL ERROR(CLASS_DA, TYPE); (9236)
        {
          putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DA));
          putBITp (8, mERRORxNUM,
                   fixedToBit (32, (int32_t)(getFIXED (mTYPE))));
          ERROR (0);
        }
    es3:;
    } // End of DO block
  // IF (ATTRIBUTES&ILL_CLASS_ATTR(CLASS))~=0 THEN (9237)
  if (1
      & (xNEQ (xAND (getFIXED (mATTRIBUTES),
                     getFIXED (mILL_CLASS_ATTR + 4 * getFIXED (mCLASS))),
               0)))
    // DO; (9238)
    {
    rs4:;
      // CALL ERROR(CLASS_DA,11); (9239)
      {
        putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DA));
        putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(11)));
        ERROR (0);
      }
      // N_DIM=0; (9240)
      {
        int32_t numberRHS = (int32_t)(0);
        putFIXED (mN_DIM, numberRHS);
      }
      // ATTRIBUTES=ATTRIBUTES&(~ILL_CLASS_ATTR(CLASS)); (9241)
      {
        int32_t numberRHS = (int32_t)(xAND (
            getFIXED (mATTRIBUTES),
            xNOT (getFIXED (mILL_CLASS_ATTR + 4 * getFIXED (mCLASS)))));
        putFIXED (mATTRIBUTES, numberRHS);
      }
      // ATTR_MASK=ATTR_MASK&(~ILL_CLASS_ATTR(CLASS)); (9242)
      {
        int32_t numberRHS = (int32_t)(xAND (
            getFIXED (mATTR_MASK),
            xNOT (getFIXED (mILL_CLASS_ATTR + 4 * getFIXED (mCLASS)))));
        putFIXED (mATTR_MASK, numberRHS);
      }
    es4:;
    } // End of DO block
  // ELSE (9243)
  else
    // IF ~BUILDING_TEMPLATE THEN (9244)
    if (1 & (xNOT (BYTE0 (mBUILDING_TEMPLATE))))
      // DO; (9245)
      {
      rs5:;
        // IF (ATTRIBUTES&RIGID_FLAG)~=0 THEN (9246)
        if (1 & (xNEQ (xAND (getFIXED (mATTRIBUTES), 2147483648), 0)))
          // DO; (9247)
          {
          rs5s1:;
            // IF TYPE = MAJ_STRUC THEN (9248)
            if (1 & (xEQ (getFIXED (mTYPE), 10)))
              // DO; (9249)
              {
              rs5s1s1:;
                // CALL ERROR(CLASS_DA,10); (9250)
                {
                  putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DA));
                  putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(10)));
                  ERROR (0);
                }
              es5s1s1:;
              } // End of DO block
            // ELSE (9251)
            else
              // CALL ERROR(CLASS_DA,12); (9252)
              {
                putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DA));
                putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(12)));
                ERROR (0);
              }
            // ATTRIBUTES=ATTRIBUTES&(~RIGID_FLAG); (9253)
            {
              int32_t numberRHS
                  = (int32_t)(xAND (getFIXED (mATTRIBUTES), 2147483647));
              putFIXED (mATTRIBUTES, numberRHS);
            }
          es5s1:;
          } // End of DO block
        // IF TYPE = MAJ_STRUC THEN (9254)
        if (1 & (xEQ (getFIXED (mTYPE), 10)))
          // DO; (9255)
          {
          rs5s2:;
            // IF (ATTRIBUTES&ALDENSE_FLAGS)~=0 THEN (9256)
            if (1 & (xNEQ (xAND (getFIXED (mATTRIBUTES), 12), 0)))
              // DO; (9257)
              {
              rs5s2s1:;
                // CALL ERROR(CLASS_DA,10); (9258)
                {
                  putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_DA));
                  putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(10)));
                  ERROR (0);
                }
                // ATTRIBUTES=ATTRIBUTES&(~ALDENSE_FLAGS); (9259)
                {
                  int32_t numberRHS
                      = (int32_t)(xAND (getFIXED (mATTRIBUTES), 4294967283));
                  putFIXED (mATTRIBUTES, numberRHS);
                }
              es5s2s1:;
              } // End of DO block
          es5s2:;
          } // End of DO block
      es5:;
      } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
