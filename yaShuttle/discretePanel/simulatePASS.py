#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Run the Space Shuttle flight software on one to four simulated GPCs, with
the crew station around them: MEDS2.py displays, the stsKeyboard.py DPS
keyboards, the panelO6.py GPC and IDP panel, and -- with more than one computer --
cam.py's GPC STATUS lamps.  yaGPC2 is the computer.

    python3 simulatePASS.py --tape OI340700-v44boot.mmv
    python3 simulatePASS.py --gpcs 1,2 --tape OI340700-v44boot.mmv
    python3 simulatePASS.py --gpcs 1-3 --tape ... --size 640 --scale 0.9
    python3 simulatePASS.py --gpcs 1,2 --instructions  # the steps, then exit

The switch-and-keyboard steps for a configuration are printed by the same
command with --instructions added, which starts nothing -- run it in a second
terminal, where the programs' output will not scroll the steps away.  Once
everything is up, press Enter in this terminal (or Ctrl-C) to shut it all
down.  Each program's output goes to a log in --logs; the previous run's are
kept in a prev-<time> directory there.

The steps are the ones the scripted runs followed, which reached OPS 2 with
two, three and four computers.

CREW SCRIPTS.  --script FILE (also spelled --panel-script) is one file for the
whole scripted crew: panel switches, 'keys ...' keystrokes, 'subtitle ...'
captions and 'wait gpc N mode-tb RUN|IPL|BP' lines, all in seconds, played by
panelO6.py on one clock so switches and keys stay in step.  The commands are
listed at the end of this help, and 'python3 crewscript.py FILE' checks a
script without running anything; examples/4gpc-startup.script brings up four
GPCs to OPS 2.  For a demonstration, --show-panel keeps panelO6's window up so the
switches are seen to move, and a 'wait user' line (first, say) holds the
script until someone clicks in the panel window -- time to arrange windows
and start a recording; leave --duration off then, since it counts from
start-up.  --wait-user gives that pause without editing the script (it also
shows the panel), so a script can stay fit to run unattended.  The paragraphs
below describe the older split, which still works.

UNATTENDED RUNS.  --panel-script hands panelO6.py a timed script ('<seconds>
<command>' per line, decimals allowed; 'gpc <n>' picks the column, and
'idppower N on|off', 'majfunc N GNC|SM|PL', 'kybdsel left 1|3', 'kybdsel right
2|3' and 'idpload N' work the IDP switches), --keys a file of '<seconds> KEY
KEY ...' lines typed on a keyboard bus (keys as on the keyboard: ITEM EXEC OPS
PRO SPEC RESUME CLEAR + - . 0-9 A-F; KB1, KB2 or KB3 sends the rest of the
line on the left, right or aft keyboard, KB1 by default; also IDP_POWER_ON,
IDP_POWER_OFF and DEU_LOAD for IDP 1 and IDP2_POWER_ON, IDP2_POWER_OFF and
DEU_LOAD2 for IDP 2, which the panel follows as if its switches had been
thrown), and --duration ends the run after that many seconds.  Key and panel
times both count from when the panel starts; a time written '+N' is instead N
seconds after the line before, in either file.

CAPTIONS FOR VIDEOS.  '<seconds> SUBTITLE text ...' in the keys file, or
'<seconds> subtitle text ...' in the panel script, shows the text in
subtitles.py's borderless caption box (the same line with no text clears it;
\\n starts a new line; a leading <left>, <center> or <right> aligns that
caption alone).  This program does not start the box of its own accord, since
no default size or place suits every recording: run subtitles.py yourself with
the same --port-base, and use its --edit to find the options that suit -- or
name it in a --layout file, which says where it goes and starts one.  When a
script captions, the log says so and gives the command.

WAITING INSTEAD OF GUESSING.  A line 'WAIT gpc N mode-tb RUN|IPL|BP [timeout S]'
in either file holds that file until GPC N's MODE talkback on panel O6 shows
the state -- RUN when a load is complete, IPL while a bootstrap is in, BP
(barberpole) otherwise, as the GPC drives it -- and the times of the lines
after it count from that moment.  The keys file learns the talkback from the
panel's log; a wait that times out stops that file, logged, rather than
typing on as if the GPC were ready.
"""

import argparse
import datetime
import json
import os
import re
import shlex
import shutil
import signal
import socket
import struct
import subprocess
import sys
import textwrap
import threading
import time

HERE = os.path.dirname(os.path.abspath(__file__))
YAGPC_DIR = os.path.normpath(os.path.join(HERE, "..", "yaGPC2"))
MCAST_GROUP = "239.255.1.1"
IFACE = os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")

# The DPS keyboard scan codes and MDU -> IDP messages live with the crew script
# language, which --keys playback below shares.
import crewscript
import windowLayout
from crewscript import SCAN, IDP_MSG
MAJOR_FUNC = {"PL": 0, "GNC": 1, "SM": 2}


def log(msg):
    print("simulatePASS: %s" % msg, flush=True)


def parse_gpcs(text):
    out = set()
    for part in text.split(","):
        part = part.strip()
        if not part:
            continue
        lo, _, hi = part.partition("-")
        out.update(range(int(lo), int(hi or lo) + 1))
    gpcs = sorted(out)
    if not gpcs or gpcs[0] < 1 or gpcs[-1] > 4:
        raise argparse.ArgumentTypeError("GPCs 1 to 4, e.g. 1  or  1,2  or  1-3")
    return gpcs


# ---------------------------------------------------------------------------
# The procedure

def procedure_text(gpcs, crts):
    g = gpcs
    n = len(g)
    L = []
    L.append("-" * 72)
    L.append("INSTRUCTIONS: GPC%s %s with %d CRT%s"
             % ("s" if n > 1 else "", ", ".join(map(str, g)), crts, "s" if crts > 1 else ""))
    L.append("-" * 72)
    L.append("")
    # Only what this configuration needs: its keyboards, its IDP/CRT sets.
    kb = ["keyboard 1 (left) types on CRT1"]
    if crts >= 2:
        kb.append("keyboard 2 (right) on CRT2")
    if crts >= 3:
        kb.append("either reaches CRT3 with its IDP/CRT SEL at 3")
    if crts == 4:
        kb.append("keyboard 3 (aft) on CRT4")
    L += textwrap.wrap("Keyboards: " + "; ".join(kb) + ".  On a DPS page the digit "
                       "before the time is the GPC driving it, and the box at the foot "
                       "is its IDP.", 78)
    L.append("")
    names = ["GPC%d" % x for x in g]
    gpcs_named = names[0] if n == 1 else ", ".join(names[:-1]) + " and " + names[-1]
    L.append("BEFORE ANY IPL  (every switch is on panelO6)")
    # The GPCs are powered first, as on the vehicle, though the switches drive
    # nothing yet.
    L.append("  a. O6: GENERAL PURPOSE COMPUTER POWER -> ON for %s." % gpcs_named)
    L.append("  b. C2: IDP/CRT %s POWER -> ON, MAJ FUNC -> GNC."
             % ", ".join(str(k) for k in range(1, min(crts, 3) + 1)))
    if crts == 4:
        L.append("     R11: IDP/CRT 4 POWER -> ON, MAJ FUNC -> GNC.")
    L.append("     (\"MDU IS AUTONOMOUS\" goes away.)")
    if crts == 1:
        L.append("  c. C2: LEFT IDP/CRT SEL -> 1.")
    else:
        L.append("  c. C2: LEFT IDP/CRT SEL -> 1, RIGHT IDP/CRT SEL -> 2.")
    L.append("  d. MODE -> HALT for %s." % gpcs_named)
    L.append("")
    if n == 1:
        gpc = g[0]
        L += [
            "IPL GPC%d" % gpc,
            "  1. BFC CRT SELECT -> 1+2, BFC CRT DISPLAY -> ON   (GPCIPL uses CRT1)",
            "  2. IPL SOURCE -> MMU 1",
            "  3. GPC%d column: press and release IPL" % gpc,
            "  4. GPC%d MODE -> STBY" % gpc,
            "     ... the GPCIPL MENU appears on CRT1 and loads the display.  Wait.",
            "  5. On the left keyboard: ITEM 1 EXEC   (the system software loads, ~1 minute;",
            "     the MM1 ACTIVITY lamp flickers red while it reads, green when done)",
            "  6. BFC CRT DISPLAY -> OFF          (after the load, before RUN)",
            "  7. GPC%d MODE -> RUN" % gpc,
            "  8. IPL SOURCE -> OFF               (after RUN)",
            "",
            "TO RE-IPL: IPL SOURCE -> MMU 1, BFC CRT DISPLAY -> ON, MODE -> HALT, O6: IDP 1",
            "LOAD, press IPL, MODE -> STBY, and on from step 4.",
        ]
        return "\n".join(L)
    L.append("IPL THE COMPUTERS ONE AT A TIME: finish each one completely before starting")
    L.append("the next.  IPL SOURCE and BFC CRT SELECT are single switches shared by every")
    L.append("computer, and GPCIPL drives one display: the first CRT named by BFC CRT SELECT.")
    L.append("Every computer loads from MMU 1; the MM1 ACTIVITY lamp is red while the unit is")
    L.append("reading and green when it is idle.")
    L.append("")
    for i, gpc in enumerate(g):
        if i == 0 or crts == 1:
            crt, sel, kb = 1, "1+2", "left"
        else:
            crt, sel, kb = 2, "2+3", "right"
        L.append("IPL GPC%d  (on CRT%d)" % (gpc, crt))
        steps = ["IPL SOURCE -> MMU 1",
                 "BFC CRT SELECT -> %s, BFC CRT DISPLAY -> ON" % sel]
        if i > 0:
            steps.append("O6: IDP %d LOAD  (PASS on GPC%d has loaded that display; without this"
                         "\n      GPC%d's menu never appears, or is drawn over PASS's page)"
                         % (crt, g[0], gpc))
        # PASS User's Guide Table 2-2's order: the load completes in STBY, the
        # CRT is deselected, THEN RUN, and the IPL source comes off last.
        steps += ["GPC%d column: press and release IPL" % gpc,
                  "GPC%d MODE -> STBY" % gpc,
                  "wait for the GPCIPL MENU on CRT%d (\"GPCIPL MENU (1)  %d\"; its clock counts"
                  "\n      up from 000/00:00:00)" % (crt, gpc),
                  "on the %s keyboard: ITEM 1 EXEC  (the system software loads: the MM1"
                  "\n      lamp flickers red)" % kb,
                  "when the MM1 lamp has stayed green (roughly 80 s after ITEM 1 EXEC):"
                  "\n      BFC CRT DISPLAY -> OFF, then GPC%d MODE -> RUN, then IPL SOURCE -> OFF."
                  "\n      GPC%d now runs PASS OPS 0; leave its switches alone from here on.%s"
                  % (gpc, gpc, "" if crt == 1 else
                     "\n      GPC%d takes CRT2 back: both CRTs show its GPC MEMORY page until"
                     " OPS 2." % g[0])]
        for k, st in enumerate(steps, 1):
            L.append("  %d. %s" % (k, st))
        L.append("")
    # The NBAT the verified runs entered.  CRT 1 must go to the first computer:
    # given to another, no OPS 2 page ever appeared on it.
    strings = {2: [1, 1, 2, 2], 3: [1, 1, 3, 2], 4: [1, 2, 3, 4]}[n]
    strings = [g[s - 1] for s in strings]
    rows = [("1", 2, "memory configuration 2 (GN&C)")]
    rows += [(str(2 + k), gpc, "target set: GPC%d" % gpc) for k, gpc in enumerate(g)]
    rows += [(str(7 + k), gpc, "flight-critical string %d -> GPC%d" % (k + 1, gpc))
             for k, gpc in enumerate(strings)]
    rows += [("11", g[0], "payload bus -> GPC%d" % g[0]),
             ("12", g[0], "CRT 1 -> GPC%d   (keep CRT 1 on GPC%d)" % (g[0], g[0])),
             ("13", g[1], "CRT 2 -> GPC%d" % g[1]),
             ("18", g[0], "mass memory 1 -> GPC%d" % g[0]),
             ("19", g[1], "mass memory 2 -> GPC%d" % g[1])]
    if crts >= 3:
        # Not yet entered in any run.  PASS drives at most three CRTs at a
        # time (DPS Workbook USA005350 Rev B), so CRT 4 is left unassigned.
        c3 = g[2] if n >= 3 else g[0]
        rows.append(("14", c3, "CRT 3 -> GPC%d   (not yet tried)" % c3))
    L.append("THE NBAT, on CRT1 with the left keyboard (PASS on GPC%d drives it now).  Each"
             % g[0])
    L.append("line ends in EXEC.")
    for item, val, what in rows:
        L.append("   %-24s %s" % ("ITEM %s + %d EXEC" % (" ".join(item), val), what))
    L += [
        "",
        "THE REDUNDANT SET AND OPS 2",
        "   OPS 2 0 1 PRO",
        "  The computers form their set within seconds, the OPS 2 overlay loads from",
        "  mass memory (about half a minute), and CRT1 shows UNIV PTG (page 2011).",
        "  The CAM stays dark while the set is healthy.  A computer voted out lights",
        "  its column; one that finds itself alone lights its own diagonal.",
    ]
    if crts >= 2:
        L.append("  CRT2 then shows GPC%d's pages (header digit %d), typed on the right keyboard."
                 % (g[1], g[1]))
    if crts >= 3:
        L.append("  CRT3 is typed on whichever forward keyboard has its IDP/CRT SEL at 3.")
    if crts == 4:
        L.append("  CRT4 is typed on the aft keyboard.  PASS drives at most three CRTs at a time,")
        L.append("  so to use it the NBAT must give up CRT3 (ITEM 14) for CRT4 (ITEM 15); not")
        L.append("  yet tried here.")
    return "\n".join(L)


# ---------------------------------------------------------------------------
# Processes

class Launcher(object):
    def __init__(self, logs):
        self.logs = logs
        self.procs = []

    def start(self, name, argv, cwd, env=None):
        path = os.path.join(self.logs, name + ".log")
        fh = open(path, "w")
        kw = {}
        if os.name == "posix":
            kw["start_new_session"] = True          # its own group, so it can be killed whole
        else:
            kw["creationflags"] = getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0)
        p = subprocess.Popen(argv, cwd=cwd, env=env, stdout=fh, stderr=subprocess.STDOUT,
                             stdin=subprocess.DEVNULL, **kw)
        self.procs.append((name, p, fh))
        log("%-9s started (pid %d, log %s)" % (name, p.pid, path))
        return p

    def stop(self, keep=()):
        """Stop the children, except any whose name is in `keep`.

        A RESUME KEEPS THE MANAGER.  It is the window the person just clicked
        Restore in, and taking it down and putting it back would lose what is
        typed in its path boxes and make the click look like a crash.  It is
        also a sibling, not a parent, so nothing else depends on it going.
        """
        kept = [e for e in self.procs if e[0] in keep]
        self.procs = [e for e in self.procs if e[0] not in keep]
        # yaGPC2 first, with SIGINT: that is the signal it treats as the end of
        # a run, printing its stop reason and device reports.  A TERM kills it
        # before it can.  Then everything else.
        for name, p, fh in self.procs:
            if name == "yaGPC2" and p.poll() is None:
                try:
                    p.send_signal(signal.SIGINT)
                except OSError:
                    pass
                deadline = time.time() + 10
                while p.poll() is None and time.time() < deadline:
                    time.sleep(0.1)
        for name, p, fh in reversed(self.procs):
            if p.poll() is None:
                try:
                    if os.name == "posix":
                        os.killpg(p.pid, signal.SIGTERM)
                    else:
                        p.terminate()
                except OSError:
                    pass
        deadline = time.time() + 5
        for name, p, fh in self.procs:
            while p.poll() is None and time.time() < deadline:
                time.sleep(0.1)
            if p.poll() is None:
                try:
                    if os.name == "posix":
                        os.killpg(p.pid, signal.SIGKILL)
                    else:
                        p.kill()
                except OSError:
                    pass
            fh.close()
        self.procs = kept


# WHAT THE CONTROL PORT ASKED FOR, read by the main thread.
#
# The listener cannot do the work itself.  A resume stops and restarts every
# child, and the thread holding those handles is the main one, parked in
# input(); a restart driven from a listener thread would race it.  So the
# listener records the request and wakes the main thread with SIGINT, which is
# already the "stop what you are doing" path here -- main tells the two apart
# by looking at this.
SESSION = {"action": None, "dir": None}


def session_listener(port_base, stop_event):
    """Thread: 'save DIR', 'save-and-quit DIR', 'resume DIR' and 'quit' from
    manager.py, on port base + 93."""
    try:
        sock = crewscript.session_receiver(port_base)
    except OSError as e:
        log("cannot listen for session commands: %s" % e)
        return
    sock.settimeout(0.5)
    log("session commands on port %d ('save DIR', 'save-and-quit DIR', "
        "'resume DIR', 'quit')" % (port_base + crewscript.SESSION_OFFSET))
    while not stop_event.is_set():
        try:
            data, _ = sock.recvfrom(4096)
        except socket.timeout:
            continue
        except OSError:
            return
        text = data.decode("utf-8", errors="replace").strip()
        word, _, rest = text.partition(" ")
        word, rest = word.lower(), rest.strip()
        if word not in ("save", "save-and-quit", "resume", "quit"):
            log("session command not understood: %r" % text)
            continue
        if word != "quit" and not rest:
            log("session command %s needs a directory" % word)
            continue
        SESSION["action"], SESSION["dir"] = word, rest
        log("session command: %s %s" % (word, rest))
        try:
            os.kill(os.getpid(), signal.SIGINT)
        except OSError:
            pass


def saved_epoch(snapdir):
    """The wall-clock epoch a snapshot was taken at, or None.

    Handed back to yaGPC2 as --date-time-epoch so the MEDS header clock
    CONTINUES across a restore instead of restarting.  It is the one piece of
    wall-clock time a snapshot is allowed to carry: everything inside the
    machine travels as a duration and is rebased on load, but the time of day
    is not a duration -- it is what the crew reads.
    """
    try:
        with open(os.path.join(snapdir, "vehicle.json")) as fh:
            return float(json.load(fh)["epoch"])
    except (OSError, ValueError, KeyError, TypeError):
        return None


def take_snapshot(snapdir, gpc, port_base, gpcs, expect_panel=True, timeout=20.0):
    """Bring the vehicle to a stand, write it, and say whether it worked.

    yaGPC2 does its own half on SIGUSR1: every computer parks at the
    rendezvous, each writes its own gpc<N> pair, and they all resume.  The
    panel writes its switches over its control port.  Both are asynchronous,
    so this waits for the FILES rather than for the signals -- a save that
    reports success without checking is how a half-written snapshot becomes a
    restore that silently comes up wrong.
    """
    snapdir = os.path.abspath(snapdir)
    try:
        os.makedirs(snapdir, exist_ok=True)
    except OSError as e:
        log("snapshot: cannot make %s: %s" % (snapdir, e))
        return False, "cannot make %s: %s" % (snapdir, e)
    want = []
    for g in gpcs:
        want += [os.path.join(snapdir, "gpc%d.json" % g),
                 os.path.join(snapdir, "gpc%d.mem.bin" % g)]
    panel_json = os.path.join(snapdir, "panel.json")
    if expect_panel:
        want.append(panel_json)
    # Old files first, so a stale one from a previous save cannot be mistaken
    # for a fresh one that never arrived.
    for w in want:
        try:
            os.unlink(w)
        except OSError:
            pass
    epoch = time.time()
    try:
        gpc.send_signal(signal.SIGUSR1)
    except OSError as e:
        log("snapshot: cannot signal yaGPC2: %s" % e)
        return False, "cannot signal yaGPC2: %s" % e
    crewscript.send_control("save " + panel_json, port_base)
    deadline = time.time() + timeout
    while time.time() < deadline:
        if all(os.path.isfile(w) and os.path.getsize(w) > 0 for w in want):
            break
        time.sleep(0.2)
    missing = [os.path.basename(w) for w in want
               if not (os.path.isfile(w) and os.path.getsize(w) > 0)]
    if missing:
        why = ("nothing was written at all -- the emulator may be reading a "
               "bootstrap off the tape, which cannot be captured"
               if len(missing) == len(want) else
               "missing " + ", ".join(missing))
        log("snapshot: INCOMPLETE after %.0f s -- %s; NOT usable" % (timeout, why))
        return False, why
    with open(os.path.join(snapdir, "vehicle.json"), "w") as fh:
        json.dump({"epoch": epoch, "gpcs": list(gpcs),
                   "taken": time.strftime("%Y-%m-%d %H:%M:%S",
                                          time.localtime(epoch))}, fh, indent=1)
        fh.write("\n")
    log("snapshot: written to %s" % snapdir)
    return True, ""


def running_conflicts(port_base):
    """PIDs of a previous run's programs on this port base (Linux only)."""
    if not os.path.isdir("/proc"):
        return []
    names = ("yaGPC2", "MEDS2.py", "panelO6.py", "discretePanel.py", "cam.py", "stsKeyboard.py")
    found = []
    for entry in os.listdir("/proc"):
        if not entry.isdigit() or int(entry) == os.getpid():
            continue
        try:
            with open("/proc/%s/cmdline" % entry, "rb") as fh:
                argv = [a.decode(errors="replace") for a in fh.read().split(b"\0") if a]
        except OSError:
            continue
        if not argv:
            continue
        prog = os.path.basename(argv[0])
        script = os.path.basename(argv[1]) if len(argv) > 1 else ""
        if not (prog == "yaGPC2" or (prog.startswith("python") and script in names)):
            continue
        base = 6900
        if "--port-base" in argv:
            try:
                base = int(argv[argv.index("--port-base") + 1])
            except (ValueError, IndexError):
                pass
        if base == port_base:
            found.append(int(entry))
    return found


def screen_info():
    """(scale, width, height) for window placement.

    scale is how many physical pixels one Qt device-independent pixel is:
    MEDS2.py's windows are placed in device-independent pixels, the Tk ones
    (panel, keyboard, CAM) in physical pixels.  Qt is asked directly, since
    that is what MEDS2.py uses; Tk's DPI need not agree (QT_SCALE_FACTOR, for
    one).  width and height are the PRIMARY screen in physical pixels -- Tk's
    screen size spans every monitor.  Tk is the fallback, and (1, None, None)
    if neither can answer."""
    probe = ("from PyQt6.QtWidgets import QApplication\n"
             "import sys\n"
             "a = QApplication(sys.argv[:1])\n"
             "s = a.primaryScreen(); g = s.geometry(); r = s.devicePixelRatio()\n"
             "print(r, int(g.width() * r), int(g.height() * r))\n")
    try:
        out = subprocess.run([sys.executable or "python3", "-c", probe], capture_output=True,
                             text=True, timeout=20).stdout.split()
        if len(out) >= 3:
            return max(1, int(round(float(out[0])))), int(out[1]), int(out[2])
    except Exception:
        pass
    try:
        import tkinter
        r = tkinter.Tk()
        r.withdraw()
        dpi = r.winfo_fpixels("1i")
        w, h = r.winfo_screenwidth(), r.winfo_screenheight()
        r.destroy()
        return max(1, int(round(dpi / 96.0))), w, h
    except Exception:
        return 1, None, None


WAIT_TIMEOUT_S = 600
SUBTITLE_OFFSET = 90            # subtitles.py listens on port base + this


def script_has_subtitles(path, panel):
    """Does a keys file (panel=False) or panel script (panel=True) caption?"""
    if not path:
        return False
    try:
        with open(path) as fh:
            for ln in fh:
                w = ln.split("#", 1)[0].split()
                if len(w) >= 2 and w[0][:1].isdigit() and w[1].lower() == "subtitle":
                    return True
    except OSError:
        pass
    return False


class TalkbackWatch(object):
    """The MODE talkbacks as panelO6.py logs them ('GPC2 MODE tb  BP -> RUN'),
    read by following the panel's log."""
    PATTERN = re.compile(r"GPC(\d) MODE tb\s+(\S+)\s+->\s+(\S+)")

    def __init__(self, log_path):
        self.path, self.pos, self.state = log_path, 0, {}

    def poll(self):
        try:
            with open(self.path, errors="replace") as fh:
                fh.seek(self.pos)
                data = fh.read()
                self.pos = fh.tell()
        except OSError:
            return
        for m in self.PATTERN.finditer(data):
            self.state[int(m.group(1))] = m.group(3)

    def shows(self, gpc):
        return self.state.get(gpc, "BP")


def parse_wait(words):
    """['gpc', N, 'mode-tb', STATE, ('timeout', S)] -> (N, STATE, seconds)."""
    if (len(words) not in (4, 6) or words[0].lower() != "gpc"
            or words[2].lower() != "mode-tb"):
        raise ValueError("expected 'WAIT gpc N mode-tb RUN|IPL|BP [timeout S]'")
    state = {"BARBERPOLE": "BP"}.get(words[3].upper(), words[3].upper())
    if state not in ("RUN", "IPL", "BP"):
        raise ValueError("a MODE talkback shows RUN, IPL or BP, not %r" % words[3])
    timeout = WAIT_TIMEOUT_S
    if len(words) == 6:
        if words[4].lower() != "timeout":
            raise ValueError("expected 'timeout S' after the state")
        timeout = float(words[5])
    return int(words[1]), state, timeout


def send_keys_thread(port_base, path, t0, stop_event, panel_log=None):
    kb = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    kb.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(IFACE))
    kb.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    with open(path) as fh:
        lines = [ln.split("#", 1)[0].split() for ln in fh]
    watch = TalkbackWatch(panel_log) if panel_log else None
    prev = 0.0                  # the line before's time, for '+N'
    for parts in lines:
        if not parts:
            continue
        if parts[0].upper() == "WAIT":
            try:
                gpc, state, timeout = parse_wait(parts[1:])
            except ValueError as e:
                log("keys: %s -- keys stopped: %s" % (e, " ".join(parts)))
                return
            if watch is None:
                log("keys: WAIT needs the panel's log -- keys stopped")
                return
            log("keys: waiting for GPC%d MODE tb %s" % (gpc, state))
            begun = time.time()
            while True:
                watch.poll()
                if watch.shows(gpc) == state:
                    log("keys: GPC%d MODE tb %s after %.1f s" % (gpc, state, time.time() - begun))
                    t0 = time.time()
                    prev = 0.0
                    break
                if time.time() - begun > timeout:
                    log("keys: WAIT TIMED OUT after %.0f s for GPC%d MODE tb %s -- keys stopped"
                        % (timeout, gpc, state))
                    return
                if stop_event.wait(0.2):
                    return
            continue
        # '+N' is N seconds after the line before (or the start, or the WAIT).
        at = prev + float(parts[0][1:]) if parts[0].startswith("+") else float(parts[0])
        prev = at
        while time.time() - t0 < at:
            if stop_event.wait(0.05):
                return
        if len(parts) >= 2 and parts[1].upper() == "SUBTITLE":
            text = " ".join(parts[2:])
            try:
                kb.sendto(text.encode("utf-8"), (MCAST_GROUP, port_base + SUBTITLE_OFFSET))
            except OSError as e:
                log("keys: cannot send a subtitle: %s" % e)
            log("keys at %.1f s: SUBTITLE %s" % (time.time() - t0, text or "(cleared)"))
            continue
        kbd = 1
        for key in parts[1:]:
            k = key.upper()
            if k in ("KB1", "KB2", "KB3"):
                kbd = int(k[2])          # the rest of the line on that keyboard
                continue
            idp = 1
            if k.startswith("IDP2_") or k.endswith("2") and k[:-1] in IDP_MSG:
                idp = 2
                k = k.replace("IDP2_", "IDP_") if k.startswith("IDP2_") else k[:-1]
            if k in IDP_MSG:
                kb.sendto(struct.pack(">%dH" % len(IDP_MSG[k]), *IDP_MSG[k]),
                          (MCAST_GROUP, port_base + 40 + idp))
            elif k in SCAN:
                kb.sendto(struct.pack(">H", SCAN[k]), (MCAST_GROUP, port_base + 30 + kbd))
            else:
                log("keys: unknown key %r ignored" % key)
                continue
            time.sleep(0.35)
        log("keys at %.1f s: %s" % (time.time() - t0, " ".join(parts[1:])))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter,
                                 epilog="crew script commands (--script FILE):\n"
                                        + crewscript.HELP)
    ap.add_argument("--snapshot-dir", metavar="DIR", default=None,
                    help="where Save writes, and the default Restore reads "
                         "(default: <logs>/snapshot).  A snapshot is a "
                         "directory: gpc<N>.json and gpc<N>.mem.bin per "
                         "computer, panel.json, and vehicle.json")
    ap.add_argument("--snapshot-resume", metavar="DIR", default=None,
                    help="start from this snapshot instead of IPLing: each "
                         "computer loads its own pair, the panel comes up with "
                         "the switches it had, and the MEDS clock continues")
    ap.add_argument("--gpcs", type=parse_gpcs, default=[1], metavar="LIST",
                    help="which GPCs: 1 (default), 1,2, 1-3, 1-4")
    ap.add_argument("--tape", metavar="FILE",
                    help="the mass memory volume (.mmv); both units hold it.  Default "
                         "$NSTS_PASS_TAPE, or OI340700-OPS0.mmv beside this program")
    ap.add_argument("--size", type=int, default=512, metavar="PX",
                    help="MDU size; the panel, keyboard and CAM scale with it (default 512)")
    ap.add_argument("--scale", type=float, default=0.8, metavar="F",
                    help="MEDS2.py text size factor (default 0.8)")
    ap.add_argument("--crts", type=int, choices=(1, 2, 3, 4), default=None,
                    help="display windows CRT1 up to CRT4: 1-4 (default 2 with more than "
                         "one GPC, else 1).  CRT4 is the aft display, on IDP 4 and the aft "
                         "keyboard")
    ap.add_argument("--keyboards", type=int, choices=(0, 1, 2, 3), default=None,
                    help="stsKeyboard.py windows: 3 the left, right and aft keyboards; "
                         "2 the forward pair; 1 the left; 0 none.  Default: the ones the "
                         "CRTs can use -- 1 with --crts 1, 2 with --crts 2 or 3, 3 with "
                         "--crts 4 (the aft keyboard reaches only CRT4).  Which IDP each "
                         "forward keyboard reaches is panel C2's IDP/CRT SEL")
    ap.add_argument("--title", metavar="TEXT",
                    help="display window title (default: GPCs <list>)")
    ap.add_argument("--major-func", choices=sorted(MAJOR_FUNC), default="GNC",
                    help="the IDP MAJ FUNC switch at start (default GNC)")
    ap.add_argument("--port-base", type=int, default=6900, metavar="N",
                    help="bus port base for every program (default 6900)")
    ap.add_argument("--yagpc-extra", metavar="ARGS", default="",
                    help="extra yaGPC2 options, quoted as one string, e.g. "
                         "\"--barrier-spin-us 50 --rt-idle-poll-ms 2\"")
    ap.add_argument("--yagpc", metavar="PATH",
                    help="the yaGPC2 executable (default ../yaGPC2/yaGPC2)")
    ap.add_argument("--logs", metavar="DIR", default="simulatePASS-logs",
                    help="where the logs go (default ./simulatePASS-logs)")
    ap.add_argument("--window-scale", type=int, metavar="N",
                    help="physical pixels per Qt pixel, for window placement (default: "
                         "from the screen's DPI)")
    ap.add_argument("--no-keyboard", action="store_true", help="no stsKeyboard.py "
                    "(--keyboards 0)")
    ap.add_argument("--instructions", action="store_true",
                    help="print the switch-and-keyboard steps for these --gpcs and --crts, "
                         "and exit without starting anything")
    ap.add_argument("--procedure", dest="instructions", action="store_true",
                    help=argparse.SUPPRESS)          # the old name
    ap.add_argument("--show-panel", action="store_true",
                    help="show panelO6's window during a --script run (for demonstrations)")
    ap.add_argument("--wait-user", action="store_true",
                    help="hold the --script until someone clicks in panelO6's window, as if "
                         "it began with 'wait user'; shows the panel too")
    ap.add_argument("--script", "--panel-script", dest="panel_script", metavar="FILE",
                    help="crew script for panelO6.py: switches, keys, subtitles and waits "
                         "in one file (commands below)")
    ap.add_argument("--manager", dest="manager", action="store_true", default=True,
                    help="a small control window (manager.py) to play a script at any "
                         "moment, save and restore the window layout, and start the "
                         "caption box (the default)")
    ap.add_argument("--no-manager", dest="manager", action="store_false",
                    help="no control window")
    ap.add_argument("--layout", metavar="FILE",
                    help="put the windows where this layout file says once they are up "
                         "(windowLayout.py save FILE writes one).  If it names the caption "
                         "box and none is running, one is started first: subtitles.py "
                         "--font-size 14 --bg #404040 --edit")
    ap.add_argument("--keys", metavar="FILE", help="timed keystrokes (see above)")
    ap.add_argument("--duration", type=float, metavar="SECONDS",
                    help="shut down after this long instead of waiting for Enter")
    args = ap.parse_args()
    gpcs = args.gpcs
    multi = len(gpcs) > 1
    if args.crts is None:
        args.crts = 2 if multi else 1
    if args.keyboards is None:
        # Only keyboards that can reach a display: the right one reaches IDP 2
        # or 3, the aft one only IDP 4.
        args.keyboards = {1: 1, 2: 2, 3: 2, 4: 3}[args.crts]
    if args.no_keyboard:
        args.keyboards = 0

    if args.instructions:
        print(procedure_text(gpcs, args.crts))
        return 0

    # A crew script with a mistake stops panelO6.py as it starts, which left
    # everything else running without a panel.  Read it here first, with the
    # same parser, and start nothing if it is wrong.
    if args.panel_script:
        try:
            with open(args.panel_script) as fh:
                crewscript.parse(fh.read(), args.panel_script)
        except (OSError, crewscript.ScriptError) as e:
            sys.exit("simulatePASS: %s: %s -- nothing started" % (args.panel_script, e))

    # Likewise a layout: read it now, so a bad one does not surface after
    # everything is running.
    layout_roles = []
    windows_before = set()
    if args.layout:
        try:
            layout_roles = windowLayout.roles_in(args.layout)
        except (OSError, ValueError, KeyError) as e:
            sys.exit("simulatePASS: %s: %s -- nothing started" % (args.layout, e))
        # What is already on screen, so this run places ITS OWN windows and
        # never another simulation's (they are named the same).
        windows_before = windowLayout.window_ids()

    tape = args.tape or os.environ.get("NSTS_PASS_TAPE") or os.path.join(HERE, "OI340700-OPS0.mmv")
    tape = os.path.abspath(tape)
    # A RESTORED RUN NEVER READS THE TAPE.  Every computer comes up from its
    # own half of the snapshot, already past its IPL, so demanding a volume
    # here would refuse a resume on a machine that has the snapshot and not
    # the build it came from.  The name is still carried, for the manager's
    # status line and so a Save records what the run was.
    if not os.path.isfile(tape) and not args.snapshot_resume:
        sys.exit("simulatePASS: no volume %s -- give --tape FILE" % tape)
    exe = args.yagpc or os.path.join(YAGPC_DIR, "yaGPC2.exe" if os.name == "nt" else "yaGPC2")
    if not os.path.isfile(exe):
        sys.exit("simulatePASS: no yaGPC2 at %s -- build it (make, in %s) or give --yagpc"
                 % (exe, YAGPC_DIR))
    for script in ("MEDS2.py", "panelO6.py", "stsKeyboard.py", "cam.py"):
        if not os.path.isfile(os.path.join(HERE, script)):
            sys.exit("simulatePASS: %s is missing from %s" % (script, HERE))

    busy = running_conflicts(args.port_base)
    if busy:
        sys.exit("simulatePASS: a previous run is still up on port base %d (pid %s); close it "
                 "first -- two panels on one discrete bus make a GPC flap between HALT and RUN"
                 % (args.port_base, " ".join(map(str, busy))))
    try:
        with open("/proc/sys/net/core/rmem_max") as fh:
            if int(fh.read()) < 4194304:
                log("WARNING: net.core.rmem_max is small and MEDS2 will drop display fills:"
                    "  sudo sysctl -w net.core.rmem_max=8388608")
    except (OSError, ValueError):
        pass

    logs = os.path.abspath(args.logs)
    os.makedirs(logs, exist_ok=True)
    old = [f for f in os.listdir(logs) if f.endswith(".log")]
    if old:
        prev = os.path.join(logs, "prev-" + datetime.datetime.now().strftime("%m%d-%H%M%S"))
        os.makedirs(prev)
        for f in old:
            shutil.move(os.path.join(logs, f), prev)
        log("previous run's logs -> %s" % prev)

    # -- window placement ----------------------------------------------------
    ws_auto, screen_w, screen_h = screen_info()
    ws = args.window_scale or ws_auto
    size = args.size
    # MEDS2's IDP pane, in Qt pixels: hidden unless NSTS_MDU_PANE=1, since
    # panelO6.py has those switches.
    pane = int(round(180.0 * size / 768 / ws)) if os.environ.get("NSTS_MDU_PANE") == "1" else 0
    mdu_w = size + pane + 16                               # Qt pixels
    crt_pos = [(k * (mdu_w + 32), 0) for k in range(args.crts)]
    right = args.crts * (mdu_w + 32) * ws + 20             # physical pixels
    kb_w = int(round(509.0 * size / 768))
    o6_w = int(round(1684.0 * size / 768))                 # panelO6.py REF_W, with C2
    kb_side_by_side = True
    kbs_w = args.keyboards * (kb_w + 20)
    kb_geom = "+%d+0" % right
    o6_geom = "+%d+0" % (right + kbs_w)
    cam_x = right + kbs_w + o6_w + 20
    cam_geom = "+%d+0" % cam_x
    cam_size = int(round(size * 0.75))
    # SIDE BY SIDE IF IT FITS, AND OTHERWISE DON'T TRY HARD.  Several full
    # windows rarely fit one screen; when they don't, each kind of window gets
    # a stack of its own (below), so every title bar can still be grabbed.
    need_w = cam_x + (int(round(528.0 * cam_size / 512)) if len(gpcs) > 1 else -20)
    # An MDU window is the display plus MEDS2's edgekey strip under it
    # (EDGE_STRIP_K = 0.09 of the display's width) plus its frame.
    edge_h = int(round(0.09 * size)) if os.environ.get("NSTS_MDU_EDGEKEYS") != "0" else 0
    need_h = max(int(round(1300.0 * size / 768)), (size + edge_h + 40) * ws)   # panelO6 REF_H
    if screen_w is not None and (need_w > screen_w or need_h > screen_h):
        # One cascading STACK per kind of window -- the displays together, the
        # keyboard, the panel, the CAM -- the stacks left to right, each pulled
        # back onto the screen if it would run off the right edge (and so
        # possibly over the one before; there is no room, and that is fine).
        log("the windows do not fit side by side on a %dx%d screen; stacking them by kind"
            % (screen_w, screen_h))
        step = 60
        cam_w = int(round(528.0 * cam_size / 512))

        def stack_x(x, width):
            return max(0, min(x, screen_w - width))

        x = 0
        crt_pos = [(k * step // ws, k * step // ws) for k in range(args.crts)]
        x += mdu_w * ws + (args.crts - 1) * step + 20
        if args.keyboards:
            kx = stack_x(x, kb_w + (args.keyboards - 1) * 60)
            kb_geom = "+%d+0" % kx
            kb_side_by_side = False
            x = kx + kb_w + (args.keyboards - 1) * 60 + 20
        ox = stack_x(x, o6_w)
        o6_geom = "+%d+0" % ox
        x = ox + o6_w + 20
        cam_geom = "+%d+0" % stack_x(x, cam_w)

    env = dict(os.environ)
    env["NSTS_MAJOR_FUNC"] = str(MAJOR_FUNC[args.major_func])
    # How far apart in simulated time the computers may drift.  25 us is what
    # every verified multi-GPC run used through OPS 2; the built-in 200 has not
    # been.  An explicit YAGPC_BARRIER_US in the environment still wins.
    env.setdefault("YAGPC_BARRIER_US", "25")
    # Unbuffered, so each program's log shows what it said when it said it.
    py = sys.executable or "python3"
    env["PYTHONUNBUFFERED"] = "1"
    # Armed on every run so that Save works at any moment.  Beside the logs by
    # default, because that is already the directory this run owns.
    snapshot_dir = os.path.abspath(args.snapshot_dir
                                   or os.path.join(logs, "snapshot"))
    try:
        os.makedirs(snapshot_dir, exist_ok=True)
    except OSError as e:
        raise SystemExit("simulatePASS: cannot make %s: %s" % (snapshot_dir, e))
    if args.snapshot_resume and not os.path.isdir(args.snapshot_resume):
        raise SystemExit("simulatePASS: --snapshot-resume %s is not a directory"
                         % args.snapshot_resume)
    L = Launcher(logs)
    stop_event = threading.Event()
    try:
        # EVERY CHILD BUT THE MANAGER, IN ONE PLACE, so that a resume can
        # run it again.  A restore is always fresh processes -- the pacer
        # takes its baseline from the CPU clock, panelO6 seeds its switches
        # before it publishes, and cam.py only rebuilds its matrix because a
        # new yaGPC2 has its discrete values zeroed and so its first publish
        # is a CHANGE.  None of that can be arranged in a running process.
        #
        # The manager is deliberately NOT in here: it is the window the
        # person is clicking, and it stays up across a resume.
        def bring_up(resume=None):
            title = args.title or "GPC%s %s" % ("s" if multi else "", ",".join(map(str, gpcs)))
            for k in range(args.crts):
                e = dict(env)
                e["NSTS_MDU_POS"] = "%d,%d" % crt_pos[k]
                L.start("meds%d" % (k + 1),
                        [py, "MEDS2.py", "--port-base", str(args.port_base), "--size", str(size),
                         "--scale", str(args.scale), "--title", title,
                         "crt%d" % (k + 1), "idp%d" % (k + 1)], HERE, e)
                time.sleep(1)
            if args.keyboards:
                for k in range(args.keyboards):
                    kx, ky = kb_geom.lstrip("+").split("+")
                    geom = "+%d+%d" % (int(kx) + k * (kb_w + 20 if kb_side_by_side else 60),
                                       int(ky) + (0 if kb_side_by_side else k * 60))
                    L.start("keyboard%d" % (k + 1),
                            [py, "stsKeyboard.py", "--kybd", str(k + 1), "--title",
                             str(k + 1), "--port-base",
                             str(args.port_base), "--size", str(size), "--geometry", geom],
                            HERE, env)
            if multi:
                L.start("cam", [py, "cam.py", "--port-base", str(args.port_base),
                                "--size", str(cam_size), "--geometry", cam_geom],
                        HERE, env)
            gpc_argv = [exe, "run"]
            # A RESTORED MACHINE IS PAST ITS IPL, so it is given the snapshot
            # instead of the tape: --resume makes each computer load its own
            # gpc<N> pair out of the directory.  --date-time-epoch is what
            # carries GMT across, and it needs no C at all -- the MEDS header
            # clock is anchored to it, so handing back the epoch recorded at
            # capture makes the display continue rather than restart.
            if resume:
                gpc_argv += ["--resume", os.path.abspath(resume)]
                epoch = saved_epoch(resume)
                if epoch is not None:
                    gpc_argv += ["--date-time-epoch", "%.3f" % epoch]
            elif multi:
                gpc_argv += ["--mmu-model", "1:" + tape, "--mmu-model", "2:" + tape,
                             "--gpcs", ",".join(map(str, gpcs))]
            else:
                gpc_argv += ["--mmu-model", tape, "--gpc-id", str(gpcs[0])]
            if resume and multi:
                gpc_argv += ["--gpcs", ",".join(map(str, gpcs))]
            elif resume:
                gpc_argv += ["--gpc-id", str(gpcs[0])]
            # --rt-idle-timeout is in MILLISECONDS and ends the run if a computer
            # sits in a wait state that long; a session must never trip it.
            # Always armed, so Save works at any moment without having been
            # asked for at start-up.  It costs nothing until SIGUSR1 arrives.
            gpc_argv += ["--snapshot", snapshot_dir]
            gpc_argv += ["--mtu-model", "--discretes", "--bce-network", "--real-time",
                         "--rt-factor", "1", "--port-base", str(args.port_base),
                         "--no-halucp-svc", "--max-steps", "0", "--rt-idle-timeout", "86400000",
                         "--verbose"] + shlex.split(args.yagpc_extra)
            gpc = L.start("yaGPC2", gpc_argv, YAGPC_DIR, env)
            time.sleep(3)
            if ((script_has_subtitles(args.keys, False)
                 or script_has_subtitles(args.panel_script, True))
                    and "subtitles" not in layout_roles):
                log("note: the script has captions; start the caption box yourself: "
                    "python3 subtitles.py --port-base %d" % args.port_base)
            # BEFORE THE PANEL PUBLISHES ANYTHING.  panelO6 seeds its switches
            # from this between construction and its first publish; without it
            # a panel coming up beside a restored vehicle would assert POWER
            # OFF and MODE HALT within a quarter second and halt it.
            panel_restore = os.path.join(resume, "panel.json") if resume else None
            panel_argv = [py, "panelO6.py", "--port-base", str(args.port_base),
                          "--gpc-id", str(gpcs[0]), "--size", str(size), "--geometry", o6_geom]
            if panel_restore and os.path.isfile(panel_restore):
                panel_argv += ["--restore", panel_restore]
            if args.wait_user and not args.panel_script:
                log("note: --wait-user holds a --script, and there is none; ignored")
            if args.panel_script:
                panel_argv += ["--script", os.path.abspath(args.panel_script)]
                if args.show_panel:
                    panel_argv += ["--show"]
                if args.wait_user:
                    panel_argv += ["--wait-user"]
                try:
                    with open(args.panel_script) as fh:
                        waits_for_user = args.wait_user or crewscript.has_wait_user(fh.read())
                except OSError:
                    waits_for_user = args.wait_user
                if waits_for_user and args.duration:
                    log("note: the script has a 'wait user', and --duration counts from "
                        "start-up -- including the time spent waiting")
            L.start("panel", panel_argv, HERE, env)
            return gpc
        gpc = bring_up(args.snapshot_resume)
        t0 = time.time()

        if args.manager:
            # IT COULD NOT REPORT THE CONFIGURATION BEFORE.  manager.py was
            # given only the port base, so it could not say how many GPCs
            # were up or which tape was loaded -- a gap in its own right,
            # and one Save/Restore would have tripped over.
            manager_argv = [py, "manager.py", "--port-base", str(args.port_base),
                            "--gpcs", ",".join(map(str, gpcs)),
                            "--crts", str(args.crts),
                            "--tape", tape,
                            "--snapshot-dir", snapshot_dir]
            if args.panel_script:
                manager_argv += ["--script", os.path.abspath(args.panel_script)]
            if args.layout:
                manager_argv += ["--layout", os.path.abspath(args.layout)]
            L.start("manager", manager_argv, HERE, env)

        # THE WINDOWS WHERE THEY WERE PUT LAST TIME.  A run does not start the
        # caption box of its own accord (no size or place suits every
        # recording), but a layout that names it says where it goes, so one is
        # started here if none is up.
        #
        # A function, because a resume destroys and recreates every window but
        # the manager's, so they all have to be placed again.
        def place_windows(windows_before):
            if not args.layout:
                return
            mine_now = windowLayout.window_ids() - windows_before
            if ("subtitles" in layout_roles
                    and not windowLayout.has_role("subtitles", mine_now)):
                # The look the layout was saved with, if it has one; failing
                # that, something legible on a dark background.
                look = (windowLayout.look_in(args.layout)
                        or ["--font-size", "14", "--bg", "#404040"])
                if "--edit" not in look:
                    look = look + ["--edit"]      # so it can be adjusted in place
                L.start("subtitles",
                        [py, "subtitles.py", "--port-base", str(args.port_base)] + look,
                        HERE, env)
            deadline = time.time() + 12
            while time.time() < deadline:
                mine = windowLayout.window_ids() - windows_before
                roles = {w["role"] for w in windowLayout.windows() if w["id"] in mine}
                if all(r in roles for r in layout_roles):
                    break
                time.sleep(0.5)
            time.sleep(1.5)        # let the window manager finish placing them
            mine = windowLayout.window_ids() - windows_before
            log("placing this run's windows as %s says" % args.layout)
            windowLayout.restore_layout(args.layout, log=log, only_ids=mine)

        place_windows(windows_before)
        threading.Thread(target=session_listener,
                         args=(args.port_base, stop_event), daemon=True).start()
        if args.keys:
            threading.Thread(target=send_keys_thread,
                             args=(args.port_base, os.path.abspath(args.keys), t0, stop_event,
                                   os.path.join(logs, "panel.log")),
                             daemon=True).start()

        # Not the steps themselves: they are long, and the programs' output
        # would scroll them away while they are being read.
        log("for the steps: python3 simulatePASS.py --gpcs %s --crts %d --instructions"
            % (",".join(map(str, gpcs)), args.crts))
        # ROUND AGAIN AFTER A RESUME.  Save and Restore arrive on the control
        # port at a moment nothing here can predict, and the listener wakes
        # this thread with SIGINT because it is already parked in input().
        # Ctrl-C and a plain Enter still mean "shut it all down"; they are
        # told apart by whether the listener left a request behind.
        while True:
            try:
                if args.duration:
                    log("running for %.0f s" % args.duration)
                    while time.time() - t0 < args.duration and gpc.poll() is None:
                        time.sleep(0.5)
                else:
                    print("Everything is up.  Press Enter here to shut it all "
                          "down (Ctrl-C also works).")
                    try:
                        input()
                    except EOFError:
                        while gpc.poll() is None and SESSION["action"] is None:
                            time.sleep(0.5)
            except KeyboardInterrupt:
                print()
            action, snapdir = SESSION["action"], SESSION["dir"]
            SESSION["action"] = SESSION["dir"] = None
            if action in ("save", "save-and-quit"):
                ok, why = take_snapshot(snapdir, gpc, args.port_base, gpcs)
                # BACK TO WHOEVER ASKED.  A failure that only reaches this
                # terminal is a failure nobody sees: the manager window exists
                # so that nobody has to watch this terminal.
                crewscript.send_result(
                    ("ok %s %s" % (action, snapdir)) if ok
                    else ("fail %s %s" % (action, why)), args.port_base)
                if action == "save" or not ok:
                    # A FAILED save-and-quit DOES NOT QUIT.  The whole point of
                    # writing before tearing anything down is that the
                    # destructive half only runs once the safe half succeeded.
                    if not ok and action == "save-and-quit":
                        log("save-and-quit: the snapshot failed, so the run is "
                            "STILL UP -- nothing was torn down")
                    continue
                break
            if action == "resume":
                if not os.path.isdir(snapdir):
                    log("resume: %s is not a directory; the run is untouched"
                        % snapdir)
                    crewscript.send_result(
                        "fail resume %s is not a directory" % snapdir,
                        args.port_base)
                    continue
                log("resume: replacing every child but the manager from %s"
                    % snapdir)
                before = windowLayout.window_ids()
                L.stop(keep={"manager"})
                gpc = bring_up(snapdir)
                t0 = time.time()
                place_windows(before)
                crewscript.send_result("ok resume %s" % snapdir, args.port_base)
                continue
            break
        if gpc.poll() is not None:
            log("yaGPC2 has exited (code %s); see %s" % (gpc.returncode,
                                                        os.path.join(logs, "yaGPC2.log")))
    except KeyboardInterrupt:
        print()
    finally:
        stop_event.set()
        log("shutting down")
        L.stop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
