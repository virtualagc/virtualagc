#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       syntaxHierarchy.py
Purpose:        This is a little one-off utility that lets me visualize the
                "abstract syntax" output by test BNFC programs.
History:        2022-11-15 RSB  Created. 
                2022-11-16 RSB  Added --strip, --no-strip.      
"""

import sys

strip = True
for param in sys.argv[1:]:
    if param == "--strip":
        strip = True
    elif param == "--no-strip":
        strip = False
    elif param == "--help":
        print("""
        Helps examine output from the TestHAL_S compiler front-end.
        Usage:
            TestHAL_S SOURCE.hal | syntaxHierarchy.py [OPTIONS]
        The available OPTIONS are:    
        --strip     Remove 2-letter prefixes from LBNF labels.
                    (This is the default.)
        --no-strip  Do not remove 2-letter prefixes from LBNF labels.
        """)
    else:
        print("Unknown parameter:", param)
        sys.exit(1)

if strip:
    skipSize = 2
else:
    skipSize = 0
step = 2
itsTime = False
for line in sys.stdin:
    if "[Abstract Syntax]" in line:
        itsTime = True
    elif itsTime:
        # This line contains the entire abstract syntax.
        indent = -step
        isEmpty = True
        skip = 0
        inQuote = False
        for c in line.strip():
            if c == "(":
                if not isEmpty:
                    print()
                    isEmpty = True
                indent += step
                skip = skipSize
            elif c == ")":
                indent -= step
                if not isEmpty:
                    print()
                    isEmpty = True
                skip = skipSize
            else:
                if isEmpty and c == " ":
                    continue
                if isEmpty:
                    if skip > 0:
                        skip -= 1
                        continue
                    for i in range(indent):
                        print(" ", end="")
                if c == '"':
                    inQuote = not inQuote
                    skip = 0
                if skip > 0:
                    skip -= 1
                    continue
                if c == " " and not inQuote:
                    skip = skipSize
                print("%c" % c, end="")
                isEmpty = False
        if not isEmpty:
            print()
        break
