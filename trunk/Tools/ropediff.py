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

def main():

    CORELEN = (2 * 044 * 02000)

    parser = OptionParser("usage: %prog [options] core1 core2")
    parser.add_option("-N", "--no-super", action="store_true", dest="noSuper", default=False, 
                      help="Discard differences in which one word has 100 in bits 5,6,7 and the other has 011.")
    parser.add_option("-S", "--only-super", action="store_true", dest="onlySuper", default=False, 
                      help="Show only differences involving 100 vs. 011 in bits 5,6,7.")
    parser.add_option("-Z", "--no-zero", action="store_true", dest="noZero", default=False, 
                      help="Discard differences in which the word from the 2nd file is 00000.")

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

    left = open(cores[0], "rb")
    right = open(cores[1], "rb")

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

    if options.analyse:
        if len(lfiles) > 1:
            print "Warning: multiple listing files!"

        print        
        print "Build: %s" % os.path.basename(os.path.dirname(lfiles[0]).split('.')[0])

        blocks = listing_analyser.analyse(lfiles[0])

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

    print
    print "Core address       Left    Right   Block Start Addr   Page   Module"
    print "----------------   -----   -----   ----------------   ----   ------------------------------------------------"

    diffs = []

    try:
        while True:
            leftdata = left.read(2)
            rightdata = right.read(2)
            if not leftdata or not rightdata:
                break
            # Read 16-bit word and unpack into 2 byte tuple, native endianness.
            leftword = struct.unpack("BB", leftdata)
            rightword = struct.unpack("BB", rightdata)
            if leftword[0] != rightword[0] or leftword[1] != rightword[1]:
                # Words differ. Check super bits.
                nleft = (leftword[0] << 7) | (leftword[1] >> 1)
                nright = (rightword[0] << 7) | (rightword[1] >> 1)
                if options.noZero and nright == 0:
                    continue
                if ((nleft ^ nright) & 0160) == 0160 and ((nleft & 0160) == 0100 or (nleft & 0160) == 0060):
                    if options.noSuper:
                        continue
                else:
                    if options.onlySuper:
                        continue
                i = (left.tell() - 2) / 2
                diffs.append(i)
                offset = 02000 + (i % 02000)
                bank = i / 02000
                line = "%06o (" % i
                if i < 04000:
                    line += "   %04o)   " % (i + 04000)
                else:
                    line += "%02o,%04o)   " % (bank, offset)
                line += "%05o   %05o" % (nleft, nright)
                if options.analyse:
                    block = listing_analyser.findBlock(blocks, i)
                    if block:
                        line += "   " + block.getInfo()
                        diffcount[block.module] += 1
                difftotal += 1
                print line
    finally:
        left.close()
        right.close()

    if options.analyse:

        print
        print "Difference blocks: (sorted by length, ignoring single isolated differences)"
        print "-" * 80

        diffblocks = []
        index = 0
        while index < len(diffs) - 1:
            cur = index
            end = index + 1
            while diffs[end] == diffs[cur] + 1:
                cur += 1
                end += 1
            length = end - index - 1
            if length > 1:
                diffblocks.append((diffs[index], length))
            index = end

        diffblocks.sort()

        for diff in sorted(diffblocks, key=operator.itemgetter(1), reverse=True):
            i = diff[0]
            offset = 02000 + (i % 02000)
            bank = i / 02000
            line = "%06o (" % i
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

    print "%-48s %6d" % ("Total differences:", difftotal)


if __name__=="__main__":
    sys.exit(main())
