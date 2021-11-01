#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     bankToBankReference.py
# Purpose:	     This program acts like a filter on the assembly-listing file
#               created by yaYUL.  It selects out just the lines of the 
#               assembly listing in which a source line in a bank (selected
#               from the command line) references an object in a bank (again,
#               selected from the command line).  I hope it may be useful
#               when reconstructing an AGC software revision and you find that
#               a change you've made in one bank adversely affects a different
#               bank as a side effect.  This lets you find out exactly which
#               objects may have changed addresses to cause the problem.
# Mod history:  2021-10-21 RSB  Began
#               2021-10-31 RSB  Now ignores the case of MM==NN.
#
# Usage:
#   bankToBankReference.py MM NN <assembly.lst
# MM=00, 01, ..., 43 (octal), while NN is one of E0, ..., E7, 00, ..., 43.
# MM of the referencing bank and NN is the referenced bank.  For example, in
#   05,2134     TC  POTATO
# MM=05 and NN=whatever bank POTATO is in.
#
# Note that this program assumes that it precisely understands the column
# alignment of the input .lst file, so if yaYUL changes that format, then
# this program needs to be adjusted.  Specifically, what it "understands"
# is:
#       Columns 16-22       Address
#       Columns 47-54       Label
#       Columns 66-73       Operator
#       Columns 75-82       Operand (first subfield)

import sys

# Test if a string is all octal digits.
def isOctal(s):
    for c in s:
        if c < '0' or c > '7':
            return False
    return True

sourceBank = sys.argv[1]
if len(sourceBank) != 2:
    sys.exit(1)
if not isOctal(sourceBank):
    sys.exit(1)
bankNum = int(sourceBank, 8)
if bankNum < 0 or bankNum > 0o43:
    sys.exit(1)
targetBank = sys.argv[2]
if len(targetBank) != 2:
    sys.exit(1)
if targetBank[:1] == "E":
    if not isOctal(targetBank[1:]):
        sys.exit(1)
elif not isOctal(targetBank):
    sys.exit(1)
else:
    bankNum = int(targetBank, 8)
    if bankNum < 0 or bankNum > 0o43:
        sys.exit(1)

if sourceBank == targetBank:
    sys.exit(1)

# Read the input listing file and parse it.
codeLines = [] # This is where we collect all of the parsed input data.
labels = {} # This is where we collect the addresses of all labels.
for line in sys.stdin:
    try:
        address = line[15:22].strip()
        if len(address) == 4 and isOctal(address):
            offset = int(address, 8)
            if offset < 0o00400:
                bank = "E0"
            elif offset < 0o01000:
                bank = "E1"
            elif offset < 0o01400:
                bank = "E2"
            elif offset < 0o04000:
                continue # illegal
            elif offset < 0o06000:
                bank = "02"
            elif offset < 0o10000:
                bank = "03"
            else:
                continue # illegal
        elif len(address) == 7:
            fields = address.split(",")
            if len(fields) != 2:
                continue
            bank = fields[0]
            if len(bank) != 2:
                continue
            if bank[:1] == 'E':
                if not isOctal(bank[1:]):
                    continue
            elif not isOctal(bank):
                continue
            else:
                banknum = int(bank, 8)
                if banknum < 0o00 or banknum > 0o43:
                    continue
        else:
            continue
        # If we've gotten here, then the address field of the input line is indeed
        # a legal memory bank, either fixed or erasable, and the variable called
        # "bank" is a 2-character string: "E0", ..., "E7", "00", ..., "43".
        if line[46].isspace():
            label = ""
        else:
            label = line[46:54].strip()
        operator = line[65:73].strip()
        operand1 = line[74:82].strip()
        codeLines.append({"line":line, "bank":bank, "label":label, "operator":operator, "operand1":operand1})
        if label != "":
            labels[label] = bank
    except:
        continue

# Output
for codeLine in codeLines:
    bank = codeLine["bank"]
    operand1 = codeLine["operand1"]
    if bank == sourceBank and operand1 in labels:
        if labels[operand1] == targetBank:
            print(codeLine["line"].strip())
