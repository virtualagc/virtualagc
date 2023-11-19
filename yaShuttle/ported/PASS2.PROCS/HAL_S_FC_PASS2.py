#!/usr/bin/env python
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   HAL_S_FC_PASS2.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
               It is PASS2's main program.
   Language:   XPL.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2023-11-16 RSB  Began adapting PASS2.PROCS/##DRIVER.xpl.
"""

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

from xplBuiltins import *
import g
import HALINCL.COMMON as h
from INITIALI import INITIALISE
from PRINTDAT import PRINT_DATE_AND_TIME
from whileGENERATING import whileGENERATING

#####################################################################
# This stuff handles for us what DD cards in JCL did originally.
# I.e., it opens the files we need.  We don't have to do it if just
# printing the --help message.  Note that we don't need to handle the
# random-access files FILE1 through FILE6, nor the system printer
# OUTPUT, since xplBuiltins.py hard-codes those.
import sys

if "--help" not in sys.argv:
    
    # I'm not certain what additional files are needed by PASS 2.  TBD
    
    # As long as we're dealing with files, let's read in the files
    # that PASS 1 wrote out to contain data which the XPL version
    # of the compiler originally communicated from PASS 1 to PASS 2
    # in memory.
    h.SYM_TAB = loadClassArray(h.sym_tab, "SYM_TAB.json")
    h.CROSS_REF = loadClassArray(h.cross_ref, "CROSS_REF.json")

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

#  START OF THE MAIN PROGRAM
CLOCK = MONITOR(18);
OUTPUT(1, '1');
PRINT_DATE_AND_TIME('   HAL/S COMPILER PHASE 2  --  VERSION OF ', \
                    g.DATE_OF_GENERATION, g.TIME_OF_GENERATION);
OUTPUT(0, '')
PRINT_DATE_AND_TIME('HAL/S PHASE 2 ENTERED ', DATE(), TIME());
OUTPUT(0, '')
INITIALISE();
g.CLOCK[1] = MONITOR(18);
g.GENERATING = g.TRUE;

'''
What's going on below requires some explanation.  What I call
whileGENERATING() was originally inline code here in the XPL version.
The problem was that it was possible for the subroutines used by this
inline code to call the ERRORS() function, which in turn would try to
"GO TO SRCERR" (which was a label in the inline code), and SRCERR would
try to "GO TO RESTART" (which was yet another label in the inline code, 
this time in the middle of a while-loop).  This is a much trickier 
problem than we encountered in PASS1, or in some other GO TO's here, in
that those *other* GO TO's led to program aborts, so that we could 
easily implement them as subroutines that abended.  But that's  
not possible here, because the GO TO SRCERR / RESTART does not lead to 
an abort, but instead to continued execution.

I see no way to handle this situation "correctly" in Python, nor 
literally in any other language I'm familiar with that's higher level
than assembler.  It can be dealt with, though not satisfyingly, as
follows:
  * The former inline code does become a subroutine that never returns,
    namely whileGENERATING()
  * Each GO TO SRCERR also becomes a call to whileGENERATING().
  * whileGENERATING(srcerr) has a parameter that tells whether it was
    a normal entry or else an entry from SRCERR.
In other words, each successive GO TO SRCERR reenters whileGENERATING().
Since whileGENERATING() has no internal state except due to global 
variables, each reentry to whileGENERATING() should be able to proceed
correctly from where the preceding entry stopped.  The only problem is
that some unknown number of reentries to while GENERATING() may 
stack up (uselessly) until PASS 2 eventually terminates.  I have no 
idea how many of them there will be ... it depends on how many calls to
the ERRORS() function there are, their error classes.
'''
whileGENERATING(False)
print("Implementation error: whileGENERATING returned.", file=sys.stderr)
sys.exit(1)
