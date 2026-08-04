#!/usr/bin/env python3
'''
License:     The author, Ron Burkey, declares this program to be in the Public
             Domain, and it may be freely modified or redistributed for any
             purpose whatever.
Filename:    SDFLIST.py
Purpose:     Runs SDFLIST -- which is to say HALSFC-PASS4 -- over Simulation
             Data Files, without the caller having to know how PASS4 expects
             to be told which files to read.
Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
History:     2026-08-04 ACC  Written.

Usage:

    SDFLIST.py [OPTIONS] ["NAME" ...]

with the SDF library in the current directory, which is where a *.results
folder leaves it.  Names may also arrive on stdin, one per line.  With --all,
every SDF in the library is listed and no names are needed.

Quote the names.  An SDF name begins with "##", and an unquoted "#" starts a
comment to the shell, so the name would never reach this program at all.

    SDFLIST.py "##HELLO"                    one SDF, default TABLST report
    SDFLIST.py --brief "##HELLO" "##FOO"    two SDFs, the summary only
    SDFLIST.py --all --tabdmp               every SDF, the full dump
    SDFLIST.py --all >everything.rpt

The reason this program exists is `--all`.  PASS4 reads the names for it from
an OS/360 PDS directory block on device 3 (SDFPROCE.xpl:127-144), which is a
halfword byte-count followed by entries of an 8-byte EBCDIC name, a 3-byte TTR
and a flags byte whose low five bits give a count of user halfwords -- so an
entry occupies 12 + 2*(flags & 0x1F) bytes -- and a name of eight 0xFF bytes
ends the scan.  Nothing in a modern working directory is that, so it has to be
synthesised, and expecting anyone to synthesise it by hand to read a report is
not reasonable.  It is built here instead, from the library's own contents.
'''

import os
import subprocess
import sys
import tempfile

PROGRAM = "HALSFC-PASS4"


def usage(msg=None):
    if msg:
        print("SDFLIST.py: " + msg, file=sys.stderr)
    print(__doc__.split("Usage:")[1].split("The reason")[0].rstrip(),
          file=sys.stderr)
    sys.exit(1 if msg else 0)


library = "SDFLIB"
report = None
names = []
passthrough = []
listAll = False

for arg in sys.argv[1:]:
    if arg in ("--help", "-h", "--usage"):
        usage()
    elif arg == "--all":
        listAll = True
    elif arg in ("--brief", "--tablst", "--tabdmp"):
        report = arg[2:].upper()
    elif arg.startswith("--sdfi="):
        library = arg[7:]
    elif arg.startswith("-"):
        passthrough.append(arg)
    else:
        names.append(arg)

if not os.path.isdir(library):
    usage("no SDF library '%s' here.  Run this where the library is, or say "
          "--sdfi=DIR." % library)

# Names not given on the command line come from stdin, as they would to PASS4
# itself.  Nothing on either means there is nothing to do -- unless --all.
if not names and not listAll and not sys.stdin.isatty():
    names = [line.strip() for line in sys.stdin if line.strip()]
if not names and not listAll:
    usage("no SDF names given.  Name them, pipe them in, or use --all.")

# PASS4's own default: with neither TABLST nor TABDMP it turns TABLST on.
parms = [report] if report else ["TABLST"]
if listAll:
    parms.insert(0, "ALL")

command = [PROGRAM, "--sdfi=" + library, "--parm=" + ",".join(parms)]
command += passthrough

directory = None
try:
    if listAll:
        members = sorted(n[:-4] for n in os.listdir(library)
                         if n.endswith(".sdf"))
        if not members:
            usage("the SDF library '%s' is empty." % library)
        block = b""
        for member in members:
            # 8-byte EBCDIC name, 3-byte TTR, flags byte: no user halfwords,
            # so each entry is the minimum twelve bytes.  PASS4 uses only the
            # name and the flags byte's count.
            block += ("%-8s" % member[:8]).encode("cp037") + b"\0\0\0" + b"\0"
        block += b"\xFF" * 8            # The end-of-directory name.
        record = (2 + len(block)).to_bytes(2, "big") + block
        handle, directory = tempfile.mkstemp(prefix="sdflist-", suffix=".dir")
        os.write(handle, record)
        os.close(handle)
        # ",E" matters: the block is binary, and without it the runtime reads
        # the record as ASCII text and every name arrives blank.
        command.append("--ddi=3,%s,E" % directory)
        result = subprocess.run(command)
    else:
        result = subprocess.run(command,
                                input="\n".join(names) + "\n",
                                text=True)
finally:
    if directory is not None:
        try:
            os.remove(directory)
        except OSError:
            pass

sys.exit(result.returncode)
