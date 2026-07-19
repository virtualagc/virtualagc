# SLRI

**Mnemonic:** SLRI

**Opcode:** 0x802

**Confidence:** High

## Behavioral Description

Start loop, repeated initialize. Opens a repeated-initial-value sequence
within a "static bypass block" (see [BINT](BINT.md) for the general
concept), used for the `n#value` repetition-factor form of an
`INITIAL(...)`/`CONSTANT(...)` specification ([USA003087] §16.2, "Use of
Repetition Factors") — e.g. `DECLARE S ARRAY(1000) SCALAR
INITIAL(1000#1.5);`. Follows [STRI](STRI.md) (the general
repeated-initialize header) and carries the repetition count.

## Usage Context

Appears once per repetition group, immediately after [STRI](STRI.md).
Even for large repetition counts, the compiler fully unrolls the
sequence into one [SINT](SINT.md)/[ELRI](ELRI.md) pair per element
(confirmed for a 1000-element array) rather than generating an actual
runtime loop — consistent with `STATIC` initialization ([USA003087]
§16.4) being realized as compile-time-laid-out data rather than
executable code. The whole sequence is closed by [ETRI](ETRI.md).

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = `DATA`=the repetition count, `QUAL`=6=IMD;
operand 2 = `DATA`=1 (observed; presumably the number of values per
repeated unit — 1 for a simple `n#value` pattern), `QUAL`=6=IMD.
Confirmed by compiling `DECLARE S1 ARRAY(1000) SCALAR
INITIAL(1000#1.5);` with `HALSFC --parms="LSTALL"`:

```
HALMAT: 801(1),0,0            <- STRI: S1, symbol index 2
HALMAT: 802(2),1,0            <- SLRI
       1000(6),0,0               <- literal 1000 (repetition count), QUAL=6=IMD
          1(6),0,0               <- literal 1 (values per unit), QUAL=6=IMD
HALMAT: 8A1(2),5,0            <- SINT (see SINT.md), element 1
          0(10),0,0              <- DATA=0, QUAL=A=OFF (relative/sequential offset — see SINT.md)
          3(5),1,0               <- literal-table index 3 (the value 1.5), QUAL=5=LIT
HALMAT: 803(0),1,0            <- ELRI (see ELRI.md): end of this unit
... (repeated 999 more times, each SINT/ELRI pair byte-identical — the
     literal-table index and OFFSET operand never change across
     repetitions, since every element gets the same value 1.5)
HALMAT: 804(0),0,0            <- ETRI (see ETRI.md): end of the whole sequence
```

This confirms [SINT](SINT.md)'s previously-speculative "OFFSET-addressed
form... used for element-by-element matrix/vector initialization" —
here used for a scalar array instead, with `QUAL`=A=OFF and `DATA`=0 for
every element, implying the offset is *relative*/sequential (advancing
implicitly with each emitted instruction) rather than an explicit
absolute index.

## Unresolved Questions

- Whether a non-uniform repeated pattern (e.g. `n#(v1, v2, v3)`, several
  distinct values repeated as a group) changes SLRI's second operand or
  produces a different `ELRI` count per group-repetition was not tested
  — only the simplest single-value `n#value` form was compiled.
- Whether `AUTOMATIC` initialization (re-run on every block entry, per
  §16.4) produces an actual runtime loop instead of this unrolled form
  was not tested.
- The exact meaning of operand 2 (observed value `1`) is inferred, not
  confirmed against a case where it would differ.

## Source Analysis & Reliability

Opcode (0x802) doubly confirmed (`XSLRI`) in `PASS1.PROCS/##DRIVER.xpl` —
see [##DRIVER.xpl] in `STATUS.md`. Slot matches HAL-1971's DLPI
("initialize loop header"); the mnemonic itself differs, so this remains
a plausibly-renamed version of the same concept rather than a confirmed
cross-language match. Statement syntax primary-sourced from [USA003087]
§16.2 (PDF p. 183ff). Full behavioral description and operand-word
structure confirmed directly against real compiled HALMAT this session.
