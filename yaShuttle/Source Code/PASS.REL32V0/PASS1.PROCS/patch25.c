/* inlines=7
 * This is a C-language patch for CALL INLINEs #25-31 in BLANK.xpl, as
 * used by XCOM-I in building PASS1 of HAL/S-FC.
 *
 * This block of INLINEs replaces `COUNT` characters in `STRING` by spaces,
 * starting at offset `START`.  Note that this occurs in-place (i.e., in-memory)
 * thus breaking the "no side effects to procedure parameters" rule of XPL.
 *
 * Note that the preceding code in BLANK.xpl has already subtracted 2 from
 * `COUNT` for some reason, so we need to add it back.
 */

uint32_t descriptor = getFIXED(mBLANKxSTRING);
uint32_t start = COREHALFWORD(mBLANKxSTART);
uint32_t count = COREHALFWORD(mBLANKxCOUNT) + 2;
if (descriptor != 0)
  {
    uint32_t length = (descriptor >> 24) + 1;
    uint32_t address = descriptor & 0xFFFFFF;
    if (start < length)
      {
        if (start + count > length)
          count = length - start;
        if (count > 0)
          memset(&memory[address + start], 0x40, count); // EBCDIC space = 0x40.
      }
  }

