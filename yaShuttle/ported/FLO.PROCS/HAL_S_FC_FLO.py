#!/usr/bin/env python3
'''
Access:     Public Domain, no restrictions believed to exist.
Filename:   HAL_S_FC_FLO.py
Purpose:    Part of the HAL/S-FC compiler's HALMAT optimization
            process.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-11-18 RSB  Ported from ##DRIVER XPL
'''

#####################################################################
# Every port from ##DRIVER.xpl needs the following, in order for all
# of them to use the same xplBuiltins.py and HALINCL/ without conflict.
import os
import pathlib
import shutil
scriptFolder = os.path.dirname(__file__)
scriptParentFolder = str(pathlib.Path(scriptFolder).parent.absolute())
shutil.copyfile(scriptParentFolder + "/xplBuiltins.py", \
                scriptFolder + "/xplBuiltins.py")
shutil.rmtree(scriptFolder + "/HALINCL", ignore_errors=True)
shutil.copytree(scriptParentFolder + "/HALINCL", \
                scriptFolder + "/HALINCL")
#####################################################################

from HALINCL.SPACELIB import RECORD_SEAL, RECORD_LINK
import g
from DUMPALL  import DUMP_ALL
from DUMPSTMT import DUMP_STMT
from INITIALI import INITIALIZE
from PROCESSH import PROCESS_HALMAT
from SORTVPTR import SORT_VPTRS

#####################################################################
# This stuff handles for us what DD cards in JCL did originally.
# I.e., it opens the files we need.  We don't have to do it if just
# printing the --help message.  Note that we don't need to handle the
# random-access files FILE1 through FILE6, nor the system printer
# OUTPUT, since xplBuiltins.py hard-codes those.
import sys

if "--help" not in sys.argv:
    # I'm not certain what additional files are needed by FLO.  TBD
    pass

####################################################################

#*************************************************************************
# PROCEDURE NAME:  MAIN PROGRAM
# MEMBER NAME:     ##DRIVER
# PURPOSE:         THE DRIVER PROGRAM FOR A PHASE OF THE COMPILER.
#                  THIS MEMBER IS THE MAIN PROGRAM, THE OTHER MEMBERS
#                  SHOULD BE CHECKED FOR HEADER INFORMATION.
# LOCAL DECLARATIONS:
# EXTERNAL VARIABLES REFERENCED:
# EXTERNAL VARIABLES CHANGED:
# CALLED BY:
#*************************************************************************

INITIALIZE();
PROCESS_HALMAT();
SORT_VPTRS();
if g.HALMAT_DUMP and g.HMAT_OPT:
    DUMP_STMT_HALMAT();
if g.VMEM_DUMP:
    DUMP_ALL(g.FORMATTED_DUMP);
if g.DONT_LINK:
    sys.exit(0);
else: # DO;
   RECORD_SEAL(h.SYM_ADD);
   RECORD_LINK();
# END;

# The BOMB_OUT: and NO_CORE: labels here formerly are now standalone
# subroutines of the same name.
