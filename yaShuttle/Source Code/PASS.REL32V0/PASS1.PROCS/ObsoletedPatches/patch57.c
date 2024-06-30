/* inlines=2
 * This is a C-language patch for CALL INLINEs #57-58 in PREPLITE.xpl, as
 * used by XCOM-I in building PASS1 of HAL/S-FC.
 *
 * I'm porting this patch code over from the code I wrote when manually porting
 * PASS1 to Python.  Here are the comments I wrote in PREPLITE.py:
 *
 *      IR-182-1 describes PREP_LITERAL like so:
 *      "PREP_LITERAL takes a floating point number fresh from
 *      creation by a MONITOR(lO) call, checks it for proper limits,
 *      enters it in the literal table via SAVE LITERAL and sets
 *      SYT_INDEX to the absoulute index of the literal."
 *
 *      *I* think it also stores the converted value in the global variable VALUE.
 *
 *      MONITOR(10,string) converts a stringified representation of a number to IBM
 *      DP floating point, and stores the most-significant word in DW[0] and the
 *      less-significant word in DW[1], return TRUE on error and FALSE on success; this
 *      boolean is the value we expect to find in EXP_OVERFLOW.  So presumably,
 *      PREP_LITERAL() expects to find DW[0] and DW[1] filled with the data.
 *
 *      The XPL has some INLINEs here, with no explanation of what they're
 *      for.  However, the documentation for the LIT1, LIT2, and LIT3 arrays
 *      explains that the code LIT2 == 0xFF000000 is encoded in case of an
 *      invalid value.  So my guess is that the INLINEs probably store this
 *      illegal-value marker in place of whatever data was passed to us.
 *      Of course, those values could simply have been stored directly as I
 *      do below without any INLINEs, so perhaps that's not quite right.
 */

uint32_t addrDW = getFIXED(mDW_AD);
putFIXED(addrDW + 0, 0xFF000000);
putFIXED(addrDW + 4, 0x00000000);

