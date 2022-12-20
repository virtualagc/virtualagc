#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
        **************************************************************
        *   This program has essentially been superseded by the      *
        *   --ast-only or --interactive switch in yaHAL-S-FC.py.     *
        **************************************************************

Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       syntaxHierarchy.py
Purpose:        This is a little one-off utility that lets me visualize the
                "abstract syntax" output by test BNFC programs.
History:        2022-11-15 RSB  Created. 
                2022-11-16 RSB  Added --strip, --no-strip.  
                2022-11-25 RSB  Added --collapse.  Fixed parentheses inside
                                the replacement string of REPLACE statements.
                2022-12-11 RSB  Added --bare.  
"""

import sys

strip = True
collapse = False
bare = False
stringDelimiter = '"'
for param in sys.argv[1:]:
    if param == "--strip":
        strip = True
    elif param == "--no-strip":
        strip = False
    elif param == "--collapse":
        collapse = True
    elif param == "--bare":
        bare = True
    elif param == "--carat":
        stringDelimiter = "^"
    elif param == "--help":
        print("""
        Helps examine output from the TestHAL_S compiler front-end.
        Usage:
            TestHAL_S SOURCE.hal | syntaxHierarchy.py [OPTIONS]
        The available OPTIONS are:    
        --strip     Remove 2-letter prefixes from LBNF labels.
                    (This is the default.)
        --no-strip  Do not remove 2-letter prefixes from LBNF labels.
        --collapse  Make the hierarchy easier to read ... I hope.
        --bare      Assumes input contains just the abstract syntax.
        --carat     Assumes string delimiter is ^ rather than double quote.
        """)
        sys.exit(0)
    else:
        print("Unknown parameter:", param)
        sys.exit(1)

if strip:
    skipSize = 2
else:
    skipSize = 0
step = 1
itsTime = False
for line in sys.stdin:
    if bare and "(" == line[:1]:
        itsTime = True
    if "[Abstract Syntax]" in line:
        itsTime = True
    elif itsTime:
        # This line contains the entire abstract syntax.
        indent = -step
        isEmpty = True
        skip = 0
        inQuote = False
        line = line.strip()
        i = 0
        while i < len(line):
            c = line[i]
            i += 1
            if c == '"' and i < len(line) and line[i] == '"':
                i += 1
            if not inQuote and c == "(":
                if not collapse and not isEmpty:
                    print()
                    isEmpty = True
                elif collapse and not isEmpty:
                    print("%d:" % (indent+1), end="")
                indent += step
                skip = skipSize
            elif not inQuote and c == ")":
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
                    if line[i-1:i+12] == "any_statement" or \
                            line[i-1:14] == "basic_statement" or \
                            line[i-1:14] == "other_statement":
                        print()
                    for j in range(indent):
                        print(" ", end="")
                    print("%d:" % indent, end="")
                if c == stringDelimiter:
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
