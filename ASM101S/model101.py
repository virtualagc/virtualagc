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

from expressions import error, unroll
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
'''
ignore = { "TITLE", 
           "GBLA", "GBLB", "GBLC", "LCLA", "LCLB",
           "LCLC", "SETA", "SETB", "SETC", "AIF",
           "AGO", "ANOP", "SPACE", "MEXIT", "MNOTE" }
def generateObjectCode(source, macros):
    csects = {} # Keys are names of c-sections, values the current pointers
    dsects = {} # Keys are names of d-sections, values the current pointers
    entries = set() # For `ENTRY`.
    extrns = set() # For `EXTRN`.
    metadata = {
        "csects": csects,
        "dsects": dsects,
        "entries": entries,
        "extrns": extrns
        }
    csect = None # Current c-section.
    dsect = None # Current d-section.
    cVsD = True # True for assembling into c-sections, False for d-sections.
    for key in macros:
        ignore.add(key)
    continuation = False
    for properties in source:
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
        operand = properties["operand"].rstrip()
        
        # The big if/elif/else that follows covers all supported operations.
        # First come the pseudo-ops (in alphabetical order), followed by all
        # instruction types, categorized in hopefully-useful ways.
        if operation == "CSECT":
            # The current section name starts as `None`, meaning none has been
            # assigned.  `START` or `CSECT` changes that to either "" (the
            # "unnamed" section) or an identifier. Code that must be assembled
            # when the section name is still `None` automatically switches to
            # the unnamed section.  I *could* check here that the name given
            # to the section is a valid identifier name, but I'm not bothering
            # with that just yet.
            csect = name
            if csect not in csects:
                csects[csect] = 0
        elif operation == "DC":
            pass
        elif operation == "DS":
            pass
        elif operation == "DSECT":
            # Same comments as for `CSECT`.
            dsect = name
            if dsect not in dsects:
                dsects[dsect] = 0
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
        elif operation == "EQU":
            pass
        elif operation == "EXTRN":
            pass
        elif operation == "LTORG":
            pass
        elif operation == "USING":
            pass
        elif operation in argsRR:
            pass
        elif operation in argsRS:
            pass
        elif operation in argsSRS:
            pass
        elif operation in argsRI:
            pass
        elif operation in argsSI:
            pass
        elif operation in argsMSC:
            # MSC operations are really standardized enough for there to be
            # any advantage in segregating them this way, but it might provide
            # some clarity in maintenance to do so.
            pass
        elif operation in argsBCE:
            # BCE operations are really standardized enough for there to be
            # any advantage in segregating them this way, but it might provide
            # some clarity in maintenance to do so.
            pass
        else:
            error(properties, "Untrapped operation " + operation)
            continue
        
    return metadata
