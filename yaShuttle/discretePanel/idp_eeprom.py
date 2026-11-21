#!/usr/bin/env python3
"""The critical formats a display unit keeps in EEPROM, and where they come from.

A real MEDS IDP keeps its critical formats -- the sixteen display backgrounds that live permanently in the unit,
with the index table that finds them -- in EEPROM, and needs an IDP LOAD only after a software change or a checksum
failure (DPS Workbook, USA005350 2.5.9 and 3.7.1).  The PASS User's Guide's default IPL does not load the DEUs at all
(steps 6, 7, 9 and 12 are omitted, and a display that does not appear is the FAILURE case, 2.3.1.2).  So a unit powers
on initialized, and answers the computer's first poll as a unit that needs nothing.

WHERE THE IMAGE COMES FROM, AND WHY NOTHING IS SHIPPED.  The image is the DEU critical-format load module, 3657
halfwords laid out from DEU address 0x0100 (CON80/CFSYSIN: ORIGIN=0100, CFITSIZE=20, CFBSIZE=0E48): a table of
sixteen branch FCWs, the format bodies, padding, and a last halfword that is the 16-bit sum of every halfword before
it.  The mass-memory volume carries it as `DMACDFT1/2/3`, three copies in eight contiguous blocks each, which is what
GPCIPL and PASS's DEU loader read.  Rather than ship those bytes, the unit's image is EXTRACTED FROM THE USER'S OWN
VOLUME the first time it is needed (`provision`): the module is found by its checksum, so no block address is
assumed, and a volume that does not carry one simply leaves the unit cold, as before.

THE FILE.  local/idp-eeprom.mem.bin (ignored by git): 8192 big-endian halfwords, the image at 0x0100-0x0f48 and zeros
elsewhere.  NSTS_IDP_EEPROM names another file; NSTS_IDP_COLD_POWERON=1 says a unit powers on needing a load.

    idp_eeprom.py VOLUME.mmv [-o FILE]       extract the image from a plain or 7z-archived volume
"""
import os
import struct
import subprocess
import sys

try:
    import numpy as np
except ImportError:                                # the module must import where numpy is absent; callers then skip
    np = None

HERE = os.path.dirname(os.path.abspath(__file__))
MEMORY_WORDS = 8192
ORIGIN = 0x0100
CF_CHECKSUM = 0x0f48
IMAGE_WORDS = CF_CHECKSUM - ORIGIN + 1             # 3657
BLOCKS_PER_COPY = 8


def path():
    """Where the image lives, or None when a cold power-on is asked for."""
    if os.environ.get("NSTS_IDP_COLD_POWERON"):
        return None
    return os.environ.get("NSTS_IDP_EEPROM") or os.path.join(HERE, "local", "idp-eeprom.mem.bin")


def read():
    """The stored 8192-halfword image, or None."""
    p = path()
    if not p or np is None:
        return None
    try:
        raw = open(p, "rb").read()
    except OSError:
        return None
    if len(raw) != 2 * MEMORY_WORDS:
        return None
    return np.frombuffer(raw, dtype=">u2").astype(np.uint16)


def write(mem):
    """Store `mem` (the formats region is all that is kept).  Returns whether it was written."""
    p = path()
    if not p or np is None:
        return False
    img = np.zeros(MEMORY_WORDS, dtype=np.uint16)
    img[ORIGIN:CF_CHECKSUM + 1] = np.asarray(mem, dtype=np.uint16)[ORIGIN:CF_CHECKSUM + 1]
    try:
        os.makedirs(os.path.dirname(p), exist_ok=True)
        tmp = "%s.%d.tmp" % (p, os.getpid())
        with open(tmp, "wb") as fh:
            fh.write(img.astype(">u2").tobytes())
        os.replace(tmp, p)
        return True
    except OSError:
        return False


def find_module(volume):
    """The critical-format module in `volume` (the bytes of an MMUVOL01 volume), as 3657 halfwords, or None.

    Volume format (yaGPC2 src/mmumodel.c): "MMUVOL01", halfwords per block u32, directory entries u32, flags u32,
    12 reserved bytes, then the directory of block numbers (u32, ascending) and one block of data per entry, in the
    same order.  A candidate is a run of eight consecutive directory entries; it is the module when its last image
    halfword equals the 16-bit sum of the 3656 before it, and the sum is not zero (a block of zeros sums to zero)."""
    if np is None or len(volume) < 32 or volume[:8] != b"MMUVOL01":
        return None
    per_block, n = struct.unpack(">II", volume[8:16])
    if per_block <= 0 or n < BLOCKS_PER_COPY:
        return None
    base = 32 + 4 * n
    if len(volume) < base + 2 * per_block * n:
        return None
    directory = np.frombuffer(volume, dtype=">u4", count=n, offset=32)
    data = np.frombuffer(volume, dtype=">u2", count=per_block * n, offset=base)
    for i in range(n - BLOCKS_PER_COPY + 1):
        if int(directory[i + BLOCKS_PER_COPY - 1]) - int(directory[i]) != BLOCKS_PER_COPY - 1:
            continue                               # not consecutive blocks on the volume
        words = data[i * per_block:i * per_block + IMAGE_WORDS]
        if len(words) < IMAGE_WORDS:
            break
        total = int(words[:-1].astype(np.uint32).sum()) & 0xffff
        if total != 0 and total == int(words[-1]) and np.count_nonzero(words) > IMAGE_WORDS // 2:
            return words.astype(np.uint16)
    return None


def find_7z():
    """The 7z executable: on the PATH, else where 7-Zip installs itself on Windows (the same search simulatePASS's
    sevenzip() makes), else the bare name so the failure says what was missing."""
    import shutil
    found = shutil.which("7z") or shutil.which("7z.exe")
    if found:
        return found
    for var in ("ProgramFiles", "ProgramW6432", "ProgramFiles(x86)"):
        exe = os.path.join(os.environ.get(var, ""), "7-Zip", "7z.exe")
        if os.path.isfile(exe):
            return exe
    return "7z"


def read_volume(tape, password=None, sevenzip=None):
    """The bytes of a plain volume, or of a 7z archive's plaintext through `7z x -so` (the password goes in on
    standard input, as yaGPC2's own reader does)."""
    if tape.lower().endswith(".7z"):
        proc = subprocess.Popen([sevenzip or find_7z(), "x", "-so", "--", tape], stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        proc.stdin.write(((password or "") + "\n").encode())
        proc.stdin.close()
        out = proc.stdout.read()
        proc.stdout.close()
        if proc.wait() != 0:
            return None
        return out
    with open(tape, "rb") as fh:
        return fh.read()


def provision(tape, password=None, sevenzip=None, log=lambda s: None):
    """Make sure the EEPROM image exists, extracting it from `tape` if it does not.  Returns True when an image is
    there afterwards.  Never raises: a volume that cannot be read, or carries no module, leaves units cold."""
    p = path()
    if not p or np is None:
        return False
    if os.path.isfile(p):
        return True
    try:
        volume = read_volume(tape, password, sevenzip)
        words = find_module(volume) if volume else None
    except (OSError, ValueError, subprocess.SubprocessError) as e:
        log("IDP EEPROM: cannot read %s (%s); display units will power on needing a load" % (tape, e))
        return False
    if words is None:
        log("IDP EEPROM: no critical-format module on %s; display units will power on needing a load" % tape)
        return False
    mem = np.zeros(MEMORY_WORDS, dtype=np.uint16)
    mem[ORIGIN:ORIGIN + IMAGE_WORDS] = words
    ok = write(mem)
    log("IDP EEPROM: critical formats taken from %s -> %s" % (os.path.basename(tape), p) if ok
        else "IDP EEPROM: could not write %s" % p)
    return ok


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description="extract the display units' critical formats from a volume")
    ap.add_argument("volume")
    ap.add_argument("-o", "--output", help="write here instead of the default location")
    a = ap.parse_args()
    if a.output:
        os.environ["NSTS_IDP_EEPROM"] = a.output
    pw = os.environ.get("YAGPC_TAPE_PASSWORD")
    if a.volume.lower().endswith(".7z") and pw is None:
        import getpass
        pw = getpass.getpass("password for %s: " % os.path.basename(a.volume))
    if os.path.isfile(path() or ""):
        os.remove(path())
    sys.exit(0 if provision(a.volume, pw, log=print) else 1)
