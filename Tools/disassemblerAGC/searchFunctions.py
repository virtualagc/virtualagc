#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       searchFunctions.py
Purpose:        Search for the locations of subroutines which are "special"
                in the sense that the disassembler must treat them differently
                than everyday, run-of-the-mill subroutines.  The 
                stereotypical example is INTPRET, since the disassembler has
                to recognize calls to it, to know when a transition has been 
                made from basic code to interpreter code.  Other examples are
                subroutines like BANKCALL that have an unusual calling 
                sequence that can fool the disassembler.
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.
                2022-10-13 RSB  Split off into a a separate module.

A relatively general-purpose algorithm that we can reuse for a 
variety of different targets:  INTPRET, BANKCALL, ....

The idea that for each symbol of interest we define a kind of pattern 
which the general-purpose algorithm can search for within
a given set of address ranges.  The pattern must encompass matches
for opcodes, optional matches for the operands of the opcodes, and the
possibility that certain opcodes-matches are optional.

Each special symbol is associated with a list of 
dictionaries.  Each of the dictionaries is associated with an essentially 
different pattern of instructions for the symbol.  Usually there will be
single dictionary, but sometimes the implementation in
very early AGC versions may be quite different from the implementation
in later versions, so that no single pattern works for both.  This is
the case for the ALARM subroutine.  The individual dictionaries are 
as follows:

    A list of address ranges to search.  Each address range is a tuple
    consisting of a bank number, a starting offset, and an ending offset.
    The starting offset can also be a string for a different special
    symbol rather than a number, to avoid re-searching an area in which
    a symbol (having an identical pattern) has already been found.
    
    A list of tuples, one for each instruction in the pattern.  Each
    tuple has 3 elements:
        1st:    True if the instruction is required, False if optional.
        2nd:    A list of opcode strings which are acceptable.
                If empty, any opcode will match.
        3rd:    A list of operand strings which are acceptable.
                If empty, the operands are ignored by the matching.
                Optionally, rather than the numerical operands returned
                by disassembly, it's also possible to use the names
                of symbols (as strings), of special subroutines already
                found.  As each special symbol is found, it is replaced
                in these opcode lists by its numerical value.  However,
                this can only be done for special symbols in fixed-fixed.
    The opcode and operand strings are as output by disassemblerBasic().
    Do not put optional opcodes at the *end* of a pattern (where they 
    would contribute nothing anyway), but they can be at the beginning 
    or in the middle.
    
    A count of the number of data-words following the TC/TCF, usually 
    a non-negative integer.  A count of -1 is used for special cases
    like POLY, where the number of data words is variable.
    
    A boolean value which is True if the TC does not return.

NOTE: A drawback is that for the opcode and operand strings above, you have
to know how disassemblerBasic() is going to disassemble.  For example, you
need to know that 30000 is going to be disassembled as CA 0000 rather than 
as NOOP.  The, command-line switches 
    --pattern=SYMBOL
    --dbank=BANK
    --dstart=START
    --dend=END (the first location not used in the pattern)
help get around this by printing out a template for the pattern, which can
be cut-and-pasted into the searchPatterns list.  Such patterns require
manual tweaking, usually, but are less prone to error.

For example, in the INTPRET pattern (see searchSpecial.py), we see that 
there is a single address range to search, 03,0000 through 03,0200, and that 
the pattern of opcodes we're looking for is RELINT, EXTEND, QXCH, CA, TS, MASK, TS.  
However the initial RELINT is optional, and we don't care about any of the 
operands except that CA's operand must be either 0004 or 0006.

It would be clever to somehow encode these things as regular expressions,
and thus get a much-more-flexible (and presumably more-efficient) matching
mechanism, but I haven't given that any thought.  The search is strictly
brute force at this point.

The output is a dictionary with a key for each special symbol, and values
of the form
        (bank, offset, fixedFixedAddress, searchPattern, symbol, dataWords)
If the symbol wasn't found, all of these fields will be -1.  The 
fixedFixedAddress, which is in the octal range 4000-7777 for banks 02 and 03,
will also be -1 for banks other then 02 or 03.
"""

def importFlexFile(flexFilename, searchPatterns, minFlex=8):
    f = open(flexFilename, "r")
    exp = "{"
    for line in f:
        exp += " " + line.strip()
    f.close()
    exp += "}"
    temp = eval(exp)
    willDelete = []
    for symbol in temp:
        for entry in temp[symbol]:
            #print(entry, file=sys.stderr)
            if len(entry["pattern"]) < minFlex:
                if symbol not in willDelete:
                    willDelete.append(symbol)
    for symbol in willDelete:
        print("Flex pattern for %s is too short, removing it." % symbol, file=sys.stderr)
        temp.pop(symbol)
    searchPatterns.update(temp)
    '''
    for symbol in ["U16,3740"]: #searchPatterns:
        print(symbol)
        for pattern in searchPatterns[symbol]:
            for key in pattern:
                if key == "pattern":
                    print("pattern = [")
                    for i in pattern[key]:
                        print("\t", i)
                    print("]")
                else:
                    print(key, "=", pattern[key])
    '''

# Search for all of the special patterns, a la those in 
# searchSpecial.py and searchSpecialBlockI.py.  The 
# disassembleBasic parameter is the name of the disassembler
# function to be used.
import sys
specialSubroutines = {}
def searchSpecial(core, searchPatterns, disassembleBasic, 
                    disassembleInterpretive, interpretiveStart, bankList):
    global specialSubroutines
    INTPRET = "no"
    for symbol in searchPatterns:
        specialSubroutines[symbol] = (-1, -1, -1, {}, symbol, 0) # Mark as not found.
        found = False
        for searchPattern in searchPatterns[symbol]:
            if found:
                break
            pattern = searchPattern["pattern"]
            ranges = searchPattern["ranges"]
            if "basic" not in searchPattern:
                startBasic = True
            else:
                startBasic = searchPattern["basic"]
            if len(ranges) == 0:
                ranges = []
                for bank in bankList:
                    ranges.append([bank, 0o0000, 0o2000])
            for searchRange in ranges:
                if symbol == "no":
                    print(symbol)
                    print(pattern)
                    print(searchRange)
                if found:
                    break
                bank = searchRange[0]
                startingOffset = searchRange[1]
                # Usually searchRange[1] is a number, but if it's a string,
                # then it's the name of a special symbol whose pattern, we
                # fear, will unfortunately match the symbol we're now trying
                # to find.  BANKCALL and IBNKCALL have that relationship.
                # In that case, we adjust the starting range accordingly to
                # avoid that.  This only works if the 2nd symbol we're 
                # searching for is at a higher offset than the 1st symbol 
                # we already found.
                if startingOffset in specialSubroutines:
                    startingOffset = specialSubroutines[startingOffset][1] + 1
                endingOffset = searchRange[2]
                for testOffset in range(startingOffset, endingOffset):
                    if found:
                        break
                    basic = startBasic
                    if not basic:
                        state = interpretiveStart()
                    iPat = 0 # Index into the pattern.
                    # Optional opcodes at the beginning of the pattern
                    # we can ignore for now, because they don't affect
                    # the match at all.  But we'll come back to them
                    # at the end if there has been a match, because
                    # they'll affect the address assigned to the symbol.
                    while not pattern[iPat][0]: 
                        iPat += 1
                    offset = testOffset
                    extended = False
                    lastOffset = -1
                    if symbol == "no":
                        print("------------------")
                    
                    test = False
                    if False and bank == 0o16 and testOffset == 0o3740 - 0o2000 and \
                            symbol == "U%02o,%04o" % (bank, testOffset + 0o2000):
                        test = True
                            
                    while offset < endingOffset and iPat < len(pattern):
                        if basic:
                            # We need to disassemble the instruction at the current
                            # offset, but we don't need to do that if the offset
                            # hasn't changed since the last time we disassembled.  
                            # More importantly, we must *not* do so, because the 
                            # value of 'extended' may change if we do, and a 2nd
                            # disassembly may therefore not be correct.
                            if offset != lastOffset:
                                opcode, operand, extended = \
                                    disassembleBasic(core[bank][offset], extended)
                            if test:
                                print("U%02o,%04o: basic=%r, opcode=%s, operand=%s" % \
                                        (bank, offset+0o2000, basic, opcode, operand), 
                                        file=sys.stderr)
                            lastOffset = offset
                            required = pattern[iPat][0]
                            desiredOpcodes = pattern[iPat][1]
                            desiredOperands = pattern[iPat][2]
                            if len(desiredOpcodes) == 0 or opcode in desiredOpcodes:
                                if len(desiredOperands) == 0 \
                                        or operand in desiredOperands:
                                    iPat += 1
                                    offset += 1
                                    if operand == INTPRET:
                                        operand = "INTPRET"
                                    if opcode == "TC" and operand == "INTPRET":
                                        basic = False
                                        state = interpretiveStart()
                                    continue
                            if required:
                                break
                            iPat += 1 # Note: offset does not increment.
                        else: # interpretive.
                            # For interpretive code, we can't really handle 
                            # too many alternatives because of the fact
                            # that only complete "equations" (or "strings")
                            # of lines can be meaningfully disassembled,
                            # as opposed to individual words.
                            disassembly, basic = \
                                disassembleInterpretive(core, bank, offset, state)
                            match = True
                            for d in disassembly:
                                left = d[0]
                                right = d[1]
                                if test:
                                    print("U%02o,%04o: basic=%r, left=%s, right=%s" % \
                                            (bank, offset+0o2000, basic, left, right), 
                                            file=sys.stderr)
                                if right == "":
                                    right = d[2]
                                desiredLeft = pattern[iPat][1]
                                desiredRight = pattern[iPat][2]
                                if len(desiredLeft) == 0 or left in desiredLeft:
                                    if len(desiredRight) == 0 or right in desiredRight:
                                        iPat += 1
                                        offset += 1
                                        continue
                                match = False
                                break
                            if not match:
                                break
                    if iPat >= len(pattern):
                        # At this point, we know that the pattern has been
                        # found at bank,testOffset.  However, if there were
                        # optional matches at the beginning of the pattern,
                        # those haven't been checked, so we have to check 
                        # those in case testOffset needs to be decremented.
                        fixedFixed = -1
                        if bank in [2, 3]:
                            fixedFixed = bank * 0o2000 + testOffset
                        specialSubroutines[symbol] = (bank, testOffset, 
                                                      fixedFixed, searchPattern,
                                                      symbol, 
                                                      searchPattern["dataWords"])
                        if symbol == "INTPRET":
                            INTPRET = "%04o" % fixedFixed
                        iPat = 0
                        while not pattern[iPat][0]: 
                            iPat += 1
                        offset = testOffset
                        while iPat > 0 and offset > startingOffset:
                            iPat -= 1
                            offset -= 1
                            desiredOpcodes = pattern[iPat][1]
                            desiredOperands = pattern[iPat][2]
                            opcode, operand, extended = \
                                disassembleBasic(core[bank][offset], False)
                            if opcode in desiredOpcodes:
                                if len(desiredOperands) == 0 \
                                        or operand in desiredOperands:
                                    # testOffset -= 1
                                    fixedFixed = -1
                                    if bank in [2, 3]:
                                        fixedFixed = bank * 0o2000 + offset
                                    specialSubroutines[symbol] = \
                                        (bank, offset, fixedFixed, 
                                         searchPattern, symbol, 
                                         searchPattern["pattern"])
                                    continue
                                else: # Does not match!
                                    break
                        found = True
        if found and specialSubroutines[symbol][2] != -1:
            # A numerical address for the symbol has been found in fixed-fixed.
            # If any of these symbols were used in the patterns for operands,
            # we need to replace them by their numerical values for subsequent
            # searching.
            for s in searchPatterns:
                for searchPattern in searchPatterns[s]:
                    pattern = searchPattern["pattern"]
                    for p in pattern:
                        ops = p[2]
                        if symbol in ops:
                            ops[ops.index(symbol)] = "%04o" % \
                                            specialSubroutines[symbol][2]
                            
