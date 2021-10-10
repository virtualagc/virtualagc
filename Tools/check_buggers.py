#!/usr/bin/env python
# Copyright 2019 Mike Stewart <mastewar1 at gmail dot com>
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

# Python script to check the bugger words of a compiled rope against a
# known set (e.g. those from MIT drawings 2021151 through 2021154). It is
# intended to check validity of reconstructed ropes.
import argparse
import array
import sys
import os

def load_rope(filename):
    # Load the rope data into an array
    rope = array.array('H')
    with open(filename, 'rb') as f:
        rope.fromfile(f, int(os.path.getsize(filename)/2))

    # Correct endianness
    rope.byteswap()

    # Shift off the parity bits
    for i,w in enumerate(rope):
        rope[i] = w >> 1

    return rope

def get_bugger(rope, bank):
    # Determine addressing base for TC self instructions
    if bank == 2:
        s = 0o4000
    elif bank == 3:
        s = 0o6000
    else:
        s = 0o2000

    # Handle swapped banks 0,1 and 2,3
    if bank < 0o04:
        bank ^= 0o02

    bank_start = bank * 0o2000
    bank_end = bank_start + 0o2000

    tc_selfs = 0
    for i in range(bank_start, bank_end):
        if tc_selfs >= 2 or i == (bank_end - 1):
            return rope[i]

        if rope[i] == s:
            tc_selfs += 1
        else:
            tc_selfs = 0

        s += 1

def mismatchSortKey(output):
    if "overflow" in output["message"]:
        return "B%-5s%02o" % (output["usage"], output["bank"])
    return "A%05o%02o" % (output["discrepancy"], output["bank"])

def bankSortKey(output):
    return output["bank"]

def usedSortKey(output):
    return output["usage"]

summary = { "match" : 0, "singleDigit" : 0, "doubleDigit" : 0, 
           "tripleDigit" : 0, "quadrupleDigit" : 0, "quintupleDigit" : 0, "overflow" : 0}
outputs = []
def check_buggers(rope_file, bugger_file, bankUsages):
    rope = load_rope(rope_file)

    with open(bugger_file, 'r') as f:
        buggers = f.readlines()

    errors = 0
    for l in buggers:
        l = l.strip()
        if l == '' or l.startswith(';'):
            continue
        
        bankstr, buggerstr = l.split(' = ')
        bank = int(bankstr, 8)
        expected_bugger = int(buggerstr, 8)

        actual_bugger = get_bugger(rope, bank)
        usage = ""
        if bankUsages[bank] != "0000/2000":
            used = int(bankUsages[bank].split("/")[0], 8)
            if used <= 01777:
                usage = "; remaining = %3d words" % (01777 - used)
            else:
                usage = "; overflow  = %3d words" % (used - 01777)
        discrepancy = abs(actual_bugger - expected_bugger)
        if bankUsages[bank][0] == "2":
            summary["overflow"] += 1
        elif actual_bugger == expected_bugger:
            summary["match"] += 1
        elif discrepancy < 010:
            summary["singleDigit"] += 1
        elif discrepancy < 0100:
            summary["doubleDigit"] += 1
        elif discrepancy < 01000:
            summary["tripleDigit"] += 1
        elif discrepancy < 010000:
            summary["quadrupleDigit"] += 1
        else:
            summary["quintupleDigit"] += 1
        outputMessage = '\tBugger word mismatch in bank %02o; actual %05o != expected %05o (diff = %05o)%s' % (bank, actual_bugger, expected_bugger, discrepancy, usage)
        outputs.append({"discrepancy" : discrepancy, "bank" : bank, "usage" : bankUsages[bank].split("/")[0], "message" : outputMessage})
        if actual_bugger != expected_bugger or bankUsages[bank][0] == "2":
            errors += 1
    
    print("Mismatched Banks, in Word-Usage Order:")
    outputs.sort(key=usedSortKey)
    for output in outputs:
        if output["discrepancy"] != 0 or "overflow" in output["message"]:
            print(output["message"])
    print("All Banks, in Checksum-Discrepancy Order:")
    outputs.sort(key=mismatchSortKey)
    for output in outputs:
        print(output["message"])
    print("Summary:  %02d-%02d-%02d-%02d-%02d-%02d-%02d" % (summary["match"], summary["singleDigit"], summary["doubleDigit"], summary["tripleDigit"], summary["quadrupleDigit"], summary["quintupleDigit"], summary["overflow"]))
    print("Mismatched Banks, in Bank-Number Order:")
    outputs.sort(key=bankSortKey)
    for output in outputs:
        if output["discrepancy"] != 0 or "overflow" in output["message"]:
            print(output["message"])
    return errors

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Check bugger words of a rope binary against a known set')
    parser.add_argument('--listing', help="Optional input assembly-listing file")
    parser.add_argument('rope_file', help="Input rope binary file")
    parser.add_argument('bugger_file', help="Input bugger word file")

    args = parser.parse_args()
    
    # We use --listing only to determine which banks have overflowed.
    bankUsages = ["0000/2000"]*044
    if args.listing:
        f = open(args.listing, "r")
        listingLines = f.readlines()
        f.close()
        inUsageTable = False
        for line in listingLines:
            if not inUsageTable:
                if "Usage Table for Fixed" in line:
                    inUsageTable = True
                continue
            if "---------------" in line:
                continue
            # Lines are of the form "Bank NN: NNNN/2000 words used."
            # For overflowed banks, NNNN>1777.
            fields = line.split()
            bank = int(fields[1][:-1], 8)
            bankUsages[bank] = fields[2]
            if bank == 043:
                break

    rc = check_buggers(args.rope_file, args.bugger_file, bankUsages)
    sys.exit(rc)
