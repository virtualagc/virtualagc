# Building the OPS 9 tape

How to build **`OI340700-v41boot.mmv`** from source — the volume that runs
`OPS 201/301/302/801/901/101 PRO` and keeps polling the displays (see "The
OPS 901/201/301 blocker" below).  Rewritten 2026-09-10, when the document was
first *followed* rather than recalled and found not to reproduce anything:
it described the v27 procedure, v36 had been built by a script that existed
only in `/tmp/claude-1000`, and half its inputs had no recipe at all.

**The procedure is now a script in this repository, and it is verified by
building from an empty directory and comparing byte for byte with the volume
that was tested.**  This section says how to run it and, for each stage, why
it is what it is.  Every input is a git repository at a named state or a file
committed beside the script; nothing is read from `~/pass-build/OI340700` or
from any scratch directory.

What the volume is made of, honestly: our own compiles (`HALSFC`), assemblies
(`ASM101Sa`), `GPCIPL`, links and stamped tables — except the three DEU load
modules, which our chain cannot generate and which are **24 blocks taken from
`pass-910.mmv`** (itself a volume we built), and the 88 halfwords that
`tools/patch_unresolved.py` fills after the link (section 7b).

---

## 0.  One command

```bash
REF=~/workspace/pass-run/OI340700-v41boot.mmv \
    ~/git/virtualagc/yaShuttle/yaGPC2/tapebuild/build.sh /tmp/claude-1000/tapebuild
```

About 25 minutes, most of it `compilePASS`.  It must end with

```
  tree a68da6e6088adf5442cfd428a17daba698dd4e8f
  1981 objects
  SYSLIBL1: 4277 entries
  lib/runtime: RUN 205 (0 failed), ZCON 284
    PHASE01: linked 7 objects ...          (every phase must say "linked")
      2  #PFCMGPT  0x01ccf2  1093       0     918
    OVERSIZE rows (must be 0): 0
    DEU blocks forced: 24 (must be 24), volume 2681 blocks
  88 filled in 7 load blocks, 125 found already correct, 0 refused
### MATCH: byte-identical to /home/rburkey/workspace/pass-run/OI340700-v41boot.mmv
```

**Verified 2026-09-10 by running exactly this command in an empty directory.**
The first attempt did not match -- a bare toolchain clone links nothing (see
"`con80build`'s default runtime directories must exist" under stages 4–7) --
and the script was fixed until it did; that is the only way this document gets
to say it works.

Omit `REF` to build without comparing.  `WORK` (the argument) may be any empty
directory; the two git clones in it are reused on a rerun.  The pre-fill
volume is `$WORK/OI340700-v36boot.mmv` — what "v36" has always meant.

**Prerequisites** — the only things taken from the machine rather than from a
pinned source:

| what | why |
|---|---|
| `~/workspace/PFS` containing commit `19464059` | sources are `git archive`d at that commit (`PFSREV` overrides) |
| this repository's `PASS.REL32V0` with built `HALSFC-*` binaries | `compilePASS` refuses a compiler older than its sources |
| `ASM101S/ASM101Sa` built | the assembler |
| `~/donschmidt/nsts-sdl-dps` | **only** its `ext/` submodules and its Python venv (`typer`, `rich`, `lark`); none of its code is run |
| network access to GitHub | two clones: the linker toolchain and `dfg` |
| `unbuffer` (expect) | so `compilePASS`'s output is not lost if interrupted |

---

## 1.  The stages

| # | stage | pinned by | output |
|---|---|---|---|
| 0 | linker toolchain | fork `rburkey2005/nsts-sdl-dps`: upstream `db9d34b` + branches `lib-inserts-and-stacks`, `mmustamp-skip-phase`, `mmu2mmv-unstamped-guard`, merged; **tree `a68da6e6` checked** | `$WORK/nsts-sdl-dps` |
| 0b | `dfg` | upstream `ColanderCombo/nsts-sdl-dps` `7d90b05` + `toolchain-patches/dfg-7d90b05-to-OI340700.patch` | `$WORK/bin/dfg` |
| 1 | source tree | PFS `19464059`: `OI340600` overlaid with `OI340700`; `RUNASM/RUNMAC/ZCONASM` from `PASS.REL32V0`; `source-patches/OI340700-APPLSRC-CSPCLB-qualification.patch` | `$WORK/OI340700` |
| 2 | objects | `compilePASS --no-csects --sdl --release=OI340700` | 1,981 objects |
| 3 | derived layers | `tapebuild/derive.py` | `SYSLIBL1`, `lib/runtime`, `sdfpad`, `pchsrc`, per-phase csect tables |
| 4–7 | link, stamp, cut, DEU splice, SSL checksum | `tapebuild/link-and-cut.sh` (the v36 procedure) | `OI340700-v36boot.mmv` |
| 8 | unresolved-relocation fill | `tools/patch_unresolved.py` (section 7b) | `OI340700-v41boot.mmv` |

---

## 2.  Why each stage is what it is

Each of these was found by building and comparing, and each one, done the
obvious way, silently produces a different tape.

### Stage 0 — the linker toolchain

Upstream `db9d34b` plus three of our branches, which are PRs to Don.  The
merge commits are local, so their hashes change on every rebuild; the script
checks the **tree** hash instead (`a68da6e6`, which is what built v36).  If
the branches move, it stops rather than build with something else.  The
`ext/` submodules are symlinked to Don's checkout, as they were for v36.

### Stage 0b — `dfg`, pinned, because the one that built v36 was never committed

The display decks are translated to HAL/S by Don's `dfg`.  The `dfg` that
built the verified volume was **his working tree**: upstream `7d90b05` (PR
#46, since merged) plus a local merge and an **uncommitted** per-release
rate-group allowance in `src/dfg/ddt.py`, which gives OI340700's `CS2120`
two more dynamic field-control words — VPD `00D5`, exactly what the S2 DASS
dump has, instead of `00D3`.  The patch is the whole difference, verified to
reproduce his `src/dfg` file for file.

It only takes effect if `dfg` is called with `--release OI340700`, and
`compilePASS` decides that by probing `dfg --help` — which is drawn by `rich`
with the two dashes styled separately, so the literal `--release` never
appeared and the probe always said no.  **Fixed in `compilePASS` on
2026-09-10**; before that, a clean build could not reproduce `CS2120`.

### Stage 1 — the source tree

`OI340600`, overlaid with `OI340700`, from PFS at `19464059` — which includes
`OI340700/CON80` with the **`STACK` cards activated** (without them the tape
has no process stacks; see below).  A **zero-byte `.hal` in the `OI340700`
overlay is an exclusion marker** — the file is not part of this release — and
is copied over OI340600's on purpose.  Never fill one in.

One source change is not in PFS: the "CSPCLB qualification" of
`CSPB_PI_UMB_RESET_MASK` in `APPLSRC/SPSPSP.hal` and `SSOSPDAT.hal`, needed
for them to compile.  It was made in a scratch tree on 2026-09-03 and never
committed anywhere; it is now `source-patches/`.

### Stage 2 — objects: `--sdl` and `--release=OI340700`, both required

`HANDOFF-OI340700-BUILD.md`'s recipe omits both, and without them the objects
differ from the ones the tape was built from:

- **`--sdl`** — the flight images are SDL builds.  Without it every PROGRAM
  gets a `START` csect, an `LHI R0,<stack>` prologue and stack ERs: 160
  objects differ.  With it the stacks come from the CON80 `STACK` cards, which
  is what the link below expects.  (`halsParms.DEFAULT_SDL` is `False` because
  a *library* build does not need it; a *tape* build does.)
- **`--release=OI340700`** — selects `halsParms`' per-release card types:
  `CPUSLS` and `CPTOSV` need `ACBC`, not the base table's `ACBD`, or they fail
  `XI3` and eight phase-15 objects fail after them.

With both, all 1,981 objects match the ones v36 was linked from in loaded
content (ESD/TXT/RLD).  They never match byte for byte: the SYM and END cards
carry the **compile date**, which does not reach the tape.

### Stage 3 — the derived layers

Each rule was established by regenerating the layer v36 used and comparing;
the details are in `tapebuild/derive.py`'s header.

- **`SYSLIBL1`** — one entry per section an object defines, a hard link to
  that object; objects in name order, first definer wins; `START` excluded.
- **`lib/runtime/RUN`** — `RUNASM` assembled with **`--fill=C6C6`**.
  `compilePASS` now assembles with `C9FB`, deliberately, since the DASS dumps'
  assembler csects are `C9FB`; but the runtime library the tested volume was
  linked with predates that change, and 94 of its 205 modules differ in fill
  halfwords.  Kept to reproduce v41; a padding deviation, recorded below.
- **`lib/runtime/ZCON`** — `compilePASS`'s objects for `ZCONASM`.
- **`sdfpad`** — `SDFLIB` with each 3,360-byte SDF padded by one zero byte:
  `con80build` accepts a prebuilt SDF only if it is *larger* than 3,360.
- **`pchsrc`** — `SSSRC/PCH*.asm` with the extension removed: `con80build`'s
  `_PATCH_SRC_RE` assumes an extensionless member name.  The objects are also
  aliased `PCHnnSRC.obj` → `PCHnnTXT.obj` in each phase's `obj/`.
- **Per-phase csect tables** — each phase gets the csect table of the
  configuration it belongs to, from `PFS/mafgen/csects-<CFG>.json` keeping
  `start`/`end`/`type`: phases 3, 8, 18 → G9; 4 → G16; 5 → G2; 6 → G3;
  7 → G8; 9, 12 → P9; 14, 15 → S2.  The configuration was chosen by counting
  how many of the phase's linked csects each dump holds.  Regenerated
  byte-identically to the 11 tables v36 used.
- **`inputs/extsyms-02-plus.json`** — phase 2's table: the SSW table (660
  csects) plus `contents` entries for 27 parent csects referenced across
  phases, with 98 further hand edits.  **Its generator is lost**; the file is
  committed as the input it is.  `inputs/extsyms-13.json` — phase 13's three
  pins — likewise.

### Stages 4–7 — link, stamp, cut, splice

`tapebuild/link-and-cut.sh`, proven byte-identical to the script that built
v36 given the same inputs.  What each step is for:

**Per-phase minimal libraries.**  A phase may take from `SYSLIBL1` only the
csects its own deck root INSERTs — passing the library whole let `lnk101` pull
other phases' compools into phase 2 (617 blocks against 256) and, once phase 2
was fixed, into phase 9.  The resident HAL/S library (`LIBZERO`, `LIBRESD`,
`LIBRESC`) belongs to phase 2 and is **shared**: offered to another phase it
is pulled in a second time at the flight addresses and fragments the phase
(12 went 216 → 334 blocks).  Phases 1 and 10 take **no library at all** (a
blanket library breaks `FCMBOOT`: phase 1 must be 7 sections, 3,624
halfwords); 23–25 take `SYSLIBL1` whole.

**The csect tables are the linker's section table, not a symbol list.**
`applyRelocations` skips any relocation whose target section the table does
not name, leaving the assembler's bytes.  Absent, pruned or over-complete, the
failure is silent: phase 13 collapses to 16,127 halfwords; `FIOPDISP+116`
keeps an assembler-relative `0033`; phase 2 overruns its allocation and
`mmu2mmv` trims the tail.  Phases 1 and 10 take none (pinning phase 10 strips
97% of `GPCIPL`).

**Stacks.**  `lnk101` creates stacks only from CON80 `STACK $0<prog>` cards
(SDL objects carry no stack ERs), and `--generate-stacks 256` supplies the
size.  Result: 28 of the flight machine's 30, 24 at exactly the flight
address; `$0ASCTIM` and `$0ASGCYC` are still not generated.  Whether the
original deck had those cards commented out is an open reconstruction
question; for our build they must be active.

**Phases 16 and 26 are omitted.**  16 (`SMASM4`) does not link: `SM4TAB`
rebinds a generic module to SPEC-4 compools OI340700 excludes.  It does not
affect phase 18 (disjoint allocations, different configuration).  26 lacks its
MAP libraries and is outside the phase table's 3–18.

**`con80build`'s default runtime directories must exist.**  It will not link
at all unless `build/lib/runtime/{RUN,ZCON}`, relative to the toolchain
checkout, exist — phases 1 and 10, given no library, fall back to them — and a
bare clone has no `build/`, so every phase links nothing and says so with a
blank line.  They take no object from them (v36's phase 1 linked its 7 own
objects, phase 10 its 12); v36's checkout had them as symlinks into Don's
build.  `build.sh` points them at our own runtime library, and both scripts now
stop at the first phase that does not say `linked`.  Found by following this
document from an empty directory; the previous revision had noted the symptom
and not connected it to phases 1 and 10.

**Stamping** (5a, 5b) — neither `con80build` nor `mmu2mmv` does it, and a tape
without it cannot transition.  `FCMSSLPT` into phase 10 (its descriptor
halfword 0 doubles as the "mass-memory built" flag); `#PFCMGPT`, `#PCDCPHA`
and `FCMG3DAT` into phase 2.  `#PFCMGPT` **must** land at `0x01ccf2`.

**Cut** — `mmu2mmv`; no row may say `OVERSIZE`.

**DEU load modules** — `mmu2mmv` cannot generate `DEUDCPLM`/`DEUCFLM`/
`DEUSTLM`.  The 24 blocks v36 took from `pass-910.mmv` (md5 `f9d116d2…`) are
extracted into `inputs/deu-loadmodules.mmv`, so the build does not depend on
that volume.  Then `tools/stamp_ssl_checksum.py` writes `SSLENGTH`/`SSLCKSUM`,
without which `SSLCHECK` takes its error path and ITEM 1 EXEC loads nothing.

---

## 3.  Deviations and loose ends, recorded rather than hidden

- **The runtime library's fill** (`C6C6` where the flight machine's assembler
  csects have `C9FB`) — padding only, kept for byte-identity with the tested
  volume.  Rebuilding with `C9FB` changes 94 runtime modules' pad halfwords.
- **`extsyms-02-plus.json`'s generator is lost** — the 98 edits are not
  derivable from anything recorded.
- **`dfg`'s `CS2120` allowance is empirical** (Don's comment: the general rule
  is unconstrained there) and lives only in our patch until it is upstream.
- **The DEU load modules are borrowed**, not built.
- **88 halfwords are filled after the link** (section 7b) — cross-phase
  relocations our per-phase links leave unresolved.  The real fix is in the
  links; until then the fill is part of the build.
- **`~/pass-build/OI340700` is stale — do not build from it.**
  `objects/AIGDEU.obj` there is the v79 `WAIT 0.100` experiment's object,
  never recompiled after the source was restored; a link from that tree gives
  118,176 differing halfwords.  Its source directories are otherwise exactly
  PFS `19464059` + the CSPCLB patch.
- **`HANDOFF-OI340700-BUILD.md` needs `--sdl --release=OI340700`** added to
  its recipe (see stage 2).

---

## 7b.  Fill the unresolved cross-phase relocations

**Stage 8 of `tapebuild/build.sh`, and a WORKAROUND for a build defect.**
Skip it and the tape boots and IPLs, but every major-mode transition then
dies: `OPS 201`, `301` and `801` draw their new display and fall silent seconds
later (POLL FAIL), and `OPS 901` either crashes or stops polling.  Standalone:

```bash
python3 ~/git/virtualagc/yaShuttle/yaGPC2/tools/patch_unresolved.py \
        $WORK/OI340700-v36boot.mmv --out $WORK/OI340700-v41boot.mmv
```

On a v36-shaped volume expect `88 filled in 7 load blocks, ... 0 refused`, and
the output is **byte-identical to `OI340700-v41boot.mmv`**, the volume verified
in the table below.  It is idempotent: a second run fills nothing and exits 0.
The cells, their broken and correct values and the surrounding code as our build
lays it out are in `tools/patch_unresolved.fills.json`, in three groups:

| group | cells | where | unfilled, it causes |
|---|---|---|---|
| `zcon` | 36 halfwords (18 Z-CONs) | root, `0x1d6-0x243` | `invalid instruction 0xc6c6 at 0x48da` after OPS 901/201 |
| `resident` | 6 | `FIOSVCP+29`, `FIOCMPLT+1be`, `FIOPDISP+27d` (each `BAL R7` to **address 0**), `$0DGRGSE+122/+12e`, `#DDGRGSE+2e` | POLL FAIL after OPS 201/301/801 |
| `phase8` | 45 | phase 8's `FIOPDSMU` (42 -- exactly the link's 42 unresolved relocations for that section), `FIOG9ADB+1/+78` (its save area, so it `STM`s the caller's registers at **address 0**), `FIOPDG9+3` | OPS 901: the CPU **starts the MSC at address 0**; then wild branches or silence |

**How it finds a cell with no phase table.**  Every load block on these volumes
starts on a 512-halfword boundary and its two-halfword checksum tail is followed
by `C6C6` padding to the next boundary, so the block holding a cell is the
nearest aligned start whose tail verifies *and* is followed by clean padding.
Neighbouring table cells inside a context are wildcards (so clustered cells
still match after a partial run), but a context must keep six halfwords that are
neither `0000` nor `C6C6` -- **without that guard a Z-CON context inside the
`C6C6` hole matched fill in an unrelated block and wrote a Z-CON value into it.**
A cell holding anything other than its expected broken value or its fill is
refused, not overwritten: that means a different build, and the table does not
apply.  It supersedes `patch_root_zcons.py`, whose 18 Z-CONs are the `zcon`
group.

**Where the values come from.**  The DASS dumps, cross-checked against our own
build wherever possible: 17 of the 18 Z-CONs against our whole-memory link's
relocation list; all 42 `FIOPDSMU` values against the **three correctly linked
copies of `FIOPDSMU` that our own build placed in other phases of the same
tape** (only phase 8's copy is broken); `FIOG9ADB`'s `a0c6` against our link's
symbol `FI$G9ADB` (`FIOCDATS.asm:324`, "REGISTER SAVE AREA FOR G9 MDM A/D"), and
`FIOPDG9`'s `a09a` against our symbol `FIOCF302`.  The whole-memory link can't
check the G9 cells: a union link can't represent overlays that share an
address, and it resolves those cells to other modules' references.

### What it is fixing

A HAL/S call into a procedure that lives in an **overlay** phase goes through a
fullword indirect address pointer -- a Z-CON -- held in the **resident root**
at a fixed low address.  The compiler emits the cell as `8000 0E00`: offset 0
with the sector bit set, `XC=1 C=1 CB=1 BSR=0`.  Only the linker can finish it,
because only the linker knows which sector the overlay's code landed in.

Our root link does not.  `PHASE02` has **678 unresolved relocations over 304
distinct symbols**, eighteen of them these Z-CONs, so the cells reach the
volume as IPL fill.

Read as a pointer, `C6C6C6C6` is not inert.  Its bits say `XC=0, C=1, CB=1,
CD=0, BSR=12`, so the `C=1`/`CB=1` rule (AP-101S PoO Fig. 2-17) **replaces the
PSW's BSR with 12**, and `XC=0` asks for post-indexing.  A `SCAL` through such
a cell branches to `(0xC6C6 + index)` in sector 12, which is unloaded fill.

Measured on v36: the `DO CASE` dispatch in `#CDCDDOW` does `SCAL` through
`#ZDCDDG9` at `0x001DE` and lands at `0x648DA`.  Note that every **correctly
filled** Z-CON here carries `XC=1` -- no post-indexing -- so which cell in the
hole is used does not change where it goes; the target depends only on the
index register.  That is why `OPS 901 PRO` and `OPS 201 PRO`, which do not call
the same routine, die at the identical address.

### Where the values come from

Two independent sources that agree, neither of them one of our tapes: the eight
DASS dumps in `~/workspace/PFS/mafgen`, which agree with each other on all 18
cells; and our own **whole-memory** link, `link/G9-symbols.json`, whose
relocation list gives the same target for 17 of the 18.  The exception is
`0x001E2`, where `#ZDCDDS4` comes from `<external-syms>` rather than from a
real `DCDDS4.obj` and the linker put `ACOS`'s Z-CON in the same cell -- a
placement collision, and a second defect.

### The real fix, which is cheaper than it looks

`pass-build/OI340700/phase3/PHASE02.lib` (2026-09-05) **already gets this
right**: it matches the DASS dumps on 159 of the 160 halfwords of the root load
block at `0x1a8..0x247`.  The root link **regressed** after that date.

| root image | deck root | modules | unresolved | matches DASS, `0x1a8-0x247` |
|---|---|---|---|---|
| `phase3/PHASE02.lib` (09-05) | `PHASE02` | 517 | 104 | **159 / 160** |
| `phase2/PHASE02.lib` (09-05) | `PHASE02` | 500 | 96 | 42 / 160 |
| `phase/PHASE02.lib` (09-06) | `PHASE02` | 516 | **6** | 96 / 160 |
| `c80boot/PHASE02.lib` (09-08) | `OFTMP@2` | 321 | 678 | -- |
| v36 tape as shipped | | | | 120 / 160 |

**Resolution count does not predict correctness.**  The 09-06 build resolves
all but six relocations and still scores 96, because its table is not unfilled
but **permuted** -- real Z-CON values in the wrong cells from `0x1ac` onward,
which is what happens when missing sections let later Z-CONs pack into earlier
slots.  So find what `phase3` did differently rather than hand-writing
`extsyms-02.json` pins; that file currently contains **none** of the eighteen
`#C...` targets.

### Not patched, on purpose

`0x1E8`, `0x202`, `0x218` and `0x22C` also differ from the DASS dumps, but they
hold **real values rather than fill**, and all four have bit 0 clear where the
dumps have it set, so the target is taken as sector 0.  That is a different
defect and wants its own diagnosis, not a hand-applied constant.

---

## 8.  Check the volume before booting it

`build.sh` already refuses a phase that does not link, an `OVERSIZE` cut, a
failed stamp and a refused fill, and `REF` compares the whole volume.  Two
further checks, with the values the verified build gives (2026-09-10):

```bash
W=/tmp/claude-1000/tapebuild
python3 ~/git/virtualagc/yaShuttle/yaGPC2/tools/check_volume_destinations.py \
        $W/OI340700-v41boot.mmv
```

Expect `No recognised load block is aimed at resident memory.`  (One header is
recognised and is fill-only -- the staging fill pattern read as a length inside
a raw phase record, not a finding.  A block with a *plausible* length and
`BODY IS ENTIRELY FILL` would be.)

Confirm the phase table reached the tape.  **Match on the build's own bytes,
not on a remembered signature** -- the phase 3 descriptor differs between
builds, and searching for another build's bytes gives a false negative.  This
was got wrong twice.

```bash
python3 - <<'PYEOF'
import sys; W = "/tmp/claude-1000/tapebuild"; sys.path.insert(0, W + "/nsts-sdl-dps/src")
from pathlib import Path
from ap101Utils.libModule import LibModule
lib = LibModule.read(Path(W + "/c80/PHASE02.lib"))
text = {}
for x in lib.extents:
    b = x.address // 2
    for i in range(x.hwLength):
        text[b + i] = (x.data[2*i] << 8) | x.data[2*i + 1]
gpt = [text.get(0x1CCF2 + i, 0) for i in range(1093)]
sig = b"".join(v.to_bytes(2, "big") for v in gpt[:12])
raw = open(W + "/OI340700-v41boot.mmv", "rb").read()
print("GPT %d non-zero; on tape: %s; first descriptor %s"
      % (sum(1 for v in gpt if v), "yes" if sig in raw else "NO",
         " ".join("%04X" % v for v in gpt[:4])))
PYEOF
```

Expect `GPT 918 non-zero; on tape: yes; first descriptor 0040 000A 1BC0 0026`.
(`mmustamp` reports the same 918 for `#PFCMGPT`; `FCMSSLPT` is stamped with 462
non-zero halfwords.)

---

## 9.  Boot it

Kill any leftover `discretePanel` **before** the run, not only after — one
left from a previous run makes the GPC flap `HALT`↔`RUN`.

The recipe that verified OPS 901/201/301 on the rebuilt volume (2026-09-10;
use `OPS,2,0,1,PRO` or `OPS,3,0,1,PRO` for the others):

```bash
cd ~/workspace/pass-run
YAGPC_DEU_EXTRA_PRELOADED=1 TAPE=/tmp/claude-1000/tapebuild/OI340700-v41boot.mmv \
DEU2="7,8,9" DEUMF=1 DEUKEYS="@120s:ITEM,1,EXEC;@280s:OPS,9,0,1,PRO" \
PORT_BASE=6800 ./headless-gpcmem.sh 430 ~/workspace/pass-run/headless-v41
```

Interactively: `./retest-crt2.sh --tape /tmp/claude-1000/tapebuild/OI340700-v41boot.mmv`.

The IPL SOURCE switch must be **off** before RUN or FCOS refuses every
post-IPL mass-memory transaction; the harness handles this.  `IDLE_TIMEOUT`
is in **milliseconds**.

Kill any leftover `discretePanel` **before** the run, not only after — one
left from a previous run makes the GPC flap `HALT`↔`RUN`.

### `@N` in DEUKEYS is a DEU POLL COUNT, not seconds

This is the parameter that decides whether the run is long enough to be worth
starting.  `@150:ITEM,1,EXEC` fires on the 150th poll and `@430:OPS,9,0,1,PRO`
on the 430th; a batch with no `@N:` uses `YAGPC_DEUKEYS_AFTER` (default 400).

**A POLL COUNT IS A BAD CLOCK, because the poll rate is a function of the
thing under test.**  An earlier revision of this file said "roughly 4.1 s of
wall clock each" and sized every run from it.  That figure was measured on a
build where PASS never took the display and polling therefore stayed slow
forever; on a tape that works it is about **1.6 s/poll** and it accelerates
once PASS is up.  Carrying it forward made every headless run two to three
times longer than it needed to be — 35 minutes for something the crew station
does in under three.

**Measure the landmarks, and re-measure after any large change.**  From
`ops901-v29/deu.log`, by correlating the `"polls":N` stats lines against the
events either side of them:

| landmark | poll |
|---|---|
| GPCIPL menu on screen (`IPL MENU` in the DEU image) | **~64** |
| PASS takes the display (`0x19ee` collapses to `3200`) | **~200** |
| SSL mass-memory activity finished | t ≈ 105 s |

So the gates are `@75` for `ITEM 1 EXEC` and about `@210` for anything that
must arrive once PASS is up.

**`@Ns` IS WALL SECONDS, NOT SIMULATED SECONDS.**  `deu_wall_seconds()`, not
the emulated clock — while `YAGPC_SNAPSHOT` and `YAGPC_TRACEWIN` are both
SIMULATED.  The two clocks do not track: the sim/wall ratio has been measured
between **0.19x and 1.7x** on otherwise identical runs, depending on what
instrumentation is attached.  A time window aimed at a simulated instant may
therefore never be reached before the script's wall-clock kill, and a
keystroke gate may fire much earlier or later in the machine's own life than
intended.  `YAGPC_SVCTRACE` and `YAGPC_EAWATCH` each cost roughly half the
emulator's speed.

**`RUN_AT` IS BACK TO 260, AND THE IPL SOURCE NOW COMES OFF *AFTER* RUN.**
The PASS User's Guide, Table 2-2 "GPC IPL SEQUENCE" (p. 54), steps 13 and 14,
are unambiguous: RUN first, then IPL SOURCE OFF.  `headless-gpcmem.sh` used to
deselect eight seconds BEFORE RUN, inverting it, and nothing established the
two were equivalent.  The panel script is now crt-deselect at `RUN_AT-10`, RUN
at `RUN_AT`, SOURCE OFF at `RUN_AT+2`.  The old `ITEM 1 EXEC must fire before
RUN_AT-8` deadline was an artefact of the inverted order and no longer exists;
the SSL load still has to finish before RUN.

**`SOURCE_RUN` DEFAULTS TO `OFF`, AND LEAVING IT ON FAILS AS SILENCE.**  With
the IPL source still selected, an OPS request is ACCEPTED — `ARCGPC` runs —
and then `FIOMGSTR` completes the mass-memory transaction synchronously with
"MM SELECTED FOR IPL", `FIOMGCMP` dequeues it in the same millisecond,
`FIOMGMTR` is never entered because nothing is left to monitor, and the tape is
never touched.  Measured with `YAGPC_PCCOUNT`: `$0ARCGPC` 1 hit, `FIOMGSTR` 2,
`FIOMGSNC` 2, `FIOMGCMP` 2, all inside one millisecond; `FIOMGMTR` 0,
`FIOMGTQE` 0.  From outside that is indistinguishable from a refused
transition or a tape missing the phase.  It cost five runs before it was
found.  **Confirm an MMU read at t > 200 s before believing any measurement of
a transition.**

**STALE `discretePanel` PROCESSES SURVIVE A KILLED RUN** and hold the port
base; two publishers on the discretes bus make the GPC flap HALT <-> RUN, and
the guard then refuses the next run.  `retest-crt2.sh` launched its panel
backgrounded INSIDE a subshell (`& )`), so the subshell exited immediately and
the panel was orphaned with no pid anyone could record — now fixed, along with
a trap that tears down the displays, the sniffer, the panel and the GPC
together, and an Enter-to-shut-down prompt in place of `wait`.

Read the poll count out of the DEU's closing stats line (`"polls":378`) before
concluding anything about a transition: a batch that never fired looks
identical to one that fired and did nothing.

### Reading the run

```bash
grep -E "read [0-9]+ block|MODE:|keystroke" <outdir>/deu.log
```

A healthy IPL, with the original's contiguous-block counts beside ours:

```
read  72 block(s) from 4/4/5/0     bootstrap
MODE: HALT -> STBY; starting at 0x0014b     <- NOT 0x00000; see the phase 1 note
read  55 block(s) from 2/4/3/0     phase 10   (orig 55)
read  17 block(s) from 4/4/3/8     DEU load modules
read   8 block(s) from 4/4/0/24
read   8 block(s) from 4/4/4/8
YAGPC_DEUKEYS delivered 3 keystroke(s)      <- ITEM 1 EXEC
read 233 block(s) from 3/4/0/0     phase 2    (orig 228)
read   7 block(s) from 3/3/0/0     phase 13   (orig 7)
read  44 block(s) from 3/3/6/0     phase 3    (orig 38)
```

Both DEUs should report `"ipled":true` with a few hundred commands.  Strings
like `GPC MEMORY` and `GNC SYS SUMM 1` appearing in the DEU image dump are
**loaded formats from `DEUCFLM`**, not evidence of a live display — do not
read them as one.

### The one test that says PASS has the display

The banner region **`0x19ee`** is occupied by `GPCIPL 09.05.00.00.01` for as
long as GPCIPL owns the screen, and **collapses to a single halfword `3200`**
once PASS takes it over.  That, not the presence of any string, is the check:

```bash
awk '/^  0x19ee/{l=$0} END{print substr(l,1,110)}' <outdir>/deu.log
```

The run that verified v27 (historical):

```bash
cd ~/workspace/pass-run
TAPE=$HOME/workspace/pass-run/OI340700-v27boot.mmv DEUMF=1 SOURCE_RUN=OFF \
DEUKEYS="@150:ITEM,1,EXEC" RUN_AT=260 PORT_BASE=6800 \
./headless-gpcmem.sh 1500 ~/workspace/pass-run/headless-v27
```

SIGINT at 873,990,427 steps, **no halt**; `0x19ee..0x19ee (1): 3200`; and the
image carries `OLD PSW`, `MAJ=`, `MIN=`, `SCHEDWRD=`, `CLOCK1=`,
`17 DEU FORMAT LOAD`, `STP/PURGE CYC CNT   ERROR/MS`, `MCDS BITE`,
`MODE   BSR1   BSR2` and `27 OPTION START 28 STOP 29` — the GPC MEMORY page.

A HEADLESS run must be **1500 s**, not 620 — and the reason is the keystroke
gate, not PASS.  `@150` fires on the 150th DEU poll, and polls accumulate at
about 4.1 s of wall clock each, so `ITEM 1 EXEC` is not delivered until
t≈615 s: at 620 s the SSL load has barely started, which is why the banner
still reads `GPCIPL 09.05.00.00.01` even on the known-good tape.  **On the
crew station `GPC MEMORY` comes up almost instantly after `RUN`** (the user,
2026-09-09), so do not read the headless run's length as a statement about how
long PASS takes to seize the display.  Lower `@N` if a faster headless
turnaround is wanted.

### Set `SNAPSHOT` on any run meant to test the transition

The logs say which phases were read and nothing about why one was not.  If
`OPS 9 PRO` fires and no phase 8 or phase 18 read follows, the question is
what `FCMMGBOV` found in `#PFCMGPT` at `0x1CCF2` and what the PCT held — and
without a memory image there is nothing to look at, so the run has to be done
again from the start at 45 minutes a time.

```bash
SNAPSHOT="t1,t2:prefix"     # harness variable, NOT YAGPC_SNAPSHOT --
                            # the harness overrides the latter
```

Pick one capture shortly after the IPL set completes and one after the
transition window, and check the in-core phase table in the second against
what §5 stamped.

---

## The OPS 901/201/301 blocker -- RESOLVED 2026-09-10

### The POLL FAIL after 201, 301, 801 and 901 -- also RESOLVED, 2026-09-10

With the transitions completing, each new major mode drew its display and then
the displays went to POLL FAIL.  The cause is the same build defect as the
Z-CONs below -- **unresolved cross-phase relocations** -- in I/O code, filled by
section 7b's `resident` and `phase8` groups.  Measured with the bus log
(`YAGPC_BUSLOG`, `gpc-buslog.py rate`), DEU buses 6/7/8:

| run | tape | after the transition |
|---|---|---|
| D201, K301 | v37 | every bus falls silent within seconds, no program check |
| B201, B201b, V201, Z201 | v38+fill / v39 / v41 | polling steady to the end of the run; buses 14/16/20/22 carry MM 201's flight-critical traffic |
| V301, Z301 | v39 / v41 | steady, ~14,000 DEU events per 20 s |
| X901b | v40 | silent after ~285 s |
| Y901a, Y901b | v41 | steady; **G9 MDM buses 10/11 carry traffic for the first time** |

**Confirmed interactively by the user on v41** with MEDS: `OPS 201 PRO` (`UNIV
PTG`), `OPS 301 PRO` (`DEORB MNVR COAST`, title now present), `OPS 302 PRO`
(`DEORB MNVR EXEC`), `OPS 801 PRO` (`FCS/DED DIS C/O`), `OPS 901 PRO` and many
GNC 9 displays, and `OPS 101 PRO` (`LAUNCH TRAJ 1`).  Some transitions show the
GPCIPL screens while loading before the PASS display arrives; that is expected.

How OPS 901 died, as it was traced (ledger #66-#72), because every step of it
was a plausible wrong turn:

1. `FIOPDSMU` in phase 8 formed an **MSC start address of 0** (`PCTRACE MSC0
   PC<-00000`).  The MSC executed the PSA as MSC instructions, ran into
   `VAASEQUE`'s procedure code, and stored CPU instruction words into protected
   FCOS code -- 776 DMA store-protect violations in 8 ms, all `pe=0`.  OPS 201
   had none.
2. Each masked DMA store-protect violation sets the **documented CC anomaly**:
   CC = binary 10.  No ordinary instruction produces 10, which is why `BCR 7`
   ("M1 = 111 always branches") never tests it -- **so a `BR 7` taken right
   after the anomaly falls through, on the real machine as on ours.**  Our
   `exec_BCR` is correct; do not "fix" it.
3. `FPMGMTIM`'s closing `BR 7` fell through into the next halfword, which is
   `FPMIHIM` (the Instruction Monitor handler -- missing from the DASS CSECT
   tables, so the ring first read as `FPMGMTIM` running on into code it does
   not contain).  `FPMIHIM` logs through `FPMERLOG`, which calls `FPMGMTIM`,
   whose `BR 7` fell through again: a recursion ending in an unused SVC whose
   table entry is 0 -- also 0 on the real machine -- and a masked wait at
   address 0.
4. With `FIOPDSMU` fixed, `FIOG9ADB`'s `STM`/`LM` at address 0 and
   `FIOPDG9`'s operand remained: the last three code differences in everything
   phases 8 and 18 load.

`OPS 901/201/301 PRO` complete, and the machine survives them.  It took **two**
fixes, and either alone leaves the machine dead.

**1.  `@LH` did not sign-extend** (`src/iop_msc_instr.c`).  `FIOMNTR2` reads
`TCVTMTTG`, the time-to-go of an I/O operation, and branches on its sign; a
negative value means the I/O is overdue.  Zero-extended, `-1` read as 65535 and
armed `FIOMDLY` with a bogus MSC sleep of up to 65535 x 33 us = **2162.7 ms**.
DK completions then ran ~1053 ms late, DEU fill requests queued, the 25-entry
IOQE pool drained, `FIOSVC` walked onto the `080ce` sentinel, the store-protect
program check cost `FPMIHPC2` its `CALL FPMITUPD`, Clock 2 was never re-armed,
and phase 8's overlay never posted.  Fixed, and **on by default**.  After it:
OPS 901 reads 34 blocks from `6/5/0/0`, OPS 201 reads 250 from `1/5/0/5`, OPS
301 reads 162 from `6/5/2/0`; `FTRMGPOV` posts; zero sentinel faults; longest
DK hold 78 ms against 4264 ms before.

**2.  Eighteen unresolved cross-phase Z-CONs in the root image** (section 7b).
With the loads working, the machine ran on into a `SCAL` through an **unfilled**
Z-CON and stopped with `invalid instruction 0xc6c6 at 0x48da`.

> **I MISSED THE SECOND FAULT BY NOT READING THE STOP REASON.**  Seven runs
> after the `@LH` fix were scored as successes because the transition completed
> and the tape reads were right.  Every one of them had in fact stopped on the
> invalid instruction, at a fixed ~226 million steps.  The pre-fix runs end on
> `interrupted (SIGINT)`, the harness timeout, because the machine was parked
> in `FPMIDLE` and never crashed -- so "ended at the timeout" and "crashed" look
> alike unless you read the line.  **Read `STOPPED after` before believing any
> run.**

Measured, same recipe and wall time, v37 (= v36 plus section 7b) against v36:

| | v36 | v37 |
|---|---|---|
| stop reason | `invalid instruction 0xc6c6 at 0x48da` | `interrupted (SIGINT)`, the harness timeout |
| simulated time | 404.05 s | **613.70 s** |
| steps | 226,882,033 | **379,270,912** |
| final NIA | `648da`, `BSR=12` -- unloaded fill | `080c6`, `BSR=1` -- normal |
| `6/5/0/0` read | yes | yes |

v37 ran **210 s of simulated time past the point where v36 dies** and stopped
only because its wall clock ran out.  Both tapes read `6/5/0/0`, so the
transition itself is the `@LH` fix's doing; section 7b is what lets the machine
live through it.

The crash is **not** a CPU defect.  `SCAL` is not in the PoO's Branch
Operations list -- it is catalogued under *Special Operations* -- but section
9.7 says "First, a branch address is computed... This is essentially a BAL
instruction", so it is branch-type for addressing and `OPTYPE_BRCH` on it is
correct.  Every digit of the crash follows from the unfilled Z-CON.

> **BEFORE SPENDING A RUN, ASK THE LEDGER.**  Causes investigated and fixes
> attempted live in `gpc-causes.db`, generated to `CAUSES.md`:
>
>     ./gpc-causes.py addr 1010d      is this address already accounted for?
>     ./gpc-causes.py search pacing   has this idea already been tried?
>     ./gpc-causes.py list --status=refuted
>
> Addresses are recorded as ranges and answer point queries.  An entry marked
> `refuted` carries the evidence and the run that settled it; do not retest one
> without new evidence.  This exists because the observed failure mode is not
> forgetting a fact but **rediscovering and re-refuting the same cause**.

### Historical: the two blockers as they looked before the fixes

Kept because the reasoning is reusable and because both builds' symptoms are
recorded nowhere else.  **Everything from here to "Diagnostics added for this
work" predates the `@LH` fix** and describes a machine that no longer exists.

They share an outcome and must not be conflated.  Fixing either alone will not
produce `6/5/0/0`.

| build | fault | when | pool overflow |
|---|---|---|---|
| ours (v36) | IOQE exhaustion -> `FIOSVC` walks onto the `080ce` sentinel | ~395-398 | yes |
| `pass-910` | `FCMPMOD` store-protect at `0x1010d` | ~389-392 | **none** |

Our tape shows **no** `FCMPMOD` fault at all; its program-check list is the
three GPCIPL self-tests plus the `FIOSVC` one.  Both end the same way: a
program check abandons a process, `FPMIHPC2` misses `CALL FPMITUPD`, Clock 2
is never re-armed, phase 8's mass-memory transaction never completes, and
phase 18 is never requested.

### What is invariant across every run

* `FCMMGPOV` is entered **twice** for the transition and never a third time.
* `$0ARCGPC` is entered **exactly twice**, parked in `WAIT FOR ARC_OVL_EVT`.
* Phase 8's data **does** arrive off the tape.
* `CZ2V_GRT_MC_PHASES` rows are FIVE halfwords; row 9 (OPS 9 GNC) reads
  **3, 8, 18**.  `dass-combine.py` agrees independently: `"G9":(3,8,18)`.
* **`TCVTMMA` never clears.**  The phase-8 mass-memory transaction is still
  outstanding at the end of every run, on both builds.
* Clock 2 dies during the transition on both builds.  In `FPMIHPC2` the only
  re-arm is `CALL FPMITUPD` (line 288) and **both** exits are after it, so a
  handler that runs to completion re-arms the clock.  Measured: 32 of 33 PC2
  passes reach `FPMITUPD`; the 33rd diverges at `FPMIHPC2+561` into
  `FIOSVC -> FPMIHPGM -> FPMERLOG -> FPMDISP`, the program-check path.

### Our build: the IOQE chain, measured end to end

1. `AIG_DEU_LOADER` issues **eight** DCP fills per DEU
   (`AIGDEU.hal`, `OUTER: DO FOR AIGV_NUM_OF_FILL = 1 TO 8`), each followed by
   a **timed** `WAIT 0.018` — not a wait on completion.  The status words are
   pre-zeroed and only a non-zero value is an error, so an unfinished I/O reads
   as success and the loop issues the next fill regardless.
2. In our emulator the fills do not complete inside 18 ms, so all eight stack.
   **8 fills x 3 DK buses + 1 mass memory = 25 = exactly the pool**
   (`NIOQE=25`).  FCOS sized it for this; we sit at capacity and overflow by
   one.
3. `FIOSVC` then walks onto the free list's deliberate sentinel
   (`GENERATE.asm:335`, `DC Y(FPMSVCEP)`) and the store-protect that follows is
   **FCOS's queue-overflow detector working as designed**.
4. That program check costs the PC2 pass its `FPMITUPD`, and the clock stops.

The free list is a full 25 from t=150 to t=389, drains 25 -> 0 across
t=392-397, and **recovers to 24** by t=402: a spike, not a leak.  The open link
is why a completed DK transaction does not clear its `TCVTBCEB` bit for ~1 s.

### The other build: the FCMPMOD protection gap

Traced from the NIA ring dumped at the program check:

    FPMIHPC2 -> FPMITUPD -> FPMDISP      (a PC2 pass completing NORMALLY)
      -> $0AIESIP -> SVC -> FPMSVC
      -> FCMPMOD+98 stores to #CDG9LIG+21 (0x1010d) -> PGMCHK 0007
      -> FPMIHPGM -> FPMERLOG -> FPMDISP

`FCMPMOD` is **SVC 26, "MAIN MEMORY PROGRAM MODIFICATION"**.  It does not test
the hardware — it branches on a **caller-supplied** flag:

    IF (TB,TMODFLGS,TMODSSP,O)  THEN DATA WORD IS PROTECTED
        ISPB@# 0 / STH@# / ISPB@# 2        unprotect, write, reprotect
    ELSE                         DATA WORD IS NOT PROTECTED
        STH@# R3,0(R7,R0)                  write directly

The caller said "not protected", so it wrote directly.  `0x100f8..0x1010d` was
unprotect-written-**reprotected** by the SSL loader at t=119.6 and never
unprotected again; the phase-8 overlay's unprotect walk (`FCMMGBOV+423`,
`m1=1`, 1914 `ISPB`s) begins at `0x1010e`, one halfword above the faulting
store.  The loop itself reads correctly — it covers every even offset from
`len-2` down to 0 — so the defect is in its **inputs**: either `FCMOVZC` is
wrong for that block, or the block never gets a walk.

### Diagnostics added for this work

All gated, all off by default.

| hook | what it answers |
|---|---|
| `YAGPC_FIRSTOP` | first execution of each opcode, with processor, address, time — finds instructions that debut at the transition and so have never been exercised |
| `YAGPC_IOQEDEPTH` | IOQE free-list depth per second, plus queue heads and `TCVTMMA` |
| `YAGPC_PGMTRACE` | every program check taken, with code and faulting address; dumps the IOQE pool on a sentinel hit and the NIA ring on the first non-IPL check |
| `YAGPC_NIAWINDOW` | every instruction in a window of simulated time |
| `YAGPC_MSCSTATE` / `YAGPC_BCESTATE` | the halt/busy bits that gate a processor, and per-second slice counts |
| `YAGPC_DKSTALL` / `YAGPC_DKRATE` | DK bus transmit census; **`DKRATE` measures command-to-command GAPS, not transfer time** |
| `YAGPC_ODDFW` | fullword reads at an odd address |
| `YAGPC_BUS_WORD_US` | models the wire as busy per word.  **Failed three times; left off.** |

### Method rules learned the hard way

* **No `.mmv` is an original.**  Every tape is one we built, `pass-910.mmv`
  included.  It can show that two builds differ; it can **not** establish that
  either is correct.  Any argument of the form "the original didn't do this,
  so the defect is ours" is circular.
* **The authoritative manuals are in the local ibiblio mirror** and went unused
  for most of this work.  `IBM-74-A31-016` is a *summary* that defers BCE
  instruction detail to the **BCE Principles of Operation**
  (`IBM-6246556A` part 3, OCR'd, `pdftotext -layout`).  Going to it found the
  `#RDL` defect in minutes.  The MSC and AP-101 manuals are beside it.
* **The DASS dumps cannot validate runtime-built areas.**  They are as-built
  images, so bus programs and scratch read as zero.  "Absent from the dumps" is
  evidence only for statically linked code.
* **The JS reference fixtures encode the bugs they should catch.**  Both the
  `@RAW` and `#RDL` fixtures pass with the defect and with the fix.
* **Judge a run's validity before its result.**  Require `keys=2`,
  `latereads >= 2`, and `SIMULATED TIME` past 410 s.  Several readings this
  session came from runs that never reached the transition.
* **The MMU trace goes stale by design** — nothing touches the tape between
  t=13 s and t=130 s — so it is not a progress indicator.  The emulated clock
  is in `gpc.log`'s `SIMULATED TIME` at exit.
* **`pgrep -f` matches the shell running it.**  Use
  `ps -eo args | grep "[y]aGPC2 run"`, and exclude `$$`/`$PPID` when killing.

### Run-to-run variability is real

Same configuration, differing only in instrumentation, has given materially
different violation counts, and the fault time drifts by seconds between runs
(392.73, 391.85, 389.69 on the same build).  **Single runs are not evidence;
confirm any effect twice**, and never key a trace window to a time observed in
a previous run.
## What this tape has that its predecessors did not

| | earlier tapes | v27 |
|---|---|---|
| phase 2 | 617 blocks (oversize), or 211 with an `FPMRESET` hole | 233 blocks, `FPMRESET` present |
| overlay content in phase 2 | 307 blocks | 0 |
| foreign-configuration csects | 31, and the tape's top of memory trimmed away | 0 |
| relocation | assembler-relative offsets in the I/O and display branch tables | applied |
| phase 3 | `LB2` straddling `FCMLINIT` | reproduces the original block for block |
| process stacks | 0 of 30 | 28 of 30, 24 at flight addresses |
| in-core phase table | zeros | 813 non-zero halfwords |
| `FCMSSLPT` | zeros | 606 non-zero |
| oversize phases | phase 2 | none |
| **what it does** | idles, or halts in a masked wait | **reaches the GPC MEMORY menu** |

Code divergence from the flight machine — linked `PHASE02.fcm` against
`pure-SSW.fcm` over code csects only, where a difference cannot be runtime
state — went from **8.37 %** to **0.50 %** over this work.

## What is still open

* **The per-phase links' unresolved relocations.**  Section 7b patches 88
  halfwords onto the finished volume; the build should not need patching.  It
  is not only the root: phase 8's link leaves its references into the root's
  `FIOCDATS` unresolved too, while three other phases' links of the *same*
  module (`FIOPDSMU`) resolve them -- so compare how those phases are linked.  678
  relocations over 304 distinct symbols are unresolved in `PHASE02`, and the
  eighteen are only the currently-fatal subset — `#PCDHMMU` alone has 179
  unresolved references.  `phase3/PHASE02.lib` (09-05) already gets the Z-CONs
  right, so this is a bisect between 09-05 and 09-08, not new work.
  `gpc-causes.py list --status=open` is the live list.
* **Four Z-CONs hold wrong values rather than fill** — `0x1E8`, `0x202`,
  `0x218`, `0x22C`, each with bit 0 clear where all eight DASS dumps have it
  set, so the target is taken as sector 0.  Deliberately not patched.
* **Build provenance -- RESOLVED 2026-09-10.**  The volume is now built by
  `tapebuild/build.sh` from pinned sources and committed inputs, and verified
  byte-identical to the tested v41 (sections 0-3).  What had been wrong: the
  v36 build script lived only in `/tmp/claude-1000/buildtape.sh`, several
  inputs had no recipe, one object in `~/pass-build/OI340700` had drifted, and
  `dfg` was an uncommitted working tree.  An earlier note here said "no tree on
  disk reproduces v36's root block"; that was **wrong** -- v36's own staging
  survives at `/tmp/claude-1000/c80v36`, with a `.lnk101.repro.json` per phase
  recording every input and its md5, which is how the drift was found.
* **The old DK question is closed by the `@LH` fix** and should not be
  reopened: a completed DK transaction was never slow to clear `TCVTBCEB`; the
  monitor was asleep for up to 2.16 s on a sign-extension bug.
* **`#RDL`'s count read was wrong and is fixed, but latent.**  It used a
  halfword access masked to 16 bits and did not ignore the address LSB, where
  the BCE PoO specifies bits 14-31 of the *fullword* with the LSB ignored —
  the same defect already fixed in its twin `#TDL`.  It never executes in this
  workload (BCE18 uses the immediate `#RDLI`), so the fix rests on the
  documentation and cannot be confirmed by a run.
* **The real end-of-load rule for a display unit is unknown.**  This model
  uses GPCIPL's 250-halfword final fill, which only ever recognises the load of
  the BFC-selected unit; `YAGPC_DEU_EXTRA_PRELOADED` is a stand-in, not an
  answer.  The user's `MEDS2-port.py` shows the same symptom from the other
  side — clock but no menu under GPCIPL, correct from GPC MEMORY onward — so
  it may well settle what the terminator actually is.
* **Phase 16 does not link** (`CON80/SM4TAB`, above), and is skipped with
  `mmustamp --skip-phase 16`.  `HALSTAT.ASC`'s SM4 map is the one description
  of it we have.
* **The `GPC POWER REFAIL` message.**  It tracks our `GPCIPL` exactly — present
  on v2–v17 and v27, absent on v18–v26 which carried the reference's — but it
  does **not** block the load, and our `GPCIPL` is bit-exact to the original
  IBM listing (`PFS/temp/temp/BILDNEW5.lst`, VER 9.05 09-23-96): 0 mismatches
  in 13,285 halfwords, against 1,167 for the GPCIPL inside
  `pass-ipl-cflm.mmv`.  It is not a build defect of ours.

### Closed since the last sync

* **POLL FAIL after OPS 201, 301, 801 and 901** -- fixed on v41 by section 7b's
  `resident` and `phase8` groups; confirmed headless and interactively.  See
  "The POLL FAIL after 201, 301, 801 and 901" above.
* **`tools/patch_unresolved.py`** supersedes `patch_root_zcons.py`; its data
  is `tools/patch_unresolved.fills.json`.
* **Diagnostics fixed or added:** `YAGPC_BUSLOG` now flushes every simulated
  second (it lost its whole tail on every SIGINT-ended run, which is how every
  healthy run ends); `YAGPC_RINGTRIG` now sees fullword stores (it was blind to
  `STM`, `ST` and PSW saves); `YAGPC_MSCRING=<n>` keeps the last *n* MSC
  instructions and dumps them at the first DMA store-protect violation.
* **`OPS 901/201/301 PRO` now complete and the machine survives them** — the
  `@LH` sign-extension fix plus section 7b's Z-CON fill.  Measured against a
  v36 control in the same session; see the section above.
* **The `0xc6c6` crash at `0x648DA` is not a CPU defect.**  `SCAL` is not in
  the PoO's Branch Operations list — it is catalogued under *Special
  Operations* — but section 9.7 ("Stack Call") says "First, a branch address is
  computed... This is essentially a BAL instruction", so it **is** branch-type
  for addressing, and `OPTYPE_BRCH` on it is correct.  The pointer's field
  layout is confirmed independently by the data: the real Z-CONs around the
  hole read `0x0E80` = `XC=1 C=1 CB=1 BSR=8`, exactly what a cross-sector call
  needs.
* **`tools/patch_root_zcons.py`** — new, and labelled a workaround in its own
  header, like `patch_ssl_zcon.py`.
* **A searchable ledger of causes now exists** — `gpc-causes.py` over
  `gpc-causes.db`, generated to `CAUSES.md`, following the same pattern as the
  `dass-handoff.py` handoffs (database is the source, Markdown is generated,
  `check` proves no drift, a hand edit is silently overwritten).  Seeded with
  23 entries from this work: 16 refuted, 3 open, 2 fixed, 2 confirmed.
  Seventeen searchable fields, including addresses **as ranges answering point
  queries** — `addr 10120` finds the entry recorded as `100f8-10129`.
* **Instruction auditing by first execution.**  `YAGPC_FIRSTOP` reduced 58
  opcodes to the single one debuting at the transition (`#DLY`, BCE18,
  `0x1d204`), which was then exonerated against the BCE PoO on four counts.
  The technique found a real defect (`#RDL`) on the way.
* **`pass-910.mmv` is not an original tape.**  Retracted; every `.mmv` is one
  we built.  Any conclusion that used it as a control for "the real machine
  did X" is void.

* **Phases 4, 5, 6, 7, 8 and 15 came out short.**  Fixed by giving each phase
  the csect table of the configuration it belongs to: 8 of 14 phases now match
  the original's block count exactly, with no oversize phase and all 30 stacks
  at the exact flight address and size.
* **The csect table now generalises**, per phase, chosen by counting how many
  of the phase's linked csects each dump contains.
* **The `STACK` cards** are uncommented in the user's own deck.
* **Queued for Don** — now **open as PRs against `ColanderCombo/nsts-sdl-dps`**:
  **#49** the resident HAL/S library never reached any phase (`.asmg.json`
  sidecars that do not exist, duplicate-by-path rather than by csect name, and
  generated stacks pinned from the csect table for address *and* size);
  **#50** `mmustamp --skip-phase`; **#51** `mmu2mmv` refusing a tape whose
  Mass-Memory-Build tables were never stamped.  `buildtape.sh` now takes its
  tooling root from `$C80SRC`, so once these land it can point at a real
  checkout instead of the scratch copy.  Note that a bare clone links
  *nothing* and reports it only as a blank line per phase: `con80build`
  resolves its `--runlib`/`--linklib` DEFAULTS relative to the cwd, so the
  checkout needs `ext/{virtualagc,sim,halmat}` populated and
  `build/lib/runtime/{RUN,ZCON}` present.
* **Tape v36** is the first built from Don's tooling at upstream `db9d34b`
  with our fixes merged rather than from the scratch copy.  It is **not**
  byte-identical to v35 — phase 7 224 -> 230 blocks, phase 9 23 -> 25, phase
  12 215 -> 216, everything else unchanged and all within allocation — and the
  difference is Don's own work since our base (PR #38, placement-only
  CSECT-table entries), not our patches.  Phase 12 at 216 now matches the
  original's exactly, where v35 was one block short.  Verified booting,
  running PASS, and transitioning.
