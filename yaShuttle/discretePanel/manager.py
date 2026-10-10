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
    Speed    1x to 16x simulated time per wall second, changed while the
             vehicle runs -- fast through long quiet stretches (about 4x is
             what a 2026 host manages; more asks for what it can do).
    Hand     Start the hand controllers (handcontrollers.py) for one
             station -- CDR, PLT or Aft -- or Stop them: the RHC and THC, from
             a joystick or, without one, a window of virtual controllers.  So
             a run started without simulatePASS's --rhc can still be flown.

There is deliberately no pause: yaGPC2 has none of its own, and stopping its
process leaves the displays timing out and the emulator racing to catch up
afterwards.

WHAT IT SHOWS.  A line naming the programs of this simulation that are up
(found by their --port-base), refreshed every few seconds, and a line saying
what happened last.
"""

import argparse
import glob
import json
import os
import re
import subprocess
import threading
import sys
import time
import tkinter as tk
import tkinter.font as tkfont

import crewscript
import discretes as D
import procinfo
import windowLayout

HERE = os.path.dirname(os.path.abspath(__file__))
PROGRAMS = ("yaGPC2", "MEDS2.py", "panelO6.py", "stsKeyboard.py", "cam.py",
            "subtitles.py", "discretePanel.py", "handcontrollers.py", "portview.py")
POLL_MS = 3000
C_BG = "#2b2b2b"
C_FG = "#e8e8e8"
C_NOTE = "#b0c4de"
# The status bar at the foot.  SILVER WITH BLACK TEXT, not another dark grey:
# a dark panel among dark buttons reads as one more button, and the one thing
# in the window that cannot be pressed should not look like the things that
# can.  Reversing it out is what makes it a band rather than a control.
C_STATUS = "#c0c0c0"
# The space around a button, used again between rows of them.
BUTTON_GAP = 2
# macOS COUNTS IN POINTS, two physical pixels each on a Retina screen, where
# Linux Tk counts physical pixels -- so every margin and gap below, written in
# Linux's pixels, came out twice as big there.  pad() halves them on macOS.
MAC = sys.platform == "darwin"


def pad(n):
    return int(round(n / 2.0)) if MAC else n


# macOS also rounds the window's bottom corners, by about 11 points on macOS
# 27, cutting off what is under them; the status bar is made that much deeper
# at the bottom so they cut into its colour and not its text.
BOTTOM_MARGIN = 12 if MAC else 0
C_STATUS_FG = "#101010"


def shrink_fonts(root, points):
    """Take `points` off every font Tk builds its widgets from.  A size is
    POINTS when positive and PIXELS when negative, so the magnitude is what
    shrinks either way."""
    for name in tkfont.names(root):
        try:
            f = tkfont.nametofont(name, root)
            size = f.cget("size")
        except tk.TclError:
            continue
        if size > 0:
            f.configure(size=max(1, size - points))
        elif size < 0:
            f.configure(size=min(-1, size + points))


def _argvs():
    """(pid, argv) of every process: from /proc on Linux, and from
    procinfo.py where there is no /proc (macOS)."""
    if not os.path.isdir("/proc"):
        yield from procinfo.argvs()
        return
    for entry in os.listdir("/proc"):
        if not entry.isdigit():
            continue
        try:
            with open("/proc/%s/cmdline" % entry, "rb") as fh:
                argv = [a for a in fh.read().decode("utf-8", "replace").split("\0") if a]
        except OSError:
            continue
        yield int(entry), argv


def running(port_base):
    """Which of the simulation's programs are up on this port base."""
    found = []
    for pid, argv in _argvs():
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
            found.append((name, pid))
    return sorted(set(found))



# ---------------------------------------------------------------------------
# THE FILE DIALOGS.
#
# Qt's, not Tk's.  tkinter.filedialog on X11 is tkfbox.tcl, whose file list is
# an IconList of icons and names -- no details mode, no columns, no dates --
# and its directory chooser is plainer still.  QFileDialog is native on all
# three platforms and its Detail view has the Date Modified column, which is
# what tells one snapshot directory from another.
#
# PyQt6 IS ALREADY REQUIRED, so there is nothing to guard against: MEDS2.py
# imports it at module level with no try around it, and MEDS2.py is what draws
# every display unit.  A simulation with a CRT cannot start without it, and
# this manager only ever runs as part of one.  An "in case it is absent"
# fallback here would be a second implementation of every chooser, kept
# working for a case that cannot arise.
#
# IN A SUBPROCESS, THOUGH.  Qt and Tk each want to own the event loop, and a
# manager keeping a simulation's windows alive is the wrong place to discover
# what happens when both try.  simulatePASS.py already asks Qt about the
# screen the same way, in screen_info().
_QT_DIALOG = r"""
import sys
from PyQt6.QtWidgets import QApplication, QFileDialog
mode, title, start, pattern = sys.argv[1:5]
app = QApplication([])
d = QFileDialog(None, title, start)
d.setViewMode(QFileDialog.ViewMode.Detail)
if mode == "dir":
    d.setFileMode(QFileDialog.FileMode.Directory)
    d.setOption(QFileDialog.Option.ShowDirsOnly, True)
    d.setAcceptMode(QFileDialog.AcceptMode.AcceptSave)
else:
    d.setFileMode(QFileDialog.FileMode.AnyFile)
    if pattern:
        d.setNameFilters([pattern, "All files (*)"])
    d.setAcceptMode(QFileDialog.AcceptMode.AcceptSave
                    if mode == "save" else QFileDialog.AcceptMode.AcceptOpen)
if d.exec():
    got = d.selectedFiles()
    if got:
        sys.stdout.write(got[0])
"""


def native_dialog(mode, title, start, pattern=""):
    """The chooser's answer: a path, or "" if it was cancelled.

    None means the child could not be run at all, which is a broken
    installation rather than a cancel, and the caller says so instead of
    quietly doing something else.
    """
    try:
        out = subprocess.run([sys.executable, "-c", _QT_DIALOG,
                              mode, title, start or "", pattern],
                             stdout=subprocess.PIPE, timeout=600)
    except Exception:
        return None
    if out.returncode != 0:
        return None
    return out.stdout.decode("utf-8", "replace").strip()


class Manager(object):
    def __init__(self, root, args):
        # Set before the UI is built: a progress datagram can arrive at any
        # moment, including before there is a heading to put it in.
        self.script_heading = None
        self.root, self.args = root, args
        self.subtitles = None              # the caption box this window started
        self.hands = None                  # the hand controllers it started
        self.views = None                  # the window views (portview.py) it started
        # SHORT ENOUGH TO READ.  This window is narrow, and a title bar it
        # cannot fit says nothing at all: "Simulation manager" came back as
        # something unreadable, let alone with the run appended.  The run is
        # in the status line instead, where there is a whole width for it.
        root.title("Manager")
        root.configure(bg=C_BG)
        # One point further on macOS, whose system font is that much larger
        # than Linux's at the same setting.
        shrink_fonts(root, 3 if MAC else 2)
        bold = tkfont.Font(family="Helvetica", size=7 if MAC else 8, weight="bold")

        self.script = tk.StringVar(value=args.script or self._first_script())
        self.layout = tk.StringVar(value=args.layout)
        self.snapshot = tk.StringVar(value=args.snapshot_dir)
        # ONE LINE.  There were two, and the upper one only ever restated what
        # the poll below already says -- a status line above the status line.
        # What is running is the standing status; a message from a button
        # takes the line for a few seconds and then it goes back.
        self.note = tk.StringVar(value="")
        self._note_until = 0.0
        # REAL TIME THE MANAGER'S OWN ACTIONS COST THE VEHICLE.  A save stops
        # the vehicle while the capture is written, and a restore holds it
        # until the replacement is running; the vehicle's clock (PASS's, the
        # timing unit's and the truth's alike) does not count that time, so
        # after these the GMT on the displays is behind the wall clock by
        # their total.  Measured HERE, from the request to simulatePASS's
        # answer, and not reported by the simulation: a loss from anything
        # else then shows up as a GMT that disagrees with this figure,
        # instead of being folded into it.  Layout saves and restores only
        # move windows and do not stop the vehicle, so they are not counted.
        self._rtLost = 0.0
        self._rtCount = {"save": 0, "resume": 0}
        self._rtStart = {}
        self.rt = tk.StringVar(value=self._rt_text())
        self._busy = self._busyText = None      # the "please wait" modal
        self._busyPending = False

        # A path is long and its interesting end is the file name, so each box
        # is as wide as the window (and grows with it) and is scrolled to show
        # the end whenever it changes; the buttons sit underneath rather than
        # stealing the width.
        # THE SCRIPT HEADING SAYS WHETHER ONE IS RUNNING, and how far it has
        # got: "SCRIPT (12/187 processing)" while it plays, plain "SCRIPT"
        # when nothing is.  Without it a run whose script is still working
        # and one whose script ended twenty minutes ago look identical --
        # which is no way to watch a simulation.  panelO6 plays the script
        # and knows the count, but its window is small and often hidden, so
        # it sends the count here (crewscript.send_progress).
        self.script_heading = self._section("SCRIPT", bold)
        self._path_box(self.script)
        row = self._row()
        self._button(row, "Browse", self.browse_script)
        self._button(row, "Play", self.play, wide=True)
        self._button(row, "Stop", self.stop)
        # RECORD: what a person does, as a draft script (recordscript.py).
        self._recorder = self._recordPath = None
        self.record_button = self._button(row, "Record", self.record)

        self._section("LAYOUT", bold)
        self._path_box(self.layout)
        row = self._row()
        self._button(row, "Browse", self.browse_layout)
        self._button(row, "Save", self.save_layout, wide=True)
        self._button(row, "Add", self.add_to_layout)
        self._button(row, "Restore", self.restore_layout)
        self._button(row, "All panels", self.toggle_all_panels)

        # SNAPSHOT.  Save & Continue is the one that has to be reachable at an
        # unplanned moment -- the whole reason this window exists -- so it is
        # the wide button.  End Simulation is deliberately in its own section,
        # away from the three that write a file first: it is the only control
        # here that destroys a run without saving it.
        self._section("SNAPSHOT", bold)
        self._path_box(self.snapshot)
        # ALL FOUR ON ONE LINE: they are one group of related actions, and
        # two rows of two suggested a division that does not exist.
        #
        # MEASURED IN THE REAL WINDOW, after a mock-up said it would not fit.
        # That mock-up built its buttons with the default Tk font instead of
        # this program's, and so put the row at 360 px against 330 available;
        # the actual row is 304 px inside an inner width of 304.  It fits
        # with the window no wider than it already was -- and one row
        # shorter.  "Save/Quit" rather than "Save & Quit", and a 6-character
        # minimum button width rather than 7 or 8, are what make the margin,
        # so both are load-bearing.
        row = self._row()
        self._button(row, "Browse", self.browse_snapshot)
        self._button(row, "Save", self.save_snapshot, wide=True)
        self.quit_button = self._button(row, "Save/Quit", self.save_and_quit)
        self._button(row, "Restore", self.restore_snapshot)

        self._section("CAPTION BOX", bold)
        row = self._row()
        self._button(row, "Start", self.start_subtitles, wide=True)
        self._button(row, "Stop", self.stop_subtitles)

        # ONE STATION, as simulatePASS's --rhc: one person flies this.  Here so
        # that forgetting --rhc at start-up does not cost the run (Ron).
        self._section("HAND CONTROLLERS", bold)
        row = self._row()
        self._button(row, "CDR", lambda: self.start_hands("lh"))
        self._button(row, "PLT", lambda: self.start_hands("rh"))
        self._button(row, "Aft", lambda: self.start_hands("aft"))
        self._button(row, "Stop", self.stop_hands)

        # THE FLIGHT STATION (owner, 2026-10-09): every switch is always there
        # and PASS reads them all, but a crew member sees one station -- the
        # forward one, or the aft flight deck's, where rendezvous, docking and
        # the RMS were flown.  Forward or Aft shows that station's panels,
        # displays and keyboards and hides the other's (nothing is stopped:
        # a script still reaches every control), starts that station's hand
        # controllers, and restarts the window views with what can be seen
        # from there.  Both shows everything, as before.
        self._section("STATION", bold)
        row = self._row()
        self._button(row, "Forward", lambda: self.set_station("fwd"))
        self._button(row, "Aft", lambda: self.set_station("aft"))
        self._button(row, "Both", lambda: self.set_station("all"))

        # THE VIEWS OUT OF THE WINDOWS (portview.py), which simulatePASS starts
        # with the vehicle dynamics; here to bring them back after closing
        # them, or to start them on a run begun without.
        self._section("WINDOW VIEWS", bold)
        row = self._row()
        self._button(row, "Start", self.start_views, wide=True)
        self._button(row, "Stop", self.stop_views)

        # SIMULATED TIME PER WALL SECOND, changed while the vehicle runs
        # (simulatePASS session `rate X`, rtpacer.c rate_poll): fast through
        # long quiet stretches, 1x where there is something to watch.  On the
        # 2026 host about 4x is the ceiling -- one GPC on orbit managed 3.8
        # when asked for 8 -- and MEDS2 kept taking every fill throughout; 8x
        # and 16x are here for faster hosts (Ron, 2026-10-06): asking for more
        # than the host can do just gets what it can.
        self._section("SPEED", bold)
        row = self._row()
        for x in (1, 2, 4, 8, 16):
            self._button(row, "%dx" % x, lambda x=x: self.set_rate(x))

        self._section("SIMULATION", bold)
        row = self._row()
        # START: a run begun held (simulatePASS --hold-start) waits, every
        # window up and nothing moving, for this or Enter in its terminal
        self._button(row, "Start", self.go)
        self._button(row, "Show Panel", self.show_panel)
        self._button(row, "End Simulation", self.end_simulation)

        # ONE BAND, SET OFF FROM THE CONTROLS.  Both lines say what the run is
        # doing rather than offering anything to do, so they read as a status
        # bar and are given their own background to say so.
        bar = tk.Frame(root, bg=C_STATUS)
        bar.pack(fill="x", side="bottom", pady=(pad(10), 0))
        # width=1 IS WHY THE WINDOW STOPS BREATHING.  A label asks for room
        # enough to show its text, and this one's text changes every three
        # seconds -- so the window grew and shrank under a person who had
        # just put it where they wanted it.  Asking for one character and
        # filling the width instead means the text never drives the size.
        tk.Label(bar, textvariable=self.note, bg=C_STATUS, fg=C_STATUS_FG,
                 anchor="w", justify="left", width=1
                 ).pack(fill="x", padx=pad(10), pady=(pad(6), 0))
        tk.Label(bar, textvariable=self.rt, bg=C_STATUS, fg=C_STATUS_FG,
                 anchor="w", justify="left", width=1
                 ).pack(fill="x", padx=pad(10), pady=(pad(2), pad(6) + BOTTOM_MARGIN))
        root.bind_all("<Control-q>", lambda _e: root.quit())
        # AND PINNED ONCE, at the size the controls actually need.  Without
        # this the toplevel keeps taking its size from its contents, and any
        # later change of text moves the edges again.  A person may still
        # resize it; nothing here will.
        root.update_idletasks()
        # A LITTLE WIDER THAN THE CONTROLS NEED, by about the width of the
        # "Save & Quit" button.  The controls alone settle on a window too
        # narrow for the SCRIPT heading, which now carries the count, the
        # line and the script's name -- and a heading that is cut off is a
        # heading that does not do its job.  Modest on purpose: the manager
        # sits beside three CRTs and a panel, and the screen is already full.
        # The four-button SNAPSHOT row is now the widest thing in here, so
        # the natural width already carries it; a little is added for the
        # SCRIPT heading, which is text rather than a widget and so asks for
        # nothing.
        want = root.winfo_reqwidth() + pad(24)
        root.minsize(want, root.winfo_reqheight())
        if not args.geometry:
            root.geometry("%dx%d" % (want, root.winfo_reqheight()))
        # Recorded rather than displayed: the window is too narrow to carry it
        # and the log is where it is wanted afterwards anyway.
        print("manager: %s" % self._what_run(), flush=True)
        self.start_results()
        self._start_station_listener()
        self._poll()

    # -- the furniture ------------------------------------------------------
    def _section(self, text, font):
        lab = tk.Label(self.root, text=text, bg=C_BG, fg="#8fbc8f", font=font,
                       anchor="w")
        lab.pack(fill="x", padx=pad(10), pady=(pad(10), pad(2)))
        return lab

    def _row(self):
        # pady MATCHES THE BUTTONS' OWN padx, so two rows of buttons are
        # separated by as much as two buttons side by side.  Without it
        # "Browse | Save" and "Save & Quit | Restore" read as one block of
        # four rather than as two rows.
        row = tk.Frame(self.root, bg=C_BG)
        row.pack(fill="x", padx=pad(10), pady=BUTTON_GAP)
        return row

    def _path_box(self, var):
        """A file name box the width of the window, showing the END of the
        path -- the part that says which file it is."""
        entry = tk.Entry(self.root, textvariable=var, bg="#1b1b1b", fg=C_FG,
                         insertbackground=C_FG, highlightthickness=1,
                         highlightbackground="#4a4a4a", highlightcolor="#7a9a7a")
        entry.pack(fill="x", padx=pad(10), pady=(0, pad(2)))
        show_end = lambda *_a: entry.after_idle(lambda: entry.xview_moveto(1.0))
        var.trace_add("write", show_end)
        entry.bind("<Configure>", show_end)      # and when the window is resized
        show_end()
        return entry

    def _button(self, row, text, command, wide=False):
        # AT LEAST AS WIDE AS ITS LABEL.  The width is in characters and was
        # once fixed at 7 or 8, which silently clipped anything longer: "Save
        # & Quit" read "ave & qui" and "End Simulation" read "nd Simulatio".
        # The minimum is now 6, which is what lets the four SNAPSHOT buttons
        # share one row; `wide` is kept so existing calls still read sensibly
        # but no longer changes the width, since the label decides it.
        if sys.platform == "darwin":
            b = self._mac_button(row, text, command)
            b.pack(side="left", padx=BUTTON_GAP)
            return b
        b = tk.Button(row, text=text, command=command,
                      width=max(6, len(text)),
                      bg="#3c3c3c", fg=C_FG, activebackground="#505050",
                      activeforeground=C_FG, highlightbackground=C_BG,
                      relief="raised")
        b.pack(side="left", padx=BUTTON_GAP)
        return b

    def _mac_button(self, row, text, command, width=None, font=None):
        """A LABEL DRAWN AS A BUTTON, on macOS only.  Tk's buttons there are
        the system's own, which ignore the colours above and wrap every label
        in about 34 points of padding that padx/pady cannot remove -- "Save/
        Quit" is 51 points of text in a 97-point button.  Four to a row, that
        made this window about 1.6 times the width it is on Linux, relative to
        the rest of the simulation.  A label has no such padding, and looks
        and behaves as the Linux button does: raised, lighter under the
        pointer, sunken while pressed, firing on release over it."""
        b = tk.Label(row, text=text, width=width or max(6, len(text)),
                     bg="#3c3c3c", fg=C_FG, relief="raised", bd=2,
                     padx=3, pady=1, cursor="hand2")
        if font is not None:
            b.configure(font=font)
        b.bind("<Enter>", lambda _e: b.configure(bg="#505050"))
        b.bind("<Leave>", lambda _e: b.configure(bg="#3c3c3c", relief="raised"))
        b.bind("<ButtonPress-1>", lambda _e: b.configure(relief="sunken"))

        def release(e):
            b.configure(relief="raised")
            if 0 <= e.x < b.winfo_width() and 0 <= e.y < b.winfo_height():
                command()
        b.bind("<ButtonRelease-1>", release)
        return b

    def _first_script(self):
        here = sorted(glob.glob(os.path.join(HERE, "examples", "*.script")))
        return here[0] if here else ""

    # How long a message from a button keeps the status line before what is
    # running takes it back.  Long enough to read, short enough that the line
    # is not left showing something that stopped being true.
    NOTE_SECONDS = 8.0

    def say(self, text, sticky=False):
        """sticky: HOLD THE LINE UNTIL THE ANSWER COMES.

        A save takes as long as it takes -- up to twenty seconds if a part of
        the simulation never answers -- and an ordinary message gives the line
        back after eight.  So "Saving to snapshot201 ..." was replaced by the
        running-programs list while the save was still going, the dialog
        arrived ten seconds after that, and the window had spent the interval
        looking exactly like a window with nothing happening in it.
        """
        self.note.set(text)
        self._note_until = float("inf") if sticky \
            else time.monotonic() + self.NOTE_SECONDS
        print("manager: %s" % text, flush=True)

    # -- what the buttons do ------------------------------------------------
    def browse_script(self):
        got = native_dialog("open", "Crew script",
                            os.path.join(HERE, "examples"),
                            "Crew scripts (*.script)")
        if got is None:
            self.say("Cannot open a file chooser")
        elif got:
            self.script.set(got)

    def browse_layout(self):
        got = native_dialog("save", "Window layout", HERE, "Layouts (*.layout)")
        if got is None:
            self.say("Cannot open a file chooser")
        elif got:
            self.layout.set(got)

    def browse_snapshot(self):
        """CHOOSE A SNAPSHOT DIRECTORY -- to restore, or to save into.

        This was a hand-written list for a while, because Tk's chooser cannot
        show WHEN a snapshot was taken and snapshots have deliberately similar
        names.  Both halves of that were wrong.  The limitation was the
        TOOLKIT, not the platform.  And the time was never missing: a snapshot
        directory's mtime is within a second of the capture time its
        vehicle.json records, measured across six of them, so a Detail view's
        Date Modified column is the right time and not merely a time.  What a
        snapshot HOLDS -- how many computers, what they were doing -- is the
        business of whoever names it, not of the dialog that lists it.

        What was genuinely wrong was navigation: the list could only descend,
        and could not name a directory that did not exist yet, which is half
        of what this box is for, since it holds the snapshot to SAVE as well
        as the one to restore.
        """
        current = self.snapshot.get().strip()
        # THE PARENT, not the snapshot itself.  Opening inside the last one
        # saved shows its gpc<N> files, which are not what is being chosen;
        # one level up is where the snapshots are.
        start = os.path.dirname(current.rstrip("/")) if current else HERE
        if not os.path.isdir(start):
            start = HERE
        got = native_dialog("dir", "Snapshot directory", start)
        if got is None:
            self.say("Cannot open a file chooser")
        elif got:
            self.snapshot.set(got)

    def play(self):
        path = self.script.get().strip()
        if not path:
            self.say("No script chosen")
            return
        path = os.path.abspath(path)
        try:
            with open(path) as fh:
                entries = crewscript.parse(fh.read(), path)
        except (OSError, crewscript.ScriptError) as e:
            self.say("%s" % e)
            return
        steps, waits = crewscript.count_entries(entries)
        try:
            # 'playnow': pressing Play is the go-ahead, so a script that opens
            # with 'wait user' does not ask for it twice.
            crewscript.send_control("playnow " + path)
        except OSError as e:
            self.say("Cannot reach the panel: %s" % e)
            return
        self.say("Playing %s -- %d steps, %d waits (the panel's log has the rest)"
                 % (os.path.basename(path), steps, waits))

    def record(self):
        """START OR STOP RECORDING a draft script of what a person does --
        panel switches, keyboard keys, MDU edgekeys -- into recordings/ beside
        this program.  Stopping puts the recording in the SCRIPT box, ready to
        open in an editor or play.  recordscript.py rewrites the file after
        every action, so ending it at any moment loses nothing."""
        if self._recorder is not None and self._recorder.poll() is None:
            self._recorder.terminate()
            try:
                self._recorder.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self._recorder.kill()
            self._recorder = None
            self._relabel(self.record_button, "Record")
            path = self._recordPath
            n = 0
            try:
                with open(path) as fh:
                    n = sum(1 for l in fh if l.startswith("+"))
            except OSError:
                pass
            self.script.set(path)
            self.say("Recorded %d step(s) to %s; it is in the SCRIPT box"
                     % (n, os.path.basename(path)))
            return
        where = os.path.join(HERE, "recordings")
        os.makedirs(where, exist_ok=True)
        path = os.path.join(where, time.strftime("recorded-%Y%m%d-%H%M%S.script"))
        argv = [sys.executable, os.path.join(HERE, "recordscript.py"), path]
        if self.args.port_base is not None:
            argv += ["--port-base", str(self.args.port_base)]
        try:
            self._recorder = subprocess.Popen(argv, cwd=HERE)
        except OSError as e:
            self.say("Cannot start the recorder: %s" % e)
            return
        self._recordPath = path
        self._relabel(self.record_button, "Stop Rec")
        self.say("Recording to %s -- press Stop Rec to finish" % os.path.basename(path),
                 sticky=True)

    @staticmethod
    def _relabel(button, text):
        try:
            button.configure(text=text, width=max(6, len(text)))
        except Exception:
            try:
                button.configure(text=text)
            except Exception:
                pass

    def stop(self):
        try:
            crewscript.send_control("stop")
            self.say("Asked the panel to stop the script")
        except OSError as e:
            self.say("Cannot reach the panel: %s" % e)

    def _layout_overwrite_ok(self, path):
        """Ask before writing over a layout made for a different vehicle.

        The box is pre-filled from --layout, so Save writes over the very
        file the run was STARTED from.  Saving a 2-GPC arrangement over a
        4-GPC layout keeps only the windows that happen to be on screen and
        silently drops the rest -- and a layout is placed by hand, so unlike
        a log it cannot be had again by running again.  The snapshot path has
        asked this question since it existed ("Replace this snapshot?"); this
        one never did, and a layout was lost that way.
        """
        try:
            with open(path) as fh:
                old = json.load(fh)
        except (OSError, ValueError):
            return True                 # unreadable or not ours: nothing to lose
        windows = old.get("windows", [])
        were = ""
        for w in windows:
            m = re.search(r"GPCs?\s+([0-9,\-]+)", w.get("title", ""))
            if m:
                were = m.group(1)
                break
        if were and self.args.gpcs and were == self.args.gpcs:
            return True                 # same vehicle: nothing would be lost
        held = "%d window%s" % (len(windows), "" if len(windows) == 1 else "s")
        if were:
            held += " arranged for GPC%s %s" % ("s" if "," in were else "", were)
        when = old.get("saved", "an earlier run")
        return self._dialog(
            "Replace this layout?",
            "%s already holds %s." % (os.path.basename(path), held),
            "It was saved %s, and this run has GPC%s %s -- saving keeps only "
            "the windows on screen now, and cannot be undone."
            % (when, "s" if (self.args.gpcs or "").count(",") else "",
               self.args.gpcs or "?"),
            "Change the name in the box first if you meant to keep both.",
            confirm="Replace")

    def save_layout(self):
        path = self.layout.get().strip()
        if not path:
            self.say("No layout file chosen")
            return
        if os.path.isfile(path) and not self._layout_overwrite_ok(path):
            self.say("Save cancelled; %s is untouched" % os.path.basename(path))
            return
        def work():
            try:
                return windowLayout.save_layout(
                    path, log=lambda _t: None,
                    only_pids=windowLayout.descendants(procinfo.parent_pid()))
            except OSError as e:
                return e

        def done(n):
            if isinstance(n, OSError):
                self.say("Cannot save: %s" % n)
            else:
                self.say("Saved %d windows to %s" % (n, os.path.basename(path)))
        self._window_work(work, done)

    def toggle_all_panels(self):
        """Every panel window up, so all of them can be placed and saved --
        or back to only those the OPS on the displays need."""
        self.all_panels = not getattr(self, "all_panels", False)
        crewscript.send_control("panels %s" % ("all" if self.all_panels else "ops"),
                                self.args.port_base)
        self.say("Panels: %s" % ("every window up -- place them, then Add"
                                 if self.all_panels else "only those the OPS need"))

    def add_to_layout(self):
        """ADD the windows on screen to the layout file: theirs replaced, the
        file's others kept.  Nothing is lost, so nothing is asked."""
        path = self.layout.get().strip()
        if not path:
            self.say("No layout file chosen")
            return
        def work():
            try:
                return windowLayout.save_layout(
                    path, log=lambda _t: None, merge=True,
                    only_pids=windowLayout.descendants(procinfo.parent_pid()))
            except (OSError, ValueError) as e:
                return e

        def done(n):
            if isinstance(n, Exception):
                self.say("Cannot add to the layout: %s" % n)
            else:
                self.say("Added %d windows to %s" % (n, os.path.basename(path)))
        self._window_work(work, done)

    def station_layout(self):
        """The layout for the station showing now: --layout-aft at the aft
        station when there is one, else the LAYOUT box's."""
        if getattr(self, "station", "all") == "aft" and getattr(self.args, "layout_aft", None):
            return self.args.layout_aft
        return self.layout.get().strip()

    def restore_layout(self, only_roles=None, path=None):
        path = path or self.layout.get().strip()
        if not os.path.isfile(path):
            self.say("No such layout file: %s" % path)
            return
        def work():
            return windowLayout.restore_layout(
                path, log=lambda _t: None,
                # This simulation's windows only: the manager is simulatePASS's
                # child, so its parent's process tree is the simulation.
                # (parent_pid, not os.getppid: see procinfo.py for Windows.)
                only_pids=windowLayout.descendants(procinfo.parent_pid()),
                only_roles=only_roles)

        def done(result):
            placed, missing, inexact = result
            self.say("Placed %d window(s)%s%s" % (
                placed, ", %d not running" % missing if missing else "",
                ", %d not exactly" % inexact if inexact else ""))
        self._window_work(work, done)

    def _window_work(self, work, done):
        """Run work() and hand its result to done().

        OFF THIS THREAD ON macOS.  There windowLayout.py moves and measures
        windows through the Accessibility interface, which asks each window's
        own application -- this one included, for this window -- and an
        application answers on its main thread.  Run here, the manager was
        busy waiting on itself: every other window moved and this one did
        not, and a saved layout left it out.  On Linux, as always, directly."""
        if not MAC:
            done(work())
            return
        threading.Thread(target=lambda: (lambda r: self.root.after(0, lambda: done(r)))(work()),
                         daemon=True).start()

    # ---- what came back -------------------------------------------------

    def _listen_results(self):
        """Thread: simulatePASS's answer to a session command, on base + 94."""
        try:
            sock = crewscript.result_receiver(self.args.port_base)
        except OSError:
            return
        while True:
            try:
                data, _ = sock.recvfrom(4096)
            except OSError:
                return
            text = data.decode("utf-8", errors="replace").strip()
            self.root.after(0, lambda t=text: self._result(t))

    def _listen_progress(self):
        """Thread: how far panelO6's script has got, on base + 96."""
        try:
            sock = crewscript.progress_receiver(self.args.port_base)
        except OSError:
            return
        while True:
            try:
                data, _ = sock.recvfrom(4096)
            except OSError:
                return
            text = data.decode("utf-8", errors="replace").strip()
            self.root.after(0, lambda t=text: self._progress(t))

    def _progress(self, text):
        """On the Tk thread.  "<done> <total> <file:line> <what>", or "done".

        THE COUNT ALONE CANNOT BE LOOKED UP.  A 'script FILE' line counts as
        one entry PLUS all of its children, so a 150-line script that calls a
        20-line one five times reports past 200 and no line of the file
        matches any number -- which is no help at all when a script sticks.
        The file and line come with it, and that is what a person needs:

            SCRIPT (194/206 at 5gpc-3crt-subtitled.script:134)

        and the step's own text goes to the status line, so a stuck script
        says what it is waiting FOR as well as where."""
        if self.script_heading is None:
            return
        if text == "done":
            self.script_heading.configure(text="SCRIPT")
            return
        parts = text.split(None, 3)
        if len(parts) < 3:
            return
        done, total, where = parts[0], parts[1], parts[2]
        # AS SHORT AS IT CAN BE MADE, because this window is narrow and the
        # heading is the whole point: no parentheses, the line appended to
        # the count with a colon, and no ".script" on the name -- every file
        # here is one.  "SCRIPT 194/206:134 5gpc-3crt-subtitled".  The name
        # may still be cut, and it is last precisely so that the count and
        # the line survive when it is.
        name, _, line = where.rpartition(":")
        if name.endswith(".script"):
            name = name[:-len(".script")]
        step = parts[3] if len(parts) > 3 else ""
        if step.lower().split()[:2] == ["wait", "user"]:
            # SAY WHAT IT IS WAITING FOR.  A 'wait user' holds until someone
            # clicks in the panel, and the count alone -- "SCRIPT 1/281" --
            # looked like a script that had stuck (Ron, 2026-09-30).  The
            # next step's report puts the count back.
            self.script_heading.configure(
                text="SCRIPT %s/%s: click the Panel to %s"
                % (done, total, "start" if done == "1" else "go on"))
            return
        self.script_heading.configure(
            text="SCRIPT %s/%s:%s %s" % (done, total, line, name)
            if name else "SCRIPT %s/%s" % (done, total))
        # THE STEP TEXT ONLY UNDER --debug.  It is useful to somebody who
        # knows what the script is doing and a distraction to everybody else
        # -- and a demonstration of PASS is not improved by a running
        # commentary on the machinery driving it.  The heading above still
        # gives the count and the line, which is what a stuck script needs.
        #
        # ONLY WHEN IT CHANGES, too: a status line rewritten a hundred times
        # a second is a status line nobody can read.
        if not getattr(self.args, "debug", False):
            return
        if step and step != getattr(self, "_last_step", None):
            self._last_step = step
            self.say(step[:70])

    def _result(self, text):
        """On the Tk thread.  Success goes to the status line; A FAILURE GETS
        A DIALOG.

        Not symmetry for its own sake.  A failed save that only tinted a small
        label is exactly the failure this is meant to remove -- somebody reads
        "saving to snapshot", believes they have one, and shuts the run down.
        A dialog during a recording is disruptive, which is the point: the
        alternative is losing the run.  Successes, which are the common case,
        stay quiet."""
        verdict, _, rest = text.partition(" ")
        verb, _, detail = rest.partition(" ")
        if verdict == "warn":
            # NOT a failure -- the restore is going ahead -- but not something
            # to leave in a log either: a vehicle that comes back with blank
            # screens looks like a restore that went wrong, and the person
            # watching deserves to know it is the snapshot and not the run.
            self._busy_done()
            self.say("Restoring, but the snapshot is incomplete")
            self._dialog("Incomplete snapshot",
                         "This snapshot does not hold everything.",
                         detail,
                         "The restore is going ahead with what it does hold.")
            return
        if verdict == "progress":
            bits = detail.split()
            try:
                self._busy_progress(int(bits[0]), int(bits[1]))
            except (IndexError, ValueError):
                pass
            return
        # Anything else is the answer, so the modal has done its job.
        self._busy_done()
        if verdict in ("ok", "fail"):
            self._rt_finish(verdict, verb)
        if verdict == "ok" and verb == "windows":
            self.say("Windows: %s" % detail)
            return
        if verdict == "ok":
            self.say({"save": "Saved to %s",
                      "save-and-quit": "Saved to %s; shutting down",
                      "resume": "Restored from %s"}.get(verb, "%s")
                     % os.path.basename(detail.rstrip("/")))
            return
        what = verb.replace("-", " ").capitalize()
        self.say("%s failed" % what)
        self._dialog(
            "%s failed" % what,
            "%s did not work, and nothing usable was written." % what,
            detail or "No reason given.",
            "The simulation is still running and has not been touched.")

    def _dialog(self, title, lead, detail, footnote, confirm=None):
        """A question or a notice, drawn INSIDE the Manager's own window.

        NOT A WINDOW OF ITS OWN.  As a separate Toplevel -- transient, marked
        always-above, raised, then re-activated every second -- End
        Simulation's question still showed BEHIND the Manager and a full-screen
        backdrop on the owner's desktop (2026-10-09).  Measured there: the
        window manager had it on top, mapped and focused, and the dialog's own
        pixels were right, but the screen at its place showed the Manager --
        Marco's compositor drawing it underneath (never reproduced with Marco
        on Xvfb, composited or not).  Holding the keyboard while invisible, it
        made the Manager seem to swallow every click.  A panel laid over the
        Manager's controls cannot be stacked wrongly: it is wherever the
        Manager is.

        Not tkinter.messagebox either: the native dialogs size to the text,
        which for messages of this length comes out tall, narrow and bold.

        `confirm`, when given, is the label of the button that says yes, and
        makes this ask rather than tell: it waits, and returns True or False.
        """
        base = tkfont.nametofont("TkDefaultFont", self.root)
        body = tkfont.Font(family=base.cget("family"),
                           size=abs(base.cget("size")), weight="normal")
        head = tkfont.Font(family=base.cget("family"),
                           size=abs(base.cget("size")), weight="bold")
        answer = {"ok": False}
        done = tk.BooleanVar(self.root, False)

        # the Manager itself to the front: the question is in it
        try:
            self.root.deiconify()
            self.root.lift()
        except tk.TclError:
            pass
        self.root.update_idletasks()
        W = max(300, self.root.winfo_width())
        pad = 24
        wrap = W - 2 * pad

        top = tk.Frame(self.root, bg=C_BG, highlightthickness=2,
                       highlightbackground=C_NOTE)
        top.place(x=0, y=0, relwidth=1, relheight=1)
        top.lift()
        tk.Label(top, text=title.upper(), bg=C_BG, fg=C_NOTE, font=head, anchor="w"
                 ).pack(fill="x", padx=pad, pady=(pad, 8))
        tk.Label(top, text=lead, bg=C_BG, fg=C_FG, font=body, anchor="w",
                 justify="left", wraplength=wrap
                 ).pack(fill="x", padx=pad, pady=(0, 12))
        # The part that differs between one of these and the next, in a panel
        # of its own so it does not compete with the sentence around it.
        box = tk.Frame(top, bg="#1b1b1b", highlightthickness=1,
                       highlightbackground="#4a4a4a")
        box.pack(fill="x", padx=pad)
        tk.Label(box, text=detail, bg="#1b1b1b", fg=C_FG, font=body, anchor="nw",
                 justify="left", wraplength=wrap - 24
                 ).pack(fill="both", expand=True, padx=12, pady=12)
        tk.Label(top, text=footnote, bg=C_BG, fg="#9a9a9a", font=body,
                 anchor="w", justify="left", wraplength=wrap
                 ).pack(fill="x", padx=pad, pady=(12, 8))

        row = tk.Frame(top, bg=C_BG)
        row.pack(fill="x", padx=pad, pady=(0, pad))

        def close(ok):
            answer["ok"] = ok
            for seq in ("<Return>", "<Escape>"):
                self.root.unbind(seq)
            try:
                top.grab_release()
            except tk.TclError:
                pass
            top.destroy()
            done.set(True)

        def button(text, ok, default):
            if MAC:
                # Not the system's button: its white face under this light
                # text is unreadable -- see _mac_button.
                b = self._mac_button(row, text, lambda: close(ok),
                                     width=max(10, len(text)), font=body)
            else:
                b = tk.Button(row, text=text, command=lambda: close(ok),
                              width=max(10, len(text)), bg="#3c3c3c", fg=C_FG,
                              activebackground="#505050", activeforeground=C_FG,
                              highlightbackground=C_BG, font=body)
            b.pack(side="right", padx=(8, 0))
            if default:
                b.focus_set()
            return b

        if confirm is None:
            button("OK", True, True)
            self.root.bind("<Return>", lambda _e: close(True))
        else:
            # Cancel is the default, because this is asked only where saying
            # yes cannot be undone.
            button(confirm, True, False)
            button("Cancel", False, True)
            self.root.bind("<Return>", lambda _e: close(False))
        self.root.bind("<Escape>", lambda _e: close(False))
        # modal within the Manager: the controls under the panel are covered,
        # and a grab on the panel keeps a click from reaching them anyway
        try:
            top.grab_set()
        except tk.TclError:
            pass
        if confirm is not None:
            self.root.wait_variable(done)
        return answer["ok"]

    # ---- while it is happening ------------------------------------------

    def _working(self, title, lead, cancellable=True):
        """A modal that says WAIT, shows how far along it is, and can stop it.

        A save takes up to twenty seconds -- the vehicle is brought to a
        stand, every computer writes its registers and a megabyte of memory,
        the panel writes its switches and every display writes 16 KB of
        picture -- and during that time the one thing that must not happen is
        somebody deciding nothing is happening and touching the simulation.
        A line of text at the foot of a window does not stop that; a modal
        does, which is the whole reason to use one here.

        The progress is FILES, not seconds.  Every part writes at its own
        pace and an estimate would be a guess; "5 of 9 saved" is a fact, and
        it also shows which part has stopped if it stops.
        """
        if self._busy is not None:
            self._busy.destroy()
        base = tkfont.nametofont("TkDefaultFont", self.root)
        head = tkfont.Font(family=base.cget("family"), size=abs(base.cget("size")),
                           weight="bold")
        # IN THE MANAGER'S OWN WINDOW, as _dialog's questions are: a separate
        # window can be drawn behind the others by the owner's compositor.
        try:
            self.root.deiconify()
            self.root.lift()
        except tk.TclError:
            pass
        self.root.update_idletasks()
        W = max(300, self.root.winfo_width())
        top = tk.Frame(self.root, bg=C_BG, highlightthickness=2,
                       highlightbackground=C_NOTE)
        top.place(x=0, y=0, relwidth=1, relheight=1)
        top.lift()
        pad = 24
        tk.Label(top, text=title.upper(), bg=C_BG, fg=C_NOTE, font=head, anchor="w"
                 ).pack(fill="x", padx=pad, pady=(pad, 8))
        tk.Label(top, text=lead, bg=C_BG, fg=C_FG, font=base, anchor="w",
                 justify="left", wraplength=W - 2 * pad
                 ).pack(fill="x", padx=pad, pady=(0, 6))
        tk.Label(top, text="Do not touch the simulation until this finishes.",
                 bg=C_BG, fg="#e0c070", font=base, anchor="w", justify="left",
                 wraplength=W - 2 * pad).pack(fill="x", padx=pad, pady=(0, 12))
        prog = tk.StringVar(value="Starting ...")
        box = tk.Frame(top, bg="#1b1b1b", highlightthickness=1,
                       highlightbackground="#4a4a4a")
        box.pack(fill="x", padx=pad)
        tk.Label(box, textvariable=prog, bg="#1b1b1b", fg=C_FG, font=base,
                 anchor="w", justify="left", wraplength=W - 2 * pad - 24
                 ).pack(fill="both", expand=True, padx=12, pady=12)
        row = tk.Frame(top, bg=C_BG)
        row.pack(fill="x", padx=pad, pady=(12, pad))
        if cancellable:
            if MAC:
                self._mac_button(row, "Cancel", self._cancel_busy, width=10,
                                 font=base).pack(side="right")
            else:
                tk.Button(row, text="Cancel", command=self._cancel_busy, width=10,
                          bg="#3c3c3c", fg=C_FG, activebackground="#505050",
                          activeforeground=C_FG, highlightbackground=C_BG, font=base
                          ).pack(side="right")
        # NO OK: the only way out is Cancel or the operation finishing.
        # Half-answering a modal that exists to stop meddling would defeat it.
        # The panel covers the Manager's controls, and a grab on it keeps a
        # click from reaching them anyway.
        try:
            top.grab_set()
        except tk.TclError:
            pass
        self._busy, self._busyText = top, prog
        return top

    # A save that finds everything already written takes a few tens of
    # milliseconds, and a modal that appears and vanishes inside that is a
    # flash nobody can read -- reported as three saves in a row that were
    # "essentially instantaneous", with the dialog unreadable each time.  So
    # the modal is not raised at once: if the answer comes back first, it is
    # never raised at all, and only an operation slow enough to be worth
    # waiting for puts a window up.
    BUSY_AFTER_MS = 400

    def _working_soon(self, title, lead, cancellable=True):
        self._busyPending = True

        def raise_it():
            if self._busyPending:
                self._busyPending = False
                self._working(title, lead, cancellable)

        self.root.after(self.BUSY_AFTER_MS, raise_it)

    def _cancel_busy(self):
        self._session("cancel")
        if self._busyText is not None:
            self._busyText.set("Cancelling ...")

    def _busy_progress(self, done, total):
        if self._busyText is None:
            return
        self._busyText.set("%d of %d file(s) saved." % (done, total)
                           if total else "Working ...")

    def _busy_done(self):
        self._busyPending = False        # never raise one after the answer
        if self._busy is not None:
            self._busy.destroy()
        self._busy = self._busyText = None

    # ---- snapshots ------------------------------------------------------
    #
    # ALL OF THESE JUST ASK.  The manager holds no process but the caption
    # box: it finds everything else by scanning /proc, which is enough to say
    # what is running and nowhere near enough to replace it.  A restore needs
    # fresh processes built from the configuration the run started with, and
    # the one process holding both is simulatePASS -- this window's own
    # parent.  So each of these is a datagram to os.getppid()'s listener, and
    # the work happens there.

    def start_results(self):
        threading.Thread(target=self._listen_results, daemon=True).start()
        threading.Thread(target=self._listen_progress, daemon=True).start()

    def _snapshot_dir(self, replacing=False):
        path = self.snapshot.get().strip()
        if not path:
            self.say("No snapshot directory chosen")
            return None
        if replacing:
            # SAVING OVER ONE DESTROYS IT, SILENTLY, and the path box keeps
            # whatever it last held -- so the way to lose a snapshot is to
            # take another without noticing the name did not change.  Which
            # is exactly what happened: three saves into three names and a
            # fourth into the second of them, leaving one snapshot holding a
            # vehicle nobody expected and one name that had never existed.
            man = os.path.join(path, "vehicle.json")
            if os.path.isfile(man):
                when = "an earlier run"
                try:
                    with open(man) as fh:
                        when = json.load(fh).get("taken", when)
                except (OSError, ValueError):
                    pass
                if not self._dialog(
                        "Replace this snapshot?",
                        "%s already holds a snapshot." % os.path.basename(
                            path.rstrip("/")),
                        "It was taken at %s, and saving over it cannot be "
                        "undone." % when,
                        "Change the name in the box first if you meant to keep "
                        "both.", confirm="Replace"):
                    self.say("Save cancelled; %s is untouched"
                             % os.path.basename(path.rstrip("/")))
                    return None
        return path

    def go(self):
        """Start a run that is held (simulatePASS --hold-start)."""
        if self._session("go"):
            self.say("Start: the vehicle starts if it was held")

    def _session(self, verb, path=None):
        try:
            crewscript.send_session(verb if path is None else "%s %s" % (verb, path),
                                    self.args.port_base)
        except OSError as e:
            self.say("Cannot reach simulatePASS: %s" % e)
            return False
        if verb in ("save", "save-and-quit", "resume"):
            self._rtStart[verb] = time.monotonic()
        return True

    def _rt_text(self):
        """The second status line: the real time lost to this window's saves
        and restores, as minutes and seconds."""
        m, sec = divmod(self._rtLost, 60.0)
        n_s, n_r = self._rtCount["save"], self._rtCount["resume"]
        return "\u0394RT \u2212%d:%04.1f  (%d save%s, %d restore%s)" % (
            int(m), sec, n_s, "" if n_s == 1 else "s", n_r, "" if n_r == 1 else "s")

    def _rt_finish(self, verdict, verb):
        """A save or restore this window asked for has been answered: add the
        time it held the vehicle.  A failed save still stopped the vehicle
        while it tried; a failed restore was refused before anything was
        stopped, so it costs nothing."""
        t0 = self._rtStart.pop(verb, None)
        if t0 is None or not (verdict == "ok" or (verdict == "fail" and verb == "save")):
            return
        self._rtLost += time.monotonic() - t0
        key = "resume" if verb == "resume" else "save"
        self._rtCount[key] += 1
        self.rt.set(self._rt_text())

    def save_snapshot(self):
        path = self._snapshot_dir(replacing=True)
        if path and self._session("save", path):
            self.say("Saving to %s ..." % os.path.basename(path), sticky=True)
            self._working_soon("Saving", "Saving the simulation to %s."
                               % os.path.basename(path))

    def save_and_quit(self):
        path = self._snapshot_dir(replacing=True)
        if path and self._session("save-and-quit", path):
            self.say("Saving to %s before shutting down ..." % os.path.basename(path),
                     sticky=True)
            self._working_soon("Saving", "Saving the simulation to %s, then shutting "
                               "down." % os.path.basename(path))

    def restore_snapshot(self):
        path = self._snapshot_dir()
        if not path:
            return
        if not os.path.isdir(path):
            self.say("No such snapshot: %s" % path)
            return
        if self._session("resume", path):
            self.say("Restoring from %s ..." % os.path.basename(path), sticky=True)
            # NOT CANCELLABLE.  By the time this is up the children are being
            # stopped; there is nothing left to go back to.
            self._working_soon("Restoring", "Restoring the simulation from %s.  "
                               "Every window except this one is being replaced."
                               % os.path.basename(path), cancellable=False)

    def show_panel(self):
        """Bring up a crew panel that a scripted run never mapped.

        simulatePASS hides it when it is given a --script, on the reasoning
        that nobody is watching an unattended run and an unmapped window
        cannot steal the keyboard.  But a script is also how someone sets a
        vehicle up before flying it by hand, and then the panel is the thing
        they want -- so rather than making them restart with --show-panel,
        ask for it.  The window is withdrawn, not destroyed.
        """
        try:
            crewscript.send_control("show", self.args.port_base)
        except OSError as e:
            self.say("Cannot reach the panel: %s" % e)
            return
        self.say("Asked the crew panel to show itself")

    def set_rate(self, x):
        if self._session("rate %g" % x):
            self.say("Speed %gx asked for: simulated seconds per wall second" % x)

    def end_simulation(self):
        """The only control here that destroys a run without saving it, so it
        is the only one that asks first.  Save & Quit does not, because its
        snapshot is written before anything is torn down."""
        if not self._dialog(
                "End simulation",
                "Shut the whole simulation down?",
                "Nothing is saved.  Everything since the last snapshot is "
                "lost, including the IPL -- which is several minutes of it.",
                "Use Save & Quit instead if you want to come back to this.",
                confirm="End Simulation"):
            return
        if self._session("quit"):
            self.say("Shutting the simulation down")

    def start_subtitles(self):
        if any(n == "subtitles.py" for n, _ in running(self.args.port_base)):
            self.say("A caption box is already running on this port base")
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
            self.say("Cannot start the caption box: %s" % e)
            return
        self.say("Caption box started (%s)" % " ".join(look))
        # PLACE IT, AND ONLY IT: restoring the whole layout here moved every
        # other window back too, undoing an arrangement made by hand (owner,
        # 2026-10-01, of the hand controllers' button, which did the same).
        if os.path.isfile(path):
            self.root.after(2500, lambda: self.restore_layout(only_roles={"subtitles"}))

    def start_hands(self, rhc):
        if any(n == "handcontrollers.py" for n, _ in running(self.args.port_base)):
            self.say("Hand controllers are already running on this port base; Stop them first")
            return
        argv = [sys.executable, os.path.join(HERE, "handcontrollers.py"),
                "--rhc", rhc, "--port-base", str(self.args.port_base),
                "--size", str(self.args.hc_size)]
        # simulatePASS's --joystick/--input/--style, as it would have passed
        # them had it started this station itself.
        for opt in ("joystick", "input", "style"):
            v = getattr(self.args, "hc_" + opt)
            if v is not None:
                argv += ["--" + opt, str(v)]
        try:
            self.hands = subprocess.Popen(argv, cwd=HERE, stdout=subprocess.DEVNULL,
                                          stderr=subprocess.STDOUT,
                                          stdin=subprocess.DEVNULL)
        except OSError as e:
            self.say("Cannot start the hand controllers: %s" % e)
            return
        self.say("Hand controllers started: %s"
                 % {"lh": "CDR (LH RHC, forward THC)", "rh": "PLT (RH RHC)",
                    "aft": "Aft (aft RHC and THC)"}[rhc])
        # PLACE IT, AND ONLY IT, where the layout says.  Restoring the whole
        # layout here moved every other window back as well, undoing what
        # the owner had just arranged by hand (2026-10-01).
        path = self.station_layout()
        if os.path.isfile(path):
            self.root.after(2500, lambda: self.restore_layout(
                only_roles={windowLayout._hc_role(rhc)}, path=path))

    # What can be seen from each station: the forward station's windows, or
    # the aft flight deck's overhead window and its A3 monitor's centerline
    # camera picture (portview's cctv).
    STATION_VIEWS = {"fwd": "front,up,left,right", "aft": "aft,cctv,rpop", "all": None}
    STATION_HANDS = {"fwd": "lh", "aft": "aft", "all": None}

    def set_station(self, st):
        """The STATION row: tell the panel and the displays, then follow."""
        crewscript.send_control("station %s" % st, self.args.port_base)
        crewscript.send_meds("station %s" % st, self.args.port_base)
        self._station_changed(st)

    def _start_station_listener(self):
        """A station change from anyone -- a flight script's handover (the
        CDR to the aft station at ESTABLISH RBAR), simulatePASS --station,
        or this window's own row -- arrives as 'station fwd|aft|all' on the
        panel's control port.  The Manager follows one it did not make:
        that station's hand controllers, views and layout.  The socket is
        read on a thread; the Tk work is done from _poll's queue."""
        import queue
        self._stationQ = queue.Queue()
        self.station = getattr(self.args, "station", "all")
        try:
            sock = crewscript.control_receiver(self.args.port_base)
        except OSError as e:
            print("manager: no station listener (%s)" % e, flush=True)
            return

        def listen():
            while True:
                try:
                    data, _a = sock.recvfrom(4096)
                except OSError:
                    return
                w = data.decode("utf-8", errors="replace").split()
                if len(w) == 2 and w[0] == "station" and w[1] in ("fwd", "aft", "all"):
                    self._stationQ.put(w[1])

        threading.Thread(target=listen, daemon=True).start()

    def _station_changed(self, st):
        """Follow a station change: its hand controllers and window views
        restarted, then -- with a layout for it -- its windows placed."""
        if st == self.station:
            return
        self.station = st
        self.say("Station: %s" % {"fwd": "forward", "aft": "aft flight deck", "all": "both"}[st])
        hands, views = self.STATION_HANDS[st], self.STATION_VIEWS[st]
        if hands:
            self.stop_hands()
        if views:
            self.stop_views()

        def restart():
            if hands:
                self.start_hands(hands)
            if views:
                self.start_views(views)
        # the stopped programs' ports and windows released first
        self.root.after(2500, restart)
        # A LAYOUT PER STATION (--layout for forward, --layout-aft for aft),
        # so a recording changes from one to the other by itself at the
        # handover.  Once the restarted windows are up: the views take ~8 s.
        path = (getattr(self.args, "layout_aft", None) if st == "aft"
                else self.layout.get().strip() if st == "fwd" else None)
        if path and os.path.isfile(path):
            self.root.after(14000, lambda: self.restore_layout(path=path))

    def start_views(self, views=None):
        # "rpop": rpop.py, the aft PGSC's RPOP display, a program of its own
        pv_views, want_rpop = windowLayout.split_views(views or self.args.portview_views)
        if want_rpop:
            self.start_rpop()
            if not pv_views:
                return
            views = pv_views
        if any(n == "portview.py" for n, _ in running(self.args.port_base)):
            self.say("The window views are already running on this port base; Stop them first")
            return
        script = os.path.join(HERE, "portview.py")
        try:
            chk = subprocess.run([sys.executable, script, "--check"], cwd=HERE,
                                 capture_output=True, text=True, timeout=30)
        except (OSError, subprocess.TimeoutExpired) as e:
            self.say("Cannot start the window views: %s" % e)
            return
        if chk.returncode != 0:
            self.say((chk.stdout.strip() or "portview: not started").splitlines()[-1])
            return
        argv = [sys.executable, script, "--port-base", str(self.args.port_base),
                "--size", str(self.args.portview_size)]
        # the run's own views unless a station asked for others: Start gave
        # only the forward view to a run begun with "aft,cctv" (owner)
        views = views or windowLayout.split_views(self.args.portview_views)[0]
        if views:
            argv += ["--views", views]
        try:
            self.views = subprocess.Popen(argv, cwd=HERE, stdout=subprocess.DEVNULL,
                                          stderr=subprocess.STDOUT,
                                          stdin=subprocess.DEVNULL)
        except OSError as e:
            self.say("Cannot start the window views: %s" % e)
            return
        self.say("Window views started")
        # PLACE THEM, AND ONLY THEM, where the layout says (as the hand
        # controllers): restoring the whole layout would undo what was
        # arranged by hand.  They take a few seconds to load their textures.
        # The station's layout, tried until they are up: on a slow machine
        # the views took longer than 25 s to open (a software-rendered
        # display); a try after they are placed moves nothing.
        path = self.station_layout()
        if os.path.isfile(path):
            for ms in (8000, 20000, 40000, 60000):
                self.root.after(ms, lambda: self.restore_layout(
                    only_roles=set(windowLayout.PORTVIEW_ROLES.values()), path=path))

    def start_rpop(self):
        if any(n == "rpop.py" for n, _ in running(self.args.port_base)):
            return
        try:
            subprocess.Popen([sys.executable, os.path.join(HERE, "rpop.py"),
                              "--port-base", str(self.args.port_base),
                              "--size", str(self.args.hc_size)], cwd=HERE,
                             stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT,
                             stdin=subprocess.DEVNULL)
        except OSError as e:
            self.say("Cannot start RPOP: %s" % e)
            return
        self.say("RPOP started")
        path = self.station_layout()
        if os.path.isfile(path):
            self.root.after(5000, lambda: self.restore_layout(only_roles={"rpop"}, path=path))

    def stop_rpop(self):
        for pid in [pid for n, pid in running(self.args.port_base) if n == "rpop.py"]:
            try:
                os.kill(pid, 15)
            except OSError:
                pass

    def stop_views(self):
        self.stop_rpop()
        if self.views is not None and self.views.poll() is None:
            self.views.terminate()
            self.views = None
            self.say("Window views stopped")
            return
        pids = [pid for n, pid in running(self.args.port_base) if n == "portview.py"]
        if not pids:
            self.say("No window views on this port base")
            return
        for pid in pids:
            try:
                os.kill(pid, 15)
            except OSError as e:
                self.say("Cannot stop %d: %s" % (pid, e))
                return
        self.say("Window views stopped (pid %s)" % ", ".join(map(str, pids)))

    def stop_hands(self):
        if self.hands is not None and self.hands.poll() is None:
            self.hands.terminate()
            self.hands = None
            self.say("Hand controllers stopped")
            return
        pids = [pid for n, pid in running(self.args.port_base) if n == "handcontrollers.py"]
        if not pids:
            self.say("No hand controllers on this port base")
            return
        for pid in pids:
            try:
                os.kill(pid, 15)
            except OSError as e:
                self.say("Cannot stop %d: %s" % (pid, e))
                return
        self.say("Hand controllers stopped (pid %s)" % ", ".join(map(str, pids)))

    def stop_subtitles(self):
        if self.subtitles is not None and self.subtitles.poll() is None:
            self.subtitles.terminate()
            self.say("Caption box stopped")
            self.subtitles = None
            return
        boxes = [pid for n, pid in running(self.args.port_base) if n == "subtitles.py"]
        if not boxes:
            self.say("No caption box on this port base")
            return
        for pid in boxes:
            try:
                os.kill(pid, 15)
            except OSError as e:
                self.say("Cannot stop %d: %s" % (pid, e))
                return
        self.say("Caption box stopped (pid %s)" % ", ".join(map(str, boxes)))

    # -- what is up ---------------------------------------------------------
    def _what_run(self):
        """The run's identity, as far as this window was told it.

        The port base alone was all it used to have, which says which run but
        not what the run IS -- and with several tapes and GPC counts in play
        that is exactly what someone reading a recording back needs.  All of
        it is passed by simulatePASS, which launches this last and so knows it.
        """
        bits = []
        if self.args.gpcs:
            n = len([g for g in self.args.gpcs.split(",") if g.strip()])
            bits.append("GPC%s %s" % ("s" if n > 1 else "", self.args.gpcs))
        if self.args.crts:
            bits.append("%d CRT%s" % (self.args.crts, "s" if self.args.crts > 1 else ""))
        if self.args.tape:
            bits.append(os.path.basename(self.args.tape))
        # NO PORT BASE.  It is how the programs find each other, not anything
        # a person looking at this window needs; it belongs on a command line,
        # where it came from, and reads as clutter here.
        return "  \u00b7  ".join(bits) if bits else "Simulation"

    def _poll(self):
        q = getattr(self, "_stationQ", None)
        while q is not None and not q.empty():
            self._station_changed(q.get_nowait())
        up = running(self.args.port_base)
        if up:
            counts = {}
            for name, _pid in up:
                counts[name] = counts.get(name, 0) + 1
            # Names a person uses, not the file names the scan found.
            pretty = {"yaGPC2": "GPC", "MEDS2.py": "MEDS", "panelO6.py": "Panel",
                      "discretePanel.py": "Panel", "cam.py": "O1",
                      "stsKeyboard.py": "Keyboard", "subtitles.py": "Captions",
                      "handcontrollers.py": "Hand controllers", "portview.py": "Views"}
            shown = []
            for n, c in sorted(counts.items()):
                shown.append("%s%s" % (pretty.get(n, n),
                                       " \u00d7%d" % c if c > 1 else ""))
            standing = ", ".join(shown)
        else:
            standing = "Nothing running"
        # A message from a button wins until it has been up long enough.
        if time.monotonic() >= self._note_until:
            self.note.set(standing)
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
    ap.add_argument("--layout-aft", metavar="FILE", default=None,
                    help="the aft station's layout, applied when the station changes to aft "
                         "(--layout is then the forward station's)")
    ap.add_argument("--station", choices=("fwd", "aft", "all"), default="all",
                    help="the station the run starts at (simulatePASS --station)")
    ap.add_argument("--geometry", metavar="SPEC", help="Tk geometry for this window")
    ap.add_argument("--debug", action="store_true",
                    help="put each script step on the status line as it runs. "
                         "Off by default: the step text means something to "
                         "whoever wrote the script and is a distraction to "
                         "everyone else, which is exactly wrong while PASS is "
                         "being demonstrated.  The SCRIPT heading shows the "
                         "count and the line either way.")
    # PASSED BY simulatePASS, which launches this last and so knows all of it.
    # Without them the manager can say which programs are up but not what the
    # run IS -- how many computers, which tape -- and Save needs to know the
    # GPC set to tell a complete snapshot from a partial one.
    ap.add_argument("--gpcs", metavar="LIST", default="",
                    help="which GPCs this run has, for the status line")
    ap.add_argument("--crts", type=int, metavar="N", default=0)
    ap.add_argument("--portview-views", default="", metavar="LIST",
                    help="the run's portview views, for Start under WINDOW VIEWS (simulatePASS "
                         "--portview-views; empty: portview's default)")
    ap.add_argument("--portview-size", type=int, metavar="N", default=368,
                    help="portview.py's --size for Start under WINDOW VIEWS (default 368)")
    ap.add_argument("--hc-size", type=int, metavar="N", default=384,
                    help="--size for hand controllers started from here "
                         "(simulatePASS passes the keyboards')")
    ap.add_argument("--hc-joystick", type=int, metavar="N", default=None,
                    help="--joystick for hand controllers started from here")
    ap.add_argument("--hc-input", choices=("auto", "joystick", "virtual"), default=None,
                    help="--input for hand controllers started from here")
    ap.add_argument("--hc-style", choices=("split", "gimbal"), default=None,
                    help="--style for hand controllers started from here")
    ap.add_argument("--tape", metavar="FILE", default="")
    ap.add_argument("--snapshot-dir", metavar="DIR", default="",
                    help="where Save writes and Restore reads")
    args = ap.parse_args(argv)
    if args.port_base is not None:
        D.set_port_base(args.port_base)
    else:
        args.port_base = D.PORT_BASE
    import macdock; macdock.set_app_name("Manager")                   # its Dock name
    root = tk.Tk()
    import windowLayout; windowLayout.claim(root)   # whose window this is
    if args.geometry:
        root.geometry(args.geometry)
    m = Manager(root, args)
    try:
        root.mainloop()
    finally:
        # A recording outlives nothing: stopped with the window, its file
        # already complete (recordscript.py writes after every action).
        if m._recorder is not None and m._recorder.poll() is None:
            m._recorder.terminate()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
