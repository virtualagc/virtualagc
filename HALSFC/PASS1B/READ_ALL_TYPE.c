/*
  File READ_ALL_TYPE.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

descriptor_t *
READ_ALL_TYPE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "READ_ALL_TYPE");
  // IF PSEUDO_TYPE(PTR(P))=MAJ_STRUC THEN (7448)
  if (1
      & (xEQ (
          BYTE0 (
              mPSEUDO_TYPE
              + 1 * COREHALFWORD (mPTR + 2 * COREHALFWORD (mREAD_ALL_TYPExP))),
          10)))
    // DO; (7449)
    {
    rs1:;
      // I=FIXL(P); (7450)
      {
        int32_t numberRHS = (int32_t)(getFIXED (
            mFIXL + 4 * COREHALFWORD (mREAD_ALL_TYPExP)));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mREAD_ALL_TYPExI, bitRHS);
        bitRHS->inUse = 0;
      }
      // IF (SYT_FLAGS(VAR_LENGTH(FIXV(P)))&EVIL_FLAG)~=0 THEN (7451)
      if (1
          & (xNEQ (
              xAND (getFIXED (getFIXED (mSYM_TAB)
                              + 34
                                    * (COREHALFWORD (
                                        getFIXED (mSYM_TAB)
                                        + 34
                                              * (getFIXED (
                                                  mFIXV
                                                  + 4
                                                        * COREHALFWORD (
                                                            mREAD_ALL_TYPExP)))
                                        + 18 + 2 * (0)))
                              + 8 + 4 * (0)),
                    2097152),
              0)))
        // RETURN 0; (7452)
        {
          reentryGuard = 0;
          return fixedToBit (32, (int32_t)(0));
        }
      // DO FOREVER; (7453)
      while (1 & (1))
        {
          // DO WHILE SYT_LINK1(I)~=0; (7454)
          while (
              1
              & (xNEQ (COREHALFWORD (getFIXED (mSYM_TAB)
                                     + 34 * (COREHALFWORD (mREAD_ALL_TYPExI))
                                     + 24 + 2 * (0)),
                       0)))
            {
              // I=SYT_LINK1(I); (7455)
              {
                descriptor_t *bitRHS
                    = getBIT (16, getFIXED (mSYM_TAB)
                                      + 34 * (COREHALFWORD (mREAD_ALL_TYPExI))
                                      + 24 + 2 * (0));
                putBIT (16, mREAD_ALL_TYPExI, bitRHS);
                bitRHS->inUse = 0;
              }
            } // End of DO WHILE block
          // IF SYT_TYPE(I)~=CHAR_TYPE THEN (7456)
          if (1
              & (xNEQ (BYTE0 (getFIXED (mSYM_TAB)
                              + 34 * (COREHALFWORD (mREAD_ALL_TYPExI)) + 32
                              + 1 * (0)),
                       2)))
            // RETURN 1; (7457)
            {
              reentryGuard = 0;
              return fixedToBit (32, (int32_t)(1));
            }
          // DO WHILE SYT_LINK2(I)<0; (7458)
          while (1
                 & (xLT (COREHALFWORD (getFIXED (mSYM_TAB)
                                       + 34 * (COREHALFWORD (mREAD_ALL_TYPExI))
                                       + 26 + 2 * (0)),
                         0)))
            {
              // I=-SYT_LINK2(I); (7459)
              {
                int32_t numberRHS = (int32_t)(xminus (COREHALFWORD (
                    getFIXED (mSYM_TAB)
                    + 34 * (COREHALFWORD (mREAD_ALL_TYPExI)) + 26 + 2 * (0))));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mREAD_ALL_TYPExI, bitRHS);
                bitRHS->inUse = 0;
              }
              // IF I=FIXL(P) THEN (7460)
              if (1
                  & (xEQ (
                      COREHALFWORD (mREAD_ALL_TYPExI),
                      getFIXED (mFIXL + 4 * COREHALFWORD (mREAD_ALL_TYPExP)))))
                // RETURN 0; (7461)
                {
                  reentryGuard = 0;
                  return fixedToBit (32, (int32_t)(0));
                }
            } // End of DO WHILE block
          // I=SYT_LINK2(I); (7462)
          {
            descriptor_t *bitRHS
                = getBIT (16, getFIXED (mSYM_TAB)
                                  + 34 * (COREHALFWORD (mREAD_ALL_TYPExI)) + 26
                                  + 2 * (0));
            putBIT (16, mREAD_ALL_TYPExI, bitRHS);
            bitRHS->inUse = 0;
          }
        } // End of DO WHILE block
    es1:;
    } // End of DO block
  // ELSE (7463)
  else
    // RETURN PSEUDO_TYPE(PTR(P))~=CHAR_TYPE; (7464)
    {
      reentryGuard = 0;
      return fixedToBit (
          32,
          (int32_t)(xNEQ (
              BYTE0 (mPSEUDO_TYPE
                     + 1
                           * COREHALFWORD (
                               mPTR + 2 * COREHALFWORD (mREAD_ALL_TYPExP))),
              2)));
    }
}
