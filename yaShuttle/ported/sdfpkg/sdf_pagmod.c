/*
 * sdf_pagmod.c  --  Paging area and FCB area data manager.
 * Ports PAGMOD.bal (INIT, TERM, AUGMENT, RESCIND).
 */
#define _POSIX_C_SOURCE 200809L
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "sdf_internal.h"

sdf_rc_t sdf_pagmod_init(sdf_ctx_t *ctx)
{
    int npages = ctx->comm.npages;
    if (npages <= 0)  npages = 2;
    if (npages > SDF_PAD_SLOTS) return SDF_ERR_BAD_PGAREA;

    ctx->bas_npgs  = (uint16_t)npages;
    ctx->num_ofpgs = (uint16_t)npages;

    ctx->pad = calloc((size_t)SDF_PAD_SLOTS, sizeof(sdf_pad_entry_t));
    if (!ctx->pad) return SDF_ERR_GETMAIN;

    size_t buf_bytes = (size_t)SDF_PAD_SLOTS * SDF_PAGE_SIZE;
    ctx->page_bufs   = malloc(buf_bytes);
    if (!ctx->page_bufs) { free(ctx->pad); ctx->pad = NULL; return SDF_ERR_GETMAIN; }
    memset(ctx->page_bufs, 0, buf_bytes);

    for (int i = 0; i < SDF_PAD_SLOTS; i++)
        ctx->pad[i].page_addr = ctx->page_bufs[i];

    sdf_push_malloc(&ctx->malloc_stack, ctx->pad,
                    (size_t)SDF_PAD_SLOTS * sizeof(sdf_pad_entry_t));
    sdf_push_malloc(&ctx->malloc_stack, ctx->page_bufs, buf_bytes);

    ctx->avuln     = &ctx->pad[0];
    ctx->cur_entry = NULL;
    ctx->go_flag   = true;
    ctx->mod_flag  = ctx->update_mode;
    ctx->getm_flag = true;
    ctx->comm.npages = (uint16_t)(SDF_PAD_SLOTS - npages);
    return SDF_OK;
}

sdf_rc_t sdf_pagmod_term(sdf_ctx_t *ctx)
{
    sdf_rc_t rc = SDF_OK;

    /* Write back all dirty pages */
    for (int i = 0; i < ctx->num_ofpgs; i++) {
        sdf_rc_t wrc = sdf_write_page(ctx, &ctx->pad[i]);
        if (wrc != SDF_OK && rc == SDF_OK) rc = wrc;
    }

    /* Free FCB tree (iterative post-order) */
    #define TSTACK_MAX 256
    sdf_fcb_t *tstack[TSTACK_MAX];
    int tsp = 0;
    if (ctx->root_fcb) tstack[tsp++] = ctx->root_fcb;
    while (tsp > 0) {
        sdf_fcb_t *fcb = tstack[--tsp];
        if (fcb->gt_tree && tsp < TSTACK_MAX) tstack[tsp++] = fcb->gt_tree;
        if (fcb->lt_tree && tsp < TSTACK_MAX) tstack[tsp++] = fcb->lt_tree;
        free(fcb->page_offsets);
        free(fcb->pad_refs);
        free(fcb);
    }
    ctx->root_fcb = NULL;
    ctx->cur_fcb  = NULL;

    sdf_free_stack(&ctx->malloc_stack);
    sdf_free_stack(&ctx->fcb_stack);

    ctx->pad       = NULL;
    ctx->page_bufs = NULL;
    ctx->avuln     = NULL;
    ctx->cur_entry = NULL;
    ctx->loc_cnt   = 0;
    ctx->num_ofpgs = 0;
    ctx->bas_npgs  = 0;
    ctx->go_flag   = false;
    ctx->reserves  = 0;

    if (ctx->fp) { fclose(ctx->fp); ctx->fp = NULL; }
    return rc;
}

sdf_rc_t sdf_pagmod_augment(sdf_ctx_t *ctx)
{
    int add_pages = (int)ctx->comm.npages;
    if (add_pages < 0) return SDF_ERR_BAD_PGAREA;
    if (add_pages > 0) {
        int new_total = (int)ctx->num_ofpgs + add_pages;
        if (new_total > SDF_PAD_SLOTS) return SDF_ERR_BAD_PGAREA;
        ctx->num_ofpgs   = (uint16_t)new_total;
        ctx->comm.npages = (uint16_t)(SDF_PAD_SLOTS - new_total);
    }
    if (ctx->comm.nbytes == (uint16_t)-1) return SDF_ERR_BAD_FCBAREA; /* negative nbytes not representable as uint16 */
    return SDF_OK;
}

sdf_rc_t sdf_pagmod_rescind(sdf_ctx_t *ctx)
{
    int extra = (int)ctx->num_ofpgs - (int)ctx->bas_npgs;
    if (extra <= 0) return SDF_ERR_RESCIND_NA;

    sdf_rc_t rc = SDF_OK;
    for (int i = (int)ctx->bas_npgs; i < (int)ctx->num_ofpgs; i++) {
        sdf_pad_entry_t *e = &ctx->pad[i];
        if (!e->fcb_addr) continue;
        if (e->resv_count > 0) return SDF_ERR_RESCIND_RSV;
        sdf_rc_t wrc = sdf_write_page(ctx, e);
        if (wrc != SDF_OK && rc == SDF_OK) rc = wrc;
        uint16_t pg_idx = e->page_no / 8;
        e->fcb_addr->pad_refs[pg_idx] = NULL;
        memset(e, 0, sizeof(*e));
        e->page_addr = ctx->page_bufs[i];
    }

    ctx->num_ofpgs   = ctx->bas_npgs;
    ctx->comm.npages = (uint16_t)(SDF_PAD_SLOTS - ctx->bas_npgs);
    return rc;
}
