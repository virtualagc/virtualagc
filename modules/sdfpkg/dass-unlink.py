#!/usr/bin/env python3
"""Re-extract every configuration's images from the DASS listings.

    dass-unlink.py [config ...] [--check] [--force] [--keep=DIR]

with no arguments, all eight.  For each one it runs unlinkMAFGEN2.py over
mafgen/DASS_<cfg>.ASC and installs its output under the names the rest of the
toolchain expects:

    memory.fcm      -> mafgen/<cfg>.fcm         the AS-BUILT image
    pureMemory.fcm  -> mafgen/pure-<cfg>.fcm    the AS-DUMPED image

WHY THIS EXISTS.  unlinkMAFGEN2.py writes into a results subdirectory of the
working directory, under fixed generic names, one configuration per run.
Turning that into the eight installed artefacts was a hand step, and a hand
step is one that gets skipped: the images are only re-extracted when a listing
or the extractor changes, which is exactly when nobody remembers the ritual.
It is also the step where the two images can be confused with each other, and
that confusion is expensive -- see below.

TWO IMAGES, TWO ORACLES, AND THEY ARE NOT INTERCHANGEABLE.

  <cfg>.fcm       AS-BUILT.  The PATCH SUMMARY's load-module (LM) values are
                  written over what memory held.  This is the image to compare
                  against an OI340700 link, because it is what the build
                  produced.  It is NOT executable: a location the ground Mass
                  Memory Build stamped after linking reads here as its
                  unstamped declaration.

  pure-<cfg>.fcm  AS-DUMPED.  What the machine actually held.  This is the
                  base for corrected-<cfg>.fcm, which exists to be executed.

#PFCMGPT is the case that forced the split.  FCMGPT.hal declares it
INITIAL(16#(4#0)) and INITIAL(1029#0), so its LM value is zero at all 1093
halfwords, while its MM value is the live phase table -- the descriptors
FCMMGBOV indexes to locate an overlay phase on mass memory.  Building an
executable image on the as-built one erases the table.  Corpus-wide, 13297
halfwords have LM=0000 with a non-zero MM, 7502 of them in #PFCMGPT.

THIS IS ALSO A REGRESSION CHECK.  The as-built path through unlinkMAFGEN2 is
supposed to be untouched by the addition of the pure one, so a freshly
extracted <cfg>.fcm must be byte-identical to the committed one.  If it is
not, that is reported and the file is NOT overwritten unless --force is given:
a silent change to the primary comparison artefact would invalidate every
score taken against it.  csectTable.json is checked against the committed
csects-<cfg>.json for the same reason, and never written.

    --check     report what would change; write nothing
    --force     install <cfg>.fcm even if it differs from the committed one
    --keep=DIR  keep the raw unlinkMAFGEN2 output under DIR instead of a
                temporary directory, for inspection
"""

import filecmp
import json
import os
import shutil
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))

from dasspfs import mafgenDir, pfsDir                            # noqa: E402

# The listing filenames are not uniform: SSW carries a parenthesised note.
# Keep the mapping explicit rather than globbing, so a missing listing is an
# error naming the configuration rather than a silently shorter run.
LISTINGS = {
    "G16": "DASS_G16.ASC",
    "G2": "DASS_G2.ASC",
    "G3": "DASS_G3.ASC",
    "G8": "DASS_G8.ASC",
    "G9": "DASS_G9.ASC",
    "P9": "DASS_P9.ASC",
    "S2": "DASS_S2.ASC",
    "SSW": "DASS_SSW_(PostIPL).ASC",
}


def extract(cfg, listing, workDir):
    """Run unlinkMAFGEN2.py for one configuration; return its results dir.

    The extractor rejects a --results containing a separator and creates the
    directory beside the working one, so it is run WITH cwd set rather than
    handed a path.
    """
    tool = os.path.join(pfsDir(), "unlinkMAFGEN2.py")
    if not os.path.exists(tool):
        sys.exit("cannot find %s" % tool)
    proc = subprocess.run(
        [sys.executable, tool, "--mafgen=%s" % listing, "--results=%s" % cfg],
        cwd=workDir, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if proc.returncode != 0:
        sys.stdout.write(proc.stdout.decode("utf-8", "replace"))
        sys.exit("%s: unlinkMAFGEN2.py failed (%d)" % (cfg, proc.returncode))
    return os.path.join(workDir, cfg)


def install(src, dst, check, label):
    """Copy src over dst, reporting what happened.  Returns True if it wrote."""
    if not os.path.exists(src):
        sys.exit("   %s: %s was not produced" % (label, os.path.basename(src)))
    same = os.path.exists(dst) and filecmp.cmp(src, dst, shallow=False)
    if same:
        print("   %-16s unchanged" % label)
        return False
    if check:
        what = "would be updated" if os.path.exists(dst) else "would be created"
        print("   %-16s %s" % (label, what))
        return False
    shutil.copyfile(src, dst)
    print("   %-16s %s" % (label, "updated" if os.path.exists(dst) else "created"))
    return True


def main():
    args = sys.argv[1:]
    check = "--check" in args
    force = "--force" in args
    keep = None
    for a in list(args):
        if a.startswith("--keep="):
            keep = os.path.abspath(os.path.expanduser(a[7:]))
            args.remove(a)
    configs = [a for a in args if not a.startswith("-")]
    unknown = [c for c in configs if c not in LISTINGS]
    if unknown:
        sys.exit("unknown configuration(s): %s" % ", ".join(unknown))
    if not configs:
        configs = sorted(LISTINGS)

    M = mafgenDir()
    workDir = keep or tempfile.mkdtemp(prefix="dass-unlink.")
    if keep:
        os.makedirs(workDir, exist_ok=True)
    problems = []
    try:
        for cfg in configs:
            listing = os.path.join(M, LISTINGS[cfg])
            if not os.path.exists(listing):
                sys.exit("%s: %s is missing" % (cfg, listing))
            print("%s:" % cfg)
            res = extract(cfg, listing, workDir)

            # The as-dumped image is new, so it simply installs.
            install(os.path.join(res, "pureMemory.fcm"),
                    os.path.join(M, "pure-%s.fcm" % cfg), check,
                    "pure-%s.fcm" % cfg)

            # The as-built one is the primary comparison artefact.  A change
            # here means the extractor's as-built path moved, which is a
            # result in itself and must not happen quietly.
            newBuilt = os.path.join(res, "memory.fcm")
            oldBuilt = os.path.join(M, "%s.fcm" % cfg)
            if os.path.exists(oldBuilt) and not filecmp.cmp(newBuilt, oldBuilt,
                                                            shallow=False):
                if force:
                    install(newBuilt, oldBuilt, check, "%s.fcm" % cfg)
                    problems.append("%s.fcm CHANGED (installed under --force)"
                                    % cfg)
                else:
                    print("   %-16s DIFFERS from the committed image -- NOT "
                          "written" % ("%s.fcm" % cfg))
                    problems.append("%s.fcm differs from the committed image"
                                    % cfg)
            else:
                install(newBuilt, oldBuilt, check, "%s.fcm" % cfg)

            # Checked, never written: the CSECT index is committed and other
            # tools key off it.
            newTable = os.path.join(res, "csectTable.json")
            oldTable = os.path.join(M, "csects-%s.json" % cfg)
            if os.path.exists(newTable) and os.path.exists(oldTable):
                a = json.load(open(newTable))
                b = json.load(open(oldTable))
                if a == b:
                    print("   %-16s matches" % ("csects-%s.json" % cfg))
                else:
                    print("   %-16s DIFFERS from the extractor's table"
                          % ("csects-%s.json" % cfg))
                    problems.append("csects-%s.json differs" % cfg)
    finally:
        if not keep:
            shutil.rmtree(workDir, ignore_errors=True)

    if problems:
        print("\n%d problem(s):" % len(problems))
        for p in problems:
            print("   %s" % p)
        return 1
    print("\n%d configuration(s), no discrepancies." % len(configs))
    return 0


if __name__ == "__main__":
    sys.exit(main())
