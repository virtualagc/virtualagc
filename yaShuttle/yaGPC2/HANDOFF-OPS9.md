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

## 7b.  Fill the root's unresolved cross-phase Z-CONs

**This step is a WORKAROUND for a build defect.**  Skip it and the tape boots,
IPLs, and completes an `OPS 901/201/301 PRO` transition -- and then the machine
stops with `invalid instruction 0xc6c6 at 0x48da`.

```bash
python3 ~/git/virtualagc/yaShuttle/yaGPC2/tools/patch_root_zcons.py \
        /tmp/claude-1000/OI340700-vNNboot.mmv
```

Expect `18 Z-CONs filled` and a recomputed load-block checksum.  The tool finds
its own load block by anchoring on the three filled Z-CONs that precede the
hole, so it need not be told a slot or a destination address, and it refuses to
write if a target cell is not fill.

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

## The OPS 901/201/301 blocker -- RESOLVED 2026-09-10

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

* **The root link's unresolved relocations.**  Section 7b patches eighteen
  Z-CONs onto the finished volume; the build should not need patching.  678
  relocations over 304 distinct symbols are unresolved in `PHASE02`, and the
  eighteen are only the currently-fatal subset — `#PCDHMMU` alone has 179
  unresolved references.  `phase3/PHASE02.lib` (09-05) already gets the Z-CONs
  right, so this is a bisect between 09-05 and 09-08, not new work.
  `gpc-causes.py list --status=open` is the live list.
* **Four Z-CONs hold wrong values rather than fill** — `0x1E8`, `0x202`,
  `0x218`, `0x22C`, each with bit 0 clear where all eight DASS dumps have it
  set, so the target is taken as sector 0.  Deliberately not patched.
* **Build provenance is not kept.**  The tape a run used cannot be traced back
  to the tree that made it: staging is reused in place, so `c80boot/` and
  `c80src/` hold only what the **last** build left there.  Thirty-six numbered
  volumes were cut across 09-08/09-09 and only the `.mmv` of each survives;
  **no tree on disk reproduces v36's root block** — its fingerprint (`c878` at
  `0x1d0` *and* `117c` at `0x1e8`) matches none of 64 staged `.lib` files.
  This is not a `/tmp` cleanup: last boot was 09-07, `tmpfiles.d` keeps `/tmp`
  for 30 days, and `OI340700-v2` through `v30` are all still there.
  Fingerprint a few halfwords before assuming a `phase*/` artifact belongs to a
  given tape.
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
