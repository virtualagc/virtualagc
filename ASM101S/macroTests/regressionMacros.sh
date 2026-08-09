#!/bin/bash
# Regression test for ASM101S macro-argument semantics: virtualagc issue #1331.
#
# This complements regressionASM101S.sh rather than duplicating it.  That one
# assembles the AP-101S runtime library and compares it against contemporary
# listings, which is the stronger check but exercises almost none of the
# conditional-assembly language:  RUNMAC uses no multilevel sublists at all,
# so the whole of this area can break without moving that score off 205 of 205.
# The FCOS macro library MLIB80 does use it, heavily.
#
# Each test assembles one source file and compares the text of its MNOTEs
# against a recorded expected result.  The expected values are not merely
# whatever ASM101S happened to print:  every one was checked against the IBM
# manuals cited in the source file, and independently against IBM HLASM (via
# z390 mz390) and Don Schmidt's asm101, in the discussion on issue #1331.
#
# Usage:
#     regressionMacros.sh [--update]
#
#     --update   Rewrite the expected-result files from the current output.
#                Only do this when you have checked the new values against
#                the manuals; it will happily record a regression as correct.
set -u
cd "$(dirname "$0")" || exit 1

UPDATE=no
[ $# -gt 0 ] && [ "$1" = "--update" ] && UPDATE=yes

# Keep only the macro-generated lines of the listing (those flagged with '+'),
# and strip the line numbers and the right-hand macro-name column, so that the
# comparison is over the MNOTE text alone.
distill() {
    grep -E "^ +[0-9]+\+" \
        | sed -E 's/^ +[0-9]+\+//; s/ +0[0-9]-[A-Z@#$]+ *$//' \
        | sed 's/ *$//'
}

status=0
for src in *.asm; do
    name=${src%.asm}
    expected="$name.txt"
    actual=$(timeout 120 ASM101S --tolerable=255 "$src" 2>&1 | distill)
    if [ ! -f "$expected" ] || [ "$UPDATE" = yes ]; then
        printf '%s\n' "$actual" > "$expected"
        echo "$name: recorded"
        continue
    fi
    if diff -u "$expected" <(printf '%s\n' "$actual") > /tmp/$$.diff; then
        echo "$name: OK"
    else
        echo "$name: FAILED"
        cat /tmp/$$.diff
        status=1
    fi
    rm -f /tmp/$$.diff
done
rm -f ./*.obj
exit $status
