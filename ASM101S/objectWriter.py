#!/usr/bin/env python3
'''
License:    This program is declared by its author to be the U.S. Public Domain,
            and may be freely used, modified, or distributed for any purpose.
Filename:   objectWriter.py
Purpose:    Emit IBM object module format
Reference:  http://bitsavers.informatik.uni-stuttgart.de/pdf/ibm/360/os/R01-08/C28-6538-3_Linkage_Editor_Oct66.pdf
'''

from asciiToEbcdic import asciiToEbcdic

def toEbcdic(s, length=8):
    return bytearray(
        asciiToEbcdic[ord(s[i])] if i < len(s) and ord(s[i]) < 128 else 0x40
        for i in range(length)
    )

def be16(val): return val.to_bytes(2, 'big')
def be24(val): return val.to_bytes(3, 'big')
def blanks(n): return bytearray([0x40] * n)  # EBCDIC blanks

def makeCard(recType, data, seqNum):
    card = blanks(80)
    card[0] = 0x02
    card[1:4] = toEbcdic(recType, 3)
    card[4:4+min(len(data), 68)] = data[:68]
    card[72:80] = toEbcdic(f"{seqNum % 100000000:08d}", 8)
    return card

def writeESD(f, esdItems, seqNum):
    """Write ESD (External Symbol Dictionary) records. Up to 3 items per card.

    ESD entry format (16 bytes per entry):
      - bytes 0-7: Symbol name (EBCDIC, blank-padded)
      - byte 8: Type code (0=SD, 1=LD, 2=ER, 3=PC, 4=CM, 5=XD/PR, 6=WX)
      - bytes 9-11: Address (3 bytes, big-endian)
      - byte 12: For SD/PC/CM = AMODE/RMODE flags; for ER/LD/WX = blank (0x40)
      - bytes 13-15: For SD/PC/CM = length; for LD = [0x40, LDID]; for ER/WX = blank
    """
    items = list(esdItems)
    for i in range(0, len(items), 3):
        batch = items[i:i+3]

        data = blanks(68)
        data[6:8] = be16(len(batch) * 16)
        data[10:12] = be16(batch[0]['esdId'])
        
        for j, item in enumerate(batch):
            o = 12 + j * 16
            data[o:o+8] = toEbcdic(item['name'], 8)
            data[o+8] = item['typeCode']
            data[o+9:o+12] = be24(item.get('address', 0))

            typeCode = item['typeCode']
            if typeCode == 0x01:  # LD (Label Definition)
                data[o+12] = 0x40  # Flags: blank
                # Length field: [0x40, LDID high, LDID low]
                ldid = item.get('ldid', 0)
                data[o+13] = 0x40
                data[o+14:o+16] = be16(ldid)
            elif typeCode == 0x02 or typeCode == 0x06:  # ER or WX
                data[o+12] = 0x40  # Flags: blank
                data[o+13:o+16] = bytearray([0x40, 0x40, 0x40])  # Length: blank
            else:  # SD, PC, CM, XD
                data[o+12] = item.get('flags', 0)
                data[o+13:o+16] = be24(item.get('length', 0))
        
        f.write(makeCard("ESD", data, seqNum))
        seqNum += 1
    
    return seqNum

def writeTXT(f, esdId, address, data, seqNum):
    """Write TXT records. Up to 56 bytes of object code per card."""
    for offset in range(0, len(data), 56):
        chunk = data[offset:offset+56]

        cardData = blanks(68)
        cardData[1:4] = be24(address + offset)
        cardData[6:8] = be16(len(chunk))
        cardData[10:12] = be16(esdId)
        cardData[12:12+len(chunk)] = chunk
        
        f.write(makeCard("TXT", cardData, seqNum))
        seqNum += 1
    
    return seqNum

def writeRLD(f, relocations, seqNum):
    """Write RLD (Relocation Dictionary) records. Up to 7 entries per card."""
    if not relocations:
        return seqNum
    
    for i in range(0, len(relocations), 7):
        batch = relocations[i:i+7]
        
        cardData = blanks(68)
        cardData[6:8] = be16(len(batch) * 8)
        
        for j, reloc in enumerate(batch):
            o = 12 + j * 8
            cardData[o:o+2] = be16(reloc['relId'])
            cardData[o+2:o+4] = be16(reloc['posId'])
            cardData[o+4] = reloc.get('flags', 0)
            cardData[o+5:o+8] = be24(reloc['address'])
        
        f.write(makeCard("RLD", cardData, seqNum))
        seqNum += 1
    
    return seqNum

def writeEND(f, entryEsdId=None, entryAddr=None, ident="ASM101S", seqNum=1):
    """Write END record with optional entry point and assembler identification.

    Format:
    - Bytes 1-3: Entry address
    - Bytes 10-11: ESD ID of entry point
    - Byte 32: IDR type (blank=no IDR, F1=type 1, F2=type 2)
    - Bytes 33-51: Translator identification (if IDR present)
    - Bytes 52-70: Processor identification (if IDR present)
    """
    cardData = blanks(68)
    cardData[1:4] = be24(entryAddr) if entryAddr is not None else bytearray([0x40, 0x40, 0x40])
    if entryEsdId is not None:
        cardData[10:12] = be16(entryEsdId)
    # Byte 32 = IDR type, blank means no IDR data
    cardData[32] = 0x40
    # Put translator ident at bytes 33-51 if provided (19 chars)
    if ident:
        cardData[33:52] = toEbcdic(ident, 19)
    f.write(makeCard("END", cardData, seqNum))
    return seqNum + 1


def writeObjectModule(filename, metadata, symtab, sects, entries, extrns):
    esdItems, esdIdMap, nextEsdId = [], {}, 1
    # SECTIONS NEED THEIR OWN MAP, because `esdIdMap` is keyed by NAME and holds
    # sections, labels and external references in one namespace -- so an
    # `ENTRY X` inside `X CSECT` overwrote the SD's id with the LD's, and every
    # consumer that means "the ESD id of a control section" silently got the id
    # of a label instead: the TXT card, the RLD posId and the END entry point.
    # An LD or ER id is never a legitimate answer to any of those three.
    #
    # FCMTBLPG is the whole failure in four cards.  Its one card is `BMTBLE PG`,
    # which expands to `FCMTBLPG CSECT` / `ENTRY FCMTBLPG` / `EXTRN FCMBMTPG` /
    # `DC Y(FCMBMTPG)`, so the collision is guaranteed; the RLD came out
    # `R=3 P=2` naming the LD, lnk101 discarded it as not naming a section, and
    # the halfword stayed 0000 where the dump has A7EE -- which is exactly where
    # the CSECT table puts FCMBMTPG.
    #
    # NOTE THAT NO LISTING COMPARISON CAN CATCH THIS.  An assembly listing prints
    # 0000 for an unresolved external too, so the entire OI301700 corpus can be
    # byte-for-byte correct with every relocation in it thrown away.  Linking is
    # the only thing that reads these records at all.
    sectIdMap = {}

    # Section Definitions (SD) for CSECTs
    for sectName, sectData in sects.items():
        if sectData.get('dsect'):
            continue
        esdIdMap[sectName] = nextEsdId
        sectIdMap[sectName] = nextEsdId
        esdItems.append({
            'esdId': nextEsdId,
            'name': sectName or '#MAIN',
            'typeCode': 0x00,  # SD
            'address': sectData.get('offset', 0) * 2,  # offset is in halfwords, card format uses bytes
            'flags': 0x00,
            'length': sectData.get('used', 0)
        })
        nextEsdId += 1
    
    # Entry points (LD)
    for entryName in entries:
        if (sym := symtab.get(entryName)):
            # Find the SD (CSECT) that contains this entry
            sectName = sym.get('section', '')
            ldid = sectIdMap.get(sectName, 1)  # Default to first SD
            esdIdMap[entryName] = nextEsdId
            esdItems.append({
                'esdId': nextEsdId,
                'name': entryName,
                'typeCode': 0x01,  # LD
                'address': (sym.get('address', 0) + sects.get(sectName, {}).get('offset', 0)) * 2,  # halfwords to bytes
                'ldid': ldid
            })
            nextEsdId += 1
    
    # External References (ER)
    for extName in extrns:
        esdIdMap[extName] = nextEsdId
        esdItems.append({
            'esdId': nextEsdId,
            'name': extName,
            'typeCode': 0x02,  # ER
        })
        nextEsdId += 1
    
    # Build RLD entries
    rldEntries = []
    for r in metadata.get('relocations', []):
        if r.get('symbol') not in esdIdMap or r.get('section') not in sectIdMap:
            continue
        # Determine RLD flags based on relocation type
        if r.get('type') == 'Z':
            # ZCON uses flag byte 0x04 (2-byte address relocation, no negation)
            # Note: The AP-101S object format spec documents ZCON flags as
            # 0x20/0x40/0x50, not 0x04.  Flag 0x04 works with the current
            # LNK101S because it falls through to the 2-byte length case,
            # but may not match the documented AP-101S flag encoding.
            rldFlags = 0x04
        elif r.get('type') == 'Y':
            # YCON: halfword address relocation
            rldFlags = 0x00
        else:
            # Standard 4-byte address constant
            rldFlags = 0x1C
        rldEntries.append({
            'relId': esdIdMap[r['symbol']],
            'posId': sectIdMap[r['section']],
            'flags': rldFlags,
            'address': r.get('address', 0)
        })
    
    with open(filename, 'wb') as f:
        seqNum = 1
        
        if esdItems:
            seqNum = writeESD(f, esdItems, seqNum)
        
        for sectName, sectData in sects.items():
            if sectData.get('dsect'):
                continue
            if (used := sectData.get('used', 0)) > 0:
                memory = sectData.get('memory', bytearray())
                seqNum = writeTXT(f, sectIdMap.get(sectName, 1), 0, bytes(memory[:used]), seqNum)
        
        if rldEntries:
            seqNum = writeRLD(f, rldEntries, seqNum)
        
        entryEsdId, entryAddr = None, None
        if entries and (firstName := next(iter(entries))) and (sym := symtab.get(firstName)):
            entryEsdId = sectIdMap.get(sym.get('section', ''), 1)
            entryAddr = sym.get('address', 0) * 2
        
        writeEND(f, entryEsdId, entryAddr, "ASM101S 0.00", seqNum)
    
    return filename
