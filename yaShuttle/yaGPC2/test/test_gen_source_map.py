#!/usr/bin/env python3
"""test_gen_source_map.py -- unit tests for tools/gen_source_map.py's
parse_pass1(), specifically its M|/E|/S| line-attachment logic and its
deliberate exclusion of C|/D| lines (comments and the DEBUG pragma --
not HAL/S statements, so not part of any statement's text).

Style follows ../../ported/sdfpkg/test_sdfpkg.py: numbered tests over
synthetic (here: literal pass1.rpt-formatted text) fixtures, PASS/FAIL
per test, process exit status reflects overall result.

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

Usage: ./test_gen_source_map.py [--help]
"""
import importlib.util
import sys
import tempfile
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

failCount = 0


def check(label, got, want):
    global failCount
    if got == want:
        print(f"PASS [{label}]")
    else:
        print(f"FAIL [{label}]: got {got!r}, want {want!r}")
        failCount += 1


def parse(text):
    with tempfile.NamedTemporaryFile("w", suffix=".rpt", delete=False) as f:
        f.write(text)
        path = f.name
    try:
        return gsm.parse_pass1(path)
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

    if failCount:
        print(f"{failCount} test(s) FAILED")
        return 1
    print("All tests PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
