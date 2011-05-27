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

# Python script to find the differences between two supplied AGC rope binaries.

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
        self.linenum = None

    def setloc(self, pagenum, module, linenum, srcline):
        self.pagenum = pagenum      # Listing page number.
        self.module = module        # Source module.
        self.linenum = linenum      # Listing line number.
        self.srcline = srcline      # Source line.
        self.srcline = srcline[:100]
        if self.srcline.endswith('\n'):
            self.srcline = self.srcline[:-1]

    def __str__(self):
        line = "%06o (%7s) %05o %05o " % (self.coreaddr, self.address, self.leftval, self.rightval)
        if self.pagenum:
            line += "%4d " % (self.pagenum)
        else:
            line += "     "
        line += "%-48s " % (self.module)
        srcline = self.srcline
        if self.srcline:
            srcline = self.srcline.rstrip()
        line += "%s" % (srcline)
        return line

    def __cmp__(self, other):
        return (self.coreaddr - other.coreaddr)

def log(text, verbose=False, newline=True):
    if verbose == False or (verbose == True and options.verbose == True):
        if options.outfile:
            print >>options.outfile, text,
            if newline:
                print >>options.outfile
        if verbose == True:
            print text,
            if newline:
                print

def main():

    CORELEN = (2 * 044 * 02000)

    global options

    parser = OptionParser("usage: %prog [options] core1 core2")
    parser.add_option("-c", "--no-checksums", action="store_false", dest="checksums", default=True,
                      help="Discard differences in checksums.")
    parser.add_option("-N", "--no-super", action="store_true", dest="noSuper", default=False,
                      help="Discard differences in which one word has 100 in bits 5,6,7 and the other has 011.")
    parser.add_option("-S", "--only-super", action="store_true", dest="onlySuper", default=False,
                      help="Show only differences involving 100 vs. 011 in bits 5,6,7.")
    parser.add_option("-Z", "--no-zero", action="store_true", dest="noZero", default=False,
                      help="Discard differences in which the word from the 2nd file is 00000.")
    parser.add_option("-s", "--stats", action="store_true", dest="stats", default=False,
                      help="Print statistics.")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False,
                      help="Print extra information.")
    parser.add_option("-o", "--output", dest="outfilename", help="Write output to file.", metavar="FILE")
    parser.add_option("-a", "--annotate", action="store_true", dest="annotate", default=False,
                      help="Output a modified listing annotated with core differences.")

    (options, args) = parser.parse_args()

    options.analyse = True

    options.outfile = None
    if options.outfilename:
        options.outfile = open(options.outfilename, "w")
    else:
        options.outfile = sys.stdout

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

    log("yaAGC Core Rope Differencer")
    log("")
    log("Left core file:  %s" % cores[0])
    log("Right core file: %s" % cores[1])

    leftcore = open(cores[0], "rb")
    rightcore = open(cores[1], "rb")

    leftdir = os.path.abspath(os.path.dirname(cores[0]))
    leftlst = os.path.join(leftdir, "*.lst")
    rightdir = os.path.abspath(os.path.dirname(cores[1]))
    rightlst = os.path.join(rightdir, "*.lst")
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
            for l in lfiles:
                if l.endswith("MAIN.lst"):
                    lfiles.remove(l)
            if len(lfiles) > 1:
                print >>sys.stderr, "Warning: multiple listing files, using %s!" % (lfiles[0])
        listfile = lfiles[0]
        if not os.path.isfile(listfile):
            parser.error("File \"%s\" does not exist" % listfile)
            sys.exit(1)
        log("")
        log("Listing: %s" % listfile)
        log("Build: %s" % os.path.basename(os.path.dirname(listfile).split('.')[0]))

        log("Analysing listing file... ", verbose=True)
        blocks = listing_analyser.analyse(listfile)

    options.annofile = None
    if options.annotate:
        if listfile == None:
            sys.exit("Annotate option specified, but no input listing file found")
        afilename = listfile
        afilename = afilename.replace(".lst", ".anno.txt")
        options.annofile = open(afilename, 'w')

    diffcount = {}
    difftotal = 0

    modlist = []
    srcfiles = glob.glob(os.path.join(leftdir, "*.agc"))
    srcfiles.remove(os.path.join(leftdir, "MAIN.agc"))
    if "Templates.agc" in srcfiles:
        srcfiles.remove(os.path.join(leftdir, "Template.agc"))
    for srcfile in srcfiles:
        modlist.append(os.path.basename(srcfile).split('.')[0])
    for module in modlist:
        diffcount[module] = 0

    log("Reading MAIN.agc... ", verbose=True)
    includelist = []
    mainfile = open(os.path.join(leftdir, "MAIN.agc"), "r")
    mainlines = mainfile.readlines()
    for line in mainlines:
        if line.startswith('$'):
            module = line.split()[0].split('.')[0][1:]
            includelist.append(module)
    mainfile.close()

    diffs = []
    lines = []

    log("Comparing core image files... ", verbose=True)
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
                line = "%06o (" % i
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

    log("%d core image differences" % (difftotal), verbose=True)

    lines = {}
    buggers = []
    module = None
    pagenum = 0
    address = 0
    checkdiffs = 0
    linenum = 0

    log("Building module/page/line list... ", verbose=True)
    for line in open(listfile, "r"):
        linenum += 1
        elems = line.split()
        if len(elems) > 0:
            if not line.startswith(' '):
                if "# Page " in line and "scans" not in line:
                    pagenum = line.split()[3]
                    if pagenum.isdigit():
                        pagenum = int(pagenum)
                if elems[0][0].isdigit():
                    if len(elems) > 1:
                        if elems[1].startswith('$'):
                            module = elems[1][1:].split('.')[0]
                        else:
                            if len(elems) > 2:
                                if elems[1][0].isdigit() and elems[2][0].isdigit() and len(elems[2]) == 5:
                                    address = elems[1]
                                    lines[address] = (module, pagenum, linenum, line)
                                    if len(elems) > 3:
                                        # Handle 2-word quantities, yaYUL outputs listing for the two combined at the address of the first.
                                        if elems[3][0].isdigit() and len(elems[3]) == 5:
                                            if "," in address:
                                                bank = int(address.split(',')[0], 8)
                                                offset = int(address.split(',')[1], 8)
                                                offset += 1
                                                address = "%02o,%04o" % (bank, offset)
                                            else:
                                                offset = int(address, 8)
                                                offset += 1
                                                address = "%04o" % offset
                                            lines[address] = (module, pagenum, linenum, line)
                if line.startswith("Bugger"):
                    buggers.append(line)

    log("Setting diff locations... ", verbose=True)
    for diff in diffs:
        address = diff.address.strip()
        if address in lines.keys():
            (module, pagenum, linenum, line) = lines[address]
            diff.setloc(pagenum, module, linenum, line)
        elif diff.srcline == None:
            foundBugger = False
            for bugger in buggers:
                bval = bugger.split()[2]
                baddr = bugger.split()[4]
                if baddr.endswith('.'):
                    baddr = baddr[:-1]
                if address == baddr:
                    diff.setloc(0, "Checksum", 0, "%s%s%s%s" % (15 * ' ', baddr, 11 * ' ', bval))
                    checkdiffs += 1
                    foundBugger = True
                    break
            if not foundBugger:
                print >>sys.stderr, "Error: address %s not found in listing file" % (address)
        else:
            print >>sys.stderr, "Error: address %s not found in listing file" % (address)

    log("")
    if options.checksums:
        log("%s %d" % ("Total differences:", difftotal))
    else:
        log("%s %d" % ("Total differences:", difftotal - checkdiffs))
    log("")

    if difftotal > 0:
        log("Core address     Left  Right Page Module                                           Line Number    Address           Source")
        log("---------------- ----- ----- ---- ------------------------------------------------ -------------- -------           ------------------------------------------------")
        log("")
        for diff in diffs:
            if options.checksums == True or (options.checksums == False and diff.module != "Checksum"):
                log(diff.__str__())

        if options.annofile:
            linenums = []
            diffsbyline = {}
            for diff in diffs:
                if diff.linenum != None and diff.linenum != 0:
                    linenums.append(diff.linenum)
                    diffsbyline[diff.linenum] = diff
            linenums.sort()
            diffindex = 0
            linenum = 0
            for line in open(listfile, "r"):
                linenum += 1
                if diffindex < len(linenums) and linenum == linenums[diffindex]:
                    diff = diffsbyline[linenum]
                    print >>options.annofile
                    print >>options.annofile, ">>> Core error %d of %d at %s: expected %05o, got %05o" % (diffindex + 1, len(linenums), diff.address, diff.leftval, diff.rightval)
                    diffindex += 1
                print >>options.annofile, line,

        if options.stats:

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
                log("")
                log("")
                log("Difference blocks: (sorted by length, ignoring single isolated differences)")
                #log("-" * 80)
                log("")
                log("Core address        Diffs   Module                                               ")
                log("----------------    -----   ---------------------------------------------------- ")

                for (diff, length) in sorted(diffblocks, key=operator.itemgetter(1), reverse=True):
                    address = diff.address
                    if "," in address:
                        bank = int(address.split(',')[0], 8)
                        offset = int(address.split(',')[1], 8)
                        i = 010000 + bank * 02000 + offset
                    else:
                        i = int(address, 8)
                    line = "%06o (" % i
                    offset = 02000 + (i % 02000)
                    bank = i / 02000
                    if bank < 4:
                        bank ^= 2
                    if i < 04000:
                        line += "   %04o)   " % (i + 04000)
                    else:
                        line += "%02o,%04o)   " % (bank, offset)
                    line += "%6d" % length
                    block = listing_analyser.findBlock(blocks, i)
                    if block:
                        line += "   " + block.getInfo()
                    log(line)
                log("-" * 80)

            counts = []
            for module in diffcount:
                counts.append((module, diffcount[module]))
            counts.sort()

            if options.stats:
                log("")
                log("Per-module differences: (sorted by errors)")
                log("-" * 80)
                for count in sorted(counts, key=operator.itemgetter(1), reverse=True):
                    log("%-48s %6d" % count)
                log("-" * 80)

                log("")
                log("Per-module differences: (sorted by module)")
                log("-" * 80)
                for count in counts:
                    log("%-48s %6d" % count)
                log("-" * 80)

                log("")
                log("Per-module differences: (sorted by include order)")
                log("-" * 80)
                for module in includelist:
                    log("%-48s %6d" % (module, diffcount[module]))
                log("-" * 80)

    log("Done", verbose=True)

    if options.annofile:
        options.annofile.close()

    if options.outfile:
        options.outfile.close()

if __name__=="__main__":
    sys.exit(main())
