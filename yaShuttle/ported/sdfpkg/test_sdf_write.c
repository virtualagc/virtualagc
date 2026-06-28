/*
 * test/test_sdf_write.c  --  Tests for the SDF write infrastructure.
 *
 * Builds the same member as make_sample_sdf.py (NAVCOMP / NAVSECT),
 * writes it via sdf_create() + sdf_write_*() + sdf_commit(), then
 * reads it back via sdfpkg.h and verifies every field.
 *
 * Run:  make test_write && ./test/test_sdf_write
 */
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>

#include "sdfpkg.h"
#include "sdf_write.h"

/* ------------------------------------------------------------------ */
/* Minimal test framework                                              */
/* ------------------------------------------------------------------ */

static int g_pass = 0, g_fail = 0;
#define PASS(n)        do { printf("  PASS  %s\n", n); g_pass++; } while(0)
#define FAIL(n, fmt, ...) do { printf("  FAIL  %s: " fmt "\n", (n), ##__VA_ARGS__); \
                               g_fail++; } while(0)
#define CHECK(n, cond) do { if(cond) PASS(n); \
    else FAIL(n, "%s", "condition false"); } while(0)
#define CHECK_RC(n,got,want) do { sdf_rc_t _g=(got),_w=(want); \
    if(_g==_w) PASS(n); \
    else FAIL(n, "rc=%d, want %d", (int)_g, (int)_w); } while(0)

/* ------------------------------------------------------------------ */
/* Build NAVCOMP member and write it                                   */
/* ------------------------------------------------------------------ */

static sdf_rc_t build_navcomp(const char *path)
{
    sdf_wctx_t *w = NULL;
    sdf_rc_t rc = sdf_create(path, "NAVCOMP", SDF_VER_DEFAULT,
                              SDF_WFLAG_HAS_SRNS, &w);
    if (rc != SDF_OK) return rc;

    /* One block: NAVCOMP PROGRAM in CSECT NAVSECT */
    uint16_t blk_no;
    sdf_wblock_t blk = {
        .csect_name = "NAVSECT",
        .blk_name   = "NAVCOMP",
        .blk_class  = SDF_BCLASS_PROGRAM,
        .blk_type   = 0,
        .blk_id     = 1,
    };
    rc = sdf_write_block(w, &blk, &blk_no);
    if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }

    /* Nine symbols (in any order; sdf_commit sorts alphabetically) */
    struct { const char *name; uint8_t cls; uint8_t typ;
             uint8_t rows; uint8_t cols; } syms[] = {
        { "VELOCITY",       SDF_SCLASS_VARIABLE,   SDF_STYPE_VECTOR,    3,  0 },
        { "ALTITUDE",       SDF_SCLASS_VARIABLE,   SDF_STYPE_SCALAR,    0,  0 },
        { "MESSAGE",        SDF_SCLASS_VARIABLE,   SDF_STYPE_CHARACTER, 0, 20 },
        { "BITS",           SDF_SCLASS_VARIABLE,   SDF_STYPE_BIT,      16,  0 },
        { "COUNT",          SDF_SCLASS_VARIABLE,   SDF_STYPE_INTEGER,   0,  0 },
        { "ARMED",          SDF_SCLASS_VARIABLE,   SDF_STYPE_BOOLEAN,   0,  0 },
        { "INERTIA",        SDF_SCLASS_VARIABLE,   SDF_STYPE_MATRIX,    3,  3 },
        { "LAUNCH_ENABLE",  SDF_SCLASS_VARIABLE,   SDF_STYPE_EVENT,     0,  0 },
        { "LONGSYMBOLNAME", SDF_SCLASS_VARIABLE,   SDF_STYPE_SCALAR,    0,  0 },
        /* NAME variable: sym_class=LABEL(4), sym_type=type of referent */
        { "ALT_PTR",        SDF_SCLASS_LABEL,      SDF_STYPE_SCALAR,    0,  0 },
        /* EQUATE_EXT: sym_class=2, sym_type=8 */
        { "EXT_CONST",      SDF_SCLASS_EQUATE_EXT, SDF_STYPE_EQUATE_EXT,0, 0 },
    };
    for (int i = 0; i < 11; i++) {
        sdf_wsymbol_t sym = {
            .blk_no    = blk_no,
            .sym_class = syms[i].cls,
            .sym_type  = syms[i].typ,
            .rows      = syms[i].rows,
            .columns   = syms[i].cols,
        };
        strncpy(sym.symb_name, syms[i].name, SDF_LONG_NAME_LEN);
        uint16_t symb_no;
        rc = sdf_write_symbol(w, &sym, &symb_no);
        if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }
    }

    /* TASK block: BURN_TASK */
    uint16_t task_blk_no;
    sdf_wblock_t task_blk = {
        .csect_name = "NAVSECT",
        .blk_name   = "BURN_TASK",
        .blk_class  = SDF_BCLASS_TASK,   /* = 4 */
        .blk_id     = 2,
    };
    rc = sdf_write_block(w, &task_blk, &task_blk_no);
    if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }

    /* TASK entry-point symbol */
    sdf_wsymbol_t task_sym = { .blk_no = task_blk_no,
                                .sym_class = SDF_SCLASS_VARIABLE,
                                .sym_type  = SDF_STYPE_TASK };
    strncpy(task_sym.symb_name, "BURN_TASK", SDF_LONG_NAME_LEN);
    rc = sdf_write_symbol(w, &task_sym, NULL);
    if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }

    /* TASK local variable */
    sdf_wsymbol_t task_loc = { .blk_no = task_blk_no,
                                .sym_class = SDF_SCLASS_VARIABLE,
                                .sym_type  = SDF_STYPE_SCALAR };
    strncpy(task_loc.symb_name, "THRUST_LEVEL", SDF_LONG_NAME_LEN);
    rc = sdf_write_symbol(w, &task_loc, NULL);
    if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }

    /* Four statements */
    struct { const char *srn; uint16_t typ; bool exec;
             uint8_t lhs; uint8_t labls; } stmts[] = {
        { "S0001 ", SDF_STTYPE_ASSIGN, true,  1, 0 },
        { "S0002 ", SDF_STTYPE_ASSIGN, true,  1, 1 },
        { "S0003 ", SDF_STTYPE_IF,     true,  0, 0 },
        { "S0004 ", 0,                 false, 0, 0 },
    };
    for (int i = 0; i < 4; i++) {
        sdf_wstmt_t st = {
            .blk_no    = blk_no,
            .stmt_type = stmts[i].typ,
            .is_exec   = stmts[i].exec,
            .num_lhs   = stmts[i].lhs,
            .num_labls = stmts[i].labls,
        };
        memcpy(st.srn, stmts[i].srn, SDF_SRN_LEN);
        uint16_t stmt_no;
        rc = sdf_write_stmt(w, &st, &stmt_no);
        if (rc != SDF_OK) { sdf_wcancel(&w); return rc; }
    }

    rc = sdf_commit(&w);
    return rc;
}

/* ------------------------------------------------------------------ */
/* Tests                                                               */
/* ------------------------------------------------------------------ */

static void run_tests(const char *path)
{
    /* T01: write succeeds */
    puts("T01: write NAVCOMP member");
    sdf_rc_t rc = build_navcomp(path);
    CHECK_RC("build_navcomp", rc, SDF_OK);
    if (rc != SDF_OK) {
        printf("  Cannot continue: write failed (%s)\n", sdf_wstrerror(rc));
        return;
    }

    /* T02: sdfcheck reports GOOD */
    puts("T02: sdfcheck NAVCOMP");
    sdf_ctx_t *ctx = NULL;
    CHECK_RC("open", sdf_open(path, SDF_OPEN_RDONLY, 0, &ctx), SDF_OK);
    CHECK_RC("select", sdf_select(ctx, "NAVCOMP"), SDF_OK);
    void *root = NULL;
    CHECK_RC("locate_root", sdf_locate_root(ctx, SDF_DISP_NONE, &root), SDF_OK);
    CHECK("root non-null", root != NULL);

    /* T03: block count and metadata */
    /* After block sort: BURN_TASK(1) < NAVCOMP(2).
     * Symbol numbering:
     *   1: BURN_TASK (task entry-point, BURN_TASK block)
     *   2: THRUST_LEVEL (scalar, BURN_TASK block)
     *   NAVCOMP block (symbs 3..13), alphabetical:
     *   3:ALTITUDE  4:ALT_PTR  5:ARMED  6:BITS  7:COUNT  8:EXT_CONST
     *   9:INERTIA  10:LAUNCH_ENABLE  11:LONGSYMBOLNAME  12:MESSAGE  13:VELOCITY
     * Note: ALTITUDE < ALT_PTR because 'I'(73) < '_'(95) */
    puts("T03: block metadata");
    sdf_block_result_t blk;
    CHECK_RC("find block 2 (NAVCOMP)", sdf_find_block_by_number(ctx, 2, SDF_DISP_NONE, &blk), SDF_OK);
    CHECK("csect=NAVSECT",  strncmp(blk.csect_name, "NAVSECT", 7) == 0);
    CHECK("name=NAVCOMP",   strcmp(blk.blk_name, "NAVCOMP") == 0);
    CHECK("blk_class=1",    blk.blk_class == SDF_BCLASS_PROGRAM);
    CHECK("fsymb=3",        blk.fsymb_no == 3);
    CHECK("lsymb=13",       blk.lsymb_no == 13);
    CHECK("fstmt=1",        blk.fstmt_no == 1);
    CHECK("lstm=4",         blk.lstm_no  == 4);

    sdf_block_result_t tblk;
    CHECK_RC("find block 1 (BURN_TASK)", sdf_find_block_by_number(ctx, 1, SDF_DISP_NONE, &tblk), SDF_OK);
    CHECK("BURN_TASK blk_class=TASK", tblk.blk_class == SDF_BCLASS_TASK);
    CHECK("BURN_TASK fsymb=1",        tblk.fsymb_no == 1);
    CHECK("BURN_TASK lsymb=2",        tblk.lsymb_no == 2);

    /* T04: full symbol order check */
    puts("T04: symbol alphabetical order");
    const char *all_order[] = {
        "BURN_TASK", "THRUST_LEVEL",                    /* symbs 1-2: BURN_TASK block */
        "ALTITUDE", "ALT_PTR", "ARMED", "BITS", "COUNT",
        "EXT_CONST", "INERTIA", "LAUNCH_ENABLE", "LONGSYMBOLNAME",
        "MESSAGE", "VELOCITY"                            /* symbs 3-13: NAVCOMP block */
    };
    bool order_ok = true;
    for (int i = 0; i < 13; i++) {
        sdf_symbol_result_t sym;
        sdf_rc_t src = sdf_find_symbol_by_number(ctx, (uint16_t)(i+1),
                                                  SDF_DISP_NONE, &sym);
        if (src != SDF_OK || strcmp(sym.symb_name, all_order[i]) != 0) {
            order_ok = false;
            printf("    symb %d: got '%s', want '%s'\n",
                   i+1, sym.symb_name, all_order[i]);
        }
    }
    CHECK("symbols alphabetical", order_ok);

    /* T05: symbol type fields */
    puts("T05: symbol type fields");

    /* BURN_TASK entry-point: symb 1, type=TASK */
    sdf_symbol_result_t bts;
    CHECK_RC("find BURN_TASK sym", sdf_find_symbol_by_number(ctx, 1, SDF_DISP_NONE, &bts),
             SDF_OK);
    CHECK("BURN_TASK sym type=TASK", bts.sym_type == SDF_STYPE_TASK);

    /* ALT_PTR: symb 4, NAME variable (class=LABEL, type=SCALAR) */
    sdf_symbol_result_t nv;
    CHECK_RC("find ALT_PTR", sdf_find_symbol_by_number(ctx, 4, SDF_DISP_NONE, &nv),
             SDF_OK);
    CHECK("ALT_PTR name",        strcmp(nv.symb_name, "ALT_PTR") == 0);
    CHECK("ALT_PTR class=LABEL", nv.sym_class == SDF_SCLASS_LABEL);
    CHECK("ALT_PTR type=SCALAR", nv.sym_type  == SDF_STYPE_SCALAR);

    /* EXT_CONST: symb 8, EQUATE_EXT (class=2, type=8) */
    sdf_symbol_result_t eq;
    CHECK_RC("find EXT_CONST", sdf_find_symbol_by_number(ctx, 8, SDF_DISP_NONE, &eq),
             SDF_OK);
    CHECK("EXT_CONST name",             strcmp(eq.symb_name, "EXT_CONST") == 0);
    CHECK("EXT_CONST class=EQUATE_EXT", eq.sym_class == SDF_SCLASS_EQUATE_EXT);
    CHECK("EXT_CONST type=EQUATE_EXT",  eq.sym_type  == SDF_STYPE_EQUATE_EXT);

    /* VELOCITY is symbol 13 */
    sdf_symbol_result_t vel;
    CHECK_RC("find VELOCITY", sdf_find_symbol_by_number(ctx, 13, SDF_DISP_NONE, &vel),
             SDF_OK);
    CHECK("VELOCITY type=VECTOR", vel.sym_type == SDF_STYPE_VECTOR);
    CHECK("VELOCITY rows=3",      vel.rows == 3);

    /* INERTIA is symbol 9 */
    sdf_symbol_result_t ine;
    CHECK_RC("find INERTIA", sdf_find_symbol_by_number(ctx, 9, SDF_DISP_NONE, &ine),
             SDF_OK);
    CHECK("INERTIA type=MATRIX",  ine.sym_type == SDF_STYPE_MATRIX);
    CHECK("INERTIA rows=3",        ine.rows == 3);
    CHECK("INERTIA cols=3",        ine.columns == 3);

    /* LAUNCH_ENABLE is symbol 10 */
    sdf_symbol_result_t lev;
    CHECK_RC("find LAUNCH_ENABLE", sdf_find_symbol_by_number(ctx, 10, SDF_DISP_NONE, &lev),
             SDF_OK);
    CHECK("LAUNCH_ENABLE name",       strcmp(lev.symb_name, "LAUNCH_ENABLE") == 0);
    CHECK("LAUNCH_ENABLE type=EVENT", lev.sym_type == SDF_STYPE_EVENT);
    CHECK("LAUNCH_ENABLE rows=0",     lev.rows == 0);
    CHECK("LAUNCH_ENABLE columns=0",  lev.columns == 0);

    /* MESSAGE is symbol 12 */
    sdf_symbol_result_t msg;
    CHECK_RC("find MESSAGE", sdf_find_symbol_by_number(ctx, 12, SDF_DISP_NONE, &msg),
             SDF_OK);
    CHECK("MESSAGE type=CHARACTER", msg.sym_type == SDF_STYPE_CHARACTER);
    CHECK("MESSAGE columns=20",     msg.columns == 20);

    /* T06: find symbol by name */
    puts("T06: find symbol by name");
    sdf_find_block_by_number(ctx, 2, SDF_DISP_NONE, NULL);  /* set NAVCOMP block ctx */
    sdf_symbol_result_t alt;
    CHECK_RC("find ALTITUDE by name",
             sdf_find_symbol_by_name(ctx, "ALTITUDE", SDF_DISP_NONE, &alt),
             SDF_OK);
    CHECK("ALTITUDE symb_no=3",    alt.symb_no == 3);
    CHECK("ALTITUDE type=SCALAR",  alt.sym_type == SDF_STYPE_SCALAR);

    /* T07: find block by name */
    puts("T07: find block by name");
    sdf_block_result_t blk2;
    CHECK_RC("find NAVCOMP by name",
             sdf_find_block_by_name(ctx, "NAVCOMP", SDF_DISP_NONE, &blk2),
             SDF_OK);
    CHECK("blk_no=2", blk2.blk_no == 2);

    /* T08: statements */
    puts("T08: statement data");
    sdf_stmt_result_t stmt;
    CHECK_RC("stmt 1 exec",
             sdf_find_stmt_by_number(ctx, 1, SDF_DISP_NONE, &stmt), SDF_OK);
    CHECK("stmt1 is_exec",    stmt.is_executable);
    CHECK("stmt1 type=assign",stmt.stmt_type == SDF_STTYPE_ASSIGN);
    CHECK("stmt1 num_lhs=1",  stmt.num_lhs == 1);
    CHECK("stmt1 labls=0",    stmt.num_labls == 0);

    CHECK_RC("stmt 2 exec",
             sdf_find_stmt_by_number(ctx, 2, SDF_DISP_NONE, &stmt), SDF_OK);
    CHECK("stmt2 labls=1",    stmt.num_labls == 1);

    rc = sdf_find_stmt_by_number(ctx, 4, SDF_DISP_NONE, &stmt);
    CHECK("stmt 4 non-exec",  rc == SDF_NOT_EXEC);

    /* T09: find statement by SRN */
    puts("T09: find statement by SRN");
    char srn[SDF_SRN_LEN] = "S0003 ";
    CHECK_RC("find SRN S0003",
             sdf_find_stmt_by_srn(ctx, srn, SDF_DISP_NONE, &stmt), SDF_OK);
    CHECK("SRN stmt_no=3",    stmt.stmt_no == 3);
    CHECK("SRN type=IF",      stmt.stmt_type == SDF_STTYPE_IF);

    /* T10: LONGSYMBOLNAME (name > 8 chars, exercises name continuation) */
    puts("T10: long symbol name");
    sdf_find_block_by_number(ctx, 2, SDF_DISP_NONE, NULL);  /* NAVCOMP = block 2 */
    sdf_symbol_result_t lsn;
    CHECK_RC("find LONGSYMBOLNAME",
             sdf_find_symbol_by_name(ctx, "LONGSYMBOLNAME", SDF_DISP_NONE, &lsn),
             SDF_OK);
    CHECK("long name correct",
          strcmp(lsn.symb_name, "LONGSYMBOLNAME") == 0);
    CHECK("long name symb_len=14", lsn.symb_len == 14);

    /* T11: add a second member to the same file */
    puts("T11: sdf_add_member (second member)");
    sdf_close(&ctx);

    sdf_wctx_t *w2 = NULL;
    rc = sdf_add_member(path, "NAVCOMP2", SDF_VER_DEFAULT,
                        SDF_WFLAG_NONE, &w2);
    CHECK_RC("add_member rc", rc, SDF_OK);
    if (rc == SDF_OK) {
        sdf_wblock_t blk2b = {
            .csect_name = "NAVSECT2",
            .blk_name   = "NAVCOMP2",
            .blk_class  = SDF_BCLASS_PROGRAM,
            .blk_id     = 2,
        };
        uint16_t bn2;
        sdf_write_block(w2, &blk2b, &bn2);
        sdf_wsymbol_t sym2 = {
            .blk_no    = bn2,
            .sym_class = SDF_SCLASS_VARIABLE,
            .sym_type  = SDF_STYPE_INTEGER,
        };
        strncpy(sym2.symb_name, "COUNTER", SDF_LONG_NAME_LEN);
        sdf_write_symbol(w2, &sym2, NULL);
        rc = sdf_commit(&w2);
        CHECK_RC("commit second member", rc, SDF_OK);
    }

    /* T12: verify both members readable */
    puts("T12: both members readable");
    rc = sdf_open(path, SDF_OPEN_RDONLY, 0, &ctx);
    CHECK_RC("re-open", rc, SDF_OK);
    CHECK_RC("select NAVCOMP",  sdf_select(ctx, "NAVCOMP"),  SDF_OK);
    CHECK_RC("select NAVCOMP2", sdf_select(ctx, "NAVCOMP2"), SDF_OK);
    sdf_block_result_t br2;
    CHECK_RC("blk in NAVCOMP2",
             sdf_find_block_by_number(ctx, 1, SDF_DISP_NONE, &br2), SDF_OK);
    CHECK("blk2 name", strcmp(br2.blk_name, "NAVCOMP2") == 0);
    sdf_close(&ctx);

    /* T13: duplicate block name rejected */
    puts("T13: duplicate block name rejected");
    sdf_wctx_t *wd = NULL;
    sdf_create("/tmp/sdf_dup_test.sdf", "DUPTEST", SDF_VER_DEFAULT, 0, &wd);
    sdf_wblock_t db = { .csect_name="CS", .blk_name="MYBLK", .blk_class=1 };
    sdf_write_block(wd, &db, NULL);
    rc = sdf_write_block(wd, &db, NULL);
    CHECK("dup block rejected", rc == SDF_ERR_DUP_BLK);
    sdf_wcancel(&wd);
    unlink("/tmp/sdf_dup_test.sdf");

    /* T14: sdf_wstats */
    puts("T14: sdf_wstats");
    sdf_create("/tmp/sdf_stats_test.sdf", "STTEST", SDF_VER_DEFAULT, 0, &wd);
    sdf_wblock_t sb = { .csect_name="CS", .blk_name="STBLK", .blk_class=1 };
    uint16_t sbno;
    sdf_write_block(wd, &sb, &sbno);
    sdf_wsymbol_t ss = { .blk_no=sbno, .sym_class=1, .sym_type=1 };
    strncpy(ss.symb_name, "X", SDF_LONG_NAME_LEN);
    sdf_write_symbol(wd, &ss, NULL);
    uint16_t nb, ns, nst;
    sdf_wstats(wd, &nb, &ns, &nst);
    CHECK("wstats blks=1",  nb  == 1);
    CHECK("wstats symbs=1", ns  == 1);
    CHECK("wstats stmts=0", nst == 0);
    sdf_wcancel(&wd);
    unlink("/tmp/sdf_stats_test.sdf");

    /* ------------------------------------------------------------------
     * T15: write STRUCTURE with COPY link (struct_of / STRCDATA)
     *
     * Scenario (mirrors HAL/S):
     *   STRUCTURE BASE_S;
     *     DECLARE BASE_FIELD SCALAR;
     *   CLOSE BASE_S;
     *
     *   STRUCTURE EXT_S COPY BASE_S;   <- copy_blk_no = blk_no(BASE_S)
     *     DECLARE EXTRA_FIELD INTEGER;
     *   CLOSE EXT_S;
     *
     * Both templates are blk_class=PROCEDURE (3).
     * The EXT_S template header symbol carries copy_blk_no pointing to
     * the BASE_S block.
     * ------------------------------------------------------------------ */
    puts("T15: write STRUCTURE-COPY member");
    sdf_wctx_t *wc = NULL;
    rc = sdf_create("/tmp/sdf_copy_test.sdf", "COPYMEM",
                    SDF_VER_DEFAULT, SDF_WFLAG_HAS_SRNS, &wc);
    CHECK_RC("copy: create", rc, SDF_OK);

    /* Block 1: main PROGRAM */
    uint16_t c_prog;
    sdf_wblock_t c_progblk = {
        .csect_name = "COPYCS", .blk_name = "COPYMAIN",
        .blk_class  = SDF_BCLASS_PROGRAM, .blk_id = 1,
    };
    rc = sdf_write_block(wc, &c_progblk, &c_prog);
    CHECK_RC("copy: add COPYMAIN block", rc, SDF_OK);

    /* Block 2: BASE_S template */
    uint16_t c_base;
    sdf_wblock_t c_baseblk = {
        .csect_name = "COPYCS", .blk_name = "BASE_S",
        .blk_class  = SDF_BCLASS_PROCEDURE, .blk_id = 2,
    };
    rc = sdf_write_block(wc, &c_baseblk, &c_base);
    CHECK_RC("copy: add BASE_S block", rc, SDF_OK);

    /* Block 3: EXT_S template (COPYs BASE_S) */
    uint16_t c_ext;
    sdf_wblock_t c_extblk = {
        .csect_name = "COPYCS", .blk_name = "EXT_S",
        .blk_class  = SDF_BCLASS_PROCEDURE, .blk_id = 3,
    };
    rc = sdf_write_block(wc, &c_extblk, &c_ext);
    CHECK_RC("copy: add EXT_S block", rc, SDF_OK);

    /* BASE_S template header symbol */
    sdf_wsymbol_t c_base_hdr = {
        .blk_no    = c_base,
        .sym_class = SDF_SCLASS_TEMPLATE,
        .sym_type  = SDF_STYPE_STRUCTURE,
    };
    strncpy(c_base_hdr.symb_name, "BASE_S", SDF_LONG_NAME_LEN);
    uint16_t c_base_hdr_no;
    rc = sdf_write_symbol(wc, &c_base_hdr, &c_base_hdr_no);
    CHECK_RC("copy: BASE_S hdr symbol", rc, SDF_OK);

    /* BASE_S member */
    sdf_wsymbol_t c_base_mem = {
        .blk_no    = c_base,
        .sym_class = SDF_SCLASS_VARIABLE,
        .sym_type  = SDF_STYPE_SCALAR,
    };
    strncpy(c_base_mem.symb_name, "BASE_FIELD", SDF_LONG_NAME_LEN);
    rc = sdf_write_symbol(wc, &c_base_mem, NULL);
    CHECK_RC("copy: BASE_FIELD symbol", rc, SDF_OK);

    /* EXT_S template header symbol -- copy_blk_no points to BASE_S */
    sdf_wsymbol_t c_ext_hdr = {
        .blk_no      = c_ext,
        .sym_class   = SDF_SCLASS_TEMPLATE,
        .sym_type    = SDF_STYPE_STRUCTURE,
        .copy_blk_no = c_base,   /* <-- the COPY link */
    };
    strncpy(c_ext_hdr.symb_name, "EXT_S", SDF_LONG_NAME_LEN);
    uint16_t c_ext_hdr_no;
    rc = sdf_write_symbol(wc, &c_ext_hdr, &c_ext_hdr_no);
    CHECK_RC("copy: EXT_S hdr symbol (with copy_blk_no)", rc, SDF_OK);

    /* EXT_S extra member */
    sdf_wsymbol_t c_ext_mem = {
        .blk_no    = c_ext,
        .sym_class = SDF_SCLASS_VARIABLE,
        .sym_type  = SDF_STYPE_INTEGER,
    };
    strncpy(c_ext_mem.symb_name, "EXTRA_FIELD", SDF_LONG_NAME_LEN);
    rc = sdf_write_symbol(wc, &c_ext_mem, NULL);
    CHECK_RC("copy: EXTRA_FIELD symbol", rc, SDF_OK);

    /* Instance of EXT_S in the PROGRAM block */
    sdf_wsymbol_t c_inst = {
        .blk_no    = c_prog,
        .sym_class = SDF_SCLASS_VARIABLE,
        .sym_type  = SDF_STYPE_STRUCTURE,
        .rows      = 0,   /* filled after commit in real compiler */
    };
    strncpy(c_inst.symb_name, "MY_EXT", SDF_LONG_NAME_LEN);
    rc = sdf_write_symbol(wc, &c_inst, NULL);
    CHECK_RC("copy: MY_EXT instance symbol", rc, SDF_OK);

    /* One statement */
    sdf_wstmt_t c_st = {
        .blk_no    = c_prog,
        .stmt_type = SDF_STTYPE_ASSIGN,
        .is_exec   = true,
        .num_lhs   = 1,
    };
    memcpy(c_st.srn, "C0001 ", SDF_SRN_LEN);
    rc = sdf_write_stmt(wc, &c_st, NULL);
    CHECK_RC("copy: write stmt", rc, SDF_OK);

    rc = sdf_commit(&wc);
    CHECK_RC("copy: commit", rc, SDF_OK);

    /* T16: read back and verify STRCDATA / copy_blk_no */
    puts("T16: read back COPY member -- verify copy_blk_no in EXT_S header");
    sdf_ctx_t *cctx = NULL;
    rc = sdf_open("/tmp/sdf_copy_test.sdf", SDF_OPEN_RDONLY, 0, &cctx);
    CHECK_RC("copy: open", rc, SDF_OK);
    rc = sdf_select(cctx, "COPYMEM");
    CHECK_RC("copy: select", rc, SDF_OK);

    /* Find the EXT_S block by name */
    sdf_block_result_t c_extblk_r;
    rc = sdf_find_block_by_name(cctx, "EXT_S", SDF_DISP_NONE, &c_extblk_r);
    CHECK_RC("copy: find EXT_S block", rc, SDF_OK);
    uint16_t ext_blk_no = c_extblk_r.blk_no;

    /* Find BASE_S block by name */
    sdf_block_result_t c_baseblk_r;
    rc = sdf_find_block_by_name(cctx, "BASE_S", SDF_DISP_NONE, &c_baseblk_r);
    CHECK_RC("copy: find BASE_S block", rc, SDF_OK);
    uint16_t base_blk_no = c_baseblk_r.blk_no;

    /* Walk symbols to find EXT_S template header (class=TEMPLATE in EXT_S block) */
    sdf_block_result_t drootblk;
    rc = sdf_find_block_by_number(cctx, 1, SDF_DISP_NONE, &drootblk);
    /* total sym count from DROOTCEL -- use find_symbol_by_number loop */
    bool found_copy = false;
    uint16_t total_syms = 0;
    /* determine sym range from all blocks */
    for (uint16_t bn = 1; bn <= 3; bn++) {
        sdf_block_result_t br;
        if (sdf_find_block_by_number(cctx, bn, SDF_DISP_NONE, &br) == SDF_OK)
            if (br.lsymb_no > total_syms) total_syms = br.lsymb_no;
    }
    for (uint16_t sn = 1; sn <= total_syms; sn++) {
        sdf_symbol_result_t sr;
        if (sdf_find_symbol_by_number(cctx, sn, SDF_DISP_NONE, &sr) != SDF_OK)
            continue;
        if (sr.blk_no == ext_blk_no &&
            sr.sym_class == SDF_SCLASS_TEMPLATE &&
            sr.sym_type  == SDF_STYPE_STRUCTURE) {
            /* Found the EXT_S template header */
            CHECK("EXT_S hdr: copy_blk_no == base_blk_no",
                  sr.copy_blk_no == base_blk_no);
            CHECK("EXT_S hdr: copy_blk_no != 0",
                  sr.copy_blk_no != 0);
            found_copy = true;
            break;
        }
    }
    CHECK("EXT_S template header found", found_copy);

    /* BASE_S template header must have copy_blk_no == 0 */
    bool found_base_hdr = false;
    for (uint16_t sn = 1; sn <= total_syms; sn++) {
        sdf_symbol_result_t sr;
        if (sdf_find_symbol_by_number(cctx, sn, SDF_DISP_NONE, &sr) != SDF_OK)
            continue;
        if (sr.blk_no == base_blk_no &&
            sr.sym_class == SDF_SCLASS_TEMPLATE &&
            sr.sym_type  == SDF_STYPE_STRUCTURE) {
            CHECK("BASE_S hdr: copy_blk_no == 0", sr.copy_blk_no == 0);
            found_base_hdr = true;
            break;
        }
    }
    CHECK("BASE_S template header found", found_base_hdr);

    sdf_close(&cctx);
    unlink("/tmp/sdf_copy_test.sdf");
}

/* ------------------------------------------------------------------ */
/* main                                                                */
/* ------------------------------------------------------------------ */

int main(void)
{
    char path[] = "/tmp/sdf_write_test_XXXXXX";
    int fd = mkstemp(path);
    if (fd < 0) { perror("mkstemp"); return 1; }
    close(fd);

    printf("Write test SDF: %s\n\n", path);
    run_tests(path);
    unlink(path);

    printf("\n--- Results: %d passed, %d failed ---\n", g_pass, g_fail);
    return g_fail > 0 ? 1 : 0;
}
