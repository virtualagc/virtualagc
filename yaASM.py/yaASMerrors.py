#!/usr/bin/env python3
# Copyright 2019 Ronald S. Burkey <info@sandroid.org>
#
# This file is part of yaAGC. 
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:        yaASMerrors.py
# Purpose:         Error tracking for yaASM.py. 
# Reference:       http://www.ibibio.org/apollo
# Mods:            2023-05-19 RSB    Split off (as a Python module) from yaASM.py.

import sys

errors = []
counts = {
    "infos" : 0,
    "warnings" : 0,
    "errors" : 0,
    "rounding" : 0,
    "mismatches" : 0,
    "implementation": 0,
    "others" : 0
}

# n is the line number, a la lines[n] array.
# nn is index, a la expandedLines[n][nn]
def addError(n, msg, nn=0):
    global errors, counts
    if n >= len(errors):
        print("Implementation error: %d >= %d = len(errors), %d = len(lines)" \
              % (n, len(errors), len(lines)),\
              file=sys.stderr)
        print("Message =", msg, file=sys.stderr)
        sys.exit(1)
    if msg not in errors[n]:
        if msg.startswith("Info:"):
            counts["infos"] += 1
        elif msg.startswith("Warning:"):
            counts["warnings"] += 1
        elif msg.startswith("Error:"):
            counts["errors"] += 1
        elif msg.startswith("Mismatch:"):
            counts["mismatches"] += 1
        elif msg.startswith("Implementation:"):
            counts["implementation"] += 1
        elif msg.startswith("Rounding:"):
            counts["rounding"] += 1
        else:
            counts["others"] += 1
        #msg = str(n) + ": " + msg
        errors[n].append((nn,msg)) 

