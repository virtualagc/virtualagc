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

# Python script to check the page meta-comments in AGC source modules. 
# Looks for all .agc files in the current direcotry, and searches them for '## Page'
# directives. It checks the directives to verify that there are no incorrect page numbers
# (missing, extra, duplicated, out of sequence). 
#
# While the page numbers do not form part of the original AGC source, they are very important
# in the code conversion process, and in the debugging of errors in the rope binary files.

import sys
import glob

def main():
    
    sfiles = glob.glob('*.agc')

    for sfile in sfiles:
        if sfile == "Template.agc":
            continue
        page = 0
        linenum = 0
        start = True
        for line in open(sfile):
            linenum += 1
            if "## Page" in line and "scans" not in line:
                pagenum = line.split()[2]
                if pagenum.isdigit():
                    pagenum = int(pagenum)
                    if start:
                        page = pagenum
                        start = False
                    else:
                        page += 1
                    if page != pagenum:
                        print "%s: page number mismatch, expected %d, got %d" % (sfile, page, pagenum)
                else:
                    print "%s: line %d, invalid page number \"%s\"" % (sfile, linenum, pagenum)

if __name__=="__main__":
    sys.exit(main())
