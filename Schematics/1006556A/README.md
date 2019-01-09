# Introduction

This folder contains the transcription of the original Apollo Program drawing 1006556A to KiCad.  This is the electrical schematic for Block I AGC module A21.  We also have revision 1006556- of the original drawing, though it has not been transcribed to CAD.  At the same time, the schematic is supplemented by the original "signal wiring diagram", of which we have 3 revisions, 1006136-, 1006136A, and 1006136B.  Signal wiring diagrams provide information lacking in the schematics, primarily reference designators and input-pin numbering for NOR gates.  The signal wiring diagrams also duplicate most of the NOR-gate and connector wiring, albeit with a certain degree of ambiguity.  Creation of the CAD files for 1006556A relied on both the schematic and the signal-wiring diagram.

_Prior_ to the availability of the original drawings for module A21, the schematics for this module were "recovered" from AC Electronics document ND-1021041 as a different set of KiCad files, referred to as [1006556r](https://github.com/virtualagc/virtualagc/edit/schematics/Schematics/1006556r).  Now that CAD files from both the original and from ND-1021041 are available, it is a useful proofing method, as well as a way to judge the accuracy of ND-1021041, to compare the netlists of these two implementation of 1006556 in CAD.  

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

# Signal ROPB

In the recovered schematic (1006556r), gate 60080 from ND-1021041 Figure 4-68 and its driving connector pin 75 (ROPB) appear which do not appear in any of the available revisions of the official schematic drawing (1006556- and 1006556A).  Moreover, while these items do not appear in earlier signal-wiring diagram revisions (1006136- and 1006136A), the _do_ appear in signal-wiring diagram 1006136B.

Conclusion:  The latest revision of the schematic which we have, namely 1006556A, is not the latest actual revision.  Probably there is a revision 106556B that contains gate 60080 and connector pin 75.

# Signals RRPA and MRRPA/

Gates 60041 and 60042, driving connector pins 18 (RRPA) and 34 (MRRPA/) respectively, are present in the available official schematic drawings (1006556- or 1006556A) but _not_ in ND-1021041 and the recovered drawing 1006556r.  Both gates are present in all available revisions of the signal-wiring diagram (1006136-, 1006136A, 1006136B).

There's not enough available evidence to distinguish between the following 3 possible explanations:

* It may be an error of omission in ND-1021041.
* It may be a transcription in 1006556r.  (I.e., the gates may appear in ND1021041 but haven't yet been found.)
* There may be revisions C (or higher) of the schematic 1006556 and wiring diagram 1006136 in which the gates have been removed.  (This assumes that the conclusion in the preceding section is correct, namely that signal-wiring diagram rev B corresponds to schematic rev B, and thus that the gates would therefore still appear in schematic rev B since they appear in rev B of the signal-wiring diagram.)


