# HANDOFF — FCMBOOT → GPCIPL → MEDS → PASS

Written to survive a `/compact`. Everything needed to resume is here. The
long-form narrative that was in `CLAUDE_LOG.md` has been folded into this
file and into `problems.md`; the log itself has since been cleared, so do not
go looking there for it.

---

## 1. The goal

Boot the real Shuttle IPL chain in yaGPC2, end to end:

    firmware IPL → FCMBOOT (bootstrap) → reads GPCIPL off the mass memory
                 → hands control to GPCIPL → GPCIPL drives the MEDS display
                 → ITEM 1 EXEC → the SSL loads PASS → PASS runs

PASS User's Guide (`~/Desktop/sandroid.org/public_html/apollo/Shuttle/PASS
USER GUIDE - OI32.pdf`) §2.3 and Table 2-2 (pages 49, 52, 53) describe the
sequence. Key facts established from it:

- **HALT** = hardware RESET held; no software runs. **STBY entered from
  HALT** releases reset and gives control to the Bootstrap Loader. The
  mode switch is a reset line, not a polled input — FCMBOOT never tests
  those bits.
- Table 2-2 step 10 (GPC IPL push/release) is the *firmware* IPL: it
  fills memory (C9FB 0-1FFFF, C6C6 20000-7FFFF) and reads the bootstrap
  in from the MMU.  **Both halves are now emulated** — omit the `fcm-file`
  and the IPL pushbutton reads FCMBOOT off the tape over the bus (§2, "The
  firmware IPL").  Giving a `fcm-file` still loads FCMBOOT from a file, and
  `--ipl` still does the fill either way.
- **Step 14 is the IPL SOURCE selector** (MM1 / OFF / MM2), and step 11 is
  the HALT→STBY release that actually starts FCMBOOT.  Keeping 10 and 11
  apart matters — see "Why reload is load-bearing" in §2.

---

## 2. WHERE IT STANDS RIGHT NOW

**The whole chain works.**  From a full boot with no `fcm-file` argument, the
firmware IPL reads FCMBOOT off the tape over the bus, FCMBOOT loads GPCIPL,
GPCIPL drives the display and accepts `ITEM 1 EXEC`, the SSL loads all three
PASS phases and verifies every checksum, and PASS starts its applications and
runs cyclically without halting.  Everything below is how each stage got there,
in the order it was fixed; "The SSL", "PASS runs" and "What is actually still
open" are the current-state parts.

**FCMBOOT loads GPCIPL and hands control to it.** Fixed 2026-08-25 in
`14a7b7581`. All five of phase 10's load blocks now match the tape
halfword for halfword (27,292 halfwords, none wrong), all five checksum
on the first attempt, and `LPS X'0014'` at 0x30239 loads `013F 0011` —
the vector off the tape — putting the machine at 0x0013F with BSR=DSR=1,
which is GPCIPL's `SRESINTN`. GPCIPL then runs.

What was wrong:
FCMBOOT skips the unread tail of a partial mass memory block by
*delaying* over it (`#DLYI`, `2*(639 - partial)` counts, built at
FCMBBLDR+0x25). The model queued whole transfers and never lost a word,
so the delay skipped nothing and every load block after the first landed
477–610 halfwords early. The same displacement had a second halfword in
it: a delay leaves one stale word latched in the MIA, which FCMBOOT
discards with a one-halfword `#RDLI` it labels "CLEAR THE MIA BUFFER"
(FCMBBLDR+0x18) — with nothing latched, that ate a live word. Now
`mmumodel.c` puts a word on the bus at its own word time with 256 word
times of gap between blocks, and `iop_bce_delay` throws away what goes
past while it runs, leaving the last one in the MIA.

Two things from the previous version of this section were simply wrong
and are recorded here so they are not re-derived:

- The "checksum pass and fail both hit" contradiction was not one.
  `FCMBCKSM` exits the whole loop on the first mismatch (0x034E, then
  `B #@LB74`), so one call hits 0x30352 once per *passing* block and
  0x3034E at most once. Both firing is the ordinary shape of "blocks
  1..n-1 passed, block n failed".
- The PSA zeros seen at the LPS came from a later, worse retry, not from
  the first load. LB1 was always byte-perfect, PSA included.

**GPCIPL then goes on to drive the display.** It runs its `MEMTST22`
memory sweep, cycles REALEXEC's `STMMAIN` job dispatcher, loads further
phases off the tape, sets `DCPLDFL`, reaches `POLL60`, IPLs the display
unit and drives the DK bus. Measured on the in-process DEU:
`commands 6648, fills 2224, displayFills 518, formatFills 8,
timeFills 512, headerless 0, ipled true`.

Two more emulator bugs were fixed to get there, both in the bus model and
both found by adding a counter rather than by reading code:

- **The MIA latch queued ahead of live traffic** (`82fb09d3b`). The latch
  added with the delay-discard was handed over before anything newer.
  FCMBOOT's LAST load block ends in a delay like the others, but the
  "CLEAR THE MIA BUFFER" `#RDLI` is only emitted *ahead of* a block that
  followed one, so the word survived into GPCIPL's first BITE STATUS and
  shifted every later reply by one. GPCIPL stored the POSITION reply
  (0x14A0) where status belonged; its own mask is `X'F800FFFF'`, so BSL1
  called ERROR 118 "MMU ERROR" and reset. Found by `wordsOut` vs
  `wordsTaken`: 28182 against 28181.
- **A transfer's unread tail was never dropped** (`629694ebf`). GPCIPL's
  loader left 360 unread words of a 4096-word transfer, so every later
  reply was 360 words late and BSL1 called ERROR 116 INVALID POSITION.
  Now a new command ends the last transfer and its unread stream goes,
  plus a block-gap-grace ageing rule for a stream nothing follows. **Only
  STREAMED words are ever dropped** — a reply is not paced and never ages
  out, and the timing rule alone left two orphaned status words at the
  head of the queue forever. Found by printing `pending` at each command.

### IT WORKS END TO END — user-confirmed on screen, 2026-08-25

Booting our own `BOOT-stamped.fcm` from our own `mmu2.mmv`, GPCIPL drives
MEDS and the display renders correctly.  Wire traffic in 45 s:

    POLL 87, TIME_FILL 88, DISPLAY_FILL 87, FORMAT_FILL 7

which matches Don's reference `IPL.fcm` (87 DISPLAY_FILL in 45 s) exactly.

**A retracted claim, recorded so it is not believed again.**  An earlier
version of this section said our tape was deficient, on a measurement of
4 DISPLAY_FILL against the reference's 87.  That was wrong: the two runs
used DIFFERENT PACING FLAGS.  The CLI's default is `--pacing=burst
--time-scale 1.0`; the reference used `--real-time --rt-factor 1`.  Those
are different mechanisms and produce very different emulated-time rates,
so the comparison measured the flags, not the software.  With identical
flags the two images agree.  `--deu-model` had already said so --
displayFills 518 against 690 -- and I did not believe the instrument.

Likewise `BSLRESET` being reached is NOT a failure: `BSLRQP15` is the
SUCCESS path ("SHW LOADFLAG  SET GOOD COMPLETION FLAG" / "BAL R5,BSLRESET
GO RESET FLAGS").  Two dead ends in one day from the same habit -- change
one variable at a time, and check whether the thing you are calling an
error is on the error path at all.

### The on-tape format, from FCMBOOT's own header

Fully specified in `FCMBOOT.asm`'s header, and worth having here rather than
re-derived: **3-halfword phase descriptors** (index to 1st load block, number
of load blocks, MM address of 1st LB) for phases 10/2/13/3, and **3-halfword
load-block descriptors** (MM address; protect/reserve/sector flags; length in
halfwords).  The table lives in CSECT `FCMSSLPT`, which is `DC 768H'0'` —
reserved space the Mass Memory Build stamps over, so in our image it is all
zeros and `tools/stamp_ipl_phase_table.py` builds it.

The cards are in the corpus: `CON80/MMUDAT*`, `MMUSYS*`, `MMLOAD`.  `MMLOAD`
carries `IPL,PH=(10,2,13,3)` — exactly the phase set FCMBOOT's header names —
and `FMAIPL2 COPY,IPL; ALLOC,ADDR=44500,BLKS=72` is the bootstrap's own tape
allocation, with the MM directory at 44000.  `nsts-sdl-dps/src/tools/mmu2mmv.py`
writes a `.mmv` volume in the geometry the MMU model uses (8 files × 8 tracks ×
8 subfiles × 32 blocks × 512 halfwords, header plus block-index directory, and
a writeProtect flag matching `mmu create --write-protect`).

**The IOP microcode that loads FCMBOOT off the tape at IPL initiation is now
emulated.**  An earlier version of this section said nothing did, and called
that "by design rather than a gap", adding that `--power-on` was what FCMBOOT's
"RECEIVES CONTROL FROM THE MICRO CODE LOADER VIA THE SYSTEM RESET PSW" meant.
**Both halves of that were wrong** and are corrected in "The firmware IPL"
below: `--power-on` takes the **power-on** vector at 0x04, where FCMBOOT
deliberately parks in a wait state, and the microcode loader uses the **system
reset** vector at 0x14.  The address table in §3 always said so.  `--ipl` still
does cold-IPL memory init (fill and protect, §2.5.3.3), and loading a `.fcm`
from a file still works exactly as before — what is new is that omitting the
file makes the firmware fetch the bootstrap off the mass memory instead.

### The firmware IPL — booting with no `.fcm` at all

`gpc run` no longer requires an `fcm-file`.  **Omit it and the GPC IPL
pushbutton reads FCMBOOT off the mass memory**, exactly as Table 2-2 step 10
has the firmware do, and the HALT→STBY release runs it.  With an `fcm-file`
present nothing changes at all.  Requires `--discretes` and either
`--mmu-model` or `--bce-network`.

**Which vector: always the system reset PSW at 0x14**, on the first release
and on every later one.  `FCMBOOT.asm:38` says so outright ("RECEIVES CONTROL
FROM THE MICRO CODE LOADER VIA THE SYSTEM RESET PSW"), and the image agrees,
measured on `BOOT-stamped.fcm` itself — `0x0004` holds `0000 0000 0002 0000`,
address 0 with the WAIT bit, a deliberate park, while `0x0014` holds
`014B 0066 0008 0000`, FCMBMOVR in sector 6 with register set 1.

**IPL is not a mode-switch position.**  It is a separate momentary pushbutton
(register A bit 3) live **only** while HALT stands, so its bit rides *on top
of* HALT's rather than excluding it.  `discretePanel.py` had it as a fourth
radio position, which cannot express the real sequence; it is now a real
pushbutton, disabled out of HALT, and the IPL source selector is MM1 / OFF /
MM2 per Table 2-2 step 14.

**It goes over the bus, through the installed servicer** — not by reading the
volume.  Two user corrections, both right: reading the volume directly models
a wire that does not exist (the MMU is a separate box and the bus is the only
path to it), and calling `mmumodel_service()` directly would have worked with
exactly one MMU — ours — when Don's lives on the far end of `--bce-network`.
It now issues POSITION / EXTENDED BLOCK / READ and drains the reply queue
through `iop.servicer`, with the bus picked by the panel's IPL-source bits
(MM1 = BCE 18, MM2 = BCE 19).

**That is also what fixed the READY indicator**, which is the symptom that
exposed the first version.  Bypassing the bus left MM READY undisturbed, so a
load gave the crew panel no sign of itself.  Draining the real queue makes
READY fall and rise on its own, because it is derived from that queue.  A
synthetic busy-timer written for this is gone again — it was treating the
symptom.  **And the transfer is paced to real time**, a block at a time:
drained flat out it dropped READY for ~20 ms against a panel that republishes
every 250 ms, i.e. invisibly.  It is now 1.80 s, measured on the wire (READY
low 3.44 → 5.23 s), matching 72×512 + 71×256 = 55,040 word times at 33 µs.
`--time-scale` still shortens it.

**The tape did not carry the bootstrap**, which is why this could not simply
be written.  CON80's `MMUDAT1` allocates it — `FMAIPL2 ALLOC,ADDR=44500,
BLKS=72` — and **a CON80 card address is FTSBB**, file/track/subfile/block, so
44500 is file 4 / track 4 / subfile 5 / block 0.  (I had TFSBB in the tool and
in `run.c`; the phase manifest settles it — card 43000 is 3/4/0/0, and it is
the only reading under which all 1,085 blocks of a built volume are accounted
for, checked over all 24 permutations.  The bootstrap's own 44500 is unaffected,
file and track both being 4, but the comments were wrong.)
`tools/stamp_bootstrap_on_tape.py` writes one there, **padding the whole
72-block allocation** with the `C6C6` the `FMAIPL2 ALLOC`'s own `INIT=` names:
a bus reader asks for a fixed block count and cannot be told which blocks were
ever recorded — an unrecorded one simply reads back as zeros — so the earlier
"stop at the first unrecorded block" trick was only possible through the back
door that has now been removed.

**Why reload is load-bearing, not housekeeping.**  FCMBOOT's External Zero
handler does `OST R5,FCMBSYRS+2`, setting the WAIT bit in its own system reset
PSW.  An already-booted in-memory FCMBOOT therefore **parks** on the next
release; re-execution works only because a fresh IPL puts a pristine copy
back.  That is what makes keeping step 10 and step 11 apart matter.

**Verified end to end.**  An isolated test issuing that exact command sequence
against the model collects all 36,864 halfwords and matches `BOOT-stamped.fcm`
**byte for byte** over its 32,512, with `C6C6` in the tail.  With no
`fcm-file`, panel HALT → HALT+IPL → STBY: "IPL; read from MM1 (BCE 18) over the
bus (72 blocks, 36864 halfwords)" then "HALT → STBY; reset released, starting
at 0x0014b" — FCMBMOVR.  The distinct SVC NIAs reached (1b57, 1cda, 1f35, 2122,
29a6) are **identical** to the canonical `--ipl BOOT-stamped.fcm` run, so the
tape-loaded boot and the file-loaded one behave the same.  A second IPL reloads
and re-runs; IPL pressed in STBY is refused.  `~/ipl-demo/mmu2-boot.mmv` is the
tape, re-stamped to the full allocation (1,157 blocks); `mmu2.mmv` beside it is
untouched and carries no bootstrap.

### What actually reaches the display unit — a retracted claim

**RETRACTED: "the Display Control Program came off our tape and went into
the display unit."**  That was inferred from `DCPLDFL` being set and from
`deumodel` printing "load complete", and neither of those inspects content.
`DCPLDFL` is a flag BSL1 sets when its transaction finishes, with real data
or without.  The user challenged it and was right.

Measured instead: `#PCVNMMU` / module `DEUIPLCP` in PHASE03, 16393 halfwords,
"DEU IPL Control Program" — **all zeros in our build**.  Verified by reading
`PHASE03.fcm` flat, with `imageSize 302702` equal to the file's halfword count
and `#PCGMCOM` in the same file reading 199 distinct values, so the method is
sound.  We have no display-unit software and cannot build any: it is a binary
COMPOOL blob for a different CPU.

**So why does anything render?**  The 717 non-zero words that do reach the
display unit are FCW display content from GPCIPL's own *assembly* screens —
`MENU12.asm`, `PCH10TXT` — which emit FCWs directly (`FCW2 ANCTL2=1`,
`POS (P2,P25)`, `DC H'0'  ASTERISK FCW`).  No `.dfg`/`.hal` display format is
involved in the IPL's screens, which is why they render with no DFG
preprocessor at all.  MEDS's MDU implements the FCW protocol natively in JS
("The DPS display implements the original DEU FCW protocol generated by
shuttle software" — Don's README), so no DEU/IDP software is needed.

Per the user, the two units are different machines: the pre-2000 MCDS unit is
an SP-0 DEU with 8K×16 RAM (hence `DEU_MEMORY_WORDS 8192`), and the post-2000
MEDS unit is a 386DX IDP running DAS.  **Our `deumodel` models the DEU; MEDS
models the IDP.**

**Method note.**  My first DEU-image measurement ran *before* the store loop
and read all-zeros regardless of what was there.  Check where a probe sits
relative to the write it is measuring.

### PASS display formats — where they live

Surveyed while chasing the above, and useful context rather than IPL work:
OI340600 holds **133 `.dfg` formats** (116 in `APPLSRC`, 17 in `SSSRC`) and
not one of them exists as `.hal` in that release.  126 have an OI301700 `.hal`
counterpart; 7 have none anywhere (`CG0540`, `CG0543`, `CG1031`, `CG6011`,
`XG0540`, `XG0543`, `XG1031`).  OI301700 has **zero** `.dfg` — every format
there is already `.hal`.

An OI301700 `.hal` *is* DFG output and says so in its own header
(`DFG VERSION: 30.40 / DDT ENTRIES: 428 / PAD HALFWORDS: 0 / STATIC FCWS(BUILT
BY DFG): 2 / ...`), and it **embeds its own DFG input** as `C`-prefixed comment
lines under a `**** DFG INPUT ****` banner — so a `.dfg` we hold can be compared
directly against the input its `.hal` was generated from.  Normalising (strip
the leading `C`, take columns 1–72 only since the sequence field differs per
file, drop the Virtual AGC `C/` banner from both, strip trailing continuation
commas, drop DFG's own `****`-prefixed output annotations), 85 of the 133 are
**identical**, 17 near (≥0.98), 24 genuinely different, 7 absent.

This corrected a dismissal of mine.  I had said substituting OI301700 `.hal`
for OI340600 `.dfg` was unsound because the releases would have drifted; the
user said the `.hal` files are provably what DFG would have generated, and the
embedded input proves it per-file.

**One structural fact that kills a suggestion of mine:** OI301700 cannot be
phase-built.  `CON80`/`PDTIN`/`PSFIN` are 0/0/0 there against 194/40/178 in
OI340600, and `OI340600/CON80/PHASE10` is the phase-membership definition.
Its 1544 `.hal` files are compilable modules with nothing saying how they group
into phases or lay out on a tape.

**Status note.**  This was written when DFG was still future work and the 85
identical formats were described as a corpus "for when DFG lands".  It has
since landed and is in use — see `problems.md` for the DFG phase and the DASS
comparison it now feeds.

### The SSL — why `ITEM 1` loaded nothing, and how it was finished

Step 12 of the IPL sequence is "select the system to be loaded" (`ITEM 1 EXEC`)
and step 13 is GPC MODE SWITCH to RUN.  The user reported the item being
**accepted** — an asterisk appears beside it — with nothing loading and GPCIPL
simply carrying on.  Pressing it twice changed nothing.

**The chain** is `CM4KYBD` (items 1–17) → `LOADCHCK` (minor cycle 1) →
`SSLCHECK` (minor cycles 2–11, 24) → `FCMINSSL`.  `LOADCHCK`'s own description
states a precondition that looked like the answer and was not:

    IF THE DEU IS NOT SELECTED OR THE DEU FORMATS HAVE NOT BEEN SENT
    THEN SCHEDULE 'CM4FMAT' TO SEND THE OFT CRITICAL FORMATS (MM AREA 1)
    TO THE DEU AND EXIT.

**Breakpoints settled it, not reasoning about that branch**: `LOADCHK 0x2c8b`
HIT, `SSLCHECK 0x2d10` HIT, `CM4FMAT 0x271f` **not** hit, `FCMINSSL 0x6fbc`
**not** hit — and the last mass-memory command of a whole run is at t=13.7 s
against a keypress at t=97.2 s, ninety-nine seconds of silence after `ITEM 1`.
So the `CM4FMAT` branch is not being taken at all and the failure is in
`SSLCHECK`.

**Root cause: `SSLENGTH` and `SSLCKSUM` are zero, and a zero length hangs the
check rather than failing it.**  `SSLCHECK`'s `BCT R3,SSL30` decrements
*before* testing, so a count of 0 underflows and the checksum loop never
terminates — measured deterministically, `SSL30` HIT and `SSL60`, the
instruction after the `BCT`, **NEVER**.  The comparison is not reached at all,
so `SSL70` — the path that master-resets and hands control to the loader —
cannot be taken.  It is not that the checksum mismatches.

They are zero because **the checksum is a build product our reconstruction does
not produce.**  `FCMCKSUM.asm`: "FCMCKSUM WILL CONTAIN THE LENGTH OF THE SSL
AND ITS ASSOCIATED CHECKSUM.  THE CHECKSUM WILL BE GENERATED BY THE MASS MEMORY
BUILD PROGRAM.  ALSO, THIS DATA CSECT MUST BE THE LAST CSECT IN PHASE ONE."
Declared `DC H'0'` and filled in when the phase is written to tape.
`tools/stamp_ssl_checksum.py` stamps them, and the chain then completes —
`SSL30`, `SSL60`, `SSL70`, `FCMINSSL` all HIT — and the load actually happens:

    BITE STATUS / POSITION 3/4/0 / EXTENDED BLOCK / READ
    mmu1: read 154 block(s) from 3/4/0/0     <- PASS area 1 phase 2

That read had never occurred on any earlier run, ever.

**The span is `SSLSTART..SSLEND`, 806 halfwords**, from the link's own `SSLEND`
equ at `0x72E2` — not `SSLSTART..FCMCKSUM` (988), which was tried first.
`SSLEND` **is** `FCMDATA`, the same address, so the sum covers code and
constants and excludes the dynamic work area; that is the principled reason,
and it is the same fact that explains why `FCMIBLK1` is scratch (see
`problems.md` §8.14).  **Caution for anyone revisiting: the checksum cannot
validate its own span**, because the value is computed *from* the span, so any
choice is self-consistent and will pass.  Only a real MMB-built tape would
settle it.

**Where it stands now — the SSL work is FINISHED.**  With the SSL checksum
stamped, `#BU@` and `#LBR@` indirecting, the AP-101S addressing rules corrected
and four load blocks restored that the tape build had been dropping, the SSL
loads all three phases, verifies every checksum and hands off to PASS. The
narrative is in `problems.md` §8.16–§8.26; the short form is:

- The `FCMMOVE` alignment conflict that used to be "the open front" was the
  **wrong manual**. The AP-101 C/M masks bit 15 for fullword operands; the
  AP-101S explicitly does not, and `ISPB`'s fullword forms changed with it
  (`problems.md` §8.16).
- Four things the ground Mass Memory Build writes and our toolchain did not:
  PASS's own PSA CSECT `FCMPSA` (dropped by `derive_load_blocks`' pool-cursor
  test, and the single cause of `0009c` staying protected, `TPSASINP` holding
  GPCIPL's `Y(EX4)`, every PSA vector keeping GPCIPL's addresses, and the
  `0xc6c6 at 0x0a3b` crash); reserved load blocks (`FCMRESRV`, `X'2000'` —
  descriptor only, no tape data, still walked by `FCMUPROT`); phase 2's own Z1
  ZCON pool; and `parent_pool_lo` reaching only one of three callers
  (`problems.md` §8.19).
- The IOP is now paced by **simulated time**, one slice per 0.5 µs with each
  slice back-dated to the time it falls at, rather than one slice per CPU
  instruction — which is what stopped a 7,654-halfword `MVH` freezing the bus
  for 6.7 ms and stealing a word from the next block (`problems.md` §8.20).
- Three context-switch defects that only running PASS could find: RS extended
  form with B2=11 (the displacement **is** the effective address), `BAL`/`SCAL`
  saving the callee's BSR/DSR instead of the caller's, and `SVC` not saving the
  EA's 4-bit extension — the last of which was itself only half right until
  2026-08-31 (`problems.md` §8.23 and §8.26).

**The volume recipe is FIVE steps, not two**, and the two that were being
omitted each produced a bit-identical *wrong* answer rather than an error:

    1. mmu2mmv --con80 <CON80> --mmu <tree> --out V.mmv
    2. stamp_ipl_phase_table.py <tree>/PHASE01/PHASE01.fcm --mmu <tree>
       --con80 <CON80> --sdl <dps> -o BOOT.fcm      <-- easy to miss
    3. stamp_ssl_checksum.py V.mmv                  <-- easy to miss
    4. stamp_bootstrap_on_tape.py V.mmv BOOT.fcm
    5. add_sysid_allocs.py V.mmv --con80 <CON80> --sysid SYS8

`stamp_ipl_phase_table.py` needs `--sym`, and the image to stamp is
`<tree>/PHASE01/PHASE01.fcm` with `PHASE01.sym.json` beside it. `BOOT-*.fcm` is
**not** `PHASEnn.fcm` even though the sizes match — it is a *stamped* PHASE01.
Both stamping tools' docstrings name the exact symptom of omitting them; read
them before chasing a boot that reads no tape.

### PASS runs — and what that took

PASS IPLs from a full boot with no `fcm-file` argument, loads, starts its
applications, paints a display, and runs cyclically without halting. Getting
there needed, besides the SSL work above, four peripheral fixes:

- `710ae8dd2` — warn when `--bce-network` is given without `--real-time`.
  **`--bce-network` requires `--real-time`**; without it the wire is paced on
  wall time while the BCE times out on emulated time, so a poll queued behind a
  511-word fill always times out and the DEU load restarts forever. Its own
  help said so; every run in a long thread omitted it.
- `d7cda7736` — map the intercomputer bus (BCE 24) by GPC identity
  (`--gpc-id`), which selecting PFS needs.
- `38e2fcd6d` — an in-process mass memory must assert its own MM READY
  discrete. This is what blocked `ITEM 1 EXEC`: `BSRDYDI` spun waiting for
  `X'0200'` and was heading for `ERROR 115 MMU WILL NOT GO READY`.
- `2331c5e3e` — the MTU reply is **seven** words, not six (the Count Field is
  one less than the transfer).

Then one line in `exec_SVC`: the EA's saved extension is bits **15-18**, not
16-19, because a sector is `0x8000` halfwords and `FPMSVC` feeds the nibble
back as a DSE that expands by `<< 15`. Taken from bit 16 it arrives halved, so
every SVC from sector 2 or above — 6,387 of 33,961 in one run, all of PASS's
applications — handed FCOS a parameter-list address several sectors low. One
resulting phantom I/O request wedged four BCEs busy for good and leaked the
IOQE pool at one entry per second until PASS went idle 26 s in. Fixed
2026-08-31; PASS now runs past t=316 s with a full pool and Clock 2 alive
(`problems.md` §8.26).

### What is actually still open

- `make test` fails four suites: `test/test_debugger.sh`,
  `test_cpu_instr_exec`, `test_iop_bce_exec`, `test_iop_msc_exec`.  They fail
  identically with the whole tree stashed, so they predate all of this, but
  they are real and nobody has looked at them.  Note the fixture counts have
  since moved for principled reasons — the AP-101S addressing corrections, the
  RS `B2=11` rule and the SVC EA-High field each cost `gpc`-derived fixtures
  that encode the behaviour those changes deliberately reject (`problems.md`
  §8.16, §8.23, §8.26).  They are an accepted divergence, not a regression, and
  they are individually justified where they occur.
- **Two `mmbstamp` questions, both build-side and both stated in
  `problems.md`.**  (1) `mmbstamp`'s `deck_protection()` and `lnk101`'s
  `placement.protected` disagree about what the deck's `SET`/`CLEAR` says — 110
  sections and 11,947 halfwords, in both directions — and one of the two
  readers is wrong.  That must be settled *before* `protection_lookup()` is
  switched to read `sym["storeProtect"]["ranges"]`, or the assembler's future
  `PROT` data will arrive on top of an already-divergent base (§8.21).  (2)
  `parent_pool_lo` should be computed inside `derive_load_blocks` from the
  parent LIB rather than passed by each caller; making it the caller's
  responsibility is what let two of three callers drift (§8.19).
- **`SPON`/`SPOFF` in `ASM101S.py`** is designed and agreed but not written.
  The format is Don's control card (`" PROT <csect> <s>-<e>,..."`,
  CSECT-relative halfword offsets, hex, end-exclusive, listing the protected
  regions), the switches are `--no-store-protect` and
  `--protect-default=on|off`, no diagnostics are emitted on unbalanced
  brackets, and the acceptance criterion is that sweeping both releases with
  `--no-store-protect --protect-default=off` reproduces the stored objects bit
  for bit.  `lnk101` needs no changes — Don pre-wired the consumer side in
  `7fff229`.  (§8.21)
- **The three `nsts-sdl-dps` fixes are local and uncommitted**, by the user's
  instruction: `parent_pool_lo` in `src/ap101Utils/mmbstamp.py`,
  `src/ap101Utils/fcmImage.py` and `src/tools/mmu2mmv.py`, plus
  `LoadBlock.reserved` in `mmbstamp.py`.  Verified present on HEAD `755a372`.
  Anything that pulls or resets that repo loses them.
- **The `MVH` DSE fix has no fixture coverage.**  `exec_MVH` ignored the
  destination's DSE entirely (AP-101S §9.4: with bit 0 of R1 zero the address
  concatenates the **DSE register**, not an implied sector 0), and every suite
  passed unchanged before and after — they do not exercise `MVH` with a nonzero
  DSE at all, consistent with `gpc` carrying the same gap.
- **The PCMMU is identified but not modelled**, deliberately: BCE 24, IUA 13, a
  3-word reply in MTU format.  Two details are unmeasured and would have to be
  guessed (§8.25).  Note the `SEND ERROR$(6:6)` that motivated it was an
  artifact of the `--no-halucp-svc` regression and is not a live symptom.
- **The MTU wire format is not in any document we have.**  USA005350 §2.6
  confirms three accumulators on FC1/FC2/FC3 preparing GMT *and MET*, which may
  well mean the transfer is 3+3 rather than the shape `mtumodel.c` assumes.
- **PASS's software clock defaults to 24 hours**, because `FPMMTURM.asm:457`
  discards any GMT under 48 half-hours, and `--mtu-model` counts from zero at
  power-on.  Two corrections were tried and both reverted (§8.25).  It is real,
  it is the flight software's own rule, and it is *not* what stopped PASS.
- **A shared-contract defect with yaHALMAT2**: `yaGpcIntegration.h:131`
  encodes `GPC_ENGINE_WARNING_HAL_S_ERROR_BASE + lastErrNum` only, dropping the
  error *group*, so an integrator asking `gpc_engine_status_message(1006)` gets
  group 4's text for a group 6 error.  `yaHALMAT2/src/yaGpcEngineStatus.c`
  carries the identical table.  Needs a relay before either side changes the
  enum.
- **We never consult a mask for program checks.**  `cpu_check_interrupts` takes
  `intPending.programCheck` unconditionally, so Fixed Point Overflow, FP
  Underflow and Significance are delivered even when their mask bits say
  otherwise.  Nothing in this boot depends on it.
- **`ISPB`'s fullword forms are an unresolved conflict**, gated as
  `YAGPC_ISPB_ALIGN=1` and not the default; aligning breaks the boot.  A
  sector's last fullword is reachable from the observed `x7ffd` under *neither*
  reading, which is why it is logged rather than decided (§8.16).
- **CSECT placement fidelity is not complete.**  PHASE02 reaches 98.79% against
  the flown article with `--external-syms` (PHASE02 only, `#Z*` dropped,
  `--resolve-phases` afterwards); the remaining gap is the autocall
  program-placement order, which needs `linkorder.json`'s `orphanFlush` /
  per-`mc` `codeOrder` / `streams` and cannot be derived from an address sort
  (§8.22).  Pinning is **fidelity, not function** — it has never changed
  behaviour.
- **The 8K DEU program image at `DCPSTART` (`0xA000`) is all zeros** in every
  load: the harness bootstrap covers only `0x0000-0x8FFF`.  Display fills carry
  real text regardless, so it is not blocking, but it is wrong.
- **`--watch` misattributes a store to the following instruction** (it reported
  `LHI 1,X'3610'` as changing memory).
- **The GUI panel's IPL button is still untested by me** — no display here.
  `--script` exercises the same code path headlessly, but somebody should
  actually press it.

---

## 3. HOW TO RUN THINGS

Paths (scratchpad, session-specific — recreate if gone, see §5):

    SP=/tmp/claude-1000/-mnt-STORAGE-home-rburkey-git-virtualagc-yaShuttle-yaGPC2/187b3ac5-a4ae-459c-9827-61f2ad3aa645/scratchpad

| artifact | path | what |
|---|---|---|
| FCMBOOT image, stamped | `$SP/boot/BOOT-stamped.fcm` | PHASE01 + IPL phase table. **Use this one.** |
| FCMBOOT image, raw | `$SP/boot/real/BOOT.fcm` | before stamping |
| its symbols | `$SP/boot/real/BOOT.sym.json` | FCMPTAD1/2/3 = 894/1150/1406 |
| FCMBOOT listing | `$SP/boot/real/FCMBOOT.log` | ASM101S listing — **the reference for addresses** |
| tape | `$SP/tape/mmu2.mmv` | 1085 blocks, GPCIPL at 2/4/3/0 |
| composed IPL image | `$SP/donroute/IPL/IPL.fcm` | 1 MB, 6 bytes from Don's reference |
| phase libs (25) | `$SP/phase_build/OI340600/PHASEnn.lib` | **top level**; sym.json is in `PHASEnn/` |

**The canonical run** (deterministic, no sockets):

    ./yaGPC2 run --ipl --mmu-model $SP/tape/mmu2.mmv --deu-model \
        --max-steps 40000000 $SP/boot/BOOT-stamped.fcm

**THE DETERMINISTIC HARNESS FOR THE SSL**, and the single most useful thing
built this week.  Two runs are byte-identical — no crew panel, no `gpcmd`, no
`--real-time`:

    ./yaGPC2 run --ipl --deu-model --mmu-model $SP/tape/mmu2.mmv \
        --discrete-b 20000000 --max-steps N [--break=ADDR] \
        $SP/boot/BOOT-stamped.fcm

`--discrete-b 20000000` is GPC 1 with **no CRT selected**, and it is what makes
the **non-menu** path reachable: per Table 2-2, without step 6 (BFC CRT display
switch ON) there is no menu at all — the SSL loads PASS area 1 phase 2 by
itself and goes straight to step 13.  So the whole load question can be studied
with no keyboard entry and no MEDS.  `--discrete-a`/`--discrete-b` are new and
set the discrete input words directly.

**The firmware IPL, with no `.fcm` at all** (needs a crew panel, since the IPL
pushbutton is what starts it):

    python3 yaShuttle/discretePanel/discretePanel.py
    ./yaGPC2 run --discretes --mmu-model ~/ipl-demo/mmu2-boot.mmv --deu-model \
        --max-steps 0

Then: MODE SWITCH to HALT, IPL SOURCE to MM1, press IPL, MODE SWITCH to STBY.
Note the **tape must carry the bootstrap** — `mmu2-boot.mmv`, not `mmu2.mmv` —
see "The firmware IPL" in §2.

**Against the real MEDS display, the run that WORKS.**  Restart MEDS
first, every time (§5.7), and use these pacing flags -- the CLI's default
burst pacing gives a twentieth of the display traffic and a nearly blank
screen:

    $SP/launch_meds.sh --size 512 crt1 idp1        # 512 = half size
    python3 yaShuttle/discretePanel/discretePanel.py
    ./yaGPC2 run --ipl --discretes --bce-network \
        --mmu-model $SP/tape/mmu2.mmv --real-time --rt-factor 1 \
        --max-steps 0 --rt-idle-timeout 900 --verbose \
        $SP/boot/BOOT-stamped.fcm

Then move the crew panel's GPC MODE SWITCH from HALT to STBY.

**The KNOWN-GOOD reference**, which renders properly (user-confirmed
2026-08-25).  Note `--mmu-model` is required even though IPL.fcm holds the
whole composed image, and `--power-on` rather than `--ipl`:

    ./yaGPC2 run --power-on --discretes --bce-network \
        --mmu-model $SP/tape/mmu2.mmv --real-time --rt-factor 1 \
        --max-steps 0 --rt-idle-timeout 900 ~/Desktop/IPL/IPL.fcm

To see what is actually reaching the display, count the wire traffic by
function code -- `$SP/dk5.py <seconds>` does it, and the numbers to beat
are the reference's 87 DISPLAY_FILL in 45 s.  Time-scale note: the CLI
paces to REAL TIME by default, so use `--time-scale 200` or more for
investigation runs; it changes only wall-clock sleeping, never the
emulated clock the MMU pacing depends on.

Add `--break <hexaddr>`, `--watch <hexaddr>`, `--verbose` (register dump at
stop), `--trace` (~100 bytes/step), or `--debug` with commands piped on
stdin: `printf 'b 0x30239\nc\nr\nx 0x14 4\nq\n' | ./yaGPC2 run ...`

Env traces: `YAGPC_INTTRACE=1` (interrupt dispatches — invaluable),
`YAGPC_PROTTRACE=1` (protection violations, **with the faulting address as
well as the NIA**), `YAGPC_MMUTRACE=1`, `YAGPC_DISCRETETRACE=1`,
`YAGPC_CLKTRACE=1`.  Added while chasing the SSL: `YAGPC_MODETRACE=1`
(driven/value/mode/prev on every mode change — this is what separated the two
causes of the mode-flapping report), `YAGPC_ALIGNTRACE=1` (every address the
fullword alignment mask actually changes — 185 lines for a whole boot, so it
is cheap to leave on), `YAGPC_DSETRACE=1`, `YAGPC_PCTRACE=1`, and
`YAGPC_DISPTRACE=1` (prints `DISP LOADMSCBUSY` every time the CPU starts the
MSC).  **`INTTRACE` plus `PROTTRACE` turned a "wild branch" into a one-line
diagnosis** and should be the first thing reached for.

### Addresses you will need

FCMBOOT relocates itself to **sector 6**, so its runtime addresses are
`0x30000 + offset`. Breakpoints take the **full** address (0x30239), but
the hit message prints only 4 hex digits ("breakpoint at 0x0239").

| addr | what |
|---|---|
| 0x0014 | PSA system-reset vector; FCMBOOT's own = 014B → FCMBMOVR |
| 0x0004 | PSA power-on vector; FCMBOOT parks here (wait-state bit) — **`--power-on` is wrong for FCMBOOT, use `--ipl`** |
| 0x3014B | FCMBMOVR, where `--ipl` starts it |
| 0x30180 | FCMBSTRT, after relocation to sector 6 |
| 0x30199 | FCMBSSM2 "NO MASS MEMORY" wait |
| 0x3019d | "SAVE THE BCE NUMBER" — a mass memory was selected |
| 0x3021E | FCMBSSM3, "tried all three areas" give-up wait |
| 0x3023E | `@SIO` — starts the MSC, i.e. talks to the MMU |
| 0x30332 | checksum loop entry (R6 = LBs left) |
| 0x3034E | `ZH FCMBGRD` — checksum FAILED |
| 0x30352 | checksum PASSED |
| 0x30239 | `LPS X'0014'` — the handover. Loads 013F/0011 → GPCIPL. |
| 0x0013F | GPCIPL `SRESINTN`, where control lands (BSR=DSR=1) |

GPCIPL and the SSL, all absolute, from `donroute/IPL/IPL.sym.json` (whose
sections are at absolute addresses).  `--break` by ADDRESS needs no symbols and
works on a tape boot, which `--symbols` does not:

| addr | what |
|---|---|
| 0x21cc | `CM4KYBD` — keyboard handler, items 1–17 |
| 0x2c8b | `LOADCHK` — schedules the load (minor cycle 1) |
| 0x271f | `CM4FMAT` — the "formats not sent → send them and EXIT" branch |
| 0x2d10 | `SSLCHECK` — checksums the SSL (minor cycles 2–11, 24) |
| 0x2d18 / 0x2d23 / 0x2d26 | `SSL20` / `SSL30` / `SSL60` — **`SSL60` is the tell**: reached only if the `BCT` count did not underflow |
| 0x2d2b / 0x2d38 / 0x2d46 | `SSL62` / `SSL70` / `SSL75` — `SSL70` is the handover to the loader |
| 0x2d70 / 0x2d72 | `SSLXIT` / `SSLRTN` |
| 0x6fbc | `FCMINSSL` / `SSLSTART` — the loader itself |
| 0x72e2 | `SSLEND`, which is also `FCMDATA` — the checksum span ends here |
| 0x7398 / 0x739b | `SSLENGTH` / `SSLCKSUM` — the two the MM build stamps |
| 0x72a1 | `FCMMOVE`, and 0x72ad its `MVH` — the current open front |
| 0x7338 / 0x733f | `FCMCTXT1` / `FCMCTXT2` — the odd one is 0x733f |
| 0x0a3b | `PCH`, GPCIPL's program check handler (**overlaid by phase 2's LB2**) |
| 0x180c | `STERROR` |
| 0x14e4 | `RTNEX0` |

Useful when the load itself is in doubt: dump memory at the checksum
entry (`b 0x30330; c; x 0x0000 32768`) and compare it against the tape
blocks directly, rather than reading dumps by eye. The tape's stream for
phase 10 is 55 blocks from 2/4/3/0, i.e. `.mmv` block index
`((4*8+2)*8+3)*32 = 8800`, and the load blocks take it in order with each
partial block's tail discarded. Getting this wrong by eye is what
produced the retracted "holes" and "PSA did not load" claims.

Phase 10's five load blocks (start, length, protected):

    0x00000 15394 1   0x03C22 9632 1   0x06DC0 502 0
    0x06FBC   994 1   0x07C00  770 1

---


### Running the whole thing headlessly, no GUI and no MEDS

Four processes; start yaGPC2 **first**, because the IPL pushbutton is momentary
and a panel started first will fire the pulse before anything is listening.

    ./yaGPC2 run --mmu-model <vol>.mmv --mtu-model --discretes --bce-network \
        --real-time --gpc-id 1 --no-halucp-svc --port-base 7000 \
        --max-steps 4000000000

    python3 /tmp/claude-1000/deustub.py 7000 6            # DK1, sends ITEM 1 EXEC
    python3 /tmp/claude-1000/deustub.py 7000 7 nokeys     # DK2
    python3 /tmp/claude-1000/deustub.py 7000 8 nokeys     # DK3
    python3 /tmp/claude-1000/drive.py   7000 85           # crew discretes, RUN at 85 s

`deustub.py` is a DEU peer implementing `deumodel.c`'s rules over the wire, with
the same constants and names so the two can be read side by side; bus 6/7/8 =
DK1/2/3, and the optional third argument is `nokeys` or `latekeys`.
`drive.py` publishes the same SET/RESET bits `discretePanel.py` does and
republishes every 0.25 s, with **no Tk window** — use it rather than
`discretePanel.py --script` for anything automated, which opens a window on the
user's display. Always run automated rigs on `--port-base 7000` so they cannot
collide with a live session on the default 6900.

Interactively, the sequence is `mode HALT` → BFC CRT select → IPL source MM1 →
press and release **IPL** → `mode STANDBY` → wait ~1 m 25 s → `mode RUN`, with
`discretePanel.py --script FILE` able to do all of it (`<ms> <command>`, where
the commands are `mode`, `ipl`, `source`, `gpcid`, `bit <A|B> <n> <on|off>`).

**Why each flag matters.** `--real-time` is mandatory over `--bce-network`
(the transport paces the wire against the wall clock while the GPC times out in
simulated time). `--mtu-model` answers the Master Timing Unit on BCE 20-22;
without it flight I/O collapses — 5,453 intercomputer datagrams against 81,795.
`--gpc-id 1` selects the intercomputer bus port, BCE 24 being per-GPC.
`--no-halucp-svc` stops HalUCP intercepting PASS's own SVCs, whose numbers
collide with the flight software's.

**What is not a fault.** MEDS on `crt1` going to POLL FAIL after `ITEM 1 EXEC`
is correct with BFC CRT = CRT 1 — that tells PASS the BFS owns display 1, so
PASS masks DK1 and drives DK2/DK3. There is no "download complete" message on
the `--bce-network` path; `deu: load complete` belongs to `--deu-model`. And a
frozen DEU image is not by itself a fault (`deu_complete_fill` counts a time
fill and discards it, and a static format refreshed every cycle writes
identical words).

## 4. TOOLS BUILT THIS WEEK (all committed, all ours)

- **`src/mmumodel.c/.h` + `--mmu-model <vol>` / `--mmu-unit <n>`** —
  in-process mass memory, ported from `mmu.coffee`/`mmuConf.coffee`/
  `volume.coffee`. Reads real `.mmv` files. Answers synchronously; no
  socket, no drops, no pacing. **Takes one bus only** and composes with
  `--bce-network` and `--deu-model` via `bus_router_service()` in run.c.
  This is what made the work reproducible — the networked runs disagreed
  with themselves and `--trace`/`--debug`/`--verbose` each changed the
  outcome. The user explicitly wants non-UI peripherals built in like
  this; MEDS stays external because it has a GUI worth having.
- **`tools/stamp_ipl_phase_table.py`** — builds FCMBOOT's IPL phase table
  and stamps it into FCMPTAD1/2/3. Nothing in the toolchain generates it
  (checked twice: `--stamp-phase-tables` covers #PFCMGPT/#PCDCPHA/
  FCMG3DAT, and mmubuild's DMMD pass names only SMARDD2A/SMARDD4A).
  Layout: four 3-hw phase descriptors (phases 10, 2, 13, 3), then 3-hw
  load-block descriptors, from `mmbstamp.LoadBlock.words()`.
  **Assumption, flagged: contiguous layout in that order.** Never verified
  against an original stamped table.
- **`tools/stamp_bootstrap_on_tape.py`** — writes FCMBOOT into a `.mmv` at the
  `FMAIPL2` allocation (card 44500 = file 4 / track 4 / subfile 5 / block 0),
  **padding the whole 72-block reservation** with `C6C6`.  Without it no tape
  we build carries a bootstrap, because our volumes come from the PASS phase
  manifest and there is no bootstrap in it.
- **`tools/stamp_ssl_checksum.py`** — stamps `SSLENGTH` (806, from the link's
  own `SSLEND` equ at 0x72E2) and `SSLCKSUM` (0xCB2C) and recomputes the
  containing load block's checksum tail.  **This is what makes the SSL run at
  all** (§2, "The SSL").  Keeps a `.prestamp` backup.
- **`tools/patch_ssl_zcon.py`** — a **stopgap, not a fix**: writes `FCMB1ZCN` =
  `832A 0006` (`FIOMUWB2` = 0x3032A) and recomputes the load-block tail,
  standing in for a link that has the defining compool among its inputs.
- **`tools/build_ipl_fcm.sh`** — rewritten to Don's composition route
  (relink with current lnk101, then `mmu2fcm --config IPL --phases 10
  --stamp-checksums`). Needs PHASE02.lib present. Output is 6 bytes from
  Don's reference IPL.fcm (the two unrelocated FIOMUWB2 constants).
- **`yaShuttle/discretePanel/`** (pushed): `discretes.py`,
  `discretePanel.py` (Tk), `discreteMonitor.py`. Wire format: multicast
  239.255.1.1:6980, four 16-bit words — op (SET=1/RESET=2), register
  (A=1/B=2), 32-bit mask in two halves, IBM bit numbering.

**CAVEAT ON THE READY DISCRETE, stated plainly: it is a PROXY, not the real
signal.**  On real hardware READY is a line driven *by* the mass memory; here
it tracks whether our own bus controller is running.  The two coincide only
while the BCE stays busy for the duration of the MMU's work — if the MMU were
still positioning after our BCE went idle, READY would rise early.  That is
sufficient for FCMBOOT, which only needs to see busy-then-ready, and it was
verified on the wire with `--reply-delay 600` (READY drops and stays down).
True fidelity would need the MMU to report its own state, which is MMU-side
work and a protocol change.

Emulator fixes made (all with POO citations, all committed):
- **MVH** wrote back the *expanded* address, overflowing and destroying
  the sector bit. gpc has the identical bug, unfixed upstream.
- **tick_counter** carried the timer borrow into the PSA high halfword
  unconditionally; the POO says a *masked* interrupt must not.
- **Instruction Monitor / MODE switch / discretes** — see `problems.md`.
  One of these is a trap in its own right and is trap 12 below: register B
  bits 6–7 are the **DEU_ID field**, not two independent switches, and a
  panel that published 0 for it stopped GPCIPL looking for a display bus
  (fixed in `58bf14106`).

---


### Instrumentation added since (all env-gated, all no-ops when unset)

Whole-state, which is what cracked the hardest bugs:

    YAGPC_SNAPSHOT=<t1>[,<t2>...]:<prefix>   whole main storage to <prefix>-<t>.bin
                                             the first time sim time passes each t
    YAGPC_MEMDUMP=<lo>-<hi>[,...]            ranges at end of run
    YAGPC_PROCDUMP                           per-processor halt/busy/PC, plus each
                                             BCE's recv state; runs for EVERY stop
                                             reason, not just max-steps

Execution:

    YAGPC_NIARING=<n>            ring of recent NIAs, dumped at the Instruction
                                 Monitor and at an invalid-instruction stop
    YAGPC_RINGTRIG=<addr>:<hw>   dump that ring when a halfword takes a value
    YAGPC_NIASAMPLE=<ms>         periodic NIA + registers (gdb cannot attach —
                                 Yama blocks ptrace)
    YAGPC_NIAPROBE=<hexaddr>     R0-R7 every time that address is about to run
    YAGPC_TRACEWIN=<a>-<b>:<f>   per-instruction trace over a simulated-time window
    YAGPC_TRACETRIG=<addr>:<val>:<count>:<f>
                                 the same, armed by a memory VALUE rather than a
                                 time — use this when the event moves between runs
    YAGPC_EATRACE=<nia>[,...]    effective address and contents for named
                                 instructions; a register dump says WHAT a wild
                                 branch went to, only this says where it came from

Memory and protection:

    YAGPC_WATCHHW=lo[-hi]        CPU *and IOP* stores into a window, with NIA and
                                 timestamp;  YAGPC_WATCHRD  for fullword reads
    YAGPC_PROTSET                protect-bit changes
    YAGPC_ISPBTRACE              ISPB by EA window, with M1 and issuing NIA
    YAGPC_DMAPROT                masked DMA store-protect violations, which are
                                 otherwise untraceable (Fig 2-20 note '##')
    YAGPC_UNPROTECT=lo-hi[,...]  }  timed diagnostic unprotect, for standing in
    YAGPC_UNPROTECT_AT=<us>      }  for a load block the tape build omits
    YAGPC_PATCH="<us>:a=v,..."   timed halfword writes bypassing protection
    YAGPC_LOADBIN=<us>:<addr>:<file>   inject a load block
    YAGPC_IPL_PROTECT=0          start memory unprotected — REFUTED as a fix, kept
                                 as a diagnostic; do not make it the default

Bus and IOP:

    YAGPC_SVCTRACE=<file>   every SVC: site, P/L address, base register, DSE, list
    YAGPC_SIOTRACE          every MSC START I/O — the only place a dispatched
                            transaction becomes a running BCE
    YAGPC_PROCTRACE         every change to the processor-enable register
    YAGPC_BUATTRACE         each `#BU@`, printing BOTH candidate targets
    YAGPC_PCTRACE           BCE program-counter loads
    YAGPC_SSTTRACE[=N]      `#SST`s (N caps the count; non-numeric = uncapped —
                            the old hardcoded cap of 10 once made a running BCE
                            look as though it had stopped signalling)
    YAGPC_CLEARTRACE        what each one-word "clear the MIA buffer" read takes
    YAGPC_MVHTRACE          each MOVE HALFWORD with resolved src/dest/count
    YAGPC_BCTRACE           conditional-branch fall-throughs, with mask and CC
    YAGPC_MMUTRACE          mass-memory commands, timestamped
    YAGPC_TIMEOUT_TRACE     BCE receive timeouts
    YAGPC_ALIGNTRACE / YAGPC_RSALIGNTRACE   odd fullword EAs, per addressing form
    YAGPC_DEUKEYS=ITEM,1,EXEC / YAGPC_DEUKEYS_AFTER=<polls>
    YAGPC_IOP_PER_INSTR=1 / YAGPC_IOP_PASS_US=<f>   revert or retune IOP pacing
    YAGPC_ISPB_ALIGN=1      the disputed fullword-ISPB alignment; not the default

Batch-mode SIGINT sets a stop reason instead of killing the process, so
`timeout -s INT` yields a full end-of-run report on an open-ended run.

## 5. TRAPS THAT COST REAL TIME — DO NOT REPEAT

1. **A breakpoint hit is not proof.** `0x4713` "proved" GPCIPL got
   control; the trace showed `004713: 0000  A 0,X'0000'(0)` — a runaway
   sliding through zeros traverses every address. **Check the instruction
   at the breakpoint.** I reported success on this and had to retract it.
2. **`timeout N cmd | grep` loses ALL output** when the timeout fires.
   Redirect to a file. (Done this four times.)
3. **The Bash tool's own default timeout is 2 minutes** regardless of the
   `timeout` given to the shell. Raise the tool timeout for long runs.
4. **Tool output is not reliably shown to the user.** Paste anything they
   must read into the reply itself.
5. **`mmu get`/`dump` take slash addresses** (`2/4/3/0`), not the ALLOC
   card form (`42300`) — the latter silently reads blank tape.
6. **Probe instruction *starts***, taken from the listing. 0x1c0 is the
   second halfword of the instruction at 0x1bf and never hits.
7. **MEDS RETAINS ITS IPLed STATE between GPC runs.**  Its poll reply
   then has the IPL-REQUIRED bit clear and `w12 = 0xc000`
   (`BITE1_IPL_DONE`), GPCIPL skips the DEU load, and the display FORMATS
   are part of that load -- so the screen shows the clock and nothing
   else.  **Restart MEDS before every run.**  The in-process `--deu-model`
   starts un-IPLed every time, which is why it saw all 518 display fills
   while the wire saw none, and why the two disagreed for hours.
8. **GPCIPL needs the mass memory ATTACHED even when the whole composed
   image is already in core.**  `--power-on ... IPL.fcm` alone gives ZERO
   display traffic; add `--mmu-model` and it comes alive.  Verified
   against a worktree build of the pre-today commit, so this is not a
   regression -- the 08-23 session simply had Don's MMU running.
9. **The command function code is `(w0 >> 1) & 0x3ff` on the WIRE word**
   and `(cmd24 >> 9) & 0x3ff` on the 24-bit internal form.  Mixing them
   makes real traffic look like nothing recognisable.  Wire framing is
   IUA byte + reserved byte + words, ONE WORD PER DATAGRAM -- deliberate,
   see bcenet_framer.c; batching was tried and broke the peer.
10. **Reach for a counter before reading code.**  Both bus bugs above were
   invisible in the source and obvious the moment the right number was
   printed: `wordsOut` vs `wordsTaken`, and `pending` per command.
11. **A "wait state" stop exits 0 and prints nothing** without `--verbose`.
   Silence is a result, not a failure to run.
12. **A panel's resting position must be the position the hardware is in**,
   or running the panel is itself a change to the machine.  `discretePanel`
   started every toggle broken, so it published register B bits 6–7 as 0.
   Those two bits are not two switches: they are the **DEU_ID field**, which
   `GPCRTOPT.asm` extracts with `NHI R3,X'0300'` / `SRL R3,8` and `POLL30`
   tests with "IS THE DEU_ID 1, 2, 3, OR 4" (`LR R3,R3` / `BZ POLL45`).
   Zero means "no display unit", so GPCIPL gave up before choosing a bus.
   yaGPC2's own `DISCRETE_IN_B_DEFAULT` is `0x21000000` — GPC 1, CRT 1.
   Fixed in `58bf14106` (DEFAULT_ON).  **Check every panel-owned bit against
   the corresponding `DISCRETE_IN_*_DEFAULT` before adding it.**
13. **Networked, real-time, `gpcmd`-driven runs are NOT deterministic**, and
   several conclusions were built on single breakpoint hits taken from them.
   `SSLCHECK 0x2d10` hit on one run and missed on a later *identical* one.
   Use the deterministic harness in §3 for anything you intend to write down,
   and repeat every observation before building on it.
14. **Your own test scripts publish onto the user's discretes bus.**  It is
   machine-wide multicast, and a script that holds RUN for 300 s drives RUN
   into every emulator on the machine.  A sending socket is not bound to 6980,
   so `ss` cannot see a publisher — only `ps` can, and it must be checked
   **before** concluding anything about discretes.  Half of a "mode flapping"
   bug report was this; the other half was real (`problems.md` §8.14).  Every
   test script must be short-lived or explicitly killed.
15. **`--symbols` is silently ignored on a tape boot** (the no-`fcm` path
   returns before symbols load).  Do not try to "fix" it in passing: I did,
   it segfaulted, and I chased it into `halucp_init_from_symbols` and added
   NULL-name guards on the written premise that `IPL.sym.json` "includes
   entries whose name is null".  **It does not** — 0 of 13 sections and 0 of
   2,982 symbols.  The real cause was my own patch loading the table a second
   time on top of the existing load.  All reverted.  `--break` by **address**
   needs no symbols and works fine.
16. **The discrete trace prints only on CHANGE.**  A RESET of a bit that is
   already 0 prints nothing.  That looks like a dropped message and is
   correct — the shadow state starts at 0.

---


**`pkill -f` kills your own shell here.** The pattern text appears in the
shell's own command line, so it matches itself — exit 144, five times in one
day.  Use a bracket pattern (`discrete[P]anel`, `[m]ain.js meds`) **and** keep
kills in a separate invocation from the relaunch.  `pgrep -f` prints only PIDs,
so `pgrep -f X | grep -c python3` always counts 0; use `pgrep -fc`.

**Leftover processes are on the user's bus.** Five stray yaGPC2 processes once
contaminated a reported measurement, and four overlapping `discretePanel`
instances — one launched per iteration without killing the previous — made a
deterministic crash look nondeterministic.  Kill by PID and verify before any
bus measurement.

**A stale binary can survive a newer timestamp.** `make` did not rebuild
`ageharness.c` despite it being newer, which invalidated three reported results
about protection modes.  `make` also does not rebuild the *test* binaries and
does not track `test/cpu_ea_fixtures.h` at all, so an edited fixture header is
silently re-run against the old binary.

**`--deu-model` cannot answer bus questions.** Its help says it "answers in the
same call", so every solicited reply is present before the poll asks — it once
reported 518 fills while the wire saw none.  Use `--bce-network` with
`deustub.py` for anything about timing or sequencing.

**A single window on a ramp is meaningless.** Two 45 s datagram counts taken 8 s
after launch straddled different points of a rising curve and were reported as a
difference between two tapes.

**Do not trust a counter from a truncated run.** "Zero DMA protect violations"
came from a run that never reached the code; the real figure is 7,170.

**Piped output is lost entirely when a command is killed** — all of it, not the
tail.  Use `python3 -u`, `PYTHONUNBUFFERED=1` or `unbuffer` for anything slow
whose output you intend to read.

**Commit before reverting.** `git checkout -- src/ageharness.c` destroyed hours
of uncommitted work.  It was recovered only because the session transcript at
`~/.claude/projects/<project>/<session-id>.jsonl` records every Edit's
`old_string`/`new_string` and every Bash heredoc — that is the recovery route,
but it is luck of the tool used.

## 6. OUTSTANDING, NOT CODE

- **49 commits unpushed** on `master` (`249669d91` … `b2c5c0399`, measured
  2026-08-27). The user pushes themselves; they asked not to push until
  things were tested.  Re-measure rather than quoting this number.
- **`make test` has four failures that are NOT ours** — `test_debugger.sh`,
  `test_cpu_instr_exec`, `test_iop_bce_exec`, `test_iop_msc_exec` fail
  identically with the working tree stashed. Checked 2026-08-25; worth
  fixing on their own account, and worth re-checking against a stash
  before blaming any new change for them.
- **Unverified in the pacing fix:** `iop_bce_delay` discards on every bus,
  not just the mass memory. That is right for hardware — a delay always
  loses bus data — but nothing in the suite exercises `#DLYI` on the DK
  bus, so a regression in the DEU/MEDS path would not have shown up.
- **MVH bug report to Don — drafted-but-held.** The user asked to wait.
  gpc still has it (`cpu_instr.coffee:5461`,
  `t.r(v.x).set32((destAddr << 16) | 0)`); JS bitwise is 32-bit so the
  same overflow applies. **Show the text before posting.**
- **Issue #30** (github.com/ColanderCombo/nsts-sim-gpc/issues/30) is open,
  asking Don for discretes; the PR is offered but explicitly withheld
  unless he asks. Branch `yagpc2-discretes` in `~/donschmidt/nsts-sim-gpc`
  is ready to become it (rebased on origin/main, 25/25 tests).
- **Issue #27** comment posted (CVFX; his call left standing).
- Repos as of now: `nsts-sdl-dps` master @ `b14293b`;
  `nsts-sim-gpc` on `yagpc2-discretes` @ `cb6b28d`. The user asks for a
  repo check first thing each session — Don is committing frequently and
  **read the commit comments**, they are substantive.

## 7. STANDING RULES (from CLAUDE.md / the user)

- **Never edit an existing `*.md`** without the phrase "Full Documentation
  Sync". Appending to `CLAUDE_LOG.md` and writing `HANDOFF*`/`RELAY-*` is
  always allowed.
- **Commit finished, verified work** without being asked. Don't commit
  unverified work.
- **Show outward-facing text before it is sent** — PR/issue prose gets
  reviewed first.
- **Use ASM101S.py / HALSFC, never `asm101` or `halsc`** for builds.
  `asm101` is a reimplementation; `halsc` is a wrapper whose API differs,
  so neither can underpin user-facing instructions.
- `~/workspace/PFS` and `~/donschmidt/*` are other people's repos: pull
  before changing, prefer read-only, say what was touched. (Everything on
  local branches in nsts-sdl-dps is ours.)
- Measure, don't recall. Re-run rather than quoting an old number.
