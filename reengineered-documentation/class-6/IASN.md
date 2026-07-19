# IASN

**Mnemonic:** IASN
**Opcode:** 0x601
**Confidence:** High

## Behavioral Description

Integer assign. Assigns the integer operand specified by one operand to
the integer variable specified by another, following the general
two-operand assign pattern shared by every type's `xASN` operator
(compare [BASN](../class-1/BASN.md), [CASN](../class-2/CASN.md),
[MASN](../class-3/MASN.md), [VASN](../class-4/VASN.md),
[SASN](../class-5/SASN.md)).

## Usage Context

Emitted for HAL/S assignment statements whose receiver is an INTEGER
variable, and for loop-index updates in `DO FOR` constructs.

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = **source value**, `QUAL`=3=VAC (`DATA`=stream
position of the producing instruction) when the right-hand side is an
expression; operand 2 = **receiver**, `DATA`=its symbol-table index,
`QUAL`=1=SYT. **Order corrected in a later session** via a direct
`unHALMAT.py` binary read of `I3 = I1 + I2` (compiled with
`HALSFC --parms="LISTING2,LSTALL"`) — an earlier reading had receiver
first, source second; same pattern as [SASN](../class-5/SASN.md), see
that file for the general account of this correction.

## Usage Context (multiple assignment)

Also confirmed to serve HAL/S multiple-assignment statements
(`L1,L2,...Ln = R;`, [USA003087] §8.5) — no separate opcode exists for
this construct; it's the same `xASN` opcode for the receivers' shared
type, with `NUMOP` extended to `n+1` (the shared source-value operand,
then one operand per receiver, `QUAL`=1=SYT each — **order corrected in
a later session**, matching the base-case fix above). Confirmed by
compiling `S1, S2 = 5.0;` (both SCALAR receivers, whole-valued literal —
see below) and cross-checking with `unHALMAT.py`, which produced
`HALMAT: 601(3),0,0` with three operands, in true stream order:
`10(5),0,0` (the literal 5.0, source, first), `4(1),0,0` (S2), `3(1),0,0`
(S1) — source first, then receivers in reverse declaration order. This
rules out an earlier hypothesis that the still-unresolved
`PMHD`/`PMAR`/`PMIN` opcode family might relate to multiple assignment —
they don't; see those files for the current best guess (procedure/
function argument passing instead).

## Unresolved Questions

- None remaining for the base integer-assign case (INTEGER receiver from
  an expression or a literal both confirmed). **However**: IASN also
  fires for a SCALAR receiver assigned a literal whose *numeric value* is
  a whole number — not just integer-looking literals like `S1 = 4;`, but
  also decimal-point literals like `S1 = 1.0;` (confirmed in a follow-up
  test). See [SASN](../class-5/SASN.md)'s Unresolved Questions for the
  full detail. The generated machine code in that case still stores the
  value as a float (`LFLI`/`STE`), so this looks like PASS1 folding
  whole-valued literals into a shared representation whose type leaks
  through as IASN regardless of the receiver's actual declared type; not
  fully explained at the bit level.

## Source Analysis & Reliability

Opcode (0x601) confirmed primary-source: base of the `XXASN` array
(element 6) in `PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in
`STATUS.md`. Matches [MSC-01847]'s HAL-1971 IASN opcode (0x601) exactly.
Operand-word format independently confirmed against real compiled HALMAT
in an earlier session; operand *order* (both base and multiple-assignment
cases) corrected in a later session via a direct `unHALMAT.py` binary
read (see Operand-Word Format above).

Behavioral description is a straightforward reading of "integer assign"
corroborated by [MSC-01847] §2.21 (Integer Operations); no verbatim
operand-word prose transcribed yet.
