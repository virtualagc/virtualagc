#!/bin/bash
# Reproduces hello.fcm, read_write.fcm, and read_eof_onerror.fcm (plus
# their -lnk101.json symbol tables) via the real HAL/S toolchain
# documented in ../../tools.md (HALSFC + lnk101, both expected on PATH).
# Not run automatically (no CI machine has the toolchain) — kept for
# provenance and to regenerate if the encoding/format ever changes.
#
# Sources:
#   hello.fcm            <- HELLO.hal (ported/PASS1.PROCS/HELLO.hal in the
#                          virtualagc/yaShuttle tree) — WRITE-only smoke test.
#   read_write.fcm        <- yaHALMAT2/src/tests/hal/test_read_write.hal —
#                          a single READ(5) I1,S1 statement.
#   read_eof_onerror.fcm  <- yaHALMAT2/src/tests/hal/test_read_eof_onerror.hal
#                          — READ-until-EOF loop with ON ERROR GO TO DONE,
#                          the standard HAL/S idiom ("Programming in HAL/S"
#                          p.193). Used to confirm HalUCP's ON ERROR/EOF
#                          dispatch end-to-end; also the fixture that
#                          exposed a real gpc run --interactive bug (see
#                          run.c's interactive_input_cb comment) — do NOT
#                          add this one to run_matrix.sh's byte-diff
#                          matrix, its expected output is checked directly
#                          against yaGPC2 only.
set -eu

HAL_SRC_DIR="/home/rburkey/git/virtualagc/yaShuttle"
HELLO_HAL="$HAL_SRC_DIR/ported/PASS1.PROCS/HELLO.hal"
READ_WRITE_HAL="$HAL_SRC_DIR/yaHALMAT2/src/tests/hal/test_read_write.hal"
ONERROR_HAL="$HAL_SRC_DIR/yaHALMAT2/src/tests/hal/test_read_eof_onerror.hal"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PARMS="LIST,NOTABLES,SRN,TEMPLATE,NOLFXI,REGOPT,VARSYM,CARDTYPE=FCRMYCZM"

build() {
    local hal="$1" base="$2" outprefix="$3"
    cp "$hal" "$WORK/$base.hal"
    (cd "$WORK" && HALSFC "$base.hal" --parms="$PARMS" -o "$base.obj")
    (cd "$WORK" && lnk101 "$base.obj" -o "$base.fcm" --json-symbols "$base-lnk101.json")
    cp "$WORK/$base.fcm" "$outprefix.fcm"
    cp "$WORK/$base-lnk101.json" "$outprefix-lnk101.json"
}

cd "$(dirname "$0")"
build "$HELLO_HAL" HELLO hello
build "$READ_WRITE_HAL" test_read_write read_write
build "$ONERROR_HAL" test_read_eof_onerror read_eof_onerror

echo "Rebuilt hello.fcm, read_write.fcm, read_eof_onerror.fcm (+ -lnk101.json)"
