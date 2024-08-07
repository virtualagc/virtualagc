/*
  File PASS2xGEN_AUXMAT_END.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
PASS2xGEN_AUXMAT_END (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PASS2xGEN_AUXMAT_END");
  // CALL GEN_AUXRATOR(MAX_POS, 0, 0, AUXMAT_END_OPCODE); (2541)
  {
    putBITp (16, mPASS2xGEN_AUXRATORxHALMATp,
             fixedToBit (32, (int32_t)(32767)));
    putBITp (5, mPASS2xGEN_AUXRATORxPTR_TYPE_VALUE,
             fixedToBit (32, (int32_t)(0)));
    putBITp (6, mPASS2xGEN_AUXRATORxTAGS_VALUE, fixedToBit (32, (int32_t)(0)));
    putBITp (4, mPASS2xGEN_AUXRATORxOPCODE, fixedToBit (32, (int32_t)(6)));
    PASS2xGEN_AUXRATOR (0);
  }
  // CALL GEN_AUXRAND(0, 0); (2542)
  {
    putBITp (16, mPASS2xGEN_AUXRANDxNOOSE_VALUE,
             fixedToBit (32, (int32_t)(0)));
    putBITp (16, mPASS2xGEN_AUXRANDxPTR_VALUE, fixedToBit (32, (int32_t)(0)));
    PASS2xGEN_AUXRAND (0);
  }
  // IF AUXMAT_PTR ~= 0 THEN (2543)
  if (1 & (xNEQ (COREHALFWORD (mAUXMAT_PTR), 0)))
    // DO; (2544)
    {
    rs1:;
      // IF PRETTY_PRINT_REQUESTED THEN (2545)
      if (1 & (bitToFixed (getBIT (1, mPRETTY_PRINT_REQUESTED))))
        // CALL PRETTY_PRINT_MAT; (2546)
        PRETTY_PRINT_MAT (0);
      // FILE(AUXMAT_FILE, CURR_AUXMAT_BLOCK) = AUXMAT; (2547)
      {
        lFILE (BYTE0 (mAUXMAT_FILE), COREHALFWORD (mCURR_AUXMAT_BLOCK),
               ADDR (NULL, 0, "AUXMAT", 0));
      }
    es1:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
