/*
  File DUMP_VMEM_STATUS.c generated by XCOM-I, 2024-08-09 12:42:16.
*/

#include "runtimeC.h"

int32_t
DUMP_VMEM_STATUS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "DUMP_VMEM_STATUS");
  // DO I = 0 TO VMEM_LIM_PAGES; (758)
  {
    int32_t from23, to23, by23;
    from23 = 0;
    to23 = 2;
    by23 = 1;
    for (putBIT (8, mDUMP_VMEM_STATUSxI, fixedToBit (8, from23));
         bitToFixed (getBIT (8, mDUMP_VMEM_STATUSxI)) <= to23;
         putBIT (8, mDUMP_VMEM_STATUSxI,
                 fixedToBit (8, bitToFixed (getBIT (8, mDUMP_VMEM_STATUSxI))
                                    + by23)))
      {
        // FLAGS(I) = ''; (759)
        {
          descriptor_t *stringRHS;
          stringRHS = cToDescriptor (NULL, "");
          putCHARACTER (mDUMP_VMEM_STATUSxFLAGS
                            + 4 * (BYTE0 (mDUMP_VMEM_STATUSxI)),
                        stringRHS);
          stringRHS->inUse = 0;
        }
        // IF (VMEM_FLAGS_STATUS(I) & RESV) ~= 0 THEN (760)
        if (1
            & (xNEQ (xAND (BYTE0 (mVMEM_FLAGS_STATUS
                                  + 1 * BYTE0 (mDUMP_VMEM_STATUSxI)),
                           BYTE0 (mRESV)),
                     0)))
          // FLAGS(I) = ' RESV'; (761)
          {
            descriptor_t *stringRHS;
            stringRHS = cToDescriptor (NULL, " RESV");
            putCHARACTER (mDUMP_VMEM_STATUSxFLAGS
                              + 4 * (BYTE0 (mDUMP_VMEM_STATUSxI)),
                          stringRHS);
            stringRHS->inUse = 0;
          }
        // IF (VMEM_FLAGS_STATUS(I) & MODF) ~= 0 THEN (762)
        if (1
            & (xNEQ (xAND (BYTE0 (mVMEM_FLAGS_STATUS
                                  + 1 * BYTE0 (mDUMP_VMEM_STATUSxI)),
                           BYTE0 (mMODF)),
                     0)))
          // FLAGS(I) = FLAGS(I) || ' MODF'; (763)
          {
            descriptor_t *stringRHS;
            stringRHS
                = xsCAT (getCHARACTER (mDUMP_VMEM_STATUSxFLAGS
                                       + 4 * BYTE0 (mDUMP_VMEM_STATUSxI)),
                         cToDescriptor (NULL, " MODF"));
            putCHARACTER (mDUMP_VMEM_STATUSxFLAGS
                              + 4 * (BYTE0 (mDUMP_VMEM_STATUSxI)),
                          stringRHS);
            stringRHS->inUse = 0;
          }
        // IF (VMEM_FLAGS_STATUS(I) & RELS) ~= 0 THEN (764)
        if (1
            & (xNEQ (xAND (BYTE0 (mVMEM_FLAGS_STATUS
                                  + 1 * BYTE0 (mDUMP_VMEM_STATUSxI)),
                           BYTE0 (mRELS)),
                     0)))
          // FLAGS(I) = FLAGS(I) || ' RELS'; (765)
          {
            descriptor_t *stringRHS;
            stringRHS
                = xsCAT (getCHARACTER (mDUMP_VMEM_STATUSxFLAGS
                                       + 4 * BYTE0 (mDUMP_VMEM_STATUSxI)),
                         cToDescriptor (NULL, " RELS"));
            putCHARACTER (mDUMP_VMEM_STATUSxFLAGS
                              + 4 * (BYTE0 (mDUMP_VMEM_STATUSxI)),
                          stringRHS);
            stringRHS->inUse = 0;
          }
        // IF FLAGS(I) = '' THEN (766)
        if (1
            & (xsEQ (getCHARACTER (mDUMP_VMEM_STATUSxFLAGS
                                   + 4 * BYTE0 (mDUMP_VMEM_STATUSxI)),
                     cToDescriptor (NULL, ""))))
          // FLAGS(I) = ' NO FLAGS'; (767)
          {
            descriptor_t *stringRHS;
            stringRHS = cToDescriptor (NULL, " NO FLAGS");
            putCHARACTER (mDUMP_VMEM_STATUSxFLAGS
                              + 4 * (BYTE0 (mDUMP_VMEM_STATUSxI)),
                          stringRHS);
            stringRHS->inUse = 0;
          }
      }
  } // End of DO for-loop block
  // OUTPUT = 'POINTERS IN CORE:     FLAGS:'; (768)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "POINTERS IN CORE:     FLAGS:");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // DO I = 0 TO VMEM_LIM_PAGES; (769)
  {
    int32_t from24, to24, by24;
    from24 = 0;
    to24 = 2;
    by24 = 1;
    for (putBIT (8, mDUMP_VMEM_STATUSxI, fixedToBit (8, from24));
         bitToFixed (getBIT (8, mDUMP_VMEM_STATUSxI)) <= to24;
         putBIT (8, mDUMP_VMEM_STATUSxI,
                 fixedToBit (8, bitToFixed (getBIT (8, mDUMP_VMEM_STATUSxI))
                                    + by24)))
      {
        // OUTPUT = '         '||HEX8(VMEM_PTR_STATUS(I))||'     '||FLAGS(I);
        // (770)
        {
          descriptor_t *stringRHS;
          stringRHS = xsCAT (
              xsCAT (xsCAT (cToDescriptor (NULL, "         "),
                            (putFIXED (
                                 mHEX8xHVAL,
                                 getFIXED (mVMEM_PTR_STATUS
                                           + 4 * BYTE0 (mDUMP_VMEM_STATUSxI))),
                             HEX8 (0))),
                     cToDescriptor (NULL, "     ")),
              getCHARACTER (mDUMP_VMEM_STATUSxFLAGS
                            + 4 * BYTE0 (mDUMP_VMEM_STATUSxI)));
          OUTPUT (0, stringRHS);
          stringRHS->inUse = 0;
        }
      }
  } // End of DO for-loop block
  {
    reentryGuard = 0;
    return 0;
  }
}