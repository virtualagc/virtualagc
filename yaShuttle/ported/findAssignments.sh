#!/usr/bin/bash
# I use this to try to find all assignments in Python files I've ported from
# XPL, so that I can determine on a case-by-case basis whether nor not they
# should be imported from g.py and/or made global inside of subroutines.

if [[ "$1" == "" ]]
then 
        files="*.py"
else 
        files="$1"
fi

grep -P '^\s*[[\]()0-9A-Za-z_]+\s*=\s*[-(A-Z]' $files | \
sed -e 's/ *//g' -e 's/=.*//' | \
sort -u | \
less
