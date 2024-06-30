/* inlines=17
 * This is a C-language patch for CALL INLINEs #59-75 in PREPLITE.xpl, as
 * used by XCOM-I in building PASS1 of HAL/S-FC. The IR-182-1 description
 * implies that the purpose of these INLINEs is to manufacture the value(s)
 * stored in the variable TABLE_ADDRESS.
 *
 * Here's how the DW array is used:
 *      DW_AD            -> DW(0),DW(1)     Input
 *                          DW(2),DW(3)     ?
 *                          DW(4),DW(5)     ?
 *      TABLE_ADDR       -> DW(6),DW(7)     Output to SAVE_LITERAL.
 *      ADDR_FIXER       -> DW(8),DW(9)     4E000000 00000000 (0.0)
 *      ADDR_FIXED_LIMIT -> DW(10),DW(11)   487FFFFF FFFFFFFF (2.0**31)
 *                          DW(12),DW(13)   407FFFFF FFFFFFFF (0.5)
 *
 * Here's what I think the individual instructions do:
 *      L   1,ADDR_FIXED_LIMIT  loads address of DW(10) into register R1
 *      L   2,TEMP1             load address of TEMP1 (which stores the address
 *                              of label NOT_EXACT) into reg R2
 *      LDR 6,0                 copy FP reg 0 to FP reg 6.
 *      LPDR 0,0                convert FP reg 0 to absolute value.
 *      CD  0,0(,1)             Compares FP reg 0 to ADDR_FIXED_LIMIT.
 *      BHR 2                   This seems to be a BCR instruction.  It will
 *                              branch to NOT_EXACT if the preceding comparison
 *                              result was ">".
 *      SDR 4,4                 This appears to be a trick to set FP reg 4 to 0.
 *      LDR 2,0                 Copy FP reg 0 to FP reg 2.
 *      L   1,ADDR_FIXER        Loads address of 0.0 into register R1.
 *      AW  0,0(,1)             Adds "unnormalized" 0.0 to FP reg 0.
 *                              Not sure why.
 *      L   1,TABLE_ADDR        Loads address of DW(6) into R1.
 *      STD 0,0(,1)             Moves FP reg 0 to DW(6),DW(7).
 *      ADR 0,4                 "Add normalized long" FP reg 4 (0.0) to
 *                              FP reg 0.  Why?
 *      SDR 2,0                 "Subtract normalized long", apparently
 *                              subtracting FP reg 0 from FP reg 2.
 *      BNER 2                  Branch to NOT_EXACT if previous operation
 *                              result "!=".
 *      L   2,4(,1)             loads DW(7) into reg R2.
 *      ST  2,VALUE             store reg R2 (i.e., DW(7)) into VALUE.
 */

uint32_t addrDW = getFIXED(mDW_AD);
uint32_t msw = getFIXED(addrDW + 0), lsw = getFIXED(addrDW + 4);
int32_t ivalue;
double value = fromFloatIBM(msw, lsw);
if (value > INT32_MAX)
  goto NOT_EXACT;
else if (value < INT32_MIN)
  goto NOT_EXACT;
else
  {
    ivalue = roundf(value);
    if (value != ivalue)
      goto NOT_EXACT;
  }
putFIXED(mVALUE, ivalue);

