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

# Python script to analyse the yaYUL listing file produced upon building an
# AGC system image. This script finds each change of address in the AGC
# sources (from the listing) and forms a list of code blocks ordered by
# resulting core (ROM) address. This allows differences between core files
# to be more easily traced to the relevant sections of the AGC sources.

import sys
import glob

class CoreBlock:
    """Class defining information about a code block in a core file."""

    def __init__(self, coreaddr, address, bank, offset, pagenum, module):
        self.coreaddr = coreaddr    # Starting address in the core file.
        self.address = address      # Starting address in the listing.
        self.bank = bank            # Bank.
        self.offset = offset        # Offset.
        self.pagenum = pagenum      # Listing page number.
        self.module = module        # Source module.

    def __str__(self):
        return ("%06o (%02o,%04o)   %4s   %s" % (self.coreaddr, self.bank, self.offset, self.pagenum, self.module))

    def __cmp__(self, other):
        return (self.coreaddr - other.coreaddr)

    def getInfo(self):
        return (self.__str__())


def analyse(listing):
    """Analyse the supplied yaYUL listing file, and return an address map, ordered by core address. """

    linenum = 0
    pagenum = 0
    blocks = []

    for line in open(listing):
        linenum += 1
        elems = line.split()
        if len(elems) > 0:
            if not line.startswith(' '):
                if elems[0][0].isdigit():
                    if len(elems) > 1:
                        if elems[1].startswith('$'):
                            module = elems[1][1:].split('.')[0]
                        if "# Page" in line and "scans" not in line and "Pages" not in line:
                            try:
                                pagenum = line.split()[3]
                            except:
                                print line
                                raise
                            if pagenum.isdigit():
                                pagenum = int(pagenum)
                            else:
                                print >>sys.stderr,"%s: line %d, invalid page number \"%s\"" % (listing, linenum, pagenum)
                    if len(elems) > 2:
                        if elems[2] == "COUNT*":
                            address = elems[1]
                            if ',' in address:
                                bank = int(address.split(',')[0], 8)
                                offset = int(address.split(',')[1], 8)
                            else:
                                bank = int(address, 8) / 02000
                                offset = int(address, 8) - 02000
                                if offset >= 04000:
                                    offset -= 02000
                            newbank = bank
                            if bank < 4:
                                newbank = bank ^2
                            coreaddr = (newbank * 02000) + (offset - 02000)
                            blocks.append(CoreBlock(coreaddr, address, bank, offset, pagenum, module))
    blocks.sort()
    return(blocks)


def findBlock(blocks, address):
    """Find the block containing the supplied core address."""
    for i in range(len(blocks)-1):
        if blocks[i].coreaddr <= address < blocks[i+1].coreaddr:
            return blocks[i]
    return blocks[len(blocks)-1]


def printBlocks(blocks):
    """Print a set of core blocks."""

    print "ROM Address        Page   Module"
    for block in blocks:
        print block


def main():

    lfiles = glob.glob('*.lst')

    if len(lfiles) == 0:
        print "Error: no listing file!"
        sys.exit()

    if len(lfiles) > 1:
        print "Warning: multiple listing files!"

    for lfile in lfiles:
        print
        print "Build: %s" % (lfile.split('.')[0])
        print
        blocks = analyse(lfile)
        printBlocks(blocks)

if __name__=="__main__":
    sys.exit(main())
