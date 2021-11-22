#!/usr/bin/python3
# This is a throwaway utility to help convert these pages I exported from
# my SlimWiki account into a form acceptable to the Zim desktop wiki program.
# It should be run separately on each exported page:
#
#   fix.py <SlimWiki.md >ZimWiki.txt

import sys
import re

print("===== Title =====")
for line in sys.stdin:
    line = line.strip("\n").replace("&nbsp;", "")
    line = re.sub(line, "\[([^]]+)\]\(([^)]+)\)", "[[\2|\1]]")
    print(line)
    