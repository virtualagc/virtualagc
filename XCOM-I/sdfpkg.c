/*
 * Licensing:   Declared by the author (Ronald Burkey) to be Public Domain in
 *              the U.S., and can be freely distributed or modified in any
 *              desired way whatsoever.
 * Filename:    sdfpkg.c
 * Purpose:     C implementation of the MONITOR(22) services originally
 *              provided by SDFPKG.ASM.  See sdfpkg.h.
 * Contact:     info@sandroid.org
 * Mod history: 2026-08-02 RSB  Wrote, porting modules/{cmem,sdfpkg,sdf} from
 *                              Python.
 *
 * The Python in modules/ is the reference implementation for this file rather
 * than the other way round: it is the version that has been driven against
 * every SDF in the tree and against the whole of the PASS corpus.  Where this
 * file and it disagree, this file is wrong.
 *
 * Unlike the Python, the searches here walk the SDF's raw System/360-format
 * bytes directly, as SDFPKG.ASM did, instead of first parsing the file into a
 * convenient in-memory representation and using that as a search index.  The
 * results are identical -- both hand back a virtual-memory pointer and the
 * address the cell has been paged in at -- but there is no reason to port a
 * whole parser to serve as an index when the caller only ever reads the raw
 * bytes anyway.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "runtimeC.h"
#include "sdfpkg.h"

/*---------------------------------------------------------------------------
 * State.
 *
 * COMMTABL and the Paging Area both live in the XPL/I program's `memory`, so
 * there is nothing to allocate for them here.  What we do keep is the set of
 * open SDF files, since the FCB area a real MVS program would have used has no
 * counterpart.
 */

#define MAX_SDFS 64
#define MAX_NAME 16

typedef struct {
  char name[MAX_NAME];          /* As it appears in SDFLIB, less ".sdf"     */
  FILE *fp;
  long size;
} sdfFile_t;

static sdfFile_t sdfs[MAX_SDFS];
static int numSdfs = 0;         /* Ids are 1-based indices into sdfs[]      */

/* The Paging Area is not one contiguous run.  Mode 2 augments it, and the
 * caller's allocator (SPACELIB, via RECORD_CONSTANT(PGING,...)) hands back a
 * fresh area each time rather than extending the previous one, so the area is
 * a set of segments and a frame's address has to be looked up rather than
 * computed.  The original spliced fresh storage in the same way. */
#define MAX_SEGMENTS 64
typedef struct {
  uint32_t base;
  int count;
} segment_t;
static segment_t segments[MAX_SEGMENTS];
static int numSegments = 0;

static int initialized = 0;
static uint32_t commtabl = 0;   /* Address of COMMTABL within memory[]      */
static uint32_t apgarea = 0;    /* Address of the first Paging Area segment */
static uint32_t padAddr = 0;    /* Address of the Paging Area Directory     */
static int npages = 0;          /* Page frames in the Paging Area           */
static int padEntries = 0;
static int currentSdf = 0;      /* Id of the selected SDF, 0 for none       */
static uint32_t usecount = 0;   /* Ticks on every call; drives LRU          */
static int updat = 0;           /* From MISC: writing back is permitted     */

/* The Paging Area Directory is ours, not the caller's.  SDFPKG.ASM keeps it in
 * its own storage and INCSDF.xpl's MONITOR(22,0) call sets neither PNTR nor
 * ADDR, so there is nothing in COMMTABL that describes one.  (The Python port
 * does pass a PAD through PNTR/ADDR, but that is a convention of the port and
 * not of the interface.)  One entry per page frame, sized to outlast any
 * augment INCSDF is going to ask for. */
#define MAX_FRAMES 4096
static uint8_t internalPad[SDF_PAD_ENTRY_SIZE * MAX_FRAMES];
static const int padIsInternal = 1;

/*---------------------------------------------------------------------------
 * DATABUF, SDFPKG's internal data buffer.
 *
 * PASS4's SDFLIST and MISCELLANEOUS/HALSTAT.xpl both read SDFPKG's running
 * statistics out of it, and both find it the same way: call MONITOR(22,0),
 * then take the base from COMMTABL_FULLWORD(7) -- the ADDR field -- and
 * overlay three BASED arrays on it, DATABUF_BYTE, DATABUF_HALFWORD and
 * DATABUF_FULLWORD, so that a field can be reached at whatever width suits
 * it.  The offsets below are HALSTAT's, which names more fields than PASS4
 * uses.  SDFLIST reads the statistics at its STATISTICS: label *before*
 * calling mode 1, so they have to be current throughout, not merely at
 * termination.
 *
 * Until this existed, mode 0 left ADDR alone, so the base came out as 0 and
 * every statistic was read from low memory: SDFLIST's "NUMBER OF SDFPKG
 * LOCATES" was COREWORD(0), the MONITOR(23) identifier descriptor, and its
 * "GETMAINS" was the halfword at 36, which is part of MONITOR(13)'s NPVALS
 * pointer.
 *
 * The buffer is placed in the topmost memory region, which XCOM-I lays out
 * above the free-string area and leaves otherwise unoccupied.  It cannot go
 * in the caller's FCB area, plausible though that would be: HALSTAT calls
 * mode 0 with a Paging Area and no FCB area at all.
 */
#define DB_LOCCNT    0    /* fullword 0  Locate operations performed         */
#define DB_CURFCB    8    /* fullword 2  Current FCB                         */
#define DB_PADADDR   12   /* fullword 3  Paging Area Directory address       */
#define DB_ACOMMTAB  16   /* fullword 4  COMMTABL address                    */
#define DB_ROOT      24   /* fullword 6  Directory Root Cell pointer         */
#define DB_NUMGETM   36   /* halfword 18 GETMAINs issued                     */
#define DB_NUMOFPGS  38   /* halfword 19 Page frames in the Paging Area      */
#define DB_BASNPGS   40   /* halfword 20 Page frames in the base segment     */
#define DB_TOTFCBLN  52   /* fullword 13 Total FCB area length, bytes        */
#define DB_RESERVES  56   /* fullword 14 RESV dispositions honoured          */
#define DB_READS     60   /* fullword 15 Pages read in                       */
#define DB_WRITES    64   /* fullword 16 Pages written back                  */
#define DB_SLECTCNT  68   /* fullword 17 SDFs selected                       */
#define DB_FCBCNT    72   /* fullword 18 FCBs in use                         */
#define DB_VERSION   94   /* halfword 47 SDFPKG version                      */
#define SDF_DATABUF_SIZE 96

static uint32_t databuf = 0;    /* Its address, 0 until mode 0 places it     */
static uint32_t statLocates = 0, statReads = 0, statWrites = 0,
                statSelects = 0, statReserves = 0;
static uint32_t totalFcbLength = 0;

/*---------------------------------------------------------------------------
 * Abends.  The codes are SDFPKG.ASM's own, from its abend table, so that a
 * failure here is diagnosed with the same number the assembly would have used.
 */

static void
sdfAbend(int code, const char *why) {
  abend("SDFPKG abend %d: %s", code, why);
}

/*---------------------------------------------------------------------------
 * Big-endian accessors.  Everything in an SDF, and everything in COMMTABL, is
 * System/360 format.
 */

static uint32_t
getU32(uint8_t *buf, uint32_t at) {
  return ((uint32_t) buf[at] << 24) | ((uint32_t) buf[at + 1] << 16) |
         ((uint32_t) buf[at + 2] << 8) | (uint32_t) buf[at + 3];
}

static void
putU32(uint8_t *buf, uint32_t at, uint32_t value) {
  buf[at] = (value >> 24) & 0xFF;
  buf[at + 1] = (value >> 16) & 0xFF;
  buf[at + 2] = (value >> 8) & 0xFF;
  buf[at + 3] = value & 0xFF;
}

static uint16_t
getU16(uint8_t *buf, uint32_t at) {
  return ((uint16_t) buf[at] << 8) | (uint16_t) buf[at + 1];
}

static void
putU16(uint8_t *buf, uint32_t at, uint16_t value) {
  buf[at] = (value >> 8) & 0xFF;
  buf[at + 1] = value & 0xFF;
}

/* COMMTABL fields. */
static uint32_t ctU32(uint32_t off) { return getU32(memory, commtabl + off); }
static void ctPutU32(uint32_t off, uint32_t v) { putU32(memory, commtabl + off, v); }
static uint16_t ctU16(uint32_t off) { return getU16(memory, commtabl + off); }
static void ctPutU16(uint32_t off, uint16_t v) { putU16(memory, commtabl + off, v); }
static uint8_t ctU8(uint32_t off) { return memory[commtabl + off]; }

/*---------------------------------------------------------------------------
 * The Paging Area Directory.  Sixteen bytes per page frame:
 *      0   Address of the frame within memory[]
 *      4   Top byte 0x80 if the page has been modified, low three bytes the
 *          id of the SDF the frame holds a page of, or 0 if the frame is free
 *      8   Use count, for LRU
 *      12  Page number within the SDF, times 8
 *      14  Reserve count
 */

/* Address of page frame `i`, counting across the segments in the order they
 * were given to us. */
static uint32_t
frameAddress(int i) {
  int seg;
  for (seg = 0; seg < numSegments; seg++)
    {
      if (i < segments[seg].count)
        return segments[seg].base + (uint32_t) i * SDF_PAGE_SIZE;
      i -= segments[seg].count;
    }
  sdfAbend(4013, "page frame index is outside the Paging Area");
  return 0;
}

static uint8_t *
padBuf(void) {
  return padIsInternal ? internalPad : memory;
}

static uint32_t
padBase(int i) {
  return (padIsInternal ? 0 : padAddr) + i * SDF_PAD_ENTRY_SIZE;
}

static uint32_t padPageAddr(int i) { return getU32(padBuf(), padBase(i) + 0); }
static void padSetPageAddr(int i, uint32_t v) { putU32(padBuf(), padBase(i) + 0, v); }
static uint32_t padFcbaddr(int i) { return getU32(padBuf(), padBase(i) + 4); }
static void padSetFcbaddr(int i, uint32_t v) { putU32(padBuf(), padBase(i) + 4, v); }
static int padId(int i) { return padFcbaddr(i) & 0x00FFFFFF; }
static uint32_t padUsecount(int i) { return getU32(padBuf(), padBase(i) + 8); }
static void padSetUsecount(int i, uint32_t v) { putU32(padBuf(), padBase(i) + 8, v); }
static uint16_t padPageNo(int i) { return getU16(padBuf(), padBase(i) + 12); }
static void padSetPageNo(int i, uint16_t v) { putU16(padBuf(), padBase(i) + 12, v); }
static uint16_t padResucnt(int i) { return getU16(padBuf(), padBase(i) + 14); }
static void padSetResucnt(int i, uint16_t v) { putU16(padBuf(), padBase(i) + 14, v); }

static void
padSetId(int i, int id) {
  padSetFcbaddr(i, (padFcbaddr(i) & 0xFF000000) | (id & 0x00FFFFFF));
}

static int
padModified(int i) {
  return ((padFcbaddr(i) >> 24) & 0xFF) == 0x80;
}

static void
padSetModified(int i, int flag) {
  padSetFcbaddr(i, ((flag ? 0x80u : 0u) << 24) | (padFcbaddr(i) & 0x00FFFFFF));
}

static void
padMarkFree(int i) {
  padSetFcbaddr(i, 0);
  padSetPageAddr(i, 0);
  padSetUsecount(i, 0);
  padSetPageNo(i, 0);
  padSetResucnt(i, 0);
}

/* SETDISPS: a halfword count, so reserving saturates and abends rather than
 * wrapping round to zero and quietly unlocking a page the caller still holds;
 * releasing one that is already zero is likewise an abend rather than a
 * silent clamp. */
static void
padIncResucnt(int i) {
  uint16_t v = padResucnt(i);
  if (v >= 0x7FFF)
    sdfAbend(4003, "too many reserves for one page");
  padSetResucnt(i, v + 1);
}

static void
padDecResucnt(int i) {
  uint16_t v = padResucnt(i);
  if (v == 0)
    sdfAbend(4004, "too many releases for one page");
  padSetResucnt(i, v - 1);
}

/*---------------------------------------------------------------------------
 * SDF files.
 */

static void
sdfPath(char *out, size_t outSize, const char *name) {
  const char *dir = (sdfDirnameIn != NULL) ? sdfDirnameIn : "SDFLIB";
  snprintf(out, outSize, "%s/%s.sdf", dir, name);
}

/* SDFNAM is an 8-character blank-padded field and PASS3 keeps the padding in
 * the filename ("##COMPA .sdf"), but callers routinely build the name without
 * it.  Accept either spelling and settle on whichever exists on disk. */
static int
resolveSdfName(const char *raw, char *out, size_t outSize) {
  char trimmed[MAX_NAME], padded[MAX_NAME], path[1024];
  size_t i, n;
  FILE *fp;
  const char *candidates[3];

  strncpy(trimmed, raw, MAX_NAME - 1);
  trimmed[MAX_NAME - 1] = 0;
  n = strlen(trimmed);
  while (n > 0 && trimmed[n - 1] == ' ')
    trimmed[--n] = 0;
  strcpy(padded, trimmed);
  for (i = strlen(padded); i < 8; i++)
    padded[i] = ' ';
  padded[8] = 0;

  candidates[0] = raw;
  candidates[1] = trimmed;
  candidates[2] = padded;
  for (i = 0; i < 3; i++)
    {
      sdfPath(path, sizeof(path), candidates[i]);
      fp = fopen(path, "rb");
      if (fp != NULL)
        {
          fclose(fp);
          strncpy(out, candidates[i], outSize - 1);
          out[outSize - 1] = 0;
          return 1;
        }
    }
  return 0;
}

/* Returns the 1-based id, opening the file if this is the first sight of it. */
static int
openSdf(const char *name) {
  char path[1024];
  int i;

  for (i = 0; i < numSdfs; i++)
    if (!strcmp(sdfs[i].name, name))
      return i + 1;
  if (numSdfs >= MAX_SDFS)
    sdfAbend(4002, "too many SDFs open at once");
  sdfPath(path, sizeof(path), name);
  sdfs[numSdfs].fp = fopen(path, "rb");
  if (sdfs[numSdfs].fp == NULL)
    return 0;
  fseek(sdfs[numSdfs].fp, 0, SEEK_END);
  sdfs[numSdfs].size = ftell(sdfs[numSdfs].fp);
  strncpy(sdfs[numSdfs].name, name, MAX_NAME - 1);
  sdfs[numSdfs].name[MAX_NAME - 1] = 0;
  numSdfs++;
  return numSdfs;
}

static void
writePageBack(int i) {
  int id = padId(i);
  long where;
  if (id < 1 || id > numSdfs)
    return;
  where = (long) (padPageNo(i) / 8) * SDF_PAGE_SIZE;
  /* Reopening for update only when there is actually something to write
   * keeps a read-only SDF library usable for the common case. */
  {
    char path[1024];
    FILE *fp;
    sdfPath(path, sizeof(path), sdfs[id - 1].name);
    fp = fopen(path, "r+b");
    if (fp == NULL)
      sdfAbend(4007, "cannot reopen an SDF to write a modified page back");
    fseek(fp, where, SEEK_SET);
    fwrite(&memory[padPageAddr(i)], SDF_PAGE_SIZE, 1, fp);
    fclose(fp);
  }
  padSetModified(i, 0);
}

static int
findCachedPage(int id, int pageNumber) {
  int i;
  for (i = 0; i < npages; i++)
    if (padId(i) == id && (padPageNo(i) / 8) == pageNumber)
      return i;
  return -1;
}

static int
cachePage(int id, int pageNumber) {
  int i, freeIndex = -1, lru = -1;
  uint32_t pageAddr;
  size_t got;

  for (i = 0; i < npages; i++)
    if (padId(i) == 0)
      {
        freeIndex = i;
        break;
      }
  if (freeIndex < 0)
    {
      for (i = 0; i < npages; i++)
        if (padResucnt(i) == 0 && (lru < 0 || padUsecount(i) < padUsecount(lru)))
          lru = i;
      if (lru < 0)
        sdfAbend(4001, "every page frame is reserved; none can be evicted");
      if (getenv("SDFPKG_TRACE") != NULL)
        {
          fflush(stdout);
          fprintf(stderr, "SDFPKG:   EVICT frame %d (was page %d of sdf %d) "
                  "for page %d of sdf %d, %d frames\n",
                  lru, padPageNo(lru) / 8, padId(lru), pageNumber, id, npages);
          fflush(stderr);
        }
      if (padModified(lru))
        writePageBack(lru);
      freeIndex = lru;
    }

  pageAddr = frameAddress(freeIndex);
  memset(&memory[pageAddr], 0, SDF_PAGE_SIZE);
  fseek(sdfs[id - 1].fp, (long) pageNumber * SDF_PAGE_SIZE, SEEK_SET);
  got = fread(&memory[pageAddr], 1, SDF_PAGE_SIZE, sdfs[id - 1].fp);
  statReads++;
  (void) got;  /* A short final page is legitimate; the rest stays zero. */

  padSetPageAddr(freeIndex, pageAddr);
  padSetId(freeIndex, id);
  padSetModified(freeIndex, 0);
  padSetUsecount(freeIndex, usecount);
  padSetPageNo(freeIndex, pageNumber * 8);
  padSetResucnt(freeIndex, 0);
  return freeIndex;
}

/*---------------------------------------------------------------------------
 * Virtual-memory pointers.  A VMP is a page number in its top halfword and a
 * *signed* offset in its bottom one, and the offset is allowed to be negative
 * or to exceed a page, so normalizing is not merely a matter of masking.
 */

static uint32_t
resolveVmp(uint32_t vmp, int *padIndexOut) {
  int pageNumber = (vmp >> 16) & 0xFFFF;
  int offset = (int) (int16_t) (vmp & 0xFFFF);
  int idx;

  if (currentSdf == 0)
    sdfAbend(4010, "no SDF has been selected");

  if (offset < 0)
    {
      offset += SDF_PAGE_SIZE;
      pageNumber += 1;
    }
  else if (offset >= SDF_PAGE_SIZE)
    {
      pageNumber += offset / SDF_PAGE_SIZE;
      offset = offset % SDF_PAGE_SIZE;
    }

  if ((long) pageNumber * SDF_PAGE_SIZE >= sdfs[currentSdf - 1].size)
    sdfAbend(4005, "virtual-memory pointer is past the end of the SDF");

  idx = findCachedPage(currentSdf, pageNumber);
  if (idx < 0)
    idx = cachePage(currentSdf, pageNumber);
  else
    padSetUsecount(idx, usecount);

  if (padIndexOut != NULL)
    *padIndexOut = idx;
  return frameAddress(idx) + offset;
}

/* Reading fields of the SDF by VMP, for the searches. */
static uint32_t sdfU32(uint32_t vmp) { return getU32(memory, resolveVmp(vmp, NULL)); }
static uint16_t sdfU16(uint32_t vmp) { return getU16(memory, resolveVmp(vmp, NULL)); }
static uint8_t sdfU8(uint32_t vmp) { return memory[resolveVmp(vmp, NULL)]; }

/* VMP arithmetic, normalizing as parsePointer does. */
static uint32_t
vmpPlus(uint32_t vmp, int delta) {
  int page = (vmp >> 16) & 0xFFFF;
  int offset = (int) (int16_t) (vmp & 0xFFFF);
  offset += delta;
  while (offset < 0)
    {
      offset += SDF_PAGE_SIZE;
      page -= 1;
    }
  while (offset >= SDF_PAGE_SIZE)
    {
      offset -= SDF_PAGE_SIZE;
      page += 1;
    }
  return ((uint32_t) page << 16) | (uint32_t) offset;
}

static void
applyDisposition(int idx, int disp) {
  /* SETDISPS's own order, CHKMODF then CHKRELS then CHKRESV.  It matters when
   * both RELS and RESV are asked for at once: releasing first means a page
   * whose count is already zero abends, rather than being incremented and
   * decremented back to zero unnoticed. */
  if (disp & SDF_DISP_MODF)
    {
      if (!updat)
        sdfAbend(4008, "MODF requested but the SDF was not opened for update");
      padSetModified(idx, 1);
    }
  if (disp & SDF_DISP_RELS)
    padDecResucnt(idx);
  if (disp & SDF_DISP_RESV)
    {
      padIncResucnt(idx);
      statReserves++;
    }
}

/*---------------------------------------------------------------------------
 * Directory navigation.  Offsets are from the SDL Interface Control Document,
 * cross-checked against modules/sdf/sdf/sdf.py which is what actually reads
 * every SDF in the tree.
 */

/* The Phase 3 version number is the halfword at the very start of page 0,
 * which the assembly calls SDFVERS. */
#define MDC_PHASE3VERSIONNUMBER 0
#define MDC_PDIRECTORYROOTCELL 8

#define DRC_FLAGFIELD 0             /* Halfword */
#define DRC_NUMBEROFBLOCKINDICES 16
#define DRC_NUMBEROFSYMBOLS 18
#define DRC_PHEADOFBLOCKINDEXTABLE 20
#define DRC_PFIRSTSYMBOLINDEXTABLEENTRY 36
#define DRC_VALUEOFTHEFIRSTISNINFILE 52   /* Halfword */
#define DRC_VALUEOFTHELASTISNINFILE 54    /* Halfword */
#define DRC_PFIRSTSTATEMENTINDEXTABLEENTRY 60
#define DRC_PINITIALIZATIONTABLE 156

/* Bit 0 of the Directory Root Cell's flag field, SRN_FLAG.  It decides the
 * width of a Statement Index Table entry, so nothing can be indexed in that
 * table without consulting it first. */
#define DRC_FLAG_SRN 0x8000

/* Block Index Table entries are 12 bytes: an 8-character CSECT name and a
 * pointer to the Block Data Cell.  Symbol Index Table entries are likewise 12:
 * the first 8 characters of the name and a pointer to the Symbol Data Cell.
 * Block and symbol numbers alike are 1-based. */
#define INDEX_ENTRY_SIZE 12

/* Symbol Data Cell. */
#define SDC_BLOCKINDEXNUMBER 0      /* Halfword */
#define SDC_SYMBOLCLASS 6           /* Byte     */
#define SDC_SYMBOLTYPE 7            /* Byte     */
#define SDC_FLAGBITS 8              /* Fullword */
#define SDC_LENGTHOFNAME 12         /* Byte     */
#define SDC_CONTINUATIONOFNAME 24   /* Text, lengthOfName - 8 bytes */

/* Block Data Cell. */
#define BDC_INDEXTOFIRSTSYMBOL 32   /* Halfword */
#define BDC_INDEXTOLASTSYMBOL 34    /* Halfword */
#define BDC_LENGTHOFNAME 44         /* Byte */
#define BDC_NAME 45                 /* Text */

/* CHKMATCH's type filter. */
#define SCLASS_LABEL 2
#define SCLASS_FUNC 3
#define STYPE_IORS 8
#define SFLAG1_TEMPLATE 0x02
#define SFLAG1_UNQUALIFIED 0x01

/* The block a mode 8, 11 or 12 call last established, and the symbol a mode 13
 * call last returned, so that "successive Mode 13 calls are legal" resumes
 * rather than handing back the same symbol for ever. */
static uint32_t searchBlockCell = 0;
static int searchBlockValid = 0;
static int lastSymbolFound = 0;
static uint8_t lastSymbolName[32];
static int lastSymbolNameLen = -1;

static uint32_t
directoryRootCell(void) {
  return sdfU32(MDC_PDIRECTORYROOTCELL);
}

/* Refresh the DATABUF counters that change as work is done.  Called on every
 * service call rather than only at termination, since SDFLIST reads them at
 * its STATISTICS: label, before it asks SDFPKG to terminate. */
static void
databufSync(void) {
  if (databuf == 0)
    return;
  putU32(memory, databuf + DB_LOCCNT, statLocates);
  putU32(memory, databuf + DB_READS, statReads);
  putU32(memory, databuf + DB_WRITES, statWrites);
  putU32(memory, databuf + DB_SLECTCNT, statSelects);
  putU32(memory, databuf + DB_RESERVES, statReserves);
  putU32(memory, databuf + DB_CURFCB, currentSdf);
  putU32(memory, databuf + DB_FCBCNT, currentSdf ? 1 : 0);
  putU16(memory, databuf + DB_NUMOFPGS, npages);
}

static void
reply(int disp, uint32_t vmp) {
  int idx;
  uint32_t addr = resolveVmp(vmp, &idx);
  applyDisposition(idx, disp);
  statLocates++;
  ctPutU32(SDF_OFF_PNTR, vmp);
  ctPutU32(SDF_OFF_ADDR, addr);
  ctPutU16(SDF_OFF_CRETURN, 0);
  databufSync();
}

static void
fail(int code) {
  ctPutU16(SDF_OFF_CRETURN, code);
}

/* Copy EBCDIC text out of the SDF into a fixed-width COMMTABL field, padding
 * with EBCDIC blanks.  The padding matters: these fields are 32 bytes wide and
 * a caller reads only the first SYMBNLEN/BLKNLEN of them, so leaving the tail
 * of a previous, longer name in place would be invisible here but wrong
 * anywhere the length is not consulted. */
#define EBCDIC_BLANK 0x40

static void
putField(uint32_t fieldOffset, int fieldWidth, uint32_t textVmp, int length) {
  int i;
  if (length > fieldWidth)
    length = fieldWidth;
  for (i = 0; i < length; i++)
    memory[commtabl + fieldOffset + i] = sdfU8(vmpPlus(textVmp, i));
  for (; i < fieldWidth; i++)
    memory[commtabl + fieldOffset + i] = EBCDIC_BLANK;
}

/* A symbol's name is split: the first 8 characters live in its Symbol Index
 * Table entry and the remainder, if the name is longer than that, in the
 * Symbol Data Cell at offset 24. */
static void
putSymbolName(uint32_t indexEntry, uint32_t dataCell, int length) {
  int i, n = length;
  if (n > 8)
    n = 8;
  for (i = 0; i < n; i++)
    memory[commtabl + SDF_OFF_SYMBNAM + i] = sdfU8(vmpPlus(indexEntry, i));
  for (; i < length && i < 32; i++)
    memory[commtabl + SDF_OFF_SYMBNAM + i] =
        sdfU8(vmpPlus(dataCell, SDC_CONTINUATIONOFNAME + i - 8));
  for (; i < 32; i++)
    memory[commtabl + SDF_OFF_SYMBNAM + i] = EBCDIC_BLANK;
}

/* SDFPKG.ASM's CHKMATCH type filter, transcribed from SDFPKG.bal's CHKTYPE:
 *
 *      CHKTYPE  CLI   FIRST,1        IF IN FIRST MODE, TAKE IT AND GO
 *               BE    SYMFOUND
 *               CLI   CLASS,2
 *               BNE   NOT2
 *               CLI   TYPE,8
 *               BE    SKIPIT         EQUATE EXTERNAL
 *      NOT2     CLI   CLASS,3        NO PROBLEMS IF CLASSES 1,2 OR 3
 *               BNH   SYMFOUND
 *               TM    FLAG1,X'03'    IS IT AN UNQUALIFIED STRUC TERMINAL?
 *               BC    5,SYMFOUND     OR A TEMPLATE HEADER???
 *
 * "BC 5" branches on condition codes 1 and 3, i.e. on "some of the tested bits
 * are set" and on "all of them are", so the final test accepts whenever
 * FLAG1 & 0x03 is non-zero.  That is the opposite of the User's Guide's
 * description of the same algorithm; the assembly is what ran, so it wins.
 */
static int
chkMatch(uint32_t cell) {
  int symbolClass = sdfU8(vmpPlus(cell, SDC_SYMBOLCLASS));
  int symbolType = sdfU8(vmpPlus(cell, SDC_SYMBOLTYPE));
  int flag1;
  if (symbolClass == SCLASS_LABEL && symbolType == STYPE_IORS)
    return 0;                                  /* EQUATE EXTERNAL */
  if (symbolClass <= SCLASS_FUNC)
    return 1;
  flag1 = (sdfU32(vmpPlus(cell, SDC_FLAGBITS)) >> 24) & 0xFF;
  return 0 != (flag1 & (SFLAG1_TEMPLATE | SFLAG1_UNQUALIFIED));
}

/* Does symbol number `symbno` have the given name?  Compared in EBCDIC, since
 * that is how both the SDF and COMMTABL hold it. */
static int
symbolNameIs(uint32_t entry, uint32_t cell, const uint8_t *name, int nameLen) {
  int i, length = sdfU8(vmpPlus(cell, SDC_LENGTHOFNAME));
  if (length != nameLen)
    return 0;
  for (i = 0; i < length && i < 8; i++)
    if (sdfU8(vmpPlus(entry, i)) != name[i])
      return 0;
  for (i = 8; i < length; i++)
    if (sdfU8(vmpPlus(cell, SDC_CONTINUATIONOFNAME + i - 8)) != name[i])
      return 0;
  return 1;
}

/* A name supplied to us in COMMTABL, honouring its length field.  SYMBNAM is a
 * fixed 32-byte area and callers write only as many characters as the name
 * has, leaving whatever was there before in the rest -- "IA" over a previous
 * "ASTRUCTURE" leaves "IATRUCTURE" -- so the length is the only thing that
 * says where the name ends.  That is why CHKMATCH loads SYMBNLEN first. */
static int
inputName(uint32_t nameOffset, uint32_t lengthOffset, uint8_t *out) {
  int length = memory[commtabl + lengthOffset];
  int i;
  if (length <= 0 || length > 32)
    length = 32;
  for (i = 0; i < length; i++)
    out[i] = memory[commtabl + nameOffset + i];
  return length;
}

/*---------------------------------------------------------------------------
 * The services.
 */

uint32_t
sdfpkgInitialize(uint32_t commtablAddress) {
  uint16_t misc;
  int i;

  if (initialized)
    sdfAbend(4017, "MONITOR(22,0) called twice without an intervening mode 1");

  commtabl = commtablAddress;
  if (getenv("SDFPKG_TRACE") != NULL)
    {
      fflush(stdout);
      fprintf(stderr, "SDFPKG: mode 0 (initialize)\n");
      fflush(stderr);
    }
  misc = ctU16(SDF_OFF_MISC);
  updat = (misc & 0x02) != 0;

  padAddr = 0;
  padEntries = MAX_FRAMES;

  npages = ctU16(SDF_OFF_NPAGES);
  if (npages == 0)
    sdfAbend(4013, "a Paging Area of no pages was requested");
  apgarea = ctU32(SDF_OFF_APGAREA);
  if (apgarea == 0)
    sdfAbend(4014, "MONITOR(22,0) with no Paging Area is not supported");
  if (padEntries < npages)
    sdfAbend(4014, "the Paging Area Directory is smaller than the Paging Area");

  totalFcbLength = ctU16(SDF_OFF_NBYTES);
  if (ctU32(SDF_OFF_AFCBAREA) > 0 && ctU16(SDF_OFF_NBYTES) == 0)
    sdfAbend(4015, "an FCB area of no bytes was requested");

  /* Initializing means starting with nothing cached.  The caller's PAD
   * outlives any one of these sessions, and ids are handed out from 1 again,
   * so an inherited entry would not merely be stale: it could be mistaken for
   * a page of the newly selected SDF. */
  for (i = 0; i < padEntries; i++)
    padMarkFree(i);

  segments[0].base = apgarea;
  segments[0].count = npages;
  numSegments = 1;

  currentSdf = 0;
  usecount = 0;
  initialized = 1;

  /* Lay DATABUF at the base of the topmost memory region and report it in
   * ADDR, which is where SDFLIST and HALSTAT go looking for it. */
  databuf = memoryRegions[6].start;  /* XCOM-I always emits 0..6. */
  memset(&memory[databuf], 0, SDF_DATABUF_SIZE);
  statLocates = statReads = statWrites = statSelects = statReserves = 0;
  putU32(memory, databuf + DB_ACOMMTAB, commtabl);
  putU32(memory, databuf + DB_PADADDR, padIsInternal ? 0 : padAddr);
  putU32(memory, databuf + DB_TOTFCBLN, totalFcbLength);
  putU16(memory, databuf + DB_BASNPGS, npages);
  putU16(memory, databuf + DB_NUMGETM, 0);  /* Nothing here does a GETMAIN. */
  databufSync();

  ctPutU16(SDF_OFF_CRETURN, 0);
  ctPutU32(SDF_OFF_APGAREA, 0);
  ctPutU32(SDF_OFF_AFCBAREA, 0);
  ctPutU16(SDF_OFF_NBYTES, 0);
  ctPutU16(SDF_OFF_NPAGES, padEntries);
  ctPutU32(SDF_OFF_ADDR, databuf);
  return 0;
}

/* Mode 4, and the SELECT disposition, which for modes 5 and 7-17 means "select
 * the SDF named in SDFNAM first, then do the operation". */
static int
selectSdf(void) {
  char raw[MAX_NAME], name[MAX_NAME];
  int i, id;

  memcpy(raw, &memory[commtabl + SDF_OFF_SDFNAM], 8);
  raw[8] = 0;
  for (i = 0; i < 8; i++)
    raw[i] = (char) ebcdicToAscii[(uint8_t) raw[i]];

  if (!resolveSdfName(raw, name, sizeof(name)))
    {
      fail(8);
      return 0;
    }
  id = openSdf(name);
  if (id == 0)
    {
      fail(8);
      return 0;
    }

  /* SELECT.bal also reports the member's revision and catenation levels, in
   * BLKNO and SYMBNO.  Both come from the z/OS PDS directory entry, which a
   * plain file in an SDF library has not got, so we report what GETRVL reports
   * when there is no revision level to be had. */
  /* BLKNO carries the revision level as two EBCDIC characters, not as a
   * number, so "no revision level" is the characters "00" and not binary
   * zero -- which would render in the report as two NULs.  The catenation
   * level in SYMBNO really is numeric. */
  ctPutU16(SDF_OFF_BLKNO, 0xF0F0);
  ctPutU16(SDF_OFF_SYMBNO, 0);

  currentSdf = id;
  statSelects++;
  /* DATABUF's VERSION is the selected SDF's Phase 3 version, which is what
   * HALSTAT gates on with "IF VERSION >= 25". */
  if (databuf != 0)
    putU16(memory, databuf + DB_VERSION, sdfU16(MDC_PHASE3VERSIONNUMBER));
  databufSync();
  ctPutU16(SDF_OFF_CRETURN, 0);
  return 1;
}

uint32_t
sdfpkgService(uint32_t mode) {
  int disp = (mode >> 28) & 0xF;
  int modeNumber = mode & 0xFFFF;

  int traceMode = 0;
  usecount++;

  if (getenv("SDFPKG_TRACE") != NULL)
    {
      fflush(stdout);
      fprintf(stderr, "SDFPKG: mode %d disp %d BLKNO %d SYMBNO %d PNTR %08X"
              " NPAGES %d APGAREA %06X\n",
              modeNumber, disp, ctU16(SDF_OFF_BLKNO), ctU16(SDF_OFF_SYMBNO),
              ctU32(SDF_OFF_PNTR), ctU16(SDF_OFF_NPAGES),
              ctU32(SDF_OFF_APGAREA));
      fflush(stderr);
    }
  traceMode = modeNumber;
  (void) traceMode;

  if (!initialized)
    sdfAbend(4009, "a MONITOR(22) service was asked for before MONITOR(22,0)");

  switch (modeNumber)
    {
    case 1:                     /* Terminate */
      {
        int i;
        for (i = 0; i < npages; i++)
          if (padModified(i))
            writePageBack(i);
        for (i = 0; i < numSdfs; i++)
          if (sdfs[i].fp != NULL)
            {
              fclose(sdfs[i].fp);
              sdfs[i].fp = NULL;
            }
        numSdfs = 0;
        currentSdf = 0;
        numSegments = 0;
        npages = 0;
        initialized = 0;
        ctPutU16(SDF_OFF_CRETURN, 0);
        return 0;
      }

    case 2:                     /* Augment the Paging Area and/or FCB area */
      {
        uint32_t newArea = ctU32(SDF_OFF_APGAREA);
        int more = ctU16(SDF_OFF_NPAGES);
        /* The original GETMAINed fresh storage and spliced it in.  There is no
         * allocator here, so an augment can only be honoured when the new area
         * abuts the one we already have; anything else abends rather than
         * being quietly ignored, so a genuine shortfall is noticed instead of
         * turning into silent corruption later.  NPAGES of zero means "no
         * action for the Paging Area" whatever APGAREA says. */
        if (more != 0)
          {
            if (newArea == 0)
              sdfAbend(4013, "augment of the Paging Area with no area given");
            if (npages + more > padEntries)
              sdfAbend(4013, "augment would outgrow the Paging Area Directory");
            if (numSegments >= MAX_SEGMENTS)
              sdfAbend(4013, "too many Paging Area augments");
            segments[numSegments].base = newArea;
            segments[numSegments].count = more;
            numSegments++;
            npages += more;
          }
        /* An FCB augment is accepted and merely accounted for: we keep the
         * SDFs' metadata in our own structures rather than in an FCB area. */
        if (ctU16(SDF_OFF_NBYTES) != 0 && ctU32(SDF_OFF_AFCBAREA) == 0)
          sdfAbend(4015, "augment of the FCB area with no area given");

        ctPutU16(SDF_OFF_CRETURN, 0);
        ctPutU32(SDF_OFF_APGAREA, 0);
        ctPutU32(SDF_OFF_AFCBAREA, 0);
        ctPutU16(SDF_OFF_NBYTES, 0);
        ctPutU16(SDF_OFF_NPAGES, padEntries - npages);
        return 0;
      }

    case 4:                     /* Select an SDF */
      selectSdf();
      if (getenv("SDFPKG_TRACE") != NULL)
        {
          fflush(stdout);
          fprintf(stderr, "SDFPKG:   mode 4 -> CRETURN %d\n",
                  ctU16(SDF_OFF_CRETURN));
          fflush(stderr);
        }
      return 0;

    default:
      break;
    }

  /* From here on the SELECT disposition applies. */
  if ((disp & SDF_DISP_SELECT) && !selectSdf())
    return 0;

  switch (modeNumber)
    {
    case 5:                     /* Locate by virtual-memory pointer */
      reply(disp, ctU32(SDF_OFF_PNTR));
      return 0;

    case 6:                     /* Set disposition parameters */
      /* SETDISPS.  There is no locate here: the disposition bits in the mode
       * word are applied to the page that the previous locate left addressed,
       * which is the one PNTR still names.  Every other mode reaches
       * `applyDisposition` through `reply`, so routing this through `reply`
       * too both applies them and leaves ADDR consistent with PNTR, in case
       * honouring RESV moved the page.  PASS4 calls it after a mode 15 to
       * reserve a block node's page while it works from that node. */
      reply(disp, ctU32(SDF_OFF_PNTR));
      return 0;

    case 7:                     /* Locate the Directory Root Cell */
      reply(disp, directoryRootCell());
      return 0;

    case 8:                     /* Locate a block by number */
      {
        uint32_t drc = directoryRootCell();
        int blkno = ctU16(SDF_OFF_BLKNO);
        int count = sdfU16(vmpPlus(drc, DRC_NUMBEROFBLOCKINDICES));
        uint32_t table, entry;
        if (blkno < 1 || blkno > count)
          {
            fail(16);
            return 0;
          }
        table = sdfU32(vmpPlus(drc, DRC_PHEADOFBLOCKINDEXTABLE));
        entry = vmpPlus(table, (blkno - 1) * INDEX_ENTRY_SIZE);
        {
          uint32_t cell = sdfU32(vmpPlus(entry, 8));
          int nameLen = sdfU8(vmpPlus(cell, BDC_LENGTHOFNAME));
          searchBlockCell = cell;
          searchBlockValid = 1;
          lastSymbolFound = 0;
          lastSymbolNameLen = -1;
          memory[commtabl + SDF_OFF_BLKNLEN] = nameLen;
          putField(SDF_OFF_CSECTNAM, 8, entry, 8);
          putField(SDF_OFF_BLKNAM, 32, vmpPlus(cell, BDC_NAME), nameLen);
          reply(disp, cell);
        }
        return 0;
      }

    case 9:                     /* Locate a symbol by number */
      {
        uint32_t drc = directoryRootCell();
        int symbno = ctU16(SDF_OFF_SYMBNO);
        int count = sdfU16(vmpPlus(drc, DRC_NUMBEROFSYMBOLS));
        uint32_t table, entry;
        if (symbno < 1 || symbno > count)
          {
            fail(20);
            return 0;
          }
        table = sdfU32(vmpPlus(drc, DRC_PFIRSTSYMBOLINDEXTABLEENTRY));
        entry = vmpPlus(table, (symbno - 1) * INDEX_ENTRY_SIZE);
        {
          uint32_t cell = sdfU32(vmpPlus(entry, 8));
          int nameLen = sdfU8(vmpPlus(cell, SDC_LENGTHOFNAME));
          /* INCSDF reads the name and the owning block back out of COMMTABL
           * in order to enter the symbol, so a locate that reported only
           * PNTR and ADDR would leave it working from whatever the previous
           * call had left behind. */
          memory[commtabl + SDF_OFF_SYMBNLEN] = nameLen;
          putSymbolName(entry, cell, nameLen);
          ctPutU16(SDF_OFF_BLKNO, sdfU16(vmpPlus(cell, SDC_BLOCKINDEXNUMBER)));
          reply(disp, cell);
        }
        return 0;
      }

    case 13:                    /* Find a symbol by name within the block */
      {
        uint32_t drc, table, entry, cell;
        uint8_t name[32];
        int nameLen, first, last, symbno, startAfter = 0, i, same;

        if (!searchBlockValid)
          /* "A Mode 13 call must have been preceded at some point by a Mode
           * 8, 11, or 12 call."  SYMBSRCH checks SAVFSYMB and takes ABEND8. */
          sdfAbend(4020, "mode 13 with no block previously specified");

        nameLen = inputName(SDF_OFF_SYMBNAM, SDF_OFF_SYMBNLEN, name);

        /* Successive calls for the same name resume after the last hit. */
        if (lastSymbolFound > 0 && lastSymbolNameLen == nameLen)
          {
            same = 1;
            for (i = 0; i < nameLen; i++)
              if (lastSymbolName[i] != name[i])
                {
                  same = 0;
                  break;
                }
            if (same)
              startAfter = lastSymbolFound;
          }

        drc = directoryRootCell();
        table = sdfU32(vmpPlus(drc, DRC_PFIRSTSYMBOLINDEXTABLEENTRY));
        first = sdfU16(vmpPlus(searchBlockCell, BDC_INDEXTOFIRSTSYMBOL));
        last = sdfU16(vmpPlus(searchBlockCell, BDC_INDEXTOLASTSYMBOL));
        if (first < startAfter + 1)
          first = startAfter + 1;
        for (symbno = first; symbno <= last; symbno++)
          {
            entry = vmpPlus(table, (symbno - 1) * INDEX_ENTRY_SIZE);
            cell = sdfU32(vmpPlus(entry, 8));
            if (symbolNameIs(entry, cell, name, nameLen) && chkMatch(cell))
              {
                int length = sdfU8(vmpPlus(cell, SDC_LENGTHOFNAME));
                lastSymbolFound = symbno;
                lastSymbolNameLen = nameLen;
                for (i = 0; i < nameLen; i++)
                  lastSymbolName[i] = name[i];
                memory[commtabl + SDF_OFF_SYMBNLEN] = length;
                putSymbolName(entry, cell, length);
                ctPutU16(SDF_OFF_SYMBNO, symbno);
                ctPutU16(SDF_OFF_BLKNO,
                         sdfU16(vmpPlus(cell, SDC_BLOCKINDEXNUMBER)));
                reply(disp, cell);
                return 0;
              }
          }
        lastSymbolFound = 0;
        lastSymbolNameLen = -1;
        fail(20);               /* Symbol not found */
        return 0;
      }

    /* Modes 15, 16 and 17 locate the *index-table entry* for a block, symbol
     * or statement, where modes 8, 9 and 10 locate the data cell the entry
     * points at.  PASS4 (SDFLIST) walks the index tables directly and so
     * wants the former. */

    case 15:                    /* Locate a block index-table entry by number */
      {
        uint32_t drc = directoryRootCell();
        int blkno = ctU16(SDF_OFF_BLKNO);
        int count = sdfU16(vmpPlus(drc, DRC_NUMBEROFBLOCKINDICES));
        uint32_t table, entry;
        if (blkno < 1 || blkno > count)
          {
            fail(16);
            return 0;
          }
        table = sdfU32(vmpPlus(drc, DRC_PHEADOFBLOCKINDEXTABLE));
        entry = vmpPlus(table, (blkno - 1) * INDEX_ENTRY_SIZE);
        /* Like mode 8, this establishes the block a subsequent mode 13 will
         * search, and so must discard any symbol a previous mode 13 found. */
        searchBlockCell = sdfU32(vmpPlus(entry, 8));
        searchBlockValid = 1;
        lastSymbolFound = 0;
        lastSymbolNameLen = -1;
        putField(SDF_OFF_CSECTNAM, 8, entry, 8);
        reply(disp, entry);
        return 0;
      }

    case 17:                    /* Locate a statement index-table entry */
      {
        uint32_t drc = directoryRootCell();
        int stmtno = ctU16(SDF_OFF_STMTNO);
        int firstISN = sdfU16(vmpPlus(drc, DRC_VALUEOFTHEFIRSTISNINFILE));
        int lastISN = sdfU16(vmpPlus(drc, DRC_VALUEOFTHELASTISNINFILE));
        uint32_t table = sdfU32(vmpPlus(drc, DRC_PFIRSTSTATEMENTINDEXTABLEENTRY));
        int hasSRNs = 0 != (sdfU16(vmpPlus(drc, DRC_FLAGFIELD)) & DRC_FLAG_SRN);
        /* An entry is a 4-byte pointer to the statement data, preceded by a
         * 6-character SRN and a halfword INCLUDE count when the SDF carries
         * SRNs at all.  Statement numbers are ISNs and do not start at 1. */
        int entrySize = hasSRNs ? 12 : 4;
        int index = stmtno - firstISN;
        uint32_t entry;
        if (table == 0 || index < 0 || stmtno > lastISN)
          {
            fail(36);           /* Statement number out of range */
            return 0;
          }
        entry = vmpPlus(table, index * entrySize);
        if (hasSRNs)
          {
            putField(SDF_OFF_SREFNO, 6, entry, 6);
            ctPutU16(SDF_OFF_INCLCNT, sdfU16(vmpPlus(entry, 6)));
          }
        reply(disp, entry);
        return 0;
      }

    case 18:                    /* Find the INITIAL data for a given symbol */
      {
        /* CR13079's mode, not the "deselect an SDF" that the SDFPKG User's
         * Guide (SFOC-PASS0092, 02/08/99) gives as mode 18 for the FSWAT C
         * build.  The assembly gained this one three months after that guide,
         * and it is the assembly being reproduced here.
         *
         *     INITDATA B     SYMB             - get the symbol's RELADDR
         *     GETINIT  L     R1,INITPTR
         *              N     R4,=X'00FFFFFF'  - mask off SYMBLEN
         *              AR    R4,R4            - halfwords to bytes
         *              CALL  LOCATE
         *
         * The dispatcher gates it on "CLI SDFVERS+1,33 / BH NEWCHECK", so
         * only an SDF newer than version 33 has an initialization table. */
        uint32_t drc, table, entry, cell, initTable, vmp;
        int symbno, count, nameLen, reladdr;

        if (sdfU16(MDC_PHASE3VERSIONNUMBER) <= 33)
          sdfAbend(4016, "mode 18 on an SDF too old to hold INITIAL data");

        drc = directoryRootCell();
        symbno = ctU16(SDF_OFF_SYMBNO);
        count = sdfU16(vmpPlus(drc, DRC_NUMBEROFSYMBOLS));
        if (symbno < 1 || symbno > count)
          {
            fail(20);
            return 0;
          }
        table = sdfU32(vmpPlus(drc, DRC_PFIRSTSYMBOLINDEXTABLEENTRY));
        entry = vmpPlus(table, (symbno - 1) * INDEX_ENTRY_SIZE);
        cell = sdfU32(vmpPlus(entry, 8));
        /* SYMBLEN is the byte at offset 12 and RELADDR the three bytes that
         * follow it, so CR13079 loads the fullword and masks the top byte
         * away rather than reading three bytes as such. */
        reladdr = sdfU32(vmpPlus(cell, SDC_LENGTHOFNAME)) & 0x00FFFFFF;
        initTable = sdfU32(vmpPlus(drc, DRC_PINITIALIZATIONTABLE));
        vmp = vmpPlus(initTable, 2 * reladdr);

        /* INITDATA falls into the whole of mode 9 before locating the data,
         * so the symbol's own outputs are reported too; only ADDR and PNTR
         * refer to the initialization data, being the last LOCATE done. */
        nameLen = sdfU8(vmpPlus(cell, SDC_LENGTHOFNAME));
        memory[commtabl + SDF_OFF_SYMBNLEN] = nameLen;
        putSymbolName(entry, cell, nameLen);
        ctPutU16(SDF_OFF_BLKNO, sdfU16(vmpPlus(cell, SDC_BLOCKINDEXNUMBER)));
        reply(disp, vmp);
        return 0;
      }

    default:
      /* Deliberately an abend rather than a quiet no-op.  A stub that returns
       * without setting CRETURN leaves the previous call's values in place and
       * therefore reads as success, which is exactly how the Python version's
       * unimplemented modes managed to look as though they worked. */
      abend("SDFPKG: MONITOR(22,%d) is not yet ported to C", modeNumber);
      return 0;
    }
}

void
sdfpkgTerminate(void) {
  int i;
  if (!initialized)
    return;
  for (i = 0; i < npages; i++)
    if (padModified(i))
      writePageBack(i);
  for (i = 0; i < numSdfs; i++)
    if (sdfs[i].fp != NULL)
      {
        fclose(sdfs[i].fp);
        sdfs[i].fp = NULL;
      }
  numSdfs = 0;
  initialized = 0;
}
