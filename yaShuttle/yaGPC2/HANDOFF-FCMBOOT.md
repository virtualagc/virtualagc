# HANDOFF — FCMBOOT → GPCIPL → MEDS

Written to survive a `/compact`. Everything needed to resume is here. The
long-form narrative that was in `CLAUDE_LOG.md` has been folded into this
file and into `problems.md`; the log itself has since been cleared, so do not
go looking there for it.

---

## 1. The goal

Boot the real Shuttle IPL chain in yaGPC2, end to end:

    firmware IPL → FCMBOOT (bootstrap) → reads GPCIPL off the mass memory
                 → hands control to GPCIPL → GPCIPL drives the MEDS display

PASS User's Guide (`~/Desktop/sandroid.org/public_html/apollo/Shuttle/PASS
USER GUIDE - OI32.pdf`) §2.3 and Table 2-2 (pages 49, 52, 53) describe the
sequence. Key facts established from it:

- **HALT** = hardware RESET held; no software runs. **STBY entered from
  HALT** releases reset and gives control to the Bootstrap Loader. The
  mode switch is a reset line, not a polled input — FCMBOOT never tests
  those bits.
- Table 2-2 step 10 (GPC IPL push/release) is the *firmware* IPL: it
  fills memory (C9FB 0-1FFFF, C6C6 20000-7FFFF) and reads the bootstrap
  in from the MMU. We do not emulate that microcode; `--ipl` stands in
  for the fill, and we load FCMBOOT from a file instead of from tape.

---

## 2. WHERE IT STANDS RIGHT NOW

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

**Nothing emulates the IOP microcode that loads FCMBOOT off the tape at IPL
initiation**, and that is by design rather than a gap: `--ipl` does cold-IPL
memory init only (fill and protect, §2.5.3.3) and still loads the `.fcm` from
a file, as `gpc` does.  FCMBOOT's own header says it "RECEIVES CONTROL FROM THE
MICRO CODE LOADER VIA THE SYSTEM RESET PSW", which is what `--power-on` already
does — so loading `BOOT.fcm` as the boot image and letting FCMBOOT do its own
MMU reads tests the real question with no microcode at all.

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

### What is actually still open

- `make test` fails four suites: `test/test_debugger.sh`,
  `test_cpu_instr_exec`, `test_iop_bce_exec`, `test_iop_msc_exec`.  They
  fail identically with the whole tree stashed, so they predate all of
  this, but they are real and nobody has looked at them.
- GPCIPL emits a stream of "HAL/S SVC unrecognized, passing to real
  interrupt" for its own assembly SVCs.  It gets on with its work, so
  this may be only noise from halucp's intercept -- but that has not been
  established either way.
- This is the IPL.  Loading the full PASS flight software on top of it is
  a further step that has not been attempted.

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
`YAGPC_MMUTRACE=1`, `YAGPC_DISCRETETRACE=1`, `YAGPC_CLKTRACE=1`.

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
13. **The discrete trace prints only on CHANGE.**  A RESET of a bit that is
   already 0 prints nothing.  That looks like a dropped message and is
   correct — the shadow state starts at 0.

---

## 6. OUTSTANDING, NOT CODE

- **13 commits unpushed** on `master` (`e7417f9c8` … `14a7b7581`). The
  user pushes themselves; they asked not to push until things were tested.
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
