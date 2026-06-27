/*
 * sdf_write.c  --  SDF member creation (write) infrastructure.
 *
 * Implements the write-side API declared in sdf_write.h.
 *
 * Design
 * ======
 * sdf_wctx_t buffers all block, symbol, and statement descriptors
 * supplied by the caller.  At sdf_commit() time it:
 *
 *   1. Sorts symbols alphabetically (required for binary search on read).
 *   2. Sorts blocks by name (for the block name binary tree).
 *   3. Assigns consecutive 1-based numbers to symbols and blocks.
 *   4. Fills in fsymb_no/lsymb_no/fstmt_no/lstm_no on each block from
 *      the symbols and statements that reference it.
 *   5. Allocates virtual memory (page:offset pairs) for every structure
 *      using a simple bump-pointer allocator starting at page 1.
 *   6. Writes PAGEZERO and DROOTCEL into page 0.
 *   7. Writes block nodes, block tree cells, symbol nodes, symbol data
 *      cells, statement nodes, statement data cells, and extent cells
 *      into pages 1+.
 *   8. Builds the block name binary tree (balanced, derived from the
 *      sorted block array using the recursive median-of-array method).
 *   9. Builds SYMEXTF/V and STMTEXTF/V extent cells (one entry per
 *      page boundary crossed in the node arrays).
 *  10. Flushes all page buffers to disk.
 *  11. Updates the flat-file header and index.
 *
 * Virtual memory layout (one member)
 * ====================================
 *   Page 0:  [0]    PAGEZERO   (12 bytes)
 *            [12]   DROOTCEL   (172 bytes)
 *            [184+] (unused / future)
 *
 *   Page 1+: block nodes (12 bytes each, sequential)
 *            block tree cells (variable, ≥53 bytes each)
 *            symbol nodes (12 bytes each, sequential)
 *            symbol data cells (variable, 23+ bytes each)
 *            statement nodes (4 or 12 bytes each, sequential)
 *            statement data cells (6 bytes each, exec stmts only)
 *            symbol extent cell (SYMEXTF + n×SYMEXTV)
 *            statement extent cell (STMTEXTF + n×STMTEXTV)
 *            initialisation data (if any; halfword-aligned)
 *
 * All structures are placed contiguously; the bump pointer advances
 * to the next page whenever a structure would straddle a page boundary
 * (structures never span pages in the original SDF format).
 */

#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <time.h>
#include <sys/types.h>

#include "sdf_types.h"
#include "sdf_internal.h"
#include "sdf_write.h"

/* ------------------------------------------------------------------ */
/* Constants                                                           */
/* ------------------------------------------------------------------ */

#define WCTX_MAX_PAGES    512   /* max pages in a single member        */
#define WCTX_BLK_INIT     32   /* initial block array capacity        */
#define WCTX_SYM_INIT    256   /* initial symbol array capacity       */
#define WCTX_STMT_INIT   512   /* initial statement array capacity    */

/* Minimum sizes: SYMEXTF header + one SYMEXTV entry */
#define SYMEXT_HDR_SZ   sizeof(sdf_symextf_disk_t)   /* 8  */
#define SYMEXT_ENT_SZ   sizeof(sdf_symextv_disk_t)   /* 20 */
#define STMTEXT_HDR_SZ  sizeof(sdf_stmtextf_disk_t)  /* 8  */
#define STMTEXT_ENT_SZ  sizeof(sdf_stmtextv_disk_t)  /* 20 */

/* Fixed size of PAGEZERO on disk */
#define PAGEZERO_SZ     sizeof(sdf_pagezero_disk_t)  /* 12 */
/* Fixed size of DROOTCEL on disk (offset from start of DROOTCEL) */
#define DROOTCEL_SZ     sizeof(sdf_drootcel_disk_t)  /* 172 */

/* ------------------------------------------------------------------ */
/* Internal per-block tracking                                         */
/* ------------------------------------------------------------------ */

typedef struct {
    sdf_wblock_t  desc;          /* caller-supplied descriptor        */
    uint16_t      blk_no;        /* assigned block number (1-based)   */
    uint16_t      fsymb_no;      /* first symbol in this block        */
    uint16_t      lsymb_no;      /* last symbol in this block         */
    uint16_t      fstmt_no;      /* first statement in this block     */
    uint16_t      lstm_no;       /* last statement in this block      */
    sdf_vptr_t    btcell_vptr;   /* vptr to BLKTCELL (set at commit)  */
} wblock_t;

/* ------------------------------------------------------------------ */
/* Internal per-symbol tracking                                        */
/* ------------------------------------------------------------------ */

typedef struct {
    sdf_wsymbol_t desc;          /* caller-supplied descriptor        */
    uint16_t      symb_no;       /* assigned symbol number (1-based)  */
    uint32_t      init_rel_addr; /* RELADDR (set by write_init_data)  */
    bool          has_init;      /* true if init data was supplied    */
} wsymbol_t;

/* ------------------------------------------------------------------ */
/* Internal per-statement tracking                                     */
/* ------------------------------------------------------------------ */

typedef struct {
    sdf_wstmt_t desc;            /* caller-supplied descriptor        */
    uint16_t    stmt_no;         /* assigned statement number         */
} wstmt_t;

/* ------------------------------------------------------------------ */
/* Bump-pointer virtual memory allocator                               */
/* ------------------------------------------------------------------ */

typedef struct {
    uint16_t  page;     /* current page number (0-based)              */
    uint16_t  offset;   /* next free byte within current page         */
} bump_t;

/* ------------------------------------------------------------------ */
/* Write context                                                        */
/* ------------------------------------------------------------------ */

struct sdf_wctx {
    /* File */
    FILE        *fp;
    char        *path;           /* strdup of the file path           */
    char         member_name[SDF_NAME_LEN + 1];

    /* Settings */
    uint16_t     version;
    uint16_t     flags;          /* SDF_WFLAG_* bits                  */
    bool         has_srns;       /* cached from flags                 */

    /* Buffered inputs */
    wblock_t    *blocks;
    uint16_t     num_blks;
    uint16_t     cap_blks;

    wsymbol_t   *symbols;
    uint16_t     num_symbs;
    uint16_t     cap_symbs;

    wstmt_t     *stmts;
    uint16_t     num_stmts;
    uint16_t     cap_stmts;

    /* Init data accumulator */
    uint8_t     *init_data;
    size_t       init_data_len;
    size_t       init_data_cap;

    /* Virtual memory pages (allocated at commit time) */
    uint8_t    (*pages)[SDF_PAGE_SIZE];
    uint16_t     num_pages;
    uint16_t     cap_pages;

    /* Bump allocator (used during commit) */
    bump_t       bump;

    /* File position of first page of this member (set at commit) */
    long         pg0_file_offset;

    /* Whether this is a new file (sdf_create) or append (sdf_add_member) */
    bool         new_file;

    /* Number of members already in the file (before this one) */
    uint32_t     existing_member_count;

    /* File offset of the flat-file header (always 0) */
    /* and offset of this member's index entry */
    long         index_entry_offset;
};

/* ------------------------------------------------------------------ */
/* Helpers: big-endian write into a page buffer                        */
/* ------------------------------------------------------------------ */

static void pw8(uint8_t *pg, uint16_t off, uint8_t v)
{
    pg[off] = v;
}

static void pw16(uint8_t *pg, uint16_t off, uint16_t v)
{
    pg[off]   = (v >> 8) & 0xFF;
    pg[off+1] =  v       & 0xFF;
}

static void pw32(uint8_t *pg, uint16_t off, uint32_t v)
{
    pg[off]   = (v >> 24) & 0xFF;
    pg[off+1] = (v >> 16) & 0xFF;
    pg[off+2] = (v >>  8) & 0xFF;
    pg[off+3] =  v        & 0xFF;
}

static void pwstr(uint8_t *pg, uint16_t off, const char *s, size_t n)
{
    size_t len = strlen(s);
    if (len > n) len = n;
    memcpy(pg + off, s, len);
    if (len < n) memset(pg + off + len, ' ', n - len);
}

/* Write vptr as big-endian u32 */
static void pwvp(uint8_t *pg, uint16_t off, sdf_vptr_t vp)
{
    pw32(pg, off, (uint32_t)vp);
}

/* ------------------------------------------------------------------ */
/* Bump allocator                                                       */
/* ------------------------------------------------------------------ */

/*
 * Ensure the write context has at least `n_pages` pages allocated.
 * Pages are zero-initialised on creation.
 */
static sdf_rc_t ensure_pages(sdf_wctx_t *w, uint16_t n_pages)
{
    if (n_pages <= w->cap_pages)
        return SDF_OK;
    if (n_pages > WCTX_MAX_PAGES)
        return SDF_ERR_PAGE_FULL;

    uint16_t new_cap = (uint16_t)(n_pages + 8);
    if (new_cap > WCTX_MAX_PAGES) new_cap = WCTX_MAX_PAGES;

    void *p = realloc(w->pages, (size_t)new_cap * SDF_PAGE_SIZE);
    if (!p)
        return SDF_ERR_GETMAIN;

    w->pages    = p;
    /* Zero-initialise new pages */
    memset((uint8_t *)w->pages + (size_t)w->cap_pages * SDF_PAGE_SIZE,
           0,
           (size_t)(new_cap - w->cap_pages) * SDF_PAGE_SIZE);
    w->cap_pages = new_cap;
    return SDF_OK;
}

/*
 * Allocate `size` bytes in virtual memory, ensuring the allocation
 * does not straddle a page boundary (structures never span pages).
 * Returns the virtual pointer to the start of the allocation.
 * Advances the bump pointer.
 */
static sdf_rc_t bump_alloc(sdf_wctx_t *w, uint16_t size, sdf_vptr_t *vptr_out)
{
    if (size > SDF_PAGE_SIZE)
        return SDF_ERR_PAGE_FULL;   /* structure larger than a page */

    /* If this allocation would straddle the page boundary, advance */
    if ((uint32_t)w->bump.offset + size > SDF_PAGE_SIZE) {
        w->bump.page++;
        w->bump.offset = 0;
    }

    if (w->bump.page >= WCTX_MAX_PAGES)
        return SDF_ERR_PAGE_FULL;

    /* Ensure the page buffer exists */
    if (w->bump.page >= w->cap_pages) {
        sdf_rc_t rc = ensure_pages(w, (uint16_t)(w->bump.page + 1));
        if (rc != SDF_OK) return rc;
    }
    if (w->bump.page >= w->num_pages)
        w->num_pages = (uint16_t)(w->bump.page + 1);

    *vptr_out = SDF_VPTR_MAKE(w->bump.page, w->bump.offset);
    w->bump.offset = (uint16_t)(w->bump.offset + size);
    return SDF_OK;
}

/* Convenience: pointer into page buffer given a vptr */
static uint8_t *vptr_buf(sdf_wctx_t *w, sdf_vptr_t vp)
{
    return (uint8_t *)w->pages[SDF_VPTR_PAGE(vp)] + SDF_VPTR_OFFSET(vp);
}

/* ------------------------------------------------------------------ */
/* Dynamic array growth helpers                                        */
/* ------------------------------------------------------------------ */

#define GROW(arr, num, cap, init_cap, type)  do {       \
    if ((num) >= (cap)) {                                \
        uint32_t nc = (cap) ? (cap) * 2 : (init_cap);   \
        if (nc > 65535) nc = 65535;                      \
        void *np = realloc((arr), nc * sizeof(type));    \
        if (!np) return SDF_ERR_GETMAIN;                 \
        (arr) = np;                                      \
        (cap) = (uint16_t)nc;                            \
    }                                                    \
} while (0)

/* ------------------------------------------------------------------ */
/* sdf_create / sdf_add_member shared init                            */
/* ------------------------------------------------------------------ */

static sdf_rc_t wctx_alloc(sdf_wctx_t **wctx_out)
{
    sdf_wctx_t *w = calloc(1, sizeof(sdf_wctx_t));
    if (!w) return SDF_ERR_GETMAIN;
    *wctx_out = w;
    return SDF_OK;
}

static sdf_rc_t wctx_init_arrays(sdf_wctx_t *w)
{
    w->blocks = calloc(WCTX_BLK_INIT, sizeof(wblock_t));
    if (!w->blocks) return SDF_ERR_GETMAIN;
    w->cap_blks = WCTX_BLK_INIT;

    w->symbols = calloc(WCTX_SYM_INIT, sizeof(wsymbol_t));
    if (!w->symbols) return SDF_ERR_GETMAIN;
    w->cap_symbs = WCTX_SYM_INIT;

    w->stmts = calloc(WCTX_STMT_INIT, sizeof(wstmt_t));
    if (!w->stmts) return SDF_ERR_GETMAIN;
    w->cap_stmts = WCTX_STMT_INIT;

    return SDF_OK;
}

/*
 * Write the flat-file header for a brand-new file:
 *   magic(4) + member_count(4) = 8 bytes
 * followed by a placeholder index entry (20 bytes).
 */
static sdf_rc_t write_new_file_header(sdf_wctx_t *w)
{
    /* Magic + count=1 */
    uint8_t hdr[8] = { 0x53, 0x44, 0x46, 0x00,
                        0x00, 0x00, 0x00, 0x01 };
    if (fwrite(hdr, 1, 8, w->fp) != 8)
        return SDF_ERR_CREATE_FAIL;

    /* Placeholder index entry (filled in at commit) */
    w->index_entry_offset = 8;
    uint8_t idx[20] = {0};
    if (fwrite(idx, 1, 20, w->fp) != 20)
        return SDF_ERR_CREATE_FAIL;

    w->pg0_file_offset = 28;   /* 8 + 20 */
    return SDF_OK;
}

/*
 * Read the existing flat-file header, verify magic, get member count,
 * seek to end ready for the new member's page data, and record the
 * offset for the new index entry.
 */
static sdf_rc_t append_to_existing_file(sdf_wctx_t *w)
{
    rewind(w->fp);
    uint8_t hdr[8];
    if (fread(hdr, 1, 8, w->fp) != 8)
        return SDF_ERR_OPEN_FAIL;

    uint32_t magic = ((uint32_t)hdr[0] << 24) | ((uint32_t)hdr[1] << 16) |
                     ((uint32_t)hdr[2] <<  8) |  (uint32_t)hdr[3];
    if (magic != 0x53444600u)
        return SDF_ERR_OPEN_FAIL;

    uint32_t n = ((uint32_t)hdr[4] << 24) | ((uint32_t)hdr[5] << 16) |
                 ((uint32_t)hdr[6] <<  8) |  (uint32_t)hdr[7];
    w->existing_member_count = n;

    /* Seek past existing index entries */
    long idx_end = 8 + (long)n * 20;
    if (fseek(w->fp, idx_end, SEEK_SET) != 0)
        return SDF_ERR_OPEN_FAIL;

    /* Read existing index to find end-of-data */
    /* We need to seek to the end of all existing page data */
    if (fseek(w->fp, 0, SEEK_END) != 0)
        return SDF_ERR_OPEN_FAIL;
    long file_end = ftell(w->fp);

    /* The new member's page data starts at file_end, but we need to
     * insert a new index entry in the index table.  Since the flat-file
     * format stores the index before the data, and we're appending,
     * we must expand the index table by 20 bytes.  We do this by
     * rewriting the file:
     *   - Read all existing page data into memory
     *   - Rewrite header with count+1
     *   - Write n+1 index entries (new one has zeros as placeholder)
     *   - Write all existing page data
     * This is O(file_size) but only done once per member addition.
     */
    long data_start = 8 + (long)n * 20;
    long data_size  = file_end - data_start;

    uint8_t *data_buf = NULL;
    if (data_size > 0) {
        data_buf = malloc((size_t)data_size);
        if (!data_buf)
            return SDF_ERR_GETMAIN;
        if (fseek(w->fp, data_start, SEEK_SET) != 0) {
            free(data_buf);
            return SDF_ERR_OPEN_FAIL;
        }
        if ((long)fread(data_buf, 1, (size_t)data_size, w->fp) != data_size) {
            free(data_buf);
            return SDF_ERR_OPEN_FAIL;
        }
    }

    /* Rewrite from the beginning */
    rewind(w->fp);

    /* Header with updated count */
    uint8_t new_hdr[8];
    memcpy(new_hdr, hdr, 4);
    uint32_t new_n = n + 1;
    new_hdr[4] = (new_n >> 24) & 0xFF;
    new_hdr[5] = (new_n >> 16) & 0xFF;
    new_hdr[6] = (new_n >>  8) & 0xFF;
    new_hdr[7] =  new_n        & 0xFF;
    if (fwrite(new_hdr, 1, 8, w->fp) != 8) {
        free(data_buf);
        return SDF_ERR_CREATE_FAIL;
    }

    /* Read and rewrite existing index entries */
    /* We already consumed 8 bytes; now we need to re-read old entries.
     * But we've rewound, so seek past new header to read old entries. */
    /* Temporarily use a separate pass: we have the old data, so
     * reconstruct old index by reading from the original file positions.
     * Simpler: we already read all page data; now rebuild index.
     * But we don't have the old index entries in memory.
     * We need to read them before rewinding.
     * Restructure: read old index entries first, then proceed. */

    /* Actually we need to do this differently -- read old entries first */
    /* Let's restart the logic cleanly */
    free(data_buf);

    /* --- Redo: read old index, then old data, then rewrite --- */
    rewind(w->fp);
    if (fread(hdr, 1, 8, w->fp) != 8) return SDF_ERR_OPEN_FAIL;

    uint8_t *old_idx = malloc((size_t)n * 20);
    if (!old_idx) return SDF_ERR_GETMAIN;
    if (n > 0 && fread(old_idx, 20, n, w->fp) != n) {
        free(old_idx);
        return SDF_ERR_OPEN_FAIL;
    }

    if (data_size > 0) {
        data_buf = malloc((size_t)data_size);
        if (!data_buf) { free(old_idx); return SDF_ERR_GETMAIN; }
        if ((long)fread(data_buf, 1, (size_t)data_size, w->fp) != data_size) {
            free(old_idx); free(data_buf);
            return SDF_ERR_OPEN_FAIL;
        }
    }

    /* Update pg0_offset in each old index entry: each existing member's
     * page data shifts by 20 bytes because we are inserting a new
     * 20-byte index entry between the index table and the data area. */
    for (uint32_t i = 0; i < n; i++) {
        uint8_t *e = old_idx + i * 20;
        uint64_t old_off = ((uint64_t)e[12] << 56) | ((uint64_t)e[13] << 48) |
                           ((uint64_t)e[14] << 40) | ((uint64_t)e[15] << 32) |
                           ((uint64_t)e[16] << 24) | ((uint64_t)e[17] << 16) |
                           ((uint64_t)e[18] <<  8) |  (uint64_t)e[19];
        uint64_t new_off = old_off + 20;  /* shift by size of new index entry */
        e[12] = (new_off >> 56) & 0xFF;  e[13] = (new_off >> 48) & 0xFF;
        e[14] = (new_off >> 40) & 0xFF;  e[15] = (new_off >> 32) & 0xFF;
        e[16] = (new_off >> 24) & 0xFF;  e[17] = (new_off >> 16) & 0xFF;
        e[18] = (new_off >>  8) & 0xFF;  e[19] =  new_off        & 0xFF;
    }

    /* Rewrite */
    rewind(w->fp);
    if (fwrite(new_hdr, 1, 8, w->fp) != 8) {
        free(old_idx); free(data_buf);
        return SDF_ERR_CREATE_FAIL;
    }
    if (n > 0 && fwrite(old_idx, 20, n, w->fp) != n) {
        free(old_idx); free(data_buf);
        return SDF_ERR_CREATE_FAIL;
    }
    free(old_idx);

    /* New (placeholder) index entry */
    w->index_entry_offset = 8 + (long)n * 20;
    uint8_t placeholder[20] = {0};
    if (fwrite(placeholder, 1, 20, w->fp) != 20) {
        free(data_buf);
        return SDF_ERR_CREATE_FAIL;
    }

    /* Existing page data */
    if (data_size > 0) {
        if ((long)fwrite(data_buf, 1, (size_t)data_size, w->fp) != data_size) {
            free(data_buf);
            return SDF_ERR_CREATE_FAIL;
        }
    }
    free(data_buf);

    /* Position: ready to write new member's pages */
    if (fseek(w->fp, 0, SEEK_END) != 0)
        return SDF_ERR_OPEN_FAIL;
    w->pg0_file_offset = ftell(w->fp);

    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* Public: sdf_create                                                  */
/* ------------------------------------------------------------------ */

sdf_rc_t sdf_create(const char    *path,
                    const char    *member_name,
                    uint16_t       version,
                    uint16_t       flags,
                    sdf_wctx_t   **wctx_out)
{
    sdf_wctx_t *w = NULL;
    sdf_rc_t rc = wctx_alloc(&w);
    if (rc != SDF_OK) return rc;

    w->path = strdup(path);
    if (!w->path) { free(w); return SDF_ERR_GETMAIN; }

    strncpy(w->member_name, member_name, SDF_NAME_LEN);
    w->member_name[SDF_NAME_LEN] = '\0';
    w->version  = version ? version : SDF_VER_DEFAULT;
    w->flags    = flags;
    w->has_srns = (flags & SDF_WFLAG_HAS_SRNS) != 0;
    w->new_file = true;

    rc = wctx_init_arrays(w);
    if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }

    w->fp = fopen(path, "w+b");
    if (!w->fp) { sdf_wcancel(&w); return SDF_ERR_CREATE_FAIL; }

    rc = write_new_file_header(w);
    if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }

    /* Data pages start at page 1 of virtual memory */
    w->bump.page   = 1;
    w->bump.offset = 0;

    *wctx_out = w;
    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* Public: sdf_add_member                                             */
/* ------------------------------------------------------------------ */

sdf_rc_t sdf_add_member(const char    *path,
                         const char    *member_name,
                         uint16_t       version,
                         uint16_t       flags,
                         sdf_wctx_t   **wctx_out)
{
    sdf_wctx_t *w = NULL;
    sdf_rc_t rc = wctx_alloc(&w);
    if (rc != SDF_OK) return rc;

    w->path = strdup(path);
    if (!w->path) { free(w); return SDF_ERR_GETMAIN; }

    strncpy(w->member_name, member_name, SDF_NAME_LEN);
    w->member_name[SDF_NAME_LEN] = '\0';
    w->version  = version ? version : SDF_VER_DEFAULT;
    w->flags    = flags;
    w->has_srns = (flags & SDF_WFLAG_HAS_SRNS) != 0;
    w->new_file = false;

    rc = wctx_init_arrays(w);
    if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }

    w->fp = fopen(path, "r+b");
    if (!w->fp) { sdf_wcancel(&w); return SDF_ERR_OPEN_FAIL; }

    rc = append_to_existing_file(w);
    if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }

    w->bump.page   = 1;
    w->bump.offset = 0;

    *wctx_out = w;
    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* Public: sdf_wcancel                                                 */
/* ------------------------------------------------------------------ */

void sdf_wcancel(sdf_wctx_t **wp)
{
    if (!wp || !*wp) return;
    sdf_wctx_t *w = *wp;
    if (w->fp)       { fclose(w->fp); w->fp = NULL; }
    free(w->path);
    free(w->blocks);
    free(w->symbols);
    free(w->stmts);
    free(w->pages);
    free(w->init_data);
    free(w);
    *wp = NULL;
}

/* ------------------------------------------------------------------ */
/* Public: sdf_write_block                                             */
/* ------------------------------------------------------------------ */

sdf_rc_t sdf_write_block(sdf_wctx_t        *w,
                          const sdf_wblock_t *blk,
                          uint16_t           *blk_no_out)
{
    if (!w || !blk) return SDF_ERR_GETMAIN;

    /* Check for duplicate block name */
    for (uint16_t i = 0; i < w->num_blks; i++) {
        if (strcmp(w->blocks[i].desc.blk_name, blk->blk_name) == 0)
            return SDF_ERR_DUP_BLK;
    }

    GROW(w->blocks, w->num_blks, w->cap_blks, WCTX_BLK_INIT, wblock_t);

    wblock_t *wb = &w->blocks[w->num_blks];
    memset(wb, 0, sizeof(*wb));
    wb->desc   = *blk;
    wb->blk_no = (uint16_t)(w->num_blks + 1);   /* 1-based */

    w->num_blks++;
    if (blk_no_out) *blk_no_out = wb->blk_no;
    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* Public: sdf_write_symbol                                            */
/* ------------------------------------------------------------------ */

sdf_rc_t sdf_write_symbol(sdf_wctx_t         *w,
                           const sdf_wsymbol_t *sym,
                           uint16_t            *symb_no_out)
{
    if (!w || !sym) return SDF_ERR_GETMAIN;

    /* Check for duplicate symbol name within the same block */
    for (uint16_t i = 0; i < w->num_symbs; i++) {
        if (w->symbols[i].desc.blk_no == sym->blk_no &&
            strcmp(w->symbols[i].desc.symb_name, sym->symb_name) == 0)
            return SDF_ERR_DUP_SYMB;
    }

    GROW(w->symbols, w->num_symbs, w->cap_symbs, WCTX_SYM_INIT, wsymbol_t);

    wsymbol_t *ws = &w->symbols[w->num_symbs];
    memset(ws, 0, sizeof(*ws));
    ws->desc    = *sym;
    ws->symb_no = (uint16_t)(w->num_symbs + 1);  /* provisional; fixed at commit */

    w->num_symbs++;
    if (symb_no_out) *symb_no_out = ws->symb_no;
    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* Public: sdf_write_stmt                                              */
/* ------------------------------------------------------------------ */

sdf_rc_t sdf_write_stmt(sdf_wctx_t       *w,
                         const sdf_wstmt_t *stmt,
                         uint16_t          *stmt_no_out)
{
    if (!w || !stmt) return SDF_ERR_GETMAIN;

    GROW(w->stmts, w->num_stmts, w->cap_stmts, WCTX_STMT_INIT, wstmt_t);

    wstmt_t *ws  = &w->stmts[w->num_stmts];
    ws->desc     = *stmt;
    ws->stmt_no  = (uint16_t)(w->num_stmts + 1);

    w->num_stmts++;
    if (stmt_no_out) *stmt_no_out = ws->stmt_no;
    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* Public: sdf_write_init_data                                        */
/* ------------------------------------------------------------------ */

sdf_rc_t sdf_write_init_data(sdf_wctx_t   *w,
                              uint16_t      symb_no,
                              const void   *data,
                              size_t        nbytes)
{
    if (!w || !data)          return SDF_ERR_GETMAIN;
    if (nbytes == 0 || nbytes & 1) return SDF_ERR_INIT_DATA;
    if (symb_no == 0 || symb_no > w->num_symbs) return SDF_ERR_INIT_DATA;

    /* Grow init_data buffer if needed */
    size_t new_len = w->init_data_len + nbytes;
    if (new_len > w->init_data_cap) {
        size_t new_cap = w->init_data_cap ? w->init_data_cap * 2 : 4096;
        while (new_cap < new_len) new_cap *= 2;
        void *p = realloc(w->init_data, new_cap);
        if (!p) return SDF_ERR_GETMAIN;
        w->init_data     = p;
        w->init_data_cap = new_cap;
    }

    /* Record the halfword offset for this symbol's RELADDR */
    wsymbol_t *ws = &w->symbols[symb_no - 1];
    ws->init_rel_addr = (uint32_t)(w->init_data_len / 2);
    ws->has_init      = true;

    memcpy(w->init_data + w->init_data_len, data, nbytes);
    w->init_data_len += nbytes;
    return SDF_OK;
}

/* ================================================================== */
/* sdf_commit() -- the heavy lifting                                   */
/* ================================================================== */

/* ------------------------------------------------------------------ */
/* Sort comparators                                                    */
/* ------------------------------------------------------------------ */

static int cmp_symbol_name(const void *a, const void *b)
{
    const wsymbol_t *sa = (const wsymbol_t *)a;
    const wsymbol_t *sb = (const wsymbol_t *)b;
    /* Primary: alphabetical by name */
    int c = strcmp(sa->desc.symb_name, sb->desc.symb_name);
    if (c) return c;
    /* Secondary: block number (stable within same name) */
    return (int)sa->desc.blk_no - (int)sb->desc.blk_no;
}

static int cmp_block_name(const void *a, const void *b)
{
    const wblock_t *ba = (const wblock_t *)a;
    const wblock_t *bb = (const wblock_t *)b;
    return strcmp(ba->desc.blk_name, bb->desc.blk_name);
}

/* ------------------------------------------------------------------ */
/* Build balanced binary tree of block tree cells                      */
/*                                                                     */
/* Blocks are already sorted by name.  We build the tree by the       */
/* median-split method: the middle element of each subarray becomes   */
/* the root, its left half the left subtree, its right half the right.*/
/* This produces a height-balanced BST with no rebalancing needed.    */
/*                                                                     */
/* Returns the vptr of the root BLKTCELL, or SDF_VPTR_NULL on error. */
/* ------------------------------------------------------------------ */

static sdf_rc_t build_btree(sdf_wctx_t *w,
                             uint16_t    lo,      /* inclusive, 0-based */
                             uint16_t    hi,      /* inclusive, 0-based */
                             sdf_vptr_t *root_out)
{
    if (lo > hi) {
        *root_out = SDF_VPTR_NULL;
        return SDF_OK;
    }

    uint16_t mid = (uint16_t)((lo + hi) / 2);
    wblock_t *wb = &w->blocks[mid];

    /* Allocate BLKTCELL in virtual memory.
     * Size: fixed fields (53 bytes) + bname_len bytes for the name. */
    uint8_t  bname_len  = (uint8_t)strlen(wb->desc.blk_name);
    uint16_t btcell_sz  = (uint16_t)(offsetof(sdf_blktcell_disk_t, blk_name)
                                     + bname_len);
    if (btcell_sz < 53) btcell_sz = 53;  /* minimum */

    sdf_vptr_t btcell_vptr;
    sdf_rc_t rc = bump_alloc(w, btcell_sz, &btcell_vptr);
    if (rc != SDF_OK) return rc;
    wb->btcell_vptr = btcell_vptr;

    /* Recurse to build left and right subtrees first
     * (so their vptrs are known when we write this cell) */
    sdf_vptr_t left_vptr = SDF_VPTR_NULL;
    sdf_vptr_t right_vptr = SDF_VPTR_NULL;

    if (mid > lo) {
        rc = build_btree(w, lo, (uint16_t)(mid - 1), &left_vptr);
        if (rc != SDF_OK) return rc;
    }
    if (mid < hi) {
        rc = build_btree(w, (uint16_t)(mid + 1), hi, &right_vptr);
        if (rc != SDF_OK) return rc;
    }

    /* Write the BLKTCELL */
    uint8_t *p = vptr_buf(w, btcell_vptr);
    pwvp(p,  0, right_vptr);             /* rtree_ptr  */
    pwvp(p,  4, left_vptr);              /* ltree_ptr  */
    pw32(p,  8, 0);                      /* fnest_ptr  */
    pw32(p, 12, 0);                      /* lnest_ptr  */
    pw32(p, 16, 0);                      /* ext_ptr    */
    pw32(p, 20, 0);                      /* spare      */
    pw8 (p, 24, wb->desc.blk_flags);    /* blk_flgs   */
    pw8 (p, 25, 0);                      /* spare2     */
    pw16(p, 26, wb->blk_no);            /* blk_ndx    */
    pw16(p, 28, wb->desc.blk_id);       /* blk_id     */
    pw8 (p, 30, wb->desc.blk_class);    /* blk_class  */
    pw8 (p, 31, wb->desc.blk_type);     /* blk_type   */
    pw16(p, 32, wb->fsymb_no);          /* fsymb_num  */
    pw16(p, 34, wb->lsymb_no);          /* lsymb_num  */
    pw16(p, 36, wb->fstmt_no);          /* fstmt_num  */
    pw16(p, 38, wb->lstm_no);           /* lstm_num   */
    pw16(p, 40, wb->desc.post_dcl);     /* post_dcl   */
    pw16(p, 42, wb->desc.stak_list);    /* stak_list  */
    pw8 (p, 44, bname_len);             /* bname_len  */
    memcpy(p + 45, wb->desc.blk_name, bname_len); /* blk_name */

    *root_out = btcell_vptr;
    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* Build symbol extent cell (SYMEXTF + SYMEXTV entries)               */
/*                                                                     */
/* One SYMEXTV entry per page that contains symbol nodes.             */
/* The extent cell lets the binary search skip directly to the right  */
/* page when looking up a symbol by name.                             */
/* ------------------------------------------------------------------ */

static sdf_rc_t build_sym_extent(sdf_wctx_t *w,
                                  sdf_vptr_t *fsn_vptr,  /* first symb node */
                                  sdf_vptr_t *snel_out)
{
    if (w->num_symbs == 0) {
        *snel_out = SDF_VPTR_NULL;
        return SDF_OK;
    }

    /* Count how many pages the symbol nodes span */
    /* Symbol nodes are 12 bytes each, contiguous from fsn_vptr */
    uint16_t nodes_per_page = SDF_PAGE_SIZE / 12;
    uint16_t n_pages_used = (uint16_t)((w->num_symbs + nodes_per_page - 1)
                                        / nodes_per_page);

    /* Allocate the extent cell:
     * SYMEXTF header (8) + n_pages_used * SYMEXTV (20 each) */
    uint16_t ext_sz = (uint16_t)(SYMEXT_HDR_SZ +
                                  (uint32_t)n_pages_used * SYMEXT_ENT_SZ);
    sdf_vptr_t ext_vptr;
    sdf_rc_t rc = bump_alloc(w, ext_sz, &ext_vptr);
    if (rc != SDF_OK) return rc;

    uint8_t *p = vptr_buf(w, ext_vptr);
    /* SYMEXTF: succ_ptr(4) + next_ntry(2) + fst_page(2) */
    pw32(p, 0, 0);                                   /* succ_ptr = NULL  */
    pw16(p, 4, n_pages_used);                        /* next_ntry        */
    pw16(p, 6, (uint16_t)SDF_VPTR_PAGE(*fsn_vptr)); /* fst_page         */

    /* Write one SYMEXTV per page */
    /* Symbol nodes start at fsn_vptr which may not be at page offset 0. */
    uint16_t sbase_page = SDF_VPTR_PAGE(*fsn_vptr);
    uint16_t sbase_off  = SDF_VPTR_OFFSET(*fsn_vptr);

    uint16_t sym_idx = 0;
    for (uint16_t pg = 0; pg < n_pages_used; pg++) {
        uint16_t pg_first_sym = sym_idx;
        uint16_t pg_last_sym  = sym_idx;

        while (pg_last_sym + 1 < w->num_symbs) {
            uint32_t next_abs = (uint32_t)sbase_off +
                                (uint32_t)(pg_last_sym + 1) * 12;
            uint16_t next_pg  = (uint16_t)(sbase_page + next_abs / SDF_PAGE_SIZE);
            if (next_pg != sbase_page + pg) break;
            pg_last_sym++;
        }

        uint32_t fst_abs = (uint32_t)sbase_off + (uint32_t)pg_first_sym * 12;
        uint32_t lst_abs = (uint32_t)sbase_off + (uint32_t)pg_last_sym  * 12;
        uint16_t fst_off = (uint16_t)(fst_abs % SDF_PAGE_SIZE);
        uint16_t lst_off = (uint16_t)(lst_abs % SDF_PAGE_SIZE);

        uint8_t *ev = p + SYMEXT_HDR_SZ + pg * SYMEXT_ENT_SZ;
        pw16(ev, 0, fst_off);
        pw16(ev, 2, lst_off);
        pwstr(ev, 4,  w->symbols[pg_first_sym].desc.symb_name, SDF_NAME_LEN);
        pwstr(ev, 12, w->symbols[pg_last_sym ].desc.symb_name, SDF_NAME_LEN);

        sym_idx = (uint16_t)(pg_last_sym + 1);
    }

    *snel_out = ext_vptr;
    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* Build statement extent cell (STMTEXTF + STMTEXTV entries)          */
/* ------------------------------------------------------------------ */

static sdf_rc_t build_stmt_extent(sdf_wctx_t *w,
                                   sdf_vptr_t *fstn_vptr, /* first stmt node */
                                   bool        has_srns,
                                   sdf_vptr_t *snel_out)
{
    if (w->num_stmts == 0 || !has_srns) {
        *snel_out = SDF_VPTR_NULL;
        return SDF_OK;
    }

    uint16_t node_sz       = has_srns ? 12 : 4;
    uint16_t nodes_per_page= (uint16_t)(SDF_PAGE_SIZE / node_sz);
    uint16_t n_pages_used  = (uint16_t)((w->num_stmts + nodes_per_page - 1)
                                         / nodes_per_page);

    uint16_t ext_sz = (uint16_t)(STMTEXT_HDR_SZ +
                                   (uint32_t)n_pages_used * STMTEXT_ENT_SZ);
    sdf_vptr_t ext_vptr;
    sdf_rc_t rc = bump_alloc(w, ext_sz, &ext_vptr);
    if (rc != SDF_OK) return rc;

    uint8_t *p = vptr_buf(w, ext_vptr);
    pw32(p, 0, 0);
    pw16(p, 4, n_pages_used);
    pw16(p, 6, (uint16_t)SDF_VPTR_PAGE(*fstn_vptr));

    /* The statement nodes start at fstn_vptr, which may not be at offset 0
     * on its page.  Compute absolute byte offsets of each node on its page. */
    uint16_t base_page = SDF_VPTR_PAGE(*fstn_vptr);
    uint16_t base_off  = SDF_VPTR_OFFSET(*fstn_vptr);

    uint16_t stmt_idx = 0;
    for (uint16_t pg = 0; pg < n_pages_used; pg++) {
        uint16_t pg_first = stmt_idx;
        uint16_t pg_last  = stmt_idx;

        /* Find the last statement node on this same page */
        while (pg_last + 1 < w->num_stmts) {
            uint32_t next_abs = (uint32_t)base_off +
                                (uint32_t)(pg_last + 1) * node_sz;
            uint16_t next_pg  = (uint16_t)(base_page + next_abs / SDF_PAGE_SIZE);
            if (next_pg != base_page + pg) break;
            pg_last++;
        }

        /* Compute offsets relative to the start of the page */
        uint32_t fst_abs = (uint32_t)base_off + (uint32_t)pg_first * node_sz;
        uint32_t lst_abs = (uint32_t)base_off + (uint32_t)pg_last  * node_sz;
        uint16_t fst_off = (uint16_t)(fst_abs % SDF_PAGE_SIZE);
        uint16_t lst_off = (uint16_t)(lst_abs % SDF_PAGE_SIZE);

        uint8_t *ev = p + STMTEXT_HDR_SZ + pg * STMTEXT_ENT_SZ;
        pw16(ev, 0, fst_off);
        pw16(ev, 2, lst_off);
        /* SRNs in extent cell are CL8 (space-padded) */
        char srn_first[SDF_SRN_PAD_LEN + 1] = "        ";
        char srn_last [SDF_SRN_PAD_LEN + 1] = "        ";
        memcpy(srn_first, w->stmts[pg_first].desc.srn, SDF_SRN_LEN);
        memcpy(srn_last,  w->stmts[pg_last ].desc.srn, SDF_SRN_LEN);
        pwstr(ev,  4, srn_first, SDF_SRN_PAD_LEN);
        pwstr(ev, 12, srn_last,  SDF_SRN_PAD_LEN);

        stmt_idx = (uint16_t)(pg_last + 1);
    }

    *snel_out = ext_vptr;
    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* sdf_commit() -- main                                                */
/* ------------------------------------------------------------------ */

sdf_rc_t sdf_commit(sdf_wctx_t **wp)
{
    if (!wp || !*wp) return SDF_ERR_NOT_WCTX;
    sdf_wctx_t *w = *wp;

    /* ---- 1. Sort symbols alphabetically ---- */
    if (w->num_symbs > 0)
        qsort(w->symbols, w->num_symbs, sizeof(wsymbol_t), cmp_symbol_name);

    /* Reassign symbol numbers after sort */
    for (uint16_t i = 0; i < w->num_symbs; i++)
        w->symbols[i].symb_no = (uint16_t)(i + 1);

    /* ---- 2. Sort blocks by name ---- */
    if (w->num_blks > 0)
        qsort(w->blocks, w->num_blks, sizeof(wblock_t), cmp_block_name);

    /* Reassign block numbers after sort */
    for (uint16_t i = 0; i < w->num_blks; i++)
        w->blocks[i].blk_no = (uint16_t)(i + 1);

    /* ---- 3. Compute per-block symbol and statement ranges ---- */
    /* Initialise ranges to "not set" */
    for (uint16_t i = 0; i < w->num_blks; i++) {
        w->blocks[i].fsymb_no = 0;
        w->blocks[i].lsymb_no = 0;
        w->blocks[i].fstmt_no = 0;
        w->blocks[i].lstm_no  = 0;
    }

    for (uint16_t si = 0; si < w->num_symbs; si++) {
        uint16_t bn = w->symbols[si].desc.blk_no;
        /* Find this block in the (now sorted/renumbered) array */
        /* blk_no is now positional so we check all entries */
        for (uint16_t bi = 0; bi < w->num_blks; bi++) {
            if (w->blocks[bi].blk_no == bn) {
                uint16_t sno = w->symbols[si].symb_no;
                if (w->blocks[bi].fsymb_no == 0 || sno < w->blocks[bi].fsymb_no)
                    w->blocks[bi].fsymb_no = sno;
                if (sno > w->blocks[bi].lsymb_no)
                    w->blocks[bi].lsymb_no = sno;
                break;
            }
        }
    }

    for (uint16_t si = 0; si < w->num_stmts; si++) {
        uint16_t bn   = w->stmts[si].desc.blk_no;
        uint16_t stno = w->stmts[si].stmt_no;
        for (uint16_t bi = 0; bi < w->num_blks; bi++) {
            if (w->blocks[bi].blk_no == bn) {
                if (w->blocks[bi].fstmt_no == 0 || stno < w->blocks[bi].fstmt_no)
                    w->blocks[bi].fstmt_no = stno;
                if (stno > w->blocks[bi].lstm_no)
                    w->blocks[bi].lstm_no = stno;
                break;
            }
        }
    }

    /* ---- 4. Layout: allocate virtual memory for all structures ---- */

    /* Page 0 is reserved for PAGEZERO + DROOTCEL; data starts at page 1 */
    sdf_rc_t rc = ensure_pages(w, 1);
    if (rc != SDF_OK) { sdf_wcancel(wp); return rc; }
    w->num_pages = 1;
    w->bump.page   = 1;
    w->bump.offset = 0;

    /* 4a. Block nodes (BLCKNODE, 12 bytes each) */
    sdf_vptr_t fbn_vptr = SDF_VPTR_NULL;
    sdf_vptr_t lbn_vptr = SDF_VPTR_NULL;
    sdf_vptr_t *bnode_vptrs = NULL;

    if (w->num_blks > 0) {
        bnode_vptrs = malloc(w->num_blks * sizeof(sdf_vptr_t));
        if (!bnode_vptrs) { sdf_wcancel(wp); return SDF_ERR_GETMAIN; }

        for (uint16_t i = 0; i < w->num_blks; i++) {
            rc = bump_alloc(w, 12, &bnode_vptrs[i]);
            if (rc != SDF_OK) { free(bnode_vptrs); sdf_wcancel(wp); return rc; }
            if (i == 0)                     fbn_vptr = bnode_vptrs[i];
            if (i == w->num_blks - 1)       lbn_vptr = bnode_vptrs[i];
        }

        /* 4b. Block tree cells (BLKTCELL, variable size)
         *     Build the balanced binary tree; this also allocates and
         *     writes the BLKTCELL structures. */
        sdf_vptr_t btree_root = SDF_VPTR_NULL;
        rc = build_btree(w, 0, (uint16_t)(w->num_blks - 1), &btree_root);
        if (rc != SDF_OK) { free(bnode_vptrs); sdf_wcancel(wp); return rc; }

        /* Now write block nodes (we know btcell_vptr for each block) */
        for (uint16_t i = 0; i < w->num_blks; i++) {
            uint8_t *p = vptr_buf(w, bnode_vptrs[i]);
            pwstr(p, 0, w->blocks[i].desc.csect_name, SDF_NAME_LEN);
            pwvp (p, 8, w->blocks[i].btcell_vptr);
        }

        /* 4c. Symbol nodes (SYMBNODE, 12 bytes each) */
        sdf_vptr_t fsn_vptr = SDF_VPTR_NULL;
        sdf_vptr_t lsn_vptr = SDF_VPTR_NULL;
        sdf_vptr_t *snode_vptrs = NULL;
        sdf_vptr_t *sdc_vptrs   = NULL;

        if (w->num_symbs > 0) {
            snode_vptrs = malloc(w->num_symbs * sizeof(sdf_vptr_t));
            sdc_vptrs   = malloc(w->num_symbs * sizeof(sdf_vptr_t));
            if (!snode_vptrs || !sdc_vptrs) {
                free(bnode_vptrs); free(snode_vptrs); free(sdc_vptrs);
                sdf_wcancel(wp); return SDF_ERR_GETMAIN;
            }

            for (uint16_t i = 0; i < w->num_symbs; i++) {
                rc = bump_alloc(w, 12, &snode_vptrs[i]);
                if (rc != SDF_OK) goto sym_err;
                if (i == 0)                      fsn_vptr = snode_vptrs[i];
                if (i == w->num_symbs - 1)       lsn_vptr = snode_vptrs[i];
            }

            /* 4d. Symbol data cells (SYMBDC, variable size) */
            for (uint16_t i = 0; i < w->num_symbs; i++) {
                const char *name   = w->symbols[i].desc.symb_name;
                uint8_t     nlen   = (uint8_t)strlen(name);
                if (nlen > SDF_LONG_NAME_LEN) nlen = SDF_LONG_NAME_LEN;
                uint8_t     cont   = (nlen > SDF_NAME_LEN)
                                     ? (uint8_t)(nlen - SDF_NAME_LEN) : 0;
                /* Fixed part is 23 bytes; add continuation bytes */
                uint16_t sdc_sz = (uint16_t)(24 + cont);

                rc = bump_alloc(w, sdc_sz, &sdc_vptrs[i]);
                if (rc != SDF_OK) goto sym_err;

                uint8_t *p  = vptr_buf(w, sdc_vptrs[i]);
                const sdf_wsymbol_t *sd = &w->symbols[i].desc;
                memset(p, 0, sdc_sz);
                pw16(p, 0, sd->blk_no);
                pw8 (p, 6, sd->sym_class);
                pw8 (p, 7, sd->sym_type);
                pw8 (p, 8, sd->flag1);
                pw8 (p, 9, sd->flag2);
                pw8 (p, 10, sd->flag3);
                pw8 (p, 11, sd->flag4);
                pw8 (p, 12, nlen);
                /* rel_addr (3 bytes) */
                uint32_t ra = w->symbols[i].has_init
                              ? w->symbols[i].init_rel_addr : sd->rel_addr;
                pw8(p, 13, (ra >> 16) & 0xFF);
                pw8(p, 14, (ra >>  8) & 0xFF);
                pw8(p, 15,  ra        & 0xFF);
                pw8 (p, 18, sd->rows);
                pw8 (p, 19, sd->columns);
                pw8 (p, 20, sd->lock_num);
                /* byte_size (3 bytes) */
                pw8(p, 20, (sd->byte_size >> 16) & 0xFF);
                pw8(p, 21, (sd->byte_size >>  8) & 0xFF);
                pw8(p, 22,  sd->byte_size        & 0xFF);
                /* name continuation */
                if (cont > 0)
                    memcpy(p + 24, name + SDF_NAME_LEN, cont);
            }

            /* Write symbol nodes (now that sdc_vptrs are known) */
            for (uint16_t i = 0; i < w->num_symbs; i++) {
                uint8_t *p = vptr_buf(w, snode_vptrs[i]);
                pwstr(p, 0, w->symbols[i].desc.symb_name, SDF_NAME_LEN);
                pwvp (p, 8, sdc_vptrs[i]);
            }

            /* 4e. Statement nodes */
            sdf_vptr_t fstn_vptr = SDF_VPTR_NULL;
            sdf_vptr_t lstn_vptr = SDF_VPTR_NULL;
            uint16_t node_sz = w->has_srns ? 12 : 4;
            uint16_t exec_count = 0;

            /* First pass: allocate all statement nodes contiguously */
            sdf_vptr_t *stnode_vptrs = malloc(w->num_stmts * sizeof(sdf_vptr_t));
            sdf_vptr_t *stdc_vptrs   = malloc(w->num_stmts * sizeof(sdf_vptr_t));
            if (!stnode_vptrs || !stdc_vptrs) {
                free(stnode_vptrs); free(stdc_vptrs);
                goto sym_err;
            }

            for (uint16_t i = 0; i < w->num_stmts; i++) {
                rc = bump_alloc(w, node_sz, &stnode_vptrs[i]);
                if (rc != SDF_OK) {
                    free(stnode_vptrs); free(stdc_vptrs); goto sym_err;
                }
                if (i == 0)                       fstn_vptr = stnode_vptrs[i];
                if (i == w->num_stmts - 1)        lstn_vptr = stnode_vptrs[i];
            }

            /* Allocate statement data cells (6 bytes, exec only) */
            for (uint16_t i = 0; i < w->num_stmts; i++) {
                if (w->stmts[i].desc.is_exec) {
                    rc = bump_alloc(w, 6, &stdc_vptrs[i]);
                    if (rc != SDF_OK) {
                        free(stnode_vptrs); free(stdc_vptrs); goto sym_err;
                    }
                    exec_count++;
                } else {
                    stdc_vptrs[i] = SDF_VPTR_NULL;
                }
            }

            /* Write statement nodes and data cells */
            for (uint16_t i = 0; i < w->num_stmts; i++) {
                uint8_t *sn = vptr_buf(w, stnode_vptrs[i]);
                const sdf_wstmt_t *sd = &w->stmts[i].desc;

                if (w->has_srns) {
                    /* STMTNOD1: srn(6) + incount(2) + stdc_ptr(4) */
                    memcpy(sn, sd->srn, SDF_SRN_LEN);
                    pw16(sn, 6, sd->incl_cnt);
                    if (sd->is_exec) {
                        pwvp(sn, 8, stdc_vptrs[i]);
                    } else {
                        pw32(sn, 8, 0);  /* non-exec: ptr = 0 */
                    }
                } else {
                    /* STMTNOD0: stdc_ptr(4) */
                    if (sd->is_exec) {
                        pwvp(sn, 0, stdc_vptrs[i]);
                    } else {
                        pw32(sn, 0, 0);
                    }
                }

                if (sd->is_exec) {
                    uint8_t *dc = vptr_buf(w, stdc_vptrs[i]);
                    pw16(dc, 0, sd->blk_no);
                    pw16(dc, 2, sd->stmt_type);
                    pw8 (dc, 4, sd->num_labls);
                    pw8 (dc, 5, sd->num_lhs);
                }
            }

            free(stnode_vptrs);
            free(stdc_vptrs);

            /* 4f. Symbol extent cell */
            sdf_vptr_t sym_ext_vptr = SDF_VPTR_NULL;
            rc = build_sym_extent(w, &fsn_vptr, &sym_ext_vptr);
            if (rc != SDF_OK) goto sym_err;

            /* 4g. Statement extent cell */
            sdf_vptr_t stmt_ext_vptr = SDF_VPTR_NULL;
            if (w->num_stmts > 0) {
                rc = build_stmt_extent(w, &fstn_vptr, w->has_srns, &stmt_ext_vptr);
                if (rc != SDF_OK) goto sym_err;
            }

            /* 4h. Initialisation data */
            sdf_vptr_t init_vptr = SDF_VPTR_NULL;
            if (w->init_data_len > 0) {
                /* Align to halfword */
                if (w->bump.offset & 1) w->bump.offset++;
                rc = bump_alloc(w, (uint16_t)w->init_data_len, &init_vptr);
                if (rc != SDF_OK) goto sym_err;
                uint8_t *dp = vptr_buf(w, init_vptr);
                memcpy(dp, w->init_data, w->init_data_len);
            }

            /* ---- 5. Write PAGEZERO and DROOTCEL into page 0 ---- */
            rc = ensure_pages(w, 1);
            if (rc != SDF_OK) goto sym_err;

            uint8_t *p0 = (uint8_t *)w->pages[0];
            memset(p0, 0, SDF_PAGE_SIZE);

            /* PAGEZERO at offset 0:
             *   version(2) + pad(2) + dir_fc_ptr(4) + droot_ptr(4) + dat_fc_ptr(4) */
            sdf_vptr_t droot_vptr = SDF_VPTR_MAKE(0, PAGEZERO_SZ);
            pw16(p0, 0, w->version);        /* version    */
            pw32(p0, 4, 0);                 /* dir_fc_ptr */
            pwvp(p0, 8, droot_vptr);        /* droot_ptr  */
            pw32(p0, 12 - 4, 0);            /* dat_fc_ptr at offset 8? */
            /* Correct offsets per sdf_pagezero_disk_t:
             * [0] version(2) [2] pad(2) [4] dir_fc_ptr(4)
             * [8] droot_ptr(4) [12] dat_fc_ptr(4) */
            pw16(p0, 0, w->version);
            pw16(p0, 2, 0);
            pw32(p0, 4, 0);
            pwvp(p0, 8, droot_vptr);
            pw32(p0, 12, 0);

            /* DROOTCEL at offset PAGEZERO_SZ (12) */
            uint8_t *dr = p0 + PAGEZERO_SZ;
            memset(dr, 0, DROOTCEL_SZ);

            /* sdf_flags[0..1] */
            dr[0] = (w->flags >> 8) & 0xFF;
            dr[1] =  w->flags       & 0xFF;
            /* last_page */
            pw16(dr, 2, (uint16_t)(w->num_pages - 1));
            /* date/time */
            time_t now = time(NULL);
            pw32(dr, 4,  (uint32_t)now);   /* sdf_date (approx) */
            pw32(dr, 8,  0);               /* sdf_time */
            /* blk_nodes, sym_nodes */
            pw16(dr, 16, w->num_blks);
            pw16(dr, 18, w->num_symbs);
            /* fbn_ptr, lbn_ptr */
            pwvp(dr, 20, fbn_vptr);
            pwvp(dr, 24, lbn_vptr);
            /* fsn_ptr, lsn_ptr */
            pwvp(dr, 36, fsn_vptr);
            pwvp(dr, 40, lsn_vptr);
            /* btree_ptr */
            pwvp(dr, 48, btree_root);
            /* fstmt_num, lstm_num */
            uint16_t fstmt = w->num_stmts > 0 ? 1 : 0;
            uint16_t lstm  = w->num_stmts;
            pw16(dr, 52, fstmt);
            pw16(dr, 54, lstm);
            /* exec_stmt count */
            pw16(dr, 56, exec_count);
            /* stmt_node size */
            pw16(dr, 58, node_sz);
            /* fstn_ptr, lstn_ptr */
            if (w->num_stmts > 0) {
                pwvp(dr, 60, fstn_vptr);
                pwvp(dr, 64, lstn_vptr);
            }
            /* snel_ptr (stmt extent) */
            pwvp(dr, 68, stmt_ext_vptr);
            /* first_srn, last_srn (CL6 each) */
            if (w->has_srns && w->num_stmts > 0) {
                memcpy(dr + 72, w->stmts[0].desc.srn, SDF_SRN_LEN);
                memcpy(dr + 78, w->stmts[w->num_stmts-1].desc.srn, SDF_SRN_LEN);
            }
            /* dinit_ptr at offset 168 */
            pwvp(dr, 168, init_vptr);
            /* symb extent cell (snel_ptr for symbols is not in DROOTCEL --
             * it's stored in each BLKTCELL.ext_ptr).
             * Update ext_ptr in each BLKTCELL to the symbol extent cell. */
            if (sym_ext_vptr != SDF_VPTR_NULL) {
                for (uint16_t i = 0; i < w->num_blks; i++) {
                    uint8_t *bt = vptr_buf(w, w->blocks[i].btcell_vptr);
                    pwvp(bt, 16, sym_ext_vptr);
                }
            }

            /* ---- 6. Write all pages to disk ---- */
            if (fseek(w->fp, w->pg0_file_offset, SEEK_SET) != 0)
                goto sym_err;

            for (uint16_t pg = 0; pg < w->num_pages; pg++) {
                if (fwrite(w->pages[pg], SDF_PAGE_SIZE, 1, w->fp) != 1)
                    goto sym_err;
            }
            fflush(w->fp);

            /* ---- 7. Update the flat-file index entry ---- */
            uint8_t idx[20];
            /* name: space-padded to 8 chars */
            memset(idx, ' ', SDF_NAME_LEN);
            size_t nlen2 = strlen(w->member_name);
            if (nlen2 > SDF_NAME_LEN) nlen2 = SDF_NAME_LEN;
            memcpy(idx, w->member_name, nlen2);
            /* page_count (u32 big-endian) */
            idx[8]  = (w->num_pages >> 24) & 0xFF;
            idx[9]  = (w->num_pages >> 16) & 0xFF;
            idx[10] = (w->num_pages >>  8) & 0xFF;
            idx[11] =  w->num_pages        & 0xFF;
            /* pg0_offset (u64 big-endian) */
            uint64_t pg0off = (uint64_t)w->pg0_file_offset;
            idx[12] = (pg0off >> 56) & 0xFF;
            idx[13] = (pg0off >> 48) & 0xFF;
            idx[14] = (pg0off >> 40) & 0xFF;
            idx[15] = (pg0off >> 32) & 0xFF;
            idx[16] = (pg0off >> 24) & 0xFF;
            idx[17] = (pg0off >> 16) & 0xFF;
            idx[18] = (pg0off >>  8) & 0xFF;
            idx[19] =  pg0off        & 0xFF;

            if (fseek(w->fp, w->index_entry_offset, SEEK_SET) != 0)
                goto sym_err;
            if (fwrite(idx, 1, 20, w->fp) != 20)
                goto sym_err;
            fflush(w->fp);

            /* Success */
            free(snode_vptrs);
            free(sdc_vptrs);
            free(bnode_vptrs);
            fclose(w->fp); w->fp = NULL;
            /* Free everything except fp (already closed) */
            free(w->path);
            free(w->blocks);
            free(w->symbols);
            free(w->stmts);
            free(w->pages);
            free(w->init_data);
            free(w);
            *wp = NULL;
            return SDF_OK;

sym_err:
            free(snode_vptrs);
            free(sdc_vptrs);
        } /* if num_symbs > 0 */

        free(bnode_vptrs);
    } /* if num_blks > 0 */

    sdf_wcancel(wp);
    return rc != SDF_OK ? rc : SDF_ERR_CREATE_FAIL;
}

/* ------------------------------------------------------------------ */
/* Public: diagnostics                                                 */
/* ------------------------------------------------------------------ */

const char *sdf_wstrerror(sdf_rc_t rc)
{
    /* Cast to int to avoid -Wswitch for values outside the sdf_rc_t enum.
     * The write-path codes are defined as macros in sdf_write.h. */
    switch ((int)rc) {
    case -4030: return "cannot create/write SDF file";
    case -4031: return "virtual page limit exceeded";
    case -4032: return "duplicate block name";
    case -4033: return "duplicate symbol name in block";
    case -4034: return "NULL or invalid write context";
    case -4035: return "sdf_commit() not called";
    case -4036: return "statements added out of order";
    case -4037: return "bad initialisation data specification";
    default:    return sdf_strerror(rc);
    }
}

void sdf_wstats(const sdf_wctx_t *w,
                uint16_t *num_blks_out,
                uint16_t *num_symbs_out,
                uint16_t *num_stmts_out)
{
    if (!w) {
        if (num_blks_out)  *num_blks_out  = 0;
        if (num_symbs_out) *num_symbs_out = 0;
        if (num_stmts_out) *num_stmts_out = 0;
        return;
    }
    if (num_blks_out)  *num_blks_out  = w->num_blks;
    if (num_symbs_out) *num_symbs_out = w->num_symbs;
    if (num_stmts_out) *num_stmts_out = w->num_stmts;
}
