#!/usr/bin/env python3
'''
This program reads two binary files, obtains a count of the number of 
mismatched bytes, and exits with a status of 1 if the count is greater than
a specified threshhold, or 0 if not.  I can use `cmp` on *nix or `fc` on 
Windows to get the mismatches, but trying to use that as a conditional
in a makefile *cleanly* in both Linux/Mac and Windows defeated me.  I haven't
made this friendly, since it's only for makefiles.

Usage:
    cmp.py THRESHHOLD FILE1 FILE2 [ --verbose ]
'''

import sys

threshhold = int(sys.argv[1])
filename1 = sys.argv[2]
filename2 = sys.argv[3]
verbose = "--verbose" in sys.argv[4:]
f = open(filename1, "rb")
file1 = f.read()
f.close()
f = open(filename2, "rb")
file2 = f.read()
f.close()

if len(file1) != len(file2):
    print("Lengths of files %s and %s differ" % \
          (filename1, filename2), file=sys.stderr)
    sys.exit(1)

badcount = 0
for i in range(len(file1)):
    if file1[i] != file2[i]:
        if verbose:
            if 0xF0 <= file1[i] and file1[i] <= 0xF9 and \
                    0xF0 <= file2[i] and file2[i] <= 0xF9:
                print("%05X: %02X %02X  EBCDIC: %c %c" % \
                      (i, file1[i], file2[i], 
                       chr(ord("0") + file1[i] - 0xF0), 
                       chr(ord("0") + file2[i] - 0xF0)))
            else:
                print("%05X: %02X %02X" % (i, file1[i], file2[i]))
        badcount += 1
        if badcount > threshhold:
            print("Too many mismatches (> %d) between %s and %s" % \
                  (threshhold, filename1, filename2), file=sys.stderr)
            sys.exit(1)

print("Files %s and %s match within tolerance (%d <= %d mismatches)" % \
      (filename1, filename2, badcount, threshhold), file=sys.stderr)
sys.exit(0)
