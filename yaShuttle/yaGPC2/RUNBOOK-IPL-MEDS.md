# Runbook — building the tape and running FCMBOOT → GPCIPL → MEDS

For someone who has not done this before.  Part A builds the software and
writes the mass memory tape; part B builds the bootstrap image; part C runs
the emulation with the display and the crew panel.

**Confidence, stated up front.**  Part C was exercised repeatedly on
2026-08-25 and every command in it is copied from a run that worked.  Part A
was *not* re-run that day — the phase libraries and tape already existed from
an earlier session — so its commands are reconstructed from the tools' own
`--help` and from the artifacts they produced.  The one thing in part A that
was re-verified is the PASS area (see A.3).  Treat part A as "should be
right, check as you go", not as "known to run clean".

---

## 0. What you need first

| thing | where | note |
|---|---|---|
| PASS sources | `~/workspace/PFS/OI340600` | `SSSRC/`, `APPLSRC/`, `INCL80/`, `MLIB80/`, `CON80/` |
| SDL toolchain | `~/donschmidt/nsts-sdl-dps` | Don Schmidt's; built into `build/bin` and `build/venv` |
| yaGPC2 | `~/git/virtualagc/yaShuttle/yaGPC2` | `make` to build |
| MEDS | `~/donschmidt/nsts-sim-gpc` | Don Schmidt's; `npm` deps installed |

Set these once per shell:

    export SDL=~/donschmidt/nsts-sdl-dps
    export PATH="$SDL/build/bin:$PATH"
    export PY="$SDL/build/venv/bin/python"
    export SRC=~/workspace/PFS/OI340600
    export WORK=~/ipl-build          # anywhere with a few hundred MB free

`~/donschmidt/*` and `~/workspace/PFS` belong to other people or other
processes.  Pull before changing anything, prefer read-only, and say what you
touched.

---

## A. Build the phases and write the tape

### A.1  Build each phase

`con80build` reads the CON80 card deck, works out which modules belong to a
phase, assembles/compiles them and links a load module.

    con80build --phase 10 --root "$SRC" --out "$WORK/phases"

Repeat for each phase you want on the tape.  For the FCMBOOT → GPCIPL demo
you need at least:

* **phase 1** — FCMBOOT's own phase
* **phase 2** — GPCIPL's parent Z1 pool; phase 10 will not compose without it
* **phase 10** — GPCIPL itself
* whatever further phases the loader pulls at run time (BSL1 reads more; a
  full build of all 25 is the safe option and is what the working tape has)

Output layout, and note the asymmetry — later tools depend on it:

    $WORK/phases/PHASEnn.lib                  <- top level
    $WORK/phases/PHASEnn/PHASEnn.sym.json     <- subdirectory
    $WORK/phases/PHASEnn/PHASEnn.fcm

`--master OFTMP` is the default master deck whose PHASE directives define the
phases; you should not need to change it.

### A.2  Sanity-check a phase before going on

    $PY - "$WORK/phases/PHASE10/PHASE10.sym.json" <<'EOF'
    import json,sys
    d=json.load(open(sys.argv[1]))
    print("sections:", len(d["sections"]), " entry:", d.get("entryPoint"))
    sp=d.get("storeProtect")
    print("store protect:", sum(hi-lo for lo,hi in sp["ranges"]) if sp else "NONE")
    EOF

`store protect: NONE` means the phase was linked by an `lnk101` too old to
carry the map.  Fix that before continuing — the emulator refuses to IPL an
image whose protection is wrong.  Phase 10 should report 9 ranges covering
27,275 halfwords.

### A.3  Write the tape

    PYTHONPATH="$SDL/src" $PY -m tools.mmu2mmv \
        --con80 "$SRC/CON80" \
        --mmu   "$WORK/phases" \
        --area  1 \
        --out   "$WORK/mmu.mmv"

**`--area 1` matters.**  The areas are redundant copies of the same software
at different tape addresses.  Area 1 is what the working tape uses: verified
by `--report`, which places phase 10 at MM address `42300`, transport
position `2/4/3/0`, 55 blocks — exactly what the emulator is seen to read.
(The existing volume is called `mmu2.mmv`; the "2" is a file-name
generation, *not* the area.  Do not be misled by it.)

Look before you write:

    PYTHONPATH="$SDL/src" $PY -m tools.mmu2mmv ... --report

A good volume is about 1085 blocks.

---

## B. Build the FCMBOOT bootstrap image

FCMBOOT is what the IOP microcode fetches at IPL.  It is three modules, and
it needs a table stamped into it afterwards.

### B.1  Assemble and link

Use the **official assembler**, `ASM101S.py` — not `asm101`, which is a
reimplementation and must not be used for builds.  (Note: the older
`tools/build_ipl_fcm.sh` in this repo still calls `asm101`; it predates that
rule and should be corrected before it is trusted.)

    cd "$SRC"
    for m in FCMBOOT FCMSSLPT LOADTBL; do
        $PY <path-to>/ASM101S.py -L MLIB80 -L SSSRC -L INCL80 \
            -o "$WORK/boot/$m.obj" "SSSRC/$m.asm"
    done

    lnk101 --concard CON80 --concard-root PHASE01 \
        -o "$WORK/boot/BOOT.fcm" \
        --json-symbols "$WORK/boot/BOOT.sym.json" \
        "$WORK/boot"/*.obj

### B.2  Stamp the IPL phase table

FCMBOOT navigates the tape using a table it does **not** build for itself.
Three 256-halfword areas (`FCMPTAD1/2/3`) sit holding `X'FFFF'` — the
documented "this area was never mass-memory built" sentinel — for the ground
Mass Memory Build program to stamp over.  Nothing in the toolchain does that,
so an unstamped FCMBOOT walks all three areas, finds `FFFF` in each, and
parks in its give-up wait state having never touched the bus.

    cd ~/git/virtualagc/yaShuttle/yaGPC2
    $PY tools/stamp_ipl_phase_table.py "$WORK/boot/BOOT.fcm" \
        --sym   "$WORK/boot/BOOT.sym.json" \
        --mmu   "$WORK/phases" \
        --con80 "$SRC/CON80" \
        -o      "$WORK/boot/BOOT-stamped.fcm"

**Use `BOOT-stamped.fcm` from here on.**  The layout the stamper writes
(four 3-halfword phase descriptors for phases 10, 2, 13, 3, then the
load-block descriptors, contiguous in that order) has never been checked
against an original stamped table.  It works; it is not proven authentic.

---

## C. Run it

### C.1  Build the emulator

    cd ~/git/virtualagc/yaShuttle/yaGPC2 && make

`make test` currently fails four suites (`test_debugger.sh`,
`test_cpu_instr_exec`, `test_iop_bce_exec`, `test_iop_msc_exec`).  They fail
identically on an untouched tree, so they are pre-existing, but they are real.

### C.2  Start MEDS — **restart it every single run**

    cd ~/donschmidt/nsts-sim-gpc
    ./MEDS.sh --size 512 crt1 idp1

`--size 512` is a convenient window size.  (Its scaling is slightly off —
reported upstream to Don.  Omit `--size` for a correct but very large window.)

**MEDS keeps its IPLed state between GPC runs.**  A MEDS that has already
been loaded answers the GPC's poll with the IPL-REQUIRED bit clear and
`w12 = 0xC000` (`BITE1_IPL_DONE`) — "I am already loaded" — so GPCIPL skips
the display load, and since the display *formats* are part of that load you
get a clock and a blank screen.  If the screen is nearly empty, this is the
first thing to check.

### C.3  Start the crew panel

    python3 ~/git/virtualagc/yaShuttle/discretePanel/discretePanel.py

It comes up with the GPC MODE SWITCH at **HALT**, which is where it should be
before the GPC starts.

### C.4  Start the GPC

    cd ~/git/virtualagc/yaShuttle/yaGPC2
    ./yaGPC2 run --ipl --discretes --bce-network \
        --mmu-model "$WORK/mmu.mmv" \
        --real-time --rt-factor 1 --max-steps 0 --rt-idle-timeout 900 \
        --verbose "$WORK/boot/BOOT-stamped.fcm"

It prints `MODE: HALT; CPU held in reset` and executes nothing.

**The pacing flags are not optional.**  Under the CLI's default
(`--pacing=burst --time-scale 1.0`) this same image puts about a twentieth of
the display traffic on the bus and the screen stays nearly blank.  With
`--real-time --rt-factor 1` you get roughly 87 DISPLAY_FILL in 45 s, matching
the reference image.

Flag by flag:

| flag | why |
|---|---|
| `--ipl` | stands in for the firmware IPL's memory fill.  **Not** `--power-on`, which is for a loaded image |
| `--discretes` | subscribe to the crew panel's bus |
| `--bce-network` | drive the real MEDS over multicast |
| `--mmu-model` | in-process mass memory, so the tape is deterministic |
| `--max-steps 0` | no instruction limit |

### C.5  Drive it

Move the panel's **GPC MODE SWITCH from HALT to STBY**.  Then:

1. `MM1 READY` on the panel drops and comes back — FCMBOOT reading the tape.
2. FCMBOOT hands to GPCIPL, which runs a memory sweep and loads further
   phases.  Ten or fifteen quiet seconds here is normal.
3. The display comes up.

To start over: put the switch back to HALT, **kill and restart the GPC and
MEDS both**, then STBY again.  Cycling the switch alone does not redo the
boot — FCMBOOT overwrites the PSA reset vector with GPCIPL's, so a second
release lands in GPCIPL at 0x0013F rather than FCMBOOT at 0x0014B.

---

## D. When it does not work

**Nothing happens at all.**  Is the panel actually at HALT when the GPC
starts?  A GPC started with the switch already at STBY boots immediately.

**Clock runs, screen otherwise blank.**  Restart MEDS (C.2).

**No display traffic at all.**  Check `--mmu-model` is present.  GPCIPL needs
the mass memory attached *even when the whole image is already in core* —
without it there is zero display traffic and the machine looks dead.

**Diagnosing headlessly.**  Swap `--bce-network` for `--deu-model` and drop
`--discretes`, add `--time-scale 2000`, and read the counters printed at exit:

    ./yaGPC2 run --ipl --mmu-model "$WORK/mmu.mmv" --deu-model \
        --time-scale 2000 --max-steps 20000000 "$WORK/boot/BOOT-stamped.fcm"

A healthy run reports roughly `mmu1: commands 41, blocksRead 88` and
`deu: displayFills 518, formatFills 8, timeFills 512, headerless 0,
ipled true`.

Useful when something is wrong:

| tool | for |
|---|---|
| `YAGPC_MMUTRACE=1` | every mass memory command, with the queue depth — `pending` must be 0 at each |
| `YAGPC_DEUIMAGE=1` | what the display unit's memory actually holds |
| `--watch ADDR:N --watch-log` | every write to a location, in the fast path |
| `--break 0xADDR --verbose` | stop and dump registers |

**Counters before code.**  Both bus bugs found on 2026-08-25 were invisible
in the source and obvious the moment the right number was printed.
