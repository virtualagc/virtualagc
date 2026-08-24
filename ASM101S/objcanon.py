#!/usr/bin/env python3
'''
The author (Ron Burkey) declares that this file is in the public domain in the
U.S., and may freely be used, modified, or distributed for any purpose whatever.

Decode an IBM AP-101S object module into a canonical, order-independent form,
so that two of them can be compared for MEANING rather than for bytes.

    objcanon.py FILE.obj

Why this is needed:  ASM101S.py holds a module's ENTRY and EXTRN symbols in
Python SETs, and set iteration order is randomised per process.  The ESD ids
that order assigns are therefore arbitrary, and two runs of the same assembly
over the same source emit different bytes -- on the OI340600 corpus, between
174 and 181 of 271 object files differed from run to run, purely on that
account.  An id is meaningless across runs; a NAME is not.

So every record that refers to an ESD id is re-expressed by the name that id
denotes, and the result is sorted.  Object modules that mean the same thing
then compare equal, and ones that do not, do not.  Used this way:

    diff <(objcanon.py a.obj) <(objcanon.py b.obj)

References:
    https://en.wikipedia.org/wiki/OS/360_Object_File_Format
    https://publibz.boulder.ibm.com/epubs/pdf/iea2b270.pdf#page=209
(The latter is IBM document "MVS Program Management: Advanced Facilities",
Appendix A.)
'''

import sys
import os

# asciiToEbcdic.py sits beside this file.  Running the script puts that
# directory on sys.path automatically; the insert covers the case of being
# imported from elsewhere, and replaces a hardcoded path into one user's home.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from asciiToEbcdic import ebcdicToAscii   # noqa: E402


def ebcdic(b):
    return "".join(ebcdicToAscii[x] for x in b).rstrip()


def be(b):
    return int.from_bytes(b, "big")


def canon(path):
    data = open(path, "rb").read()
    esd = {}          # id -> (name, type)
    sd = []           # canonical SD/LD/ER descriptions
    txt = []
    rld = []
    for i in range(0, len(data), 80):
        card = data[i:i + 80]
        typ = ebcdic(card[1:4])
        body = card[4:72]
        if typ == "ESD":
            count = be(body[6:8]) // 16
            first = be(body[10:12])
            for j in range(count):
                o = 12 + j * 16
                name = ebcdic(body[o:o + 8])
                tc = body[o + 8]
                addr = be(body[o + 9:o + 12])
                esd[first + j] = (name, tc)
                if tc == 0x00:
                    sd.append(("SD", name, addr, be(body[o + 13:o + 16])))
                elif tc == 0x01:
                    sd.append(("LD", name, addr, be(body[o + 14:o + 16])))
                else:
                    sd.append(("ER", name))
        elif typ == "TXT":
            addr = be(body[1:4])
            n = be(body[6:8])
            esdId = be(body[10:12])
            txt.append((esdId, addr, body[12:12 + n].hex()))
        elif typ == "RLD":
            n = be(body[6:8]) // 8
            for j in range(n):
                o = 12 + j * 8
                rld.append((be(body[o:o + 2]), be(body[o + 2:o + 4]),
                            body[o + 4], be(body[o + 5:o + 8])))
        elif typ == "END":
            # A BARE `END' NAMES NO ENTRY POINT, and the fields are then EBCDIC
            # blanks rather than zeros -- 0x404040 and 0x4040.  Rendering those
            # as integers produced `END addr=4210752 sect=?16448\', which reads
            # as a wild address pointing at a nonexistent ESD id.  Harmless when
            # comparing two runs of one assembler, since both sides say it; a
            # false positive the moment this is used to compare two DIFFERENT
            # assemblers, where it was the only difference some modules had.
            addr, esdId = be(body[1:4]), be(body[10:12])
            if addr == 0x404040 and esdId == 0x4040:
                sd.append(("END", None, None))
            else:
                sd.append(("END", addr, esdId))

    # Re-express everything that names an ESD id by the NAME it refers to, and
    # sort, so that only the content is compared.
    def named(i):
        return esd.get(i, ("?%d" % i, -1))[0]

    out = []
    for e in sorted(sd, key=repr):
        if e[0] == "END":
            if e[1] is None:
                out.append("END (no entry point)")
            else:
                out.append("END addr=%d sect=%s" % (e[1], named(e[2])))
        elif e[0] == "LD":
            out.append("LD %s addr=%d in=%s" % (e[1], e[2], named(e[3])))
        elif e[0] == "SD":
            out.append("SD %s addr=%d len=%d" % (e[1], e[2], e[3]))
        else:
            out.append("ER %s" % e[1])
    for esdId, addr, hexdata in sorted(txt, key=repr):
        out.append("TXT %s @%d %s" % (named(esdId), addr, hexdata))
    for rel, pos, flags, addr in sorted(rld, key=repr):
        out.append("RLD rel=%s pos=%s flags=%02X addr=%d"
                   % (named(rel), named(pos), flags, addr))
    return "\n".join(sorted(out))


if __name__ == "__main__":
    print(canon(sys.argv[1]))
