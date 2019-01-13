# Introduction

This folder contains the transcription of the original Apollo Program drawing 1006542- to KiCad.  This is the electrical schematic for Block I AGC module A18, and it is the only revision of the drawing available to us at this writing.  

At the same time, the schematic is supplemented by the original "signal wiring diagram", of which we have drawing 1006122-.  Signal wiring diagrams provide information lacking in the schematics, primarily reference designators and input-pin numbering for NOR gates.  The signal wiring diagrams also duplicate most of the NOR-gate and connector wiring, albeit with a certain degree of ambiguity, though this information is not needed by the transcription process.  

Because the revision level of the two drawings match (they are both "-"), it is likely that they form a matching pair.

_Prior_ to the availability of the original drawings for module A18, the schematics for this module were "recovered" from AC Electronics document ND-1021041 as a different set of KiCad files, referred to as [1006542r](https://github.com/virtualagc/virtualagc/edit/schematics/Schematics/1006542r).  Now that CAD files from both the original and from ND-1021041 are available, it is a useful proofing method, as well as a way to judge the accuracy of ND-1021041, to compare the netlists of these two implementation of 1006542 in CAD.  

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

# Connector Pin 109

In Figure 4-111, ND-1021041 indicates that backplane signal 234/ is fed to gate 32753 from connector pin 109.  This contradicts both schematic 1006542- and wiring diagram 1006122-.  Neither of the latter two indicates any use of connector pin 109, while 1006122- supplies the supplemental information that signal 234/ is fed to gate 32753 from connector pin 13.

While is is possible that a later revision of the schematic and wiring diagram might use pin 109 for this purpose, a more likely explanation seems to be the following:  The schematic does indicate that the "AGC4" version of module A18 (as opposed to the "AGC5" version of the module documented by ND-1021041) did indeed use pin 109 for signal 234/.  (Actually, the schematic is inconsistent and indicates that pin 109 in AGC4 was used for both 234/ and for WS/, but that is irrelevant to the argument I'm making.)  Therefore, it would probably have been easy for the author(s) of ND-1021041 to substitute pin 109 for the correct pin.

I conclude, therefore, that this is an error in ND-1021041.

# Differing Backplane Signal Names for Gate 32782

For gate 32782, ND-1021042 indicates in figure 4-144 that the input is from connector pin 113, signal name INKL/, while the output drives connector pin 111, signal name CA5.

Schematic 1006542-, on the other hand indicates pin 113, WYG/, and 111, MWYG, respectively.

It is tempting to say that in a later schematic revision the signal names are changed in the way ND-1021041 suggests.  However, gate 32782 is one of a series of gates (32780 through 32784) with a naming pattern for the inputs/outputs that follows the CPU register names and seems unlikely to change:  WAG/ MWAG, WZG MWZG, WYG/ MWYG, WQG/ MWQG, WLPG/ MWLPG.

In summary, I have no explanation to offer for the discrepancy.

# Inversions

ND-1021041 and schematic 1006542- wire several gates differently from each other, resulting in backplane signals that are inverted for one of them but not for the other.  These gates and their signals are:

|Gate   |Connector Pin|ND-1021041|Figure|Schematic 1006542-|
|-------|-------------|----------|------|------------------|
|32213  |28           |MWG1      |4-108 |MWG1/             |
|32224  |50           |MWG2      |4-108 |MWG2/             |
|32229  |70           |MWG4      |4-108 |MWG4/             |
|32238  |90           |MWG6      |4-108 |MWG6/             |
|32249  |118          |MWG3      |4-108 |MWG3/             |
|32758  |87           |MRUG      |4-111 |MRUG/             |
|32912  |7            |MWALPG    |4-101 |MWALPG/           |

All of these outputs are driven by expander NOR gates, so it is _possible_ that the author(s) of ND-1021041 became confused by the fact that Block I schematics were drawn in such a way that expander NOR-gates appear without inverting circles on the outputs, and therefore visually appear to be OR gates, which would result in the ND-1021041 drawings having the same output polarity as schematic 1006542.  However, this scenario seems somewhat unlikely, and the most-likely scenario in my view is that ND-1021041 was based on a later revision of the schematic in which these polarity changes were real.


