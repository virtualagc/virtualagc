'''
License:    This program is declared by its author, Ronald Burkey, to be the 
            U.S. Public Domain, and may be freely used, modifified, or 
            distributed for any purpose whatever.
Filename:   model101tables.py
Purpose:    Tables used by module model101.py and others.
Contact:    info@sandroid.org
Refer to:   https://www.ibiblio.org/apollo/ASM101S.html
History:    2024-10-28 RSB  Split off from model101.py.
            2026-05-19 RSB  Fixed `PC` instruction per issue #1317.
            2026-05-21 RSB  Per issue #1320:  Added `BVC[@][#]`
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
           "LACR": 0b111011,   "PC": 0b110111 }

# The 10-bit numerical codes are the codes in encoded positions 0-4 (in both
# the RS and SRS forms of the instruction) suffixed by the bits in positions
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
 "BVC": 0b1100111110, 
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
   "BP#": 0b1100000000,   
   "BVC@": 0b1100111110,  "BVC@#": 0b1100111110,  "BVC#": 0b1100111110,
   "BZ@": 0b1100000000,   "BZ@#": 0b1100000000, 
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

# A '$' SUFFIX FORCES THE LONG (RS) FORM of an instruction that would
# otherwise be assembled in the short (SRS) form.  It is not a fourth
# addressing variant alongside @, # and @#; it selects the FORM, and the
# addressing bits stay clear.
#
# The AP-101S POO does not mention it, so it was established from the
# assembled binaries in ~/workspace/PFS/"OI301700 as received", which list the
# object code each statement generated in the original build.  BILDNEW5 has
#
#     00C14 C7F2 0000      0000      6526 STM1392  BC$   7,0(R2)
#
# and ASM101S already produces C7F2 0064 for `BC 7,100(R2)`, the same opcode
# and base with a displacement large enough to have forced the long form by
# itself.  It differs from BC@ (C7F6 5000), BC# (C7F6 4800) and BC@# (C7F6
# 5800), so '$' is none of those.  The pattern holds across all twelve forms
# that appear in the corpus -- B$, BAL$, BC$, BL$, BNZ$, BZ$, IAL$, L$, LA$,
# LH$, ST$, STH$ -- every one of which assembles to four bytes whose second
# byte is 0xF0 | base register.
#
# Membership of argsRSonly is exactly what sets `forceRS` in model101.py, and
# since '$' contains neither '@' nor '#' the `ia` and `i` bits derived from
# the mnemonic stay zero.  So the entry needs no code of its own.
#
# Why the sources use it: an instruction whose length must be known in advance
# cannot be left to the assembler's choice between the two forms.  BILDNEW5's
# BC$ is preceded by `CNOP 2` and commented "EXECUTE AN UNPROTECTED BRANCH".
for _mnemonic in [_m[:-1] for _m in list(argsRSonly) if _m.endswith("@")]:
    for _table in (argsSRSandRS, argsSRSonly, argsRSonly):
        if _mnemonic in _table:
            argsRSonly[_mnemonic + "$"] = _table[_mnemonic]
            break

# The no-op each flavour of CNOP pads with.  These are three different
# processors' alignment directives, not three spellings of one:  CNOP is the
# CPU's and pads with D800, which is exactly what `NOP 0` assembles to, and
# @CNOP is the MSC's and pads with C000.  Both were read off the original
# build in ~/workspace/PFS/"OI301700 as received".
#
# #CNOP is the BCE's.  Its two appearances there both fell on an already
# aligned address and so emitted nothing, which leaves its padding unknown;
# None means "align, but say so rather than guess if padding is actually
# needed".  Fill it in when the BCE instructions are encoded.
cnopFills = { "CNOP": b"\xD8\x00", "@CNOP": b"\xC0\x00", "#CNOP": None }

argsSRSorRS = argsSRSandRS | argsSRSonly | argsRSonly

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
         "@XAX": -1, "@BC": -1, "@BP": -1, "@BXC": -1, "@CALL": -1, "@CALL@": -1, "@LBB": -1, "@LBB@": -1, "@LBP": -1, 
         "@LBP@": -1 }

# And BCE instructions.
# #@#DEC, #@#HEX, #@#SCN, #ORG and #SPLIT USED TO BE LISTED HERE and are not
# BCE instructions at all.  They are MACROS, and the five files of those names
# in ~/workspace/PFS/"OI340600 as received"/MLIB80 each begin with a MACRO
# statement and a prototype.  Listing them here did real harm, because
# `instructionsWithoutOperands` was this same table and so their operands were
# discarded before anything could look at them.
#
# #CNOP is not an instruction either -- it is the BCE's alignment directive,
# handled with CNOP and @CNOP through `cnopFills` -- but it stays here because
# it is genuinely a BCE mnemonic and the dispatch reaches the CNOP case first.
argsBCE = { "#BU": -1, "#BU@": -1, "#CMD": -1, "#CMDI": -1,
           "#CNOP": -1, "#DLY": -1, "#DLYI": -1, "#LBR": -1, "#LBR@": -1, "#LTO": -1, "#LTOI": -1, "#MIN": -1,
           "#MIN@": -1, "#MINC": -1, "#MOUT": -1, "#MOUT@": -1, "#MOUTC": -1, "#RDL": -1,
           "#RDLI": -1, "#RDS": -1, "#RIB": -1, "#SIB": -1, "#SSC": -1, "#SST": -1, "#STP": -1,
           "#TDL": -1, "#TDLI": -1, "#TDS": -1, "#WAT": -1, "#WIX": -1
       }

# THE TWO-BYTE MSC INSTRUCTIONS, in three formats, all derived from the
# original build in ~/workspace/PFS/"OI301700 as received" and checked against
# the format descriptions in the POO.  See ap101s-notes.db.
#
# MEMORY REFERENCE -- OP(4) M(1) DISP(11).  The displacement is PC-RELATIVE
# from the UPDATED PC, that is from the halfword after this instruction, and
# is signed.  M is the index-mode flag: it is 1 exactly when the operand is
# written with an index in parentheses, `@L TSTMASK(1)`, and 0 otherwise.
# This format is NOT in the POO in any findable form and was read off the
# original build.  (The POO's "Short format 1 ... OP M DISP" passage is in its
# BCE section and does not describe these.)
mscMemory = { "@L": 0x4, "@A": 0x5, "@N": 0x6, "@X": 0x7,
              "@ST": 0x8, "@TSZ": 0x9 }

# BRANCHES -- OP(4)=0010 M(1) CC(3) DISP(8), the displacement again signed and
# relative to the updated PC.  This one IS documented: the POO's @BC and @BXC
# pages (II-38 and II-39) give the layout, say the displacement is added to
# the updated MSC program counter with a range of -128 to +127 halfwords, and
# tabulate the condition codes -- 1 >0, 2 <0, 3 !=0, 4 =0, 5 >=0, 6 <=0,
# 7 always -- against both the accumulator mnemonics and the index-register
# ones.  The two families differ only in M, which is why @BNN is 0x25 and
# @BXNN 0x2D.  @BC and @BXC state the condition as an operand instead and are
# handled separately.
mscBranch = { "@B": (0, 7), "@BN": (0, 2), "@BNN": (0, 5), "@BNZ": (0, 3),
              "@BZ": (0, 4), "@BP": (0, 1), "@BNP": (0, 6),
              "@BXNN": (1, 5), "@BXN": (1, 2), "@BXP": (1, 1),
              "@BXNP": (1, 6), "@BXZ": (1, 4), "@BXNZ": (1, 3) }

# IMMEDIATE -- an 8-bit opcode over an 8-bit operand.  Only those whose split
# is PROVEN by a non-zero operand somewhere in the corpus are listed; an
# instruction seen only with a zero operand would fit any layout and is left
# out deliberately.  @DLY, @INT, @RAW and @STP are also left out because their
# high byte varies, so it carries a modifier this does not yet account for.
mscImmediate = { "@LI": 0xEF, "@LXI": 0xEB, "@TXI": 0xEA, "@TXA": 0xEC,
                 "@TI": 0xED, "@SAI": 0xEE, "@RAI": 0xD4, "@RNI": 0xD5,
                 "@LAR": 0xE0, "@RAW": 0xD0,
                 # These nine are written with a LITERAL ZERO operand
                 # everywhere in the corpus -- `@XAX 0`, `@SIO 0` -- and the
                 # halfword emitted is invariant, so the value below is not an
                 # extrapolation from anything: it is what the original build
                 # emits for exactly the source line the sources contain.  The
                 # opcode/operand BOUNDARY is still unattested, though, so a
                 # non-zero operand is diagnosed rather than encoded.
                 "@XAX": 0xE5, "@SIO": 0xE4, "@WAT": 0x08, "@RFD": 0xE2,
                 "@SFD": 0xE1, "@LMS": 0xE3, "@NIX": 0xE8, "@RBI": 0xE7,
                 "@TAX": 0xE9 }

# Those of the immediates whose operand is only ever zero, so that a non-zero
# one can be diagnosed instead of guessed at.  See the comment above.
mscImmediateZeroOnly = { "@XAX", "@SIO", "@WAT", "@RFD", "@SFD", "@LMS",
                         "@NIX", "@RBI", "@TAX" }

# Bit 4 of the halfword, 0x08 in the first byte, is the index flag -- the same
# position it occupies in the long format.  Only @RAW attests it among the
# short immediates: it is 0xD0 written plain and 0xD8 written `@RAW 0(1)`.
# For the others an index is diagnosed rather than assumed to work the same
# way, since a wrongly-placed index bit is silently wrong object code.
mscImmediateIndexable = { "@RAW" }

# THE FOUR-BYTE MSC INSTRUCTIONS.  The POO gives the layout on the @BU and
# @CALL pages (II-40, II-41):
#
#   OP(4)=1111  I(1)  SUBOP(3)  FIELD(5)  M(1)  ADDRESS(18)
#
# I is the index flag, set when the operand carries an index.  M is the
# INDIRECT flag, and the POO's effective-value tables are uniform about what
# it means: M=0 gives Address, M=1 gives (Address).  That is what the '@'
# mnemonic suffix sets, and it is also the whole difference between @CI
# (compare against the address itself) and @C (compare against what it points
# at).  The 18-bit address is in the same halfword units as the location
# counter, with no scaling for the fullword operations.
#
# FIELD is 5 bits whose meaning goes with the sub-opcode: the delta for
# @CALL, the BCE number for @LBB and @LBP -- both taken from the first
# operand -- and an operand-size selector for the loads and stores, 0 for a
# fullword and 1 for a halfword.  'operand' below means take it from the
# first operand.
#
# @TMI and @TM are the one pair of long forms NOT here.  They appear nowhere
# in the original build, and the POO's figure for them is too badly OCR'd to
# read the sub-opcode off.  7 would be the obvious guess and a guess is
# exactly what must not be made.
mscLong = { "@BU":   (0, 0, 0),        "@BU@":   (0, 1, 0),
            "@CALL": (1, 0, "operand"), "@CALL@": (1, 1, "operand"),
            "@LBB":  (2, 0, "operand"), "@LBB@":  (2, 1, "operand"),
            "@LBP":  (3, 0, "operand"), "@LBP@":  (3, 1, "operand"),
            "@LF":   (4, 0, 0),        "@LH":    (4, 0, 1),
            "@STF":  (5, 0, 0),        "@STH":   (5, 0, 1),
            "@CI":   (6, 0, 0),        "@C":     (6, 1, 0) }

# THE FOUR-BYTE BCE INSTRUCTIONS:  opcode byte, then the layout of bytes 1-3.
#
#   ADDRESS     one 24-bit value.  In the original build this field equals the
#               resolved effective address exactly, unlike a CPU instruction
#               where it is a displacement from a base register.
#   DISPCOUNT   byte 1 the displacement, bytes 2-3 the transfer count.  The
#               POO gives #MIN and #MOUT the operands "Displacement, Transfer
#               Count".
#   IUACOMMAND  byte 1 the IUA, bytes 2-3 the command.
#   PARAMETER   not an instruction at all but the parameter word that follows
#               a #MIN or #MOUT; opcode byte 00, then IUA and command.
#
# Derived from about 5500 instances in the original build, and pinned by the
# ones whose operands are literal and so need no symbol table:  `#MIN 0,13` is
# F100000D, `#MOUT 2,0` is F5020000, `#TDLI 511` is F40001FF.  The two fields
# of IUACOMMAND are pinned by `#CMDI FIOLMIUA,FIOFFIUA*256+12` giving F6400A0C,
# whose *256+12 could only land that way if byte 1 and bytes 2-3 were separate.
# 0x08 distinguishes the indirect "@" forms.  See ap101s-notes.db.
#
# The two-byte BCE instructions are deliberately absent.  Their opcode/operand
# boundary cannot be read off the listings, most of their observed operands
# being zero -- #WAT occurs 1105 times as 0800 and never otherwise -- so
# encoding them would be guesswork.
bceLong = {
    "#BU":    (0xF0, "ADDRESS"),    "#BU@":   (0xF8, "ADDRESS"),
    "#MIN":   (0xF1, "DISPCOUNT"),  "#MIN@":  (0xF9, "ADDRESS"),
    "#LBR":   (0xF2, "ADDRESS"),    "#LBR@":  (0xFA, "ADDRESS"),
    "#RDLI":  (0xF3, "ADDRESS"),    "#RDL":   (0xFB, "ADDRESS"),
    "#TDLI":  (0xF4, "ADDRESS"),    "#TDL":   (0xFC, "ADDRESS"),
    "#MOUT":  (0xF5, "DISPCOUNT"),  "#MOUT@": (0xFD, "ADDRESS"),
    "#CMDI":  (0xF6, "IUACOMMAND"), "#CMD":   (0xFE, "ADDRESS"),
    "#MINC":  (0x00, "PARAMETER"),  "#MOUTC": (0x00, "PARAMETER"),
    }

# EMPTY, where it used to be the whole of argsBCE.  Every BCE instruction
# observed in the original build carries an operand -- the POO gives #MIN and
# #MOUT "Displacement, Transfer Count" and #CMDI "IUA, Command" -- so treating
# them as operandless threw those operands away in the operand-joining phase,
# long before the code generator could object.  With no operand there was no
# AST, and every one of them fell through to the unrecognized-operation
# catch-all.  That is why no module using a BCE instruction ever reached the
# silently-wrong four zero bytes the MSC instructions produce: they always
# failed loudly instead.
instructionsWithoutOperands = { }
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
    "DC": "dcOperands", "DS": "dsOperands", "ORG": "orgAll"
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

# LAST, because @CNOP and #CNOP are members of argsMSC and argsBCE and the two
# loops above would otherwise give them an instruction operand rule.  They are
# not instructions:  all three CNOPs are alignment directives whose single
# operand is an ordinary arithmetic expression, which is what equOperand
# parses, stopping at the first blank so a trailing comment does no harm.
for operation in cnopFills:
    appropriateRules[operation] = "equOperand"

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
    
