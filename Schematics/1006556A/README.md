# Introduction

This folder contains the transcription of the original Apollo Program drawing 1006556A to KiCad.  This is the electrical schematic for Block I AGC module A21.  We also have revision 1006556- of the original drawing, though it has not been transcribed to CAD.

_Prior_ to the availability of the original schematic drawings for module A21, the schematics for this module were "recovered" from AC Electronics document ND-1021041 as a different set of KiCad files, referred to as [1006556r](https://github.com/virtualagc/virtualagc/edit/schematics/Schematics/1006556r).  Now that CAD files from both the original and from ND-1021041 are available, it is a useful proofing method, as well as a way to judge the accuracy of ND-1021041, to compare the netlists of these two implementation of 1006556 in CAD.  

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

# Expander Gate 60080

In the recovered schematic (1006556r), a gate (60080 from ND-1021041 Figure 4-68) appears which does not appear in any of the available revisions of the official drawing (1006556- and 1006556A).  Moreover, while this gate does not appear in earlier signal wiring diagram revisions (1006136- and 1006136A), it _does_ appear in 1006136B.

My conclusion is that the latest revisions of the schematic which we have, namely 1006556A, is not the latest actual revision.  Probably there is a revision 106556B that contains gate 60080.



