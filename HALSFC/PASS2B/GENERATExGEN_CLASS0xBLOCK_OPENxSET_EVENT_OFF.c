/*
  File GENERATExGEN_CLASS0xBLOCK_OPENxSET_EVENT_OFF.c generated by XCOM-I,
  2024-08-08 04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xBLOCK_OPENxSET_EVENT_OFF (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard,
                               "GENERATExGEN_CLASS0xBLOCK_OPENxSET_EVENT_OFF");
  // I = SHR(SYT_DIMS(PTR),8) &  255; (11883)
  {
    int32_t numberRHS = (int32_t)(xAND (
        SHR (COREHALFWORD (
                 getFIXED (mSYM_TAB)
                 + 34
                       * (COREHALFWORD (
                           mGENERATExGEN_CLASS0xBLOCK_OPENxSET_EVENT_OFFxPTR))
                 + 18 + 2 * (0)),
             8),
        255));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mGENERATExGEN_CLASS0xBLOCK_OPENxI, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF I ~= 0 THEN (11884)
  if (1 & (xNEQ (COREHALFWORD (mGENERATExGEN_CLASS0xBLOCK_OPENxI), 0)))
    // IF I ~=  255 THEN (11885)
    if (1 & (xNEQ (COREHALFWORD (mGENERATExGEN_CLASS0xBLOCK_OPENxI), 255)))
      // RETURN; (11886)
      {
        reentryGuard = 0;
        return 0;
      }
  // CALL SET_LOCCTR(INITBASE, IADDR); (11887)
  {
    putBITp (16, mSET_LOCCTRxNEST, getBIT (16, mGENERATExINITBASE));
    putFIXED (mSET_LOCCTRxVALUE,
              getFIXED (mGENERATExGEN_CLASS0xBLOCK_OPENxSET_EVENT_OFFxIADDR));
    SET_LOCCTR (0);
  }
  // DO CASE OPMODE(SYT_TYPE(PTR)); (11888)
  {
  rs1:
    switch (BYTE0 (
        mOPMODE
        + 1
              * BYTE0 (
                  getFIXED (mSYM_TAB)
                  + 34
                        * (COREHALFWORD (
                            mGENERATExGEN_CLASS0xBLOCK_OPENxSET_EVENT_OFFxPTR))
                  + 32 + 1 * (0))))
      {
      case 0:
          // ; (11890)
          ;
        break;
      case 1:
        // DO I = 1 TO LUMP_ARRAYSIZE(PTR); (11891)
        {
          int32_t from116, to116, by116;
          from116 = 1;
          to116 = (putBITp (
                       16, mGENERATExLUMP_ARRAYSIZExOP,
                       getBIT (
                           16,
                           mGENERATExGEN_CLASS0xBLOCK_OPENxSET_EVENT_OFFxPTR)),
                   GENERATExLUMP_ARRAYSIZE (0));
          by116 = 1;
          for (putBIT (16, mGENERATExGEN_CLASS0xBLOCK_OPENxI,
                       fixedToBit (16, from116));
               bitToFixed (getBIT (16, mGENERATExGEN_CLASS0xBLOCK_OPENxI))
               <= to116;
               putBIT (
                   16, mGENERATExGEN_CLASS0xBLOCK_OPENxI,
                   fixedToBit (16, bitToFixed (getBIT (
                                       16, mGENERATExGEN_CLASS0xBLOCK_OPENxI))
                                       + by116)))
            {
              // CALL EMITC(0, 0); (11891)
              {
                putBITp (16, mEMITCxTYPE, fixedToBit (32, (int32_t)(0)));
                putBITp (16, mEMITCxINST, fixedToBit (32, (int32_t)(0)));
                EMITC (0);
              }
            }
        } // End of DO for-loop block
        break;
      case 2:
        // DO; (11893)
        {
        rs1s2:;
          // I = LUMP_ARRAYSIZE(PTR); (11893)
          {
            int32_t numberRHS = (int32_t)((
                putBITp (
                    16, mGENERATExLUMP_ARRAYSIZExOP,
                    getBIT (
                        16,
                        mGENERATExGEN_CLASS0xBLOCK_OPENxSET_EVENT_OFFxPTR)),
                GENERATExLUMP_ARRAYSIZE (0)));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mGENERATExGEN_CLASS0xBLOCK_OPENxI, bitRHS);
            bitRHS->inUse = 0;
          }
          // CALL EMITC(DATABLK, I); (11894)
          {
            putBITp (16, mEMITCxTYPE, getBIT (8, mDATABLK));
            putBITp (16, mEMITCxINST,
                     getBIT (16, mGENERATExGEN_CLASS0xBLOCK_OPENxI));
            EMITC (0);
          }
          // DO I = 1 TO I; (11895)
          {
            int32_t from117, to117, by117;
            from117 = 1;
            to117
                = bitToFixed (getBIT (16, mGENERATExGEN_CLASS0xBLOCK_OPENxI));
            by117 = 1;
            for (putBIT (16, mGENERATExGEN_CLASS0xBLOCK_OPENxI,
                         fixedToBit (16, from117));
                 bitToFixed (getBIT (16, mGENERATExGEN_CLASS0xBLOCK_OPENxI))
                 <= to117;
                 putBIT (16, mGENERATExGEN_CLASS0xBLOCK_OPENxI,
                         fixedToBit (
                             16, bitToFixed (getBIT (
                                     16, mGENERATExGEN_CLASS0xBLOCK_OPENxI))
                                     + by117)))
              {
                // CALL EMITW(0); (11896)
                {
                  putFIXED (mEMITWxDATA, 0);
                  EMITW (0);
                }
              }
          } // End of DO for-loop block
        es1s2:;
        } // End of DO block
        break;
      }
  } // End of DO CASE block
  {
    reentryGuard = 0;
    return 0;
  }
}
