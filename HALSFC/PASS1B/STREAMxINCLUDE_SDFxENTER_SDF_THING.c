/*
  File STREAMxINCLUDE_SDFxENTER_SDF_THING.c generated by XCOM-I, 2024-08-08
  04:33:34.
*/

#include "runtimeC.h"

int32_t
STREAMxINCLUDE_SDFxENTER_SDF_THING (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard
      = guardReentry (reentryGuard, "STREAMxINCLUDE_SDFxENTER_SDF_THING");
  // IF CONTROL( 3) THEN (3857)
  if (1 & (bitToFixed (getBIT (1, mCONTROL + 1 * 3))))
    // OUTPUT = 'ENTER_SDF_THING: ENTERED'; (3858)
    {
      descriptor_t *stringRHS;
      stringRHS = cToDescriptor (NULL, "ENTER_SDF_THING: ENTERED");
      OUTPUT (0, stringRHS);
      stringRHS->inUse = 0;
    }
  // BCD = NEW_STRING(SDFPKG_SYMBNAM); (3859)
  {
    descriptor_t *stringRHS;
    stringRHS = SUBSTR2 (
        xsCAT (getCHARACTER (mX1),
               getCHARACTERd (xadd (
                   xadd (SHL (xsubtract (
                                  BYTE0 (getFIXED (
                                             mSTREAMxINCLUDE_SDFxCOMMTABL_BYTE)
                                         + 1 * 23),
                                  1),
                              24),
                         getFIXED (mSTREAMxINCLUDE_SDFxCOMMTABL_ADDR)),
                   88))),
        1);
    putCHARACTER (mBCD, stringRHS);
    stringRHS->inUse = 0;
  }
  // DO CASE SDF_SYMB_CLASS; (3860)
  {
  rs1:
    switch (BYTE0 (getFIXED (mSTREAMxINCLUDE_SDFxSDF_B) + 1 * 6))
      {
      case 0:
          // ; (3862)
          ;
        break;
      case 1:
        // CALL ENTER_SDF_VAR(VAR_CLASS); (3863)
        {
          putBITp (16, mSTREAMxINCLUDE_SDFxENTER_SDF_VARxCLASS,
                   getBIT (8, mVAR_CLASS));
          STREAMxINCLUDE_SDFxENTER_SDF_VAR (0);
        }
        break;
      case 2:
        // DO; (3864)
        {
        rs1s1:;
          // IF SDF_SYMB_TYPE = 9 THEN (3864)
          if (1
              & (xEQ (BYTE0 (getFIXED (mSTREAMxINCLUDE_SDFxSDF_B) + 1 * 7),
                      9)))
            // CALL ENTER_SDF_MACRO; (3865)
            STREAMxINCLUDE_SDFxENTER_SDF_MACRO (0);
          // ELSE (3866)
          else
            // IF SDF_SYMB_TYPE ~= 8 THEN (3867)
            if (1
                & (xNEQ (BYTE0 (getFIXED (mSTREAMxINCLUDE_SDFxSDF_B) + 1 * 7),
                         8)))
              // CALL ENTER_SDF_LABEL(LABEL_CLASS); (3868)
              {
                putBITp (16, mSTREAMxINCLUDE_SDFxENTER_SDF_LABELxCLASS,
                         getBIT (8, mLABEL_CLASS));
                STREAMxINCLUDE_SDFxENTER_SDF_LABEL (0);
              }
        es1s1:;
        } // End of DO block
        break;
      case 3:
        // CALL ENTER_SDF_VAR(FUNC_CLASS); (3870)
        {
          putBITp (16, mSTREAMxINCLUDE_SDFxENTER_SDF_VARxCLASS,
                   getBIT (8, mFUNC_CLASS));
          STREAMxINCLUDE_SDFxENTER_SDF_VAR (0);
        }
        break;
      case 4:
        // DO; (3871)
        {
        rs1s2:;
          // IF (SDF_SYMB_FLAGS & SDF_TPL_HDR_FLAG) ~= 0 THEN (3871)
          if (1
              & (xNEQ (xAND (getFIXED (getFIXED (mSTREAMxINCLUDE_SDFxSDF_F)
                                       + 4 * 2),
                             33554432),
                       0)))
            // CALL ENTER_SDF_TEMPLATE; (3872)
            STREAMxINCLUDE_SDFxENTER_SDF_TEMPLATE (0);
          // ELSE (3873)
          else
            // CALL ERROR(CLASS_XI, 8, BCD); (3874)
            {
              putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_XI));
              putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(8)));
              putCHARACTERp (mERRORxTEXT, getCHARACTER (mBCD));
              ERROR (0);
            }
        es1s2:;
        } // End of DO block
        break;
      case 5:
        // CALL ERROR(CLASS_XI, 8, BCD); (3876)
        {
          putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_XI));
          putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(8)));
          putCHARACTERp (mERRORxTEXT, getCHARACTER (mBCD));
          ERROR (0);
        }
        break;
      case 6:
        // CALL ERROR(CLASS_XI, 8, BCD); (3877)
        {
          putBITp (16, mERRORxCLASS, getBIT (16, mCLASS_XI));
          putBITp (8, mERRORxNUM, fixedToBit (32, (int32_t)(8)));
          putCHARACTERp (mERRORxTEXT, getCHARACTER (mBCD));
          ERROR (0);
        }
        break;
      }
  } // End of DO CASE block
  // RETURN; (3877)
  {
    reentryGuard = 0;
    return 0;
  }
}
