#!/usr/bin/env python3
'''
License:    Declared to be in the Public Domain in the U.S. by its author
            (Ron Burkey), and may be used, modified, or distributed freely for
            any purpose whatever.
Filename:   partiallist.py
Purpose:    Test the "D INCLUDE TEMPLATE name: a, b, c;" partial-include form.
Reference:  https://www.ibiblio.org/apollo
Contact:    Ron Burkey <info@sandroid.org>

A colon and a list of names after the member name imports only those symbols
rather than the whole compool.  Unlike everything else about including an SDF,
this cannot be checked against the template route, because it is handled
entirely inside INCLUDE_SDF: when no SDF is found, PATCH_INCLUDE falls through
to FINDER and includes the whole template, list and all ignored.  So the two
routes are meant to differ here, and the test states the expected symbol table
outright instead.

The listed names are looked up with SDFPKG mode 13, which is reached from
nowhere else, and the "STRUCTURE name" form asks for a structure template --
whose name is held in the SDF with a leading space, which is why INCLUDE_SDF
prefixes one.

Usage:
    partiallist.py [--compiler=PATH]
'''

import sys
import os
import json
import shutil
import subprocess
import tempfile

# For each user program: the symbols expected in the table afterwards, the
# expected exit status, and any diagnostic that must appear.
CASES = [
    ("USEL.hal",  ["COMPA", "IA", "CA", "USEL"], 0, None),
    ("USEL4.hal", ["COMPA", " ASTRUCTURE", "SI", "SL", "SS", "SC",
                   "ASTRUCTURE", "IA", "USEL4"], 0, None),
    # Referring to a symbol that was not listed must fail as undeclared --
    # otherwise the list is not actually restricting anything.
    ("USEL2.hal", None, 8, "UNDECLARED IDENTIFIER SA"),
    # And naming something the SDF does not have is XI7.
    ("USEL3.hal", None, 8, "SYMBOL NOSUCH NOT IN SDF"),
]

_here = os.path.dirname(os.path.realpath(__file__))
_defaultCompiler = os.path.join(
    _here, "..", "..", "..", "yaShuttle", "ported", "PASS1.PROCS",
    "HAL_S_FC.py")


def compile(compiler, workDir, halFile, *extra):
    command = [sys.executable, compiler, "--pfs", "--templib",
               "--hal=" + halFile] + list(extra)
    result = subprocess.run(command, cwd=workDir, capture_output=True,
                            text=True)
    return result.returncode, result.stdout, result.stderr


def symbolNames(workDir):
    with open(os.path.join(workDir, "SYM_TAB.json")) as f:
        return [e["SYM_NAME"] for e in json.load(f) if e["SYM_NAME"]]


def main():
    compiler = _defaultCompiler
    for parm in sys.argv[1:]:
        if parm.startswith("--compiler="):
            compiler = parm.split("=", 1)[1]
        elif parm == "--help":
            print(__doc__)
            return 0

    if shutil.which("HALSFC") is None:
        print("SKIP: HALSFC is not on the PATH, and it is what runs the PASS3 "
              "that writes an SDF")
        return 0

    workDir = tempfile.mkdtemp(prefix="sdfPartialList_")
    try:
        for name in ["COMPA.hal"] + [case[0] for case in CASES]:
            shutil.copy(os.path.join(_here, name), workDir)
        os.mkdir(os.path.join(workDir, "SDFLIB"))
        compile(compiler, workDir, "COMPA.hal", "TEMPLATE")
        subprocess.run(["HALSFC", "--parms=TEMPLATE", "--clean", "--archive",
                        "COMPA.hal"], cwd=workDir, capture_output=True,
                       text=True)
        if not os.listdir(os.path.join(workDir, "SDFLIB")):
            print("SKIP: HALSFC produced no SDF")
            return 0

        failed = 0
        for halFile, expected, expectedStatus, expectedText in CASES:
            status, report, errors = compile(compiler, workDir, halFile,
                                             "--sdfi=SDFLIB")
            complaints = []
            if status != expectedStatus:
                complaints.append("exit status %d, expected %d"
                                  % (status, expectedStatus))
                if errors:
                    complaints.append(errors.strip().splitlines()[-1])
            if "INCLUDED FROM SDF" not in report:
                complaints.append("no SDF was imported; the compiler fell "
                                  "back on the template library")
            if expectedText and expectedText not in report:
                complaints.append("expected the report to say %r"
                                  % expectedText)
            if expected is not None:
                got = symbolNames(workDir)
                if got != expected:
                    complaints.append("symbols are %s, expected %s"
                                      % (got, expected))
            if complaints:
                failed += 1
                print("FAIL: " + halFile)
                for complaint in complaints:
                    print("        " + complaint)
            else:
                print("PASS: " + halFile)
        return 1 if failed else 0
    finally:
        shutil.rmtree(workDir, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
