/*
  File GENERATExGEN_CLASS0xCHECK_NAMEADD.c generated by XCOM-I, 2024-08-08
  04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xCHECK_NAMEADD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "GENERATExGEN_CLASS0xCHECK_NAMEADD");
  // ARGLOC1 = LOC2(RESULT); (10718)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mRESULT))
                          + 42 + 2 * (0));
    putBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC1, bitRHS);
    bitRHS->inUse = 0;
  }
  // ARGLOC2 = LOC2(LEFTOP); (10719)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mIND_STACK) + 73 * (COREHALFWORD (mLEFTOP))
                          + 42 + 2 * (0));
    putBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (SYT_FLAGS(ARGLOC1) & NI_FLAGS) ~= (SYT_FLAGS(ARGLOC2) & NI_FLAGS) THEN
  // (10720)
  if (1
      & (xNEQ (xAND (getFIXED (
                         getFIXED (mSYM_TAB)
                         + 34
                               * (COREHALFWORD (
                                   mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC1))
                         + 8 + 4 * (0)),
                     getFIXED (mNI_FLAGS)),
               xAND (getFIXED (
                         getFIXED (mSYM_TAB)
                         + 34
                               * (COREHALFWORD (
                                   mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                         + 8 + 4 * (0)),
                     getFIXED (mNI_FLAGS)))))
    // DO; (10721)
    {
    rs1:;
      // MISMATCH = TRUE; (10722)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mGENERATExMISMATCH, bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN; (10723)
      {
        reentryGuard = 0;
        return 0;
      }
    es1:;
    } // End of DO block
  // ELSE (10724)
  else
    // IF (SYT_FLAGS(ARGLOC1) & LOCK_BITS) ~= (SYT_FLAGS(ARGLOC2) & LOCK_BITS)
    // THEN (10725)
    if (1
        & (xNEQ (
            xAND (getFIXED (
                      getFIXED (mSYM_TAB)
                      + 34
                            * (COREHALFWORD (
                                mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC1))
                      + 8 + 4 * (0)),
                  getFIXED (mLOCK_BITS)),
            xAND (getFIXED (
                      getFIXED (mSYM_TAB)
                      + 34
                            * (COREHALFWORD (
                                mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                      + 8 + 4 * (0)),
                  getFIXED (mLOCK_BITS)))))
      // DO; (10726)
      {
      rs2:;
        // MISMATCH = TRUE; (10727)
        {
          int32_t numberRHS = (int32_t)(1);
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (1, mGENERATExMISMATCH, bitRHS);
          bitRHS->inUse = 0;
        }
        // RETURN; (10728)
        {
          reentryGuard = 0;
          return 0;
        }
      es2:;
      } // End of DO block
  // IF SYT_TYPE(ARGLOC1) ~= SYT_TYPE(ARGLOC2) THEN (10729)
  if (1
      & (xNEQ (BYTE0 (getFIXED (mSYM_TAB)
                      + 34
                            * (COREHALFWORD (
                                mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC1))
                      + 32 + 1 * (0)),
               BYTE0 (getFIXED (mSYM_TAB)
                      + 34
                            * (COREHALFWORD (
                                mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                      + 32 + 1 * (0)))))
    // DO; (10730)
    {
    rs3:;
      // MISMATCH = TRUE; (10731)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mGENERATExMISMATCH, bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN; (10732)
      {
        reentryGuard = 0;
        return 0;
      }
    es3:;
    } // End of DO block
  // IF COPY(LEFTOP) ~= COPY(RESULT) THEN (10733)
  if (1
      & (xNEQ (COREHALFWORD (getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mLEFTOP)) + 26 + 2 * (0)),
               COREHALFWORD (getFIXED (mIND_STACK)
                             + 73 * (COREHALFWORD (mRESULT)) + 26 + 2 * (0)))))
    // DO; (10734)
    {
    rs4:;
      // MISMATCH = TRUE; (10735)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (1, mGENERATExMISMATCH, bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN; (10736)
      {
        reentryGuard = 0;
        return 0;
      }
    es4:;
    } // End of DO block
  // ARRNESS1 = GETARRAY#(LOC(RESULT)); (10737)
  {
    descriptor_t *bitRHS
        = (putBITp (16, mGETARRAYpxOP,
                    getBIT (16, getFIXED (mIND_STACK)
                                    + 73 * (COREHALFWORD (mRESULT)) + 40
                                    + 2 * (0))),
           GETARRAYp (0));
    putBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxARRNESS1, bitRHS);
    bitRHS->inUse = 0;
  }
  // ARRNESS2 = GETARRAY#(LOC(LEFTOP)); (10738)
  {
    descriptor_t *bitRHS
        = (putBITp (16, mGETARRAYpxOP,
                    getBIT (16, getFIXED (mIND_STACK)
                                    + 73 * (COREHALFWORD (mLEFTOP)) + 40
                                    + 2 * (0))),
           GETARRAYp (0));
    putBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxARRNESS2, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF (ARRNESS1 > 0) & (ARRNESS2 > 0) THEN (10739)
  if (1
      & (xAND (
          xGT (COREHALFWORD (mGENERATExGEN_CLASS0xCHECK_NAMEADDxARRNESS1), 0),
          xGT (COREHALFWORD (mGENERATExGEN_CLASS0xCHECK_NAMEADDxARRNESS2),
               0))))
    // DO I = 1 TO ARRNESS2; (10740)
    {
      int32_t from106, to106, by106;
      from106 = 1;
      to106 = bitToFixed (
          getBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxARRNESS2));
      by106 = 1;
      for (putBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxI,
                   fixedToBit (16, from106));
           bitToFixed (getBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxI))
           <= to106;
           putBIT (
               16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxI,
               fixedToBit (16, bitToFixed (getBIT (
                                   16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxI))
                                   + by106)))
        {
          // J = GETARRAYDIM(I, ARGLOC1); (10741)
          {
            descriptor_t *bitRHS
                = (putBITp (8, mGETARRAYDIMxIX,
                            getBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxI)),
                   putBITp (
                       16, mGETARRAYDIMxOP1,
                       getBIT (16,
                               mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC1)),
                   GETARRAYDIM (0));
            putBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxJ, bitRHS);
            bitRHS->inUse = 0;
          }
          // K = GETARRAYDIM(I, ARGLOC2); (10742)
          {
            descriptor_t *bitRHS
                = (putBITp (8, mGETARRAYDIMxIX,
                            getBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxI)),
                   putBITp (
                       16, mGETARRAYDIMxOP1,
                       getBIT (16,
                               mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2)),
                   GETARRAYDIM (0));
            putBIT (16, mGENERATExGEN_CLASS0xCHECK_NAMEADDxK, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF K ~< 0 THEN (10743)
          if (1
              & (xGE (COREHALFWORD (mGENERATExGEN_CLASS0xCHECK_NAMEADDxK), 0)))
            // IF K ~= J THEN (10744)
            if (1
                & (xNEQ (COREHALFWORD (mGENERATExGEN_CLASS0xCHECK_NAMEADDxK),
                         COREHALFWORD (mGENERATExGEN_CLASS0xCHECK_NAMEADDxJ))))
              // DO; (10745)
              {
              rs5s1:;
                // MISMATCH = TRUE; (10746)
                {
                  int32_t numberRHS = (int32_t)(1);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (1, mGENERATExMISMATCH, bitRHS);
                  bitRHS->inUse = 0;
                }
                // RETURN; (10747)
                {
                  reentryGuard = 0;
                  return 0;
                }
              es5s1:;
              } // End of DO block
        }
    } // End of DO for-loop block
  // IF SYT_TYPE(ARGLOC2) = VECMAT THEN (10748)
  if (1
      & (xEQ (BYTE0 (getFIXED (mSYM_TAB)
                     + 34
                           * (COREHALFWORD (
                               mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                     + 32 + 1 * (0)),
              BYTE0 (mVECMAT))))
    // DO; (10749)
    {
    rs6:;
      // IF ROW(RESULT) ~= (SHR(SYT_DIMS(ARGLOC2),8)& 255) | COLUMN(RESULT) ~=
      // (SYT_DIMS(ARGLOC2)& 255) THEN (10750)
      if (1
          & (xOR (
              xNEQ (
                  COREHALFWORD (getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mRESULT)) + 48
                                + 2 * (0)),
                  xAND (
                      SHR (
                          COREHALFWORD (
                              getFIXED (mSYM_TAB)
                              + 34
                                    * (COREHALFWORD (
                                        mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                              + 18 + 2 * (0)),
                          8),
                      255)),
              xNEQ (
                  COREHALFWORD (getFIXED (mIND_STACK)
                                + 73 * (COREHALFWORD (mRESULT)) + 24
                                + 2 * (0)),
                  xAND (
                      COREHALFWORD (
                          getFIXED (mSYM_TAB)
                          + 34
                                * (COREHALFWORD (
                                    mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                          + 18 + 2 * (0)),
                      255)))))
        // DO; (10751)
        {
        rs6s1:;
          // MISMATCH = TRUE; (10752)
          {
            int32_t numberRHS = (int32_t)(1);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mGENERATExMISMATCH, bitRHS);
            bitRHS->inUse = 0;
          }
          // RETURN; (10753)
          {
            reentryGuard = 0;
            return 0;
          }
        es6s1:;
        } // End of DO block
    es6:;
    } // End of DO block
  // ELSE (10754)
  else
    // IF SYT_TYPE(ARGLOC2) = BITS THEN (10755)
    if (1
        & (xEQ (BYTE0 (getFIXED (mSYM_TAB)
                       + 34
                             * (COREHALFWORD (
                                 mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                       + 32 + 1 * (0)),
                BYTE0 (mBITS))))
      // DO; (10756)
      {
      rs7:;
        // IF SIZE(RESULT) ~= (SYT_DIMS(ARGLOC2) &  255) THEN (10757)
        if (1
            & (xNEQ (
                COREHALFWORD (getFIXED (mIND_STACK)
                              + 73 * (COREHALFWORD (mRESULT)) + 48 + 2 * (0)),
                xAND (
                    COREHALFWORD (
                        getFIXED (mSYM_TAB)
                        + 34
                              * (COREHALFWORD (
                                  mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                        + 18 + 2 * (0)),
                    255))))
          // DO; (10758)
          {
          rs7s1:;
            // MISMATCH = TRUE; (10759)
            {
              int32_t numberRHS = (int32_t)(1);
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (1, mGENERATExMISMATCH, bitRHS);
              bitRHS->inUse = 0;
            }
            // RETURN; (10760)
            {
              reentryGuard = 0;
              return 0;
            }
          es7s1:;
          } // End of DO block
      es7:;
      } // End of DO block
    // ELSE (10761)
    else
      // IF SYT_TYPE(ARGLOC2) = CHAR THEN (10762)
      if (1
          & (xEQ (BYTE0 (getFIXED (mSYM_TAB)
                         + 34
                               * (COREHALFWORD (
                                   mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                         + 32 + 1 * (0)),
                  BYTE0 (mCHAR))))
        // DO; (10763)
        {
        rs8:;
          // IF (SIZE(RESULT) ~= -1) & (SYT_DIMS(ARGLOC2) ~= 1) THEN (10764)
          if (1
              & (xAND (
                  xNEQ (COREHALFWORD (getFIXED (mIND_STACK)
                                      + 73 * (COREHALFWORD (mRESULT)) + 48
                                      + 2 * (0)),
                        -1),
                  xNEQ (
                      COREHALFWORD (
                          getFIXED (mSYM_TAB)
                          + 34
                                * (COREHALFWORD (
                                    mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                          + 18 + 2 * (0)),
                      1))))
            // IF SIZE(RESULT) ~= (SYT_DIMS(ARGLOC2) &  255) THEN (10765)
            if (1
                & (xNEQ (
                    COREHALFWORD (getFIXED (mIND_STACK)
                                  + 73 * (COREHALFWORD (mRESULT)) + 48
                                  + 2 * (0)),
                    xAND (
                        COREHALFWORD (
                            getFIXED (mSYM_TAB)
                            + 34
                                  * (COREHALFWORD (
                                      mGENERATExGEN_CLASS0xCHECK_NAMEADDxARGLOC2))
                            + 18 + 2 * (0)),
                        255))))
              // DO; (10766)
              {
              rs8s1:;
                // MISMATCH = TRUE; (10767)
                {
                  int32_t numberRHS = (int32_t)(1);
                  descriptor_t *bitRHS;
                  bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                  putBIT (1, mGENERATExMISMATCH, bitRHS);
                  bitRHS->inUse = 0;
                }
                // RETURN; (10768)
                {
                  reentryGuard = 0;
                  return 0;
                }
              es8s1:;
              } // End of DO block
        es8:;
        } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
