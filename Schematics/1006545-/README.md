This folder contains the transcription of the original Apollo Program drawing 1006545- to KiCad.  This is the electrical schematic for Block I AGC module A23.  No other revisions (if indeed there _are_ any other revisions of the original drawing) are presently available.

Normally, a Block I logic flow diagram would be supplemented during transcription by the original "signal wiring diagram", which in this case would be drawing 1006125-.  Signal wiring diagrams provide information lacking in the schematics, primarily reference designators and input-pin numbering for NOR gates.  The signal wiring diagrams also duplicate most of the NOR-gate and connector wiring, albeit with a certain degree of ambiguity, though this information is not needed by the transcription process. Note also that AC Electronics document ND-1021041, which largley duplicates the schematics, does not contain the information just mentioned.

Unfortunately, drawing 1006125 was not available during transcription of the schematic, with the result that in the CAD files it was necessary to _arbitrarily_ assign reference designators and input-pin arrangements to the NOR gates.  For example, imagine that in the correct original design (in which the signal wiring diagram is taken account of properly) NOR gate 65133 might have reference designator U105 and might be fed with the following input signals: C1 on pin 5, C5 on pin 1, 1S on pin 3.  Since the wiring diagram is absent, thes particular assignments aren't known, so (perhaps) the gate might now be U47 and be fed by C1 on pin 1, C5 on pin 3, and 1S on pin 5.

These substitutions have no affect whatever on electrical behavior, which remains identical at all gates and all connector pins, but does relate to physical positioning of NOR gates and routing of wires, all of which will now presumably differ from the original design.

If the signal-wiring diagram becomes available in the future, I expect that the CAD files will be corrected to conform to them.

Note #4 in the CAD drawing may require a few extra words of explanation.  The relatively small amount of space available for the note within the schematic may, perhaps, make that note a tad cryptic.  What it's trying to say is this: Some connector pins in the original drawing are duplicated ... but such duplication isn't allowed in CAD, and therefore some of those pins are represented in the CAD schematic by something other than connector pins.  The problem occurs for 8 different connector pins.  I _think_ the way this happened is that in the AGC4 hardware generation, these 8 signals were each connected to two separate connector pins, but in the AGC5 hardware generation those pairs of connections were each coalesced into a single connector pin.  The original drawing displayed _both_ AGC4 and AG5 connections, but the CAD drawing (while _visually_ as close to the original drawing as possible) electrically matches only the AGC5 generation.  Thus in the CAD drawing, one connector pin from each of these 8 pairs had to be removed, in order to have a valid drawing with the correct electrical connectivity but without duplicated pins.  Where this has happened, i.e., where a connector pin has seemingly been removed, there is a notation in the schematic giving the original AGC4 pin number and AGC5 pin number.  The affected connector pins from the original drawing are as follows:

|Signal Name|AGC4 Pin Number|AGC5 Pin Number|
|-----------|---------------|---------------|
|NDX0       |31             |28             |
|0S         |34             |34             |
|TC         |70             |84             |
|C5         |51             |137            |
|SU0        |77             |139            |
|CCS1       |60             |18             |
|NDX1       |61             |52             |
|MP3        |62             |134            |




