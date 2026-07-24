# Resuming yaHALMAT2 debugging in a new conversation

This file exists to let a brand-new conversation (no prior message
history) pick up yaHALMAT2 bug-fixing work at close to the same
effectiveness as a long-running session that's already built up context.
It's a supplement to `Maintenance.md`, not a replacement — **read
`Maintenance.md` first**; it's the durable, general workflow guide (where
things live, the bug-fix loop, conventions to preserve) and doesn't need
restating here. This file instead covers two things `Maintenance.md`
doesn't: primary-source material that's been extracted since it was last
updated, and a dense summary of *this specific run* of sessions' findings
and open threads, so a new session doesn't have to rediscover them from
scratch or accidentally contradict them.

## Primary sources now extracted (don't re-fetch or re-render PDFs for these)

All four are gitignored-with-exception (see `.gitignore`) and tracked
directly in git, `pdftotext -layout` dumps, page-separated by `\f`:

| File | Abbreviation used in docs | Covers |
|---|---|---|
| `source-documentation/USA003087.txt` | `[USA003087]` | "HAL/S Programmer's Guide" — general prose-level statement semantics (READ/WRITE/I-O formatting Sec. 12, etc.) |
| `source-documentation/USA003088.txt` | `[USA003088]` | "HAL/S Language Specification" — the *formal*, rule-numbered syntax/semantics spec; more precise than USA003087 when the two overlap (e.g. Sec. 10.1.1 vs. USA003087 Sec. 12.3 on READ) |
| `source-documentation/USA003090.txt` | `[USA003090]` (older docs sometimes say `[USA00309]` — same document, a citation typo predating this file's extraction, left as-is rather than mass-renamed) | "HAL/S-FC User's Manual" — Appendix C's execution-time-error "standard fixup" table (pp. 199-201) is the big one; also §8.2/§6.1.2-6.1.3 datatype/conversion rules |
| `source-documentation/ProgrammingInHALS.txt` | `["Programming in HAL/S"]` | Introductory 1978 textbook. **Not primary source** (generic to HAL/S, not this project's specific compiler) but influential/worth checking — often has the clearest worked examples, and this project's own `Source Code/Programming in HAL-S/*.hal` fixture corpus is drawn from it directly |

Full citation registry (what each abbreviation used throughout
`reengineered-documentation/` actually refers to) is
`reengineered-documentation/HALMAT.md`'s "References" table — check there
before assuming a bracketed citation is unexplained.

## What this run of sessions found and fixed (chronological, see STATUS.md for full detail)

Working tree is clean; all of this is committed. Recent commits, oldest
first:

1. **`5b04039ee`** — USA003090 Appendix C audit: every "standard fixup"
   this interpreter could implement (INVERSE/UNIT/SQRT/EXP/LOG/SIN/COS/
   TAN error conditions, 0**B≤0 and negative-base exponentiation, MSDV/
   VSDV division-by-zero, STOI SCALAR→INTEGER overflow) now applies its
   documented fixup instead of aborting. Along the way, found `MINV`
   (0x3CA) is HAL/S's **general matrix-exponentiation opcode** (`M**N`
   for any integer `N`), not INVERSE-only as previously documented — an
   earlier session mistook a literal-table *index* for the literal's
   actual *value* and concluded the operand was unrelated.
2. **`e116ad546`** — `ON ERROR`'s user-statement (`GO TO`) form was a
   complete no-op at runtime (an earlier session's comment wrongly
   assumed a separate `BRA` skipped the inline handler body; it doesn't
   — that skip is part of `ERON`'s own object code). Implemented a real
   handler table and wired it into every Appendix C fixup site from
   commit 1.
3. **`82370c6fb`** — `READ` fields separated by commas (`"1,2,3"`) failed
   outright (`fscanf`'s `%lf`/`%ld` skip whitespace but not commas).
   Fixed, and while verifying the fix against a full real program, found
   `EXIT loop-label;` also completely broken (`precompute_labels()` only
   understood `LBL`, not the `DTST`/`ETST` bookkeeping-label pair `EXIT`
   actually targets) — fixed that too.
4. **`b02dc1c8b`** — added a project-specific exception to
   `~/.claude/CLAUDE.md`'s "never edit `*.md` without 'Full Documentation
   Sync'" rule, in `yaHALMAT2/CLAUDE.md` — **not this file's concern, see
   that file directly; deliberately not duplicated or overridden here.**
5. **`6f54f1b1e`** — a *leading* comma (`",2,3"`) still failed after (3)
   — naively reusing the same "consume one separator" logic for the
   first list item shifts the whole remaining list over by one instead
   of nulling just the first item. Needed a real two-shape fix
   (`require_separator` parameter), not just removing a guard.
6. **`7c5f806e1`** — a semicolon in `READ` input was still a hard parse
   error. USA003088 rule 5 (confirmed independently by "Programming in
   HAL/S" §8.3's own worked example) says a semicolon terminates the
   *whole remaining list*, not just one field like a comma does — this
   is HAL/S's documented "process a variable number of input values"
   idiom. Also took two attempts: the first pass's "no comma found here,
   must be space-only separation" early-return path skipped the
   semicolon check entirely.

**Pattern worth noting for future debugging**: more than one of the
above bugs was only fully caught by testing the *complete* user-supplied
repro (or a primary source's own full worked example) end-to-end, not
just the narrowly-described symptom — isolated/simplified test cases
missed real misalignment and hang bugs that only showed up against real
data. Don't declare a fix done until the original full repro runs clean.

## Known open items, not yet resolved

- `ON ERROR`'s handler table is flat/global — USA003087 Sec. 25.1's
  per-block dynamic-scoping rule (a modification made inside a
  `PROCEDURE`/`FUNCTION` unwinds on return from it) isn't implemented.
- `ON ERROR ... IGNORE`'s exact effect on a *value-producing* built-in
  (as opposed to a procedural side-effect error) isn't spelled out by
  primary-source examples; currently treated the same as `SYSTEM`.
- Only the Appendix C errors this interpreter has fixups for at all
  consult the `ON ERROR` table — errors for genuinely unimplemented
  functions (`MOD`, `REMAINDER`, `LJUST`/`RJUST`, `ARCSIN`/`ARCCOS`/etc.,
  `BIT@OCT`/`BIT@HEX`, subscripted `SUBBITn TO m(...)`) obviously don't,
  since there's no fixup site to wire in yet.
- Whether a same-unit `FUNCTION` reaching `CLOSE` without executing
  `RETURN` is handled at all (App. C error 14) is unclear —
  `interp_copy_external_call_result()` has an explicit check for
  *cross-unit* calls only; not investigated.

## Tooling/environment notes (would otherwise need rediscovering)

- **Compile a `.hal` fixture for real**: `HALSFC` is at
  `"Source Code/PASS.REL32V0/HALSFC"` (relative to `yaShuttle/`). Copy the
  source into a scratch dir, `cd` there, run
  `HALSFC --parms="LISTING2,LSTALL" file.hal` (the parms enable the
  reports `unHALMAT.py` needs). Decode with
  `python3 ".../PASS.REL32V0/unHALMAT.py" halmat.bin` — if the file is
  literally named `halmat.bin`, it auto-discovers `litfile`/`memory`/
  `common` companions, no extra flags needed.
- **The shell here runs through an `rtk` hook** that rewrites most
  commands and resets `cwd` back to the project root after *every* Bash
  tool call — chain `cd`+work in one call, don't rely on `cd` persisting
  across calls. Compound `find` predicates (`-o`, multiple `-iname`) need
  `rtk proxy find ...` (raw, unfiltered) instead of plain `find`.
  `printf` format strings starting with `-` need `printf -- '...'` or
  bash's `printf` treats it as an option.
- **`HALSFC` self-modifies** a `filesPorted` list in its own script file
  as a side effect of being run (observed as an unstaged, unrelated
  working-tree change after compiling fixtures) — not something to
  commit or worry about; leave it alone.
- **Compile artifacts accumulate** as untracked files (`COMMON5.out`,
  `CURRENT`, `SDFLIB/`, `current.results`, etc.) in whatever directory a
  `.hal` file gets compiled in, including pre-existing ones scattered
  around this repo from before — never delete or `git add` these
  reflexively; they aren't necessarily yours to manage, and none of the
  commits above touch them.
- **A real compiler quirk, not a bug**: assigning a *whole-number*
  literal to a variable on its first-ever write (e.g. `S2 = 99.0;` where
  `S2` was never `INITIAL(...)`'d) compiles to `IASN` (INTEGER assign)
  rather than `SASN`, making that `SYT` slot display in INTEGER format
  thereafter even though it's declared `SCALAR`. Confirmed via real
  `unHALMAT.py` decode, not an interpreter bug. When writing test
  fixtures, use a fractional first-write value (e.g. `99.5`) to avoid
  this tripping up expected-output strings.
- **Testing**: `src/tests/run_all.sh` is the full suite — run it (and
  `make clean all` first) before considering any fix done.
  `run_local_fixture.sh`/`run_read_fixture.sh` compile a
  `src/tests/hal/test_*.hal` fixture with real `HALSFC` and diff actual
  output; get the *actual* output once via
  `run_local_fixture.sh NAME ""` (empty expected) rather than hand-typing
  expected strings, to avoid transcription mismatches.
- **Git**: user has given standing permission to commit once
  `run_all.sh` passes clean, without asking each time — but stage files
  explicitly by name (never `-A`/`-u`), since this repo's working tree
  routinely has unrelated pre-existing untracked/modified files (compile
  artifacts, other in-progress edits elsewhere in the monorepo) that
  aren't part of the current fix and shouldn't be swept into a commit
  incidentally.

## Working style this user has confirmed/corrected on

- Wants primary-source verification via real compiled HALMAT
  (`HALSFC`/`unHALMAT.py`), not inference from memory or documentation
  prose alone — matches `Maintenance.md`'s own loop, but worth
  internalizing as a hard preference, not just a suggestion.
- Cites exact primary-source section/page numbers and expects the same
  in return; will push back with a specific counter-citation if a fix's
  reasoning is shaky (e.g. correctly identified that Figure 12-4 in
  USA003087 contradicted an initial "short line ends the READ list"
  hypothesis before it was implemented).
- Willing to have their own speculation checked against primary sources
  and corrected rather than implemented blindly — treat their hypotheses
  as starting points to verify, not instructions to implement as-is.
- Wants the full regression suite run, clean, before anything is
  reported as done — including re-running the *original* full repro,
  not just the isolated new fixture.
