/*
  File GENERATExGEN_CLASS0xCLEAR_STMT_REGS.c generated by XCOM-I, 2024-08-08
  04:34:25.
*/

#include "runtimeC.h"

int32_t
GENERATExGEN_CLASS0xCLEAR_STMT_REGS (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "GENERATExGEN_CLASS0xCLEAR_STMT_REGS");
  // DO I = 0 TO REG_NUM; (10828)
  {
    int32_t from110, to110, by110;
    from110 = 0;
    to110 = 15;
    by110 = 1;
    for (putBIT (16, mGENERATExGEN_CLASS0xCLEAR_STMT_REGSxI,
                 fixedToBit (16, from110));
         bitToFixed (getBIT (16, mGENERATExGEN_CLASS0xCLEAR_STMT_REGSxI))
         <= to110;
         putBIT (
             16, mGENERATExGEN_CLASS0xCLEAR_STMT_REGSxI,
             fixedToBit (16, bitToFixed (getBIT (
                                 16, mGENERATExGEN_CLASS0xCLEAR_STMT_REGSxI))
                                 + by110)))
      {
        // IF USAGE(I) THEN (10829)
        if (1
            & (bitToFixed (getBIT (
                16, mUSAGE
                        + 2
                              * COREHALFWORD (
                                  mGENERATExGEN_CLASS0xCLEAR_STMT_REGSxI)))))
          // IF R_CONTENTS(I) = IMD THEN (10830)
          if (1
              & (xEQ (
                  BYTE0 (mR_CONTENTS
                         + 1
                               * COREHALFWORD (
                                   mGENERATExGEN_CLASS0xCLEAR_STMT_REGSxI)),
                  BYTE0 (mIMD))))
            // CALL UNRECOGNIZABLE(I); (10831)
            {
              putBITp (16, mGENERATExUNRECOGNIZABLExR,
                       getBIT (16, mGENERATExGEN_CLASS0xCLEAR_STMT_REGSxI));
              GENERATExUNRECOGNIZABLE (0);
            }
      }
  } // End of DO for-loop block
  {
    reentryGuard = 0;
    return 0;
  }
}
