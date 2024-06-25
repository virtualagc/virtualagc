/* inlines=13
 * This is a C patch for CALL INLINEs #33-45 in the `MAKE_FIXED_LIT` function
 * of PASS1 of HAL/S-FC.
 *
 * So, here's my lame attempt to grasp what the inlines are doing, using GRn
 * to denote general registers and FRn to denot floating-point registers:
 *
 *      L    3,DW_AD            Load address of DW(0) into general register GR3.
 *      LD   0,0(0,3)           Load DW(0),DW(1) into FR0.
 *      LPDR 0,0                Convert FR0 to absolute value.
 *      L   1,ADDR_ROUNDER      Load address of 0.5 into GR1.
 *      AD  0,0(0,1)            Add 0.5 to FR0.
 *      L 1,ADDR_FIXED_LIMIT    Load ADDR_FIXED_LIMIT (addr of DW[10]) into GR1.
 *                              DW(10),DW(11) contains the value 2.0**31.
 *      L   2,  PTR             Load address of LIMIT_OK label into GR2.
 *      CD  0,0(0,1)            Compare FR0 to 2.0**31.
 *      BNHR 2                  If <, branch to LIMIT_OK.
 *      LD   0,0(0,1)           Load 2.0**31 into FR0.
 * LIMIT_OK:
 *      L   1,ADDR_FIXER        Load address of DW[8] into GR1.
 *                              DW[8],DW[9] contains a DP 0.0.
 *      AW  0,0(0,1)            Add 0.0 to FR0.
 *      STD 0,8(0,3)            Store FR0 into DW[2],DW[3].
 */

int addrDW = getFIXED(mFOR_DW);
double FR0 = fabs( fromFloatIBM( getFIXED(addrDW + 0),
                                 getFIXED(addrDW + 4) ));
int ADDR_FIXED_LIMIT = getFIXED(mADDR_FIXED_LIMIT);

if (FR0 > ADDR_FIXED_LIMIT)
  FR0 = ADDR_FIXED_LIMIT;

putFIXED(addrDW + 8, 0);
putFIXED(addrDW + 12, rint(FR0));
