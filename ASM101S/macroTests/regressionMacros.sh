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

# Reduce a listing to the two things worth comparing.
#
#   - Macro-generated lines, those flagged with '+', carry the MNOTE text that
#     the conditional-assembly tests assert on.  Line numbers and the
#     right-hand macro-name column are dropped, since both shift whenever a
#     test file is edited.
#   - Lines that generated object code carry an address and the bytes.  Those
#     are kept as "address data statement", which is what a constants test
#     needs:  a DC that emits the wrong number of bytes, or the right number
#     with the wrong contents, shows up here and nowhere else.
distill() {
    sed -E 's/\r$//' \
        | awk '
            /^ +[0-9]+\+/ {
                sub(/^ +[0-9]+\+/, "")
                sub(/ +0[0-9]-[A-Z@#$]+ *$/, "")
                sub(/ +$/, "")
                print
                next
            }
            /^[0-9A-F]{5} / {
                # Fixed columns, because the line-number field sits between
                # the data and the statement and picking fields by whitespace
                # mistakes it for data on any line that generated none.
                # 1-5 address, 7-30 data, ending col 35 line number, 37+ text.
                addr = substr($0, 1, 5)
                data = substr($0, 7, 24)
                stmt = substr($0, 37)
                sub(/ +$/, "", data)
                sub(/ +$/, "", stmt)
                print addr " " data "  " stmt
                next
            }
        '
}

# Column 72 is the continuation column.  A COMMENT line that reaches it is a
# continued comment, and the statement on the next card is swallowed as its
# continuation -- silently, with no diagnostic and no generated code.  That is
# correct assembler behaviour and a trap for anyone writing a test file in an
# editor that does not show column 72:  it cost an afternoon here, and was
# briefly written up as an ASM101S defect in MACRO/MEND tracking before being
# recognised for what it was.  A statement line may of course reach column 72,
# which is how a real continuation is written.
status=0
for src in *.asm; do
    long=$(awk '/^\*/ && length($0) > 71 { print NR }' "$src")
    if [ -n "$long" ]; then
        echo "$src: FAILED -- comment lines reach column 72 (continuation"
        echo "  column), so the next statement is swallowed.  Lines: $(echo $long | tr '\n' ' ')"
        status=1
        continue
    fi
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
