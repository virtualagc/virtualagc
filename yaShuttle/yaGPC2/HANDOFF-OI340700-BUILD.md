# Building OI340700 from source

Goal: a full, correct build of the OI340700 object files, per `PFS/BUILD.md`.
This is the object-file stage only.  Linking is deliberately out of scope --
`lnk101` needs Don's `build/lib/runtime/{RUN,ZCON}` and we may end up using his
runtime objects rather than the RTL we assemble; that is undecided.

## Where it stands

    assembly   761 of  761 objects      complete
    display     68 of   69 objects      CDAP15 outstanding
    HAL       1105 of 1126 objects      21 outstanding
    total     1955 objects, 22 missing, 105 files tombstoned

Progression, so each change's worth is visible:

    --csects                        145 missing
    --no-csects                      78
      + retry pass                   73
      + CSPCLB qualification         59
    --csects again                  126
      + 105 tombstones               22

## This is no longer the whole story -- see HANDOFF-OPS9.md

The counts above are the OBJECT-FILE stage as it stood when linking was out
of scope.  Linking is in scope now, a bootable volume exists, and the build
is automated end to end by `tapebuild/build.sh`:

    REF=~/workspace/pass-run/OI340700-v44boot.mmv \
        yaShuttle/yaGPC2/tapebuild/build.sh <workdir>

Its last stage (8) also writes `OI340700-v44boot-noOPS136.mmv`, the same
volume without GNC OPS 1, 3 and 6, via `tools/abridge_volume.py VOLUME
--con80 CON80 --drop-mc 1,3 -o OUT` (`REF_ABRIDGED=` checks it as `REF=`
checks the full one).  The tool takes memory-configuration rows from the
flight table `CZ2V_GRT_PHASES` (`OI340600/SSSRC/CZ2COMMO.hal`: MC1 3,4; MC2
3,5; MC3 3,6; MC4 14,15; MC5 14,16; MC6 9,12; MC8 3,7; MC9 3,8,18),
cross-checks them against `CON80/MMUSYS1`'s `MC=` cards, removes a phase only
if neither the IPL set nor a kept configuration loads it, drops that phase's
whole `MMUDATn` allocation (overlaps refused), and verifies every kept block
byte-identical.  From v44boot it removes phases 4 ("GNC ASCENT AND ABORT")
and 6 ("GNC ENTRY"), keeping 1866 of 2665 blocks
(`~/workspace/pass-run/OI340700-v44boot-noOPS136.mmv`); a two-GPC run reached
OPS 2 on it with mass memory 1 read exactly as on the full tape.  Requesting
OPS 1, 3 or 6 from it is not supported: `#PFCMGPT` still describes phases 4
and 6, their blocks read as zeros, and a zero load block passes its
checksum.  SM OPS 4 (phase 16) is absent from the full tape as well.

v44 is v43 plus ASM101S `6d418f3c6`, which changes only `BILDNEW5.obj`'s RLDs
and ten phase-10 halfwords.  `HANDOFF-OPS9.md` is that build's handoff -- its
sections 0-3 carry the stages, what pins each of them, and the deviations --
and this file remains useful for WHY the object stage is shaped as it is:
the tombstones, the 21 HAL failures, and the blind spots in the verification
method.

One finding worth carrying here rather than leaving it in OPS9: GPCIPL's
`>>> GPC POWER REFAIL -PROGRAM/MACHINE WERE R` is NOT a refail.  It is
message 132 printed with message 130's text.  See `gpc-causes.py show 84`.

## The recipe that produces that

Scratch tree at `/mnt/STORAGE/home/rburkey/pass-build/OI340700`, built by
copying OI340600's `APPLSRC SSSRC MLIB80 INCL80` plus PASS.REL32V0's
`RUNASM RUNMAC ZCONASM`, then overlaying OI340700's `APPLSRC SSSRC MLIB80`
(17 files: 13 sources + 4 macros).

    cd <scratch>/OI340700
    prepareTEMPLIB --clear                    # NOT --clean; BUILD.md says --clean, the tools take --clear
    prepareINCLIB --clear --include=INCL80
    rm -rf objects SDFLIB TEMPLIB archive.results; mkdir objects SDFLIB
    PATH=<PASS.REL32V0>:<ASM101S>:<dps>/build/bin:$PATH \
        compilePASS --no-csects --sdl --release=OI340700

`PATH` must carry PASS.REL32V0 (HALSFC, preprocessHALSFC), our ASM101S
directory (ASM101Sa), and Don's `build/bin` (dfg only).  Launch it with
`setsid nohup ... &` -- a foreground wrapper's timeout kills the process group
and takes the build with it.  About 15 minutes.

`--no-csects` is right ONLY because tombstones now do the removal; see below.

**`--sdl --release=OI340700` are not optional for a TAPE build**, and a plain
`compilePASS --no-csects` does not reproduce the objects the volume was built
from:

- Without `--sdl`, 160 PROGRAM objects gain a START csect, a stack prologue
  and stack ERs that the tape's objects do not have.
- Without `--release`, `CPUSLS` and `CPTOSV` get `CARDTYPE` ACBD instead of
  ACBC -- the B->D mapping discussed under "Open decision" below -- fail XI3,
  and eight phase-15 objects cascade away behind them.

With both, 1,981 of 1,981 objects match in loaded content.

Two things that must be pinned alongside them.  `dfg` must be the pinned
build (`HANDOFF-OPS9.md` stage 0b), not whatever is on `PATH`.  And
`compilePASS`'s own `dfg --release` probe was broken by `rich`'s ANSI styling
until 2026-09-10 -- it parsed the styled help text and concluded the option
was absent -- so a build from before that date silently omitted the release
even when it was asked for.

## What was added to compilePASS

`assemble()` runs **our** ASM101Sa with BUILD.md's options: `--library=RUNMAC`
for RUNASM/ and ZCONASM/, `--library=MLIB80` otherwise, `--tolerable=4`,
`--no-rtl-fixes`, `--fill=C6C6`.  C6C6 is the tape's padding convention;
validated against the earlier compileLinkCompare work in
`~/ForClaude/OI340600-clc-G9`, where our object reproduces theirs exactly bar
the END record (their `asm101` fabricates an entry point for a bare END -- a
known upstream bug with a PR in flight).  C6C6 gave 2 differing lines against
6 for C9FB and 6 for 0000.

`dfg()` runs Don's `dfg` to translate a deck to HAL/S, then compiles it with
**our** compiler.  A generation failure is recoverable and collected, not fatal.

Display decks are compilation units in the dependency graph: a deck names its
compools as `INCLUDE=NAME,` (underscores and all), and `dfg` needs their SDFs.

A retry pass sweeps units that produced no object until a pass gains nothing.
It is worth little -- 5 or 6 units -- because the failures are a cascade, not
independent ordering accidents.

Tombstones: a ZERO-LENGTH source means OI340700 removed the file.  The overlay
is applied by copying OI340700/ over OI340600/, so it can add and replace but
has no way to express a deletion; an empty file is that missing verb and is
skipped everywhere.

## Deriving the tombstone list -- TWO conditions, not one

    no CSECT in any of the 8 DASS configurations   -> 124 candidates
    AND not INCLUDEd by a file that IS in OI340700 ->  19 withheld
                                                      105 tombstoned

The 19 are compools with no storage, hence no CSECT, that surviving files still
need as templates: CSAPXT (used by six, including SBISM), PTVOSV/PDLIUS/PDSSEQ/
PMGGNC/PMRSLR/PMTSLG/PMWSLW (all by SSPEXEC), CPCGXT (by four), CSACAT CSADAR
CSAFCM CSAIFT CSAINB CSAIPT CSAIXP CSAPAR CSAPAT CSDINI.  Tombstoning those
breaks their consumers.

List saved at `<scratch>/../con80-rebuild/oi340700-removal-candidates.txt`.
**They exist only in the scratch tree; PFS is untouched.**  Creating them for
real in `PFS/OI340700/` is a decision for the user.

## The 21 remaining HAL failures are ONE root cause

    roots     CS2IXP CS2PX3 CS2PXT CSAPCT   DI11: reference OI340600-only payloads
              CS2PX2                        IS1, same family
              CPTOSV CPUSLS                 DI11 once their SM4 branch is off
    cascade   CS2IX2..7 CS2PCT CS2IFT CS2PAT PTVOSV SCOSPE SGCKIP SM2OPS SSPEXEC
              chain: PTVOSV <- CPTOSV, SSPEXEC <- PTVOSV, SM2OPS <- SSPEXEC

Every root is a compool that indexes payload IDs OI340700 does not carry.
`CS2PDT`'s payload set is DISJOINT between releases -- 262 entries against 50,
nothing in common; `CSAPDT` shares 756 of ~906 and swaps ~150 each way.  These
files need OI340700 reconstructions from their DASS structure listings, exactly
as CS2PDT and CSAPDT got.  They are all `#P` CSECTs present in the S2 dump
(`#PCS2IXP` 136 hw, `#PCS2PX3` 1028, `#PCSAPCT` 1179, `#PCS2PXT` 1030), so the
data to do it is there.

Open decision: `halsParms` gives CPUSLS and CPTOSV
`CARDTYPE=ACBDFCRMUDXCVMWCYCZM`, mapping B->D, which makes their type-B card
`INCLUDE TEMPLATE CS4_PDT` an ACTIVE directive.  OI340700 has no CS4PDT, so
that branch must be off (B->C).  Verified necessary but not sufficient: it
changes the error from `@@CS4PDT NOT IN INCLUDE LIBRARY` to a payload DI11.
The neighbouring type-F card (`MSP4 = SM4O`) is already commented, so the
branch is half-enabled as things stand.

## Why the verification method let these through

Three blind spots, all demonstrated, all worth remembering:

1. A NAME-ONLY change compiles to identical object code, so a binary compare
   cannot see it.  CS2IXP, CS2PX3, CS2PXT and CSAPCT each bumped one revision
   (BY->BZ, BW->BX, BW->BX, BX->BY) and matched byte for byte, so no
   reconstruction was ever attempted -- and they are precisely the files that
   now cannot compile.
2. A SECTION SHORTER THAN THE DUMP'S PASSES AS "ok".  `#PCSPCLB` is recorded
   `ours=134 expected=140 n_diffs=0 verdict=ok`.  The 6-halfword shortfall is
   exactly the padding the later reconstruction added.  `expected` is stored
   but takes no part in the verdict.
3. REVISION CODES WERE MAINTAINED BY HAND.  A bump means something changed; no
   bump means nothing either way.  SPSPSP is BP in both and demonstrably
   changed.

And the databases themselves: every run in `~/ForClaude/dass-compare-*.db` is
dated 2026-08-06/07, while `PFS/OI340700/` was created 2026-08-26.  So every
"match" there means "OI340600 source reproduces the OI340700 dump", NOT "the
reconstruction is verified".  Do not read them as validating OI340700/.

**The DASS report is the reliable oracle.**  `DASS_G9.ASC` names every member
and offset, and it settled the CSPCLB question outright:

    00A84E-00A850 #PCSPCLB+0060 CSPB_PI_UMB_RESET_BUF   (structure)
    00A84E-00A84F #PCSPCLB+0060 CSPB_PI_UMB_RESET_DUM   0.0
    00A850        #PCSPCLB+0062 CSPB_PI_UMB_RESET_MASK  01FF
    010D13 A6SPSPSP+000B EC92 00A850 LA R4,X'0024'(R2)  CSPB_PI_UMB_RESET_BUF+2

So the reconstruction's structure IS what OI340700 used, and SPSPSP reaches the
mask THROUGH it.  SPSPSP and SSOSPDAT therefore need OI340700 versions using
the qualified name.  Tested in the scratch tree and SPSPSP compiles; the
qualified reference ends at column 75 and overruns the SRN field at 73-80, so
each needs a continuation card -- a reconstruction decision about card layout
and SRNs, not a mechanical substitution.  **PFS is untouched.**

## Traps met

- `compilePASS` had an in-progress edit calling `parms.remove()` on the result
  of `getParms()`, which returns a STRING.  Repaired via the supported
  `options=` parameter.  (It was swept into a commit of mine by `git add`
  without checking `git diff` first -- do not repeat that.)
- Don's `halsc` supplies ONE global `CARDTYPE=UDVMWCXCYCZM` to every file,
  where `halsParms` has a per-file table whose baseline is `FCRMUDXCVMWCYCZM`.
  They differ on every one of the 1167 HAL sources.  Use `compilePASS`.
- 296 sources are `#`-named (all 286 in ZCONASM/, 3 in SSSRC/, 7 in MLIB80/).
  `#` opens a comment in sh.  Nothing here uses a shell; do not introduce one.
- `ASM101S.py` emits csects in Python `set` order and is not reproducible.
  `ASM101Sa` (the C port) is deterministic and canonically identical; use it.
  `objcanon.py` normalises either.
