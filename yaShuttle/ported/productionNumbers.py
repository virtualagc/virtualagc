#!/usr/bin/env python3
'''
Getting PRODUCTION_NUMBERS right manually in the giant DO CASE statement in
porting SYNTHESI.xpl to SYNTHESI.py has simply proven to be too time-consuming
and error-prone.  This script subtitutes the correct numbers in an automated
way.

I envisage two possible algorithms:  "clean", which is used the first time 
through whan all of the cases are in strictl sequentially-increasing order,
and "reference", when some of the cases have been reordered and thus have to
be renumbered based on the reference numbers which the "clean" method embedded.
'''

import sys

clean = True

productionNumber = -1
originalLine = 0
pattern = "if PRODUCTION_NUMBER == "

if clean:
    for line in sys.stdin:
        originalLine += 1
        line = line.rstrip('\n')
        if pattern in line:
            index = line.index(pattern) + len(pattern)
            fields = line[index:].split(":")
            productionNumber += 1
            print(line[:index] + str(productionNumber) + \
                    ": # reference " + str(10 * productionNumber))
        else:
            print(line)
