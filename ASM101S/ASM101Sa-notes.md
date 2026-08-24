# ASM101Sa — the C port of ASM101S

`ASM101Sa` is a C port of the Python program `ASM101S.py`: about 13,000 lines 
of Python as roughly 25,500 lines of C99. The executable it 
builds is called `ASM101Sa` (or `ASM101Sa.exe` in Windows).  Its command line, its listing, its object 
module and its diagnostics are those of `ASM101S.py`; it is meant to be a 
drop-in replacement, and is tested as one. While `ASM101S.py` is the official
implementation of the AP-101S assembler, it can be slow to operate, and 
`ASM101Sa` is provided in order to optionally provide the same capabilities but
with much quicker operation.

`ASM101Sa` does provide one command-line switch (`--version`) not present in 
`ASM101S.py`, in order to give the version of `ASM101S.py` (in terms of a git 
hashtag) which it ports. `ASM101Sa` is not necessarily updated for every update of `ASM101S.py`,
in which case the hashtag given by `--version` may not coincide with the hashtag
of the most-recent version of `ASM101S.py` itself.

## Building

The source is in `ASM101Sa-src/`, and the build puts the executable in the
directory above it — this one, alongside `ASM101S.py` — so that a single
directory on the `PATH` offers both assemblers.

| Platform | Command |
| --- | --- |
| Linux, macOS | `make -C ASM101Sa-src` |
| Windows, Visual C++ | `cd ASM101Sa-src` then `nmake /f Makefile.msvc` |
| Windows, MinGW-w64 / MSYS2 / Cygwin | `cd ASM101Sa-src` then `make -f Makefile.mingw` |

The source directory is not itself called `ASM101Sa`, because a directory and a
file of that name cannot both exist here and the file is the point. On Windows
the `.exe` suffix would hide the clash, so it would surprise whoever next built
on Linux rather than failing where it was introduced.

Windows gets its own makefiles because it has no GNU-compatible `make`, and
`nmake`'s syntax differs from GNU `make`'s in enough places that one file cannot
serve both without becoming unreadable. The sources themselves carry no
platform conditionals beyond the shims in `common.h`.

Useful options for the GNU makefile:

```
make -C ASM101Sa-src CC=clang           build with clang rather than the default
make -C ASM101Sa-src DEBUG=1            unoptimised, with symbols
make -C ASM101Sa-src ASAN=1             AddressSanitizer + UndefinedBehaviorSanitizer
make -C ASM101Sa-src install PREFIX=... install to $(PREFIX)/bin, default /usr/local
make -C ASM101Sa-src BINDIR=.           build the executable in ASM101Sa-src/ instead
make -C ASM101Sa-src clean
```

Both gcc 13 and clang 18 build it clean at `-Wall -Wextra`, and the two
compilers' executables agree on every module of the regression corpus.

> **Note**: The remainder of the document was written in its entirety by Claude Code A.I., which ported the software, and contains notes about the porting process that are likely not of interest to most people. Specific file-system paths, for example, coincide with those in Claude Code's local environment, and won't correspond to anything on other computer systems.

`-fwrapv` is not optional. A symbol's value is a hashcode of up to 28 bits
shifted left by 36, so it reaches bit 63, and the differences the assembler
takes between such values rely on wrapping being defined. The arithmetic that
matters goes through the `ASM_ADD`/`ASM_SUB`/`ASM_MUL` macros in `common.h`,
which work on unsigned types and so are well defined everywhere; `-fwrapv`
guards against a stray signed operation elsewhere becoming undefined behaviour.

## Which version this is a port of

`ASM101Sa --version` answers this, and `--help` names the commit in its first
two lines:

- virtualagc **`105ad9afb`** (2026-08-15 21:18:29), *"ASM101S: a bare END names
  no entry point, so do not invent one"* — complete, with nothing carried over
  separately and nothing missing.

That is the most recent commit to touch any of the ten ported `.py` files. The
repository was at HEAD `dc5b97707` when the parity pass was made, and the
commits between the two changed none of them. Naming the last commit that
actually altered the assembler, rather than whatever HEAD happened to be, is
what makes the claim checkable.

**Do not compute it as "the last commit touching `ASM101S/`".** That was the
rule while the port lived outside the repository, and it broke when
`ASM101Sa-src/` moved in: the port's own commits now touch `ASM101S/`, so the
rule answers with them and the constant looks perpetually stale. It first
misfired at `522a96c84`, *"Added ASM101Sa."* Restrict the pathspec to the
Python — list the ten files, or exclude the port:

```
git log -1 -- ASM101S/ ':(exclude)ASM101S/ASM101Sa-src/' \
                       ':(exclude)ASM101S/ASM101Sa-notes.md'
```

The distinction matters because a check that cries stale on every commit gets
ignored, and then a genuinely stale port goes unnoticed.

To ask whether this port *is* stale — the question the constant exists to
answer, and a one-liner now that the two live in one directory:

```
git log --oneline 105ad9afb..HEAD -- ASM101S/ASM101S.py ASM101S/expressions.py \
    ASM101S/fieldParser.py ASM101S/parser_asm.py ASM101S/model101.py \
    ASM101S/model101tables.py ASM101S/ibmHex.py ASM101S/asciiToEbcdic.py \
    ASM101S/objectWriter.py ASM101S/readListing.py
```

Empty output means in sync. Anything listed is exactly what the next parity
pass must carry over.

It has already paid for itself. Between two sweeps of the same corpus the
repository moved 50 commits, `dc5b97707` to `10bea05ab`; the check returned
empty — all of it was yaGPC2/yaHALMAT2 work — so the Python comparison was known
to be valid *before* it was run rather than hoped to be afterwards. The old
"last commit touching `ASM101S/`" rule would have flagged all 50 and told you
nothing.

`version.h` is the single place any of that is written down —
`PORTED_FROM_COMMIT`/`_DATE`/`_SUBJECT`, an optional `PORTED_EXTRAS` for
changes carried over individually, and an optional `PARITY_INCOMPLETE` printed
as a warning. The last two are currently undefined, which is the state to aim
for, and the file documents the format to use if either is needed again. Update
it in the same commit as any parity work.

**`version.h` must stay in the `HEADERS` list of `Makefile` and
`Makefile.msvc`.** It was in neither when the constant was first introduced, so
editing the provenance rebuilt nothing and `--version` went on printing the old
commit — silently, which is the one failure mode a hand-maintained constant is
supposed to be immune to. After any `version.h` edit, run the binary and check
that it reports what the file says.

**It is deliberately not derived from `git rev-parse HEAD` at build time.**
That would make the binary claim parity with whatever happened to be checked
out when someone typed `make` — a statement nobody has checked, and one that is
wrong more often than right while the assembler is under repair. A
hand-maintained constant fails only to forgetfulness, and then it understates
rather than overstates. The parity line is part of the answer too: a bare
hashcode implies "this is that version", and that is false while anything is
missing.

`--version` exits 0. `--help` exits 1, which is what `ASM101S.py` does and is
matched deliberately rather than by accident.

## Generated sources

Two files are **generated and committed**, and must not be hand-edited:

| File | Generated from | By |
| --- | --- | --- |
| `parser_asm.c` | `parser_asm.py` | `tools/xlate.py` |
| `tables.c` | `model101tables.py`, `ASM101S.py` | `tools/gentables.py` |

```
make -C ASM101Sa-src regenerate
```

`ASM101S=` names the directory holding `ASM101S.py` and defaults to `..`, which
is now the right answer; pass it only to regenerate against a Python assembler
somewhere else.

Both are generated rather than transcribed for the same reason: their content
is already the output of a generator or of a loop. `parser_asm.py` is TatSu's
own output for the grammar embedded in `fieldParser.py`, and translating it
mechanically keeps a statement-for-statement correspondence, which is the only
practical way to check that a grammar of that size was carried over correctly.
Several of the instruction tables are built by loops in `model101tables.py` —
the `$`, `@` and `#` suffixed spellings, the `argsSRSorRS` union, the
per-operation parsing rules — and transcribing the *result* of those loops by
hand is exactly the sort of thing that goes wrong silently and shows up as one
wrong opcode in one module.

To change the grammar: edit `fieldParser.py`, run `fieldParser.py --generate`
to renew `parser_asm.py`, then `make -C ASM101Sa-src regenerate`.

## How the port is arranged

Most of the code is a direct transliteration, and reads alongside its Python
original. Four pieces needed design rather than translation.

**`val.[ch]` — a Python-shaped dynamic value.** The assembler does not consume
an abstract syntax tree of its own devising; it consumes TatSu's concrete
syntax tree, and it recognises the parts of it by *shape* — sixty-odd places
test things like `len(x) == 5 and x[1] == "(" and x[4] == ")"`. A faithful port
therefore has to preserve those shapes node for node, including three
distinctions Python draws that C does not: a tuple is what a rule returns when
it has no named elements while a *list* is what an accumulating capture
returns; `tatsu.contexts.closure` is a list *subclass* for which TatSu's own
`is_list` (an exact type test) is false, which is the entire reason a `{ ... }`
repetition becomes one element of the enclosing sequence rather than being
spread across it; and an AST is an insertion-ordered dict whose declared keys
are seeded ahead of its captured ones. Re-typing the trees would have meant
re-deriving every one of those tests, which is where a port of this kind goes
wrong.

**`peg.[ch]` — the TatSu runtime.** A reimplementation of exactly as much of
`tatsu/contexts.py` as the generated parser uses, written against that source
rather than against the documentation. A survey of `parser_asm.py` finds only
`_token`, `_pattern`, `_check_eof`, `_choice`, `_option`, `_optional`,
`_group`, `_closure`, `_define`, `name_last_node`, `add_last_node_to_name`,
`_error` and rule invocation — no cut, no lookahead, no left recursion, no
gather and no semantic action — so none of that machinery is present. Failure
is a `longjmp`: TatSu signals a failed parse with an exception that unwinds
through nested context managers, and `_option` is the only place that catches
one and carries on, so an option records the stack depths on the way in and
truncates to them on the way out.

**`pattern.c` — the grammar's regular expressions, written out.** All
thirty-four of them are character classes with a quantifier, plus one negative
lookbehind. Writing them out avoids a dependency on three platforms and is
faster in what is the parser's innermost loop. One subtlety is preserved
deliberately: TatSu matches with `cre.match(self.text, pos)` rather than
against a slice, so a lookbehind *sees the text before* `pos` — which is what
stops `&ABC` from being read as the identifier `ABC`, and matching against a
slice instead would quietly change the language.

**`dec.[ch]` — Python's `decimal` at 20 significant digits.** `toFloatIBM`
converts a constant *as written* — `DC D'0.232830643653869628E-9'` — and
`ibmHex.py`'s own comment says why: the string form is better "because if the
value has already been converted to a Python float, it may no longer be able to
correctly match all significant digits". Doing that arithmetic in `double`
changes the last bit of some constants, and that constant is one of them.

### Memory

Bump arenas; nothing is individually freed. The assembler runs once over one
module and exits, and reference counting a graph of this shape — parse trees
stored into line properties, line properties stored into symbol table entries,
symbol table entries pointing back at line properties — buys nothing but the
opportunity to get it wrong.

A separate **parse arena** keeps that honest. A single parse of one operand
field builds and throws away a great deal of tree as it backtracks through the
alternatives; all of it lands in the parse arena and is reclaimed wholesale
when the next parse begins. Only the result survives, copied into the main
arena by `val_export` on the way out, with its internal sharing preserved —
memoization hands the same node to every rule that asks for it at the same
position, so a parse tree can be a DAG, and copying it naively would duplicate
the shared parts once per reference.

Peak resident memory for the regression corpus is about 18 MB, against the
Python's 28 MB.

## Verification

Everything below compares against `ASM101S.py` or against the contemporary
assembly listings, never against expectations of what the code ought to do.

**The parser.** `tools/parsedump.c` and `tools/parsedump.py` write the same
canonical rendering of a parse tree — one distinguishing tuple from list, list
from closure, and preserving an AST's insertion order, because each of those
differences changes what the code generator does. Fed the 4,971 distinct
`(rule, text)` pairs harvested by instrumenting `parserASM` over the whole
205-module corpus, the C parser and TatSu agree on every one.

**IBM floating point.** Agrees with `ibmHex.py` on 225 cases, including the
`D'0.232830643653869628E-9'` value whose rounding carries out of the fraction,
and the extremes of the double range.

**Whole assemblies.** Compared module by module against `ASM101S.py`:

- all 205 RUNASM modules, byte-identical listings — in *both* configurations of
  the `&ASM101S` switch, that is with and without `--no-rtl-fixes`;
- all five `macroTests`, which exercise the multilevel sublists, ACTR,
  alignment and duplication factors that RUNMAC does not use at all;
- a 168-card synthetic source covering the DC/DS types, literals of every type,
  bit-length packing, the MSC, BCE, RI, SI and shift instructions, ORG, LTORG,
  CNOP, multiple control sections and a DSECT — all of which RUNASM never
  reaches;
- the options `--fill`, `--sysparm`, `--no-rtl-fixes`, `--no-force-d`;
- the intolerable-error abort listing, which takes a different path entirely.

**The FCOS corpus.** Two PFS releases, swept module by module against
`ASM101S.py`:

| Release | Modules | Exit status | Listings | Objects, canonical | Objects, raw |
| --- | --- | --- | --- | --- | --- |
| OI340600 | 271 | identical, all 0 | **byte-identical** | identical | 178 differ |
| OI301700 | 271 | identical, all 0 | **byte-identical** | identical | 181 differ |

The raw counts are worth one significant figure and no more: they came out 180
and 174 on an earlier pair of runs of the same two programs over the same
sources. That is Python's per-process `set` ordering, and it is why the
canonical column is the one that means anything.

With BILDNEW5, compared separately below, that is **544 modules** — 272 from
each release — with byte-identical listings and no canonical object difference,
on two corpora with no module names in common.

OI340600 used to sweep 224. The missing 47 were its PCH patch decks, which
shipped without a filename extension and so were refused by both assemblers
before any assembly began; renaming them to `*.asm` (PFS commit `00d1051b`)
brought the two releases to the same count, which is not a coincidence — the
entire difference between them was those decks being unreachable. The raw object
differences are ESD ordering, which is Python `set` iteration and varies from
run to run of `ASM101S.py` itself — see *Deliberate divergences* below.

This is much heavier going than RUNASM: OI340600 alone is 15 MB of source
against 1 MB, with 210 MLIB80 members read as open code ahead of every module,
and it is the corpus most of the commentary in `model101.c` was written against.

BILDNEW5 is excluded from both sweeps, as it is from the project's own
`oi340600-sweep.sh`, because it used to never complete. It does now, and both
releases' copies were compared by hand — see below.

The harness is `pfs-test/`, and it is release-parameterised:

```
./sweep.sh c   [RELEASE]     # RELEASE defaults to OI340600
./sweep.sh py  [RELEASE]
./compare.sh   [RELEASE]
```

It finds both assemblers in `~/git/virtualagc/ASM101S` — `ASM101S.py`, and
`ASM101Sa` as built there — overridable by `ASM101SA=` and `ASM101SPY=`, and
checks they exist before starting so a missing build fails once instead of 224
times.

**A date stamp in the page heading will fool the comparison.** Every heading
ends in the assembly date, so two sweeps that straddle midnight differ on every
module for a reason that has nothing to do with the assemblers. That happened
once and read convincingly as a regression: all 224 and all 271 listings
differing, immediately after the port was relocated. Normalising that one field
gave 0 and 0. `compare.sh` therefore prints the strict count and, beneath it,
the count with the heading date normalised away — read the second whenever the
first equals the module count.

Each assembler works in its own subdirectory with its own symlink to the release
and its own `out-RELEASE/`, because both write `.obj` and `.lst` under fixed
names and would otherwise overwrite each other between producing a file and its
being compared, and because keeping the output per release as well as per
variant means sweeping a second release does not discard the first one's
results. The symlink is created on demand. `~/workspace/PFS` is never written
to, which was checked afterwards rather than assumed: no file under it newer
than the run, no stray outputs in the source or library directories, and
`MACROFILES.txt` intact at 278 lines.

**The PCH patch decks.** OI340600/SSSRC holds 47 of them, each a short list of
`001 IS <len>,<prefix>[,<fill>]` cards, and they are the corpus's real exercise
of the macro machinery rather than of the code generator.

They look wrong at first: every card carries what appears to be an illegal,
repeating label — `001`. It is not a label. `IS` (MLIB80/IS.asm) has the
prototype `&S IS &L,&P,&FILL` and its body does `&N&S CSECT`, so the name field
is a macro parameter concatenated onto a global prefix, and `001` never becomes
a symbol. `IS 1F4,#Y101,C6C6` yields CSECT `#Y101001`, `DC 500X'C6C6'`, ESD
length `0001F4`.

All 47 assemble exit 0 under both assemblers with byte-identical listings — but
the stronger check is against the **contemporary IBM assembler's own listings**,
which survive for OI301700 in `~/workspace/PFS/OI301700 as received/SSSRC/`.
Those files are listings, not source, and they carry the original expansion of
these same decks. Ours matches card for card: **45 of the 45 decks that are the
same revision in both releases, 368 generated cards.** The other two differ in
revision and are not comparable — PCH02SRC has 23 `IS` cards against 22,
PCH03SRC 5 against 6.

The subtle path is exercised. `&FV` is a `GBLC`, so an omitted fill operand
inherits the previous invocation's; 136 of the 184 `IS` invocations omit it, and
PCH03SRC's four later CSECTs correctly inherit `C6C6` from the first. The
`'0000'` default is *not* exercised — every deck's first `IS` supplies a fill.

**BILDNEW5.** The module the `cb10a480b` and `105ad9afb` repairs were aimed at,
and the reason it was excluded from every sweep, now assembles. The two releases
carry genuinely different sources (47.3 KB and 50.8 KB, diverging at line 5).

| Release | C | `ASM101S.py` | Listing | Object |
| --- | --- | --- | --- | --- |
| OI301700 | ~20 s | 1m10s | **byte-identical** | canonically identical |
| OI340600 | 1m44s | 56m16s | **byte-identical** | canonically identical |

Both exit 0; OI340600's listing is 38,696 lines. That release's copy is far the
more expensive of the two — 56 minutes of Python against about ten for the other
224 put together — and is what keeps the exclusion in the sweep script.
OI301700's does not need excluding at all, and only is because one script serves
both.

**Against the 1980s listings.** Both assemblers score **205 of 205 byte-exact
with `--no-rtl-fixes`**, and 199 of 205 without it. The six that differ by
default — CINDEX, MM14SN, MM6SN, MV6SN, VV6S3, VX6S3 — are exactly the six
files in RUNASM that contain `&ASM101S`, and they differ *by design*: each
carries two variants of a block selected by `AIF (&ASM101S)`, and the RUNLST
listings are historical output from an assembler that never defined that
symbol. `regressionASM101S.sh --no-rtl-fixes` is therefore the full-fidelity
invocation, and that script's "all 205 modules assemble byte-for-byte" comment
is correct as written.

**Score a `--compare` run by counting `Comparison mismatch` lines in the
listing, not by testing `$?`.** A mismatch is reported in the listing and does
*not* set a nonzero exit status. A regression loop written around `$?` scores
205 of 205 in *both* modes and looks like good news; it is measuring nothing.
The six differ by 72, 193, 42, 28, 12 and 34 mismatched bytes respectively — and
`ASM101S.py` reports the same six modules with the same six counts, which is the
comparison that matters here. VX6S3's 34 is the same 34 named in the
`svDeclare` comment in `expressions.c`.

CINDEX shows why the bytes move rather than merely change: its fixed arm
inserts an `SRL R6,1` — rescaling from `NHI`'s 0x10000-per-character unit to
GTBYTE's real 0x8000 — and hoists a `CR` above it so the comparison happens
while both registers still share a scale. The module gets longer, and every
address after the insertion is displaced.

**A moving source tree is not a sound thing to measure against.** One OI340600
sweep was run while `expressions.py` was being edited underneath it — the sweep
ran 16:25:12 to 16:35:04 and the file changed at 16:30:06 — so roughly half the
corpus went through the old Python and half through the new, and the result was
reported as though it were a single measurement. Record
`git -C ~/git/virtualagc rev-parse HEAD` and `git status --porcelain ASM101S/`
before a differential sweep and again after, and treat any change between them
as invalidating it. The tests that use only this program and the historical
listings are immune, and are the ones to reach for while the tree is moving.

Every figure in this section was measured that way. The sweeps behind them ran
with the repository at `dc5b977071b5aa1a266d4117df867eb38675ff06` and one
untracked `ASM101S/ZT4.obj`, before and after, identical.

**Nor is a moving harness directory.** Renaming or moving `pfs-test/` while a
differential run is in flight will corrupt it, by a route that is not the
obvious one. The Python's cwd resolves through the symlink at `cd` time, so it
holds the real PFS directory and does not care; its output descriptors are
already open. But `--library=` is a *path string*, and `ASM101S.py` opens
library members **lazily** throughout the assembly — `COPY` via
`os.path.join(library, ...)`, which at least exits 1 on failure, and the
on-demand macro fetch via `os.path.isfile`, which on failure merely records the
name as not-a-library-member and carries on. The second is the dangerous one: it
does not crash, it turns every not-yet-fetched macro into an undefined operation
and produces a plausible-looking wrong listing. Wait for the run.

**Sanitizers.** Clean under AddressSanitizer and UndefinedBehaviorSanitizer
across the whole corpus. The only LeakSanitizer reports are the arenas
themselves, which is the design.

**Speed.**

| Sweep | C | `ASM101S.py` |
| --- | --- | --- |
| RUNASM, 205 modules | 2.9 s | 154 s |
| OI340600, 224 modules, `JOBS=10` | 10.9 s | ~10 min |
| OI301700, 271 modules, `JOBS=10` | 1.6 s | 32 s |

The ratio is roughly 55x on the first two and only 20x on OI301700, because
OI340600's cost is concentrated in a handful of very large modules where the C's
advantage compounds, while OI301700's 271 are mostly small — 14 MB of listings
from 271 modules against OI340600's 16.7 MB from 224.

Peak resident memory is about 18 MB per process on RUNASM and 130 MB on FCOS,
where the arenas hold the whole 210-member macro library; Python's is 28 MB and
50 MB.

## Deliberate divergences from the Python

Two, both commented at the point they occur.

**Hashcodes** use a small counter-based generator rather than CPython's
Mersenne Twister. The values only have to be distinct 28-bit numbers; nothing
depends on which they are, and none of them reaches the listing, since every
place a symbol's value is printed masks off bit 32 and above. Reproducing
CPython's `random` module exactly would have bought nothing.

**`entries` and `extrns` iterate in insertion order.** In Python they are
`set`s, and their iteration order is Python's hash order, which is randomised
per process — so **`ASM101S.py` writes a different `.obj` on every run**. CSLD's
END-record entry address came out 88, 14 and 200 on three consecutive runs.

It shows up as ESD card *order*, and as nothing else. On OI340600, about 180 of
224 objects differ raw and **all 224 are identical once ESD order is
canonicalised**; on OI301700, about 180 of 271 differ raw and all 271 are
canonically identical. "About", because the raw count is itself a function of
the run: four sweeps of the same two programs over the same sources gave 180,
178, 174 and 181. The canonical count was 0 in all four.
`pfs-test/objcanon.py` re-expresses an object module by symbol name rather than
by ESD id, which is the only way to compare two of them.

The correlation is exact: **every** module whose object differs has two or more
ENTRY symbols, and **none** of the 137 with one or none does. Note that a single
ENTRY *statement* can supply several — FPMIDLE's one
`ENTRY FPMSPNT,FPMDSBL,FPMENBL` is why counting ENTRY cards is not a proxy for
counting entry symbols.

There used to be a second consequence, and it is worth recording because it was
the more serious one. `ASM101S.py` wrote the address of an arbitrary member of
the `entries` set into the END record's entry point, so FIOCBLKS's came out
1196, 2120 and 316 on three consecutive runs and the value reached the linked
image; 63 of the 224 FCOS objects differed in that field. Commit `105ad9afb`
removed it on both sides — an entry point comes from `END SYMBOL`, and every
module in this corpus writes a bare END. The END record's entry address and ESD
id are now blank in both assemblers' output, which was checked directly on the
FIOCBLKS and FPMIDLE cards rather than inferred from the canonical comparison.

Neither divergence affects the listing, the generated code, or the meaning of
the object module.

## File map

| File | Contents |
| --- | --- |
| `asm101s.c` | main: source reading, macro expansion, conditional assembly, command line, listing, cross reference, `--compare` |
| `model101.c` | the four-pass code generator; the largest file |
| `expressions.c` | symbolic variables, arithmetic/boolean/character evaluation, attributes |
| `tables.c` *(generated)* | instruction tables |
| `tablesupport.c` | lookups over those tables, and the SRS/RS/RS1 encoders |
| `parser_asm.c` *(generated)* | the 78 grammar rules |
| `peg.c` | TatSu runtime |
| `pattern.c` | the grammar's regular expressions |
| `fieldparser.c` | `parserASM`, `joinOperand`, continuation-card handling |
| `val.c` | the dynamic value and the arenas |
| `pyutil.c` | the Python behaviours the output depends on — banker's rounding, floor division, `str.center`, `str.isdigit` |
| `dec.c` | decimal arithmetic at 20 digits |
| `ibmhex.c` | IBM hexadecimal floating point |
| `ebcdic.c` | the conversion tables |
| `objectwriter.c` | the IBM object module |
| `readlisting.c` | reads a contemporary listing for `--compare` |
| `tools/` | the two generators, and the two halves of the parser differential test |
