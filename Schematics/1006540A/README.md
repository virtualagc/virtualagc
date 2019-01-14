# Introduction

This folder contains the transcription of the original Apollo Program drawing 1006540A to KiCad.  This is the electrical schematic for Block I AGC modules A1 through A16, and it is the only revision of the drawing available to us at this writing.  

At the same time, the schematic is supplemented by the original "signal wiring diagram", of which we have drawing 1006120-.  Signal wiring diagrams provide information lacking in the schematics, primarily reference designators and input-pin numbering for NOR gates.  The signal wiring diagram also duplicates most of the NOR-gate and connector wiring, albeit with a certain degree of ambiguity, though this information is not needed by the transcription process.  

Because the revision level of the two drawings not match ("A" vs "-"), it is likely that do not form an exactly matching pair, and we would instead need the (currently unavailable) wiring diagram 1006120A for an exact match.

Note that neither schematic 1006540A nor wiring diagram 1006120- lists quite a few of the backplane-signal names for the connector pins. Presumably that information resides in some currently unavailable (and indeed unknown) Apollo Program document. ND-1021041 _does_ list most of the missing signal names in tabular form in its figures, without attribution, but that information is not reproduced in this CAD file.  The information is reproduced in CAD schematic 1006540r (see below) and its related auxiliary file tables.txt.

_Prior_ to the availability of the original drawings for module A18, the schematics for this module were "recovered" from AC Electronics document ND-1021041 as a different set of KiCad files, referred to as [1006540r](https://github.com/virtualagc/virtualagc/edit/schematics/Schematics/1006540r).  Now that CAD files from both the original and from ND-1021041 are available, it is a useful proofing method, as well as a way to judge the accuracy of ND-1021041, to compare the netlists of these two implementation of 1006540 in CAD.  

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

# TBD

TBD
