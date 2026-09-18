#!/usr/bin/env python3
"""Does --dump-state survive --state?  Dump, load, dump again, diff.

    state_roundtrip.py <state.json> <memory.mem.bin> [--yagpc PATH]

A capture is only worth taking if it can be read back.  The failure this
catches is silent in every other way: a field that is dumped but not loaded,
or loaded into the wrong type, restores a machine that runs perfectly and
is not the machine that was captured.  One was found exactly that way --
msc.failDiscSeen is a WORD, one bit per fail discrete already noticed, and
it was being written as "true"/"false", which would have restored "some bit
was set" as "bit 31 was set".

HOW IT WORKS.  The second run loads the state and is captured by
YAGPC_DUMPSTATE_AT=0, which fires at step 0 -- before a single instruction
executes -- so the second file is the loaded state undisturbed and any
difference is a round-trip fault rather than the machine moving on.

WHY IT REPORTS COVERAGE.  A dump of a machine that never ran is nearly all
zeros, and zeros round-trip perfectly whether the code is right or wrong: an
early version of this passed with 0 differences while testing almost none of
the fields it was written for.  So it prints how much of the input was
non-zero and FAILS a run whose input is too empty to mean anything.  Capture
with YAGPC_DUMPSTATE_BUSY=<bce>,<afterSec> to catch a machine mid-transfer,
which is where the interesting state lives.
"""
import argparse, json, os, subprocess, sys, tempfile

# Not compared.  "protect" is a file name that changes with the prefix, and
# capturedAtUs is the capture's own clock -- it is dumped as informational
# and deliberately not restored (see ageharness.c).
SKIP = {"protect", "capturedAtUs"}

# Below this, the input is too empty for a clean result to mean anything.
MIN_NONZERO_FRACTION = 0.15


def leaves(x, path=""):
    if isinstance(x, dict):
        for k in sorted(x):
            if k in SKIP:
                continue
            yield from leaves(x[k], path + "/" + k)
    elif isinstance(x, list):
        for i, v in enumerate(x):
            yield from leaves(v, "%s[%d]" % (path, i))
    else:
        yield path, x


def nonzero(v):
    if isinstance(v, bool):
        return v
    if isinstance(v, str):
        return bool(set(v) - {"0"})
    if isinstance(v, (int, float)):
        return v != 0
    return v is not None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("state")
    ap.add_argument("memory")
    ap.add_argument("--yagpc", default=os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "..", "yaGPC2"))
    args = ap.parse_args()

    a = json.load(open(args.state))
    la = dict(leaves(a))
    nz = sum(1 for v in la.values() if nonzero(v))
    frac = nz / len(la) if la else 0.0
    print("input: %d leaf fields, %d non-zero (%.1f%%)" % (len(la), nz, 100 * frac))

    with tempfile.TemporaryDirectory() as td:
        pfx = os.path.join(td, "B")
        env = dict(os.environ, YAGPC_DUMPSTATE_AT="0")
        r = subprocess.run(
            [args.yagpc, "run", args.memory, "--state", args.state,
             "--gpc-id", "1", "--no-halucp-svc", "--max-steps", "1",
             "--dump-state", pfx],
            env=env, capture_output=True, text=True, timeout=300)
        out = [f for f in os.listdir(td) if f.endswith("-0.json")]
        if not out:
            print("FAIL: the reload wrote no capture\n" + r.stderr[-2000:])
            return 1
        b = json.load(open(os.path.join(td, out[0])))

    lb = dict(leaves(b))
    diffs = [(k, la[k], lb.get(k, "<absent>"))
             for k in la if k not in lb or la[k] != lb[k]]
    gone = [k for k in la if k not in lb]
    extra = [k for k in lb if k not in la]

    for k, u, v in diffs[:40]:
        print("  %-46s %s -> %s" % (k, u, v))
    if len(diffs) > 40:
        print("  ... and %d more" % (len(diffs) - 40))
    if gone:
        print("  fields the reload did not write: %s" % gone[:10])
    if extra:
        print("  fields only the reload wrote: %s" % extra[:10])

    ok = True
    if frac < MIN_NONZERO_FRACTION:
        print("FAIL: input is %.1f%% non-zero, under the %.0f%% floor -- a clean "
              "result here would prove nothing.  Capture with "
              "YAGPC_DUMPSTATE_BUSY to catch a machine mid-transfer."
              % (100 * frac, 100 * MIN_NONZERO_FRACTION))
        ok = False
    if diffs:
        print("FAIL: %d of %d fields did not survive the round trip"
              % (len(diffs), len(la)))
        ok = False
    if ok:
        print("PASS: all %d fields survived, %d of them non-zero" % (len(la), nz))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
