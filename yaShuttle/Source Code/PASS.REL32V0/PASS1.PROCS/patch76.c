/* inlines=2
 * This is a C-language patch for CALL INLINEs #76-77 in PREPLITE.xpl, as
 * used by XCOM-I in building PASS1 of HAL/S-FC.
 *
 * See the comments in patch57.c and patch59.c.  My interpretation of the
 * INLINEs:
 *      L   1,TABLE_ADDR        Loads address of DW(6) into R1.
 *      STD 6,0(0,1)            stores FP reg 6 into DW(6),DW(7).
 */

uint32_t tableAddr = getFIXED(mTABLE_ADDR);
uint32_t msw, lsw;
uint32_t ivalue = getFIXED(mVALUE);
toFloatIBM(&msw, &lsw, ivalue);
putFIXED(tableAddr, msw);
putFIXED(tableAddr + 4, lsw);
