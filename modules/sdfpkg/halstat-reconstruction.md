# Reconstructing HALSTAT

HALSTAT 8.1 is a general-purpose tool for reporting on an already-compiled HAL/S
program — a Global Cross-Reference of every symbol across a build, plus
top-level memory maps.  It is an XPL/I program, so in principle XCOM-I can
compile it, and `MISCELLANEOUS/README.md` says as much.  It cannot presently be
built, but the obstacle is not the one that README gives.

Everything below is measured against
`yaShuttle/Source Code/MISCELLANEOUS/HALSTAT.xpl` (7651 lines), which is
untouched.  Experiments live in `MISCELLANEOUS/HALSTAT2.xpl`, a copy whose eight
`$%NAME` include directives are neutralised to `@%NAME` **in place** — so every
line keeps its shape and its columns 73–80 sequence number — plus a marked
`/*@ */` block of stand-ins for the STND include.

## The blocker is eight missing includes, not the unported passes

`MISCELLANEOUS/README.md` says HALSTAT's utility is limited because "passes 3
and 4 have not yet been ported into the modern world".  That is now obsolete —
PASS3 works and PASS4 runs — and it never was the real blocker.  The real one is
that all eight of HALSTAT's includes are absent from the entire repository:

    VMEM1X  VMEM2X  VMEM3X  VMEM4X  STND  CONV  TRACE  EXPAND

That README is worth correcting.

## Two card-image traps

Both of these cost time, and neither is obvious.

XCOM-I resolves `$%` includes relative to the **source file's** directory, not
the current one.  Putting a build directory under `PASS.REL32V0` therefore does
*not* make `../HALINCL` resolve for a source that lives in `MISCELLANEOUS`.

Code occupies columns 1–72 only.  An 80-column stub line silently loses its
tail: a one-line `LPAD:` stub had its closing `;` chopped, turning `END LPAD;`
into `END LPAD` and merging it with the next procedure.  Any inserted line must
fit in 72 columns — and must not itself contain the characters `$%`, or XCOM-I
reads it as a directive, which is how a *comment* describing the STND include
became an attempt to include STND.

Relatedly: inserting stubs by splitting an existing comment open leaves that
line's sequence number standing as code, where it attaches itself to whatever
statement follows.  That produced a spurious "Unimplemented" report against a
perfectly ordinary `DECLARE`, and cost a detour into a non-existent `FIXED`
problem.  Insert whole lines instead.

## STND is essentially solved, and small

Iteratively stubbing whatever XCOM-I reported missing yields exactly:

| missing | kind | counterpart already in the tree |
|---|---|---|
| `TRUE`, `FALSE` | `LITERALLY '1'` / `'0'` | ubiquitous |
| `FOREVER` | `LITERALLY 'WHILE 1'` | `PASS4.PROCS/##DRIVER.xpl:240` |
| `LPAD(s,n)` | procedure | `PASS4.PROCS/LEFTPAD.xpl` (`LEFT_PAD`) |
| `CHAR_TIME(t)` | procedure | `PASS4.PROCS/CHARTIME.xpl` (`CHARTIME`) |
| `CHAR_DATE(d)` | procedure | `PASS4.PROCS/CHARDATE.xpl` (`CHARDATE`) |
| `MOVE(len,from,into)` | procedure | `PASS4.PROCS/MOVE.xpl` |

Every one has a working counterpart in `PASS.REL32V0/PASS4.PROCS/`, and `MOVE`'s
`(LEGNTH,FROM,INTO)` signature matched on the first attempt.  Reconstructing
STND from those is a small, low-risk job.

`CONV`, `TRACE` and `EXPAND` produce **no** unresolved references at all once
STND is stubbed.  HALSTAT may simply not use them, in which case they can be
dropped rather than reconstructed — though that wants confirming once VMEM is
dealt with, since later errors could still be hiding behind it.

## VMEM1X–4X is the real work

XCOM-I reports one missing name per run, so the discovery is serial; with STND
stubbed, the only remaining error is `PROCEDURE VMEM_LOCATE_PTR not found`.

HALSTAT references 39 `VMEM_`-prefixed names.  Searching all of `HALINCL` and
the `*.PROCS` directories, **9 are already present** — and they are precisely
the low-level paging vocabulary:

| name | where |
|---|---|
| `VMEM_LOC_PTR`, `VMEM_LOC_ADDR` | `VMEM2` — the locate result pair |
| `VMEM_PAD_ADDR`, `VMEM_PAD_CNT`, `VMEM_PAD_DISP` | `VMEM2` — page-area directory |
| `VMEM_PAGE_SIZE`, `VMEM_LIM_PAGES` | `VMEM1` |
| `VMEM_NDX` | `COMMON.xpl`, a `VMEMREC` field |
| `VMEM_H` | `##DRIVER`, `DUMPSDF` |

The 30 that are absent read as a *generalisation* of the compiler's package
rather than an unrelated one, and the mapping is legible from `VMEM1.xpl` and
`VMEM2.xpl`:

| compiler (one file) | HALSTAT (many files) |
|---|---|
| `VMEM_FILE# LITERALLY '6'` | `VMEM_MAX_FILES`, `VMEM_OPEN_FILE/4`, `VMEM_CLOSE_FILE/2` |
| `VMEM_LOC_CNT` | `VMEM_FILE_LOCATE_CNT` |
| `VMEM_READ_CNT` | `VMEM_FILE_READ_CNT` |
| `VMEM_WRITE_CNT` | `VMEM_FILE_WRITE_CNT` |
| `VMEM_TOTAL_PAGES` | `VMEM_PAGE_LIMIT`, `VMEM_FILE_LAST_PAGE(1)` |
| `VMEM_LIM_PAGES` | `VMEM_MAX_PAD`, `VMEM_MAX_PTR_CNT` |

Above that sit two layers with no compiler counterpart at all: sequential access
(`VMEM_SEQ_OPEN/5`, `VMEM_SEQ_CLOSE/1`, `VMEM_SEQ_LOC_ADDR`,
`VMEM_SEQ_LOC_COPY`) and sorted structures holding several copies per key
(`VMEM_ALLOC_STRUC(7)`, `VMEM_SORT_STRUC/6`, `VMEM_FIX_STRUC/2`,
`VMEM_GET_STRUC_COPIES(2)`, `VMEM_NEXT_COPY/2`).  That is exactly what a global
cross-reference over a whole build needs and exactly what a single-file compiler
VMEM does not provide.

So the practical reading is that `VMEM1X` and `VMEM2X` are very likely `VMEM1`
and `VMEM2` *extended* — the declaration half is a decent prospect, the shared
names being just the sort of thing those two files hold — while `VMEM3X` and
`VMEM4X`, the routines, are the part with nothing to build on.  Anyone resuming
should start by diffing HALSTAT's usage against `VMEM1`/`VMEM2` declaration by
declaration rather than treating the X group as a black box.

### Full inventory, classified by use

CALLed procedures, with arity: `VMEM_OPEN_FILE/4`, `VMEM_CLOSE_FILE/2`,
`VMEM_SEQ_OPEN/5`, `VMEM_SEQ_CLOSE/1`, `VMEM_LOCATE_PTR/3`,
`VMEM_LOCATE_COPY/0`, `VMEM_NEXT_COPY/2`, `VMEM_SORT_STRUC/6`,
`VMEM_FIX_STRUC/2`, `VMEM_DISP/1`.

Function or subscript style: `VMEM_ALLOC_STRUC(7)`, `VMEM_ALLOC_CELL(3)`,
`VMEM_GET_STRUC_COPIES(2)`, `VMEM_F(1)`, `VMEM_H(1)`, `VMEM_PAD_ADDR(1)`,
`VMEM_PAD_DISP(1)`, `VMEM_FILE_LAST_PAGE(1)`.

Data and macros: `VMEM_MAX_FILES`, `VMEM_MAX_PAD`, `VMEM_MAX_PTR_CNT`,
`VMEM_MAX_CELLSIZE1`, `VMEM_MAX_CELLSIZE2`, `VMEM_PAGE_SIZE`,
`VMEM_PAGE_LIMIT`, `VMEM_LIM_PAGES`, `VMEM_BUFF_ADDR1`, `VMEM_BUFF_ADDR2`,
`VMEM_LOC_ADDR`, `VMEM_LOC_PTR`, `VMEM_NDX`, `VMEM_PAD_CNT`,
`VMEM_PAD_PAGEID`, `VMEM_NEW`, `VMEM_SAVE`, `VMEM_SEQ_LOC_ADDR`,
`VMEM_SEQ_LOC_COPY`, `VMEM_FILE_READ_CNT`, `VMEM_FILE_WRITE_CNT`,
`VMEM_FILE_LOCATE_CNT`.

HALSTAT declares `VMEM_LIM_PAGES` and `VMEM_PAGE_LIMIT` itself, just above the
`VMEM1X` directive, so those two are not owed by the include.

## There is no `FIXED` problem

Recorded because it was chased for a while and is a dead end.  HALSTAT is
XPL/I, where `FIXED` is a 32-bit integer, used 157 times in the file and handled
throughout by XCOM-I.  Tested in isolation, XCOM-I accepts every form involved —
`DECLARE A(1) FIXED;`, `DECLARE B FIXED INITIAL(100000);`, and both orders of
the two combined.  HAL/S's `FIXED`, the scaled fixed-point type of chapter 14 of
*Programming in HAL/S*, is a different language's datatype, and is annotated
there as "HAL/S-FC does not support the FIXED datatype.  Use SCALAR instead."
Nothing needs faking with `SCALAR`.

## HALSTAT would exercise DATABUF far harder than PASS4 does

HALSTAT reads SDFPKG's DATABUF too, and its field map at `HALSTAT.xpl:661-687`
is the fullest available — it is where `XCOM-I/sdfpkg.c`'s `DB_*` offsets came
from.  PASS4 touches only `LOCCNT`, `TOTFCBLN`, `NUMGETM`, `NUMOFPGS`, `READS`
and `SLECTCNT`.  HALSTAT additionally uses `AVULN`, `CURFCB`, `PADADDR`,
`ACOMMTAB`, `ACURNTRY`, `ROOT`, `SAVEXTPT`, `SAVFSYMB`, `SAVLSYMB`, `BASNPGS`,
`FCBSTKLN`, `IOFLAG`, `GETMFLAG`, `GOFLAG`, `MODFLAG`, `ONEFCB`, `FIRST`,
`RESERVES`, `WRITES`, `FCBCNT` and `VERSION`.  Several of those the C currently
leaves at zero.  It also gates structure decisions on `IF VERSION >= 25`, which
is why the C sets `DB_VERSION` from the selected SDF's Phase 3 version at select
time rather than to a constant.

Whenever HALSTAT can be built, it will be a much better test of DATABUF than
SDFLIST is.

## SDFLIST, for the avoidance of doubt

SDFLIST is not a separate program and needs no build of its own.
`TOOLS.COMPILER.CLIST/SDFLIST` runs
`PROGRAM(NCAMCM.&SYSTEM..&COMPVER..PASS4.OBJ)` with
`CALL '&MONITOR.' 'TABLST,P=&PG.'` and the SDF name written to SYSIN — that is,
`HALSFC-PASS4` standalone.  See `sdfpkg-rationale.md` for the modern equivalent.
