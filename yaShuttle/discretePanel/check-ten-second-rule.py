#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   check-ten-second-rule.py
Purpose:    Check crew scripts against PASS Program Notes 42433 and 37536:
            nothing on their lists within ten seconds either side of moding
            a GPC to RUN.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

Usage:      check-ten-second-rule.py [--margin=SECONDS] SCRIPT [SCRIPT ...]

Exit status 1 if any script breaks the rule.

THE RULE.  Program Note 42433 (DR46617, DR30138), "POTENTIAL F-T-S DUE TO ICC
CONTENTION AT NEW GPC START-UP", lists activities that "SHOULD NOT BE
PERFORMED DURING THE TIME SPAN BEGINNING APPROXIMATELY 10 SECONDS BEFORE
MODING A SECONDARY GPC TO RUN UNTIL 10 SECONDS AFTER PLACING THE MODE SWITCH
TO RUN OR UNTIL THE OUTPUT TALKBACK GOES GRAY": a downlist GPC switch, FC/PL
string moding, a DEU major function switch change, a GPC/CRT key, the BFC CRT
SELECT or DISP switch, OPS transitions and recalls, and moding another GPC.
Program Note 37536 adds keyboard functions on the system SPECs during "GPC
INITIALIZATION TO CS (STBY TO RUN)".  A script that broke it lost a computer
about one run in ten (yaGPC2 ledger #256).

WHAT IS COUNTED.  Script verbs mode, crt, select, display, majfunc and output,
and every keyboard entry -- which is stricter than the notes, since not every
entry is on a system SPEC, but a script cannot know what display a keyboard is
talking to.  NOT counted: the mode switch of the computer itself on its way
to RUN, gpc (it selects which column of the panel the next
verb acts on, and moves nothing in the vehicle), source, ipl, idpload,
idppower, subtitles and the rest.

INCLUDED SCRIPTS ARE EXPANDED, with their parameters, so an action in a parent
is measured against a 'mode RUN' in the script it called and the other way
about.  TIME ACROSS A WAIT IS TAKEN AS ZERO: a wait lasts as long as it lasts,
so the scripted delays either side of it are all a script can promise.
'''
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import crewscript

LISTED = ("mode", "crt", "select", "display", "majfunc", "output")

def flatten(entries, t, where, out):
    prev = 0
    for e in entries:
        if e.get("kind") != "step":
            prev = 0                      # a wait: the count of ms starts again
            out.append((t, "wait", e.get("text", ""), where, e.get("line")))
            continue
        if e["ms"] < prev:                # the count restarted: a script
            prev = 0                      # called just before had waits in it
        t += (e["ms"] - prev) / 1000.0
        prev = e["ms"]
        if e["verb"] == "script":
            t = flatten(e.get("entries", []), t,
                        os.path.basename(e.get("path", "?")), out)
        else:
            out.append((t, e["verb"], e.get("arg", ""), where, e.get("line")))
    return t

def check(path, margin):
    entries = crewscript.parse(open(path).read(), path=path)
    flat = []
    flatten(entries, 0.0, os.path.basename(path), flat)
    bad = []
    gpc = "?"
    runs = []
    col = []                              # the panel column each entry acts on
    for k, (t, verb, arg, where, line) in enumerate(flat):
        if verb == "gpc":
            gpc = arg
        col.append(gpc)
        if verb == "mode" and arg.upper() == "RUN":
            runs.append((k, t, gpc, where, line))
    for k, t, g, where, line in runs:
        for j, (u, verb, arg, w2, l2) in enumerate(flat):
            if j == k or abs(u - t) >= margin:
                continue
            # The computer's OWN way to RUN -- HALT, STBY, RUN -- is not
            # "moding ANOTHER GPC".
            if verb == "mode" and col[j] == g:
                continue
            if verb in LISTED or verb == "keys":
                bad.append((where, line, g, verb, arg, u - t, w2, l2))
    return runs, bad

def main():
    margin = 10.0
    paths = []
    for a in sys.argv[1:]:
        if a.startswith("--margin="):
            margin = float(a.split("=", 1)[1])
        else:
            paths.append(a)
    if not paths:
        sys.exit(__doc__)
    worst = 0
    for p in paths:
        try:
            runs, bad = check(p, margin)
        except Exception as err:
            print("%s: CANNOT CHECK -- %s" % (os.path.basename(p), err))
            worst = 1
            continue
        if not bad:
            print("%s: ok, %d 'mode RUN'" % (os.path.basename(p), len(runs)))
            continue
        worst = 1
        print("%s: %d action(s) inside %.0f s of a 'mode RUN'"
              % (os.path.basename(p), len(bad), margin))
        for where, line, g, verb, arg, dt, w2, l2 in bad:
            print("    GPC %s to RUN at %s:%s -- '%s %s' %.1f s %s, at %s:%s"
                  % (g, where, line, verb, arg, abs(dt),
                     "BEFORE" if dt < 0 else "after", w2, l2))
    sys.exit(worst)

if __name__ == "__main__":
    main()
