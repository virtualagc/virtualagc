#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       yaHAL-preprocessor.py
Purpose:        This is a preprocessor for the "modern" HAL/S compiler
                which takes care of things I don't think can be handled
                by the compiler itself (given the BNFC framework for
                developing the compiler).
History:        2022-11-07 RSB  Created. 
                2022-11-09 RSB  Change emphasis (and filename) from 
                                compiler to preprocessor.
                2022-11-17 RSB  Began trying to account for 
                                    REPLACE ... by "..." ;
                                statements.
                2022-11-18 RSB  Moved replaceBy into separate module
                                for continued development.
                2022-11-21 RSB  Began adding identifier type prefixes.
                                Removed #-comments.
                                
Here are the features of HAL/S I don't think the compiler can handle:

    1.  Special characters in column 1.  Specifically:
            a)  The original comments ('C' in column 1).
            b)  Multiline E / M / S constructs (including tabulation).
            v)  Compiler directives ('D' in column 1).
    2.  The macro statements:
            REPLACE identifier[(identifier)] by "string" ;
        The compiler can parse these lines all right, but cannot 
        perform the macro expansions themselves, as far as I can tell.
       
Of these matters:

    *   I think that 1a through 1c can be handled perfectly well.  
    *   I don't currently know how to address 1d, so I'm ignoring it for now.
    *   I don't see any perfect way to handle issue 2, so I've hidden
        in a separate module where it's "easily" replacable if the 
        implementation is inadequate.

Additionally, the preprocessor mangles IDENTIFIERs according to their
datatype This is actually handled by appropriating the mechanism used for 
REPLACE/BY macros, so the work is all handled by the replaceBy module
transparently.
"""

import sys
import re
import unEMS
import replaceBy

#Parse the command-line arguments.
tabSize = 8
halsSource = []
metadata = []
files = []
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
        files.append(param)
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
            elif halsSource[i][:1] == "D":
                m["directive"] = True
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
    
# Remove E/M/S multiline constructs. 
unEMS.unEMS(halsSource, metadata)

warningCount = unEMS.warningCount
fatalCount = unEMS.fatalCount

# To the best of my understanding when variables are shown in the compiler's
# output listing as "[NAME]", the brackets are really just for annotation
# purposes.  The BNF doesn't mention the brackets at all.  We need to 
# replace [NAME] by NAME.
for i in range(len(halsSource)):
    line = halsSource[i]
    while True:
        match = re.search("\\[" + replaceBy.bareIdentifierPattern + "\\]", line)
        if match == None:
            break
        line = line[:match.span()[0]] + match.group()[1:-1] + line[match.span()[1]:]
    if line != halsSource[i]:
        halsSource[i] = line

# Take care of REPLACE ... BY "..." macros.
replaceBy.replaceBy(halsSource, metadata)

# Take care of full-line comments.
for i in range(len(halsSource)):
    if "comment" in metadata[i]:
        print("//" + halsSource[i][1:])
    elif "directive" in metadata[i]:
        print("//D" + halsSource[i][1:])
    else:
        print(halsSource[i])

# Print final summary.
print("//M -----------------------------------------------------------------")
print("//M Files:")
for file in files:
    print("//M    ", file)
print("//M Summary:")
for i in range(len(halsSource)):
    if "errors" in metadata[i]:
        print("//M Line %d:" % (i+1), halsSource[i])
        for error in metadata[i]["errors"]:
            print("//M    ", error)
print("//M    ", warningCount, "warnings")
print("//M    ", fatalCount, "errors")
if fatalCount > 0:
    sys.exit(1)

