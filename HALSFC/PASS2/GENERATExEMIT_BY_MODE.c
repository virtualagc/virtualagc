/*
  File GENERATExEMIT_BY_MODE.c generated by XCOM-I, 2024-08-08 04:32:26.
*/

#include "runtimeC.h"

int32_t
GENERATExEMIT_BY_MODE (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "GENERATExEMIT_BY_MODE");
  // IF FORM(OP2) = 0 THEN (3299)
  if (1
      & (xEQ (COREHALFWORD (getFIXED (mIND_STACK)
                            + 73 * (COREHALFWORD (mGENERATExEMIT_BY_MODExOP2))
                            + 32 + 2 * (0)),
              0)))
    // ITYPE = RI; (3300)
    {
      descriptor_t *bitRHS = getBIT (16, mGENERATExRI);
      putBIT (16, mGENERATExEMIT_BY_MODExITYPE, bitRHS);
      bitRHS->inUse = 0;
    }
  // ELSE (3301)
  else
    // ITYPE = RX; (3302)
    {
      descriptor_t *bitRHS = getBIT (16, mGENERATExRX);
      putBIT (16, mGENERATExEMIT_BY_MODExITYPE, bitRHS);
      bitRHS->inUse = 0;
    }
  // CALL EMITOP(MAKE_INST(OP, MODE, ITYPE), R, OP2); (3303)
  {
    putBITp (16, mGENERATExEMITOPxINST,
             (putBITp (16, mGENERATExMAKE_INSTxOPCODE,
                       getBIT (16, mGENERATExEMIT_BY_MODExOP)),
              putBITp (16, mGENERATExMAKE_INSTxOPTYPE,
                       getBIT (16, mGENERATExEMIT_BY_MODExMODE)),
              putBITp (16, mGENERATExMAKE_INSTxOPFORM,
                       getBIT (16, mGENERATExEMIT_BY_MODExITYPE)),
              GENERATExMAKE_INST (0)));
    putBITp (16, mGENERATExEMITOPxXREG, getBIT (16, mGENERATExEMIT_BY_MODExR));
    putBITp (16, mGENERATExEMITOPxOP, getBIT (16, mGENERATExEMIT_BY_MODExOP2));
    GENERATExEMITOP (0);
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
