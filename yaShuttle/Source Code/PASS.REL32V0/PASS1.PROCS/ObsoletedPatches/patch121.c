/* inlines=4
 * This is a C-language patch for CALL INLINEs #121-124 in INITIALI.xpl, as
 * used by XCOM-I in building PASS1 of HAL/S-FC.
 */

// Note that `LIT_CHAR_AD` is aliased to `COMM(0)`, which is also `COMM`.
putFIXED(mCOMM, getFIXED(mLIT_NDX));
putFIXED(mDW_AD, getFIXED(mFOR_DW));
