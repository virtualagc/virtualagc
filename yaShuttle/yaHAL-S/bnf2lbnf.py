#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       bnf2lbnf.py
Purpose:        Convert the HAL-S.bnf file to HAL-S.lbnf for use with
                BNFC.  May work with other BNF input files, but I 
                don't guarantee it, because it makes no attempt to 
                correctly parse the BNF in all generality.
History:        2022-11-09 RSB  Created. 

A variety of things need to be done.

    1.  All nonterminals like <some string> need to be converted to 
        some_string ... i.e., no angular brackets and no spaces.
    2.  All terminals need to be double-quoted.
    3.  All alternatives need to be converted to separate lines, 
        terminated by semi-colons at the ends of the lines.
    4.  Each line needs to be given a label.
    
So for example,

    <all greetings> ::= hello | hola | aloha
    
might turn into

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
    line = lines[i].rstrip()
    if line[:2] == "--" or "::=" not in line:
        continue
    n1 = line.index("::=")
    nonterminal = line[:n1].strip()
    if nonterminal[:1] != "<" or nonterminal[-1:] != ">":
        print("Fatal: Illegal non-terminal")
        print(line)
        sys.exit(1)
    replacement = nonterminal.replace(" ", "_")
    replacement = replacement.replace("#", "pound")
    replacement = replacement.replace(";", "semicolon")
    replacement = replacement.replace("$", "dollar")
    replacement = replacement.replace("*", "star")
    replacement = replacement.replace("%", "percent")
    replacement = replacement.replace("=", "equals")
    replacement = replacement.replace(",", "comma")
    replacement = replacement.replace("&", "amp")
    nonterminals[nonterminal] = replacement
    
for nonterminal in nonterminals:
    reverse[nonterminals[nonterminal]] = nonterminal
    
# Second, final pass.
for i in range(len(lines)):
    line = lines[i].rstrip()
    if line[:2] == "--" or "::=" not in line:
        #print(line)
        continue
    for nonterminal in nonterminals:
        line = line.replace(nonterminal, nonterminals[nonterminal])
    n1 = line.index("::=")
    nonterminal = line[:n1].strip()[1:-1]

    # Okay, here's some ad-hoc'ery based simply on knowledge of HAL-S.bnf:
    if nonterminal == "OR":
        print('OR_1. OR ::= "|" ;')
        print('OR_2. OR ::= "OR" ;')
        continue
    if nonterminal == "CAT":
        print('CAT_1. CAT ::= "||" ;')
        print('CAT_2. CAT ::= "CAT" ;')
        continue
    
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
        print("%s_%d. %s ::=" % (nonterminal, i+1, nonterminal), end="")
        for field in fields:    
            print(" " + field, end="")   
        print(" ;")
     

