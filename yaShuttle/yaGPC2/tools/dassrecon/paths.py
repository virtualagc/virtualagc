"""Where the reconstruction tools find things.  Every path can be overridden
from the environment.

    DASSRECON_PFS    the PFS repository (default ~/workspace/PFS): the dumps in
                     mafgen/ are read, and results are written to OI340700/
    DASSRECON_TREE   a SCRATCH compile tree -- a copy of a tapebuild source
                     tree after stage 2 (APPLSRC SSSRC INCL80 INCLIB MLIB80
                     SDFLIB TEMPLIB and the two .json indexes), with an empty
                     objects/.  Units are compiled here, never in PFS.
    DASSRECON_SDL    the toolchain's src/ (ap101Utils), for Z-CON relocation
"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
PFS = os.environ.get("DASSRECON_PFS", os.path.expanduser("~/workspace/PFS"))
MAFGEN = os.path.join(PFS, "mafgen") + "/"
TREE = os.environ.get("DASSRECON_TREE", "/tmp/claude-1000/smfix/tree")
SDL = os.environ.get("DASSRECON_SDL", "/tmp/claude-1000/tapebuild/nsts-sdl-dps/src")
WORK = os.path.dirname(TREE)
