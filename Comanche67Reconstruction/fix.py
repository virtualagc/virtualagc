#!/usr/bin/python3
# This is a throwaway utility to help convert these pages I exported from
# my SlimWiki account into a form acceptable to the Zim desktop wiki program.
# It should be run separately on each exported page:
#
#   fix.py <SlimWiki.md >ZimWiki.txt

import sys
import re

#print("===== Title =====\n")
for line in sys.stdin:
    line = line.strip("\n")
    line = line.replace("&nbsp;", "")
    line = re.sub("^\( \[", "([", line)
    line = re.sub("^(\s*)\-", "\\1*", line)
    line = re.sub("\[([^]]+)\]\(([^)]+)\)", "[[\\2|\\1]]", line)
    line = re.sub("^####(.*)", "==\\1==", line)
    line = re.sub("^###(.*)", "===\\1===", line)
    line = re.sub("^##(.*)", "====\\1====", line)
    line = re.sub("_([^_]+)_", "//\\1//", line)
    line = line.replace("\\_", "_")
    line = re.sub("^    ", "\t", line)
    line = re.sub("^    ", "\t", line)
    line = re.sub("^    ", "\t", line)
    line = re.sub("^>\s+", "\t", line)
    print(line)
    