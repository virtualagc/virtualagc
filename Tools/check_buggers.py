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

def check_buggers(rope_file, bugger_file, bankOverflows):
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
        overflow = ""
        if len(bankOverflows) > bank and bankOverflows[bank]:
            overflow = " OVERFLOW"
        if actual_bugger != expected_bugger or overflow != "":
            print('Bugger word mismatch in bank %02o; actual %05o != expected %05o (diff = %05o)%s' %
                  (bank, actual_bugger, expected_bugger, abs(actual_bugger - expected_bugger), overflow))
            errors += 1

    return errors

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Check bugger words of a rope binary against a known set')
    parser.add_argument('--listing', help="Optional input assembly-listing file")
    parser.add_argument('rope_file', help="Input rope binary file")
    parser.add_argument('bugger_file', help="Input bugger word file")

    args = parser.parse_args()
    
    # We use --listing only to determine which banks have overflowed.
    bankOverflows = []
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
            # For overflowed banks, NNNN=2000.
            fields = line.split()
            subfields = fields[2].split("/")
            overflowed = subfields[0] == "2000"
            bankOverflows.append(overflowed)
            if fields[1] == "43:":
                break

    rc = check_buggers(args.rope_file, args.bugger_file, bankOverflows)
    sys.exit(rc)
