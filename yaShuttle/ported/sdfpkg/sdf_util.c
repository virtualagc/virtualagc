#define _POSIX_C_SOURCE 200809L
/*
 * sdf_util.c  --  Utility helpers for the SDF package.
 *
 * Covers:
 *   - Fixed-length blank-padded field  <->  C string conversion
 *   - Memory allocation tracking stack (for bulk-free at TERM time)
 *   - Error string table
 *   - set_disps: apply MODF / RELS / RESV disposition flags
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "sdf_internal.h"

/* ------------------------------------------------------------------ */
/* String / field helpers                                              */
/* ------------------------------------------------------------------ */

/*
 * sdf_str_to_field()
 *
 * Copy a null-terminated C string into a blank-padded fixed-width
 * field (no null terminator in the destination).  Truncates if the
 * source is longer than field_len.
 */
void sdf_str_to_field(const char *src, char *dst, size_t field_len)
{
    size_t n = strlen(src);
    if (n > field_len)
        n = field_len;
    memcpy(dst, src, n);
    if (n < field_len)
        memset(dst + n, ' ', field_len - n);
}

/*
 * sdf_field_to_str()
 *
 * Convert a blank-padded (possibly not null-terminated) fixed-width
 * field to a null-terminated C string.  Trailing spaces are stripped.
 * `dst` must have room for at least field_len + 1 bytes.
 */
void sdf_field_to_str(const char *src, size_t field_len, char *dst)
{
    /* Start from the end and scan backward past blanks */
    size_t len = field_len;
    while (len > 0 && src[len - 1] == ' ')
        --len;
    memcpy(dst, src, len);
    dst[len] = '\0';
}

/* ------------------------------------------------------------------ */
/* Memory tracking stack                                               */
/* ------------------------------------------------------------------ */

/*
 * sdf_push_malloc()
 *
 * Record a malloc'd region on the stack so it can be freed en masse
 * at termination.  Returns 0 on success, -1 if the stack is full.
 */
int sdf_push_malloc(sdf_memstack_t *stack, void *addr, size_t len)
{
    if (stack->count >= SDF_MAX_STACK)
        return -1;
    stack->addr[stack->count] = addr;
    stack->len[stack->count]  = len;
    stack->count++;
    return 0;
}

/*
 * sdf_free_stack()
 *
 * Free all regions recorded on the stack and reset it.
 */
void sdf_free_stack(sdf_memstack_t *stack)
{
    for (int i = 0; i < stack->count; i++) {
        free(stack->addr[i]);
        stack->addr[i] = NULL;
    }
    stack->count = 0;
}

/* ------------------------------------------------------------------ */
/* Disposition parameter application  (SETDISPS in SDFPKG.bal)        */
/*                                                                     */
/* Called after each successful lookup.  Applies MODF / RELS / RESV  */
/* flags to the PAD entry of the most recently located page.          */
/* ------------------------------------------------------------------ */

sdf_rc_t sdf_set_disps(sdf_ctx_t *ctx, int disp_flags)
{
    if (disp_flags == SDF_DISP_NONE)
        return SDF_OK;

    sdf_pad_entry_t *e = ctx->cur_entry;
    if (!e)
        return SDF_ERR_NO_CURENTRY;

    /* MODF: mark page as modified (dirty) */
    if (disp_flags & SDF_DISP_MODF) {
        if (!ctx->mod_flag)
            return SDF_ERR_MODF_MODE;  /* update mode required */
        e->modified = true;
    }

    /* RELS: release a previous reserve */
    if (disp_flags & SDF_DISP_RELS) {
        if (e->resv_count == 0)
            return SDF_ERR_RELEASE_OVF;
        e->resv_count--;
        if (ctx->reserves > 0)
            ctx->reserves--;
    }

    /* RESV: reserve (pin) the page */
    if (disp_flags & SDF_DISP_RESV) {
        if (e->resv_count == 0x7FFF)
            return SDF_ERR_RESERVE_OVF;
        e->resv_count++;
        ctx->reserves++;
    }

    return SDF_OK;
}

/* ------------------------------------------------------------------ */
/* Error string table                                                   */
/* ------------------------------------------------------------------ */

const char *sdf_strerror(sdf_rc_t rc)
{
    switch (rc) {
    case SDF_OK:               return "success";
    case SDF_NOT_FOUND:        return "block not found";
    case SDF_SYM_NOT_FOUND:    return "symbol not found";
    case SDF_NOT_EXEC:         return "statement found but not executable";
    case SDF_NO_SRNS:          return "file has no SRNs";
    case SDF_SRNS_NONMONO:     return "SRNs are not monotonic";
    case SDF_STMT_OOB:         return "statement number out of range";

    case SDF_ERR_DEADLOCK:     return "paging area deadlocked (U4001)";
    case SDF_ERR_OPEN_FAIL:    return "file open / I/O failure (U4002)";
    case SDF_ERR_RESERVE_OVF:  return "too many reserves for one page (U4003)";
    case SDF_ERR_RELEASE_OVF:  return "too many releases for one page (U4004)";
    case SDF_ERR_BAD_PTR:      return "bad virtual pointer (U4005)";
    case SDF_ERR_BAD_BLOCK:    return "bad block index (U4006)";
    case SDF_ERR_BAD_SYMB:     return "bad symbol index (U4007)";
    case SDF_ERR_MODF_MODE:    return "MODF requires update mode (U4008)";
    case SDF_ERR_NOT_INIT:     return "called before init (U4009)";
    case SDF_ERR_NO_SELECT:    return "no SDF member currently selected (U4010)";
    case SDF_ERR_RESCIND_RSV:  return "rescind with reserved pages (U4011)";
    case SDF_ERR_RESCIND_NA:   return "rescind without external area (U4012)";
    case SDF_ERR_BAD_PGAREA:   return "bad paging area specification (U4013)";
    case SDF_ERR_NO_CURENTRY:  return "set-disps before any locate (U4014)";
    case SDF_ERR_BAD_FCBAREA:  return "bad FCB area specification (U4015)";
    case SDF_ERR_BAD_SVCCODE:  return "bad service code (U4016)";
    case SDF_ERR_MULTI_INIT:   return "multiple INIT calls (U4017)";
    case SDF_ERR_FCB_OOM:      return "FCB area exhausted (U4018)";
    case SDF_ERR_GETMAIN:      return "memory allocation failure (U4019)";
    case SDF_ERR_BLK_NOSPEC:   return "block not previously specified (U4020)";
    case SDF_ERR_STACK_OVF:    return "internal stack exhausted (U4021)";
    case SDF_ERR_SEL_RESERVED: return "select while pages reserved (U4022)";
    case SDF_ERR_LEN_MISMATCH: return "SDF length mismatch (U4023)";
    default:                   return "unknown SDF error";
    }
}
