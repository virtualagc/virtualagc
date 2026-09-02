#!/usr/bin/env python3
"""Pretty-print JSON from stdin or a file, so single-line documents are
readable with ordinary text tools.

    tools/jsonpp.py < augmented-G9.json | less
    tools/jsonpp.py augmented-G9.json --keys          # top-level keys only
    tools/jsonpp.py augmented-G9.json --schema        # shape, not contents
    tools/jsonpp.py augmented-G9.json --get FIOERRLC  # one entry

The mafgen augmented-*.json files are a single line of several hundred KB,
which grep and head cannot usefully cut up: a match prints the whole file.
Written because that came up repeatedly rather than as a general utility."""

import argparse, collections, json, sys


def schema(o, depth=0, maxdepth=3):
    if depth > maxdepth:
        return "..."
    if isinstance(o, dict):
        if not o:
            return "{}"
        k = next(iter(o))
        return {"<%d keys, e.g. %r>" % (len(o), k): schema(o[k], depth + 1, maxdepth)}
    if isinstance(o, list):
        return ["<%d items>" % len(o)] + ([schema(o[0], depth + 1, maxdepth)] if o else [])
    return type(o).__name__


def main():
    ap = argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("file", nargs="?", help="default: stdin")
    ap.add_argument("--keys", action="store_true", help="top-level keys only")
    ap.add_argument("--schema", action="store_true", help="shape, not contents")
    ap.add_argument("--get", action="append", help="print just these keys")
    ap.add_argument("--count-by", help="tally top-level entries by this field")
    a = ap.parse_args()

    d = json.load(open(a.file) if a.file else sys.stdin)

    if a.keys:
        ks = list(d) if isinstance(d, dict) else range(len(d))
        print("%d entries" % len(ks))
        for k in ks:
            print(" ", k)
    elif a.schema:
        print(json.dumps(schema(d), indent=2))
    elif a.count_by:
        c = collections.Counter(v.get(a.count_by) if isinstance(v, dict) else None
                                for v in (d.values() if isinstance(d, dict) else d))
        for k, n in c.most_common():
            print("%8d  %s" % (n, k))
    elif a.get:
        for k in a.get:
            print("%s: %s" % (k, json.dumps(d.get(k), indent=2)))
    else:
        print(json.dumps(d, indent=2))


if __name__ == "__main__":
    main()
