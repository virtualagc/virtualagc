#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       yaHAL-preprocessor.py
Purpose:        I had originally intended this to be a compiler for the
                HAL/S programming language, targeting a p-code form known 
                as p-HAL/S. Now I think that using a more-modern
                compiler-compiler approach is more appropriate ... but 
                there are still things that I thing need to be handled by
                preprocessing, such as converting the multiline E/M/S
                construct to single lines of code.  That's what this
                program does.
History:        2022-11-07 RSB  Created. 
                2022-11-09 RSB  Change emphasis (and filename) from 
                                compiler to preprocessor.
         
"""

import sys
from tokenize import tokenize

#Parse the command-line arguments.
tabSize = 8
halsSource = []
metadata = []
for param in sys.argv[1:]:
    if param == "--help":
        print("""
        This is a preprocessor for HAL/S code, intended to remove certain 
        constructs (particularly multiline equations) prior to compilation.
        
        Usage:
            yaHAL-preprocessor.py [OPTIONS] SOURCE1.hal [SOURCE2.hal [...]] >SOURCE.hal
        
        The OPTIONS are: 
        
        --tab=N         Tab size in source files; assumed to be 8.  No allowance
                        is made for different tab sizes in different source files,
                        so let's just hope that never happens!  Probably the 
                        Shuttle source has no tabs anyway since it was supplied on
                        punchcards, but it's certainly possible to accidentally
                        end up with tabs if source is edited in modern editors.
        """)
    elif param[:6] == "--tab=":
        tabSize = int(param[6:])
    else:
        start = len(halsSource)
        halsFile = open(param, "r")
        halsSource += halsFile.readlines()
        halsFile.close()
        if len(halsSource) == start:
            continue
        first = True
        for i in range(len(metadata), len(halsSource)):
            m = {}
            if first:
                m["file"] = param
                first = False
            if halsSource[i][:1] == "C":
                m["comment"] = True
            elif halsSource[i][:1] == "#":
                m["modern"] = True
            metadata.append(m)

# Because whitespace is important in E/M/S constructs and (potentially) in the 
# positioning our compiler output is going to use for error markers, let's
# expand all tabs to spaces.
def untab(line):
    while "\t" in line:
        tabAt = line.index('\t')
        alignTo = tabSize * ((tabAt + tabSize) // tabSize)
        fmt = "%-" + ("%d" % alignTo) + "s"
        line = fmt % line[:tabAt] + line[tabAt + 1:]
    return line
for i in range(len(halsSource)):
    halsSource[i] = untab(halsSource[i].rstrip())
    
# The original compiler's first step was to tokenize this stream of characters
# into keywords vs identifiers vs operators vs literals, and we may as well do
# the same.  
tokenize(halsSource, metadata)

for i in range(len(halsSource)):
    if "comment" in metadata[i]:
        print("//" + halsSource[i][1:])
    elif "modern" in metadata[i]:
        print("///" + halsSource[i][1:])
    else:
        print(halsSource[i])
