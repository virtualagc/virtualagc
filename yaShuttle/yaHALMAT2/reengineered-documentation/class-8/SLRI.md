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
**Correction (later session, re-confirmed against a current HALSFC
build):** the compiler emits exactly one [SINT](SINT.md)/[ELRI](ELRI.md)
unit regardless of repetition count — confirmed for both a 3-element and
a 1000-element array (`DECLARE A ARRAY(1000) SCALAR
INITIAL(1000#1.5);`, both `--parms="LSTALL"` and plain compiles agree:
exactly one `SINT`/`ELRI` pair, not one per element). The originally
documented "999 more repetitions" trace below does not reproduce against
this build and is believed to have been a documentation error rather
than a genuine compiler-version difference (no other evidence of
compiler-version-dependent HALMAT shape has turned up elsewhere in this
project). The single unit is instead **replayed by the consuming
program** at runtime, driven by SLRI's own repetition-count operand — the
same "single-instance-plus-trailing-metadata, replayed by the consumer"
shape [ADLP](../class-0/ADLP.md)/[IDLP](../class-0/IDLP.md) use, except
SLRI *leads* the paragraph it describes (STRI names the target symbol,
SLRI opens the replay, the single SINT/ELRI unit is the body, ETRI
closes it) rather than trailing it. Consistent either way with `STATIC`
initialization ([USA003087] §16.4) being realized as compile-time-laid-
out data rather than executable code — a real runtime loop was never
required, whichever the compiler generates. The whole sequence is closed
by [ETRI](ETRI.md).

## Operand-Word Format (confirmed empirically)

Two operands: operand 1 = `DATA`=the repetition count, `QUAL`=6=IMD;
operand 2 = `DATA`=1 (observed; presumably the number of values per
repeated unit — 1 for a simple `n#value` pattern), `QUAL`=6=IMD.
Confirmed by compiling `DECLARE A ARRAY(3) SCALAR INITIAL(3#1.5);`:

```
HALMAT: 801(1),0,0            <- STRI: A, symbol index 2
HALMAT: 802(2),1,0            <- SLRI
          3(6),0,0               <- literal 3 (repetition count), QUAL=6=IMD
          1(6),0,0               <- literal 1 (values per unit), QUAL=6=IMD
HALMAT: 8A1(2),5,0            <- SINT (see SINT.md), single unit -- the runtime
                                  consumer replays this once per repetition
          0(10),0,0              <- DATA=0, QUAL=A=OFF (relative/sequential offset — see SINT.md)
          3(5),1,0               <- literal-table index 3 (the value 1.5), QUAL=5=LIT
HALMAT: 803(0),1,0            <- ELRI (see ELRI.md): end of this unit
HALMAT: 804(0),0,0            <- ETRI (see ETRI.md): end of the whole sequence
```

This confirms [SINT](SINT.md)'s previously-speculative "OFFSET-addressed
form... used for element-by-element matrix/vector initialization" —
here used for a scalar array instead, with `QUAL`=A=OFF and `DATA`=0 for
every element, implying the offset is *relative*/sequential (the
runtime replay's own iteration counter, not a literal encoded per
instance) rather than an explicit absolute index.

## Unresolved Questions

- Whether a non-uniform repeated pattern (e.g. `n#(v1, v2, v3)`, several
  distinct values repeated as a group) changes SLRI's second operand or
  produces a different `ELRI` count per group-repetition was not tested
  — only the simplest single-value `n#value` form was compiled.
- Whether `AUTOMATIC` initialization (re-run on every block entry, per
  §16.4) produces an actual runtime loop instead of this single-unit-
  replayed form was not tested.
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
