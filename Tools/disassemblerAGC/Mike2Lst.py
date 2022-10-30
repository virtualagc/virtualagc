#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       Mike2Lst.py
Purpose:        This program converts a manual disassembly in Mike's
                format so that it's compatible enough with yaYUL's
                output listing format that specifyAGC.py can read it.  
History:        2022-10-30 RSB  Created.

I have to make some assumptions here about Mike's column alignment.

Usage:
    Mike2Lst.py <MIKE.disagc >MIKE.lst
"""

import sys

count = 1

for line in sys.stdin:

    output = "%06d,%06d: " % (count, count)
    count += 1
    
    fields = line.split(";")
    code = ""
    comment = ""
    if len(fields) > 0:
        code = fields[0]
    if len(fields) > 1:
        comment = fields[1].strip()
    
    address = code[:7].strip()
    output += "%7s" % address
    word = code[9:14].rstrip()
    output += "%11s%5s" % ("", word)
    label = code[17:25].rstrip()
    offset = ""
    if label[:1] == " ":
        offset = label.strip()
        label = ""
    output += "%8s%-8s %-8s" % ("", label, offset)
    opcode = code[26:33].rstrip()
    operands = code[33:].rstrip()
    output += "%2s%-9s%s" % ("", opcode, operands)
        
    if comment != "":
        output = "%-112s# %s" % (output, comment)
    print(output)

