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
# A NEGATIVE VALUE IS TWO'S COMPLEMENT IN THE THREE BYTES, not an error.  An
# ENTRY may sit BEFORE its own section: PCGEN's `&CURLABL EQU *-FIOBUS&STRTBUS`
# puts FIOADCNS's FIOIPR two halfwords ahead of it, as a virtual base for
# bus-indexed addressing.  lnk101's objModule.py decodes the field that way and
# its comment names that symbol; without the mask this raised OverflowError.
def be24(val): return (val & 0xFFFFFF).to_bytes(3, 'big')
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


def writePROT(f, sectName, ranges, seqNum):
    """Write ' PROT <csect> <s>-<e>,...' store-protect control cards.

    NOT AN OBJECT RECORD, and that distinction is the whole point.  An object
    module record has 0x02 in column 1; ap101Utils/objModule.py routes those to
    Record.from_image() and everything else to ControlRecord, and lnk101 reads
    PROT only from the ControlRecord list (lnk101/linker.py, "' PROT <csect>
    [<s>-<e>,...]' control cards: asm101's SPON/SPOFF capture").  A 0x02 record
    typed "PRT" was tried first and is INVISIBLE to the linker -- it would have
    integrated cleanly, produced nothing, and passed every test.

    There is precedent for the carrier inside the format: HAL/S-FC's PASS2
    already interleaves " STACK <csect>" cards in the object stream.

    The ranges are the PROTECTED regions, as CSECT-RELATIVE halfword offsets,
    in HEX without a prefix, END-EXCLUSIVE.  Naming a csect on a PROT card takes
    it out of the deck-level SET/CLEAR scheme entirely (linker.py adds it to
    protManaged), so a csect whose marks leave nothing protected still gets a
    card, with an empty range list, meaning exactly that.  Several cards for one
    csect accumulate, so a long list simply continues onto the next card.
    """
    pieces = ["%X-%X" % (a, b) for a, b in ranges]
    # 80-column card, and the linker splits on whitespace, so keep well inside
    # it and continue rather than truncate.
    batches, cur = [], []
    for piece in pieces:
        trial = ",".join(cur + [piece])
        if len(" PROT %s %s" % (sectName, trial)) > 71:
            batches.append(cur)
            cur = [piece]
        else:
            cur.append(piece)
    batches.append(cur)

    for batch in batches:
        text = " PROT %s" % sectName
        if batch:
            text += " " + ",".join(batch)
        card = bytearray([0x40] * 80)
        card[0:len(text)] = toEbcdic(text, len(text))
        f.write(bytes(card))
        seqNum += 1

    return seqNum


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
        if r.get('type') == 'Z' and 'rldFlags' in r:
            # The caller has worked out whether this ZCON is code or data; see
            # the note where it does.  0x04/0x10 patch BSR, 0x50 patches DSR.
            rldFlags = r['rldFlags']
        elif r.get('type') == 'Z':
            # ZCON uses flag byte 0x04 (2-byte address relocation, no negation)
            # Note: The AP-101S object format spec documents ZCON flags as
            # 0x20/0x40/0x50, not 0x04.  Flag 0x04 works with the current
            # LNK101S because it falls through to the 2-byte length case,
            # but may not match the documented AP-101S flag encoding.
            rldFlags = 0x04
        elif r.get('type') == 'Y':
            # YCON: halfword address relocation.  BIT 7 IS THE SIGN, and a
            # negative displacement is emitted as its MAGNITUDE with that bit
            # set -- OBJECTGE.xpl's V flag, which lnk101's addrcon.py reads as
            # "existing is the absolute value of a negative" and subtracts.
            # Without it `DC Y(SYM-1)` links as SYM+1.
            rldFlags = 0x80 if r.get('negative') else 0x00
        else:
            # Standard 4-byte address constant.  0x9C is that byte with the
            # sign bit: the field holds the MAGNITUDE of a negative
            # displacement, which is what the contemporary listing shows.
            rldFlags = 0x9C if r.get('negative') else 0x1C
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

            # STORE-PROTECT RANGES, one PROT control card set per control section that
        # carries any SPON/SPOFF.  Suppressed entirely by --no-store-protect, which
        # is what makes the feature testable: with it, this file must be bit-for-bit
        # what the assembler produced before any of this existed.
        if metadata.get("storeProtect", True):
            byState = {}
            for t in metadata.get("protects", []):
                byState.setdefault(t["section"], []).append(t)
            for sectName in sects:
                if sectName not in byState or sects[sectName].get("dsect"):
                    continue
                nHw = (sects[sectName].get("used", 0) + 1) // 2
                if nHw <= 0:
                    continue
                # Walk the marks, carrying the state forward, and collect the runs
                # that are PROTECTED.  The state before the first mark is
                # --protect-default; the state after the last runs to the end of the
                # section, which is why SPOFF with no matching SPON needs no
                # diagnostic to be meaningful.
                state = metadata.get("protectDefault", True)
                marks = sorted(byState[sectName], key=lambda t: t["offset"])
                ranges, runStart = [], (0 if state else None)
                for t in marks:
                    hw = min(t["offset"] // 2, nHw)
                    if t["protect"] and runStart is None:
                        runStart = hw
                    elif not t["protect"] and runStart is not None:
                        if hw > runStart:
                            ranges.append((runStart, hw))
                        runStart = None
                if runStart is not None and nHw > runStart:
                    ranges.append((runStart, nHw))
                seqNum = writePROT(f, sectName, ranges, seqNum)
    
            # THE END RECORD CARRIES NO ENTRY POINT, because no source names one.
            # This used to take `next(iter(entries))` -- an arbitrary element of a
            # SET -- and write that symbol's address into the END record.  Two
            # things were wrong with it.
            #
            # It was not even deterministic: hash order varies from process to
            # process, so BILDNEW5 assembled twice gave `END entry=0303C` one time
            # and `END entry=034FA` the next, with all 5022 other lines of the
            # normalized dump identical, and the value reached the linked image.
            #
            # And there was nothing to choose from in the first place.  An entry
            # point comes from the END statement's operand, `END SYMBOL`, and
            # EVERY module here writes a bare END: 702 of 702 across OI340600,
            # OI301700 and RUNASM, with 101 of them declaring ENTRY symbols that
            # this code was picking among.  A bare END specifies no entry point,
            # and the loader takes the start of the first control section.
            #
            # If a source ever does name one, model101.py must capture it first --
            # `END` there simply breaks out of the loop and the operand is
            # discarded -- and the value should be passed in rather than guessed.
            writeEND(f, None, None, "ASM101S 0.00", seqNum)
    
        return filename
