/*
  File EMIT_ADDRS.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
EMIT_ADDRS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "EMIT_ADDRS");
  // STMT# = STMT_NO &  32767; (1482)
  {
    int32_t numberRHS
        = (int32_t)(xAND (COREHALFWORD (mEMIT_ADDRSxSTMT_NO), 32767));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mEMIT_ADDRSxSTMTp, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF STMT# = 0 THEN (1483)
  if (1 & (xEQ (COREHALFWORD (mEMIT_ADDRSxSTMTp), 0)))
    // DO; (1484)
    {
    rs1:;
      // IF FIRST_CALL THEN (1485)
      if (1 & (bitToFixed (getBIT (1, mEMIT_ADDRSxFIRST_CALL))))
        // DO; (1486)
        {
        rs1s1:;
          // FIRST_CALL = FALSE; (1487)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mEMIT_ADDRSxFIRST_CALL, bitRHS);
            bitRHS->inUse = 0;
          }
          // IF (((OPTION_BITS& 1048576)~=0)&((OPTION_BITS& 2048)~=0)) THEN
          // (1488)
          if (1
              & (xAND (xNEQ (xAND (getFIXED (mCOMM + 4 * 7), 1048576), 0),
                       xNEQ (xAND (getFIXED (mCOMM + 4 * 7), 2048), 0))))
            // DO; (1489)
            {
            rs1s1s1:;
              // GO_FLAG = TRUE; (1490)
              {
                int32_t numberRHS = (int32_t)(1);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (1, mEMIT_ADDRSxGO_FLAG, bitRHS);
                bitRHS->inUse = 0;
              }
              // STMT_DATA_PTR = STMT_DATA_HEAD; (1491)
              {
                int32_t numberRHS = (int32_t)(getFIXED (mCOMM + 4 * 16));
                putFIXED (mEMIT_ADDRSxSTMT_DATA_PTR, numberRHS);
              }
            es1s1s1:;
            } // End of DO block
        es1s1:;
        } // End of DO block
      // ELSE (1492)
      else
        // DO; (1493)
        {
        rs1s2:;
          // GO_FLAG = FALSE; (1494)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (1, mEMIT_ADDRSxGO_FLAG, bitRHS);
            bitRHS->inUse = 0;
          }
        es1s2:;
        } // End of DO block
    es1:;
    } // End of DO block
  // ELSE (1495)
  else
    // IF GO_FLAG THEN (1496)
    if (1 & (bitToFixed (getBIT (1, mEMIT_ADDRSxGO_FLAG))))
      // DO; (1497)
      {
      rs2:;
        // DO UNTIL CUR_STMT# = STMT#; (1498)
        do
          {
            // IF STMT_DATA_PTR = -1 THEN (1499)
            if (1 & (xEQ (getFIXED (mEMIT_ADDRSxSTMT_DATA_PTR), -1)))
              // DO; (1500)
              {
              rs2s1s1:;
                // CALL ERRORS(CLASS_BI,510); (1501)
                {
                  putBITp (16, mERRORSxCLASS, getBIT (8, mCLASS_BI));
                  putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(510)));
                  ERRORS (0);
                }
                // CALL EXIT; (1502)
                EXIT ();
              es2s1s1:;
              } // End of DO block
            // CALL LOCATE(STMT_DATA_PTR,ADDR(NODE_F),0); (1503)
            {
              putFIXED (mLOCATExPTR, getFIXED (mEMIT_ADDRSxSTMT_DATA_PTR));
              putFIXED (mLOCATExBVAR,
                        ADDR ("EMIT_ADDRSxNODE_F", 0x80000000, NULL, 0));
              putBITp (8, mLOCATExFLAGS, fixedToBit (32, (int32_t)(0)));
              LOCATE (0);
            }
            // CUR_STMT# = (SHR(NODE_F(7),16) &  65535); (1504)
            {
              int32_t numberRHS = (int32_t)(xAND (
                  SHR (getFIXED (getFIXED (mEMIT_ADDRSxNODE_F) + 4 * 7), 16),
                  65535));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mEMIT_ADDRSxCUR_STMTp, bitRHS);
              bitRHS->inUse = 0;
            }
            // IF CUR_STMT# ~= 0 THEN (1505)
            if (1 & (xNEQ (COREHALFWORD (mEMIT_ADDRSxCUR_STMTp), 0)))
              // STMT_DATA_PTR = NODE_F(0); (1506)
              {
                int32_t numberRHS = (int32_t)(getFIXED (
                    getFIXED (mEMIT_ADDRSxNODE_F) + 4 * 0));
                putFIXED (mEMIT_ADDRSxSTMT_DATA_PTR, numberRHS);
              }
          }
        while (!(1
                 & (xEQ (COREHALFWORD (mEMIT_ADDRSxCUR_STMTp),
                         COREHALFWORD (
                             mEMIT_ADDRSxSTMTp))))); // End of DO UNTIL block
        // CALL DISP(MODF); (1507)
        {
          putBITp (8, mDISPxFLAGS, getBIT (8, mMODF));
          DISP (0);
        }
        // IF (CURRENT_ESDID >= PROGPOINT) & (CURRENT_ESDID <= PROCLIMIT) THEN
        // (1508)
        if (1
            & (xAND (
                xGE (getFIXED (mCURRENT_ESDID), COREHALFWORD (mPROGPOINT)),
                xLE (getFIXED (mCURRENT_ESDID), COREHALFWORD (mPROCLIMIT)))))
          // DO; (1509)
          {
          rs2s2:;
            // NODE_F(8)= ADDR1; (1510)
            {
              int32_t numberRHS = (int32_t)(getFIXED (mEMIT_ADDRSxADDR1));
              putFIXED (getFIXED (mEMIT_ADDRSxNODE_F) + 4 * (8), numberRHS);
            }
            // NODE_F(9)= ADDR2; (1511)
            {
              int32_t numberRHS = (int32_t)(getFIXED (mEMIT_ADDRSxADDR2));
              putFIXED (getFIXED (mEMIT_ADDRSxNODE_F) + 4 * (9), numberRHS);
            }
            // NODE_F(10),NODE_F(11)= 0; (1512)
            {
              int32_t numberRHS = (int32_t)(0);
              putFIXED (getFIXED (mEMIT_ADDRSxNODE_F) + 4 * (10), numberRHS);
              putFIXED (getFIXED (mEMIT_ADDRSxNODE_F) + 4 * (11), numberRHS);
            }
          es2s2:;
          } // End of DO block
      es2:;
      } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
