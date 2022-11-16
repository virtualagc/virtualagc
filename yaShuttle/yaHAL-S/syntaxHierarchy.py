#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       syntaxHierarchy.py
Purpose:        This is a little one-off utility that lets me visualize the
                "abstract syntax" output by test BNFC programs.
History:        2022-11-15 RSB  Created.       
"""

import sys

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
                skip = 2
            elif c == ")":
                indent -= step
                if not isEmpty:
                    print()
                    isEmpty = True
                skip = 2
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
                    skip = 2
                print("%c" % c, end="")
                isEmpty = False
        if not isEmpty:
            print()
        break
