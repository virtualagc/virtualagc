#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

                **********************************************************
                * This file is now frozen and deprecated.  Work directly *
                * with the LBNF description in the file HAL_S.cf instead.*
                **********************************************************

Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       bnf2lbnf.py
Purpose:        Convert the HAL-S.bnf file to HAL-S.lbnf for use with
                BNFC.  May work with other BNF input files, but I 
                don't guarantee it, because it makes no attempt to 
                correctly parse the BNF in all generality.
History:        2022-11-09 RSB  Created. 
                2022-11-13 RSB  Now allows for mixture of BNF and LBNF
                                input lines.
                2022-11-16 RSB  If input LBNF has a label, it's allowed
                                to keep it; labels are generated only
                                where they had been left empty.  Added
                                ~~ for marking suggested labels in BNF.

For the HAL/S BNF in particular, not all nonterminals have rules
defined.  I've had to reverse engineer those, but instead of doing so
in BNF, I've created LBNF for them in the file extraHAL-S.lbnf.  The
syntax for creating the full LBNF for input into BNFC is:

    cat extraHAL-S.lbnf HAL-s.bnf | bnf2lbnf.py >fullHAL-S.lbnf

The LBNF input lines can simply be passed through (after noting which
nonterminals are defined), but for the BNF input lines a variety of 
things need to be done.

    1.  All nonterminals like <some string> need to be converted to 
        some_string ... i.e., no angular brackets and no spaces.
    2.  All terminals need to be double-quoted.
    3.  All alternatives need to be converted to separate lines, 
        terminated by semi-colons at the ends of the lines.
    4.  Each line needs to be given a label.
    
So for example, the BNF

    <all greetings> ::= hello | hola | aloha
    
might turn into the LBNF

    all_greetings_1. all_greetings ::= "hello" ;
    all_greetings_2. all_greetings ::= "hola" ;
    all_greetings_3. all_greetings ::= "aloha" ;

Unfortunately, not all of these 4 conversions are independent of each
other.  The biggest problem is that | is a terminal in HAL-S.bnf, so
mindlessly splitting these rules at the '|' character doesn't work all
the time.  And then there's < as a terminal as well.

On the other hand, rules with embedded terminals are few and far
between, and can be handled in an ad-hoc fashion.
"""

import sys

lines = sys.stdin.readlines()

# I'm going to do two passes here.  The first finds all of the 
# terminals to the left of ::=.
nonterminals = {}
reverse = {}
for i in range(len(lines)):
    if lines[i][:2] == "--":
        continue
    fields = lines[i].split("~~")
    if len(fields) == 0:
        continue
    line = fields[0].rstrip()
    if "token " == line[:6] or "entrypoints " == line[:12] \
            or "comment " == line[:8]:
        nonterminal = line.split()[1]
        replacement = nonterminal
    else:
        if line[:2] == "--" or "::=" not in line:
            continue
        nonterminal = line[:line.index("::=")].strip()
        if "." in nonterminal:  # Detect an LBNF line.
            nonterminal = "<" + \
                nonterminal[nonterminal.index(".") + 1:].replace("_", " ").strip() \
                + ">"
        if nonterminal[:1] != "<" or nonterminal[-1:] != ">":
            print("Fatal: Illegal non-terminal")
            print(line)
            sys.exit(1)
        replacement = nonterminal.replace(" ", "_")
    if nonterminal not in nonterminals:
        nonterminals[nonterminal] = replacement
       
for nonterminal in nonterminals:
    reverse[nonterminals[nonterminal]] = nonterminal
    
# Second, final pass.
print("-- ****************************************************************")
print("-- * This file was created by the script bnf2lbnf.py, forming a   *")
print("-- * complete LBNF description from several BNF and LBNF partial  *")
print("-- * descriptions of the language.  Any embedded comments below   *")
print("-- * are from the partial-description files, and thus are not     *")
print("-- * necessarily 100% accurate for the complete LBNF description. *")
print("-- ****************************************************************")
print()
for i in range(len(lines)):
    if lines[i][:2] == "--":
        print(lines[i].rstrip())
        continue
    fields = lines[i].split("~~")
    if len(fields) == 0:
        print(line)
        continue
    line = fields[0].rstrip()
    suggestions = []
    if len(fields) > 1:
        suggestions = fields[1:]
    if "::=" not in line:
        print(line)
        continue
    if "." in line[:line.index("::=")].strip():  # Detect an LBNF line.
        index = line.index(".")
        if line[:index].strip() != "": # Does it have a label already?
            print(line)
            continue
        # It's a label we left empty, so let's create one:
        line = line[index:]
        nonterminal = line[1:line.index("::=")].strip().lower()
        prefix = chr(0x41 + i // 26) + chr(0x41 + i % 26)
        print(prefix + nonterminal + " " + line)
        continue
    for nonterminal in nonterminals:
        line = line.replace(nonterminal, nonterminals[nonterminal])
    n1 = line.index("::=")
    nonterminal = line[:n1].strip()[1:-1]

    rules = line[n1+3:].strip().split("|")
    for i in range(len(rules)):
        rule = rules[i]
        fields = rule.split()
        for j in range(len(fields)):
            field = fields[j]
            if "<" not in field:
                fields[j] = '"' + field + '"'
            else:
                found = False
                for replacement in reverse:
                    if replacement in field:
                        found = True
                        field = field.replace(replacement, replacement[1:-1])
                if found:
                    fields[j] = field
                else:
                    fields[j] = '"' + field + '"'
        if i < len(suggestions) and suggestions[i].strip() != "":
            labelBody = suggestions[i].strip()
        else:
            labelBody = nonterminal.lower()
        labelPrefix = chr(0x41 + i // 26) + chr(0x41 + i % 26)
        print("%s%s . %s ::=" % (labelPrefix, labelBody, nonterminal), end="")
        for field in fields:    
            print(" " + field, end="")   
        print(" ;")
     

