/*
  File INITIALIZExGET_CODE_HWM.c generated by XCOM-I, 2024-08-08 04:33:10.
*/

#include "runtimeC.h"

descriptor_t *
INITIALIZExGET_CODE_HWM (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "INITIALIZExGET_CODE_HWM");
  // CELL_PTR = CODEHWM_HEAD; (2401)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mCOMM + 4 * 30));
    putFIXED (mINITIALIZExGET_CODE_HWMxCELL_PTR, numberRHS);
  }
  // DO WHILE CELL_PTR ~= -1; (2402)
  while (1 & (xNEQ (getFIXED (mINITIALIZExGET_CODE_HWMxCELL_PTR), -1)))
    {
      // CALL LOCATE(CELL_PTR,ADDR(HWMCELL),0); (2403)
      {
        putFIXED (mLOCATExPTR, getFIXED (mINITIALIZExGET_CODE_HWMxCELL_PTR));
        putFIXED (mLOCATExBVAR, ADDR ("HWMCELL", 0x80000000, NULL, 0));
        putBITp (8, mLOCATExFLAGS, fixedToBit (32, (int32_t)(0)));
        LOCATE (0);
      }
      // COREWORD(ADDR(C)) =  117440512 | (VMEM_LOC_ADDR +6); (2404)
      {
        int32_t numberRHS
            = (int32_t)(xOR (117440512, xadd (getFIXED (mVMEM_LOC_ADDR), 6)));
        COREWORD2 (ADDR (NULL, 0, "INITIALIZExGET_CODE_HWMxC", 0), numberRHS);
      }
      // IF TS = C THEN (2405)
      if (1
          & (xsEQ (getCHARACTER (mINITIALIZExTS),
                   getCHARACTER (mINITIALIZExGET_CODE_HWMxC))))
        // RETURN HWMCELL.LENGTH; (2406)
        {
          reentryGuard = 0;
          return getBIT (16, getFIXED (mHWMCELL) + 14 * (0) + 4 + 2 * (0));
        }
      // CELL_PTR = HWMCELL.NEXT_CELL_PTR; (2407)
      {
        int32_t numberRHS = (int32_t)(getFIXED (getFIXED (mHWMCELL) + 14 * (0)
                                                + 0 + 4 * (0)));
        putFIXED (mINITIALIZExGET_CODE_HWMxCELL_PTR, numberRHS);
      }
    } // End of DO WHILE block
  // RETURN 0; (2408)
  {
    reentryGuard = 0;
    return fixedToBit (32, (int32_t)(0));
  }
}
