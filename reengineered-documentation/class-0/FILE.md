# FILE

**Mnemonic:** FILE

**Opcode:** 0x022

**Confidence:** High

## Behavioral Description

File I/O specifier. Emitted for a HAL/S random-access I/O statement (the
`FILE` pseudo-variable construct, [USA003087] §22.2), in either its
write-mode form `FILE(n, address) = exp;` (saves `exp` as a record) or
read-mode form `var = FILE(n, address);` (retrieves a record into `var`).
`n` is a channel code (0–9, implementation-dependent range) and `address`
an integer expression giving the record's address — both are ordinary
HAL/S random-access I/O concepts, conceptually and physically separate
from `READ`/`WRITE`'s sequential-I/O device numbers even when the same
numeral is used (confirmed empirically — see Operand-Word Format below).

## Usage Context

Unlike `READ`/`WRITE` (bracketed by [XXST](XXST.md)/[XXAR](XXAR.md)/
[XXND](XXND.md)), a `FILE` statement compiles to a single FILE instruction
carrying the transferred variable, with the channel/address values folded
directly into the generated machine code as constants passed to a runtime
routine — no XXST-style bracketing construct is used. In the trace below,
the write-mode `FILE` statement happened to be preceded by an
[EDCL](EDCL.md) (0x031) instruction — this turned out to be unrelated to
`FILE` itself (EDCL marks the end of a compilation unit's declarations,
firing before whatever its first executable statement happens to be; see
[EDCL](EDCL.md)).

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = `DATA`=a literal-table index, `QUAL`=5=LIT —
**now confirmed this session to be the record address itself** (see
below); operand 2 = `DATA`=symbol-table index of the transferred
variable, `QUAL`=1=SYT (the value being written, for write-mode; the
target being read into, for read-mode). **The channel code is not a
separate operand at all — it's the operator word's own `TAG` field**
(the `3`/`4` in `022(2),3,0`/`022(2),4,0` below), confirmed by
cross-checking a direct `unHALMAT.py` binary read against the value
decoded for each `FILE`'s literal operand.

Confirmed by compiling `FILE(3, 7) = S1;` (write) and `I1 = FILE(4, 8);`
(read) together with `HALSFC --parms="LSTALL"`:

```
FILE(3, 7) = S1;             <- write mode
HALMAT: 031(0),1,0            <- EDCL (see EDCL.md), no operands
HALMAT: 022(2),3,0            <- FILE
          3(5),0,0             <- op 1: literal-table index 3, QUAL=5=LIT
          3(1),5,1             <- op 2: S1, symbol index 3, QUAL=1=SYT
0000A:  LA   2,S1
0000B:  LFXI 5,4               <- R5 <- (a literal/descriptor constant)
0000C:  LFXI 6,9               <- R6 <- 7  (the record address)
0000D:  LFXI 7,5               <- R7 <- 3  (the channel code)
0000E:  SCAL 0,#QFILEOUT       <- runtime call: R2=&S1, R5=?, R6=7, R7=3

I1 = FILE(4, 8);              <- read mode
HALMAT: 022(2),4,0            <- FILE (no preceding EDCL)
          5(5),0,0             <- op 1: literal-table index 5, QUAL=5=LIT
          2(1),6,0             <- op 2: I1, symbol index 2, QUAL=1=SYT
000010: LA   2,I1
000011: LFXI 5,3               <- R5 <- (a literal/descriptor constant)
000012: LFXI 6,10              <- R6 <- 8  (the record address)
000013: LFXI 7,6               <- R7 <- 4  (the channel code)
000014: SCAL 0,#QFILEIN        <- runtime call: R2=&I1, R5=?, R6=8, R7=4
```

(Symbol indices confirmed against `pass1.rpt`'s symbol table: `DCL 1
FTEST`, `DCL 2 I1`, `DCL 3 S1`. Register-constant values confirmed
against `pass2.rpt`'s per-statement "R USE" tables, which show R6/R7
resolving to the literal `CONST` values 7/3 and 8/4 respectively.)

**LIT operand and channel TAG both resolved this session**, by
recompiling with `HALSFC --parms="LISTING2,LSTALL"` and cross-checking
the same binary directly with `unHALMAT.py` (which decodes each
literal's actual value, not just its table index): the write-mode
`FILE`'s literal-table operand (index 3) decodes to value `7.0` — the
statement's own record address — and the read-mode `FILE`'s (index 5)
decodes to `8.0`, the record address there too. So **FILE's LIT operand
genuinely is the record address**, encoded exactly like any other
literal reference elsewhere in HALMAT — not a mysterious format/type
descriptor as previously speculated. Separately, the operator word's own
`TAG` field (`3` and `4` in `022(2),3,0` / `022(2),4,0`) is the channel
code — both values are also independently baked into the generated
object code as immediate constants (via `LFXI`) for the runtime-call
arguments, which is what the trace below already showed; that's simply
PASS2 choosing immediate-constant codegen for a compile-time-known
literal/TAG value rather than a runtime literal-table lookup, not
evidence that the HALMAT-level operand/TAG don't carry these values.
This resolves the open device-number question: **neither the channel
code nor the record address needs its own dedicated non-literal operand
mechanism** — the record address is an ordinary LIT operand and the
channel code is the operator word's TAG field, both distinct from
READ/RDAL/WRIT's device number (which is an `IMD` operand on the
READ/RDAL/WRIT header itself — corrected in a later session; see
[XXST](XXST.md)) — confirming FILE's device/channel space is handled
distinctly from READ/WRITE's, down to the HALMAT encoding level, not
just the numbering convention.

## Confirmed later: read/write disambiguation, and real runtime semantics via `--raf`

**The SYT operand's own `TAG2` distinguishes write from read**, confirmed
by two independent real compiles (this file's own trace above, plus a
fresh one this session): `TAG2`=1 when the variable is the *source*
(`FILE(n,addr)=exp` — write), `TAG2`=0 when it's the *destination*
(`var=FILE(n,addr)` — read). Not previously called out; the two example
statements above happen to use different channels, which obscured that
`TAG2` (not the channel) is what actually carries the direction.

**`FILE` I/O *is* supported by a real, working runtime** — just not the
one the original "Unresolved Questions" bullet below refers to. That
bullet's claim (`#QFILEOUT`/`#QFILEIN` unresolved at link time, per
[USA00309] §6.2) is about the *original* 1980s IBM-mainframe HAL/S-FC
runtime library, confirmed independently by
`Programming in HAL-S/176-P.hal`'s own source comment citing that exact
manual section as the reason its `FILE` statement is commented out. The
*modern* `virtualagc` project's own C reimplementation of the runtime
(`PASS.REL32V0/PASS2.PROCS/PASS2B.build/runtimeC.c`) does implement
`#QFILEOUT`/`#QFILEIN` (as C functions `lFILE`/`rFILE`), gated by a
`--raf=I,R,N,F` runtime option ("attach random-access file F to device
number N, record size R bytes") — a real, authoritative reference for
`FILE`'s intended runtime behavior, even though (per direct user
clarification) BFS-flavor object files use a different format from PFS
and the available `lnk101` linker doesn't support BFS, so no genuinely
linked-and-run comparison binary could be produced this session either.
`lFILE`/`rFILE`'s logic is simple: `position = recordSize * recordNumber`
(so `address` truly is a *record number*, not a byte offset); the full
`recordSize` bytes are copied verbatim between the file and the
variable's memory, with **no recoding/translation of any kind** (per
`--raf`'s own documented text) — i.e. genuinely raw, fixed-size binary
records.

`yaHALMAT2` implements `FILE` against this specification (own `--raf`
option, same name/shape) since it has no byte-addressable "memory" to
copy from/to the way the real runtime does — instead serializing
`INTEGER` as a 4-byte big-endian value and `SCALAR` as its existing
msw/lsw wire format (4 bytes single, 8 bytes double, matching this
project's already-established bit-exact representation elsewhere).
Confirmed end-to-end (`src/tests/hal/test_file.hal`): writing `INTEGER`
`42` then `SCALAR` `3.5` to two different records, reading both back,
overwriting the `INTEGER` record with `99` and reading that back too,
round-trips correctly through `yaHALMAT2`'s own execution. This is
internal round-trip validation only, **not** verified byte-for-byte
compatible with the real runtime's own in-memory layout for these
types (no way to test that without a working BFS link).

## Unresolved Questions

- Whether/how array-, structure-, or arrayed-type transfers (legal per
  [USA003087] §22.2's write-mode type list) change the operand-word
  count or structure is untested — both statements compiled here used a
  single unarrayed scalar. `yaHALMAT2` only implements the plain
  `INTEGER`/`SCALAR` case for the same reason.
- Whether `FILE`'s channel-number space is JCL-associated the same way
  `READ`/`WRITE`'s is — [USA00309] §6.1.4 documents a fixed `CHANNELn` DD
  name convention for `READ`/`WRITE`/`READALL` device numbers 2–9 (see
  [XXAR](XXAR.md)'s Unresolved Questions, resolving what HAL-1971's
  `FASN` instruction's role became) — is not confirmed; `FILE`'s own
  channel/address values are compiled as immediate constants rather than
  going through the same device-number mechanism at all (see Operand-Word
  Format above), so this may not even apply.
- The exact byte layout the real runtime uses for `INTEGER`/`SCALAR` in
  a `--raf` record (endianness, padding) is not independently confirmed
  against `yaHALMAT2`'s own choice, for the reason given above.

## Source Analysis & Reliability

Opcode (0x022) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103); no page content for FILE's own HAL/S description (target p. 63) is
present in the available partial copy. Statement syntax (`FILE(n,
address) = exp;` / `var = FILE(n, address);`, channel-code range,
argument-type lists) primary-sourced from [USA003087] §22.2 (PDF pp.
275–279), located via direct user guidance to that section. Full
operand-word structure confirmed directly against real compiled HALMAT
in an earlier session; the LIT operand's and channel TAG's exact
meanings resolved in a later session via `unHALMAT.py`'s literal-value
decoding (see Operand-Word Format above).

Earlier behavioral description (now superseded) had been drawn from
[MSC-01847] p. 2-13's identically-named predecessor-language instruction
(HAL 1971 opcode 0x034, differing from HAL/S's 0x022); that predecessor
carried the device/record numbers directly on its own operands, which
does **not** carry over to HAL/S — see Operand-Word Format above.
