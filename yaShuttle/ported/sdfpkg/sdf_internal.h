/*
 * sdf_internal.h  --  Private context structure and helpers shared
 *                     across sdf_locate.c, sdf_select.c, sdfpkg.c, etc.
 *
 * NOT part of the public API.  Do not include from user code.
 */

#ifndef SDF_INTERNAL_H
#define SDF_INTERNAL_H

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/types.h>
#include "sdf_types.h"
#include "sdfpkg.h"

/* ------------------------------------------------------------------ */
/* Endian helpers (SDF on-disk data is big-endian S/360)              */
/* ------------------------------------------------------------------ */

static inline uint16_t sdf_be16(const void *p) {
    const uint8_t *b = (const uint8_t *)p;
    return (uint16_t)((b[0] << 8) | b[1]);
}

static inline uint32_t sdf_be32(const void *p) {
    const uint8_t *b = (const uint8_t *)p;
    return ((uint32_t)b[0] << 24) | ((uint32_t)b[1] << 16) |
           ((uint32_t)b[2] <<  8) |  (uint32_t)b[3];
}

static inline void sdf_put_be16(void *p, uint16_t v) {
    uint8_t *b = (uint8_t *)p;
    b[0] = (v >> 8) & 0xFF;
    b[1] =  v       & 0xFF;
}

static inline void sdf_put_be32(void *p, uint32_t v) {
    uint8_t *b = (uint8_t *)p;
    b[0] = (v >> 24) & 0xFF;
    b[1] = (v >> 16) & 0xFF;
    b[2] = (v >>  8) & 0xFF;
    b[3] =  v        & 0xFF;
}

/* ------------------------------------------------------------------ */
/* Memory allocation stacks                                            */
/*                                                                     */
/* The original used parallel arrays (GETMSTK1/GETMSTK2) of up to    */
/* SDF_MAX_STACK address/length pairs so all malloc'd regions could   */
/* be freed in bulk at TERM time.                                      */
/* ------------------------------------------------------------------ */

typedef struct {
    void    *addr[SDF_MAX_STACK];
    size_t   len[SDF_MAX_STACK];
    int      count;
} sdf_memstack_t;

/* ------------------------------------------------------------------ */
/* Internal context  (sdf_ctx_t)                                       */
/* ------------------------------------------------------------------ */

struct sdf_ctx {
    /* ---- File I/O ------------------------------------------------ */
    FILE        *fp;            /* open SDF file                      */
    bool         update_mode;   /* opened for read/write              */

    /* ---- Global state (mirrors DATABUF / LOCATE's COMMDATA area) - */
    uint32_t     loc_cnt;       /* locate counter (CR11165: 31-bit)   */
    sdf_pad_entry_t *avuln;     /* ptr to current "vulnerable" PAD slot*/
    sdf_fcb_t   *cur_fcb;       /* currently selected FCB             */
    sdf_pad_entry_t *cur_entry; /* PAD entry of last locate           */
    sdf_fcb_t   *root_fcb;      /* root of FCB binary tree            */
    sdf_vptr_t   save_extpt;    /* ptr to symbol node extent cell     */
    uint16_t     sav_fsymb;     /* first symbol of current block      */
    uint16_t     sav_lsymb;     /* last symbol of current block       */
    uint16_t     num_ofpgs;     /* current paging area page count     */
    uint16_t     bas_npgs;      /* base (initial) page count          */
    bool         io_flag;       /* I/O in progress                    */
    bool         getm_flag;     /* auto-malloc for FCBs enabled       */
    bool         go_flag;       /* successfully initialized           */
    bool         mod_flag;      /* update mode active                 */
    bool         one_fcb;       /* keep only one FCB                  */
    bool         first_sym;     /* take first matching symbol         */

    /* ---- Statistics ---------------------------------------------- */
    uint32_t     total_fcb_len; /* total FCB bytes in use             */
    uint32_t     reserves;      /* global reserve count               */
    uint32_t     reads;         /* total pages read from disk         */
    uint32_t     writes;        /* total pages written to disk        */
    uint32_t     select_cnt;    /* total SELECT calls                 */
    uint32_t     fcb_cnt;       /* number of FCBs allocated           */

    /* ---- Memory management stacks -------------------------------- */
    sdf_memstack_t malloc_stack; /* all malloc'd regions (free at term)*/
    sdf_memstack_t fcb_stack;    /* FCB area stacks                   */

    /* ---- Paging area --------------------------------------------- */
    sdf_pad_entry_t *pad;       /* array of PAD entries               */
    int              pad_cap;   /* allocated capacity of pad[]        */
    uint8_t        (*page_bufs)[SDF_PAGE_SIZE]; /* the actual buffers */
    /* page_bufs[i] is the 1680-byte buffer for pad[i] */

    /* ---- Communication area (caller I/O) ------------------------- */
    sdf_commtabl_t  comm;       /* mirrors COMMTABL; set by caller,   */
                                /* updated on return                  */

    /* ---- SDFPKG local state ------------------------------------- */
    sdf_vptr_t      sav_ptr;    /* saved pointer for mode 5           */
    uint8_t         mode;       /* current service code               */
    sdf_vptr_t      init_ptr;   /* CR13079 initial data ptr           */
};

/* ------------------------------------------------------------------ */
/* Internal function prototypes (implemented in separate .c files)     */
/* ------------------------------------------------------------------ */

/* sdf_io.c */
sdf_rc_t sdf_write_page(sdf_ctx_t *ctx, sdf_pad_entry_t *e);
sdf_rc_t sdf_read_page(sdf_ctx_t *ctx, sdf_fcb_t *fcb,
                        uint16_t pg_num, sdf_pad_entry_t *e);

/* sdf_locate.c */
sdf_rc_t sdf_locate_vptr(sdf_ctx_t *ctx, sdf_vptr_t vptr,
                          sdf_pad_entry_t **entry_out, void **addr_out);
sdf_rc_t sdf_ndx2ptr(sdf_ctx_t *ctx, int service, uint16_t index,
                     sdf_vptr_t *ptr_out);

/* sdf_select.c */
sdf_rc_t sdf_do_select(sdf_ctx_t *ctx);

/* sdf_pagmod.c */
sdf_rc_t sdf_pagmod_init(sdf_ctx_t *ctx);
sdf_rc_t sdf_pagmod_term(sdf_ctx_t *ctx);
sdf_rc_t sdf_pagmod_augment(sdf_ctx_t *ctx);
sdf_rc_t sdf_pagmod_rescind(sdf_ctx_t *ctx);

/* sdf_util.c */
void sdf_str_to_field(const char *src, char *dst, size_t field_len);
void sdf_field_to_str(const char *src, size_t field_len, char *dst);
int  sdf_push_malloc(sdf_memstack_t *stack, void *addr, size_t len);
void sdf_free_stack(sdf_memstack_t *stack);

/* Internal set-disposition logic (used at exit of each service) */
sdf_rc_t sdf_set_disps(sdf_ctx_t *ctx, int disp_flags);

#endif /* SDF_INTERNAL_H */
