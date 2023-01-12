#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       ppPALMAT.py
Purpose:        Pretty-prints a PALMAT file as created by the "modern" HAL/S
                compiler yaHAL-S-FC.  (While JSON pretty-printers can do this
                as well, ppPALMAT.py is more to my own liking.)
History:        2023-01-10 RSB  Created. 
"""

import sys
import json

# Read JSON from stdin.
PALMAT = json.loads(sys.stdin.readline())

scopes = PALMAT["scopes"]
errors = []

# Print with indentation.
def tabPrint(message, tabs=""):
    print("%s%s" % (tabs, message))

# Add an error message.
def addError(message, tabs=""):
    global errors
    errors.append(message)
    tabPrint(message, tabs)

tabs = ""

# Handle the scopes.
for scopeNumber in range(len(scopes)):
    tabPrint("Scope %d:" % scopeNumber, tabs)
    tabs = tabs + "\t"
    scope = scopes[scopeNumber]
    if scope["self"] != scopeNumber:
        error = "Scope-number mismatch (%d vs %d)." \
                % (scopeNumber, scope["self"])
        addError(error, tabs)
    parent = scope["parent"]
    children = scope["children"]
    identifiers = scope["identifiers"]
    instructions = scope["instructions"]
    scopeType = scope["scopeType"]
    
    tabPrint("Type:         %s" % scopeType, tabs)
    tabPrint("Parent:       %s" % str(parent), tabs)
    tabPrint("Children:     %s" % str(children), tabs)
    
    # Identifiers.
    if identifiers == {}:
        tabPrint("Identifiers:  (none)", tabs)
    else:
        tabPrint("Identifiers:", tabs)
        tabs = tabs + "\t"
        for identifier in sorted(identifiers):
            tabPrint("%s: %s" \
                     % (identifier[1:-1], str(identifiers[identifier])), tabs)
        tabs = tabs[:-1]
    
    # Instructions.
    if len(instructions) == 0:
        tabPrint("Instructions: (none)", tabs)
    else:
        tabPrint("Instructions:", tabs)
        tabs = tabs + "\t"
        for i in range(len(instructions)):
            tabPrint("%d: %s" % (i, str(instructions[i])), tabs)
        tabs = tabs[:-1]
    
    # Take care of the remaining keys.
    for key in sorted(scope):
        if key in ["parent", "self", "children", "identifiers", "instructions"]:
            continue
        addError("Unknown object in scope %d: %s" % (scopeNumber, key), tabs)
    tabs = tabs[:-1]

# Handle other keys (non-scopes) in the PALMAT file.
for key in sorted(PALMAT):
    if key == "scopes":
        continue
    addError("Unknown top-level object: %s" % key, tabs)

if len(errors) == 0:
    tabPrint("No errors found.")
else:
    tabPrint("", tabs)
    tabPrint("Errors encountered, file is corrupted:", tabs)
    for error in errors:
        tabPrint("%s" % error, tabs+"\t")
