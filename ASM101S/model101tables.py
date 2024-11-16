'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   model101tables.py
Purpose:    Tables used by module model101.py and others.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-10-28 RSB  Split off from model101.py.
'''

# First, the CPU instructions, categorized by instruction types, accompanied
# by opcodes.  When the opcode is given as -1, it's a special case in terms
# of how the code is generated.  (There are other special cases, though, which
# are not so-marked, such as almost all conditional branches..)

# The 6-bit numerical codes are the 5-bit OP field, suffixed by the 1-bit OPX
# field.  Though technically considered RR instructions, the mnemonics
# LFXI, LFLI, SPM, BR, and NOPR are special, in that they either
# are encoded slightly differently or else are aliases and accept an altered 
# syntax from the others.
argsRR = {   "AR": 0b000000,   "CR": 0b000100,   "CBL": 0b000011,   
             "DR": 0b010010,  "XUL": 0b000001,    "LR": 0b000110,  
            "LCR": 0b111011, "LFXI": 0b101110,    "MR": 0b010000,    
             "SR": 0b000010, "BALR": 0b111000,   "BCR": 0b110000, 
           "BCRE": 0b110001, "BCTR": 0b110100,  "BVCR": 0b110010, 
            "NCT": 0b111001,   "NR": 0b001000,    "XR": 0b011100,   
             "OR": 0b001010,  "SUM": 0b100111,  "AEDR": 0b010101,  
            "AER": 0b010100, "CEDR": 0b000111,   "CER": 0b010011, 
           "CVFX": 0b001110, "CVFL": 0b001111,  "DEDR": 0b000101, 
            "DER": 0b011010,  "LER": 0b011110,  "LECR": 0b011111, 
           "LFXR": 0b001001, "LFLI": 0b100010,  "LFLR": 0b001011,  
           "MEDR": 0b001101,  "MER": 0b011000,  "SEDR": 0b010111, 
            "SER": 0b010110,  "MVH": 0b011011,   "SPM": 0b110011, 
           "SRET": 0b100101, "LXAR": 0b010001, "STXAR": 0b101001, 
            "ICR": 0b110110,   "BR": 0b110000,  "NOPR": 0b110000,  
           "LACR": 0b111011,   "PC": 0b011011 }

# The 10-bit numerical codes are the codes in encoded positions 0-4 (in both
# the RS and SRS forms of the instructin) suffixed by the bits in positions
# 8-12 (of the RS form, but are unused in the SRS forms.
argsSRSandRS = {
   "A": 0b0000011110, "AH": 0b1000011110,   "C": 0b0001011110, 
  "CH": 0b1001011110,  "D": 0b0100111110, "IAL": 0b1110011111, 
   "L": 0b0001111110, "LA": 0b1110111110,  "LH": 0b1001111110, 
   "M": 0b0100011110, "MH": 0b1010111110,  "ST": 0b0011011110, 
 "STH": 0b1011111110,  "S": 0b0000111110,  "SH": 0b1000111110, 
  "TD": 0b1010011110, "BC": 0b1100011110,   "N": 0b0010011110, 
   "X": 0b0111011110,  "O": 0b0010111110, "SHW": 0b1010011110,
  "TH": 0b1010011110, "ZH": 0b1010011110,  "AE": 0b0101011110, 
  "DE": 0b0110111110, "LE": 0b0111111110,  "ME": 0b0110011110,  
  "SE": 0b0101111110,
 "STE": 0b0011111110,   
   "B": 0b1100000000,   "BH": 0b1100000000,   
  "BL": 0b1100000000,   "BE": 0b1100000000,  "BNH": 0b1100000000, 
 "BNL": 0b1100000000,  "BNE": 0b1100000000,   "BO": 0b1101100000,   
  "BP": 0b1100000000,   "BM": 0b1100000000,   "BZ": 0b1100000000,  
 "BNP": 0b1100000000,  "BNM": 0b1100000000,  "BNN": 0b1100000000,
 "BNZ": 0b1100000000,  "BNO": 0b1100000000,  "BLE": 0b1100000000,   
  "BN": 0b1100000000,  "BHE": 0b1100000000,  "BNC": 0b1101100000,
 }

argsSRSonly = {
  "BCB": 0b1101100000,  "BCF": 0b1101100000, "BCTB": 0b1101100000, 
 "BVCF": 0b1101100000,  "SLL": 0b1111000000, "SLDL": 0b1111100000, 
  "SRA": 0b1111000000, "SRDA": 0b1111100000, "SRDL": 0b1111100000,  
  "SRL": 0b1111000000,  "SRR": 0b1111000000, "SRDR": 0b1111100000,
  "NOP": 0b1100000000, 
 }
shiftOperations = { # Special cases of SRS. Values are least-sig bits of code.
  "SLL": 0b00, "SLDL": 0b00, "SRA": 0b01, "SRDA": 0b01, 
  "SRDL": 0b10, "SRL": 0b10, "SRR": 0b11, "SRDR": 0b11
}
# The field values are the masks.
branchAliases = {"B": 7, "BR": 7, "NOP": 0, "NOPR": 0, "BH": 1, "BL": 2, 
                 "BE": 4, "BNH": 6, "BNL": 5, "BNE": 3, "BO": 1, "BP": 1, 
                 "BM": 2, "BZ": 4, "BNP": 6, "BNM": 5, "BNN": 5, "BNZ": 3, 
                 "BNO": 6, "BLE": 6, "BN": 2, "BHE": 5, "BNC": 6 }

argsRSonly = { 
   "AST": 0b0000011111,    "IHL": 0b1000011111,     "LM": 0b1100111111, 
   "MIH": 0b1001111111,    "STM": 0b1100111111,    "SST": 0b0000111111, 
   "BAL": 0b1110011110,    "BIX": 0b1101111110,    "BCT": 0b1101011110, 
   "BCV": 0b1100111110,    "NST": 0b0010011111,    "XST": 0b0111011111, 
   "OST": 0b0010111111,    "AED": 0b0101011111,    "CED": 0b0001111111, 
    "CE": 0b0100111111,    "DED": 0b0001011111,    "LED": 0b0111111111, 
   "MVS": 0b0110011111,    "MED": 0b0011011111,    "SED": 0b0101111111, 
  "STED": 0b0011111111,                            "DIAG": 0b1100011111, 
  "ISPB": 0b1110111111,    "LPS": 0b1100111111,    "SSM": 0b1000111111, 
  "SCAL": 0b1101011111,    "SVC": 0b1100111111,     "TS": 0b1011111111, 
   "LXA": 0b0100011111,    "LDM": 0b0110111111,   "STXA": 0b1010011111, 
  "STDM": 0b1001011111,     "A@": 0b0000011110,    "A@#": 0b0000011110, 
    "A#": 0b0000011110,    "AE@": 0b0101011110,   "AE@#": 0b0101011110, 
   "AE#": 0b0101011110,   "AED@": 0b0101011111,  "AED@#": 0b0101011111, 
  "AED#": 0b0101011111,    "AH@": 0b1000011110,   "AH@#": 0b1000011110, 
   "AH#": 0b1000011110,   "AST@": 0b0000011111,  "AST@#": 0b0000011111, 
  "AST#": 0b0000011111,     "B@": 0b1100000000,    "B@#": 0b1100000000, 
    "B#": 0b1100000000,   "BAL@": 0b1110011110,  "BAL@#": 0b1110011110, 
  "BAL#": 0b1110011110,    "BC@": 0b1100011110,   "BC@#": 0b1100011110, 
   "BC#": 0b1100011110,   "BCT@": 0b1101011110,  "BCT@#": 0b1101011110, 
  "BCT#": 0b1101011110,   "BCV@": 0b1100111110,  "BCV@#": 0b1100111110, 
  "BCV#": 0b1100111110,    "BE@": 0b1100000000,   "BE@#": 0b1100000000, 
   "BE#": 0b1100000000,    "BH@": 0b1100000000,   "BH@#": 0b1100000000, 
   "BH#": 0b1100000000,   "BIX@": 0b1101111110,  "BIX@#": 0b1101111110, 
  "BIX#": 0b1101111110,    "BL@": 0b1100000000,   "BL@#": 0b1100000000, 
   "BL#": 0b1100000000,   "BLE@": 0b1100000000,  "BLE@#": 0b1100000000, 
  "BLE#": 0b1100000000,    "BM@": 0b1100000000,   "BM@#": 0b1100000000, 
   "BM#": 0b1100000000,    "BN@": 0b1100000000,   "BN@#": 0b1100000000, 
   "BN#": 0b1100000000,   "BNE@": 0b1100000000,  "BNE@#": 0b1100000000, 
  "BNE#": 0b1100000000,   "BNH@": 0b1100000000,  "BNH@#": 0b1100000000, 
  "BNH#": 0b1100000000,   "BNL@": 0b1100000000,  "BNL@#": 0b1100000000, 
  "BNL#": 0b1100000000,   "BNM@": 0b1100000000,  "BNM@#": 0b1100000000, 
  "BNM#": 0b1100000000,   "BNO@": 0b1100000000,  "BNO@#": 0b1100000000, 
  "BNO#": 0b1100000000,   "BNP@": 0b1100000000,  "BNP@#": 0b1100000000, 
  "BNP#": 0b1100000000,   "BNZ@": 0b1100000000,  "BNZ@#": 0b1100000000, 
  "BNZ#": 0b1100000000,    "BO@": 0b1100000000,   "BO@#": 0b1100000000, 
   "BO#": 0b1100000000,    "BP@": 0b1100000000,   "BP@#": 0b1100000000, 
   "BP#": 0b1100000000,    "BZ@": 0b1100000000,   "BZ@#": 0b1100000000, 
   "BZ#": 0b1100000000,     "C@": 0b0001011110,    "C@#": 0b0001011110, 
    "C#": 0b0001011110,    "CE@": 0b0100111111,   "CE@#": 0b0100111111, 
   "CE#": 0b0100111111,   "CED@": 0b0001111111,  "CED@#": 0b0001111111, 
  "CED#": 0b0001111111,    "CH@": 0b1001011110,   "CH@#": 0b1001011110, 
   "CH#": 0b1001011110,     "D@": 0b0100111110,    "D@#": 0b0100111110, 
    "D#": 0b0100111110,    "DE@": 0b0110111110,   "DE@#": 0b0110111110, 
   "DE#": 0b0110111110,   "DED@": 0b0001011111,  "DED@#": 0b0001011111, 
  "DED#": 0b0001011111,  "DIAG@": 0b1100011111, "DIAG@#": 0b1100011111, 
 "DIAG#": 0b1100011111,   "IAL@": 0b1110011111,  "IAL@#": 0b1110011111, 
  "IAL#": 0b1110011111,   "IHL@": 0b1000011111,  "IHL@#": 0b1000011111, 
  "IHL#": 0b1000011111,  "ISPB@": 0b1110111111, "ISPB@#": 0b1110111111, 
 "ISPB#": 0b1110111111,     "L@": 0b0001111110,    "L@#": 0b0001111110, 
    "L#": 0b0001111110,    "LA@": 0b1110111110,   "LA@#": 0b1110111110, 
   "LA#": 0b1110111110,   "LDM@": 0b0110111111,  "LDM@#": 0b0110111111, 
  "LDM#": 0b0110111111,    "LE@": 0b0111111110,   "LE@#": 0b0111111110, 
   "LE#": 0b0111111110,   "LED@": 0b0111111111,  "LED@#": 0b0111111111, 
  "LED#": 0b0111111111,    "LH@": 0b1001111110,   "LH@#": 0b1001111110, 
   "LH#": 0b1001111110,    "LM@": 0b1100111111,   "LM@#": 0b1100111111, 
   "LM#": 0b1100111111,   "LPS@": 0b1100111111,  "LPS@#": 0b1100111111, 
  "LPS#": 0b1100111111,   "LXA@": 0b0100011111,  "LXA@#": 0b0100011111, 
  "LXA#": 0b0100011111,     "M@": 0b0100011110,    "M@#": 0b0100011110, 
    "M#": 0b0100011110,    "ME@": 0b0110011110,   "ME@#": 0b0110011110, 
   "ME#": 0b0110011110,   "MED@": 0b0011011111,  "MED@#": 0b0011011111, 
  "MED#": 0b0011011111,    "MH@": 0b1010111110,   "MH@#": 0b1010111110, 
   "MH#": 0b1010111110,   "MIH@": 0b1001111111,  "MIH@#": 0b1001111111, 
  "MIH#": 0b1001111111,   "MVS@": 0b0110011111,  "MVS@#": 0b0110011111, 
  "MVS#": 0b0110011111,     "N@": 0b0010011110,    "N@#": 0b0010011110, 
    "N#": 0b0010011110,   "NOP@": 0b1100000000,  "NOP@#": 0b1100000000, 
  "NOP#": 0b1100000000,   "NST@": 0b0010011111,  "NST@#": 0b0010011111, 
  "NST#": 0b0010011111,     "O@": 0b0010111110,    "O@#": 0b0010111110, 
    "O#": 0b0010111110,   "OST@": 0b0010111111,  "OST@#": 0b0010111111, 
  "OST#": 0b0010111111,     "S@": 0b0000111110,    "S@#": 0b0000111110, 
    "S#": 0b0000111110,  "SCAL@": 0b1101011111, "SCAL@#": 0b1101011111, 
 "SCAL#": 0b1101011111,    "SE@": 0b0101111110,   "SE@#": 0b0101111110, 
   "SE#": 0b0101111110,   "SED@": 0b0101111111,  "SED@#": 0b0101111111, 
  "SED#": 0b0101111111,    "SH@": 0b1000111110,   "SH@#": 0b1000111110, 
   "SH#": 0b1000111110,   "SHW@": 0b1010011110,  "SHW@#": 0b1010011110, 
  "SHW#": 0b1010011110,   "SSM@": 0b1000111111,  "SSM@#": 0b1000111111, 
  "SSM#": 0b1000111111,   "SST@": 0b0000111111,  "SST@#": 0b0000111111, 
  "SST#": 0b0000111111,    "ST@": 0b0011011110,   "ST@#": 0b0011011110, 
   "ST#": 0b0011011110,  "STDM@": 0b1001011111, "STDM@#": 0b1001011111, 
 "STDM#": 0b1001011111,   "STE@": 0b0011111110,  "STE@#": 0b0011111110, 
  "STE#": 0b0011111110,  "STED@": 0b0011111111, "STED@#": 0b0011111111, 
 "STED#": 0b0011111111,   "STH@": 0b1011111110,  "STH@#": 0b1011111110, 
  "STH#": 0b1011111110,   "STM@": 0b1100111111,  "STM@#": 0b1100111111, 
  "STM#": 0b1100111111,  "STXA@": 0b1010011111, "STXA@#": 0b1010011111, 
 "STXA#": 0b1010011111,   "SVC@": 0b1100111111,  "SVC@#": 0b1100111111, 
  "SVC#": 0b1100111111,    "TD@": 0b1010011110,   "TD@#": 0b1010011110, 
   "TD#": 0b1010011110,    "TH@": 0b1010011110,   "TH@#": 0b1010011110, 
   "TH#": 0b1010011110,    "TS@": 0b1011111111,   "TS@#": 0b1011111111, 
   "TS#": 0b1011111111,     "X@": 0b0111011110,    "X@#": 0b0111011110, 
    "X#": 0b0111011110,   "XST@": 0b0111011111,  "XST@#": 0b0111011111, 
  "XST#": 0b0111011111,    "ZH@": 0b1010011110,   "ZH@#": 0b1010011110, 
   "ZH#": 0b1010011110    
   }

argsSRSorRS = argsSRSandRS | argsSRSonly | argsRSonly

'''
i = 0
for key in argsRSonly:
    i += 1
    value = format(argsSRSorRS[key.replace("@","").replace("#","")], "#012b")
    print('%8s: %s, ' % ('"'+key+'"', value), end="")
    if i % 3 == 0:
            print()
print()
sys.exit(1)
'''

# The 14-bit numerical codes are what's encoded in bits 0-12
# LHI and SHI are special and must be specially handled.
argsRI = { "AHI": 0b1011000011100, "CHI": 0b1011010111100, 
           "MHI": 0b1011011111100, "NHI": 0b1011011011100, 
           "XHI": 0b1011010011100, "OHI": 0b1011001011100, 
           "TRB": 0b1011001111100, "ZRB": 0b1011000111100, 
           "LHI": 0b0000000000000, "SHI": 0b1011000011100 }

# The 8-bit numerical codes are the OP+OPX fields of the encoded instruction.
argsSI = { "CIST": 0b10110101, "MSTH": 0b10110000, "NIST": 0b10110110, 
           "XIST": 0b10110100,   "SB": 0b10110010,   "TB": 0b10110011, 
             "ZB": 0b10110001,  "TSB": 0b10110111 }

# Now, the MSC instructions.
argsMSC = { "@A": -1, "@B": -1, "@BN": -1, "@BNN": -1, "@BNP": -1, "@BNZ": -1, "@BU": -1, "@BU@": -1, "@BXN": -1,
         "@BXNN": -1, "@BXNP": -1, "@BXNZ": -1, "@BXP": -1, "@BXZ": -1, "@BZ": -1, "@C": -1, "@CI": -1, 
         "@CNOP": -1, "@DLY": -1, "@INT": -1, "@L": -1, "@LAR": -1, "@LF": -1, "@LH": -1, "@LI": -1, "@LMS": -1, 
         "@LXI": -1, "@N": -1, "@NIX": -1, "@RAI": -1, "@RAW": -1, "@RBI": -1, "@REC": -1, "@RFD": -1, "@RNI": -1, 
         "@RNW": -1, "@SAI": -1, "@SEC": -1, "@SFD": -1, "@SIO": -1, "@ST": -1, "@STF": -1, "@STH": -1, "@STP": -1, 
         "@TAX": -1, "@TI": -1, "@TM": -1, "@TMI": -1, "@TSZ": -1, "@TXA": -1, "@TXI": -1, "@WAT": -1, "@X": -1, 
         "@XAX": -1, "@BC": -1, "@BXC" "@CALL": -1, "@CALL@": -1, "@LBB": -1, "@LBB@": -1, "@LBP": -1, 
         "@LBP@": -1 }

# And BCE instructions.
argsBCE = { "#@#DEC": -1, "#@#HEX": -1, "#@#SCN": -1, "#BU": -1, "#BU@": -1, "#CMD": -1, "#CMDI": -1, 
           "#CNOP": -1, "#DLY": -1, "#DLYI": -1, "#LBR": -1, "#LBR@": -1, "#LTO": -1, "#LTOI": -1, "#MIN": -1,
           "#MIN@": -1, "#MINC": -1, "#MOUT": -1, "#MOUT@": -1, "#MOUTC": -1, "#ORG": -1, "#RDL": -1, 
           "#RDLI": -1, "#RDS": -1, "#RIB": -1, "#SIB": -1, "#SPLIT": -1, "#SSC": -1, "#SST": -1, "#STP": -1, 
           "#TDL": -1, "#TDLI": -1, "#TDS": -1, "#WAT": -1, "#WIX": -1
       }

instructionsWithoutOperands = argsBCE
instructionsWithOperands = argsRR | argsSRSorRS | argsRSonly | argsSRSonly | \
                           argsSI | argsMSC
knownInstructions = instructionsWithoutOperands | instructionsWithOperands

# Floating-point RS/SRS mnemonics. 
fpOperations = { "AED", "AE", "CE", "CED", "DED", "DE", "LED", "LE", 
                 "MED", "ME", "SED", "SE", "STED", "STE" }
fpOperationsSP = []
fpOperationsDP = []
for operation in fpOperations:
    if operation[-1] == "D":
        fpOperationsDP.append(operation)
    else:
        fpOperationsSP.append(operation)

# Alignment of various datatypes of so-called "literals" (=...).
literalDatatypeAlignments = { "B": 2, "C": 2, "X": 2, "H": 2, "Y": 2, "Z": 2,
                              "F": 4, "E": 4, "D": 8 }

# Parsing rules for different operations.
appropriateRules = {
    "ENTRY": "identifierList", "EXTRN": "identifierList",
    "EQU": "equOperand", "USING": "expressions", "DROP": "expressions",
    "DC": "dcOperands", "DS": "dsOperands", 
    }
for operation in argsRR:
    appropriateRules[operation] = "rrAll"
appropriateRules["LFXI"] = "lfxiAll"
for operation in argsSRSorRS:
    appropriateRules[operation] = "rsAll"
for operation in argsRI:
    appropriateRules[operation] = "riAll"
for operation in argsSI:
    appropriateRules[operation] = "siAll"
for operation in argsMSC:
    appropriateRules[operation] = "mscAll"
for operation in argsBCE:
    appropriateRules[operation] = "bceAll"

##############################################################################
# Low-level machine-code generators.  Each returns a `bytearray` of the 
# appropriate size, filled with the appropriate binary data.  Each accepts
# the data for each field of the encoded instruction and assumes
# without checking that that data is correct.  (I.e., mnemonics are assumed to
# be legitimate SRS or RS mnemonics, and all numeric fields are assumed to be
# actual number in the correct range.)

def generateSRS(properties, mnemonic, r1, d2, b2):
    data = bytearray(2)
    data[0] = ((argsSRSorRS[mnemonic] & 0b1111100000) >> 2) | r1
    data[1] = 0xFF & ((d2 << 2) | b2)
    if "adr1" in properties and properties["adr1"] != d2 and \
            (b2 == 3 or properties["operation"] in branchAliases):
        properties["adr2"] = d2
    return data

def generateRS0(properties, mnemonic, r1, d2, b2):
    data = bytearray(4)
    opcode = argsSRSorRS[mnemonic]
    data[0] = ((opcode & 0b1111100000) >> 2) | r1
    data[1] = ((opcode & 0b11111) << 3) | b2
    data[2] = (d2 & 0xFF00) >> 8
    data[3] = d2 & 0xFF
    if "adr1" in properties and properties["adr1"] != d2:
        properties["adr2"] = d2
    return data
    

def generateRS1(properties, mnemonic, ia, i, r1, d2, x2, b2):
    data = bytearray(4)
    opcode = argsSRSorRS[mnemonic]
    data[0] = ((opcode & 0b1111100000) >> 2) | r1
    data[1] = ((opcode & 0b11111) << 3) | 0b100 | b2
    data[2] = (x2 << 5) | (ia << 4) | (i << 3) | ((d2 & 0x700) >> 8)
    data[3] = d2 & 0x0FF
    if "adr1" in properties and properties["adr1"] != d2:
        properties["adr2"] = d2
    return data
    
