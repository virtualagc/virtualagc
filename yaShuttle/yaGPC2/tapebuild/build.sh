#!/bin/bash
# Build the OI340700 mass-memory volume from SOURCE, end to end.
#
#     tapebuild/build.sh [WORK]          default WORK=/tmp/claude-1000/tapebuild
#
# Produces $WORK/OI340700-v44boot.mmv, and beside it
# $WORK/OI340700-v44boot-noOPS136.mmv, the same volume without GNC OPS 1, 3
# and 6 (stage 8).  Given the same inputs the full volume is
# byte-identical to ~/workspace/pass-run/OI340700-v44boot.mmv -- the last
# stage checks that when REF is set:
#
#     REF=~/workspace/pass-run/OI340700-v44boot.mmv tapebuild/build.sh
#
# (v43boot, 2026-09-11, is this build with the ASM101Sa before its RLD
# R-pointer fix: BILDNEW5.obj named GPCIPL instead of LINES in ten RLDs, so
# GPCIPL read its error-message table two halfwords low and announced itself
# with message 130's text, ">>> GPC POWER REFAIL -PROGRAM/MACHINE WERE R".
# That object is the only input that differs.)
#
# (v42boot, 2026-09-11 morning, is this build at PFS 19464059 with the SM2
# STACK cards as a source patch and the DEU critical formats copied from
# pass-910; git history of this directory reproduces it.)
#
# (v41boot, 2026-09-10, was this build WITHOUT toolchain-patches/lnk101-*
# and link-and-cut stages 4b/4c, plus 88 halfwords hand-filled on the volume
# by tools/patch_unresolved.py.  git history of this directory reproduces it.)
#
# Every input is either SOURCE (a git repository at a named state) or a file
# committed beside this script.  Nothing is read from ~/pass-build or from a
# scratch directory of an earlier session; that is the point of it.  See
# HANDOFF-OPS9.md, "Building the tape", for why each stage is what it is.
#
# Inputs (override by environment):
#   PFS      ~/workspace/PFS            OI340600 + OI340700 source overlays and
#                                       mafgen/csects-*.json, read at PFSREV
#   PFSREV   24af1848                   (git archive, not the working tree)
#   PASSREL  <this repo>/yaShuttle/Source Code/PASS.REL32V0
#                                       HALSFC, compilePASS, RUNASM/RUNMAC/ZCONASM
#   ASM      <this repo>/ASM101S        ASM101Sa
#   DPS      ~/donschmidt/nsts-sdl-dps  Don's checkout: ext/ submodules and the
#                                       Python venv (typer, rich, lark) only
#   FORK     https://github.com/rburkey2005/nsts-sdl-dps   linker toolchain
#   UPSTREAM https://github.com/ColanderCombo/nsts-sdl-dps dfg, at 7d90b05
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
VA="$(cd "$HERE/../../.." && pwd)"
WORK=${1:-/tmp/claude-1000/tapebuild}
PFS=${PFS:-$HOME/workspace/PFS}
PASSREL=${PASSREL:-$VA/yaShuttle/Source Code/PASS.REL32V0}
ASM=${ASM:-$VA/ASM101S}
DPS=${DPS:-$HOME/donschmidt/nsts-sdl-dps}
FORK=${FORK:-https://github.com/rburkey2005/nsts-sdl-dps}
UPSTREAM=${UPSTREAM:-https://github.com/ColanderCombo/nsts-sdl-dps}
PFSREV=${PFSREV:-24af1848}
TOOLS="$VA/yaShuttle/yaGPC2/tools"
IN="$HERE/inputs"
die() { echo "FAILED: $*" >&2; exit 1; }
mkdir -p "$WORK" || die "cannot create $WORK"

# ---------------------------------------------------------------------------
echo "### 0. toolchain: upstream db9d34b + our three branches + lnk101 patch"
# The three branches merge to tree a68da6e6, what built v36 and v41
# (/tmp/claude-1000/sdl-pr, 95b034a).  toolchain-patches/lnk101-first-
# definition-and-zcon-pool.patch is then committed on top, giving 0dce2b7f:
#   * the LE keeps the FIRST definition of a csect name.  One object reaching
#     the link under two names (DSPSPC.obj and the library's #CDSPSPC.obj)
#     had every relocation in #CDSPSPC, #CDPDSPC, #CDXCCCS and #CDXRDMM
#     applied TWICE -- 62 sites in phase 2, among them the root Z-CONs at
#     001E8/00202/00218/0022C (ledger #58: 117C for 88BE);
#   * a Z1-pool word the csect table names is built as a real pool stub, so
#     the root carries it and stage 4b resolves it, instead of an address-
#     only entry that left 0x1D6..0x243 as C6C6 padding.
# The merge commits get new hashes on every rebuild; the TREE must not.
SDL="$WORK/nsts-sdl-dps"
if [ ! -d "$SDL/.git" ]; then
  git clone -q "$FORK" "$SDL" || die "clone $FORK"
  git -C "$SDL" -c advice.detachedHead=false checkout -q db9d34b || die "db9d34b"
  git -C "$SDL" checkout -q -b tapebuild
  for b in lib-inserts-and-stacks mmustamp-skip-phase mmu2mmv-unstamped-guard; do
    git -C "$SDL" -c user.name=tapebuild -c user.email=tapebuild@localhost \
        merge -q --no-edit "origin/$b" || die "merge $b"
  done
  [ "$(git -C "$SDL" rev-parse HEAD^{tree})" = a68da6e6088adf5442cfd428a17daba698dd4e8f ] \
    || die "merged tree is not a68da6e6 -- the branches have moved"
  git -C "$SDL" apply "$HERE/toolchain-patches/lnk101-first-definition-and-zcon-pool.patch" \
    || die "lnk101 patch"
  git -C "$SDL" add src/lnk101/linker.py
  git -C "$SDL" -c user.name=tapebuild -c user.email=tapebuild@localhost \
      commit -q -m "tapebuild: lnk101 first-definition rule and Z1-pool words" \
    || die "commit lnk101 patch"
fi
tree=$(git -C "$SDL" rev-parse HEAD^{tree})
[ "$tree" = 0dce2b7fb827adf6455718ef53a7ce0c2b6ffedc ] \
  || die "toolchain tree $tree, expected 0dce2b7f -- the branches or the patch have moved"
# ext/ submodules: the same checkout v36 used, by symlink, as sdl-pr had.
for e in halmat sim virtualagc; do
  rm -rf "$SDL/ext/$e"; ln -s "$DPS/ext/$e" "$SDL/ext/$e"
done
S="$SDL/src"
echo "  tree $tree"

echo "### 0b. dfg: upstream 7d90b05 + toolchain-patches/dfg-7d90b05-to-OI340700.patch"
# The display decks are translated by Don's dfg.  The dfg that built v36 was
# his working tree -- upstream 7d90b05 (PR #46, merged) plus a local merge and
# an UNCOMMITTED per-release rate-group allowance for OI340700's CS2120
# (VPD 00D5, as the flight dump has it; 00D3 without it).  The patch is that
# whole difference, verified to reproduce his src/dfg file for file.
DFG="$WORK/dfg"
if [ ! -d "$DFG/.git" ]; then
  git clone -q "$UPSTREAM" "$DFG" || die "clone $UPSTREAM"
  git -C "$DFG" -c advice.detachedHead=false checkout -q 7d90b05 || die "7d90b05"
  git -C "$DFG" apply "$HERE/toolchain-patches/dfg-7d90b05-to-OI340700.patch" \
    || die "dfg patch"
fi
mkdir -p "$WORK/bin"
cat > "$WORK/bin/dfg" <<EOF
#!/bin/bash
PYTHONPATH="$DFG/src" exec "$DPS/build/venv/bin/python" -m dfg "\$@"
EOF
chmod +x "$WORK/bin/dfg"
[ "$(cd /tmp && PYTHONPATH="$DFG/src" "$DPS/build/venv/bin/python" -c 'import dfg; print(dfg.__file__)')" \
  = "$DFG/src/dfg/__init__.py" ] || die "the pinned dfg is not the one imported"

# ---------------------------------------------------------------------------
echo "### 1. source tree: PFS OI340600, overlaid with OI340700, + PASS.REL32V0"
# A zero-byte .hal in the OI340700 overlay is an EXCLUSION MARKER -- the file
# is not part of this release -- and the overlay copies it over OI340600's on
# purpose.  Never fill one in.
T="$WORK/OI340700"; PX="$WORK/pfs"
rm -rf "$T" "$PX"; mkdir -p "$T" "$PX"
git -C "$PFS" archive "$PFSREV" OI340600 OI340700 mafgen | tar -x -C "$PX" \
  || die "git archive $PFSREV"
for d in APPLSRC SSSRC MLIB80 INCL80 CON80; do
  mkdir -p "$T/$d"
  for layer in OI340600 OI340700; do
    [ -d "$PX/$layer/$d" ] && find "$PX/$layer/$d" -maxdepth 1 -type f \
        -exec cp -p {} "$T/$d/" \;
  done
done
for d in RUNASM RUNMAC ZCONASM; do cp -a "$PASSREL/$d" "$T/"; done
# The one source patch not in PFS: the CSPCLB qualification (stage 1 of
# HANDOFF-OPS9.md).  (SM2's lost STACK cards were a patch here until PFS
# 24af1848 took them.)
( cd "$T" && patch -s -p1 < "$HERE/source-patches/OI340700-APPLSRC-CSPCLB-qualification.patch" ) \
  || die "source patch"
echo "  PFS at $PFSREV"

# ---------------------------------------------------------------------------
echo "### 2. objects: compilePASS --sdl --release=OI340700"
# --sdl: the tape links these objects, and the flight images are SDL builds
#   (no START csect, no stack ER); stacks come from the CON80 STACK cards.
# --release=OI340700: CPUSLS and CPTOSV need CARDTYPE ACBC, not the base
#   table's ACBD, or they fail XI3 and eight phase-15 objects cascade away.
export PATH="$WORK/bin:$PASSREL:$ASM:$PATH"
( cd "$T" && prepareTEMPLIB --clear && prepareINCLIB --clear --include=INCL80 \
  && mkdir -p objects SDFLIB \
  && unbuffer compilePASS --no-csects --sdl --release=OI340700 ) \
  > "$WORK/compile.log" 2>&1 || die "compilePASS (see $WORK/compile.log)"
echo "  $(ls "$T/objects" | wc -l) objects"

# ---------------------------------------------------------------------------
echo "### 3. derived layers"
PFS="$PX" python3 "$HERE/derive.py" "$T" "$WORK" "$ASM/ASM101Sa" || die "derive.py"

# ---------------------------------------------------------------------------
echo "### 4-7. link, resolve, stamp, cut, splice"
# con80build will not link at all unless its DEFAULT runtime directories,
# build/lib/runtime/{RUN,ZCON} relative to the toolchain checkout, exist --
# and phases 1 and 10, which are given no library, fall back to them.  They
# take no object from them (v36's phase 1 linked its 7 own objects, phase 10
# its 12), but a bare clone has no build/ and every phase then links nothing,
# reported only as a blank line.  v36's checkout had them as symlinks into
# Don's build; point them at OUR runtime library instead.
mkdir -p "$SDL/build/lib/runtime"
ln -sfn "$T/lib/runtime/RUN"  "$SDL/build/lib/runtime/RUN"
ln -sfn "$T/lib/runtime/ZCON" "$SDL/build/lib/runtime/ZCON"
T="$T" S="$S" WORK="$WORK" IN="$IN" TOOLS="$TOOLS" DFG="$DFG" DPS="$DPS" bash "$HERE/link-and-cut.sh" \
  || die "link-and-cut.sh"

OUT="$WORK/OI340700-v44boot.mmv"
if [ -n "${REF:-}" ]; then
  if cmp -s "$OUT" "$REF"; then echo "### MATCH: byte-identical to $REF"
  else echo "### MISMATCH against $REF"; cmp "$OUT" "$REF" | head -1; exit 1; fi
fi

echo "### 8. abridged volume: no GNC OPS 1, 3 or 6"
# The same volume without memory configurations 1 (GNC OPS 1 and 6) and 3
# (GNC OPS 3): phases 4 and 6 left off, every other block untouched.  Rebuilt
# with the full volume, so a change to one is never missing from the other.
# Requesting a removed OPS from it is not supported -- see the tool.
# REF_ABRIDGED=<volume> checks it the way REF checks the full one.
ABR="$WORK/OI340700-v44boot-noOPS136.mmv"
python3 "$TOOLS/abridge_volume.py" "$OUT" --con80 "$T/CON80" --drop-mc 1,3 -o "$ABR" \
  || die "abridge_volume.py"
if [ -n "${REF_ABRIDGED:-}" ]; then
  if cmp -s "$ABR" "$REF_ABRIDGED"; then echo "### MATCH: byte-identical to $REF_ABRIDGED"
  else echo "### MISMATCH against $REF_ABRIDGED"; cmp "$ABR" "$REF_ABRIDGED" | head -1; exit 1; fi
fi
echo "### done -> $OUT"
echo "###        $ABR"
