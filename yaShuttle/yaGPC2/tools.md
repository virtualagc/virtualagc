# HAL/S Compiler & AP-101S Toolchain Reference

Notes carried over from work in `yaHALMAT2` (a HALMAT bytecode
interpreter/emulator project), written up here for use from
`~/git/yaGPC/yaGPC/`. All paths below are given relative to that
directory.

## The toolchain, end to end

A HAL/S source file goes through three stages to actually run:

1. **`HALSFC`** (compiler front end) — HAL/S source (`.hal`) -> AP-101S
   object code (`.obj`) [+ a `halmat.bin`/report files, depending on
   options].
2. **`lnk101`** (linker) — object code -> a loadable "FCM" image
   (`.fcm`) [+ a JSON symbol-table file].
3. **`gpc run`** (or **`yaGPC`**, this project's own emulator) — loads
   and executes the `.fcm` image.

`compileLinkRun` (see below) automates all three steps for a
single-file standalone program.

Binaries (`HALSFC`, `lnk101`) live under:

    /home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/

and must be on `PATH` for the scripts below to find them.

An AP-101S assembly-language files goes through similar steps, except that instead of the compiler `HALSFC`, the AP-101S assembler `ASM101S` is the first tool used. [Usage of `ASM101S` is documented here](file:///home/rburkey/Desktop/sandroid.org/public_html/apollo/ASM101S.html#ASM101S).

## `HALSFC`

```
HALSFC [OPTIONS] SOURCE.hal
```

Compiles HAL/S source to AP-101S object code, using "modern" ports of
the original Intermetrics/USA HAL/S-FC compiler passes
(`HALSFC-PASS1[.exe]`, etc. — all must be on `PATH`).

Key options:
- `-o F` — object-file/folder output name (default `cards.bin` for
  PFS, `cards/` for BFS).
- `--parms="..."` — comma-separated HAL/S-FC compiler options (quote
  for Windows compatibility). If omitted (or no `CARDTYPE=...` given),
  a default `CARDTYPE` is supplied automatically.
- `--test` — also run all available validity tests (requires
  `NOTABLES` in `--parms`; requires `diff`, `egrep`, `HAL_S_FC.py` on
  `PATH`).
- `--force` — force a `HAL_S_FC.py` compilation even if
  `HALSFC-PASS1[.exe]` failed.
- `--no-opt` — skip optimization passes; generate object code from
  unoptimized HALMAT.
- `--bfs` — use the BFS build of HAL/S-FC (default is PFS).
- `--exe` — use the Windows port (default on Windows; also usable on
  Linux/macOS via WINE if installed).
- `--clean` — remove compiler workfiles/results from the current
  directory (kept only under the results directory).
- `--archive` — put results directories (`"HALSFC ...".results`) under
  `archive.results/` instead of the current directory.
- `--debug=X` — hex debug flagword passed to the compiler passes (bit
  0: PASS2 prints messages in `SAVE_LITERAL`).
- `--verbose` — print the underlying command lines.

If `SOURCE.hal` begins with `_` (or `./_`), it is *moved* rather than
copied into the results directory — avoid a leading underscore in
HAL/S filenames for this reason (that prefix is normally reserved for
compiler-internal preprocessed files).

## Getting HALMAT and AP-101S assembly out of the compiler reports

The compiler passes can be made to print their intermediate
representations via HAL/S-FC's own compile-time options, passed
through `--parms`:

- **`HALMAT`** (abbreviated `HM`) — makes PASS1's `pass1.rpt` print
  each HALMAT instruction (`HALMAT LINE N: <opcode>(<numop>),<tag>,
  <extra>` plus operands) interleaved with the HAL/S source listing.
  Example: `HALSFC --parms="HALMAT,LIST,LISTING2" file.hal`. Noisy (a
  full scanner/parser trace prints regardless of other options) —
  worth piping through `grep`.
- **`LSTALL`** — makes PASS2's report (`pass2.rpt`) include HALMAT,
  the generated AP-101S **assembly/object code**, and HAL/S source
  statements (by statement number) all interleaved. This is the way
  to get real generated assembly (`LHI`, `STH`, `IAL`, `LA`, etc.)
  with addresses out of the compiler.
  - **Gotcha**: `LSTALL` internally *toggles* debug bits `¢5`/`¢6`. If
    the source file's own `DEBUG` line already has `¢5`/`¢6` on,
    combining it with `LSTALL` silently cancels back to off and
    `pass2.rpt` looks unchanged. Use a source file with no conflicting
    `¢5`/`¢6` codes, or write the `DEBUG` line using explicit
    `¢5+¢6+` (turn-on) rather than the bare toggling form.
  - Recommended invocation: `HALSFC --parms="LSTALL" file.hal`, then
    read the resulting `pass2.rpt`.
- **`LISTING2`** — used together with the above; also useful on its
  own with `unHALMAT.py` (a raw-binary HALMAT reader) for a
  ground-truth cross-check of `pass2.rpt`'s text output, since
  `pass2.rpt` prints operand words out of textual order in some cases
  (after the consuming instruction, not before) — worth reading the
  binary directly (`unHALMAT.py`) rather than trusting the report's
  visual layout when operand order actually matters.

Statement numbers in `pass2.rpt` cross-reference back to source text
via PASS1's own report (which prints statement numbers against source
lines), since PASS2's report only labels statements by number.

## `lnk101`

```
lnk101 OBJFILE -o FCMFILE --json-symbols SYMFILE
```

Links one or more `.obj` files produced by `HALSFC` into a single
loadable FCM image, and (with `--json-symbols`) emits a JSON
symbol-table file consumed by the emulator (`gpc run --symbols ...`)
for symbolic tracing/disassembly. If linking fails, the fallback tool
is `rldanalyze SYMFILE FCMFILE OTHERFCM --csect-table CSECTS.json
--show-gaps --show-csects --scan-gaps` (diagnoses CSECT/relocation
gaps between images).

## `gpc run` / `yaGPC`

The AP-101S emulator that actually executes a linked `.fcm` image.
Two implementations exist:

- **`gpc run`** — presumably the "real"/reference AP-101S emulator
  (used as the default, and as a ground-truth cross-check against
  this project's own emulator).
- **`yaGPC`** (this project) — invoked as a single command (no `run`
  subcommand needed, per `compileLinkRun`'s usage), or via
  `GPC.sh`:
  ```
  GPC.sh run <fcm>       # batch execution
  GPC.sh debug <fcm>     # interactive REPL debugger
  GPC.sh gui [fcm]       # Electron GUI debugger
  GPC.sh dump <fcm>      # FCM dump report
  GPC.sh disasm <fcm>    # disassembly listing
  ```
  `GPC.sh` auto-builds the JS bundle before running.

Common invocation flags (as used by `compileLinkRun`, see below):
`--interactive --no-trace --no-verbose --symbols SYMFILE
--line-width 240 FCMFILE`.

## `compileLinkRun` — one-shot compile/link/run

    /home/rburkey/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0/compileLinkRun

A Python script that chains `HALSFC` -> `lnk101` -> `gpc run` (or
`yaGPC`) for a single standalone HAL/S file, cleaning up intermediate
`.obj`/`.fcm` files afterward.

```
compileLinkRun [OPTIONS] --filename=F
```

- `--filename=F` (required) — path to the HAL/S source file (`~` and
  `$VAR` are expanded).
- `--parms=P` — full override of the default HAL/S-FC `--parms` list
  (default is roughly `LIST,NOTABLES,SRN,TEMPLATE,NOLFXI,REGOPT,
  VARSYM,CARDTYPE=...`, with the `CARDTYPE` value chosen by matching
  the filename against a small hardcoded table).
- `--extra-parms=P` — extra options *prefixed* to the defaults
  (must end in a comma).
- `--extra-pass1=P` — extra modern/native `HALSFC` command-line flags
  (space-separated, no embedded spaces even quoted), e.g.
  `--extra-pass1="--pretty-bnf --verbose"`.
- `--interactive` — show raw emulator output and allow `READ(5)` input
  interactively, instead of the default mode (which captures output
  and prints only `OUTPUT(6)`-prefixed lines, filtering emulator
  noise). This is the default in the current script version.
- `--no-test` — skip HALSFC's `--test` option (by default, `--test
  --force --clean --archive` are all added automatically).
- `--yaGPC` — run the compiled program with `yaGPC` instead of the
  default `gpc run ...`.

Use this as the primary way to cross-check a `yaHALMAT2`/`yaGPC`
emulator finding against the real AP-101S emulator (`gpc run`) — but
sparingly, not as a routine step, since it's a real compile+link+run
cycle with meaningful overhead.

## `yaHALMAT2`'s test suite

Location (relative to here): `/home/rburkey/git/virtualagc/yaShuttle/yaHALMAT2/src/tests/`

- `run_all.sh` — the full permanent regression suite (currently ~169
  `test_*.hal` fixtures under `src/tests/hal/`). Intended to be run
  after any `interp.c`/`value.c` change, and before every commit. Some
  fixtures derive their expected output live from a reference
  `yaHALMAT` emulator build (`$REF_YAHALMAT`, a sibling project) run
  against `HALSFC`-compiled HALMAT, rather than hardcoding expected
  strings by hand.
- `run_fixture.sh` / `run_link_fixture.sh` / `run_link_container_fixture.sh`
  / `run_debug_link_fixture.sh` / `run_ext_func_fixture.sh` /
  `run_local_fixture.sh` / `run_py_fixture.sh` / `run_raf_fixture.sh` /
  `run_read_fixture.sh` / `run_realtime_fixture.sh` /
  `run_walltime_fixture.sh` — individual fixture-runner scripts for
  different test shapes (single-file, multi-file linking, container
  arguments, external functions, I/O, timing, etc.), each invoked from
  `run_all.sh`.
- `hal/test_*.hal` — the HAL/S source fixtures themselves, one per
  regression case, generally named/commented after the real-world
  sample program or bug report that motivated them.

Build the emulator itself from `/home/rburkey/git/virtualagc/yaShuttle/yaHALMAT2/src/`:
`cd` into that directory and run `make clean all`. The test shell
scripts are Linux-only (untested on Windows).

## Documentation sources (yaHALMAT2's reengineered documentation)

Location (relative to here):
`/home/rburkey/git/virtualagc/yaShuttle/yaHALMAT2/reengineered-documentation/`

- `HALMAT.md` — top-level HALMAT intermediate-language documentation
  (word format, block structure, qualifier tables).
- `class-0/` .. `class-8/` — one `.md` file per HALMAT opcode,
  grouped by instruction class, each with Behavioral Description,
  Usage Context, Operand-Word Format, Implementation Notes, and
  Source Analysis & Reliability sections.
- `STATUS.md` — the cross-session progress tracker: what's been
  reviewed, open questions, and (most usefully here) the empirical
  notes on compiler report switches (`HALMAT`, `LSTALL`, etc. — see
  above) and the primary/secondary source review table.
- `MULTI-FILE-LINKING.md` — notes specific to multi-file HAL/S linking
  via `lnk101`.

Primary/secondary sources referenced throughout (full text extracted
to `.txt` for cheap `grep`/`pdftotext` lookups where noted), under
`/home/rburkey/git/virtualagc/yaShuttle/yaHALMAT2/source-documentation/`:

- **[USA003087]** "HAL/S Programmer's Guide" — the primary
  human-readable reference for HAL/S statement syntax/semantics.
  Extracted to `USA003087.txt`.
- **[USA003088]** "HAL/S Language Specification" — the formal
  syntax/semantics companion to the Programmer's Guide (more precise,
  rule-numbered). Extracted to `USA003088.txt`.
- **[USA003090]** "HAL/S-FC User's Manual" (also cited elsewhere as
  `[USA00309]`, a pre-existing typo left as-is) — compiler-user-facing
  manual; Appendix C tabulates execution-time error "standard
  fixups." Extracted to `USA003090.txt`.
- **[Programming in HAL/S]** (Sept. 1978) — an introductory textbook,
  *not* a primary source for the compiler itself, but the source of
  this project's `Source Code/Programming in HAL-S/*.hal` worked-example
  regression corpus. Extracted to `ProgrammingInHALS.txt`.
- **[MSC-01847]** "HALMAT: An Intermediate Language" — describes the
  *predecessor* language HAL (1971), not HAL/S (1977); used as
  corroborating/background material for HALMAT's general shape. Split
  into `MSC-01847.part{1,2,3}.pdf` (original exceeds the Read tool's
  100 MB extraction limit).
- **[##DRIVER.xpl]** — `PASS1.PROCS/##DRIVER.xpl` in the actual
  compiler source tree itself declares every HALMAT opcode as a named
  XPL/I constant; the single most authoritative source available for
  opcode numbers, since it's what the real compiler itself uses.
- **[IR-60-5]** "HAL/S-360 Compiler System Specification" — another
  secondary cross-reference for HALMAT opcode tables.
- **[Halmat.pdf]** — the Zane Hambly "Halmat" repository's own PDF
  documentation (this project follows that repo's general approach).
- **[CourseSlides.pdf]** "Basic HAL/S Programming Course" — informal
  training slide deck; occasionally has implementation-level detail
  (CSECT/ESD/linkage) not found in the formal manuals.

If a needed primary-source PDF isn't already in `source-documentation/`,
check (paths relative to the `yaHALMAT2` directory, not here):
`/home/rburkey/Desktop/sandroid.org/public_html/apollo/Shuttle/` or
`/home/rburkey/git/virtualagc-web/` — nearly everything shows up in
one of those.
