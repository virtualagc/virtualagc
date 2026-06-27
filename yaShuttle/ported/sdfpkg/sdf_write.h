/*
 * sdf_write.h  --  Public API for the SDF write (creation) infrastructure.
 *
 * This header provides the write-side complement to sdfpkg.h.  Where
 * sdfpkg.h covers reading existing SDF members, this header covers
 * building new SDF members from scratch -- the operation needed by
 * PASS3 of HALSFC when it generates an SDF for a compiled module.
 *
 * Usage pattern
 * =============
 *
 *   sdf_wctx_t *w = NULL;
 *   sdf_create("myfile.sdf", "MYMOD", SDF_VER_DEFAULT,
 *              SDF_WFLAG_HAS_SRNS, &w);
 *
 *   // Add one block (program unit):
 *   uint16_t blk_no;
 *   sdf_write_block(w, &(sdf_wblock_t){
 *       .csect_name = "MYCSECT",
 *       .blk_name   = "MYPROG",
 *       .blk_class  = SDF_BCLASS_PROGRAM,
 *       .blk_type   = 0,
 *       .blk_id     = 1,
 *   }, &blk_no);
 *
 *   // Add symbols (in any order; they are sorted alphabetically on commit):
 *   uint16_t sym_no;
 *   sdf_write_symbol(w, &(sdf_wsymbol_t){
 *       .blk_no     = blk_no,
 *       .symb_name  = "ALTITUDE",
 *       .sym_class  = SDF_SCLASS_VARIABLE,
 *       .sym_type   = SDF_STYPE_SCALAR,
 *   }, &sym_no);
 *
 *   // Add statements (in statement-number order):
 *   uint16_t stmt_no;
 *   sdf_write_stmt(w, &(sdf_wstmt_t){
 *       .blk_no     = blk_no,
 *       .srn        = "S0001 ",
 *       .stmt_type  = SDF_STTYPE_ASSIGN,
 *       .is_exec    = true,
 *       .num_lhs    = 1,
 *       .num_labls  = 0,
 *   }, &stmt_no);
 *
 *   // Finalise: sorts, builds trees, writes file.
 *   sdf_commit(&w);
 *
 * To add a second member to the same file, call sdf_add_member() after
 * sdf_commit() to open a new write context on the same file.
 *
 * Thread safety
 * =============
 * sdf_wctx_t objects are not thread-safe.  Use one context per thread.
 */

#ifndef SDF_WRITE_H
#define SDF_WRITE_H

#include "sdf_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* ------------------------------------------------------------------ */
/* Write context (opaque)                                              */
/* ------------------------------------------------------------------ */

typedef struct sdf_wctx sdf_wctx_t;

/* ------------------------------------------------------------------ */
/* Additional error codes for the write path                           */
/* ------------------------------------------------------------------ */

/* These extend sdf_rc_t; cast freely between the two. */
#define SDF_ERR_CREATE_FAIL  ((sdf_rc_t)(-4030))  /* cannot create file */
#define SDF_ERR_PAGE_FULL    ((sdf_rc_t)(-4031))  /* virtual page limit  */
#define SDF_ERR_DUP_BLK      ((sdf_rc_t)(-4032))  /* duplicate block     */
#define SDF_ERR_DUP_SYMB     ((sdf_rc_t)(-4033))  /* duplicate symbol    */
#define SDF_ERR_NOT_WCTX     ((sdf_rc_t)(-4034))  /* wrong context type  */
#define SDF_ERR_NO_COMMIT    ((sdf_rc_t)(-4035))  /* commit not called   */
#define SDF_ERR_BAD_STMT_ORD ((sdf_rc_t)(-4036))  /* stmts out of order  */
#define SDF_ERR_INIT_DATA    ((sdf_rc_t)(-4037))  /* bad init data       */

/* ------------------------------------------------------------------ */
/* Write flags  (passed to sdf_create / sdf_add_member)               */
/* ------------------------------------------------------------------ */

#define SDF_WFLAG_NONE       0x0000
#define SDF_WFLAG_HAS_SRNS   0x8000  /* statement nodes carry SRNs     */
#define SDF_WFLAG_NONMONO    0x0400  /* SRNs are not monotonic         */

/* ------------------------------------------------------------------ */
/* Version number                                                       */
/* ------------------------------------------------------------------ */

#define SDF_VER_DEFAULT  1   /* SDF format version written by this library */

/* ------------------------------------------------------------------ */
/* Block class and type constants  (BLKTCELL.blk_class / blk_type)    */
/* ------------------------------------------------------------------ */

#define SDF_BCLASS_PROGRAM    1
#define SDF_BCLASS_FUNCTION   2
#define SDF_BCLASS_PROCEDURE  3
#define SDF_BCLASS_TASK       4
#define SDF_BCLASS_COMPOOL    5
#define SDF_BCLASS_CLOSE      6

/* ------------------------------------------------------------------ */
/* Symbol class and type constants  (SYMBDC.sym_class / sym_type)     */
/* ------------------------------------------------------------------ */

#define SDF_SCLASS_VARIABLE   1
#define SDF_SCLASS_EQUATE_EXT 2
#define SDF_SCLASS_TEMPLATE   3
#define SDF_SCLASS_LABEL      4
#define SDF_SCLASS_COMPOOL    6

#define SDF_STYPE_SCALAR      1
#define SDF_STYPE_INTEGER     2
#define SDF_STYPE_BOOLEAN     3
#define SDF_STYPE_CHARACTER   4
#define SDF_STYPE_BIT         5
#define SDF_STYPE_VECTOR      6
#define SDF_STYPE_MATRIX      7
#define SDF_STYPE_EQUATE_EXT  8
#define SDF_STYPE_EVENT       9
#define SDF_STYPE_STRUCTURE  10
#define SDF_STYPE_TASK       11

/* ------------------------------------------------------------------ */
/* Statement type constants  (STMTDC.stmt_type)                       */
/* ------------------------------------------------------------------ */

#define SDF_STTYPE_ASSIGN      1
#define SDF_STTYPE_IF          2
#define SDF_STTYPE_DO          3
#define SDF_STTYPE_DO_WHILE    4
#define SDF_STTYPE_DO_UNTIL    5
#define SDF_STTYPE_DO_FOR      6
#define SDF_STTYPE_END         7
#define SDF_STTYPE_RETURN      8
#define SDF_STTYPE_CALL        9
#define SDF_STTYPE_GOTO       10
#define SDF_STTYPE_ON_ERROR   11

/* ------------------------------------------------------------------ */
/* Input descriptor structures                                          */
/*                                                                     */
/* These are the caller-facing descriptions of what to write.  They   */
/* are buffered internally and laid out in virtual memory at commit    */
/* time.  Callers may initialise them with designated-initialiser      */
/* syntax and leave unused fields zero.                                */
/* ------------------------------------------------------------------ */

/*
 * sdf_wblock_t -- descriptor for one block (program unit).
 *
 * csect_name  : CSECT (object-module section) name, up to 8 chars.
 * blk_name    : Block name as it appears in HAL/S source, up to 32 chars.
 * blk_class   : SDF_BCLASS_* constant.
 * blk_type    : Sub-type (compiler-specific; 0 for most uses).
 * blk_id      : Unique block (stack) ID assigned by the compiler.
 * blk_flags   : BLKTCELL flag byte (pass 0 if not needed).
 * post_dcl    : Statement number of first post-declare statement (0 if none).
 * stak_list   : Stack variable list head (0 if none).
 *
 * The symbol and statement ranges (fsymb_no, lsymb_no, fstmt_no, lstm_no)
 * are filled in automatically by sdf_commit() from the symbols and
 * statements that have been associated with this block.
 */
typedef struct {
    char     csect_name[SDF_NAME_LEN + 1];
    char     blk_name[SDF_LONG_NAME_LEN + 1];
    uint8_t  blk_class;
    uint8_t  blk_type;
    uint16_t blk_id;
    uint8_t  blk_flags;
    uint16_t post_dcl;
    uint16_t stak_list;
} sdf_wblock_t;

/*
 * sdf_wsymbol_t -- descriptor for one symbol.
 *
 * blk_no     : Block number this symbol belongs to (from sdf_write_block).
 * symb_name  : Full symbol name, up to 32 chars.
 * sym_class  : SDF_SCLASS_* constant.
 * sym_type   : SDF_STYPE_* constant.
 * flag1..4   : Compiler flag bytes (pass 0 if not needed).
 * rows       : For VECTOR: length; for BIT: bit-length; else 0.
 * columns    : For MATRIX: column count; for CHARACTER: char length; else 0.
 * rel_addr   : Relative core address (3-byte value, 0 if not used).
 * lock_num   : Lock group number (0 if not locked).
 * byte_size  : Total bytes used by this symbol in memory (0 if not known).
 */
typedef struct {
    uint16_t blk_no;
    char     symb_name[SDF_LONG_NAME_LEN + 1];
    uint8_t  sym_class;
    uint8_t  sym_type;
    uint8_t  flag1, flag2, flag3, flag4;
    uint8_t  rows;
    uint8_t  columns;
    uint32_t rel_addr;
    uint8_t  lock_num;
    uint32_t byte_size;
} sdf_wsymbol_t;

/*
 * sdf_wstmt_t -- descriptor for one statement.
 *
 * blk_no     : Block number this statement belongs to.
 * srn        : Statement Reference Number, exactly SDF_SRN_LEN (6) chars,
 *              space-padded.  Ignored if SDF_WFLAG_HAS_SRNS was not set.
 * incl_cnt   : Include count (for SRN; normally 0).
 * stmt_type  : SDF_STTYPE_* constant (used only for executable stmts).
 * is_exec    : true for executable statements; false for declarations.
 * num_lhs    : Number of left-hand-side targets (assignments).
 * num_labls  : Number of labels on this statement.
 *
 * Non-executable statements (is_exec = false) do not generate a STMTDC;
 * their STMTNOD entry has stdc_ptr = 0.
 */
typedef struct {
    uint16_t blk_no;
    char     srn[SDF_SRN_LEN];  /* 6 chars, space-padded, no NUL needed */
    uint16_t incl_cnt;
    uint16_t stmt_type;
    bool     is_exec;
    uint8_t  num_lhs;
    uint8_t  num_labls;
} sdf_wstmt_t;

/* ------------------------------------------------------------------ */
/* Lifecycle                                                            */
/* ------------------------------------------------------------------ */

/*
 * sdf_create() -- Create a new SDF flat file and begin a new member.
 *
 * Creates the file at `path` (truncating any existing content), writes
 * a placeholder flat-file header, and initialises a write context for
 * the named member.
 *
 * Parameters:
 *   path        : File path to create.
 *   member_name : SDF member name, up to 8 ASCII characters.
 *   version     : SDF version number to write (use SDF_VER_DEFAULT).
 *   flags       : Combination of SDF_WFLAG_* bits.
 *   wctx_out    : Receives the newly allocated write context.
 *
 * Returns SDF_OK, or a negative error code.
 */
sdf_rc_t sdf_create(const char    *path,
                    const char    *member_name,
                    uint16_t       version,
                    uint16_t       flags,
                    sdf_wctx_t   **wctx_out);

/*
 * sdf_add_member() -- Add a new member to an existing SDF flat file.
 *
 * Opens an existing flat file (already containing one or more committed
 * members) and initialises a fresh write context for a new member.
 * The new member is appended to the file's index on sdf_commit().
 *
 * Parameters are identical to sdf_create() except that the file must
 * already exist.
 */
sdf_rc_t sdf_add_member(const char    *path,
                         const char    *member_name,
                         uint16_t       version,
                         uint16_t       flags,
                         sdf_wctx_t   **wctx_out);

/*
 * sdf_commit() -- Finalise the SDF member and write it to disk.
 *
 * Sorts symbols alphabetically and blocks by name, builds the block
 * name tree, builds symbol and statement extent cells, lays out all
 * node and data-cell structures into virtual-memory pages, writes the
 * DROOTCEL and PAGEZERO, flushes all pages to disk, and writes (or
 * updates) the flat-file index entry for this member.
 *
 * On success *wctx is set to NULL and all resources are freed.
 * On failure the write context remains valid and the caller may
 * inspect it, but the file on disk is in an indeterminate state.
 */
sdf_rc_t sdf_commit(sdf_wctx_t **wctx);

/*
 * sdf_wcancel() -- Abandon a write context without writing to disk.
 *
 * Frees all buffered data and closes the file.  The file on disk is
 * left in whatever state it was in before sdf_create() or
 * sdf_add_member() was called (i.e., for sdf_create(), an empty or
 * partially-written file remains and should be deleted by the caller).
 */
void sdf_wcancel(sdf_wctx_t **wctx);

/* ------------------------------------------------------------------ */
/* Adding data                                                          */
/* ------------------------------------------------------------------ */

/*
 * sdf_write_block() -- Add a block descriptor to the write context.
 *
 * May be called in any order; blocks are sorted by name at commit time.
 * Returns SDF_ERR_DUP_BLK if a block with the same name already exists.
 * On success *blk_no_out receives the assigned block number (1-based),
 * which the caller should use in subsequent sdf_write_symbol() and
 * sdf_write_stmt() calls.
 */
sdf_rc_t sdf_write_block(sdf_wctx_t        *w,
                          const sdf_wblock_t *blk,
                          uint16_t           *blk_no_out);

/*
 * sdf_write_symbol() -- Add a symbol descriptor to the write context.
 *
 * May be called in any order; symbols are sorted alphabetically at
 * commit time.  Returns SDF_ERR_DUP_SYMB if a symbol with the same
 * name in the same block already exists.
 * On success *symb_no_out receives the assigned symbol number.
 */
sdf_rc_t sdf_write_symbol(sdf_wctx_t         *w,
                           const sdf_wsymbol_t *sym,
                           uint16_t            *symb_no_out);

/*
 * sdf_write_stmt() -- Add a statement descriptor to the write context.
 *
 * Statements must be added in monotonically increasing statement-number
 * order (i.e., in source order).  The first call establishes the base
 * statement number as 1; subsequent calls assign the next number.
 * Returns SDF_ERR_BAD_STMT_ORD if a statement is added out of order.
 * On success *stmt_no_out receives the assigned statement number.
 */
sdf_rc_t sdf_write_stmt(sdf_wctx_t       *w,
                         const sdf_wstmt_t *stmt,
                         uint16_t          *stmt_no_out);

/*
 * sdf_write_init_data() -- Write initialisation data for a symbol.
 *
 * Appends `nbytes` of raw initialisation data for the symbol identified
 * by `symb_no`.  The data is written into the data area beginning at
 * the next available halfword-aligned address, and the symbol's RELADDR
 * field is set to that address / 2.
 *
 * `data` must point to `nbytes` bytes of data in big-endian byte order.
 * `nbytes` must be even (halfword-aligned).
 *
 * Returns SDF_OK, or SDF_ERR_INIT_DATA if nbytes is odd or symb_no is
 * invalid, or SDF_ERR_PAGE_FULL if virtual memory is exhausted.
 */
sdf_rc_t sdf_write_init_data(sdf_wctx_t   *w,
                              uint16_t      symb_no,
                              const void   *data,
                              size_t        nbytes);

/* ------------------------------------------------------------------ */
/* Diagnostics                                                          */
/* ------------------------------------------------------------------ */

/*
 * sdf_wstrerror() -- Human-readable string for a write-path error code.
 *
 * Returns the string from sdf_strerror() for read-path codes, and a
 * write-specific string for SDF_ERR_CREATE_FAIL and friends.
 */
const char *sdf_wstrerror(sdf_rc_t rc);

/*
 * sdf_wstats() -- Return counts of items buffered in the write context.
 */
void sdf_wstats(const sdf_wctx_t *w,
                uint16_t *num_blks_out,
                uint16_t *num_symbs_out,
                uint16_t *num_stmts_out);

#ifdef __cplusplus
}
#endif

#endif /* SDF_WRITE_H */
