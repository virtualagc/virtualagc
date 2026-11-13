#!/bin/sh
# Assemble the ODYSSEY AGC test ROMs with yaYUL into $BUILD/roms/<name>.bin.
# Usage: YAYUL=/path/to/yaYUL BUILD=build tools/build_roms.sh
# Sources are copied into the build tree first so yaYUL's side files
# (.lst, .symtab, ...) never land in the repository.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
build=${BUILD:-build}
yayul=${YAYUL:-$(command -v yaYUL 2>/dev/null || true)}

if [ -z "$yayul" ] || [ ! -x "$yayul" ]; then
  echo "build_roms.sh: yaYUL not found. Set YAYUL=/path/to/yaYUL (build it with" >&2
  echo "  cmake -S <repo root> -B <dir> && cmake --build <dir> --target yaYUL)." >&2
  exit 1
fi

out="$here/$build/roms"
mkdir -p "$out"

# assemble NAME SRCDIR... MAINFILE
#   Copies every *.agc from the given source directories into a scratch dir,
#   assembles MAINFILE, and installs $out/NAME.bin.
assemble() {
  name=$1; main=$2; shift 2
  work="$out/_work_$name"
  rm -rf "$work"
  mkdir -p "$work"
  for d in "$@"; do cp "$d"/*.agc "$work"/; done
  log="$out/$name.yayul.log"
  # --force makes yaYUL write a .bin even after errors, so a .bin existing
  # proves nothing.  Judge success by the assembler's own fatal-error count.
  ( cd "$work" && "$yayul" --force "$main" > "$log" 2>&1 ) || true
  fatal=$(sed -n 's/^Fatal errors: *\([0-9][0-9]*\) *$/\1/p' "$log" | tail -1)
  final=$(sed -n 's/^Fatal errors (final): *\([0-9][0-9]*\) *$/\1/p' "$log" | tail -1)
  bad=0
  [ -s "$work/$main.bin" ] || bad=1
  [ -n "$fatal" ] || bad=1                       # no summary line: don't trust it
  [ "${fatal:-1}" = 0 ] || bad=1
  [ -z "$final" ] || [ "$final" = 0 ] || bad=1
  if [ "$bad" != 0 ]; then
    echo "build_roms.sh: assembling $name failed; see $log" >&2
    grep -n 'Fatal Error' "$log" >&2 || true
    exit 1
  fi
  cp "$work/$main.bin" "$out/$name.bin"
  rm -rf "$work"
  echo "assembled $name -> $build/roms/$name.bin"
}

for name in SEQTEST SILENT PHASE-500 PHASE-1K PHASE-2K; do
  assemble "$name" "$name.agc" "$here/flight/tests" "$here/flight/common"
done

# A real flight program from this repository, used by the isolation tests as a
# second, independent workload.  The repo root is two levels above yaAGC/odyssey.
comanche="$here/../../Comanche055"
if [ -d "$comanche" ]; then
  assemble Comanche055 MAIN.agc "$comanche"
else
  echo "build_roms.sh: $comanche not found; skipping Comanche055" >&2
fi
