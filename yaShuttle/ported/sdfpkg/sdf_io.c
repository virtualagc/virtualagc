/*
 * sdf_io.c  --  Shared low-level I/O: write_page / read_page.
 *
 * These were duplicated as static functions in sdf_locate.c,
 * sdf_pagmod.c, and sdf_select.c.  Centralised here to avoid
 * multiple-definition problems.
 */

#define _POSIX_C_SOURCE 200809L   /* fseeko / off_t on Linux */
#include <stdio.h>
#include "sdf_internal.h"

sdf_rc_t sdf_write_page(sdf_ctx_t *ctx, sdf_pad_entry_t *e)
{
    if (!e->fcb_addr || !e->modified)
        return SDF_OK;
    uint16_t   pg_idx  = e->page_no / 8;
    sdf_fcb_t *fcb     = e->fcb_addr;
    off_t      offset  = fcb->page_offsets[pg_idx];
    if (fseeko(ctx->fp, offset, SEEK_SET) != 0)
        return SDF_ERR_OPEN_FAIL;
    if (fwrite(e->page_addr, SDF_PAGE_SIZE, 1, ctx->fp) != 1)
        return SDF_ERR_OPEN_FAIL;
    ctx->writes++;
    e->modified = false;
    return SDF_OK;
}

sdf_rc_t sdf_read_page(sdf_ctx_t *ctx, sdf_fcb_t *fcb,
                        uint16_t pg_num, sdf_pad_entry_t *e)
{
    off_t offset = fcb->page_offsets[pg_num];
    if (fseeko(ctx->fp, offset, SEEK_SET) != 0)
        return SDF_ERR_OPEN_FAIL;
    if (fread(e->page_addr, SDF_PAGE_SIZE, 1, ctx->fp) != 1)
        return SDF_ERR_OPEN_FAIL;
    ctx->reads++;
    return SDF_OK;
}
