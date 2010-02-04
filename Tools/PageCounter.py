#!/usr/bin/env python

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
