/* Linker symbol table (.sym.json / .symtypes.json), ported from
 * gpc/symbolTable.coffee. `sectionColors`/`getSectionColor` (GUI memory-
 * pane coloring) are omitted — never observable in `run`'s output, same
 * rationale as mcm.h/regmem.h's GUI-only omissions.
 *
 * `getSectionAt` is implemented via binary search over sorted sections
 * instead of JS's precomputed per-halfword `addrToSection` hash — same
 * observable answer for any address, without the O(total section size)
 * memory blowup of eagerly materializing every offset. */
#ifndef YAGPC_SYMBOLTABLE_H
#define YAGPC_SYMBOLTABLE_H

#include <stdbool.h>
#include <stdint.h>

typedef struct {
    uint32_t address;
    char *name;
} Symbol;

typedef struct {
    char *name;
    uint32_t address;
    uint32_t size;
    char *module; /* source module name; used by run()'s SECTION MAP and disasm's section headers */
} Section;

typedef struct {
    uint32_t address;
    char *symbol;
} Reloc;

typedef struct {
    char *type; /* e.g. "ascii", "fw", "int32", "float", "dfloat", "ebcdic" */
    int size;   /* displaySize; -1 if absent in the JSON */
} SymType;

typedef struct {
    char *name;
    SymType st;
} SymTypeEntry;

typedef struct {
    bool hasEntryPoint;
    uint32_t entryPoint;

    Symbol *symbols;
    int symbolCount;

    Section *sections; /* sorted by address */
    int sectionCount;

    Reloc *relocs;
    int relocCount;

    SymTypeEntry *symTypes;
    int symTypeCount;

    bool loaded;
} SymbolTable;

void symtable_init(SymbolTable *st);
void symtable_free(SymbolTable *st);

/* Ported from SymbolTable#load: reads+parses symPath, then (best-effort)
 * the sibling .symtypes.json. Returns true and sets *entryPointOut if the
 * symbols JSON has a numeric `entryPoint`; returns false (entryPoint
 * untouched) on any load/parse failure, after printing
 * "SymbolTable: Could not load symbols: <message>\n" to stderr (message
 * text is a close approximation of Node's fs/JSON error strings, not a
 * byte-exact replication — see symboltable.c). When verbose is true and
 * loading succeeds, prints the same diagnostic lines gpc/symbolTable.coffee
 * does to stderr. */
bool symtable_load(SymbolTable *st, const char *symPath, bool verbose, uint32_t *entryPointOut);

/* Returns NULL if none. */
const Symbol *symtable_get_label_at(const SymbolTable *st, uint32_t addr); /* first symbol at addr, or NULL */
const char *symtable_get_section_at(const SymbolTable *st, uint32_t addr); /* section name, or NULL */
/* Which HAL/S (or other) compiled unit's own object code addr belongs
 * to -- used by debugger.c to dispatch a multi-unit HAL/S source map
 * (see sourcemap.h) to the right compile's own statement numbering,
 * since a linked image is in general the result of linking many
 * separately-compiled units and statement numbers are only unique
 * within one. */
const char *symtable_get_module_at(const SymbolTable *st, uint32_t addr); /* module name, or NULL */
const char *symtable_get_reloc_at(const SymbolTable *st, uint32_t instrAddr, int instrLen);

/* Writes into out[16] (8 chars name, '+', 5 hex digits, NUL — matches
 * "NNNNNNNN+HHHHH" / "        +     " for no-section). */
void symtable_format_csect(const SymbolTable *st, uint32_t addr, char *out, int outLen);

/* NULL if no override for `name` exists in .symtypes.json. */
const SymType *symtable_get_symtype(const SymbolTable *st, const char *name);

/* Symbol display size in halfwords, matching SymbolTable#getSymbolSize. */
int symtable_get_symbol_size(const SymbolTable *st, const Symbol *sym, const char *displayType, int displaySize);

#endif
