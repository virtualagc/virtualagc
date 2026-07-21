# Multi-file HAL/S linking (Phase 3 finding)

Plan.md's Phase 3 called for discovering, documenting, and implementing
how `yaHALMAT2` should link multiple independently-compiled HALMAT files
into one running program, since — confirmed during Phase 2 research —
the real HAL/S-FC toolchain has **no HALMAT-level linking mechanism at
all**: only post-HALMAT AP-101S object code is linked (by a separate
linker, `lnk101`), and `COMMON0.out`→`COMMON5.out` is purely an
intra-unit pipeline state chain (PASS1→FLO→OPT→AUXP→PASS2→PASS3), never
a mechanism for combining two different `.hal` source files.

## The real mechanism: `EXTERNAL COMPOOL` block templates

HAL/S's actual cross-unit data sharing is source-level, via `COMPOOL`
blocks and their **templates** ([USA003087] §15.4): a template is a
byte-for-byte mirror of the real `COMPOOL`'s own declarations, with the
opening keyword changed to `EXTERNAL COMPOOL`:

```
real block (compiled separately, e.g. pool_out/):
  POOL:
  COMPOOL;
     DECLARE INTEGER, SHARED_X INITIAL(42);
  CLOSE POOL;

referencing unit (compiled separately, e.g. prog_out/):
  POOL:
  EXTERNAL COMPOOL;
     DECLARE INTEGER, SHARED_X INITIAL(42);      <- must textually mirror the real block
  CLOSE POOL;

  MAINPROG:
  PROGRAM;
     DECLARE INTEGER, Y;
     Y = SHARED_X + 1;
     WRITE(6) 'Y=', Y;
  CLOSE MAINPROG;
```

Compiled and run independently (`HALSFC pool.hal`, `HALSFC main.hal`),
each produces its own complete, self-contained `halmat.bin` + companion
files, with **independently 0-based `SYT`/literal-table numbering** —
confirming Plan.md's design note that these must never be naively
concatenated.

## Where the `EXTERNAL` flag actually lands (empirically confirmed)

**Not** on the individual shared variable. Compiling the example above
and reading both units' `COMMON0.out` symbol-table dumps directly shows
`SHARED_X`'s `SYM_FLAGS` are **identical** (`0x00804808`) in both the
real block and the referencing template — no distinguishing bit on the
variable itself.

The `EXTERNAL` flag (`SYM_FLAGS` bit `0x00100000`, matching
`unHALMAT.py`'s `symbolFlags` table) instead lands on the **COMPOOL
block's own name** (`POOL`) in the referencing unit's symbol table:
`POOL` → `0x00100040` (includes `0x00100000`) in the referencing unit,
vs. `0x00000040` (no `EXTERNAL` bit) for the real block's own name in
its own unit.

This makes linking a two-step, name-based match:
1. For each auxiliary unit, find its own `COMPOOL` header (`CDEF`,
   opcode `0x02F`) and the block name it declares.
2. Check whether the primary (executing `PROGRAM`, `MDEF`-headed) unit's
   own symbol table has an entry with that **same block name**, flagged
   `EXTERNAL`. If so, every other symbol name in the auxiliary unit's
   table (its actual declared variables) is matched by name against the
   primary's table and imported.

An `EXTERNAL`-flagged block name in the primary with no matching
auxiliary unit is treated as an unresolved external — a hard error at
startup, mirroring a normal linker, not a silent zero-default at
runtime.

## The templating mechanism is generic, not `COMPOOL`-specific

`--parms=TEMPLATE` isn't a `COMPOOL`-only feature: it works on any unit
kind. Compiling a plain `PROGRAM` with `--parms=TEMPLATE` (not otherwise
useful for linking, but tried for completeness) still produces a
`TEMPLIB/@@name` entry, and decoding it (EBCDIC) shows the same rewrite
rule already documented above for `COMPOOL`/`FUNCTION`/`PROCEDURE`:
the unit's own header keyword gets `EXTERNAL` prefixed, its body is
stripped to nothing:

```
TEST_PROG_TMPL: EXTERNAL PROGRAM; CLOSE;
```

So the rule is uniform across `CDEF`/`FDEF`/`PDEF`/`MDEF`-headed units:
`--parms=TEMPLATE` always emits `EXTERNAL <original keyword>` plus
(for `COMPOOL`) the mirrored declarations. This matters for scope
questions below — "is templating available for kind X" is never itself
a reason a linking feature is unsupported; the *executor's* handling of
that kind is the actual gate.

## Execution model: `COMPOOL` units don't need real concurrency

Compiling a real, standalone `COMPOOL` and inspecting its HALMAT
confirms it's a trivial, non-looping, non-branching, non-task-spawning
prologue: `CDEF` → (`IINT`/`SINT`-family init per `INITIAL(...)` value)
→ `EDCL` → `CLOS`. This means `yaHALMAT2` doesn't need per-unit
`VAC`/program-counter/scheduler plumbing to support linking — each
auxiliary unit can simply be run to completion, once, using the
same single-unit interpreter machinery used for a standalone program,
with its resulting `SYT` values harvested by name afterward and seeded
into the primary unit's matching `SYT` slots before the primary itself
runs normally.

## `EXTERNAL FUNCTION`/`PROCEDURE` (comsub) units: synchronous cross-unit calls

Unlike `COMPOOL`, a comsub-headed (`FDEF`/`PDEF`) auxiliary unit is *not*
run to completion once at link time — it's a callable entry point, kept
loaded persistently for the life of the run. `yaHALMAT2` gives each such
unit its own independent, heap-allocated interpreter state (own `SYT`,
literal table, PC, VAC — no sharing with the primary or with each other),
wired into the primary's `FCAL`/`PCAL` dispatch by the same by-name
`EXTERNAL`-flag match already used for `COMPOOL` blocks. A call from the
primary (or from another linked unit) runs that unit's own interpreter
loop synchronously to completion of exactly one call, then copies the
single return value (function form only) back into the caller's VAC slot.
State persists across repeated calls to the same unit — matching this
interpreter's existing same-unit call semantics, i.e. no "fresh locals per
call."

One symbol-table wrinkle specific to comsubs: `INCLUDE TEMPLATE NAME` on
a `PROCEDURE` referenced via `CALL` produces *two* symtab entries sharing
that name — an unused "template stub" (carrying the `EXTERNAL` flag) plus
a separate, actually-referenced call-site entry that does not carry the
flag. A naive first-match-by-name lookup picks the wrong one; `yaHALMAT2`
confirms `EXTERNAL`-ness via *any* matching-name entry, then wires the
call table against *every* entry sharing that name.

Validated end-to-end: `src/tests/hal/test_ext_mytable.hal` +
`test_ext_square.hal`/`test_ext_squroo.hal` (the `FUNCTION`/`FCAL` case)
and `test_ext_pcal_prog.hal` + `test_ext_double.hal` (the `PROCEDURE`/
`PCAL` case), both via `src/tests/run_ext_func_fixture.sh`.

## `yaHALMAT2` scope (current)

- One executing `PROGRAM` (`MDEF`-headed) unit, selected via `--entry
  <directory>` or auto-detected (exactly one `MDEF`-headed directory in
  the `@list`).
- Any number of `COMPOOL` (`CDEF`-headed) auxiliary units, run to
  completion once at link time (see above).
- Any number of `FUNCTION`/`PROCEDURE` (`FDEF`/`PDEF`-headed) auxiliary
  units, called synchronously at runtime (see above).
- `--opt` loads `optmat.bin` (+ its own companion convention:
  `litfile2.bin`, `COMMON2.out.bin[.gz]`, `COMMON3.out`) instead of
  `halmat.bin` for every unit in the list.

**Not yet supported** (explicit scope boundary, not silently wrong):
- Multiple concurrently-*executing* `PROGRAM` units sharing live,
  mutable `COMPOOL` state (each would need to observe the others'
  writes as they happen — full per-unit scheduler integration, not
  attempted yet). This also bounds the comsub support above: a linked
  `FUNCTION`/`PROCEDURE` unit is invoked synchronously to completion of
  one call and never itself `SCHEDULE`s a task that outlives that call.
- `ARRAY`/`MATRIX`-typed `EXTERNAL COMPOOL` variables (only plain
  `INTEGER`/`SCALAR` values are imported; safely transferring an element
  buffer's ownership across the auxiliary unit's cleanup needs more than
  a struct copy).
- A `PROGRAM`-headed (`MDEF`) auxiliary unit referenced as if callable.
  `--parms=TEMPLATE` will happily produce an `EXTERNAL PROGRAM` template
  for one (see above) — HALSFC's templating step doesn't know or care
  what the caller intends to do with it — but nothing in real HAL/S calls
  *into* another `PROGRAM`, and `yaHALMAT2` has no `MDEF`-as-callee path;
  an `MDEF`-headed non-primary unit is simply not matched by the
  `FCAL`/`PCAL` external-call wiring.

Validated end-to-end with `src/tests/hal/test_link_pool.hal` +
`test_link_prog.hal` (`src/tests/run_link_fixture.sh`): the linked run
produces `Y=43` (`SHARED_X`=42, imported from the separately-compiled
`COMPOOL`, `+1`), and omitting the `COMPOOL` unit from the `@list`
correctly fails with `unresolved external 'POOL'` rather than silently
defaulting `SHARED_X` to `0`.

## Linked-archive containers (`--link-only`): one self-contained file instead of a directory tree

`@list` is convenient for development (each line is just a HALSFC output
directory already sitting on disk) but awkward to *distribute*: shipping
a linked program means shipping N directories, each with its own
`halmat.bin`/`litfile0.bin`/`COMMON0.out`/`COMMON0.out.bin.gz` quartet.
`yaHALMAT2 --link-only FILENAME @list` instead builds a single,
self-contained, compressed container file from an `@list`, which can
later be run directly and positionally — `yaHALMAT2 FILENAME`, no `@`,
no directory tree — in place of either `@list` or a plain `HALMAT_FILE`.
The container is auto-detected by its own magic bytes, so no extra flag
is needed to run one.

### Why the container doesn't embed `COMMONn.out.bin.gz` verbatim

`COMMONn.out.bin.gz` (decompressed size capped by `HALMAT_MEM_IMAGE_MAX`
in `literal.c`, matching the reference `yaHALMAT` emulator's own
`HALMAT_MEM_SIZE`) is a **fixed 16 MB** image of AP-101S compiler memory,
of which `halmat_literal_load()` only ever reads small `(pointer,
length)` slices out — one per `CHARACTER` literal (`LIT_STRING`-typed
litfile entries). Measured this session against a 2-literal test fixture
(`WRITE(6) 'HELLO WORLD', 'A SECOND LONGER LITERAL STRING FOR TESTING';`):
only **~54 bytes total** were ever actually read out of that 16 MB
buffer — and the file is still **35 KB even gzip'd** on disk, because the
other 16 MB, minus a couple dozen bytes, is compiler-internal padding
irrelevant to running the program. Embedding it verbatim in a
"self-contained" container would make the container hundreds of times
larger than the `halmat.bin`/`litfile*.bin`/`COMMON*.out` data that
actually matters.

The container format therefore never stores the memory image. Instead,
at `--link-only` build time, every `CHARACTER` literal's text is resolved
once (the normal way, via the unit's own `COMMON*.out.bin.gz`) and only
the resulting already-EBCDIC-decoded strings are stored — see "byte
layout" below. `COMMONn.out` (the *other*, unrelated, plain-text
symbol-table report `symtab.c` parses) is not similarly wasteful — in the
same test fixture, ~91% of its lines were genuine per-symbol field
records `symtab.c` actually parses, scaling with the declared-symbol
count — so it's stored unfiltered, verbatim.

Measured real container sizes (`src/tests/run_link_container_fixture.sh`,
via `src/tests/run_all.sh`): the minimal single-unit `CHARACTER`-literal
round trip (`test_link_lit.hal`, exercising exactly the string-blob
mechanism above) produces a **26260-byte** container; the two-unit
`EXTERNAL COMPOOL` round trip (`test_link_pool.hal` + `test_link_prog.hal`)
**52712 bytes**; the three-unit `EXTERNAL FUNCTION` round trip
(`test_ext_mytable.hal` + `test_ext_square.hal` + `test_ext_squroo.hal`)
**79299 bytes** — all of them, even the 3-unit case with three separate
embedded `COMMON*.out` symbol tables, over two orders of magnitude
smaller than the one 16 MB memory image `--link-only` would otherwise
need to embed per unit.

### Byte layout

All multi-byte integers are big-endian, matching this codebase's existing
convention (e.g. `loader.c`'s `decode_word_be`):

```
bytes 0-3:   magic "YHLA" (4 raw ASCII bytes, no NUL)
byte  4:     format version = 1
bytes 5-12:  u64 BE -- uncompressed payload length
bytes 13-20: u64 BE -- compressed payload length
bytes 21..:  exactly <compressed payload length> bytes of zlib-deflated payload
```

The magic/version/lengths prefix is deliberately left uncompressed, so a
reader can identify and size-check the file (`halmat_container_sniff()`)
without decompressing anything. Compression is `zlib`'s one-shot
`compress2()`/`uncompress()` under `#ifdef HAVE_ZLIB` (this build's
existing convention -- see the `Makefile`'s zlib probe and `literal.c`'s
memory-image handling), falling back to piping through the `gzip` binary
via `popen`/`_popen` when zlib isn't available at build time.

Payload (after decompression), all integers big-endian:

```
u16 num_units
u16 primary_idx              -- index into the units array below; the executing PROGRAM unit
repeated num_units times, a "unit record":
    u16 label_len ; label_len bytes            -- unit label (originally the @list directory
                                                   string; diagnostics/disasm headers only, not
                                                   semantically used)
    u32 halmat_len ; halmat_len bytes           -- raw halmat.bin/optmat.bin file content,
                                                   VERBATIM (exact original file bytes)
    u8  have_lit (0 or 1)
    if have_lit:
        u32 litfile_len ; litfile_len bytes         -- raw litfile*.bin content, VERBATIM
                                                        (unchanged 1560-byte-record format)
        u32 string_blob_len ; string_blob_len bytes -- sequence of (u32 str_len BE; str_len
                                                        bytes), one entry per LIT_STRING-typed
                                                        cell in the unit's literal table (including
                                                        unused/placeholder cells -- the reader must
                                                        consume exactly one blob entry per such
                                                        cell, in the same order halmat_literal_load's
                                                        decode loop visits them, or its blob cursor
                                                        desyncs from the writer's). Each string is
                                                        the already-resolved, EBCDIC-decoded
                                                        CHARACTER text, taking the place of the
                                                        16MB memory image.
    u8  have_sym (0 or 1)
    if have_sym:
        u32 symtab_len ; symtab_len bytes           -- raw COMMON*.out text content, VERBATIM,
                                                        unfiltered
```

### Implementation

- `src/container.h`/`src/container.c`: the format itself --
  `halmat_container_write()` (writer, takes raw bytes directly, no
  dependency on `main.c`'s internal `unit_t`) and
  `halmat_container_sniff()`/`halmat_container_read()`/
  `halmat_container_free()` (reader).
- `src/loader.c` (`halmat_load_from_buffer`), `src/literal.c`
  (`halmat_literal_load_from_buffer`), and `src/symtab.c`
  (`halmat_symtab_load_from_buffer`) each grew a buffer-based sibling of
  their existing file-based loader, sharing the actual decode logic (not
  duplicating it) so a container-sourced unit is parsed by exactly the
  same code as a file-sourced one. The literal buffer-loader is the one
  case with a real behavioral difference from its file-based sibling: a
  `LIT_STRING` cell whose blob entry is missing or the blob is exhausted
  is a genuine container-corruption error and fails loudly via `errbuf`,
  unlike the file-based path's graceful degrade-to-blanks when no memory
  image is available at all.
- `src/main.c`: `run_linked()`'s original body was split into
  `find_primary_unit()` (resolve which `@list`/container unit is the
  executing `PROGRAM`) and `run_linked_units()` (the `EXTERNAL`
  COMPOOL/FUNCTION/PROCEDURE wiring + run, unchanged from before this
  split) so both the ordinary `@list` path and the new
  `run_linked_container()` path share that logic instead of duplicating
  it. `write_container()` implements `--link-only`: it loads every unit
  the ordinary way to resolve the primary and each unit's companion-file
  set, then independently re-reads each companion file's raw bytes off
  disk (the container needs the exact original bytes, not a
  re-serialization of the parsed structures).

### CLI usage

```
yaHALMAT2 --link-only OUT.yhla @list      # build a container from @list
yaHALMAT2 OUT.yhla                        # run it directly, no @ needed
```

`--link-only` requires an `@list` argument (not a plain `HALMAT_FILE`)
and is mutually exclusive with `--disasm`/`--debug`. Once built, a
container fixes everything `--opt`/`--py`/`--entry`/`--litfile`/
`--memory` would otherwise let you override per invocation (those
choices were baked in at `--link-only` build time), so passing any of
them alongside a container path is a usage error rather than silently
ignored. `--debug` is not supported for a container run, matching the
existing, pre-existing gap where `--debug` is already unsupported for a
plain `@list` run today.

Validated end-to-end (`src/tests/run_link_container_fixture.sh`, driven
from `src/tests/run_all.sh`): round-tripping both the `EXTERNAL COMPOOL`
fixture pair and the `EXTERNAL FUNCTION` fixture set above through
`--link-only` + a container run reproduces their original `@list`-run
output exactly, and the dedicated `test_link_lit.hal` fixture
(`WRITE(6) 'HELLO CONTAINER';`, a single `PROGRAM` unit with no
`EXTERNAL` linking at all) confirms the string-blob mechanism itself: it
fails or prints blank/wrong output if that plumbing is broken, so a
passing run is specific evidence the memory-image-avoidance fix works,
not just that linking survives round-tripping.
