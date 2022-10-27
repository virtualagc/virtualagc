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
startingCoreBank = 1
numCoreBanks = 0o35 # 1 .. 0o34
sizeCoreBank = 0o2000
coreOffset = 0o6000
numErasableBanks = 1 # 0 only; i.e., there really aren't any "banks"
sizeErasableBank = 0o2000
erasableOffset = 0o0000
numIoChannels = 0
# Module order B28, 29, 21, 22, 23, 24.
bankListHardware = [0o04, 0o01, 0o24, 0o21, 0o02, 0o03, 0o22, 0o23,
                    0o10, 0o05, 0o30, 0o25, 0o06, 0o07, 0o26, 0o27,
                    0o14, 0o11, 0o34, 0o31, 0o12, 0o13, 0o32, 0o33]
bankListBin = list(range(1, numCoreBanks))
banksPerModule = 4

# Convert bank,offset pair to an address string.  The parameters are integers,
# and if either is unknown, it should be set to -1.  Returns a pair:
# the address string, and the fixed-fixed address integer (-1 if none).
def getAddressString(bank, offset, minimal=False):
    offset = offset % sizeCoreBank
    commonString = ""
    bankString = "??"
    if bank >= startingCoreBank and bank < numCoreBanks:
        bankString = "%02o" % bank
    offsetString = "????"
    fAddress = -1
    if bank in [1, 2]:
        fAddress = offset + bank * sizeCoreBank
        commonString = "%04o" % fAddress
    offsetString = "%04o" % (offset + 3 * sizeCoreBank)
    if commonString != "":
        if minimal:
            addressString = commonString
        else:
            addressString = "%s (%s,%s)" % (commonString, bankString, offsetString)
    else:
        if minimal:
            addressString = "%s,%s" % (bankString, offsetString)
        else:
            addressString = "%s,%s%7s" % (bankString, offsetString, "")
    return addressString, fAddress

def getAddress12(address12, minimal=False):
    if address12 < 0:
        addressString = "??,????"
    elif address12 < 0o2000:
        if minimal:
            addressString = "%04o" % address12
        else:
            addressString = "%04o (E0,%04o)" % (address12, address12)
    elif address12 < 0o6000:
        if minimal:
            addressString = "%04o" % address12
        else:
            bank = address12 // sizeCoreBank
            address = 0o6000 + address12 % sizeCoreBank
            addressString = "%04o (%02o,%04o)" % (address12, bank, address)
    elif address12 <= 0o7777:
        addressString = "??,%04o" % (0o6000 + address12 % sizeCoreBank)
    else:
        addressString = "??,????"
    return addressString

def getAddressInterpretive11(address11, referenceType, minimal=False):
    addressString = "E0,%04o" % address11
    if minimal:
        return addressString[3:]
    return addressString[3:] + " (" + addressString + ")"

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

def parseAddress12(address12):
    error = True
    fixed = True
    bank = 0
    address = 0
    offset = 0
    if address12 <= 0:
        pass
    elif address12 < 0o2000:
        error = False
        fixed = False
        bank = 0
        offset = address12
        address = address12
    elif address12 < 0o6000:
        error = False
        fixed = True
        bank = address12 // sizeCoreBank
        offset = address12 % sizeCoreBank
        address = 0o6000 + offset
    elif address12 <= 0o7777:
        error = False
        fixed = True
        bank = -1
        offset = address12 % sizeCoreBank
        address = 0o6000 + offset
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
