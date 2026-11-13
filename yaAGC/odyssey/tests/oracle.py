#!/usr/bin/env python3
"""Independent test oracles for the ODYSSEY integration tests.

IMPORTANT: this file is TEST CODE ONLY.  It computes what the AGC program is
EXPECTED to emit so the tests can compare it with what the AGC actually wrote.
It is never used to produce audio.  The host (C code) contains no oscillator.

usage:
  oracle.py phase  CSV STEP_OCT          check PHASE-* output against a model
  oracle.py timing CSV                   print inter-sample cycle statistics
  oracle.py seq    CSV w1,w2,...         check an exact word sequence (octal)
"""
import csv
import statistics
import sys


def rows(path):
    with open(path, newline="") as f:
        return list(csv.DictReader(f))


def step14(u, s):
    """Model of the PHASE-* program for a non-negative phase and step.

    The AGC adds in a 16-bit accumulator.  For phase 037700 + step 0100 the sum
    is 040000: the accumulator OVERFLOWS (sign bit S1 = 0 but S2 = 1).  TS then
    stores the overflow-CORRECTED word: sign from S1 (positive), magnitude = the
    low 14 bits.  So the stored phase is (phase + step) mod 2**14: a clean
    unipolar sawtooth 0 .. +16383 that wraps to +0.  (An earlier version of this
    oracle wrongly modelled a mod-32767 wrap into the negative half; the AGC
    output showed that was the oracle's mistake, not the program's.)
    """
    return (u + s) & 0o37777


def check_phase(path, step):
    r = rows(path)
    if not r:
        print("phase: no samples"); return 1
    u = 0
    bad = 0
    for i, row in enumerate(r):
        u = step14(u, step)
        got = int(row["word_octal"], 8)
        if got != u:
            bad += 1
            if bad <= 5:
                print(f"phase: sample {i}: AGC {got:05o} != model {u:05o}")
    seqs = [int(x["seq"]) for x in r]
    if seqs != list(range(len(r))):
        print("phase: sequence numbers are not 0..N-1"); bad += 1
    print(f"phase: {len(r)} samples checked, {bad} mismatches")
    return 1 if bad else 0


def cycles(path):
    return [int(x["cycle"]) for x in rows(path)]


def timing(path):
    c = cycles(path)
    d = [b - a for a, b in zip(c, c[1:])]
    if not d:
        print("timing: need >= 2 samples"); return 1
    if any(x <= 0 for x in d):
        print("timing: NON-MONOTONIC cycle stamps"); return 1
    agc_hz = (1024000 + 6) // 12
    mean = statistics.fmean(d)
    print(f"timing: n={len(c)} mean={mean:.3f} min={min(d)} max={max(d)} "
          f"stdev={statistics.pstdev(d):.3f} cycles/sample; "
          f"mean rate={agc_hz / mean:.1f} Hz (min-period rate "
          f"{agc_hz / min(d):.1f} Hz, max-period rate {agc_hz / max(d):.1f} Hz)")
    return 0


def check_seq(path, words):
    got = [x["word_octal"] for x in rows(path)]
    want = [f"{int(w, 8):05o}" for w in words.split(",")]
    if got != want:
        print(f"seq: MISMATCH\n  got : {got}\n  want: {want}")
        return 1
    print(f"seq: {len(got)} words match exactly")
    return 0


if __name__ == "__main__":
    mode = sys.argv[1]
    if mode == "phase":
        sys.exit(check_phase(sys.argv[2], int(sys.argv[3], 8)))
    if mode == "timing":
        sys.exit(timing(sys.argv[2]))
    if mode == "seq":
        sys.exit(check_seq(sys.argv[2], sys.argv[3]))
    print(__doc__); sys.exit(2)
