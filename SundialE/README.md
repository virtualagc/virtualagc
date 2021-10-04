The file SundialE.bin contains data dumped from physical fixed-memory modules from the AGC owned by the MIT Museum.  The dump was performed using the restored AGC owned by collector Jimmie Loocke in July 2019.

Source code will become available eventually, via regeneration from related programs and disassembly.

Identification of this AGC is based on circumstantial evidence, because the AGC itself has no part tag.  The observable facts are that the AGC contains:

1. "B" tray of type 2003075-031
2. Alarm module of type 2003890
3. Fixed-memory modules B1 (p/n 2003053-121), B2 (p/n 2003053-151), B3 (p/n 2003972-211)

On the available information -- and admitting that there may be AGC units not covered by the available information -- this would seem to narrow the AGC p/n to 2003100-061, and possibly the following specific AGC:

* From CSM-098, "2VT-1"
* AGC p/n 2003100-061
* Software SUNDIAL E, 2021104-041

The discrepancy is that the fixed-memory modules listed are known to be from SUNDIAL assembly 2021104-051.  However, both the 2021104-041 and -51 modules contain SUNDIAL E software, so if the modules were exchanged at some point it wouldn't have affected functionality in any way.

By the way, the documentation on which the assertions about fixed-memory modules 2021104-041 vs 2021104-051 are based is this:  All of these dash numbers are past the dash-number range for which we have obtained explicit [engineering drawings (namely, 2021104-011 and -021)](https://archive.org/details/apertureCardBox467Part2NARASW_images/page/n16/mode/1up?view=theater), although the drawings we have _do_ identify 2021104-x as a SUNDIAL assembly. However, [document ND-1021043](https://www.ibiblio.org/apollo/Documents/HSI-208435-002.pdf#page=19) has "compatibility" tables showing what module part numbers are in which positions for 2021104-011 through 2021104-061.  From the tables, it is clear that the combination 2003053-121/2003053-151/2003972-211 is indeed one of the three possible combinations acceptable for 2021104-051.  The compatibility table also states that SUNDIAL assemblies 2021104-041, 2021104-051, and 2021104-061 are compatible replacements for each other under all circumstances (and that -031 is compatible as well, for testing purposes, but is "not as good").

But why SUNDIAL E, as opposed to SUNDIAL A through D?  I haven't found any explicit documentation, but the indirect evidence is that in the afore-mentioned compatibility table, it is noted that 2021104-021 "contains gyro compassing error", whereas -031 through -061 presumably do not.  If we look at [document E-1142 Rev 50, "System Status Report"](https://www.ibiblio.org/apollo/Documents/E1142-50.pdf#page=27), it is noted that "Verification of fix to Sundial C and D gyrocompass program incorporation into Sundial E was completed." From this combination of statements, it seems that we would have to infer that SUNDIAL assemblies 2021104-031 through -061 each contained SUNDIAL E, whereas 2021104-021 likely contained SUNDIAL C or D.

