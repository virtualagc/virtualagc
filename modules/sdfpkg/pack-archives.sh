#!/bin/bash
# Pack stale corpus run archives into tarballs.
#
#     pack-archives.sh [KEEP] [DIR ...]      default: KEEP=2, both -sdftest dirs
#
# Each corpus run leaves an archive.results/ of ~1000 module subdirectories
# holding ~58 intermediate files apiece, and corpus-run.sh renames the previous
# one rather than deleting it.  Twenty generations per corpus had accumulated --
# roughly 2.3 million files -- which is why the work directories had to leave
# ~/workspace/PFS, an IDE project (see HANDOFF.md section 9).
#
# The KEEP most recent generations per corpus are left unpacked, since those are
# the ones we actually read.  An original is removed only after its tarball's
# file count is verified to match, so a failed pack costs disk, never data.
#
# Do NOT run this while a corpus run is in flight: it competes for the disk, and
# the newest archive.results is being written.

set -u
KEEP="${1:-2}"; shift 2>/dev/null || true
DIRS=("$@")
[ ${#DIRS[@]} -eq 0 ] && DIRS=(~/ForClaude/OI340600-sdftest ~/ForClaude/OI301700-sdftest)

for d in "${DIRS[@]}"; do
    [ -d "$d" ] || { echo "skip: no $d"; continue; }
    cd "$d" || continue
    # Newest first by mtime; skip the KEEP most recent, pack the remainder.
    ls -dt archive.results.* 2>/dev/null | tail -n +$((KEEP + 1)) | while read -r a; do
        [ -d "$a" ] || continue
        n=$(find "$a" | wc -l)
        if tar -I 'zstd -3 -T4' -cf "$a.tar.zst" "$a" 2>/dev/null; then
            m=$(tar -tf "$a.tar.zst" 2>/dev/null | wc -l)
            if [ "$n" -eq "$m" ]; then
                rm -rf "$a"
                echo "  $(basename "$d")/$a  packed: $n files -> $(du -h "$a.tar.zst" | cut -f1)"
            else
                echo "  $(basename "$d")/$a  COUNT MISMATCH $n vs $m -- original kept"
            fi
        else
            echo "  $(basename "$d")/$a  tar FAILED -- original kept"
            rm -f "$a.tar.zst"
        fi
    done
done
echo "=== packing complete"
