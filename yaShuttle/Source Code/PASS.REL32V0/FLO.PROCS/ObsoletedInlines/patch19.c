/* inlines=5
 * This is a C-language patch for CALL INLINEs #19-23 in HALINCL/VMEM3.xpl, as
 * used by XCOM-I in building FLO of HAL/S-FC.
 *
 * This block of inlines zeroes out a block of `COUNT` bytes of memory ,
 * beginning at address `CORE_ADDR`.
 */

memset(&memory[getFIXED(mZERO_CORExCORE_ADDR)], 0, getFIXED(mZERO_CORExCOUNT));
