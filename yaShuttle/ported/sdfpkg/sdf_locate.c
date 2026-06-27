/*
 * sdf_locate.c  --  Virtual memory pointer -> real address resolution.
 * Ports LOCATE.bal and NDX2PTR.bal.
 */
#define _POSIX_C_SOURCE 200809L
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "sdf_internal.h"

/* Find the PAD slot with the lowest use_count that is not reserved
 * and is not the one we just used. Returns NULL only on deadlock. */
static sdf_pad_entry_t *find_victim(sdf_ctx_t *ctx,
                                    sdf_pad_entry_t *exclude)
{
    sdf_pad_entry_t *victim  = NULL;
    uint32_t         min_use = UINT32_MAX;

    for (int i = 0; i < ctx->num_ofpgs; i++) {
        sdf_pad_entry_t *e = &ctx->pad[i];
        if (e == exclude)       continue;
        if (e->resv_count != 0) continue;
        if (e->fcb_addr == NULL)
            return e;                   /* prefer an empty slot */
        if (e->use_count <= min_use) {
            min_use = e->use_count;
            victim  = e;
        }
    }
    return victim;
}

sdf_rc_t sdf_locate_vptr(sdf_ctx_t *ctx, sdf_vptr_t vptr,
                          sdf_pad_entry_t **entry_out, void **addr_out)
{
    sdf_fcb_t *fcb = ctx->cur_fcb;
    if (!fcb)
        return SDF_ERR_NO_SELECT;

    uint16_t pg_num = SDF_VPTR_PAGE(vptr);
    uint16_t offset = SDF_VPTR_OFFSET(vptr);

    if (pg_num > fcb->lst_page)
        return SDF_ERR_BAD_PTR;
    if (offset >= SDF_PAGE_SIZE)
        return SDF_ERR_BAD_PTR;

    /* CR11165: 31-bit locate counter; reset + zero use_counts on overflow */
    ctx->loc_cnt++;
    if ((int32_t)ctx->loc_cnt <= 0) {
        ctx->loc_cnt = 1;
        for (int i = 0; i < ctx->num_ofpgs; i++)
            ctx->pad[i].use_count = 0;
    }

    sdf_pad_entry_t *target = fcb->pad_refs[pg_num];

    if (!target) {
        /* Page not in core: evict the vulnerable slot. */
        sdf_pad_entry_t *slot = ctx->avuln;

        sdf_rc_t rc = sdf_write_page(ctx, slot);
        if (rc != SDF_OK) return rc;

        /* Disconnect old occupant */
        if (slot->fcb_addr) {
            uint16_t old_pg = slot->page_no / 8;
            slot->fcb_addr->pad_refs[old_pg] = NULL;
        }

        rc = sdf_read_page(ctx, fcb, pg_num, slot);
        if (rc != SDF_OK) return rc;

        slot->fcb_addr = fcb;
        slot->page_no  = (uint16_t)(pg_num * 8);
        slot->modified = false;
        fcb->pad_refs[pg_num] = slot;
        target = slot;

        /* Find new vulnerable slot */
        sdf_pad_entry_t *new_avuln = find_victim(ctx, target);
        if (!new_avuln) return SDF_ERR_DEADLOCK;
        ctx->avuln = new_avuln;
    }

    target->use_count = ctx->loc_cnt;

    void *addr = (uint8_t *)target->page_addr + offset;
    ctx->cur_entry = target;
    ctx->comm.pntr = vptr;
    ctx->comm.addr = addr;

    if (entry_out) *entry_out = target;
    if (addr_out)  *addr_out  = addr;
    return SDF_OK;
}

sdf_rc_t sdf_ndx2ptr(sdf_ctx_t *ctx, int service, uint16_t index,
                     sdf_vptr_t *ptr_out)
{
    sdf_fcb_t *fcb = ctx->cur_fcb;
    if (!fcb) return SDF_ERR_NO_SELECT;

    sdf_vptr_t base_ptr;
    uint16_t   node_size;

    switch (service) {
    case 0: /* block nodes -- 12 bytes */
        if (index == 0 || index > fcb->num_blks)
            return SDF_ERR_BAD_BLOCK;
        base_ptr  = fcb->blk_ptr;
        node_size = 12;
        break;
    case 4: /* symbol nodes -- 12 bytes */
        if (index == 0 || index > fcb->num_symbs)
            return SDF_ERR_BAD_SYMB;
        base_ptr  = fcb->symb_ptr;
        node_size = 12;
        break;
    case 8: /* statement nodes -- 4 or 12 bytes */
        if (index < fcb->fst_stmt || index > fcb->lst_stmt)
            return SDF_STMT_OOB;
        base_ptr  = fcb->stmt_ptr;
        node_size = fcb->node_size;
        index     = (uint16_t)(index - fcb->fst_stmt + 1);
        break;
    default:
        return SDF_ERR_BAD_SVCCODE;
    }

    uint16_t base_page   = SDF_VPTR_PAGE(base_ptr);
    uint16_t base_offset = SDF_VPTR_OFFSET(base_ptr);
    uint32_t total       = (uint32_t)base_offset +
                           (uint32_t)(index - 1) * node_size;
    uint16_t new_page    = (uint16_t)(base_page + total / SDF_PAGE_SIZE);
    uint16_t new_offset  = (uint16_t)(total % SDF_PAGE_SIZE);

    *ptr_out = SDF_VPTR_MAKE(new_page, new_offset);
    return SDF_OK;
}
