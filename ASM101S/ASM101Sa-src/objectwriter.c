/*
 * License:    This program is declared by its author to be the U.S. Public
 *             Domain, and may be freely used, modified, or distributed for any
 *             purpose.
 * Filename:   objectwriter.c
 * Purpose:    Emit an IBM object module.
 * Reference:  C28-6538-3
 */

#include "objectwriter.h"
#include "ebcdic.h"

static void
toEbcdic (unsigned char *out, const char *s, size_t length)
{
  size_t i;
  size_t n = s == NULL ? 0 : strlen (s);
  for (i = 0; i < length; i++)
    {
      unsigned char c = (i < n) ? (unsigned char) s[i] : 0;
      out[i] = (i < n && c < 128) ? asciiToEbcdic[c] : 0x40;
    }
}

static void
be16 (unsigned char *out, asmint v)
{
  out[0] = (unsigned char) ((v >> 8) & 0xFF);
  out[1] = (unsigned char) (v & 0xFF);
}

/*
 * A NEGATIVE VALUE IS TWO'S COMPLEMENT IN THE THREE BYTES, not an error.  An
 * ENTRY may sit BEFORE its own section:  PCGEN's `&CURLABL EQU *-FIOBUS&STRTBUS`
 * puts FIOADCNS's FIOIPR two halfwords ahead of it, as a virtual base for
 * bus-indexed addressing.  lnk101's objModule.py decodes the field that way and
 * its comment names that symbol; without the mask this raised OverflowError.
 */
static void
be24 (unsigned char *out, asmint v)
{
  asmuint u = (asmuint) v & 0xFFFFFFu;
  out[0] = (unsigned char) ((u >> 16) & 0xFF);
  out[1] = (unsigned char) ((u >> 8) & 0xFF);
  out[2] = (unsigned char) (u & 0xFF);
}

static void
blanks (unsigned char *out, size_t n)
{
  memset (out, 0x40, n); /* EBCDIC blanks */
}

static asmint
makeCard (FILE *f, const char *recType, const unsigned char *data,
          size_t dataLen, asmint seqNum)
{
  unsigned char card[80];
  char seq[16];
  blanks (card, 80);
  card[0] = 0x02;
  toEbcdic (card + 1, recType, 3);
  if (dataLen > 68)
    dataLen = 68;
  memcpy (card + 4, data, dataLen);
  sprintf (seq, "%08d", (int) (seqNum % 100000000));
  toEbcdic (card + 72, seq, 8);
  fwrite (card, 1, 80, f);
  return seqNum;
}

/*
 * ESD entry format, 16 bytes each:
 *   0-7   symbol name (EBCDIC, blank-padded)
 *   8     type code (0=SD, 1=LD, 2=ER, 3=PC, 4=CM, 5=XD/PR, 6=WX)
 *   9-11  address
 *   12    for SD/PC/CM the AMODE/RMODE flags; for ER/LD/WX a blank
 *   13-15 for SD/PC/CM the length; for LD [0x40, LDID]; for ER/WX blank
 */
typedef struct
{
  asmint esdId;
  const char *name;
  unsigned char typeCode;
  asmint address;
  asmint length;
  asmint flags;
  asmint ldid;
} EsdItem;

static asmint
writeESD (FILE *f, EsdItem *items, size_t n, asmint seqNum)
{
  size_t i;
  for (i = 0; i < n; i += 3)
    {
      unsigned char data[68];
      size_t batch = (n - i) < 3 ? (n - i) : 3;
      size_t j;
      blanks (data, 68);
      be16 (data + 6, (asmint) (batch * 16));
      be16 (data + 10, items[i].esdId);
      for (j = 0; j < batch; j++)
        {
          EsdItem *item = &items[i + j];
          size_t o = 12 + j * 16;
          toEbcdic (data + o, item->name, 8);
          data[o + 8] = item->typeCode;
          be24 (data + o + 9, item->address);
          if (item->typeCode == 0x01) /* LD (Label Definition) */
            {
              data[o + 12] = 0x40; /* flags: blank */
              data[o + 13] = 0x40;
              be16 (data + o + 14, item->ldid);
            }
          else if (item->typeCode == 0x02 || item->typeCode == 0x06) /* ER, WX */
            {
              data[o + 12] = 0x40;
              data[o + 13] = 0x40;
              data[o + 14] = 0x40;
              data[o + 15] = 0x40;
            }
          else /* SD, PC, CM, XD */
            {
              data[o + 12] = (unsigned char) item->flags;
              be24 (data + o + 13, item->length);
            }
        }
      makeCard (f, "ESD", data, 68, seqNum);
      seqNum += 1;
    }
  return seqNum;
}

/* Up to 56 bytes of object code per card. */
static asmint
writeTXT (FILE *f, asmint esdId, asmint address, const unsigned char *data,
          size_t dataLen, asmint seqNum)
{
  size_t offset;
  for (offset = 0; offset < dataLen; offset += 56)
    {
      unsigned char cardData[68];
      size_t chunk = (dataLen - offset) < 56 ? (dataLen - offset) : 56;
      blanks (cardData, 68);
      be24 (cardData + 1, address + (asmint) offset);
      be16 (cardData + 6, (asmint) chunk);
      be16 (cardData + 10, esdId);
      memcpy (cardData + 12, data + offset, chunk);
      makeCard (f, "TXT", cardData, 68, seqNum);
      seqNum += 1;
    }
  return seqNum;
}

typedef struct
{
  asmint relId;
  asmint posId;
  asmint flags;
  asmint address;
} RldEntry;

/* Up to 7 entries per card. */
static asmint
writeRLD (FILE *f, RldEntry *entries, size_t n, asmint seqNum)
{
  size_t i;
  if (n == 0)
    return seqNum;
  for (i = 0; i < n; i += 7)
    {
      unsigned char cardData[68];
      size_t batch = (n - i) < 7 ? (n - i) : 7;
      size_t j;
      blanks (cardData, 68);
      be16 (cardData + 6, (asmint) (batch * 8));
      for (j = 0; j < batch; j++)
        {
          RldEntry *r = &entries[i + j];
          size_t o = 12 + j * 8;
          be16 (cardData + o, r->relId);
          be16 (cardData + o + 2, r->posId);
          cardData[o + 4] = (unsigned char) r->flags;
          be24 (cardData + o + 5, r->address);
        }
      makeCard (f, "RLD", cardData, 68, seqNum);
      seqNum += 1;
    }
  return seqNum;
}

/*
 * The END record, with an optional entry point and assembler identification:
 *   1-3    entry address
 *   10-11  ESD ID of the entry point
 *   32     IDR type (blank = no IDR)
 *   33-51  translator identification
 */
static asmint
writeEND (FILE *f, int haveEntry, asmint entryEsdId, asmint entryAddr,
          const char *ident, asmint seqNum)
{
  unsigned char cardData[68];
  blanks (cardData, 68);
  if (haveEntry)
    {
      be24 (cardData + 1, entryAddr);
      be16 (cardData + 10, entryEsdId);
    }
  else
    {
      cardData[1] = 0x40;
      cardData[2] = 0x40;
      cardData[3] = 0x40;
    }
  cardData[32] = 0x40;
  if (ident != NULL)
    toEbcdic (cardData + 33, ident, 19);
  makeCard (f, "END", cardData, 68, seqNum);
  return seqNum + 1;
}

int
writeObjectModule (const char *filename, Val *metadataArg, Val *symtabArg,
                   Val *sectsArg, Val *entriesArg, Val *extrnsArg)
{
  EsdItem *esdItems;
  size_t nEsd = 0;
  Val *esdIdMap = val_dict ();
  /*
   * SECTIONS NEED THEIR OWN MAP, because `esdIdMap` is keyed by NAME and holds
   * sections, labels and external references in one namespace -- so an
   * `ENTRY X` inside `X CSECT` overwrote the SD's id with the LD's, and every
   * consumer that means "the ESD id of a control section" silently got the id
   * of a label instead:  the TXT card, the RLD posId and the END entry point.
   *
   * FCMTBLPG is the whole failure in four cards.  Its one card is `BMTBLE PG`,
   * which expands to `FCMTBLPG CSECT` / `ENTRY FCMTBLPG` / `EXTRN FCMBMTPG` /
   * `DC Y(FCMBMTPG)`, so the collision is guaranteed; the RLD came out
   * `R=3 P=2` naming the LD, lnk101 discarded it as not naming a section, and
   * the halfword stayed 0000 where the dump has A7EE.
   *
   * NOTE THAT NO LISTING COMPARISON CAN CATCH THIS.  An assembly listing prints
   * 0000 for an unresolved external too, so an entire corpus can be
   * byte-for-byte correct with every relocation in it thrown away.  Linking is
   * the only thing that reads these records at all.
   */
  Val *sectIdMap = val_dict ();
  asmint nextEsdId = 1;
  RldEntry *rldEntries;
  size_t nRld = 0;
  Val *relocs = val_dget (metadataArg, "relocations");
  size_t i;
  FILE *f;
  asmint seqNum = 1;

  esdItems = (EsdItem *) arena_alloc (
      ARENA_MAIN,
      (val_dlen (sectsArg) + val_dlen (entriesArg) + val_dlen (extrnsArg) + 1)
          * sizeof (EsdItem));

  /* Section Definitions (SD) for CSECTs. */
  for (i = 0; i < val_dlen (sectsArg); i++)
    {
      const char *sectName = val_dkey (sectsArg, i);
      Val *sectData = val_dval (sectsArg, i);
      EsdItem *item;
      if (val_dget_bool (sectData, "dsect", 0))
        continue;
      val_dset_int (esdIdMap, sectName, nextEsdId);
      val_dset_int (sectIdMap, sectName, nextEsdId);
      item = &esdItems[nEsd++];
      item->esdId = nextEsdId;
      item->name = sectName[0] == '\0' ? "#MAIN" : sectName;
      item->typeCode = 0x00; /* SD */
      /* `offset` is in halfwords; the card format uses bytes. */
      item->address = ASM_MUL (val_dget_int (sectData, "offset", 0), 2);
      item->flags = 0x00;
      item->length = val_dget_int (sectData, "used", 0);
      item->ldid = 0;
      nextEsdId += 1;
    }

  /* Entry points (LD). */
  for (i = 0; i < val_dlen (entriesArg); i++)
    {
      const char *entryName = val_dkey (entriesArg, i);
      Val *sym = val_dget (symtabArg, entryName);
      EsdItem *item;
      const char *sectName;
      if (sym == NULL)
        continue;
      /* Find the SD (CSECT) that contains this entry. */
      sectName = val_dget_str (sym, "section", "");
      item = &esdItems[nEsd++];
      item->esdId = nextEsdId;
      item->name = entryName;
      item->typeCode = 0x01; /* LD */
      item->address
          = ASM_MUL (ASM_ADD (val_dget_int (sym, "address", 0),
                              val_dget_int (val_dget (sectsArg, sectName),
                                            "offset", 0)),
                     2);
      item->ldid = val_dget_int (sectIdMap, sectName, 1); /* default first SD */
      item->length = 0;
      item->flags = 0;
      val_dset_int (esdIdMap, entryName, nextEsdId);
      nextEsdId += 1;
    }

  /* External References (ER). */
  for (i = 0; i < val_dlen (extrnsArg); i++)
    {
      const char *extName = val_dkey (extrnsArg, i);
      EsdItem *item = &esdItems[nEsd++];
      val_dset_int (esdIdMap, extName, nextEsdId);
      item->esdId = nextEsdId;
      item->name = extName;
      item->typeCode = 0x02; /* ER */
      item->address = 0;
      item->length = 0;
      item->flags = 0;
      item->ldid = 0;
      nextEsdId += 1;
    }

  /* Build the RLD entries. */
  rldEntries = (RldEntry *) arena_alloc (
      ARENA_MAIN, (val_len (relocs) + 1) * sizeof (RldEntry));
  for (i = 0; i < val_len (relocs); i++)
    {
      Val *r = val_get (relocs, i);
      const char *symbol = val_dget_str (r, "symbol", NULL);
      const char *section = val_dget_str (r, "section", NULL);
      const char *type = val_dget_str (r, "type", "");
      asmint rldFlags;
      if (symbol == NULL || section == NULL || !val_dhas (esdIdMap, symbol)
          || !val_dhas (sectIdMap, section))
        continue;
      if (strcmp (type, "Z") == 0 && val_dhas (r, "rldFlags"))
        {
          /* The caller has worked out whether this ZCON is code or data; see
             the note where it does.  0x04/0x10 patch BSR, 0x50 patches DSR. */
          rldFlags = val_dget_int (r, "rldFlags", 0x04);
        }
      else if (strcmp (type, "Z") == 0)
        {
          /* Note: the AP-101S object format documents ZCON flags as
             0x20/0x40/0x50, not 0x04.  Flag 0x04 works with the current
             LNK101S because it falls through to the 2-byte length case, but
             may not match the documented encoding. */
          rldFlags = 0x04;
        }
      else if (strcmp (type, "Y") == 0)
        {
          /* YCON: halfword address relocation.  BIT 7 IS THE SIGN, and a
             negative displacement is emitted as its MAGNITUDE with that bit set
             -- OBJECTGE.xpl's V flag, which lnk101's addrcon.py reads as
             "existing is the absolute value of a negative" and subtracts.
             Without it `DC Y(SYM-1)` links as SYM+1. */
          rldFlags = val_dget_bool (r, "negative", 0) ? 0x80 : 0x00;
        }
      else
        {
          /* Standard 4-byte address constant.  0x9C is that byte with the sign
             bit:  the field holds the MAGNITUDE of a negative displacement,
             which is what the contemporary listing shows. */
          rldFlags = val_dget_bool (r, "negative", 0) ? 0x9C : 0x1C;
        }
      rldEntries[nRld].relId = val_dget_int (esdIdMap, symbol, 0);
      rldEntries[nRld].posId = val_dget_int (sectIdMap, section, 0);
      rldEntries[nRld].flags = rldFlags;
      rldEntries[nRld].address = val_dget_int (r, "address", 0);
      nRld++;
    }

  f = fopen (filename, "wb");
  if (f == NULL)
    return 0;

  if (nEsd > 0)
    seqNum = writeESD (f, esdItems, nEsd, seqNum);

  for (i = 0; i < val_dlen (sectsArg); i++)
    {
      const char *sectName = val_dkey (sectsArg, i);
      Val *sectData = val_dval (sectsArg, i);
      asmint used;
      if (val_dget_bool (sectData, "dsect", 0))
        continue;
      used = val_dget_int (sectData, "used", 0);
      if (used > 0)
        {
          Val *memory = val_dget (sectData, "memory");
          size_t n = val_len (memory);
          if ((asmint) n > used)
            n = (size_t) used;
          seqNum = writeTXT (f, val_dget_int (sectIdMap, sectName, 1), 0,
                             val_bytes_ptr (memory), n, seqNum);
        }
    }

  if (nRld > 0)
    seqNum = writeRLD (f, rldEntries, nRld, seqNum);

  /* THE END RECORD CARRIES NO ENTRY POINT, because no source names one.  This
     used to take the first element of `entries' -- in the Python an arbitrary
     element of a SET -- and write that symbol's address into the END record.
     Two things were wrong with it.

     It was not even deterministic on the Python side: hash order varies from
     process to process, so BILDNEW5 assembled twice gave `END entry=0303C' one
     time and `END entry=034FA' the next, with all 5022 other lines of the
     normalized dump identical, and the value reached the linked image.

     And there was nothing to choose from in the first place.  An entry point
     comes from the END statement's operand, `END SYMBOL', and EVERY module
     here writes a bare END: 702 of 702 across OI340600, OI301700 and RUNASM,
     with 101 of them declaring ENTRY symbols that this code was picking among.
     A bare END specifies no entry point, and the loader takes the start of the
     first control section.

     If a source ever does name one, model101.c must capture it first -- `END'
     there simply breaks out of the loop and the operand is discarded -- and
     the value should be passed in rather than guessed. */
  writeEND (f, 0, 0, 0, "ASM101S 0.00", seqNum);

  fclose (f);
  return 1;
}
