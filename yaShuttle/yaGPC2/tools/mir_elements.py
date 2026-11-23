#!/usr/bin/env python3
"""Mir's element sets from the planet4589.org archive, as TLEs and as a target line.

    tools/mir_elements.py S16609.txt --list 1997-01-12 1997-01-16
    tools/mir_elements.py S16609.txt --before 1997-01-15T03:19:25 [--tle]
    tools/mir_elements.py S16609.txt --before 1997-01-15T03:19:25 --at 1997-01-15T01:13:54
                          [--bc KG_PER_M2] [--port X,Y,Z] >> targets.txt

S16609.txt is Jonathan McDowell's historical element-set archive for Mir (NORAD
16609, 1986-017A): three lines per record, the first two an ordinary TLE and the
third a source tag ("3 16609 1 NOR  SGP4 TEME UTC Earth  gb/GB970110.ELM").  The
archive's formatting is not clean (fields such as "+.00002762" or "051.6501", and
the last records hand-made with another epoch format), so every set is parsed
and then checked by SGP4 itself; a set that fails either is counted and skipped,
never repaired.

Which set to use matters.  After docking the stack's drag changes at once (the
ndot jumps), so a set from after docking propagates the pre-docking Mir wrongly
by 8 to 11 km: --before names the instant (UTC) the chosen set must precede, and
for rendezvous planning that is the capture, never later.  Without --before the
set nearest --at is used, whichever side of it.

--tle prints the chosen set as two TLE lines.  --at (default: the set's own
epoch) prints the target line tools/tle_target.py makes from it -- the state by
SGP4 in GCRS, lvlh attitude, the same format the ISS's targets use -- and
--bc and --port pass through to it.  Mir's ballistic coefficient and docking
port are NOT sourced here: the default 130 kg/m^2 is the ISS's, and the Docking
Module's APAS face in the model frame is step 4 of HANDOFF-MIR-STS81.md.
"""
import argparse
import datetime
import os
import subprocess
import sys


def epoch_of(line1):
    """The set's epoch as a UTC datetime, from columns 19-32 (yyddd.dddddddd)."""
    f = line1[18:32].strip()
    yy = int(f[:2])
    day = float(f[2:])
    year = 2000 + yy if yy < 57 else 1900 + yy
    return (datetime.datetime(year, 1, 1, tzinfo=datetime.timezone.utc)
            + datetime.timedelta(days=day - 1))


def read_sets(path):
    """[(epoch, line1, line2, source_tag)] for every record SGP4 accepts, and the
    number of records dropped."""
    from sgp4.api import Satrec
    lines = [ln.rstrip("\n") for ln in open(path, errors="replace")]
    out, bad = [], 0
    i = 0
    while i < len(lines) - 1:
        if lines[i].startswith("1 ") and lines[i + 1].startswith("2 "):
            l1, l2 = lines[i], lines[i + 1]
            has3 = i + 2 < len(lines) and lines[i + 2].startswith("3 ")
            tag = lines[i + 2].split()[-1] if has3 else ""
            i += 3 if has3 else 2
            try:
                sat = Satrec.twoline2rv(l1, l2)
                if sat.error:
                    raise ValueError
                out.append((epoch_of(l1), l1, l2, tag))
            except Exception:
                bad += 1
        else:
            i += 1
    return out, bad


def when(s):
    d = datetime.datetime.fromisoformat(s)
    return d if d.tzinfo else d.replace(tzinfo=datetime.timezone.utc)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("archive")
    ap.add_argument("--list", nargs=2, metavar=("FROM", "TO"),
                    help="list the sets with epochs in [FROM, TO] (UTC, ISO 8601)")
    ap.add_argument("--before", help="use the last set whose epoch is at or before this instant")
    ap.add_argument("--at", help="the instant for the target line (default: the set's epoch)")
    ap.add_argument("--tle", action="store_true", help="print the chosen set's two TLE lines")
    ap.add_argument("--bc", help="ballistic coefficient, kg/m^2 (passed to tle_target.py)")
    ap.add_argument("--port", help="X,Y,Z docking port, body metres (passed to tle_target.py)")
    args = ap.parse_args()
    try:
        sets, bad = read_sets(args.archive)
    except ImportError:
        sys.exit("mir_elements: pip install sgp4")
    if not sets:
        sys.exit("mir_elements: no usable element sets in %s" % args.archive)
    sets.sort(key=lambda s: s[0])
    if args.list:
        a, b = when(args.list[0]), when(args.list[1])
        for e, l1, l2, tag in sets:
            if a <= e <= b:
                print("%s  %s  %s" % (e.strftime("%Y-%m-%dT%H:%M:%S"), l1[18:32], tag))
        print("# %d usable sets in the archive, %d records dropped" % (len(sets), bad), file=sys.stderr)
        return
    if args.before:
        t = when(args.before)
        cand = [s for s in sets if s[0] <= t]
        if not cand:
            sys.exit("mir_elements: no set at or before %s" % args.before)
        chosen = cand[-1]
    elif args.at:
        t = when(args.at)
        chosen = min(sets, key=lambda s: abs((s[0] - t).total_seconds()))
    else:
        sys.exit("mir_elements: give --before or --at (or --list)")
    e, l1, l2, tag = chosen
    if args.tle or not (args.at or args.before):
        print("MIR\n%s\n%s" % (l1, l2))
        return
    if args.tle:
        return
    # a target line, by tle_target.py, from exactly this set
    import tempfile
    with tempfile.NamedTemporaryFile("w", suffix=".tle", delete=False) as f:
        f.write("MIR\n%s\n%s\n" % (l1, l2))
        name = f.name
    try:
        cmd = [sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), "tle_target.py"), name,
               "--at", (args.at or e.strftime("%Y-%m-%dT%H:%M:%S"))]
        if args.bc:
            cmd += ["--bc", args.bc]
        if args.port:
            cmd += ["--port", args.port]
        r = subprocess.run(cmd, capture_output=True, text=True)
    finally:
        os.unlink(name)
    sys.stderr.write(r.stderr)
    if r.returncode:
        sys.exit(r.returncode)
    print("# Mir element set epoch %s (%s), archive %s" % (e.strftime("%Y-%m-%dT%H:%M:%S"), tag or "no source tag",
                                                          os.path.basename(args.archive)))
    sys.stdout.write(r.stdout)


if __name__ == "__main__":
    main()
