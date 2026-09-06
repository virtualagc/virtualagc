#!/bin/bash
# Link a PASS configuration and compare it against its DASS memory image.
#
#     dass-link.sh <build-tree> <config>          e.g. dass-link.sh ~/pass-build/OI340700 S2
#
# WHAT HAS TO BE TRUE BEFORE THIS WILL MATCH ANYTHING.  Each of these was found
# the hard way and each is worth a large fraction of the result:
#
#   1. THE HAL/S MUST BE COMPILED WITH SDL.  A flight build does not use it, so
#      compilePASS defaults to NOSDL and that is right for its normal purpose --
#      but the DASS dumps are of a Software Development Lab build, and NOSDL
#      emits a START CSECT and an "LHI R0,<stack>" prologue for every PROGRAM
#      that the dumped images do not have.  Build with `compilePASS --sdl`.
#      Check monitor13.parms in any results directory: it records the PARM field
#      actually used, and is the only place the difference is visible.
#
#   2. THE ASSEMBLY MUST USE --fill=C9FB.  Measured over 2345 alignment gaps in
#      all eight dumps: HAL-origin CSECTs are C6C6 without exception, assembly
#      ones are C9FB.  C6C6 is the COMPILER's fill -- HALSFC has no --fill option
#      and emits it inherently -- so passing C6C6 to the assembler conflates the
#      two.  (A theoretical 0x20000 address cutoff does not hold in practice:
#      origin predicts the fill 98.6% of the time, an address split 85.8%.)
#
#   3. --external-syms AND --concard, TOGETHER.  --external-syms places every
#      section at the address the real image has -- 1243 of 1243 here -- which
#      no deck layout reproduces (con80build's own layout scores 0 of 327).
#      --concard is still needed for the deck's CHANGE cards, which redirect a
#      module's ZCON to another's; without it SSP_EXEC differs in exactly the
#      seven halfwords SM2MSPS redirects.
#
#   4. LINK EVERY OBJECT, NOT JUST THE CONFIGURATION'S OWN.  Scoping the list
#      to modules with a CSECT in augmented-<config>.json makes fcmcmp's report
#      far tidier -- 40 SKIPs instead of 1545, 284 failures instead of 1739 --
#      but it is WORSE, because the modules it drops still define symbols this
#      configuration references: undefined symbols go from 91 to 337 and every
#      relocation to one of them comes out wrong.  Measured on the same
#      denominator, scoping costs 10 sections (863 -> 853), and by fcmcmp's own
#      count 993 OK -> 976.  The extra SKIPs and failures are sections that are
#      not in the image at all; they are noise in the report, not error.
#
#   5. STACK CARDS ARE REMOVED from this release's decks.  Under SDL a CON80
#      STACK card is the only trigger for generating an @-stack CSECT, and a
#      generated stack is placed by deck layout, which is not where the real
#      one is -- all 28 misplacements were stacks and nothing else.  With the
#      cards gone the PDE's stack-address halfword is resolved from
#      external-syms instead and 20 PDE sections come right.  The cost is that
#      the @-stacks are absent from our image; they are pure fill in the dumps,
#      so nothing is lost but coverage of those ranges.
set -e
TREE=${1:?build tree}; CFG=${2:?config, e.g. S2}
# The data lives in PFS, the code in virtualagc; the instructions have the
# reader cd to the PFS directory first.  $PFS overrides.
if [ -z "${PFS:-}" ]; then
    if [ -d mafgen ]; then PFS=$(pwd); else PFS=$HOME/workspace/PFS; fi
fi
BIN=${LNK101_BIN:-$HOME/donschmidt/nsts-sdl-dps/build/bin}
AUG=$PFS/mafgen/augmented-$CFG.json
IMG=$PFS/mafgen/$CFG.fcm
# The tracked copy in mafgen/ is canonical; the sweep's working copy in
# ~/ForClaude is the fallback.  $EXCEPTIONS overrides both.
EXC=${EXCEPTIONS:-$PFS/mafgen/exceptions-$CFG.txt}
[ -f "$EXC" ] || EXC=$HOME/ForClaude/OI340600-clc/exceptions-$CFG.txt
ROOT=${CONCARD_ROOT:-SM2}

cd "$TREE"
mkdir -p link
# Every object except two exclusions.
#
#   _stub*.obj  are the cycle-breaking seeds; they duplicate every symbol of
#               the real unit and the link fails on duplicate definitions.
#
#   the OVERRUNNING modules.  A handful of compools are much larger in our
#   build than the index says this configuration holds -- CVYADTDA is 175
#   halfwords against a 2-halfword index entry -- because the configuration
#   carries only a stub of them.  Linked at their index address they run past
#   it and overwrite whatever follows, so the neighbour fails through no fault
#   of its own.  Dropping the 21 that both exceed their entry AND overlap
#   something is worth 11 sections (993 -> 1004) and takes the size mismatches
#   from 36 to 13.  Do NOT put SYSLIBL1 on -L when doing this: autocall pulls
#   them straight back in and the gain is lost (896).
ls "$PWD"/objects/*.obj | grep -v '_stub' > link/objlist-$CFG-all.txt
"$BIN/lnk101" "@link/objlist-$CFG-all.txt" -L lib/runtime/RUN -L lib/runtime/ZCON \
    --external-syms "$AUG" --concard CON80 --concard-root "$ROOT" --allow-undefined \
    -o link/probe-$CFG.fcm --json-symbols link/probe-$CFG-symbols.json >/dev/null 2>&1 || true
python3 - "$AUG" link/probe-$CFG-symbols.json link/objlist-$CFG-all.txt > link/objlist-$CFG-overrun.txt <<'PY'
import json, io, sys, os
aug = json.load(io.open(sys.argv[1]))
secs = sorted((e["address"], e["address"]+e["size"]-1, e["name"], e["module"], e["size"])
              for e in json.load(io.open(sys.argv[2]))["sections"] if e["size"] > 0)
bad = set()
for i in range(len(secs)-1):
    a0, b0 = secs[i][0], secs[i][1]
    for j in range(i+1, len(secs)):
        if secs[j][0] > b0: break
        for nm, md, sz in ((secs[i][2], secs[i][3], secs[i][4]),
                           (secs[j][2], secs[j][3], secs[j][4])):
            g = aug.get(nm)
            if g and sz > g["end"] - g["start"] + 1:
                bad.add(md)
for l in io.open(sys.argv[3]).read().split():
    if os.path.splitext(os.path.basename(l))[0] not in bad:
        print(l)
PY

# A CHANGE card aliases one CSECT to another, and the ALIASED-FROM module is
# then not linked: its references go to the target instead.  SM2MSPS's seven
# #ZP*(#ZSMNCLN) cards are the clearest case -- neither $0PTVOSV nor #ZPTVOSV
# appears anywhere in the S2 image.  Linking those modules anyway puts a second
# definition at a shared slot and one overwrites the other.  Excluding the 19
# is worth a further 2 sections and, more to the point, is what the deck says.
# (Excluding the other side instead -- the modules defining the TARGET name --
# measures WORSE, 998, and would drop SMNCLN itself, which the image plainly
# contains.)
python3 - link/csect-to-object.json CON80 link/objlist-$CFG-overrun.txt "$ROOT" > link/objlist-$CFG-trim.txt <<'PY'
import io, os, re, sys, json
c2o = json.load(io.open(sys.argv[1])); C = sys.argv[2]
seen, stack, changes = set(), [sys.argv[4]], []
while stack:
    d = stack.pop()
    if d in seen or not os.path.exists(os.path.join(C, d)): continue
    seen.add(d)
    for l in io.open(os.path.join(C, d), errors="replace"):
        b = l[:72]
        m = re.match(r'\s+INCLUDE\s+CONCARDS?\((\w+)\)', b) or re.match(r'\s+INCLUDE\s+([A-Z0-9]+)\s*$', b)
        if m: stack.append(m.group(1))
        m = re.search(r'CHANGE\s+(\S+?)\((\S+?)\)', b)
        if m and b[:1] != "*": changes.append((m.group(1), m.group(2)))
excl = {os.path.splitext(c2o[a])[0] for a, b in changes
        if a in c2o and c2o.get(a) != c2o.get(b)}
for l in io.open(sys.argv[3]).read().split():
    if os.path.splitext(os.path.basename(l))[0] not in excl:
        print(l)
PY

# A configuration's OVERLAY regions are shared: augmented-<config>.json lists
# every CSECT that could occupy a range, not the one this image holds.  Linking
# them all lets the alternatives overwrite each other and the survivor is
# whichever came last -- #CSSXISS was being buried under DCDDG1/2/3/8, the GNC
# display modules, and differed in 450 of its 526 halfwords as a result.
#
# Exclude a module only when BOTH signals agree: its CSECT sits in an index
# range that overlaps another CSECT's, AND some other configuration's deck
# names it while this one's chain does not.  That is 26 modules for SM2 and
# worth 19 sections (837 -> 856).  Neither signal alone will do: excluding
# everything another deck names drops 691 modules this configuration really
# uses and collapses the score to 507.
python3 - "$AUG" "$PWD/CON80" "$ROOT" link/csect-to-object.json link/objlist-$CFG-trim.txt \
        > link/objlist-$CFG.txt <<'PY'
import io, os, re, json, sys
aug=json.load(io.open(sys.argv[1])); C=sys.argv[2]; root=sys.argv[3]
c2o=json.load(io.open(sys.argv[4]))
def chain(top):
    seen, st, names = set(), [top], set()
    while st:
        x = st.pop()
        if x in seen or not os.path.exists(os.path.join(C, x)): continue
        seen.add(x)
        for l in io.open(os.path.join(C, x), errors="replace"):
            b = l[:72]
            if b[:1] == "*": continue
            m = (re.match(r'\s+INCLUDE\s+CONCARDS?\((\w+)\)', b)
                 or re.match(r'\s+INCLUDE\s+([A-Z0-9]+)\s*$', b))
            if m: st.append(m.group(1)); continue
            p = b.split()
            if len(p) >= 2 and p[0] in ("INSERT", "RESERVE"): names.add(p[1])
            m = re.search(r'INCLUDE\s+\w+\(([^)]*)\)', b)
            if m: names.update(y.strip() for y in m.group(1).split(","))
    return names
mine = chain(root)
others = set()
# Alternative CONFIGURATIONS only.  MFB14 and OPS0 are NOT alternatives --
# they are decks of this same image (PHASE14 includes MFB14, and PHASE15 maps
# it), so treating them as "another configuration" drops CSAPDT, CSAPCT and
# CSDRTCCM, which S2 plainly contains, and costs 5 sections.
for r0 in ("GNC1","GNC2","GNC3","GNC8","GNC9","SM2","SM4","PL9","SSW",
           "TEXTGPH","MFB3","MFB9"):
    if r0 != root: others |= chain(r0)
rng = sorted((g["start"], g["end"], n) for n, g in aug.items())
overlap = set()
for i in range(len(rng) - 1):
    for j in range(i + 1, len(rng)):
        if rng[j][0] > rng[i][1]: break
        overlap.add(rng[i][2]); overlap.add(rng[j][2])
drop = {os.path.splitext(c2o[n])[0] for n in overlap
        if n in others and n not in mine and n in c2o}
drop -= {os.path.splitext(c2o[n])[0] for n in mine if n in c2o}
for l in io.open(sys.argv[5]).read().split():
    if os.path.splitext(os.path.basename(l))[0] not in drop:
        print(l)
PY
echo "linking $(wc -l < link/objlist-$CFG.txt) objects"
"$BIN/lnk101" "@link/objlist-$CFG.txt" \
    -L lib/runtime/RUN -L lib/runtime/ZCON \
    --external-syms "$AUG" --concard CON80 --concard-root "$ROOT" \
    --allow-undefined \
    -o "link/$CFG.fcm" --lib "link/$CFG.lib" --json-symbols "link/$CFG-symbols.json"
"$BIN/fcmcmp" ${EXC:+--exceptions "$EXC"} \
    "link/$CFG-symbols.json" "link/$CFG.fcm" "$IMG" > "link/$CFG.fcmcmp.log" || true
echo "  OK   $(grep -c '^  OK:'   "link/$CFG.fcmcmp.log")"
echo "  FAIL $(grep -c '^  FAIL:' "link/$CFG.fcmcmp.log")"
echo "  SKIP $(grep -c '^  SKIP:' "link/$CFG.fcmcmp.log")"
