#ifndef HALMAT_SYMTAB_H
#define HALMAT_SYMTAB_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Parses a compiler-produced COMMON*.out symbol-table text report
 * (tab-separated "/  SYMuTAB  N  BASED  ..." record headers, ".  SYM_NAME"
 * / ".  SYM_FLAGS" field lines -- see reengineered-documentation and
 * this project's own research notes) into a simple index->{name,flags}
 * table. Used for M6's multi-file linking: matching EXTERNAL-flagged
 * symbols (SYM_FLAGS bit 0x00100000, confirmed against unHALMAT.py's
 * symbolFlags table) by name across independently-compiled units. */

#define HALMAT_SYM_FLAG_EXTERNAL 0x00100000u

typedef struct {
    size_t index; /* SYT slot within its own unit */
    char *name;   /* may be empty ("") for anonymous/reserved slots */
    uint32_t flags;
} halmat_symtab_entry_t;

typedef struct {
    halmat_symtab_entry_t *entries;
    size_t count;
} halmat_symtab_t;

bool halmat_symtab_load(const char *path, halmat_symtab_t *out, char *errbuf, size_t errbuf_size);
void halmat_symtab_free(halmat_symtab_t *table);

/* Case-sensitive name lookup (HAL/S identifiers are compiled upper-case).
 * Returns NULL if not found or name is empty. */
const halmat_symtab_entry_t *halmat_symtab_find(const halmat_symtab_t *table, const char *name);

#endif
