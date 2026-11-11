#!/usr/bin/env python3
"""THE SNAPSHOT SET AS ONE ENCRYPTED ARCHIVE: index it, pack it, verify a download, take one snapshot out.

    snapshot_bundle.py index  ROOT... [-o snapshot-index.json]
    snapshot_bundle.py pack   ARCHIVE.7z ROOT... [--index snapshot-index.json]       (the OWNER runs this: it asks for the password)
    snapshot_bundle.py verify ARCHIVE.7z [MANIFEST.json]
    snapshot_bundle.py list   [snapshot-index.json]
    snapshot_bundle.py extract ARCHIVE.7z NAME... [--to DIR] [--index snapshot-index.json]

A snapshot is a directory holding vehicle.json and gpc1.json -- it holds the flight computer's memory image, so it is
flight software and is shipped only inside the encrypted archive (7z, AES-256, headers encrypted, as the OI340700-OPS*.7z
tapes are).  The archive is published beside two PLAIN files, which hold nothing of the memory images:

  snapshot-index.json    one row per snapshot: name, set (the run directory it came from), GMT, MET, the tape digests it
                         runs with, size, and the NEXT snapshot of its set (what the run did next).  `list` prints it.
  snapshot-bundle.json   the manifest: the archive's size and sha256 and how many snapshots it holds.  `verify` checks a
                         downloaded archive against it WITHOUT the password, so a truncated download is told from a
                         wrong password.

Names are "SET/NAME" (e.g. ST4-rndz-dock-T1no136/sts134r-dock), unique across the archive.  `extract` unpacks the named
snapshots to DIR/SET/NAME, ready for simulatePASS --snapshot-resume.

The password is read from the terminal (hidden), never from the command line, and is piped to 7z's own prompt; for the
unattended `extract` it may come from $YAGPC_TAPE_PASSWORD, as for the tapes.  `pack` accepts $YAGPC_BUNDLE_PASSWORD
only so that the tool can be tested with a dummy.
"""
import argparse
import datetime
import getpass
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile

MANIFEST = "snapshot-bundle.json"
INDEX = "snapshot-index.json"
J2011 = datetime.datetime(2011, 1, 1, tzinfo=datetime.timezone.utc)


def sevenz():
    exe = shutil.which("7z") or shutil.which("7za") or shutil.which("7zz")
    if not exe:
        sys.exit("snapshot_bundle: no 7z on the PATH")
    return exe


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def gmt_text(unix):
    t = datetime.datetime.fromtimestamp(unix, datetime.timezone.utc)
    d = (t - J2011).total_seconds()
    day = int(d // 86400) + 1
    s = d - (day - 1) * 86400
    return "%03d/%02d:%02d:%06.3f" % (day, s // 3600, (s % 3600) // 60, s % 60)


def met_text(sec):
    sign = "-" if sec < 0 else ""
    sec = abs(sec)
    return "%s%03d/%02d:%02d:%04.1f" % (sign, sec // 86400, (sec % 86400) // 3600, (sec % 3600) // 60, sec % 60)


def snapshots_under(root):
    """Snapshot directories in or under ROOT, in path order."""
    root = os.path.abspath(root)
    found = []
    for dp, dn, fn in os.walk(root):
        if "vehicle.json" in fn and "gpc1.json" in fn:
            found.append(dp)
            dn[:] = []
    return sorted(found)


def tree_size(path):
    return sum(os.path.getsize(os.path.join(d, f)) for d, _, fs in os.walk(path) for f in fs)


def describe(snap, setname):
    v = json.load(open(os.path.join(snap, "vehicle.json")))
    try:
        c = json.load(open(os.path.join(snap, "capture.json")))
    except (OSError, ValueError):
        c = {}
    row = {"name": "%s/%s" % (setname, os.path.basename(snap)), "set": setname, "taken": v.get("taken"),
           "tape": os.path.basename(v.get("tape") or ""), "tapeSha256": v.get("tapeSha256"),
           "tapeSha256Also": v.get("tapeSha256Also") or [], "bytes": tree_size(snap)}
    g = c.get("gmtUnix")
    if g is not None:
        row["gmt"] = gmt_text(g)
        row["gmtUnix"] = g
        if v.get("metEpoch") is not None:
            row["met"] = met_text(g - v["metEpoch"])
    return row


def build_index(roots):
    """(rows, {name: directory}); `set` is the name of the directory the snapshot sits in."""
    rows, where = [], {}
    for root in roots:
        root = os.path.abspath(root)
        for snap in snapshots_under(root):
            setname = os.path.basename(os.path.dirname(snap))
            row = describe(snap, setname)
            if row["name"] in where:
                sys.exit("snapshot_bundle: %s appears twice (%s and %s)" % (row["name"], where[row["name"]], snap))
            rows.append(row)
            where[row["name"]] = snap
    sets = {}
    for r in rows:
        sets.setdefault(r["set"], []).append(r)
    for rs in sets.values():
        rs.sort(key=lambda r: (r.get("gmtUnix") is None, r.get("gmtUnix") or 0, r["name"]))
        for a, b in zip(rs, rs[1:]):
            a["next"] = b["name"]
    rows.sort(key=lambda r: (r["set"], r.get("gmtUnix") is None, r.get("gmtUnix") or 0, r["name"]))
    return rows, where


def read_password(confirm):
    pw = os.environ.get("YAGPC_BUNDLE_PASSWORD" if confirm else "YAGPC_TAPE_PASSWORD")
    if pw:
        return pw
    pw = getpass.getpass("archive password: ")
    if confirm and getpass.getpass("again: ") != pw:
        sys.exit("snapshot_bundle: the two entries differ")
    return pw


def cmd_index(a):
    rows, _ = build_index(a.roots)
    json.dump({"snapshots": rows}, open(a.o, "w"), indent=1)
    print("%d snapshot(s) in %d set(s) -> %s" % (len(rows), len({r["set"] for r in rows}), a.o))


def cmd_pack(a):
    rows, where = build_index(a.roots)
    if not rows:
        sys.exit("snapshot_bundle: no snapshots under %s" % " ".join(a.roots))
    pw = read_password(True)
    out = os.path.abspath(a.archive)
    if os.path.exists(out):
        sys.exit("snapshot_bundle: %s exists; it is not overwritten" % out)
    with tempfile.TemporaryDirectory() as stage:
        for name, src in where.items():
            dst = os.path.join(stage, name)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copytree(src, dst)
        json.dump({"snapshots": rows}, open(os.path.join(stage, INDEX), "w"), indent=1)
        # `-p` with no value makes 7z prompt on its stdin, so the password is never on a command line.
        r = subprocess.run([sevenz(), "a", "-t7z", "-mx=9", "-mhe=on", "-p", "-bso0", "-bsp0", out, "."], cwd=stage,
                           input=(pw + "\n" + pw + "\n").encode(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if r.returncode != 0:
            sys.exit("snapshot_bundle: 7z failed:\n" + r.stderr.decode(errors="replace")[-600:])
    index_out = a.index or os.path.join(os.path.dirname(out), INDEX)
    json.dump({"snapshots": rows}, open(index_out, "w"), indent=1)
    man = {"archive": os.path.basename(out), "bytes": os.path.getsize(out), "sha256": sha256_file(out),
           "snapshots": len(rows), "sets": sorted({r["set"] for r in rows})}
    mp = os.path.join(os.path.dirname(out), MANIFEST)
    json.dump(man, open(mp, "w"), indent=1)
    print("%s: %d snapshot(s), %d bytes, sha256 %s" % (out, len(rows), man["bytes"], man["sha256"]))
    print("also written (publish beside the archive; they hold no memory): %s, %s" % (index_out, mp))


def cmd_verify(a):
    mp = a.manifest or os.path.join(os.path.dirname(os.path.abspath(a.archive)), MANIFEST)
    man = json.load(open(mp))
    size = os.path.getsize(a.archive)
    if size != man["bytes"]:
        sys.exit("snapshot_bundle: %s is %d bytes, the manifest says %d -- an incomplete download?" % (a.archive, size, man["bytes"]))
    sha = sha256_file(a.archive)
    if sha != man["sha256"]:
        sys.exit("snapshot_bundle: sha256 %s is not the manifest's %s" % (sha, man["sha256"]))
    print("ok: %s, %d bytes, sha256 %s..., %d snapshot(s)" % (os.path.basename(a.archive), size, sha[:12], man["snapshots"]))


def cmd_list(a):
    rows = json.load(open(a.index or INDEX))["snapshots"]
    print("%-52s %-15s %-13s %s" % ("snapshot", "GMT", "MET", "next"))
    for r in rows:
        print("%-52s %-15s %-13s %s" % (r["name"], r.get("gmt", "-"), r.get("met", "-"), r.get("next", "")))


def cmd_extract(a):
    pw = read_password(False)
    os.makedirs(a.to, exist_ok=True)
    for name in a.names:
        r = subprocess.run([sevenz(), "x", "-y", "-bso0", "-bsp0", "-o" + a.to, a.archive, name + "/*"],
                           input=(pw + "\n").encode(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if r.returncode != 0 or not os.path.isfile(os.path.join(a.to, name, "vehicle.json")):
            sys.exit("snapshot_bundle: could not extract %s -- wrong password, or no such snapshot (`list`)\n%s"
                     % (name, r.stderr.decode(errors="replace")[-300:]))
        print("%s/%s" % (a.to, name))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("index")
    p.add_argument("roots", nargs="+")
    p.add_argument("-o", default=INDEX)
    p.set_defaults(f=cmd_index)
    p = sub.add_parser("pack")
    p.add_argument("archive")
    p.add_argument("roots", nargs="+")
    p.add_argument("--index")
    p.set_defaults(f=cmd_pack)
    p = sub.add_parser("verify")
    p.add_argument("archive")
    p.add_argument("manifest", nargs="?")
    p.set_defaults(f=cmd_verify)
    p = sub.add_parser("list")
    p.add_argument("index", nargs="?")
    p.set_defaults(f=cmd_list)
    p = sub.add_parser("extract")
    p.add_argument("archive")
    p.add_argument("names", nargs="+")
    p.add_argument("--to", default="snapshots")
    p.add_argument("--index")
    p.set_defaults(f=cmd_extract)
    a = ap.parse_args()
    a.f(a)


if __name__ == "__main__":
    main()
