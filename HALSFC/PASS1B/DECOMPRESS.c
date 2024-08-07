/*
  File DECOMPRESS.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

descriptor_t *
DECOMPRESS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "DECOMPRESS");
  // OUT_REC_PTR = 0; (2819)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mDECOMPRESSxOUT_REC_PTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // INPUT_PTR = IN_REC_PTR(DEV); (2820)
  {
    descriptor_t *bitRHS = getBIT (
        16, mDECOMPRESSxIN_REC_PTR + 2 * COREHALFWORD (mDECOMPRESSxDEV));
    putBIT (16, mDECOMPRESSxINPUT_PTR, bitRHS);
    bitRHS->inUse = 0;
  }
  // CURRENT_RECORD = INPUT_REC(DEV); (2821)
  {
    descriptor_t *stringRHS;
    stringRHS = getCHARACTER (mINPUT_REC + 4 * COREHALFWORD (mDECOMPRESSxDEV));
    putCHARACTER (mDECOMPRESSxCURRENT_RECORD, stringRHS);
    stringRHS->inUse = 0;
  }
  // CALL BLANK(RECRD, 0, 132); (2822)
  {
    putCHARACTERp (mBLANKxSTRING, getCHARACTER (mDECOMPRESSxRECRD));
    putBITp (16, mBLANKxSTART, fixedToBit (32, (int32_t)(0)));
    putBITp (16, mBLANKxCOUNT, fixedToBit (32, (int32_t)(132)));
    BLANK (0);
  }
  // DO WHILE OUT_REC_PTR <= LRECL(DEV); (2823)
  while (1
         & (xLE (COREHALFWORD (mDECOMPRESSxOUT_REC_PTR),
                 COREHALFWORD (mLRECL + 2 * COREHALFWORD (mDECOMPRESSxDEV)))))
    {
      // IF INPUT_PTR > LRECL(DEV) THEN (2824)
      if (1
          & (xGT (COREHALFWORD (mDECOMPRESSxINPUT_PTR),
                  COREHALFWORD (mLRECL + 2 * COREHALFWORD (mDECOMPRESSxDEV)))))
        // DO; (2825)
        {
        rs1s1:;
          // CURRENT_RECORD = INPUT(INPUT_DEV); (2826)
          {
            descriptor_t *stringRHS;
            stringRHS = INPUT (COREHALFWORD (mINPUT_DEV));
            putCHARACTER (mDECOMPRESSxCURRENT_RECORD, stringRHS);
            stringRHS->inUse = 0;
          }
          // INPUT_REC(DEV) = CURRENT_RECORD; (2827)
          {
            descriptor_t *stringRHS;
            stringRHS = getCHARACTER (mDECOMPRESSxCURRENT_RECORD);
            putCHARACTER (mINPUT_REC + 4 * (COREHALFWORD (mDECOMPRESSxDEV)),
                          stringRHS);
            stringRHS->inUse = 0;
          }
          // INPUT_PTR = 2; (2828)
          {
            int32_t numberRHS = (int32_t)(2);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mDECOMPRESSxINPUT_PTR, bitRHS);
            bitRHS->inUse = 0;
          }
        es1s1:;
        } // End of DO block
      // CNTL_BYTE = BYTE(CURRENT_RECORD, INPUT_PTR); (2829)
      {
        int32_t numberRHS
            = (int32_t)(BYTE (getCHARACTER (mDECOMPRESSxCURRENT_RECORD),
                              COREHALFWORD (mDECOMPRESSxINPUT_PTR)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mDECOMPRESSxCNTL_BYTE, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF SHR(CNTL_BYTE, 7) THEN (2830)
      if (1 & (SHR (BYTE0 (mDECOMPRESSxCNTL_BYTE), 7)))
        // DO; (2831)
        {
        rs1s2:;
          // IF CNTL_BYTE =  255 THEN (2832)
          if (1 & (xEQ (BYTE0 (mDECOMPRESSxCNTL_BYTE), 255)))
            // DO; (2833)
            {
            rs1s2s1:;
              // IN_REC_PTR(DEV) = 2; (2834)
              {
                int32_t numberRHS = (int32_t)(2);
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16,
                        mDECOMPRESSxIN_REC_PTR
                            + 2 * (COREHALFWORD (mDECOMPRESSxDEV)),
                        bitRHS);
                bitRHS->inUse = 0;
              }
              // RETURN ''; (2835)
              {
                reentryGuard = 0;
                return cToDescriptor (NULL, "");
              }
            es1s2s1:;
            } // End of DO block
          // ELSE (2836)
          else
            // DO; (2837)
            {
            rs1s2s2:;
              // OUT_REC_PTR = OUT_REC_PTR + (CNTL_BYTE &  127) + 1; (2838)
              {
                int32_t numberRHS = (int32_t)(xadd (
                    xadd (COREHALFWORD (mDECOMPRESSxOUT_REC_PTR),
                          xAND (BYTE0 (mDECOMPRESSxCNTL_BYTE), 127)),
                    1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mDECOMPRESSxOUT_REC_PTR, bitRHS);
                bitRHS->inUse = 0;
              }
              // INPUT_PTR = INPUT_PTR + 1; (2839)
              {
                int32_t numberRHS = (int32_t)(xadd (
                    COREHALFWORD (mDECOMPRESSxINPUT_PTR), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mDECOMPRESSxINPUT_PTR, bitRHS);
                bitRHS->inUse = 0;
              }
            es1s2s2:;
            } // End of DO block
        es1s2:;
        } // End of DO block
      // ELSE (2840)
      else
        // DO; (2841)
        {
        rs1s3:;
          // IF SHR(CNTL_BYTE, 6) THEN (2842)
          if (1 & (SHR (BYTE0 (mDECOMPRESSxCNTL_BYTE), 6)))
            // DO; (2843)
            {
            rs1s3s1:;
              // I = INPUT_PTR + 1; (2844)
              {
                int32_t numberRHS = (int32_t)(xadd (
                    COREHALFWORD (mDECOMPRESSxINPUT_PTR), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mDECOMPRESSxI, bitRHS);
                bitRHS->inUse = 0;
              }
              // J = I + (CNTL_BYTE &  63); (2845)
              {
                int32_t numberRHS = (int32_t)(xadd (
                    COREHALFWORD (mDECOMPRESSxI),
                    xAND (BYTE0 (mDECOMPRESSxCNTL_BYTE), 63)));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mDECOMPRESSxJ, bitRHS);
                bitRHS->inUse = 0;
              }
              // DO WHILE I <= J; (2846)
              while (1
                     & (xLE (COREHALFWORD (mDECOMPRESSxI),
                             COREHALFWORD (mDECOMPRESSxJ))))
                {
                  // IF I > LRECL(DEV) THEN (2847)
                  if (1
                      & (xGT (
                          COREHALFWORD (mDECOMPRESSxI),
                          COREHALFWORD (
                              mLRECL + 2 * COREHALFWORD (mDECOMPRESSxDEV)))))
                    // DO; (2848)
                    {
                    rs1s3s1s1s1:;
                      // CURRENT_RECORD = INPUT(INPUT_DEV); (2849)
                      {
                        descriptor_t *stringRHS;
                        stringRHS = INPUT (COREHALFWORD (mINPUT_DEV));
                        putCHARACTER (mDECOMPRESSxCURRENT_RECORD, stringRHS);
                        stringRHS->inUse = 0;
                      }
                      // INPUT_REC(DEV) = CURRENT_RECORD; (2850)
                      {
                        descriptor_t *stringRHS;
                        stringRHS = getCHARACTER (mDECOMPRESSxCURRENT_RECORD);
                        putCHARACTER (
                            mINPUT_REC + 4 * (COREHALFWORD (mDECOMPRESSxDEV)),
                            stringRHS);
                        stringRHS->inUse = 0;
                      }
                      // I = 2; (2851)
                      {
                        int32_t numberRHS = (int32_t)(2);
                        descriptor_t *bitRHS;
                        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                        putBIT (16, mDECOMPRESSxI, bitRHS);
                        bitRHS->inUse = 0;
                      }
                      // J = J - LRECL(DEV) + 1; (2852)
                      {
                        int32_t numberRHS = (int32_t)(xadd (
                            xsubtract (
                                COREHALFWORD (mDECOMPRESSxJ),
                                COREHALFWORD (
                                    mLRECL
                                    + 2 * COREHALFWORD (mDECOMPRESSxDEV))),
                            1));
                        descriptor_t *bitRHS;
                        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                        putBIT (16, mDECOMPRESSxJ, bitRHS);
                        bitRHS->inUse = 0;
                      }
                    es1s3s1s1s1:;
                    } // End of DO block
                  // K = BYTE(CURRENT_RECORD, I); (2853)
                  {
                    int32_t numberRHS = (int32_t)(BYTE (
                        getCHARACTER (mDECOMPRESSxCURRENT_RECORD),
                        COREHALFWORD (mDECOMPRESSxI)));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mDECOMPRESSxK, bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // BYTE(RECRD, OUT_REC_PTR) = K; (2854)
                  {
                    descriptor_t *bitRHS = getBIT (16, mDECOMPRESSxK);
                    lBYTEb (ADDR (NULL, 0, "DECOMPRESSxRECRD", 0),
                            COREHALFWORD (mDECOMPRESSxOUT_REC_PTR),
                            COREHALFWORD (mDECOMPRESSxK));
                    bitRHS->inUse = 0;
                  }
                  // OUT_REC_PTR = OUT_REC_PTR + 1; (2855)
                  {
                    int32_t numberRHS = (int32_t)(xadd (
                        COREHALFWORD (mDECOMPRESSxOUT_REC_PTR), 1));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mDECOMPRESSxOUT_REC_PTR, bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // I = I + 1; (2856)
                  {
                    int32_t numberRHS
                        = (int32_t)(xadd (COREHALFWORD (mDECOMPRESSxI), 1));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mDECOMPRESSxI, bitRHS);
                    bitRHS->inUse = 0;
                  }
                } // End of DO WHILE block
              // INPUT_PTR = I; (2857)
              {
                descriptor_t *bitRHS = getBIT (16, mDECOMPRESSxI);
                putBIT (16, mDECOMPRESSxINPUT_PTR, bitRHS);
                bitRHS->inUse = 0;
              }
            es1s3s1:;
            } // End of DO block
          // ELSE (2858)
          else
            // DO; (2859)
            {
            rs1s3s2:;
              // INPUT_PTR = INPUT_PTR + 1; (2860)
              {
                int32_t numberRHS = (int32_t)(xadd (
                    COREHALFWORD (mDECOMPRESSxINPUT_PTR), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mDECOMPRESSxINPUT_PTR, bitRHS);
                bitRHS->inUse = 0;
              }
              // IF INPUT_PTR > LRECL(DEV) THEN (2861)
              if (1
                  & (xGT (COREHALFWORD (mDECOMPRESSxINPUT_PTR),
                          COREHALFWORD (
                              mLRECL + 2 * COREHALFWORD (mDECOMPRESSxDEV)))))
                // DO; (2862)
                {
                rs1s3s2s1:;
                  // CURRENT_RECORD = INPUT(INPUT_DEV); (2863)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = INPUT (COREHALFWORD (mINPUT_DEV));
                    putCHARACTER (mDECOMPRESSxCURRENT_RECORD, stringRHS);
                    stringRHS->inUse = 0;
                  }
                  // INPUT_REC(DEV) = CURRENT_RECORD; (2864)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = getCHARACTER (mDECOMPRESSxCURRENT_RECORD);
                    putCHARACTER (mINPUT_REC
                                      + 4 * (COREHALFWORD (mDECOMPRESSxDEV)),
                                  stringRHS);
                    stringRHS->inUse = 0;
                  }
                  // INPUT_PTR = 2; (2865)
                  {
                    int32_t numberRHS = (int32_t)(2);
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mDECOMPRESSxINPUT_PTR, bitRHS);
                    bitRHS->inUse = 0;
                  }
                es1s3s2s1:;
                } // End of DO block
              // J = BYTE(CURRENT_RECORD, INPUT_PTR); (2866)
              {
                int32_t numberRHS = (int32_t)(BYTE (
                    getCHARACTER (mDECOMPRESSxCURRENT_RECORD),
                    COREHALFWORD (mDECOMPRESSxINPUT_PTR)));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mDECOMPRESSxJ, bitRHS);
                bitRHS->inUse = 0;
              }
              // DO OUT_REC_PTR = OUT_REC_PTR TO OUT_REC_PTR + (CNTL_BYTE & 63)
              // + 1; (2867)
              {
                int32_t from57, to57, by57;
                from57 = bitToFixed (getBIT (16, mDECOMPRESSxOUT_REC_PTR));
                to57 = xadd (xadd (COREHALFWORD (mDECOMPRESSxOUT_REC_PTR),
                                   xAND (BYTE0 (mDECOMPRESSxCNTL_BYTE), 63)),
                             1);
                by57 = 1;
                for (putBIT (16, mDECOMPRESSxOUT_REC_PTR,
                             fixedToBit (16, from57));
                     bitToFixed (getBIT (16, mDECOMPRESSxOUT_REC_PTR)) <= to57;
                     putBIT (16, mDECOMPRESSxOUT_REC_PTR,
                             fixedToBit (16, bitToFixed (getBIT (
                                                 16, mDECOMPRESSxOUT_REC_PTR))
                                                 + by57)))
                  {
                    // BYTE(RECRD, OUT_REC_PTR) = J; (2868)
                    {
                      descriptor_t *bitRHS = getBIT (16, mDECOMPRESSxJ);
                      lBYTEb (ADDR (NULL, 0, "DECOMPRESSxRECRD", 0),
                              COREHALFWORD (mDECOMPRESSxOUT_REC_PTR),
                              COREHALFWORD (mDECOMPRESSxJ));
                      bitRHS->inUse = 0;
                    }
                  }
              } // End of DO for-loop block
              // INPUT_PTR = INPUT_PTR + 1; (2869)
              {
                int32_t numberRHS = (int32_t)(xadd (
                    COREHALFWORD (mDECOMPRESSxINPUT_PTR), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mDECOMPRESSxINPUT_PTR, bitRHS);
                bitRHS->inUse = 0;
              }
            es1s3s2:;
            } // End of DO block
        es1s3:;
        } // End of DO block
    }     // End of DO WHILE block
  // IN_REC_PTR(DEV) = INPUT_PTR; (2870)
  {
    descriptor_t *bitRHS = getBIT (16, mDECOMPRESSxINPUT_PTR);
    putBIT (16, mDECOMPRESSxIN_REC_PTR + 2 * (COREHALFWORD (mDECOMPRESSxDEV)),
            bitRHS);
    bitRHS->inUse = 0;
  }
  // RETURN SUBSTR(X1 || RECRD, 1, LRECL(DEV) + 1); (2871)
  {
    reentryGuard = 0;
    return SUBSTR (
        xsCAT (getCHARACTER (mX1), getCHARACTER (mDECOMPRESSxRECRD)), 1,
        xadd (COREHALFWORD (mLRECL + 2 * COREHALFWORD (mDECOMPRESSxDEV)), 1));
  }
}
