#!/usr/bin/env python2
#
# Python program to generate a matrix of log sections used by different
# missions.
# 
# Jim Lawton 2016-11-17
# 
# The input file is generated using:
# $ du -a | grep .agc$ | grep -v MAIN.agc | grep -v Validation | grep -v test | # awk '{print $2}' | sed 's/\.\///' | sed 's/\.agc//' | sed 's/\// /' | grep -v # Contributed >logsections.txt

import os
import os.path
import sys
from optparse import OptionParser


def main():
    parser = OptionParser("usage: %prog [base_dir]")
    (options, args) = parser.parse_args()
    basedir = os.path.join(os.getcwd(), "..")
    if len(args) >= 1:
        basedir = args[0]
        if not os.path.exists(basedir) or not os.path.isdir(basedir):
            sys.exit("Supplied base directory does not exist!")

    flights = ["Artemis072", "Aurora12", "Colossus237", "Colossus249", "Comanche055", "Luminary099", "Luminary131", "Luminary210", "Solarium055", "Sunburst120"]
    flights = sorted(flights)

    indata = {}
    # du -a | grep .agc$ | grep -v MAIN.agc | grep -v Validation | grep -v test # | awk '{print $2}' | sed 's/\.\///' | sed 's/\.agc//' | sed 's/\// /' | # grep -v Contributed | grep -v Template >Tools/logsections.txt
    for flight in flights:
        fdir = os.path.join(basedir, flight)
        agcfiles = [f for f in os.listdir(fdir) if f.endswith(".agc")]
        logs = [f.replace(".agc", "") for f in agcfiles]
        indata[flight] = logs

    outdata = {}
    logsections = []
    for flight in flights:
        for logsection in indata[flight]:
            if logsection not in logsections:
                logsections.append(logsection)
            if logsection in outdata.keys():
                if flight not in outdata[logsection]:
                    outdata[logsection].append(flight)
            else:
                outdata[logsection] = [flight]

    logsections = sorted(logsections)

    maxls = 0
    for l in logsections:
        if len(l) > maxls:
            maxls = len(l)

    maxf = 0
    for f in flights:
        if len(f) > maxf:
            maxf = len(f)

    print ' ' * maxls, "    ",  
    for f in flights:
        print "%*s  " % (maxf, f),
    print 

    for ls in logsections:
        fs = outdata[ls]
        line = ""
        for f in flights:
            if f in fs:
                line += "%*s  " % (maxf, "X")
            else:
                line += "%*s  " % (maxf, " ")
        print "%*s    %s" % (maxls, ls, line)


if __name__ == "__main__":
    main()
