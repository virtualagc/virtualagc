#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       engineering.py
Purpose:        Some auxiliary functions I temporarily want available
                across disassemblerAGC.py and all of its modules.
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.
"""

# Standard modules.
import sys

# Insert an invocation of this whenever reaching
# an unimplemented part of the disassembler.
def endOfImplementation():
    print("Reached end of implemented part of the disassembler.")
    sys.exit(1)

