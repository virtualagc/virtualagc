#!/usr/bin/env python3
"""Where the PFS data is.

The code lives here, in virtualagc, because that is what every user clones and
what the web instructions can refer to.  The data it reads -- mafgen/, the
DASS_*.ASC listings, the CSECT indexes, the exceptions files -- lives in the
PFS repository, which is restricted.  The two are not co-located.

That costs nothing, because the usage instructions tell the reader to change
to the PFS directory first and these scripts are on the PATH.  The working
directory is therefore the answer, and looking beside the script -- what these
did when they lived in the PFS root -- is only a fallback for that older
layout.

Resolution order:

    $PFS                       an explicit override wins
    the working directory      if it holds a mafgen/, which is what the
                               instructions arrange
    beside this file           the old PFS-root layout
    ~/workspace/PFS            the customary clone

`pfsDir()` returns the directory, `mafgenDir()` its mafgen/.  Neither checks
that a particular file is present: the caller's own open() reports a missing
one better than a guess here would.
"""

import os

_ENV = "PFS"
_DEFAULT = "~/workspace/PFS"


def pfsDir():
    """The PFS repository root."""
    p = os.environ.get(_ENV)
    if p:
        return os.path.expanduser(p)
    if os.path.isdir("mafgen"):
        return os.path.abspath(".")
    # realpath, not abspath: reached through a ~/bin symlink, abspath would
    # answer ~/bin and this fallback would look for ~/bin/mafgen.
    here = os.path.dirname(os.path.realpath(__file__))
    if os.path.isdir(os.path.join(here, "mafgen")):
        return here
    return os.path.expanduser(_DEFAULT)


def mafgenDir():
    """The mafgen/ directory holding the dumps, indexes and exceptions."""
    return os.path.join(pfsDir(), "mafgen")


if __name__ == "__main__":
    print(pfsDir())
