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
# to be more easily traced to the relevant sectionsof the AGC sources. 
 
import sys
import glob

def main():
    
    sfiles = glob.glob('*.lst')

    if len(sfiles) > 1:
        print "Warning: multiple listing files!"

    for sfile in sfiles:
        print
        print "Build: %s" % (sfile.split('.')[0])
        print
        page = 0
        linenum = 0
        start = True
        pagenum = 0
        mem_map = {}
        addresses = []
        for line in open(sfile):
            linenum += 1
            elems = line.split()
            if len(elems) > 0:
                if not line.startswith(' '):
                    if elems[0][0].isdigit():
                        if len(elems) > 1:
                            if elems[1].startswith('$'):
                                module = elems[1][1:].split('.')[0]
                                mem_map[module] = []
                            if "## Page" in line and "scans" not in line:
                                pagenum = line.split()[3]
                                if pagenum.isdigit():
                                    pagenum = int(pagenum)
                                else:
                                    print "%s: line %d, invalid page number \"%s\"" % (sfile, linenum, pagenum)
                        if len(elems) > 2:
                            #if elems[2] == "BANK" or elems[2] == "SETLOC" or elems[2] == "BLOCK":
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
                                if 0 <= bank <= 3:
                                    newbank = bank ^ 2
                                else:
                                    newbank = bank
                                romaddr = (newbank * 02000) + (offset - 02000)
                                mem_map[module].append((romaddr, address, pagenum))
                                addresses.append("%08o  (%7s)  %4o  %6o   %6s   %s" % (romaddr, address, bank, offset, pagenum, module))
        addresses.sort()
        print "%8s  (%7s)  %4s  %6s   %6s   %s" % ("ROM Addr", "Address", "Bank", "Offset", "Page", "Module")
        print "\n".join(addresses)

if __name__=="__main__":
    sys.exit(main())
