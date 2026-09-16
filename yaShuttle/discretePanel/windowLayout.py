#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Save where the simulation's windows are, and put them back later.

    python3 windowLayout.py save demo.layout     # arrange them, then save
    python3 windowLayout.py restore demo.layout  # next run, same places
    python3 windowLayout.py show                 # what is on screen now
    python3 windowLayout.py show demo.layout     # what a file holds

A run started by simulatePASS.py opens a window per display, per keyboard,
the crew panel, the CAM and the caption box, and the places they land in are
rarely the ones wanted for a recording.  Arrange them once by hand, save, and
every later run can be put back the same way.

WHAT A WINDOW IS CALLED.  Not its title -- two keyboards are titled "1" and
"2" -- and not its WM_CLASS, which for Tk is "tk #4" and changes run to run.
Each window is named for the program that made it, from that process's own
command line, so the same name matches the same window in a later run:

    crt1 crt2 crt3 crt4     the MEDS2.py displays
    kybd1 kybd2 kybd3       the DPS keyboards
    panel                   panelO6.py
    cam                     cam.py
    subtitles               subtitles.py
    meds:<name>             any other MEDS2.py window, by its LRU name

Anything not recognised is saved under 'other:<title>', matched by title.

SIZES.  Only the caption box is resized: the displays and the panel size
themselves from --size, and forcing a different size on them would not scale
what they draw.  'restore --with-sizes' resizes everything in the file.

A window manager may place a window a few pixels from where it is asked to
(the frame is its business, not ours), so each window is moved, measured, and
nudged by the difference, up to three times.  --verbose shows that happening.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import time

# Tk tells nobody its process id, so its windows are named by title instead.
TITLE_ROLES = [
    (re.compile(r"^Subtitles$"), "subtitles"),
    (re.compile(r"^CAM$"), "cam"),
    (re.compile(r"^Panels O6\b"), "panel"),
    (re.compile(r"^GPC discrete panel"), "discretepanel"),
    (re.compile(r"^([123])$"), lambda m: "kybd%s" % m.group(1)),
]
ROLE_PATTERNS = [
    # (what to look for in the command line, the name to give it)
    (re.compile(r"stsKeyboard\.py.*--kybd\s+(\d)"), lambda m: "kybd%s" % m.group(1)),
    (re.compile(r"MEDS2\.py.*\b(crt\d|cdr\d|plt\d|mfd\d|afd\d)\b"), lambda m: m.group(1)),
    (re.compile(r"MEDS2\.py"), lambda m: "meds"),
    (re.compile(r"panelO6\.py"), lambda m: "panel"),
    (re.compile(r"discretePanel\.py"), lambda m: "discretepanel"),
    (re.compile(r"cam\.py"), lambda m: "cam"),
    (re.compile(r"subtitles\.py"), lambda m: "subtitles"),
]
RESIZE_BY_DEFAULT = ("subtitles",)


HOSTNAME = os.uname().nodename


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout


def cmdline(pid):
    try:
        with open("/proc/%d/cmdline" % pid, "rb") as fh:
            return " ".join(fh.read().decode("utf-8", "replace").split("\0")).strip()
    except OSError:
        return ""


def role_of(pid, title):
    cmd = cmdline(pid) if pid else ""
    for pattern, name in ROLE_PATTERNS:
        m = pattern.search(cmd)
        if m:
            return name(m), cmd
    title = title.strip()
    for pattern, name in TITLE_ROLES:
        m = pattern.match(title)
        if m:
            return (name(m) if callable(name) else name), cmd
    return "other:" + title, cmd


def windows():
    """Every managed window: {id, pid, x, y, w, h, title, role, cmd}."""
    out = []
    for line in run(["wmctrl", "-lpG"]).splitlines():
        parts = line.split(None, 7)
        if len(parts) < 8:
            continue
        wid, _desk, pid, x, y, w, h, rest = parts
        # the last field is the client's machine and then the title; the
        # machine is "N/A" for a window that does not say (Tk's do not).
        host, _, title = rest.partition(" ")
        if host not in ("N/A", HOSTNAME):
            title = rest
        title = title.strip()
        if title in ("Desktop", "Bottom Panel", "Top Panel", ""):
            continue
        pid = int(pid)
        role, cmd = role_of(pid, title)
        out.append({"id": wid, "pid": pid, "x": int(x), "y": int(y),
                    "w": int(w), "h": int(h), "title": title, "role": role, "cmd": cmd})
    return out


def geometry(wid):
    """Where the window manager actually has it now."""
    text = run(["xdotool", "getwindowgeometry", "--shell", wid])
    g = dict(re.findall(r"^(\w+)=(-?\d+)$", text, re.M))
    if not g:
        return None
    return int(g["X"]), int(g["Y"]), int(g["WIDTH"]), int(g["HEIGHT"])


def place(wid, x, y, w=None, h=None, verbose=False):
    """Move (and optionally resize), correcting for what the frame does."""
    if w and h:
        subprocess.run(["xdotool", "windowsize", "--sync", wid, str(w), str(h)],
                       capture_output=True)
    ask_x, ask_y = x, y                # x, y stay the target; the ask moves
    for attempt in range(3):
        subprocess.run(["xdotool", "windowmove", "--sync", wid, str(ask_x), str(ask_y)],
                       capture_output=True)
        time.sleep(0.05)
        now = geometry(wid)
        if now is None:
            return False
        dx, dy = x - now[0], y - now[1]
        if verbose:
            print("    try %d: asked %d,%d got %d,%d (want %d,%d)"
                  % (attempt + 1, ask_x, ask_y, now[0], now[1], x, y))
        if dx == 0 and dy == 0:
            return True
        ask_x, ask_y = ask_x + dx, ask_y + dy    # off by that much: ask for less
    return False


def cmd_save(args):
    ws = windows()
    keep = [w for w in ws if not w["role"].startswith("other:") or args.all]
    layout = {"saved": time.strftime("%Y-%m-%d %H:%M:%S"),
              "windows": [{k: w[k] for k in ("role", "x", "y", "w", "h", "title")}
                          for w in sorted(keep, key=lambda w: w["role"])]}
    with open(args.file, "w") as fh:
        json.dump(layout, fh, indent=2)
        fh.write("\n")
    print("saved %d windows to %s" % (len(keep), args.file))
    for w in layout["windows"]:
        print("   %-12s %5d,%-5d %4dx%-4d  %s" % (w["role"], w["x"], w["y"],
                                                  w["w"], w["h"], w["title"][:40]))
    return 0


def cmd_restore(args):
    with open(args.file) as fh:
        layout = json.load(fh)
    here = {}
    for w in windows():
        here.setdefault(w["role"], []).append(w)
    done = missing = failed = 0
    for want in layout["windows"]:
        role = want["role"]
        got = here.get(role)
        if not got:
            print("   %-12s not on screen" % role)
            missing += 1
            continue
        w = got.pop(0)
        size = (want["w"], want["h"]) if (args.with_sizes or role in RESIZE_BY_DEFAULT) else (None, None)
        ok = place(w["id"], want["x"], want["y"], size[0], size[1], args.verbose)
        print("   %-12s -> %d,%d%s%s" % (role, want["x"], want["y"],
                                         " %dx%d" % size if size[0] else "",
                                         "" if ok else "  (could not place it exactly)"))
        done += 1
        failed += 0 if ok else 1
    print("placed %d window(s)%s%s" % (done,
                                       ", %d not running" % missing if missing else "",
                                       ", %d inexact" % failed if failed else ""))
    return 0


def cmd_show(args):
    if args.file:
        with open(args.file) as fh:
            layout = json.load(fh)
        print("%s, saved %s" % (args.file, layout.get("saved", "?")))
        rows = [(w["role"], w["x"], w["y"], w["w"], w["h"], w["title"]) for w in layout["windows"]]
    else:
        rows = [(w["role"], w["x"], w["y"], w["w"], w["h"], w["title"])
                for w in sorted(windows(), key=lambda w: w["role"])
                if not w["role"].startswith("other:") or args.all]
    for role, x, y, w, h, title in rows:
        print("   %-12s %5d,%-5d %4dx%-4d  %s" % (role, x, y, w, h, title[:45]))
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                 epilog=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="what")
    s = sub.add_parser("save", help="write the current placement to a file")
    s.add_argument("file")
    s.add_argument("--all", action="store_true", help="unrecognised windows too")
    s.set_defaults(func=cmd_save)
    r = sub.add_parser("restore", help="put the windows back where a file says")
    r.add_argument("file")
    r.add_argument("--with-sizes", action="store_true",
                   help="resize every window, not just the caption box")
    r.add_argument("--verbose", action="store_true", help="show each move and what came of it")
    r.set_defaults(func=cmd_restore)
    h = sub.add_parser("show", help="what is on screen now, or what a file holds")
    h.add_argument("file", nargs="?")
    h.add_argument("--all", action="store_true", help="unrecognised windows too")
    h.set_defaults(func=cmd_show)
    args = ap.parse_args(argv)
    if not args.what:
        ap.print_help()
        return 1
    for tool in ("wmctrl", "xdotool"):
        if not any(os.access(os.path.join(p, tool), os.X_OK)
                   for p in os.environ.get("PATH", "").split(":")):
            sys.exit("windowLayout: %s is not installed" % tool)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
