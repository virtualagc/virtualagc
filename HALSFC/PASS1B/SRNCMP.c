/*
  File SRNCMP.c generated by XCOM-I, 2024-08-08 04:33:34.
*/

#include "runtimeC.h"

descriptor_t *
SRNCMP (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SRNCMP");
  // IF NO_MORE_SOURCE THEN (1531)
  if (1 & (bitToFixed (getBIT (1, mNO_MORE_SOURCE))))
    // RETURN 2; (1532)
    {
      reentryGuard = 0;
      return fixedToBit (32, (int32_t)(2));
    }
  // DO I=1 TO LIMIT; (1533)
  {
    int32_t from28, to28, by28;
    from28 = 1;
    to28 = 6;
    by28 = 1;
    for (putBIT (16, mSRNCMPxI, fixedToBit (16, from28));
         bitToFixed (getBIT (16, mSRNCMPxI)) <= to28;
         putBIT (16, mSRNCMPxI,
                 fixedToBit (16, bitToFixed (getBIT (16, mSRNCMPxI)) + by28)))
      {
        // BYTE1=BYTE(TEXT1,I-1)-BYTE('0'); (1534)
        {
          int32_t numberRHS = (int32_t)(xsubtract (
              BYTE (getCHARACTER (mSRNCMPxTEXT1),
                    xsubtract (COREHALFWORD (mSRNCMPxI), 1)),
              BYTE1 (cToDescriptor (NULL, "0"))));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mSRNCMPxBYTE1, bitRHS);
          bitRHS->inUse = 0;
        }
        // BYTE2=BYTE(TEXT2,I-1)-BYTE('0'); (1535)
        {
          int32_t numberRHS = (int32_t)(xsubtract (
              BYTE (getCHARACTER (mSRNCMPxTEXT2),
                    xsubtract (COREHALFWORD (mSRNCMPxI), 1)),
              BYTE1 (cToDescriptor (NULL, "0"))));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mSRNCMPxBYTE2, bitRHS);
          bitRHS->inUse = 0;
        }
        // IF BYTE1<BYTE2 THEN (1536)
        if (1
            & (xLT (COREHALFWORD (mSRNCMPxBYTE1),
                    COREHALFWORD (mSRNCMPxBYTE2))))
          // RETURN 1; (1537)
          {
            reentryGuard = 0;
            return fixedToBit (32, (int32_t)(1));
          }
        // IF BYTE1>BYTE2 THEN (1538)
        if (1
            & (xGT (COREHALFWORD (mSRNCMPxBYTE1),
                    COREHALFWORD (mSRNCMPxBYTE2))))
          // RETURN 2; (1539)
          {
            reentryGuard = 0;
            return fixedToBit (32, (int32_t)(2));
          }
      }
  } // End of DO for-loop block
  // RETURN 0; (1540)
  {
    reentryGuard = 0;
    return fixedToBit (32, (int32_t)(0));
  }
}
