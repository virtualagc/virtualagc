#!/usr/bin/env python3
"""WHICH VOLUMES A SNAPSHOT MAY RUN WITH: record them in the snapshot, after checking that they really are alike.

    tools/stamp_snapshots.py --reference TAKEN_WITH.mmv [--also OTHER.mmv ...] [--primary NEW.mmv] [--allow-changed] [--dry-run] SNAPDIR...

simulatePASS refuses a snapshot on any volume but the one it was taken with (vehicle.json "tapeSha256"), because
PASS reads mass memory at every OPS transition and the resident memory is what that volume loaded.  Two cases make
that too strict:

  --also    the same snapshots serving a second volume, e.g. a set taken on the OPS 2-only tier (T1-no136) and used
            on the full tier (T1): the digest of each --also volume goes into vehicle.json "tapeSha256Also", which
            simulatePASS accepts as well as "tapeSha256".
  --primary a volume that replaces the one the snapshots were taken with (the tape was rebuilt): "tapeSha256" and
            "tape" are rewritten and the old digest is dropped, so nothing is regenerated.

NOTHING IS STAMPED ON FAITH.  A snapshot's memory is what the --reference volume loaded, so another volume is alike
only if every block of it that the reference also has reads the same, and it has every block the reference has.  The
blocks are compared (abridge_volume.read_volume; a block absent from a volume reads as zeros).  A volume that differs
is refused, with the block ranges; --allow-changed stamps it anyway, which is --ignore-tape-digest done once and in
the snapshot rather than at every run.  A volume that only ADDS blocks (T1 against T1-no136: the OPS 1/3/6 loads) passes:
the snapshot cannot be holding anything those blocks would have changed in the OPS 2 loads it has.

Volumes may be bare .mmv or an encrypted .7z of one (digested by their contents, as simulatePASS does); the password
is read once, from $YAGPC_TAPE_PASSWORD or a prompt.  A snapshot whose "tapeSha256" is not the --reference's digest
is skipped with a message.
"""
import argparse
import getpass
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import abridge_volume as av                         # noqa: E402

SEVENZ_MAGIC = b"7z\xbc\xaf\x27\x1c"
_pw = None


def password():
    global _pw
    if _pw is None:
        _pw = os.environ.get("YAGPC_TAPE_PASSWORD") or getpass.getpass("volume password: ")
    return _pw


def volume_bytes(path):
    """The contents of a volume, decrypting an archive."""
    with open(path, "rb") as fh:
        magic = fh.read(6)
    if path.lower().endswith(".7z") or magic == SEVENZ_MAGIC:
        exe = shutil.which("7z") or "7z"
        r = subprocess.run([exe, "x", "-so", "--", path], input=(password() + "\n").encode(),
                           stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        if r.returncode != 0:
            sys.exit("stamp_snapshots: %s would not open -- wrong password?" % path)
        return r.stdout
    return Path(path).read_bytes()


def load(path):
    """(sha256, blocks) of a volume."""
    b = volume_bytes(path)
    with tempfile.TemporaryDirectory() as d:
        t = Path(d) / "v.mmv"
        t.write_bytes(b)
        _, _, blocks = av.read_volume(t)
    return hashlib.sha256(b).hexdigest(), blocks


def ranges(ix):
    out, ix = [], sorted(ix)
    s = p = None
    for i in ix:
        if s is None:
            s = p = i
        elif i == p + 1:
            p = i
        else:
            out.append((s, p))
            s = p = i
    if s is not None:
        out.append((s, p))
    return ", ".join("%d" % a if a == b else "%d-%d" % (a, b) for a, b in out[:12]) + (" ..." if len(out) > 12 else "")


def compare(ref, other):
    """(changed, missing, added) block indices of `other` against `ref`; absent reads as zeros."""
    zero = bytes(len(next(iter(ref.values()))))
    changed = [i for i in ref if i in other and ref[i] != other[i]]
    missing = [i for i in ref if i not in other and ref[i] != zero]
    added = [i for i in other if i not in ref]
    return changed, missing, added


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--reference", required=True, help="the volume the snapshots were taken with")
    ap.add_argument("--also", action="append", default=[], metavar="VOL", help="another volume the snapshots may run with")
    ap.add_argument("--primary", metavar="VOL", help="the volume that replaces the one they were taken with")
    ap.add_argument("--allow-changed", action="store_true", help="stamp a volume whose shared blocks differ")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("snapshots", nargs="+", metavar="SNAPDIR")
    a = ap.parse_args()

    ref_sha, ref_blocks = load(a.reference)
    print("reference %s: sha256 %s..., %d blocks" % (os.path.basename(a.reference), ref_sha[:12], len(ref_blocks)))
    targets = [(p, "also") for p in a.also] + ([(a.primary, "primary")] if a.primary else [])
    stamp = {}
    for path, role in targets:
        sha, blocks = load(path)
        changed, missing, added = compare(ref_blocks, blocks)
        print("%-8s %s: sha256 %s..., %d blocks; against the reference %d changed, %d missing (non-zero), %d added"
              % (role, os.path.basename(path), sha[:12], len(blocks), len(changed), len(missing), len(added)))
        if changed:
            print("         changed blocks: %s" % ranges(changed))
        if missing:
            print("         missing blocks: %s" % ranges(missing))
        if (changed or missing) and not a.allow_changed:
            sys.exit("stamp_snapshots: %s is not alike -- the snapshots' memory was loaded from blocks it does not "
                     "read the same; regenerate them, or --allow-changed to stamp anyway" % path)
        stamp[role] = (path, sha) if role == "primary" else stamp.get(role, []) + [(path, sha)]
    done = 0
    for snap in a.snapshots:
        vj = os.path.join(snap, "vehicle.json")
        try:
            v = json.load(open(vj))
        except (OSError, ValueError) as e:
            print("skip %s: no readable vehicle.json (%s)" % (snap, e))
            continue
        if v.get("tapeSha256") != ref_sha:
            print("skip %s: it records sha256 %s..., not the reference's" % (snap, str(v.get("tapeSha256"))[:12]))
            continue
        also = set(v.get("tapeSha256Also") or [])
        also.update(sha for _, sha in stamp.get("also", []))
        if "primary" in stamp:
            path, sha = stamp["primary"]
            v["tapeSha256"] = sha
            v["tape"] = os.path.abspath(path)
            also.discard(sha)
        also.discard(v["tapeSha256"])
        if also:
            v["tapeSha256Also"] = sorted(also)
        else:
            v.pop("tapeSha256Also", None)
        if not a.dry_run:
            json.dump(v, open(vj, "w"), indent=1)
        done += 1
    print("%s %d of %d snapshot(s)" % ("would stamp" if a.dry_run else "stamped", done, len(a.snapshots)))
    if done != len(a.snapshots):
        sys.exit(1)


if __name__ == "__main__":
    main()
