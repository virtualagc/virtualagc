#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       auxiliary.py
Purpose:        Some auxiliary data and functions used throughout the 
                disassemblerAGC suite, such as the geometry of memory,
                formatting functionality for addresses, and so forth. 
                This particular file is Block I only. 
History:        2022-10-14 RSB  Split off from disassemblerAGC.py.
"""


# Note that Block I banks are numbered from 0o01 to 0o34.  There is 
# no bank 0.  We get around this by saying there are 35 banks, but
# bank 0 is filled with the "unused" value.
numCoreBanks = 0o35
startingCoreBank = 1
sizeCoreBank = 0o2000
coreOffset = 0o6000
numErasableBanks = 1
sizeErasableBank = 0o2000
numIoChannels = 0

# Convert bank,offset pair to an address string.  The parameters are integers,
# and if either is unknown, it should be set to -1.  Returns a pair:
# the address string, and the fixed-fixed address integer (-1 if none).
def getAddressString(bank, offset):
    commonString = ""
    bankString = "??"
    if bank >= startingCoreBank and bank < numCoreBanks:
        bankString = "%02o" % bank
    offsetString = "????"
    fAddress = -1
    if bank in [1, 2]:
        fAddress = offset % sizeCoreBank + bank * sizeCoreBank
        commonString = "%04o" % fAddress
    offsetString = "%04o" % (offset % sizeCoreBank + 3 * sizeCoreBank)
    if commonString != "":
        addressString = "%s (%s,%s)" % (commonString, bankString, offsetString)
    else:
        addressString = "%s,%s%7s" % (bankString, offsetString, "")
    return addressString, fAddress

# Convert an address in the conventional print format, i.e.,
#       NNNN
#       NN,NNNN
#       EN,NNNN (not possible for Block I)
# to a quintuple:
#       error (boolean)
#       fixed (boolean)     True if fixed, False if erasable
#       bank (integer)      -1 if indeterminate.
#       address (integer)   
#       offset (integer)    0 to banksize-1
def parseAddressString(addressString):
    error = True
    fixed = True
    bank = 0
    address = 0
    offset = 0
    fields = addressString.split(",")
    try:
        if len(fields) == 1:
            value = int(fields[0], 8)
            if value <= 0:
                pass
            elif value < 0o2000:
                error = False
                fixed = False
                bank = 0
                offset = value
                address = value
            elif value < 0o6000:
                error = False
                fixed = True
                bank = value // sizeCoreBank
                offset = value % sizeCoreBank
                address = 0o6000 + offset
            elif value <= 0o7777:
                error = False
                fixed = True
                bank = -1
                offset = value % sizeCoreBank
                address = 0o6000 + offset
        elif len(fields) == 2:
            fixed = True
            bank = int(fields[0], 8)
            address = int(fields[1], 8)
            if bank >= startingCoreBank and bank < numCoreBanks and \
                    address >= 0o6000 and address <= 0o7777:
                error = False
                offset = address % sizeCoreBank
                address = 0o6000 + offset
    except:
        pass
    return error, fixed, bank, address, offset
 
if False:
    import sys
    for addressString in ["0123", "0456", "1234", "1432", "2345", 
                          "4567", "7654", "05,6701", "E1,1456", "01,2345",
                          "8901", "E0,1111", "34,1234", "45,2345"]:
        error, fixed, bank, address, offset = parseAddressString(addressString)
        print("%s %r %r %02o %04o %04o" % \
                (addressString, error, fixed, bank, address, offset), 
                file=sys.stderr)
