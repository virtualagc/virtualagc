# virtualagc
Virtual Apollo Guidance Computer (AGC) software

The 'scenarios' branch of the virtualagc repository contains core dumps made by the AGC simulator
yaAGC, and are typically supplied by NASSP.  They represent the complete internal state of the AGC at various
significant points of selected missions, so that by loading a given core dump into AGC, you can
resume the mission at exactly the point in the mission that the core dump was made.

Separate directories are provided for each available AGC program (Luminary099 for Apollo 11 LM, 
Colossus237 for Apollo 8 CM, and so on), and each of those directories can contain multiple 
core dumps, along with associated "readme" files describing the situations to which those core
dumps pertain.
