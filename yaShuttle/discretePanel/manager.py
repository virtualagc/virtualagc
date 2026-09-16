#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""A small control window for a running simulation: play a crew script at any
moment, save and restore where the windows are, and start the caption box.

    python3 manager.py                    # port base 6900
    python3 manager.py --port-base 27000
    simulatePASS.py ...                   # starts one itself (--no-manager not to)

WHY.  Everything here can be typed in a terminal, but not while a recording
is running: the point is to decide DURING a demonstration to play a script,
without having planned it beforehand.

WHAT IT DOES.

    Script   choose a .script file and Play it, or Stop the one playing.
             The command goes to panelO6.py, which owns the script player
             (port base + 92); the panel reads and checks the file, so a
             mistake is reported in its log and nothing happens.  A script
             may itself call others with 'script FILE' lines.
    Layout   Save where the windows are now, or Restore them from the file.
             windowLayout.py does the work; the caption box's look -- font,
             size, colours -- is saved with it.
    Caption  Start the caption box (subtitles.py) with the look the layout
             file holds, or Stop the one this window started.

There is deliberately no pause: yaGPC2 has none of its own, and stopping its
process leaves the displays timing out and the emulator racing to catch up
afterwards.

WHAT IT SHOWS.  A line naming the programs of this simulation that are up
(found by their --port-base), refreshed every few seconds, and a line saying
what happened last.
"""

import argparse
import glob
import os
import subprocess
import sys
import time
import tkinter as tk
import tkinter.filedialog as filedialog
import tkinter.font as tkfont

import crewscript
import discretes as D
import windowLayout

HERE = os.path.dirname(os.path.abspath(__file__))
PROGRAMS = ("yaGPC2", "MEDS2.py", "panelO6.py", "stsKeyboard.py", "cam.py",
            "subtitles.py", "discretePanel.py")
POLL_MS = 3000
C_BG = "#2b2b2b"
C_FG = "#e8e8e8"
C_NOTE = "#b0c4de"


def running(port_base):
    """Which of the simulation's programs are up on this port base."""
    found = []
    for entry in os.listdir("/proc"):
        if not entry.isdigit():
            continue
        try:
            with open("/proc/%s/cmdline" % entry, "rb") as fh:
                argv = [a for a in fh.read().decode("utf-8", "replace").split("\0") if a]
        except OSError:
            continue
        if not argv or "--port-base" not in argv:
            continue
        try:
            if argv[argv.index("--port-base") + 1] != str(port_base):
                continue
        except IndexError:
            continue
        # 'python3 -u panelO6.py ...' as well as 'python3 panelO6.py ...',
        # and yaGPC2, which is not a script at all.
        if os.path.basename(argv[0]) in ("timeout", "bash", "sh", "env"):
            continue                   # a wrapper, not the program itself
        name = ""
        for a in argv:
            base = os.path.basename(a)
            if base in PROGRAMS:
                name = base
                break
        if name:
            found.append((name, int(entry)))
    return sorted(set(found))


class Manager(object):
    def __init__(self, root, args):
        self.root, self.args = root, args
        self.subtitles = None              # the caption box this window started
        root.title("Simulation manager")
        root.configure(bg=C_BG)
        bold = tkfont.Font(family="Helvetica", size=10, weight="bold")

        self.script = tk.StringVar(value=args.script or self._first_script())
        self.layout = tk.StringVar(value=args.layout)
        self.note = tk.StringVar(value="port base %d" % D.PORT_BASE)
        self.state = tk.StringVar(value="looking...")

        self._section("SCRIPT", bold)
        row = self._row()
        tk.Entry(row, textvariable=self.script, width=44, bg="#1b1b1b", fg=C_FG,
                 insertbackground=C_FG).pack(side="left", padx=(0, 6))
        self._button(row, "Browse", self.browse_script)
        self._button(row, "Play", self.play, wide=True)
        self._button(row, "Stop", self.stop)
        row = self._row()
        self.skip_wait = tk.BooleanVar(value=True)
        tk.Checkbutton(row, text="skip an opening 'wait user' (you just pressed Play)",
                       variable=self.skip_wait, bg=C_BG, fg="#9a9a9a",
                       activebackground=C_BG, activeforeground=C_FG,
                       selectcolor="#1b1b1b", highlightthickness=0).pack(side="left")

        self._section("LAYOUT", bold)
        row = self._row()
        tk.Entry(row, textvariable=self.layout, width=44, bg="#1b1b1b", fg=C_FG,
                 insertbackground=C_FG).pack(side="left", padx=(0, 6))
        self._button(row, "Browse", self.browse_layout)
        self._button(row, "Save", self.save_layout, wide=True)
        self._button(row, "Restore", self.restore_layout)

        self._section("CAPTION BOX", bold)
        row = self._row()
        self._button(row, "Start", self.start_subtitles, wide=True)
        self._button(row, "Stop", self.stop_subtitles)
        tk.Label(row, text="   (started with the look the layout file holds)",
                 bg=C_BG, fg="#808080").pack(side="left")

        tk.Label(root, textvariable=self.state, bg=C_BG, fg=C_NOTE, anchor="w",
                 justify="left").pack(fill="x", padx=10, pady=(10, 0))
        tk.Label(root, textvariable=self.note, bg=C_BG, fg="#9a9a9a", anchor="w",
                 justify="left", wraplength=560).pack(fill="x", padx=10, pady=(2, 10))
        root.bind_all("<Control-q>", lambda _e: root.quit())
        self._poll()

    # -- the furniture ------------------------------------------------------
    def _section(self, text, font):
        tk.Label(self.root, text=text, bg=C_BG, fg="#8fbc8f", font=font,
                 anchor="w").pack(fill="x", padx=10, pady=(10, 2))

    def _row(self):
        row = tk.Frame(self.root, bg=C_BG)
        row.pack(fill="x", padx=10)
        return row

    def _button(self, row, text, command, wide=False):
        tk.Button(row, text=text, command=command, width=8 if wide else 7,
                  bg="#3c3c3c", fg=C_FG, activebackground="#505050",
                  activeforeground=C_FG, highlightbackground=C_BG,
                  relief="raised").pack(side="left", padx=2)

    def _first_script(self):
        here = sorted(glob.glob(os.path.join(HERE, "examples", "*.script")))
        return here[0] if here else ""

    def say(self, text):
        self.note.set(text)
        print("manager: %s" % text, flush=True)

    # -- what the buttons do ------------------------------------------------
    def browse_script(self):
        name = filedialog.askopenfilename(
            title="Crew script", initialdir=os.path.join(HERE, "examples"),
            filetypes=[("Crew scripts", "*.script"), ("All files", "*")])
        if name:
            self.script.set(name)

    def browse_layout(self):
        name = filedialog.asksaveasfilename(
            title="Window layout", initialdir=HERE, confirmoverwrite=False,
            filetypes=[("Layouts", "*.layout"), ("All files", "*")])
        if name:
            self.layout.set(name)

    def play(self):
        path = self.script.get().strip()
        if not path:
            self.say("no script chosen")
            return
        path = os.path.abspath(path)
        try:
            with open(path) as fh:
                entries = crewscript.parse(fh.read(), path)
        except (OSError, crewscript.ScriptError) as e:
            self.say("%s" % e)
            return
        steps, waits = crewscript.count_entries(entries)
        opens_waiting = bool(entries) and entries[0]["kind"] == "wait_user"
        skip = self.skip_wait.get()
        try:
            crewscript.send_control(("playnow " if skip else "play ") + path)
        except OSError as e:
            self.say("cannot reach the panel: %s" % e)
            return
        if opens_waiting and not skip:
            self.say("%s starts with 'wait user' -- CLICK IN THE PANEL WINDOW to start it"
                     % os.path.basename(path))
        else:
            self.say("playing %s -- %d steps, %d waits%s"
                     % (os.path.basename(path), steps, waits,
                        " (opening 'wait user' skipped)" if opens_waiting and skip else ""))

    def stop(self):
        try:
            crewscript.send_control("stop")
            self.say("asked the panel to stop the script")
        except OSError as e:
            self.say("cannot reach the panel: %s" % e)

    def save_layout(self):
        path = self.layout.get().strip()
        if not path:
            self.say("no layout file chosen")
            return
        try:
            n = windowLayout.save_layout(path, log=lambda _t: None)
        except OSError as e:
            self.say("cannot save: %s" % e)
            return
        self.say("saved %d windows to %s" % (n, os.path.basename(path)))

    def restore_layout(self):
        path = self.layout.get().strip()
        if not os.path.isfile(path):
            self.say("no such layout file: %s" % path)
            return
        placed, missing, inexact = windowLayout.restore_layout(path, log=lambda _t: None)
        self.say("placed %d window(s)%s%s" % (
            placed, ", %d not running" % missing if missing else "",
            ", %d not exactly" % inexact if inexact else ""))

    def start_subtitles(self):
        if any(n == "subtitles.py" for n, _ in running(self.args.port_base)):
            self.say("a caption box is already running on this port base")
            return
        look = []
        path = self.layout.get().strip()
        if os.path.isfile(path):
            try:
                look = windowLayout.look_in(path)
            except (OSError, ValueError, KeyError):
                look = []
        if not look:
            look = ["--font-size", "14", "--bg", "#404040"]
        if "--edit" not in look:
            look = look + ["--edit"]
        argv = [sys.executable, os.path.join(HERE, "subtitles.py"),
                "--port-base", str(self.args.port_base)] + look
        try:
            self.subtitles = subprocess.Popen(argv, cwd=HERE, stdout=subprocess.DEVNULL,
                                              stderr=subprocess.STDOUT,
                                              stdin=subprocess.DEVNULL)
        except OSError as e:
            self.say("cannot start the caption box: %s" % e)
            return
        self.say("caption box started (%s)" % " ".join(look))
        if os.path.isfile(path):
            self.root.after(2500, self.restore_layout)   # put it where the layout says

    def stop_subtitles(self):
        if self.subtitles is not None and self.subtitles.poll() is None:
            self.subtitles.terminate()
            self.say("caption box stopped")
            self.subtitles = None
            return
        boxes = [pid for n, pid in running(self.args.port_base) if n == "subtitles.py"]
        if not boxes:
            self.say("no caption box on this port base")
            return
        for pid in boxes:
            try:
                os.kill(pid, 15)
            except OSError as e:
                self.say("cannot stop %d: %s" % (pid, e))
                return
        self.say("caption box stopped (pid %s)" % ", ".join(map(str, boxes)))

    # -- what is up ---------------------------------------------------------
    def _poll(self):
        up = running(self.args.port_base)
        if up:
            counts = {}
            for name, _pid in up:
                counts[name] = counts.get(name, 0) + 1
            self.state.set("up on port base %d:  %s" % (
                self.args.port_base,
                "   ".join("%s%s" % (n, " x%d" % c if c > 1 else "")
                           for n, c in sorted(counts.items()))))
        else:
            self.state.set("nothing running on port base %d" % self.args.port_base)
        self.root.after(POLL_MS, self._poll)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                 epilog=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--port-base", type=int, default=None, metavar="N",
                    help="the simulation's port base (default 6900, or NSTS_BUS_PORT_BASE)")
    ap.add_argument("--script", metavar="FILE", help="crew script to start with in the box")
    ap.add_argument("--layout", metavar="FILE", default=os.path.join(HERE, "demo.layout"),
                    help="layout file to save to and restore from (default demo.layout here)")
    ap.add_argument("--geometry", metavar="SPEC", help="Tk geometry for this window")
    args = ap.parse_args(argv)
    if args.port_base is not None:
        D.set_port_base(args.port_base)
    else:
        args.port_base = D.PORT_BASE
    root = tk.Tk()
    if args.geometry:
        root.geometry(args.geometry)
    Manager(root, args)
    root.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
