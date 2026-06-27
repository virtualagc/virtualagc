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

    /* Eight symbols (in any order; sdf_commit sorts alphabetically) */
    struct { const char *name; uint8_t cls; uint8_t typ;
             uint8_t rows; uint8_t cols; } syms[] = {
        { "VELOCITY",       SDF_SCLASS_VARIABLE, SDF_STYPE_VECTOR,    3,  0 },
        { "ALTITUDE",       SDF_SCLASS_VARIABLE, SDF_STYPE_SCALAR,    0,  0 },
        { "MESSAGE",        SDF_SCLASS_VARIABLE, SDF_STYPE_CHARACTER, 0, 20 },
        { "BITS",           SDF_SCLASS_VARIABLE, SDF_STYPE_BIT,      16,  0 },
        { "COUNT",          SDF_SCLASS_VARIABLE, SDF_STYPE_INTEGER,   0,  0 },
        { "ARMED",          SDF_SCLASS_VARIABLE, SDF_STYPE_BOOLEAN,   0,  0 },
        { "INERTIA",        SDF_SCLASS_VARIABLE, SDF_STYPE_MATRIX,    3,  3 },
        { "LONGSYMBOLNAME", SDF_SCLASS_VARIABLE, SDF_STYPE_SCALAR,    0,  0 },
    };
    for (int i = 0; i < 8; i++) {
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

    return sdf_commit(&w);
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
    puts("T03: block metadata");
    sdf_block_result_t blk;
    CHECK_RC("find block 1", sdf_find_block_by_number(ctx, 1, SDF_DISP_NONE, &blk), SDF_OK);
    CHECK("csect=NAVSECT",  strncmp(blk.csect_name, "NAVSECT", 7) == 0);
    CHECK("name=NAVCOMP",   strcmp(blk.blk_name, "NAVCOMP") == 0);
    CHECK("blk_class=1",    blk.blk_class == SDF_BCLASS_PROGRAM);
    CHECK("fsymb=1",        blk.fsymb_no == 1);
    CHECK("lsymb=8",        blk.lsymb_no == 8);
    CHECK("fstmt=1",        blk.fstmt_no == 1);
    CHECK("lstm=4",         blk.lstm_no  == 4);

    /* T04: symbol sort order (alphabetical) */
    puts("T04: symbol alphabetical order");
    const char *expected_order[] = {
        "ALTITUDE", "ARMED", "BITS", "COUNT",
        "INERTIA", "LONGSYMBOLNAME", "MESSAGE", "VELOCITY"
    };
    bool order_ok = true;
    for (int i = 0; i < 8; i++) {
        sdf_symbol_result_t sym;
        sdf_rc_t src = sdf_find_symbol_by_number(ctx, (uint16_t)(i+1),
                                                  SDF_DISP_NONE, &sym);
        if (src != SDF_OK || strcmp(sym.symb_name, expected_order[i]) != 0) {
            order_ok = false;
            printf("    symb %d: got '%s', want '%s'\n",
                   i+1, sym.symb_name, expected_order[i]);
        }
    }
    CHECK("symbols alphabetical", order_ok);

    /* T05: symbol type fields */
    puts("T05: symbol type fields");
    /* VELOCITY is symbol 8 (last alphabetically) */
    sdf_symbol_result_t vel;
    CHECK_RC("find VELOCITY", sdf_find_symbol_by_number(ctx, 8, SDF_DISP_NONE, &vel),
             SDF_OK);
    CHECK("VELOCITY type=VECTOR", vel.sym_type == SDF_STYPE_VECTOR);
    CHECK("VELOCITY rows=3",      vel.rows == 3);

    /* INERTIA */
    sdf_symbol_result_t ine;
    CHECK_RC("find INERTIA", sdf_find_symbol_by_number(ctx, 5, SDF_DISP_NONE, &ine),
             SDF_OK);
    CHECK("INERTIA type=MATRIX",  ine.sym_type == SDF_STYPE_MATRIX);
    CHECK("INERTIA rows=3",        ine.rows == 3);
    CHECK("INERTIA cols=3",        ine.columns == 3);

    /* MESSAGE */
    sdf_symbol_result_t msg;
    CHECK_RC("find MESSAGE", sdf_find_symbol_by_number(ctx, 7, SDF_DISP_NONE, &msg),
             SDF_OK);
    CHECK("MESSAGE type=CHARACTER", msg.sym_type == SDF_STYPE_CHARACTER);
    CHECK("MESSAGE columns=20",     msg.columns == 20);

    /* T06: find symbol by name */
    puts("T06: find symbol by name");
    sdf_find_block_by_number(ctx, 1, SDF_DISP_NONE, NULL);  /* set block ctx */
    sdf_symbol_result_t alt;
    CHECK_RC("find ALTITUDE by name",
             sdf_find_symbol_by_name(ctx, "ALTITUDE", SDF_DISP_NONE, &alt),
             SDF_OK);
    CHECK("ALTITUDE symb_no=1", alt.symb_no == 1);
    CHECK("ALTITUDE type=SCALAR", alt.sym_type == SDF_STYPE_SCALAR);

    /* T07: find block by name */
    puts("T07: find block by name");
    sdf_block_result_t blk2;
    CHECK_RC("find NAVCOMP by name",
             sdf_find_block_by_name(ctx, "NAVCOMP", SDF_DISP_NONE, &blk2),
             SDF_OK);
    CHECK("blk_no=1", blk2.blk_no == 1);

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
    sdf_find_block_by_number(ctx, 1, SDF_DISP_NONE, NULL);
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
