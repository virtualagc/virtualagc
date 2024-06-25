/* inlines=8
 * This is a C-language patch for CALL INLINEs #8-15 in the `MOVE` function
 * from HALINCL/VMEM3.xpl, as used by XCOM-I in building PASS1 of HAL/S-FC.
 *
 * This block copies `LEGNTH` bytes from address `FROM` to address `INTO`.
 * And no, `LEGNTH` is not a misprint; or at least, not a misprint by *me*.
 */

memmove(&memory[getFIXED(mMOVExINTO)], &memory[getFIXED(mMOVExFROM)],
    COREHALFWORD(mMOVExLEGNTH));

