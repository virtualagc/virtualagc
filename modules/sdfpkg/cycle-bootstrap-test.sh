#!/bin/bash
# Test whether a template-dependency cycle can be bootstrapped.
#
#     cycle-bootstrap-test.sh [WORKDIR]     default ~/ForClaude/OI340600-sdftest
#
# 156 files in OI340600 and 178 in OI301700 are never attempted, because
# compilePASS compiles a file only once every template it needs exists, and
# these sit in six mutually-dependent groups where no member can go first.  The
# smallest is a pair:
#
#     VM1BFDCY:58,63   CALL VM4_BF_SHUT_DN;      needs VM4's template
#     VM4BFSHU:71      CANCEL VM1_BFD_CYCLIC;    needs VM1's template
#
# Both uses are real, so neither D INCLUDE TEMPLATE card can just be dropped.
# But PASS1 takes TEMPLIB as both input (--pdsi=4) and output (--pdso=6), so a
# unit may deposit its own template before failing on an undeclared name.  If
# so, compiling one member, failure and all, seeds the template the other needs,
# and a second pass closes the cycle -- with no change to the source.
#
# Run this only when no corpus run is in flight: HALSFC keeps its intermediates
# in the work directory's cwd, and a concurrent compile there loses them.

set -u
D="${1:-$HOME/ForClaude/OI340600-sdftest}"
cd "$D" || exit 1
P=TABLST,SREF,LIST,LISTING2,SRN,TEMPLATE,NOLFXI,REGOPT,LITSTRINGS=3000,CARDTYPE=FCRMUDXCVMWC

compile () {                            # compile NAME SRCDIR -> prints verdict
    local n="$1" s="$2"
    timeout 900 HALSFC "$s/$n.hal" --test --force --parms="$P" \
        -o "objects/$n.obj" --clean --archive --sdfi=SDFLIB > "/tmp/$n.out" 2>&1
    echo "  $n exit=$? : $(grep -cE 'Compilation successful' "/tmp/$n.out") success marker(s)"
    grep -oE "\b[A-Z]{1,2}[0-9]+ " "/tmp/$n.out" | sort -u | tr '\n' ' ' | sed 's/^/     errors: /'
    echo
}

echo "=== TEMPLIB before: $(ls TEMPLIB | wc -l) members"
ls TEMPLIB > /tmp/templib.before

echo "=== step 1: compile VM4BFSHU with its cycle partner absent (expected to fail)"
compile VM4BFSHU APPLSRC
ls TEMPLIB > /tmp/templib.after1
echo "  TEMPLIB gained: $(comm -13 /tmp/templib.before /tmp/templib.after1 | tr '\n' ' ')"

if ! comm -13 /tmp/templib.before /tmp/templib.after1 | grep -q .; then
    echo "=== PASS1 emits no template on failure; falling back to a stub."
    # Seed the library from a minimal unit carrying only the block statement --
    # enough for a template, since what a caller needs is the name and the
    # parameter list.  The real unit is compiled over it immediately after, so
    # the stub never survives into the library the corpus run uses.
    head="$(grep -m1 -E "^[ A-Z]+VM4_BF_SHUT_DN *: *PROCEDURE" APPLSRC/VM4BFSHU.hal \
            | cut -c2-72 | sed 's/  *$//')"
    [ -n "$head" ] || { echo "  cannot find block statement; stopping"; exit 1; }
    printf ' %s\n CLOSE VM4_BF_SHUT_DN;\n' "$head" > _stubVM4BFSHU.hal
    echo "  stub:"; sed 's/^/    |/' _stubVM4BFSHU.hal
    compile _stubVM4BFSHU .
    ls TEMPLIB > /tmp/templib.after1
    echo "  TEMPLIB gained: $(comm -13 /tmp/templib.before /tmp/templib.after1 | tr '\n' ' ')"
    if ! comm -13 /tmp/templib.before /tmp/templib.after1 | grep -q .; then
        echo "=== even a stub deposits no template; bootstrap ruled out here."
        exit 0
    fi
fi

echo "=== step 2: compile VM1BFDCY, which should now find VM4's template"
compile VM1BFDCY APPLSRC

echo "=== step 3: recompile VM4BFSHU, which should now find VM1's template"
compile VM4BFSHU APPLSRC

echo "=== TEMPLIB after: $(ls TEMPLIB | wc -l) members"
