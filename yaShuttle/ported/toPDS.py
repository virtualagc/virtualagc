#!/usr/bin/env python3
'''
This program is used to create what for the purposes of my Python 3 port of 
HAL/S-FC I'm calling a Partitioned Data Set.  Namely, a file that's a JSON
representation of a Python dictionary of the form:
    {
        MEMBER1: BYTEARRAY1,
        MEMBER2: BYTEARRAY2, 
        ...
    }

The input for the program is a folder of files with names like MEMBERx, where 
BYTEARRAYx is the contents of file MEMBERx.  The input folder is simply the 
current working directory, and the output is stdout.  Files with names not 
satisfying the rules for IBM z/OS PDS members are ignored.

It's only really intended to be used on the ERRORLIB folder of the HAL/S-FC
source code, but I suppose it might be useful for other things.
'''

import sys
from os import listdir
from os.path import isfile
import json

pds = {}
specials = ["#", "@", "$"]

for name in listdir("."):
    if len(name) > 8 or not name.isascii() or name[0].isdigit() or \
            name != name.upper() or not isfile(name):
        print("Ignoring", name, file=sys.stderr)
        continue
    fail = False
    for c in name:
        if c not in specials and not c.isalnum():
            fail = True
            break
    if fail:
        continue
    f = open(name, "r")
    contents = f.readlines()
    f.close()
    for i in range(len(contents)):
        contents[i] = contents[i].rstrip("\n\r")
    pds["%-8s" % name] = contents

json.dump(pds, sys.stdout)
