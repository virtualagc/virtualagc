/*
 * sdfpkg.h  --  Public C API for the HAL/S Symbol Data File (SDF) package.
 *
 * Replaces the SDFPKG / COMMTABL interface.  Callers create an opaque
 * sdf_ctx_t with sdf_open(), look up blocks/symbols/statements through
 * typed query functions, and close with sdf_close().
 *
 * Original service codes (modes 0-18) map to named functions:
 *
 *   Mode 0  → sdf_open()
 *   Mode 1  → sdf_close()
 *   Mode 2  → sdf_augment()
 *   Mode 3  → sdf_rescind()
 *   Mode 4  → sdf_select()
 *   Mode 5  → sdf_locate_ptr()
 *   Mode 6  → (internal: set disposition -- handled via locate flags)
 *   Mode 7  → sdf_locate_root()
 *   Mode 8  → sdf_find_block_by_number()
 *   Mode 9  → sdf_find_symbol_by_number()
 *   Mode 10 → sdf_find_stmt_by_number()
 *   Mode 11 → sdf_find_block_by_name()
 *   Mode 12 → sdf_find_symbol_by_block_and_name()
 *   Mode 13 → sdf_find_symbol_by_name()
 *   Mode 14 → sdf_find_stmt_by_srn()
 *   Mode 15 → sdf_find_block_node_by_number()
 *   Mode 16 → sdf_find_symbol_node_by_number()
 *   Mode 17 → sdf_find_stmt_node_by_number()
 *   Mode 18 → sdf_find_init_data()   (CR13079)
 */

#ifndef SDFPKG_H
#define SDFPKG_H

#include "sdf_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* ------------------------------------------------------------------ */
/* Opaque context                                                       */
/* ------------------------------------------------------------------ */

typedef struct sdf_ctx sdf_ctx_t;

/* ------------------------------------------------------------------ */
/* Open flags  (bitfield, passed to sdf_open)                          */
/* ------------------------------------------------------------------ */

#define SDF_OPEN_RDONLY      0x00   /* default: read-only             */
#define SDF_OPEN_UPDATE      0x01   /* open for read/write (update)   */
#define SDF_OPEN_FIRST_SYM   0x02   /* take first matching symbol     */
#define SDF_OPEN_ONE_FCB     0x04   /* keep only one FCB at a time    */

/* ------------------------------------------------------------------ */
/* Locate / disposition flags  (bitfield, passed to query functions)   */
/* ------------------------------------------------------------------ */

#define SDF_DISP_NONE        0x00
#define SDF_DISP_MODF        0x40   /* mark page as modified (dirty)  */
#define SDF_DISP_RELS        0x20   /* release a previous reserve     */
#define SDF_DISP_RESV        0x10   /* reserve (pin) the page         */

/* ------------------------------------------------------------------ */
/* Result structures returned by query functions                       */
/* ------------------------------------------------------------------ */

/* Block lookup result */
typedef struct {
    uint16_t  blk_no;                           /* block index        */
    uint16_t  blk_id;                           /* block stack ID     */
    uint8_t   blk_class;
    uint8_t   blk_type;
    uint8_t   blk_flags;
    char      csect_name[SDF_NAME_LEN + 1];     /* CSECT name         */
    char      blk_name[SDF_LONG_NAME_LEN + 1];  /* block name         */
    uint16_t  fsymb_no;                         /* first symbol #     */
    uint16_t  lsymb_no;                         /* last symbol #      */
    uint16_t  fstmt_no;                         /* first stmt #       */
    uint16_t  lstm_no;                          /* last stmt #        */
    void     *raw_cell;    /* pointer into paged memory (BLKTCELL)    */
} sdf_block_result_t;

/* Symbol lookup result */
typedef struct {
    uint16_t  symb_no;                          /* symbol index       */
    uint16_t  blk_no;                           /* owning block index */
    char      symb_name[SDF_LONG_NAME_LEN + 1]; /* full symbol name   */
    uint8_t   sym_class;
    uint8_t   sym_type;
    uint8_t   flag1, flag2, flag3, flag4;
    uint8_t   rows, columns;
    uint8_t   symb_len;
    void     *raw_cell;    /* pointer into paged memory (SYMBDC)      */
} sdf_symbol_result_t;

/* Statement lookup result */
typedef struct {
    uint16_t  stmt_no;                          /* statement index    */
    uint16_t  blk_no;                           /* owning block index */
    uint16_t  stmt_type;
    uint8_t   num_labls;
    uint8_t   num_lhs;
    char      srn[SDF_SRN_LEN + 1];             /* SRN (if present)   */
    bool      is_executable;
    void     *raw_cell;    /* pointer into paged memory (STMTDC)      */
} sdf_stmt_result_t;

/* ------------------------------------------------------------------ */
/* Lifecycle                                                            */
/* ------------------------------------------------------------------ */

/*
 * sdf_open()  --  Mode 0: Initialize the SDF package.
 *
 * Opens the SDF PDS-equivalent file at `path`.  On z/OS this was a
 * PDS; on Linux it is a flat binary file whose layout is the sequence
 * of raw 1680-byte pages belonging to one or more named members,
 * described by a small index at the start of the file (see sdf_io.h).
 *
 * Parameters:
 *   path      - path to the SDF file
 *   flags     - SDF_OPEN_* flags
 *   npages    - initial size of in-memory paging area (0 → default 2)
 *   ctx_out   - receives newly allocated context on success
 *
 * Returns SDF_OK on success, negative sdf_rc_t on error.
 */
sdf_rc_t sdf_open(const char *path, int flags, int npages,
                  sdf_ctx_t **ctx_out);

/*
 * sdf_close()  --  Mode 1: Terminate the SDF package.
 *
 * Flushes modified pages, frees all memory, closes the file.
 * After this call *ctx is NULL.
 */
sdf_rc_t sdf_close(sdf_ctx_t **ctx);

/*
 * sdf_augment()  --  Mode 2: Augment the in-memory paging area.
 *
 * npages_add   additional page slots to add (0 → check FCB area only)
 * nbytes_add   additional FCB bytes (0 → check paging area only)
 */
sdf_rc_t sdf_augment(sdf_ctx_t *ctx, int npages_add, int nbytes_add);

/*
 * sdf_rescind()  --  Mode 3: Release augmented paging area pages.
 */
sdf_rc_t sdf_rescind(sdf_ctx_t *ctx);

/* ------------------------------------------------------------------ */
/* Member selection                                                     */
/* ------------------------------------------------------------------ */

/*
 * sdf_select()  --  Mode 4: Select a named SDF member.
 *
 * `member_name` is an ASCII string up to 8 characters.
 * Must be called (once per member) before any lookup.
 * Idempotent if called again with the same name.
 *
 * On success the context is positioned on the selected member.
 * Returns SDF_OK, or SDF_ERR_* on failure.
 */
sdf_rc_t sdf_select(sdf_ctx_t *ctx, const char *member_name);

/* ------------------------------------------------------------------ */
/* Low-level pointer access                                            */
/* ------------------------------------------------------------------ */

/*
 * sdf_locate()  --  Mode 5: Translate a virtual pointer to a real address.
 *
 * Returns the host pointer corresponding to `vptr`, loading the page
 * from disk if necessary.  `disp_flags` is a combination of
 * SDF_DISP_* bits.  On success `*addr_out` receives the pointer.
 */
sdf_rc_t sdf_locate(sdf_ctx_t *ctx, sdf_vptr_t vptr, int disp_flags,
                    void **addr_out);

/*
 * sdf_locate_root()  --  Mode 7: Locate the SDF directory root cell.
 *
 * Returns a pointer to the in-memory sdf_drootcel_disk_t (in paged
 * memory).  The returned pointer is valid until the next I/O operation.
 */
sdf_rc_t sdf_locate_root(sdf_ctx_t *ctx, int disp_flags,
                         void **root_out);

/* ------------------------------------------------------------------ */
/* Block lookups                                                        */
/* ------------------------------------------------------------------ */

/* Mode 8 / 11 -- find block data cell by number / name */
sdf_rc_t sdf_find_block_by_number(sdf_ctx_t *ctx, uint16_t blk_no,
                                  int disp_flags,
                                  sdf_block_result_t *result);

sdf_rc_t sdf_find_block_by_name(sdf_ctx_t *ctx, const char *blk_name,
                                int disp_flags,
                                sdf_block_result_t *result);

/* Mode 15 -- find block *node* only (no tree-cell follow-through) */
sdf_rc_t sdf_find_block_node_by_number(sdf_ctx_t *ctx, uint16_t blk_no,
                                       int disp_flags,
                                       char csect_name_out[SDF_NAME_LEN + 1]);

/* ------------------------------------------------------------------ */
/* Symbol lookups                                                       */
/* ------------------------------------------------------------------ */

/* Mode 9  -- find symbol data cell by symbol number */
sdf_rc_t sdf_find_symbol_by_number(sdf_ctx_t *ctx, uint16_t symb_no,
                                   int disp_flags,
                                   sdf_symbol_result_t *result);

/* Mode 12 -- find symbol by block name + symbol name */
sdf_rc_t sdf_find_symbol_by_block_and_name(sdf_ctx_t *ctx,
                                           const char *blk_name,
                                           const char *symb_name,
                                           int disp_flags,
                                           sdf_symbol_result_t *result);

/* Mode 13 -- find symbol by name within the last-selected block */
sdf_rc_t sdf_find_symbol_by_name(sdf_ctx_t *ctx, const char *symb_name,
                                 int disp_flags,
                                 sdf_symbol_result_t *result);

/* Mode 16 -- find symbol *node* only */
sdf_rc_t sdf_find_symbol_node_by_number(sdf_ctx_t *ctx, uint16_t symb_no,
                                        int disp_flags,
                                        char name_out[SDF_NAME_LEN + 1],
                                        sdf_vptr_t *sdc_ptr_out);

/* ------------------------------------------------------------------ */
/* Statement lookups                                                    */
/* ------------------------------------------------------------------ */

/* Mode 10 / 17 -- find statement data cell / node by number */
sdf_rc_t sdf_find_stmt_by_number(sdf_ctx_t *ctx, uint16_t stmt_no,
                                 int disp_flags,
                                 sdf_stmt_result_t *result);

sdf_rc_t sdf_find_stmt_node_by_number(sdf_ctx_t *ctx, uint16_t stmt_no,
                                      int disp_flags,
                                      sdf_stmt_result_t *result);

/* Mode 14 -- find statement by SRN (statement reference number) */
sdf_rc_t sdf_find_stmt_by_srn(sdf_ctx_t *ctx,
                               const char srn[SDF_SRN_LEN],
                               int disp_flags,
                               sdf_stmt_result_t *result);

/* ------------------------------------------------------------------ */
/* CR13079: Initialization data  (Mode 18)                             */
/* ------------------------------------------------------------------ */

sdf_rc_t sdf_find_init_data(sdf_ctx_t *ctx, uint16_t symb_no,
                             int disp_flags, void **data_out);

/* ------------------------------------------------------------------ */
/* Diagnostic / utility                                                 */
/* ------------------------------------------------------------------ */

/* Human-readable description of an sdf_rc_t value */
const char *sdf_strerror(sdf_rc_t rc);

/* Number of pages currently in core, total reads, writes */
void sdf_stats(const sdf_ctx_t *ctx,
               uint32_t *reads_out,
               uint32_t *writes_out,
               uint32_t *selects_out);

#ifdef __cplusplus
}
#endif

#endif /* SDFPKG_H */
