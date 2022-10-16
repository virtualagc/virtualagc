#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       auxiliary.py
Purpose:        Some auxiliary data and functions used throught the 
                disassemblerAGC suite, such as the geometry of memory,
                formatting functionality for addresses, and so forth. 
                This particular file is Block II only. 
History:        2022-10-14 RSB  Split off from disassemblerAGC.py.
"""

numCoreBanks = 0o44
startingCoreBank = 0
sizeCoreBank = 0o2000
coreOffset = 0o2000
numErasableBanks = 0o10
sizeErasableBank = 0o400
numIoChannels = 8

# Convert bank,offset pair to an address string.  The parameters are integers,
# and if either is unknown, it should be set to -1.  Returns a pair:
# the address string, and the fixed-fixed address integer (-1 if none).
def getAddressString(bank, offset):
    offset = offset % sizeCoreBank
    commonString = ""
    bankString = "??"
    if bank >= startingCoreBank and bank < numCoreBanks:
        bankString = "%02o" % bank
    offsetString = "????"
    fAddress = -1
    if bank in [2, 3]:
        fAddress = offset + bank * sizeCoreBank
        commonString = "%04o" % fAddress
    offsetString = "%04o" % (offset + sizeCoreBank)
    if commonString != "":
        addressString = "%s (%s,%s)" % (commonString, bankString, offsetString)
    else:
        addressString = "%s,%s%7s" % (bankString, offsetString, "")
    return addressString, fAddress

# Convert an address in the conventional print format, i.e.,
#       NNNN
#       NN,NNNN
#       EN,NNNN
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
            elif value < 0o1400:
                error = False
                fixed = False
                bank = value // sizeErasableBank
                offset = value % sizeErasableBank
                address = 0o1400 + offset
            elif value < 0o2000:
                error = False
                fixed = False
                bank = -1
                offset = value % sizeErasableBank
                address = 0o1400 + offset
            elif value < 0o4000:
                error = False
                fixed = True
                bank = -1
                offset = value % sizeCoreBank
                address = 0o2000 + offset
            elif value <= 0o7777:
                error = False
                fixed = True
                bank = value // sizeCoreBank
                offset = value % sizeCoreBank
                address = 0o2000 + offset
        elif len(fields) == 2:
            if fields[0][0] == "E":
                fixed = False
                bank = int(fields[0][1:], 8)
                address = int(fields[1], 8)
                if bank >= 0 and bank < numErasableBanks and \
                        address >= 0o1400 and address < 0o2000:
                    error = False
                    offset = address % sizeErasableBank
            else:
                fixed = True
                bank = int(fields[0], 8)
                address = int(fields[1], 8)
                if bank >= startingCoreBank and bank < numCoreBanks and \
                        address >= 0o2000 and address < 0o4000:
                    error = False
                    offset = address % sizeCoreBank
    except:
        pass
    return error, fixed, bank, address, offset
 
if False:
    # Just some tests of the stuff above.
    import sys
    for addressString in ["0123", "0456", "1234", "1432", "2345", 
                          "4567", "7654", "05,6701", "E1,1456", "01,2345",
                          "8901", "E0,1111", "34,1234", "45,2345"]:
        error, fixed, bank, address, offset = parseAddressString(addressString)
        print("%s %r %r %02o %04o %04o" % \
                (addressString, error, fixed, bank, address, offset), 
                file=sys.stderr)
