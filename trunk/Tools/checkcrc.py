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


def getBugger(data):
    """Return the bugger word in the supplied bank data. The bugger word is the last non-zero word."""
    
    index = 0
    for i in range(len(data)-1, -1, -1):
        if data[i] != 0:
            index = i
            if i == len(data)-1:
                if data[i-1] == 0:
                    # Search farther back for bugger word. 
                    for j in range(len(data)-2, -1, -1):
                        if data[j] != 0:
                            index = j
                            break
            break
    return data[index]
    

def main():
    parser = OptionParser("usage: %prog binsrc_file")
    (options, args) = parser.parse_args()
    if len(args) < 1:
        parser.error("Binsource file must be supplied!")
        sys.exit(1)

    bsfile = open(args[0], 'r')
    lines = bsfile.readlines()
    
    print
    print "Parsing", args[0]
    
    banks = {}
    linenum = 0
    bank = -1
    banklines = 0
    bankwords = 0
    bankpages = {}
    pages = []
    
    for line in lines:
        linenum += 1
        if line.startswith(' ') or len(line) <= 1:
            continue
        if line.startswith(';'):
            if line.startswith('; p.'):
                pages.append(int(line.split('.')[1].split(',')[0]))
            continue
        if line.startswith("BANK="):
            if bank != -1:
                if bankwords != 1024:
                    if bankwords % 256 != 0:
                        print "Error: bank %02d (%03o) ending on line %d: invalid length, expected 1024, got %d." \
                              % (bank, bank, linenum-2, bankwords)
            bankpages[bank] = pages[:-1]
            pages = [ pages[-1] ]
            banklines = 0
            bankwords = 0
            # Assume bank number is always octal.
            bank = int(line.split('=')[1], 8)
            banks[bank] = []
            continue
        banklines += 1
        for value in line.split():
            if ',' in value:
                value = value[:value.index(',')]
            try:
                octval = int(value, 8)
            except:
                print "Error: invalid octal number on line", linenum
                sys.exit(1)
            banks[bank].append(octval)
            bankwords += 1

    bankpages[bank] = pages

    if len(banks) == 36:
        print "AGC Block II rope image detected"
    elif len(banks) == 24:
        print "AGC Block I rope image detected"
    else:
        print "Invalid rope image!"
        sys.exit(1)
    print
    
    for bank in banks:
        checksum = 0
        for word in banks[bank]:
            checksum = add(word, checksum)
        bugger = getBugger(banks[bank])
        if checksum == bank or checksum == (077777 & ~bank):
            print "Bank %02d (%03o): pages %d-%d, bugger %05o, checksum %05o (%05o,%05o) OK" \
                  % (bank, bank, bankpages[bank][0], bankpages[bank][-1], bugger, checksum, bank, 077777 & ~bank)
        else:
            print "Bank %02d (%03o): pages %d-%d, bugger %05o, checksum %05o (%05o,%05o) ERROR" \
                  % (bank, bank, bankpages[bank][0], bankpages[bank][-1], bugger, checksum, bank, 077777 & ~bank)
            
    bsfile.close()
    

if __name__ == "__main__":
    main()
