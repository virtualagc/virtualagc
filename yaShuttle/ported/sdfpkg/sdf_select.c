/*
 * sdf_select.c  --  SDF member selection and FCB management.
 * Ports SELECT.bal.
 *
 * File format: 8-byte header (magic + member count), then N×20-byte
 * index entries (name8 + page_count4 + pg0_offset8), then page data.
 */
#define _POSIX_C_SOURCE 200809L
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "sdf_internal.h"

#define SDF_FILE_MAGIC   0x53444600u
#define SDF_IDX_NAME_LEN 8
#define SDF_IDX_ENTRY_SZ (SDF_IDX_NAME_LEN + 4 + 8)

/* Locate a member by name in the file index.
 * name8: blank-padded 8-char key (no null). */
static sdf_rc_t find_member(sdf_ctx_t *ctx, const char *name8,
                             off_t *pg0_out, uint32_t *count_out)
{
    rewind(ctx->fp);
    uint8_t hdr[8];
    if (fread(hdr, 1, 8, ctx->fp) != 8) return SDF_ERR_OPEN_FAIL;

    uint32_t magic = ((uint32_t)hdr[0]<<24)|((uint32_t)hdr[1]<<16)|
                     ((uint32_t)hdr[2]<< 8)| (uint32_t)hdr[3];
    if (magic != SDF_FILE_MAGIC) return SDF_ERR_OPEN_FAIL;

    uint32_t n = ((uint32_t)hdr[4]<<24)|((uint32_t)hdr[5]<<16)|
                 ((uint32_t)hdr[6]<< 8)| (uint32_t)hdr[7];

    uint8_t entry[SDF_IDX_ENTRY_SZ];
    for (uint32_t i = 0; i < n; i++) {
        if (fread(entry, 1, SDF_IDX_ENTRY_SZ, ctx->fp) != SDF_IDX_ENTRY_SZ)
            return SDF_ERR_OPEN_FAIL;
        if (memcmp(entry, name8, SDF_IDX_NAME_LEN) == 0) {
            *count_out = ((uint32_t)entry[8] <<24)|((uint32_t)entry[9] <<16)|
                         ((uint32_t)entry[10]<< 8)| (uint32_t)entry[11];
            uint64_t off =
                ((uint64_t)entry[12]<<56)|((uint64_t)entry[13]<<48)|
                ((uint64_t)entry[14]<<40)|((uint64_t)entry[15]<<32)|
                ((uint64_t)entry[16]<<24)|((uint64_t)entry[17]<<16)|
                ((uint64_t)entry[18]<< 8)| (uint64_t)entry[19];
            *pg0_out = (off_t)off;
            return SDF_OK;
        }
    }
    return SDF_NOT_FOUND;
}

/* Build page offset table and pad_refs array for a new FCB. */
static sdf_rc_t build_page_table(sdf_ctx_t *ctx, sdf_fcb_t *fcb,
                                  off_t pg0_offset, uint32_t pg_count)
{
    fcb->page_offsets = malloc(pg_count * sizeof(off_t));
    if (!fcb->page_offsets) return SDF_ERR_GETMAIN;

    fcb->pad_refs = calloc(pg_count, sizeof(sdf_pad_entry_t *));
    if (!fcb->pad_refs) {
        free(fcb->page_offsets);
        fcb->page_offsets = NULL;
        return SDF_ERR_GETMAIN;
    }
    for (uint32_t i = 0; i < pg_count; i++)
        fcb->page_offsets[i] = pg0_offset + (off_t)i * SDF_PAGE_SIZE;

    ctx->reads += pg_count;   /* count sequential scan as reads */
    return SDF_OK;
}

/* Read page-0 metadata into the FCB. */
static sdf_rc_t init_fcb_from_page0(sdf_ctx_t *ctx, sdf_fcb_t *fcb)
{
    sdf_vptr_t pg0_ptr = SDF_VPTR_MAKE(0, 0);
    void *pg0_raw;
    sdf_rc_t rc = sdf_locate_vptr(ctx, pg0_ptr, NULL, &pg0_raw);
    if (rc != SDF_OK) return rc;

    sdf_pagezero_disk_t *pz = (sdf_pagezero_disk_t *)pg0_raw;
    fcb->version             = sdf_be16(&pz->version);
    sdf_vptr_t droot_vptr    = sdf_be32(&pz->droot_ptr);

    void *droot_raw;
    rc = sdf_locate_vptr(ctx, droot_vptr, NULL, &droot_raw);
    if (rc != SDF_OK) return rc;

    sdf_drootcel_disk_t *dr = (sdf_drootcel_disk_t *)droot_raw;

    uint16_t last_page = sdf_be16(&dr->last_page);
    if (last_page > fcb->lst_page) return SDF_ERR_LEN_MISMATCH;

    fcb->num_blks  = sdf_be16(&dr->blk_nodes);
    fcb->num_symbs = sdf_be16(&dr->sym_nodes);
    fcb->fst_stmt  = sdf_be16(&dr->fstmt_num);
    fcb->lst_stmt  = sdf_be16(&dr->lstm_num);
    fcb->lst_page  = last_page;
    fcb->flags     = (uint16_t)((dr->sdf_flags[0] << 8) | dr->sdf_flags[1]);
    fcb->blk_ptr   = sdf_be32(&dr->fbn_ptr);
    fcb->symb_ptr  = sdf_be32(&dr->fsn_ptr);
    fcb->stmt_ptr  = sdf_be32(&dr->fstn_ptr);
    fcb->tree_ptr  = sdf_be32(&dr->btree_ptr);
    fcb->stmt_expt = sdf_be32(&dr->snel_ptr);
    fcb->node_size = (fcb->flags & SDF_FLAG_HAS_SRNS) ? 12 : 4;

    /* CR13079 */
    ctx->init_ptr = sdf_be32(&dr->dinit_ptr);
    return SDF_OK;
}

sdf_rc_t sdf_do_select(sdf_ctx_t *ctx)
{
    ctx->select_cnt++;
    ctx->save_extpt = SDF_VPTR_NULL;
    ctx->sav_fsymb  = 0;
    ctx->sav_lsymb  = 0;

    if (ctx->cur_fcb &&
        strncmp(ctx->comm.sdf_nam, ctx->cur_fcb->filename,
                SDF_NAME_LEN) == 0)
        return SDF_OK;

    ctx->cur_fcb = NULL;

    char name8[SDF_NAME_LEN];
    sdf_str_to_field(ctx->comm.sdf_nam, name8, SDF_NAME_LEN);

    /* Search FCB tree */
    sdf_fcb_t **slot = &ctx->root_fcb;
    while (*slot) {
        int cmp = memcmp(name8, (*slot)->filename, SDF_NAME_LEN);
        if (cmp == 0) { ctx->cur_fcb = *slot; return SDF_OK; }
        slot = (cmp < 0) ? &(*slot)->lt_tree : &(*slot)->gt_tree;
    }

    /* ONE_FCB: flush all pages before building a new FCB */
    if (ctx->one_fcb && ctx->root_fcb) {
        if (ctx->reserves != 0) return SDF_ERR_SEL_RESERVED;
        for (int i = 0; i < ctx->num_ofpgs; i++) {
            sdf_pad_entry_t *e = &ctx->pad[i];
            if (!e->fcb_addr) continue;
            sdf_write_page(ctx, e);
            e->fcb_addr->pad_refs[e->page_no / 8] = NULL;
            e->fcb_addr   = NULL;
            e->modified   = false;
            e->use_count  = 0;
            e->page_no    = 0;
            e->resv_count = 0;
        }
    }

    off_t    pg0_offset;
    uint32_t pg_count;
    sdf_rc_t rc = find_member(ctx, name8, &pg0_offset, &pg_count);
    if (rc != SDF_OK) { ctx->comm.creturn = 8; return rc; }

    sdf_fcb_t *fcb = calloc(1, sizeof(sdf_fcb_t));
    if (!fcb) return SDF_ERR_GETMAIN;

    memcpy(fcb->filename, name8, SDF_NAME_LEN);
    fcb->filename[SDF_NAME_LEN] = '\0';
    /* Trim trailing spaces */
    for (int i = SDF_NAME_LEN - 1; i >= 0 && fcb->filename[i] == ' '; i--)
        fcb->filename[i] = '\0';

    fcb->lst_page = (uint16_t)(pg_count - 1);

    rc = build_page_table(ctx, fcb, pg0_offset, pg_count);
    if (rc != SDF_OK) { free(fcb); return rc; }

    *slot        = fcb;
    ctx->cur_fcb = fcb;
    ctx->fcb_cnt++;

    rc = init_fcb_from_page0(ctx, fcb);
    if (rc != SDF_OK) {
        *slot        = NULL;
        ctx->cur_fcb = NULL;
        free(fcb->page_offsets);
        free(fcb->pad_refs);
        free(fcb);
        return rc;
    }
    return SDF_OK;
}
