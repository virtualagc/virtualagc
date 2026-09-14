#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Run the Space Shuttle flight software on one to four simulated GPCs, with
the crew station around them: MEDS2.py displays, the stsKeyboard.py DPS
keyboards, the panelO6.py GPC and IDP panel, and -- with more than one computer --
cam.py's GPC STATUS lamps.  yaGPC2 is the computer.

    python3 simulatePASS.py --tape OI340700-v44boot.mmv
    python3 simulatePASS.py --gpcs 1,2 --tape OI340700-v44boot.mmv
    python3 simulatePASS.py --gpcs 1-3 --tape ... --size 640 --scale 0.9
    python3 simulatePASS.py --gpcs 1,2 --procedure     # just the steps

Once everything is up it prints the switch-and-keyboard procedure for the
computers you named.  Press Enter in this terminal (or Ctrl-C) to shut it all
down.  Each program's output goes to a log in --logs; the previous run's are
kept in a prev-<time> directory there.

With one GPC the procedure is retest-crt2.sh's; with several, the order the
scripted two-, three- and four-computer runs verified through OPS 2.

UNATTENDED RUNS.  --panel-script hands panelO6.py a timed script ('<ms>
<command>' per line; 'gpc <n>' picks the column, and 'idppower N on|off',
'majfunc N GNC|SM|PL', 'kybdsel left 1|3', 'kybdsel right 2|3' and 'idpload N'
work the IDP switches), --keys a file of '<seconds> KEY KEY ...' lines typed on
a keyboard bus (keys as on the keyboard: ITEM EXEC OPS PRO SPEC RESUME CLEAR +
- . 0-9 A-F; KB1, KB2 or KB3 sends the rest of the line on the left, right or
aft keyboard, KB1 by default; also IDP_POWER_ON, IDP_POWER_OFF and DEU_LOAD for
IDP 1 and IDP2_POWER_ON, IDP2_POWER_OFF and DEU_LOAD2 for IDP 2, which the panel
follows as if its switches had been thrown), and --duration ends the run after
that many seconds.  Key and panel times both count from when the panel starts.
"""

import argparse
import datetime
import os
import shutil
import signal
import socket
import struct
import subprocess
import sys
import threading
import time

HERE = os.path.dirname(os.path.abspath(__file__))
YAGPC_DIR = os.path.normpath(os.path.join(HERE, "..", "yaGPC2"))
MCAST_GROUP = "239.255.1.1"
IFACE = os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")

# DPS keyboard scan codes (stsKeyboard.py's SCAN, from MEDS2.py's KYBD.DEUKey).
SCAN = {
    "FAULT_SUMM": 0xFFE1, "SYS_SUMM": 0xFFE9, "MSG_RESET": 0xFFF1, "ACK": 0xFFF9,
    "GPC/CRT": 0xFFC1, "A": 0xFFC9, "B": 0xFFD1, "C": 0xFFD9,
    "I/O_RESET": 0xFF3A, "D": 0xFF7A, "E": 0xFFBA, "F": 0xFFFA,
    "ITEM": 0xFE3A, "1": 0xFE7A, "2": 0xFEFB, "3": 0xFEFA,
    "EXEC": 0xF9FB, "4": 0xFBFB, "5": 0xFDFB, "6": 0xFFFB,
    "OPS": 0xF1FB, "7": 0xF3FB, "8": 0xF5FB, "9": 0xF7FB,
    "SPEC": 0xCFFC, "-": 0xDFFC, "0": 0xEFFC, "+": 0xFFFC,
    "RESUME": 0x8FFC, "CLEAR": 0x9FFC, ".": 0xAFFC, "PRO": 0xBFFC,
}
# MDU -> IDP messages on an _IDPn bus (MEDS2.py's MDUMsg): IDP POWER and IDP
# LOAD, which panelO6.py's C2 and O6 switches send and follow.
IDP_MSG = {"DEU_LOAD": (0x0002,), "IDP_POWER_ON": (0x0003, 1), "IDP_POWER_OFF": (0x0003, 0)}
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
    L.append("PROCEDURE for GPC%s %s" % ("s" if n > 1 else "", ", ".join(map(str, g))))
    L.append("-" * 72)
    L.append("")
    L.append("The IDP switches are on panelO6: panel C2 (IDP/CRT POWER and MAJ FUNC, and the")
    L.append("two IDP/CRT SEL switches) and O6 (INTEGRATED DISPLAY PROCESSOR LOAD).  The")
    L.append("LEFT keyboard (KYBD1) reaches IDP 1 or 3, the RIGHT keyboard (KYBD2) IDP 2 or 3.")
    L.append("The box at the foot of a DPS page names its IDP, with a red bar beside it for")
    L.append("the left keyboard and a yellow one for the right; the digit before the time in")
    L.append("the page header is the GPC driving it.")
    L.append("")
    L.append("BEFORE ANY IPL")
    L.append("  a. C2: IDP/CRT %s POWER -> ON, MAJ FUNC -> GNC  (\"MDU IS AUTONOMOUS\" goes)."
             % ", ".join(str(k) for k in range(1, min(crts, 3) + 1)))
    if crts == 4:
        L.append("     R11 (under O6's IDP LOAD): IDP/CRT 4 POWER -> ON, MAJ FUNC -> GNC.")
    L.append("  b. C2: LEFT IDP/CRT SEL -> 1, RIGHT IDP/CRT SEL -> 2.")
    L.append("  c. panelO6: MODE -> HALT for %s." % ("GPC%d" % g[0] if n == 1 else
                                                   "every GPC column in use"))
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
        steps += ["GPC%d column: press and release IPL" % gpc,
                  "GPC%d MODE -> STBY, then about 15 s later -> RUN" % gpc,
                  "wait for the GPCIPL MENU on CRT%d (\"GPCIPL MENU (1)  %d\"; its clock counts"
                  "\n      up from 000/00:00:00)" % (crt, gpc),
                  "on the %s keyboard: ITEM 1 EXEC  (the system software loads: the MM1 lamp"
                  "\n      flickers red)" % kb,
                  "when the MM1 lamp has stayed green (roughly 80 s after ITEM 1 EXEC):"
                  "\n      BFC CRT DISPLAY -> OFF, then IPL SOURCE -> OFF.  GPC%d now runs PASS"
                  "\n      OPS 0; leave its switches alone from here on.%s"
                  % (gpc, "" if crt == 1 else
                     "  GPC%d takes CRT2 back:\n      both CRTs show its GPC MEMORY page"
                     " until OPS 2." % g[0])]
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

    def stop(self):
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
        self.procs = []


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


def send_keys_thread(port_base, path, t0, stop_event):
    kb = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    kb.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(IFACE))
    kb.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    with open(path) as fh:
        lines = [ln.split("#", 1)[0].split() for ln in fh]
    for parts in lines:
        if not parts:
            continue
        at = float(parts[0])
        while time.time() - t0 < at:
            if stop_event.wait(0.05):
                return
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
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
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
    ap.add_argument("--keyboards", type=int, choices=(0, 1, 2, 3), default=3,
                    help="stsKeyboard.py windows: 3 (default) the left, right and aft "
                         "keyboards; 2 the forward pair; 1 the left; 0 none.  Which IDP "
                         "each forward keyboard reaches is panel C2's IDP/CRT SEL")
    ap.add_argument("--title", metavar="TEXT",
                    help="display window title (default: GPCs <list>)")
    ap.add_argument("--major-func", choices=sorted(MAJOR_FUNC), default="GNC",
                    help="the IDP MAJ FUNC switch at start (default GNC)")
    ap.add_argument("--port-base", type=int, default=6900, metavar="N",
                    help="bus port base for every program (default 6900)")
    ap.add_argument("--yagpc", metavar="PATH",
                    help="the yaGPC2 executable (default ../yaGPC2/yaGPC2)")
    ap.add_argument("--logs", metavar="DIR", default="simulatePASS-logs",
                    help="where the logs go (default ./simulatePASS-logs)")
    ap.add_argument("--window-scale", type=int, metavar="N",
                    help="physical pixels per Qt pixel, for window placement (default: "
                         "from the screen's DPI)")
    ap.add_argument("--no-keyboard", action="store_true", help="no stsKeyboard.py "
                    "(--keyboards 0)")
    ap.add_argument("--procedure", action="store_true", help="print the procedure and exit")
    ap.add_argument("--panel-script", metavar="FILE", help="timed script for panelO6.py")
    ap.add_argument("--keys", metavar="FILE", help="timed keystrokes (see above)")
    ap.add_argument("--duration", type=float, metavar="SECONDS",
                    help="shut down after this long instead of waiting for Enter")
    args = ap.parse_args()
    gpcs = args.gpcs
    multi = len(gpcs) > 1
    if args.crts is None:
        args.crts = 2 if multi else 1
    if args.no_keyboard:
        args.keyboards = 0

    if args.procedure:
        print(procedure_text(gpcs, args.crts))
        return 0

    tape = args.tape or os.environ.get("NSTS_PASS_TAPE") or os.path.join(HERE, "OI340700-OPS0.mmv")
    tape = os.path.abspath(tape)
    if not os.path.isfile(tape):
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
    need_h = max(int(round(1250.0 * size / 768)), (size + 40) * ws)
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
    L = Launcher(logs)
    stop_event = threading.Event()
    try:
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
                         "KYBD%d (%s)" % (k + 1, ("left", "right", "aft")[k]), "--port-base",
                         str(args.port_base), "--size", str(size), "--geometry", geom],
                        HERE, env)
        if multi:
            L.start("cam", [py, "cam.py", "--port-base", str(args.port_base),
                            "--size", str(cam_size), "--geometry", cam_geom],
                    HERE, env)
        gpc_argv = [exe, "run"]
        if multi:
            gpc_argv += ["--mmu-model", "1:" + tape, "--mmu-model", "2:" + tape,
                         "--gpcs", ",".join(map(str, gpcs))]
        else:
            gpc_argv += ["--mmu-model", tape, "--gpc-id", str(gpcs[0])]
        # --rt-idle-timeout is in MILLISECONDS and ends the run if a computer
        # sits in a wait state that long; a session must never trip it.
        gpc_argv += ["--mtu-model", "--discretes", "--bce-network", "--real-time",
                     "--rt-factor", "1", "--port-base", str(args.port_base),
                     "--no-halucp-svc", "--max-steps", "0", "--rt-idle-timeout", "86400000",
                     "--verbose"]
        gpc = L.start("yaGPC2", gpc_argv, YAGPC_DIR, env)
        time.sleep(3)
        panel_argv = [py, "panelO6.py", "--port-base", str(args.port_base),
                      "--gpc-id", str(gpcs[0]), "--size", str(size), "--geometry", o6_geom]
        if args.panel_script:
            panel_argv += ["--script", os.path.abspath(args.panel_script)]
        L.start("panel", panel_argv, HERE, env)
        t0 = time.time()
        if args.keys:
            threading.Thread(target=send_keys_thread,
                             args=(args.port_base, os.path.abspath(args.keys), t0, stop_event),
                             daemon=True).start()

        print()
        print(procedure_text(gpcs, args.crts))
        print()
        if args.duration:
            log("running for %.0f s" % args.duration)
            while time.time() - t0 < args.duration and gpc.poll() is None:
                time.sleep(0.5)
        else:
            print("Everything is up.  Press Enter here to shut it all down (Ctrl-C also works).")
            try:
                input()
            except EOFError:
                while gpc.poll() is None:
                    time.sleep(0.5)
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
