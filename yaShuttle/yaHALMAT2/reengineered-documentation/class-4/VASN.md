# VASN

**Mnemonic:** VASN

**Opcode:** 0x401

**Confidence:** High

## Behavioral Description

Vector assign. Assigns the vector operand specified by one operand to the
vector variable specified by another, following the general two-operand
assign pattern shared by every type's `xASN` operator (compare
[BASN](../class-1/BASN.md), [CASN](../class-2/CASN.md),
[MASN](../class-3/MASN.md), [SASN](../class-5/SASN.md),
[IASN](../class-6/IASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is a VECTOR
variable. Named explicitly in the Optimizer HALMAT inline-vector/matrix-
loop note in [HALMAT.md](../HALMAT.md#optimizer-halmat), sourced from
[IR-60-5] A-113, where arrayed VASN operations are expected to be
bracketed by [ADLP](../class-0/ADLP.md)/[DLPE](../class-0/DLPE.md).

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, `QUAL`=3=VAC when the
right-hand side is an expression; operand 2 = **receiver**, ordinarily
`DATA`=its symbol-table index, `QUAL`=1=SYT — but see "Confirmed Runtime
Behavior" below for a second, `QUAL`=3=VAC receiver shape (a whole
`VECTOR`, or a `MATRIX` row/column-partition select — this same opcode
handles both since `M$(i,*)`/`M$(*,j)` produce a `VECTOR`-shaped `VAC`
result) that's also valid. **Order corrected in a later session** via a
direct `unHALMAT.py` binary read of `V3 = V1 + V2` (compiled with
`HALSFC --parms="LISTING2,LSTALL"`) — an earlier reading had receiver
first, source second; same correction applied to
[SASN](../class-5/SASN.md)/[IASN](../class-6/IASN.md)/[MASN](../class-3/MASN.md),
see [SASN](../class-5/SASN.md) for the general account.

## Unresolved Questions

- None remaining for the base vector-assign case.

## Confirmed Runtime Behavior

**`QUAL`=3=`VAC` receiver — a whole `VECTOR` or `MATRIX` row/column-
partition select used as an assignment target.** `OP_MASN`/`OP_VASN`
share a single handler in `interp.c`, so this is the exact same fix
described in [MASN](../class-3/MASN.md)'s own "Confirmed Runtime
Behavior" section (user-reported via `047-ROWS.hal`'s `M$(I,*) =
C * MM$(I,*);`) — see that file for the full writeup, the
`container_ref_stride` write-back mechanism, and the regression
fixtures. Nothing VASN-specific was needed beyond MASN's own fix, since
both opcodes go through the identical code path.

**`ARRAY`-of-`VECTOR` write-back** (Maintenance phase, user-reported via
117-EXAMPLE_8.hal's `[VELOCITY]=([POSITIONS]-[OLD_POSN])/DELTA_T;`,
`VELOCITY`/`POSITIONS`/`OLD_POSN` all `ARRAY(5) VECTOR`, `ADLP`/`DLPE`-
replayed): unlike the read side (`resolve_container()`, shared by every
`xASN` opcode — see [MASN](../class-3/MASN.md)'s own note), VASN's own
*write*-back to an `ARRAY`-of-`VECTOR` receiver is hand-rolled and
bypasses the general `write_destination()` path, so it needed its own,
separate fix to slice by the replay's own `arrayed_index` (one
`VECTOR`-worth of elements per pass) rather than writing the whole flat
container on every pass. Output independently hand-verified (vector
subtraction/magnitude/dot-product arithmetic across the whole file, not
just cross-checked against `compileLinkRun`). Fixture:
`test_array_of_vector.hal`.

## Source Analysis & Reliability

Opcode (0x401) confirmed primary-source: `XVASN` (base of an array) in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. Matches
[MSC-01847]'s HAL-1971 VASN opcode (0x401) exactly, and matches
[IR-60-5] A-113's mnemonic. Operand-word format independently confirmed
against real compiled HALMAT in an earlier session; operand order
corrected in a later session via a direct `unHALMAT.py` binary read (see
Operand-Word Format above).

Behavioral description is a straightforward reading of "vector assign"
corroborated by [MSC-01847] §2.19 (Vector Operations); no verbatim
operand-word prose transcribed yet.
