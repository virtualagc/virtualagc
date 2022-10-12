#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       disassemblerAGC.py
Purpose:        Disassembler for an AGC core-rope image (i.e., a .binsource 
                or .bin file).  I was tempted to call this program LUY (the 
                opposite of YUL), but I've resisted the temptation.  Mostly.
                For Block II CMC and LGC only.  Could be adapted for the
                Block I CMC, but won't work as-is.
History:        2022-09-25 RSB  Created.
                2022-09-28 RSB  Can now find not only INTPRET, but (I think)
                                all subroutines with calling sequences like
                                TC/CADR or TC/2CADR. which I believe is just
                                BANKCALL, IBNKCALL, POSTJUMP, USPRCADR for
                                the former and NOVAC, FINDVAC for the latter.
                2022-10-05 RSB  Working for core rope, I think.
                2022-10-06 RSB  Added erasable matching.
                2022-10-07 RSB  Accounted for differences between address 
                                encoding of single-word vs double-word basic
                                instructions. Fixed encoding for interpretive
                                arguments.  Began adding --check.
                2022-10-08 RSB  Added some ordering enforcement, including
                                --hint.
"""

#=============================================================================
# *** NOTE THAT MY OWN MODULES ARE IMPORTED FARTHER DOWN! ***

# Standard modules.
import sys
import copy

#=============================================================================
# Initialize globals.

# Geometry of core  and erasable memory.
numCoreBanks = 0o44
sizeCoreBank = 0o2000
numErasableBanks = 0o10
sizeErasableBank = 0o400
numIoChannels = 8

# Erasable contents.
erasable = []
for bank in range(numErasableBanks):
    erasable.append([-1]*sizeErasableBank)

# Core-rope contents.
unusedCore = -1
core = []
for bank in range(numCoreBanks):
    core.append([unusedCore]*sizeCoreBank)

# i/o channel contents
iochannels = [-1]*numIoChannels

# Disassembly contents.  There's one entry for each word of core, representing
# the disassembled form of that word.  The entries are tuples having the 
# following formats:
# For basic instructions:           (Opcode, Operand|"")
# For basic data:                   ("", Data)
# For interpretive, 2 instructions: (False, Instruction1, Instruction2)
# For interpretive, 1 instruction:  (False, Instruction, "")
# For interpretive, operand only:   (False, "", Operand)
# For interpretive, store:          (False, StoreInstruction, Address)
# In particular, basic vs interpretive is determined by 2-tuples vs 3-tuples.
unusedDisassembly = ()
disassembly = []
for bank in range(numCoreBanks):
    disassembly.append([unusedDisassembly]*sizeCoreBank)

#=============================================================================
# *** IMPORT MY OWN MODULES ***.  
# Parse command-line as a byproduct, returning options as fields in 
# global cli.

# Some temporary code useful for debugging.
from engineering import endOfImplementation
# Parse command-line arguments.
import parseCommandLine as cli
# Reader for .bin/.binsource files.
from readCoreRope import readCoreRope
# Disassembler for a single basic instruction.
from disassembleBasic import disassembleBasic
# Disassembler for a single line of interpreter instructions plus arguments.
from disassembleInterpretive import disassembleInterpretive
# Semi-emulation of instruction operations on erasable.
from semulate import semulate
# Search for "special" subroutines like INTPRET and BANKCALL.
import searchSpecial

#=============================================================================
# Read the input file.

readCoreRope(core, cli, numCoreBanks, sizeCoreBank)

#=============================================================================
# Read the --check file.

checkErasable = {}
checkCore = {}
underline = "------------"
divider = "=============================="
def addCheckSymbol(line, offset0, offset1, offset2):
    global checkErasable, checkCore
    fields = line.strip().split()
    while underline in fields:
        fields.remove(underline)
    while divider in fields:
        fields.remove(divider)
    for i in range(0, len(fields), 3):
        if "E" not in fields[i] and "F" not in fields[i]:
            continue
        symbol = fields[i+1].strip().replace("'", "!")
        address = fields[i+2].strip()
        addressFields = address.split(",")
        if len(addressFields) == 1:
            value = int(addressFields[0], 8)
            if value < 0o1400:
                bank = value // 0o400
                offset = value % 0o400
                checkErasable[symbol] = (bank, offset)
            else:
                bank = value // 0o2000
                offset = value % 0o2000
                checkCore[symbol] = (bank, offset)
        else:
            offset = int(addressFields[1], 8)
            if addressFields[0][0] == "E":
                bank = int(addressFields[0][1:], 8)
                checkErasable[symbol] = (bank, offset % 0o400)
            else:        
                bank = int(addressFields[0], 8)
                checkCore[symbol] = (bank, offset % 0o2000)

if cli.checkFilename != "":
    f = open(cli.checkFilename, "r")
    inSymbols = False
    for line in f:
        if line[:12] == "Symbol Table":
            inSymbols = True
            continue
        if "Unresolved symbols" == line[:18]:
            inSymbols = False
            continue
        if not inSymbols:
            continue
        addCheckSymbol(line, 7, 12, 25)
        addCheckSymbol(line, 55, 60, 73)
        addCheckSymbol(line, 103, 108, 121)   
    f.close

#=============================================================================
# Search for special symbols like INTPRET, BANKCALL, ....  Their addresses
# will be stored as searchSpecial.specialSubroutines["INTPRET"] (and so on).

searchSpecial.searchSpecial(core)

if cli.findFilename != "":
    print("┌─────────────────────────────────────────────────────────────────┐")
    print('│ Matches for "special" symbols or --flex symbols appear below.   │')
    print("│ Note: The special symbols found here match some AGC version,    │")
    print("│ but may not match the selected baseline.  Matches vs the        │")
    print("│ specific baseline may appear later, in the core section.        │")
    print("└─────────────────────────────────────────────────────────────────┘")
specialFixedFixed = {}
for symbol in sorted(searchSpecial.specialSubroutines):
    addressTuple = searchSpecial.specialSubroutines[symbol]
    bank = addressTuple[0]
    address = addressTuple[1]
    fAddress = addressTuple[2]
    if cli.specialOnly or cli.findFilename != "":
        if fAddress != -1:
            print("%-8s = %04o" % (symbol, fAddress))
        elif bank != -1 and address != -1:
            print("%-8s = %02o,%04o" % (symbol, bank, address + 0o2000))
        else:
            # print("%-8s" % symbol, "not found")
            pass
    if fAddress != -1:
        specialFixedFixed[fAddress] = addressTuple
        cli.entryPoints.append(    
            {   "symbol": symbol,
                "inBasic": True, 
                "bank": fAddress // sizeCoreBank, 
                "offset": fAddress % sizeCoreBank, 
                "eb": 0, "fb": 0, "feb": 0   }
        )

INTPRET = searchSpecial.specialSubroutines["INTPRET"][2]

if cli.specialOnly:
    sys.exit(0)

#=============================================================================
# Auxiliary functions.

# For instructions like "TC SYMBOL", tries to determine how many data words 
# follow the TC ... e.g., if the invocation is
#
#           TC      SYMBOL
#           OCT     ...
#           ...
#           OCT     ...
#
# the question being answered is "How many OCTs are there?"  Usually there are
# 0, of course, but for the various "special subroutines" searched for above,
# there's often a fixed number of 1 or 2 OCTs.  However, there are also weird
# cases among the special subroutines (POLY, PHASCHNG, ...) where the number
# of OCTs is variable, and has to be determined by explicitly parsing the next
# word(s) immediately following the TC.  That's what the following function.
# does. Comanche 055 is taken as the official documentation for figuring this
# out.
def getDataWords(core, bank, offset, symbol, dataWords):
    offset += 1
    if symbol == "POLY":
        # The data words are the SP degree and the DP
        # coefficients of the polynomial.
        degree = core[bank][offset]
        dataWords = 1 + 2 * (degree + 1)
    elif symbol in ["PHASCHNG", "2PHSCHNG"]:
        dataWords = 1 # Will increment below in various ways.
        if symbol == "2PHSCHNG":
            dataWords += 1
            offset += 1
        firstWord = core[bank][offset]
        phasechangeType = (firstWord & 0o14000) >> 11
        A = firstWord & 0o02000
        if phasechangeType == 0: # "type A"
            D = 0
        elif phasechangeType == 1: # "type C"
            D = firstWord & 0o01000
        else: # phasechangeType == 2 or 3, "type B"
            D = firstWord & 0o04000
        if D > 0:
            dataWords += 1
        if A > 0:
            dataWords += 2
    return dataWords

# Disassemble a memory range, which can include any combination of basic
# and interpreter instructions.  But cannot contain data, unless it's
# related the the case of a TC to a special function that requires data
# word(s) immediately following the TC.  The parameters are:
#   core, erasable, iochannels are (usually) the global structures of the
#               same name.  For recursive use of disassembleRange, though,
#               local copies of erasable and iochannels are used instead.
#               Basically, they are only used by the response function (see
#               below), and then only if the response function calls 
#               semulate().  In other words, if the response function does 
#               not use semulate(), then erasable and iochannels could be 
#               set to anything (such as an integer), in order to minimize 
#               execution time and memory usage.
#   bank        The memory-bank number.
#   start       Starting address within the bank.  This is the 4-digit part
#               of the address (2000-7777) as it would appear in fixed-fixed
#               (4000-7777) or fixed (XX,2000-XX,3777), and not the offset
#               (0000-1777) into the bank.  Disassembling erasable is not
#               supported.
#   end         Stop when reaching this address.  I.e., end-1 is
#               the last address actually disassembled.
#   response    A function to be executed after each location is
#               disassembled.  Such a function has parameters:
#                   core, erasable, iochannels (as above)
#                   occasion    0 - octal, 1 - basic, 2 - interpretive.
#                   bank        (as above)
#                   address     (as in start, end above)
#                   left        The opcode for basic, or left opcode 
#                               for interpretive.
#                   right       The operand for basic, or right opcode
#                               or argument for interpretive.
#               The response function returns True if it wants the
#               the disassembly to end (if, for example, it is performing
#               pattern matches and has succeeded in finding a match), but
#               in general returns False.
#   inBasic     Boolean. True if the first address is a basic
#               instruction, False if the first address is
#               interpretive.
#   autoQuit    Boolean. True if should quit prior to reaching the selected
#               end address when reaching a TCF or a TC that is believed
#               not to return, or other similar conditions in which there
#               is reason to believe that the next address won't contain
#               disassemblable code. 
#   autoCCS     Boolean.  The CCS instruction is problematic in regard to 
#               autoQuit=True; the 4 successive locations are typically all
#               basic code, but sometimes they are not.  For maximal 
#               prudence, therefore, we should immediately quit upon
#               encountering any CCS (autoCCS=True).  For typical 
#               scenarios (autoCCS=False), on the other hand, not only would 
#               we not want to quit upon finding a CCS, but indeed would not 
#               want to quit on TCF instructions in the 3 words immediately 
#               following the CCS ... but would still want to quit for a TCF
#               in the fourth word.
# The disassembleRange() function returns False, unless it terminates early
# due to a response function, in which case it returns True.

def disassembleRange(core, erasableOnEntry, iochannelsOnEntry, bank, start, 
                     end, response, inBasic=True, autoQuit=False,
                     autoCCS=False):
    startInterp = False
    erasable = copy.deepcopy(erasableOnEntry)
    iochannels = copy.deepcopy(iochannelsOnEntry)
    dataWords = 0
    extended = 0
    stadr = False
    address = start
    sinceCCS = 10
    while address < end:
        offset = address % 0o2000
        if dataWords > 0:
            if response(core, erasable, iochannels, 0, bank, address, "OCT", 
                    "%05o" % core[bank][offset]):
                return True
            dataWords -= 1
            address += 1
            continue
        if inBasic:
            noReturn = False
            opcode, operand, extended = \
                disassembleBasic(core[bank][offset], extended)
            try:
                nOperand = int(operand, 8)
            except:
                nOperand = -1
            if opcode == "TC" and nOperand in specialFixedFixed:
                    searchPattern = specialFixedFixed[nOperand][3]
                    symbol = specialFixedFixed[nOperand][4]
                    operand = symbol
                    noReturn = searchPattern["noReturn"]
                    dataWords = getDataWords(core, bank, offset, symbol, 
                                             searchPattern["dataWords"])
                    if symbol == "INTPRET":
                        inBasic = False
            if response(core, erasable, iochannels, 
                     1, bank, address, opcode, operand):
                return True
            address += 1
            
            if autoQuit:
                # Quit prematurely if we can't predict that the next
                # address will contain code, or what type of code it is,
                # due to a transfer of control. Conditional branches, 
                # by the way, are no problem.
                
                sinceCCS += 1
                
                if opcode in ["RETURN", "RESUME"]:
                    break
                # Various other instructions for which I decline to predict
                # the behavior vis-a-vis transfer of control.
                elif opcode in ["DTCB", "DTCF", "EDRUPT", 
                                "TCAA", "XLQ", "XXALQ"]:
                    break
                # Is a TC to a "special function" known not to return?
                elif opcode == "TC" and noReturn:
                    break
                # A TCF instruction does not return.  However, there are
                # exceptions to consider:  In a jump table, there will be
                # a long series of TCF instructions, on which we shouldn't
                # quit.  Also, TCFs in the 3-word shadow of a CCS shouldn't
                # be cause to quit.
                elif opcode == "TCF":
                    if sinceCCS > 3:
                        dummyOpcode, dummyOperand, dummyExtended = \
                            disassembleBasic(core[bank][offset+1], extended)
                        if dummyOpcode != "TCF":
                            break
                # CCS
                elif opcode == "CCS":
                    if autoCCS:
                        break
                    else:
                        sinceCCS = 0
        else:
            if startInterp:
                print("A.1 %02o %04o" % (bank, offset))
            disassembly, stadr, inBasic = \
                disassembleInterpretive(core, bank, offset, stadr)
            if startInterp:
                print("A.1.5", disassembly)
            if startInterp:
                print("A.2")
            for entry in disassembly:
                left = entry[0]
                right = entry[1]
                argument = entry[2]
                if right == "":
                    right = argument
                if response(core, erasable, iochannels,
                         2, bank, address, left, right):
                    return True
                offset += 1
                address += 1
            if startInterp:
                print("A.3")
    return False
    
#=============================================================================
# Perform some options (based on command-line settings), which bypass
# all of the normal disassembly workflow and then exit.

# Command-line switch:  --dump
if cli.dump:
    for bank in [2, 3, 0, 1] + list(range(4, numCoreBanks)):
        print()
        print("BANK=%o" % bank)
        for row in range(128):
            if row % 4 == 0:
                print()
            if row % 32 == 0:
                if row > 0:
                    print(";")
                    print()
            line = ""
            for col in range(8):
                o = core[bank][8 * row + col]
                if o == unusedCore:
                    line += "  @   "
                else:
                    line += "%05o " % o
            print(line)
    sys.exit(0)

# Command-line switch:  --specs

# Converts an opcode,operand pair into a pattern for pattern matching.
# The occasion parameter is 0 for data, 1 for basic, 2 for interpretive.
def patternize(occasion, opcode, operand):
    if occasion == 0:
        pattern = "_"
    else:
        pattern = opcode + "_"
        # Recognize operands we have to ignore, which are
        # NNNN or NN,NNNN.
        fields = operand.split(",")
        if not fields[0].isdigit() or \
                (len(fields) > 1 and not fields[1].isdigit()):
            pattern += operand
    return pattern

if cli.specsFilename != "":

    # A response function for disassembleRange().
    def printSpec(core, erasable, iochannels,
                  occasion, bank, address, opcode, operand):
        print("\t" + patternize(occasion, opcode, operand))
        return False

    # First, read the entire specifications file selected on the
    # command line into memory as the patternSpecs list.
    f = open(cli.specsFilename, "r")
    patternSpecs = []
    erasableSpecs = []
    lastBank = 0
    for line in f:
        fields = line.upper().split("#")[0].strip().split()
        if len(fields) == 0:
            continue
        if fields[0] not in [ "+", "-" ] and fields[1] != "=": # Spec for core
            for i in range(len(fields)):
                # Remove any extraneous comma at the end of the field.
                if fields[i][-1:] == "," and fields[i][:-1].isdigit():
                    fields[i] = fields[i][:-1]
                if fields[i].isdigit():
                    fields[i] = int(fields[i], 8) % 0o2000
            if fields[1] == ".":
                fields[1] = lastBank
            elif isinstance(fields[1], int):
                lastBank = fields[1]
            patternSpec = { "symbol": fields[0], "dbank": fields[1], 
                            "dstart": fields[2], "inBasic": True}
            for i in range(3, len(fields)):
                if fields[i] == "I":
                    patternSpec["inBasic"] = False
                elif isinstance(fields[i], int):
                    patternSpec["dend"] = fields[i]
            patternSpecs.append(patternSpec)
        elif len(fields) in [3, 5]:  # Spec for erasable or program label aliases.
            erasableSpecs.append(line.strip())
    f.close()

    for i in range(len(patternSpecs)):
        if "dend" not in patternSpecs[i]:
            patternSpecs[i]["dend"] = patternSpecs[i+1]["dstart"]
            
    # Now iterate through all of the different specification in the 
    # patternSpecs list, forming patterns suitable for pattern-matching.
    for patternSpec in patternSpecs:
        symbol = patternSpec["symbol"]
        if patternSpec["inBasic"]:
            print(symbol, "basic")
        else:
            print(symbol, "interpretive")
        disassembleRange(core, erasable, iochannels,
                         patternSpec["dbank"], patternSpec["dstart"], 
                         patternSpec["dend"], printSpec, 
                         patternSpec["inBasic"])
    # And write out the erasable specs, which we're just passing through
    # as-is:
    for spec in erasableSpecs:
        print(spec)
    sys.exit(0)

# Command-line switch:  --pattern
if cli.pattern:
    indent = '                '
    
    # A response function for disassembleRange().
    def printPattern(core, erasable, iochannels,
                     occasion, bank, address, opcode, operand):
        operandString = '"' + operand + '"'
        if len(operand) == 4 and operand.isdigit():
            operandString = ''
        print(indent + '        [True, ["%s"], [%s]],' % \
              (opcode, operandString))
        return False
    
    print('    "%s": [{' % cli.symbol)
    print(indent + '    "dataWords": 0,')
    print(indent + '    "noReturn": False,')
    print(indent + '    "pattern": [')
    disassembleRange(core, erasable, iochannels, 
                     cli.dbank, cli.dstart, cli.dend, printPattern, 
                     cli.dbasic)
    print(indent + '     ],')
    print(indent + '    "ranges": [[0o%02o, 0o0000, 0o2000]]' % cli.dbank)
    print(indent + '}],')
    sys.exit(0)

# Command-line switch:  --dtest
if cli.dtest:

    # A response function for disassembleRange().
    def printDisassembly(core, erasable, iochannels,
                         occasion, bank, address, left, right):
        print("%02o,%04o    %05o         %-12s %s" \
              % (bank, address, core[bank][address % 0o2000], left, right))
        return False
    
    disassembleRange(core, erasable, iochannels,
                     cli.dbank, cli.dstart, cli.dend, printDisassembly, 
                     cli.dbasic)
    sys.exit(0)
    
# Command-line switch:  --find
if cli.findFilename != "":

    # In the specs file and internally for this matching process, symbol names
    # that are supposed to contain an apostrophe have an exclamation point 
    # instead.  The following function is used to reverse this in symbols as
    # they're printed out.
    def norm(symbol):
        return symbol.replace("!", "'")

    # First step: Read in the entire pattern file into the dictionaries
    # desiredMatches
    erasableSpecs = []
    programLabelAliasSpecs = {}
    fixedReferences = {}
    desiredMatches = { "basic": {}, "interpretive": {}}
    maxPatternLength = { "basic": 0, "interpretive": 0}
    basicOrInterpretive = "(none)"
    symbol = "(none)"
    desiredOrdering = { "basic": [], "interpretive": [] }

    f = open(cli.findFilename, "r")
    for line in f:
        fields = line.strip().split()
        if len(fields) < 1:
            continue
        if fields[0] == "+": # Erasable specs
            symbols = \
                fields[1].replace("['", "").replace("']", "").split("','")
            references = fields[2].replace("[(", "").replace(")]", "")
            references = references.split("),(")
            for i in range(len(references)):
                references[i] = references[i][1:-1]
                r1 = references[i].split("',")
                r2 = r1[1].split(",'")
                references[i] = (r1[0], int(r2[0]), r2[1])
            erasableSpecs.append({  "symbols": symbols,
                                    "references": references,
                                    "referencedAddresses": [] })
        elif fields[0] == "-": # Specs for references to fixed.
            referencedSymbol = fields[1]
            if referencedSymbol not in fixedReferences:
                fixedReferences[referencedSymbol] = []
            fixedReferences[referencedSymbol].append( 
                (fields[2], int(fields[3], 8), fields[4])
            )
            
        elif len(fields) > 1 and fields[1] == "=": # Program label alias specs
            if fields[2] not in programLabelAliasSpecs:
                programLabelAliasSpecs[fields[2]] = []
            programLabelAliasSpecs[fields[2]].append((int(fields[4], 8), 
                                                          fields[0]))
        elif line[:1] != '\t': # Core rope specs
            symbol = fields[0]
            basicOrInterpretive = fields[1]
            desiredMatches[basicOrInterpretive][symbol] = []
            desiredOrdering[basicOrInterpretive].append(symbol)
        else:
            desiredMatches[basicOrInterpretive][symbol].append(line.strip())
    for symbol in cli.ignore:
        for basicOrInterpretive in ["basic", "interpretive"]:
            if symbol in desiredMatches[basicOrInterpretive]:
                desiredMatches[basicOrInterpretive].pop(symbol)
                desiredOrdering[basicOrInterpretive].remove(symbol)
    f.close()
    for basicOrInterpretive in ["basic", "interpretive"]:
        for symbol in desiredMatches[basicOrInterpretive]:
            if len(desiredMatches[basicOrInterpretive][symbol]) \
                    > maxPatternLength[basicOrInterpretive]:
                maxPatternLength[basicOrInterpretive] \
                    = len(desiredMatches[basicOrInterpretive][symbol])
            if False:
                print(symbol, basicOrInterpretive, 
                    desiredMatches[basicOrInterpretive][symbol])
    symbolsSought = { "basic": desiredMatches["basic"].keys(),
                      "interpretive": desiredMatches["interpretive"].keys()}
    symbolsFound = { "basic": {}, "interpretive": {}}
    
    print("┌─────────────────────────────────────────────────────────────────┐")
    print("│ Matches of the core rope vs the specific baseline appear below. │")
    print("│ Note:  Symbols of the form 'Rbb,aaaa' do not appear in baseline │")
    print("│ source code.  They apply to code that is unlabeled in the       │")
    print("│ baseline but that immediately succeeds data.                    │")
    print("└─────────────────────────────────────────────────────────────────┘")

    # Next, try to find these patterns in core.  This is entirely a
    # brute-force procedure which does not rely on recursive disassembly.
    # We simply go to each location in every memory bank, and start 
    # disassembling until we either find one of the patterns or else 
    # can eliminate all of them, at which point we move on to the next
    # location.
    
    coreUsed = []
    for bank in range(0o44):
        coreUsed.append([False]*0o2000)
    
    # Response function for disassembleRange().
    symbols = []
    indexIntoPatterns = 0
    basicOrInterpretive = "basic"
    def match(core, erasable, iochannels,
                  occasion, bank, address, opcode, operand):
        global symbols, indexIntoPatterns, cli
          
        # Turn current disassembled location into a pattern.
        pattern = patternize(occasion, opcode, operand)
        
        # Now try to match the pattern with those read from the specs file.
        if cli.disjoint and coreUsed[bank][address % 0o2000]:
            symbols = []
        if len(symbols) == 0:
            #print("I am here")
            return True
        forElimination = []
        for symbol in symbols:
            desiredPatterns = desiredMatches[basicOrInterpretive][symbol]
            if len(desiredPatterns) <= indexIntoPatterns:
                print("Implementation error A", "%02o" % bank, 
                    "%04o" % address, symbol, indexIntoPatterns, 
                    len(desiredPatterns), desiredPatterns)
                sys.exit(1)
            desiredPattern = desiredPatterns[indexIntoPatterns]
            if desiredPattern != pattern:
                forElimination.append(symbol)
            elif indexIntoPatterns == len(desiredPatterns) - 1:
                # Match!  However, if it's one of those symbols we're
                # supposed to skip the initial matches for, then let's do
                # that instead.
                if symbol not in cli.skips \
                        or cli.skips[symbol] == 0:
                    symbols = [symbol]
                    return True
                else:
                    cli.skips[symbol] -= 1
                    forElimination.append(symbol)
        for symbol in forElimination:
            symbols.remove(symbol)
        indexIntoPatterns += 1
        return False
    
    if len(cli.oBanks) > 0:
        findBanks = cli.oBanks.split(",")
        for i in range(len(findBanks)):
            findBanks[i] = int(findBanks[i], 8)
    else:
        findBanks = list(range(numCoreBanks))
    if len(cli.pBanks) > 0:
        dummy = cli.pBanks.split(",")
        for i in range(len(dummy)):
            dummy[i] = int(dummy[i], 8)
            findBanks.remove(dummy[i])
        findBanks = dummy + findBanks
    for bank in findBanks:
        #print("# Match bank %02o." % bank)
        for address in range(0o2000, sizeCoreBank + 0o2000):
            avoiding = False
            for avoid in cli.avoid:
                if bank == avoid[0] and address >= avoid[1] \
                        and address < avoid[2]:
                    avoiding = True
                    break
            if avoiding:
                continue
            for basicOrInterpretive in ["basic", "interpretive"]:
                inBasic = (basicOrInterpretive == "basic")
                if len(symbolsSought[basicOrInterpretive]) == 0:
                    break
                if len(symbolsSought[basicOrInterpretive]) == 0:
                    break
                if cli.disjoint and coreUsed[bank][address % 0o2000]:
                    continue
                symbols = []
                for symbol in desiredOrdering[basicOrInterpretive]:
                    ok = True
                    if symbol in cli.hintAfter:
                        for before in cli.hintAfter[symbol]:
                            if before in desiredOrdering["basic"] or \
                                    before in desiredOrdering["interpretive"]:
                                ok = False
                                break
                    if ok:
                        symbols.append(symbol)
                indexIntoPatterns = 0
                end = address + maxPatternLength[basicOrInterpretive]
                if end > sizeCoreBank + 0o2000:
                    end = sizeCoreBank + 0o2000
                if disassembleRange(core, erasable, iochannels,
                                 bank, address, end, match, 
                                 inBasic):
                    # If a match has been found at this address,
                    # the symbols list should now contain a
                    # single entry, which is the name of the
                    # match.  Otherwise, it should be the case
                    # that the symbols list is now empty.
                    if len(symbols) > 1:
                        print("Implementation error B")
                        sys.exit(1)
                    elif len(symbols) == 0:
                        continue
                    symbol = symbols[0]
                    symbolsFound[basicOrInterpretive][symbol] \
                        = (bank, address)
                    endAddress = address + \
                        len(desiredMatches[basicOrInterpretive][symbol])
                    for a in range(address, endAddress):
                        if False and bank == 0o16 and a >=0o2504 and a < 0o2520:
                            print(symbol, "overwriting %02o,%04o" % (bank, a))
                        coreUsed[bank][a % 0o2000] = True
                    del desiredMatches[basicOrInterpretive][symbol]
                    desiredOrdering[basicOrInterpretive].remove(symbol)
                    symbolsSought = { 
                        "basic": desiredMatches["basic"].keys(),
                        "interpretive": desiredMatches["interpretive"].keys()
                        }
                    nSymbol = norm(symbol)
                    if bank in [2, 3]:
                        print("%-8s = %04o (%02o,%04o)" % \
                            (nSymbol, 0o2000 * bank + address % 0o2000,
                             bank, address))
                        if nSymbol in programLabelAliasSpecs:
                            for spec in programLabelAliasSpecs[nSymbol]:
                                print("%-8s = %04o (%02o,%04o)" % \
                                    (spec[1], 0o2000 * bank + \
                                     address % 0o2000 + spec[0],
                                     bank, address + spec[0]))
                                symbolsFound[basicOrInterpretive][spec[1]] = \
                                    (bank, address + spec[0]) 
                                    
                    else:
                        print("%-8s = %02o,%04o" % (nSymbol, bank, address))
                        if nSymbol in programLabelAliasSpecs:
                            for spec in programLabelAliasSpecs[nSymbol]:
                                print("%-8s = %02o,%04o" % (spec[1], bank, \
                                                        address + spec[0]))
                                symbolsFound[basicOrInterpretive][spec[1]] = \
                                    (bank, address + spec[0])

    #print("symbolsFound =", symbolsFound)
    #print("symbolsSought =", symbolsSought)
        
    # At this point, the program labels have undergone matching.  We'd now
    # like to use the results of those matches for erasable matching as well.
    # The idea is that each erasable symbol defined in baseline erasable, we
    # have a list of the subroutines that reference them, and the lines of
    # the subroutine that do so.  For any of those subroutines that have been
    # matched above, we can go to those lines of the subroutines in the 
    # rope dump and find the address being used.  If it's the same address
    # for all of the references, then we can assume that that's the address
    # associated with that particular erasable symbol in the rope dump.
    foundErasables = {}
    print("┌─────────────────────────────────────────────────────────────────┐")
    print("│ Matches for variables in erasable memory appear below.          │")
    print("└─────────────────────────────────────────────────────────────────┘")
    totalCertainErasables = 0
    totalUncertainErasables = 0
    totalUnreferencedErasables = 0
    for spec in erasableSpecs:
        symbols = spec["symbols"]
        references = spec["references"]
        for reference in references:
            programLabel = reference[0]
            if programLabel in symbolsFound["basic"]:
                location = symbolsFound["basic"][programLabel]
                foundBasic = True
            elif programLabel in symbolsFound["interpretive"]:
                location = symbolsFound["interpretive"][programLabel]
                foundBasic = False
            else:
                spec["referencedAddresses"].append("(none)")
                continue
            bank = location[0]
            lineNumber = reference[1]
            address = location[1] + lineNumber
            referenceType = reference[2]
            context = core[bank][address % 0o2000]
            if referenceType in ["B", "C", "D"]:
                if referenceType == 'C':
                    context = ~context
                elif referenceType == 'D':
                    context -= 1
                context &= 0o1777
                if context < 0o1400:
                    referenced1 = context // 0o400
                    referenced2 = 0o1400 + (context % 0o400)
                    referencedAddress = "E%o,%04o" % (referenced1, referenced2)
                else:
                    referenced2 = 0o1400 + (context % 0o400)
                    referencedAddress = "E?,%04o" % referenced2
            elif referenceType in ['S', 'A', 'L', 'I', 'E']:
                if referenceType == 'I':
                    context = ~context
                if referenceType not in ['L', 'E']:
                    context -= 1
                context &= 0o3777
                referenced1 = context // 0o400
                referenced2 = 0o1400 + (context % 0o400)
                if referenceType == 'E' and context > 0o03:
                    referencedAddress = "E?,%04o" % referenced2
                else:
                    referencedAddress = "E%o,%04o" % (referenced1, referenced2)  
            spec["referencedAddresses"].append(referencedAddress)
        # Information about all code references to this erasable symbol
        # collected.  We now have to perform some statistics to decide
        # what we can report about what address we can report for this
        # symbol.
        sSymbols = str(sorted(symbols)).replace("[", "").replace("]", "")
        sSymbols = sSymbols.replace("'", "").replace(", ", " = ")
        stats = {}
        for i in range(len(spec["references"])):
            programLabel = spec["references"][i]
            a = spec["referencedAddresses"][i]
            if a == "(none)":
                continue
            if a not in stats:
                stats[a] = [programLabel]
            else:
                stats[a].append(programLabel)
        keys = list(stats.keys())
        certain = False
        if len(keys) == 1:
            certain = True
            chosen = keys[0]
        elif len(keys) == 2:
            if (keys[0][1] == "?" or keys[1][1] == "?") \
                    and keys[0][2:] == keys[1][2:]:
                if keys[0][1].isdigit():
                    chosen = keys[0]
                else:
                    chosen = keys[1]
                certain = True 
            else:
                chosen = "E?,????" 
        else:
            chosen = "E?,????"
        total = 0
        for stat in stats:
            total += len(stats[stat])
        if not certain:
            print("┌─────────────────────────────────────────────────────────────────┐")
            if total == 0:
                print("│ Unable to detect references to the following variable.          │")
            else:
                print("│ Discrepancies for review:                                       │")
            for stat in stats:
                msg = stat + ":"
                for p in stats[stat]:
                    if len(msg) > 48:
                        print("│ %-63s │" % msg)
                        msg = "        "
                    msg += "  %s +%o" % (norm(p[0]), p[1])
                print("│ %-63s │" % msg)
            print("└─────────────────────────────────────────────────────────────────┘")
        elif chosen[:3] in ["E0,", "E1,", "E2,"]:
            bank = int(chosen[1], 8)
            address = int(chosen[3:], 8)
            chosen = "%04o (%s)" % (0o400 * bank + address % 0o400, chosen)
        if chosen != "E?,????":
            for symbol in symbols:
                foundErasables[symbol] = chosen
        total = 0
        for stat in stats:
            total += len(stats[stat])
        print("%-8s" % norm(sSymbols), "=", chosen, "(%d references)" % total)
        if total == 0:
            totalUnreferencedErasables += 1
        elif certain:
            totalCertainErasables += 1
        else:
            totalUncertainErasables += 1
     
    print("┌─────────────────────────────────────────────────────────────────┐")
    print("│ Matches for references to fixed memory appear below.            │")
    print("└─────────────────────────────────────────────────────────────────┘")
    # Quick pass to get a list of all the references.
    # keys are the referenced symbol, values are lists of triples,
    # (referencing symbol, offset within symbol, 12-bit address)
    observedReferences = {}
    fixedFound = {}
    for referencedSymbol in sorted(fixedReferences):
        if referencedSymbol in symbolsFound["basic"] or \
                referencedSymbol in symbolsFound["interpretive"]:
                    continue
        for references in fixedReferences[referencedSymbol]:
            referringSymbol = references[0]
            offsetFromReferrer = references[1]
            referenceType = references[2]
            if referringSymbol in symbolsFound["basic"]:
                location = symbolsFound["basic"][referringSymbol]
            elif referringSymbol in symbolsFound["interpretive"]:
                location = symbolsFound["interpretive"][referringSymbol]
            else:
                continue
            if referencedSymbol not in observedReferences:
                observedReferences[referencedSymbol] = []
            bank = location[0]
            offset = (location[1] + offsetFromReferrer) % 0o2000
            context = core[bank][offset]
            if referenceType in ['b', 'd']:
                address12 = context & 0o7777
                if referenceType == 'd':
                    address12 -= 1
                if address12 < 0o2000:
                    continue
                observedReferences[referencedSymbol].append([address12, references])
    # Final pass to check for consistency and print report.
    for referencedSymbol in sorted(observedReferences):
        #print("here A", referencedSymbol, observedReferences[referencedSymbol], file=sys.stderr)
        references = observedReferences[referencedSymbol]
        referencesByAddress = {}
        for reference in references:
            #print("here B", reference, references, file=sys.stderr)
            referencingSymbol = reference[1][0]
            offsetWithinReference = reference[1][1]
            address12 = reference[0]
            if address12 not in referencesByAddress:
                referencesByAddress[address12] = {}
            if referencingSymbol not in referencesByAddress[address12]:
                referencesByAddress[address12][referencingSymbol] = []
            referencesByAddress[address12][referencingSymbol].append(offsetWithinReference)
        keys = list(referencesByAddress.keys())
        if len(keys) == 0:
            continue
        elif len(keys) == 1:
            address12 = keys[0]
            if address12 >= 0o4000:
                bank = address12 // 0o2000
                add = 0o2000 + address12 % 0o2000
                print("%-8s = %04o (%02o,%04o) (%d references)" % (referencedSymbol, \
                                                address12, bank, add, len(references)))  
                fixedFound[referencedSymbol] = (bank, add)
            else:
                bank = "??"
                add = address12
                print("%-8s = ??,%04o (%d references)" % (referencedSymbol, \
                                                address12, len(references)))  
                fixedFound[referencedSymbol] = (bank, add)
        elif len(keys) == 2 and (keys[0] % 0o2000 == keys[1] % 0o2000) \
                and (keys[0] < 0o4000 or keys[1] < 0o4000):
            bank = "??"
            add = address12 % 0o2000 + 0o2000
            print("%-8s = ??,%04o (%d reference)" % (referencedSymbol, \
                                            address12, len(references)))  
            fixedFound[referencedSymbol] = (bank, add)
        else:
            for a in sorted(referencesByAddress):
                print("# %05o" % a)    
            print("%s = ??,???? (%d references)" % (referencedSymbol, len(references)))
    
    print()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("Summary of the match process.")
    print()
    print("Special symbols:")
    found = 0
    notFound = 0
    for symbol in sorted(searchSpecial.specialSubroutines):
        addressTuple = searchSpecial.specialSubroutines[symbol]
        bank = addressTuple[0]
        address = addressTuple[1]
        fAddress = addressTuple[2]
        if fAddress == -1 and (bank == -1 or address == -1):
            print("%-8s" % norm(symbol), "not found")
            notFound += 1
        else:
            found += 1
    print("Total matched:", found)
    print("Total unmatched:", notFound)     
    print()
    print("Core:")
    for basicOrInterpretive in ["basic", "interpretive"]:
        for symbol in symbolsSought[basicOrInterpretive]:
            print("%s (%s) not found" % (norm(symbol), basicOrInterpretive))
    print("Total matched: %d (basic), %d (interpretive)" % \
        (len(symbolsFound["basic"]), len(symbolsFound["interpretive"])))
    print("Total unmatched:  %d (basic), %d (interpretive)" % \
        (len(symbolsSought["basic"]), len(symbolsSought["interpretive"])))
    print()
    print("Erasable:")
    print("Total matched:", totalCertainErasables)
    print("Total partially matched:", totalUncertainErasables) 
    print("Total unreferenced by code:", totalUnreferencedErasables)
    print("Note: Map of core used by disassembly is in disassemblerAGC.core.")
    f = open("disassemblerAGC.core", 'w')
    for bank in range(0o44):
        print("BANK = %02o" % bank, file=f)
        for offset in range(0, 0o2000, 0o100):
            row = "%04o:" % (offset + 0o2000)
            for i in range(0o100):
                if 0 == i % 8:
                    row += " "
                if coreUsed[bank][offset + i]:
                    row += "X"
                else:
                    row += "O"
            print(row, file=f)
    f.close()
    
    if cli.checkFilename != "":
    
        print()
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("Cross-check vs baseline assembly listing.")
        print()
        print("Core:")
        coreMatch = 0
        coreMismatch = 0
        for basic in symbolsFound:
            for symbol in symbolsFound[basic]:
                bank1 = symbolsFound[basic][symbol][0]
                address1 = symbolsFound[basic][symbol][1] % 0o2000
                if symbol in checkCore:
                    bank2 = checkCore[symbol][0]
                    address2 = checkCore[symbol][1]
                else:
                    fields = symbol.split(",")
                    if len(fields) == 2 and fields[0][0] == "R" \
                            and fields[0][1:].isdigit() \
                            and fields[1].isdigit():
                        bank2 = int(fields[0][1:], 8)
                        address2 = int(fields[1], 8) % 0o2000
                    else:
                        print("Implementation error:  Symbol check", norm(symbol))
                        continue
                if bank1 == bank2 and address1 == address2:
                    coreMatch += 1
                else:
                    coreMismatch += 1
                    print("%-8s is at %02o,%04o but should be at %02o,%04o" \
                        % (norm(symbol), bank1, address1 + 0o2000,
                            bank2, address2 + 0o2000))
                            
        print("Total matched =", coreMatch)
        print("Total unmatched =", coreMismatch)
        
        print()
        print("Erasable:")
        erasableMatch = 0
        erasablePartialMatch = 0
        erasableMismatch = 0
        for symbol in sorted(foundErasables):
            #print(symbol, "=", foundErasables[symbol])
            found = foundErasables[symbol].replace("(", "").replace(")", "")
            fields = found.split(",")
            bank1 = fields[0][-1]
            if bank1 != "?":
                bank1 = int(bank1, 8)
            address1 = int(fields[1], 8)
            bank2 = checkErasable[symbol][0]
            address2 = checkErasable[symbol][1] + 0o1400
            if bank1 == bank2 and address1 == address2:
                erasableMatch += 1
            elif bank1 == "?" and address1 == address2:
                erasablePartialMatch += 1
            else:
                erasableMismatch += 1
                if bank1 == "?":
                    print("%-8s E?,%04o != E%o,%04o" % \
                        (norm(symbol), address1, bank2, address2))
                else:
                    print("%-8s E%o,%04o =? E%o,%04o" % \
                        (norm(symbol), bank1, address1, bank2, address2))
        print("Total matched =", erasableMatch)
        print("Total consistent =", erasablePartialMatch)
        print("Total mismatched =", erasableMismatch)
        
        print()
        print("Fixed references:")
        fixedMatch = 0
        fixedPartialMatch = 0
        fixedMismatch = 0
        for symbol in sorted(fixedFound):
            found = fixedFound[symbol]
            bank1 = found[0]
            address1 = found[1]
            bank2 = checkCore[symbol][0]
            address2 = checkCore[symbol][1] + 0o2000
            if bank1 == bank2 and address1 == address2:
                fixedMatch += 1
            elif bank1 == "??" and address1 == address2:
                fixedPartialMatch += 1
            else:
                fixedMismatch += 1
                if bank1 == "??":
                    print("%-8s ??,%04o != %02o,%04o" % \
                        (norm(symbol), address1, bank2, address2))
                else:
                    print("%-8s %02o,%04o =? %02o,%04o" % \
                        (norm(symbol), bank1, address1, bank2, address2))
        print("Total matched =", fixedMatch)
        print("Total consistent =", fixedPartialMatch)
        print("Total mismatched =", fixedMismatch)
                
    sys.exit(0)
    
#=============================================================================
# Recursive disassembly.  Each invocation tries to disassemble from the 
# starting offset to the end of the bank, descending recursively wherever it
# finds a transfer of control, but stopping if it finds a blocking
# condition such as reaching a location that has already been disassembled
# or unconditionally jumping away.  Each invocation of disassemble() is
# passed a dictionary structured as follows:
#   {
#       "inBasic": ...,
#       "bank": ..., 
#       "offset": ...,
#       "fb": ...,
#       "eb": ...
#   }
if cli.descent:
    if True:

        # A response function for disassembleAGC() as called from
        # disassemble().
        def controlTransferCheck(core, erasable, iochannels, 
                                 occasion, bank, address, left, right):
            offset = address % 0o2000
            if cli.debug:
                print("%02o,%04o EB=%05o FB=%05o "
                      "FEB=%05o A=%05o L=%05o Q=%05o"
                      "    %05o         %-12s %s" \
                          % (bank, address, erasable[0][3], erasable[0][4],
                             iochannels[7], erasable[0][0], erasable[0][1],
                             erasable[0][2],
                             core[bank][offset], left, right))
            disassembly[bank][offset] = (left, right)

            # Try to track effect on erasable and/or io channels.
            if occasion == 1:
                semulate(core, erasable, iochannels, left, right)
                # More TBD.

        def disassemble(erasable, iochannels, entryPoint):
            global disassembly
            
            bank = entryPoint["bank"]
            offset = entryPoint["offset"]
            entryPointString = "%02o,%04o" % (bank, offset + 0o2000)
            if disassembly[bank][offset] != unusedDisassembly:
                if cli.debug:
                    print("Already ", entryPointString, 
                        " -------------------------------")
                return
            if cli.debug:
                print("Entering", entryPointString, 
                    " ------------------------------")
            inBasic = entryPoint["inBasic"]
            fb = entryPoint["fb"]
            eb = entryPoint["eb"]
            feb = entryPoint["feb"]
            erasable[0][3] = eb
            erasable[0][4] = fb
            if eb == -1 or fb == -1:
                erasable[0][6] = -1
            else:
                erasable[0][6] = (fb & 0o76000) | ((eb >> 8) & 0o7)
            iochannels[7] = feb
            disassembleRange(core, erasable, iochannels, bank, offset, 
                         sizeCoreBank, controlTransferCheck, inBasic, True,
                         False)

    else:

        def disassemble(erasable, iochannels, entryPoint):
            global disassembly
            
            bank = entryPoint["bank"]
            offset = entryPoint["offset"]
            entryPointString = "%02o,%04o" % (bank, offset + 0o2000)
            if disassembly[bank][offset] != unusedDisassembly:
                if cli.debug:
                    print("Already ", entryPointString, 
                        " -------------------------------")
                return
            if cli.debug:
                print("Entering", entryPointString, 
                      " ------------------------------")
            inBasic = entryPoint["inBasic"]
            fb = entryPoint["fb"]
            eb = entryPoint["eb"]
            feb = entryPoint["feb"]
            erasable[0][3] = eb
            erasable[0][4] = fb
            if eb == -1 or fb == -1:
                erasable[0][6] = -1
            else:
                erasable[0][6] = (fb & 0o76000) | ((eb >> 8) & 0o7)
            iochannels[7] = feb
            lastCA = -1
            extended = False
            while offset < sizeCoreBank:
                if disassembly[bank][offset] != unusedDisassembly:
                    break
                if inBasic: # Basic location
                    value = core[bank][offset]
                    if value == INTPRET and not extended:
                        disassembly[bank][offset] = ("TC", "INTPRET")
                        offset += 1
                        inBasic = False
                        continue
                    opcode, operand, extended = \
                        disassembleBasic(core[bank][offset], extended)
                    if cli.debug:
                        print("%02o,%04o eb=%05o fb=%05o feb=%05o "
                              "A=%05o L=%05o Q=%05o"
                              "    %05o         %-12s %s" \
                                  % (bank, offset + 0o2000, erasable[0][3], 
                                     erasable[0][4],
                                     iochannels[7], erasable[0][0], 
                                     erasable[0][1],
                                     erasable[0][2],
                                     core[bank][offset], opcode, operand))
                    disassembly[bank][offset] = (opcode, operand)
                    offset += 1

                    # Try to track effect on erasable and/or io channels.
                    semulate(core, erasable, iochannels, opcode, operand)
                    
                    # Transfer of control? 
                    if opcode in ["RETURN", "RESUME"]:
                        break
                    elif opcode in ["BZF", "BZMF"]:
                        newErasable = copy.deepcopy(erasable)
                        newIochannels = copy.deepcopy(iochannels)
                        disassemble( newErasable, newIochannels,
                                    { "inBasic": True, "bank": bank, 
                                      "offset": int(operand, 8) % 0o2000,
                                      "eb": newErasable[0][3], 
                                      "fb": newErasable[0][4], 
                                      "feb": newIochannels[7] } )
                    elif opcode in ["TC", "TCF"]:
                        nOperand = int(operand, 8)
                        if nOperand < 0o2000: # Erasable
                            pass
                        elif nOperand < 0o4000:
                            if erasable[0][4] != -1:
                                newErasable = copy.deepcopy(erasable)
                                if opcode == "TC":
                                    newErasable[0][2] = offset
                                newIochannels = copy.deepcopy(iochannels)
                                disassemble( newErasable, newIochannels,
                                        {   "inBasic": True, 
                                            "bank": (erasable[0][4] >> 10) \
                                                        & 0o37,
                                            "offset": nOperand % 0o2000,
                                            "eb": erasable[0][3], 
                                            "fb": erasable[0][4], 
                                            "feb": newIochannels[7] } )
                        else:
                                newErasable = copy.deepcopy(erasable)
                                newIochannels = copy.deepcopy(iochannels)
                                disassemble( newErasable, newIochannels,
                                        {   "inBasic": True, 
                                            "bank": nOperand // 0o2000, 
                                            "offset": nOperand % 0o2000,
                                            "eb": newErasable[0][3], 
                                            "fb": newErasable[0][4], 
                                            "feb": newIochannels[7] } )
                        # If the opcode is TC, check if it's one of those with
                        # a funky calling sequence in which the TC is followed
                        # by arguments rather than additional basic
                        # instructions, or for which the TC never returns. 
                        # Note that while INTPRET is special, it has already
                        # been processed, so the code below is never reached.
                        if opcode == "TC":
                            if nOperand in specialFixedFixed:
                                searchPattern = specialFixedFixed[nOperand][3]
                                symbol = specialFixedFixed[nOperand][4]
                                noReturn = searchPattern["noReturn"]
                                dataWords = getDataWords(core, bank, 
                                                offset, symbol,
                                                searchPattern["dataWords"])
                            else:
                                symbol = ""
                                dataWords = 0
                                noReturn = False
                            for i in range(dataWords):
                                disassembly[bank][offset] = \
                                    ("OCT", "%05o" % core[bank][offset])
                                offset += 1
                            if noReturn:
                                # Even though "called" via TC, there's no
                                # actual return from the called subroutine, 
                                # so from the viewpoint of the disassembler
                                # it's really a TCF instead.
                                break
                        # Usually, if the opcode is a TCF (which does not
                        # return), we shouldn't continue disassembling the
                        # succeeding word because we have no reason to 
                        # believe that it is still basic code.  However,
                        # heuristically thinking, there is an exception:  
                        # In a jump table, there will be
                        # a long series of TCF instructions.  So before
                        # bailing out after a TCF, we should also check if 
                        # the next instruction if a TCF too.
                        if opcode == "TCF":
                            opcode, operand, extended = \
                                disassembleBasic(core[bank][offset], extended)
                            if opcode != "TCF":
                                break
                    elif opcode in ["DTCB", "DTCF", "EDRUPT", "TCAA", 
                                    "XLQ", "XXALQ"]:
                        # TBD
                        break
                else:       # Interpretive location.
                    # Recall that disassembleInterpretive() returns a list not
                    # only of the disassembled current word, but of all its
                    # arguments too.
                    disAll = disassembleInterpretive(core, bank, offset)
                    for dis in disAll:
                        if disassembly[bank][offset] != unusedDisassembly:
                            print("Implementation error C")
                            sys.exit(1)
                        disassembly[bank][offset] = dis
                        offset += 1
                    # We have to do extra stuff here if the instruction
                    # transfers control, to insure that branches are
                    # disassembled.
                    # TBD
                    if disAll[0][0] == "EXIT" or disAll[0][1] == "EXIT":
                        inBasic = True
            if cli.debug:
                print("Leaving ", entryPointString, 
                      " -------------------------------")

    # Try disassembling, starting from each known code-entry point.
    for entryPoint in cli.entryPoints:
        print("Processing entry point: ", entryPoint["symbol"])
        disassemble(copy.deepcopy(erasable), copy.deepcopy(iochannels),
                    entryPoint) 

    #========================================================================
    # Convert bank,offset to linear address (10000-117777 octal).
    # Output results of recursive disassembly.

    def linearAddress(bank, offset):
        return 0o10000 + 0o2000 * bank + offset

    # Output results
    f = open("disassemblerAGC.agc", "w")
    basicWords = [0]*numCoreBanks
    interpreterWords = [0]*numCoreBanks
    for bank in range(numCoreBanks):
        inCode = False
        for offset in range(sizeCoreBank):
            d = disassembly[bank][offset]
            if len(d) == 0: # Empty location
                inCode = False
            else:           # Not empty location
                if not inCode:
                    print(file=f)
                    print("\t\tBANK\t%o" % bank, file=f)
                    print("\t\tSETLOC\t%o" % linearAddress(bank,offset),
                            file=f)
                    print(file=f) 
                    inCode = True
                if len(d) == 2: # Basic instructions
                    basicWords[bank] += 1
                    if d[0] == "":
                        print("\t\tOCT\t%s" % d[1], file=f)
                    else:
                        print("\t\t%s\t%s" % d, file=f)
                elif len(d) == 3: # Interpreter instructions
                    interpreterWords[bank] += 1
                    print("\t\t%s\t%s" % (d[1], d[2]), file=f)
    f.close()

    # Print summary:
    print()
    print("     Number of disassembled locations")
    print("-------------------------------------------")
    print("Bank            Basic           Interpreter")
    print("----            -----           -----------")
    for bank in range(numCoreBanks):
        print(" %02o             %5d           %5d" \
            % (bank, basicWords[bank], interpreterWords[bank]))
            
