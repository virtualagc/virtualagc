# Findings from the HAL_S_FC.py familiarization exercise

This is the answer to the exercise set at the end of `familiarization.md`: read
`PASS.REL32V0/PASS1.PROCS/*.xpl` against `yaShuttle/ported/PASS1.PROCS/*.py` and
find incorrect translations from XPL/I to Python.  Everything below has been
fixed and regression-tested unless it says otherwise.

Throughout, the regression measure is `HALSFC --verbose --test --clean
--archive` over all 98 sources in `Source Code/Programming in HAL-S/` plus
`DEMO.hal` and `HELLO.hal`, compared against a pre-change baseline, and (for the
Python side) the same 98 sources compiled by `HAL_S_FC.py` with the reports
compared line for line, ignoring timestamps and CPU timings.

## Crash-class errors

Each of these raises `AttributeError` or `TypeError` the first time the code
runs, so each marks a path that had never executed.

| Site | Was | Should be | XPL |
| --- | --- | --- | --- |
| `STREAM.py:640` | `l.L = g.J(g.J)` | `l.L = h.IODEV[g.J]` | `STREAM.xpl:532` `L=IODEV(J)` |
| `STREAM.py:669` | `g.J[g.J] = l.L` | `h.IODEV[g.J] = l.L` | `STREAM.xpl:564` `IODEV(J)=L` |
| `SETDUPLF.py:25` | `g.SYT_NAME(g.DUPL_TERM)` | `g.SYT_NAME(DUPL_TERM)` | parameter, not global |
| `INCSDF.py:1123` | `g.g.STMT_NUM()` | `g.STMT_NUM()` | |
| `INCSDF.py:354` | `g.MONITOR(22, mode)` | `MONITOR(22, mode)` | built-in, not a global |
| `INCSDF.py:1037` | `g.NDECSY + 1` | `g.NDECSY() + 1` | COMM-backed accessor |

The `STREAM.py` pair is reached by the `D DEVICE n PAGED|UNPAGED` directive.

## XPL multiple assignment rendered as Python tuple-unpacking

XPL's `A, B = 0;` assigns right to left to each target in turn; written
unchanged in Python it is a tuple-unpack and raises `TypeError`.  Five
instances, all in `HALINCL/INCSDF.py`: lines 826, 937, 1037, 1121, 1122, from
`INCSDF.xpl:626,723,813,889,890`.

## Operator precedence

Relational operators bind *tighter* than `&` and `|` in XPL and *looser* in
Python, so an unparenthesized translation silently changes meaning.

- `SYNTHESI.py:5163` — `if g.CLASS > 0 & (not g.NAME_IMPLIED)` parses as
  `g.CLASS > (0 & ...)`, dropping the `NAME_IMPLIED` test altogether
  (`SYNTHESI.xpl:5007`).
- `SYNTHESI.py:5202` — `if g.NEST > 1 | g.BLOCK_MODE[1] != g.PROG_MODE` becomes
  a Python chained comparison rather than the XPL
  `(NEST>1) | (BLOCK_MODE(1)^=PROG_MODE)` (`SYNTHESI.xpl:5039`).

## Missing implicit `& 1` in a conditional

XPL conditionals test only the least significant bit.

- `SYNTHESI.py:3756` — `if g.DO_INX[g.TEMP]:` (`SYNTHESI.xpl:1728`).  `DO_INX`
  is one of {0 = simple DO, 1 = DO FOR, 2 = DO CASE, 3 = DO WHILE} or'd with
  0x80, so the XPL test deliberately admits only the iterative DOs.  The Python
  also admitted DO CASE, so a `REPEAT` inside a `DO CASE` would branch to the
  wrong DO.
- `ERRORSUB.py:136` — `if not g.VAL_P[g.TEMP]` (`ERRORSUB.xpl:105`,
  `IF ^VAL_P(TEMP)`).

## GOTO emulation

`ERRORSUB.py:135,138,145,148` used `break` where `continue` was meant.  `break`
leaves the `while goto != None` loop at line 99 and suppresses the
`ERROR(CLASS_RE, MODE)` diagnostic entirely, which also makes the
`if goto != None: continue` at line 154 dead code.

## Wrong literal

`COMPILAT.py:201` masked with `0x1FF` where `COMPILAT.xpl:1909` has `&"FFF"`.
Latent — the largest `#PRODUCE_NAME` is 0x137 — but wrong.

## Loop-variable terminal value

XPL's `DO I = a TO b` leaves `I` at `b+1` on normal exit; Python's `for` leaves
it at `b`.  `STREAM.py`'s `D DEVICE CHANNEL=n` loop depended on that, so a
one-digit channel — the only legal kind — always took the `NO_CHAN` exit and
reported XD3.  Fixed with a `for…else`.  `OUTPUTWR.py` already compensates for
the same idiom in three places (`I += 1  # Terminal value of for-loop
differs...`); `STREAM` was the only place that had missed it.  An AST sweep for
other loop variables read after their loop found no further genuine instances.

`SET_BLOCK_SRN` later turned out to need the same care; see below.

## SDF simulation: STABHDR, FINISH_MACRO_TEXT and the `--sdf` interlude

`STABHDR.py` was a stub — its whole body was a docstring, and only
`g.STMT_TYPE = 0` executed — and `INITIALI.py` hard-coded `g.SIMULATING = 0` in
place of `(OPTIONS_CODE & 0x800) != 0`.  Between them they made the entire
`STAB_HDR`/`STAB_VAR`/`STAB_LAB` path in `SYNTHESI`/`EMITSMRK`/`CHECKASS`
unreachable.

`STABHDR.py` is now ported for real.  Doing so needed new `COREBYTE`,
`COREHALFWORD` and `COREWORD` helpers in `HALINCL/VMEM3.py`: XPL reached
virtual-memory cells through BASED variables, i.e. pointers, so `NODE_H(13) = X`
becomes `COREHALFWORD(NODE_H + 2*13, X)` over the integer "core address" that
`GET_CELL()`/`LOCATE()` return.  The dope-vector idioms
`COREWORD(ADDR(NODE_H)) = COREWORD(ADDR(NODE_H)) + 4` and
`COREWORD(ADDR(NODE_F)) = ADDR(NODE_H(0))` reduce to `NODE_H += 4` and
`NODE_F = NODE_H`.  The four `INLINE` statements per SRN block are an `MVC` of 8
bytes of SRN text into the cell at offset `SRN_INX`.

Note that in `STABHDR.xpl` the dangling `ELSE CELLSIZE = CELLSIZE + 9;` binds to
the inner `IF SRN_COUNT(2) > 0`, not to `IF SRN_PRESENT`, despite what the
indentation suggests.

`FINISH_MACRO_TEXT` (`HALINCL/FINISHMA.py`) had to be finished too: its
`SIMULATING > 0` branch wrote the cell header to the Python locals `l.NODE_F0`
and `l.NODE_F1` instead of to virtual memory, and handed `MOVE()` a byte *value*
where the XPL passed `ADDR(MACRO_TEXT(n))`.  Since `MACRO_TEXTS` is a list of
one-byte objects rather than a contiguous run, the copy is spelled out
byte-at-a-time in a new local `MOVE_MACRO_TEXT()`.

Two further bugs surfaced while verifying all this.  `STAB_VAR` is called at
`SYNTHESI.py:1890` and `:4175` but was never imported there — a `NameError` on
21 of the 99 test sources once `SIMULATING` is on.  And the `D DEVICE CHANNEL=n`
loop bug above was found the same way.

A `--sdf` switch was added at this point, defaulting off, so that the newly
reachable code could not disturb ordinary compiles while it was still being
proved.  **It has since been removed** — see the next section.  `--sdfi`, which
names the SDF library, is a different thing entirely and is permanent.

## SET_BLOCK_SRN, and retiring `--sdf`

`SETBLOCK.py`'s `SET_BLOCK_SRN` had been stubbed out with an unconditional
`return` ("the more I think about this, the more at a loss I am"), and its
`BLOCK_SRN_DATA = GET_CELL(2044, MODF)` allocation was commented out in
`INITIALI.py`.  The difficulty was that `LOCATE()` returns an address into a
paged buffer at an arbitrary offset and Python cannot make a reference to part
of a `bytearray`.  `COREWORD()`, added to `VMEM3` for `STABHDR`, removes it: the
based-variable subscripting spells out as `COREWORD(SRN_BLOCK_RECORD + 4*n)`
exactly as it does there.  The `GET_CELL` is reinstated, storing only the
pointer in `COMM(18)`, since `SET_BLOCK_SRN` re-`LOCATE`s on every call;
`g.SRN_BLOCK_RECORD` is gone.

Two XPL details the routine depends on:

- `BLOCK_PTR` is declared inside the procedure as `DECLARE BLOCK_PTR FIXED
  INITIAL(1)`, but XPL allocates procedure locals statically and applies
  `INITIAL` once at load rather than on entry.  It therefore persists across
  calls, which is the only reason successive blocks land in successive slots.
  It is module-level in the port, and the C build agrees —
  `mSETuBLOCKuSRNxBLOCKuPTR` is a static memory cell in
  `PASS1.build/SETuBLOCKuSRN.c`.
- `DO I=0 TO 5` leaves the shared global `I` at 6, so the loop is written out
  longhand rather than left to `range()`.

Verified by probe rather than by inspection: `268-INT_HANDLER` records five
blocks with distinct symbol numbers, and a purpose-built two-block source with
sequence numbers in columns 73–78, compiled with the `SRN` option, yields
`(1, 470100)` and `(3, 470102)` — each block label's own card.

What the table is for: `BLOCK_SRN_DATA` is `COMM(18)`, a 2044-byte virtual
memory cell whose word 0 is a running count followed by (symbol number, numeric
SRN) pairs, one per block, appended at `SYNTHESI.xpl:4502` (label `NEW_SCOPE`,
"ALL BLOCKS AND TEMPLATES COME HERE").  Only PASS3 reads it —
`PASS3.PROCS/INITIALI.xpl:1470-1471`, `OLD_INT_BLOCK# = SRN_BLOCK_RECORD(0) - 1`,
with the cell released at 1585 — and `OLD_INT_BLOCK#` is itself never read
anywhere.  PASS2 never touches it, despite the routine's own comment saying
"IN TABLE FOR PHASE2".  So the mechanism is vestigial in REL32V0, which is why
PASS1's report is unaffected either way.

With that done the condition `--sdf` existed for no longer held, and it has been
removed.  `SIMULATING` again follows its option bit unconditionally.  That is a
real change rather than a cosmetic one, because the bit is 0x800 = the `TABLES`
option, which is on by default.  Removing the switch exposed one more genuine
port bug, in a `PTR_LOCATE` branch nothing had ever reached: `VMEM3.py:354,383`
wrote `v2VMEM_PAD_CNT`, missing a dot, giving a `NameError` on
`029-DATATYPES`.

Regression for this stage: all 98 `Programming in HAL-S` sources compile to
reports byte-identical to the pre-change baseline (modulo timestamps and CPU
timings), with identical exit statuses and empty stderr, measured separately for
the `SET_BLOCK_SRN` change alone and again with `SIMULATING` on.

## The two remaining stubs, and the four defects behind them

Both of the stubs listed here previously have now been dealt with, and closing
them turned up four more defects in the same never-executed stretch of
`VMEM3.py`.

### The `MISC` family

`GET_MISCF`/`SET_MISCF`/`GET_MISCH`/`SET_MISCH`/`GET_MISCB`/`SET_MISCB` now
reach their datum with `COREWORD`/`COREHALFWORD`/`COREBYTE` over the core
address `LOC_MISC` returns, instead of doing `NODE_F(0)` on a Python list.
`SET_MISCF`'s reference to `v2.ODF` — no such name, `VMEM2` defines only `MODF`
— is corrected.  `SET_MISCH` keeps the XPL's vestigial `OLD_VALUE` parameter but
defaults it, XPL having had no other way to declare a procedure-level local.

`LOC_MISC`'s `OFFSET / VMEM_PAGE_SIZE` was Python float division where XPL's
`FIXED` division truncates, so `SHL()` had nothing it could shift.  And
`MISC_ALLOCATE` marks a multi-page table with `| 0x80000000`, which makes a
32-bit `FIXED` negative but leaves a Python `int` positive — so `LOC_MISC` took
the single-page branch and added the whole byte offset to one page's offset
field.  Now coerced to signed 32-bit.

### `PTR_LOCATE`, all of it in code no compilation had reached

`BAD_PTR;` appeared twice as a bare name rather than a call, so an invalid
pointer was diagnosed nowhere.  `VMEM_TOTAL_PAGES` was unqualified, a
`NameError`.  `EXIT;` likewise bare.  `d` was never imported, so the `CLASS_BI`
diagnostics could not have been issued in any case.  `global PREV_COUNT`
misspelt `PREV_CNT`.  And `SET_INDEX` declared `global PREV_CNT, CUR_INDEX`
where `CUR_NDX` was meant, so `CUR_NDX` stayed at −1 and `PAGING_STRATEGY`
always reported error 700.

The structural one is worth stating carefully.  The XPL's `GO TO LOC_COMMON1`
leaves the new-page branch and lands *inside the other branch's*
`IF CUR_NDX = -1 THEN DO`, just past the FILE read.  The port set `goto` and
then simply fell out of the if/else, so a newly created page was never recorded
in `VMEM_PAGE_TO_NDX` or `VMEM_PAD_PAGE` and `VMEM_PAD_CNT` was not updated.
The consequence was that the next reference to that page took the reload path,
and `PAGING_STRATEGY` eventually tried to write a page out to page number −1.
The label's body is now lifted out below both branches, which is where all three
paths converge in the XPL.

`GET_CELL`'s page-search loop was missing the exit that `GO TO GET_SPACE`
performs, so it ran to its last iteration and handed `PTR_LOCATE` the wrong
page's `PAGE`/`AVAIL_SIZE` — page 0 with a negative `AVAIL_SIZE`, an offset past
the end of the page.  This one was *not* latent: it happens on `029-DATATYPES`
with `SIMULATING` on.  It went unnoticed only because `BAD_PTR` was a no-op and
because `normalize()` treats a core address flatly, so the malformed pointer
happened to land on the right byte anyway.  Making `BAD_PTR` a real call is what
exposed it; the compile aborted with BI701 until the loop was fixed.

### `DECOMPRE.py`

Ported from `DECOMPRE.xpl`, and `NEXT_RECORD` now imports `DECOMPRESS` rather
than calling a nonexistent `g.DECOMPRESS`.  `IN_REC_PTR` is module-level, XPL
locals being static, which is what lets one call resume where the last stopped.
The duplicate-character loop is written out longhand because XPL's
`DO OUT_REC_PTR = OUT_REC_PTR TO OUT_REC_PTR + (CNTL_BYTE & '3F') + 1`
evaluates its limit once and leaves the variable one past it.

Verified by round trip against a compressor written to the same format: six
cards including blank runs, literal runs, a 66-character repeat, an all-blank
card and a run straddling a record boundary.  The EOF branch had to be driven
directly, for the reason below.

Porting `DECOMPRE` is necessary but not sufficient for compressed source, and
the docstring now says so.  A compressed record is binary, but the port carries
a record as a Python `str` and recovers bytes with `BYTE()`, i.e.
`asciiToEbcdic[ord(c)]` — which has no preimage for 130 of the 256 values, 0xFF
(the EOF control byte) among them.  Reading compressed source also wants the
input path to carry bytes rather than characters, which is a change to the I/O
model and not to `DECOMPRE`.

### Regression

98 sources byte-identical to the pre-change baseline, identical statuses, empty
stderr.  New probes: 30 `MISC` checks and 11 `DECOMPRESS` checks.
`tests/runall.sh` 13/13, `cmem` 78, `sdfpkg` 3451.
