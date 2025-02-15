#!/usr/bin/env python
# Copyright 2018 Ronald S. Burkey <info@sandroid.org>
# 
# This file is part of yaAGC.
# 
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# Filename:     dumbInitialization0.py
# Purpose:      Try to determine a set of logical-net values (i.e., 0 or 1)
#               that's consistent with the open-drain triple-input NOR logic.
# Mod history:  2025-01-19 RSB  Forked from dumbInitialization.py  Ripped out 
#                               the algorithm for determining the net values
#                               and replaced it with something entirely 
#                               different.
#               2025-01-23 RSB  Optionally accept input file from command line.

doRecursive = True
tryValues = (True, False)

'''
I don't entirely understand the algorithm I was using in dumbInitialization.py
It seems be initializing all nets to 0, and then interating 
through computation of the complete set of gate outputs until the values of 
the nets no longer change in some iteration.  A random order of evaluating the 
nets was used on each iteration.  Besides that, constraints
could be specified in which the outputs of specific gates were forced to values
of `False` or `True` on each iteration.  I'm not sure that was being done
correctly.  But whether or not this was being done correctly, I began 
finding cases in which I simply couldn't get the thing to settle into a 
consistent state, or to get the results the specified constraints.

The new algorithm is entirely different:  Given specified desires for the 
values of certain nets, the algorithm ripples those values through all 
interconnected gates to the extent possible, computing the logical consequences
and assigning values to unassigned nets reached by this computation..
I call this "rippling" action the `butterflyEffect`.  Applying the 
`butterflyEffect` may either succeed (if the specified desires were logically
consistent with the structure of the interconnections) or may fail (if they were
logically inconsistent).  I'll get to the consequences of those results in a 
moment. 

Note that any net of an AGC logic module can be modeled as an N-input NOR gate
(except a pure input).  The "logical consequences" I mentioned are:

    1. If the output of a NOR gate is `True`, then *all* inputs must be `False`.
    2. If *any* input of a NOR gate is `True`, then the output must be `False`.
    3. If the input of a 1-input NOR-gate is `False`, then the output must be `True`.
    4. If the ouput of a 1-input NOR gate, `False`, then the input must be `True`.

Typically, a few nets will have values we'd like to insist upon.  I call those
"requirements".  So the first step is to use the requirements as the "specified
desires" and apply the `butterflyEffect`.

In most cases, the result of applying `butterflyEffect` will leave some nets 
with undefined values (which are Python `None`).  If not, then we're all done,
and have found a solution.  In other words, this process must iterate
in some way until all nets are assigned values.  The nature of the iteration
is to choose some currently-undefined net, assign it a value, and then reapply
`butterflyEffect`.  There are only two possible assignments, `False` and `True`,
and the value we choose to assign them is somewhat arbitrary.  In fact, the value
we choose is the first element Python tuple `tryValues`.  For the 
sake of this discussion, we'll assume that's `True`.  The net we choose to
assign a value to is also arbitrary, though there are undoubtedly some 
strategies that would result in greater or lesser speed of convergence; we 
simply choose to use the order in which we have encountered the nets in Verilog
source code, at least for now.

As I said above, the result of applying the `butterflyEffect` is either failure
(a logical inconsistency was found) or success (no logical inconsistencies were
found).  If the result of `butterflyEffect` had been success, then
we can just proceed to the next iteration without further ado.

If the result of `butterflyEffect` was failure, then some arbitrary assignment
we've made to a net has revealed a logical inconsistency.  What we do in this
case is to unroll all of the interations (i.e., the assignments and applications
of `butterflyEffect`) until we find deepest iteration at which we assigned a
net the value `True` (or more exactly, `tryValues[0]`), and instead assign it
`False` (`tryValues[1]`), then continue iterating from that point.  If there
*are* no arbitrary assignments we've made of `True`, then the original 
requirements must have been inconsistent to begin with, and the entire process
fails.
'''

# Usage is:
#   cat VERILOG_FILES | dumbInitialization.py
# where the input VERILOG_FILES include files for A1 through A24.
# The result is a series of files A1.init, A2.init, ..., A24.init.
# You can use a smaller set of module files, but the initialization will
# be independent of the modules that aren't included, and therefore
# possibly inconsistent with them.

import sys
#import random
import re
import copy

DEBUG = False

# Parse command-line options and read all of the concatenated input Verilog files.
usedFile = None
makeGraph = False
for parm in sys.argv[1:]:
    if parm == "--graph":
        makeGraph = True
    elif not parm.startswith("--"):
        usedFile = parm
        f = open(usedFile)
        lines = f.readlines()
        f.close()
    else:
        print("Usage is:")
        print("\tdumbInitialization0.py [OPTIONS] [VERILOGSOURCE.v]")
        print("If no VERILOGSOURCE.v file is specified, the Verilog source")
        print("code is read from stdin.  The available OPTIONS are:")
        print("  --graph   Causes a `graphviz` directed graph to be created")
        print("            rather than the default behavior (described below).")
        print("            The output is a file called dumbInitialization0.dot,")
        print("            which subsequently can be compiled:")
        print("                 dot -Tsvg dumbInitialization0.dot")
        print("                     or")
        print("                 dot -Tpng dumbInitialization0.dot")
        print("But the default behavior is to find a consistent set of net values")
        print("relative to the boolean circuit described by the Verilog source")
        print("code and to output a set of initialization files.")
if usedFile == None:
    usedFile = "stdin"
    lines = sys.stdin.readlines()

# The way dumbVerilog.py creates the Verilog files, each input, output, inout, 
# internal net is named uniquely.  Moreover, each "assign" statement is 
# accompanied by a comment that tells which specific gates' outputs it applies
# to.  Therefore, to build up the data describing the electrical structure,
# all we need to look at is the "assign" statements and their accompanying comments.
# For our purposes, each "assign" statement (i.e., each gate) is completely
# described by:
#   Its reference designator and pin (or in this case, the list of connected ones).
#   Its output netname.
#   Its input netnames.
netRules = {}
netValues = {}
module = ""
inReg = False
for line in lines:
    fields = line.strip().split()
    if len(fields) < 1:
        if inReg:
            inReg = False
        continue
    # Take care of regs.
    if fields[0] == "reg":
        inReg = True
        regFields = re.split(r'[,;]', line.strip()[4:])
    elif inReg:
        regFields = re.split(r'[,;]', line.strip())
    if inReg:
        for field in regFields:
            fieldsInTheReg = field.replace(" ", "").split("=")
            if len(fieldsInTheReg) == 2:
                if fieldsInTheReg[1] == "1":
                    if fieldsInTheReg[0] not in want1:
                        want1.append(fieldsInTheReg[0])
                    if fieldsInTheReg[0] in want0:
                        want0.remove(fieldsInTheReg[0])
                elif fieldsInTheReg[1] == "0":
                    if fieldsInTheReg[0] not in want0:
                        want0.append(fieldsInTheReg[0])
                    if fieldsInTheReg[0] in want1:
                        want1.remove(fieldsInTheReg[0])
        if ";" in line:
            inReg = False
        continue
    # "module" line.
    if len(fields) == 3 and fields[0] == "module":
        module = fields[1]
        continue
    # Comment field associated with following "assign".
    if len(fields) >= 3 and fields[0] == "//" and fields[1] == "Gate":
        gates = fields[2:]
        continue
    # "assign" statements have several possible forms, but there's always one or 
    # the other of the following: 
    #   assign ... OUTNET = ... !(0|INNET1|INNET2|...)...
    #   assign ... OUTNET = ... ((0|INNET1|INNET2|...)...
    if len(fields) < 1:
        continue
    if fields[0] != "assign":
        continue
    j = 0
    for i in range(2, len(fields)):
        if fields[i] == "=":
            j = i
            outnet = fields[j - 1]
            break
    if j == 0:
        continue
    innets = []
    for i in range(j + 1, len(fields)):
        if fields[i][:4] in ["((0|", "!(0|"]:
            k = fields[i].find(")")
            if k < 5:
                continue
            stripped = fields[i][4:k]
            innets = stripped.split("|")
    if len(innets) < 1:
        continue
    # Save the data in structures.
    if outnet not in netRules:
        netRules[outnet] = { "gates":gates, "innets":innets }
    else:
        netRules[outnet] = { "gates":(netRules[outnet]["gates"]+gates), 
                        "innets":(netRules[outnet]["innets"]+innets) }
    netRules[outnet]["gates"] = sorted(list(set(netRules[outnet]["gates"])))
    netRules[outnet]["innets"] = sorted(list(set(netRules[outnet]["innets"])))
    if outnet not in netValues:
        netValues[outnet] = { "value": None, "why": None }
    for innet in innets:
        if innet not in netValues:
            netValues[innet] = { "value": None, "why": None }

if False: ###DEBUG###
    for netRule in netRules:
        print(netRule, netRules[netRule])

if makeGraph:
    f = open("dumbInitialization0.dot", "wt")
    print("# Directed graph created by dumbInitialization0.py from", \
          usedFile, file = f)
    print("digraph dumbInitialization0 {", file = f)
    for netRule in netRules:
        print('"%s" ;' % netRule, file = f)
    for netRule in netRules:
        innets = netRules[netRule]["innets"]
        for innet in innets:
            print('"%s" -> "%s" ;' % (innet, netRule), file = f)
    print("}", file = f)
    f.close()
    sys.exit(0)

if False:
    # Inherited from dumbInitialization.py
    want1 = [
        #"GOSET_", 
        "STOPA", 
        # This zeroes the flip-flops in counter modules A20-A21 can otherwise trigger
        # a bunch of involuntaries (PINC etc.) on registers 024-060 at startup.
        "g31132", "g31129", # 24
        "g31139", "g31136", # 25
        "g31146", "g31143", # 26
        "g31232", "g31229", # 27
        "g31239", "g31236", # 30
        "g31246", "g31243", # 31
        "g31106", "g31102", "g31109", # 32
        "g31119", "g31115", "g31124", # 33
        "g32108", "g31202", "g31209", # 34
        "g31219", "g31215", "g31224", # 35
        "g31306", "g31302", "g31309", # 36
        "g31319", "g31315", "g31324", # 37
        "g31406", "g31402", "g31409", # 40
        "g31419", "g31415", "g31424", # 41
        "g32506", "g32502", "g32509", # 42
        "g32519", "g32515", "g32524", # 43
        "g32608", "g32602", "g32609", # 44
        "g32619", "g32615", "g32624", # 45
        "g32632", "g32629", "g32636", # 46
        "g32646", "g32643", # 47
        "g31332", "g31329", # 50
        "g31341", "g31336", # 51
        "g31346", "g31343", # 52
        "g31432", "g31429", # 53
        "g31439", "g31436", # 54
        "g31446", "g31443", # 55
        "g32532", "g32529", # 56
        "g32539", "g32536", # 57
        "g32546", "g32543", # 60
        "g31346", "g31339", "g31332", 
        "g31319", "g31306", "g31302", "g31309", "g31315", 
        "g31324", "g48148", "g48144", "g48138", "g48134",
        "g31419", "g31406", "g31402", "g31409", "g31415",
        "g31424", "g49328", "g49324", "g49317", "g49313",
        "g31246", "g31239", "g31232", "g31229", "g31236", "g31243",
        # Restart monitor
        "g98023", "g98027", "g98029", "g80031", 
        #"g98033", 
        "g98035", "g98037", "g98039", "g98041",    "g98013",
        # Various flip-flops affecting the behavior of CHORxx.
        #"g48402", "g48406", "E7_", 
        "g45117", "g45105", "g45225",
        # RAM related
        #"g42246", "g42238", "g42234", "g42209", "g42206"
    ]
else:
    want1 = []
    
# The `requirements` dictionary tells what our requirements are for the
# outputs of NOR gates (or more accurately for the values of nets), and
# any given net (using its name as key) can have the value True (HIGH, 1)
# or False (LOW, 0).  Any nets not appearing in `requirements` aren't 
# specified and an attempt to compute them will be made.
requirements = {
    # STNDBY is controlled from a B-module that we're not simulating.
    "STNDBY": False, "STRT1": False,
    '''
    # CHORxx
    #"PIPAFL": False, 
    "AGCWAR": False,
    # Misc
    "g32607": False,
    # RAM related
    #"g42247": False, "g42239": False, "g42235": False, "g42210": False, "g42205": False,
    '''
    "STRT2": True, "STOPA": True,
    # STNDBY is controlled from a B-module that we're not simulating.
    #"STNDBY": False, "STRT1": False,
    #"AGCWAR": False,
    # Misc
    #"g32607": False,
    # RAM related
    #"SBE": False, "REX": False, "REY": False, "WEX": False, "WEY": False,
    #"_A99_2_EDESTROY": False
    }
for n in want1:
    if n in netRules and n not in requirements:
        requirements[n] = True
if True:
    # Put the clock dividers in module A1 into a known state.
    if True:
        for x in range(100, 500, 100): 
            for y in range(0, 80, 10):
                requirements["g%d" % (38004 + x + y)] = True
                requirements["g%d" % (38005 + x + y)] = True
    #for n in range(1, 33):
    #   requirements["FS%02d"] = False
    # This zeroes the flip-flops in counter modules A20-A21 that can otherwise trigger
    # a bunch of involuntaries (PINC etc.) on registers 024-060 at startup.
    for n in range(24, 61): 
        requirements["C%dA" % n] = False

for key in netValues:
    # Initialize the network values using the `requirements`.
    if key in requirements:
        netValues[key]["value"] = requirements[key]
        netValues[key]["why"] = "requirements"
    
if DEBUG: ###DEBUG###
    for key in netRules:
        print("netRules['%s'] =" % key, netRules[key])
    if False:
        for key in netValues:
            print("Initial netValues['%s'] =" % key, netValues[key])

# Print (for debugging) an explanation of how a net assigment was made.
tracedNetValues = []
def traceNetValue(final, indent=0):
    if indent == 0:
        tracedNetValues.clear()
    
    netValue = netValues[final]
    if netValue["value"] == None:
        return
    if final in requirements:
        print("%sRequirement %s" % (" "*indent, final), netValues[final], file=sys.stderr)
        if indent > 0:
            return
    else:
        print("%sTracing %s:" % (" "*indent, final), netValues[final], file=sys.stderr)
    if final not in tracedNetValues and final in netRules:
        tracedNetValues.append(final)
        if netValue["value"]:
            # Why is this HIGH?  It can only be because all NOR inputs are LOW.
            for innet in netRules[final]["innets"]:
                traceNetValue(innet, indent+1)
        else:
            # Why is this LOW?  It can only be because at least one NOR input is HIGH.
            for innet in netRules[final]["innets"]:
                if netValues[innet]["value"] == True:
                    traceNetValue(innet, indent+1)

# Assign all net values which can be computed from nets already 
# assigned values.  Returns False on success, True on failure.  Failures can
# only occur, I think, if there is a logical inconsistency.
def butterflyEffect(netValues=netValues, showMessages=False):
    changed = True
    while changed:
        changed = False
        for netName in netValues:
            if doRecursive and "rippled" in netValues[netName]:
                continue
            netValue = netValues[netName]["value"]
            why = netValues[netName]["why"]
            if netName not in netRules:
                continue
            if netValue == None:
                continue
            netValues[netName]["rippled"] = True
            if netValue:
                # Make sure all inputs to the (ganged) NOR-gate are assigned LOW
                innets = netRules[netName]["innets"]
                for innetName in innets:
                    innetValue = netValues[innetName]["value"]
                    if innetValue == True:
                        if showMessages:
                            print("Input %s HIGH inconsistent with output %s HIGH" \
                                  % (innetName, netName), file=sys.stderr)
                            traceNetValue(netName)
                        return True
                    if innetValue == None:
                        changed = True
                        netValues[innetName]["value"] = False
                        netValues[innetName]["why"] = why
                # Make sure all (ganged) NOR-gates with this net as input are
                # assigned a LOW output.
                for outnet in netRules:
                    innets = netRules[outnet]["innets"]
                    if netName not in innets:
                        continue
                    if netValues[outnet]["value"] == False:
                        continue
                    if netValues[outnet]["value"] == None:
                        changed = True
                        netValues[outnet]["value"] = False
                        netValues[outnet]["why"] = why
            else:
                # If this net has a single input, make sure that input is 
                # assigned HIGH.
                if len(netRules[netName]) == 1:
                    innetName = netRules["innets"][0]
                    if innetName not in netValues:
                        continue
                    innetValue = netValues[innetName]["value"]
                    if innetValue == False:
                        if showMessages:
                            print("Input %s LOW inconsistent with output %s LOW" \
                                  % (innetName, netName), file=sys.stderr)
                            traceNetValue(netName)
                        return True
                    else:
                        if innetValue == None:
                            changed = True
                            netValues[innetName]["value"] = True
                            netValues[innetName]["why"] = why
                # If this net is an input to a NOR gate having no other inputs,
                # account for the effect on that NOR gate's output.
                for outnet in netRules:
                    innets = netRules[outnet]["innets"]
                    if len(innets) == 1 and innets[0] == netName:
                        if netValues[outnet]["value"] == False:
                            if showMessages:
                                print("Output %s LOW inconsistent with input %s LOW" \
                                      % (outnet, netName), file=sys.stderr)
                                traceNetValue(netName)
                            return True
                        if netValues[outnet]["value"] == None:
                            changed = True
                            netValues[outnet]["value"] = True
                            netValues[outnet]["why"] = why
                
    return False

# Now the tricky part: Trying to assign values to the as-yet-unassigned nets
# in such a way as to remain consistent with the values determined by the 
# already-assigned nets.
if doRecursive:
    
    # `assignUnassigned` is a recursive function to assign values to all 
    # unassigned nets.  The function has three inputs:
    #    `index`        an index into `netNames` in which you're guaranteed
    #                   that all preceding nets in `netNames` have already 
    #                   been assigned value.  Default 0.
    #    `nets`         which the function makes a deep copy of before 
    #                   proceeding, defaulting to `netValues`.
    #    `depth`        the depth of the iteration, defaulting to 0.
    # The function returns an ordered pair:
    #    `status`       `False` upon success, `True` upon failure.
    #    `nets`         Upon success, the altered copy of the `nets` input.
    
    lastPrintTrace = -1
    def printTrace(indent, net, value):
        global lastPrintTrace
        if indent > lastPrintTrace:
            c = "+"
        elif indent < lastPrintTrace:
            c = "-"
        else:
            c = "="
        print("%c %05d: %s=%r" % (c, indent, net, value))
        lastPrintTrace = indent
    
    if False: 
        # Use nets simply in the order they were discovered.
        netNames=list(netValues)
    elif False:
        # Sort `netNames` alphabetically.  The idea is that gXXXXX gates likely
        # to be closely related are processed together, hopefully revealing 
        # logical contradictions sooner.
        netNames = list(sorted(netValues))
    elif True:
        # Order the nets with requirements and pure outputs first.  Followed
        # by all inputs to the NORs driving those nets.  Followed by all inputs
        # to the NORs driving those nets, and so on.
        netNames = []
        for netName in requirements:
            if netName in netValues:
                netNames.append(netName)
        print("requirements", len(netNames), netNames)
        extra = copy.deepcopy(netNames)
        # Find all of the pure outputs.  Assume at first that all nets are pure
        # outputs, but remove any that are found to be inputs of other nets.
        outputs = set(list(netRules))
        for netName in netRules:
            for input in netRules[netName]["innets"]:
                outputs.discard(input)
        layer = sorted(list(outputs))
        print("pure outputs", len(layer), layer)
        # Now add all of the "layers" consisting of inputs to the nets already
        # added.
        while len(layer) + len(extra) > 0:
            netNames.extend(layer)
            inputs = []
            for netName in extra + layer:
                if netName not in netRules:
                    continue
                for input in netRules[netName]["innets"]:
                    if input in netNames or input in inputs:
                        continue
                    #print("###DEBUG###", netName, input)
                    inputs.append(input)
            layer = inputs
            extra = []
            print("layer", len(layer), layer)
        print("netRules", len(netRules), netRules)
        print("netValues", len(netValues), netValues)
        print("netNames", len(netNames), netNames)
    else:
        print("No net ordering selected; abort!")
        sys.exit(1)
        
    def assignUnassigned(index=0, nets=netValues, indent=0):
        trialNets = copy.deepcopy(nets)
        if butterflyEffect(trialNets, indent == 0):
            # Failure!
            return True, None
        for i in range(index, len(netNames)):
            net = netNames[i]
            if nets[net]["value"] != None:
                continue
            newNets = copy.deepcopy(trialNets)
            newNets[net]["why"] = net
            newNets[net]["value"] = tryValues[0]
            printTrace(indent, net, tryValues[0])
            status, newerNets = assignUnassigned(i + 1, newNets, indent + 1)
            if status:
                # Failure
                newNets = copy.deepcopy(nets)
                newNets[net]["why"] = net
                newNets[net]["value"] = tryValues[1]
                printTrace(indent, net, tryValues[1])
                status, newerNets = assignUnassigned(i + 1, newNets, indent + 1)
                if status:
                    # Failure!
                    return True, None
            return False, newerNets
        return False, trialNets
    status, nets = assignUnassigned()
    if status:
        print("No consistent configuration found", file=sys.stderr)
        sys.exit(1)
    netValues = nets
    
else:
    '''
    In this algorithm, unlike the superseded algorithm, we use an evaluation 
    order for the unassigned nets that never changes.  At the moment, this is 
    simply the order in which they appear in `netValues`; I think the algorithm 
    could be sped up if a better order were used, such as the nets being 
    farther to the right-hand-side of the schematics being prioritized over the 
    ones on the left -- i.e., if the nets "closer" to being "outputs" were 
    prioritized over the ones being closer to inputs.  Or perhaps prioritizing
    nets with more endpoints.  The order in which the values are tried --
    currently HIGH and then LOW, but it could be LOW and then HIGH -- could 
    also make a difference.  Regardless, it shouldn't matter in terms of 
    whether the algorithm works or not.  
    
    [Following up on the latter suggestion above:
    My current empirical observation is that about 1305+2*434 nets are assigned 
    the initial value of HIGH, whereas about 4600 are assigned the value of LOW.
    So at least statistically, we're much more likely to be correct on the 
    first try if we try assigning nets the value LOW than if we first try
    assigning them HIGH. And yet the side effects (via `butterflyEffect`) are
    going to be greater by trying HIGH first, so failure is detected earlier,
    perhaps reducing the number of backtrack attempts.  Difficult to gauge which
    would be more effective without actually trying it first.  When I do try it,
    though, I get a complete pig's breakfast in which the simulation aborts in
    nanoseconds.  But I digress!]
    
    The idea is this:  Once `netValues` corresponding to the `requirements` are
    set, search to find the first net still having a value of 
    None.  Append the name of this net to a list (`assignedNets`), and assign
    it a value of True.  Compute the side effects (`butterflyEffect`).  If
    consistent, proceed to the next unassigned net and do similarly.  But if not,
    unassign the nets just assigned by `butterflyEffect`, then reassign the net
    to have a value of 'False` and retry.  If consistent, proceed to the next
    unassigned net and do similarly.  But if inconsistent, then instead
    backtrack through the nets in `assignedNets`, undoing all of the net
    assignments that had been performed at the nets being backtracked through,
    until reaching a net (from `assignedNets`) which had been assigned a value
    of True.  Assign it instead a value of False, recomputing the side 
    effects and then again proceeding through the next unassigned nets.
    Once no new unassigned nets can be found, then the process is complete.
    When backtracking through `assignedNets`, if *no* net is reached that has
    been assigned the value True, then the `requirements` were inconsistent
    with the wiring of the unassigned nets, and no consistent assignments are
    possible.
    
    This process takes a *very* long time, much longer than I had ever imagined
    given the amount of backtracking I think is taking place -- namely, very 
    little -- so I some optimizations may be desirable.  But that's TBD.
    '''
    # Take care of the `requirements` and all of the nets whose values are
    # indirectly but unambiguously determined by the requirements.
    if butterflyEffect(netValues, True):
        sys.exit(1)
    
    # Undo the assignment of values to a net and its collateral nets.
    def undoNet(net):
        for unet in netValues:
            if netValues[unet]["why"] == net:
                netValues[unet]["value"] = None
                netValues[unet]["why"] = None
    
    netNames = list(netValues)
    assignedNets = []
    netIndex = 0
    regress = False
    while netIndex < len(netNames):
        net = netNames[netIndex]
        thisValue = netValues[net]["value"]
        if not regress and thisValue != None:
            netIndex += 1
            continue
        assignedNets.append(netIndex)
        if regress:
            regress = False
            start = 1
            undoNet(net)
        else:
            start = 0
        for tryValue in tryValues[start:]:
            netValues[net]["value"] = tryValue
            netValues[net]["why"] = net
            if butterflyEffect(netValues):
                if tryValue == tryValues[0]:
                    undoNet(net)
                else:
                    regress = True
            else:
                break
        if regress:
            while len(assignedNets) > 0 and netValues[netNames[assignedNets[-1]]]["value"] == tryValues[1]:
                netIndex = assignedNets.pop()
                undoNet(netValues[netNames[netIndex]]["why"])
            if len(assignedNets) == 0:
                print("No settings consistent with the requirements found", file=sys.stderr)
                sys.exit(1)
        else:
            netIndex += 1
    
if DEBUG: ###DEBUG###
    for key in netValues:
        print("Final netValues['%s'] =" % key, netValues[key])

for netName in []:
    print(netName + " = " + str(netValues[netName]) + ", " + str(netRules[netName]))
#print netRules

ones = []
#zeroes = []
for norNet in netRules:
    if not netValues[norNet]["value"]:
        #for nor in netRules[norNet]["gates"]:
        #   zeroes.append(nor)
        continue
    for nor in netRules[norNet]["gates"]:
        ones.append(nor)

# Create the MODULE.init files.
for moduleNumber in list(range(1, 25)) + [99, 52]:
    f = open("A" + str(moduleNumber) + ".init", "w")
    f.write("# Auto-generated for module A" + str(moduleNumber) + \
            " by dumbInitialization.py.\n")
    for sheet in range(1, 5):
        for location in range(1, 72):
            localRefd = "U" + str(sheet)
            if location < 10:
                localRefd += "0"
            localRefd += str(location)
            refd = "A" + str(moduleNumber) + "-" + localRefd
            j = 0
            k = 0
            if (refd + "A") in ones:
                j = 1
            if (refd + "B") in ones:
                k = 1
            if j == 1 or k == 1:
                f.write(localRefd + " " + str(j) + " " + str(k) + "\n")
    f.close()

# Print out a nice report about this.
#ones.sort()
#print ones
netNames = []
for netName in netValues:
    netNames.append(netName)
netNames.sort()
f = open("dumbInitialization.log", "w")
for netName in netNames:
    f.write(netName + " = " + str(netValues[netName]) + "\n")
f.close()

    

