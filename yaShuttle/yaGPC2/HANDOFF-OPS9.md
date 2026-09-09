# Building the OPS 9 tape

How the volume `OI340700-v27boot.mmv` was produced, finished 2026-09-09.

**This tape boots.**  It IPLs, loads G9 and reaches the **GPC MEMORY** menu
screen, and every part of it comes from our own chain — every module compiled
by `HALSFC` and assembled by `ASM101S`/`ASM101Sa`, our own `GPCIPL`, our own
stamped `FCMSSLPT` and `#PFCMGPT`, nothing spliced from a reference volume.
Its final DEU image is identical, 0 of 8192 words differing, to that of v26,
which was the same tape still carrying the reference's `GPCIPL` — so nothing
on that screen depended on the borrowed content.

Written to be executable, not narrated.  Where a step exists because of a
defect, the defect is named in one line and the detail is in
`modules/sdfpkg/HANDOFF-OI340600.md`.

The procedure below is the v27 one.  Earlier revisions of this file described
the v8 tape, which cut cleanly but did not run; the differences are called out
where they matter and summarised at the end.

---

## 0.  What you need before you start

| symbol | is | note |
|---|---|---|
| `$T` | `~/pass-build/OI340700` | the staged OI340700 tree: `CON80/`, `SSSRC/`, `APPLSRC/`, `objects/`, `SYSLIBL1/`, `lib/runtime/{RUN,ZCON}` |
| `$S` | `/tmp/claude-1000/c80src` | **a patched copy** of `nsts-sdl-dps/src` — see §1 |
| `$P` | `/tmp/claude-1000/pchsrc` | the extensionless patch-source directory |
| `$SD` | `/tmp/claude-1000/sdfpad` | `SDFLIB` with the 132 minimum-size SDFs padded past 3360 bytes |
| — | `/tmp/claude-1000/extsyms-02-plus.json` | the csect table for phase 2 and phase 3 (SSW-only, extended) |
| — | `$T/phase/extsyms-13.json` | external-symbol pins for phase 13 |
| — | `~/workspace/pass-run/pass-910.mmv` | donor for the DEU load modules (§7) |

`$T` is a **reconstruction**.  A zero-byte `.hal` in it is not damage: it
means *the OI340600 file is not used in OI340700*.  There are 37 of them and
they must not be filled in from `PFS/OI340600`.  The same 37 are zero-byte in
`PFS/OI340700`, which is a sparse overlay on OI340600 rather than a whole
release.

---

## 1.  The patched toolchain, and why it is a copy

Don's checkout diverged and will not fast-forward, so `con80build`,
`mmu2mmv`, `mmustamp` and `mmbstamp` are run from a patched copy at `$S` with
`PYTHONPATH=$S`, from inside `~/donschmidt/nsts-sdl-dps`.  Five changes, none
of them upstream yet:

1. **`con80build --external-syms FILE`** — passthrough to `lnk101`.
2. **`con80build --nocall/--no-nocall`** — override the deck's `NOCALLER`.
   *Not used by this procedure*; the default (`--nocall`, honour the card) is
   what the tape was built with.
3. **`con80build --insert-root CARD`** — scan INSERT cards from one deck root
   while laying out at another.  *Not used*: it was measured to make no
   difference to phase 2, and neither does `--concard-root SSW`.
4. **`mmu2mmv`** refuses a tree whose `#PFCMGPT` is all zeros, with
   `--allow-unstamped` to override.  Guards §5 — a tape built without it
   carries a phase table of zeros, every descriptor reads a segment count of
   zero, and no OPS transition can load anything.
5. **`mmustamp --skip-phase N`** and `mmbstamp.generate(skip=…)` — treat a
   phase as unassigned, giving it the placeholder descriptor phases 11 and 17
   already get, instead of failing when its load module is missing.  Required
   by §6, because phase 16 does not link.

---

## 2.  Stage each phase's object and SDF directories

`con80build` reuses an existing `<out>/PHASEnn/obj/NAME.obj` instead of
recompiling, and accepts a prebuilt SDF only if it is larger than 3360 bytes.

```bash
T=~/pass-build/OI340700; S=/tmp/claude-1000/c80src
C=/tmp/claude-1000/c80boot; P=/tmp/claude-1000/pchsrc; SD=/tmp/claude-1000/sdfpad
rm -rf $C; mkdir -p $C
for p in 1 2 3 4 5 6 7 8 9 10 12 13 14 15 18 23 24 25; do
  n=$(printf "PHASE%02d" $p)
  mkdir -p $C/$n/obj $C/$n/gen
  ln -s $T/objects/*.obj $C/$n/obj/ 2>/dev/null
  for s in $T/objects/PCH*SRC.obj; do
    b=$(basename $s SRC.obj); ln -sf $s $C/$n/obj/${b}TXT.obj
  done
  cp -r $SD $C/$n/gen/SDFLIB
done
```

The `PCHnnSRC.obj` → `PCHnnTXT.obj` aliasing is required: `_PATCH_SRC_RE`
assumes an extensionless member name and does not find the patch text
otherwise.

> **The `obj/` entries are symlinks into `$T/objects`.**  Anything that writes
> into them writes through to the real object.  After every build, check
> `find $T/objects -name '*.obj' -size 0 | wc -l` is still 0.

---

## 3.  Build a minimal INSERT library **for every phase**

**This is the step that makes the phases fit.**  `SYSLIBL1` holds one object
per csect, 4,277 of them, and passing it whole lets `lnk101` satisfy a
phase's references to compools that live in *other* phases by pulling them in
locally — which the deck's `NOCALLER` card is supposed to prevent.  In phase
2 that contributed **307 blocks of other phases' content**, taking it to 617
blocks against a 256-block allocation.

> **Do not treat this as a phase 2 problem.**  Fixing phase 2 alone moved it:
> phase 9 went from 22 blocks to 180 and overlapped phase 3's area, gaining
> the same compools — `#PCDIMMU`, `#PCD1MMU`–`#PCD4MMU`, `#PCVTTCS`.  They
> were never *in* phase 2; a fat phase 2 was **suppressing** the pull for
> every phase that maps it, because `con80build` gates a pull on whether a
> mapped phase's load module defines the symbol.  The in-core phase table
> settles where they really belong: `#PCDIMMU` is loaded by phases 4, 5, 6,
> 7, 8, 12 and 14, and by neither 2 nor 9.

The rule is therefore general: **a phase may take from `SYSLIBL1` only the
csects its own deck root INSERTs.**  Every phase's INSERT list resolves in
the library almost entirely — 430 of 431 for phase 2, 105 of 105 for phase 3,
29 of 29 for phase 9 — and a library is searched only for *undefined*
symbols, so passing a phase's whole INSERT list is equivalent to passing just
the subset it actually lacks.

```bash
cd ~/donschmidt/nsts-sdl-dps
PYTHONPATH=$S python3 - <<'PYEOF'
import os, sys
sys.path.insert(0, "/tmp/claude-1000/c80src")
from con80.con80build import concard
T = "/home/rburkey/pass-build/OI340700"
deck = concard.ConcardDeck(T + "/CON80")
base = "/tmp/claude-1000/minilibs"
os.makedirs(base, exist_ok=True)
for p in (1,2,3,4,5,6,7,8,9,10,12,13,14,15,18):
    root = "PHASE%02d" % p
    ins = {op.operand for op in concard.layout_program(deck, root)
           if op.verb == "INSERT" and op.operand}
    d = os.path.join(base, root)
    os.makedirs(d, exist_ok=True)
    for f in os.listdir(d):
        os.unlink(os.path.join(d, f))
    n = 0
    for name in sorted(ins):
        src = os.path.join(T, "SYSLIBL1", name + ".obj")
        if os.path.exists(src):
            os.symlink(src, os.path.join(d, name + ".obj")); n += 1
    print("%s: %d of %d INSERTs in SYSLIBL1" % (root, n, len(ins)))
PYEOF
```

Phases 23–25 have no deck root of that name and are one object each; give
them `SYSLIBL1` whole.

### The phase 2 subset, for reference

Diffing a `SYSLIBL1` link against a no-library link shows phase 2 needs
exactly 21 of its 431 INSERTs from the library, carrying 18 blocks with zero
overlay content — all resident FCOS/FIO/FPM csects:

```
FCMBMASK FCMBMTPG FCMBUSPC FCMTBLPG FIOACTMD FIOCYCTB FIOERRLB FIOERRLC
FIOHFEPG FIOMGCV  FIOMGSTR FIOPBYTB FIOPDISP FIOPDSMU FIOPDSRB FIOSVCP
FPMCVTFX FPMIHPC2 FPMIHPGM FPMMTURM FPMRESET
```

You do not need to reproduce that subset — the per-phase library above is a
superset of it and the linker takes only the symbols it lacks.  It is
recorded because it is a cheap check that phase 2 came out right.

---

## 4.  Link the phases, in ascending numeric order

Order matters: a phase's `MAP n,…` cards are resolved from earlier phases'
`.lib` files, which is how the per-phase build models the linkage editor
processing `OFTMP` as one job.

```bash
cd ~/donschmidt/nsts-sdl-dps
for p in 1 2 3 4 5 6 7 8 9 10 12 13 14 15 18 23 24 25; do
  ML=/tmp/claude-1000/minilibs
  RT="--linklib $T/lib/runtime/RUN --linklib $T/lib/runtime/ZCON"
  extra=""
  case $p in
    1|10)     lib="" ;;                               # no library at all
    23|24|25) lib="--linklib $T/SYSLIBL1 $RT" ;;      # no deck root by name
    *)        lib="--linklib $ML/$n $RT" ;;           # this phase's INSERTs
  esac
  [ $p -eq 2 ]  && extra="--external-syms /tmp/claude-1000/extsyms-02-plus.json"
  [ $p -eq 3 ]  && extra="--external-syms /tmp/claude-1000/extsyms-02-plus.json"
  [ $p -eq 13 ] && extra="--external-syms $T/phase/extsyms-13.json"
  PYTHONPATH=$S timeout 1800 python3 -m con80.con80build --phase $p --root $T \
      --src $P --src $T/SSSRC --src $T/APPLSRC --out $C --link $lib $extra 2>&1 \
    | grep -E 'linked|FAILED' | head -1
done
```

### The csect table must be **complete for this phase's configuration**

`--external-syms` is not a symbol list; it **is the linker's csect table**, and
`linker.py`'s `applyRelocations` skips any relocation whose target section the
table does not name — leaving the assembler's own bytes in place.  Get its size
wrong in either direction and the failure is silent:

| table | what happens |
|---|---|
| absent | nothing is suppressed; relocation against fabricated addresses.  Phase 13's image collapses 330,391 → 16,127 halfwords and the tape re-reads it forever |
| **pruned** | real csects keep **assembler-relative offsets**.  `FIOPDISP+116` reads `0033` where the flight machine has `B9AD`.  The display dispatcher then branches into low memory, the DEUs are never polled, and FCOS idles in `FPMIDLE` |
| union of all 8 configs | every csect in the table is *placed*, so phase 2 gains 31 csects belonging to P9, S2, G9 and G16 — 59,521 halfwords.  Phase 2 overruns its 256-block allocation and `mmu2mmv` **trims the tail silently**, losing `$0AIBGPC`, `$0AIESIP`, `$0ARCGPC` and 132 more |
| **SSW-only, extended** | correct.  Foreign csects 0, phase 2 = **228 blocks, exactly the original's**, phase 3 = 38/38 |

Build it as the SSW table (660 csects) plus `contents` entries for the 27
parent csects whose members are referenced across phases; that takes unresolved
symbols from 658 to 290.  `extsyms-02-plus.json` is that file.

Phase 3 needs it too.  Without it phase 3's `LB2` runs `04572..060A8` while
`FCMLINIT` sits at `047E0..04A1F` — **entirely inside it** — so loading phase 3
DMAs over resident FCOS and the machine executes the wreckage
(`invalid instruction 0xc055 at 0x47e0`).  With it, phase 3 reproduces the
original block for block: `0024A..002AC`, `00654..00660`, `03A96..03FE0`,
`04C70..067A6`.

**Do not give it to the other phases.**  Applied everywhere it fragments the
phases whose full csect set we do not build — 756 load blocks against the
original's 298, phase 4 going 28 → 169 — which overflows `#PFCMGPT`'s 1093
halfwords and `mmustamp` refuses with `overflow at phase 6`.

Three different library policies, and each one is load-bearing:

**Phases 1 and 10 take no library at all.**  A blanket `SYSLIBL1` breaks
`FCMBOOT`: phase 1 goes from 7 sections and 3,624 halfwords to 8 and 20,017,
and the resulting tape gets through the 72-block bootstrap read and then
spins — 718 million steps at `NIA=0x00486` with every register zero, three
mass-memory commands in total, no phase ever read, the DEUs never IPLed.
Check phase 1 after linking: **7 sections, 3,624 halfwords**, matching
`~/ipl-demo/phases/PHASE01`.  Anything else and the tape will not boot.

**Every other phase takes its own minimal library** from §3, plus the HAL/S
runtime (`RUN`, `ZCON`), which is pulled by reference and is small.  With
that policy the phases come out close to the original:

| ph | ours | orig | | ph | ours | orig |
|---|---|---|---|---|---|---|
| 2 | **233** | 228 | | 9 | 24 | 25 |
| 3 | 44 | 38 | | 10 | 55 | 55 |
| 4 | 325 | 414 | | 12 | 206 | 216 |
| 5 | 254 | 292 | | 13 | 7 | 7 |
| 6 | 310 | 385 | | 14 | 114 | 107 |
| 7 | 196 | 230 | | 15 | 198 | 304 |
| 8 | 206 | 243 | | 18 | 30 | 34 |

"orig" is the contiguous-block count from the in-core phase table in
`pure-G9.fcm`, decoded by `/tmp/claude-1000/gpt.py`.  Phase 2 is 228 blocks
from the link and 233 once the process stacks are created (next section);
both fit its 256-block allocation.  Phases 4, 5, 6, 7, 8 and 15 are still
short; that is open and is not what this procedure fixes.

### Uncomment the `STACK` cards, or the tape has no process stacks at all

`lnk101` creates stacks in `generateStackSections()` from `stackCsectNames()`,
whose docstring is explicit: *"Primary source: the CON80 `STACK $0<prog>` cards
— SDL-mode objects carry no stack ERs at all, the cards are the only trigger."*
Our objects are SDL-mode, and in `~/pass-build/OI340700/CON80` **every one of
the 181 `STACK` cards is commented out** — an asterisk in column 1 — across
`SSW`, `OPS0`, `GNC1`, `GNC2`, `GNC3`, `GNC8`, `GNC9`, `MFB14`, `PL9` and
`SM4`.  `con80build` never passes `--generate-stacks` either, so even an active
card set would have had no fallback size.

The DASS SSW dump has 30 csects of type `STACK`; without this step our phase 2
has **zero**.  The first store into one is then a program check —
`YAGPC_INTTRACE=1` shows `store-protect at 013be`, which is `$0AIBGPC`, from
`FCMLINIT+407` — and everything downstream follows from it: the masked wait,
the resume address of `$0AIBGPC+0`, the DEUs never polled, the display never
leaving the GPCIPL banner.

```bash
# work on a COPY; the user's deck is reconstructed and is not modified
cp -r ~/pass-build/OI340700/CON80 /tmp/claude-1000/CON80s
sed -i -E 's/^\*(\s+STACK\s+\$0)/ \1/' /tmp/claude-1000/CON80s/{SSW,OPS0,GNC1,GNC2,GNC3,GNC8,GNC9,MFB14,PL9,SM4}
# then link with --concards /tmp/claude-1000/CON80s and --generate-stacks 256
```

Result: 28 of the 30 stacks, **24 at exactly the flight machine's address**,
`$0AIBGPC` among them at `0x013BC`.  Four come out one halfword larger and
shift accordingly; `$0ASCTIM` and `$0ASGCYC` are still not generated.

**Whether those asterisks belong in the deck is an open reconstruction
question for the user.**  The flight machine has the stacks and our SDL objects
cannot produce them any other way, so for our build the cards must be active.

### Phases 16 and 26 are omitted, deliberately

**Phase 16 (`SMASM4`, memory configuration 5) does not link.**
`CON80/SM4TAB` carries `CHANGE #PCSADAR(#PCS4DAR)` and ten more, rebinding a
generic module to the SPEC-4 compools — whose modules are exactly the ones
OI340700 marks excluded.  The rename leaves `#PCS4DAR` unresolved,
`con80build`'s autocall guesses `CS4DART.hal` from the naming convention,
compiles the zero-byte source into an 80-byte END-record object, and `lnk101`
refuses it.  Two reconstructed artefacts disagree; which is wrong is open.

**Leaving phase 16 out does not affect phase 18**, checked four ways:
`CON80/PHASE18` maps phases 2, 3 and 8 and not 16; the allocations are
disjoint (16 is tape blocks 7520–7872, 18 is 11776–11840); 16 is memory
configuration 5 against 18's 9, so a G9 transition never requests it; and in
the phase table only the running displacement of later phases moves, which
`FCMMGBOV` reads out of the descriptor.  Phase 18's load-block count, mass
memory address and all eight of its load-block descriptors are unchanged.
The only deck that maps 16 is `CONCARDS/SMPLRID`, under phase 26.

**Phase 26** fails for want of its MAP phase libraries and is outside the
phase table's 3–18 range.

---

## 5.  Stamp the Mass-Memory-Build tables into the load modules

Two separate stamping steps, both between the link and the tape, and
**neither is called by `con80build` or by `mmu2mmv`**.  Skipping them is why
earlier tapes could not transition.

```bash
# 5a.  FCMSSLPT -- phase 10's own IPL phase table.  Descriptor halfword 0
#      doubles as the "this system was mass-memory built" flag and the loader
#      skips the whole load when it is zero.
cd ~/donschmidt/nsts-sdl-dps
PYTHONPATH=$S python3 - <<'PYEOF'
import sys; sys.path.insert(0, "/tmp/claude-1000/c80src")
from pathlib import Path
from ap101Utils import mmbstamp as mb
C = Path("/tmp/claude-1000/c80boot"); T = Path("/home/rburkey/pass-build/OI340700")
sslpt, notes = mb.generate_sslpt(C, T / "CON80")
p = C / "PHASE10.lib"
at = {s["name"]: s for s in mb._lib_sym(p).get("sections", [])}
lib = mb.LibModule.read(p)
mb._splice(lib, at[mb.SSLPT_CSECT]["address"], list(sslpt), mb.SSLPT_CSECT)
lib.write(p)
print("FCMSSLPT stamped, %d non-zero" % sum(1 for w in sslpt if w))
PYEOF

# 5b.  #PFCMGPT, #PCDCPHA and FCMG3DAT into PHASE02.lib.
PYTHONPATH=$S python3 -m tools.mmustamp --mmu $C --con80 $T/CON80 --skip-phase 16
```

Expect `FCMSSLPT stamped, 606 non-zero` and

```
    2  #PFCMGPT  0x01ccf2  1093       0     870
    2  #PCDCPHA  0x0300e4    57      57      48
    2  FCMG3DAT  0x004b48   161       0      98
```

`#PFCMGPT` **must** be at `0x01ccf2`.  A different address means phase 2 has
linked its csects somewhere the original did not, and the tape will be wrong
in ways that show up much later.

Re-run 5b after any relink: the tables are a readout of where the linker put
every csect.  `mmustamp --restore` undoes it from the sidecars.

---

## 6.  Cut the tape

```bash
V=/tmp/claude-1000/OI340700-v27.mmv
cd ~/donschmidt/nsts-sdl-dps
PYTHONPATH=$S timeout 900 python3 -m tools.mmu2mmv \
    --con80 $T/CON80 --mmu $C --area 1 --out $V
```

**No row may say `OVERSIZE`.**  The DEU rows saying `not supplied`
(`DEUDCPLM`, `DEUCFLM`, `DEUSTLM`) are expected and are handled by §7.

---

## 7.  Splice in the DEU load modules and close the checksums

`mmu2mmv` does not generate the DEU load modules, so they are taken from a
volume that has them.  The eight ranges below are exactly the allocations
`mmu2mmv` reported as `not supplied`.

```bash
python3 - <<'PYEOF'
import struct
def load(p):
    raw = open(p, "rb").read()
    hw, ent, flag = struct.unpack(">III", raw[8:20])
    dirs = list(struct.unpack(">%dI" % ent, raw[32:32 + 4 * ent]))
    off = 32 + 4 * ent
    return raw[:8], hw, flag, {d: raw[off + i*hw*2: off + (i+1)*hw*2]
                               for i, d in enumerate(dirs)}
def bidx(t, f, s, b):
    return ((((f & 7) * 8 + (t & 7)) * 8 + (s & 7)) * 32 + (b & 0x1f))
magic, hw, flag, ours = load("/tmp/claude-1000/OI340700-v27.mmv")
_, _, _, ref = load("/home/rburkey/workspace/pass-run/pass-910.mmv")
n = 0
for f, t, s, b0, cnt in ((4,4,0,7,17), (4,4,7,8,17), (4,4,3,8,17), (4,4,4,8,8),
                         (4,4,4,16,8), (4,4,4,24,8), (4,4,0,24,8), (4,4,4,0,8)):
    for b in range(cnt):
        i = bidx(t, f, s, b0 + b)
        if i in ref:
            ours[i] = ref[i]; n += 1
dirs = sorted(ours)
out = bytearray(magic) + struct.pack(">III", hw, len(dirs), flag)
out += b"\0" * (32 - len(out))
for d in dirs: out += struct.pack(">I", d)
for d in dirs: out += ours[d]
open("/tmp/claude-1000/OI340700-v27boot.mmv", "wb").write(bytes(out))
print("DEU blocks forced: %d, volume %d blocks" % (n, len(dirs)))
PYEOF

python3 ~/git/virtualagc/yaShuttle/yaGPC2/tools/stamp_ssl_checksum.py \
        /tmp/claude-1000/OI340700-v27boot.mmv
```

The splice must be unconditional.  An "only if absent" version silently
copies 0 blocks when the target volume already has something there.

Expect `DEU blocks forced: 24, volume 2210 blocks`.

---

## 8.  Check the volume before booting it

```bash
python3 ~/git/virtualagc/yaShuttle/yaGPC2/tools/check_volume_destinations.py \
        /tmp/claude-1000/OI340700-v27boot.mmv
```

On the v27 volume this reports two blocks with `len C6C6` — the staging fill
pattern read as a length, inside a raw phase record.  The tool recognises one
load-block header form and says so; a length of 50886 halfwords is not a real
finding.  A block flagged with a *plausible* length and `BODY IS ENTIRELY
FILL` would be.

Confirm the phase table actually reached the tape.  **Match on the tree's own
bytes, not on a remembered signature** — the phase 3 descriptor's load-block
count differs between builds, and searching for another tree's bytes produces
a false negative.  This was got wrong twice.

```bash
python3 - <<'PYEOF'
import sys; sys.path.insert(0, "/tmp/claude-1000/c80src")
from pathlib import Path
from ap101Utils.libModule import LibModule
lib = LibModule.read(Path("/tmp/claude-1000/c80boot/PHASE02.lib"))
text = {}
for x in lib.extents:
    b = x.address // 2
    for i in range(x.hwLength):
        text[b + i] = (x.data[2*i] << 8) | x.data[2*i + 1]
gpt = [text.get(0x1CCF2 + i, 0) for i in range(1093)]
sig = b"".join(v.to_bytes(2, "big") for v in gpt[:12])
raw = open("/tmp/claude-1000/OI340700-v27boot.mmv", "rb").read()
print("GPT %d non-zero; on tape: %s"
      % (sum(1 for v in gpt if v), "yes" if sig in raw else "NO"))
PYEOF
```

Expect `GPT 813 non-zero; on tape: yes`, first descriptor `0040 000C 1BC0
0027`.

---

## 9.  Boot it

Kill any leftover `discretePanel` **before** the run, not only after — one
left from a previous run makes the GPC flap `HALT`↔`RUN`.

```bash
cd ~/workspace/pass-run
TAPE=/tmp/claude-1000/OI340700-v27boot.mmv DEUMF=1 \
DEUKEYS="@150:ITEM,1,EXEC;@430:OPS,9,0,1,PRO" RUN_AT=260 PORT_BASE=6900 \
./headless-gpcmem.sh 1500 ~/workspace/pass-run/headless-v27
```

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

So the gates are `@75` for `ITEM 1 EXEC`, about `@210` for anything that must
arrive once PASS is up, and `RUN_AT=140` — which is what `headless-gpcmem.sh`
now defaults to.  A 700-second run covers an OPS transition with margin.

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

The run that verified v27:

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

* **Phases 4, 5, 6, 7, 8 and 15 come out short** of the phase table's
  contiguous-block counts.  The undersized ones are display-heavy, which is
  why the zero-byte exclusion markers were the first hypothesis — but phase 15
  is 198 against 304 with its SPEC-2 sources all present, so something else
  undersizes phases as well.
* **Phase 16 does not link** (`CON80/SM4TAB`, above), and is skipped.
* **The csect table does not generalise** to the phases whose full csect set we
  do not build.  That has to be solved before an OPS transition can work.
* **The `STACK` cards** need the user's decision; the fix was tested only in a
  copy of the deck.
* **The `GPC POWER REFAIL` message.**  It tracks our `GPCIPL` exactly — present
  on v2–v17 and v27, absent on v18–v26 which carried the reference's — but it
  does **not** block the load, and our `GPCIPL` is bit-exact to the original
  IBM listing (`PFS/temp/temp/BILDNEW5.lst`, VER 9.05 09-23-96): 0 mismatches
  in 13,285 halfwords, against 1,167 for the GPCIPL inside
  `pass-ipl-cflm.mmv`.  It is not a build defect of ours.
* **Queued for Don**, all patched on the copy at `/tmp/claude-1000/c80src`:
  `mmu2mmv` should call `stamp_ipl` (or refuse an unstamped tree);
  `mmustamp --skip-phase`; `con80build --generate-stacks` and
  `--external-syms` passthroughs; `_PATCH_SRC_RE`'s extensionless member
  assumption; and autocall's SDF-size proxy, which should test the object
  rather than a byte threshold and read an empty source as absent rather than
  compile it.
