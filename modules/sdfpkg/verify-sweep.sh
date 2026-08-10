#!/bin/bash
# Assemble every OI301700 module and COMPARE it against its own contemporary
# listing, one TSV row per module: module, exit status, class, detail.
#
# WHY THIS IS DIFFERENT FROM fcos-sweep.sh.  That script asks whether ASM101S
# COMPLAINS.  A module that exits 0 has only established that the assembler
# had nothing to say about it, which is not the same as the bytes being right;
# several of the defects found in August 2026 were silently wrong object code
# in modules the sweep was counting as OK.  This script asks the only question
# that settles it -- do the bytes match the original build.
#
# IT IS ONLY POSSIBLE FOR OI301700.  The "as received" directory for that
# version holds real assembly listings, object code and all, and every one of
# its 272 sources has one.  OI340600's "as received" directory holds SOURCES,
# not listings, so there is nothing there to compare against.
#
# DO NOT BORROW OI340600'S MACRO LIBRARY to make up OI301700's 13 macro
# definitions against OI340600's 235.  NOT for the reason first given here --
# that of the 40 members existing in both versions none are identical, which
# is a fact about the members OI301700 HAS and says nothing about the ones it
# lacks -- but because THE PREPARED SOURCES ARE ALREADY MACRO-EXPANDED.
#
# Whoever built them kept the generated cards, the ones the listing marks with
# `+` after the statement number, so the .asm holds the expansion as ordinary
# source; DFLDCU's listing has 51 of them, all 51 are in its .asm, and it
# matches byte for byte.  That is why the library barely has any macros.  Where
# an invocation also survived it sits BESIDE its own expansion, so supplying
# the macro would expand it a second time.  PCH10SRC settles it in four lines:
# with OI340600's `IS` it fails outright, and with `IS` undefined and the
# leftover card ignored it is 0 mismatched and 0 missing.
#
# MACROFILES.txt IS THE LIST OF MEMBERS ASM101S READS AS OPEN CODE ahead of
# the module, and the two libraries are not the same kind of thing.  Of
# OI340600's 278 members, 214 are macro DEFINITIONS.  Of OI301700's 40, ONE
# is -- MACSMITH -- and the other 39 are COPY fragments meant to be pulled
# INTO a control section, not assembled ahead of one.
#
# (When counting these, look only at columns 1-71.  The cards carry sequence
# numbers in 73-80, so a `MACRO` statement does not end its line and a regexp
# anchored at end-of-line finds NONE of them.  That mistake was made here
# first and gave exactly the wrong answer, that neither library held any
# macros at all.)
#
# Listing all 40 therefore put a `DS` outside any control section and every
# OI301700 module failed with "Instruction outside of control section
# (undefined macro 'DS'?)", a message whose parenthetical guess sends you
# hunting a macro that does not exist.  DCI#STK goes from that to a clean
# byte-for-byte match once the fragments are left alone.
#
# NOR CAN MACSMITH BE PRE-READ, though it is the one member that does contain
# a MACRO statement.  It is really a symbolic-equates member -- it is where
# R0 through R7, B0 through B3 and F0 through F5 are defined -- with a macro
# block inside it, no OI301700 source invokes it as a macro, and pre-reading
# it gives every module 153 intolerable lines.  (Listing it and nothing else
# was tried, and turned 127 matches into 272 failures.  A uniform result
# across a whole corpus means the harness is broken.)
#
# So the index is EMPTY: nothing in this library is meant to be read ahead of
# the module, and the directory exists only to give COPY somewhere to look.
#
# WHAT THIS CANNOT FIX is that 213 of the 214 macros OI340600 defines are
# absent from OI301700's library, PROC and PROGRAM and the IF/ELSE/CASE/DO
# family among them.  But only SIXTEEN of the 213 are actually invoked, by TEN
# of the 272 modules, so the archive gap is small and the buildable
# denominator is 262.
#
# COUNT THOSE INVOCATIONS ON OPERATION FIELDS ONLY.  A regexp that takes the
# second word of any line counts COMMENT CARDS, and these sources carry long
# comment blocks that spell out the macro syntax -- FPMIDLE has a block
# listing "WAIT UNTIL", "SCHEDULE AT", "REPEAT AFTER" and the rest, none of
# it code.  Counting that way said 139 modules were blocked when the true
# figure is 10, and it made the assembler look nine times better than it is
# by shrinking the denominator it is judged against.  Skip cards beginning
# with `*` or `.*`, and skip the card after any card with a non-blank column
# 72, which is a continuation and has no operation field at all.
#
# PFS is somebody else's repository and is not written to.
set -u
OUT=${1:?usage: verify-sweep.sh OUTFILE}
PFS=~/workspace/PFS
SRC="$PFS/OI301700/SSSRC"
LST="$PFS/OI301700 as received/SSSRC"
export VERIFY_TIMEOUT=${VERIFY_TIMEOUT:-600}

[ -d "$SRC" ] || { echo "missing $SRC" >&2; exit 1; }
[ -d "$LST" ] || { echo "missing $LST" >&2; exit 1; }

# A scratch macro library: symlinks to OI301700's own members, plus the index
# file ASM101S wants and that directory lacks.
MLIB=$(mktemp -d)
trap 'rm -rf "$MLIB"' EXIT
for d in "$PFS"/OI301700/MLIB80 "$PFS"/OI301700/INCL80 "$PFS"/OI301700/INCLIB; do
    [ -d "$d" ] || continue
    for f in "$d"/*; do
        [ -f "$f" ] && ln -sf "$f" "$MLIB/$(basename "$f")"
    done
done
: > "$MLIB/MACROFILES.txt"      # deliberately empty; see the note above
export MLIB LST SRC

: > "$OUT"
ls "$SRC"/*.asm | xargs -n 1 basename | sed 's/\.asm$//' | xargs -P 6 -n 1 bash -c '
    m=$0
    cd "$SRC" || exit 1
    [ -f "$LST/$m" ] || { printf "%s\t-\tNOLISTING\t\n" "$m"; exit 0; }
    so=$(mktemp); se=$(mktemp); obj=$(mktemp --suffix=.obj)
    timeout -k 5 "$VERIFY_TIMEOUT" \
    ASM101S --library="$MLIB" --tolerable=4 --object="$obj" \
            --compare="$LST/$m" "$m.asm" > "$so" 2> "$se"
    status=$?
    # The summary line is the result.  Anything else is a failure to reach it.
    summary=$(grep -h "bytes mismatched" "$so" | tail -1)
    if [ "$status" = 124 ] || [ "$status" = 137 ]; then
        class=HANG; detail="exceeded ${VERIFY_TIMEOUT}s"
    elif [ -n "$summary" ]; then
        mm=$(sed -n "s/.*: \([0-9]*\) bytes mismatched.*/\1/p" <<< "$summary")
        ms=$(sed -n "s/.*and \([0-9]*\) bytes missing.*/\1/p" <<< "$summary")
        if [ "$mm" = 0 ] && [ "$ms" = 0 ]; then class=MATCH; else class=DIFFERS; fi
        detail="$summary"
    elif grep -q "Traceback" "$se"; then
        class=CRASH; detail=$(grep -v "^ " "$se" | tail -1)
    elif grep -qi "for COPY not found" "$so" "$se"; then
        class=NOCOPY; detail=$(grep -hi "for COPY not found" "$so" "$se" | head -1)
    else
        class=NOCOMPARE; detail=$(tail -1 "$so")
    fi
    printf "%s\t%s\t%s\t%s\n" "$m" "$status" "$class" "$detail"
    rm -f "$so" "$se" "$obj"
' >> "$OUT"
echo "DONE: $(wc -l < "$OUT") rows in $OUT"
