/*
  File PASS1xCLASS_0xCLASS_05.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
PASS1xCLASS_0xCLASS_05 (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PASS1xCLASS_0xCLASS_05");
  // DO CASE OPCODE_CASE_DECODE(HALRATOR &  15); (2492)
  {
  rs1:
    switch (BYTE0 (mPASS1xCLASS_0xCLASS_05xOPCODE_CASE_DECODE
                   + 1 * xAND (COREHALFWORD (mHALRATOR), 15)))
      {
      case 0:
          // ; (2494)
          ;
        break;
      case 1:
        // CALL PUSH_BLOCK_FRAME; (2495)
        PASS1xPUSH_BLOCK_FRAME (0);
        break;
      case 2:
        // CALL POP_BLOCK_FRAME; (2496)
        PASS1xPOP_BLOCK_FRAME (0);
        break;
      case 3:
        // CALL FLUSH_INFO; (2497)
        PASS1xFLUSH_INFO (0);
        break;
      }
  } // End of DO CASE block
  {
    reentryGuard = 0;
    return 0;
  }
}
