#!/usr/bin/env python3
'''
The author (Ron Burkey) declares that this file is in the public domain in the
U.S., and may freely be used, modified, or distributed for any purpose whatever.

The purpose is to read an IBM AP-101S object file (or more-generally I suppose,
a System/360 object file) and to decode it into the form of a Python structure.
I'm unaware of any existing software that does this, outside of System/360 
software itself.

References:
    https://en.wikipedia.org/wiki/OS/360_Object_File_Format
    https://publibz.boulder.ibm.com/epubs/pdf/iea2b270.pdf#page=209
(The latter is IBM document "MVS Program Management: Advanced Facilities", 
Appendix A.)
'''

import copy
from asciiToEbcdic import *

def bytearrayToInteger(data):
    i = 0
    for b in data:
        i = (i << 8) | b
    return i

def isBytearrayBlank(data):
    for b in data:
        if b != 0x40:
            return False
    return True

def bytearrayToAscii(data):
    ascii = ""
    for b in data:
        if b == 0x00:
            ascii += "a"
        elif b == 0x01:
            ascii += "b"
        elif b == 0x02:
            ascii += "c"
        else:
            ascii += ebcdicToAscii[b]
    return ascii

symbolTypes = [ "SD", "LD", "ER", "PC", "CM", "XD/PR", "WX", 
               "SD(QUAD)", "PC(QUAD", "CM(QUAD"]
def parseModuleSymbol(oi, symbol, data):
    symdict = {}
    oi[symbol] = symdict
    name = bytearrayToAscii(data[:8])
    symdict["name"] = name
    typ = data[8]
    if typ < 0 or typ >= len(symbolTypes):
        oi["errors"].append("Error: Unknown type for module symbol %s" % symbol)
        typ = "??"
    else:
        symdict["type"] = symbolTypes[typ]
        typ = symdict["type"]
    typ2 = typ[:2]
    if typ2 not in ["ER", "XD", "WX"]:
        symdict["address"] = bytearrayToInteger(data[9:12])
    if typ2 == "XD":
        symdict["alignment"] = data[12]
    elif typ2 in ["ER", "LD", "WX"]:
        if data[12] != 0x40:
            oi["errors"].append("Warning: Stray byte in module symbol %s" % symbol)
    else:
        flags = data[12]
        if (flags & 0b00100000) != 0:
            symdict["RMODE64"] = True
        elif (flags & 0b00000100) == 0:
            symdict["RMODE24"] = True
        else:
            symdict["RMODE31ANY"] = True
        if (flags & 0b00010000) != 0:
            symdict["AMODE64"] = True
        else:
            bit67 = flags & 3
            if bit67 == 0b00:
                symdict["AMODE24"] = True
            elif bit67 == 0b01:
                symdict["AMODE24"] = True
            elif bit67 == 0b10:
                symdict["AMODE31"] = True
            elif bit67 == 0b11:
                symdict["AMODEANY"] = True
        if (flags & 0b00001000) != 0:
            symdict["RSECT"] = True
        else:
            symdict["RW"] = True
    size = data[13:16]
    if typ2 in ["PC", "CM", "SD"]:
        symdict["length"] = bytearrayToInteger(size)
    elif typ2 == "LD":
        if size[0] != 0x40:
            oi["errors"].append("Warning: Stray byte in module symbol %s" % symbol)
        symdict["ldid"] = bytearrayToInteger(size[1:])
    elif typ2 in ["ER", "XD", "PR", "WX"]:
        if not isBytearrayBlank(size):
            oi["errors"].append("Warning: Stray data for module symbol %s" % symbol)

# The input `offset` is the column number of the next symbol.  Updates 
# `oi["symbols"]` (a list) in place, and returns the upated offset.
datatypes = {
    0x00: "C", 0x04: "X", 0x08: "B", 0x10: "F", 0x14: "H", 0x18: "E", 
    0x1C: "D", 0x20:"AQ", 0x24: "Y", 0x28: "S", 0x2C: "V", 0x30: "P",
    0x34: "z", 0x38: "L", 
    0x84: "Z" }
def parsePackedSymbol(packedSymbols, offset):
    symbol = { "packedOffset": offset }
    
    def getOutaHere():
        if offset >= len(packedSymbols):
            symbol["error"] = "Error: Bad offset %05X into SYM record" % offset
            return True
        return False
    
    if getOutaHere(): return None,symbol
    organization = packedSymbols[offset]
    offset += 1
    if getOutaHere(): return None,symbol
    symbol["offsetInCSECT"] = bytearrayToInteger(packedSymbols[offset:offset+3])
    offset += 3
    multiplicity = False
    cluster = False
    scaling = False
    dataItem = (organization & 0b10000000) != 0
    if dataItem:
        symbol["symbolType"] = "DATA"
        multiplicity = (organization & 0b01000000) != 0
        cluster = (organization & 0b00100000) != 0
        scaling = (organization & 0b00010000) != 0
    else:
        typ = (organization >> 4) & 0b111
        if typ == 0b000:
            symbol["symbolType"] = "SPACE"
        elif typ == 0b001:
            symbol["symbolType"] = "CONTROL"
        elif typ == 0b010:
            symbol["symbolType"] = "DUMMY"
        elif typ == 0b011:
            symbol["symbolType"] = "COMMON"
        elif typ == 0b100:
            symbol["symbolType"] = "INSTRUCTION"
        elif typ == 0b101:
            symbol["symbolType"] = "CCW"
        elif typ == 0b110:
            symbol["symbolType"] = "RELOCATABLE"
        else:
            symbol["error"] = "Error: Unknown symbol type %02X" % type
            return None,symbol
    if cluster:
        symbol["cluster"] = True
    hasName = (organization & 0b00001000) == 0
    nameLength = 1 + (organization & 0b111)
    name = ""
    if hasName:
        if getOutaHere(): return None,symbol
        name = bytearrayToAscii(packedSymbols[offset:offset+nameLength])
        symbol["name"] = name
        offset += nameLength
    if not dataItem:
        return offset,symbol
    if getOutaHere(): return None,symbol
    dataType = packedSymbols[offset]
    offset += 1
    if dataType in datatypes:
        symbol["dataType"] = datatypes[dataType]
    else:
        #symbol["error"] = 'Warning: Unknown data type %02X for symbol "%s"' % \
        #                    (dataType, name)
        symbol["dataType"] = "%02X" % dataType
    if symbol["dataType"] in ["C", "X", "B"]:
        if getOutaHere(): return None,symbol
        symbol["length"] = bytearrayToInteger(packedSymbols[offset:offset+2]) + 1
        offset += 2
    elif dataType in datatypes:
        if getOutaHere(): return None,symbol
        symbol["length"] = packedSymbols[offset] + 1
        offset += 1
    else:
        # This is here just to catch the (apparent) AP-101S datatype 0x84, for
        # which (empirically) there seems to be no length field.
        pass
    if multiplicity:
        if getOutaHere(): return None,symbol
        symbol["multiplicity"] = bytearrayToInteger(packedSymbols[offset:offset+3])
        offset += 3
    if scaling:
        if getOutaHere(): return None,symbol
        symbol["scale"] = bytearrayToInteger(packedSymbols[offset:offset+2])
        offset += 2
    return offset,symbol

def readObject101S(filename):
    object = { -1: { "errors": [] }, "numLines": 0 }
    symbols = []
    #afterEND = False
    try:
        f = open(filename, "rb")
        fullData = bytearray(f.read())
        f.close()
    except:
        object[-1]["errors"].append("Error: Could not read file " + filename)
        return object, symbols
    #numLines = (len(fullData) + 79) // 80
    packedSymbols = bytearray(0)
    if False and len(fullData) % 80 != 0:
        object[-1]["errors"].append("Warning: File size not a multiple of 80")
    deckOffset = 0
    while deckOffset < len(fullData):
        i = object["numLines"]
        object["numLines"] += 1
        if fullData[deckOffset] == 0x02:
            data = fullData[deckOffset:deckOffset+80]
            oi = { "errors": [], "lineData": data, "deckOffset": deckOffset,
                  "type": "???", "ident": " "*8 }
            object[i] = oi
            deckOffset += 80
        else:
            try:
                nextCard = fullData.index(0x02, deckOffset)
            except:
                nextCard = len(fullData)
            data = fullData[deckOffset:nextCard]
            oi = { "errors": [], "lineData": data,  "deckOffset": deckOffset,
                  "type": "HDR", "text": bytearrayToAscii(data), "ident": " "*8 }
            object[i] = oi
            deckOffset = nextCard
            continue
        d = oi["lineData"]
        #if afterEND:
        #    oi["type"] = "HDR"
        #    oi["text"] = bytearrayToAscii(d)
        #    continue
        # Parse the common fields.
        if d[0] != 0x02:
            oi["errors"].append("Error: Line does not begin with 0x02")
            continue
        typ = bytearrayToAscii(d[1:4])
        oi["type"] = typ
        address = d[5:8]
        size = d[10:12]
        flagBits = d[12:14]
        esdid = d[14:16]
        data = d[16:72]
        ident = bytearrayToAscii(d[72:80])
        oi["ident"] = ident
        if typ == "ESD":
            if not isBytearrayBlank(address):
                oi["errors"].append("Warning: Non-blank address field")
            oi["size"] = bytearrayToInteger(size)
            if not isBytearrayBlank(flagBits):
                oi["errors"].append("Warning: Flag-bit field not blank")
            if not isBytearrayBlank(esdid):
                oi["esdid"] = bytearrayToInteger(esdid)
            if oi["size"] >= 16:
                parseModuleSymbol(oi, "symbol1", data[:16])
            if oi["size"] >= 32:
                parseModuleSymbol(oi, "symbol2", data[16:32])
            if oi["size"] >= 48:
                parseModuleSymbol(oi, "symbol3", data[32:48])
            if not isBytearrayBlank(data[48:56]):
                oi["errors"].append("Warning: Stray non-blank characters")
        elif typ == "TXT":
            oi["relativeAddress"] = bytearrayToInteger(address) 
            oi["size"] = bytearrayToInteger(size)
            if not isBytearrayBlank(flagBits):
                oi["errors"].append("Warning: Flag-bit field not blank")
            oi["esdid"] = bytearrayToInteger(esdid)
            oi["data"] = tuple(data)
        elif typ == "RLD":
            if not isBytearrayBlank(address):
                oi["errors"].append("Warning: Non-blank address field")
            oi["size"] = bytearrayToInteger(size)
            pass
        elif typ == "SYM":
            if not isBytearrayBlank(address):
                oi["errors"].append("Warning: Non-blank address field")
            oi["size"] = bytearrayToInteger(size)
            if not isBytearrayBlank(flagBits):
                oi["errors"].append("Warning: Non-blank flag-bit field")
            if not isBytearrayBlank(esdid):
                oi["errors"].append("Warning: Non-blank ESDID field")
            oi["symbols"] = []
            packedSymbols += oi["lineData"][16:16+oi["size"]]
            offset = 16
        elif typ == "XSD":
            if not isBytearrayBlank(address):
                oi["errors"].append("Warning: Non-blank address field")
            oi["size"] = bytearrayToInteger(size)
            pass
        elif typ == "END":
            #afterEND = True
            if not isBytearrayBlank(address):
                oi["entryAddress"] = bytearrayToInteger(address) 
            if not isBytearrayBlank(size):
                oi["errors"].append("Warning: Size field not blank")
            if not isBytearrayBlank(flagBits):
                oi["errors"].append("Warning: Flag-bit field not blank")
            if not isBytearrayBlank(esdid):
                oi["esdid"] = bytearrayToInteger(esdid)
            
            if d[28] == 0x00:
                oi["length"] = bytearrayToInteger(d[28:32])
            flagField = d[32]
            if flagField in [0xF1, 0xF2]: # Type 1 or 2
                if d[28] == 0x00:
                    oi["length"] = bytearrayToInteger(d[28:32])
                if flagField == 0xF1:
                    oi["entryAddress"] = bytearrayToInteger(address)
                    oi["esdid"] = bytearrayToInteger(esdid)
                elif flagField == 0xF2:
                    if not isBytearrayBlank(d[16:24]):
                        oi["entryName"] = bytearrayToAscii(d[16:24])
                oi["idrType"] = ebcdicToAscii[flagField]
                oi["translator"] = bytearrayToAscii(d[33:52])
                oi["processor"] = bytearrayToAscii(d[52:71])
            elif flagField == 0x40:
                oi["idrType"] = ' ' # No IDR data
            else:
                oi["errors"].append("Error: Unsupported flag field")
                oi["idrType"] = '?'
            pass
        else:
            oi["errors"].append("Error: Unrecognized line type")
            continue
    offset = 0
    while offset < len(packedSymbols):
        if len(symbols) >= 9: ###DEBUG###
            pass
        offset, symbol = parsePackedSymbol(packedSymbols, offset)
        if offset != None: # No error
            symbols.append(symbol)
        else:
            oi["errors"].append("Error: Undetermined error in symbol table")
        if "error" in symbol:
            oi["errors"].append(symbol["error"])
        if offset == None:
            break
    return object, symbols

if __name__ == "__main__":
    import sys
    
    # Parse command line.
    helpMsg = '''
This file is used as an importable module for other Python 3 programs, for 
reading the contents of an IBM AP-101S object-code file, or else can be used
for test purposes in stand-alone mode.

The stand-alone usage is:
    readObject101S.py [OPTIONS] OBJECT.obj

There are presently no available options other than --help, which shows this
message.
'''
    object = None
    for parm in sys.argv[1:]:
        if parm == "--help":
            print(helpMsg)
            sys.exit(0)
        elif parm.startswith("-"):
            print("Error: Unknown command-line parameter " + parm)
            sys.exit(1)
        else:
            object, symbols = readObject101S(parm)
            break
    if object == None:
        print("Error: No filename specified")
        sys.exit(1)
    
    if True: ###DEBUG###
        
        # `symSym` is "symbol1", "symbol2", or "symbol3"
        def printSymbolESD(symSym):
            if symSym not in line:
                return
            sym = copy.deepcopy(line[symSym])
            msg = "\n\t%s:" % symSym
            if "name" in sym:
                msg += ' name="%s"' % sym.pop("name")
            if "type" in sym:
                msg += ' type=%s' % sym.pop("type")
            if "address" in sym:
                msg += ' address=%06X' % sym.pop("address")
            if "length" in sym:
                msg += ' length=%04X' % sym.pop("length")
            popThese = []
            for key in sorted(sym):
                if isinstance(sym[key], bool) and sym[key]:
                    msg += ' %s' % key
                    popThese.append(key)
            for key in popThese:
                sym.pop(key)
            if len(sym) > 0:
                msg += ' other=%s' % str(sym)
            print(msg, end="")
        
        for errMsg in object[-1]["errors"]:
            print(errMsg)
        for i in range(object["numLines"]):
            line = object[i]
            for errMsg in line["errors"]:
                print(errMsg)
            if line["deckOffset"] % 80 != 0: ###DEBUG###
                pass
            
            typ = line["type"]
            print("%04X: " % line["deckOffset"], end="")
            if False and typ == "SYM": ###DEBUG###
                for j in range(16, 72):
                    if j > 0 and (j & 0x07) == 0:
                        print("- ", end="")
                    print("%02X " % line["lineData"][j], end="")
                print()
            if typ not in ["ESD", "TXT", "END", "SYM", "RLD", "HDR"]:
                for b in line["lineData"]:
                    print("%02X" % b, end="")
                print()
            print('\ttype=%s ident="%s"' % (typ, line["ident"]), end="")
            if typ == "ESD":
                print(" size=%04X esdid=%04X" % (line["size"], line["esdid"]), end="")
                for j in range(1, 4):
                    printSymbolESD("symbol%d" % j)
            elif typ == "TXT":
                print(" offset=%06X" % line["relativeAddress"], end="")
                print(" size=%04X" % line["size"], end="")
                print(" esdid=%04X" % line["esdid"], end="")
                print("\n\tdata:", end="")
                for i in range(line["size"]):
                    #if (i & 31) == 15:
                    #    print("  | ", end="")
                    if i > 0 and (i & 15) == 0:
                        print("\n\t     ", end="")
                    print(" %02X" % line["data"][i], end="")
            elif typ == "RLD":
                size = line["size"]
                print(" size=%04X" % size, end="")
                for j in range(0, size, 8):
                    data = line["lineData"][16+j:16+j+8]
                    msg = "\n\trelocation=%04X" % bytearrayToInteger(data[:2])
                    msg += " position=%04X" % bytearrayToInteger(data[2:4])
                    flags = data[4]
                    msg += " flags=(%d" % ((flags >> 7) & 1)
                    msg += ",%d" % ((flags >> 6) & 1)
                    msg += ",%s" % ("A", "V", "Q", "CXD")[(flags >> 4) & 3]
                    msg += ",%d" % (1 + ((flags >> 2) & 3))
                    msg += ",%d" % ((flags >> 1) & 1)
                    msg += ",%d)" % (flags & 1)
                    msg += " address=%06X" % bytearrayToInteger(data[5:])
                    print(msg, end="")
            elif typ == "SYM":
                inSYMs = True
                print(" size=%04X" % line["size"], end="")
                for symbol in line["symbols"]:
                    print("\n\t%s" % str(line["symbols"][symbol]), end="")
            elif typ == "XSD":
                pass
            elif typ == "END":
                if "entryAddress" in line:
                    print(" entryAddress=%06X" % line["entryAddress"], end="")
                if "esdid" in line:
                    print(" esdid=%04X" % line["esdid"], end="")
                if "length" in line:
                    print(' length=%d' % line["length"], end="")
                if "entryName" in line:
                    print(' entryName="%s"' % line["entryName"], end="")
                if "idrType" in line:
                    print(' idrType="%s"' % line["idrType"], end="")
                if "translator" in line:
                    print('\n\ttranslator="%s"' % line["translator"], end="")
                if "processor" in line:
                    print('\n\tprocessor="%s"' % line["processor"], end="")
            elif typ == "HDR":
                print(' length=%d' % len(line["text"]), end="")
                print('\n\ttext="%s"' % line["text"], end="")
            else:
                pass
            print()

    if len(symbols) > 0:
        print("-"*80)
        print("SYM-Record Summary:")
        for symbol in symbols:
            msg = '\t%-11s offset=%06X' % (symbol["symbolType"], symbol["offsetInCSECT"])
            if "name" in symbol:
                msg += ' name="%s"' % symbol["name"]
            if "dataType" in symbol:
                msg += ' datatype=%s' % symbol["dataType"]
            if "cluster" in symbol:
                msg += " cluster"
            if "multiplicity" in symbol:
                msg += " multiplicity=%d" % symbol["multiplicity"]
            if "scale" in symbol:
                msg += " scale=%d" % symbol["scale"]
            print(msg)
        #print("-"*80)
            