#!/usr/bin/env python3
'''
This script is the opposite of dddScrape.py.  It can be used to read the files
ddd-*-LM.tsv and ddd-*.CM.tsv (or some other AGC software versions) and 
create a file DecodeDigitalDownlinkHardcodes.c from them, which in turn defines
the hard-coded downlist specs in programs such as yaTelemetry.
'''

import sys

header = '''/*
  Declared to be in the Public Domain by its original author, Ron Burkey.

  Filename:     DecodeDownlinkListHardcodes.c
  Purpose:      This file is used only by DecodeDigitalDownlink.c.  It provides
                hard-code downlist specifications for yaTelemetry.  The original
                version of this file was manually coded, but future versions
                may be generated via scripts such as dddUnscrape.py from
                files ddd-*-*.tsv.  Therefore, no modification history is
                maintained internally to this file.
  Contact:      Ron Burkey <info@sandroid.org>
  Ref:          http://www.ibiblio.org/apollo/index.html
*/
'''

cm = "CM"
lm = "LM"
for parm in sys.argv[1:]:
    if parm.startswith("--cm="):
        cm = parm[5:]
    elif parm.startswith("--lm="):
        lm = parm[5:]
    elif parm == "--help":
        print("Usage:", file=sys.stderr)
        print("\tdddUnscrape.py [OPTIONS] >OUTPUT.c", file=sys.stderr)
        print("The available OPTIONS are:", file=sys.stderr)
        print("--help    Print this menu.", file=sys.stderr)
        print("--cm=SOFT Set name of CM software, such as Comanche055. Default is CM.", file=sys.stderr)
        print("--lm=SOFT Set name of CM software, such as Luminary099. Default is LM.", file=sys.stderr)
        sys.exit(0)
    else:
        print("Unrecognized parameter %s" % parm, file=sys.stderr)
        sys.exit(1)

downlists = {
    "CmPoweredListSpec": (0o77774, "Powered List"),
    "LmOrbitalManeuversSpec": (0o77774, "Orbital Maneuvers List"),
    "CmCoastAlignSpec": (0o77777, "Coast and Align List"),
    "LmCoastAlignSpec": (0o77777, "Coast and Align List"),
    "CmRendezvousPrethrustSpec": (0o77775, "Rendezvous and Prethrust List"),
    "LmRendezvousPrethrustSpec": (0o77775, "Rendezvous and Prethrust List"),
    "CmProgram22Spec": (0o77773, "Program 22 List"),
    "LmDescentAscentSpec": (0o77773, "Descent and Ascent List"),
    "LmLunarSurfaceAlignSpec": (0o77772, "Lunar Surface Align List"),
    "CmEntryUpdateSpec": (0o77776, "Entry and Update List"),
    "LmAgsInitializationUpdateSpec": (0o77776, "LM AGS Initialization and Update List")
    }

print(header)
for structureName in downlists:
    downlist = downlists[structureName]
    id = downlist[0]
    title = downlist[1]
    url = "DEFAULT_URL"
    filename = "ddd-%05o-%s.tsv" % (id, structureName[:2].upper())
    #print("Processing %s ..." % filename, file=sys.stderr)
    f = open(filename, "r")
    fieldStrings = []
    for line in f:
        line = line.rstrip("\n\r")
        if len(line) == 0:
            continue
        if line[0] == "#":
            fieldStrings.append("    //" + line[1:])
            continue
        fields = line.split('\t')
        if len(fields) == 1:
            if fields[0].startswith("http"):
                if fields[0] == 'https://www.ibiblio.org/apollo/yaTelemetry.html#yaTelemetry':
                    url = "DEFAULT_URL"
                else:
                    url = '"' + fields[0] + '"'
            else:
                title = fields[0]
            continue
        if len(fields) != 6:
            print('Corrupted line "%s" in %s' % (line, filename), file=sys.stderr)
            #print(fields, file=sys.stderr)
            sys.exit(1)
        if fields[0] == "-1":
            fieldStrings.append('    { -1 },')
            continue
        fieldString = '    { %s, "%s=", %s, %s' % (fields[0], fields[1], fields[2], fields[3])
        if len(fields[4]) == 0:
            fieldString += ' },'
        else:
            fieldString += ', &%s },' % fields[4]
        fieldStrings.append(fieldString)
    print('static DownlinkListSpec_t %s = {' % structureName)
    print('  "%s",' % title)
    print('  %s,' % url)
    print('  {')
    for fieldString in fieldStrings:
        print(fieldString)
    print('  }')
    print('};')
    print('')
    f.close()

