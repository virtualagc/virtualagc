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
    parser.add_option("-a", "--analyse", action="store_true", dest="analyse", default=False,
                      help="Use a list file to indicate where core differences are.")

    (options, args) = parser.parse_args()

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

    f1 = open(cores[0], "rb")
    f2 = open(cores[1], "rb")

    if options.analyse:
        f1lst = os.path.join(os.path.abspath(os.path.dirname(cores[0])), "*.lst")
        f2lst = os.path.join(os.path.abspath(os.path.dirname(cores[1])), "*.lst")
        lfiles = glob.glob(f1lst)
        lfiles.extend(glob.glob(f2lst))
        # Remove duplicates.
        ldict = {}
        for x in lfiles:
            ldict[x] = x
        lfiles = ldict.values()

        if len(lfiles) == 0:
            print >>sys.stderr, "Error: no listing file for analyse option!"
            sys.exit(1)

        if len(lfiles) > 1:
            print "Warning: multiple listing files!"
    
        print "Build: %s" % os.path.basename(os.path.dirname(lfiles[0]).split('.')[0])
        print

        blocks = listing_analyser.analyse(lfiles[0])
        #listing_analyser.printBlocks(blocks)

    try:
        while True:
            data1 = f1.read(2)
            data2 = f2.read(2)
            if not data1 or not data2:
                break
            # Read 16-bit word and unpack into 2 byte tuple, native endianness.
            word1 = struct.unpack("BB", data1)
            word2 = struct.unpack("BB", data2)
            if word1[0] != word2[0] or word1[1] != word2[1]:
                # Words differ. Check super bits.
                n1 = (word1[0] << 7) | (word1[1] >> 1)
                n2 = (word2[0] << 7) | (word2[1] >> 1)
                if options.noZero and n2 == 0:
                    continue
                if ((n1 ^ n2) & 0160) == 0160 and ((n1 & 0160) == 0100 or (n1 & 0160) == 0060):
                    if options.noSuper:
                        continue
                else:
                    if options.onlySuper:
                        continue
                i = (f1.tell() - 2) / 2
                offset = 02000 + (i % 02000)
                bank = i / 02000
                if bank < 4:
                    bank ^= 2
                line = "0%06o (%02o,%04o" % (i, bank, offset)
                if i < 04000:
                    line += " or %04o): " % (i + 04000)
                else:
                    line += "):         "
                line += "%05o %05o" % (n1, n2)
                if options.analyse:
                    block = listing_analyser.findBlock(blocks, i)
                    if block:
                        line += " " + block.getInfo()
                print line
    finally:
        f1.close()
        f2.close()

if __name__=="__main__":
    sys.exit(main())
