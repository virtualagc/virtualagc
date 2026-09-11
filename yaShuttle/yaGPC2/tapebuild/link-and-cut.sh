#!/bin/bash
# Link, resolve, stamp, cut and splice.  Began as the procedure that built
# OI340700-v36boot.mmv on 2026-09-09 (/tmp/claude-1000/buildtape.sh, 14:34), with its hard-coded
# paths made parameters.  Called by build.sh, which sets:
#   T      the source tree with objects/, SYSLIBL1/, lib/runtime/, CON80/
#   S      the toolchain's src/ directory (modules run from its parent)
#   WORK   scratch: sdfpad/, pchsrc/, extsyms/, and the outputs
#   IN     tapebuild/inputs    TOOLS  yaGPC2/tools
# Output: $WORK/OI340700-v42boot.mmv.  (Until 2026-09-11 this produced v36boot,
# which tools/patch_unresolved.py then hand-filled into v41boot; stages 4b
# and 4c replace that fill, and the link fixes in toolchain-patches/ the rest.)
set -u
set -o pipefail
: "${T:?}" "${S:?}" "${WORK:?}" "${IN:?}" "${TOOLS:?}"
C="$WORK/c80"; P="$WORK/pchsrc"; SD="$WORK/sdfpad"; ML="$WORK/minilibs"
RT="--linklib $T/lib/runtime/RUN --linklib $T/lib/runtime/ZCON"
OUT="$WORK/OI340700-v42.mmv"; BOOT="$WORK/OI340700-v42boot.mmv"
export C80SRC_RESOLVED="$S"
rm -rf "$C"; mkdir -p "$C"
cd "$(dirname "$S")" || exit 1

echo "  per-phase minimal INSERT libraries"
PYTHONPATH=$S python3 - "$T" "$ML" <<'PYEOF'
import os, sys
sys.path.insert(0, os.environ["C80SRC_RESOLVED"])
from con80.con80build import concard
T, base = sys.argv[1], sys.argv[2]
deck = concard.ConcardDeck(T + "/CON80")
os.makedirs(base, exist_ok=True)
# The resident HAL/S library belongs to phase 2 and is SHARED: `MAP
# 2,LIBZERO,LIBRESD,LIBRESC` reserves it, so no other phase may take a copy
# (a second copy is pinned at the flight addresses and fragments the phase --
# phase 12 went 216 -> 334 blocks).
RESLIB = set()
for r in ("LIBZERO", "LIBRESD", "LIBRESC"):
    for op in concard.layout_program(deck, r):
        if op.verb == "INSERT" and op.operand:
            RESLIB.add(op.operand)
for p in (1,2,3,4,5,6,7,8,9,10,12,13,14,15,18):
    root = "PHASE%02d" % p
    ins = {op.operand for op in concard.layout_program(deck, root)
           if op.verb == "INSERT" and op.operand}
    if p != 2:
        ins -= RESLIB
    d = os.path.join(base, root); os.makedirs(d, exist_ok=True)
    for f in os.listdir(d): os.unlink(os.path.join(d, f))
    for name in sorted(ins):
        src = os.path.join(T, "SYSLIBL1", name + ".obj")
        if os.path.exists(src):
            os.symlink(src, os.path.join(d, name + ".obj"))
PYEOF

echo "  stage and link, ascending phase order"
for p in 1 2 3 4 5 6 7 8 9 10 12 13 14 15 18 23 24 25; do
  n=$(printf "PHASE%02d" $p)
  mkdir -p $C/$n/obj $C/$n/gen
  ln -s $T/objects/*.obj $C/$n/obj/ 2>/dev/null
  for s in $T/objects/PCH*SRC.obj; do
    b=$(basename $s SRC.obj); ln -sf $s $C/$n/obj/${b}TXT.obj
  done
  cp -r $SD $C/$n/gen/SDFLIB
  extra=""
  case $p in
    1|10)     lib="" ;;                               # no library at all
    23|24|25) lib="--linklib $T/SYSLIBL1 $RT" ;;      # no deck root by name
    *)        lib="--linklib $ML/$n $RT" ;;           # this phase's INSERTs
  esac
  # Each phase gets the csect table of its own configuration (phase 2:
  # SSW's); 13 its own pins; 1 and 10 NONE (pinning PHASE10 strips 97% of
  # GPCIPL).
  [ $p -eq 13 ] && extra="--external-syms $IN/extsyms-13.json"
  case $p in
    2|3|4|5|6|7|8|9|12|14|15|18)
      extra="--external-syms $WORK/extsyms/extsyms-ph$(printf %02d $p).json" ;;
  esac
  out=$(PYTHONPATH=$S timeout 1800 python3 -m con80.con80build --phase $p --root $T \
        --src $P --src $T/SSSRC --src $T/APPLSRC --out $C --link $lib $extra \
        --generate-stacks 256 2>&1)
  line=$(echo "$out" | grep -E 'linked|FAILED' | head -1)
  echo "    $n: $(echo "$line" | cut -c1-40)"
  # A phase that does not say "linked" has failed, whether or not it says so:
  # a missing default library is reported as NOTHING.  Every later phase
  # MAPs the earlier ones, so going on only multiplies the damage.
  case "$line" in linked*) ;; *) echo "$out" | tail -5 >&2; exit 1 ;; esac
done

echo "  4b. cross-phase resolution"
# The flight linked each memory configuration as ONE job, so a reference from
# one phase to a csect another phase of the same configuration places got a
# real address.  Our links are per phase and leave such sites as assembled,
# with their RLDs kept in the .lib; lnk101.phaseresolve replays them against
# the phases that share a configuration with the site (con80's mcconfigs),
# honouring the decks' LIBRARY *(...) no-call cards.  Without it v36 carried
# 793 unresolved sites, the ones that mattered hand-filled on the volume by
# tools/patch_unresolved.py.  Any residue other than the two pool words of
# stage 4c is fatal.
PYTHONPATH=$S python3 -m lnk101.phaseresolve --con80 $T/CON80 $C/PHASE*.lib \
  > $WORK/xres.log 2>&1 || { tail -5 $WORK/xres.log >&2; exit 1; }
grep -E '^PHASE' $WORK/xres.log \
  | awk '{r += $2} / still unresolved/ {split($0, a, ", "); for (i in a) if (a[i] ~ /still unresolved/) {split(a[i], b, "/"); u += b[2] + 0}} END {printf "    %d site(s) resolved, %d left unresolved (must be 2)\n", r, u; exit (u != 2)}' \
  || { grep -B2 -A6 'still unresolved' $WORK/xres.log | grep -v ' 0 symbol' >&2; exit 1; }

echo "  4c. root pool words whose target no phase links"
PYTHONPATH=$S python3 - "$C" "$IN/zcon-pool-unlinked.json" <<'PYEOF'
import json, sys, os; sys.path.insert(0, os.environ["C80SRC_RESOLVED"])
from pathlib import Path
from ap101Utils import mmbstamp as mb
C = Path(sys.argv[1]); words = json.load(open(sys.argv[2]))["words"]
p = C / "PHASE02.lib"
at = {s["name"]: s for s in mb._lib_sym(p).get("sections", [])}
lib = mb.LibModule.read(p)
have = {}
for x in lib.extents:
    for i in range(x.hwLength):
        have[x.address // 2 + i] = (x.data[2*i] << 8) | x.data[2*i+1]
for name, w in sorted(words.items()):
    a = at[name]["address"]
    if a != w["address"] or [have.get(a), have.get(a + 1)] != [0x8000, 0x0E00]:
        sys.exit("    %s: not the unresolved stub at %05X -- refused" % (name, w["address"]))
    mb._splice(lib, a, list(w["value"]), name)
    print("    %s @%05X = %04X %04X" % (name, a, *w["value"]))
lib.write(p)
PYEOF
[ $? -eq 0 ] || exit 1

echo "  5a. FCMSSLPT into PHASE10.lib"
PYTHONPATH=$S python3 - "$C" "$T" <<'PYEOF'
import sys, os; sys.path.insert(0, os.environ["C80SRC_RESOLVED"])
from pathlib import Path
from ap101Utils import mmbstamp as mb
C = Path(sys.argv[1]); T = Path(sys.argv[2])
sslpt, _ = mb.generate_sslpt(C, T / "CON80")
p = C / "PHASE10.lib"
at = {s["name"]: s for s in mb._lib_sym(p).get("sections", [])}
lib = mb.LibModule.read(p)
mb._splice(lib, at[mb.SSLPT_CSECT]["address"], list(sslpt), mb.SSLPT_CSECT)
lib.write(p)
print("    FCMSSLPT stamped, %d non-zero" % sum(1 for w in sslpt if w))
PYEOF
[ $? -eq 0 ] || exit 1

echo "  5b. #PFCMGPT / #PCDCPHA / FCMG3DAT into PHASE02.lib"
PYTHONPATH=$S python3 -m tools.mmustamp --mmu $C --con80 $T/CON80 --skip-phase 16 \
  2>&1 | grep -E 'PFCMGPT|PCDCPHA|FCMG3DAT' | sed 's/^/  /'
[ ${PIPESTATUS[0]} -eq 0 ] || exit 1

echo "  6. cut the tape"
PYTHONPATH=$S timeout 900 python3 -m tools.mmu2mmv --con80 $T/CON80 --mmu $C \
   --area 1 --out $OUT > $WORK/cut.log 2>&1
ov=$(grep -ci oversize $WORK/cut.log)
echo "    OVERSIZE rows (must be 0): $ov"
[ "$ov" -eq 0 ] && [ -s "$OUT" ] || { tail -5 $WORK/cut.log >&2; exit 1; }

echo "  7. splice the DEU load modules, close the SSL checksum"
# mmu2mmv cannot generate DEUDCPLM/DEUCFLM/DEUSTLM.  The 24 blocks are the
# ones v36 took from pass-910.mmv (md5 f9d116d2...), extracted into
# inputs/deu-loadmodules.mmv so the build does not depend on that volume.
python3 - "$OUT" "$BOOT" "$IN/deu-loadmodules.mmv" <<'PYEOF'
import struct, sys
def load(p):
    raw = open(p, "rb").read()
    hw, ent, flag = struct.unpack(">III", raw[8:20])
    dirs = list(struct.unpack(">%dI" % ent, raw[32:32 + 4 * ent]))
    off = 32 + 4 * ent
    return raw[:8], hw, flag, {d: raw[off+i*hw*2: off+(i+1)*hw*2] for i, d in enumerate(dirs)}
magic, hw, flag, ours = load(sys.argv[1])
_, _, _, ref = load(sys.argv[3])
for d, blk in ref.items(): ours[d] = blk
dirs = sorted(ours)
out = bytearray(magic) + struct.pack(">III", hw, len(dirs), flag)
out += b"\0" * (32 - len(out))
for d in dirs: out += struct.pack(">I", d)
for d in dirs: out += ours[d]
open(sys.argv[2], "wb").write(bytes(out))
print("    DEU blocks forced: %d (must be 24), volume %d blocks" % (len(ref), len(dirs)))
PYEOF
python3 $TOOLS/stamp_ssl_checksum.py $BOOT | sed 's/^/    /'
[ ${PIPESTATUS[0]} -eq 0 ] || exit 1
