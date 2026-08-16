#!/usr/bin/env python3
"""The reference half of the parser differential test.

Reads `RULE<TAB>TEXT` lines on stdin and writes the same canonical rendering of
the parse tree that tools/parsedump.c writes, using the real TatSu parser.
Point both at the same input and `diff` the outputs.

Usage:  parsedump.py /path/to/ASM101S < pairs.txt
"""

import sys
import os

sys.path.insert(0, sys.argv[1] if len(sys.argv) > 1 else ".")
os.chdir(sys.argv[1] if len(sys.argv) > 1 else ".")

from fieldParser import parserASM      # noqa: E402
from tatsu.contexts import closure     # noqa: E402


def dump(v, out):
    if v is None:
        out.append("N")
        return
    if isinstance(v, str):
        out.append("S%d:%s" % (len(v), v))
        return
    if isinstance(v, bool):
        out.append("B1" if v else "B0")
        return
    if isinstance(v, int):
        out.append("I%d" % v)
        return
    if isinstance(v, dict):
        out.append("D{")
        first = True
        for k, val in v.items():
            if not first:
                out.append(",")
            first = False
            if k == "parseinfo":
                out.append("parseinfo=P%d" % val.endpos)
            else:
                out.append(k)
                out.append("=")
                dump(val, out)
        out.append("}")
        return
    if isinstance(v, closure):
        out.append("C[")
        for i, e in enumerate(v):
            if i:
                out.append(",")
            dump(e, out)
        out.append("]")
        return
    if type(v) is list:
        out.append("L[")
        for i, e in enumerate(v):
            if i:
                out.append(",")
            dump(e, out)
        out.append("]")
        return
    if isinstance(v, tuple):
        out.append("T(")
        for i, e in enumerate(v):
            if i:
                out.append(",")
            dump(e, out)
        out.append(")")
        return
    out.append("?" + str(type(v)))


for line in sys.stdin:
    line = line.rstrip("\n")
    if "\t" not in line:
        continue
    rule, text = line.split("\t", 1)
    out = []
    dump(parserASM(text, rule), out)
    sys.stdout.write("".join(out) + "\n")
