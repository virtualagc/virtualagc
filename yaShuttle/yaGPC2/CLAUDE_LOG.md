# CLAUDE_LOG.md

Staging area for documentation updates.  Append timestamped entries as

    ### [YYYY-MM-DD] Target: [Filename.md]
    - note

and they are applied to their targets on the next "Full Documentation Sync".

For CAUSES INVESTIGATED and FIXES ATTEMPTED use `gpc-causes.py` instead --
that is a database with an `addr`/`search` front end, not prose, precisely
because this file records everything and recovers nothing.

### [2026-09-14] Target: HANDOFF-OI340700-BUILD.md
- Abridged volume: tools/abridge_volume.py VOLUME --con80 CON80 --drop-mc 1,3 -o OUT removes memory configurations from a built volume. MC rows are the flight table CZ2V_GRT_PHASES (OI340600/SSSRC/CZ2COMMO.hal, verified: MC1 3,4; MC2 3,5; MC3 3,6; MC4 14,15; MC5 14,16; MC6 9,12; MC8 3,7; MC9 3,8,18), cross-checked against CON80/MMUSYS1's MC= cards; a phase goes only if neither the IPL set nor a kept MC loads it, and its whole MMUDATn ALLOC goes (overlaps refused). Kept blocks are re-read and verified byte-identical. tapebuild/build.sh stage 8 writes $WORK/OI340700-v44boot-noOPS136.mmv (REF_ABRIDGED checks it). Result from v44boot: phases 4 (GMAGN1A1, "GNC ASCENT AND ABORT") and 6 (GMAGN3A1, "GNC ENTRY") removed, 1866 of 2665 blocks kept -> ~/workspace/pass-run/OI340700-v44boot-noOPS136.mmv. Verified: simulatePASS --gpcs 1,2 through OPS 2 on it (CRT1 UNIV PTG 1, CRT2 UNIV PTG 2; mmu1 127 commands / 1181 blocks read, identical to the full tape). Not supported: requesting OPS 1, 3 or 6 from it -- #PFCMGPT still describes phases 4/6, their blocks read as zeros and a zero load block passes its checksum. SM OPS 4 (phase 16) is absent from the full tape too.
