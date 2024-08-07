/*
  File PASS1xPUSH_FIRST_CASE_FRAME.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
PASS1xPUSH_FIRST_CASE_FRAME (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PASS1xPUSH_FIRST_CASE_FRAME");
  // IF STACK_DUMP THEN (1970)
  if (1 & (bitToFixed (getBIT (1, mSTACK_DUMP))))
    // CALL DUMP_STACK; (1971)
    PASS1xDUMP_STACK (0);
  // CALL INCR_STACK_PTR; (1972)
  INCR_STACK_PTR (0);
  // IF FRAME_TYPE(STACK_PTR - 1) ~= CB_TYPE THEN (1973)
  if (1
      & (xNEQ (BYTE0 (getFIXED (mSTACK_FRAME)
                      + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 30
                      + 1 * (0)),
               2)))
    // CALL STACK_ERROR(PUSH_IND, FRAME_TYPE(STACK_PTR - 1), CCURRENT); (1974)
    {
      putCHARACTERp (mPASS1xSTACK_ERRORxHALMAT_TYPE,
                     getCHARACTER (mPASS1xPUSH_FIRST_CASE_FRAMExPUSH_IND));
      putBITp (16, mPASS1xSTACK_ERRORxFRM_TYPE,
               getBIT (8, getFIXED (mSTACK_FRAME)
                              + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                              + 30 + 1 * (0)));
      putCHARACTERp (mPASS1xSTACK_ERRORxWHICH_FRAME, getCHARACTER (mCCURRENT));
      PASS1xSTACK_ERROR (0);
    }
  // FRAME_TYPE(STACK_PTR) = CASE_TYPE; (1975)
  {
    int32_t numberRHS = (int32_t)(3);
    putBIT (8,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 30
                + 1 * (0),
            fixedToBit (8, numberRHS));
  }
  // FRAME_FLAGS(STACK_PTR) = PUSH_IND_FLAG; (1976)
  {
    descriptor_t *bitRHS
        = getBIT (8, mPASS1xPUSH_FIRST_CASE_FRAMExPUSH_IND_FLAG);
    putBIT (8,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 31
                + 1 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // MAX_CASE_LENGTH(STACK_PTR - 1) =  32768; (1977)
  {
    int32_t numberRHS = (int32_t)(32768);
    putBIT (16,
            getFIXED (mSTACK_FRAME)
                + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 0
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // FRAME_START(STACK_PTR) = HALMAT_PTR; (1978)
  {
    descriptor_t *bitRHS = getBIT (16, mHALMAT_PTR);
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 4
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // FRAME_START(STACK_PTR - 1) = HALMAT_PTR; (1979)
  {
    descriptor_t *bitRHS = getBIT (16, mHALMAT_PTR);
    putBIT (16,
            getFIXED (mSTACK_FRAME)
                + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 4
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // FRAME_BLOCK_PTR(STACK_PTR) = FRAME_BLOCK_PTR(STACK_PTR - 1); (1980)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mSTACK_FRAME)
                          + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                          + 26 + 2 * (0));
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 26
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // FRAME_UVCS(STACK_PTR) = 0; (1981)
  {
    int32_t numberRHS = (int32_t)(0);
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 6
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // FRAME_UVCS(STACK_PTR - 1) = 0; (1982)
  {
    int32_t numberRHS = (int32_t)(0);
    putBIT (16,
            getFIXED (mSTACK_FRAME)
                + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 6
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // FRAME_CB_NEST_LEVEL(STACK_PTR - 1) = 1; (1983)
  {
    int32_t numberRHS = (int32_t)(1);
    putBIT (16,
            getFIXED (mSTACK_FRAME)
                + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 2
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // IF (FRAME_FLAGS(STACK_PTR - 1) & PREV_BLOCK_FLAG) = 0 THEN (1984)
  if (1
      & (xEQ (xAND (BYTE0 (getFIXED (mSTACK_FRAME)
                           + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                           + 31 + 1 * (0)),
                    2),
              0)))
    // DO; (1985)
    {
    rs1:;
      // TEMP_PTR1 = NEW_SYT_REF_FRAME; (1986)
      {
        descriptor_t *bitRHS = NEW_SYT_REF_FRAME (0);
        putBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1, bitRHS);
        bitRHS->inUse = 0;
      }
      // TEMP_PTR2 = FRAME_SYT_PREV_REF(STACK_PTR - 1); (1987)
      {
        descriptor_t *bitRHS
            = getBIT (16, getFIXED (mSTACK_FRAME)
                              + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                              + 14 + 2 * (0));
        putBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR2, bitRHS);
        bitRHS->inUse = 0;
      }
      // TEMP_PTR3 = FRAME_SYT_REF(STACK_PTR - 1); (1988)
      {
        descriptor_t *bitRHS
            = getBIT (16, getFIXED (mSTACK_FRAME)
                              + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                              + 10 + 2 * (0));
        putBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR3, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO FOR WORK1 = 0 TO SYT_REF_POOL_FRAME_SIZE; (1989)
      {
        int32_t from47, to47, by47;
        from47 = 0;
        to47 = bitToFixed (getBIT (16, mSYT_REF_POOL_FRAME_SIZE));
        by47 = 1;
        for (putFIXED (mWORK1, from47); getFIXED (mWORK1) <= to47;
             putFIXED (mWORK1, getFIXED (mWORK1) + by47))
          {
            // SYT_REF_POOL(TEMP_PTR1 + WORK1) = SYT_REF_POOL(TEMP_PTR2 +
            // WORK1) | SYT_REF_POOL(TEMP_PTR3 + WORK1); (1990)
            {
              int32_t numberRHS = (int32_t)(xOR (
                  COREWORD (
                      getFIXED (mS_POOL)
                      + 4
                            * (xadd (
                                COREHALFWORD (
                                    mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR2),
                                getFIXED (mWORK1)))
                      + 0 + 4 * (0)),
                  COREWORD (
                      getFIXED (mS_POOL)
                      + 4
                            * (xadd (
                                COREHALFWORD (
                                    mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR3),
                                getFIXED (mWORK1)))
                      + 0 + 4 * (0))));
              putBIT (
                  32,
                  getFIXED (mS_POOL)
                      + 4
                            * (xadd (
                                COREHALFWORD (
                                    mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1),
                                getFIXED (mWORK1)))
                      + 0 + 4 * (0),
                  fixedToBit (32, numberRHS));
            }
          }
      } // End of DO for-loop block
      // FRAME_SYT_PREV_REF(STACK_PTR) = TEMP_PTR1; (1991)
      {
        descriptor_t *bitRHS
            = getBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1);
        putBIT (16,
                getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 14
                    + 2 * (0),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // FRAME_SYT_PREV_REF(STACK_PTR - 1) = TEMP_PTR1; (1992)
      {
        descriptor_t *bitRHS
            = getBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1);
        putBIT (16,
                getFIXED (mSTACK_FRAME)
                    + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 14
                    + 2 * (0),
                bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // ELSE (1993)
  else
    // DO; (1994)
    {
    rs2:;
      // IF FRAME_SYT_REF(STACK_PTR - 1) ~= 0 THEN (1995)
      if (1
          & (xNEQ (
              COREHALFWORD (getFIXED (mSTACK_FRAME)
                            + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                            + 10 + 2 * (0)),
              0)))
        // FRAME_SYT_PREV_REF(STACK_PTR), FRAME_SYT_PREV_REF(STACK_PTR - 1) =
        // COPY_SYT_REF_FRAME(FRAME_SYT_REF(STACK_PTR - 1)); (1996)
        {
          descriptor_t *bitRHS
              = (putBITp (
                     16, mCOPY_SYT_REF_FRAMExFRAME,
                     getBIT (
                         16,
                         getFIXED (mSTACK_FRAME)
                             + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                             + 10 + 2 * (0))),
                 COPY_SYT_REF_FRAME (0));
          putBIT (16,
                  getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR))
                      + 14 + 2 * (0),
                  bitRHS);
          putBIT (16,
                  getFIXED (mSTACK_FRAME)
                      + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 14
                      + 2 * (0),
                  bitRHS);
          bitRHS->inUse = 0;
        }
      // ELSE (1997)
      else
        // FRAME_SYT_PREV_REF(STACK_PTR), FRAME_SYT_PREV_REF(STACK_PTR - 1) =
        // NEW_ZERO_SYT_REF_FRAME; (1998)
        {
          descriptor_t *bitRHS = NEW_ZERO_SYT_REF_FRAME (0);
          putBIT (16,
                  getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR))
                      + 14 + 2 * (0),
                  bitRHS);
          putBIT (16,
                  getFIXED (mSTACK_FRAME)
                      + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 14
                      + 2 * (0),
                  bitRHS);
          bitRHS->inUse = 0;
        }
    es2:;
    } // End of DO block
  // IF (FRAME_FLAGS(STACK_PTR - 1) & PREV_BLOCK_FLAG) = 0 THEN (1999)
  if (1
      & (xEQ (xAND (BYTE0 (getFIXED (mSTACK_FRAME)
                           + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                           + 31 + 1 * (0)),
                    2),
              0)))
    // DO; (2000)
    {
    rs3:;
      // TEMP_PTR1 = NEW_VAC_REF_FRAME; (2001)
      {
        descriptor_t *bitRHS = NEW_VAC_REF_FRAME (0);
        putBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1, bitRHS);
        bitRHS->inUse = 0;
      }
      // TEMP_PTR2 = FRAME_VAC_PREV_REF(STACK_PTR - 1); (2002)
      {
        descriptor_t *bitRHS
            = getBIT (16, getFIXED (mSTACK_FRAME)
                              + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                              + 16 + 2 * (0));
        putBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR2, bitRHS);
        bitRHS->inUse = 0;
      }
      // TEMP_PTR3 = FRAME_VAC_REF(STACK_PTR - 1); (2003)
      {
        descriptor_t *bitRHS
            = getBIT (16, getFIXED (mSTACK_FRAME)
                              + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                              + 12 + 2 * (0));
        putBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR3, bitRHS);
        bitRHS->inUse = 0;
      }
      // DO FOR WORK1 = 0 TO VAC_REF_POOL_FRAME_SIZE; (2004)
      {
        int32_t from48, to48, by48;
        from48 = 0;
        to48 = bitToFixed (getBIT (16, mVAC_REF_POOL_FRAME_SIZE));
        by48 = 1;
        for (putFIXED (mWORK1, from48); getFIXED (mWORK1) <= to48;
             putFIXED (mWORK1, getFIXED (mWORK1) + by48))
          {
            // VAC_REF_POOL(TEMP_PTR1 + WORK1) = VAC_REF_POOL(TEMP_PTR2 +
            // WORK1) | VAC_REF_POOL(TEMP_PTR3 + WORK1); (2005)
            {
              int32_t numberRHS = (int32_t)(xOR (
                  COREWORD (
                      getFIXED (mV_POOL)
                      + 4
                            * (xadd (
                                COREHALFWORD (
                                    mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR2),
                                getFIXED (mWORK1)))
                      + 0 + 4 * (0)),
                  COREWORD (
                      getFIXED (mV_POOL)
                      + 4
                            * (xadd (
                                COREHALFWORD (
                                    mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR3),
                                getFIXED (mWORK1)))
                      + 0 + 4 * (0))));
              putBIT (
                  32,
                  getFIXED (mV_POOL)
                      + 4
                            * (xadd (
                                COREHALFWORD (
                                    mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1),
                                getFIXED (mWORK1)))
                      + 0 + 4 * (0),
                  fixedToBit (32, numberRHS));
            }
          }
      } // End of DO for-loop block
      // FRAME_VAC_PREV_REF(STACK_PTR) = TEMP_PTR1; (2006)
      {
        descriptor_t *bitRHS
            = getBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1);
        putBIT (16,
                getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 16
                    + 2 * (0),
                bitRHS);
        bitRHS->inUse = 0;
      }
      // FRAME_VAC_PREV_REF(STACK_PTR - 1) = TEMP_PTR1; (2007)
      {
        descriptor_t *bitRHS
            = getBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1);
        putBIT (16,
                getFIXED (mSTACK_FRAME)
                    + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 16
                    + 2 * (0),
                bitRHS);
        bitRHS->inUse = 0;
      }
    es3:;
    } // End of DO block
  // ELSE (2008)
  else
    // DO; (2009)
    {
    rs4:;
      // IF FRAME_VAC_REF(STACK_PTR - 1) ~= 0 THEN (2010)
      if (1
          & (xNEQ (
              COREHALFWORD (getFIXED (mSTACK_FRAME)
                            + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                            + 12 + 2 * (0)),
              0)))
        // FRAME_VAC_PREV_REF(STACK_PTR), FRAME_VAC_PREV_REF(STACK_PTR - 1) =
        // COPY_VAC_REF_FRAME(FRAME_VAC_REF(STACK_PTR - 1)); (2011)
        {
          descriptor_t *bitRHS
              = (putBITp (
                     16, mCOPY_VAC_REF_FRAMExFRAME,
                     getBIT (
                         16,
                         getFIXED (mSTACK_FRAME)
                             + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                             + 12 + 2 * (0))),
                 COPY_VAC_REF_FRAME (0));
          putBIT (16,
                  getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR))
                      + 16 + 2 * (0),
                  bitRHS);
          putBIT (16,
                  getFIXED (mSTACK_FRAME)
                      + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 16
                      + 2 * (0),
                  bitRHS);
          bitRHS->inUse = 0;
        }
      // ELSE (2012)
      else
        // FRAME_VAC_PREV_REF(STACK_PTR), FRAME_VAC_PREV_REF(STACK_PTR - 1) =
        // NEW_ZERO_VAC_REF_FRAME; (2013)
        {
          descriptor_t *bitRHS = NEW_ZERO_VAC_REF_FRAME (0);
          putBIT (16,
                  getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR))
                      + 16 + 2 * (0),
                  bitRHS);
          putBIT (16,
                  getFIXED (mSTACK_FRAME)
                      + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 16
                      + 2 * (0),
                  bitRHS);
          bitRHS->inUse = 0;
        }
    es4:;
    } // End of DO block
  // FRAME_SYT_REF(STACK_PTR - 1) = NEW_ZERO_SYT_REF_FRAME; (2014)
  {
    descriptor_t *bitRHS = NEW_ZERO_SYT_REF_FRAME (0);
    putBIT (16,
            getFIXED (mSTACK_FRAME)
                + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 10
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // FRAME_SYT_REF(STACK_PTR) = NEW_ZERO_SYT_REF_FRAME; (2015)
  {
    descriptor_t *bitRHS = NEW_ZERO_SYT_REF_FRAME (0);
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 10
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // FRAME_VAC_REF(STACK_PTR - 1) = NEW_ZERO_VAC_REF_FRAME; (2016)
  {
    descriptor_t *bitRHS = NEW_ZERO_VAC_REF_FRAME (0);
    putBIT (16,
            getFIXED (mSTACK_FRAME)
                + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 12
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // FRAME_VAC_REF(STACK_PTR) = NEW_ZERO_VAC_REF_FRAME; (2017)
  {
    descriptor_t *bitRHS = NEW_ZERO_VAC_REF_FRAME (0);
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 12
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // FRAME_INL(STACK_PTR) = -1; (2018)
  {
    int32_t numberRHS = (int32_t)(-1);
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 8
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // FRAME_BUMP_FACTOR(STACK_PTR) = FRAME_BUMP_FACTOR(STACK_PTR - 1); (2019)
  {
    descriptor_t *bitRHS
        = getBIT (16, getFIXED (mSTACK_FRAME)
                          + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1))
                          + 18 + 2 * (0));
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 18
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // FRAME_CASE_LIST(STACK_PTR) = HALMAT_PTR; (2020)
  {
    descriptor_t *bitRHS = getBIT (16, mHALMAT_PTR);
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 20
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // TEMP_PTR1, AUXMAT1(HALMAT_PTR) = GET_FREE_CELL; (2021)
  {
    descriptor_t *bitRHS = GET_FREE_CELL (0);
    putBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1, bitRHS);
    putBIT (16,
            getFIXED (mWORK_VARS) + 11 * (COREHALFWORD (mHALMAT_PTR)) + 2
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // CELL1(TEMP_PTR1) = -1; (2022)
  {
    int32_t numberRHS = (int32_t)(-1);
    putBIT (16,
            getFIXED (mLIST_STRUX)
                + 8 * (COREHALFWORD (mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1))
                + 0 + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // GEN_CODE(HALMAT_PTR) = GEN_LIST_OPCODE; (2023)
  {
    int32_t numberRHS = (int32_t)(7);
    putBIT (8,
            getFIXED (mWORK_VARS) + 11 * (COREHALFWORD (mHALMAT_PTR)) + 10
                + 1 * (0),
            fixedToBit (8, numberRHS));
  }
  // TEMP_PTR1, FRAME_MAP_SAVE(STACK_PTR - 1) = GET_FREE_CELL; (2024)
  {
    descriptor_t *bitRHS = GET_FREE_CELL (0);
    putBIT (16, mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1, bitRHS);
    putBIT (16,
            getFIXED (mSTACK_FRAME)
                + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 22
                + 2 * (0),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // CELL1(TEMP_PTR1) = -1; (2025)
  {
    int32_t numberRHS = (int32_t)(-1);
    putBIT (16,
            getFIXED (mLIST_STRUX)
                + 8 * (COREHALFWORD (mPASS1xPUSH_FIRST_CASE_FRAMExTEMP_PTR1))
                + 0 + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // FRAME_MAP_SAVE(STACK_PTR) = 0; (2026)
  {
    int32_t numberRHS = (int32_t)(0);
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 22
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // CASE_LIST_PTRS(STACK_PTR - 1) = 0; (2027)
  {
    int32_t numberRHS = (int32_t)(0);
    putBIT (16,
            getFIXED (mSTACK_FRAME)
                + 32 * (xsubtract (COREHALFWORD (mSTACK_PTR), 1)) + 28
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // CASE_LIST_PTRS(STACK_PTR) = 0; (2028)
  {
    int32_t numberRHS = (int32_t)(0);
    putBIT (16,
            getFIXED (mSTACK_FRAME) + 32 * (COREHALFWORD (mSTACK_PTR)) + 28
                + 2 * (0),
            fixedToBit (16, numberRHS));
  }
  // PUSH_IND_FLAG = 0; (2029)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mPASS1xPUSH_FIRST_CASE_FRAMExPUSH_IND_FLAG, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF STACK_DUMP THEN (2030)
  if (1 & (bitToFixed (getBIT (1, mSTACK_DUMP))))
    // CALL DUMP_STACK; (2031)
    PASS1xDUMP_STACK (0);
  {
    reentryGuard = 0;
    return 0;
  }
}
