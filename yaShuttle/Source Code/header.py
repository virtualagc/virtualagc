#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       header.py
Purpose:        Performs some light processing on some Shuttle-related files
                that I want to add to our source tree.
History:        2023-04-16 RSB  Created.          

Adds a filename extension and a file header.  For example,

    header.py STREAM xpl RSB

would create STREAM.xpl from STREAM, by appending the header header.xpl to it, 
with some string substitutions in it related to the filename, date (today!), 
and initials of whoever ran the program.
"""

import sys
import pathlib
from datetime import datetime

dir = pathlib.Path(__file__).parent.resolve()
base = sys.argv[1]
extension = sys.argv[2]
if "." + extension in base:
    sys.exit(0)
print("%s -> %s" % (base, base + "." + extension))
initials = sys.argv[3]
date = datetime.today().strftime("%Y-%m-%d " + initials)

f = open(base, "r")
baseLines = f.readlines()
f.close()
f = open(str(dir) + "/header." + extension, "r")
headerLines = f.readlines()
f.close()
f = open(base + "." + extension, "w")
for line in headerLines:
    line = line.rstrip().replace("@1@", base).replace("@2@", date)
    print(line, file=f)
for line in baseLines:
    print(line.rstrip(), file=f)
f.close()
