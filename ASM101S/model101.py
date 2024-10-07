'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   model101.py
Purpose:    This object-code generation for ASM101S, specific to the assembly 
            language of the IBM AP-101S computer.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-09-05 RSB  Began.
'''

from expressions import error, unroll, astFlattenList, evalArithmeticExpression
from fieldParser import parserASM

#=============================================================================
# Various tables or the instruction set.

ap101 = True
system390 = False

# First, the CPU instructions, categorized by instruction types
argsE = set()
argsRR = { "AR", "CR", "CBL", "DR", "XUL", "LR", "LCR", "LFXI", "MR", "SR", 
           "BALR", "BCR", "BCRE", "BCTR", "BVCR", "NCT", "NR", "XR", "OR",
           "SUM", "AEDR", "AER", "CER", "CEDR", "CVFX", "CVFL", "DEDR", "DER",
           "LER", "LECR", "LFXR", "LFLI", "LFLR", "MEDR", "MER", "SEDR", "SER",
           "STXA", "MVH", "SPM", "SRET", "LXA", "ICR", "PC",
           "BR", "NOPR", "LACR" }
argsI = set()
argsRRE = set()
argsRRF = set()
argsRX = set()
argsRXE = set()
argsRXF = set()
argsRS = { "A", "AH", "AST", 
           "C", "CH", "D", 
           "IAL", "IHL", 
           "L", "LA", "LH",
           "LM", "M", "MH", 
           "MIH", "ST", "STH", 
           "STM", "S", "SST", 
           "SH", "TD", "BAL",
           "BIX", "BC", "BCT", 
           "BCV", "N", "NST", 
           "X", "XST", "O",
           "OST", "SHW", "TH", 
           "ZH", "AED", "AE", "CE", "CED", "DED", "DE", "LED", "LE", "MVS", 
           "MED", "ME", "SED", "SE", "STED", "STE", "DIAG", "STXA", "STDM",
           "ISPB", "LPS", "SSM", "SCAL", "LDM", "LXA", "SVC", "TS",
           "B", "NOP", "BH", "BL", "BE", "BNH", "BNL", "BNE", "BO", "BP",
           "BM", "BZ", "BNP", "BNM", "BNZ", "BNO", "BLE", "BN" }
for m in sorted(argsRS):
    argsRS.add(m + "@")
    argsRS.add(m + "@#")
    argsRS.add(m + "#")
argsRSE = set()
argsRSL = set()
argsRSI = set()
argsRI = { "AHI", "CHI", "MHI", "NHI", "XHI", "OHI", "TRB", "ZRB", "LHI",
           "SHI" }
argsRIL = set()
argsSRS = { "BCB", "BCF", "BCTB", "BVCF", "SLL", "SLDL", "SRA", "SRDA", "SRL",
            "SRDL", "SRR", "SRDR",
            "A", "AH", "C", "CH", "D", "IAL", "L", "LA", "LH",
            "M", "MH", "ST", "STH", "S", "SH", "TD",
            "BC", "N", "X", "O", 
            "SHW", "TH", "ZH", "AE", "DE", "LE", "ME", "SE" }
argsSI = { "CIST", "MSTH", "NIST", "XIST", "SB", "TB", "ZB", "TSB" }
argsS = set()
argsSS = set()
argsSSE = set()

# Now, the MSC instructions.
argsMSC = { "@A", "@B", "@BN", "@BNN", "@BNP", "@BNZ", "@BU", "@BU@", "@BXN",
         "@BXNN", "@BXNP", "@BXNZ", "@BXP", "@BXZ", "@BZ", "@C", "@CI", 
         "@CNOP", "@DLY", "@INT", "@L", "@LAR", "@LF", "@LH", "@LI", "@LMS", 
         "@LXI", "@N", "@NIX", "@RAI", "@RAW", "@RBI", "@REC", "@RFD", "@RNI", 
         "@RNW", "@SAI", "@SEC", "@SFD", "@SIO", "@ST", "@STF", "@STH", "@STP", 
         "@TAX", "@TI", "@TM", "@TMI", "@TSZ", "@TXA", "@TXI", "@WAT", "@X", 
         "@XAX", "@BC", "@BXC" "@CALL", "@CALL@", "@LBB", "@LBB@", "@LBP", 
         "@LBP@" }

# And BCE instructions.
argsBCE = { "#@#DEC", "#@#HEX", "#@#SCN", "#BU", "#BU@", "#CMD", "#CMDI", 
           "#CNOP", "#DLY", "#DLYI", "#LBR", "#LBR@", "#LTO", "#LTOI", "#MIN",
           "#MIN@", "#MINC", "#MOUT", "#MOUT@", "#MOUTC", "#ORG", "#RDL", 
           "#RDLI", "#RDS", "#RIB", "#SIB", "#SPLIT", "#SSC", "#SST", "#STP", 
           "#TDL", "#TDLI", "#TDS", "#WAT", "#WIX"
       }

knownInstructions = set.union(argsE, argsRR, argsI, argsRRE, argsRRF, argsRX, 
                             argsRXE, argsRXF, argsRS, argsRSE, argsRSL, 
                             argsRSI, argsRI, argsRIL, argsSRS, 
                             argsSI, argsS, argsSS, argsSSE, argsMSC, argsBCE)
instructionsWithoutOperands = set.union(argsE, argsBCE)
instructionsWithOperands = knownInstructions - instructionsWithoutOperands

#=============================================================================
# Generate object code for AP-101S.

'''
Work is done in place on the `source` array, which is a list of "property"
structures, one for each line if source code, including all of the macro
definitions from the macro library.  However, all manipulations of symbolic
variables and expansion of macros has been performed, so only the lines of
pure assembly-language code (i.e., CPU instructions and related pseudo-ops)
are processed.  Moreover, while continuation lines are present, all after the
first in any sequence have been merged into the first line of the sequence.
The `macros` argument is provided merely to have a list of operations which
can be ignored.

The only manipulations done to any particular entry of `source` are:
    1. The `errors` field may be augmented via the `error` function.
    2. Non-previously-existing fields may be added to hold object-code data.
I.e., no existing fields other than `errors` are affected.

Additionally, the function returns a dictionary of non-line-by-line info about
the assembly.

Note that addresses are in units of bytes.
'''
ignore = { "TITLE", 
           "GBLA", "GBLB", "GBLC", "LCLA", "LCLB",
           "LCLC", "SETA", "SETB", "SETC", "AIF",
           "AGO", "ANOP", "SPACE", "MEXIT", "MNOTE" }
hexDigits = "0123456789ABCDEF"
def generateObjectCode(source, macros):
    
    #-----------------------------------------------------------------------
    # Setup
    
    sects = {} # CSECTS and DSECTS.
    entries = set() # For `ENTRY`.
    extrns = set() # For `EXTRN`.
    symtab = {}
    metadata = {
        "sects": sects,
        "entries": entries,
        "extrns": extrns,
        "symtab": symtab
        }
    sect = None # Current section.
    for key in macros:
        ignore.add(key)
    
    #-----------------------------------------------------------------------
    
    # A function for writing to memory or allocating it without writing to
    # it, as appropriate, though in this case "not writing to it" means 
    # zeroing it.  This occurs in the current CSECT or DSECT
    #    `bytes`        Is either a number (for DS) indicating how much memory
    #                   to allocate, or else a `bytearray` (for DC) of the
    #                   actual bytes to store.
    # Alignment must have been done prior to entry.
    memoryChunkSize = 4096
    def toMemory(bytes):
        if isinstance(bytes, bytearray):
            pos = sects[sect]["pos"]
            end = pos + len(bytes)
            if cVsD:
                memory = sects[sect]["memory"]
                if end > len(memory):
                    chunks = (end - len(memory) + memoryChunkSize - 1) \
                                // memoryChunkSize
                    memory.extend([0]*(chunks * memoryChunkSize - len(memory)))
                for i in range(len(bytes)):
                    memory[pos + i] = bytes[i]
                if end > sects[sect]["used"]:
                    sects[sect]["used"] = end
            sects[sect]["pos"] = end
        else:
            sects[sect]["pos"] += bytes

    # Common processing for all instructions. The `alignment` argument is one
    # of 1 (byte), 2 (halfword), 4 (word), 8 (doubleword).
    # The memory added for padding is 0-filled if `zero` is `True`, or left
    # unchanged if `False`.
    def commonProcessing(alignment=1, zero=False):
        nonlocal cVsD, sect
        
        # Make sure we're in *some* CSECT or DSECT
        if sect == None:
            cVsD = True
            sect = ""
            sects[sect] = {
                "pos": 0,
                "used": 0,
                "memory": bytearray(memoryChunkSize)
                }
        
        # Perform alignment.
        if alignment > 1:
            rem = sects[sect]["pos"] % alignment
            if rem != 0:
                if zero:
                    toMemory(bytearray(alignment - rem))
                else:
                    toMemory(alignment - rem)
        
        # Add `name` (if any) to the symbol table.
        if name != "":
            if name in symtab:
                error(properties, "Symbol %s already defined" % name)
            else:
                symtab[name] = { "section": sect,  "address": sects[sect]["pos"] }
    
    #-----------------------------------------------------------------------
    # Process `source`, line by line.
    
    continuation = False
    for properties in source:
        
        #******** Should this line be processed or discarded? ********
        if properties["inMacroDefinition"] or properties["fullComment"] or \
                properties["dotComment"] or properties["empty"]:
            continue
        # We only need to look at the first line of any sequence of continued
        # lines.
        if continuation:
            continuation = properties["continues"]
            continue
        continuation = properties["continues"]
        # Various types of lines we can immediately discard by looking at 
        # their `operation` fields
        operation = properties["operation"]
        if operation in ignore:
            continue
        
        name = properties["name"]
        if name.startswith("."):
            name = ""
        operand = properties["operand"].rstrip()
        
        #******** Most pseudo-ops ********
        # Take care of pseudo-ops that don't add anything to AP-101S memory.
        # Each one of these should either `continue` or `break`, so as not to
        # fall through to instruction processing.
        if operation in ["CSECT", "DSECT"]:
            # The current section name starts as `None`, meaning none has been
            # assigned.  `START` or `CSECT` changes that to either "" (the
            # "unnamed" section) or an identifier. Code that must be assembled
            # when the section name is still `None` automatically switches to
            # the unnamed section.  I *could* check here that the name given
            # to the section is a valid identifier name, but I'm not bothering
            # with that just yet.
            cVsD = (operation == "CSECT")
            if name == "" and not cVsD:
                error(properties, "Unnamed DSECT not allowed.")
            sect = name
            if sect not in sects:
                sects[sect] = {
                    "pos": 0,
                    "used": 0,
                    "memory": bytearray(memoryChunkSize)
                    }
                symtab[sect] = { "section": sect, "address": 0 }
            continue
        elif operation == "END":
            break
        elif operation in ["ENTRY", "EXTRN"]:
            ast = parserASM(operand, "identifierList")
            if ast == None:
                error(properties, "Cannot parse operand of %s" % operation)
            else:
                ast = unroll(ast)
                symbols = []
                if isinstance(ast, str):
                    symbols.append(ast)
                else:
                    symbols.append(ast[0])
                    for e in ast[1]:
                        symbols.append(e[1])
                for symbol in symbols:
                    if operation == "ENTRY":
                        entries.add(symbol)
                    else:
                        extrns.add(symbol)
            continue
        elif operation == "EQU":
            continue
        elif operation == "EXTRN":
            continue
        elif operation == "LTORG":
            continue
        elif operation == "USING":
            continue
                
        #******** Process instruction ********
        
        # For our purposes, pseudo-ops like `DS` and `DC` that can have labels,
        # modify memory, and move the instruction pointer are "instructions".
        
        if operation in ["DC", "DS"]:
            ast = parserASM(operand, operation.lower() + "Operands")
            if ast == None:
                error(properties, "Cannot parse %s operand" % operation)
                continue
            flattened = astFlattenList(ast)
            # At this point, `flattened` should be a list with one entry for
            # each suboperand.  Those suboperands are in the form of 
            # dicts with the keys:
            #    'd'    duplication factor
            #    't'    type
            #    'l'    length modifier
            #    'v'    value
            # Each of these fields will itself be an AST.
            for suboperand in flattened:
                if suboperand["d"] == []:
                    duplicationFactor = 1
                else:
                    duplicationFactor = evalArithmeticExpression(suboperand["d"], {}, properties)
                    if duplicationFactor == None:
                        error(properties, "Could not evaluate duplication factor")
                        continue
                try:
                    suboperandType = suboperand["t"][0]
                except:
                    error(properties, "Suboperand type not specified")
                    continue
                if suboperand["l"] == []:
                    lengthModifier = None
                else:
                    lengthModifier = evalArithmeticExpression(suboperand["l"], {}, properties)
                    if lengthModifier == None:
                        error(properties, "Count not evaluate length modifier")
                        continue
                astValue = suboperand["v"]
                if suboperandType == "C":
                    commonProcessing(1)
                    
                    pass
                elif suboperandType == "X":
                    commonProcessing(1)
                    # Adjust the string to have an even number of digits,
                    # 0-padded or truncated to the length modifier, if any.
                    try:
                        hexString = flattened[0]["v"][0][1]
                        if lengthModifier == None:
                            count = len(hexString)
                            count += (count % 1)
                        else:
                            count = lengthModifier * 2
                        while len(hexString) < count:
                            hexString = "0" + hexString
                        hexString = hexString[-count:]
                    except:
                        error(properties, "Cannot parse X value")
                        continue
                    # Deal with memory.
                    if operation == "DC":
                        bytes = bytearray()
                        for i in range(0, count, 2):
                            b = hexString[i:i+2]
                            bytes.append(int(b, 16))
                        toMemory(bytes)
                    else:
                        toMemory(count // 2)
                elif suboperandType == "B":
                    commonProcessing(1)
                    
                    pass
                elif suboperandType == "F":
                    commonProcessing(1)
                    if lengthModifier != None:
                        pass
                    if operation == "DC":
                        pass
                    
                    toMemory(duplicationFactor * 4)
                elif suboperandType == "H":
                    commonProcessing(1)
                    if lengthModifier != None:
                        pass
                    if operation == "DC":
                        pass
                    
                    toMemory(duplicationFactor * 2)
                elif suboperandType == "E":
                    commonProcessing(1)
                    if lengthModifier != None:
                        pass
                    if operation == "DC":
                        pass
                    
                    toMemory(duplicationFactor * 4)
                elif suboperandType == "D":
                    commonProcessing(1)
                    if lengthModifier != None:
                        pass
                    if operation == "DC":
                        pass
                    
                    toMemory(duplicationFactor * 8)
                elif suboperandType == "A":
                    commonProcessing(1)
                    if lengthModifier != None:
                        pass
                    if operation == "DC":
                        pass
                    
                    toMemory(duplicationFactor * 4)
                elif suboperandType == "Y":
                    commonProcessing(1)
                    if lengthModifier != None:
                        pass
                    if operation == "DC":
                        pass
                    
                    
                    toMemory(duplicationFactor * 2)
                else:
                    error(properties, "Unsupported DC/DS type %s" % suboperandType)
                    continue
        elif operation in argsRR:
            commonProcessing(2)
            ast = parserASM(operand, "rrAll")
            
            toMemory(bytearray(2))
        elif operation in argsRS:
            commonProcessing(2)
            ast = parserASM(operand, "rsAll")
            
            toMemory(bytearray(4))
        elif operation in argsSRS:
            commonProcessing(2)
            ast = parserASM(operand, "srsAll")
            
            toMemory(bytearray(2))
        elif operation in argsRI:
            commonProcessing(2)
            ast = parserASM(operand, "riAll")
            
            toMemory(bytearray(4))
        elif operation in argsSI:
            commonProcessing(2)
            ast = parserASM(operand, "siAll")
            
            toMemory(bytearray(4))
        elif operation in argsMSC:
            commonProcessing(2)
            ast = parserASM(operand, "mscAll")
            # MSC operations are really standardized enough for there to be
            # any advantage in segregating them this way, but it might provide
            # some clarity in maintenance to do so.
            
            toMemory(bytearray(4))
        elif operation in argsBCE:
            commonProcessing(2)
            ast = parserASM(operand, "bceAll")
            # BCE operations are really standardized enough for there to be
            # any advantage in segregating them this way, but it might provide
            # some clarity in maintenance to do so.
            
            toMemory(bytearray(4))
        else:
            error(properties, "Untrapped operation " + operation)
            continue
        
    return metadata
