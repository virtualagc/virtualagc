/*
  File SET_MASKING_BIT.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
SET_MASKING_BIT (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SET_MASKING_BIT");
  // STMT# = STMT_NO &  32767; (1453)
  {
    int32_t numberRHS
        = (int32_t)(xAND (COREHALFWORD (mSET_MASKING_BITxSTMT_NO), 32767));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mSET_MASKING_BITxSTMTp, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF STMT# = 0 THEN (1454)
  if (1 & (xEQ (COREHALFWORD (mSET_MASKING_BITxSTMTp), 0)))
    // DO; (1455)
    {
    rs1:;
      // IF FIRST_CALL THEN (1456)
      if (1 & (bitToFixed (getBIT (1, mSET_MASKING_BITxFIRST_CALL))))
        // DO; (1457)
        {
        rs1s1:;
          // FIRST_CALL = FALSE; (1458)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mSET_MASKING_BITxFIRST_CALL, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF ((OPTION_BITS &  2048) ~= 0) THEN (1459)
          if (1 & (xNEQ (xAND (getFIXED (mCOMM + 4 * 7), 2048), 0)))
            // DO; (1460)
            {
            rs1s1s1:;
              // GO_FLAG = TRUE; (1461)
              {
                int32_t numberRHS = (int32_t)(1);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (1, mSET_MASKING_BITxGO_FLAG, bitRHS);
                bitRHS->inUse = 0;
              }
              // STMT_DATA_PTR = STMT_DATA_HEAD; (1462)
              {
                int32_t numberRHS = (int32_t)(getFIXED (mCOMM + 4 * 16));
                putFIXED (mSET_MASKING_BITxSTMT_DATA_PTR, numberRHS);
              }
            es1s1s1:;
            } // End of DO block
        es1s1:;
        } // End of DO block
      // ELSE (1463)
      else
        // DO; (1464)
        {
        rs1s2:;
          // GO_FLAG = FALSE; (1465)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mSET_MASKING_BITxGO_FLAG, bitRHS);
            bitRHS->inUse = 0;
          }
        es1s2:;
        } // End of DO block
    es1:;
    } // End of DO block
  // ELSE (1466)
  else
    // IF GO_FLAG THEN (1467)
    if (1 & (bitToFixed (getBIT (1, mSET_MASKING_BITxGO_FLAG))))
      // DO; (1468)
      {
      rs2:;
        // DO WHILE CUR_STMT# < STMT#; (1469)
        while (1
               & (xLT (COREHALFWORD (mSET_MASKING_BITxCUR_STMTp),
                       COREHALFWORD (mSET_MASKING_BITxSTMTp))))
          {
            // CALL NEXT; (1470)
            SET_MASKING_BITxNEXT (0);
            // IF CUR_STMT# ~= STMT# THEN (1471)
            if (1
                & (xNEQ (COREHALFWORD (mSET_MASKING_BITxCUR_STMTp),
                         COREHALFWORD (mSET_MASKING_BITxSTMTp))))
              // STMT_DATA_PTR = NODE_F(0); (1472)
              {
                int32_t numberRHS = (int32_t)(getFIXED (
                    getFIXED (mSET_MASKING_BITxNODE_F) + 4 * 0));
                putFIXED (mSET_MASKING_BITxSTMT_DATA_PTR, numberRHS);
              }
          } // End of DO WHILE block
        // IF STMT# = CUR_STMT# THEN (1473)
        if (1
            & (xEQ (COREHALFWORD (mSET_MASKING_BITxSTMTp),
                    COREHALFWORD (mSET_MASKING_BITxCUR_STMTp))))
          // DO; (1474)
          {
          rs2s2:;
            // NODE_F(6) = NODE_F(6) |  33554432; (1475)
            {
              int32_t numberRHS = (int32_t)(xOR (
                  getFIXED (getFIXED (mSET_MASKING_BITxNODE_F) + 4 * 6),
                  33554432));
              putFIXED (getFIXED (mSET_MASKING_BITxNODE_F) + 4 * (6),
                        numberRHS);
            }
            // CALL PTR_LOCATE(STMT_DATA_PTR,MODF); (1476)
            {
              putFIXED (mPTR_LOCATExPTR,
                        getFIXED (mSET_MASKING_BITxSTMT_DATA_PTR));
              putBITp (8, mPTR_LOCATExFLAGS, getBIT (8, mMODF));
              PTR_LOCATE (0);
            }
            // IF CUR_STMT# ~= 0 THEN (1477)
            if (1 & (xNEQ (COREHALFWORD (mSET_MASKING_BITxCUR_STMTp), 0)))
              // STMT_DATA_PTR = NODE_F(0); (1478)
              {
                int32_t numberRHS = (int32_t)(getFIXED (
                    getFIXED (mSET_MASKING_BITxNODE_F) + 4 * 0));
                putFIXED (mSET_MASKING_BITxSTMT_DATA_PTR, numberRHS);
              }
          es2s2:;
          } // End of DO block
        // ELSE (1479)
        else
          // DO; (1480)
          {
          rs2s3:;
            // CALL PTR_LOCATE(STMT_DATA_PTR,RELS); (1481)
            {
              putFIXED (mPTR_LOCATExPTR,
                        getFIXED (mSET_MASKING_BITxSTMT_DATA_PTR));
              putBITp (8, mPTR_LOCATExFLAGS, getBIT (8, mRELS));
              PTR_LOCATE (0);
            }
            // CALL ERRORS(CLASS_BI,500); (1482)
            {
              putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_BI));
              putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(500)));
              ERRORS (0);
            }
          es2s3:;
          } // End of DO block
      es2:;
      } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
