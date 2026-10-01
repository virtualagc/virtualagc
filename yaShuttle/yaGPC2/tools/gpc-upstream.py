#!/usr/bin/env python3
"""Which of Don Schmidt's gpc fixes has yaGPC2 not looked at yet?

yaGPC2 descends from Don's JavaScript gpc, and Don keeps fixing it in
ColanderCombo/nsts-sim-gpc.  Many of those fixes are to defects yaGPC2
inherited (ledger #264: MVS, fixed upstream three weeks before we found it
the hard way).  This tool keeps the local checkout current and lists every
upstream emulator commit that has no verdict recorded here yet.

    tools/gpc-upstream.py                   fetch, fast-forward main, list unreviewed
    tools/gpc-upstream.py --offline         no network; one line if any are unreviewed
    tools/gpc-upstream.py show SHA          the commit's message and files
    tools/gpc-upstream.py mark SHA VERDICT "note"

VERDICT is one of:
    ported      yaGPC2 changed to match (name the commit in the note)
    already     yaGPC2 already behaves this way (say where)
    n/a         does not apply: GUI, debugger, packaging, a path yaGPC2 lacks
    open        applies, not yet done (put it in the ledger too)

Verdicts live in tools/gpc-upstream.reviewed, one line per commit, and are
committed with the tree.  `make test` runs --offline at the end, so a backlog
is visible without anyone having to remember to look.

The checkout is ~/donschmidt/nsts-sim-gpc, or $GPC_UPSTREAM.  It is only ever
fast-forwarded, and only when it is on main with no tracked changes; anything
else is reported and left alone.  Where it does not exist (the Mac and Windows
builds) the tool says nothing.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REVIEWED = os.path.join(HERE, "gpc-upstream.reviewed")
REPO = os.environ.get("GPC_UPSTREAM", os.path.expanduser("~/donschmidt/nsts-sim-gpc"))
# The commit the frozen yaGPC fork was taken at; everything after it is new
# to this lineage.  The emulator moved from gpc/ to src/gpc/ in 952826663.
BASE = "3c60088"
PATHS = ["gpc/", "com/", "src/gpc/", "src/com/"]
VERDICTS = ("ported", "already", "n/a", "open")


def git(*args, timeout=60):
    r = subprocess.run(["git", "-C", REPO] + list(args), capture_output=True,
                       text=True, timeout=timeout)
    return r.returncode, r.stdout.strip(), r.stderr.strip()


def reviewed():
    out = {}
    try:
        with open(REVIEWED) as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                sha, verdict, *rest = line.split(None, 2)
                out[sha] = (verdict, rest[0] if rest else "")
    except FileNotFoundError:
        pass
    return out


def known(sha, done):
    return any(sha.startswith(k) or k.startswith(sha) for k in done)


def upstream_commits(ref):
    rc, out, _ = git("log", "--reverse", "--format=%h %cs %s", "%s..%s" % (BASE, ref), "--", *PATHS)
    return [l for l in out.splitlines() if l] if rc == 0 else []


def refresh():
    """Fetch and fast-forward main.  Returns the ref to list from."""
    rc, _, err = git("fetch", "-q", "origin", timeout=30)
    if rc != 0:
        print("gpc-upstream: fetch failed (%s); listing what is local" % err.splitlines()[-1:] )
    _, branch, _ = git("rev-parse", "--abbrev-ref", "HEAD")
    _, dirty, _ = git("status", "--porcelain", "--untracked-files=no")
    if branch == "main" and not dirty:
        rc, _, err = git("merge", "-q", "--ff-only", "origin/main")
        if rc != 0:
            print("gpc-upstream: main does not fast-forward (%s); left alone" % err)
    else:
        print("gpc-upstream: checkout is on %s%s; not fast-forwarded" %
              (branch, " with changes" if dirty else ""))
    return "origin/main"


def main(argv):
    if not os.path.isdir(os.path.join(REPO, ".git")):
        if "--offline" not in argv:
            print("gpc-upstream: no checkout at %s (set GPC_UPSTREAM)" % REPO)
        return 0
    done = reviewed()

    if argv[:1] == ["show"] and len(argv) == 2:
        os.execvp("git", ["git", "-C", REPO, "show", "--stat", "--format=fuller", argv[1], "--", *PATHS])

    if argv[:1] == ["mark"] and len(argv) == 4:
        sha, verdict, note = argv[1:]
        if verdict not in VERDICTS:
            print("verdict must be one of %s" % (VERDICTS,)); return 1
        rc, full, _ = git("rev-parse", "--short=9", sha + "^{commit}")
        if rc != 0:
            print("no commit %s in %s" % (sha, REPO)); return 1
        if known(full, done):
            print("%s already has a verdict: %s" % (full, done[next(k for k in done if full.startswith(k) or k.startswith(full))][0])); return 1
        with open(REVIEWED, "a") as f:
            f.write("%s %s %s\n" % (full, verdict, note))
        print("%s %s" % (full, verdict))
        return 0

    if argv[:1] == ["--offline"]:
        try:
            todo = [c for c in upstream_commits("origin/main") if not known(c.split()[0], done)]
        except Exception:
            return 0
        if todo:
            print("NOTE: %d upstream gpc commit(s) not yet reviewed for yaGPC2 -- tools/gpc-upstream.py" % len(todo))
        return 0

    if argv:
        print(__doc__); return 1

    ref = refresh()
    commits = upstream_commits(ref)
    todo = [c for c in commits if not known(c.split()[0], done)]
    opn = [(k, v[1]) for k, v in done.items() if v[0] == "open"]
    print("%d upstream emulator commit(s) since %s; %d reviewed, %d not" %
          (len(commits), BASE, len(commits) - len(todo), len(todo)))
    for c in todo:
        print("  " + c)
    for k, note in opn:
        print("  OPEN %s %s" % (k, note))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
