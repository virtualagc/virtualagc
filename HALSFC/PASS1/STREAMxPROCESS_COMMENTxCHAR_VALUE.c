/*
  File STREAMxPROCESS_COMMENTxCHAR_VALUE.c generated by XCOM-I, 2024-08-08
  04:31:11.
*/

#include "runtimeC.h"

int32_t
STREAMxPROCESS_COMMENTxCHAR_VALUE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "STREAMxPROCESS_COMMENTxCHAR_VALUE");
  // J, VAL=0; (4452)
  {
    int32_t numberRHS = (int32_t)(0);
    putFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExJ, numberRHS);
    putFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExVAL, numberRHS);
  }
  // DO WHILE J < LENGTH(STR); (4453)
  while (
      1
      & (xLT (getFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExJ),
              LENGTH (getCHARACTER (mSTREAMxPROCESS_COMMENTxCHAR_VALUExSTR)))))
    {
      // K = BYTE(STR, J); (4454)
      {
        int32_t numberRHS = (int32_t)(BYTE (
            getCHARACTER (mSTREAMxPROCESS_COMMENTxCHAR_VALUExSTR),
            getFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExJ)));
        putFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExK, numberRHS);
      }
      // IF (K >= BYTE('0')) & (K <= BYTE('9')) THEN (4455)
      if (1
          & (xAND (xGE (getFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExK),
                        BYTE1 (cToDescriptor (NULL, "0"))),
                   xLE (getFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExK),
                        BYTE1 (cToDescriptor (NULL, "9"))))))
        // VAL = VAL * 10 + (K - BYTE('0')); (4456)
        {
          int32_t numberRHS = (int32_t)(xadd (
              xmultiply (getFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExVAL),
                         10),
              xsubtract (getFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExK),
                         BYTE1 (cToDescriptor (NULL, "0")))));
          putFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExVAL, numberRHS);
        }
      // J = J + 1; (4457)
      {
        int32_t numberRHS = (int32_t)(xadd (
            getFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExJ), 1));
        putFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExJ, numberRHS);
      }
    } // End of DO WHILE block
  // RETURN VAL; (4458)
  {
    reentryGuard = 0;
    return getFIXED (mSTREAMxPROCESS_COMMENTxCHAR_VALUExVAL);
  }
}
