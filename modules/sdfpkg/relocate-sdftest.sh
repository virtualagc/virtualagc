#!/bin/bash
# Move the -sdftest corpus work directories out of ~/workspace/PFS (an IDE
# project, which the ~2.3 million archived files had rendered unusable) and
# into ~/ForClaude, then pack the stale run archives into tarballs.
#
#     relocate-sdftest.sh
#
# Waits for any corpus run in flight to finish first: a run writes corpus.done
# on completion, and corpus-run.sh removes it at the start.  Nothing functional
# hardcodes the old location -- corpus-run.sh takes its work directory as an
# argument -- so the move needs no other change.
#
# The archives are the whole problem: each archive.results.* directory holds
# ~1000 module subdirectories of ~58 intermediate files apiece, and 20 of them
# had accumulated per corpus.  The two most recent of each are left unpacked
# because they are the ones we actually read; the rest become .tar.zst.
# Originals are removed only after the tarball's file count is verified to
# match, so a failed pack costs disk, never data.

set -u
SRC=~/workspace/PFS
DST=~/ForClaude
KEEP=2                                  # newest N archive.results.* left loose

echo "=== waiting for corpus runs to finish"
for d in "$SRC"/OI340600-sdftest "$SRC"/OI301700-sdftest; do
    [ -d "$d" ] || continue
    while pgrep -f "corpus-run.sh $d" > /dev/null; do sleep 60; done
    echo "    $(basename "$d") idle; corpus.done = $(cat "$d/corpus.done" 2>/dev/null || echo absent)"
done

# Belt and braces: never move a tree a compiler is still writing into.
while pgrep -f "PASS.REL32V0/(HALSFC|compilePASS)" > /dev/null; do
    echo "    compiler still active, waiting"; sleep 60
done

mkdir -p "$DST"
echo "=== moving"
for d in "$SRC"/*-sdftest; do
    [ -d "$d" ] || continue
    mv "$d" "$DST"/ && echo "    $(basename "$d") -> $DST/"
done

echo "=== packing stale run archives"
for d in "$DST"/*-sdftest; do
    [ -d "$d" ] || continue
    cd "$d" || continue
    # Newest first by mtime; skip the KEEP most recent, pack the remainder.
    ls -dt archive.results.* 2>/dev/null | tail -n +$((KEEP + 1)) | while read -r a; do
        n=$(find "$a" | wc -l)
        if tar -I 'zstd -3 -T4' -cf "$a.tar.zst" "$a" 2>/dev/null; then
            m=$(tar -tf "$a.tar.zst" 2>/dev/null | wc -l)
            if [ "$n" -eq "$m" ]; then
                rm -rf "$a"
                echo "    $(basename "$d")/$a  packed ($n files, $(du -h "$a.tar.zst" | cut -f1))"
            else
                echo "    $(basename "$d")/$a  COUNT MISMATCH $n vs $m -- original kept"
            fi
        else
            echo "    $(basename "$d")/$a  tar FAILED -- original kept"
            rm -f "$a.tar.zst"
        fi
    done
done

echo "=== done; ~/workspace/PFS now holds:"
ls "$SRC"
