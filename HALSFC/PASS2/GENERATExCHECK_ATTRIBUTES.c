/*
  File GENERATExCHECK_ATTRIBUTES.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExCHECK_ATTRIBUTES (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExCHECK_ATTRIBUTES");
  // IF ~SYMFORM(FORM(RIGHTOP)) THEN (7937)
  if (1
      & (xNOT (BYTE0 (mSYMFORM
                      + 1
                            * COREHALFWORD (getFIXED (mIND_STACK)
                                            + 73 * (COREHALFWORD (mRIGHTOP))
                                            + 32 + 2 * (0))))))
    // IF ~(NR_DEREF(RIGHTOP) & (FORM(RIGHTOP)=NRTEMP)) THEN (7938)
    if (1
        & (xNOT (xAND (BYTE0 (getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mRIGHTOP)) + 60 + 1 * (0)),
                       xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                          + 73 * (COREHALFWORD (mRIGHTOP)) + 32
                                          + 2 * (0)),
                            BYTE0 (mWORK))))))
      // CALL ERRORS(CLASS_F,100); (7939)
      {
        putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_F));
        putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(100)));
        ERRORS (0);
      }
  // IF MAJOR_STRUCTURE(RIGHTOP) THEN (7940)
  if (1
      & (bitToFixed (
          (putBITp (16, mGENERATExMAJOR_STRUCTURExOP, getBIT (16, mRIGHTOP)),
           GENERATExMAJOR_STRUCTURE (0)))))
    // TEMP_LOC = LOC(RIGHTOP); (7941)
    {
      descriptor_t *bitRHS
          = getBIT (16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP))
                            + 40 + 2 * (0));
      putBIT (16, mGENERATExCHECK_ATTRIBUTESxTEMP_LOC, bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (7942)
  else
    // TEMP_LOC = LOC2(RIGHTOP); (7943)
    {
      descriptor_t *bitRHS
          = getBIT (16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRIGHTOP))
                            + 42 + 2 * (0));
      putBIT (16, mGENERATExCHECK_ATTRIBUTESxTEMP_LOC, bitRHS);
      bitRHS->inUse = 0;
    }
  // IF CLASS=8 THEN (7944)
  if (1 & (xEQ (COREHALFWORD (mCLASS), 8)))
    // DO; (7945)
    {
    rs1:;
      // IF (SYT_FLAGS(ARGPOINT)&NI_FLAGS) ~=  (SYT_FLAGS(TEMP_LOC)&NI_FLAGS)
      // THEN (7946)
      if (1
          & (xNEQ (
              xAND (getFIXED (getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mARGPOINT)) + 8 + 4 * (0)),
                    getFIXED (mNI_FLAGS)),
              xAND (getFIXED (getFIXED (mSYM_TAB)
                              + 34
                                    * (COREHALFWORD (
                                        mGENERATExCHECK_ATTRIBUTESxTEMP_LOC))
                              + 8 + 4 * (0)),
                    getFIXED (mNI_FLAGS)))))
        // CALL ERRORS(CLASS_DI,109); (7947)
        {
          putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_DI));
          putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(109)));
          ERRORS (0);
        }
      // ELSE (7948)
      else
        // IF (SYT_FLAGS(ARGPOINT)&LOCK_BITS)~=
        // (SYT_FLAGS(LOC(RIGHTOP))&LOCK_BITS) THEN (7949)
        if (1
            & (xNEQ (xAND (getFIXED (getFIXED (mSYM_TAB)
                                     + 34 * (COREHALFWORD (mARGPOINT)) + 8
                                     + 4 * (0)),
                           getFIXED (mLOCK_BITS)),
                     xAND (getFIXED (getFIXED (mSYM_TAB)
                                     + 34
                                           * (COREHALFWORD (
                                               getFIXED (mIND_STACK)
                                               + 73 * (COREHALFWORD (mRIGHTOP))
                                               + 40 + 2 * (0)))
                                     + 8 + 4 * (0)),
                           getFIXED (mLOCK_BITS)))))
          // CALL ERRORS(CLASS_DI,109); (7950)
          {
            putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_DI));
            putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(109)));
            ERRORS (0);
          }
    es1:;
    } // End of DO block
  // ELSE (7951)
  else
    // DO; (7952)
    {
    rs2:;
      // IF (SYT_FLAGS(ARGPOINT)&NI_FLAGS)~=  (SYT_FLAGS(TEMP_LOC)&NI_FLAGS)
      // THEN (7953)
      if (1
          & (xNEQ (
              xAND (getFIXED (getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mARGPOINT)) + 8 + 4 * (0)),
                    getFIXED (mNI_FLAGS)),
              xAND (getFIXED (getFIXED (mSYM_TAB)
                              + 34
                                    * (COREHALFWORD (
                                        mGENERATExCHECK_ATTRIBUTESxTEMP_LOC))
                              + 8 + 4 * (0)),
                    getFIXED (mNI_FLAGS)))))
        // CALL ERRORS(CLASS_FT,102); (7954)
        {
          putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_FT));
          putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(102)));
          ERRORS (0);
        }
      // ELSE (7955)
      else
        // IF ((SYT_FLAGS(ARGPOINT)&REMOTE_FLAG)=0)&  (POINTS_REMOTE(RIGHTOP) |
        // (LIVES_REMOTE(RIGHTOP) & ~NAME_VAR(RIGHTOP)))  THEN (7956)
        if (1
            & (xAND (
                xEQ (xAND (getFIXED (getFIXED (mSYM_TAB)
                                     + 34 * (COREHALFWORD (mARGPOINT)) + 8
                                     + 4 * (0)),
                           getFIXED (mREMOTE_FLAG)),
                     0),
                xOR (BYTE0 (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mRIGHTOP)) + 68 + 1 * (0)),
                     xAND (BYTE0 (getFIXED (mIND_STACK)
                                  + 73 * (COREHALFWORD (mRIGHTOP)) + 69
                                  + 1 * (0)),
                           xNOT (BYTE0 (getFIXED (mIND_STACK)
                                        + 73 * (COREHALFWORD (mRIGHTOP)) + 70
                                        + 1 * (0))))))))
          // CALL ERRORS(CLASS_FT,102); (7957)
          {
            putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_FT));
            putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(102)));
            ERRORS (0);
          }
        // ELSE (7958)
        else
          // IF ((SYT_FLAGS(TEMP_LOC)&REMOTE_FLAG)=0) &
          // ((SYT_FLAGS(ARGPOINT)&NAME_OR_REMOTE)=NAME_OR_REMOTE) THEN (7959)
          if (1
              & (xAND (
                  xEQ (
                      xAND (getFIXED (
                                getFIXED (mSYM_TAB)
                                + 34
                                      * (COREHALFWORD (
                                          mGENERATExCHECK_ATTRIBUTESxTEMP_LOC))
                                + 8 + 4 * (0)),
                            getFIXED (mREMOTE_FLAG)),
                      0),
                  xEQ (xAND (getFIXED (getFIXED (mSYM_TAB)
                                       + 34 * (COREHALFWORD (mARGPOINT)) + 8
                                       + 4 * (0)),
                             getFIXED (mNAME_OR_REMOTE)),
                       getFIXED (mNAME_OR_REMOTE)))))
            // CALL ERRORS(CLASS_FT,102); (7960)
            {
              putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_FT));
              putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(102)));
              ERRORS (0);
            }
          // ELSE (7961)
          else
            // IF (SYT_FLAGS(ARGPOINT)&LOCK_BITS)~=
            // (SYT_FLAGS(LOC(RIGHTOP))&LOCK_BITS)  THEN (7962)
            if (1
                & (xNEQ (
                    xAND (getFIXED (getFIXED (mSYM_TAB)
                                    + 34 * (COREHALFWORD (mARGPOINT)) + 8
                                    + 4 * (0)),
                          getFIXED (mLOCK_BITS)),
                    xAND (getFIXED (getFIXED (mSYM_TAB)
                                    + 34
                                          * (COREHALFWORD (
                                              getFIXED (mIND_STACK)
                                              + 73 * (COREHALFWORD (mRIGHTOP))
                                              + 40 + 2 * (0)))
                                    + 8 + 4 * (0)),
                          getFIXED (mLOCK_BITS)))))
              // CALL ERRORS(CLASS_FT,102); (7963)
              {
                putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_FT));
                putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(102)));
                ERRORS (0);
              }
    es2:;
    } // End of DO block
  // IF SYT_LOCK#(ARGPOINT) ~=  255 THEN (7964)
  if (1
      & (xNEQ (BYTE0 (getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mARGPOINT))
                      + 31 + 1 * (0)),
               255)))
    // IF ~BLOCK_CLASS(SYT_CLASS(LOC2(RIGHTOP))) THEN (7965)
    if (1
        & (xNOT (BYTE0 (
            mBLOCK_CLASS
            + 1
                  * BYTE0 (
                      getFIXED (mSYM_TAB)
                      + 34
                            * (COREHALFWORD (getFIXED (mIND_STACK)
                                             + 73 * (COREHALFWORD (mRIGHTOP))
                                             + 42 + 2 * (0)))
                      + 30 + 1 * (0))))))
      // IF SYT_LOCK#(ARGPOINT) ~= SYT_LOCK#(LOC(RIGHTOP)) THEN (7966)
      if (1
          & (xNEQ (
              BYTE0 (getFIXED (mSYM_TAB) + 34 * (COREHALFWORD (mARGPOINT)) + 31
                     + 1 * (0)),
              BYTE0 (getFIXED (mSYM_TAB)
                     + 34
                           * (COREHALFWORD (getFIXED (mIND_STACK)
                                            + 73 * (COREHALFWORD (mRIGHTOP))
                                            + 40 + 2 * (0)))
                     + 31 + 1 * (0)))))
        // CALL ERRORS(CLASS_FT,103,''||ARGNO); (7967)
        {
          putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_FT));
          putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(103)));
          putCHARACTERp (mERRORSxTEXT,
                         xsCAT (cToDescriptor (NULL, ""),
                                bitToCharacter (getBIT (16, mARGNO))));
          ERRORS (0);
        }
  {
    reentryGuard = 0;
    return 0;
  }
}
