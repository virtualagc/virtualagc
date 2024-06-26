/* inlines=2
 * This is a C-language patch for CALL INLINEs #17-18 in HALINCL/VMEM3.xpl, as
 * used by XCOM-I in building PASS1 of HAL/S-FC.
 *
 * All this block of inlines does is to write a single byte of 0 into core
 * memory at address `CORE_ADDR`.
 */

memory[getFIXED(mZERO_256xCORE_ADDR)] = 0;
