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
# Looks for all .agc files in the current directory, and searches them for '## Page'
# directives. It checks the directives to verify that there are no incorrect page numbers
# (missing, extra, duplicated, out of sequence).
#
# While the page numbers do not form part of the original AGC source, they are very important
# in the code conversion process, and in the debugging of errors in the rope binary files.

import sys
import glob

def main():

    sfiles = glob.glob('*.agc')

    if len(sfiles) == 0:
        print >>sys.stderr, "Error, no AGC source files found!"
        sys.exit(1)

    errors = 0

    for sfile in sfiles:
        if sfile == "Template.agc":
            continue
        page = 0
        linenum = 0
        start = True
        for line in open(sfile):
            linenum += 1
            sline = line.strip()
            if not sline.startswith('#'):
                continue
            if not "Page" in sline or ("Page" in sline and ("scans" in sline or "Pages" in sline)):
                continue
            fields = sline
            if sline.startswith('#Page'):
                print >>sys.stderr, "%s, line %d: invalid page number \"%s\"" % (sfile, linenum, sline)
                errors += 1
                fields = sline[1:]
            elif sline.startswith('# Page'):
                fields = sline[2:]
            else:
                continue
            pagenum = fields.split()[1]
            if pagenum.isdigit():
                pagenum = int(pagenum)
                if start:
                    page = pagenum
                    start = False
                else:
                    page += 1
                if page != pagenum:
                    print >>sys.stderr, "%s, line %d: page number mismatch, expected %d, got %d" % (sfile, linenum, page, pagenum)
                    errors += 1
            else:
                print >>sys.stderr, "%s, line %d: invalid page number \"%s\"" % (sfile, linenum, pagenum)
                errors += 1
    if errors != 0:
        print >>sys.stderr, "%d errors found" % (errors)
    else:
        print "No errors found"

if __name__=="__main__":
    sys.exit(main())
