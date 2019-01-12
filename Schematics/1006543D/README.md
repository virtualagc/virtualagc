# Introduction

This folder contains the transcription of the original Apollo Program drawing 1006543D to KiCad.  This is the electrical schematic for Block I AGC module A17.  We also have revisions 1006543-, 1006543B, and 1006543C of the original drawing, though these have not been transcribed to CAD so far.  

At the same time, the schematic is supplemented by the original "signal wiring diagram", of which we have drawing 1006123B (and 1006123- and 1006123A).  Signal wiring diagrams provide information lacking in the schematics, primarily reference designators and input-pin numbering for NOR gates.  The signal wiring diagrams also duplicate most of the NOR-gate and connector wiring, albeit with a certain degree of ambiguity, though this information is not needed by the transcription process.  

__Note:__ Wiring diagram 1006123B is likely matched to schematic 1006543B rather than to 1006543D, and we would likely require 1006123D to have the appropriate match instead.  However, we only have the resources we have, and not the resources we might wish to have.

_Prior_ to the availability of the original drawings for module A17, the schematics for this module were "recovered" from AC Electronics document ND-1021041 as a different set of KiCad files, referred to as [1006543r](https://github.com/virtualagc/virtualagc/edit/schematics/Schematics/1006543r).  Now that CAD files from both the original and from ND-1021041 are available, it is a useful proofing method, as well as a way to judge the accuracy of ND-1021041, to compare the netlists of these two implementation of 1006543 in CAD.  

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

# Missing/Extra Connector Pins

The following connector pins are present in all available revisions of schematic 1006143 but not in ND-1021041, providing signals that already exist and are the same in both 1006143 and ND-1021041 to the backplane:

* 29 (SS05) ... _should_ be in ND-1021041 Figure 4-100.
* 129 (GP) ... _should_ be in ND-1021041 Figure 4-108.

On the available data, I can't distinguish between the following possibilities:

1. ND-1021041 omits these in error.
2. They appear in some other figure of ND-1021041, and I have overlooked them.
3. There is a later revision of drawing 1006543 in which they have been removed.

My personal suspicion is that the correct explanation is #1.

# Different Wiring of Input Signals to Gates 33101 and 33102

In Figure 4-100, ND-1021041 uses signal YT0/ (connector pin 25) as input to gate 33101, whereas 1006543 (all available revisions) uses it as input to gate 33102.  Because the outputs of gates 33101 and 33102 are ganged, the two gates logically form a single 5-input NOR gate, so moving this signal from one of the two gates to the other produces an identical electrical output, even with respect to propagation delay.

I would characterize this as a simple mistake in ND-1021041, which fortunately produces an electrically-correct result.




