#!/usr/bin/env python3
'''
License:    Declared to be in the Public Domain in the U.S. by its author
            (Ron Burkey), and may be used, modified, or distributed freely for
            any purpose whatever.
Filename:   invariant.py
Purpose:    Acceptance test for importing an SDF in place of a TEMPLATE.
Reference:  https://www.ibiblio.org/apollo
Contact:    Ron Burkey <info@sandroid.org>

Substituting an SDF for a TEMPLATE is only correct if both routes leave the
compiler with the same symbol table -- that is the entire premise of the
feature, since adding entries to the symbol table is the only thing a TEMPLATE
is for.  That makes the two routes each other's reference implementation, which
is useful here because there is no other: HALSFC-PASS1 contains the whole of
INCLUDE_SDF but its runtime's MONITOR(22) is still a stub, so it too falls back
on the TEMPLATE and cannot serve as an oracle.

So: compile the same program twice, once with an SDF library present and once
without, and require the symbol tables to match.

Three differences are expected rather than faults, and are allowed for below:

  * SDF_INCL_FLAG on the included block.  The point of it is to record that
    the block came from an SDF, so the routes must differ here.

  * SYM_ADDR.  PASS1 does not assign addresses; a TEMPLATE therefore has none
    to offer, whereas an SDF carries the ones its own compilation settled on.
    Picking those up is a benefit of the SDF route, not a discrepancy.

  * SYM_LINK1 and SYM_LINK2 of a block label.  SET_LABEL threads these when it
    sees a label defined in source (SETLABEL.xpl:110-113, "SYT_LINK1(LOC) =
    -DO_LEVEL" and the SYT_LINK2(0) chain).  A block arriving from an SDF is
    entered directly and never passes through SET_LABEL, in the original XPL
    exactly as here -- INCSDF.xpl sets SYT_LINK1/2 only inside
    ENTER_SDF_TEMPLATE, for the members of a structure template.

  * DEFINED_LABEL on a label declared inside a structure template.  See the
    comment beside the test for it below.

  * SYM_XREF, which is an index into the cross-reference table.  Including a
    TEMPLATE inserts the included source, and those statements are themselves
    cross-referenced, so the table is larger and every index into it shifts.
    Rather than ignore the field, the flag bits of each symbol's leading
    cross-reference entry are compared instead: those must agree.  The
    statement number in that entry legitimately does not, an imported symbol
    being attributed to the INCLUDE statement ("TREAT EACH INCLUDE AS ONE
    STMT") rather than to a source line that is not part of this compilation.

Usage:
    invariant.py [--compiler=PATH] [--keep] COMPOOL.hal USER.hal ...

Each COMPOOL.hal is compiled twice over, once to populate the template library
and once (by PASS3) to produce the SDF, and then each USER.hal is compiled by
both routes and the two symbol tables compared.  Exits 0 if they agree.
'''

import sys
import os
import json
import shutil
import subprocess
import tempfile

SDF_INCL_FLAG = 0x800
DEFINED_LABEL = 0x40
EXEMPT = {"SYM_ADDR", "SYM_LINK1", "SYM_LINK2", "SYM_XREF"}
XREF_MASK = 0x1FFF

_here = os.path.dirname(os.path.realpath(__file__))
_defaultCompiler = os.path.join(
    _here, "..", "..", "..", "yaShuttle", "ported", "PASS1.PROCS",
    "HAL_S_FC.py")


def compile(compiler, workDir, halFile, *extra):
    '''Run one compilation, returning (exit status, report).'''
    command = [sys.executable, compiler, "--pfs", "--templib",
               "--hal=" + halFile] + list(extra)
    result = subprocess.run(command, cwd=workDir, capture_output=True,
                            text=True)
    if result.returncode not in (0, 8):
        print(command)
        print(result.stderr[-2000:], file=sys.stderr)
    return result.returncode, result.stdout


def symbolTable(workDir):
    with open(os.path.join(workDir, "SYM_TAB.json")) as f:
        symbols = json.load(f)
    with open(os.path.join(workDir, "CROSS_REF.json")) as f:
        crossRef = json.load(f)
    return symbols, crossRef


def xrefFlags(symbol, crossRef):
    '''The flag bits of a symbol's leading cross-reference entry, or None.'''
    index = symbol.get("SYM_XREF") or 0
    if not 0 < index < len(crossRef):
        return None
    return (crossRef[index].get("CR_REF", 0) >> 13) & 7


def compare(template, templateXref, sdf, sdfXref):
    '''Return a list of complaints, empty if the two tables agree.'''
    complaints = []
    if len(template) != len(sdf):
        return ["symbol table has %d entries via the template and %d via the "
                "SDF" % (len(template), len(sdf))]
    for i, (a, b) in enumerate(zip(template, sdf)):
        left, right = xrefFlags(a, templateXref), xrefFlags(b, sdfXref)
        if left != right:
            complaints.append(
                "symbol %d (%s): leading cross-reference flags are %s via the "
                "template but %s via the SDF"
                % (i, a.get("SYM_NAME", "?"), left, right))
        for field in sorted(set(a) | set(b)):
            if field in EXEMPT:
                continue
            left, right = a.get(field), b.get(field)
            if field == "SYM_FLAGS":
                # The SDF route additionally marks the block as SDF-derived.
                right &= ~SDF_INCL_FLAG
                # A label declared inside a structure template -- "1 P NAME
                # PROGRAM" -- is marked DEFINED_LABEL when the declaration is
                # seen in source, but not when it arrives from an SDF:
                # INCSDF.xpl names DEFINED_LABEL in exactly one place, for the
                # compilation unit's own block label, and the SDF carries no
                # flag for SET_SYT_FLAGS to map onto it.  Allowed in that
                # direction only, so that any other flag difference still
                # fails.
                if (left & DEFINED_LABEL) and not (right & DEFINED_LABEL):
                    left &= ~DEFINED_LABEL
            if left != right:
                complaints.append(
                    "symbol %d (%s): %s is %s via the template but %s via the "
                    "SDF" % (i, a.get("SYM_NAME", "?"), field, left, right))
    return complaints


def main():
    compiler = _defaultCompiler
    keep = False
    halFiles = []
    for parm in sys.argv[1:]:
        if parm.startswith("--compiler="):
            compiler = parm.split("=", 1)[1]
        elif parm == "--keep":
            keep = True
        elif parm == "--help":
            print(__doc__)
            return 0
        else:
            halFiles.append(parm)
    if len(halFiles) < 2:
        print(__doc__, file=sys.stderr)
        return 1
    compools, users = halFiles[:-1], halFiles[-1:]

    workDir = tempfile.mkdtemp(prefix="sdfInvariant_")
    try:
        for name in compools + users:
            shutil.copy(os.path.join(_here, name)
                        if not os.path.isabs(name) and
                        os.path.exists(os.path.join(_here, name)) else name,
                        workDir)
        os.mkdir(os.path.join(workDir, "SDFLIB"))

        # Build the template library from the compools.  Note that the
        # template library HAL_S_FC.py uses is TEMPLIB.json, not HALSFC's
        # TEMPLIB/ directory, so it has to be built with this compiler.
        for name in compools:
            status, _ = compile(compiler, workDir, name, "TEMPLATE")
            if status not in (0, 8):
                print("FAIL: could not compile %s (status %d)"
                      % (name, status))
                return 1

        # And the SDF library.  An SDF is written by PASS3, and HAL_S_FC.py is
        # a port of PASS1 alone, so this part needs the whole compiler.
        if shutil.which("HALSFC") is None:
            print("SKIP: HALSFC is not on the PATH, and it is what runs the "
                  "PASS3 that writes an SDF")
            return 0
        for name in compools:
            subprocess.run(["HALSFC", "--parms=TEMPLATE", "--clean",
                            "--archive", name],
                           cwd=workDir, capture_output=True, text=True)
        sdfs = os.listdir(os.path.join(workDir, "SDFLIB"))
        if not sdfs:
            print("SKIP: HALSFC produced no SDFs")
            return 0
        print("SDF library: " + ", ".join(sorted(sdfs)))

        failed = 0
        for name in users:
            status, report = compile(compiler, workDir, name)
            template, templateXref = symbolTable(workDir)
            statusSdf, reportSdf = compile(compiler, workDir, name,
                                           "--sdfi=SDFLIB")
            sdf, sdfXref = symbolTable(workDir)
            complaints = compare(template, templateXref, sdf, sdfXref)
            # Without this the test would be satisfied by an SDF route that
            # quietly fell back on the template, which is exactly what happens
            # when the SDF cannot be read -- and the two would then agree
            # trivially.
            if "INCLUDED FROM SDF" not in reportSdf:
                complaints.insert(0, "the --sdfi run did not import an SDF; "
                                  "it fell back on the template library")
            if "INCLUDED FROM SDF" in report:
                complaints.insert(0, "the run without --sdfi imported an SDF "
                                  "anyway, so the two routes are not distinct")
            if status != statusSdf:
                complaints.insert(0, "exit status %d via the template but %d "
                                  "via the SDF" % (status, statusSdf))
            elif status != 0:
                # Otherwise two routes that fail in the same way would look
                # like agreement.  The fixtures are meant to compile cleanly.
                complaints.insert(0, "neither route compiled cleanly (exit "
                                  "status %d), so agreement proves nothing"
                                  % status)
            if complaints:
                failed += 1
                print("FAIL: %s" % name)
                for complaint in complaints:
                    print("        " + complaint)
            else:
                print("PASS: %s -- %d symbols identical either way"
                      % (name, len(template)))
        return 1 if failed else 0
    finally:
        if keep:
            print("work directory kept at", workDir)
        else:
            shutil.rmtree(workDir, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
