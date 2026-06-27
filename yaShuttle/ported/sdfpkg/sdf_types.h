/*
 * sdf_types.h  --  Core types and on-disk/in-memory data structures
 *                  for the HAL/S Symbol Data File (SDF) package.
 *
 * Ported from IBM System/360 BAL (HAL/S-FC compiler, Space Shuttle era).
 * Original sources: DATABUF.bal, FCBCELL.bal, PDENTRY.bal, PAGEZERO.bal,
 *   DROOTCEL.bal, BLKTCELL.bal, BLCKNODE.bal, SYMBNODE.bal, SYMBDC.bal,
 *   STMTDC.bal, STMTNOD0.bal, COMMTABL.bal.
 *
 * Design notes
 * ============
 *  - "Virtual pointer"  (sdf_vptr_t): the original packing scheme is
 *    preserved -- high 16 bits = page number, low 16 bits = byte offset
 *    within a 1680-byte page.  Helper macros decompose/compose these.
 *  - All on-disk structures use fixed-width types so the layout matches
 *    the original big-endian S/360 records.  Fields are read from disk
 *    with explicit byte-swap helpers (see sdf_io.h).
 *  - In-memory structures (FCB, PAD entries, databuf) use host-endian
 *    types for speed.
 *  - Names that were EBCDIC CL8 or CL32 fields are plain ASCII char
 *    arrays here; callers supply null-terminated C strings and the
 *    library right-pads / truncates as needed.
 */

#ifndef SDF_TYPES_H
#define SDF_TYPES_H

/* ------------------------------------------------------------------ */
/* Portability                                                          */
/* ------------------------------------------------------------------ */

/* _POSIX_C_SOURCE: needed on Linux for fseeko/off_t; macOS exposes   */
/* these by default; on MSYS2/MinGW the CRT provides them natively.   */
#if defined(__linux__)
#  ifndef _POSIX_C_SOURCE
#    define _POSIX_C_SOURCE 200809L
#  endif
#endif

/* SDF_PACKED: portable packed-struct attribute.                       */
/* GCC and Clang both support __attribute__((packed)).                 */
/* MSVC requires #pragma pack; we emit a warning if neither is known.  */
#if defined(__GNUC__) || defined(__clang__)
#  define SDF_PACKED __attribute__((packed))
#elif defined(_MSC_VER)
#  define SDF_PACKED   /* handled via #pragma pack below */
#  pragma pack(push, 1)
#else
#  define SDF_PACKED
#  warning "SDF_PACKED not defined for this compiler; on-disk structs may be padded"
#endif

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

/* ------------------------------------------------------------------ */
/* Fundamental constants                                               */
/* ------------------------------------------------------------------ */

#define SDF_PAGE_SIZE       1680    /* bytes per SDF page              */
#define SDF_NAME_LEN           8    /* short name field width (chars)  */
#define SDF_LONG_NAME_LEN     32    /* block / symbol long name width  */
#define SDF_SRN_LEN            6    /* SRN field length (CL6 in STMTNOD1/COMMTABL) */
#define SDF_SRN_PAD_LEN        8    /* SRN as stored in extent cells (CL8, space-padded) */
#define SDF_MAX_PAGES        250    /* max pages in paging area        */
#define SDF_PAD_SLOTS        250    /* paging area directory slots     */
#define SDF_FCB_PRIMARY     1024    /* bytes: primary FCB allocation   */
#define SDF_FCB_SECONDARY    512    /* bytes: secondary FCB allocation */
#define SDF_MAX_STACK         50    /* max entries in internal stacks  */

/* ------------------------------------------------------------------ */
/* Virtual memory pointer                                              */
/*                                                                     */
/*   31      16 15       0                                             */
/*  +---------+---------+                                              */
/*  | page #  |  offset |                                              */
/*  +---------+---------+                                              */
/* ------------------------------------------------------------------ */

typedef uint32_t sdf_vptr_t;

#define SDF_VPTR_NULL          ((sdf_vptr_t)0)
#define SDF_VPTR_PAGE(vp)      ((uint16_t)(((vp) >> 16) & 0xFFFF))
#define SDF_VPTR_OFFSET(vp)    ((uint16_t)((vp) & 0xFFFF))
#define SDF_VPTR_MAKE(pg, off) ((sdf_vptr_t)(((uint32_t)(pg) << 16) | \
                                             ((uint32_t)(off) & 0xFFFF)))

/* ------------------------------------------------------------------ */
/* Return / error codes                                                */
/*                                                                     */
/* Positive values: informational (item not found, non-executable ...) */
/* Negative values: fatal errors (maps to original ABEND codes)        */
/* ------------------------------------------------------------------ */

typedef enum {
    SDF_OK              =  0,
    SDF_NOT_FOUND       = 16,   /* block / symbol not found           */
    SDF_SYM_NOT_FOUND   = 20,   /* symbol not found                   */
    SDF_NOT_EXEC        = 24,   /* stmt found but not executable      */
    SDF_NO_SRNS         = 28,   /* file has no SRNs                   */
    SDF_SRNS_NONMONO    = 32,   /* SRNs are not monotonic             */
    SDF_STMT_OOB        = 36,   /* statement number out of range      */

    /* Fatal / abend codes (negative mirrors of original U4xxx) */
    SDF_ERR_DEADLOCK    = -4001, /* paging area deadlocked            */
    SDF_ERR_OPEN_FAIL   = -4002, /* file open / SYNAD failure         */
    SDF_ERR_RESERVE_OVF = -4003, /* too many reserves                 */
    SDF_ERR_RELEASE_OVF = -4004, /* too many releases                 */
    SDF_ERR_BAD_PTR     = -4005, /* bad virtual pointer               */
    SDF_ERR_BAD_BLOCK   = -4006, /* bad block index                   */
    SDF_ERR_BAD_SYMB    = -4007, /* bad symbol index                  */
    SDF_ERR_MODF_MODE   = -4008, /* MODF without UPDAT mode           */
    SDF_ERR_NOT_INIT    = -4009, /* called before init                */
    SDF_ERR_NO_SELECT   = -4010, /* select-dependent call, no select  */
    SDF_ERR_RESCIND_RSV = -4011, /* rescind with reserved pages       */
    SDF_ERR_RESCIND_NA  = -4012, /* rescind without external area     */
    SDF_ERR_BAD_PGAREA  = -4013, /* bad paging area specification     */
    SDF_ERR_NO_CURENTRY = -4014, /* SETDISPS before any LOCATE        */
    SDF_ERR_BAD_FCBAREA = -4015, /* bad FCB area specification        */
    SDF_ERR_BAD_SVCCODE = -4016, /* bad service code                  */
    SDF_ERR_MULTI_INIT  = -4017, /* multiple INIT calls               */
    SDF_ERR_FCB_OOM     = -4018, /* FCB area exhausted                */
    SDF_ERR_GETMAIN     = -4019, /* memory allocation failure         */
    SDF_ERR_BLK_NOSPEC  = -4020, /* block not previously specified    */
    SDF_ERR_STACK_OVF   = -4021, /* internal stack exhausted          */
    SDF_ERR_SEL_RESERVED= -4022, /* select while pages reserved       */
    SDF_ERR_LEN_MISMATCH= -4023, /* SDF length mismatch               */
} sdf_rc_t;

/* ------------------------------------------------------------------ */
/* Paging Area Directory Entry  (PDENTRY.bal)                          */
/*                                                                     */
/* One slot per in-memory page in the paging area.                     */
/* ------------------------------------------------------------------ */

typedef struct sdf_pad_entry {
    void        *page_addr;     /* pointer to the 1680-byte buffer    */
    struct sdf_fcb *fcb_addr;   /* FCB that owns this page (or NULL)  */
    bool         modified;      /* page has been written (dirty bit)  */
    uint32_t     use_count;     /* recency counter for LRU eviction   */
    uint16_t     page_no;       /* page number * 8 (original encoding)*/
    uint16_t     resv_count;    /* reserve counter                    */
} sdf_pad_entry_t;

/* ------------------------------------------------------------------ */
/* File Control Block  (FCBCELL.bal)                                   */
/*                                                                     */
/* One FCB per selected SDF member; they live in a binary tree keyed  */
/* by filename.                                                        */
/* ------------------------------------------------------------------ */

typedef struct sdf_fcb {
    /* Binary tree links (keyed on filename, ASCII) */
    struct sdf_fcb *gt_tree;        /* right child (filename >)       */
    struct sdf_fcb *lt_tree;        /* left child  (filename <)       */

    char            filename[SDF_NAME_LEN + 1]; /* null-terminated    */

    /* Virtual pointers into the SDF data */
    sdf_vptr_t      blk_ptr;        /* first block node               */
    sdf_vptr_t      symb_ptr;       /* first symbol node              */
    sdf_vptr_t      stmt_ptr;       /* first statement node           */
    sdf_vptr_t      tree_ptr;       /* root of block tree             */
    sdf_vptr_t      stmt_expt;      /* statement node extent cell ptr */

    uint16_t        node_size;      /* size of a statement node (4 or 12) */
    uint16_t        flags;          /* SDF flags (SRNs present, etc.) */
    uint16_t        num_blks;       /* number of block nodes          */
    uint16_t        num_symbs;      /* number of symbol nodes         */
    uint16_t        fst_stmt;       /* first statement number         */
    uint16_t        lst_stmt;       /* last statement number          */
    uint16_t        lst_page;       /* last SDF page number           */
    uint16_t        version;        /* SDF version number             */

    /* Per-page TTR equivalents: file offset of each page.
     * Index by page_number; each entry is the file offset (in bytes)
     * of that page's start within the SDF member data.
     * Allocated at FCB creation time: (lst_page+1) * sizeof(off_t).  */
    off_t          *page_offsets;   /* replaces FCBTTRZ array         */

    /* PAD back-references: one slot per page (parallel to page_offsets).
     * NULL means the page is not currently in core.                   */
    sdf_pad_entry_t **pad_refs;     /* replaces FCBPDADR array        */
} sdf_fcb_t;

/* Flag bits in fcb->flags (and drootcel->sdf_flags) */
#define SDF_FLAG_HAS_SRNS   0x8000  /* statement nodes have SRNs (sdf_flags[0] bit7) */
#define SDF_FLAG_NONMONO    0x0400  /* SRNs not monotonic (sdf_flags[0] bit2) */

/* ------------------------------------------------------------------ */
/* Page-zero layout  (PAGEZERO.bal)                                    */
/* On-disk, big-endian.  We read it and convert on load.              */
/* ------------------------------------------------------------------ */

typedef struct {
    uint16_t version;           /* SDF version number                 */
    uint16_t _pad;
    uint32_t dir_fc_ptr;        /* directory free cell chain ptr      */
    uint32_t droot_ptr;         /* directory root cell ptr            */
    uint32_t dat_fc_ptr;        /* data free cell chain ptr           */
} SDF_PACKED sdf_pagezero_disk_t;

/* ------------------------------------------------------------------ */
/* Directory Root Cell  (DROOTCEL.bal)                                 */
/* On-disk, big-endian.                                               */
/* ------------------------------------------------------------------ */

typedef struct {
    uint8_t  sdf_flags[2];
    uint16_t last_page;
    uint32_t sdf_date;
    uint32_t sdf_time;
    uint16_t last_dpage;
    uint16_t compools;
    uint16_t blk_nodes;
    uint16_t sym_nodes;
    uint32_t fbn_ptr;           /* first block node ptr               */
    uint32_t lbn_ptr;           /* last block node ptr                */
    uint16_t instr_cnt;
    uint16_t free_byte;
    uint16_t dlst_head;
    uint16_t rlst_head;
    uint32_t fsn_ptr;           /* first symbol node ptr              */
    uint32_t lsn_ptr;           /* last symbol node ptr               */
    uint32_t cubtc_ptr;
    uint32_t btree_ptr;         /* root of block tree                 */
    uint16_t fstmt_num;
    uint16_t lstm_num;
    uint16_t exec_stmt;
    uint16_t stmt_node;
    uint32_t fstn_ptr;          /* first statement node ptr           */
    uint32_t lstn_ptr;          /* last statement node ptr            */
    uint32_t snel_ptr;          /* statement node extent list ptr     */
    uint8_t  first_srn[SDF_SRN_LEN];
    uint8_t  last_srn[SDF_SRN_LEN];
    uint16_t cubtc_num;
    uint16_t comp_unit;
    uint32_t title_ptr;
    uint8_t  user_data[8];
    uint32_t symb_cnt;
    uint32_t macro_cnt;
    uint32_t lits_cnt;
    uint32_t xref_cnt;
    uint8_t  dummy[36];         /* CR13079 unused area                */
    uint32_t dinit_ptr;         /* CR13079: initial data pointer      */
} SDF_PACKED sdf_drootcel_disk_t;

/* ------------------------------------------------------------------ */
/* Block node  (BLCKNODE.bal)  -- on disk                             */
/* ------------------------------------------------------------------ */

typedef struct {
    char     csct_name[SDF_NAME_LEN];  /* CSECT name (ASCII)         */
    uint32_t block_ptr;                /* ptr to block tree cell      */
} SDF_PACKED sdf_blcknode_disk_t;

/* ------------------------------------------------------------------ */
/* Block data cell  (BLKTCELL.bal)  -- on disk                        */
/* ------------------------------------------------------------------ */

typedef struct {
    uint32_t rtree_ptr;
    uint32_t ltree_ptr;
    uint32_t fnest_ptr;
    uint32_t lnest_ptr;
    uint32_t ext_ptr;
    uint32_t _spare;
    uint8_t  blk_flgs;
    uint8_t  _spare2;
    uint16_t blk_ndx;
    uint16_t blk_id;
    uint8_t  blk_class;
    uint8_t  blk_type;
    uint16_t fsymb_num;
    uint16_t lsymb_num;
    uint16_t fstmt_num;
    uint16_t lstm_num;
    uint16_t post_dcl;
    uint16_t stak_list;
    uint8_t  bname_len;
    char     blk_name[SDF_LONG_NAME_LEN]; /* variable length in orig */
} SDF_PACKED sdf_blktcell_disk_t;

/* ------------------------------------------------------------------ */
/* Symbol node  (SYMBNODE.bal)  -- on disk                            */
/* ------------------------------------------------------------------ */

typedef struct {
    char     symb_name[SDF_NAME_LEN];  /* first 8 chars of name      */
    uint32_t sdc_ptr;                  /* ptr to symbol data cell     */
} SDF_PACKED sdf_symbnode_disk_t;

/* ------------------------------------------------------------------ */
/* Symbol data cell  (SYMBDC.bal)  -- on disk                         */
/* ------------------------------------------------------------------ */

typedef struct {
    uint16_t block_num;
    uint8_t  extd_off;
    uint8_t  xref_off;
    uint8_t  array_off;
    uint8_t  struct_of;
    uint8_t  sym_class;
    uint8_t  sym_type;
    uint8_t  flag1;
    uint8_t  flag2;
    uint8_t  flag3;
    uint8_t  flag4;
    uint8_t  symb_len;          /* total length of symbol name        */
    uint8_t  rel_addr[3];
    uint16_t sblk_id;
    /* union of overlapping fields at same offset */
    uint8_t  rows;              /* also: templ#, dense_off, char_len  */
    uint8_t  columns;           /* also: bit_len                      */
    uint8_t  lock_num;
    uint8_t  byte_size[3];
    /* name continuation follows (variable length) */
    char     name_cont[SDF_LONG_NAME_LEN - SDF_NAME_LEN];
} SDF_PACKED sdf_symbdc_disk_t;

/* Symbol class / type flags */
#define SDF_CLASS_EQUATE_EXT  2
#define SDF_TYPE_EQUATE_EXT   8
#define SDF_FLAG1_UNQUAL_STRUC 0x03

/* ------------------------------------------------------------------ */
/* Statement node, no SRN  (STMTNOD0.bal)  -- on disk                 */
/* ------------------------------------------------------------------ */

typedef struct {
    uint32_t stdc_ptr;          /* ptr to statement data cell         */
} SDF_PACKED sdf_stmtnod0_disk_t;

/* Statement node with SRN (12 bytes): SRN(CL6) + INCOUNT(CL2) + STDCPTR1(A) */
typedef struct {
    char     srn[6];            /* statement reference number (6 chars) */
    char     incount[2];        /* include count                        */
    uint32_t stdc_ptr;          /* ptr to statement data cell           */
} SDF_PACKED sdf_stmtnod1_disk_t;

/* ------------------------------------------------------------------ */
/* Statement data cell  (STMTDC.bal)  -- on disk                      */
/* ------------------------------------------------------------------ */

typedef struct {
    uint16_t block_num;
    uint16_t stmt_type;
    uint8_t  num_labls;
    uint8_t  num_lhs;
} SDF_PACKED sdf_stmtdc_disk_t;

/* ------------------------------------------------------------------ */
/* Symbol node extent cell (SDFPKG references SYMEXTF / SYMEXTV)      */
/* ------------------------------------------------------------------ */

/* SYMEXTF: SUCCPTR(F=4) + NEXTNTRY(H=2) + FSTPAGE(H=2) = 8 bytes */
typedef struct {
    uint32_t succ_ptr;          /* ptr to successor cell (usually 0)  */
    uint16_t next_ntry;         /* number of variable entries         */
    uint16_t fst_page;          /* page # corresponding to 1st entry  */
    /* variable entries (sdf_symextv_disk_t) follow immediately       */
} SDF_PACKED sdf_symextf_disk_t;

/* SYMEXTV: FSTOFF(H=2) + LSTOFF(H=2) + FSTSYMB(CL8) + LSTSYMB(CL8) = 20 bytes */
typedef struct {
    uint16_t fst_off;                  /* offset to first symbol node */
    uint16_t lst_off;                  /* offset to last symbol node  */
    char     fst_symb[SDF_NAME_LEN];   /* name of first symbol (8 ch) */
    char     lst_symb[SDF_NAME_LEN];   /* name of last symbol  (8 ch) */
} SDF_PACKED sdf_symextv_disk_t;

/* ------------------------------------------------------------------ */
/* Statement node extent cell                                          */
/* ------------------------------------------------------------------ */

/* STMTEXTF: SUCCPTR1(F=4) + NXNTRY(H=2) + FSTPAGE1(H=2) = 8 bytes */
typedef struct {
    uint32_t succ_ptr1;         /* ptr to successor cell              */
    uint16_t nx_ntry;           /* number of variable entries         */
    uint16_t fst_page1;         /* page # corresponding to 1st entry  */
    /* variable entries (sdf_stmtextv_disk_t) follow immediately      */
} SDF_PACKED sdf_stmtextf_disk_t;

/* STMTEXTV: FSTOFF1(H=2) + LSTOFF1(H=2) + FSTSRN(CL8) + LSTSRN(CL8) = 20 bytes */
typedef struct {
    uint16_t fst_off1;          /* offset to first SRN on page        */
    uint16_t lst_off1;          /* offset to last SRN on page         */
    char     fst_srn[SDF_SRN_PAD_LEN]; /* first SRN on page (8 chars, space-padded) */
    char     lst_srn[SDF_SRN_PAD_LEN]; /* last SRN on page  (8 chars, space-padded) */
} SDF_PACKED sdf_stmtextv_disk_t;

/* ------------------------------------------------------------------ */
/* Communication area  (COMMTABL.bal)                                  */
/*                                                                     */
/* In the original, callers passed a pointer to this struct in R0 on  */
/* the init call, and SDFPKG stored/used it throughout.  In the C     */
/* port it becomes an opaque sdf_ctx_t; the fields below are the      */
/* internal representation.                                            */
/* ------------------------------------------------------------------ */

typedef struct sdf_commtabl {
    /* Paging area (external, caller-supplied or NULL for malloc) */
    void        *apg_area;     /* base of external paging area        */
    void        *afcb_area;    /* base of external FCB area           */
    uint16_t     npages;       /* # pages in paging area or augment   */
    uint16_t     nbytes;       /* # bytes in FCB area or augment      */
    uint16_t     misc;         /* option flags for INIT               */
    uint16_t     creturn;      /* SDFPKG return code                  */

    /* Search parameters (set by caller before each SDFPKG call) */
    uint16_t     blk_no;       /* block number                        */
    uint16_t     symb_no;      /* symbol number                       */
    uint16_t     stmt_no;      /* statement number                    */
    uint8_t      blkn_len;     /* length of block name                */
    uint8_t      symbn_len;    /* length of symbol name               */

    /* Results (set by SDFPKG on return) */
    sdf_vptr_t   pntr;         /* virtual pointer last located        */
    void        *addr;         /* core address corresponding to pntr  */

    /* Selection identifiers */
    char         sdf_nam[SDF_NAME_LEN + 1];  /* SDF member name      */
    char         csect_nam[SDF_NAME_LEN + 1];/* CSECT name of block  */
    char         sref_no[SDF_SRN_LEN + 1];   /* statement ref number (6 chars) */
    uint16_t     incl_cnt;     /* include count (for SRN)             */
    char         blk_nam[SDF_LONG_NAME_LEN + 1]; /* block name       */
    char         symb_nam[SDF_LONG_NAME_LEN + 1];/* symbol name      */
} sdf_commtabl_t;

/* MISC flag bits */
#define SDF_MISC_AUTO_GETM  0x0001  /* auto-GETMAIN (malloc) for FCBs */
#define SDF_MISC_UPDAT_MODE 0x0002  /* open for update (write-back)   */
#define SDF_MISC_RELEASE    0x0004  /* release disposition            */
#define SDF_MISC_RESERVE    0x0008  /* reserve disposition            */
#define SDF_MISC_FIRST_SYM  0x0010  /* take first matching symbol     */
#define SDF_MISC_ONE_FCB    0x0020  /* keep only one FCB at a time    */ /* (re-used bit from original) */
#define SDF_MISC_ALT_DD     0x0040  /* alternate file name specified  */
#define SDF_MISC_ALT_PAD    0x0080  /* alternate paging area supplied */

/* Close the MSVC pack pragma if it was opened above. */
#if defined(_MSC_VER)
#  pragma pack(pop)
#endif

#endif /* SDF_TYPES_H */
