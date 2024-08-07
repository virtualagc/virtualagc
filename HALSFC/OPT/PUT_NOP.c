/*
  File PUT_NOP.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
PUT_NOP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PUT_NOP");
  // IF WATCH THEN (4161)
  if (1 & (bitToFixed (getBIT (8, mWATCH))))
    // OUTPUT = 'PUT_NOP: ' || PTR; (4162)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (cToDescriptor (NULL, "PUT_NOP: "),
                         bitToCharacter (getBIT (16, mPUT_NOPxPTR)));
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // HALMAT_NODE_START = PTR; (4163)
  {
    descriptor_t *bitRHS = getBIT (16, mPUT_NOPxPTR);
    putBIT (16, mHALMAT_NODE_START, bitRHS);
    bitRHS->inUse = 0;
  }
  // A_INX = 1; (4164)
  {
    int32_t numberRHS = (int32_t)(1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mA_INX, bitRHS);
    bitRHS->inUse = 0;
  }
  // ADD(1) = PTR; (4165)
  {
    descriptor_t *bitRHS = getBIT (16, mPUT_NOPxPTR);
    putBIT (16, mADD + 2 * (1), bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE A_INX ~= 0; (4166)
  while (1 & (xNEQ (COREHALFWORD (mA_INX), 0)))
    {
      // TEMP = ADD(A_INX); (4167)
      {
        descriptor_t *bitRHS = getBIT (16, mADD + 2 * COREHALFWORD (mA_INX));
        putBIT (16, mPUT_NOPxTEMP, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF TEMP < HALMAT_NODE_START THEN (4168)
      if (1
          & (xLT (COREHALFWORD (mPUT_NOPxTEMP),
                  COREHALFWORD (mHALMAT_NODE_START))))
        // HALMAT_NODE_START = TEMP; (4169)
        {
          descriptor_t *bitRHS = getBIT (16, mPUT_NOPxTEMP);
          putBIT (16, mHALMAT_NODE_START, bitRHS);
          bitRHS->inUse = 0;
        }
      // A_INX = A_INX -1; (4170)
      {
        int32_t numberRHS = (int32_t)(xsubtract (COREHALFWORD (mA_INX), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mA_INX, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF OPTYPE = CLASSIFY(TEMP) OR TWIN_MATCH THEN (4171)
      if (1
          & (xOR (xEQ (COREHALFWORD (mOPTYPE),
                       bitToFixed ((putBITp (16, mCLASSIFYxPTR,
                                             getBIT (16, mPUT_NOPxTEMP)),
                                    CLASSIFY (0)))),
                  BYTE0 (mTWIN_MATCH))))
        // DO FOR I = TEMP + 1 TO TEMP + NO_OPERANDS(TEMP); (4172)
        {
          int32_t from97, to97, by97;
          from97 = xadd (COREHALFWORD (mPUT_NOPxTEMP), 1);
          to97 = xadd (COREHALFWORD (mPUT_NOPxTEMP),
                       bitToFixed ((putBITp (16, mNO_OPERANDSxPTR,
                                             getBIT (16, mPUT_NOPxTEMP)),
                                    NO_OPERANDS (0))));
          by97 = 1;
          for (putBIT (16, mPUT_NOPxI, fixedToBit (16, from97));
               bitToFixed (getBIT (16, mPUT_NOPxI)) <= to97;
               putBIT (16, mPUT_NOPxI,
                       fixedToBit (16, bitToFixed (getBIT (16, mPUT_NOPxI))
                                           + by97)))
            {
              // IF ~TERMINAL(I) THEN (4173)
              if (1
                  & (xNOT (bitToFixed (
                      (putBITp (16, mTERMINALxPTR, getBIT (16, mPUT_NOPxI)),
                       TERMINAL (0))))))
                // DO; (4174)
                {
                rs1s1s1:;
                  // POINT = SHR(OPR(I),16); (4175)
                  {
                    int32_t numberRHS = (int32_t)(SHR (
                        getFIXED (mOPR + 4 * COREHALFWORD (mPUT_NOPxI)), 16));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mPUT_NOPxPOINT, bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // IF CLASSIFY(POINT) = TSUB THEN (4176)
                  if (1
                      & (xEQ (
                          bitToFixed ((putBITp (16, mCLASSIFYxPTR,
                                                getBIT (16, mPUT_NOPxPOINT)),
                                       CLASSIFY (0))),
                          COREHALFWORD (mTSUB))))
                    // DO; (4177)
                    {
                    rs1s1s1s1:;
                      // OPR(POINT) = OPR(POINT) &  16711680; (4178)
                      {
                        int32_t numberRHS = (int32_t)(xAND (
                            getFIXED (mOPR
                                      + 4 * COREHALFWORD (mPUT_NOPxPOINT)),
                            16711680));
                        putFIXED (mOPR + 4 * (COREHALFWORD (mPUT_NOPxPOINT)),
                                  numberRHS);
                      }
                      // POINT = POINT + 1; (4179)
                      {
                        int32_t numberRHS = (int32_t)(xadd (
                            COREHALFWORD (mPUT_NOPxPOINT), 1));
                        descriptor_t *bitRHS;
                        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                        putBIT (16, mPUT_NOPxPOINT, bitRHS);
                        bitRHS->inUse = 0;
                      }
                      // DO WHILE OPR(POINT); (4180)
                      while (1
                             & (getFIXED (
                                 mOPR + 4 * COREHALFWORD (mPUT_NOPxPOINT))))
                        {
                          // OPR(POINT) = 0; (4181)
                          {
                            int32_t numberRHS = (int32_t)(0);
                            putFIXED (
                                mOPR + 4 * (COREHALFWORD (mPUT_NOPxPOINT)),
                                numberRHS);
                          }
                          // POINT = POINT + 1; (4182)
                          {
                            int32_t numberRHS = (int32_t)(xadd (
                                COREHALFWORD (mPUT_NOPxPOINT), 1));
                            descriptor_t *bitRHS;
                            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                            putBIT (16, mPUT_NOPxPOINT, bitRHS);
                            bitRHS->inUse = 0;
                          }
                        } // End of DO WHILE block
                    es1s1s1s1:;
                    } // End of DO block
                  // A_INX = A_INX + 1; (4183)
                  {
                    int32_t numberRHS
                        = (int32_t)(xadd (COREHALFWORD (mA_INX), 1));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mA_INX, bitRHS);
                    bitRHS->inUse = 0;
                  }
                  // ADD(A_INX) = SHR(OPR(I),16); (4184)
                  {
                    int32_t numberRHS = (int32_t)(SHR (
                        getFIXED (mOPR + 4 * COREHALFWORD (mPUT_NOPxI)), 16));
                    descriptor_t *bitRHS;
                    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                    putBIT (16, mADD + 2 * (COREHALFWORD (mA_INX)), bitRHS);
                    bitRHS->inUse = 0;
                  }
                es1s1s1:;
                } // End of DO block
              // OPR(I) = 0; (4185)
              {
                int32_t numberRHS = (int32_t)(0);
                putFIXED (mOPR + 4 * (COREHALFWORD (mPUT_NOPxI)), numberRHS);
              }
            }
        } // End of DO for-loop block
      // OPR(TEMP) = OPR(TEMP) &  16711680; (4186)
      {
        int32_t numberRHS = (int32_t)(xAND (
            getFIXED (mOPR + 4 * COREHALFWORD (mPUT_NOPxTEMP)), 16711680));
        putFIXED (mOPR + 4 * (COREHALFWORD (mPUT_NOPxTEMP)), numberRHS);
      }
      // IF NONCOMMUTATIVE THEN (4187)
      if (1 & (bitToFixed (getBIT (8, mNONCOMMUTATIVE))))
        // RETURN; (4188)
        {
          reentryGuard = 0;
          return 0;
        }
    } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
