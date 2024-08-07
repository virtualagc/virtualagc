/*
  File SCANxCHAR_OP_CHECK.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

descriptor_t *
SCANxCHAR_OP_CHECK (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SCANxCHAR_OP_CHECK");
  // IF OVER_PUNCH = 0 THEN (6603)
  if (1 & (xEQ (BYTE0 (mOVER_PUNCH), 0)))
    // RETURN CHAR; (6604)
    {
      reentryGuard = 0;
      return getBIT (8, mSCANxCHAR_OP_CHECKxCHAR);
    }
  // IF OVER_PUNCH = CHAR_OP THEN (6605)
  if (1 & (xEQ (BYTE0 (mOVER_PUNCH), BYTE0 (mCHAR_OP))))
    // DO; (6606)
    {
    rs1:;
      // HOLD_CHAR = TRANS_IN(CHAR) &  255; (6607)
      {
        int32_t numberRHS = (int32_t)(xAND (
            COREHALFWORD (mTRANS_IN + 2 * BYTE0 (mSCANxCHAR_OP_CHECKxCHAR)),
            255));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mSCANxCHAR_OP_CHECKxHOLD_CHAR, bitRHS);
        bitRHS->inUse = 0;
      }
    // VALID_TEST: (6608)
    VALID_TEST:
      // IF HOLD_CHAR =  0 THEN (6609)
      if (1 & (xEQ (BYTE0 (mSCANxCHAR_OP_CHECKxHOLD_CHAR), 0)))
        // IF OVER_PUNCH ~= VALID_00_OP | CHAR ~= VALID_00_CHAR THEN (6610)
        if (1
            & (xOR (xNEQ (BYTE0 (mOVER_PUNCH), BYTE0 (mVALID_00_OP)),
                    xNEQ (BYTE0 (mSCANxCHAR_OP_CHECKxCHAR),
                          BYTE0 (mVALID_00_CHAR)))))
          // DO; (6611)
          {
          rs1s1:;
            // CALL ERROR(CLASS_MO, 6, HEX(CHAR, 2)); (6612)
            {
              putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_MO));
              putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(6)));
              putCHARACTERp (
                  mERRORxTEXT,
                  (putFIXED (mHEXxNUM, BYTE0 (mSCANxCHAR_OP_CHECKxCHAR)),
                   putFIXED (mHEXxWIDTH, 2), HEX (0)));
              ERROR (0);
            }
            // RETURN CHAR; (6613)
            {
              reentryGuard = 0;
              return getBIT (8, mSCANxCHAR_OP_CHECKxCHAR);
            }
          es1s1:;
          } // End of DO block
      // RETURN HOLD_CHAR; (6614)
      {
        reentryGuard = 0;
        return getBIT (8, mSCANxCHAR_OP_CHECKxHOLD_CHAR);
      }
    es1:;
    } // End of DO block
  // ELSE (6615)
  else
    // IF OVER_PUNCH = CHAR_OP(1) THEN (6616)
    if (1 & (xEQ (BYTE0 (mOVER_PUNCH), BYTE0 (mCHAR_OP + 1 * 1))))
      // DO; (6617)
      {
      rs2:;
        // HOLD_CHAR = SHR(TRANS_IN(CHAR), 8) &  255; (6618)
        {
          int32_t numberRHS = (int32_t)(xAND (
              SHR (COREHALFWORD (mTRANS_IN
                                 + 2 * BYTE0 (mSCANxCHAR_OP_CHECKxCHAR)),
                   8),
              255));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (8, mSCANxCHAR_OP_CHECKxHOLD_CHAR, bitRHS);
          bitRHS->inUse = 0;
        }
        // GO TO VALID_TEST; (6619)
        goto VALID_TEST;
      es2:;
      } // End of DO block
    // ELSE (6620)
    else
      // DO; (6621)
      {
      rs3:;
        // CALL ERROR(CLASS_MO, 1, HEX(CHAR, 2)); (6622)
        {
          putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_MO));
          putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(1)));
          putCHARACTERp (
              mERRORxTEXT,
              (putFIXED (mHEXxNUM, BYTE0 (mSCANxCHAR_OP_CHECKxCHAR)),
               putFIXED (mHEXxWIDTH, 2), HEX (0)));
          ERROR (0);
        }
        // RETURN CHAR; (6623)
        {
          reentryGuard = 0;
          return getBIT (8, mSCANxCHAR_OP_CHECKxCHAR);
        }
      es3:;
      } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
