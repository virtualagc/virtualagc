/*
  File REFERENCE.c generated by XCOM-I, 2024-08-08 04:34:00.
*/

#include "runtimeC.h"

descriptor_t *
REFERENCE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "REFERENCE");
  // OLD = PTR; (2945)
  {
    descriptor_t *bitRHS = getBIT (16, mREFERENCExPTR);
    putBIT (16, mREFERENCExOLD, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE (OPR(PTR) &  65521) ~= XSMRK; (2946)
  while (1
         & (xNEQ (
             xAND (getFIXED (mOPR + 4 * COREHALFWORD (mREFERENCExPTR)), 65521),
             COREHALFWORD (mXSMRK))))
    {
      // DO FOR I = PTR + 1 TO PTR + NO_OPERANDS(PTR); (2947)
      {
        int32_t from67, to67, by67;
        from67 = xadd (COREHALFWORD (mREFERENCExPTR), 1);
        to67 = xadd (COREHALFWORD (mREFERENCExPTR),
                     bitToFixed ((putBITp (16, mNO_OPERANDSxPTR,
                                           getBIT (16, mREFERENCExPTR)),
                                  NO_OPERANDS (0))));
        by67 = 1;
        for (putBIT (16, mREFERENCExI, fixedToBit (16, from67));
             bitToFixed (getBIT (16, mREFERENCExI)) <= to67;
             putBIT (16, mREFERENCExI,
                     fixedToBit (16, bitToFixed (getBIT (16, mREFERENCExI))
                                         + by67)))
          {
            // IF ~TERMINAL(I) & SHR(OPR(I),16) = OLD THEN (2948)
            if (1
                & (xAND (
                    xNOT (bitToFixed ((
                        putBITp (16, mTERMINALxPTR, getBIT (16, mREFERENCExI)),
                        TERMINAL (0)))),
                    xEQ (
                        SHR (getFIXED (mOPR + 4 * COREHALFWORD (mREFERENCExI)),
                             16),
                        COREHALFWORD (mREFERENCExOLD)))))
              // DO; (2949)
              {
              rs1s1s1:;
                // IF TRACE THEN (2950)
                if (1 & (bitToFixed (getBIT (8, mTRACE))))
                  // OUTPUT = 'REFERENCE '|| OLD || ' IS '||I; (2951)
                  {
                    descriptor_t *stringRHS;
                    stringRHS = xsCAT (
                        xsCAT (xsCAT (cToDescriptor (NULL, "REFERENCE "),
                                      bitToCharacter (
                                          getBIT (16, mREFERENCExOLD))),
                               cToDescriptor (NULL, " IS ")),
                        bitToCharacter (getBIT (16, mREFERENCExI)));
                    OUTPUT (0, stringRHS);
                    stringRHS->inUse = 0;
                  }
                // RETURN I; (2952)
                {
                  reentryGuard = 0;
                  return getBIT (16, mREFERENCExI);
                }
              es1s1s1:;
              } // End of DO block
          }
      } // End of DO for-loop block
      // PTR = PTR + 1 + NO_OPERANDS(PTR); (2953)
      {
        int32_t numberRHS = (int32_t)(xadd (
            xadd (COREHALFWORD (mREFERENCExPTR), 1),
            bitToFixed (
                (putBITp (16, mNO_OPERANDSxPTR, getBIT (16, mREFERENCExPTR)),
                 NO_OPERANDS (0)))));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mREFERENCExPTR, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // RETURN PTR; (2954)
  {
    reentryGuard = 0;
    return getBIT (16, mREFERENCExPTR);
  }
}
