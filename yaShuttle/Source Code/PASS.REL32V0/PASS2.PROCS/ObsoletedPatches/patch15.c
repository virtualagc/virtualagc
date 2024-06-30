/* inlines=2,0
 * License:     Public Domain, use or modify freely for any purpose.
 * Filename:    PASS2.PROCS/patch15.c
 * Purpose:     PFS only:  C-language patch for CALL INLINEs #15-16 in
 *                         EMITSTRING module of HAL/S-FC PASS2.
 * History:     2024-06-18 RSB  Created.
 */

#ifdef PFS
/* Here's my analysis of the IBM 360 machine code being replaced by C:
 *
 * CALL INLINE("58", 1, 0, TEMP)                Loads the descriptor for TEMP
 *                                              into GR1.  TEMP contains the
 *                                              address of a translation table
 *                                              called DEUTRANS.
 * CALL INLINE("DC", 0, 255, TEMPSTRING, 1, 0)  The characters of TEMPSTRING
 *                                              are translated according to the
 *                                              translation table DEUTRANS.
 *
 * The character set, and the encoding thereof, is different for the DEU than
 * the EBCDIC character set.  The DEU (Display Electronics Unit) is a piece
 * of display hardware in the shuttle.  Table 8-2 in the HAL/S-FC User's Manual
 * (USA003090) lists that character set encoding, while Table 8-1 lists the HAL/S
 * characters conventionally used to represent those DEU characters.  The DEU
 * set appears to be ASCII for printable characters, with all of the non-printable
 * positions filled up with mostly-printable characters.  Thus, I think this
 * INLINE code translates the HAL/S representation of the character into the
 * DEU representation of the characters, in-place.
 *
 * For example in the HAL/S code, an 'A' would have the EBCDIC code "C1".
 * Looking at position "C1" in DEUTRANS, we find "41", which according to table
 * 8-2 is the code for a DEU 'A'.
 */

uint32_t descTEMPSTRING = getFIXED(mEMITSTRINGxTEMPSTRING);
uint8_t *tempstring = &memory[descTEMPSTRING & 0xFFFFFF];
int length = 1 + ((descTEMPSTRING >> 24) & 0xFF);
uint8_t *deutrans = &memory[mEMITSTRINGxDEUTRANS];
int i;

for (i = 0; i < length; i++)
  tempstring[i] = deutrans[tempstring[i]];

#endif // PFS
