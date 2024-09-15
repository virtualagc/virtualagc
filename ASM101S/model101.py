'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   model101.py
Purpose:    This is data for ASM101S, specific to the assembly language of 
            the IBM AP-101S computer.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-09-05 RSB  Began.
'''

#=============================================================================
# instruction set.

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
                                                        