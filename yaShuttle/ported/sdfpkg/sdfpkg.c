#define _POSIX_C_SOURCE 200809L
/*
 * sdfpkg.c  --  Top-level SDF package dispatcher.
 *
 * Ports SDFPKG.bal (the main entry point for all 18+1 service modes).
 *
 * In the original, one assembly entry point branched on R1 (the mode
 * number) via a branch table.  Here each mode is a separate C function
 * in the public API (sdfpkg.h), and this file provides their
 * implementations plus the shared internal helpers they all use.
 *
 * Mapping:
 *   sdf_open()                      → modes 0 (INIT)
 *   sdf_close()                     → mode 1 (TERM)
 *   sdf_augment()                   → mode 2
 *   sdf_rescind()                   → mode 3
 *   sdf_select()                    → mode 4
 *   sdf_locate_ptr()                → mode 5
 *   (set_disps is internal)         → mode 6
 *   sdf_locate_root()               → mode 7
 *   sdf_find_block_by_number()      → mode 8
 *   sdf_find_symbol_by_number()     → mode 9
 *   sdf_find_stmt_by_number()       → mode 10
 *   sdf_find_block_by_name()        → mode 11
 *   sdf_find_symbol_by_block_...()  → mode 12
 *   sdf_find_symbol_by_name()       → mode 13
 *   sdf_find_stmt_by_srn()          → mode 14
 *   sdf_find_block_node_by_number() → mode 15
 *   sdf_find_symbol_node_by_number()→ mode 16
 *   sdf_find_stmt_node_by_number()  → mode 17
 *   sdf_find_init_data()            → mode 18 (CR13079)
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "sdf_internal.h"

/* ------------------------------------------------------------------ */
/* Internal helpers                                                     */
/* ------------------------------------------------------------------ */

/*
 * require_select() -- ensure a member has been selected.
 */
static sdf_rc_t require_select(sdf_ctx_t *ctx)
{
    if (!ctx->cur_fcb)
        return SDF_ERR_NO_SELECT;
    return SDF_OK;
}

/*
 * do_block_lookup() -- shared core for modes 8, 11, 15.
 *
 * Given a blk_no already set in ctx->comm, locate the block node and
 * optionally the block tree cell, populating `result`.
 * `node_only` = true skips the tree-cell traversal (mode 15).
 */
static sdf_rc_t do_block_lookup(sdf_ctx_t *ctx, int disp_flags,
                                 bool node_only,
                                 sdf_block_result_t *result)
{
    /* Invalidate saved extent info */
    ctx->save_extpt = SDF_VPTR_NULL;
    ctx->sav_fsymb  = 0;
    ctx->sav_lsymb  = 0;

    uint16_t blk_no = ctx->comm.blk_no;

    /* NDX2PTR for block */
    sdf_vptr_t bnode_ptr;
    sdf_rc_t rc = sdf_ndx2ptr(ctx, 0, blk_no, &bnode_ptr);
    if (rc != SDF_OK)
        return rc;

    void *bnode_raw;
    rc = sdf_locate_vptr(ctx, bnode_ptr, NULL, &bnode_raw);
    if (rc != SDF_OK)
        return rc;

    sdf_blcknode_disk_t *bn = (sdf_blcknode_disk_t *)bnode_raw;
    sdf_field_to_str(bn->csct_name, SDF_NAME_LEN, ctx->comm.csect_nam);

    if (result)
        sdf_field_to_str(bn->csct_name, SDF_NAME_LEN, result->csect_name);

    if (node_only) {
        if (result) {
            result->blk_no = blk_no;
            result->raw_cell = bnode_raw;
        }
        return sdf_set_disps(ctx, disp_flags);
    }

    /* Follow BLOCKPTR to the block tree cell */
    sdf_vptr_t btcell_ptr = sdf_be32(&bn->block_ptr);
    void *btcell_raw;
    rc = sdf_locate_vptr(ctx, btcell_ptr, NULL, &btcell_raw);
    if (rc != SDF_OK)
        return rc;

    sdf_blktcell_disk_t *bt = (sdf_blktcell_disk_t *)btcell_raw;

    /* Copy block name into comm area and result */
    uint8_t name_len = bt->bname_len;
    if (name_len > SDF_LONG_NAME_LEN) name_len = SDF_LONG_NAME_LEN;
    char blk_name[SDF_LONG_NAME_LEN + 1];
    memcpy(blk_name, bt->blk_name, name_len);
    blk_name[name_len] = '\0';

    strncpy(ctx->comm.blk_nam, blk_name, SDF_LONG_NAME_LEN);
    ctx->comm.blk_nam[SDF_LONG_NAME_LEN] = '\0';
    ctx->comm.blkn_len = name_len;

    /* Extract extent info for symbol searches */
    ctx->save_extpt = sdf_be32(&bt->ext_ptr);
    ctx->sav_fsymb  = sdf_be16(&bt->fsymb_num);
    ctx->sav_lsymb  = sdf_be16(&bt->lsymb_num);

    if (result) {
        result->blk_no    = blk_no;
        result->blk_id    = sdf_be16(&bt->blk_id);
        result->blk_class = bt->blk_class;
        result->blk_type  = bt->blk_type;
        result->blk_flags = bt->blk_flgs;
        result->fsymb_no  = sdf_be16(&bt->fsymb_num);
        result->lsymb_no  = sdf_be16(&bt->lsymb_num);
        result->fstmt_no  = sdf_be16(&bt->fstmt_num);
        result->lstm_no   = sdf_be16(&bt->lstm_num);
        strncpy(result->blk_name, blk_name, SDF_LONG_NAME_LEN);
        result->blk_name[SDF_LONG_NAME_LEN] = '\0';
        result->raw_cell  = btcell_raw;
    }

    return sdf_set_disps(ctx, disp_flags);
}

/*
 * do_symbol_fill() -- extract symbol result fields from a located SDC.
 *
 * `snode_raw` points to the SYMBNODE in paged memory.
 * `sdc_raw`   points to the SYMBDC.
 * `symb_no`   is the resolved symbol number.
 */
static sdf_rc_t do_symbol_fill(sdf_ctx_t *ctx,
                                uint16_t   symb_no,
                                void      *snode_raw,
                                void      *sdc_raw,
                                int        disp_flags,
                                sdf_symbol_result_t *result)
{
    sdf_symbnode_disk_t *sn  = (sdf_symbnode_disk_t *)snode_raw;
    sdf_symbdc_disk_t   *sdc = (sdf_symbdc_disk_t   *)sdc_raw;

    /* Assemble full symbol name: up to 8 chars from node + continuation */
    uint8_t total_len = sdc->symb_len;
    if (total_len > SDF_LONG_NAME_LEN) total_len = SDF_LONG_NAME_LEN;

    char full_name[SDF_LONG_NAME_LEN + 1];
    memset(full_name, 0, sizeof(full_name));
    memcpy(full_name, sn->symb_name, SDF_NAME_LEN);
    if (total_len > SDF_NAME_LEN) {
        uint8_t cont_len = total_len - SDF_NAME_LEN;
        memcpy(full_name + SDF_NAME_LEN, sdc->name_cont, cont_len);
    }
    /* Strip trailing spaces */
    /* Null-terminate at total_len first, then strip trailing spaces.
     * This is necessary because memcpy of the 8-char node name may have
     * copied space-padding beyond the actual name length. */
    if (total_len <= SDF_LONG_NAME_LEN)
        full_name[total_len] = '\0';
    for (int i = total_len - 1; i >= 0 && full_name[i] == ' '; i--)
        full_name[i] = '\0';

    strncpy(ctx->comm.symb_nam, full_name, SDF_LONG_NAME_LEN);
    ctx->comm.symb_nam[SDF_LONG_NAME_LEN] = '\0';
    ctx->comm.symbn_len = total_len;

    uint16_t blk_num = sdf_be16(&sdc->block_num);
    ctx->comm.blk_no  = blk_num;
    ctx->comm.symb_no = symb_no;

    if (result) {
        result->symb_no   = symb_no;
        result->blk_no    = blk_num;
        result->sym_class = sdc->sym_class;
        result->sym_type  = sdc->sym_type;
        result->flag1     = sdc->flag1;
        result->flag2     = sdc->flag2;
        result->flag3     = sdc->flag3;
        result->flag4     = sdc->flag4;
        result->rows      = sdc->rows;
        result->columns   = sdc->columns;
        result->symb_len  = total_len;
        strncpy(result->symb_name, full_name, SDF_LONG_NAME_LEN);
        result->symb_name[SDF_LONG_NAME_LEN] = '\0';
        result->raw_cell  = sdc_raw;
    }

    return sdf_set_disps(ctx, disp_flags);
}

/*
 * chk_match() -- determine whether a located symbol matches the
 * search argument.  Returns:
 *    0  = match (proceed)
 *   -1  = search should go "up" (target < current)
 *   +1  = search should go "down" (target > current)
 *
 * Mirrors the CHKMATCH subroutine in SDFPKG.bal.
 * `srcharg` is the blank-padded 8-char search argument.
 * `symb_no` is the symbol number being tested.
 */
static int chk_match(sdf_ctx_t *ctx,
                     const char *srcharg8,
                     uint16_t    symb_no,
                     bool        first_mode)
{
    /* Locate the symbol node */
    sdf_vptr_t sn_ptr;
    if (sdf_ndx2ptr(ctx, 4, symb_no, &sn_ptr) != SDF_OK) return 1;
    void *sn_raw;
    if (sdf_locate_vptr(ctx, sn_ptr, NULL, &sn_raw) != SDF_OK) return 1;
    sdf_symbnode_disk_t *sn = (sdf_symbnode_disk_t *)sn_raw;

    /* Compare 8-char prefixes */
    int cmp8 = memcmp(srcharg8, sn->symb_name, SDF_NAME_LEN);
    if (cmp8 != 0)
        return (cmp8 < 0) ? -1 : 1;

    /* 8-char prefix matches -- check full name via SDC */
    sdf_vptr_t sdc_ptr = sdf_be32(&sn->sdc_ptr);
    void *sdc_raw;
    if (sdf_locate_vptr(ctx, sdc_ptr, NULL, &sdc_raw) != SDF_OK) return 1;
    sdf_symbdc_disk_t *sdc = (sdf_symbdc_disk_t *)sdc_raw;

    if (first_mode)
        return 0;   /* take the first match unconditionally */

    /* Skip equate externals */
    if (sdc->sym_class == SDF_CLASS_EQUATE_EXT &&
        sdc->sym_type  == SDF_TYPE_EQUATE_EXT)
        return 0;   /* signal "no direction change" → caller will skip */

    /* Accept classes 1–3 directly */
    if (sdc->sym_class <= 3) {
        /* But reject unqualified structure terminals */
        if ((sdc->flag1 & SDF_FLAG1_UNQUAL_STRUC) == 0)
            return 0;
    }

    /* Full name comparison */
    uint8_t sought_len = (uint8_t)strlen(srcharg8);
    /* strip spaces from srcharg8 */
    while (sought_len > 0 && srcharg8[sought_len-1] == ' ')
        sought_len--;

    uint8_t found_len  = sdc->symb_len;
    if (found_len > SDF_LONG_NAME_LEN) found_len = SDF_LONG_NAME_LEN;

    /* Build full found name */
    char full[SDF_LONG_NAME_LEN + 1] = {0};
    memcpy(full, sn->symb_name, SDF_NAME_LEN);
    if (found_len > SDF_NAME_LEN)
        memcpy(full + SDF_NAME_LEN, sdc->name_cont,
               found_len - SDF_NAME_LEN);

    uint8_t cmp_len = (sought_len < found_len) ? sought_len : found_len;
    /* We already matched the first 8 chars; compare the rest */
    if (found_len > SDF_NAME_LEN && sought_len > SDF_NAME_LEN) {
        int cmp_rest = memcmp(srcharg8 + SDF_NAME_LEN,
                              full     + SDF_NAME_LEN,
                              cmp_len  - SDF_NAME_LEN);
        if (cmp_rest != 0)
            return (cmp_rest < 0) ? -1 : 1;
    }

    if (sought_len == found_len)
        return 0;
    return (sought_len < found_len) ? -1 : 1;
}

/*
 * symbol_binary_search() -- binary + linear search for a symbol by name.
 * Mirrors the BINSRCH / LINSRCH logic in SDFPKG.bal.
 *
 * Operates within the symbol number range [ctx->sav_fsymb, ctx->sav_lsymb].
 * Uses symbol node extent cells when available.
 */
static sdf_rc_t symbol_binary_search(sdf_ctx_t *ctx,
                                      const char *srcharg8,
                                      uint16_t   *found_symb_no,
                                      void      **found_sn_raw,
                                      void      **found_sdc_raw)
{
    uint16_t lo = ctx->sav_fsymb;
    uint16_t hi = ctx->sav_lsymb;
    bool first  = ctx->first_sym;

    /*
     * If extent cells exist, use them to narrow the search to one page,
     * then binary search within that page's symbol number range.
     */
    if (ctx->save_extpt != SDF_VPTR_NULL) {
        sdf_vptr_t ext_ptr = ctx->save_extpt;
        while (ext_ptr != SDF_VPTR_NULL) {
            void *ext_raw;
            if (sdf_locate_vptr(ctx, ext_ptr, NULL, &ext_raw) != SDF_OK)
                break;
            sdf_symextf_disk_t *ef = (sdf_symextf_disk_t *)ext_raw;
            uint16_t nentries = sdf_be16(&ef->next_ntry);
            uint32_t succ     = sdf_be32(&ef->succ_ptr);
            uint8_t *vp       = (uint8_t *)(ef + 1);

            bool found_page = false;
            for (uint16_t i = 0; i < nentries; i++) {
                sdf_symextv_disk_t *ev = (sdf_symextv_disk_t *)vp;
                if (memcmp(ev->fst_symb, srcharg8, SDF_NAME_LEN) > 0) {
                    /* All remaining pages are alphabetically after our key */
                    return SDF_SYM_NOT_FOUND;
                }
                if (memcmp(ev->lst_symb, srcharg8, SDF_NAME_LEN) >= 0) {
                    /* Symbol, if present, is on this page -- refine lo/hi */
                    lo = ctx->sav_fsymb;  /* recalculate from page offset */
                    /* Derive symbol numbers from offsets */
                    uint16_t fst_off = sdf_be16(&ev->fst_off);
                    uint16_t lst_off = sdf_be16(&ev->lst_off);
                    uint16_t delta   = (lst_off - fst_off) / 12;
                    lo = ctx->sav_fsymb; /* base that increments per page */
                    hi = (uint16_t)(lo + delta);
            
                    break;
                }
                /* Advance base symbol number */
                uint16_t fst_off = sdf_be16(&ev->fst_off);
                uint16_t lst_off = sdf_be16(&ev->lst_off);
                uint16_t cnt     = (uint16_t)((lst_off - fst_off) / 12 + 1);
                lo = (uint16_t)(lo + cnt);
                vp += sizeof(sdf_symextv_disk_t);
            }
            if (found_page)
                break;
            ext_ptr = (sdf_vptr_t)succ;
        }
    }

    /* Binary search over [lo, hi] */
    while (lo <= hi) {
        uint16_t mid = (uint16_t)((lo + hi) / 2);
        int dir = chk_match(ctx, srcharg8, mid, first);
        if (dir == 0) {
            /* Hit -- linear scan backward to find the first occurrence */
            uint16_t candidate = mid;
            while (candidate > ctx->sav_fsymb) {
                uint16_t prev = (uint16_t)(candidate - 1);
                int d = chk_match(ctx, srcharg8, prev, first);
                if (d != 0) break;
                candidate = prev;
            }
            /* Now scan forward to find the best match */
            while (candidate <= ctx->sav_lsymb) {
                sdf_vptr_t sn_ptr;
                if (sdf_ndx2ptr(ctx, 4, candidate, &sn_ptr) != SDF_OK)
                    break;
                void *sn_raw;
                if (sdf_locate_vptr(ctx, sn_ptr, NULL, &sn_raw) != SDF_OK)
                    break;
                sdf_symbnode_disk_t *sn = (sdf_symbnode_disk_t *)sn_raw;
                if (memcmp(srcharg8, sn->symb_name, SDF_NAME_LEN) != 0)
                    break;
                sdf_vptr_t sdc_ptr = sdf_be32(&sn->sdc_ptr);
                void *sdc_raw;
                if (sdf_locate_vptr(ctx, sdc_ptr, NULL, &sdc_raw) != SDF_OK)
                    break;
                int d2 = chk_match(ctx, srcharg8, candidate, first);
                if (d2 == 0) {
                    *found_symb_no = candidate;
                    *found_sn_raw  = sn_raw;
                    *found_sdc_raw = sdc_raw;
                    return SDF_OK;
                }
                candidate++;
            }
            return SDF_SYM_NOT_FOUND;
        } else if (dir < 0) {
            if (mid == 0) break;
            hi = (uint16_t)(mid - 1);
        } else {
            lo = (uint16_t)(mid + 1);
        }
    }
    return SDF_SYM_NOT_FOUND;
}

/* ------------------------------------------------------------------ */
/* Public API implementations                                           */
/* ------------------------------------------------------------------ */

/*
 * sdf_open()  --  Mode 0: INIT
 */
sdf_rc_t sdf_open(const char *path, int flags, int npages,
                  sdf_ctx_t **ctx_out)
{
    sdf_ctx_t *ctx = calloc(1, sizeof(sdf_ctx_t));
    if (!ctx)
        return SDF_ERR_GETMAIN;

    ctx->update_mode = (flags & SDF_OPEN_UPDATE) != 0;
    ctx->first_sym   = (flags & SDF_OPEN_FIRST_SYM) != 0;
    ctx->one_fcb     = (flags & SDF_OPEN_ONE_FCB) != 0;

    ctx->fp = fopen(path, ctx->update_mode ? "r+b" : "rb");
    if (!ctx->fp) {
        free(ctx);
        return SDF_ERR_OPEN_FAIL;
    }

    ctx->comm.npages = (uint16_t)npages;

    sdf_rc_t rc = sdf_pagmod_init(ctx);
    if (rc != SDF_OK) {
        fclose(ctx->fp);
        free(ctx);
        return rc;
    }

    *ctx_out = ctx;
    return SDF_OK;
}

/*
 * sdf_close()  --  Mode 1: TERM
 */
sdf_rc_t sdf_close(sdf_ctx_t **ctx_p)
{
    if (!ctx_p || !*ctx_p)
        return SDF_OK;
    sdf_rc_t rc = sdf_pagmod_term(*ctx_p);
    free(*ctx_p);
    *ctx_p = NULL;
    return rc;
}

/*
 * sdf_augment()  --  Mode 2
 */
sdf_rc_t sdf_augment(sdf_ctx_t *ctx, int npages_add, int nbytes_add)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    ctx->comm.npages = (uint16_t)npages_add;
    ctx->comm.nbytes = (uint16_t)nbytes_add;
    return sdf_pagmod_augment(ctx);
}

/*
 * sdf_rescind()  --  Mode 3
 */
sdf_rc_t sdf_rescind(sdf_ctx_t *ctx)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    return sdf_pagmod_rescind(ctx);
}

/*
 * sdf_select()  --  Mode 4
 */
sdf_rc_t sdf_select(sdf_ctx_t *ctx, const char *member_name)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    strncpy(ctx->comm.sdf_nam, member_name, SDF_NAME_LEN);
    ctx->comm.sdf_nam[SDF_NAME_LEN] = '\0';
    return sdf_do_select(ctx);
}

/*
 * sdf_locate()  --  Mode 5
 */
sdf_rc_t sdf_locate(sdf_ctx_t *ctx, sdf_vptr_t vptr, int disp_flags,
                    void **addr_out)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = sdf_locate_vptr(ctx, vptr, NULL, addr_out);
    if (rc != SDF_OK) return rc;
    return sdf_set_disps(ctx, disp_flags);
}

/*
 * sdf_locate_root()  --  Mode 7
 */
sdf_rc_t sdf_locate_root(sdf_ctx_t *ctx, int disp_flags, void **root_out)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;

    /* Locate page 0 */
    sdf_vptr_t pg0 = SDF_VPTR_MAKE(0, 0);
    void *pg0_raw;
    rc = sdf_locate_vptr(ctx, pg0, NULL, &pg0_raw);
    if (rc != SDF_OK) return rc;

    sdf_pagezero_disk_t *pz = (sdf_pagezero_disk_t *)pg0_raw;
    sdf_vptr_t droot_ptr = sdf_be32(&pz->droot_ptr);

    void *droot_raw;
    rc = sdf_locate_vptr(ctx, droot_ptr, NULL, &droot_raw);
    if (rc != SDF_OK) return rc;

    /* CR13079: extract init data pointer */
    sdf_drootcel_disk_t *dr = (sdf_drootcel_disk_t *)droot_raw;
    ctx->init_ptr = sdf_be32(&dr->dinit_ptr);

    if (root_out)
        *root_out = droot_raw;

    return sdf_set_disps(ctx, disp_flags);
}

/*
 * sdf_find_block_by_number()  --  Mode 8
 */
sdf_rc_t sdf_find_block_by_number(sdf_ctx_t *ctx, uint16_t blk_no,
                                   int disp_flags,
                                   sdf_block_result_t *result)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;
    ctx->comm.blk_no = blk_no;
    return do_block_lookup(ctx, disp_flags, false, result);
}

/*
 * sdf_find_symbol_by_number()  --  Mode 9
 */
sdf_rc_t sdf_find_symbol_by_number(sdf_ctx_t *ctx, uint16_t symb_no,
                                    int disp_flags,
                                    sdf_symbol_result_t *result)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;

    sdf_vptr_t sn_ptr;
    rc = sdf_ndx2ptr(ctx, 4, symb_no, &sn_ptr);
    if (rc != SDF_OK) return rc;

    void *sn_raw;
    rc = sdf_locate_vptr(ctx, sn_ptr, NULL, &sn_raw);
    if (rc != SDF_OK) return rc;

    sdf_symbnode_disk_t *sn = (sdf_symbnode_disk_t *)sn_raw;

    /* Copy 8-char name into comm area */
    sdf_field_to_str(sn->symb_name, SDF_NAME_LEN, ctx->comm.symb_nam);

    sdf_vptr_t sdc_ptr = sdf_be32(&sn->sdc_ptr);
    void *sdc_raw;
    rc = sdf_locate_vptr(ctx, sdc_ptr, NULL, &sdc_raw);
    if (rc != SDF_OK) return rc;

    /* Mode 18 split (CR13079) handled separately; continue here */
    return do_symbol_fill(ctx, symb_no, sn_raw, sdc_raw, disp_flags, result);
}

/*
 * sdf_find_stmt_by_number()  --  Mode 10
 */
sdf_rc_t sdf_find_stmt_by_number(sdf_ctx_t *ctx, uint16_t stmt_no,
                                  int disp_flags,
                                  sdf_stmt_result_t *result)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;

    sdf_vptr_t sn_ptr;
    rc = sdf_ndx2ptr(ctx, 8, stmt_no, &sn_ptr);
    if (rc != SDF_OK) return rc;

    void *sn_raw;
    rc = sdf_locate_vptr(ctx, sn_ptr, NULL, &sn_raw);
    if (rc != SDF_OK) return rc;

    sdf_fcb_t *fcb = ctx->cur_fcb;
    sdf_vptr_t sdc_ptr;
    char srn[SDF_SRN_LEN + 1] = {0};
    bool has_srn = (fcb->flags & SDF_FLAG_HAS_SRNS) != 0;

    if (has_srn) {
        sdf_stmtnod1_disk_t *sn1 = (sdf_stmtnod1_disk_t *)sn_raw;
        memcpy(srn, sn1->srn, SDF_SRN_LEN);   /* CL6 */
        srn[SDF_SRN_LEN] = '\0';
        memcpy(ctx->comm.sref_no, srn, SDF_SRN_LEN + 1);
        ctx->comm.incl_cnt = (uint16_t)((sn1->incount[0] << 8) | sn1->incount[1]);
        sdc_ptr = sdf_be32(&sn1->stdc_ptr);
    } else {
        sdf_stmtnod0_disk_t *sn0 = (sdf_stmtnod0_disk_t *)sn_raw;
        sdc_ptr = sdf_be32(&sn0->stdc_ptr);
    }

    /* Non-executable statements have a non-positive pointer value */
    bool is_exec = ((int32_t)sdc_ptr > 0);
    bool is_decl = ((int32_t)sdc_ptr < 0);

    if (!is_exec && !is_decl) {
        ctx->comm.creturn = SDF_NOT_EXEC;
        return SDF_NOT_EXEC;
    }

    if (!is_exec) {
        /* Negative pointer: declare statement */
        sdc_ptr = (sdf_vptr_t)(-(int32_t)sdc_ptr);
    }

    void *sdc_raw;
    rc = sdf_locate_vptr(ctx, sdc_ptr, NULL, &sdc_raw);
    if (rc != SDF_OK) return rc;

    sdf_stmtdc_disk_t *sdc = (sdf_stmtdc_disk_t *)sdc_raw;
    uint16_t blk_num = sdf_be16(&sdc->block_num);
    ctx->comm.blk_no  = blk_num;
    ctx->comm.stmt_no = stmt_no;

    if (result) {
        result->stmt_no      = stmt_no;
        result->blk_no       = blk_num;
        result->stmt_type    = sdf_be16(&sdc->stmt_type);
        result->num_labls    = sdc->num_labls;
        result->num_lhs      = sdc->num_lhs;
        result->is_executable = is_exec;
        memcpy(result->srn, srn, SDF_SRN_LEN);   /* 6 chars */
        result->srn[SDF_SRN_LEN] = '\0';
        result->raw_cell = sdc_raw;
    }

    return sdf_set_disps(ctx, disp_flags);
}

/*
 * sdf_find_block_by_name()  --  Mode 11
 *
 * Binary tree walk on the BLKTCELL tree keyed by block name.
 * Mirrors the BNAME / LOCLOOP section of SDFPKG.bal.
 */
sdf_rc_t sdf_find_block_by_name(sdf_ctx_t *ctx, const char *blk_name,
                                 int disp_flags,
                                 sdf_block_result_t *result)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;

    strncpy(ctx->comm.blk_nam, blk_name, SDF_LONG_NAME_LEN);
    ctx->comm.blk_nam[SDF_LONG_NAME_LEN] = '\0';
    ctx->comm.blkn_len = (uint8_t)strlen(blk_name);
    if (ctx->comm.blkn_len > SDF_LONG_NAME_LEN)
        ctx->comm.blkn_len = SDF_LONG_NAME_LEN;
    ctx->comm.blk_no = 0;  /* zero in case not found */

    sdf_fcb_t *fcb = ctx->cur_fcb;
    sdf_vptr_t node_ptr = fcb->tree_ptr;

    while (node_ptr != SDF_VPTR_NULL) {
        void *btcell_raw;
        rc = sdf_locate_vptr(ctx, node_ptr, NULL, &btcell_raw);
        if (rc != SDF_OK) return rc;

        sdf_blktcell_disk_t *bt = (sdf_blktcell_disk_t *)btcell_raw;
        uint8_t found_len = bt->bname_len;
        if (found_len > SDF_LONG_NAME_LEN) found_len = SDF_LONG_NAME_LEN;

        uint8_t sought_len = ctx->comm.blkn_len;

        uint8_t cmp_len = (sought_len < found_len) ? sought_len : found_len;
        int cmp = memcmp(blk_name, bt->blk_name, cmp_len);

        if (cmp == 0 && sought_len == found_len) {
            /* Exact match */
            ctx->comm.blk_no = sdf_be16(&bt->blk_ndx);
            return do_block_lookup(ctx, disp_flags, false, result);
        }

        bool go_right = (cmp > 0) || (cmp == 0 && sought_len > found_len);
        node_ptr = go_right ? sdf_be32(&bt->rtree_ptr)
                            : sdf_be32(&bt->ltree_ptr);
    }

    ctx->save_extpt = SDF_VPTR_NULL;
    ctx->sav_fsymb  = 0;
    ctx->sav_lsymb  = 0;
    ctx->comm.creturn = SDF_NOT_FOUND;
    return SDF_NOT_FOUND;
}

/*
 * sdf_find_symbol_by_block_and_name()  --  Mode 12
 *
 * Find block by name first, then search for symbol within it.
 */
sdf_rc_t sdf_find_symbol_by_block_and_name(sdf_ctx_t *ctx,
                                            const char *blk_name,
                                            const char *symb_name,
                                            int disp_flags,
                                            sdf_symbol_result_t *result)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;

    sdf_rc_t rc = sdf_find_block_by_name(ctx, blk_name,
                                          SDF_DISP_NONE, NULL);
    if (rc != SDF_OK) return rc;

    /* Now do the symbol search within that block */
    strncpy(ctx->comm.symb_nam, symb_name, SDF_LONG_NAME_LEN);
    ctx->comm.symb_nam[SDF_LONG_NAME_LEN] = '\0';
    ctx->comm.symbn_len = (uint8_t)strlen(symb_name);
    ctx->comm.symb_no   = 0;

    return sdf_find_symbol_by_name(ctx, symb_name, disp_flags, result);
}

/*
 * sdf_find_symbol_by_name()  --  Mode 13
 *
 * Search within the block established by the most recent mode 8/11/12
 * call (ctx->sav_fsymb / sav_lsymb).
 */
sdf_rc_t sdf_find_symbol_by_name(sdf_ctx_t *ctx, const char *symb_name,
                                  int disp_flags,
                                  sdf_symbol_result_t *result)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;

    if (ctx->sav_fsymb == 0)
        return SDF_ERR_BLK_NOSPEC;

    /* Prepare blank-padded 8-char search argument */
    char srcharg8[SDF_NAME_LEN];
    sdf_str_to_field(symb_name, srcharg8, SDF_NAME_LEN);

    ctx->comm.symb_no = 0;

    uint16_t found_symb_no;
    void *sn_raw, *sdc_raw;
    rc = symbol_binary_search(ctx, srcharg8,
                              &found_symb_no, &sn_raw, &sdc_raw);
    if (rc != SDF_OK) {
        ctx->comm.creturn = SDF_SYM_NOT_FOUND;
        return SDF_SYM_NOT_FOUND;
    }

    ctx->comm.symb_no = found_symb_no;
    return do_symbol_fill(ctx, found_symb_no, sn_raw, sdc_raw,
                          disp_flags, result);
}

/*
 * sdf_find_stmt_by_srn()  --  Mode 14
 *
 * Binary search over statement nodes (which have SRNs) to find the
 * one matching the given 8-char SRN.  Mirrors FINDSRN in SDFPKG.bal.
 */
sdf_rc_t sdf_find_stmt_by_srn(sdf_ctx_t *ctx,
                               const char srn[SDF_SRN_LEN],
                               int disp_flags,
                               sdf_stmt_result_t *result)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;

    sdf_fcb_t *fcb = ctx->cur_fcb;

    if (!fcb->stmt_expt)
        return SDF_NO_SRNS;
    if (fcb->flags & SDF_FLAG_NONMONO)
        return SDF_SRNS_NONMONO;

    memcpy(ctx->comm.sref_no, srn, SDF_SRN_LEN);
    ctx->comm.sref_no[SDF_SRN_LEN] = '\0';
    ctx->comm.stmt_no = 0;

    uint16_t stmt_base = fcb->fst_stmt;
    sdf_vptr_t ext_ptr = fcb->stmt_expt;

    /* Walk statement node extent cells to find the right page */
    uint16_t lo_off = 0, hi_off = 0;
    uint32_t page_no = 0;


    while (ext_ptr != SDF_VPTR_NULL) {
        void *ext_raw;
        rc = sdf_locate_vptr(ctx, ext_ptr, NULL, &ext_raw);
        if (rc != SDF_OK) return rc;

        sdf_stmtextf_disk_t *ef  = (sdf_stmtextf_disk_t *)ext_raw;
        uint16_t nentries = sdf_be16(&ef->nx_ntry);
        uint32_t succ     = sdf_be32(&ef->succ_ptr1);
        uint8_t *vp       = (uint8_t *)(ef + 1);

        for (uint16_t i = 0; i < nentries; i++) {
            sdf_stmtextv_disk_t *ev = (sdf_stmtextv_disk_t *)vp;
            if (memcmp(ev->fst_srn, srn, SDF_SRN_LEN) > 0) {
                ext_ptr = SDF_VPTR_NULL;
                goto srn_not_found;
            }
            if (memcmp(ev->lst_srn, srn, SDF_SRN_LEN) >= 0) {
                lo_off     = sdf_be16(&ev->fst_off1);
                hi_off     = sdf_be16(&ev->lst_off1);
                page_no    = sdf_be16(&ef->fst_page1) + i;
        
                goto page_found;
            }
            /* Advance base statement number */
            uint16_t fst_off = sdf_be16(&ev->fst_off1);
            uint16_t lst_off = sdf_be16(&ev->lst_off1);
            uint16_t cnt = (uint16_t)((lst_off - fst_off) / 12 + 1);
            stmt_base = (uint16_t)(stmt_base + cnt);
            vp += sizeof(sdf_stmtextv_disk_t);
        }
        ext_ptr = (sdf_vptr_t)succ;
    }

srn_not_found:
    ctx->comm.creturn = SDF_SYM_NOT_FOUND;
    return SDF_SYM_NOT_FOUND;

page_found:;
    /* Load the page and binary search by SRN */
    sdf_vptr_t pg_ptr = SDF_VPTR_MAKE((uint16_t)page_no, 0);
    void *pg_raw;
    rc = sdf_locate_vptr(ctx, pg_ptr, NULL, &pg_raw);
    if (rc != SDF_OK) return rc;

    /* Binary search [lo_off, hi_off] by SRN.
     * Work in item-relative indices (0-based from lo_off). */
    uint16_t n_items = (uint16_t)((hi_off - lo_off) / 12 + 1);
    uint16_t blo = 0, bhi = (uint16_t)(n_items - 1);
    uint16_t match_off = UINT16_MAX;

    while (blo <= bhi) {
        uint16_t bmid    = (uint16_t)((blo + bhi) / 2);
        uint16_t mid_off = (uint16_t)(lo_off + bmid * 12);

        sdf_stmtnod1_disk_t *sn =
            (sdf_stmtnod1_disk_t *)((uint8_t *)pg_raw + mid_off);
        int cmp = memcmp(srn, sn->srn, SDF_SRN_LEN);

        if (cmp == 0) {
            match_off = mid_off;
            /* Scan backward to find the first matching entry */
            while (match_off >= lo_off + 12) {
                uint16_t prev_off = (uint16_t)(match_off - 12);
                sdf_stmtnod1_disk_t *prev_sn =
                    (sdf_stmtnod1_disk_t *)((uint8_t *)pg_raw + prev_off);
                if (memcmp(srn, prev_sn->srn, SDF_SRN_LEN) != 0)
                    break;
                match_off = prev_off;
            }
            break;
        } else if (cmp < 0) {
            if (bmid == 0) break;
            bhi = (uint16_t)(bmid - 1);
        } else {
            blo = (uint16_t)(bmid + 1);
        }
    }

    if (match_off == UINT16_MAX)
        goto srn_not_found;

    sdf_stmtnod1_disk_t *matched =
        (sdf_stmtnod1_disk_t *)((uint8_t *)pg_raw + match_off);
    uint16_t stmt_no = (uint16_t)(stmt_base +
                                  (match_off - lo_off) / 12);
    sdf_vptr_t sdc_ptr = sdf_be32(&matched->stdc_ptr);

    bool is_exec = ((int32_t)sdc_ptr > 0);
    bool is_decl = ((int32_t)sdc_ptr < 0);

    if (!is_exec && !is_decl) {
        ctx->comm.creturn = SDF_NOT_EXEC;
        return SDF_NOT_EXEC;
    }

    ctx->comm.stmt_no = stmt_no;
    if (!is_exec)
        sdc_ptr = (sdf_vptr_t)(-(int32_t)sdc_ptr);

    void *sdc_raw;
    rc = sdf_locate_vptr(ctx, sdc_ptr, NULL, &sdc_raw);
    if (rc != SDF_OK) return rc;

    sdf_stmtdc_disk_t *sdc = (sdf_stmtdc_disk_t *)sdc_raw;
    ctx->comm.blk_no = sdf_be16(&sdc->block_num);

    if (result) {
        result->stmt_no      = stmt_no;
        result->blk_no       = sdf_be16(&sdc->block_num);
        result->stmt_type    = sdf_be16(&sdc->stmt_type);
        result->num_labls    = sdc->num_labls;
        result->num_lhs      = sdc->num_lhs;
        result->is_executable = is_exec;
        memcpy(result->srn, srn, SDF_SRN_LEN);
        result->srn[SDF_SRN_LEN] = '\0';
        result->raw_cell = sdc_raw;
    }

    return sdf_set_disps(ctx, disp_flags);
}

/*
 * sdf_find_block_node_by_number()  --  Mode 15
 */
sdf_rc_t sdf_find_block_node_by_number(sdf_ctx_t *ctx, uint16_t blk_no,
                                        int disp_flags,
                                        char csect_name_out[SDF_NAME_LEN + 1])
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;
    ctx->comm.blk_no = blk_no;
    sdf_block_result_t tmp;
    rc = do_block_lookup(ctx, disp_flags, true, &tmp);
    if (rc == SDF_OK && csect_name_out)
        memcpy(csect_name_out, tmp.csect_name, SDF_NAME_LEN + 1);
    return rc;
}

/*
 * sdf_find_symbol_node_by_number()  --  Mode 16
 */
sdf_rc_t sdf_find_symbol_node_by_number(sdf_ctx_t *ctx, uint16_t symb_no,
                                         int disp_flags,
                                         char name_out[SDF_NAME_LEN + 1],
                                         sdf_vptr_t *sdc_ptr_out)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;

    sdf_vptr_t sn_ptr;
    rc = sdf_ndx2ptr(ctx, 4, symb_no, &sn_ptr);
    if (rc != SDF_OK) return rc;

    void *sn_raw;
    rc = sdf_locate_vptr(ctx, sn_ptr, NULL, &sn_raw);
    if (rc != SDF_OK) return rc;

    sdf_symbnode_disk_t *sn = (sdf_symbnode_disk_t *)sn_raw;
    if (name_out)
        sdf_field_to_str(sn->symb_name, SDF_NAME_LEN, name_out);
    if (sdc_ptr_out)
        *sdc_ptr_out = sdf_be32(&sn->sdc_ptr);

    sdf_field_to_str(sn->symb_name, SDF_NAME_LEN, ctx->comm.symb_nam);
    ctx->comm.symb_no = symb_no;

    return sdf_set_disps(ctx, disp_flags);
}

/*
 * sdf_find_stmt_node_by_number()  --  Mode 17
 */
sdf_rc_t sdf_find_stmt_node_by_number(sdf_ctx_t *ctx, uint16_t stmt_no,
                                       int disp_flags,
                                       sdf_stmt_result_t *result)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    /* Mode 17 finds the node only, not the data cell */
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;

    sdf_vptr_t sn_ptr;
    rc = sdf_ndx2ptr(ctx, 8, stmt_no, &sn_ptr);
    if (rc != SDF_OK) return rc;

    void *sn_raw;
    rc = sdf_locate_vptr(ctx, sn_ptr, NULL, &sn_raw);
    if (rc != SDF_OK) return rc;

    sdf_fcb_t *fcb = ctx->cur_fcb;
    bool has_srn = (fcb->flags & SDF_FLAG_HAS_SRNS) != 0;
    ctx->comm.stmt_no = stmt_no;

    if (result) {
        result->stmt_no = stmt_no;
        result->raw_cell = sn_raw;
        if (has_srn) {
            sdf_stmtnod1_disk_t *sn1 = (sdf_stmtnod1_disk_t *)sn_raw;
            memcpy(result->srn, sn1->srn, SDF_SRN_LEN);   /* CL6 */
            result->srn[SDF_SRN_LEN] = '\0';
            memcpy(ctx->comm.sref_no, sn1->srn, SDF_SRN_LEN);
            ctx->comm.incl_cnt = (uint16_t)((sn1->incount[0] << 8) | sn1->incount[1]);
        }
    }

    return sdf_set_disps(ctx, disp_flags);
}

/*
 * sdf_find_init_data()  --  Mode 18 (CR13079)
 *
 * Find the initialization data entry for a symbol by its symbol number.
 * The symbol's RELADDR field (3 bytes) is used as a byte offset into
 * the initialization data area pointed to by the directory root cell.
 */
sdf_rc_t sdf_find_init_data(sdf_ctx_t *ctx, uint16_t symb_no,
                              int disp_flags, void **data_out)
{
    if (!ctx || !ctx->go_flag) return SDF_ERR_NOT_INIT;
    sdf_rc_t rc = require_select(ctx);
    if (rc != SDF_OK) return rc;

    /* First do mode-9 style symbol lookup to get the RELADDR */
    sdf_vptr_t sn_ptr;
    rc = sdf_ndx2ptr(ctx, 4, symb_no, &sn_ptr);
    if (rc != SDF_OK) return rc;

    void *sn_raw;
    rc = sdf_locate_vptr(ctx, sn_ptr, NULL, &sn_raw);
    if (rc != SDF_OK) return rc;

    sdf_symbnode_disk_t *sn = (sdf_symbnode_disk_t *)sn_raw;
    sdf_vptr_t sdc_ptr = sdf_be32(&sn->sdc_ptr);

    void *sdc_raw;
    rc = sdf_locate_vptr(ctx, sdc_ptr, NULL, &sdc_raw);
    if (rc != SDF_OK) return rc;

    sdf_symbdc_disk_t *sdc = (sdf_symbdc_disk_t *)sdc_raw;

    /* RELADDR is a 3-byte big-endian value in the SDC */
    uint32_t rel_addr = ((uint32_t)sdc->rel_addr[0] << 16) |
                        ((uint32_t)sdc->rel_addr[1] <<  8) |
                         (uint32_t)sdc->rel_addr[2];

    /* Byte offset = rel_addr * 2 (halfword addressing) */
    uint32_t byte_off = rel_addr * 2;

    /* Compute virtual pointer: init_ptr + byte_off */
    sdf_vptr_t init_ptr = ctx->init_ptr;
    uint32_t base_pg    = SDF_VPTR_PAGE(init_ptr);
    uint32_t base_off   = SDF_VPTR_OFFSET(init_ptr);
    uint32_t total_off  = base_off + byte_off;
    uint32_t add_pages  = total_off / SDF_PAGE_SIZE;
    uint32_t new_off    = total_off % SDF_PAGE_SIZE;
    sdf_vptr_t data_ptr = SDF_VPTR_MAKE(base_pg + add_pages, new_off);

    void *data_raw;
    rc = sdf_locate_vptr(ctx, data_ptr, NULL, &data_raw);
    if (rc != SDF_OK) return rc;

    if (data_out) *data_out = data_raw;
    return sdf_set_disps(ctx, disp_flags);
}

/*
 * sdf_stats()
 */
void sdf_stats(const sdf_ctx_t *ctx,
               uint32_t *reads_out,
               uint32_t *writes_out,
               uint32_t *selects_out)
{
    if (!ctx) {
        if (reads_out)   *reads_out   = 0;
        if (writes_out)  *writes_out  = 0;
        if (selects_out) *selects_out = 0;
        return;
    }
    if (reads_out)   *reads_out   = ctx->reads;
    if (writes_out)  *writes_out  = ctx->writes;
    if (selects_out) *selects_out = ctx->select_cnt;
}
