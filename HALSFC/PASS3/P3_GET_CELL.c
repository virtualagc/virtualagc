/*
  File P3_GET_CELL.c generated by XCOM-I, 2024-08-08 04:33:10.
*/

#include "runtimeC.h"

int32_t
P3_GET_CELL (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "P3_GET_CELL");
  // LENGTH = (LENGTH + 3)& 4294967292; (1262)
  {
    int32_t numberRHS = (int32_t)(xAND (
        xadd (getFIXED (mP3_GET_CELLxLENGTH), 3), 4294967292));
    putFIXED (mP3_GET_CELLxLENGTH, numberRHS);
  }
  // IF LENGTH < 8 THEN (1263)
  if (1 & (xLT (getFIXED (mP3_GET_CELLxLENGTH), 8)))
    // LENGTH = 8; (1264)
    {
      int32_t numberRHS = (int32_t)(8);
      putFIXED (mP3_GET_CELLxLENGTH, numberRHS);
    }
  // IF LENGTH > PAGE_SIZE THEN (1265)
  if (1 & (xGT (getFIXED (mP3_GET_CELLxLENGTH), 1680)))
    // DO; (1266)
    {
    rs1:;
      // OUTPUT = X1; (1267)
      {
        descriptor_t *stringRHS;
        stringRHS = getCHARACTER (mX1);
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // OUTPUT = P3ERR || 'ILLEGAL CELL SIZE (' || LENGTH || ') ***'; (1268)
      {
        descriptor_t *stringRHS;
        stringRHS = xsCAT (
            xsCAT (xsCAT (getCHARACTER (mP3ERR),
                          cToDescriptor (NULL, "ILLEGAL CELL SIZE (")),
                   fixedToCharacter (getFIXED (mP3_GET_CELLxLENGTH))),
            cToDescriptor (NULL, ") ***"));
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // GO TO PHASE3_ERROR; (1269)
      {
        resetAllReentryGuards ();
        longjmp (jbPHASE3_ERROR, 1);
      }
    es1:;
    } // End of DO block
  // CUR_PTR = PRED_PTR; (1270)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mP3_GET_CELLxPRED_PTR));
    putFIXED (mP3_GET_CELLxCUR_PTR, numberRHS);
  }
  // DO FOREVER; (1271)
  while (1 & (1))
    {
      // CALL P3_LOCATE(CUR_PTR,ADDR(NODE),0); (1272)
      {
        putFIXED (mP3_LOCATExPTR, getFIXED (mP3_GET_CELLxCUR_PTR));
        putFIXED (mP3_LOCATExBVAR,
                  ADDR ("P3_GET_CELLxNODE", 0x80000000, NULL, 0));
        putBITp (8, mP3_LOCATExFLAGS, fixedToBit (32, (int32_t)(0)));
        P3_LOCATE (0);
      }
      // IF NODE(0) >= LENGTH THEN (1273)
      if (1
          & (xGE (getFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * 0),
                  getFIXED (mP3_GET_CELLxLENGTH))))
        // DO; (1274)
        {
        rs2s1:;
          // IF NODE(0) < LENGTH + 8 THEN (1275)
          if (1
              & (xLT (getFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * 0),
                      xadd (getFIXED (mP3_GET_CELLxLENGTH), 8))))
            // LENGTH = NODE(0); (1276)
            {
              int32_t numberRHS
                  = (int32_t)(getFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * 0));
              putFIXED (mP3_GET_CELLxLENGTH, numberRHS);
            }
          // IF NODE(0) = LENGTH THEN (1277)
          if (1
              & (xEQ (getFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * 0),
                      getFIXED (mP3_GET_CELLxLENGTH))))
            // DO; (1278)
            {
            rs2s1s1:;
              // FULL_TEMP = NODE(1); (1279)
              {
                int32_t numberRHS = (int32_t)(getFIXED (
                    getFIXED (mP3_GET_CELLxNODE) + 4 * 1));
                putFIXED (mP3_GET_CELLxFULL_TEMP, numberRHS);
              }
              // NODE(1) = 0; (1280)
              {
                int32_t numberRHS = (int32_t)(0);
                putFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * (1), numberRHS);
              }
              // CALL P3_DISP(MODF); (1281)
              {
                putBITp (8, mP3_DISPxFLAGS, getBIT (8, mMODF));
                P3_DISP (0);
              }
              // CALL PUTN(PRED_PTR,4,ADDR(FULL_TEMP),4,0); (1282)
              {
                putFIXED (mPUTNxPTR, getFIXED (mP3_GET_CELLxPRED_PTR));
                putBITp (16, mPUTNxOFFSET, fixedToBit (32, (int32_t)(4)));
                putFIXED (mPUTNxCORE_ADDR,
                          ADDR (NULL, 0, "P3_GET_CELLxFULL_TEMP", 0));
                putBITp (16, mPUTNxCOUNT, fixedToBit (32, (int32_t)(4)));
                putBITp (8, mPUTNxFLAGS, fixedToBit (32, (int32_t)(0)));
                PUTN (0);
              }
              // GO TO GOT_CELL; (1283)
              goto GOT_CELL;
            es2s1s1:;
            } // End of DO block
          // ELSE (1284)
          else
            // DO; (1285)
            {
            rs2s1s2:;
              // NODE(0) = NODE(0) - LENGTH; (1286)
              {
                int32_t numberRHS = (int32_t)(xsubtract (
                    getFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * 0),
                    getFIXED (mP3_GET_CELLxLENGTH)));
                putFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * (0), numberRHS);
              }
              // CUR_PTR = CUR_PTR + NODE(0); (1287)
              {
                int32_t numberRHS = (int32_t)(xadd (
                    getFIXED (mP3_GET_CELLxCUR_PTR),
                    getFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * 0)));
                putFIXED (mP3_GET_CELLxCUR_PTR, numberRHS);
              }
              // DEX = SHR(NODE(0),2); (1288)
              {
                int32_t numberRHS = (int32_t)(SHR (
                    getFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * 0), 2));
                putFIXED (mP3_GET_CELLxDEX, numberRHS);
              }
              // NODE(DEX) = LENGTH; (1289)
              {
                int32_t numberRHS = (int32_t)(getFIXED (mP3_GET_CELLxLENGTH));
                putFIXED (getFIXED (mP3_GET_CELLxNODE)
                              + 4 * (getFIXED (mP3_GET_CELLxDEX)),
                          numberRHS);
              }
              // GO TO GOT_CELL; (1290)
              goto GOT_CELL;
            es2s1s2:;
            } // End of DO block
        es2s1:;
        } // End of DO block
      // ELSE (1291)
      else
        // DO; (1292)
        {
        rs2s2:;
          // PRED_PTR = CUR_PTR; (1293)
          {
            int32_t numberRHS = (int32_t)(getFIXED (mP3_GET_CELLxCUR_PTR));
            putFIXED (mP3_GET_CELLxPRED_PTR, numberRHS);
          }
          // CUR_PTR = NODE(1); (1294)
          {
            int32_t numberRHS
                = (int32_t)(getFIXED (getFIXED (mP3_GET_CELLxNODE) + 4 * 1));
            putFIXED (mP3_GET_CELLxCUR_PTR, numberRHS);
          }
          // IF CUR_PTR = 0 THEN (1295)
          if (1 & (xEQ (getFIXED (mP3_GET_CELLxCUR_PTR), 0)))
            // DO; (1296)
            {
            rs2s2s1:;
              // CUR_PTR = FREE_CHAIN; (1297)
              {
                int32_t numberRHS = (int32_t)(getFIXED (mFREE_CHAIN));
                putFIXED (mP3_GET_CELLxCUR_PTR, numberRHS);
              }
              // OVERFLOW_FLAG = TRUE; (1298)
              {
                int32_t numberRHS = (int32_t)(1);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (1, mOVERFLOW_FLAG, bitRHS);
                bitRHS->inUse = 0;
              }
            es2s2s1:;
            } // End of DO block
        es2s2:;
        } // End of DO block
    }     // End of DO WHILE block
// GOT_CELL: (1299)
GOT_CELL:
  // FLAGS = FLAGS | MODF; (1300)
  {
    int32_t numberRHS
        = (int32_t)(xOR (BYTE0 (mP3_GET_CELLxFLAGS), BYTE0 (mMODF)));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (8, mP3_GET_CELLxFLAGS, bitRHS);
    bitRHS->inUse = 0;
  }
  // CALL P3_LOCATE(CUR_PTR,BVAR,FLAGS); (1301)
  {
    putFIXED (mP3_LOCATExPTR, getFIXED (mP3_GET_CELLxCUR_PTR));
    putFIXED (mP3_LOCATExBVAR, getFIXED (mP3_GET_CELLxBVAR));
    putBITp (8, mP3_LOCATExFLAGS, getBIT (8, mP3_GET_CELLxFLAGS));
    P3_LOCATE (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
