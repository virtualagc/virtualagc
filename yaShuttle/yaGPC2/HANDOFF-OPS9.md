# Building the OPS 9 tape

How the volume `OI340700-v8boot.mmv` was produced on 2026-09-08: the first
tape cut from our own OI340700 links with **no oversize phase**, with
`FPMRESET` present rather than a hole, and with a populated in-core phase
table.

Written to be executable, not narrated.  Where a step exists because of a
defect, the defect is named in one line and the detail is in
`modules/sdfpkg/HANDOFF-OI340600.md`.

Nothing here is claimed about whether G9 comes up.  This document covers
producing the tape; the run is a separate question.

---

## 0.  What you need before you start

| symbol | is | note |
|---|---|---|
| `$T` | `~/pass-build/OI340700` | the staged OI340700 tree: `CON80/`, `SSSRC/`, `APPLSRC/`, `objects/`, `SYSLIBL1/`, `lib/runtime/{RUN,ZCON}` |
| `$S` | `/tmp/claude-1000/c80src` | **a patched copy** of `nsts-sdl-dps/src` — see §1 |
| `$P` | `/tmp/claude-1000/pchsrc` | the extensionless patch-source directory |
| `$SD` | `/tmp/claude-1000/sdfpad` | `SDFLIB` with the 132 minimum-size SDFs padded past 3360 bytes |
| — | `/tmp/claude-1000/extsyms-02-pruned.json` | external-symbol pins for phase 2 |
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
  [ $p -eq 2 ]  && extra="--external-syms /tmp/claude-1000/extsyms-02-pruned.json"
  [ $p -eq 13 ] && extra="--external-syms $T/phase/extsyms-13.json"
  PYTHONPATH=$S timeout 1800 python3 -m con80.con80build --phase $p --root $T \
      --src $P --src $T/SSSRC --src $T/APPLSRC --out $C --link $lib $extra 2>&1 \
    | grep -E 'linked|FAILED' | head -1
done
```

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
| 2 | **229** | 228 | | 9 | 24 | 25 |
| 3 | 39 | 38 | | 10 | 55 | 55 |
| 4 | 325 | 414 | | 12 | 206 | 216 |
| 5 | 254 | 292 | | 13 | 7 | 7 |
| 6 | 310 | 385 | | 14 | 114 | 107 |
| 7 | 196 | 230 | | 15 | 198 | 304 |
| 8 | 206 | 243 | | 18 | 30 | 34 |

"orig" is the contiguous-block count from the in-core phase table in
`pure-G9.fcm`, decoded by `/tmp/claude-1000/gpt.py`.  Phases 4, 5, 6 and 15
are still short; that is open and is not what this procedure fixes.

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

Expect `FCMSSLPT stamped, 633 non-zero` and

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
V=/tmp/claude-1000/OI340700-v8.mmv
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
magic, hw, flag, ours = load("/tmp/claude-1000/OI340700-v8.mmv")
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
open("/tmp/claude-1000/OI340700-v8boot.mmv", "wb").write(bytes(out))
print("DEU blocks forced: %d, volume %d blocks" % (n, len(dirs)))
PYEOF

python3 ~/git/virtualagc/yaShuttle/yaGPC2/tools/stamp_ssl_checksum.py \
        /tmp/claude-1000/OI340700-v8boot.mmv
```

The splice must be unconditional.  An "only if absent" version silently
copies 0 blocks when the target volume already has something there.

Expect `DEU blocks forced: 24, volume 2210 blocks`.

---

## 8.  Check the volume before booting it

```bash
python3 ~/git/virtualagc/yaShuttle/yaGPC2/tools/check_volume_destinations.py \
        /tmp/claude-1000/OI340700-v8boot.mmv
```

On the v8 volume this reports two blocks with `len C6C6` — the staging fill
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
raw = open("/tmp/claude-1000/OI340700-v8boot.mmv", "rb").read()
print("GPT %d non-zero; on tape: %s"
      % (sum(1 for v in gpt if v), "yes" if sig in raw else "NO"))
PYEOF
```

Expect `GPT 870 non-zero; on tape: yes`, first descriptor `0040 000C 1BC0
0027`.

---

## 9.  Boot it

Kill any leftover `discretePanel` **before** the run, not only after — one
left from a previous run makes the GPC flap `HALT`↔`RUN`.

```bash
cd ~/workspace/pass-run
TAPE=/tmp/claude-1000/OI340700-v8boot.mmv DEUMF=1 \
DEUKEYS="@150:ITEM,1,EXEC;@430:OPS,9,0,1,PRO" RUN_AT=260 PORT_BASE=6900 \
./headless-gpcmem.sh 620 ~/workspace/pass-run/headless-v8
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

Polls accumulate at roughly **4.1 s of wall clock each** on this machine, so:

| run length | polls reached | gets you |
|---|---|---|
| 620 s | ~151 | the IPL set only — `ITEM 1 EXEC` fires at the very last poll |
| ~1800 s | ~430 | `OPS 9 PRO` fires |
| 2700 s | ~650 | `OPS 9 PRO` with margin |

A 620-second run looks like a failed transition and is not one: the second
batch simply never fires.  Read the poll count out of the DEU's closing stats
line (`"polls":151`) before concluding anything about a transition.

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
read 229 block(s) from 3/4/0/0     phase 2    (orig 228)
read   7 block(s) from 3/3/0/0     phase 13   (orig 7)
read  39 block(s) from 3/3/6/0     phase 3    (orig 38)
```

Both DEUs should report `"ipled":true` with a few hundred commands.  Strings
like `GPC MEMORY` and `GNC SYS SUMM 1` appearing in the DEU image dump are
**loaded formats from `DEUCFLM`**, not evidence of a live display — do not
read them as one.

---

## What this tape has that its predecessors did not

| | earlier tapes | v8 |
|---|---|---|
| phase 2 | 617 blocks (oversize) or 211 with an `FPMRESET` hole | 241 blocks, `FPMRESET` present |
| overlay content in phase 2 | 307 blocks | 0 |
| in-core phase table | zeros | 870 of 1093 halfwords |
| `FCMSSLPT` | zeros on some | 633 non-zero |
| oversize phases | phase 2 | none |

Phase 2's 241 blocks against the original's 228, measured by classifying every
section against the eight DASS csect tables: 237 blocks in the SSW dump, 0 in
any other configuration's, 4 in none (the phase 10 IPL loader, correctly
absent from a post-IPL dump).
