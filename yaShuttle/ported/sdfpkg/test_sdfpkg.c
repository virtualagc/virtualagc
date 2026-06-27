#define _POSIX_C_SOURCE 200809L
/*
 * test/test_sdfpkg.c  --  Unit tests for the SDF package C port.
 *
 * Self-contained: builds a synthetic in-memory SDF file (written to a
 * tmp file), then exercises every public sdfpkg.h entry point.
 *
 * Test plan
 * ---------
 *  T01  sdf_open / sdf_close lifecycle
 *  T02  sdf_select: known member
 *  T03  sdf_select: unknown member → SDF_NOT_FOUND
 *  T04  sdf_select: same member twice (idempotent)
 *  T05  sdf_locate_root: reads DROOTCEL fields correctly
 *  T06  sdf_find_block_by_number: all fields populated
 *  T07  sdf_find_block_by_name: tree search
 *  T08  sdf_find_block_by_name: not found → SDF_NOT_FOUND
 *  T09  sdf_find_symbol_by_number: fields correct
 *  T10  sdf_find_symbol_by_name: binary search hit
 *  T11  sdf_find_symbol_by_name: not found → SDF_SYM_NOT_FOUND
 *  T12  sdf_find_stmt_by_number: executable statement
 *  T13  sdf_find_stmt_by_number: non-executable → SDF_NOT_EXEC
 *  T14  sdf_find_block_node_by_number: CSECT name returned
 *  T15  sdf_find_symbol_node_by_number: name + SDC ptr returned
 *  T16  sdf_find_stmt_node_by_number: SRN returned
 *  T17  sdf_locate / sdf_locate_ptr: bad pointer → SDF_ERR_BAD_PTR
 *  T18  sdf_augment / sdf_rescind
 *  T19  sdf_stats: read/write counters
 *  T20  sdf_strerror: non-empty for all codes
 *  T21  NDX2PTR: block index 0 → SDF_ERR_BAD_BLOCK
 *  T22  NDX2PTR: block index > num_blks → SDF_ERR_BAD_BLOCK
 *  T23  Locate counter wrap: force loc_cnt overflow path
 *  T24  sdf_find_stmt_by_srn: hit
 *  T25  sdf_find_stmt_by_srn: SDF_NO_SRNS when no SRNs
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>

#ifdef _WIN32
#include <io.h>
#define TMPFILE "sdf_test_tmp.bin"
#else
#include <unistd.h>
#define TMPFILE "/tmp/sdf_test_XXXXXX"
#endif

#include "sdfpkg.h"
#include "sdf_internal.h"
#include "sdf_types.h"

/* ================================================================== */
/* Minimal test framework                                              */
/* ================================================================== */

static int g_pass = 0;
static int g_fail = 0;

#define PASS(name) do {                                                \
    printf("  PASS  %s\n", (name));                                    \
    g_pass++;                                                          \
} while (0)

#define FAIL(name, fmt, ...) do {                                      \
    printf("  FAIL  %s: " fmt "\n", (name), ##__VA_ARGS__);           \
    g_fail++;                                                          \
} while (0)

#define CHECK(name, cond) do {                                         \
    if (cond) PASS(name);                                              \
    else       FAIL(name, "condition false: %s", #cond);              \
} while (0)

#define CHECK_RC(name, got, want) do {                                 \
    sdf_rc_t _g = (got), _w = (want);                                 \
    if (_g == _w) PASS(name);                                          \
    else FAIL(name, "rc=%d (%s), want %d (%s)",                       \
              _g, sdf_strerror(_g), _w, sdf_strerror(_w));            \
} while (0)

/* ================================================================== */
/* SDF flat-file builder                                               */
/*                                                                     */
/* Layout:                                                             */
/*   [8 bytes]  magic (0x53444600) + member count (big-endian u32)    */
/*   [20 bytes per member]  name(8) + page_count(4) + pg0_offset(8)   */
/*   [pages]  1680-byte page data for each member, in index order     */
/*                                                                     */
/* We build one member "TESTMEMB" with 3 pages:                       */
/*   Page 0: PAGEZERO header + DROOTCEL                                */
/*   Page 1: block nodes + block data cells                            */
/*   Page 2: symbol nodes + symbol data cells + stmt nodes + stmt data */
/* ================================================================== */

#define PAGE_SIZE   SDF_PAGE_SIZE   /* 1680 */
#define MEMBER_NAME "TESTMEMB"

/* Big-endian write helpers */
static void w8 (uint8_t *p, int off, uint8_t  v) { p[off]=v; }
static void w16(uint8_t *p, int off, uint16_t v) {
    p[off]=(v>>8)&0xFF; p[off+1]=v&0xFF;
}
static void w32(uint8_t *p, int off, uint32_t v) {
    p[off]=(v>>24)&0xFF; p[off+1]=(v>>16)&0xFF;
    p[off+2]=(v>>8)&0xFF; p[off+3]=v&0xFF;
}
static void wstr(uint8_t *p, int off, const char *s, int len) {
    int n=(int)strlen(s); if(n>len)n=len;
    memcpy(p+off,s,n);
    if(n<len) memset(p+off+n,' ',len-n);
}

/* ------------------------------------------------------------------ */
/* Virtual pointer encoding                                            */
/* ------------------------------------------------------------------ */
static uint32_t vptr(uint16_t page, uint16_t offset) {
    return ((uint32_t)page << 16) | offset;
}

/* ------------------------------------------------------------------ */
/* Build the synthetic SDF file                                        */
/*                                                                     */
/* Data layout decisions                                               */
/* ----------------------                                              */
/*  Page 0 @ offset 0:                                                 */
/*    [0]  PAGEZERO: version=1, droot_ptr=vptr(0,16)                  */
/*    [16] DROOTCEL: 1 block, 2 symbols, stmts 1-3                    */
/*                   fbn_ptr=vptr(1,0), fsn_ptr=vptr(2,0)             */
/*                   fstn_ptr=vptr(2,100), btree_ptr=vptr(1,12)       */
/*                   flags: HAS_SRNS, snel_ptr=vptr(2,200)            */
/*                                                                     */
/*  Page 1 @ offset 1680:                                              */
/*    [0]   BLCKNODE[1]: csct='CSECT1  ', block_ptr=vptr(1,12)        */
/*    [12]  BLKTCELL[1]: name='MAINPROG', ndx=1, fsymb=1, lsymb=2    */
/*                        fstmt=1, lstmt=3, rtree=0, ltree=0          */
/*                        ext_ptr=0 (no extent cell)                   */
/*                                                                     */
/*  Page 2 @ offset 3360:                                              */
/*    [0]   SYMBNODE[1]: name='ALPHA   ', sdc_ptr=vptr(2,24)          */
/*    [12]  SYMBNODE[2]: name='BETA    ', sdc_ptr=vptr(2,48)          */
/*    [24]  SYMBDC[1]:   block=1, class=1, type=1, len=5, name='ALPHA'*/
/*    [48]  SYMBDC[2]:   block=1, class=2, type=1, len=4, name='BETA' */
/*    [100] STMTNOD1[1]: srn='S0001   ', stdc_ptr=vptr(2,150)  (exec) */
/*    [112] STMTNOD1[2]: srn='S0002   ', stdc_ptr=vptr(2,156)  (exec) */
/*    [124] STMTNOD1[3]: srn='S0003   ', stdc_ptr=0x00000000   (non-exec)*/
/*    [150] STMTDC[1]:   block=1, type=1                              */
/*    [156] STMTDC[2]:   block=1, type=2                              */
/*    [200] STMTEXTF:    1 entry, fst_page=2, succ=0                  */
/*    [208] STMTEXTV:    fst_srn='S0001',lst_srn='S0003',             */
/*                        fst_off=100, lst_off=124                    */
/* ------------------------------------------------------------------ */

static int build_sdf_file(const char *path)
{
    /* Allocate 3 pages */
    uint8_t *pages = calloc(3, PAGE_SIZE);
    if (!pages) return -1;

    uint8_t *p0 = pages + 0 * PAGE_SIZE;
    uint8_t *p1 = pages + 1 * PAGE_SIZE;
    uint8_t *p2 = pages + 2 * PAGE_SIZE;

    /* ---- Page 0: PAGEZERO ---------------------------------------- */
    w16(p0, 0,  1);              /* version = 1                        */
    w16(p0, 2,  0);              /* pad                                */
    w32(p0, 4,  0);              /* dir_fc_ptr = 0                     */
    w32(p0, 8,  vptr(0,16));     /* droot_ptr  = page0 offset 16       */
    w32(p0, 12, 0);              /* dat_fc_ptr = 0                     */

    /* ---- Page 0: DROOTCEL at offset 16 --------------------------- */
    uint8_t *dr = p0 + 16;
    w8 (dr,  0, 0x80);              /* sdf_flags[0]=HAS_SRNS bit7                   */
    w8 (dr,  1, 0);
    w16(dr,  2, 2);              /* last_page = 2                      */
    w32(dr,  4, 0);              /* sdf_date                           */
    w32(dr,  8, 0);              /* sdf_time                           */
    w16(dr, 12, 0);              /* last_dpage                         */
    w16(dr, 14, 0);              /* compools                           */
    w16(dr, 16, 1);              /* blk_nodes = 1                      */
    w16(dr, 18, 2);              /* sym_nodes = 2                      */
    w32(dr, 20, vptr(1,0));      /* fbn_ptr (first block node)         */
    w32(dr, 24, vptr(1,0));      /* lbn_ptr                            */
    w16(dr, 28, 0);              /* instr_cnt                          */
    w16(dr, 30, 0);              /* free_byte                          */
    w16(dr, 32, 0);              /* dlst_head                          */
    w16(dr, 34, 0);              /* rlst_head                          */
    w32(dr, 36, vptr(2,0));      /* fsn_ptr (first symbol node)        */
    w32(dr, 40, vptr(2,12));     /* lsn_ptr                            */
    w32(dr, 44, 0);              /* cubtc_ptr                          */
    w32(dr, 48, vptr(1,12));     /* btree_ptr (root of block tree)     */
    w16(dr, 52, 1);              /* fstmt_num = 1                      */
    w16(dr, 54, 3);              /* lstm_num  = 3                      */
    w16(dr, 56, 2);              /* exec_stmt                          */
    w16(dr, 58, 3);              /* stmt_node count                    */
    w32(dr, 60, vptr(2,100));    /* fstn_ptr (first stmt node)         */
    w32(dr, 64, vptr(2,124));    /* lstn_ptr                           */
    w32(dr, 68, vptr(2,200));    /* snel_ptr (stmt node extent list)   */
    /* first_srn / last_srn */
    wstr(dr, 72, "S0001   ", 8);
    wstr(dr, 80, "S0003   ", 8);
    w16(dr, 88, 0);              /* cubtc_num                          */
    w16(dr, 90, 0);              /* comp_unit                          */
    w32(dr, 92, 0);              /* title_ptr                          */
    /* user_data[8], symb_cnt, macro_cnt, lits_cnt, xref_cnt, dummy[36] */
    /* dinit_ptr at offset 16+168 = 184 from start of page */
    /* sdf_drootcel_disk_t size: 2+2+4+4+2+2+2+2+4+4+2+2+2+2+4+4+4+4+
                                  2+2+2+2+4+4+4+8+8+2+2+4+8+4+4+4+4+36+4
       = let's just hard-code the dinit_ptr offset within the struct   */
    /* offsetof(sdf_drootcel_disk_t, dinit_ptr) -- struct is packed,
       we know from DROOTCEL.bal it's after dummy[36]:
       2+2+4+4+2+2+2+2+4+4+2+2+2+2+4+4+4+4+2+2+2+2+4+4+4+8+8+2+2+4+8+4+4+4+4+36
       = 168 bytes before dinit_ptr */
    w32(dr, 168, 0);             /* dinit_ptr = 0 (no init data)       */

    /* ---- Page 1: BLCKNODE[1] at offset 0 ------------------------- */
    wstr(p1, 0, "CSECT1  ", 8);          /* csct_name                 */
    w32 (p1, 8, vptr(1,12));             /* block_ptr → BLKTCELL       */

    /* ---- Page 1: BLKTCELL[1] at offset 12 ----------------------- */
    uint8_t *bt = p1 + 12;
    w32(bt,  0, 0);              /* rtree_ptr = NULL                   */
    w32(bt,  4, 0);              /* ltree_ptr = NULL                   */
    w32(bt,  8, 0);              /* fnest_ptr                          */
    w32(bt, 12, 0);              /* lnest_ptr                          */
    w32(bt, 16, 0);              /* ext_ptr = 0 (no extent cell)       */
    w32(bt, 20, 0);              /* spare                              */
    w8 (bt, 24, 0);              /* blk_flgs                           */
    w8 (bt, 25, 0);              /* spare2                             */
    w16(bt, 26, 1);              /* blk_ndx = 1                        */
    w16(bt, 28, 1);              /* blk_id  = 1                        */
    w8 (bt, 30, 1);              /* blk_class = 1 (PROGRAM)            */
    w8 (bt, 31, 0);              /* blk_type                           */
    w16(bt, 32, 1);              /* fsymb_num = 1                      */
    w16(bt, 34, 2);              /* lsymb_num = 2                      */
    w16(bt, 36, 1);              /* fstmt_num = 1                      */
    w16(bt, 38, 3);              /* lstm_num  = 3                      */
    w16(bt, 40, 0);              /* post_dcl                           */
    w16(bt, 42, 0);              /* stak_list                          */
    w8 (bt, 44, 8);              /* bname_len = 8                      */
    wstr(bt, 45, "MAINPROG", 8); /* blk_name                           */

    /* ---- Page 2: SYMBNODE[1] at offset 0 ------------------------ */
    wstr(p2,  0, "ALPHA   ", 8);         /* symb_name                  */
    w32 (p2,  8, vptr(2,24));            /* sdc_ptr                    */

    /* ---- Page 2: SYMBNODE[2] at offset 12 ----------------------- */
    wstr(p2, 12, "BETA    ", 8);
    w32 (p2, 20, vptr(2,48));

    /* ---- Page 2: SYMBDC[1] at offset 24 ------------------------- */
    uint8_t *sdc1 = p2 + 24;
    w16(sdc1,  0, 1);            /* block_num = 1                      */
    w8 (sdc1,  2, 0);            /* extd_off                           */
    w8 (sdc1,  3, 0);            /* xref_off                           */
    w8 (sdc1,  4, 0);            /* array_off                          */
    w8 (sdc1,  5, 0);            /* struct_of                          */
    w8 (sdc1,  6, 1);            /* sym_class = 1                      */
    w8 (sdc1,  7, 1);            /* sym_type  = 1                      */
    w8 (sdc1,  8, 0);            /* flag1                              */
    w8 (sdc1,  9, 0);            /* flag2                              */
    w8 (sdc1, 10, 0);            /* flag3                              */
    w8 (sdc1, 11, 0);            /* flag4                              */
    w8 (sdc1, 12, 5);            /* symb_len = 5 ("ALPHA")             */
    w8 (sdc1, 13, 0);            /* rel_addr[0]                        */
    w8 (sdc1, 14, 0);            /* rel_addr[1]                        */
    w8 (sdc1, 15, 0);            /* rel_addr[2]                        */
    w16(sdc1, 16, 1);            /* sblk_id = 1                        */
    w8 (sdc1, 18, 0);            /* rows                               */
    w8 (sdc1, 19, 0);            /* columns                            */
    w8 (sdc1, 20, 0);            /* lock_num                           */
    /* byte_size[3] */
    /* name_cont: "ALPHA" is 5 chars, first 8 in node, so no continuation */

    /* ---- Page 2: SYMBDC[2] at offset 48 ------------------------- */
    uint8_t *sdc2 = p2 + 48;
    w16(sdc2,  0, 1);            /* block_num = 1                      */
    w8 (sdc2,  6, 1);            /* sym_class = 1                      */
    w8 (sdc2,  7, 1);            /* sym_type  = 1                      */
    w8 (sdc2, 12, 4);            /* symb_len = 4 ("BETA")              */

    /* ---- Page 2: STMTNOD1 entries (12 bytes each w/ SRN) -------- */
    /* Layout: SRN(CL6) + INCOUNT(CL2) + STDCPTR1(A)                 */
    /* Stmt 1 at offset 100 */
    uint8_t *sn1 = p2 + 100;
    wstr(sn1, 0, "S0001 ", 6);   /* srn (CL6)                          */
    w8  (sn1, 6, 0); w8(sn1, 7, 0); /* incount = 0                    */
    w32 (sn1, 8, vptr(2,150));   /* stdc_ptr (positive = executable)   */

    /* Stmt 2 at offset 112 */
    uint8_t *sn2 = p2 + 112;
    wstr(sn2, 0, "S0002 ", 6);   /* srn (CL6)                          */
    w8  (sn2, 6, 0); w8(sn2, 7, 0);
    w32 (sn2, 8, vptr(2,156));   /* stdc_ptr (executable)              */

    /* Stmt 3 at offset 124 -- non-executable (stdc_ptr = 0) */
    uint8_t *sn3 = p2 + 124;
    wstr(sn3, 0, "S0003 ", 6);   /* srn (CL6)                          */
    w8  (sn3, 6, 0); w8(sn3, 7, 0);
    w32 (sn3, 8, 0x00000000);    /* stdc_ptr = 0 => not executable     */

    /* ---- Page 2: STMTDC[1] at offset 150 ----------------------- */
    uint8_t *stdc1 = p2 + 150;
    w16(stdc1, 0, 1);            /* block_num = 1                      */
    w16(stdc1, 2, 1);            /* stmt_type = 1                      */
    w8 (stdc1, 4, 0);            /* num_labls                          */
    w8 (stdc1, 5, 1);            /* num_lhs = 1                        */

    /* ---- Page 2: STMTDC[2] at offset 156 ----------------------- */
    uint8_t *stdc2 = p2 + 156;
    w16(stdc2, 0, 1);            /* block_num = 1                      */
    w16(stdc2, 2, 2);            /* stmt_type = 2                      */
    w8 (stdc2, 4, 1);            /* num_labls = 1                      */
    w8 (stdc2, 5, 0);

    /* ---- Page 2: STMTEXTF at offset 200 ------------------------ */
    /* Layout: SUCCPTR1(F=4) + NXNTRY(H=2) + FSTPAGE1(H=2)           */
    uint8_t *ef = p2 + 200;
    w32(ef, 0, 0);               /* succ_ptr1 = NULL                   */
    w16(ef, 4, 1);               /* nx_ntry = 1 entry                  */
    w16(ef, 6, 2);               /* fst_page1 = 2                      */

    /* ---- Page 2: STMTEXTV at offset 208 ------------------------ */
    /* Layout: FSTOFF1(H=2) + LSTOFF1(H=2) + FSTSRN(CL8) + LSTSRN(CL8) */
    uint8_t *ev = p2 + 208;
    w16 (ev,  0, 100);           /* fst_off1 = 100                     */
    w16 (ev,  2, 124);           /* lst_off1 = 124                     */
    wstr(ev,  4, "S0001   ", 8); /* fst_srn (CL8, space-padded)        */
    wstr(ev, 12, "S0003   ", 8); /* lst_srn (CL8, space-padded)        */

    /* ----------------------------------------------------------------
     * Write the file: header + index + 3 pages
     * --------------------------------------------------------------- */
    FILE *fp = fopen(path, "wb");
    if (!fp) { free(pages); return -1; }

    /* File header: magic + member count */
    uint8_t fhdr[8];
    fhdr[0]=0x53; fhdr[1]=0x44; fhdr[2]=0x46; fhdr[3]=0x00; /* "SDF\0" */
    fhdr[4]=0x00; fhdr[5]=0x00; fhdr[6]=0x00; fhdr[7]=0x01; /* count=1 */
    fwrite(fhdr, 1, 8, fp);

    /* Member index entry: name(8) + page_count(4) + pg0_offset(8) */
    uint8_t idx[20];
    memcpy(idx, MEMBER_NAME, 8);          /* "TESTMEMB" -- exactly 8  */
    /* page_count = 3 */
    idx[ 8]=0; idx[ 9]=0; idx[10]=0; idx[11]=3;
    /* pg0_offset = 8 + 20 = 28 (header + one index entry) */
    uint64_t pg0 = 28;
    idx[12]=(uint8_t)(pg0>>56); idx[13]=(uint8_t)(pg0>>48);
    idx[14]=(uint8_t)(pg0>>40); idx[15]=(uint8_t)(pg0>>32);
    idx[16]=(uint8_t)(pg0>>24); idx[17]=(uint8_t)(pg0>>16);
    idx[18]=(uint8_t)(pg0>> 8); idx[19]=(uint8_t)(pg0    );
    fwrite(idx, 1, 20, fp);

    /* Page data */
    fwrite(pages, PAGE_SIZE, 3, fp);
    fclose(fp);
    free(pages);
    return 0;
}

/* ================================================================== */
/* Tests                                                               */
/* ================================================================== */

static const char *g_path;

static void t01_open_close(void)
{
    puts("T01: open / close");
    sdf_ctx_t *ctx = NULL;
    CHECK_RC("open succeeds",
             sdf_open(g_path, SDF_OPEN_RDONLY, 0, &ctx), SDF_OK);
    CHECK("ctx not NULL", ctx != NULL);
    CHECK_RC("close succeeds", sdf_close(&ctx), SDF_OK);
    CHECK("ctx nulled", ctx == NULL);
    /* Double-close is safe */
    CHECK_RC("double close", sdf_close(&ctx), SDF_OK);
}

static void t02_select_known(void)
{
    puts("T02: select known member");
    sdf_ctx_t *ctx = NULL;
    sdf_open(g_path, SDF_OPEN_RDONLY, 0, &ctx);
    CHECK_RC("select TESTMEMB", sdf_select(ctx, "TESTMEMB"), SDF_OK);
    sdf_close(&ctx);
}

static void t03_select_unknown(void)
{
    puts("T03: select unknown member");
    sdf_ctx_t *ctx = NULL;
    sdf_open(g_path, SDF_OPEN_RDONLY, 0, &ctx);
    sdf_rc_t rc = sdf_select(ctx, "NOSUCHXX");
    CHECK("unknown member not found",
          rc == SDF_NOT_FOUND || rc < 0);
    sdf_close(&ctx);
}

static void t04_select_idempotent(void)
{
    puts("T04: select same member twice");
    sdf_ctx_t *ctx = NULL;
    sdf_open(g_path, SDF_OPEN_RDONLY, 0, &ctx);
    sdf_select(ctx, "TESTMEMB");
    CHECK_RC("re-select same", sdf_select(ctx, "TESTMEMB"), SDF_OK);
    sdf_close(&ctx);
}

static void t05_locate_root(void)
{
    puts("T05: locate root");
    sdf_ctx_t *ctx = NULL;
    sdf_open(g_path, SDF_OPEN_RDONLY, 0, &ctx);
    sdf_select(ctx, "TESTMEMB");
    void *root = NULL;
    CHECK_RC("locate_root", sdf_locate_root(ctx, SDF_DISP_NONE, &root), SDF_OK);
    CHECK("root not NULL", root != NULL);
    /* Check version field from DROOTCEL via PAGEZERO (version stored in FCB) */
    /* drootcel.blk_nodes should be 1 */

    /* blk_nodes is at offset 16 in DROOTCEL; use raw read */
    /* Access via the packed struct -- big-endian u16 at offset 16 */
    uint8_t *raw = (uint8_t *)root;
    uint16_t bn = (uint16_t)((raw[16] << 8) | raw[17]);
    CHECK("root: blk_nodes=1", bn == 1);
    uint16_t sn = (uint16_t)((raw[18] << 8) | raw[19]);
    CHECK("root: sym_nodes=2", sn == 2);
    sdf_close(&ctx);
}

/* Helper: open + select */
static sdf_ctx_t *open_selected(void)
{
    sdf_ctx_t *ctx = NULL;
    sdf_open(g_path, SDF_OPEN_RDONLY, 0, &ctx);
    sdf_select(ctx, "TESTMEMB");
    return ctx;
}

static void t06_find_block_by_number(void)
{
    puts("T06: find block by number");
    sdf_ctx_t *ctx = open_selected();
    sdf_block_result_t r;
    memset(&r, 0, sizeof(r));
    CHECK_RC("find block 1",
             sdf_find_block_by_number(ctx, 1, SDF_DISP_NONE, &r), SDF_OK);
    CHECK("blk_no=1",  r.blk_no == 1);
    CHECK("blk_id=1",  r.blk_id == 1);
    CHECK("csect=CSECT1", strncmp(r.csect_name, "CSECT1", 6) == 0);
    CHECK("name=MAINPROG", strcmp(r.blk_name, "MAINPROG") == 0);
    CHECK("fsymb=1",   r.fsymb_no == 1);
    CHECK("lsymb=2",   r.lsymb_no == 2);
    CHECK("fstmt=1",   r.fstmt_no == 1);
    CHECK("lstm=3",    r.lstm_no  == 3);
    sdf_close(&ctx);
}

static void t07_find_block_by_name(void)
{
    puts("T07: find block by name");
    sdf_ctx_t *ctx = open_selected();
    sdf_block_result_t r;
    memset(&r, 0, sizeof(r));
    CHECK_RC("find MAINPROG",
             sdf_find_block_by_name(ctx, "MAINPROG", SDF_DISP_NONE, &r),
             SDF_OK);
    CHECK("blk_no=1", r.blk_no == 1);
    CHECK("name match", strcmp(r.blk_name, "MAINPROG") == 0);
    sdf_close(&ctx);
}

static void t08_find_block_not_found(void)
{
    puts("T08: find block by name - not found");
    sdf_ctx_t *ctx = open_selected();
    sdf_block_result_t r;
    CHECK("not found",
          sdf_find_block_by_name(ctx, "NOBLOCK", SDF_DISP_NONE, &r)
          == SDF_NOT_FOUND);
    sdf_close(&ctx);
}

static void t09_find_symbol_by_number(void)
{
    puts("T09: find symbol by number");
    sdf_ctx_t *ctx = open_selected();
    sdf_symbol_result_t r;
    memset(&r, 0, sizeof(r));
    CHECK_RC("find symb 1",
             sdf_find_symbol_by_number(ctx, 1, SDF_DISP_NONE, &r), SDF_OK);
    CHECK("symb_no=1",  r.symb_no == 1);
    CHECK("blk_no=1",   r.blk_no  == 1);
    CHECK("name=ALPHA", strncmp(r.symb_name, "ALPHA", 5) == 0);
    CHECK("class=1",    r.sym_class == 1);

    memset(&r, 0, sizeof(r));
    CHECK_RC("find symb 2",
             sdf_find_symbol_by_number(ctx, 2, SDF_DISP_NONE, &r), SDF_OK);
    CHECK("name=BETA",  strncmp(r.symb_name, "BETA", 4) == 0);
    sdf_close(&ctx);
}

static void t10_find_symbol_by_name(void)
{
    puts("T10: find symbol by name");
    sdf_ctx_t *ctx = open_selected();
    /* Must establish block context first */
    sdf_find_block_by_number(ctx, 1, SDF_DISP_NONE, NULL);

    sdf_symbol_result_t r;
    memset(&r, 0, sizeof(r));
    CHECK_RC("find ALPHA",
             sdf_find_symbol_by_name(ctx, "ALPHA", SDF_DISP_NONE, &r),
             SDF_OK);
    CHECK("symb_no=1", r.symb_no == 1);
    CHECK("name=ALPHA", strncmp(r.symb_name, "ALPHA", 5) == 0);

    memset(&r, 0, sizeof(r));
    CHECK_RC("find BETA",
             sdf_find_symbol_by_name(ctx, "BETA", SDF_DISP_NONE, &r),
             SDF_OK);
    CHECK("symb_no=2", r.symb_no == 2);
    sdf_close(&ctx);
}

static void t11_find_symbol_not_found(void)
{
    puts("T11: find symbol - not found");
    sdf_ctx_t *ctx = open_selected();
    sdf_find_block_by_number(ctx, 1, SDF_DISP_NONE, NULL);
    sdf_symbol_result_t r;
    CHECK("ZZZZ not found",
          sdf_find_symbol_by_name(ctx, "ZZZZ", SDF_DISP_NONE, &r)
          == SDF_SYM_NOT_FOUND);
    sdf_close(&ctx);
}

static void t12_find_stmt_exec(void)
{
    puts("T12: find executable statement");
    sdf_ctx_t *ctx = open_selected();
    sdf_stmt_result_t r;
    memset(&r, 0, sizeof(r));
    CHECK_RC("find stmt 1",
             sdf_find_stmt_by_number(ctx, 1, SDF_DISP_NONE, &r), SDF_OK);
    CHECK("stmt_no=1",  r.stmt_no == 1);
    CHECK("blk_no=1",   r.blk_no  == 1);
    CHECK("is_exec",    r.is_executable);
    CHECK("type=1",     r.stmt_type == 1);

    memset(&r, 0, sizeof(r));
    CHECK_RC("find stmt 2",
             sdf_find_stmt_by_number(ctx, 2, SDF_DISP_NONE, &r), SDF_OK);
    CHECK("type=2",     r.stmt_type == 2);
    sdf_close(&ctx);
}

static void t13_find_stmt_non_exec(void)
{
    puts("T13: find non-executable statement");
    sdf_ctx_t *ctx = open_selected();
    sdf_stmt_result_t r;
    memset(&r, 0, sizeof(r));
    sdf_rc_t rc = sdf_find_stmt_by_number(ctx, 3, SDF_DISP_NONE, &r);
    CHECK("non-exec returns SDF_NOT_EXEC", rc == SDF_NOT_EXEC);
    sdf_close(&ctx);
}

static void t14_find_block_node(void)
{
    puts("T14: find block node by number");
    sdf_ctx_t *ctx = open_selected();
    char csect[SDF_NAME_LEN + 1];
    CHECK_RC("block node 1",
             sdf_find_block_node_by_number(ctx, 1, SDF_DISP_NONE, csect),
             SDF_OK);
    CHECK("csect=CSECT1", strncmp(csect, "CSECT1", 6) == 0);
    sdf_close(&ctx);
}

static void t15_find_symbol_node(void)
{
    puts("T15: find symbol node by number");
    sdf_ctx_t *ctx = open_selected();
    char name[SDF_NAME_LEN + 1];
    sdf_vptr_t sdc_ptr;
    CHECK_RC("symb node 1",
             sdf_find_symbol_node_by_number(ctx, 1, SDF_DISP_NONE,
                                             name, &sdc_ptr),
             SDF_OK);
    CHECK("name prefix ALPHA", strncmp(name, "ALPHA", 5) == 0);
    CHECK("sdc_ptr non-zero", sdc_ptr != SDF_VPTR_NULL);
    sdf_close(&ctx);
}

static void t16_find_stmt_node(void)
{
    puts("T16: find stmt node by number (SRN)");
    sdf_ctx_t *ctx = open_selected();
    sdf_stmt_result_t r;
    memset(&r, 0, sizeof(r));
    CHECK_RC("stmt node 1",
             sdf_find_stmt_node_by_number(ctx, 1, SDF_DISP_NONE, &r),
             SDF_OK);
    CHECK("srn=S0001", strncmp(r.srn, "S0001", 5) == 0);
    sdf_close(&ctx);
}

static void t17_bad_pointer(void)
{
    puts("T17: bad virtual pointer");
    sdf_ctx_t *ctx = open_selected();
    void *addr;
    /* Page 999 does not exist in a 3-page member */
    sdf_vptr_t bad = SDF_VPTR_MAKE(999, 0);
    sdf_rc_t rc = sdf_locate(ctx, bad, SDF_DISP_NONE, &addr);
    CHECK("bad ptr rejected", rc == SDF_ERR_BAD_PTR || rc < 0);
    sdf_close(&ctx);
}

static void t18_augment_rescind(void)
{
    puts("T18: augment / rescind");
    sdf_ctx_t *ctx = open_selected();
    CHECK_RC("augment +5 pages",
             sdf_augment(ctx, 5, 0), SDF_OK);
    CHECK_RC("rescind",
             sdf_rescind(ctx), SDF_OK);
    sdf_close(&ctx);
}

static void t19_stats(void)
{
    puts("T19: statistics");
    sdf_ctx_t *ctx = open_selected();
    /* Do some I/O */
    sdf_find_block_by_number(ctx, 1, SDF_DISP_NONE, NULL);
    sdf_find_symbol_by_number(ctx, 1, SDF_DISP_NONE, NULL);

    uint32_t reads, writes, selects;
    sdf_stats(ctx, &reads, &writes, &selects);
    CHECK("reads > 0",   reads   > 0);
    CHECK("selects > 0", selects > 0);
    sdf_close(&ctx);
}

static void t20_strerror(void)
{
    puts("T20: strerror");
    sdf_rc_t codes[] = {
        SDF_OK, SDF_NOT_FOUND, SDF_SYM_NOT_FOUND, SDF_NOT_EXEC,
        SDF_NO_SRNS, SDF_SRNS_NONMONO, SDF_STMT_OOB,
        SDF_ERR_DEADLOCK, SDF_ERR_OPEN_FAIL, SDF_ERR_RESERVE_OVF,
        SDF_ERR_BAD_PTR, SDF_ERR_BAD_BLOCK, SDF_ERR_NOT_INIT,
        SDF_ERR_FCB_OOM, SDF_ERR_GETMAIN, SDF_ERR_MULTI_INIT,
    };
    bool all_ok = true;
    for (size_t i = 0; i < sizeof(codes)/sizeof(codes[0]); i++) {
        const char *s = sdf_strerror(codes[i]);
        if (!s || s[0] == '\0') { all_ok = false; break; }
    }
    CHECK("all strerror non-empty", all_ok);
}

static void t21_ndx2ptr_bad_block_zero(void)
{
    puts("T21: NDX2PTR block index 0");
    sdf_ctx_t *ctx = open_selected();
    sdf_block_result_t r;
    sdf_rc_t rc = sdf_find_block_by_number(ctx, 0, SDF_DISP_NONE, &r);
    CHECK("index 0 rejected", rc == SDF_ERR_BAD_BLOCK);
    sdf_close(&ctx);
}

static void t22_ndx2ptr_bad_block_overflow(void)
{
    puts("T22: NDX2PTR block index > num_blks");
    sdf_ctx_t *ctx = open_selected();
    sdf_block_result_t r;
    sdf_rc_t rc = sdf_find_block_by_number(ctx, 999, SDF_DISP_NONE, &r);
    CHECK("overflow rejected", rc == SDF_ERR_BAD_BLOCK);
    sdf_close(&ctx);
}

static void t23_locate_counter_wrap(void)
{
    puts("T23: locate counter overflow reset");
    sdf_ctx_t *ctx = open_selected();

    /* Force loc_cnt near the 31-bit limit then do one more locate */
    ctx->loc_cnt = 0x7FFFFFFF;
    void *addr;
    sdf_vptr_t p0 = SDF_VPTR_MAKE(0, 0);
    CHECK_RC("locate after wrap", sdf_locate(ctx, p0, SDF_DISP_NONE, &addr),
             SDF_OK);
    /* After the overflow locate, loc_cnt should have been reset to 1 */
    CHECK("loc_cnt reset to 1", ctx->loc_cnt == 1);
    sdf_close(&ctx);
}

static void t24_find_stmt_by_srn(void)
{
    puts("T24: find statement by SRN");
    sdf_ctx_t *ctx = open_selected();
    sdf_stmt_result_t r;
    memset(&r, 0, sizeof(r));
    char srn[SDF_SRN_LEN] = "S0001 ";  /* 6 chars */
    CHECK_RC("find SRN S0001",
             sdf_find_stmt_by_srn(ctx, srn, SDF_DISP_NONE, &r), SDF_OK);
    CHECK("stmt is executable", r.is_executable);
    CHECK("blk_no=1", r.blk_no == 1);
    sdf_close(&ctx);
}

static void t25_find_stmt_by_srn_no_srns(void)
{
    puts("T25: find_stmt_by_srn on file with no SRNs");
    /*
     * We don't have a second member without SRNs in the test file, so
     * we simulate by temporarily clearing the HAS_SRNS flag in the FCB
     * after select.
     */
    sdf_ctx_t *ctx = open_selected();
    /* Force the FCB's flags to have no SRNs and clear stmt_expt */
    ctx->cur_fcb->flags     &= (uint16_t)~SDF_FLAG_HAS_SRNS;
    ctx->cur_fcb->stmt_expt  = SDF_VPTR_NULL;
    char srn[SDF_SRN_LEN]    = "S0001 ";  /* 6 chars */
    sdf_stmt_result_t r;
    CHECK("no-SRN file returns SDF_NO_SRNS",
          sdf_find_stmt_by_srn(ctx, srn, SDF_DISP_NONE, &r) == SDF_NO_SRNS);
    sdf_close(&ctx);
}

/* ================================================================== */
/* main                                                                 */
/* ================================================================== */

int main(void)
{
    /* Create temp file */
#ifdef _WIN32
    char path[MAX_PATH];
    GetTempFileNameA(".", "sdf", 0, path);
    g_path = path;
#else
    char path[] = "/tmp/sdf_test_XXXXXX";
    int fd = mkstemp(path);
    if (fd < 0) { perror("mkstemp"); return 1; }
    close(fd);
    g_path = path;
#endif

    if (build_sdf_file(g_path) != 0) {
        fprintf(stderr, "Failed to build test SDF file\n");
        return 1;
    }
    printf("Test SDF file: %s\n\n", g_path);

    t01_open_close();
    t02_select_known();
    t03_select_unknown();
    t04_select_idempotent();
    t05_locate_root();
    t06_find_block_by_number();
    t07_find_block_by_name();
    t08_find_block_not_found();
    t09_find_symbol_by_number();
    t10_find_symbol_by_name();
    t11_find_symbol_not_found();
    t12_find_stmt_exec();
    t13_find_stmt_non_exec();
    t14_find_block_node();
    t15_find_symbol_node();
    t16_find_stmt_node();
    t17_bad_pointer();
    t18_augment_rescind();
    t19_stats();
    t20_strerror();
    t21_ndx2ptr_bad_block_zero();
    t22_ndx2ptr_bad_block_overflow();
    t23_locate_counter_wrap();
    t24_find_stmt_by_srn();
    t25_find_stmt_by_srn_no_srns();

    /* Remove temp file */
    remove(g_path);

    printf("\n--- Results: %d passed, %d failed ---\n", g_pass, g_fail);
    return g_fail > 0 ? 1 : 0;
}
