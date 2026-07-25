# LBL

**Mnemonic:** LBL

**Opcode:** 0x008

**Confidence:** High

## Behavioral Description

Label. Indicates the destination of a branch specified by one of the
branch instructions [BRA](BRA.md), [FBRA](FBRA.md), or (in the
predecessor language HAL, and presumably HAL/S) a bit-string conditional
branch. Its operand is either a symbol-table pointer or an internal flow
number, and must match the destination operand carried by the
originating branch instruction(s).

## Usage Context

Appears at the target location of unconditional and conditional branches
— confirmed this session for the `ELSE` entry point and the post-`IF`
join point of an `IF...THEN...ELSE` statement ([USA003087] §9.1).
Compare [CLBL](CLBL.md), the analogous destination marker used
specifically for *computed* branches ([DCAS](DCAS.md)/`DO CASE`).

## Operand-Word Format (confirmed empirically)

One operand: `DATA`=an internal branch-target/label identifier (matching
the identifier carried by the originating [FBRA](FBRA.md) or
[BRA](BRA.md) instruction), `QUAL`=2=GLI/INL. Confirmed by compiling
`IF I1 > 0 THEN S1 = 1.0; ELSE S1 = 2.0;` with `HALSFC --parms="LSTALL"`
— see [IFHD](IFHD.md) for the full worked trace, in which two LBL
instructions appear: one marking the `ELSE` branch's entry point
(target of [FBRA](FBRA.md)'s conditional branch) and one marking the
statement following the whole `IF`/`ELSE` construct (target of the true
part's own closing unconditional [BRA](BRA.md)).

## A second, distinct QUAL=SYT form: user-declared statement labels

**Confirmed this session** (user-reported, 119-EXAMPLE_9.hal's
`INNER: DO FOR TEMPORARY J = 1 TO 3; ... EXIT INNER; ... END INNER;`):
a *user-declared statement label* (`INNER:`, the target of a real `GO
TO`/`EXIT` naming a source-level label rather than an ELSE/join point
the compiler generated on its own) also compiles to this same LBL
opcode, but with `QUAL`=1=`SYT` (keyed by the label's own symbol-table
index) instead of `QUAL`=2=GLI/INL (keyed by an internal bookkeeping-
label number, as in the ELSE/join-point case above). These are two
genuinely independent numbering spaces that can coincidentally collide
in a small enough program — a real `GO TO <label>;` uses the `QUAL`=`SYT`
form (confirmed via `test_eron_goto.hal`/`test_eron_goto_appc.hal`).

`yaHALMAT2`'s own label-precomputation pass originally registered every
LBL into one flat table regardless of `QUAL`, silently mis-registering
one numbering space as the other whenever a small program's own
bookkeeping-label and symbol-table-index values happened to coincide —
found while implementing `EXIT`-of-labeled-`DO FOR` (see
[EFOR](EFOR.md)'s own Implementation Notes for that fix); the first
attempted fix (registering only `QUAL`=`INL`) then broke real `GO TO`,
which needs the `QUAL`=`SYT` form. Fixed properly by splitting into two
parallel tables (`label_pos`/`label_pos_syt`, `state.h`), with
[BRA](BRA.md)/[FBRA](FBRA.md) dispatching on their own operand's
qualifier rather than assuming a shared namespace.

## Unresolved Questions

- Whether HAL/S LBL is also the destination for a bit-string conditional
  branch (HAL 1971's BBRA, opcode 0x013 in that language) is unconfirmed;
  no HAL/S Class 0 opcode has been identified as a bit-string-specific
  branch analogous to BBRA — see [BTOQ](../class-1/BTOQ.md) for a related
  open investigation into bit-string-in-conditional-context encoding.

## Source Analysis & Reliability

Opcode (0x008) and mnemonic are primary-sourced from [IR-60-5] A.2 (p.
A-103) and independently confirmed by `XLBL BIT(16) INITIAL("008")` in the
HAL/S-FC compiler source itself (`PASS1.PROCS/##DRIVER.xpl`) — see
[##DRIVER.xpl] in `STATUS.md`. No page content for LBL's own HAL/S
description (target p. 49) is present in the available partial copy.
Operand-word format confirmed directly against real compiled HALMAT this
session (part of a systematic sweep of USA003087 syntax patterns against
previously-untested HALMAT constructs).

Behavioral description drawn from [MSC-01847] p. 2-2 ("2.2 LABELS"),
describing the predecessor-language instruction of the same mnemonic *and
the same opcode* (HAL 1971 also assigns LBL opcode 0x008) — one of only a
handful of exact opcode matches found between the two language versions
(see `STATUS.md` for the full comparison).
