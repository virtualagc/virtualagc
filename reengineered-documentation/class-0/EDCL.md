# EDCL

**Mnemonic:** EDCL

**Opcode:** 0x031

**Confidence:** High

## Behavioral Description

End-of-declarations marker — the mnemonic reading ("End DeCLarations") is
now grammar-confirmed, not just inferred from behavior: emitted directly
by `PASS1.PROCS/SYNTHESI.xpl`'s `<BLOCK BODY>` production, which is
literally the declarations-section-then-executable-body boundary of every
HAL/S block (`PROGRAM`/`TASK`/`PROCEDURE`/`FUNCTION`/`COMPOOL`). Carries
no operands. Appears exactly once per *block* (not once per compilation
unit — see Usage Context), immediately before the HALMAT for the first
executable statement following the block's `DECLARE` statements —
regardless of what that first executable statement actually is.

## Usage Context

Emitted from two grammar-rule alternatives for `<BLOCK BODY>`:

- `<BLOCK BODY> ::= <EMPTY>` — a block with **no** declarations at all —
  `CALL HALMAT_POP(XEDCL,0,XCO_N,0)`, trailing tag `0`.
- `<BLOCK BODY> ::= <DECLARE GROUP>` — a block with **at least one**
  declaration — `CALL HALMAT_POP(XEDCL,0,XCO_N,1)`, trailing tag `1`.

This directly explains the previously-unexplained trailing tag
(`031(0),1,0`, i.e. tag `1`) observed in every test program compiled so
far this project — all of them declared at least one variable before
their first executable statement. A block with zero declarations
(e.g. `MAIN: PROGRAM; I1 = 3; CLOSE MAIN;` with no preceding `DECLARE`)
is expected to instead show tag `0`, though this specific case was not
independently recompiled this session (the grammar-rule source itself is
unambiguous).

Fires once per *block*, not just once for the whole compilation unit —
confirmed by compiling a `PROGRAM` containing a nested `TASK` block: EDCL
appeared once right before the `TASK` header's own HALMAT (the outer
`PROGRAM` block's first executable "statement," from its own
declarations' point of view, is the nested block's opening), and *again*
right before the `TASK` block's own first true executable statement
(`WAIT 5.0;`) — but did not reappear before the outer `PROGRAM`'s next
statement after `CLOSE`ing the task, confirming it's a once-per-block
marker.

## Operand-Word Format (confirmed empirically)

No operands. Confirmed by compiling two different test programs with
`HALSFC --parms="LSTALL"`:

```
 DCASTST: PROGRAM;
    DECLARE INTEGER, I1;      <- statement 2 (declaration)
    DECLARE SCALAR, S1;       <- statement 3 (declaration)
    I1 = 3;                   <- statement 4 (first executable statement)
```
produced `HALMAT: 031(0),1,0` (EDCL, no operand line, trailing tag `1` =
"at least one declaration present") immediately before statement 4's
`601(2)` (IASN) HALMAT.

## Unresolved Questions

- The zero-declaration case (`<BLOCK BODY> ::= <EMPTY>`, tag `0`) was
  identified via the grammar source but not independently recompiled to
  visually confirm the resulting `031(0),0,0` trace.

## Source Analysis & Reliability

Opcode (0x031) confirmed primary-source: `XEDCL BIT(16) INITIAL("031")` in
`PASS1.PROCS/##DRIVER.xpl` — see [##DRIVER.xpl] in `STATUS.md`. No
[MSC-01847] (HAL-1971) analog identified. Behavioral description
originally based on two independent empirical data points (`FILE(3, 7) =
S1;` and `I1 = 3;`, both the first executable statement of their
respective compilation units) which established the "end of
declarations" reading over an earlier, too-narrow "`FILE`-write-specific"
hypothesis. This session, grepping the full `PASS.REL32V0` compiler
source tree for every site referencing `XEDCL` found the single emitting
site — `PASS1.PROCS/SYNTHESI.xpl`'s `<BLOCK BODY>` grammar-rule pair —
which both confirms the mnemonic reading directly from source and fully
decodes the previously-unexplained trailing tag as a
declarations-present/absent flag, without requiring any new compilation.
