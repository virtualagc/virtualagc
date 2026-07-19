# Control Flow Patterns

Cross-reference material for how HAL/S's control-flow statements compile
to HALMAT, tying together instruction files that only make full sense in
combination. Each pattern below is confirmed by direct compilation and
a `unHALMAT.py`/`pass2.rpt` cross-check; see the individual instruction
files (linked throughout) for opcodes, operand-word formats, and Source
Analysis citations — this document only covers how they compose.

## IF / THEN / ELSE

```
IF exp THEN true-statement;
ELSE false-statement;
```

compiles to:

```
IFHD                          <- no operand, pure marker (see IFHD.md)
<comparison opcode>           <- evaluates exp (e.g. IGT, SEQU, CAND...)
FBRA   VAC=comparison, LBL=①  <- branch to ① if exp is FALSE
<true-statement's HALMAT>
BRA    LBL=②                  <- unconditional: skip the ELSE part
LBL    ①                      <- ELSE entry point
<false-statement's HALMAT>
LBL    ②                      <- post-IF/ELSE join point
```

See [IFHD](class-0/IFHD.md) for the full worked trace this pattern is
drawn from. The no-`ELSE` form (`IF exp THEN true-statement;` alone) is
expected to omit the closing `BRA` and the `ELSE`-entry `LBL`, with
`FBRA` branching directly to the post-statement join point instead —
this specific reduction is flagged as untested in
[IFHD](class-0/IFHD.md)'s Unresolved Questions, not yet independently
confirmed. Nested `IF`s and compound (`DO;...END;`) true/false parts are
likewise untested.

[FBRA](class-0/FBRA.md)'s own comparison operand is `VAC`-qualified,
pointing at whichever comparison opcode ([SGT](class-7/SGT.md),
[IEQU](class-7/IEQU.md), [CAND](class-7/CAND.md)/[COR](class-7/COR.md)
for compound conditions, etc. — see Class 7 in `STATUS.md`) evaluated
`exp`; [BRA](class-0/BRA.md)/[FBRA](class-0/FBRA.md)'s label operands and
the matching [LBL](class-0/LBL.md)'s own operand are all the same
internal branch-target identifier space (`QUAL`=2=GLI/INL), independent
per `IF` statement.

## DO WHILE / DO UNTIL

```
DO WHILE condition;            (or: DO UNTIL condition;)
   body;
END;
```

compiles to:

```
DTST   <construct id>, tag=WHILE(0)/UNTIL(1)
[UNTIL only: unconditional branch skipping the first test]
<loop-top label>
<comparison opcode evaluating condition>
CTST   VAC=comparison, tag=WHILE(0)/UNTIL(1)   <- branch out of loop if false
<body's HALMAT>
ETST   <construct id>          <- branch back to loop-top; defines the exit label
```

See [DTST](class-0/DTST.md) for the full worked trace of both polarities
(including the `UNTIL`-only initial-test-skip branch) and
[CTST](class-0/CTST.md)/[ETST](class-0/ETST.md) for their own
operand-word formats. `DTST`/`CTST` share a trailing polarity flag
(`0`=`WHILE`, `1`=`UNTIL`); `ETST` needs no such flag of its own since
the polarity is already fully expressed by the other two.

## DO FOR

Two distinct forms, both closed by [EFOR](class-0/EFOR.md) but otherwise
structurally different — see [DFOR](class-0/DFOR.md) for the full
per-form operand-word breakdown:

- **Range form** (`DO FOR var = initial TO final BY increment;`):
  [DFOR](class-0/DFOR.md) carries the construct id, control variable,
  and range literals (initial/final/[increment]); the loop body is
  followed by [EFOR](class-0/EFOR.md), which generates the
  increment/re-test/branch-back logic directly (using
  [BRA](class-0/BRA.md)'s "absolute label" form for the loop-back edge,
  per [BRA](class-0/BRA.md)'s Behavioral Description — a HALMAT-instruction-index
  branch target rather than an ordinary [LBL](class-0/LBL.md)-relative
  one). A supplementary `WHILE`/`UNTIL` clause inserts
  [CFOR](class-0/CFOR.md) once per cycle, immediately before the body —
  the `DFOR`/`EFOR` analog of `CTST`.
- **List form** (`DO FOR var = exp1, exp2, ...expn;`): the reduced
  (2-operand) [DFOR](class-0/DFOR.md) is followed by one
  [AFOR](class-0/AFOR.md) per value, each dispatching into the loop body
  via a call-and-computed-return mechanism rather than range form's
  increment/re-test loop — see [AFOR](class-0/AFOR.md) for the full
  worked trace of the dispatch/return machinery.

## DO CASE

```
DO CASE selector;
   case-1-statement;
   case-2-statement;
   ...
END;
```

compiles to a genuine computed (indexed) branch, not a chain of
comparisons:

```
DCAS   <construct id>, selector      <- computed branch (AHI/LH/BCR at the object-code level)
CLBL   <construct id>, <case-1 label>
<case-1's HALMAT>, ending in an unconditional branch to the join point
CLBL   <construct id>, <case-2 label>
<case-2's HALMAT>, ...
...
CLBL   <construct id>, <trailing-case label>   <- same 2-operand shape as every other case
ECAS   <construct id>                          <- join point every case's closing branch targets
```

See [DCAS](class-0/DCAS.md) for the full worked trace and
[CLBL](class-0/CLBL.md) for confirmation that **every** `CLBL` — including
the final one before `ECAS` — carries the same two operands (a construct
id and its own label), distinguished only by a trailing tag, not by
operand count (an earlier reading of this final `CLBL` as a one-operand
special case was a `pass2.rpt` misreading, corrected in a later session —
see [CLBL](class-0/CLBL.md)'s Source Analysis). Behavior when the
selector is out of range (a runtime error, or an `ELSE` clause) remains
untested — see [DCAS](class-0/DCAS.md)'s Unresolved Questions.

## Plain `DO; ... END;`

No condition, no computed branch — [DSMP](class-0/DSMP.md)/
[ESMP](class-0/ESMP.md) bracket the group purely for scoping purposes,
generating no branch code of their own.

## Related: Optimizer HALMAT

Comparison opcodes feeding any of the branches above (`FBRA`/`CTST`) gain
register-environment tag bits once compiled HALMAT passes through the
optimizer (T1/T2, empirically confirmed for T1 — see
[HALMAT.md](HALMAT.md#optimizer-halmat) and `STATUS.md`'s "Optimizer
HALMAT" section) — these don't change the control-flow *shape* documented
above, only add PASS2-facing metadata to the comparison instructions
already in the pattern.
