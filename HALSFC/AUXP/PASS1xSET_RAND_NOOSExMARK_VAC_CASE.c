/*
  File PASS1xSET_RAND_NOOSExMARK_VAC_CASE.c generated by XCOM-I, 2024-08-08
  04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
PASS1xSET_RAND_NOOSExMARK_VAC_CASE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "PASS1xSET_RAND_NOOSExMARK_VAC_CASE");
  // TEMP_PTR = STACK_PTR; (1511)
  {
    descriptor_t *bitRHS = getBIT (16, mSTACK_PTR);
    putBIT (16, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE TRUE; (1512)
  while (1 & (1))
    {
      // DO WHILE TRUE; (1513)
      while (1 & (1))
        {
          // IF FRAME_TYPE(TEMP_PTR) = BLOCK_TYPE THEN (1514)
          if (1
              & (xEQ (
                  BYTE0 (
                      getFIXED (mSTACK_FRAME)
                      + 32
                            * (COREHALFWORD (
                                mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                      + 30 + 1 * (0)),
                  1)))
            // RETURN; (1515)
            {
              reentryGuard = 0;
              return 0;
            }
          // IF FRAME_TYPE(TEMP_PTR) = CASE_TYPE THEN (1516)
          if (1
              & (xEQ (
                  BYTE0 (
                      getFIXED (mSTACK_FRAME)
                      + 32
                            * (COREHALFWORD (
                                mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                      + 30 + 1 * (0)),
                  3)))
            // DO; (1517)
            {
            rs1s1s1:;
              // IF (FRAME_FLAGS(TEMP_PTR) & (ZAP_OR_FLUSH | PREV_BLOCK_FLAG))
              // ~= 0 THEN (1518)
              if (1
                  & (xNEQ (
                      xAND (
                          BYTE0 (
                              getFIXED (mSTACK_FRAME)
                              + 32
                                    * (COREHALFWORD (
                                        mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                              + 31 + 1 * (0)),
                          7),
                      0)))
                // RETURN; (1519)
                {
                  reentryGuard = 0;
                  return 0;
                }
              // GO TO EXIT_CASE_LOOP; (1520)
              goto EXIT_CASE_LOOP;
            es1s1s1:;
            } // End of DO block
          // TEMP_PTR = TEMP_PTR - 1; (1521)
          {
            int32_t numberRHS = (int32_t)(xsubtract (
                COREHALFWORD (mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR),
                1));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR, bitRHS);
            bitRHS->inUse = 0;
          }
        } // End of DO WHILE block
    // EXIT_CASE_LOOP: (1522)
    EXIT_CASE_LOOP:
      // IF ((VAC_REF_POOL(FRAME_VAC_REF(TEMP_PTR) + SHR(RAND + BUMP_FACTOR,
      // 5)) & MAP_INDICES((RAND + BUMP_FACTOR) &  31)) = 0) &
      // ((VAC_REF_POOL(FRAME_VAC_PREV_REF(TEMP_PTR) + SHR(RAND + BUMP_FACTOR,
      // 5)) & MAP_INDICES((RAND + BUMP_FACTOR) &  31)) ~= 0) THEN (1523)
      if (1
          & (xAND (
              xEQ (
                  xAND (
                      COREWORD (
                          getFIXED (mV_POOL)
                          + 4
                                * (xadd (
                                    COREHALFWORD (
                                        getFIXED (mSTACK_FRAME)
                                        + 32
                                              * (COREHALFWORD (
                                                  mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                                        + 12 + 2 * (0)),
                                    SHR (
                                        xadd (
                                            COREHALFWORD (
                                                mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND),
                                            COREHALFWORD (
                                                mPASS1xSET_RAND_NOOSExMARK_VAC_CASExBUMP_FACTOR)),
                                        5)))
                          + 0 + 4 * (0)),
                      getFIXED (
                          mMAP_INDICES
                          + 4
                                * xAND (
                                    xadd (
                                        COREHALFWORD (
                                            mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND),
                                        COREHALFWORD (
                                            mPASS1xSET_RAND_NOOSExMARK_VAC_CASExBUMP_FACTOR)),
                                    31))),
                  0),
              xNEQ (
                  xAND (
                      COREWORD (
                          getFIXED (mV_POOL)
                          + 4
                                * (xadd (
                                    COREHALFWORD (
                                        getFIXED (mSTACK_FRAME)
                                        + 32
                                              * (COREHALFWORD (
                                                  mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                                        + 16 + 2 * (0)),
                                    SHR (
                                        xadd (
                                            COREHALFWORD (
                                                mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND),
                                            COREHALFWORD (
                                                mPASS1xSET_RAND_NOOSExMARK_VAC_CASExBUMP_FACTOR)),
                                        5)))
                          + 0 + 4 * (0)),
                      getFIXED (
                          mMAP_INDICES
                          + 4
                                * xAND (
                                    xadd (
                                        COREHALFWORD (
                                            mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND),
                                        COREHALFWORD (
                                            mPASS1xSET_RAND_NOOSExMARK_VAC_CASExBUMP_FACTOR)),
                                    31))),
                  0))))
        // DO; (1524)
        {
        rs1s2:;
          // IF FRAME_CASE_LIST(TEMP_PTR) < HALMAT_SIZE THEN (1525)
          if (1
              & (xLT (
                  COREHALFWORD (
                      getFIXED (mSTACK_FRAME)
                      + 32
                            * (COREHALFWORD (
                                mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                      + 20 + 2 * (0)),
                  1800)))
            // CALL SEARCH_FOR_REF(RAND_TYPE, RAND,
            // AUXMAT1(FRAME_CASE_LIST(TEMP_PTR)), -1 ); (1526)
            {
              putBITp (
                  4, mPASS1xSEARCH_FOR_REFxRAND_TYPE,
                  getBIT (8, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND_TYPE));
              putBITp (16, mPASS1xSEARCH_FOR_REFxRAND,
                       getBIT (16, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND));
              putBITp (
                  16, mPASS1xSEARCH_FOR_REFxLIST_HEAD,
                  getBIT (
                      16,
                      getFIXED (mWORK_VARS)
                          + 11
                                * (COREHALFWORD (
                                    getFIXED (mSTACK_FRAME)
                                    + 32
                                          * (COREHALFWORD (
                                              mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                                    + 20 + 2 * (0)))
                          + 2 + 2 * (0)));
              putBITp (16, mPASS1xSEARCH_FOR_REFxPATER,
                       fixedToBit (32, (int32_t)(-1)));
              PASS1xSEARCH_FOR_REF (0);
            }
          // ELSE (1527)
          else
            // CALL SEARCH_FOR_REF(RAND_TYPE, RAND | SHL(XB_FLAG, 15),
            // AUXMAT1(FRAME_CASE_LIST(TEMP_PTR)), -1 ); (1528)
            {
              putBITp (
                  4, mPASS1xSEARCH_FOR_REFxRAND_TYPE,
                  getBIT (8, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND_TYPE));
              putBITp (
                  16, mPASS1xSEARCH_FOR_REFxRAND,
                  fixedToBit (
                      32,
                      (int32_t)(xOR (
                          COREHALFWORD (
                              mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND),
                          SHL (
                              BYTE0 (
                                  mPASS1xSET_RAND_NOOSExMARK_VAC_CASExXB_FLAG),
                              15)))));
              putBITp (
                  16, mPASS1xSEARCH_FOR_REFxLIST_HEAD,
                  getBIT (
                      16,
                      getFIXED (mWORK_VARS)
                          + 11
                                * (COREHALFWORD (
                                    getFIXED (mSTACK_FRAME)
                                    + 32
                                          * (COREHALFWORD (
                                              mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                                    + 20 + 2 * (0)))
                          + 2 + 2 * (0)));
              putBITp (16, mPASS1xSEARCH_FOR_REFxPATER,
                       fixedToBit (32, (int32_t)(-1)));
              PASS1xSEARCH_FOR_REF (0);
            }
          // IF REF_PTR2 ~= 0 THEN (1529)
          if (1 & (xNEQ (COREHALFWORD (mREF_PTR2), 0)))
            // CELL2(REF_PTR2) = RET_MIN_NOOSE(CELL2(REF_PTR2), NEXT_USE);
            // (1530)
            {
              descriptor_t *bitRHS
                  = (putBITp (16, mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE1,
                              getBIT (16, getFIXED (mLIST_STRUX)
                                              + 8 * (COREHALFWORD (mREF_PTR2))
                                              + 2 + 2 * (0))),
                     putBITp (
                         16, mPASS1xSET_RAND_NOOSExRET_MIN_NOOSExNOOSE2,
                         getBIT (
                             16,
                             mPASS1xSET_RAND_NOOSExMARK_VAC_CASExNEXT_USE)),
                     PASS1xSET_RAND_NOOSExRET_MIN_NOOSE (0));
              putBIT (16,
                      getFIXED (mLIST_STRUX) + 8 * (COREHALFWORD (mREF_PTR2))
                          + 2 + 2 * (0),
                      bitRHS);
              bitRHS->inUse = 0;
            }
          // ELSE (1531)
          else
            // DO; (1532)
            {
            rs1s2s1:;
              // TEMP_CELL = GET_FREE_CELL; (1533)
              {
                descriptor_t *bitRHS = GET_FREE_CELL (0);
                putBIT (16, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_CELL,
                        bitRHS);
                bitRHS->inUse = 0;
              }
              // IF FRAME_CASE_LIST(TEMP_PTR) < HALMAT_SIZE THEN (1534)
              if (1
                  & (xLT (
                      COREHALFWORD (
                          getFIXED (mSTACK_FRAME)
                          + 32
                                * (COREHALFWORD (
                                    mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                          + 20 + 2 * (0)),
                      1800)))
                // CELL1(TEMP_CELL) = RAND; (1535)
                {
                  descriptor_t *bitRHS
                      = getBIT (16, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND);
                  putBIT (
                      16,
                      getFIXED (mLIST_STRUX)
                          + 8
                                * (COREHALFWORD (
                                    mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_CELL))
                          + 0 + 2 * (0),
                      bitRHS);
                  bitRHS->inUse = 0;
                }
              // ELSE (1536)
              else
                // CELL1(TEMP_CELL) = RAND | SHL(XB_FLAG, 15); (1537)
                {
                  int32_t numberRHS = (int32_t)(xOR (
                      COREHALFWORD (mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND),
                      SHL (BYTE0 (mPASS1xSET_RAND_NOOSExMARK_VAC_CASExXB_FLAG),
                           15)));
                  putBIT (
                      16,
                      getFIXED (mLIST_STRUX)
                          + 8
                                * (COREHALFWORD (
                                    mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_CELL))
                          + 0 + 2 * (0),
                      fixedToBit (16, numberRHS));
                }
              // CELL2(TEMP_CELL) = NEXT_USE; (1538)
              {
                descriptor_t *bitRHS = getBIT (
                    16, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExNEXT_USE);
                putBIT (
                    16,
                    getFIXED (mLIST_STRUX)
                        + 8
                              * (COREHALFWORD (
                                  mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_CELL))
                        + 2 + 2 * (0),
                    bitRHS);
                bitRHS->inUse = 0;
              }
              // CELL1_FLAGS(TEMP_CELL) = RAND_TYPE; (1539)
              {
                descriptor_t *bitRHS = getBIT (
                    8, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExRAND_TYPE);
                putBIT (
                    8,
                    getFIXED (mLIST_STRUX)
                        + 8
                              * (COREHALFWORD (
                                  mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_CELL))
                        + 6 + 1 * (0),
                    bitRHS);
                bitRHS->inUse = 0;
              }
              // CDR_CELL(TEMP_CELL) = AUXMAT1(FRAME_CASE_LIST(TEMP_PTR));
              // (1540)
              {
                descriptor_t *bitRHS = getBIT (
                    16,
                    getFIXED (mWORK_VARS)
                        + 11
                              * (COREHALFWORD (
                                  getFIXED (mSTACK_FRAME)
                                  + 32
                                        * (COREHALFWORD (
                                            mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                                  + 20 + 2 * (0)))
                        + 2 + 2 * (0));
                putBIT (
                    16,
                    getFIXED (mLIST_STRUX)
                        + 8
                              * (COREHALFWORD (
                                  mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_CELL))
                        + 4 + 2 * (0),
                    bitRHS);
                bitRHS->inUse = 0;
              }
              // AUXMAT1(FRAME_CASE_LIST(TEMP_PTR)) = TEMP_CELL; (1541)
              {
                descriptor_t *bitRHS = getBIT (
                    16, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_CELL);
                putBIT (
                    16,
                    getFIXED (mWORK_VARS)
                        + 11
                              * (COREHALFWORD (
                                  getFIXED (mSTACK_FRAME)
                                  + 32
                                        * (COREHALFWORD (
                                            mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR))
                                  + 20 + 2 * (0)))
                        + 2 + 2 * (0),
                    bitRHS);
                bitRHS->inUse = 0;
              }
            es1s2s1:;
            } // End of DO block
        es1s2:;
        } // End of DO block
      // ELSE (1542)
      else
        // RETURN; (1543)
        {
          reentryGuard = 0;
          return 0;
        }
      // TEMP_PTR = TEMP_PTR - 1; (1544)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            COREHALFWORD (mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mPASS1xSET_RAND_NOOSExMARK_VAC_CASExTEMP_PTR, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
