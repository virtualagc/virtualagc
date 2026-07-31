#!/usr/bin/env python3
"""test_gen_source_map.py -- unit tests for tools/gen_source_map.py's
parse_pass1() and parse_pass2().

parse_pass1() tests cover its M|/E|/S| line-attachment logic and its
deliberate exclusion of C|/D| lines (comments and the DEBUG pragma --
not HAL/S statements, so not part of any statement's text). parse_pass2()
tests cover its TIME:-annotation-based code/data CSECT classification
and the resulting buffer-and-resume-at-next-code logic for statements
with no code of their own.

Style follows ../../ported/sdfpkg/test_sdfpkg.py: numbered tests over
synthetic (here: literal pass1.rpt/pass2.rpt-formatted text) fixtures,
PASS/FAIL per test, process exit status reflects overall result.

T01-T05 use a real excerpt (unmodified except for trimming) of
"HALSFC 108-EXAMPLE_5.hal ... .results/pass1.rpt", chosen because it's
the smallest known real HALSFC output exercising both annotation-line
attachment directions plus a multi-line C| comment block -- see
parse_pass1()'s own docstring for the rule being tested (an E| line
preceded by a blank line attaches FORWARD to the next M| statement; an
S| line with no blank since the last M| line attaches BACKWARD to it;
C| is dropped regardless of position). T06-T09 are small synthetic
cases for the remaining edge cases: an SRN column, a "||" concatenation
operator not truncating the line early, a D| (DEBUG pragma) line being
dropped the same way C| is, and a non-blank unrecognized line (e.g. a
page header) acting as a boundary the same way a blank line does.

T10 uses a real excerpt (trimmed) of "HALSFC 176-P.hal ...
.results/pass2.rpt" -- the smallest known real HALSFC output where a
single compile bounces between a data CSECT and a code CSECT more than
once, including a marker ("ST#7") appearing before any CSECT line at
all. T11 is a small synthetic case for the one thing the 176-P excerpt
doesn't exercise: resuming into a *different-named* code CSECT than the
one execution left off in (e.g. a HAL/S PROGRAM's own "$0NAME" resuming
into an internal PROCEDURE's separate "A1NAME" CSECT).

T12 exercises build_unit()'s handling of a COMPOOL/template-only compile
(no code markers at all, e.g. a shared STRUCTURE declaration referenced
by other units but with no executable statements of its own) -- confirmed
against the real 176.0-SUPER_VECTOR.hal (see compileLinkRun's own manifest
support): it should be skipped with a warning, not treated as a hard
error, since a real multi-unit build legitimately mixes such units in
with ones that have real code.

T13-T15 use a real excerpt of "yaHALMAT2 --disasm optmat.bin" against the
same HELLO.hal compile backing test/fixtures/hello.srcmap.json (hand-
verified statement by statement against this exact output, and cross-
checked against the real SDF's own per-statement HALMAT data, during
planning -- see parse_halmat_offsets()'s own docstring for the
attribution rule being tested): the leading PXRC record header excluded
but MDEF (the program-definition header) correctly attributed to
statement 1, back-to-back SMRKs for statements with no HALMAT of their
own (plain DECLAREs), a single-instruction statement, and a multi-
instruction one. T16-T18 cover fold_halmat_to_eligible_statements() --
folding a statement with no address entry of its own (e.g. a DECLARE)
forward into the nearest preceding one that has one, matching the
debugger's own "nearest address <= target" display semantics -- using
the same real HELLO.hal data. T19-T21 cover is_subsequence(), the
comparison the SDF cross-check itself relies on (SDF's per-statement
opcode list is expected to be a subsequence of the raw-stream one, not
necessarily an exact match, since SDF's HALMAT-cell pointer doesn't
track once-at-startup-only operators like an INITIAL(...) clause's own
CINT -- confirmed empirically: such a value is not reset on a second
CALL). T22-T23 cover derive_internal_name(), confirmed against a real
multi-unit link to differ from the --unit MODULE= name.

Usage: ./test_gen_source_map.py [--help]
"""
import importlib.util
import io
import sys
import tempfile
from contextlib import redirect_stderr
from pathlib import Path

TOOLS_DIR = Path(__file__).resolve().parent.parent / "tools"
spec = importlib.util.spec_from_file_location("gen_source_map", TOOLS_DIR / "gen_source_map.py")
gsm = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gsm)

# Real pass1.rpt excerpt (statements 7-16 of 108-EXAMPLE_5.hal), used
# verbatim for T01-T05. See parse_pass1()'s docstring for the source.
EXAMPLE_5_EXCERPT = """\
          7 M|   DO FOR TEMPORARY N = 1 TO COUNT;                                                                  |EXAMPLE_5
          8 M| 1   A  = N;                                                                                         |EXAMPLE_5
            S|      N                                                                                              |

          9 M|   END;                                                                                              |ST#7
         10 M|   DO FOR TEMPORARY N = 1 TO COUNT;                                                                  |EXAMPLE_5

            E|                      2                                                                              |
         11 M| 1   TOTAL = TOTAL + A ;                                                                             |EXAMPLE_5
            S|                      N                                                                              |

         12 M|   END;                                                                                              |ST#10
         13 M|   RMS = SQRT(TOTAL / COUNT);                                                                        |EXAMPLE_5
         14 M|   WRITE(6) RMS;                                                                                     |EXAMPLE_5

            C|        Compare vs formula for sum of squares.                                                       |EXAMPLE_5
            C|        (which would be the natural way of writing it), the result                                   |EXAMPLE_5
         15 M|   WRITE(6) SQRT((COUNT (COUNT + 1) (2 COUNT + 1) / 6) / COUNT);                                     |EXAMPLE_5

            C|  %SVCI(0);                                                                                          |EXAMPLE_5
         16 M| CLOSE EXAMPLE_5;                                                                                    |EXAMPLE_5
"""

# Real pass2.rpt excerpt (statements 7-16 of 176-P.hal), used verbatim
# for T10. See parse_pass2()'s own docstring for the rule being tested.
P176_PASS2_EXCERPT = """\
0000000                             ST#7     EQU    *
00000                               #EP      CSECT        ESDID= 0005
00000 0000                                   DC     X'0000'
00001 0000                                   DC     X'0000'
00002 00000700                               DC     A'00000700'         #DP
00004 0000                                   DC     X'0000'
00005 0005                                   DC     X'0005'
00000                               $0P      CSECT        ESDID= 0003
0000000                             P        EQU    *
00000 E8F3 0000                              LHI    R0,0()              TIME: 0.25; @0P
00002 E9F3 0000                              LHI    R1,0()              TIME: 0.25; #DP
00004 B914           0005                    STH    R1,5(R0)            TIME: 0.5
00005 E0FB 001C                              IAL    R0,28()             TIME: 0.5
00007 EB21           0008                    LA     R3,8(R1)            TIME: 0.25
00008 BB24           0009                    STH    R3,9(R0)            TIME: 0.5
0000009                             ST#8     EQU    *
0000009                             ST#9     EQU    *
0000009                             ST#10    EQU    *
0000009                             ST#11    EQU    *
0000009                             ST#12    EQU    *
0000009                             ST#13    EQU    *
0006D                               #DP      CSECT        ESDID= 0006
0006D 00000A                                 ORG    *-99
0000A 0000                                   DC     X'0000'
000000B                             ST#14    EQU    *
000000B                             ST#15    EQU    *
00009                               $0P      CSECT        ESDID= 0003
00009 EDF3 0011                              LHI    R5,17               TIME: 0.25
0000B EA48           0012                    LA     R2,18(R0)           TIME: 0.25
0000C D0FF 3800                              SCAL@# R0,0(R1,R3)         TIME: 24.5 (SEE POO); #ZREADAC
0000E 1D0D           0006                    L      R5,6(R1)            TIME: 0.25
0000F EA48           0012                    LA     R2,18(R0)           TIME: 0.25
00010 E2FB 0001                              IAL    R2,1()              TIME: 0.5
00012 6DEA                                   MVH    R5,R2               TIME: 12.0+.875(N-1) (SEE POO)
0000013                             ST#16    EQU    *
"""

# Real "yaHALMAT2 --disasm optmat.bin" excerpt (word offsets 0-32) against
# the same HELLO.hal compile backing test/fixtures/hello.srcmap.json, used
# verbatim for T13-T15. See parse_halmat_offsets()'s own docstring.
HELLO_OPTMAT_DISASM_EXCERPT = """\
#0      0x005 PXRC  numop=1 tag=0x00 copt=0x0  ; Record header, points to closing XREC
        [0] data=0x005A(90) qual=  0 tag1=0x00 tag2=0x0
#2      0x02B MDEF  numop=1 tag=0x00 copt=0x0  ; Program definition header
        [0] data=0x0001(1) qual=SYT tag1=0x00 tag2=0x0
#4      0x004 SMRK  numop=1 tag=0x00 copt=0x0  ; Statement marker
        [0] data=0x0001(1) qual=  0 tag1=0xCA tag2=0x1
#6      0x004 SMRK  numop=1 tag=0x00 copt=0x0  ; Statement marker
        [0] data=0x0002(2) qual=  0 tag1=0x00 tag2=0x0
#8      0x841 CINT  numop=2 tag=0x02 copt=0x0  ; Character initialize
        [0] data=0x0003(3) qual=SYT tag1=0x00 tag2=0x0
        [1] data=0x0002(2) qual=LIT tag1=0x00 tag2=0x0
#11     0x004 SMRK  numop=1 tag=0x00 copt=0x0  ; Statement marker
        [0] data=0x0003(3) qual=  0 tag1=0x00 tag2=0x0
#13     0x004 SMRK  numop=1 tag=0x00 copt=0x0  ; Statement marker
        [0] data=0x0004(4) qual=  0 tag1=0x00 tag2=0x0
#15     0x004 SMRK  numop=1 tag=0x00 copt=0x0  ; Statement marker
        [0] data=0x0005(5) qual=  0 tag1=0x00 tag2=0x0
#17     0x031 EDCL  numop=0 tag=0x01 copt=0x0  ; End-of-declarations marker
#18     0x025 XXST  numop=1 tag=0x00 copt=0x0  ; I/O statement start, carries I/O-kind code
        [0] data=0x0002(2) qual=IMD tag1=0x00 tag2=0x0
#20     0x027 XXAR  numop=1 tag=0x00 copt=0x0  ; I/O statement argument
        [0] data=0x0004(4) qual=LIT tag1=0x02 tag2=0x0
#22     0x021 WRIT  numop=1 tag=0x00 copt=0x0  ; WRITE statement header
        [0] data=0x0006(6) qual=IMD tag1=0x00 tag2=0x0
#24     0x026 XXND  numop=0 tag=0x00 copt=0x0  ; I/O statement end
#25     0x004 SMRK  numop=1 tag=0x00 copt=0x0  ; Statement marker
        [0] data=0x0006(6) qual=  0 tag1=0x00 tag2=0x1
#27     0x010 DFOR  numop=4 tag=0x01 copt=0x0  ; DO FOR statement header
        [0] data=0x0001(1) qual=INL tag1=0x00 tag2=0x1
        [1] data=0x0002(2) qual=SYT tag1=0x00 tag2=0x0
        [2] data=0x0005(5) qual=LIT tag1=0x00 tag2=0x0
        [3] data=0x0006(6) qual=LIT tag1=0x00 tag2=0x0
#32     0x004 SMRK  numop=1 tag=0x00 copt=0x0  ; Statement marker
        [0] data=0x0007(7) qual=  0 tag1=0x00 tag2=0x1
"""

failCount = 0


def check(label, got, want):
    global failCount
    if got == want:
        print(f"PASS [{label}]")
    else:
        print(f"FAIL [{label}]: got {got!r}, want {want!r}")
        failCount += 1


def parse_text_to_file(text):
    with tempfile.NamedTemporaryFile("w", suffix=".rpt", delete=False) as f:
        f.write(text)
        return f.name


def parse(text, parser=gsm.parse_pass1):
    path = parse_text_to_file(text)
    try:
        return parser(path)
    finally:
        Path(path).unlink()


def main():
    if len(sys.argv) > 1 and sys.argv[1] in ("--help", "-h"):
        print(__doc__)
        return 0

    stmts = parse(EXAMPLE_5_EXCERPT)

    check("T01 M-line tag preserved verbatim", stmts[7], ["M|   DO FOR TEMPORARY N = 1 TO COUNT;"])
    check(
        "T02 trailing S| attaches to the preceding statement",
        stmts[8],
        ["M| 1   A  = N;", "S|      N"],
    )
    check(
        "T03 leading E| (blank before it) attaches to the FOLLOWING statement, not stmt 10",
        stmts[11],
        [
            "E|                      2",
            "M| 1   TOTAL = TOTAL + A ;",
            "S|                      N",
        ],
    )
    check("T04 stmt 10 itself carries no trailing annotation stolen by stmt 11's E|", stmts[10],
          ["M|   DO FOR TEMPORARY N = 1 TO COUNT;"])
    check(
        "T05 C| comment lines are dropped entirely, not attached to stmt 15 (not a HAL/S statement)",
        stmts[15],
        ["M|   WRITE(6) SQRT((COUNT (COUNT + 1) (2 COUNT + 1) / 6) / COUNT);"],
    )
    check("T05b ...nor to stmt 16, whose own leading C| line is also dropped", stmts[16],
          ["M| CLOSE EXAMPLE_5;"])

    srn = parse("000010    1 M| EXAMPLE_5:" + " " * 100 + "|EXAMPLE_5\n")
    check("T06 leading SRN column doesn't shift the statement number", srn[1], ["M| EXAMPLE_5:"])

    concat = parse("          6 M|   X = A||B;" + " " * 100 + "|EXAMPLE_5\n")
    check("T07 '||' concatenation operator not mistaken for the closing pipe", concat[6], ["M|   X = A||B;"])

    debug_pragma = (
        "            D| EBUG `E                                                                                    |\n"
        "\n"
        "          1 M| SIMPLE:                                                                                    |SIMPLE\n"
    )
    d = parse(debug_pragma)
    check("T08 D| (DEBUG pragma) line is dropped entirely, not attached to stmt 1", d[1], ["M| SIMPLE:"])

    boundary = (
        "         14 M|   WRITE(6) RMS;                                                                             |EXAMPLE_5\n"
        "^L------------------------------------------------------------------------------------------------------\n"
        "            E|                      2                                                                     |\n"
        "         15 M| 1   NEXT;                                                                                   |EXAMPLE_5\n"
    )
    b = parse(boundary)
    check("T09 unrecognized line (page break) resets attachment like a blank line", b[15],
          ["E|                      2", "M| 1   NEXT;"])
    check("T09b ...and stmt 14 keeps no stolen trailing annotation", b[14], ["M|   WRITE(6) RMS;"])

    p176 = parse(P176_PASS2_EXCERPT, parser=gsm.parse_pass2)
    check(
        "T10 TIME:-based code/data classification + resume-at-next-code, real 176-P.hal excerpt",
        p176,
        [
            ("$0P", 0, 7),  # ST#7, seen before any CSECT line, flushed when $0P (code) opens
            ("$0P", 9, 8),  # ST#8-13: zero-code markers found directly inside the $0P code run
            ("$0P", 9, 9),
            ("$0P", 9, 10),
            ("$0P", 9, 11),
            ("$0P", 9, 12),
            ("$0P", 9, 13),
            ("$0P", 9, 14),  # ST#14/15: buffered while #DP (data, no TIME: lines) is open,
            ("$0P", 9, 15),  # bound to $0P's own resumption offset (9), not their own loc (0xB)
            ("$0P", 0x13, 16),  # ST#16: found directly inside the (still) $0P code run
        ],
    )

    resume_diff_csect = """\
00000                               $0X      CSECT        ESDID= 0001
00000 E8F3 0000                              LHI    R0,0()              TIME: 0.25
0000001                             ST#1     EQU    *
00002                               #DX      CSECT        ESDID= 0002
00002 0000                                   DC     X'0000'
0000003                             ST#2     EQU    *
00000                               A1X      CSECT        ESDID= 0003
00000 E9F3 0000                              LHI    R1,0()              TIME: 0.25
0000001                             ST#3     EQU    *
"""
    r = parse(resume_diff_csect, parser=gsm.parse_pass2)
    check(
        "T11 a statement buffered in one code CSECT can resume in a DIFFERENTLY-named one",
        r,
        [("$0X", 1, 1), ("A1X", 0, 2), ("A1X", 1, 3)],
    )

    compool_pass1 = parse_text_to_file(
        "          1 M| DUMMY_COMPOOL:                                                                             |DUMMY_COMPOOL\n"
        "          1 M| COMPOOL;                                                                                   |DUMMY_COMPOOL\n"
    )
    compool_pass2 = parse_text_to_file(
        "0000000                             ST#1     EQU    *\n"
        "00000                               #DDUMMY  CSECT        ESDID= 0002\n"
        "00000 0000                                   DC     X'0000'\n"
    )
    try:
        stderr = io.StringIO()
        with redirect_stderr(stderr):
            unit = gsm.build_unit("DUMMY_COMPOOL", compool_pass1, compool_pass2, None, None, {})
        check("T12 a COMPOOL/template-only compile (no code markers) is skipped, not a hard error", unit, None)
        check("T12b ...with a warning explaining why", "skipping" in stderr.getvalue(), True)
    finally:
        Path(compool_pass1).unlink()
        Path(compool_pass2).unlink()

    halmat = gsm.parse_halmat_offsets(HELLO_OPTMAT_DISASM_EXCERPT)
    check(
        "T13 leading PXRC excluded but MDEF (the program-definition header) IS attributed to "
        "statement 1 (label+PROGRAM) -- confirmed against real SDF data during planning",
        halmat[1],
        [(2, 0x02B)],
    )
    check("T13b statement 2 (plain DECLARE) has none -- back-to-back SMRKs", halmat[2], [])
    check(
        "T14 statement 3 (DECLARE ... INITIAL(...)) is a single-instruction CINT",
        halmat[3],
        [(8, 0x841)],
    )
    check(
        "T15 statement 6 (first executable WRITE, also sweeps up the EDCL phase-transition marker) "
        "gets the whole instruction set, not one representative value",
        halmat[6],
        [(17, 0x031), (18, 0x025), (20, 0x027), (22, 0x021), (24, 0x026)],
    )
    check("T15b statement 7 (DO FOR header) is a single instruction", halmat[7], [(27, 0x010)])

    # T16-T18: fold_halmat_to_eligible_statements(). Statements 2-5 never
    # win their own address entry (confirmed against the real HELLO.hal
    # fixture: their zero-code markers all cluster at the very same
    # offset statement 6's own marker does, and lose that tie) -- so
    # their raw HALMAT (statement 3's CINT) must fold forward into
    # statement 1, the nearest *preceding* statement that does win an
    # address, matching the debugger's own "nearest address <= target"
    # display semantics exactly.
    addr_to_stmt = {65536: 1, 65545: 6, 65554: 7}  # 2,3,4,5 never appear as values
    folded = gsm.fold_halmat_to_eligible_statements(halmat, addr_to_stmt)
    check(
        "T16 statement 1's folded HALMAT includes its own MDEF plus statement 3's folded-in CINT",
        folded[1],
        [(2, 0x02B), (8, 0x841)],
    )
    check("T16b statements 2/4/5 (empty, and no address of their own) vanish rather than leaving empty entries",
          {k: v for k, v in folded.items() if k in (2, 4, 5)}, {})
    check("T17 statement 6 (its own address) keeps just its own instructions, nothing extra folds in",
          folded[6], halmat[6])
    check(
        "T18 no address entries at all (e.g. --unit had no HALMAT_FILE and this never gets called in "
        "practice, but should still degrade gracefully) folds nothing rather than raising",
        gsm.fold_halmat_to_eligible_statements(halmat, {}),
        {},
    )

    # T19-T21: is_subsequence() -- the SDF-cross-check comparison itself.
    check("T19 SDF's list missing a leading one-time-startup op is still a valid subsequence",
          gsm.is_subsequence([0x25, 0x27, 0x21, 0x26], [0x31, 0x25, 0x27, 0x21, 0x26]), True)
    check("T19b an empty SDF list is trivially a subsequence of anything", gsm.is_subsequence([], [0x25, 0x27]), True)
    check("T20 identical lists are a subsequence of each other", gsm.is_subsequence([0x25, 0x27], [0x25, 0x27]), True)
    check(
        "T21 a genuinely wrong/out-of-order SDF list is NOT a subsequence",
        gsm.is_subsequence([0x27, 0x25], [0x25, 0x27]),
        False,
    )
    check(
        "T21b an SDF opcode that never appears in the raw list at all is NOT a subsequence",
        gsm.is_subsequence([0x99], [0x25, 0x27]),
        False,
    )

    # T22-T23: derive_internal_name() -- the compiler's own internal
    # PROGRAM/PROCEDURE/FUNCTION identifier (used for the SDF member
    # filename), confirmed against a real multi-unit link to differ from
    # the --unit MODULE= name (just the external .hal filename's stem):
    # "176-P" -> CSECT "$0P" -> internal name "P"; "176.1-READ_ACC" ->
    # CSECT "#CREADAC" -> internal name "READAC".
    check(
        "T22 a PROGRAM's own internal name comes from its \"$0NAME\" CSECT",
        gsm.derive_internal_name([("$0P", 0, 1), ("$0P", 9, 2), ("A1P", 0, 7)]),
        "P",
    )
    check(
        "T22b a separately-compiled PROCEDURE/FUNCTION's own internal name comes from its \"#CNAME\" CSECT",
        gsm.derive_internal_name([("#CREADAC", 0, 4), ("#CREADAC", 7, 7)]),
        "READAC",
    )
    check(
        "T23 no matching CSECT (e.g. a COMPOOL, with no code CSECT of its own) returns None",
        gsm.derive_internal_name([("#DDUMMY", 0, 1)]),
        None,
    )

    if failCount:
        print(f"{failCount} test(s) FAILED")
        return 1
    print("All tests PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
