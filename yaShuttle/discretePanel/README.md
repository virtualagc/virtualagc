This directory contains software and data files needed for running Space Shuttle flight software via emulation. All of the available software that's needed is provided, except for the AP-101S CPU emulator, `yaGPC2`, which is instead provided in the directory ../yaGPC2.  The full flight software is not provided here due to legal fears, but an abbreviated version that's deemed legally safe is provided for demonstration purposes.

Note: The acronym IPL stands for Initial Program Load.

Here are some specifics as to what's provided:

- `discretePanel.py` is a primitive GUI which provides simulation of some control-panel switches needed for IPL, covering only the single-GPC configuration.
- `discreteMonitor.py` is a program for monitoring the network signals emitted by `discretePanel.py`.
- `discretes.py` is a Python module used by both `discretePanel.py` and `discreteMonitor.py`.
- `MEDS2.py` provides a simulation of a Multifunction Electronic Display Subsystem (MEDS), i.e. a Shuttle display screen, with clickable edgekeys under each display. The directories config/ and data/ belong also to this program.
- `panelO6.py` &mdash; is an improved replacement for `discretePanel.py`, featuring multi-GPC configurations, much more visually realistic controls, window resizing, and so on. Its MODE and OUTPUT talkbacks are driven by the GPCs themselves, and it can play a *crew script* (`--script`) that throws switches, types keys and shows captions on a timetable, waiting on the talkbacks where it needs to.
- `stsKeyboard.py` &mdash; provides a simulation for the Shuttle keyboards used with the MEDS. Keys typed by a crew script are shown as if pressed.
- `cam.py` &mdash; provides a simulation of the Computer Annunciation Matrix (CAM), which shows which if any of the redundant GPCs in a multiple-GPC configuration have fallen out of sync with the others.
- `OI340700-OPS0.mmv` &mdash; a simulated magnetic tape for the Shuttle's Mass Memory Units (MMU), suitable for booting the simulation and running it. The tape has been abridged to contain only enough software to IPL OPS 0, i.e., the "system software" as opposed to any actual "application software". Nevertheless, it's enough to let you get a flavor of the process and to see various display screens.
- `simulatePASS.py` &mdash; a wrapper program to tie all of the above together so as to run the simulation. If you happen to have a non-abridged tape, you could run the entirety of the flight software (OPS 1, OPS 2, etc.). It handles 1 to 4 GPCs (`--gpcs`) and 1 to 4 CRTs (`--crts`); adding `--instructions` to a command line prints the switch-and-keyboard steps for that configuration (in the order of the PASS User's Guide) instead of running it, `--script` runs a crew script, and `--help` lists the rest.
- `crewscript.py` &mdash; checks crew scripts without running anything (`python3 crewscript.py FILE`); with `--help` it lists the commands a crew script may use. `examples/4gpc-startup.script` is an example that brings up four GPCs (it needs a non-abridged tape, since it goes on to OPS 2).
- `subtitles.py` &mdash; a caption box for making demonstration videos; crew scripts put text in it. Start it yourself, with the same `--port-base` as the simulation; its `--edit` option lets you type into it to settle on a size, position and font.
- HANDOFF-*.md &mdash; Information about these programs, as written by the A.I. agents that assisted me in creating or porting the programs.  A.I. agents Claude Code (primarily Sonnet 5) and Grok Build (Grok 4.6) assisted in coding, porting, and adapting. These files are for the purpose of bringing an A.I. agent up to speed if modifications to the programs are required, and probably aren't of direct use in a human sense.

The `MEDS2.py` program was adapted from a port of an adaptation of [Don Schmidt's `MEDS` simulation program](https://github.com/ColanderCombo/nsts-sim-gpc). (And yes, I said "adaptation" twice there.) The adaptation was originally made for pragmatic reasons involving delayed committing of program modifications, and once those delays were ironed out, the divergence was too large to easily merge `MEDS2` back into Don's `MEDS`. You may nevertheless find that `MEDS` can still be used here.  Or you can try using Don's tools in their entirety at the link given above.

All *other* programs were created from scratch here.
