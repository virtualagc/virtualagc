/*
  File STRUCTURE_COMPARE.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
STRUCTURE_COMPARE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "STRUCTURE_COMPARE");
  // IF A = B THEN (733)
  if (1
      & (xEQ (COREHALFWORD (mSTRUCTURE_COMPARExA),
              COREHALFWORD (mSTRUCTURE_COMPARExB))))
    // RETURN TRUE; (734)
    {
      reentryGuard = 0;
      return 1;
    }
  // IF ((SYT_FLAGS(A) | SYT_FLAGS(B)) & EVIL_FLAGS) = EVIL_FLAGS THEN (735)
  if (1
      & (xEQ (xAND (xOR (getFIXED (getFIXED (mSYM_TAB)
                                   + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExA))
                                   + 8 + 4 * (0)),
                         getFIXED (getFIXED (mSYM_TAB)
                                   + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExB))
                                   + 8 + 4 * (0))),
                    getFIXED (mEVIL_FLAGS)),
              getFIXED (mEVIL_FLAGS))))
    // GO TO STRUC_ERR; (736)
    goto STRUC_ERR;
  // AX = A; (737)
  {
    descriptor_t *bitRHS = getBIT (16, mSTRUCTURE_COMPARExA);
    putBIT (16, mSTRUCTURE_COMPARExAX, bitRHS);
    bitRHS->inUse = 0;
  }
  // BX = B; (738)
  {
    descriptor_t *bitRHS = getBIT (16, mSTRUCTURE_COMPARExB);
    putBIT (16, mSTRUCTURE_COMPARExBX, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO FOREVER; (739)
  while (1 & (1))
    {
      // DO WHILE SYT_LINK1(AX) > 0; (740)
      while (
          1
          & (xGT (COREHALFWORD (getFIXED (mSYM_TAB)
                                + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExAX))
                                + 24 + 2 * (0)),
                  0)))
        {
          // AX = SYT_LINK1(AX); (741)
          {
            descriptor_t *bitRHS
                = getBIT (16, getFIXED (mSYM_TAB)
                                  + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExAX))
                                  + 24 + 2 * (0));
            putBIT (16, mSTRUCTURE_COMPARExAX, bitRHS);
            bitRHS->inUse = 0;
          }
          // BX = SYT_LINK1(BX); (742)
          {
            descriptor_t *bitRHS
                = getBIT (16, getFIXED (mSYM_TAB)
                                  + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExBX))
                                  + 24 + 2 * (0));
            putBIT (16, mSTRUCTURE_COMPARExBX, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF BX = 0 THEN (743)
          if (1 & (xEQ (COREHALFWORD (mSTRUCTURE_COMPARExBX), 0)))
            // GO TO STRUC_ERR; (744)
            goto STRUC_ERR;
        } // End of DO WHILE block
      // IF SYT_LINK1(BX) ~= 0 THEN (745)
      if (1
          & (xNEQ (COREHALFWORD (getFIXED (mSYM_TAB)
                                 + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExBX))
                                 + 24 + 2 * (0)),
                   0)))
        // GO TO STRUC_ERR; (746)
        goto STRUC_ERR;
      // IF SYT_TYPE(AX) ~= SYT_TYPE(BX) THEN (747)
      if (1
          & (xNEQ (BYTE0 (getFIXED (mSYM_TAB)
                          + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExAX)) + 32
                          + 1 * (0)),
                   BYTE0 (getFIXED (mSYM_TAB)
                          + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExBX)) + 32
                          + 1 * (0)))))
        // GO TO STRUC_ERR; (748)
        goto STRUC_ERR;
      // IF SYT_DIMS(AX) ~= SYT_DIMS(BX) THEN (749)
      if (1
          & (xNEQ (COREHALFWORD (getFIXED (mSYM_TAB)
                                 + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExAX))
                                 + 18 + 2 * (0)),
                   COREHALFWORD (getFIXED (mSYM_TAB)
                                 + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExBX))
                                 + 18 + 2 * (0)))))
        // GO TO STRUC_ERR; (750)
        goto STRUC_ERR;
      // IF (SYT_FLAGS(AX)&SM_FLAGS) ~= (SYT_FLAGS(BX)&SM_FLAGS) THEN (751)
      if (1
          & (xNEQ (
              xAND (getFIXED (getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExAX)) + 8
                              + 4 * (0)),
                    getFIXED (mSM_FLAGS)),
              xAND (getFIXED (getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExBX)) + 8
                              + 4 * (0)),
                    getFIXED (mSM_FLAGS)))))
        // GO TO STRUC_ERR; (752)
        goto STRUC_ERR;
      // DO I = 0 TO EXT_ARRAY(SYT_ARRAY(AX)); (753)
      {
        int32_t from19, to19, by19;
        from19 = 0;
        to19 = bitToFixed (getBIT (
            16, mEXT_ARRAY
                    + 2
                          * COREHALFWORD (
                              getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExAX))
                              + 20 + 2 * (0))));
        by19 = 1;
        for (putBIT (16, mSTRUCTURE_COMPARExI, fixedToBit (16, from19));
             bitToFixed (getBIT (16, mSTRUCTURE_COMPARExI)) <= to19; putBIT (
                 16, mSTRUCTURE_COMPARExI,
                 fixedToBit (16, bitToFixed (getBIT (16, mSTRUCTURE_COMPARExI))
                                     + by19)))
          {
            // IF EXT_ARRAY(SYT_ARRAY(AX)+I) ~= EXT_ARRAY(SYT_ARRAY(BX)+I) THEN
            // (754)
            if (1
                & (xNEQ (
                    COREHALFWORD (
                        mEXT_ARRAY
                        + 2
                              * xadd (COREHALFWORD (
                                          getFIXED (mSYM_TAB)
                                          + 34
                                                * (COREHALFWORD (
                                                    mSTRUCTURE_COMPARExAX))
                                          + 20 + 2 * (0)),
                                      COREHALFWORD (mSTRUCTURE_COMPARExI))),
                    COREHALFWORD (
                        mEXT_ARRAY
                        + 2
                              * xadd (COREHALFWORD (
                                          getFIXED (mSYM_TAB)
                                          + 34
                                                * (COREHALFWORD (
                                                    mSTRUCTURE_COMPARExBX))
                                          + 20 + 2 * (0)),
                                      COREHALFWORD (mSTRUCTURE_COMPARExI))))))
              // GO TO STRUC_ERR; (755)
              goto STRUC_ERR;
          }
      } // End of DO for-loop block
      // DO WHILE SYT_LINK2(AX) < 0; (756)
      while (
          1
          & (xLT (COREHALFWORD (getFIXED (mSYM_TAB)
                                + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExAX))
                                + 26 + 2 * (0)),
                  0)))
        {
          // AX = -SYT_LINK2(AX); (757)
          {
            int32_t numberRHS = (int32_t)(xminus (
                COREHALFWORD (getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExAX))
                              + 26 + 2 * (0))));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mSTRUCTURE_COMPARExAX, bitRHS);
            bitRHS->inUse = 0;
          }
          // BX = -SYT_LINK2(BX); (758)
          {
            int32_t numberRHS = (int32_t)(xminus (
                COREHALFWORD (getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExBX))
                              + 26 + 2 * (0))));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mSTRUCTURE_COMPARExBX, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF AX = A THEN (759)
          if (1
              & (xEQ (COREHALFWORD (mSTRUCTURE_COMPARExAX),
                      COREHALFWORD (mSTRUCTURE_COMPARExA))))
            // DO; (760)
            {
            rs1s3s1:;
              // IF BX ~= B THEN (761)
              if (1
                  & (xNEQ (COREHALFWORD (mSTRUCTURE_COMPARExBX),
                           COREHALFWORD (mSTRUCTURE_COMPARExB))))
                // GO TO STRUC_ERR; (762)
                goto STRUC_ERR;
              // RETURN TRUE; (763)
              {
                reentryGuard = 0;
                return 1;
              }
            es1s3s1:;
            } // End of DO block
          // IF BX <= 0 THEN (764)
          if (1 & (xLE (COREHALFWORD (mSTRUCTURE_COMPARExBX), 0)))
            // GO TO STRUC_ERR; (765)
            goto STRUC_ERR;
        } // End of DO WHILE block
      // AX = SYT_LINK2(AX); (766)
      {
        descriptor_t *bitRHS
            = getBIT (16, getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExAX))
                              + 26 + 2 * (0));
        putBIT (16, mSTRUCTURE_COMPARExAX, bitRHS);
        bitRHS->inUse = 0;
      }
      // BX = SYT_LINK2(BX); (767)
      {
        descriptor_t *bitRHS
            = getBIT (16, getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mSTRUCTURE_COMPARExBX))
                              + 26 + 2 * (0));
        putBIT (16, mSTRUCTURE_COMPARExBX, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF BX <= 0 THEN (768)
      if (1 & (xLE (COREHALFWORD (mSTRUCTURE_COMPARExBX), 0)))
        // GO TO STRUC_ERR; (769)
        goto STRUC_ERR;
    } // End of DO WHILE block
// STRUC_ERR: (770)
STRUC_ERR:
  // RETURN FALSE; (771)
  {
    reentryGuard = 0;
    return 0;
  }
}
