#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     symbolBankCompare.py
# Purpose:	     The idea here is to prepare a symbol table from an AGC assembly
#               by retaining symbol names and bank numbers, but discarding all
#               other info (such as the address offset into the bank).  The
#               idea is to detect symbols which have changed banks between
#               AGC software versions. We also do the actual comparison, 
#               rather than leaving it to an external utility like 'diff', so
#               that we can continue to use the address offsets within the 
#               output report, even though they are not used in detecting the
#               changes.
# Mod history:  2021-10-05 RSB  Began
#
# Usage:
#   symbolBankCompare.py ProgramVersion1.lst ProgramVersion2.lst

import sys
#import re

def sortByLabel(record):
    return record["label"]

def sortByAddress(record):
    if "movedto" in record:
        movedTo = record["movedTo"]
    else:
        movedTo = "NW"
    return record["bank"] + movedTo + record["offset"]

def readListing(filename):
    listingFile = open(filename, "r")
    lines = listingFile.readlines()
    listingFile.close()
    listing = []
    state = 0
    for line in lines:
        if state == 0 and line[:12] == "Symbol Table":
            state = 1
        elif state == 1:
            state = 2
        elif state == 2:
            if line[:19] == "Unresolved symbols:":
                break
        fields = line.split("\t\t")
        for field in fields:
            subfields = field.strip().split()
            if len(subfields) != 3:
                continue
            if ",F:" in subfields[0] or ",E:" in subfields[0]:
                subsubfields = subfields[2].split(",")
                if len(subsubfields) == 1:
                    bank = "FF"
                    offset = subsubfields[0]
                else:
                    bank= subsubfields[0]
                    offset = subsubfields[1]
                listing.append({"label" : subfields[1], "bank" : bank, "offset" : offset})
    listing.sort(key=sortByLabel)           
    return listing
    
listing1 = readListing(sys.argv[1])
listing2 = readListing(sys.argv[2])

n1 = 0
n2 = 0
while n1 < len(listing1) and n2 < len(listing2):
    if listing1[n1]["label"] < listing2[n2]["label"]:
        n1 += 1
    elif listing1[n1]["label"] > listing2[n2]["label"]:
        n2 += 1
    elif listing1[n1]["bank"] != listing2[n2]["bank"]:
        listing1[n1]["movedTo"] = listing2[n2]["bank"]
        n1 += 1
        n2 += 1
    else:
        n1 += 1
        n2 += 1
listing1.sort(key=sortByAddress)
lastFrom = 0
lastTo = 0
numOnLine = 0
for symbol in listing1:
    if "movedTo" not in symbol:
        continue
    if lastFrom != symbol["bank"] or lastTo != symbol["movedTo"]:
        if numOnLine != 0:
            print("")
        print("%s -> %s:" % (symbol["bank"], symbol["movedTo"]), end="")
        numOnLine = 0
        lastFrom = symbol["bank"]
        lastTo= symbol["movedTo"]
    if numOnLine == 0:
        print("  ", end="")
    else:
        print(", ", end="")
    print(symbol["label"], end="")
    numOnLine += 1
if numOnLine != 0:
    print("")
