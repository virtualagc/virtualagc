/*
  File _SPMANERR.c generated by XCOM-I, 2024-08-08 04:31:49.
*/

#include "runtimeC.h"

int32_t
_SPMANERR (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "_SPMANERR");
  // IF ~ _IN_COMPACTIFY THEN (39)
  if (1 & (xNOT (BYTE0 (m_IN_COMPACTIFY))))
    // IF ( FREELIMIT > FREEPOINT + 650 ) THEN (40)
    if (1 & (xGT (FREELIMIT (), xadd (FREEPOINT (), 650))))
      // DO; (41)
      {
      rs1:;
        // OUTPUT='BI002 SEVERITY 3 BUG IN SPACE MANAGEMENT SYSTEM ->->'|| MSG;
        // (42)
        {
          descriptor_t *stringRHS;
          stringRHS = xsCAT (
              cToDescriptor (
                  NULL,
                  "BI002 SEVERITY 3 BUG IN SPACE MANAGEMENT SYSTEM ->->"),
              getCHARACTER (m_SPMANERRxMSG));
          OUTPUT (0, stringRHS);
          stringRHS->inUse = 0;
        }
        // CALL EXIT; (43)
        EXIT ();
      es1:;
      } // End of DO block
    // ELSE (44)
    else
      // DO; (45)
      {
      rs2:;
        // OUTPUT='BI003 SEVERITY 3  BUG IN SPACE MANAGEMENT SYSTEM'; (46)
        {
          descriptor_t *stringRHS;
          stringRHS = cToDescriptor (
              NULL, "BI003 SEVERITY 3  BUG IN SPACE MANAGEMENT SYSTEM");
          OUTPUT (0, stringRHS);
          stringRHS->inUse = 0;
        }
        // CALL EXIT; (47)
        EXIT ();
      es2:;
      } // End of DO block
  // NUMERRORS=NUMERRORS+1; (48)
  {
    int32_t numberRHS
        = (int32_t)(xadd (COREHALFWORD (m_SPMANERRxNUMERRORS), 1));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, m_SPMANERRxNUMERRORS, bitRHS);
    bitRHS->inUse = 0;
  }
  // IF NUMERRORS > MAX_NUM_ERRORS THEN (49)
  if (1 & (xGT (COREHALFWORD (m_SPMANERRxNUMERRORS), 50)))
    // DO; (50)
    {
    rs3:;
      // OUTPUT='BI004 SEVERITY 3 TOO MANY SPACE MANAGEMENT ERRORS ' || '--
      // ABORTING.'; (51)
      {
        descriptor_t *stringRHS;
        stringRHS = cToDescriptor (
            NULL,
            "BI004 SEVERITY 3 TOO MANY SPACE MANAGEMENT ERRORS -- ABORTING.");
        OUTPUT (0, stringRHS);
        stringRHS->inUse = 0;
      }
      // CALL EXIT; (52)
      EXIT ();
    es3:;
    } // End of DO block
  {
    reentryGuard = 0;
    return 0;
  }
}
