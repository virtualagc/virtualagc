/*
  File SCAN_INITIAL_LISTxFIND_GCD.c generated by XCOM-I, 2024-08-08 04:31:35.
*/

#include "runtimeC.h"

descriptor_t *
SCAN_INITIAL_LISTxFIND_GCD (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "SCAN_INITIAL_LISTxFIND_GCD");
  // IF ARG1 = 0 THEN (1764)
  if (1 & (xEQ (COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG1), 0)))
    // RETURN ARG2; (1765)
    {
      reentryGuard = 0;
      return getBIT (16, mSCAN_INITIAL_LISTxFIND_GCDxARG2);
    }
  // IF ARG2 = 0 THEN (1766)
  if (1 & (xEQ (COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG2), 0)))
    // RETURN ARG1; (1767)
    {
      reentryGuard = 0;
      return getBIT (16, mSCAN_INITIAL_LISTxFIND_GCDxARG1);
    }
  // IF ARG1 = 1 | ARG2 = 1 THEN (1768)
  if (1
      & (xOR (xEQ (COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG1), 1),
              xEQ (COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG2), 1))))
    // RETURN 1; (1769)
    {
      reentryGuard = 0;
      return fixedToBit (32, (int32_t)(1));
    }
  // DO FOREVER; (1770)
  while (1 & (1))
    {
      // IF ARG1 < ARG2 THEN (1771)
      if (1
          & (xLT (COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG1),
                  COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG2))))
        // ARG2 = ARG2 - ARG1; (1772)
        {
          int32_t numberRHS = (int32_t)(xsubtract (
              COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG2),
              COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG1)));
          descriptor_t *bitRHS;
          bitRHS = fixedToBit (32, (int32_t)(numberRHS));
          putBIT (16, mSCAN_INITIAL_LISTxFIND_GCDxARG2, bitRHS);
          bitRHS->inUse = 0;
        }
      // ELSE (1773)
      else
        // IF ARG1 > ARG2 THEN (1774)
        if (1
            & (xGT (COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG1),
                    COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG2))))
          // ARG1 = ARG1 - ARG2; (1775)
          {
            int32_t numberRHS = (int32_t)(xsubtract (
                COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG1),
                COREHALFWORD (mSCAN_INITIAL_LISTxFIND_GCDxARG2)));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mSCAN_INITIAL_LISTxFIND_GCDxARG1, bitRHS);
            bitRHS->inUse = 0;
          }
        // ELSE (1776)
        else
          // RETURN ARG1; (1777)
          {
            reentryGuard = 0;
            return getBIT (16, mSCAN_INITIAL_LISTxFIND_GCDxARG1);
          }
    } // End of DO WHILE block
  {
    reentryGuard = 0;
    return 0;
  }
}
