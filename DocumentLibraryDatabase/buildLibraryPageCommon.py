#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     buildLibraryPage.py
# Purpose:	    Module containing common elements for buildLibraryPage.py.
#               Basically, constants and sort-key functions.
# Mod history:  2026-01-28 RSB  Split off from old buildLibraryPage.py.

import time
from datetime import datetime, date
import re

cutoffMonths = 2
cutoffFiles = 25
hoverColor = "#e0e0e0"
#frowny = "&#128547;" # 😣
#frowny = "&#128533;" # 😕
frowny = "&#128558;" # 😮

currentEpoch = int(time.time())
currentDateString = time.strftime("%Y-%m-%d", time.localtime(currentEpoch))

blurbDebug = """
This section is present temporarily, only for the purpose of debugging.  It
will be removed before this auto-generated page goes live in production.
Right now, it simply lists every document in the library, in the same order
found on <a href="links.html">our 
previously-existing Document Library page</a> ... at least to the extent that
I've input the data.
"""

# What this function does is to take something like NA, where N represents
# any string of 0-10 digits and A is any string of 0-10 characters with a 
# leading non-digit, and to pad it so that N is left-padded with '0' and 
# A is left-padded with ' '.  The idea is to normalize strings like "34A",
# "568", and 129FJ so that they sort in a way we'd expect:  first, numerically
# on N, and then stringily on A.
def padDocNumberField(n):
    m = "0000000000"
    while n[:1].isdigit():
        m = m[1:] + n[:1]
        n = n[1:]
    return m + "%10s" % n

# Used for sorting the records in order of document numbers.  We assume
# in this case that the first document number in a record that we encounter
# having the form "something#number" is what we want to use to sort on 
# numbers.
def myDocSortKeyRaw(record, reverse):
    dn = ""
    for documentNumber in record["DocumentNumbers"]:
        if "#" not in documentNumber["Number"]:
            continue
        fields = documentNumber["Number"].split("#")
        if len(fields) == 2:
            fields2 = fields[1].split("-")
            if len(fields2) == 1:
                dn = padDocNumberField("")
                n = padDocNumberField(fields2[0])
            elif reverse:
                dn = padDocNumberField(fields2[0])
                n = padDocNumberField(fields2[1])
            else:
                dn = padDocNumberField(fields2[1])
                n = padDocNumberField(fields2[0])
            dn += n
            break
    return dn
def myDocSortKey(record):
    return myDocSortKeyRaw(record, False)
def myDocSortKeyReverse(record):
    return myDocSortKeyRaw(record, True)

def myXdeSortKey(record):
    dn = ""
    for documentNumber in record["DocumentNumbers"]:
        fields = documentNumber["Number"].split("-")
        if len(fields) == 4 and fields[0] == "XDE":
            dn = fields[0] + "-" + fields[1] + "-" + fields[2] + "-"
            dn += padDocNumberField(fields[3])
            break
    return dn

# Tries to normalize the form of document numbers of the form 
# x-y-...-z[.u] by turning all fields that are pure integers into 
# zero-padded fixed lengths. If there are multiple document numbers,
# only the primary one is used.
def myDashSortKey(record):
    if len(record["DocumentNumbers"]) == 0:
        return ""
    fields = re.split('[-.]' , record["DocumentNumbers"][0]["Number"])
    key = ""
    for field in fields:
        if field == "PCN":
            field = "PCR"
        key += "%10s" % field
    return key

# Sort key for database order.
def myOriginalSortKey(record):
    return record["lineNumber"]

# Sort key for document titles.
def myTitleSortKey(record):
    return record["Title"]

# Sort key for authors.  This is really tricky. This is really tricky.  We
# have to be able to normalize names from FIRST [MIDDLE] LAST [SUFFIX] to
# LAST FIRST [MIDDLE] [SUFFIX].  But we also have to distinguish that case
# from the case of corporate authors like "MIT Instrumentation Lab" (which
# we don't want converted to "Lab MIT Instrumentation").  Then too, there
# may be multiple authors, so we need to normalize each author name into
# a fixed-length string (of adequate length) and concatenate them all.  
# Finally, if the names match, we need to add on the title as a secondary
# sort field.
def myAuthorSortKey(record):
    output = ""
    for author in record["Authors"]:
        authorName = author["Name"].upper()
        if author["Organization"] != "":
            # If we've gotten here, then the authorName is an individual
            # rather than a corporate author (if the author names are
            # formatted properly in the database).  We have to normalize
            # by picking off the author's last name, and putting it 
            # first.
            nameFields = authorName.split()
            if len(nameFields) > 0:
                if nameFields[-1] in [ "JR", "JR.", "SR", "SR.", "III", "IV", "V", "VI", "VII", "VIII" ]:
                    suffix = nameFields[-1]
                    nameFields = nameFields[:-1]
                else:
                    suffix = ""
                if len(nameFields) > 0:
                    lastName = nameFields[-1]
                    nameFields = nameFields[:-1]
                    while lastName[-1:] == ",":
                        lastName = lastName[:-1]
                    authorName = lastName
                    for n in nameFields:
                        authorName += " " + n
                    if suffix != "":
                        authorName += " " + suffix
        output += "%-30s" % authorName
    return output + record["Title"].upper()

def myDateAuthorSortKey(record):
    key = myPubDateSortKey(record) + myAuthorSortKey(record)
    # print ("\"%s\" %s" % (key, record["Title"]), file=sys.stderr)
    return key

def myMissionSortKey(record):
    targets = record["Targets"]
    if len(targets) > 0:
        fmt = "%-10s%10s"
        firstTarget = targets[0].lower()
        if "as-" == firstTarget[:3]:
            key = fmt % ("1as-", firstTarget[3:].strip())
        elif "apollo " == firstTarget[:7]:
            key = fmt % ("2apollo", firstTarget[7:].strip())
        elif "skylab" == firstTarget:
            key = fmt % ("3skylab", "1")
        elif "skylab " == firstTarget[:7]:
            key = fmt % ("3skylab", firstTarget[7:].strip())
        elif "astp" == firstTarget[:4]:
            key = fmt % ("4astp", "")
        else:
            key = fmt % ("", "")
        #print("'" + key + "'", file=sys.stderr)
        return key
    return ""

# Sort key used for the "Recently Added" section.  We want to sort primarily
# on the epoch added (myTimeSortKey), but then secondarily the way we
# normally sort on publication date and author (myDateAuthorSortKey).  The
# problem is that the former we want in descending order but that we want
# the latter in ascending order.  To account for that, we mathematically
# manipulate the epoch to reverse the sort order for just that field.
def myRecentSortKey(record):
    key = myTimeReverseSortKey(record)
    if "blurb" in record["Keywords"]:
        key = key + "A"
    else:
        key = key + "B"
    key += myDateAuthorSortKey(record)
    return key

# For sorting software anomalies.
def myAnomalySortKey(record):
    if len(record["DocumentNumbers"]) == 0:
        return ""
    key = record["DocumentNumbers"][0]["Number"]
    fields = key.split("-")
    while len(fields[0]) < 3:
        fields[0] += "Z"
    if len(fields) == 2:
        while len(fields[1]) < 3:
            fields[1] = "0" + fields[1]
        key = fields[0] + fields[1]
    elif len(fields) == 3:
        while len(fields[2]) < 3:
            fields[2] = "0" + fields[2]
        key = fields[0] + fields[1] + fields[2]
    return key

def myPubDateSortKey(record):
    month = record["MonthPublished"]
    day = record["DayPublished"]
    year = record["YearPublished"]
    if year == "":
        year = "0000"
    if month == "":
        month = "00"
    if day == "":
        day = "00"
    return year + month + day

# Used for sorting the records in order of descending newness.
def myTimeSortKey(record):
    epoch = record["EpochAdded"]
    if record["EpochFile"] > epoch:
        epoch = record["EpochFile"]
    return epoch

# This sorting key not only reverses the order of myTimeSortKey, but 
# also reduces it to an integral number of days, without hours, minutes, 
# seconds.
def myTimeReverseSortKey(record):
    if False:
        days = myTimeSortKey(record) // 86400
        reverse = 99999 - days 
        return "%05d" % reverse
    else:
        epoch = myTimeSortKey(record)
        epochString = datetime.fromtimestamp(epoch).strftime("%Y/%m/%d")
        fields = epochString.split("/")
        reverseEpoch = "%04d%02d%02d" % ( 9999-int(fields[0]), 99-int(fields[1]), 99-int(fields[2]))
        return reverseEpoch

