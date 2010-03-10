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

# Python script to find the differences between two supplied AGC rope binaries.
# This is just a Python version of ../Luminary131/bdiffhead.c that Ron wrote.

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

    CORELEN = (2 * 044 * 02000)

    parser = OptionParser("usage: %prog [options] core1 core2")
    parser.add_option("-N", "--no-super", action="store_true", dest="noSuper", default=False, 
                      help="Discard differences in which one word has 100 in bits 5,6,7 and the other has 011.")
    parser.add_option("-S", "--only-super", action="store_true", dest="onlySuper", default=False, 
                      help="Show only differences involving 100 vs. 011 in bits 5,6,7.")
    parser.add_option("-Z", "--no-zero", action="store_true", dest="noZero", default=False, 
                      help="Discard differences in which the word from the 2nd file is 00000.")
    parser.add_option("-s", "--stats", action="store_true", dest="stats", default=False, 
                      help="Print statistics.")

    (options, args) = parser.parse_args()

    options.analyse = True

    if len(args) < 2:
        parser.error("Two core files must be supplied!")
        sys.exit(1)

    cores = []
    for arg in args:
        cores.append(arg)
        if not os.path.isfile(arg):
            parser.error("File \"%s\" does not exist" % arg)
            sys.exit(1)

    sizes = []
    for core in cores:
        sizes.append(os.path.getsize(core))

    if sizes[0] != sizes[1]:
        parser.error("Core files are not the same size!")
        sys.exit(1)

    if sizes[0] != CORELEN:
        parser.error("Core files are incorrect length, must be %d bytes!" % CORELEN)
        sys.exit(1)

    print "yaAGC Core Rope Differencer"
    print
    print "Left core file:  ", cores[0]
    print "Right core file: ", cores[1]

    leftcore = open(cores[0], "rb")
    rightcore = open(cores[1], "rb")

    leftlst = os.path.join(os.path.abspath(os.path.dirname(cores[0])), "*.lst")
    rightlst = os.path.join(os.path.abspath(os.path.dirname(cores[1])), "*.lst")
    lfiles = glob.glob(leftlst)
    lfiles.extend(glob.glob(rightlst))
    # Remove duplicates.
    ldict = {}
    for x in lfiles:
        ldict[x] = x
    lfiles = ldict.values()

    if len(lfiles) == 0:
        print >>sys.stderr, "Warning: no listing file for analysis!"
        options.analyse = False

    listfile = None
    if options.analyse:
        if len(lfiles) > 1:
            print "Warning: multiple listing files!"
        listfile = lfiles[0]
        if not os.path.isfile(listfile):
            parser.error("File \"%s\" does not exist" % listfile)
            sys.exit(1)
        print        
        print "Build: %s" % os.path.basename(os.path.dirname(listfile).split('.')[0])

        blocks = listing_analyser.analyse(listfile)

    diffcount = {}
    difftotal = 0

    modlist = [] 
    srcfiles = glob.glob("*.agc")
    srcfiles.remove("MAIN.agc")
    srcfiles.remove("Template.agc")
    for srcfile in srcfiles:
        modlist.append(srcfile.split('.')[0])
    for module in modlist:
        diffcount[module] = 0

    includelist = []
    mainfile = open("MAIN.agc", "r")
    mainlines = mainfile.readlines()
    for line in mainlines:
        if line.startswith('$'):
            module = line.split()[0].split('.')[0][1:]
            includelist.append(module)
    mainfile.close()

    diffs = []
    lines = []

    try:
        while True:
            leftdata = leftcore.read(2)
            rightdata = rightcore.read(2)
            if not leftdata or not rightdata:
                break
            # Read 16-bit word and unpack into 2 byte tuple, native endianness.
            leftword = struct.unpack("BB", leftdata)
            rightword = struct.unpack("BB", rightdata)
            if leftword[0] != rightword[0] or leftword[1] != rightword[1]:
                # Words differ. Check super bits.
                leftval = (leftword[0] << 7) | (leftword[1] >> 1)
                rightval = (rightword[0] << 7) | (rightword[1] >> 1)
                if options.noZero and rightval == 0:
                    continue
                if ((leftval ^ rightval) & 0160) == 0160 and ((leftval & 0160) == 0100 or (leftval & 0160) == 0060):
                    if options.noSuper:
                        continue
                else:
                    if options.onlySuper:
                        continue
                i = (leftcore.tell() - 2) / 2
                offset = 02000 + (i % 02000)
                bank = i / 02000
                if bank < 4:
                    bank ^= 2
                line += "%06o (" % i
                if i < 04000:
                    address = "   %04o" % (i + 04000)
                else:
                    address = "%02o,%04o" % (bank, offset)
                line += "%s)   " % address
                line += "%05o   %05o" % (leftval, rightval)
                if options.analyse:
                    block = listing_analyser.findBlock(blocks, i)
                    if block:
                        line += "   " + block.getInfo()
                        diffcount[block.module] += 1
                diffs.append(CoreDiff(i, address, leftval, rightval))
                difftotal += 1
                lines.append(line)
    finally:
        leftcore.close()
        rightcore.close()

    lines = []
    buggers = []
    module = None
    pagenum = 0

    for line in open(listfile, "r"):
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

    # Catch errors in 2nd word of 2-word quantities, yaYUL only outputs listing for the two combined.
    for (module, pagenum, line) in lines:
        for diff in diffs:
            if diff.srcline == None:
                bank = int(diff.address.split(',')[0], 8)
                offset = int(diff.address.split(',')[1], 8)
                offset -= 1
                address = "%02o,%04o" % (bank, offset)
                elems = line.split()
                if len(elems) > 1:
                    if address == elems[1] and elems[3] != "EBANK=":
                        diff.setloc(pagenum, module, line)


    print
    print "%s %d" % ("Total differences:", difftotal)
    print

    if difftotal > 0:
        print "Core address       Left    Right   Block Start Addr   Page   Module"
        print "----------------   -----   -----   ----------------   ----   ------------------------------------------------"
        print
        for diff in diffs:
            print diff.__str__()
    
        if options.analyse:
    
            diffblocks = []
            index = 0
            while index < len(diffs) - 1:
                cur = index
                end = index + 1
                while diffs[end].coreaddr == diffs[cur].coreaddr + 1:
                    cur += 1
                    end += 1
                length = end - index - 1
                if length > 1:
                    diffblocks.append((diffs[index], length))
                index = end
    
            diffblocks.sort()
    
            if len(diffblocks) > 0:
                print
                print "Difference blocks: (sorted by length, ignoring single isolated differences)"
                print "-" * 80
        
                for diff in sorted(diffblocks, key=operator.itemgetter(1), reverse=True):
                    i = diff[0]
                    line = "%06o (" % i
                    offset = 02000 + (i % 02000)
                    bank = i / 02000
                    if bank < 4:
                        bank ^= 2
                    if i < 04000:
                        line += "   %04o)   " % (i + 04000)
                    else:
                        line += "%02o,%04o)   " % (bank, offset)
                    line += "%6d" % diff[1]
                    block = listing_analyser.findBlock(blocks, i)
                    if block:
                        line += "   " + block.getInfo()
                    print line
                print "-" * 80
    
            counts = []
            for module in diffcount:
                counts.append((module, diffcount[module]))
            counts.sort()
    
            if options.stats:
                print
                print "Per-module differences: (sorted by errors)"
                print "-" * 80
                for count in sorted(counts, key=operator.itemgetter(1), reverse=True):
                    print "%-48s %6d" % count
                print "-" * 80
        
                print
                print "Per-module differences: (sorted by module)"
                print "-" * 80
                for count in counts:
                    print "%-48s %6d" % count
                print "-" * 80
        
                print
                print "Per-module differences: (sorted by include order)"
                print "-" * 80
                for module in includelist:
                    print "%-48s %6d" % (module, diffcount[module])
                print "-" * 80


if __name__=="__main__":
    sys.exit(main())
