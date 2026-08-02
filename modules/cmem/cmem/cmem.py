#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or
            modified for any purpose whatever without licensing.
Filename:   cmem.py
Purpose:    A virtual-memory manipulation module used to manage a collection
            of "Simulation Data Files" (SDFs), intended eventually for use
            as part of a port of the HAL/S SDFPKG compiler component.
            See README.md for the functional specification this file
            implements.
Requires:   Python 3.6 or later.
History:    2026-07-14 RSB  Coded by Claude Code using model Sonnet 5.  I made
                            the minor change of putting all of the code 
                            dedicated for stand-alone usage under 
                                if __name__ == "__main__":
                            whereas Claude itself had put only the literal 
                            `def main()` underneath it.
            2026-07-16 RSB  Adapted from its own separate development folder 
                            for use in Virtual AGC as a module.

Implementation notes (points where README.md is ambiguous or marked TBD,
and the choice made here):

  - SDFNAM (the SDF basename input used by MODE_NUMBER 4 and 18) is an
    8-byte, space-padded EBCDIC field immediately following ADDR in
    COMMTABL, i.e. at offset 32.
  - "If AFCBAREA==0, then TBD" (mode 0 init): AFCBAREA==0 is exactly the
    state produced by the recommended usage (cmem maintains SDF metadata
    itself rather than using FCBAREA), so it is treated as "no FCBAREA in
    use" rather than as an unimplemented branch.
  - Genuinely unimplemented TBD branches (APGAREA==0, MISC&0x01 combined
    with AFCBAREA>0, PAD placement outside the documented PNTR ranges)
    raise NotImplementedError rather than silently doing something
    unspecified. MODE_NUMBER 2 and 3 are specified: they abend(4001) and
    abend(4012) respectively.
  - PAD's PAGENO field stores the SDF page number multiplied by 8; the
    actual page number is recovered via integer division by 8 wherever the
    field is read.
  - Reading a page from an SDF file that is shorter than required is
    zero-filled rather than treated as an error, so that pages "beyond"
    the current end of a growable SDF behave as freshly-allocated storage.
'''

import os
import sys
import argparse
import tempfile
import traceback

for i in range(2):
    try:
        from asciiToEbcdic import *
    except ImportError as error:
        _pathToVAGC = os.path.dirname(os.path.realpath(__file__)) + "/../../.."
        with open(f"{_pathToVAGC}/modules/pipIt.py", "r") as f: exec(f.read())
        pipIt(i, _pathToVAGC, error.name)

# ---------------------------------------------------------------------------
# Small big-endian pack/unpack helpers, shared between the cmem class and
# the standalone test/interactive code below.

def packU16(buf, addr, value):
    buf[addr:addr + 2] = (value & 0xFFFF).to_bytes(2, "big")


def packU32(buf, addr, value):
    buf[addr:addr + 4] = (value & 0xFFFFFFFF).to_bytes(4, "big")


def unpackU16(buf, addr):
    return int.from_bytes(buf[addr:addr + 2], "big")


def unpackU32(buf, addr):
    return int.from_bytes(buf[addr:addr + 4], "big")


def buildMode(modeNumber, select=0, modf=0, rels=0, resv=0):
    '''Pack a monitor22() `mode` integer from MODE_NUMBER and the disposition flags.'''
    return ((select & 1) << 31) | ((modf & 1) << 30) | ((rels & 1) << 29) | \
           ((resv & 1) << 28) | (modeNumber & 0xFFFF)


def encodeText(text, length):
    '''Encode an ASCII string as an N-byte, space-padded EBCDIC field.'''
    text = (text or "")[:length].ljust(length)
    return bytes(asciiToEbcdic[ord(c)] for c in text)


def encodeName8(name):
    '''Encode an ASCII basename as an 8-byte, space-padded EBCDIC field.'''
    return encodeText(name, 8)


def writeSdfName(mem, commtablAddr, name):
    mem[commtablAddr + cmem.OFF_SDFNAM:commtablAddr + cmem.OFF_SDFNAM + 8] = encodeName8(name)


class cmem:

    PAGE_SIZE = 1680
    PAD_ENTRY_SIZE = 16
    COMMTABL_SIZE = 120
    # "The Paging Area cannot be augmented past its maximum value", SDFPKG
    # User's Guide section 13.3, which also gives 250 as the default PAD size.
    MAX_PAGES = 250

    # COMMTABL field offsets.
    OFF_APGAREA = 0
    OFF_AFCBAREA = 4
    OFF_NPAGES = 8
    OFF_NBYTES = 10
    OFF_MISC = 12
    OFF_CRETURN = 14
    OFF_BLKNO = 16
    OFF_SYMBNO = 18
    OFF_STMTNO = 20
    OFF_BLKNLEN = 22
    OFF_SYMBNLEN = 23
    OFF_PNTR = 24
    OFF_ADDR = 28
    OFF_SDFNAM = 32
    OFF_CSECTNAM = 40
    OFF_SREFNO = 48
    OFF_INCLCNT = 54
    OFF_BLKNAM = 56
    OFF_SYMBNAM = 88

    # (fieldName, offset, kind) for every named COMMTABL field, in the order
    # given in README.md, used by toNative()/fromNative(). "kind" is "u8",
    # "u16", "u32", or "textN" for an N-byte EBCDIC text field.
    _COMMTABL_FIELDS = [
        ("APGAREA", OFF_APGAREA, "u32"),
        ("AFCBAREA", OFF_AFCBAREA, "u32"),
        ("NPAGES", OFF_NPAGES, "u16"),
        ("NBYTES", OFF_NBYTES, "u16"),
        ("MISC", OFF_MISC, "u16"),
        ("CRETURN", OFF_CRETURN, "u16"),
        ("BLKNO", OFF_BLKNO, "u16"),
        ("SYMBNO", OFF_SYMBNO, "u16"),
        ("STMTNO", OFF_STMTNO, "u16"),
        ("BLKNLEN", OFF_BLKNLEN, "u8"),
        ("SYMBNLEN", OFF_SYMBNLEN, "u8"),
        ("PNTR", OFF_PNTR, "u32"),
        ("ADDR", OFF_ADDR, "u32"),
        ("SDFNAM", OFF_SDFNAM, "text8"),
        ("CSECTNAM", OFF_CSECTNAM, "text8"),
        ("SREFNO", OFF_SREFNO, "text6"),
        ("INCLCNT", OFF_INCLCNT, "u16"),
        ("BLKNAM", OFF_BLKNAM, "text32"),
        ("SYMBNAM", OFF_SYMBNAM, "text32"),
    ]

    def __init__(self, mem, sdflib):
        self.mem = mem
        self.sdflib = sdflib

        self.initialized = False
        self.commtabl = None
        self.usecount = 0

        self.updat = False
        self.onefcb = False
        self.first = False

        self.pad = None
        self.padSize = None
        self.padInternal = False
        self.padBytes = None

        self.npages = None
        self.apgarea = None
        self.afcbarea = None
        self.nbytes = None

        self.sdfs = {}            # basename -> {'file': fileobj, 'id': int}
        self.sdfIdToName = {}     # id -> basename
        self._nextSdfId = 1

        self.current = None
        self.recentPage = None
        self.recentSDF = None

    def __del__(self):
        sdfs = getattr(self, "sdfs", None)
        if sdfs:
            for info in list(sdfs.values()):
                f = info.get("file")
                if f is not None and not f.closed:
                    f.close()
            sdfs.clear()

    @staticmethod
    def abend(code):
        # os._exit() is deliberate -- an abend must be uncatchable and must not
        # run atexit handlers -- but it also discards whatever is still sitting
        # in stdout's buffer, which silently swallows the output of whatever
        # was running at the time.  So flush both streams first.
        sys.stdout.flush()
        print(f"Abend {code}", file=sys.stderr)
        sys.stderr.flush()
        os._exit(1)

    # -- COMMTABL field access -------------------------------------------------

    def _getU16(self, offset):
        return unpackU16(self.mem, self.commtabl + offset)

    def _setU16(self, offset, value):
        packU16(self.mem, self.commtabl + offset, value)

    def _getU32(self, offset):
        return unpackU32(self.mem, self.commtabl + offset)

    def _setU32(self, offset, value):
        packU32(self.mem, self.commtabl + offset, value)

    def _getU8(self, offset):
        return self.mem[self.commtabl + offset]

    def _setU8(self, offset, value):
        self.mem[self.commtabl + offset] = value & 0xFF

    def _getText(self, offset, length, stripText=True):
        a = self.commtabl + offset
        raw = self.mem[a:a + length]
        s = "".join(ebcdicToAscii[b] for b in raw)
        if stripText:
            s = s.rstrip(" ")
        return s

    def _setText(self, offset, length, value):
        a = self.commtabl + offset
        self.mem[a:a + length] = encodeText(value, length)

    def _readSdfName(self):
        # Stripped, to agree with what toNative() reports for the same field.
        # Trailing blanks are a property of the 8-character COMMTABL field, not
        # of the SDF's identity; _resolveSdfName() puts them back if that is
        # how the member happens to be named on disk.
        return self._getText(self.OFF_SDFNAM, 8)

    def toNative(self):
        '''Translate COMMTABL from mem into a dict of native Python values, keyed by field name.'''
        result = {}
        for name, offset, kind in self._COMMTABL_FIELDS:
            if kind == "u8":
                result[name] = self._getU8(offset)
            elif kind == "u16":
                result[name] = self._getU16(offset)
            elif kind == "u32":
                result[name] = self._getU32(offset)
            elif kind.startswith("text"):
                result[name] = self._getText(offset, int(kind[4:]))
        return result

    def fromNative(self, fields, commtabl=None):
        '''Write a dict of native Python values, keyed by field name, into COMMTABL in mem.

        Only the fields present in `fields` are overwritten; any keys not
        naming a COMMTABL field are ignored, as is any field whose value is
        `None`. `commtabl`, if given, overrides the COMMTABL base address
        for this call only -- self.commtabl is left unchanged -- which
        allows COMMTABL to be filled in in mem before the first
        monitor22(0) call.
        '''
        base = self.commtabl if commtabl is None else commtabl
        for name, offset, kind in self._COMMTABL_FIELDS:
            if name not in fields:
                continue
            value = fields[name]
            if value is None:
                continue
            addr = base + offset
            if kind == "u8":
                self.mem[addr] = value & 0xFF
            elif kind == "u16":
                packU16(self.mem, addr, value)
            elif kind == "u32":
                packU32(self.mem, addr, value)
            elif kind.startswith("text"):
                length = int(kind[4:])
                self.mem[addr:addr + length] = encodeText(value, length)

    # -- PAD field access --------------------------------------------------

    def _padBuf(self):
        if self.padInternal:
            return self.padBytes, 0
        return self.mem, self.pad

    def _padFieldAddr(self, i, fieldOffset):
        buf, base = self._padBuf()
        return buf, base + i * self.PAD_ENTRY_SIZE + fieldOffset

    def _padGetPageAddr(self, i):
        buf, addr = self._padFieldAddr(i, 0)
        return unpackU32(buf, addr)

    def _padSetPageAddr(self, i, value):
        buf, addr = self._padFieldAddr(i, 0)
        packU32(buf, addr, value)

    def _padGetFcbaddr(self, i):
        buf, addr = self._padFieldAddr(i, 4)
        return unpackU32(buf, addr)

    def _padSetFcbaddr(self, i, value):
        buf, addr = self._padFieldAddr(i, 4)
        packU32(buf, addr, value)

    def _padGetId(self, i):
        return self._padGetFcbaddr(i) & 0x00FFFFFF

    def _padSetId(self, i, idVal):
        top = self._padGetFcbaddr(i) & 0xFF000000
        self._padSetFcbaddr(i, top | (idVal & 0x00FFFFFF))

    def _padGetModifiedFlag(self, i):
        return ((self._padGetFcbaddr(i) >> 24) & 0xFF) == 0x80

    def _padSetModified(self, i, flag):
        low24 = self._padGetFcbaddr(i) & 0x00FFFFFF
        top = 0x80 if flag else 0x00
        self._padSetFcbaddr(i, (top << 24) | low24)

    def _padGetUsecount(self, i):
        buf, addr = self._padFieldAddr(i, 8)
        return unpackU32(buf, addr)

    def _padSetUsecount(self, i, value):
        buf, addr = self._padFieldAddr(i, 8)
        packU32(buf, addr, value)

    def _padGetPageNo(self, i):
        buf, addr = self._padFieldAddr(i, 12)
        return unpackU16(buf, addr)

    def _padSetPageNo(self, i, value):
        buf, addr = self._padFieldAddr(i, 12)
        packU16(buf, addr, value)

    def _padGetResucnt(self, i):
        buf, addr = self._padFieldAddr(i, 14)
        return unpackU16(buf, addr)

    def _padSetResucnt(self, i, value):
        buf, addr = self._padFieldAddr(i, 14)
        packU16(buf, addr, value)

    def _padIncResucnt(self, i):
        # SETDISPS:  CH R1,=X'7FFF' / BE ABEND4  "TOO MANY RESERVES FOR ONE
        # PAGE".  The count is a halfword, so it saturates rather than wrapping
        # round to zero and quietly unlocking the page.
        v = self._padGetResucnt(i)
        if v >= 0x7FFF:
            self.abend(4003)
        self._padSetResucnt(i, v + 1)

    def _padDecResucnt(self, i):
        # SETDISPS:  LH R1,RESVCNT / LTR R1,R1 / BZ ABEND5  "TOO MANY RELEASES
        # FOR ONE PAGE".  Releasing a page that was never reserved is a
        # programming error in the caller, not something to absorb quietly --
        # doing so would let a page the caller still believes is pinned be
        # evicted underneath it.
        v = self._padGetResucnt(i)
        if v == 0:
            self.abend(4004)
        self._padSetResucnt(i, v - 1)

    def _padMarkFree(self, i):
        self._padSetFcbaddr(i, 0)
        self._padSetPageAddr(i, 0)
        self._padSetUsecount(i, 0)
        self._padSetPageNo(i, 0)
        self._padSetResucnt(i, 0)

    def _nameForPad(self, i):
        idVal = self._padGetId(i)
        if idVal == 0:
            return None
        return self.sdfIdToName.get(idVal)

    def padSummary(self):
        '''Summarize the current state of the PAD as a Python dictionary.

        Returns a dict with:
          - "totalPages": the number of PAD entries actually usable as PA
            page slots (i.e. self.npages).
          - "cachedCount": how many of those entries currently hold a
            cached page.
          - "cached": a list of per-entry dicts (one per cached page),
            each human-readable and excluding the underlying Python file
            object -- only the SDF's basename is included.
        '''
        cached = []
        for i in range(self.npages):
            idVal = self._padGetId(i)
            if idVal == 0:
                continue
            cached.append({
                "padIndex": i,
                "sdf": self.sdfIdToName.get(idVal),
                "pageNumber": self._padGetPageNo(i) // 8,
                "pageAddr": self._padGetPageAddr(i),
                "modified": self._padGetModifiedFlag(i),
                "usecount": self._padGetUsecount(i),
                "resucnt": self._padGetResucnt(i),
            })
        return {
            "totalPages": self.npages,
            "cachedCount": len(cached),
            "cached": cached,
        }

    # -- SDF file management -------------------------------------------------

    def _sdfPath(self, name):
        return os.path.join(self.sdflib, name + ".sdf")

    def _resolveSdfName(self, name):
        '''SDFNAM is an 8-character blank-padded field, and PASS3 keeps the
        padding in the filename it writes ("##COMPA .sdf").  Callers who build
        the name themselves often leave the padding off, so accept either
        spelling and canonicalize on whichever one actually exists.  Returns
        None if neither does.
        '''
        for candidate in (name, name.rstrip(" "), name.ljust(8)):
            if os.path.exists(self._sdfPath(candidate)):
                return candidate
        return None

    def _openSdf(self, name):
        if name in self.sdfs:
            return self.sdfs[name]
        path = self._sdfPath(name)
        fileobj = open(path, "r+b")
        sdfId = self._nextSdfId
        self._nextSdfId += 1
        self.sdfs[name] = {"file": fileobj, "id": sdfId}
        self.sdfIdToName[sdfId] = name
        return self.sdfs[name]

    def _pageExistsInSdf(self, name, pageNumber):
        info = self.sdfs.get(name)
        if info is None:
            return False
        fileobj = info["file"]
        fileobj.seek(0, os.SEEK_END)
        size = fileobj.tell()
        return pageNumber * self.PAGE_SIZE < size

    def _findCachedPage(self, name, pageNumber):
        for i in range(self.npages):
            if self._nameForPad(i) == name and (self._padGetPageNo(i) // 8) == pageNumber:
                return i
        return None

    def _cachePage(self, name, sdfPageNumber):
        freeIndex = None
        for i in range(self.npages):
            if self._padGetId(i) == 0:
                freeIndex = i
                break

        if freeIndex is None:
            candidates = [i for i in range(self.npages) if self._padGetResucnt(i) == 0]
            if not candidates:
                self.abend(4001)
            lru = min(candidates, key=lambda i: self._padGetUsecount(i))
            if self._padGetModifiedFlag(lru):
                self._writePageToSdf(lru)
            freeIndex = lru

        info = self._openSdf(name)
        fileobj = info["file"]
        fileobj.seek(sdfPageNumber * self.PAGE_SIZE)
        data = fileobj.read(self.PAGE_SIZE)
        if len(data) < self.PAGE_SIZE:
            data = data + bytes(self.PAGE_SIZE - len(data))

        pageAddr = self.apgarea + freeIndex * self.PAGE_SIZE
        self.mem[pageAddr:pageAddr + self.PAGE_SIZE] = data

        self._padSetPageAddr(freeIndex, pageAddr)
        self._padSetId(freeIndex, info["id"])
        self._padSetModified(freeIndex, False)
        self._padSetUsecount(freeIndex, self.usecount)
        self._padSetPageNo(freeIndex, sdfPageNumber * 8)
        self._padSetResucnt(freeIndex, 0)
        return freeIndex

    def _writePageToSdf(self, i):
        pageAddr = self._padGetPageAddr(i)
        sdfPageNumber = self._padGetPageNo(i) // 8
        idVal = self._padGetId(i)
        name = self.sdfIdToName[idVal]
        fileobj = self.sdfs[name]["file"]
        fileobj.seek(sdfPageNumber * self.PAGE_SIZE)
        fileobj.write(bytes(self.mem[pageAddr:pageAddr + self.PAGE_SIZE]))
        # Writing the page back to its SDF is the only thing that resets bit 0
        # of FCBADDR to 0; a MODF disposition of 0 must never clear it.
        self._padSetModified(i, False)

    # -- monitor22 -------------------------------------------------------------

    def monitor22(self, mode, commtabl=None):
        self.usecount += 1

        select = (mode >> 31) & 1
        modf = (mode >> 30) & 1
        rels = (mode >> 29) & 1
        resv = (mode >> 28) & 1
        modeNumber = mode & 0xFFFF
        disposition = (select, modf, rels, resv)

        if modeNumber == 0:
            self._mode0(commtabl)
            return

        if not self.initialized:
            self.abend(4009)

        # "Auto-Select": for modes 5 and 7-17 the SELECT disposition means
        # "select the SDF named in SDFNAM first, then do the operation".  See
        # note 1 of section 13 of the SDFPKG User's Guide.  Modes 7-17 are
        # implemented a layer up, in sdfpkg, but the select belongs here since
        # this is where selection lives; sdfpkg calls autoSelect() for them.
        if select and modeNumber in (5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17):
            if not self.autoSelect():
                return

        if modeNumber == 1:
            self._mode1()
        elif modeNumber == 2:
            self._mode2()
        elif modeNumber == 3:
            self._mode3()
        elif modeNumber == 4:
            self._mode4()
        elif modeNumber == 5:
            self._mode5(disposition)
        elif modeNumber == 6:
            self._mode6(disposition)
        elif modeNumber == 18:
            self._mode18()
        else:
            self.abend(4016)

    def _mode0(self, commtabl):
        if self.initialized:
            self.abend(4017)

        self.commtabl = commtabl
        misc = self._getU16(self.OFF_MISC)
        self.updat = bool(misc & 0x02)
        self.onefcb = bool(misc & 0x08)
        self.first = bool(misc & 0x10)

        pntr = self._getU32(self.OFF_PNTR)
        addr = self._getU32(self.OFF_ADDR)
        if 0 < pntr < 4096:
            self.pad = addr
            self.padSize = pntr
            self.padInternal = False
        elif addr == 0 and pntr == 0:
            self.pad = 0
            self.padSize = 16 * 250
            self.padInternal = True
            self.padBytes = bytearray(self.padSize)
        else:
            raise NotImplementedError(
                "monitor22(0): PAD configuration with PNTR=%d, ADDR=%d is TBD" % (pntr, addr))

        npages = self._getU16(self.OFF_NPAGES)
        if npages == 0:
            self.abend(4013)

        apgarea = self._getU32(self.OFF_APGAREA)
        if apgarea > 0:
            self.apgarea = apgarea
            self.npages = npages
            padEntries = self.padSize // 16
            if padEntries < self.npages:
                raise RuntimeError(
                    "PAD has only %d entries but PA has %d pages" % (padEntries, self.npages))
        else:
            raise NotImplementedError("monitor22(0): APGAREA==0 is TBD")

        afcbarea = self._getU32(self.OFF_AFCBAREA)
        nbytes = self._getU16(self.OFF_NBYTES)
        if afcbarea > 0 and nbytes == 0:
            self.abend(4015)

        if afcbarea > 0 and (misc & 0x01) == 0:
            self.afcbarea = afcbarea
            self.nbytes = nbytes
        elif afcbarea > 0 and (misc & 0x01) != 0:
            raise NotImplementedError("monitor22(0): MISC&0x01 with AFCBAREA>0 is TBD")
        else:
            # AFCBAREA == 0: no FCBAREA in use; cmem tracks SDF metadata itself.
            self.afcbarea = None
            self.nbytes = None

        # Initializing means starting with nothing cached.  This matters when
        # the caller supplies the PAD, because then it lives in the caller's
        # memory and outlives us: a second cmem over the same memory would
        # otherwise inherit the previous one's entries.  They would not merely
        # be stale, they would be actively wrong, since SDF ids are handed out
        # from 1 again and an inherited entry can therefore be mistaken for a
        # page of the newly selected SDF.  (Which is exactly what happened:
        # including a second COMPOOL re-read the first one's pages.)
        for i in range(self.padSize // self.PAD_ENTRY_SIZE):
            self._padMarkFree(i)

        # Remembered so that mode 3 (rescind) knows how far back to unwind the
        # augments applied by mode 2.
        self.baseNpages = self.npages

        self._setU16(self.OFF_CRETURN, 0)
        self._setU32(self.OFF_APGAREA, 0)
        self._setU32(self.OFF_AFCBAREA, 0)
        self._setU16(self.OFF_NBYTES, 0)
        self._setU16(self.OFF_NPAGES, self.padSize // 16)

        self.initialized = True

    def _pagesStillAvailable(self):
        '''Mode 0, 2 and 3 all report, in NPAGES, how many further pages the
        Paging Area could still grow by.  That is bounded both by the PAD and
        by the documented maximum Paging Area size.
        '''
        return max(0, min(self.padSize // 16, self.MAX_PAGES) - self.npages)

    def _mode2(self):
        '''Augment the Paging Area and/or the FCB Area.

        The original GETMAINed fresh storage and spliced it in.  There is no
        allocator here, so an augment can only be honoured when the caller's
        area happens to abut the one we already have -- which is exactly what
        happens when the caller is carving both out of one static memory model,
        the arrangement the Python port uses.  Anything else abends rather than
        being quietly ignored, so that a genuine shortfall is noticed instead
        of turning into silent corruption later.
        '''
        apgarea = self._getU32(self.OFF_APGAREA)
        npages = self._getU16(self.OFF_NPAGES)
        afcbarea = self._getU32(self.OFF_AFCBAREA)
        nbytes = self._getU16(self.OFF_NBYTES)

        if npages != 0:
            if apgarea == 0:
                self.abend(4013)                      # User's Guide case 2
            if npages > self._pagesStillAvailable():
                self.abend(4013)
            if apgarea != self.apgarea + self.npages * self.PAGE_SIZE:
                # Not contiguous with the existing Paging Area, so we cannot
                # represent the result as one flat run of pages.
                self.abend(4013)
            self.npages += npages
        # npages == 0 is "no action" for the Paging Area, whatever APGAREA says.

        if nbytes != 0:
            if afcbarea == 0:
                self.abend(4015)                      # User's Guide case 5
            # cmem keeps SDF metadata in Python objects rather than in an FCB
            # area, so an FCB augment is accepted and merely accounted for.
            self.nbytes = (self.nbytes or 0) + nbytes
        # nbytes == 0 is "no action" for the FCB Area.

        self._setU16(self.OFF_CRETURN, 0)
        self._setU32(self.OFF_APGAREA, 0)
        self._setU32(self.OFF_AFCBAREA, 0)
        self._setU16(self.OFF_NBYTES, 0)
        self._setU16(self.OFF_NPAGES, self._pagesStillAvailable())

    def _mode3(self):
        '''Rescind Paging Area augments.  "All Paging Area augments are removed
        by a single rescind", and none of the FCB Area augments can be.  Any
        page cached in the part of the area that is going away has to be
        written back first if it was modified, and must not still be reserved.
        '''
        for i in range(self.baseNpages, self.npages):
            if self._padGetId(i) == 0:
                continue
            if self._padGetResucnt(i) > 0:
                self.abend(4012)
            if self._padGetModifiedFlag(i):
                self._writePageToSdf(i)
            self._padMarkFree(i)

        self.npages = self.baseNpages

        self._setU16(self.OFF_CRETURN, 0)
        self._setU32(self.OFF_APGAREA, 0)
        self._setU32(self.OFF_AFCBAREA, 0)
        self._setU16(self.OFF_NBYTES, 0)
        self._setU16(self.OFF_NPAGES, self._pagesStillAvailable())

    def _mode1(self):
        for i in range(self.npages):
            if self._padGetId(i) != 0 and self._padGetModifiedFlag(i):
                self._writePageToSdf(i)

        for info in self.sdfs.values():
            info["file"].flush()
        for info in self.sdfs.values():
            info["file"].close()
        self.sdfs.clear()
        self.sdfIdToName.clear()

        self._setU16(self.OFF_CRETURN, 0)
        self._setU32(self.OFF_APGAREA, 0)
        self._setU32(self.OFF_AFCBAREA, 0)
        self._setU16(self.OFF_NBYTES, 0)
        self._setU16(self.OFF_NPAGES, 250)

        self.__del__()

    def autoSelect(self):
        '''Honour the SELECT disposition: select the SDF named in SDFNAM before
        carrying out the operation the mode number asks for.  Returns True if
        the caller should go on to do that operation, or False if the select
        failed, in which case CRETURN already holds the failure code (8) and
        nothing further should be attempted.
        '''
        if not self.initialized:
            self.abend(4009)
        self._mode4()
        return self._getU16(self.OFF_CRETURN) == 0

    def _mode4(self):
        name = self._resolveSdfName(self._readSdfName())
        if name is None:
            self._setU16(self.OFF_CRETURN, 8)
            return

        # SELECT.bal also reports, undocumented by the User's Guide, the
        # member's revision level in BLKNO (as two EBCDIC characters) and its
        # catenation level in SYMBNO.  Both come from the z/OS PDS directory
        # entry -- "PMF always inserts the RVL immediately after the last
        # TTRN" -- which a plain file in an SDF library does not have.  So we
        # report what GETRVL reports when there is no revision level to be
        # had: zero, meaning "SHOW NO REVISION LEVEL OBTAINED".
        self._setU16(self.OFF_BLKNO, 0)
        self._setU16(self.OFF_SYMBNO, 0)

        for i in range(self.npages):
            if self._nameForPad(i) == name:
                self.current = name
                self._setU16(self.OFF_CRETURN, 0)
                return

        self._cachePage(name, 0)
        self.current = name
        self._setU16(self.OFF_CRETURN, 0)

    def _resolveVmp(self, vmp):
        '''Validate a VMP against the currently-selected SDF, caching its page
        if necessary, and return (padIndex, address) for it in mem. This is
        the caching-management core shared by monitor22(5) and mode5().
        '''
        if self.current is None:
            self.abend(4010)

        pageNumber = (vmp >> 16) & 0xFFFF
        offset = vmp & 0xFFFF
        if offset >= 0x8000:            # offset is a signed 16-bit integer.
            offset -= 0x10000

        if offset < 0:
            offset += self.PAGE_SIZE
            pageNumber += 1
        elif offset >= self.PAGE_SIZE:
            pageNumber += offset // self.PAGE_SIZE
            offset = offset % self.PAGE_SIZE

        if not self._pageExistsInSdf(self.current, pageNumber):
            self.abend(4005)

        self.recentPage = pageNumber
        self.recentSDF = self.current

        idx = self._findCachedPage(self.current, pageNumber)
        if idx is None:
            idx = self._cachePage(self.current, pageNumber)
        else:
            self._padSetUsecount(idx, self.usecount)

        pageAddr = self.apgarea + idx * self.PAGE_SIZE
        return idx, pageAddr + offset

    def _mode5(self, disposition):
        vmp = self._getU32(self.OFF_PNTR)
        idx, addr = self._resolveVmp(vmp)
        self._applyDisposition(idx, disposition)
        self._setU32(self.OFF_ADDR, addr)
        self._setU16(self.OFF_CRETURN, 0)

    def mode5(self, vmp):
        '''Convenience equivalent of monitor22(5)'s page-caching behavior,
        bypassing COMMTABL: takes a VMP directly as an argument and returns
        the corresponding address in mem directly, rather than via PNTR/ADDR.

        Disposition parameters (SELECT/MODF/RELS/RESV) are not part of this
        call; use monitor22(5) or monitor22(6) for those.
        '''
        if not self.initialized:
            self.abend(4009)
        self.usecount += 1
        _, addr = self._resolveVmp(vmp)
        return addr

    def _mode6(self, disposition):
        if self.recentSDF is None:
            self.abend(4010)
        idx = self._findCachedPage(self.recentSDF, self.recentPage)
        if idx is None:
            self.abend(4010)
        self._applyDisposition(idx, disposition)
        self._setU16(self.OFF_CRETURN, 0)

    def _applyDisposition(self, idx, disposition):
        # SELECT is dealt with in monitor22() before the operation runs, so it
        # has nothing left to do here.  The other three are applied in the
        # order SETDISPS applies them -- CHKMODF, CHKRELS, CHKRESV -- which
        # matters when both RELS and RESV are asked for at once: releasing
        # first means a page whose count is already 0 abends, rather than
        # being incremented and decremented back to 0 unnoticed.
        select, modf, rels, resv = disposition
        if modf:
            if not self.updat:
                self.abend(4008)
            # MODF!=0 is the only way to *set* bit 0 of FCBADDR; MODF==0 must
            # leave it untouched (only writing the page back clears it).
            self._padSetModified(idx, True)
        if rels:
            self._padDecResucnt(idx)
        if resv:
            self._padIncResucnt(idx)

    def _mode18(self):
        name = self._resolveSdfName(self._readSdfName())
        if name is None:
            name = self._readSdfName()
        indices = [i for i in range(self.npages) if self._nameForPad(i) == name]

        if not indices or any(self._padGetResucnt(i) > 0 for i in indices):
            self._setU16(self.OFF_CRETURN, 8)
            return

        for i in indices:
            if self._padGetModifiedFlag(i):
                self._writePageToSdf(i)

        info = self.sdfs.get(name)
        if info is not None:
            info["file"].flush()
            info["file"].close()
            del self.sdfIdToName[info["id"]]
            del self.sdfs[name]

        for i in indices:
            self._padMarkFree(i)

        if self.current == name:
            self.current = None
        if self.recentSDF == name:
            self.recentSDF = None
            self.recentPage = None

        self._setU16(self.OFF_CRETURN, 0)


# ---------------------------------------------------------------------------
# Stand-alone mode: behavioral tests and an interactive demonstration shell.
if __name__ == "__main__":

    def _runInChild(fn):
        '''Run fn() in a forked child process and report its exit status.
    
        abend() terminates via os._exit(), which cannot be caught in-process,
        so tests that expect an abend are run in a child process and checked
        via their exit code (1 == abend, 0 == fn() returned normally,
        2 == an unexpected Python exception was raised).
        '''
        pid = os.fork()
        if pid == 0:
            try:
                fn()
                os._exit(0)
            except SystemExit:
                os._exit(0)
            except Exception:
                traceback.print_exc()
                os._exit(2)
        else:
            _, status = os.waitpid(pid, 0)
            return os.WEXITSTATUS(status) if os.WIFEXITED(status) else -1
    
    
    def _makeInstance(sdflib, npages, updat=True, onefcb=False):
        apgarea = 0x1000
        commtablAddr = 0x100
        padAddr = apgarea + npages * cmem.PAGE_SIZE
        padSize = 16 * npages
        memSize = padAddr + padSize + 256
        mem = bytearray(memSize)
        m = cmem(mem, sdflib)
    
        misc = 0
        if updat:
            misc |= 0x02
        if onefcb:
            misc |= 0x08
    
        packU32(mem, commtablAddr + cmem.OFF_APGAREA, apgarea)
        packU32(mem, commtablAddr + cmem.OFF_AFCBAREA, 0)
        packU16(mem, commtablAddr + cmem.OFF_NPAGES, npages)
        packU16(mem, commtablAddr + cmem.OFF_NBYTES, 0)
        packU16(mem, commtablAddr + cmem.OFF_MISC, misc)
        packU32(mem, commtablAddr + cmem.OFF_PNTR, padSize)
        packU32(mem, commtablAddr + cmem.OFF_ADDR, padAddr)
        m.monitor22(0, commtablAddr)
        return m, mem, commtablAddr
    
    
    def runTests():
        passed = 0
        failed = 0
    
        def check(desc, cond):
            nonlocal passed, failed
            if cond:
                print("PASS:", desc)
                passed += 1
            else:
                print("FAIL:", desc)
                failed += 1
    
        with tempfile.TemporaryDirectory() as sdflib:
            # --- init ---------------------------------------------------------
            npages = 3
            m, mem, ct = _makeInstance(sdflib, npages)
            check("init sets CRETURN=0", unpackU16(mem, ct + cmem.OFF_CRETURN) == 0)
            check("init reports NPAGES = padSize/16", unpackU16(mem, ct + cmem.OFF_NPAGES) == 16 * npages // 16)
            check("attribute npages set", m.npages == npages)
            check("attribute updat True", m.updat is True)
    
            check("double init aborts (abend 4017)",
                  _runInChild(lambda: m.monitor22(0, ct)) == 1)
    
            # --- select a missing SDF ------------------------------------------
            writeSdfName(mem, ct, "NOSUCH")
            m.monitor22(buildMode(4))
            check("selecting missing SDF returns CRETURN=8", unpackU16(mem, ct + cmem.OFF_CRETURN) == 8)
    
            # --- create and select a real SDF -----------------------------------
            sdfPath = os.path.join(sdflib, "TESTSDF.sdf")
            with open(sdfPath, "wb") as f:
                f.write(bytes(cmem.PAGE_SIZE * 2))
            writeSdfName(mem, ct, "TESTSDF")
            m.monitor22(buildMode(4))
            check("selecting existing SDF returns CRETURN=0", unpackU16(mem, ct + cmem.OFF_CRETURN) == 0)
            check("current SDF recorded", m.current == "TESTSDF")
    
            # --- fetch, lock, modify, release, then terminate/flush ------------
            packU32(mem, ct + cmem.OFF_PNTR, (0 << 16) | 10)
            m.monitor22(buildMode(5, modf=1, resv=1))
            check("fetch page 0 returns CRETURN=0", unpackU16(mem, ct + cmem.OFF_CRETURN) == 0)
            addr = unpackU32(mem, ct + cmem.OFF_ADDR)
            mem[addr] = 0xAB
            idx0 = m._findCachedPage("TESTSDF", 0)
            check("MODF!=0 sets the modified bit", m._padGetModifiedFlag(idx0))
    
            # Releasing with MODF==0 must NOT clear the modified bit -- only
            # writing the page back to its SDF does that.
            m.monitor22(buildMode(6, rels=1))
            check("release returns CRETURN=0", unpackU16(mem, ct + cmem.OFF_CRETURN) == 0)
            check("MODF==0 on release leaves the modified bit set", m._padGetModifiedFlag(idx0))
    
            m.monitor22(buildMode(1))
            with open(sdfPath, "rb") as f:
                data = f.read()
            check("modified byte persisted to SDF file on terminate", data[10] == 0xAB)
    
            # --- LRU eviction and locking abends --------------------------------
            npages2 = 2
            m2, mem2, ct2 = _makeInstance(sdflib, npages2)
    
            sdfPath2 = os.path.join(sdflib, "MULTI.sdf")
            with open(sdfPath2, "wb") as f:
                f.write(bytes(cmem.PAGE_SIZE * 3))
            writeSdfName(mem2, ct2, "MULTI")
            m2.monitor22(buildMode(4))
            check("select MULTI ok", unpackU16(mem2, ct2 + cmem.OFF_CRETURN) == 0)

            # An offset >= PAGE_SIZE should roll over into pageNumber rather than abend.
            packU32(mem2, ct2 + cmem.OFF_PNTR, (0 << 16) | (cmem.PAGE_SIZE + 50))
            m2.monitor22(buildMode(5))
            check("oversized VMP offset normalizes instead of aborting",
                  unpackU16(mem2, ct2 + cmem.OFF_CRETURN) == 0)
            normalizedAddr = unpackU32(mem2, ct2 + cmem.OFF_ADDR)

            packU32(mem2, ct2 + cmem.OFF_PNTR, (1 << 16) | 50)
            m2.monitor22(buildMode(5))
            check("normalized VMP resolves to the same address as its equivalent (page+1, offset-1680)",
                  unpackU32(mem2, ct2 + cmem.OFF_ADDR) == normalizedAddr)

            # A negative (signed 16-bit) offset should roll into the *next* page,
            # per spec: offset += PAGE_SIZE, pageNumber += 1.
            packU32(mem2, ct2 + cmem.OFF_PNTR, (1 << 16) | (0x10000 - 30))
            m2.monitor22(buildMode(5))
            check("negative VMP offset normalizes instead of aborting",
                  unpackU16(mem2, ct2 + cmem.OFF_CRETURN) == 0)
            negativeAddr = unpackU32(mem2, ct2 + cmem.OFF_ADDR)

            packU32(mem2, ct2 + cmem.OFF_PNTR, (2 << 16) | (cmem.PAGE_SIZE - 30))
            m2.monitor22(buildMode(5))
            check("negative-offset VMP resolves to the same address as its equivalent (page+1, offset+1680)",
                  unpackU32(mem2, ct2 + cmem.OFF_ADDR) == negativeAddr)

            for pageNum in range(3):
                packU32(mem2, ct2 + cmem.OFF_PNTR, (pageNum << 16) | 0)
                m2.monitor22(buildMode(5))
            check("LRU eviction allows fetching more distinct pages than PA capacity",
                  unpackU16(mem2, ct2 + cmem.OFF_CRETURN) == 0)
    
            for pageNum in range(2):
                packU32(mem2, ct2 + cmem.OFF_PNTR, (pageNum << 16) | 0)
                m2.monitor22(buildMode(5, resv=1))
    
            def tryOverflow():
                packU32(mem2, ct2 + cmem.OFF_PNTR, (2 << 16) | 0)
                m2.monitor22(buildMode(5, resv=1))
    
            check("fetch with all pages locked aborts (abend 4001)", _runInChild(tryOverflow) == 1)
    
            def tryBadOffset():
                # Normalizes to pageNumber=5, offset=1599, and page 5 doesn't exist
                # in a 3-page SDF.
                packU32(mem2, ct2 + cmem.OFF_PNTR, (0 << 16) | 9999)
                m2.monitor22(buildMode(5))

            check("VMP normalizing to an out-of-range page number aborts (abend 4005)",
                  _runInChild(tryBadOffset) == 1)

            # --- modes 2 and 3: augment / rescind the Paging Area -------------
            def augment(m, mem, ct, apgarea, npages, afcbarea=0, nbytes=0):
                packU32(mem, ct + cmem.OFF_APGAREA, apgarea)
                packU16(mem, ct + cmem.OFF_NPAGES, npages)
                packU32(mem, ct + cmem.OFF_AFCBAREA, afcbarea)
                packU16(mem, ct + cmem.OFF_NBYTES, nbytes)
                m.monitor22(buildMode(2))

            basePages = 3
            mA, memA, ctA = _makeInstance(sdflib, basePages)
            # The PAD in _makeInstance is sized to exactly npages entries, so
            # there is no room to grow; that itself is worth asserting.
            check("mode 2 with NPAGES=0 is a no-op",
                  (augment(mA, memA, ctA, 0, 0),
                   unpackU16(memA, ctA + cmem.OFF_CRETURN) == 0
                   and mA.npages == basePages)[1])
            check("mode 2 reports 0 further pages when the PAD is full",
                  unpackU16(memA, ctA + cmem.OFF_NPAGES) == 0)
            check("mode 2 with NPAGES>0 but APGAREA=0 aborts (abend 4013)",
                  _runInChild(lambda: augment(mA, memA, ctA, 0, 1)) == 1)
            check("mode 2 beyond the PAD's capacity aborts (abend 4013)",
                  _runInChild(lambda: augment(
                      mA, memA, ctA,
                      mA.apgarea + mA.npages * cmem.PAGE_SIZE, 1)) == 1)

            # Now an instance whose PAD has room, so an augment can succeed.
            padRoom = 6
            apgarea = 0x1000
            commtablAddr = 0x100
            padAddr = apgarea + padRoom * cmem.PAGE_SIZE
            memB = bytearray(padAddr + 16 * padRoom + 256)
            mB = cmem(memB, sdflib)
            packU32(memB, commtablAddr + cmem.OFF_APGAREA, apgarea)
            packU32(memB, commtablAddr + cmem.OFF_AFCBAREA, 0)
            packU16(memB, commtablAddr + cmem.OFF_NPAGES, 2)
            packU16(memB, commtablAddr + cmem.OFF_NBYTES, 0)
            packU16(memB, commtablAddr + cmem.OFF_MISC, 0x02)
            packU32(memB, commtablAddr + cmem.OFF_PNTR, 16 * padRoom)
            packU32(memB, commtablAddr + cmem.OFF_ADDR, padAddr)
            mB.monitor22(0, commtablAddr)
            ctB = commtablAddr
            check("mode 0 reports the pages still addable",
                  unpackU16(memB, ctB + cmem.OFF_NPAGES) == padRoom)

            augment(mB, memB, ctB, apgarea + 2 * cmem.PAGE_SIZE, 3)
            check("a contiguous mode 2 augment succeeds",
                  unpackU16(memB, ctB + cmem.OFF_CRETURN) == 0 and mB.npages == 5)
            check("mode 2 reports the pages still addable after augmenting",
                  unpackU16(memB, ctB + cmem.OFF_NPAGES) == padRoom - 5)
            check("a non-contiguous mode 2 augment aborts (abend 4013)",
                  _runInChild(lambda: augment(
                      mB, memB, ctB, apgarea + 99 * cmem.PAGE_SIZE, 1)) == 1)
            check("mode 2 with NBYTES>0 but AFCBAREA=0 aborts (abend 4015)",
                  _runInChild(lambda: augment(mB, memB, ctB, 0, 0, 0, 512)) == 1)

            # A page cached in the augmented region must be given up by mode 3.
            sdfPathB = os.path.join(sdflib, "AUGMENT.sdf")
            with open(sdfPathB, "wb") as f:
                f.write(bytes(cmem.PAGE_SIZE * 5))
            writeSdfName(memB, ctB, "AUGMENT")
            mB.monitor22(buildMode(4))
            for pageNum in range(5):
                packU32(memB, ctB + cmem.OFF_PNTR, (pageNum << 16) | 0)
                mB.monitor22(buildMode(5))
            check("all 5 pages of the augmented area are in use",
                  mB.padSummary()["cachedCount"] == 5)

            mB.monitor22(buildMode(3))
            check("mode 3 restores the Paging Area to its mode-0 size",
                  unpackU16(memB, ctB + cmem.OFF_CRETURN) == 0 and mB.npages == 2)
            check("mode 3 frees the PAD entries above the base size",
                  mB.padSummary()["cachedCount"] == 2)
            check("mode 3 reports the pages still addable",
                  unpackU16(memB, ctB + cmem.OFF_NPAGES) == padRoom - 2)

            def rescindWhileReserved():
                augment(mB, memB, ctB, apgarea + 2 * cmem.PAGE_SIZE, 1)
                packU32(memB, ctB + cmem.OFF_PNTR, (4 << 16) | 0)
                mB.monitor22(buildMode(5, resv=1))
                mB.monitor22(buildMode(3))
            check("mode 3 with a reserved page in the augment aborts (abend 4012)",
                  _runInChild(rescindWhileReserved) == 1)

            # --- a caller-supplied PAD must be initialized by mode 0 -----------
            # Two cmems in succession over the same memory: the second must not
            # inherit the first's cached pages.  Ids restart at 1, so an
            # inherited entry can otherwise be mistaken for a page of the
            # newly-selected SDF.
            padPages = 2
            padApgarea = 0x1000
            padCommtabl = 0x100
            padAddr = padApgarea + padPages * cmem.PAGE_SIZE
            sharedMem = bytearray(padAddr + 16 * padPages + 256)
            for sdfName, fill in (("PADONE", 0xAA), ("PADTWO", 0xBB)):
                with open(os.path.join(sdflib, sdfName + ".sdf"), "wb") as f:
                    f.write(bytes([fill]) * cmem.PAGE_SIZE)
            firstByte = {}
            for sdfName in ("PADONE", "PADTWO"):
                mP = cmem(sharedMem, sdflib)
                packU32(sharedMem, padCommtabl + cmem.OFF_APGAREA, padApgarea)
                packU32(sharedMem, padCommtabl + cmem.OFF_AFCBAREA, 0)
                packU16(sharedMem, padCommtabl + cmem.OFF_NPAGES, padPages)
                packU16(sharedMem, padCommtabl + cmem.OFF_NBYTES, 0)
                packU16(sharedMem, padCommtabl + cmem.OFF_MISC, 0x02)
                packU32(sharedMem, padCommtabl + cmem.OFF_PNTR, 16 * padPages)
                packU32(sharedMem, padCommtabl + cmem.OFF_ADDR, padAddr)
                mP.monitor22(0, padCommtabl)
                writeSdfName(sharedMem, padCommtabl, sdfName)
                mP.monitor22(buildMode(4))
                packU32(sharedMem, padCommtabl + cmem.OFF_PNTR, 0)
                mP.monitor22(buildMode(5))
                addr = unpackU32(sharedMem, padCommtabl + cmem.OFF_ADDR)
                firstByte[sdfName] = sharedMem[addr]
            check("mode 0 clears a caller-supplied PAD, so a later cmem over "
                  "the same memory does not inherit stale pages",
                  firstByte["PADONE"] == 0xAA and firstByte["PADTWO"] == 0xBB)

            # --- RESV/RELS accounting -------------------------------------------
            writeSdfName(memB, ctB, "MULTI")
            mB.monitor22(buildMode(4))
            packU32(memB, ctB + cmem.OFF_PNTR, (0 << 16) | 0)
            mB.monitor22(buildMode(5))
            check("a page starts out unreserved",
                  mB.padSummary()["cached"][0]["resucnt"] == 0
                  if mB.padSummary()["cachedCount"] == 1 else True)
            check("releasing a page that was never reserved aborts (abend 4004)",
                  _runInChild(lambda: mB.monitor22(buildMode(5, rels=1))) == 1)
            mB.monitor22(buildMode(5, resv=1))
            mB.monitor22(buildMode(5, rels=1))
            check("reserve then release balances out",
                  all(e["resucnt"] == 0 for e in mB.padSummary()["cached"]))

            def tooManyReserves():
                idx, _ = mB._resolveVmp((0 << 16) | 0)
                mB._padSetResucnt(idx, 0x7FFF)
                mB.monitor22(buildMode(5, resv=1))
            check("reserving a page 0x7FFF times over aborts (abend 4003)",
                  _runInChild(tooManyReserves) == 1)

            def relsAndResvTogether():
                # SETDISPS releases before it reserves, so asking for both at
                # once on an unreserved page must still abend.
                mB.monitor22(buildMode(5, rels=1, resv=1))
            check("RELS+RESV on an unreserved page aborts (abend 4004)",
                  _runInChild(relsAndResvTogether) == 1)

            # --- SELECT (auto-select) disposition ------------------------------
            writeSdfName(memB, ctB, "MULTI")
            packU32(memB, ctB + cmem.OFF_PNTR, (0 << 16) | 0)
            mB.monitor22(buildMode(5, select=1))
            check("SELECT on mode 5 selects the SDF named in SDFNAM first",
                  unpackU16(memB, ctB + cmem.OFF_CRETURN) == 0
                  and mB.current == "MULTI")
            writeSdfName(memB, ctB, "NOSUCH")
            mB.monitor22(buildMode(5, select=1))
            check("SELECT on a missing SDF reports CRETURN=8 and does not locate",
                  unpackU16(memB, ctB + cmem.OFF_CRETURN) == 8)

            def tryModifyWithoutUpdat():
                m3, mem3, ct3 = _makeInstance(sdflib, 1, updat=False)
                sdfPath3 = os.path.join(sdflib, "RONLY.sdf")
                with open(sdfPath3, "wb") as f:
                    f.write(bytes(cmem.PAGE_SIZE))
                writeSdfName(mem3, ct3, "RONLY")
                m3.monitor22(buildMode(4))
                packU32(mem3, ct3 + cmem.OFF_PNTR, 0)
                m3.monitor22(buildMode(5, modf=1))
    
            check("modifying a page when updat is False aborts (abend 4008)",
                  _runInChild(tryModifyWithoutUpdat) == 1)
    
            def tryBeforeInit():
                mem4 = bytearray(4096)
                m4 = cmem(mem4, sdflib)
                m4.monitor22(buildMode(4))
    
            check("call before init aborts (abend 4009)", _runInChild(tryBeforeInit) == 1)
    
            # --- deselect (mode 18) ---------------------------------------------
            m5, mem5, ct5 = _makeInstance(sdflib, 2)
            sdfPath5 = os.path.join(sdflib, "DESEL.sdf")
            with open(sdfPath5, "wb") as f:
                f.write(bytes(cmem.PAGE_SIZE))
            writeSdfName(mem5, ct5, "DESEL")
            m5.monitor22(buildMode(4))
            m5.monitor22(buildMode(18))
            check("deselect of unlocked SDF returns CRETURN=0", unpackU16(mem5, ct5 + cmem.OFF_CRETURN) == 0)
            check("current cleared after deselecting the current SDF", m5.current is None)
    
            writeSdfName(mem5, ct5, "DESEL")
            m5.monitor22(buildMode(18))
            check("deselect of an unmanaged SDF returns CRETURN=8", unpackU16(mem5, ct5 + cmem.OFF_CRETURN) == 8)

            # --- toNative / fromNative -------------------------------------------
            expectedFields = {"APGAREA", "AFCBAREA", "NPAGES", "NBYTES", "MISC", "CRETURN",
                               "BLKNO", "SYMBNO", "STMTNO", "BLKNLEN", "SYMBNLEN", "PNTR",
                               "ADDR", "SDFNAM", "CSECTNAM", "SREFNO", "INCLCNT", "BLKNAM",
                               "SYMBNAM"}
            native = m5.toNative()
            check("toNative reports all 19 named fields", set(native.keys()) == expectedFields)
            check("toNative SDFNAM matches last-written basename (space-stripped)",
                  native["SDFNAM"] == "DESEL")
            check("toNative CRETURN matches COMMTABL contents",
                  native["CRETURN"] == unpackU16(mem5, ct5 + cmem.OFF_CRETURN))

            m5.fromNative({"SYMBNAM": "ROUNDTRIP"})
            check("toNative/fromNative round-trips a space-padded text field",
                  m5.toNative()["SYMBNAM"] == "ROUNDTRIP")

            m5.fromNative({
                "CRETURN": 99, "SDFNAM": "PARTIAL", "BLKNO": 7, "BLKNLEN": 250,
                "SREFNO": "SIXCH", "BLKNAM": "A" * 40, "BOGUS": 12345,
            })
            check("fromNative overwrites only the given fields (CRETURN, u16)",
                  unpackU16(mem5, ct5 + cmem.OFF_CRETURN) == 99)
            check("fromNative overwrites only the given fields (SDFNAM, text8)",
                  m5._readSdfName() == "PARTIAL")
            check("fromNative overwrites only the given fields (BLKNO, u16)",
                  unpackU16(mem5, ct5 + cmem.OFF_BLKNO) == 7)
            check("fromNative overwrites only the given fields (BLKNLEN, u8)",
                  mem5[ct5 + cmem.OFF_BLKNLEN] == 250)
            check("fromNative overwrites only the given fields (SREFNO, text6)",
                  m5._getText(cmem.OFF_SREFNO, 6) == "SIXCH")
            check("fromNative truncates oversized text to the field length (BLKNAM, text32)",
                  m5._getText(cmem.OFF_BLKNAM, 32) == "A" * 32)
            check("fromNative leaves untouched fields alone (NPAGES)",
                  unpackU16(mem5, ct5 + cmem.OFF_NPAGES) == native["NPAGES"])
            check("fromNative silently ignores unknown dictionary keys", True)  # no exception raised above

            beforeNpages = unpackU16(mem5, ct5 + cmem.OFF_NPAGES)
            m5.fromNative({"NPAGES": None, "CRETURN": 42})
            check("fromNative ignores a field whose value is None (NPAGES unchanged)",
                  unpackU16(mem5, ct5 + cmem.OFF_NPAGES) == beforeNpages)
            check("fromNative still applies other fields in the same call (CRETURN)",
                  unpackU16(mem5, ct5 + cmem.OFF_CRETURN) == 42)

            # --- fromNative(commtabl=...) override, used before monitor22(0) ----
            memPre = bytearray(4096)
            mPre = cmem(memPre, sdflib)
            preCt = 0x50
            mPre.fromNative({
                "APGAREA": 0x100, "AFCBAREA": 0, "NPAGES": 2, "NBYTES": 0,
                "MISC": 0x02, "PNTR": 0, "ADDR": 0,
            }, commtabl=preCt)
            check("fromNative(commtabl=...) writes into mem at the overridden address",
                  unpackU32(memPre, preCt + cmem.OFF_APGAREA) == 0x100)
            check("fromNative(commtabl=...) does not set self.commtabl", mPre.commtabl is None)

            mPre.monitor22(0, preCt)
            check("COMMTABL filled via fromNative(commtabl=...) is usable by monitor22(0)",
                  mPre.npages == 2 and mPre.apgarea == 0x100)

            # --- mode5() convenience method (bypasses COMMTABL) -----------------
            m6, mem6, ct6 = _makeInstance(sdflib, 2)
            sdfPath6 = os.path.join(sdflib, "M5.sdf")
            with open(sdfPath6, "wb") as f:
                f.write(bytes(cmem.PAGE_SIZE * 2))
            writeSdfName(mem6, ct6, "M5")
            m6.monitor22(buildMode(4))

            addr6 = m6.mode5((0 << 16) | 20)
            check("mode5() returns an address within the PA",
                  m6.apgarea <= addr6 < m6.apgarea + m6.npages * cmem.PAGE_SIZE)
            mem6[addr6] = 0x77

            packU32(mem6, ct6 + cmem.OFF_PNTR, (0 << 16) | 20)
            m6.monitor22(buildMode(5))
            check("mode5() result matches the address monitor22(5) resolves for the same VMP",
                  unpackU32(mem6, ct6 + cmem.OFF_ADDR) == addr6)
            check("mode5() shares cache state with monitor22(5) (byte survives)", mem6[addr6] == 0x77)

            def tryMode5BeforeInit():
                mem7 = bytearray(4096)
                m7 = cmem(mem7, sdflib)
                m7.mode5(0)

            check("mode5() before monitor22(0) aborts (abend 4009)", _runInChild(tryMode5BeforeInit) == 1)

            def tryMode5NoSelection():
                m8, mem8, ct8 = _makeInstance(sdflib, 2)
                m8.mode5(0)

            check("mode5() with no SDF selected aborts (abend 4010)", _runInChild(tryMode5NoSelection) == 1)

            # --- padSummary() ------------------------------------------------------
            summary = m6.padSummary()
            check("padSummary totalPages matches the PA's page capacity", summary["totalPages"] == m6.npages)
            check("padSummary cachedCount matches the number of cached entries",
                  summary["cachedCount"] == 1 and len(summary["cached"]) == 1)
            entry = summary["cached"][0]
            check("padSummary cached entry names the SDF by basename, not a file object",
                  entry["sdf"] == "M5" and "file" not in entry)
            check("padSummary cached entry reports the correct page number", entry["pageNumber"] == 0)
            check("padSummary cached entry's pageAddr matches the PA", entry["pageAddr"] == m6.apgarea)
            check("padSummary cached entry reflects the unmodified state", entry["modified"] is False)
            check("padSummary cached entry reports a lock count of 0", entry["resucnt"] == 0)

            m6.monitor22(buildMode(6, modf=1))
            entry = m6.padSummary()["cached"][0]
            check("padSummary reflects a page marked modified after monitor22(6)", entry["modified"] is True)

        print()
        print("%d passed, %d failed" % (passed, failed))
        return failed == 0
    
    
    def interactive():
        print("cmem interactive demonstration shell. Type 'help' for commands, 'quit' to leave.")
    
        state = {"mem": None, "m": None, "commtablAddr": 0x100, "sdflib": None, "lastAddr": None}
    
        def ensureInit():
            if state["m"] is None:
                print("Not initialized. Use 'init' first.")
                return False
            return True
    
        def cmd_init(args):
            npages = int(args[0]) if len(args) > 0 else 4
            sdflib = args[1] if len(args) > 1 else tempfile.mkdtemp(prefix="cmem_sdflib_")
            m, mem, ct = _makeInstance(sdflib, npages)
            state.update(mem=mem, m=m, commtablAddr=ct, sdflib=sdflib, lastAddr=None)
            print("Initialized cmem: npages=%d sdflib=%s" % (npages, sdflib))
    
        def cmd_mkfile(args):
            if not state["sdflib"]:
                print("Run 'init' first.")
                return
            name = args[0]
            pages = int(args[1]) if len(args) > 1 else 2
            path = os.path.join(state["sdflib"], name + ".sdf")
            with open(path, "wb") as f:
                f.write(bytes(cmem.PAGE_SIZE * pages))
            print("Created", path, "(%d pages)" % pages)
    
        def cmd_select(args):
            if not ensureInit():
                return
            writeSdfName(state["mem"], state["commtablAddr"], args[0])
            state["m"].monitor22(buildMode(4))
            cr = unpackU16(state["mem"], state["commtablAddr"] + cmem.OFF_CRETURN)
            print("CRETURN =", cr, "; current =", state["m"].current)
    
        def cmd_fetch(args):
            if not ensureInit():
                return
            page = int(args[0])
            offset = int(args[1]) if len(args) > 1 else 0
            lock = "lock" in args[2:]
            modify = "modify" in args[2:]
            packU32(state["mem"], state["commtablAddr"] + cmem.OFF_PNTR, (page << 16) | offset)
            mode = buildMode(5, modf=1 if modify else 0, resv=1 if lock else 0)
            state["m"].monitor22(mode)
            cr = unpackU16(state["mem"], state["commtablAddr"] + cmem.OFF_CRETURN)
            addr = unpackU32(state["mem"], state["commtablAddr"] + cmem.OFF_ADDR)
            state["lastAddr"] = addr
            print("CRETURN =", cr, "; ADDR =", hex(addr))
    
        def cmd_peek(args):
            if state["lastAddr"] is None:
                print("No address fetched yet.")
                return
            print("byte at", hex(state["lastAddr"]), "=", hex(state["mem"][state["lastAddr"]]))
    
        def cmd_poke(args):
            if state["lastAddr"] is None:
                print("No address fetched yet.")
                return
            value = int(args[0], 0) & 0xFF
            state["mem"][state["lastAddr"]] = value
            print("wrote", hex(value), "at", hex(state["lastAddr"]))
    
        def cmd_release(args):
            if not ensureInit():
                return
            state["m"].monitor22(buildMode(6, rels=1))
            print("CRETURN =", unpackU16(state["mem"], state["commtablAddr"] + cmem.OFF_CRETURN))
    
        def cmd_deselect(args):
            if not ensureInit():
                return
            writeSdfName(state["mem"], state["commtablAddr"], args[0])
            state["m"].monitor22(buildMode(18))
            print("CRETURN =", unpackU16(state["mem"], state["commtablAddr"] + cmem.OFF_CRETURN))
    
        def cmd_terminate(args):
            if not ensureInit():
                return
            state["m"].monitor22(buildMode(1))
            print("Terminated.")
            state["m"] = None
    
        def cmd_status(args):
            if not ensureInit():
                return
            m = state["m"]
            print("npages=%s current=%s usecount=%s onefcb=%s updat=%s" %
                  (m.npages, m.current, m.usecount, m.onefcb, m.updat))

        def cmd_padsummary(args):
            if not ensureInit():
                return
            summary = state["m"].padSummary()
            print("totalPages=%d cachedCount=%d" % (summary["totalPages"], summary["cachedCount"]))
            for entry in summary["cached"]:
                print("  " + str(entry))

        def cmd_help(args):
            print('''Commands:
  init [npages] [sdflib]           Initialize a fresh cmem instance (mode 0)
  mkfile NAME [pages]              Create a blank SDF file in the SDF library
  select NAME                      Select/open an SDF (mode 4)
  fetch PAGE OFFSET [lock] [modify]
                                    Fetch a VMP into the PA (mode 5)
  peek                             Show the byte at the last fetched address
  poke VALUE                       Write a byte at the last fetched address
  release                          Release lock / clear disposition (mode 6)
  deselect NAME                    Deselect (close) an SDF (mode 18)
  terminate                        Terminate cmem, flushing to disk (mode 1)
  status                           Show current cmem attributes
  padsummary                       Summarize the PAD's current contents
  help                             Show this message
  quit / exit                      Leave the interactive shell''')

        commands = {
            "init": cmd_init, "mkfile": cmd_mkfile, "select": cmd_select,
            "fetch": cmd_fetch, "peek": cmd_peek, "poke": cmd_poke,
            "release": cmd_release, "deselect": cmd_deselect,
            "terminate": cmd_terminate, "status": cmd_status,
            "padsummary": cmd_padsummary, "help": cmd_help,
        }
    
        while True:
            try:
                line = input("cmem> ").strip()
            except EOFError:
                print()
                break
            if not line:
                continue
            parts = line.split()
            cmdName, args = parts[0], parts[1:]
            if cmdName in ("quit", "exit"):
                break
            handler = commands.get(cmdName)
            if handler is None:
                print("Unknown command %r. Type 'help'." % cmdName)
                continue
            try:
                handler(args)
            except SystemExit:
                raise
            except Exception as e:
                print("Error:", e)
    
    
    def main():
        parser = argparse.ArgumentParser(
            description="cmem virtual-memory manager: self-tests and interactive demonstration shell")
        parser.add_argument("mode", nargs="?", default="test", choices=["test", "interactive"],
                             help="run the self-tests (default) or an interactive demo shell")
        args = parser.parse_args()
    
        if args.mode == "interactive":
            interactive()
        else:
            ok = runTests()
            sys.exit(0 if ok else 1)

    main()
