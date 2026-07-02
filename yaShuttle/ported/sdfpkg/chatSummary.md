```
You are continuing a long-running software engineering project to port the HAL/S Space Shuttle compiler's Symbol Data File (SDF) access package from IBM System/360 Basic Assembly Language (BAL) to C and Python, for integration into the Virtual AGC Project's modern HALSFC compiler port. The immediate goals are SDF creation in PASS3 of HALSFC and SDF importation in PASS1 of HALSFC.

## Background

The original BAL source files are: `SDFPKG.bal`, `LOCATE.bal`, `SELECT.bal`, `PAGMOD.bal`, `NDX2PTR.bal`, and the DSECT macros `DATABUF`, `FCBCELL`, `PDENTRY`, `PAGEZERO`, `DROOTCEL`, `BLCKNODE`, `BLKTCELL`, `SYMBNODE`, `SYMBDC`, `STMTDC`, `STMTNOD0`, `STMTNOD1`, `STMTEXTF`, `STMTEXTV`, `SYMEXTF`, `SYMEXTV`. The authoritative reference for SDF data structures is the SDFPKG Users Guide (1992), available at `https://www.ibiblio.org/apollo/Shuttle/SDFPKG-USERS-GUIDE-1992.pdf`.

## Output files

All files live in a flat directory. The complete set of deliverables is:

**C library:** `sdf_compat.h`, `sdf_types.h`, `sdf_internal.h`, `sdfpkg.h`, `sdf_write.h`, `sdf_util.c`, `sdf_io.c`, `sdf_locate.c`, `sdf_pagmod.c`, `sdf_select.c`, `sdfpkg.c`, `sdf_write.c`, `sdfcheck.c`, `sdf_convert.c`, `Makefile`

**Test suite:** `test_sdfpkg.c` (67 tests), `test_sdf_write.c` (93 tests)

**Python:** `sdfpkg.py`, `test_sdfpkg.py` (103 tests), `demo_sdfpkg.py`, `sdfpkg_dump.py`

**Sample data:** `make_sample_sdf.py`, `sample.sdf`, `NAVCOMP.hal`

## Flat file format

The sdfpkg flat file format (replacing the original z/OS PDS) is:

- 4 bytes: magic `0x53444600` ("SDF\0")
- 4 bytes: member count N (big-endian u32)
- N × 20 bytes: name(8, ASCII, space-padded) + page\_count(4, BE u32) + pg0\_offset(8, BE u64)
- Member data: N × page\_count × 1680 bytes

## Key design decisions

**Symbol ordering.** Symbols are sorted within each block alphabetically, then blocks are concatenated in block-name alphabetical order. This keeps `fsymb_no..lsymb_no` ranges contiguous and meaningful for each block's BLKTCELL entry.

**Virtual pointers.** A vptr is a 32-bit big-endian value: high 16 bits = page number, low 16 bits = byte offset within the 1680-byte page. Null pointer = 0.

**Bump allocator.** Write infrastructure uses a simple bump-pointer allocator starting at page 1 (page 0 is reserved for PAGEZERO + DROOTCEL). Structures never straddle page boundaries.

**Block tree.** The block name binary search tree (BLKTCELL) is built using the balanced median-split method over the sorted block array.

**Extent cells.** Symbol extent cells (SYMEXTF/V) and statement extent cells (STMTEXTF/V) record the page offsets of the first and last nodes on each page. The fst\_off/lst\_off values are byte offsets from the start of the page.

**STRUCTURE variables.** A STRUCTURE template occupies its own block with `blk_class = 3` (PROCEDURE). The template header symbol has `sym_class = 3` (SCLASS\_TEMPLATE), `sym_type = 10` (STYPE\_STRUCTURE), and `rows = own symb_no` (self-referential).

**STRUCTURE COPY.** When a STRUCTURE template COPYs another template's members, the template header symbol's SDC carries a STRCDATA block (2 bytes: `copy_blk_no`) appended after ARRADATA. The SDC's `struct_of` byte holds the byte offset to STRCDATA. `sdf_types.h` defines `sdf_strcdata_disk_t`; `sdf_wsymbol_t` / `WSymbol` expose `copy_blk_no` (0 = no COPY).

**ARRAY variables.** An array variable's SDC has `array_off != 0` pointing to an ARRADATA block (8 bytes: `ARRAYNUM(H) + RANGE1(H) + RANGE2(H) + RANGE3(H)`). In `sdf_wsymbol_t` and `WSymbol`, array dimensions are passed as `array_dims[4]` where `[0]` is the dimension count and `[1..3]` are the sizes.

**SDC fixed layout.** 24 bytes: `block_num(2) extd_off(1) xref_off(1) array_off(1) struct_of(1) sym_class(1) sym_type(1) flag1(1) flag2(1) flag3(1) flag4(1) symb_len(1) rel_addr(3) sblk_id(2) rows(1) columns(1) lock_num(1) byte_size(3)`, followed by name continuation, optionally ARRADATA (8 bytes) if `array_off != 0`, optionally STRCDATA (2 bytes) if `struct_of != 0`.

**Symbol classes.** `SCLASS_VARIABLE=1`, `SCLASS_EQUATE_EXT=2`, `SCLASS_TEMPLATE=3`, `SCLASS_LABEL=4` (NAME variables), `SCLASS_COMPOOL=6`. NAME variables use `sym_class=4` with `sym_type` = type of the referent.

**Symbol types.** `STYPE_SCALAR=1`, `STYPE_INTEGER=2`, `STYPE_BOOLEAN=3`, `STYPE_CHARACTER=4`, `STYPE_BIT=5`, `STYPE_VECTOR=6`, `STYPE_MATRIX=7`, `STYPE_EQUATE_EXT=8`, `STYPE_EVENT=9`, `STYPE_STRUCTURE=10`, `STYPE_TASK=11`. All types are fully supported in write and read paths.

**Block classes.** `BCLASS_PROGRAM=1`, `BCLASS_FUNCTION=2`, `BCLASS_PROCEDURE=3` (also used for STRUCTURE templates), `BCLASS_TASK=4`, `BCLASS_COMPOOL=5`, `BCLASS_CLOSE=6`. TASK blocks use `blk_class=4`; their entry-point symbol uses `sym_type=STYPE_TASK`.

**Cross-platform build.** The Makefile detects Linux, macOS, and MSYS2/MinGW. `sdf_compat.h` centralises all portability shims. `SDF_PACKED` maps to `__attribute__((packed))` on GCC/Clang and `#pragma pack` on MSVC.

## Bugs fixed during the project (cumulative)

- `name_cont` field in SDC is at offset 24, not 23.
- `do_symbol_fill()` must null-terminate `full_name` at `total_len` before stripping trailing spaces.
- Extent cell `fst_off`/`lst_off` are absolute byte offsets from the page start.
- `sdf_add_member()` must update existing members' `pg0_offset` fields in the index by +20 when inserting a new index entry.
- After a global alphabetical sort of symbols, the binary search extent cell's narrowed `hi` must be capped at `sav_lsymb`.
- The `d` variable in `SdfWriter.commit()`'s SDC write loop must be reassigned inside the loop.
- **Symbol sort order (sdf\_write.c / sdfpkg.py):** Symbols must be sorted block-first then alphabetically within each block, not globally. Block renumbering must happen before symbol sort. `cmp_symbol_name` compares `blk_no` first, then name.
- **`chk_match` class logic inverted (sdfpkg.c / sdfpkg.py):** Classes 1–3 are accepted unconditionally. Classes > 3 are accepted only when `flag1 & 0x03` has exactly one bit set (template header). Previously the flag check was applied to class ≤ 3 symbols, rejecting ordinary variables whenever NAME or EQUATE_EXT symbols were present.
- **Symbol binary search uses 8-char compare only (sdfpkg.c / sdfpkg.py):** BAL `BINSRCH` compares raw 8-char names for lo/hi adjustment; `CHKMATCH` is called only in `LINSRCH` after an 8-char match. The port was using `chk_match` for binary search direction, causing skip signals (return 0) to be misinterpreted as matches.
- **Extent cell false early-return (sdfpkg.c):** The `fst_symb` guard in extent cell narrowing returned NOT\_FOUND when the search key fell before the page's first symbol — which happens legitimately when searching a non-first block. Fix: track page symbol ranges numerically and use `lst_symb` only as an upper bound; clamp narrowed range to `[sav_fsymb, sav_lsymb]`.
- **`strlen` on non-null-terminated `srcharg8` (sdfpkg.c):** `chk_match` called `strlen` on an 8-char blank-padded field without a null terminator. Fix: use `ctx->comm.symbn_len` (set by `sdf_find_symbol_by_name` before the search) for the sought name length.
- **`sdf_find_symbol_by_name` did not set `symb_nam`/`symbn_len` (sdfpkg.c):** These must be populated before calling `symbol_binary_search` so `chk_match` has the full name available.

## Sample SDF (sample.sdf / NAVCOMP.hal)

`make_sample_sdf.py` uses `SdfWriter` (not hand-built binary) and produces a 4-block member: `BURN_TASK` (TASK, blk\_class=4), `EXT_SENSOR` (STRUCTURE template COPYing SENSOR\_DATA), `NAVCOMP` (PROGRAM), `SENSOR_DATA` (STRUCTURE template). NAVCOMP contains all supported types including NAME (ALT\_PTR), EQUATE\_EXT (EXT\_CONST), EVENT (LAUNCH\_ENABLE), ARRAY, and STRUCTURE instance. `NAVCOMP.hal` includes `DECLARE LAUNCH_ENABLE EVENT`.

## Test status

C: 67 read tests + 93 write tests = 160 passing, zero warnings. Python: 103 tests passing. `sdfcheck` reports GOOD on `sample.sdf`.
```
