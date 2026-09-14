#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Run the Space Shuttle flight software on one to four simulated GPCs, with
the crew station around them: MEDS2.py displays, the stsKeyboard.py DPS
keyboard, the panelO6.py GPC panel, and -- with more than one computer --
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
<command>' per line; 'gpc <n>' picks the column), --keys a file of
'<seconds> KEY KEY ...' lines typed on the keyboard bus (keys as on the
keyboard: ITEM EXEC OPS PRO SPEC RESUME CLEAR + - . 0-9 A-F; also IDP_POWER_ON,
IDP_POWER_OFF and DEU_LOAD, which work CRT1's IDP pane), and --duration ends
the run after that many seconds.  Key and panel times both count from when
the panel starts.
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
# MDU -> IDP messages on the _IDP1 bus (MEDS2.py's MDUMsg), for IDP1's pane.
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
    L.append("BEFORE ANY IPL")
    L.append("  a. CRT1's pane: IDP POWER -> ON (the MDU leaves \"MDU IS AUTONOMOUS\").")
    L.append("  b. The MDU title shows MF GNC; if not, click the MDU and press Shift+2.")
    L.append("  c. panelO6: MODE -> HALT for %s." % ("GPC%d" % g[0] if n == 1 else
                                                   "every GPC column in use"))
    L.append("")
    if n == 1:
        gpc = g[0]
        L += [
            "IPL GPC%d" % gpc,
            "  1. BFC CRT select -> CRT 1",
            "  2. IPL SOURCE -> MMU 1",
            "  3. GPC%d column: press and release IPL" % gpc,
            "  4. GPC%d MODE -> STBY" % gpc,
            "     ... the GPCIPL MENU appears on CRT1 and loads the display.  Wait.",
            "  5. On the keyboard: ITEM 1 EXEC   (the system software loads, ~1 minute)",
            "  6. BFC CRT select -> none          (after the load, before RUN)",
            "  7. GPC%d MODE -> RUN" % gpc,
            "  8. IPL SOURCE -> OFF               (after RUN)",
            "",
            "TO RE-IPL: IPL SOURCE -> MMU 1, BFC CRT -> CRT 1, MODE -> HALT, push",
            "DEU LOAD on CRT1's pane, press IPL, MODE -> STBY, and on from step 4.",
        ]
        return "\n".join(L)
    for i, gpc in enumerate(g):
        mm = "MMU 1" if i % 2 == 0 else "MMU 2"
        L.append("IPL GPC%d  (from %s)" % (gpc, mm))
        steps = ["IPL SOURCE -> %s" % mm, "BFC CRT select -> CRT 1"]
        if i > 0:
            steps.append("CRT1's pane: push and release DEU LOAD  (GPC%d already loaded that "
                         "display;\n      without this GPC%d's menu never appears)" % (g[0], gpc))
        steps += ["GPC%d column: press and release IPL" % gpc,
                  "GPC%d MODE -> STBY, then about 15 s later -> RUN" % gpc,
                  "wait for the GPCIPL MENU on CRT1 (its clock counts up from 000/00:00:00)",
                  "on the keyboard: ITEM 1 EXEC  (the system software loads)",
                  "about 80 s after ITEM 1 EXEC: BFC CRT select -> none, then IPL SOURCE -> OFF"]
        for k, s in enumerate(steps, 1):
            L.append("  %d. %s" % (k, s))
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
    L.append("THE NBAT, on CRT1 (PASS on GPC%d drives it now).  Each line ends in EXEC." % g[0])
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
    if crts == 2:
        L.append("  CRT2 is the second display; the NBAT gave it to GPC%d." % g[1])
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
        for key in parts[1:]:
            k = key.upper()
            if k in IDP_MSG:
                kb.sendto(struct.pack(">%dH" % len(IDP_MSG[k]), *IDP_MSG[k]),
                          (MCAST_GROUP, port_base + 41))
            elif k in SCAN:
                kb.sendto(struct.pack(">H", SCAN[k]), (MCAST_GROUP, port_base + 31))
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
    ap.add_argument("--crts", type=int, choices=(1, 2), default=1,
                    help="display windows: 1 (default) or 2")
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
    ap.add_argument("--no-keyboard", action="store_true", help="no stsKeyboard.py")
    ap.add_argument("--procedure", action="store_true", help="print the procedure and exit")
    ap.add_argument("--panel-script", metavar="FILE", help="timed script for panelO6.py")
    ap.add_argument("--keys", metavar="FILE", help="timed keystrokes (see above)")
    ap.add_argument("--duration", type=float, metavar="SECONDS",
                    help="shut down after this long instead of waiting for Enter")
    args = ap.parse_args()
    gpcs = args.gpcs
    multi = len(gpcs) > 1

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
    pane = int(round(180.0 * size / 768 / ws))            # MEDS2's IDP pane, Qt pixels
    mdu_w = size + pane + 16                               # Qt pixels
    crt_pos = [(0, 0), (mdu_w + 32, 0)]
    right = args.crts * (mdu_w + 32) * ws + 20             # physical pixels
    kb_w = int(round(509.0 * size / 768))
    o6_w = int(round(948.0 * size / 768))
    kb_geom = "+%d+0" % right
    o6_geom = "+%d+0" % (right + (0 if args.no_keyboard else kb_w + 20))
    cam_x = right + (0 if args.no_keyboard else kb_w + 20) + o6_w + 20
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
        crt_pos = [(0, 0), (step // ws, step // ws)]
        x += mdu_w * ws + (args.crts - 1) * step + 20
        if not args.no_keyboard:
            kx = stack_x(x, kb_w)
            kb_geom = "+%d+0" % kx
            x = kx + kb_w + 20
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
        title = "GPC%s %s" % ("s" if multi else "", ",".join(map(str, gpcs)))
        for k in range(args.crts):
            e = dict(env)
            e["NSTS_MDU_POS"] = "%d,%d" % crt_pos[k]
            L.start("meds%d" % (k + 1),
                    [py, "MEDS2.py", "--port-base", str(args.port_base), "--size", str(size),
                     "--scale", str(args.scale), "--title", title,
                     "crt%d" % (k + 1), "idp%d" % (k + 1)], HERE, e)
            time.sleep(1)
        if not args.no_keyboard:
            L.start("keyboard", [py, "stsKeyboard.py", "--kybd", "1", "--port-base",
                                 str(args.port_base), "--size", str(size),
                                 "--geometry", kb_geom], HERE, env)
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
