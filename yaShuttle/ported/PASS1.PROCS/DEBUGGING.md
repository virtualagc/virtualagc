This is a guide for debugging discrepancies between HALSFC and HAL_S_FC.py, for use on future issues of this kind.

Note: If any files or directories referenced here are not found in the specified locations, stop and inquire rather than searching for them. If any online files are referenced, they are also available locally; if you don't know where, stop and inquire rather than searching for them.

## Background

HALSFC is a locally-installed compiler for the HAL/S computer language. It consists of several passes, referred to as PASS1, FLOW, OPT, AUX, PASS2, PASS3, and PASS4. Our interest is entirely on PASS1. HALSFC is a port of an earlier compiler, HAL/S-FC written in the XPL/I computer language, created by translation of the original XPL/I to C. The original XPL/I source code for PASS1 is in the local directories ../../"Source Code"/PASS.REL32V0/PASS1.PROCS/ and ../../"Source Code"/PASS.REL32V0/HALINCL/. The corresponding C source code for PASS1 of HALSFC is in the directory ../../"Source Code"/PASS.REL32V0/PASS1.PROCS/PASS1.build/. Filenames of the C code are based on those in the XPL/I code, but with the filename extension ".c" rather than ".xpl". Filenames of the C code are based on the PROCEDURE names within the original XPL/I code rather than the filenames of the original XPL/I code, but mangled in several ways. The characters #, @, $, and _ are legal in XPL/I identifiers, and mangling replaces those characters by p, a, d, and u respectively in C code and filenames. Also, the mangling of identifiers prefixes them with the names of their enclosing scopes, separating each with the character m. For example, the file HALINCL/PRINTCOM.xpl in HAL/S-FC becomes STREAMmPRINTuCOMMENT.c in HALSFC (because the file from HALINCL just happens to be "included" within the STREAM PROCEDURE). However, the main program, which is "##DRIVER.xpl" in HAL/S-FC is instead just main.c in HALSFC.

HAL_S_FC.py is an entirely-independent port of PASS1 of HAL/S-FC to the Python 3 language. The porting process was based on manual translation of the original HAL/S-FC source code in XPL/I to Python on a line-by-line basis. Its source code is found in the current directory. Filenames of the Python code are based on the filenames of the original XPL/I code. If the characters #, @, or $ are found in identifiers, they are replaced by p, a, and d respectively. However, the main program, which is "##DRIVER.xpl" in HAL/S-FC, is HAL_S_FC.py.

## The general task

A HAL/S source-code file is found to compile differently (in error status, in generated output, or both) under HALSFC than it does under HAL_S_FC.py. Since HALSFC is taken as authoritative/correct, the objective is to find and fix the porting bug(s) in HAL_S_FC.py responsible for the discrepancy, without introducing regressions in behavior that already matches.

## Reproducing and comparing

To compile a HAL/S file FOO.hal with both compilers and capture every artifact each one produces:

```
HALSFC --clean --archive --test --force <path-to-FOO.hal>
```

Add `--parms=LISTING2` to this command (i.e. `HALSFC --clean --archive --test --force --parms=LISTING2 <path-to-FOO.hal>`) when you'll need the HALMAT-level analysis described below.

This runs both compilers and stores every file each one produces in current.results/, and prints a summary of which corresponding output-file pairs matched or differed, e.g.:

```
Files pass1A.rpt and pass1pA.rpt are identical
Binary files FILE1.bin and halmat.bin differ
Files FILE3.bin and icfile.bin are identical
Files literals1.txt and literals1p.txt are identical
```

pass1A.rpt / FILE1.bin / literals1.txt / etc. are HALSFC's outputs; pass1pA.rpt / halmat.bin / literals1p.txt / etc. (note the trailing/embedded "p") are HAL_S_FC.py's.

Each run creates a new numbered subdirectory under archive.results/; current.results is always a symlink-like pointer to the newest one, current-1.results to the previous one, current-2.results to the one before that, and so on. This makes it easy to compare a fresh run against earlier attempts while iterating on a fix. INCLIB.json, TEMPLIB.json, sdfpkg.py, and the archive.results/current*.results directories/files are all compiler-generated artifacts of this run, not source files — ignore them unless you're specifically inspecting compiler state.

For fast iteration once you have a specific hypothesis, PYONLY.sh runs HAL_S_FC.py alone (not HALSFC) against a given HAL/S file, producing pass1pA.rpt (and other artifacts) directly in the current working directory rather than in current.results/:

```
./PYONLY.sh <path-to-FOO.hal>
```

## Success criteria

A fix is complete only when a full HALSFC comparison run reports every generated output-file pair as identical — not merely "no compile errors." Passing PASS1 without errors is necessary but not sufficient: the generated HALMAT (FILE1.bin vs halmat.bin) can differ in ways invisible to the compiler reports themselves (e.g. mismatched statement-numbering metadata), which produces a subtly-wrong compiled program even though nothing looks wrong on the surface. If eliminating an error still leaves any file pair differing, keep digging — do not consider the bug fixed. If you run out of ideas, stop and inform the user rather than guessing or declaring victory prematurely.

You can also actually execute the generated HALMAT with yaHALMAT2 to check functional (not just byte-level) equivalence:

```
yaHALMAT2 @CURRENT        # runs HALSFC's compiled code (halmat.bin)
yaHALMAT2 --py @CURRENT   # runs HAL_S_FC.py's compiled code (FILE1.bin)
```

Note that functionally-identical execution does NOT guarantee the HALMAT files are byte-identical (metadata like statement numbers can be wrong without affecting runtime behavior), so this check complements, but doesn't replace, the file-comparison step above.

## Diagnostic techniques, in rough order of effort

1. **Read the compiler reports.** pass1A.rpt / pass1pA.rpt show the source line and any error messages. Error "classes" (e.g. "PF", "GL") and numbers can be located in the source by searching for "CLASS_xx" (XPL/I and Python) or "CLASSuxx" (HALSFC's C).

2. **Production traces.** Add the line `` DEBUG `8 `` (a literal backtick, preferred over a UTF-8 cent sign since the cent sign is awkward to embed in markdown/plain text, though HAL/S-FC accepts both), aligned at column 1, somewhere before the suspect statement. This causes both compilers to print every BNF production number they process into their reports as they parse the following code. Comparing the two traces side by side quickly localizes the first point where the two compilers' parses diverge. The BNF grammar and production numbers are listed at the start of ##DRIVER.xpl. This is usually the fastest way to localize a bug — but it only helps when the production *sequence* actually diverges. If the two traces are identical, the defect lies in what a shared production's *action code* does, not in which productions fire, and you need technique 3.

3. **Source comparison.** Once you know which production(s), routine(s), or ERROR() call site is implicated, read the corresponding code in all three of:
   - `../../Source Code/PASS.REL32V0/PASS1.PROCS/<NAME>.xpl` or `HALINCL/<NAME>.xpl` (search by PROCEDURE name if the filename isn't obvious) — the original, authoritative logic.
   - `../../Source Code/PASS.REL32V0/PASS1.PROCS/PASS1.build/<mangled-name>.c` — the mechanically-translated C, useful as a second opinion when the XPL/I is ambiguous, but not itself the porting target.
   - The corresponding `<NAME>.py` file in this directory (or its HALINCL/ subdirectory) — the hand-ported Python.

   Compare the Python translation against the XPL/I line by line, watching for the common porting-bug patterns below. Often the actual corruption happens several calls upstream of where the symptom (e.g. an ERROR() call) is observed, so be prepared to trace state backward through several routines, not just the one that reports the problem.

4. **HALMAT-level analysis.** If the compiler reports match but the compiled output (FILE1.bin vs halmat.bin) doesn't, or you need to see exactly what instructions were generated, recompile with `--parms=LISTING2` (see above), then from within current.results run:

   ```
   unHALMAT.py --listing2=listing2.txt halmat.bin > test-halmat.txt
   unHALMAT.py --listing2=LISTING2p.txt --litfile=FILE2.bin --memory=LIT_CHAR.bin FILE1.bin > test-FILE1.txt
   diff test-halmat.txt test-FILE1.txt
   ```

   (the first pair of files/args are HALSFC's, i.e. the reference; the second pair are HAL_S_FC.py's). Note that HAL_S_FC.py does not currently publish symbol-table information in a form unHALMAT.py can render, so large chunks of that section of the listing will differ superficially and can be ignored — focus on differences in the actual HALMAT instruction stream (opcodes and operands).

## Common HAL/S-FC -> HAL_S_FC.py porting-bug patterns

- Global variables defined in INITIALI.xpl (HAL/S-FC) are usually defined in g.py and referenced via the g. namespace in HAL_S_FC.py — e.g. PTR_TOP becomes g.PTR_TOP. Omitting the g. prefix, or using the wrong namespace, is an error.
- Other common namespaces: h (globals from HALINCL/COMMON), d (globals from HALINCL/CERRDECL), and similar per-include namespaces.
- XPL/I uses parentheses for both procedure argument lists and array index lists; Python requires brackets for array indices. Watch for XPL/I array references accidentally ported as function calls or vice versa.
- XPL/I lets integer-declared variables be used as ersatz arrays, referencing adjacent variables in memory (e.g. if I, J, K are consecutive integers, J[-1], J[0], J[1] may refer to I, J, K respectively). This kind of aliasing has no direct Python equivalent and needs case-by-case handling; check the original memory layout carefully if it's suspected.
- XPL/I lets an array-declared variable be referenced without an index, implicitly meaning its first element (e.g. C, declared as an array of two elements, means C(0) when written bare). Python requires an explicit index; a bare reference in the port is a bug (or, if intentionally ported as `[0]`, verify that's actually the right element every time — the correct index isn't always 0 when the "implicit" element isn't literally the first component of the array).
- XPL/I conditionals (IF/WHILE) test only the least-significant bit of the condition expression, as if "& 1" were implicitly appended. Usually harmless since conditions are already 0/1, but if the Python port omits the "& 1" where it does matter, the bug can be very hard to spot.
- XPL/I permits inline IBM System/360 machine code; these sections were replaced by hand with equivalent-effect Python, and that hand-translation can be wrong.
- XPL/I multiple assignment, "A, B, C = D", assigns D to C, then B, then A (conceptually right-to-left), but due to a bug in the original XPL compilers' code generation, the actual generated code sometimes assigns left-to-right (A, then B, then C) instead. This matters when a later target's evaluation depends on an earlier one (e.g. "A(I), I = B" differs from "I, A(I) = B"). Two sub-patterns to watch for specifically:
  - When the right-hand side is itself a single function/procedure call (e.g. `I,FIXL(MP)=ENTER(...)`), the correct translation calls the function *once* and assigns its result to *every* target (e.g. `g.I = ENTER(...); g.FIXL[g.MP] = g.I`). A subtly wrong port may compute the call, assign it to only one target, and then copy from a second variable that was never actually updated — silently propagating stale/garbage data. (This bit HAL_S_FC.py in issue #1337: `g.FIXL[g.MP] = ENTER(...); g.FIXL[g.MP] = g.I` clobbered the freshly-entered symbol reference with a stale `g.I`.)
- XPL/I `IF cond1 THEN ... ELSE IF cond2 THEN ...` chains must be ported as Python `if cond1: ... elif cond2: ...` — NOT as two independent `if` statements. Splitting an ELSE IF into a second unconditional `if` makes the second block execute even when the first one already fired, a subtle bug that manifests only when both conditions happen to be true simultaneously. (This also bit HAL_S_FC.py in issue #1337, in EMIT_SMRK's statement-number bookkeeping: `IF INLINE_STMT_RESET>0 THEN ... ELSE IF T THEN STMT_NUM=STMT_NUM+1;` was ported as two sequential `if`s, double-incrementing STMT_NUM whenever a reset was pending.)

When you find a new pattern that isn't in this list, add it here for next time.
