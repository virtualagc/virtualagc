#
# Python program to check AGC binsource.
# 
# Jim Lawton 2010-02-28
# 
# binsource files are in the form of blocks of 5-digit octal numbers, 
# 8 per line, 4 lines per block, 8 blocks per page, 4 pages per bank.
# Example:
#
#     50026 30001 30027 02177 50026 30001 30027 02034
#     50026 30001 30027 02630 50026 30001 30027 02042
#     50026 30001 30027 02037 50026 30001 30027 02377
#     20017 32075 50015 07005 03007 01101 02266 32075
#
# Comments begin with a semicolon. The rest of the line is ignored.
# the BANK keyword specifies the bank number (e.g. "BANK=2"). 
#
# The checksum of any given bank is equal to the sum of all of the words
# in the bank, including the so-called "bugger" word (checksum), which 
# follows all of the valid data. The sum is supposed to be equal to the 
# bank number. Filler words of 0 are added after the checksum word, so 
# that the banks never end prematurely


import sys
import os
from optparse import OptionParser

def convertToNative(n):
    i = n
    if (n & 040000) != 0:
        i = -(077777 & ~i)
    return i


def add(n1, n2):
    # Convert from AGC 1's-complement format to the native integer.
    i1 = convertToNative(n1)
    i2 = convertToNative(n2)
    sum = i1 + i2

    if sum > 16383:
        sum -= 16384
        sum += 1
    elif sum < -16383:
        sum += 16384
        sum -= 1

    if sum > 16383 or sum < -16383:
        print "Arithmetic overflow."
    
    if sum < 0:
        sum = (077777 & ~(-sum))
        
    return sum

def check(banknum, checksum):
    if checksum == banknum or checksum == (077777 & ~banknum):
        print "Checksum word for bank %02o matches (%05o,-%05o)." % (banknum, checksum, 077777 & ~checksum)
    else:
        print "Error: checksum word for bank %02o does not match (computed=%05o,-%05o)." \
              % (banknum, checksum, 077777 & ~checksum)

def main():
    parser = OptionParser("usage: %prog binsrc_file")
    (options, args) = parser.parse_args()
    if len(args) < 1:
        parser.error("Binsource file must be supplied!")
        sys.exit(1)

    bsfile = open(args[0], 'r')
    lines = bsfile.readlines()
    
    print "Parsing", args[0]
    
    checksum = 0
    bankcount = 0
    linenum = 0
    for line in lines:
        linenum += 1
        if line.startswith(';'):
            continue
        if line.startswith("BANK="):
            bankcount += 1
            if bankcount > 1:
                check(bank, checksum)
                checksum = 0
            try:
                bank = int(line.split('=')[1], 8)
            except:
                # Try decimal if not octal.
                bank = int(line.split('=')[1])
            sum = 0
            continue
        for value in line.split():
            if value.endswith(','):
                value = value[:-1]
            try:
                octval = int(value, 8)
            except:
                print "Error: invalid octal number on line", linenum
                sys.exit(1)
            checksum = add(octval, checksum)
    check(bank, checksum)
            
    bsfile.close()
    

if __name__ == "__main__":
    main()
