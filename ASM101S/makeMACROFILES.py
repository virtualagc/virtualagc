#!/usr/bin/env python3
'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   makeMACROFILES.py
Purpose:    This is a utility to help set up a macro library for use by 
            ASM101S.py.  It reads all of the files in a macro library to 
            determine which of them are literally definitions of macros (used
            by ASM101S's --library swith) and which are instead eligible for
            inclusion via the assembly-language pseudo-op COPY.  The names of
            the former are stored in the file MACROFILES.txt.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-08-31 RSB  Began.

This program is run with a current working directory that's the macro library
being processed.  It has no options.  Output is to stdout, and should be 
piped into MACROFILES.txt if acceptable.
'''

import sys
import os

for filename in sorted(os.listdir(".")):
    if not filename.endswith(".asm") and not filename.endswith(".bal"):
        print("; " + filename)
        continue
    hasMacros = False
    hasOther = False
    inMacro = False
    f = open(filename, "rt")
    for line in f:
        line = line.rstrip()[:72].rstrip()
        if line == "" or line.startswith("*") or line.startswith(".*"):
            continue
        fields = line.split()
        if inMacro:
            if line[0] == " " and len(fields) > 0 and fields[0] == "MEND":
                inMacro = False
            elif line[0] != " " and len(fields) > 1 and fields[1] == "MEND":
                inMacro = False
        elif line[0] == " " and fields[0] == "MACRO":
            inMacro = True
            hasMacros = True
        else:
            # If we've gotten here, we know that:
            #    a) We're not in a comment or empty line.
            #    b) We're not within a macro.
            # So what else is there, other than code?
            hasOther = True
            break
    f.close()
    if hasOther or not hasMacros:
        print("; " + filename)
    else:
        print(filename)
