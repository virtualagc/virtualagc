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
import json
import os
import subprocess
import threading
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
# The status bar at the foot.  SILVER WITH BLACK TEXT, not another dark grey:
# a dark panel among dark buttons reads as one more button, and the one thing
# in the window that cannot be pressed should not look like the things that
# can.  Reversing it out is what makes it a band rather than a control.
C_STATUS = "#c0c0c0"
# The space around a button, used again between rows of them.
BUTTON_GAP = 2
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
        # SHORT ENOUGH TO READ.  This window is narrow, and a title bar it
        # cannot fit says nothing at all: "Simulation manager" came back as
        # something unreadable, let alone with the run appended.  The run is
        # in the status line instead, where there is a whole width for it.
        root.title("Manager")
        root.configure(bg=C_BG)
        shrink_fonts(root, 2)
        bold = tkfont.Font(family="Helvetica", size=8, weight="bold")

        self.script = tk.StringVar(value=args.script or self._first_script())
        self.layout = tk.StringVar(value=args.layout)
        self.snapshot = tk.StringVar(value=args.snapshot_dir)
        # ONE LINE.  There were two, and the upper one only ever restated what
        # the poll below already says -- a status line above the status line.
        # What is running is the standing status; a message from a button
        # takes the line for a few seconds and then it goes back.
        self.note = tk.StringVar(value="")
        self._note_until = 0.0
        self._busy = self._busyText = None      # the "please wait" modal
        self._busyPending = False

        # A path is long and its interesting end is the file name, so each box
        # is as wide as the window (and grows with it) and is scrolled to show
        # the end whenever it changes; the buttons sit underneath rather than
        # stealing the width.
        self._section("SCRIPT", bold)
        self._path_box(self.script)
        row = self._row()
        self._button(row, "Browse", self.browse_script)
        self._button(row, "Play", self.play, wide=True)
        self._button(row, "Stop", self.stop)

        self._section("LAYOUT", bold)
        self._path_box(self.layout)
        row = self._row()
        self._button(row, "Browse", self.browse_layout)
        self._button(row, "Save", self.save_layout, wide=True)
        self._button(row, "Restore", self.restore_layout)

        # SNAPSHOT.  Save & Continue is the one that has to be reachable at an
        # unplanned moment -- the whole reason this window exists -- so it is
        # the wide button.  End Simulation is deliberately in its own section,
        # away from the three that write a file first: it is the only control
        # here that destroys a run without saving it.
        self._section("SNAPSHOT", bold)
        self._path_box(self.snapshot)
        row = self._row()
        self._button(row, "Browse", self.browse_snapshot)
        self._button(row, "Save", self.save_snapshot, wide=True)
        row = self._row()
        self._button(row, "Save & Quit", self.save_and_quit)
        self._button(row, "Restore", self.restore_snapshot)

        self._section("CAPTION BOX", bold)
        row = self._row()
        self._button(row, "Start", self.start_subtitles, wide=True)
        self._button(row, "Stop", self.stop_subtitles)

        self._section("SIMULATION", bold)
        row = self._row()
        self._button(row, "Show Panel", self.show_panel)
        self._button(row, "End Simulation", self.end_simulation)

        # ONE BAND, SET OFF FROM THE CONTROLS.  Both lines say what the run is
        # doing rather than offering anything to do, so they read as a status
        # bar and are given their own background to say so.
        bar = tk.Frame(root, bg=C_STATUS)
        bar.pack(fill="x", side="bottom", pady=(10, 0))
        # width=1 IS WHY THE WINDOW STOPS BREATHING.  A label asks for room
        # enough to show its text, and this one's text changes every three
        # seconds -- so the window grew and shrank under a person who had
        # just put it where they wanted it.  Asking for one character and
        # filling the width instead means the text never drives the size.
        tk.Label(bar, textvariable=self.note, bg=C_STATUS, fg=C_STATUS_FG,
                 anchor="w", justify="left", width=1
                 ).pack(fill="x", padx=10, pady=6)
        root.bind_all("<Control-q>", lambda _e: root.quit())
        # AND PINNED ONCE, at the size the controls actually need.  Without
        # this the toplevel keeps taking its size from its contents, and any
        # later change of text moves the edges again.  A person may still
        # resize it; nothing here will.
        root.update_idletasks()
        root.minsize(root.winfo_reqwidth(), root.winfo_reqheight())
        if not args.geometry:
            root.geometry("%dx%d" % (root.winfo_reqwidth(), root.winfo_reqheight()))
        # Recorded rather than displayed: the window is too narrow to carry it
        # and the log is where it is wanted afterwards anyway.
        print("manager: %s" % self._what_run(), flush=True)
        self.start_results()
        self._poll()

    # -- the furniture ------------------------------------------------------
    def _section(self, text, font):
        tk.Label(self.root, text=text, bg=C_BG, fg="#8fbc8f", font=font,
                 anchor="w").pack(fill="x", padx=10, pady=(10, 2))

    def _row(self):
        # pady MATCHES THE BUTTONS' OWN padx, so two rows of buttons are
        # separated by as much as two buttons side by side.  Without it
        # "Browse | Save" and "Save & Quit | Restore" read as one block of
        # four rather than as two rows.
        row = tk.Frame(self.root, bg=C_BG)
        row.pack(fill="x", padx=10, pady=BUTTON_GAP)
        return row

    def _path_box(self, var):
        """A file name box the width of the window, showing the END of the
        path -- the part that says which file it is."""
        entry = tk.Entry(self.root, textvariable=var, bg="#1b1b1b", fg=C_FG,
                         insertbackground=C_FG, highlightthickness=1,
                         highlightbackground="#4a4a4a", highlightcolor="#7a9a7a")
        entry.pack(fill="x", padx=10, pady=(0, 2))
        show_end = lambda *_a: entry.after_idle(lambda: entry.xview_moveto(1.0))
        var.trace_add("write", show_end)
        entry.bind("<Configure>", show_end)      # and when the window is resized
        show_end()
        return entry

    def _button(self, row, text, command, wide=False):
        # AT LEAST AS WIDE AS ITS LABEL.  The width is in characters and was
        # fixed at 7 or 8, which silently clipped anything longer: "Save &
        # Quit" read "ave & qui" and "End Simulation" read "nd Simulatio".
        # The minimum keeps the short buttons the size they have always been.
        tk.Button(row, text=text, command=command,
                  width=max(8 if wide else 7, len(text)),
                  bg="#3c3c3c", fg=C_FG, activebackground="#505050",
                  activeforeground=C_FG, highlightbackground=C_BG,
                  relief="raised").pack(side="left", padx=BUTTON_GAP)

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

    def browse_snapshot(self):
        """CHOOSE A SNAPSHOT BY WHEN IT WAS TAKEN, not by its name.

        A file browser cannot do this.  It shows directories, and snapshots
        are directories with deliberately similar names -- snapshot301-6,
        snapshot000-2, snapshot901-99 -- so picking between a dozen of them
        by name alone is guesswork, and the one fact that tells them apart is
        the one a directory chooser will not show: when each was taken.
        vehicle.json has recorded exactly that since the first one, so this
        reads it and lists them newest first.
        """
        current = self.snapshot.get().strip()
        parent = os.path.dirname(current.rstrip("/")) if current else HERE
        if not os.path.isdir(parent):
            parent = HERE
        rows = []
        try:
            for name in os.listdir(parent):
                path = os.path.join(parent, name)
                man = os.path.join(path, "vehicle.json")
                if not os.path.isfile(man):
                    continue
                try:
                    with open(man) as fh:
                        v = json.load(fh)
                    when = float(v.get("epoch", 0))
                    gpcs = ",".join(str(g) for g in v.get("gpcs", []))
                except (OSError, ValueError, TypeError):
                    when, gpcs = os.path.getmtime(path), "?"
                extra = []
                if os.path.isfile(os.path.join(path, "layout.json")):
                    extra.append("windows")
                if os.path.isfile(os.path.join(path, "panel.json")):
                    extra.append("panel")
                rows.append((when, name, gpcs, ", ".join(extra)))
        except OSError as e:
            self.say("Cannot list %s: %s" % (parent, e))
            return
        if not rows:
            # Nothing to choose between; fall back to the ordinary chooser so
            # somewhere else can be pointed at.
            name = filedialog.askdirectory(title="Snapshot directory",
                                           initialdir=parent, mustexist=False)
            if name:
                self.snapshot.set(name)
            return
        rows.sort(reverse=True)               # newest first
        self._choose_snapshot(parent, rows)

    def _choose_snapshot(self, parent, rows):
        """The list itself: name, when it was taken, and what is in it."""
        base = tkfont.nametofont("TkDefaultFont", self.root)
        mono = tkfont.Font(family="monospace", size=abs(base.cget("size")))
        W, H = 620, 400
        top = tk.Toplevel(self.root, bg=C_BG)
        top.title("Choose a snapshot")
        top.transient(self.root)
        self.root.update_idletasks()
        top.geometry("%dx%d+%d+%d" % (
            W, H,
            max(0, self.root.winfo_rootx() + (self.root.winfo_width() - W) // 2),
            max(0, self.root.winfo_rooty() + (self.root.winfo_height() - H) // 3)))
        tk.Label(top, text="In %s" % parent, bg=C_BG, fg="#9a9a9a", font=base,
                 anchor="w", justify="left", wraplength=W - 48
                 ).pack(fill="x", padx=24, pady=(20, 6))
        frame = tk.Frame(top, bg="#1b1b1b", highlightthickness=1,
                         highlightbackground="#4a4a4a")
        frame.pack(fill="both", expand=True, padx=24)
        bar = tk.Scrollbar(frame)
        bar.pack(side="right", fill="y")
        box = tk.Listbox(frame, bg="#1b1b1b", fg=C_FG, font=mono,
                         selectbackground="#4a6a4a", selectforeground=C_FG,
                         highlightthickness=0, borderwidth=0, activestyle="none",
                         yscrollcommand=bar.set)
        box.pack(side="left", fill="both", expand=True, padx=8, pady=8)
        bar.config(command=box.yview)
        width = max(len(r[1]) for r in rows)
        for when, name, gpcs, extra in rows:
            box.insert("end", "%-*s   %s   GPC %-6s %s" % (
                width, name,
                time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(when)),
                gpcs, extra))
        box.selection_set(0)
        box.focus_set()

        def take(_e=None):
            sel = box.curselection()
            if sel:
                self.snapshot.set(os.path.join(parent, rows[sel[0]][1]))
                self.say("Chose %s" % rows[sel[0]][1])
            top.destroy()

        row = tk.Frame(top, bg=C_BG)
        row.pack(fill="x", padx=24, pady=(12, 24))
        for text, cmd in (("Open", take), ("Cancel", top.destroy)):
            tk.Button(row, text=text, command=cmd, width=10, bg="#3c3c3c",
                      fg=C_FG, activebackground="#505050", activeforeground=C_FG,
                      highlightbackground=C_BG, font=base
                      ).pack(side="right", padx=(8, 0))
        box.bind("<Double-Button-1>", take)
        top.bind("<Return>", take)
        top.bind("<Escape>", lambda _e: top.destroy())
        top.grab_set()

    def _browse_snapshot_plain(self):
        """The ordinary chooser, for pointing somewhere new."""
        # THE PARENT, not the snapshot itself.  Opening inside the last one
        # saved shows its gpc<N> files, which are not what is being chosen;
        # one level up is where the snapshots are, which is where someone
        # picking between them wants to start.
        current = self.snapshot.get().strip()
        start = os.path.dirname(current.rstrip("/")) if current else HERE
        name = filedialog.askdirectory(
            title="Snapshot directory",
            initialdir=start or HERE, mustexist=False)
        if name:
            self.snapshot.set(name)

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

    def stop(self):
        try:
            crewscript.send_control("stop")
            self.say("Asked the panel to stop the script")
        except OSError as e:
            self.say("Cannot reach the panel: %s" % e)

    def save_layout(self):
        path = self.layout.get().strip()
        if not path:
            self.say("No layout file chosen")
            return
        try:
            n = windowLayout.save_layout(path, log=lambda _t: None)
        except OSError as e:
            self.say("Cannot save: %s" % e)
            return
        self.say("Saved %d windows to %s" % (n, os.path.basename(path)))

    def restore_layout(self):
        path = self.layout.get().strip()
        if not os.path.isfile(path):
            self.say("No such layout file: %s" % path)
            return
        placed, missing, inexact = windowLayout.restore_layout(path, log=lambda _t: None)
        self.say("Placed %d window(s)%s%s" % (
            placed, ", %d not running" % missing if missing else "",
            ", %d not exactly" % inexact if inexact else ""))

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
        """A window of our own rather than tkinter.messagebox.

        The native dialogs hand their shape to the platform: they size to the
        text, which for messages of this length comes out tall, narrow and
        bold -- and bold is what makes them read as an alarm when what they
        need to do is be legible.  A Toplevel can be shaped: wider than it is
        tall, the reason set off from the sentence around it, the ordinary
        face at the window's own size, and nothing emboldened anywhere.

        `confirm`, when given, is the label of the button that says yes, and
        makes this ask rather than tell: it waits, and returns True or False.
        """
        base = tkfont.nametofont("TkDefaultFont", self.root)
        body = tkfont.Font(family=base.cget("family"),
                           size=abs(base.cget("size")), weight="normal")

        W, H = 620, 400            # wider than 4:3, which is what was asked for
        answer = {"ok": False}
        top = tk.Toplevel(self.root, bg=C_BG)
        top.title(title)
        top.transient(self.root)
        top.resizable(True, True)
        # Over the window it belongs to, not wherever the pointer happens to be.
        self.root.update_idletasks()
        x = self.root.winfo_rootx() + (self.root.winfo_width() - W) // 2
        y = self.root.winfo_rooty() + (self.root.winfo_height() - H) // 3
        top.geometry("%dx%d+%d+%d" % (W, H, max(0, x), max(0, y)))

        pad = 24
        tk.Label(top, text=lead, bg=C_BG, fg=C_FG, font=body, anchor="w",
                 justify="left", wraplength=W - 2 * pad
                 ).pack(fill="x", padx=pad, pady=(pad, 12))
        # The part that differs between one of these and the next, in a panel
        # of its own so it does not compete with the sentence around it.
        box = tk.Frame(top, bg="#1b1b1b", highlightthickness=1,
                       highlightbackground="#4a4a4a")
        box.pack(fill="both", expand=True, padx=pad)
        tk.Label(box, text=detail, bg="#1b1b1b", fg=C_FG, font=body, anchor="nw",
                 justify="left", wraplength=W - 2 * pad - 24
                 ).pack(fill="both", expand=True, padx=12, pady=12)
        tk.Label(top, text=footnote, bg=C_BG, fg="#9a9a9a", font=body,
                 anchor="w", justify="left", wraplength=W - 2 * pad
                 ).pack(fill="x", padx=pad, pady=(12, 8))

        row = tk.Frame(top, bg=C_BG)
        row.pack(fill="x", padx=pad, pady=(0, pad))

        def close(ok):
            answer["ok"] = ok
            top.destroy()

        def button(text, ok, default):
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
            top.bind("<Return>", lambda _e: close(True))
        else:
            # Cancel is the default, because this is asked only where saying
            # yes cannot be undone.
            button(confirm, True, False)
            button("Cancel", False, True)
            top.bind("<Return>", lambda _e: close(False))
        top.bind("<Escape>", lambda _e: close(False))
        top.protocol("WM_DELETE_WINDOW", lambda: close(False))
        top.grab_set()
        if confirm is not None:
            self.root.wait_window(top)
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
        W, H = 620, 260
        top = tk.Toplevel(self.root, bg=C_BG)
        top.title(title)
        top.transient(self.root)
        self.root.update_idletasks()
        top.geometry("%dx%d+%d+%d" % (
            W, H,
            max(0, self.root.winfo_rootx() + (self.root.winfo_width() - W) // 2),
            max(0, self.root.winfo_rooty() + (self.root.winfo_height() - H) // 3)))
        pad = 24
        tk.Label(top, text=lead, bg=C_BG, fg=C_FG, font=base, anchor="w",
                 justify="left", wraplength=W - 2 * pad
                 ).pack(fill="x", padx=pad, pady=(pad, 6))
        tk.Label(top, text="Do not touch the simulation until this finishes.",
                 bg=C_BG, fg="#e0c070", font=base, anchor="w", justify="left",
                 wraplength=W - 2 * pad).pack(fill="x", padx=pad, pady=(0, 12))
        prog = tk.StringVar(value="Starting ...")
        box = tk.Frame(top, bg="#1b1b1b", highlightthickness=1,
                       highlightbackground="#4a4a4a")
        box.pack(fill="both", expand=True, padx=pad)
        tk.Label(box, textvariable=prog, bg="#1b1b1b", fg=C_FG, font=base,
                 anchor="w", justify="left", wraplength=W - 2 * pad - 24
                 ).pack(fill="both", expand=True, padx=12, pady=12)
        row = tk.Frame(top, bg=C_BG)
        row.pack(fill="x", padx=pad, pady=(12, pad))
        if cancellable:
            tk.Button(row, text="Cancel", command=self._cancel_busy, width=10,
                      bg="#3c3c3c", fg=C_FG, activebackground="#505050",
                      activeforeground=C_FG, highlightbackground=C_BG, font=base
                      ).pack(side="right")
        # NO OK, and the window manager's close button does nothing: the only
        # way out is Cancel or the operation finishing.  Half-answering a
        # modal that exists to stop meddling would defeat it.
        top.protocol("WM_DELETE_WINDOW", lambda: None)
        top.grab_set()
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

    def _session(self, verb, path=None):
        try:
            crewscript.send_session(verb if path is None else "%s %s" % (verb, path),
                                    self.args.port_base)
        except OSError as e:
            self.say("Cannot reach simulatePASS: %s" % e)
            return False
        return True

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
        if os.path.isfile(path):
            self.root.after(2500, self.restore_layout)   # put it where the layout says

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
        up = running(self.args.port_base)
        if up:
            counts = {}
            for name, _pid in up:
                counts[name] = counts.get(name, 0) + 1
            # Names a person uses, not the file names the scan found.
            pretty = {"yaGPC2": "GPC", "MEDS2.py": "MEDS", "panelO6.py": "Panel",
                      "discretePanel.py": "Panel", "cam.py": "CAM",
                      "stsKeyboard.py": "Keyboard", "subtitles.py": "Captions"}
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
    ap.add_argument("--geometry", metavar="SPEC", help="Tk geometry for this window")
    # PASSED BY simulatePASS, which launches this last and so knows all of it.
    # Without them the manager can say which programs are up but not what the
    # run IS -- how many computers, which tape -- and Save needs to know the
    # GPC set to tell a complete snapshot from a partial one.
    ap.add_argument("--gpcs", metavar="LIST", default="",
                    help="which GPCs this run has, for the status line")
    ap.add_argument("--crts", type=int, metavar="N", default=0)
    ap.add_argument("--tape", metavar="FILE", default="")
    ap.add_argument("--snapshot-dir", metavar="DIR", default="",
                    help="where Save writes and Restore reads")
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
