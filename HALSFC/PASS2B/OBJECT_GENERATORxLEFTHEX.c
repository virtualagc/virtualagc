/*
  File OBJECT_GENERATORxLEFTHEX.c generated by XCOM-I, 2024-08-08 04:34:25.
*/

#include "runtimeC.h"

descriptor_t *
OBJECT_GENERATORxLEFTHEX (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "OBJECT_GENERATORxLEFTHEX");
  // K = 0; (15053)
  {
    int32_t numberRHS = (int32_t)(0);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOBJECT_GENERATORxLEFTHEXxK, bitRHS);
    bitRHS->inUse = 0;
  }
  // SHIFTCOUNT=28; (15054)
  {
    int32_t numberRHS = (int32_t)(28);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mOBJECT_GENERATORxSHIFTCOUNT, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE N>0; (15055)
  while (1 & (xGT (COREHALFWORD (mOBJECT_GENERATORxLEFTHEXxN), 0)))
    {
      // B=BYTE(HEXCODES,SHR(F,SHIFTCOUNT)&FONE); (15056)
      {
        int32_t numberRHS = (int32_t)(BYTE (
            getCHARACTER (mHEXCODES),
            xAND (SHR (getFIXED (mOBJECT_GENERATORxLEFTHEXxF),
                       COREHALFWORD (mOBJECT_GENERATORxSHIFTCOUNT)),
                  getFIXED (mOBJECT_GENERATORxFONE))));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxLEFTHEXxB, bitRHS);
        bitRHS->inUse = 0;
      }
      // BYTE(SS,K)=B; (15057)
      {
        descriptor_t *bitRHS = getBIT (16, mOBJECT_GENERATORxLEFTHEXxB);
        lBYTEb (ADDR (NULL, 0, "OBJECT_GENERATORxLEFTHEXxSS", 0),
                COREHALFWORD (mOBJECT_GENERATORxLEFTHEXxK),
                COREHALFWORD (mOBJECT_GENERATORxLEFTHEXxB));
        bitRHS->inUse = 0;
      }
      // K=K+1; (15058)
      {
        int32_t numberRHS
            = (int32_t)(xadd (COREHALFWORD (mOBJECT_GENERATORxLEFTHEXxK), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxLEFTHEXxK, bitRHS);
        bitRHS->inUse = 0;
      }
      // N=N-1; (15059)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            COREHALFWORD (mOBJECT_GENERATORxLEFTHEXxN), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxLEFTHEXxN, bitRHS);
        bitRHS->inUse = 0;
      }
      // SHIFTCOUNT=SHIFTCOUNT-4; (15060)
      {
        int32_t numberRHS = (int32_t)(xsubtract (
            COREHALFWORD (mOBJECT_GENERATORxSHIFTCOUNT), 4));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mOBJECT_GENERATORxSHIFTCOUNT, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // RETURN BLANK||SUBSTR(SS,0,K); (15061)
  {
    reentryGuard = 0;
    return xsCAT (getCHARACTER (mBLANK),
                  SUBSTR (getCHARACTER (mOBJECT_GENERATORxLEFTHEXxSS), 0,
                          COREHALFWORD (mOBJECT_GENERATORxLEFTHEXxK)));
  }
}
