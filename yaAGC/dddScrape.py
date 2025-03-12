#!/usr/bin/env python3
'''
This is a script that can be run using DecodeDigitalDownlinkHardcodes.c as input
to produce the files ddd-*-LM.tsv, ddd-*-CM.tsv, and ddd-format-lookup.tsv.
'''

import sys

ids = {
    "CmPoweredListSpec": 0o77774,
    "LmOrbitalManeuversSpec": 0o77774,
    "CmCoastAlignSpec": 0o77777,
    "LmCoastAlignSpec": 0o77777,
    "CmRendezvousPrethrustSpec": 0o77775,
    "LmRendezvousPrethrustSpec": 0o77775,
    "CmProgram22Spec": 0o77773,
    "LmDescentAscentSpec": 0o77773,
    "LmLunarSurfaceAlignSpec": 0o77772,
    "CmEntryUpdateSpec": 0o77776,
    "LmAgsInitializationUpdateSpec": 0o77776
    }

def outtaHere(message, j):
    print(message, file=sys.stderr)
    f.close();
    sys.exit(1);

unique = {}
downlist = None
id = None
for line in sys.stdin:
    line = line.lstrip()
    if downlist != None and line.startswith("//"):
        print("#" + line[2:].rstrip(), file=f)
        continue
    line = line.rstrip()
    while "  " in line:
        line = line.replace("  ", " ")
    if downlist == None:
        if line.startswith("static DownlinkListSpec_t"):
            fields = line.split()
            downlist = fields[2]
            id = ids[downlist]
            filename = "ddd-%05o-%s.tsv" % (id, downlist[:2].upper())
            f = open(filename, "w")
        continue
    if line.startswith("DEFAULT_URL"):
        print('https://www.ibiblio.org/apollo/yaTelemetry.html#yaTelemetry', file=f)
        continue
    if line.startswith('"'):
        print(line.rstrip(",").strip('"'), file=f)
        continue
    if line == "}":
        f.close();
        downlist = None
        id = None
    if line.startswith("{") and line != "{":
        line = line[1:].lstrip()
        fields = line.split(",")
        offset = fields[0].strip()
        if offset == "-1 }":
            print("-1\t\t\t\t\t", file=f)
            continue
        n = 1 # Index in the `fields` list
        variable = fields[n].strip()
        n += 1
        while not variable.endswith('"'):
            variable += "," + fields[n].rstrip()
            n += 1
        variable = variable[1:-2]
        scale = fields[n].strip()
        n += 1
        format = fields[n].strip()
        n += 1
        formatter = ""
        if (format.endswith(" }")):
            format = format[:-2]
        else:
            formatter = fields[n].lstrip().split("}")[0].rstrip()
            
        if formatter.startswith("&"):
            formatter = formatter[1:]
            
        # Sanity clauses.
        if not offset.isdigit():
            outtaHere("Illegal offset %s" % offset, f)
        if scale.startswith("B"):
            scaleChars = scale[1:]
        else:
            scaleChars = scale
        if len(scaleChars) == 0:
            outtaHere("Empty scale", f)
        if not scaleChars.isdigit():
            outtaHere("Unknown scale \"%s\"" % scale, f)
        if not format.startswith("FMT_"):
            outtaHere("Unknown format \"%s\"" % format, f)
        if formatter != "" and not formatter.startswith("Format"):
            outtaHere("Unknown formatter \"%s\"" % formatter, f)
        
        print("%s\t%s\t%s\t%s\t%s\tTBD" % (offset, variable, scale, format, formatter), file=f)
        
        record = {
            "scale": scale,
            "format": format,
            "formatter": formatter
            }
        key = variable
        for modifier in "@abcdefghijklmnopqrstuvwxyz":
            if modifier == "@":
                modifier = ""
            fields = key.split("+")
            if len(fields) == 1:
                modifiedKey = key + modifier
            else:
                modifiedKey = fields[0] + modifier + "+" + fields[1]
            if modifiedKey not in unique:
                unique[modifiedKey] = record
                break
            elif unique[modifiedKey] == record:
                break

f = open("ddd-format-lookup.tsv", "w")
for key in sorted(unique):
    print("%s\t%s\t%s\t%s\tTBD" % (key, unique[key]["scale"],
                                   unique[key]["format"], 
                                   unique[key]["formatter"]), file=f)
f.close()

    