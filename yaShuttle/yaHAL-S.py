#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       yaHAL-S.py
Purpose:        This is a compiler for the HAL/S programming language which
                produces a p-code form known as p-HAL/S. 
History:        2022-11-07 RSB  Created. 

         
"""

import sys

#Parse the command-line arguments.
pcodeFilename = "yaHAL-S.phl"
showSource = False
showComments = True
showSymbols = True
halsSource = []
metadata = []
for param in sys.argv[1:]:
    if param == "--help":
        print("""
        This is a HAL/S compiler, producing p-HAL/S p-code.
        
        Usage:
            yaHAL-S.py [OPTIONS] SOURCE1.hal[SOURCE2.hal [...]] >LISTING.lst
        
        The SOURCEx.hal files are supposed to comprise a complete image of the
        application code loaded into a Shuttle GPC at any given time.  In flight,
        different images are loaded into the GPC for different mission segments,
        and each of those images would consist of a different set of SOURCEx.hal
        files.
        
        The p-HAL/S output p-code is expected to be subsequently executed as part
        of an emulated Shuttle (sub)system by either the yaPASS.py program or 
        the yaGPC.c subroutine.
        
        The OPTIONS are: 
        
        --pcode=F       Specifies the name of the output file of p-code, which
                        by default is yaHAL-S.phl.
        --source        If present, the original source-code lines are included
                        in the output listing.  By default, they are not.
        --no-comments   If present, program comments are omitted from the listing
                        file.  By default, they are included.
        --no-symbols    If present, numerical addresses and constant values are
                        used in the listing file, in place of the (default) 
                        symbolic names of variables and code.
        """)
    elif param[:8] == "--pcode=":
        pcodeFilename = param[8:]
    elif param == "--source":
        showSource = True
    elif param == "--no-comments":
        showComments = False
    elif param == "--no-symbols":
        showSymbols = False
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
        
# Having gotten to this point, halsSource is a list of all the soure-code lines
# in all the input files.  The metadata list, in general, contains any and all 
# supplemental information about each line of source.  Each entry in metadata
# is a dictionary.  At this point, most of those dictionaries will be empty, 
# but some of them may already be populated with the following key/value pairs:
#   metadata[i] = {
#                   "file": FILENAME,       Start of a new source file.
#                   "comment": True,        Shuttle-era full-line comment.
#                   "modern": True          Virtual AGC full-line comment.
#                 }
# The shuttle-era full-line comments have 'C' in column 1, whereas the Virtual
# AGC comments have "#" in column 1. The latter, of course, is not covered by
# any of the shuttle-era documentation.  The other possible characters in 
# column 1 are "E" (exponent), "M" (main), "S" (subscript), "D" (???),
# and blank (which is just a normal line).

# Other than the special interpretation of column 1, the original HAL/S compiler 
# had no respect for the original division into lines (or punch-cards as the case
# may be), and could simply be regarded as concatenating everything on every 
# line beyond column 1.  Its first step was to tokenize this stream of characters
# into keywords vs identifiers vs operators vs literals, and we may as well do
# the same.


