/* inlines=3
 * This is a C-language patch for CALL INLINEs #5-7 in the `MOVE` function
 * from HALINCL/VMEM3.xpl, as used by XCOM-I in building PASS1 of HAL/S-FC.
 *
 * This block copies 256 bytes from address `FROM` to address `INTO`.
 */

memmove(&memory[getFIXED(mMOVExINTO)], &memory[getFIXED(mMOVExFROM)], 256);

