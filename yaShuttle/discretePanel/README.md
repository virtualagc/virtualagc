This directory contains software and data files needed for running Space Shuttle flight software via emulation. All of the available software that's needed is provided, except for the AP-101S CPU emulator, `yaGPC2`, which is instead provided in the directory ../yaGPC2.  The full flight software is not provided here due to legal fears, but an abbreviated version that's deemed legally safe is provided for demonstration purposes.

Note: The acronym IPL stands for Initial Program Load.

Here are some specifics as to what's provided:

- `discretePanel.py` is a primitive GUI which provides simulation of some control-panel switches needed for IPL, covering only the single-GPC configuration.
- `discreteMonitor.py` is a program for monitoring the network signals emitted by `discretePanel.py`.
- `discretes.py` is a Python module used by both `discretePanel.py` and `discreteMonitor.py`.
- `MEDS2.py` provides a simulation of a Multifunction Electronic Display Subsystem (MEDS), i.e. a Shuttle display screen. The directories config/ and data/ belong also to this program.
- `panelO6.py` &mdash; is an improved replacement for `discretePanel.py`, featuring multi-GPC configurations, much more visually realistic controls, window resizing, and so on.
- `stsKeyboard.py` &mdash; provides a simulation for the Shuttle keyboards used with the MEDS.
- `OI340700-OPS0.mmv` &mdash; a simulated magnetic tape for the Shuttle's Mass Memory Units (MMU), suitable for booting the simulation and running it. The tape has been abridged to contain only enough software to IPL OPS 0, i.e., the "system software" as opposed to any actual "application software". Nevertheless, it's enough to let you get a flavor of the process and to see various display screens.
- `simulatePASS.py` &mdash; a wrapper program to tie all of the above together so as to run the simulation. If you happen to have a non-abridged tape, you could run the entirety of the flight software (OPS 1, OPS 2, etc.). 
- HANDOFF-*.md &mdash; Information about these programs, as written by the A.I. agents that assisted me in creating or porting the programs.  A.I. agents Claude Code (primarily Sonnet 5) and Grok Build (Grok 4.6) assisted in coding, porting, and adapting. These files are for the purpose of bringing an A.I. agent up to speed if modifications to the programs are required, and probably aren't of direct use in a human sense.

The `MEDS2.py` program was adapted from a port of an adaptation of [Don Schmidt's `MEDS` simulation program](https://github.com/ColanderCombo/nsts-sim-gpc). The adaptation was originally made for pragmatic reasons involving delayed committing of program modifications, and once those delays were ironed out, the divergence was too large to easily merge `MEDS2` back into Don's `MEDS`. You may nevertheless find that `MEDS` can still be used here.  Or you can try using Don's tools in their entirety at the link given above.

All *other* programs were created from scratch here.
