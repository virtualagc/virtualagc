# Maintenance Guide for yaHALMAT2

Plan.md records how this project was originally built, in three phases (HALMAT
documentation reverse-engineering, then deeper compiler-source-driven
reverse-engineering, then the yaHALMAT2 emulator itself). All three phases are
complete. This file is for what comes after: fixing bugs and adding features to
the finished emulator. It assumes Plan.md's background and doesn't repeat the
phase-by-phase history — read Plan.md once if that context is ever needed, but
day-to-day work should only need this file plus `reengineered-documentation/`.

## Where things live

- `src/` — yaHALMAT2 itself (C, `make clean all` to build). `src/tests/hal/`
  holds HAL/S source fixtures; `src/tests/run_all.sh` is the full regression
  suite (run it after any `interp.c`/`value.c` change, before considering a fix
  done). `run_local_fixture.sh NAME EXPECTED [EXTRA_ARGS...]` compiles
  `hal/test_NAME.hal` with real HALSFC and diffs yaHALMAT2's output against
  `EXPECTED`; extra args (e.g. `--time-scale 1000000`) pass straight through —
  use a large `--time-scale` for any fixture with a real `WAIT`/`SCHEDULE`
  delay so the test doesn't actually sleep that long.
- `reengineered-documentation/` — the durable reference. `HALMAT.md` is the
  top-level index; `class-0/` through `class-8/` hold one file per opcode;
  `STATUS.md` is the cross-session log of what's been confirmed and how
  (mostly Phase 1/2 history, but still the place to log a new bug fix's root
  cause and citation); `MULTI-FILE-LINKING.md` covers the multi-unit `@list`/
  linked-archive mechanism.
- `source-documentation/` — primary-source PDFs and derived text (gitignored,
  regenerate/refetch if missing). `USA003087.txt` is a full `pdftotext -layout`
  dump of the HAL/S Programmer's Guide (441 pages, page-separated by `\f`) —
  grep or page-index it directly instead of re-rendering PDF pages; hand-drawn
  figures still need `pdftoppm -r 300 -png` + a visual read, text extraction
  scrambles those. If a needed PDF isn't here, check
  `~/Desktop/sandroid.org/public_html/apollo/Shuttle/`, `../../../virtualagc-web/`,
  and `../../../Halmat/` (both siblings of the `virtualagc` repo itself) before
  assuming it's unavailable.
- `../Source Code/PASS.REL32V0/` — the real HAL/S-FC compiler source (XPL/I)
  and a working `HALSFC` binary. `unHALMAT.py`/`unLitfile.py` there decode
  HALMAT/literal files to text (the *original* `unHALMAT.py` — treat it as
  shared infrastructure, not a scratch file). `##DRIVER.xpl` in each pass's
  `.PROCS/` directory declares that pass's opcode/qualifier constants;
  grepping the whole source tree for an `X`-prefixed constant name (not just
  its declaration) is the single most reliable way to find the deciding logic
  for any opcode's behavior.
- `../../../Halmat/` — Zane Hambly's yaHALMAT (OCaml) repo clone: reference
  emulator binary, plus `data/test_*.hal` fixtures with prebaked compiled
  output, used as an independent ground-truth cross-check (never as primary
  evidence).
- `/home/rburkey/temp/` — default location to check for a HAL/S file the user
  mentions without a path.

## The bug-fix / feature loop

This is the technique that resolved every issue found in this project's
maintenance phase so far:

1. **Reproduce for real.** Compile the reported (or a minimal) `.hal` file with
   `HALSFC --parms="LISTING2,LSTALL"`, then decode `halmat.bin` with
   `unHALMAT.py` (needs `--listing2=pass1.rpt --litfile=... --memory=...
   --common=...`, run from the directory holding the compiled output). This is
   ground truth — don't guess at HALMAT shape from documentation or memory.
2. **Cross-reference the compiler source** when the wire format alone doesn't
   settle the question: grep `PASS.REL32V0/*.PROCS/` for the opcode's
   `X`-prefixed constant, or for a suspected keyword's grammar rule in
   `SYNTHESI.xpl`. `pass2.rpt` (via `LSTALL`) interleaves HALMAT with generated
   AP-101S assembly and original source lines, but its own print order can
   diverge from true stream order (`SMRK` is the known offender) — trust a
   direct `unHALMAT.py` binary read over the report's visual layout.
3. **Fix in `src/interp.c`** (or wherever the bug actually is), matching the
   file's existing style: comments explain *why*, cite the primary source
   section/page when a behavior comes from one, and fail loudly rather than
   guess when a case genuinely isn't handled yet.
4. **Add a regression fixture**: a new `src/tests/hal/test_*.hal`, its expected
   output captured from a real run, wired into `run_all.sh` with a comment
   explaining what it exercises and why it used to fail.
5. **Update `reengineered-documentation/`** — the relevant opcode file(s) and
   `STATUS.md` — with the finding, its citation, and how it was confirmed.
   Resolve any "Unresolved Questions" bullet the fix happens to settle.
6. **Rebuild clean and run the full suite** (`make clean all`, then
   `run_all.sh`) before calling anything done. A prior fix's own regression
   fixture failing is not automatically a new bug — check whether the fixture's
   *expected* value baked in the old, buggy behavior and needs updating instead
   (this has happened more than once).

## Conventions to preserve

- **Documentation files** (`reengineered-documentation/class-*/*.md`): heading
  order is Mnemonic, Opcode, Confidence, Behavioral Description, Usage
  Context, Unresolved Questions, Source Analysis & Reliability. Prefer citing
  primary sources (USA003087, IR-60-5, MSC-01847, `##DRIVER.xpl`/compiler
  source) over `Halmat.pdf`, which is secondary/comparative only. Avoid
  referring to individuals by name; cite documents and page numbers instead.
- **Sourcing precedence**: primary HAL/S-era source > predecessor-language
  (HAL 1971) source used as a cross-language inference > this project's own
  empirical compiled-output confirmation > `Halmat.pdf`/yaHALMAT as an
  independent but non-authoritative check.
- **Tooling**: prefer lightweight, targeted text extraction (grep/regex/line-
  based) over building a general XPL/I parser; prefer compiling and
  disassembling real test programs over static inference from source
  structure alone.
- **yaHALMAT2 design invariants** — don't casually violate these when adding a
  feature: cross-platform build (`clang` default on Linux/Mac, falling back to
  `gcc`; MSVC on Windows, `clang`/`gcc` under MSYS2 — always overridable on the
  `make` command line); no GUI; arithmetic is bit-exact AP-101S single/double
  precision, not native-double approximation; `--debug` mode mimics a useful
  `gdb` subset; device-mapping options (`--ddi`/`--ddo`/`--raf`) follow
  the historical HALSFC runtime's own option shapes; the real-time scheduler
  (`SCHEDULE`/`WAIT`/priority/`REPEAT`) runs on a virtual/logical clock, with
  `--time-scale` only affecting wall-clock pacing, never tick arithmetic or
  program output.
- **Never modify `unHALMAT.py`/other shared original tooling** casually if a
  past instruction says otherwise for a specific file — check for such
  constraints before editing something outside `src/`.
