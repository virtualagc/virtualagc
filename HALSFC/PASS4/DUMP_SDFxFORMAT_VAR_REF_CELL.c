/*
  File DUMP_SDFxFORMAT_VAR_REF_CELL.c generated by XCOM-I, 2024-08-08 04:33:20.
*/

#include "runtimeC.h"

descriptor_t *
DUMP_SDFxFORMAT_VAR_REF_CELL (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (descriptor_t *)0;
    }
  reentryGuard = guardReentry (reentryGuard, "DUMP_SDFxFORMAT_VAR_REF_CELL");
  // CALL SDF_LOCATE(PTR,ADDR(VMEM_H),RESV); (2119)
  {
    putFIXED (mSDF_LOCATExPTR, getFIXED (mDUMP_SDFxFORMAT_VAR_REF_CELLxPTR));
    putFIXED (mSDF_LOCATExBVAR, ADDR ("VMEM_H", 0x80000000, NULL, 0));
    putBITp (8, mSDF_LOCATExFLAGS, getBIT (8, mRESV));
    SDF_LOCATE (0);
  }
  // COREWORD(ADDR(VMEM_F)) = LOC_ADDR; (2120)
  {
    int32_t numberRHS = (int32_t)(getFIXED (mLOC_ADDR));
    COREWORD2 (ADDR ("VMEM_F", 0x80000000, NULL, 0), numberRHS);
  }
  // IF VMEM_H(1) < 0 THEN (2121)
  if (1 & (xLT (COREHALFWORD (getFIXED (mVMEM_H) + 2 * 1), 0)))
    // DO; (2122)
    {
    rs1:;
      // SUBSCRIPTS = TRUE; (2123)
      {
        int32_t numberRHS = (int32_t)(1);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxSUBSCRIPTS, bitRHS);
        bitRHS->inUse = 0;
      }
      // #SYTS = VMEM_H(1) &  32767; (2124)
      {
        int32_t numberRHS = (int32_t)(xAND (
            COREHALFWORD (getFIXED (mVMEM_H) + 2 * 1), 32767));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxpSYTS, bitRHS);
        bitRHS->inUse = 0;
      }
    es1:;
    } // End of DO block
  // ELSE (2125)
  else
    // DO; (2126)
    {
    rs2:;
      // SUBSCRIPTS = FALSE; (2127)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxSUBSCRIPTS, bitRHS);
        bitRHS->inUse = 0;
      }
      // #SYTS = VMEM_H(1); (2128)
      {
        descriptor_t *bitRHS = getBIT (16, getFIXED (mVMEM_H) + 2 * 1);
        putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxpSYTS, bitRHS);
        bitRHS->inUse = 0;
      }
    es2:;
    } // End of DO block
  // IF #SYTS = 1 THEN (2129)
  if (1 & (xEQ (COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxpSYTS), 1)))
    // MSG(2) = ' ' || VMEM_H(4); (2130)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, " "),
                   bitToCharacter (getBIT (16, getFIXED (mVMEM_H) + 2 * 4)));
      putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (2), stringRHS);
      stringRHS->inUse = 0;
    }
  // ELSE (2131)
  else
    // MSG(2) = ' ('||VMEM_H(4); (2132)
    {
      descriptor_t *stringRHS;
      stringRHS
          = xsCAT (cToDescriptor (NULL, " ("),
                   bitToCharacter (getBIT (16, getFIXED (mVMEM_H) + 2 * 4)));
      putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (2), stringRHS);
      stringRHS->inUse = 0;
    }
  // MSG = SYMBOL_NAME(VMEM_H(4)); (2133)
  {
    descriptor_t *stringRHS;
    stringRHS = (putBITp (16, mSYMBOL_NAMExSYMBp,
                          getBIT (16, getFIXED (mVMEM_H) + 2 * 4)),
                 SYMBOL_NAME (0));
    putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG, stringRHS);
    stringRHS->inUse = 0;
  }
  // DO J = 5 TO #SYTS+3; (2134)
  {
    int32_t from39, to39, by39;
    from39 = 5;
    to39 = xadd (COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxpSYTS), 3);
    by39 = 1;
    for (putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ, fixedToBit (16, from39));
         bitToFixed (getBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ)) <= to39;
         putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ,
                 fixedToBit (16, bitToFixed (getBIT (
                                     16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ))
                                     + by39)))
      {
        // MSG(2) = MSG(2) || ',' || VMEM_H(J); (2135)
        {
          descriptor_t *stringRHS;
          stringRHS = xsCAT (
              xsCAT (getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 2),
                     cToDescriptor (NULL, ",")),
              bitToCharacter (getBIT (
                  16,
                  getFIXED (mVMEM_H)
                      + 2 * COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxJ))));
          putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (2),
                        stringRHS);
          stringRHS->inUse = 0;
        }
        // MSG = MSG || '.' || SYMBOL_NAME(VMEM_H(J)); (2136)
        {
          descriptor_t *stringRHS;
          stringRHS = xsCAT (
              xsCAT (getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG),
                     cToDescriptor (NULL, ".")),
              (putBITp (
                   16, mSYMBOL_NAMExSYMBp,
                   getBIT (16,
                           getFIXED (mVMEM_H)
                               + 2
                                     * COREHALFWORD (
                                         mDUMP_SDFxFORMAT_VAR_REF_CELLxJ))),
               SYMBOL_NAME (0)));
          putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG, stringRHS);
          stringRHS->inUse = 0;
        }
      }
  } // End of DO for-loop block
  // IF #SYTS = 1 THEN (2137)
  if (1 & (xEQ (COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxpSYTS), 1)))
    // MSG = MSG(2) || '=' || MSG; (2138)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (
          xsCAT (getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 2),
                 cToDescriptor (NULL, "=")),
          getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG));
      putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG, stringRHS);
      stringRHS->inUse = 0;
    }
  // ELSE (2139)
  else
    // MSG = MSG(2) || ')=' || MSG; (2140)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (
          xsCAT (getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 2),
                 cToDescriptor (NULL, ")=")),
          getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG));
      putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG, stringRHS);
      stringRHS->inUse = 0;
    }
  // IF ~SUBSCRIPTS THEN (2141)
  if (1 & (xNOT (BYTE0 (mDUMP_SDFxFORMAT_VAR_REF_CELLxSUBSCRIPTS))))
    // DO; (2142)
    {
    rs4:;
      // CALL SDF_PTR_LOCATE(PTR,RELS); (2143)
      {
        putFIXED (mSDF_PTR_LOCATExPTR,
                  getFIXED (mDUMP_SDFxFORMAT_VAR_REF_CELLxPTR));
        putBITp (8, mSDF_PTR_LOCATExFLAGS, getBIT (8, mRELS));
        SDF_PTR_LOCATE (0);
      }
      // IF NO_PRINT THEN (2144)
      if (1
          & (bitToFixed (getBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxNO_PRINT))))
        // DO; (2145)
        {
        rs4s1:;
          // IF LENGTH(S(L)) > LINELENGTH THEN (2146)
          if (1
              & (xGT (
                  LENGTH (getCHARACTER (mS + 4 * COREHALFWORD (mDUMP_SDFxL))),
                  131)))
            // L = L + 1; (2147)
            {
              int32_t numberRHS
                  = (int32_t)(xadd (COREHALFWORD (mDUMP_SDFxL), 1));
              descriptor_t *bitRHS;
              bitRHS = fixedToBit (32, (int32_t)(numberRHS));
              putBIT (16, mDUMP_SDFxL, bitRHS);
              bitRHS->inUse = 0;
            }
          // S(L) = S(L) || MSG; (2148)
          {
            descriptor_t *stringRHS;
            stringRHS
                = xsCAT (getCHARACTER (mS + 4 * COREHALFWORD (mDUMP_SDFxL)),
                         getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG));
            putCHARACTER (mS + 4 * (COREHALFWORD (mDUMP_SDFxL)), stringRHS);
            stringRHS->inUse = 0;
          }
          // NO_PRINT = FALSE; (2149)
          {
            int32_t numberRHS = (int32_t)(0);
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxNO_PRINT, bitRHS);
            bitRHS->inUse = 0;
          }
        es4s1:;
        } // End of DO block
      // RETURN MSG; (2150)
      {
        reentryGuard = 0;
        return getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG);
      }
    es4:;
    } // End of DO block
  // J = #SYTS + 4; (2151)
  {
    int32_t numberRHS = (int32_t)(xadd (
        COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxpSYTS), 4));
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ, bitRHS);
    bitRHS->inUse = 0;
  }
  // MSG(1) = '$('; (2152)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "$(");
    putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (1), stringRHS);
    stringRHS->inUse = 0;
  }
  // MSG(2), MSG(3) = ''; (2153)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (2), stringRHS);
    putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (3), stringRHS);
    stringRHS->inUse = 0;
  }
  // LAST_SUB_TYPE = -1; (2154)
  {
    int32_t numberRHS = (int32_t)(-1);
    descriptor_t *bitRHS;
    bitRHS = fixedToBit (32, (int32_t)(numberRHS));
    putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxLAST_SUB_TYPE, bitRHS);
    bitRHS->inUse = 0;
  }
  // DO WHILE J <= SHR(VMEM_H(0),1) - 1; (2155)
  while (1
         & (xLE (COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxJ),
                 xsubtract (SHR (COREHALFWORD (getFIXED (mVMEM_H) + 2 * 0), 1),
                            1))))
    {
      // ALPHA = SHR(VMEM_H(J),8) & 3; (2156)
      {
        int32_t numberRHS = (int32_t)(xAND (
            SHR (COREHALFWORD (
                     getFIXED (mVMEM_H)
                     + 2 * COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxJ)),
                 8),
            3));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxALPHA, bitRHS);
        bitRHS->inUse = 0;
      }
      // SUB_TYPE = SHR(VMEM_H(J),10) & 3; (2157)
      {
        int32_t numberRHS = (int32_t)(xAND (
            SHR (COREHALFWORD (
                     getFIXED (mVMEM_H)
                     + 2 * COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxJ)),
                 10),
            3));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_TYPE, bitRHS);
        bitRHS->inUse = 0;
      }
      // BETA = VMEM_H(J) &  15; (2158)
      {
        int32_t numberRHS = (int32_t)(xAND (
            COREHALFWORD (
                getFIXED (mVMEM_H)
                + 2 * COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxJ)),
            15));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxBETA, bitRHS);
        bitRHS->inUse = 0;
      }
      // EXP_TYPE = SHR(VMEM_H(J),4) &  15; (2159)
      {
        int32_t numberRHS = (int32_t)(xAND (
            SHR (COREHALFWORD (
                     getFIXED (mVMEM_H)
                     + 2 * COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxJ)),
                 4),
            15));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxEXP_TYPE, bitRHS);
        bitRHS->inUse = 0;
      }
      // MSG(3) = MSG(3) || EXP_STRINGS(SHR(EXP_TYPE,1)); (2160)
      {
        descriptor_t *stringRHS;
        stringRHS = xsCAT (
            getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 3),
            getCHARACTER (
                mDUMP_SDFxFORMAT_VAR_REF_CELLxEXP_STRINGS
                + 4
                      * SHR (BYTE0 (mDUMP_SDFxFORMAT_VAR_REF_CELLxEXP_TYPE),
                             1)));
        putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (3), stringRHS);
        stringRHS->inUse = 0;
      }
      // IF EXP_TYPE THEN (2161)
      if (1
          & (bitToFixed (getBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxEXP_TYPE))))
        // DO; (2162)
        {
        rs5s1:;
          // J = J + 1; (2163)
          {
            int32_t numberRHS = (int32_t)(xadd (
                COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxJ), 1));
            descriptor_t *bitRHS;
            bitRHS = fixedToBit (32, (int32_t)(numberRHS));
            putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ, bitRHS);
            bitRHS->inUse = 0;
          }
          // MSG(3) = MSG(3) || VMEM_H(J); (2164)
          {
            descriptor_t *stringRHS;
            stringRHS = xsCAT (
                getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 3),
                bitToCharacter (getBIT (
                    16, getFIXED (mVMEM_H)
                            + 2
                                  * COREHALFWORD (
                                      mDUMP_SDFxFORMAT_VAR_REF_CELLxJ))));
            putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (3),
                          stringRHS);
            stringRHS->inUse = 0;
          }
        es5s1:;
        } // End of DO block
      // ELSE (2165)
      else
        // MSG(3) = MSG(3) || '?'; (2166)
        {
          descriptor_t *stringRHS;
          stringRHS = xsCAT (
              getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 3),
              cToDescriptor (NULL, "?"));
          putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (3),
                        stringRHS);
          stringRHS->inUse = 0;
        }
      // DO CASE ALPHA; (2167)
      {
      rs5s2:
        switch (BYTE0 (mDUMP_SDFxFORMAT_VAR_REF_CELLxALPHA))
          {
          case 0:
            // MSG(3) = '*'; (2169)
            {
              descriptor_t *stringRHS;
              stringRHS = cToDescriptor (NULL, "*");
              putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (3),
                            stringRHS);
              stringRHS->inUse = 0;
            }
            break;
          case 1:
              // ; (2170)
              ;
            break;
          case 2:
            // IF BETA THEN (2171)
            if (1
                & (bitToFixed (
                    getBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxBETA))))
              {
                descriptor_t *stringRHS;
                stringRHS = xsCAT (
                    getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 3),
                    cToDescriptor (NULL, " TO "));
                putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (3),
                              stringRHS);
                stringRHS->inUse = 0;
              }
            break;
          case 3:
            // IF BETA THEN (2173)
            if (1
                & (bitToFixed (
                    getBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxBETA))))
              {
                descriptor_t *stringRHS;
                stringRHS = xsCAT (
                    getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 3),
                    cToDescriptor (NULL, " AT "));
                putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (3),
                              stringRHS);
                stringRHS->inUse = 0;
              }
            break;
          }
      } // End of DO CASE block
      // IF BETA = 0 THEN (2174)
      if (1 & (xEQ (BYTE0 (mDUMP_SDFxFORMAT_VAR_REF_CELLxBETA), 0)))
        // DO; (2175)
        {
        rs5s3:;
          // IF LAST_SUB_TYPE >= 0 THEN (2176)
          if (1
              & (xGE (
                  COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxLAST_SUB_TYPE),
                  0)))
            // IF SUB_TYPE~=LAST_SUB_TYPE THEN (2177)
            if (1
                & (xNEQ (BYTE0 (mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_TYPE),
                         COREHALFWORD (
                             mDUMP_SDFxFORMAT_VAR_REF_CELLxLAST_SUB_TYPE))))
              // MSG(2)=SUB_STRINGS(LAST_SUB_TYPE); (2178)
              {
                descriptor_t *stringRHS;
                stringRHS = getCHARACTER (
                    mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_STRINGS
                    + 4
                          * COREHALFWORD (
                              mDUMP_SDFxFORMAT_VAR_REF_CELLxLAST_SUB_TYPE));
                putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (2),
                              stringRHS);
                stringRHS->inUse = 0;
              }
            // ELSE (2179)
            else
              // MSG(2) = ','; (2180)
              {
                descriptor_t *stringRHS;
                stringRHS = cToDescriptor (NULL, ",");
                putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (2),
                              stringRHS);
                stringRHS->inUse = 0;
              }
          // LAST_SUB_TYPE = SUB_TYPE; (2181)
          {
            descriptor_t *bitRHS
                = getBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_TYPE);
            putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxLAST_SUB_TYPE, bitRHS);
            bitRHS->inUse = 0;
          }
          // MSG(1) = MSG(1) || MSG(2) || MSG(3); (2182)
          {
            descriptor_t *stringRHS;
            stringRHS = xsCAT (
                xsCAT (
                    getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 1),
                    getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 2)),
                getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 3));
            putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (1),
                          stringRHS);
            stringRHS->inUse = 0;
          }
          // MSG(3) = ''; (2183)
          {
            descriptor_t *stringRHS;
            stringRHS = cToDescriptor (NULL, "");
            putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (3),
                          stringRHS);
            stringRHS->inUse = 0;
          }
        es5s3:;
        } // End of DO block
      // J = J + 1; (2184)
      {
        int32_t numberRHS = (int32_t)(xadd (
            COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxJ), 1));
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ, bitRHS);
        bitRHS->inUse = 0;
      }
    } // End of DO WHILE block
  // IF SUB_TYPE=1 | SUB_TYPE=2 THEN (2185)
  if (1
      & (xOR (xEQ (BYTE0 (mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_TYPE), 1),
              xEQ (BYTE0 (mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_TYPE), 2))))
    // MSG(1)=MSG(1)||SUB_STRINGS(SUB_TYPE); (2186)
    {
      descriptor_t *stringRHS;
      stringRHS = xsCAT (
          getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 1),
          getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_STRINGS
                        + 4 * BYTE0 (mDUMP_SDFxFORMAT_VAR_REF_CELLxSUB_TYPE)));
      putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (1), stringRHS);
      stringRHS->inUse = 0;
    }
  // MSG(2), MSG(3) = ''; (2187)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (2), stringRHS);
    putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (3), stringRHS);
    stringRHS->inUse = 0;
  }
  // IF VMEM_F(1) ~= 0 THEN (2188)
  if (1 & (xNEQ (getFIXED (getFIXED (mVMEM_F) + 4 * 1), 0)))
    // DO; (2189)
    {
    rs6:;
      // MSG(1) = MSG(1) || '):'; (2190)
      {
        descriptor_t *stringRHS;
        stringRHS
            = xsCAT (getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 1),
                     cToDescriptor (NULL, "):"));
        putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (1), stringRHS);
        stringRHS->inUse = 0;
      }
      // CALL STACK_STRING(','); (2191)
      {
        putCHARACTERp (mDUMP_SDFxSTACK_STRINGxSTRING,
                       cToDescriptor (NULL, ","));
        DUMP_SDFxSTACK_STRING (0);
      }
      // CALL STACK_PTR(VMEM_F(1) |  2147483648); (2192)
      {
        putFIXED (mDUMP_SDFxSTACK_PTRxPTR,
                  xOR (getFIXED (getFIXED (mVMEM_F) + 4 * 1), 2147483648));
        DUMP_SDFxSTACK_PTR (0);
      }
    es6:;
    } // End of DO block
  // ELSE (2193)
  else
    // IF NO_PRINT THEN (2194)
    if (1 & (bitToFixed (getBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxNO_PRINT))))
      // MSG(1) = MSG(1) || '),'; (2195)
      {
        descriptor_t *stringRHS;
        stringRHS
            = xsCAT (getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 1),
                     cToDescriptor (NULL, "),"));
        putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (1), stringRHS);
        stringRHS->inUse = 0;
      }
    // ELSE (2196)
    else
      // MSG(1) = MSG(1) || ')'; (2197)
      {
        descriptor_t *stringRHS;
        stringRHS
            = xsCAT (getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 1),
                     cToDescriptor (NULL, ")"));
        putCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * (1), stringRHS);
        stringRHS->inUse = 0;
      }
  // CALL SDF_PTR_LOCATE(PTR,RELS); (2198)
  {
    putFIXED (mSDF_PTR_LOCATExPTR,
              getFIXED (mDUMP_SDFxFORMAT_VAR_REF_CELLxPTR));
    putBITp (8, mSDF_PTR_LOCATExFLAGS, getBIT (8, mRELS));
    SDF_PTR_LOCATE (0);
  }
  // IF NO_PRINT THEN (2199)
  if (1 & (bitToFixed (getBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxNO_PRINT))))
    // DO; (2200)
    {
    rs7:;
      // DO J = 0 TO 1; (2201)
      {
        int32_t from40, to40, by40;
        from40 = 0;
        to40 = 1;
        by40 = 1;
        for (putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ,
                     fixedToBit (16, from40));
             bitToFixed (getBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ)) <= to40;
             putBIT (16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ,
                     fixedToBit (16, bitToFixed (getBIT (
                                         16, mDUMP_SDFxFORMAT_VAR_REF_CELLxJ))
                                         + by40)))
          {
            // IF LENGTH(S(L)) > LINELENGTH THEN (2202)
            if (1
                & (xGT (LENGTH (getCHARACTER (
                            mS + 4 * COREHALFWORD (mDUMP_SDFxL))),
                        131)))
              // L = L + 1; (2203)
              {
                int32_t numberRHS
                    = (int32_t)(xadd (COREHALFWORD (mDUMP_SDFxL), 1));
                descriptor_t *bitRHS;
                bitRHS = fixedToBit (32, (int32_t)(numberRHS));
                putBIT (16, mDUMP_SDFxL, bitRHS);
                bitRHS->inUse = 0;
              }
            // S(L) = S(L) || MSG(J); (2204)
            {
              descriptor_t *stringRHS;
              stringRHS = xsCAT (
                  getCHARACTER (mS + 4 * COREHALFWORD (mDUMP_SDFxL)),
                  getCHARACTER (
                      mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG
                      + 4 * COREHALFWORD (mDUMP_SDFxFORMAT_VAR_REF_CELLxJ)));
              putCHARACTER (mS + 4 * (COREHALFWORD (mDUMP_SDFxL)), stringRHS);
              stringRHS->inUse = 0;
            }
          }
      } // End of DO for-loop block
      // NO_PRINT = FALSE; (2205)
      {
        int32_t numberRHS = (int32_t)(0);
        descriptor_t *bitRHS;
        bitRHS = fixedToBit (32, (int32_t)(numberRHS));
        putBIT (8, mDUMP_SDFxFORMAT_VAR_REF_CELLxNO_PRINT, bitRHS);
        bitRHS->inUse = 0;
      }
      // RETURN; (2206)
      {
        reentryGuard = 0;
        return cToDescriptor (NULL, "");
      }
    es7:;
    } // End of DO block
  // ELSE (2207)
  else
    // RETURN MSG || MSG(1); (2208)
    {
      reentryGuard = 0;
      return xsCAT (getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG),
                    getCHARACTER (mDUMP_SDFxFORMAT_VAR_REF_CELLxMSG + 4 * 1));
    }
}
