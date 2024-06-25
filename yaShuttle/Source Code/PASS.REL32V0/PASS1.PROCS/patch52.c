/* inlines=5
 * This is a C-language patch for CALL INLINEs #52-56 in HALINCL/SAVELITE for
 * compiling with HAL/S-FC as translated by XCOM-I.
 *
 * These CALL INLINEs appear to me to be self-modifying code.  The instruction
 * at `MOV` seem to move the value of `VAL` into `LIT_CHAR` (in-place, without
 * reallocation of the string EBCDIC data).  The self-modifying part, prior to
 * `MOV` appears to be for the purpose of inserting the length-1 field into the
 * instruction at `MOV`.
 */

/* Note that `LIT_CHAR_AD` is aliased to `COMM(0)`. */
uint32_t val = getFIXED(mSAVE_LITERALxVAL);
memmove(&memory[getFIXED(mCOMM)],
       &memory[val & 0xFFFFFF],
       1 + ((val >> 24) & 0xFF));
