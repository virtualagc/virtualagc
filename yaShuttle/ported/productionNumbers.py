#!/usr/bin/env python3
'''
Getting PRODUCTION_NUMBERS right manually in the giant DO CASE statement in
porting SYNTHESI.xpl to SYNTHESI.py has simply proven to be too time-consuming
and error-prone.  This script subtitutes the correct numbers in an automated
way.

I envisage two possible algorithms:  "clean", which is used the first time 
through whan all of the cases are in strictl sequentially-increasing order,
and "nonclean", when some of the cases have been reordered and thus have to
be renumbered based on their original ordering.
'''

import sys

clean = True

productionNumber = -1
originalLine = 0
pattern = "elif PRODUCTION_NUMBER == "

if clean:
    for line in sys.stdin:
        orignalLine += 1
        line = line.rstrip()
        if pattern in line:
            index = line.index("elif PRODUCTION_NUMBER == ") + len(pattern)
            fields = line[index:].split(":")
            productionNumber += 1
            print(line[:index] + str(productionNumber) + \
                    ": original line " + str(originalLine))
        else:
            print(line)
