# Introduction

This folder contains the transcription of the original Apollo Program drawing 1006552A to KiCad.  This is the electrical schematic for Block I AGC module A21.  We also have revision 1006552- of the original drawing, though it has not been transcribed to CAD.  

At the same time, the schematic is supplemented by the original "signal wiring diagram", of which we have drawing 1006132-.  Signal wiring diagrams provide information lacking in the schematics, primarily reference designators and input-pin numbering for NOR gates.  The signal wiring diagrams also duplicate most of the NOR-gate and connector wiring, albeit with a certain degree of ambiguity, though this information is not needed by the transcription process.  

__Note:__ Several electrical discrepancies between schematic 1006552A and wiring diagram 1006132- found during transcription are described in notes 4, 5, and 9 of the 1006552A CAD file.  These discrepancies are not present in schematic 1006552-, so presumably wiring diagram 1006132- corresponds to schematic 1006552-, and (unavailable) wiring diagram 1006132A corresponds to schematic 1006552A.  There is no functional impact from these discrepancies, since only the assignment of reference designators and pin numbers of interchangeable pins are affected.

_Prior_ to the availability of the original drawings for module A21, the schematics for this module were "recovered" from AC Electronics document ND-1021041 as a different set of KiCad files, referred to as [1006552r](https://github.com/virtualagc/virtualagc/edit/schematics/Schematics/1006552r).  Now that CAD files from both the original and from ND-1021041 are available, it is a useful proofing method, as well as a way to judge the accuracy of ND-1021041, to compare the netlists of these two implementation of 1006552 in CAD.  

There is [a Python script](https://github.com/virtualagc/virtualagc/edit/schematics/Scripts/netlistCompare.py) to assist in carrying out this comparison.  I don't claim the script is perfect or all-inclusive, but it did find stuff, and after I fixed up those things it did stop detecting them.

The reason a script is needed rather than a simple text comparison is that various factors need to be ignored in the comparison, and thus some semantic understanding of what's going on is needed:

* Different reference designators for NOR gates
* Different input-pin assignments in NOR gates
* Different naming of backplane signals, in cases where ND-1021041 _does not_ provide explicits name for them.

Differences which can be detected using this method, once the factors above are discounted, are:

* Missing components in one or the other netlist.
* Missing component pins in one or the other netlist.
* Different naming of backplane signals, in cases where ND-1021041 _does_ provide explicit names for them.
* Different connectivity.

The differences that are detected are then either transcription errors (which are fixed within the CAD files themselves), legitimate differences in conventions (such as "(NC)" vs "N.C." for no-connects), or else are actual differences that require, or at least invite, resolution.  The findings relating to the actual differences are noted below.

# Connector Pin 2

Connector pin 2, the input to inverter 51303 is assigned the backplane signal name F02B/ in schematic drawing 1006552A (and 1006552-).  However, in ND-1021041 Figure 4-62 it is assigned the name GO/.

I don't have any information at present to resolve this discrepancy.

# Wiring of Inputs to Gate 51312.

In ND-1021041 Figure 4-62, the inputs to gate 51312 are given as:

* Connector pin 16
* Connector pin 20
* Output of gate 51311

In schematic 1006552A (and 1006552-) and wiring diagram 1006132-, they are instead given as:

* Connector pin 50
* Connector pin 20
* Output of gate 51311

Because of the way the wires from connector pins 16 and 50 are drawn in the schematic, it would be a natural error to accidentally swap them, and so I believe this is an error in ND-1021041.

