/*
 * This is a C-language patch for CALL INLINEs #57-58 in PREPLITE.xpl, as
 * used by XCOM-I in building PASS1 of HAL/S-FC.
 *
 * I'm porting this code over from the code I wrote when manually porting
 * PASS1 to Python.  Here are the comments I wrote in PREPLITE.py:
 *
 *      The XPL has some INLINEs here, with no explanation of what they're
 *      for.  However, the documentation for the LIT1, LIT2, and LIT3 arrays
 *      explains that the code LIT2 == 0xFF000000 is encoded in case of an
 *      invalid value.  So my guess is that the INLINEs probably store this
 *      illegal-value marker in place of whatever data was passed to us.
 *      Of course, those values could simply have been stored directly as I
 *      do below without any INLINEs, so perhaps that's not quite right.
 *
 */

{
  uint32_t addrDW = getFIXED(mFOR_DW);
  putFIXED(addrDW + 0, 0xFF000000);
  putFIXED(addrDW + 4, 0x00000000);
}
