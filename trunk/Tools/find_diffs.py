#!/usr/bin/env python

# Copyright 2010 Jim lawton <jim dot lawton at gmail dot com>
# 
# This file is part of yaAGC. 
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# Python script to find a specified set of rope image differences in a yaYUL 
# listing file. 

import os
import sys
import glob
from optparse import OptionParser
import struct
import operator
import listing_analyser

class CoreDiff:
    """Class defining information about a difference between 2 core files."""

    def __init__(self, coreaddr, address, leftval, rightval):
        self.coreaddr = coreaddr    # Starting address in the core file.
        self.address = address      # Starting address in the listing.
        self.leftval = leftval      # Left value.
        self.rightval = rightval    # Right value.
        self.pagenum = None
        self.module = None
        self.srcline = None

    def setloc(self, pagenum, module, srcline):
        self.pagenum = pagenum      # Listing page number.
        self.module = module        # Source module.
        self.srcline = srcline      # Source line.
        self.srcline = srcline[:100]
        if self.srcline.endswith('\n'):
            self.srcline = self.srcline[:-1]

    def __str__(self):
        line = "%06o (%7s)   %05o   %05o   " % (self.coreaddr, self.address, self.leftval, self.rightval)
        if self.pagenum:
            line += "%4d   " % (self.pagenum)
        else:
            line += "       "
        line += "%-48s   " % (self.module)
        line += "%-100s" % self.srcline
        return line

    def __cmp__(self, other):
        return (self.coreaddr - other.coreaddr)


def main():

    parser = OptionParser("usage: %prog [list_file] diff_file")

    (options, args) = parser.parse_args()

    if len(args) < 1:
        parser.error("Difference file must be supplied!")
        sys.exit(1)

    list_file = None
    diff_file = None
    if len(args) >= 2:
        list_file = args[0]
        diff_file = args[1]
    else:
        diff_file = args[0]
        lfiles = glob.glob("*.lst")
        if len(lfiles) == 0:
            print >>sys.stderr, "Warning: no listing file for analysis!"
            sys.exit(1)
        if len(lfiles) > 1:
            print >>sys.stderr, "Warning: multiple listing files!"
            sys.exit(1)
        list_file = lfiles[0]

    if not os.path.isfile(list_file):
        parser.error("File \"%s\" does not exist" % list_file)
        sys.exit(1)
    if not os.path.isfile(diff_file):
        parser.error("File \"%s\" does not exist" % diff_file)
        sys.exit(1)

    diffs = []
    for line in open(diff_file, "r"):
        if line.startswith('0') or line.startswith('1') and len(line.split()) == 8:
            elems = line.split()
            coreaddr = int(elems[0], 8)
            address = elems[1][1:-1]
            lval = int(elems[2], 8)
            rval = int(elems[3], 8)
            diffs.append(CoreDiff(coreaddr, address, lval, rval))

    lines = []
    buggers = []
    module = None
    pagenum = 0

    for line in open(list_file, "r"):
        elems = line.split()
        if len(elems) > 0:
            if not line.startswith(' '):
                if "## Page" in line and "scans" not in line:
                    pagenum = line.split()[3]
                    if pagenum.isdigit():
                        pagenum = int(pagenum)
                if elems[0][0].isdigit():
                    if len(elems) > 1:
                        if elems[1].startswith('$'):
                            module = elems[1][1:].split('.')[0]
                if module:
                    lines.append((module, pagenum, line))
                if line.startswith("Bugger"):
                    buggers.append(line)

    for (module, pagenum, line) in lines:
        for diff in diffs:
            elems = line.split()
            if len(elems) > 1:
                if diff.address == elems[1]:
                    diff.setloc(pagenum, module, line)

    for diff in diffs:
        if diff.srcline == None:
            for bugger in buggers:
                bval = bugger.split()[2]
                baddr = bugger.split()[4]
                if baddr.endswith('.'):
                    baddr = baddr[:-1]
                if diff.address == baddr:
                    diff.setloc(0, "Bugger", bugger)

    print "Core address       Left    Right   Page   Module                                             Source Line"
    print "----------------   -----   -----   ----   ------------------------------------------------   -----------"
    for diff in diffs:
        print diff.__str__()

if __name__=="__main__":
    sys.exit(main())
