/*
 * monitor14.c  --  Emulates the z/OS MONITOR 14 SDF-write service,
 *                  targeting the synthetic flat-file SDF format.
 *
 * On z/OS, MONITOR 14 wrote compiler output pages into a true PDS member.
 * Here, the equivalent flat file (magic + index + page data) is maintained
 * as described in sdf_io.c / sdfpkg.py.
 *
 * Public functions:
 *
 *   MONITOR14_0(lastPage)    -- begin a new member; lastPage+1 pages follow
 *   MONITOR14_4(locAddr)     -- supply scratch buffer (first call) or one
 *                               data page at memory[locAddr] (subsequent calls)
 *   MONITOR14_8(memberName)  -- flush buffered pages to the SDF flat file;
 *                               returns 0 (new/unchanged) or 1 (replaced)
 *
 * Typical call sequence (from the original HAL/S pseudocode):
 *
 *   CALL MONITOR14_8(NAME);              // ignored – no prior MONITOR14_0
 *   CALL MONITOR14_0(LAST_PAGE);
 *   CALL MONITOR14_4(PAD_ADDR(MAX+1));  // scratch buffer
 *   DO I = 0 TO LAST_PAGE;
 *       CALL MONITOR14_4(LOCATE_PAGE(I));
 *   END;
 *   IF MONITOR14_8(NAME) THEN ...;      // 0=created/unchanged, 1=replaced
 */

#define _POSIX_C_SOURCE 200809L
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/* ------------------------------------------------------------------ */
/* Flat-file constants (must agree with sdf_io.c / sdfpkg.py)         */
/* ------------------------------------------------------------------ */

#define PAGE_SIZE        1680
#define NAME_LEN         8
#define FLAT_IDX_ENTRY   20          /* 8 name + 4 page_count + 8 pg0_offset */
#define FLAT_MAGIC_U32   0x53444600u

static const uint8_t FLAT_MAGIC_BYTES[4] = {0x53, 0x44, 0x46, 0x00};

/* ------------------------------------------------------------------ */
/* External memory model                                               */
/* ------------------------------------------------------------------ */

#define MEMORY_SIZE (1 << 24)
extern uint8_t memory[MEMORY_SIZE];  /* The memory model              */
char sdfName[32];                    /* Base name of the SDF          */

/* ------------------------------------------------------------------ */
/* Public state                                                        */
/* ------------------------------------------------------------------ */

uint32_t AREADBUF = 0;   /* address in memory[] of the scratch page   */

/* ------------------------------------------------------------------ */
/* Internal state                                                      */
/* ------------------------------------------------------------------ */

/* Upper bound on pages per member; generous enough for any real member. */
#define MAX_SDF_PAGES  4096

static bool     m14_ready        = false;
static bool     m14_scratch_done = false;
static uint32_t m14_last_page    = 0;
static uint32_t m14_page_addrs[MAX_SDF_PAGES];
static int      m14_pages_count  = 0;

/* ------------------------------------------------------------------ */
/* Big-endian helpers                                                  */
/* ------------------------------------------------------------------ */

static uint16_t m14_be16(const uint8_t *p)
{
    return (uint16_t)(((unsigned)p[0] << 8) | p[1]);
}

static uint32_t m14_be32(const uint8_t *p)
{
    return ((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|
           ((uint32_t)p[2]<< 8)| (uint32_t)p[3];
}

static uint64_t m14_be64(const uint8_t *p)
{
    return ((uint64_t)p[0]<<56)|((uint64_t)p[1]<<48)|
           ((uint64_t)p[2]<<40)|((uint64_t)p[3]<<32)|
           ((uint64_t)p[4]<<24)|((uint64_t)p[5]<<16)|
           ((uint64_t)p[6]<< 8)| (uint64_t)p[7];
}

static void m14_put_be16(uint8_t *p, uint16_t v)
{
    p[0] = (v >> 8) & 0xff;  p[1] = v & 0xff;
}

static void m14_put_be32(uint8_t *p, uint32_t v)
{
    p[0]=(v>>24)&0xff; p[1]=(v>>16)&0xff;
    p[2]=(v>> 8)&0xff; p[3]= v     &0xff;
}

static void m14_put_be64(uint8_t *p, uint64_t v)
{
    p[0]=(v>>56)&0xff; p[1]=(v>>48)&0xff;
    p[2]=(v>>40)&0xff; p[3]=(v>>32)&0xff;
    p[4]=(v>>24)&0xff; p[5]=(v>>16)&0xff;
    p[6]=(v>> 8)&0xff; p[7]= v     &0xff;
}

/* ------------------------------------------------------------------ */
/* Encode a member name as an 8-char, space-padded, non-null field.   */
/* ------------------------------------------------------------------ */

static void m14_name_to_field(const char *name, char out[NAME_LEN])
{
    memset(out, ' ', NAME_LEN);
    size_t n = strlen(name);
    if (n > NAME_LEN) n = NAME_LEN;
    memcpy(out, name, n);
}

/* ------------------------------------------------------------------ */
/* Content comparison                                                  */
/*                                                                     */
/* Returns true if the two page arrays are equivalent.  Before         */
/* comparing page 0 we mask out two regions that change on every       */
/* write regardless of logical content:                                */
/*                                                                     */
/*   bytes  0-1   PAGEZERO.version   (big-endian uint16)              */
/*   bytes 20-27  DROOTCEL.sdf_date  (big-endian uint32, 4 bytes)     */
/*                DROOTCEL.sdf_time  (big-endian uint32, 4 bytes)     */
/*                                                                     */
/* Layout (all big-endian, packed):                                    */
/*   PAGEZERO: version(2) + pad(2) + dir_fc_ptr(4) + droot_ptr(4) +  */
/*             dat_fc_ptr(4) = 16 bytes total.                        */
/*   DROOTCEL starts at page-0 byte 16.  sdf_date is at DROOTCEL+4   */
/*   (page-0 byte 20); sdf_time is at DROOTCEL+8 (page-0 byte 24).   */
/* ------------------------------------------------------------------ */

static bool m14_pages_equal(const uint8_t *new_pages, int np,
                             const uint8_t *old_pages, int op)
{
    if (np != op) return false;
    if (np == 0)  return true;

    size_t total = (size_t)np * PAGE_SIZE;

    /* Compare page 0 with volatile fields masked to zero */
    uint8_t n0[PAGE_SIZE], o0[PAGE_SIZE];
    memcpy(n0, new_pages, PAGE_SIZE);
    memcpy(o0, old_pages, PAGE_SIZE);
    memset(n0,      0, 2);   /* PAGEZERO.version  (bytes  0-1)  */
    memset(o0,      0, 2);
    memset(n0 + 20, 0, 8);  /* DROOTCEL.sdf_date (bytes 20-23) */
    memset(o0 + 20, 0, 8);  /* DROOTCEL.sdf_time (bytes 24-27) */
    if (memcmp(n0, o0, PAGE_SIZE) != 0) return false;

    /* Compare remaining pages verbatim */
    if (total > PAGE_SIZE)
        return memcmp(new_pages + PAGE_SIZE,
                      old_pages + PAGE_SIZE,
                      total - PAGE_SIZE) == 0;
    return true;
}

/* ------------------------------------------------------------------ */
/* Flat member descriptor used while building the output file          */
/* ------------------------------------------------------------------ */

typedef struct {
    char     name8[NAME_LEN]; /* 8-char space-padded, no null terminator */
    uint32_t page_count;
    uint8_t *data;            /* page_count × PAGE_SIZE bytes            */
    bool     free_data;       /* true → must free(data) when done        */
} M14Entry;

/* ------------------------------------------------------------------ */
/* Write all entries to the flat file.                                 */
/* Returns true on success.                                            */
/* ------------------------------------------------------------------ */

static bool m14_write_flat(const char *filename,
                           M14Entry   *entries,
                           uint32_t    n)
{
    FILE *f = fopen(filename, "wb");
    if (!f) return false;

    /* Header: magic + member count */
    uint8_t hdr[8];
    memcpy(hdr, FLAT_MAGIC_BYTES, 4);
    m14_put_be32(hdr + 4, n);
    if (fwrite(hdr, 1, 8, f) != 8) { fclose(f); return false; }

    /* Reserve space for index (will be back-filled below) */
    long idx_start = ftell(f);
    {
        uint8_t blank[FLAT_IDX_ENTRY];
        memset(blank, 0, FLAT_IDX_ENTRY);
        for (uint32_t i = 0; i < n; i++)
            (void)fwrite(blank, 1, FLAT_IDX_ENTRY, f);
    }

    /* Write member data; record the file offset of each member's page 0 */
    uint64_t *offsets = malloc(n * sizeof(uint64_t));
    if (!offsets) { fclose(f); return false; }

    for (uint32_t i = 0; i < n; i++) {
        offsets[i] = (uint64_t)ftell(f);
        size_t sz  = (size_t)entries[i].page_count * PAGE_SIZE;
        if (sz && fwrite(entries[i].data, 1, sz, f) != sz) {
            free(offsets); fclose(f); return false;
        }
    }

    /* Back-fill the index entries */
    for (uint32_t i = 0; i < n; i++) {
        uint8_t entry[FLAT_IDX_ENTRY];
        memcpy(entry, entries[i].name8, NAME_LEN);
        m14_put_be32(entry + 8,  entries[i].page_count);
        m14_put_be64(entry + 12, offsets[i]);
        fseek(f, idx_start + (long)(i * FLAT_IDX_ENTRY), SEEK_SET);
        (void)fwrite(entry, 1, FLAT_IDX_ENTRY, f);
    }

    free(offsets);
    fclose(f);
    return true;
}

/* ------------------------------------------------------------------ */
/* Free an array of M14Entry (their malloc'd data fields only)        */
/* ------------------------------------------------------------------ */

static void m14_free_entries(M14Entry *entries, uint32_t n)
{
    if (!entries) return;
    for (uint32_t i = 0; i < n; i++)
        if (entries[i].free_data) free(entries[i].data);
    free(entries);
}

/* ================================================================== */
/* EBCDIC → ASCII translation                                         */
/*                                                                     */
/* m14_asciiToEbcdic is an identical copy of asciiToEbcdic in         */
/* XCOM-I/runtimeC.c.  m14_ebcdicToAscii is its inverse, built at    */
/* first use: each EBCDIC byte value that is the image of ASCII code  */
/* a is mapped back to a; EBCDIC codes with no ASCII preimage become  */
/* ASCII space (0x20).                                                 */
/*                                                                     */
/* m14_translate_pages() walks the SDF virtual-memory structure in a  */
/* page buffer and translates every EBCDIC text field (block names,   */
/* CSECT names, symbol names, SRNs) to ASCII in-place.  The member   */
/* name itself is already ASCII and is never passed through here.     */
/* ================================================================== */

static const uint8_t m14_asciiToEbcdic[128] = {
  /* Identical to asciiToEbcdic[] in XCOM-I/runtimeC.c */
  0x00, 0x01, 0x02, 0x03, 0x37, 0x2d, 0x2e, 0x2f,
  0x16, 0x05, 0x25, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
  0x10, 0x11, 0x12, 0x13, 0x3c, 0x3d, 0x32, 0x26,
  0x18, 0x19, 0x3f, 0x27, 0x1c, 0x1d, 0x1e, 0x1f,
  0x40, 0x5A, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D,
  0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61,
  0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7,
  0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F,
  0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7,
  0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6,
  0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6,
  0xE7, 0xE8, 0xE9, 0xAD, 0xFE, 0xBD, 0x5F, 0x6D,
  0x4A, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
  0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96,
  0x97, 0x98, 0x99, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6,
  0xA7, 0xA8, 0xA9, 0xC0, 0x4F, 0xD0, 0x5F, 0x07
};

static uint8_t m14_ebcdicToAscii[256];  /* built from table above */

static void m14_init_xlate(void)
{
    static bool built = false;
    if (built) return;
    memset(m14_ebcdicToAscii, ' ', 256);   /* unmapped EBCDIC → space */
    for (int a = 0; a < 128; a++)
        m14_ebcdicToAscii[m14_asciiToEbcdic[a]] = (uint8_t)a;
    built = true;
}

/* Translate a fixed-length EBCDIC text field to ASCII in-place. */
static void m14_xlate(uint8_t *p, size_t len)
{
    for (size_t i = 0; i < len; i++)
        p[i] = m14_ebcdicToAscii[p[i]];
}

/* Resolve a virtual pointer (page<<16 | offset) into the raw page buffer.
   Returns NULL for the null pointer or any out-of-range address. */
static uint8_t *m14_vp_resolve(uint8_t *pages, int np, uint32_t vp)
{
    if (vp == 0) return NULL;
    uint32_t pg  = (vp >> 16) & 0xFFFFu;
    uint32_t off =  vp        & 0xFFFFu;
    if ((int)pg >= np || off >= PAGE_SIZE) return NULL;
    return pages + pg * (uint32_t)PAGE_SIZE + off;
}

/* Advance a sequential-array virtual pointer by one node of node_size bytes.
   Mirrors the SDF paging allocator: if the new offset reaches PAGE_SIZE the
   pointer moves to offset 0 of the next page (no partial-page node). */
static uint32_t m14_vp_next(uint32_t vp, uint16_t node_size)
{
    uint32_t pg  = (vp >> 16) & 0xFFFFu;
    uint32_t off =  vp        & 0xFFFFu;
    off += node_size;
    if (off >= PAGE_SIZE) { pg++; off = 0; }
    return (pg << 16) | off;
}

/*
 * m14_translate_pages -- walk the SDF virtual-memory structure and
 * translate every EBCDIC text field to ASCII in-place.
 *
 * Cell layout (from original BAL DSECTs, all big-endian on-disk):
 *
 *   PAGEZERO  (16 bytes at page-0 offset 0):
 *     [8]  DROOTPTR (A) → virtual pointer to DROOTCEL
 *
 *   DROOTCEL (found via DROOTPTR):
 *     [0]  SDFFLAGS (2C) — bit 7 of byte 0 = HAS_SRNs
 *     [16] BLKNODES (H) — number of block nodes
 *     [18] SYMNODES (H) — number of symbol nodes
 *     [20] FBNPTR   (A) → first BLCKNODE
 *     [36] FSNPTR   (A) → first SYMBNODE
 *     [58] STMTNODE (H) — number of statement nodes
 *     [60] FSTNPTR  (A) → first STMTNOD1
 *     [68] SNELPTR  (A) → statement node extent list (STMTEXTF)
 *     [72] FIRSTSRN (CL8) ← EBCDIC
 *     [80] LASTSRN  (CL8) ← EBCDIC
 *
 *   BLCKNODE (12 bytes, sequential array from FBNPTR):
 *     [0]  CSCTNAME (CL8)     ← EBCDIC
 *     [8]  BLOCKPTR (A) → BLKTCELL
 *
 *   BLKTCELL (variable, reached via BLOCKPTR):
 *     [16] EXTPTR   (A) → SYMEXTF chain
 *     [44] BNAMELEN (C) — byte count of block name
 *     [45] BLKNAME  (variable, BNAMELEN bytes) ← EBCDIC
 *
 *   SYMBNODE (12 bytes, sequential array from FSNPTR):
 *     [0]  SYMBNAME (CL8)     ← EBCDIC
 *     [8]  SDCPTR   (A) → SYMBDC
 *
 *   SYMBDC (reached via SDCPTR):
 *     [12] SYMBLEN  (C) — total symbol name length
 *     [24] NAMECONT (variable, SYMBLEN-8 bytes) ← EBCDIC
 *
 *   SYMEXTF (reached via BLKTCELL.EXTPTR, linked via SUCCPTR):
 *     [0]  SUCCPTR  (F) → next SYMEXTF (0 = end)
 *     [4]  NEXTNTRY (H) — number of SYMEXTV entries
 *     SYMEXTV entries follow at [8], each 20 bytes:
 *       [4]  FSTSYMB (CL8) ← EBCDIC
 *       [12] LSTSYMB (CL8) ← EBCDIC
 *
 *   STMTNOD1 (12 bytes, sequential array from FSTNPTR, only when HAS_SRNs):
 *     [0]  SRN      (CL6)     ← EBCDIC
 *     [6]  INCOUNT  (CL2)     ← EBCDIC
 *
 *   STMTEXTF (reached via SNELPTR, linked via SUCCPTR1):
 *     [0]  SUCCPTR1 (F) → next STMTEXTF (0 = end)
 *     [4]  NXNTRY   (H) — number of STMTEXTV entries
 *     STMTEXTV entries follow at [8], each 20 bytes:
 *       [4]  FSTSRN  (CL8) ← EBCDIC
 *       [12] LSTSRN  (CL8) ← EBCDIC
 */
static void m14_translate_pages(uint8_t *pages, int np)
{
    if (np < 1) return;
    m14_init_xlate();

    /* --- Locate DROOTCEL via PAGEZERO.DROOTPTR at page-0 byte offset 8 --- */
    uint32_t droot_vp = m14_be32(pages + 8);
    uint8_t *dr = m14_vp_resolve(pages, np, droot_vp);
    if (!dr) return;

    /* Extract DROOTCEL fields */
    bool     has_srns  = (dr[0] & 0x80) != 0;  /* SDFFLAGS byte0 bit7  */
    uint16_t blk_nodes = m14_be16(dr + 16);     /* BLKNODES             */
    uint16_t sym_nodes = m14_be16(dr + 18);     /* SYMNODES             */
    uint32_t fbn_ptr   = m14_be32(dr + 20);     /* FBNPTR               */
    uint32_t fsn_ptr   = m14_be32(dr + 36);     /* FSNPTR               */
    uint16_t stmtnode  = m14_be16(dr + 58);     /* STMTNODE             */
    uint32_t fstn_ptr  = m14_be32(dr + 60);     /* FSTNPTR              */
    uint32_t snel_ptr  = m14_be32(dr + 68);     /* SNELPTR              */

    /* Translate FIRSTSRN (CL8 at dr+72) and LASTSRN (CL8 at dr+80) */
    m14_xlate(dr + 72, 8);
    m14_xlate(dr + 80, 8);

    /* --- Block nodes: BLCKNODE array (12 bytes each) from FBNPTR --- */
    uint32_t bn_vp = fbn_ptr;
    for (uint16_t b = 0; b < blk_nodes; b++, bn_vp = m14_vp_next(bn_vp, 12)) {
        uint8_t *bn = m14_vp_resolve(pages, np, bn_vp);
        if (!bn) break;

        /* CSCTNAME (CL8) at bn[0..7] */
        m14_xlate(bn, 8);

        /* Follow BLOCKPTR (bn[8..11]) → BLKTCELL */
        uint8_t *btc = m14_vp_resolve(pages, np, m14_be32(bn + 8));
        if (!btc) continue;

        /* BLKNAME (variable, BNAMELEN bytes) at btc[45] */
        uint8_t bname_len = btc[44];
        if (bname_len > 0 && bname_len <= 32)
            m14_xlate(btc + 45, bname_len);

        /* Walk this block's SYMEXT chain: EXTPTR at btc[16] */
        uint32_t ext_vp = m14_be32(btc + 16);
        while (ext_vp) {
            uint8_t *ef = m14_vp_resolve(pages, np, ext_vp);
            if (!ef) break;
            uint16_t nentries = m14_be16(ef + 4);    /* NEXTNTRY */
            uint16_t ef_off   = (uint16_t)(ext_vp & 0xFFFFu);
            for (uint16_t e = 0; e < nentries; e++) {
                /* Guard against running off the page */
                if ((uint32_t)ef_off + 8u + (uint32_t)(e + 1u) * 20u > PAGE_SIZE)
                    break;
                uint8_t *ev = ef + 8 + (size_t)e * 20;
                m14_xlate(ev + 4,  8);   /* FSTSYMB (CL8) */
                m14_xlate(ev + 12, 8);   /* LSTSYMB (CL8) */
            }
            ext_vp = m14_be32(ef);       /* SUCCPTR → next SYMEXTF */
        }
    }

    /* --- Symbol nodes: SYMBNODE array (12 bytes each) from FSNPTR --- */
    uint32_t sn_vp = fsn_ptr;
    for (uint16_t s = 0; s < sym_nodes; s++, sn_vp = m14_vp_next(sn_vp, 12)) {
        uint8_t *sn = m14_vp_resolve(pages, np, sn_vp);
        if (!sn) break;

        /* SYMBNAME (CL8) at sn[0..7] */
        m14_xlate(sn, 8);

        /* Follow SDCPTR (sn[8..11]) → SYMBDC */
        uint8_t *sdc = m14_vp_resolve(pages, np, m14_be32(sn + 8));
        if (!sdc) continue;

        /* NAMECONT at sdc[24], length = SYMBLEN (sdc[12]) minus 8 */
        uint8_t symb_len = sdc[12];
        if (symb_len > 8) {
            uint8_t cont_len = symb_len - 8;
            if (cont_len > 24) cont_len = 24;
            m14_xlate(sdc + 24, cont_len);
        }
    }

    /* --- Statement nodes: STMTNOD1 (12 bytes each) from FSTNPTR ---
       Only meaningful when HAS_SRNs; without SRNs nodes are 4 bytes and
       carry no text fields.                                             */
    if (has_srns && stmtnode > 0) {
        uint32_t tn_vp = fstn_ptr;
        for (uint16_t t = 0; t < stmtnode; t++, tn_vp = m14_vp_next(tn_vp, 12)) {
            uint8_t *tn = m14_vp_resolve(pages, np, tn_vp);
            if (!tn) break;
            m14_xlate(tn, 6);    /* SRN     (CL6) at tn[0..5] */
            m14_xlate(tn + 6, 2);/* INCOUNT (CL2) at tn[6..7] */
        }
    }

    /* --- Statement extent chain: STMTEXTF → STMTEXTV from SNELPTR --- */
    if (has_srns && snel_ptr) {
        uint32_t se_vp = snel_ptr;
        while (se_vp) {
            uint8_t *ef = m14_vp_resolve(pages, np, se_vp);
            if (!ef) break;
            uint16_t nentries = m14_be16(ef + 4);    /* NXNTRY */
            uint16_t ef_off   = (uint16_t)(se_vp & 0xFFFFu);
            for (uint16_t e = 0; e < nentries; e++) {
                if ((uint32_t)ef_off + 8u + (uint32_t)(e + 1u) * 20u > PAGE_SIZE)
                    break;
                uint8_t *ev = ef + 8 + (size_t)e * 20;
                m14_xlate(ev + 4,  8);   /* FSTSRN (CL8) */
                m14_xlate(ev + 12, 8);   /* LSTSRN (CL8) */
            }
            se_vp = m14_be32(ef);        /* SUCCPTR1 → next STMTEXTF */
        }
    }
}

/* ================================================================== */
/* Public functions                                                    */
/* ================================================================== */

/*
 * MONITOR14_0 -- begin a new member.
 *
 * lastPage+1 is the number of 1680-byte pages the member occupies in the
 * memory model.  Resets all internal state for a fresh write cycle.
 */
void MONITOR14_0(uint32_t lastPage)
{
    m14_last_page    = lastPage;
    m14_pages_count  = 0;
    m14_scratch_done = false;
    m14_ready        = true;
    AREADBUF         = 0;
}

/*
 * MONITOR14_4 -- supply the scratch buffer (first call) or a data page.
 *
 * First call:  locAddr is a 1680-byte area in memory[] free for our use;
 *              stored in AREADBUF.
 * Subsequent calls (lastPage+1 of them): locAddr is the address in
 *              memory[] of the next sequential 1680-byte SDF page.
 */
void MONITOR14_4(uint32_t locAddr)
{
    if (!m14_ready) return;

    if (!m14_scratch_done) {
        AREADBUF         = locAddr;
        m14_scratch_done = true;
        return;
    }

    if (m14_pages_count < MAX_SDF_PAGES)
        m14_page_addrs[m14_pages_count++] = locAddr;
}

/*
 * MONITOR14_8 -- flush the buffered member to the SDF flat file.
 *
 * memberName  : the HAL/S member name (up to 8 characters).
 *
 * Returns 0 if the member was newly created or its content was unchanged.
 * Returns 1 if the member already existed and its content has changed
 * (i.e., it was replaced and its version number incremented).
 *
 * If called before MONITOR14_0 or before the first MONITOR14_4 in this
 * cycle, the call is silently ignored and 0 is returned.
 */
uint32_t MONITOR14_8(const char *memberName)
{
    /* Ignore if the sequence MONITOR14_0 → MONITOR14_4 → ... hasn't run */
    if (!m14_ready || !m14_scratch_done) {
        m14_ready        = false;
        m14_scratch_done = false;
        return 0;
    }
    m14_ready        = false;
    m14_scratch_done = false;

    /* Build the SDF flat-file path: sdfName + ".sdf" */
    char filename[sizeof(sdfName) + 8];
    snprintf(filename, sizeof(filename), "%s.sdf", sdfName);

    /* Encode the member name as an 8-char space-padded key */
    char name8[NAME_LEN];
    m14_name_to_field(memberName, name8);

    int num_pages = m14_pages_count;   /* actual pages provided */

    /* Copy new page data out of memory[] into a contiguous buffer    */
    size_t new_sz   = (size_t)num_pages * PAGE_SIZE;
    uint8_t *new_data = (new_sz > 0) ? malloc(new_sz) : NULL;
    if (new_sz > 0 && !new_data) return 0;   /* out of memory        */

    for (int i = 0; i < num_pages; i++)
        memcpy(new_data + (size_t)i * PAGE_SIZE,
               &memory[m14_page_addrs[i]], PAGE_SIZE);

    /* Translate EBCDIC object-name fields in the page data to ASCII.  */
    m14_translate_pages(new_data, num_pages);

    /* ----------------------------------------------------------------
     * Read the existing flat file (if any) and load all member data. *
     * ---------------------------------------------------------------- */
    M14Entry *old_entries = NULL;
    uint32_t  old_n       = 0;
    int       target_idx  = -1;    /* index of our member in old file  */
    uint16_t  old_version = 0;

    FILE *f = fopen(filename, "rb");
    if (f) {
        uint8_t hdr[8];
        if (fread(hdr, 1, 8, f) == 8 && m14_be32(hdr) == FLAT_MAGIC_U32) {
            old_n = m14_be32(hdr + 4);
            old_entries = calloc(old_n, sizeof(M14Entry));
            if (old_entries) {
                /* Read the index first, collecting offsets and counts */
                uint64_t *offsets = malloc(old_n * sizeof(uint64_t));
                if (offsets) {
                    bool ok = true;
                    for (uint32_t i = 0; i < old_n && ok; i++) {
                        uint8_t e[FLAT_IDX_ENTRY];
                        if (fread(e, 1, FLAT_IDX_ENTRY, f) != FLAT_IDX_ENTRY)
                            { ok = false; break; }
                        memcpy(old_entries[i].name8, e, NAME_LEN);
                        old_entries[i].page_count = m14_be32(e + 8);
                        offsets[i] = m14_be64(e + 12);
                    }
                    /* Read each member's page data */
                    for (uint32_t i = 0; i < old_n; i++) {
                        size_t sz = (size_t)old_entries[i].page_count * PAGE_SIZE;
                        old_entries[i].data = (sz > 0) ? malloc(sz) : NULL;
                        old_entries[i].free_data = true;
                        if (sz > 0 && old_entries[i].data) {
                            fseek(f, (long)offsets[i], SEEK_SET);
                            (void)fread(old_entries[i].data, 1, sz, f);
                        }
                        if (memcmp(old_entries[i].name8, name8, NAME_LEN) == 0) {
                            target_idx = (int)i;
                            if (sz >= 2 && old_entries[i].data)
                                old_version = m14_be16(old_entries[i].data);
                        }
                    }
                    free(offsets);
                }
            }
        }
        fclose(f);
    }

    /* ----------------------------------------------------------------
     * Determine version and whether the content actually changed.    *
     * ---------------------------------------------------------------- */
    uint16_t new_version;
    uint32_t result;

    if (target_idx < 0) {
        /* Member does not yet exist: create at version 0 */
        new_version = 0;
        result      = 0;
    } else {
        bool same = m14_pages_equal(new_data, num_pages,
                                    old_entries[target_idx].data,
                                    (int)old_entries[target_idx].page_count);
        if (same) {
            /* Content unchanged: leave the file untouched */
            new_version = old_version;
            result      = 0;
        } else {
            new_version = (uint16_t)(old_version + 1);
            result      = 1;
        }
    }

    /* Content unchanged: skip the write */
    if (target_idx >= 0 && result == 0) {
        m14_free_entries(old_entries, old_n);
        free(new_data);
        return 0;
    }

    /* ----------------------------------------------------------------
     * Stamp the new version into page 0 of the new data, and also   *
     * update the in-memory copy so the caller sees the correct value. *
     * ---------------------------------------------------------------- */
    if (num_pages > 0 && new_data) {
        m14_put_be16(new_data, new_version);
        if (m14_page_addrs[0] + 1 < MEMORY_SIZE)
            m14_put_be16(&memory[m14_page_addrs[0]], new_version);
    }

    /* ----------------------------------------------------------------
     * Build the final entry list for the output file.                *
     * ---------------------------------------------------------------- */
    M14Entry *final_entries;
    uint32_t  final_n;

    if (target_idx >= 0) {
        /* Replace the existing member in-place */
        final_entries = old_entries;
        final_n       = old_n;
        old_entries   = NULL;   /* ownership transferred */

        if (final_entries[target_idx].free_data)
            free(final_entries[target_idx].data);
        final_entries[target_idx].data       = new_data;
        final_entries[target_idx].page_count = (uint32_t)num_pages;
        final_entries[target_idx].free_data  = true;
        new_data = NULL;
    } else {
        /* Append the new member */
        final_n = old_n + 1;
        /* realloc(NULL, n) is equivalent to malloc(n) per C99 */
        final_entries = realloc(old_entries, final_n * sizeof(M14Entry));
        if (!final_entries) {
            m14_free_entries(old_entries, old_n);
            free(new_data);
            return 0;
        }
        old_entries = NULL;
        memcpy(final_entries[final_n - 1].name8, name8, NAME_LEN);
        final_entries[final_n - 1].page_count = (uint32_t)num_pages;
        final_entries[final_n - 1].data       = new_data;
        final_entries[final_n - 1].free_data  = true;
        new_data = NULL;
    }

    /* ----------------------------------------------------------------
     * Write the flat file.                                           *
     * ---------------------------------------------------------------- */
    m14_write_flat(filename, final_entries, final_n);

    m14_free_entries(final_entries, final_n);
    if (new_data) free(new_data);   /* safety: should already be NULL  */

    return result;
}
