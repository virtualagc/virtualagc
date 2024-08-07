/*
  File GET_FREE_SPACE.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

descriptor_t *
GET_FREE_SPACE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GET_FREE_SPACE");
  // DO INDEX=0 TO LAST_SPACE_BLOCK; (1518)
  {
    int32_t from33, to33, by33;
    from33 = 0;
    to33 = bitToFixed (getBIT (16, mLAST_SPACE_BLOCK));
    by33 = 1;
    for (putBIT (16, mGET_FREE_SPACExINDEX, fixedToBit (16, from33));
         bitToFixed (getBIT (16, mGET_FREE_SPACExINDEX)) <= to33; putBIT (
             16, mGET_FREE_SPACExINDEX,
             fixedToBit (16, bitToFixed (getBIT (16, mGET_FREE_SPACExINDEX))
                                 + by33)))
      {
        // IF FREE_SPACE(INDEX)>=SPACE THEN (1519)
        if (1
            & (xGE (COREHALFWORD (mFREE_SPACE
                                  + 2 * COREHALFWORD (mGET_FREE_SPACExINDEX)),
                    COREHALFWORD (mGET_FREE_SPACExSPACE))))
          // DO; (1520)
          {
          rs1s1:;
            // BEGIN = FREE_BLOCK_BEGIN(INDEX); (1521)
            {
              descriptor_t *bitRHS = getBIT (
                  16, mFREE_BLOCK_BEGIN
                          + 2 * COREHALFWORD (mGET_FREE_SPACExINDEX));
              putBIT (16, mGET_FREE_SPACExBEGIN, bitRHS);
              bitRHS->inUse = 0;
            }
            // FREE_BLOCK_BEGIN(INDEX) = FREE_BLOCK_BEGIN(INDEX)+SPACE; (1522)
            {
              int32_t numberRHS = (int32_t)(xadd (
                  COREHALFWORD (mFREE_BLOCK_BEGIN
                                + 2 * COREHALFWORD (mGET_FREE_SPACExINDEX)),
                  COREHALFWORD (mGET_FREE_SPACExSPACE)));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16,
                      mFREE_BLOCK_BEGIN
                          + 2 * (COREHALFWORD (mGET_FREE_SPACExINDEX)),
                      bitRHS);
              bitRHS->inUse = 0;
            }
            // FREE_SPACE(INDEX) = FREE_SPACE(INDEX)-SPACE; (1523)
            {
              int32_t numberRHS = (int32_t)(xsubtract (
                  COREHALFWORD (mFREE_SPACE
                                + 2 * COREHALFWORD (mGET_FREE_SPACExINDEX)),
                  COREHALFWORD (mGET_FREE_SPACExSPACE)));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16,
                      mFREE_SPACE + 2 * (COREHALFWORD (mGET_FREE_SPACExINDEX)),
                      bitRHS);
              bitRHS->inUse = 0;
            }
            // RETURN BEGIN; (1524)
            {
              reentryGuard = 0;
              return getBIT (16, mGET_FREE_SPACExBEGIN);
            }
          es1s1:;
          } // End of DO block
      }
  } // End of DO for-loop block
  // CALL ERRORS (CLASS_BI, 308); (1525)
  {
    putBITp (16, mERRORSxCLASS, getBIT (16, mCLASS_BI));
    putBITp (16, mERRORSxNUM, fixedToBit (32, (int32_t)(308)));
    ERRORS (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
