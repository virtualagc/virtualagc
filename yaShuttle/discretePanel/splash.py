#!/usr/bin/env python3
"""A start-up splash, in front of everything until simulatePASS says it is up.

    splash.py [--image FILE]

Reads lines from stdin:

    STAGE text      the current step (one short line)
    READY text      everything is up: shown briefly, then the window closes

and closes when stdin does.  Without --image it is a small plain window; with
one (PNG, GIF or, with Pillow, JPEG) the picture IS the splash and the step is
one line beneath it.  It sits on the PRIMARY monitor, never straddling two.
Without a display or Tk it exits at once, so a headless run is unaffected.
"""
import argparse
import os
import queue
import re
import subprocess
import sys
import threading
import time

try:
    import tkinter as tk
except Exception:
    sys.exit(0)

BG, FG, DIM, OK = "#202020", "#e8e8e8", "#8a8a8a", "#7ec87e"
HERE = os.path.dirname(os.path.abspath(__file__))


def primary_monitor(root):
    """(x, y, w, h) of the primary monitor.  Tk's screen is the whole virtual
    desktop on X11 (two monitors are one wide screen), so ask xrandr there; on
    Windows and macOS Tk's screen is the primary display already."""
    if sys.platform.startswith("linux"):
        try:
            out = subprocess.run(["xrandr", "--listmonitors"], capture_output=True,
                                 text=True, timeout=3).stdout
            first = None
            for line in out.splitlines():
                m = re.search(r"(\d+)/\d+x(\d+)/\d+\+(-?\d+)\+(-?\d+)", line)
                if not m:
                    continue
                g = (int(m.group(3)), int(m.group(4)), int(m.group(1)), int(m.group(2)))
                if first is None:
                    first = g
                if "*" in line.split(":", 1)[-1].split()[0]:
                    return g
            if first is not None:
                return first
        except (OSError, subprocess.SubprocessError):
            pass
    return (0, 0, root.winfo_screenwidth(), root.winfo_screenheight())


def load_image(path):
    try:
        return tk.PhotoImage(file=path)
    except tk.TclError:
        pass
    try:
        from PIL import Image, ImageTk
        return ImageTk.PhotoImage(Image.open(path))
    except Exception:
        return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image")
    args = ap.parse_args()
    try:
        root = tk.Tk()
    except Exception:
        return 0
    root.configure(bg=BG)
    root.overrideredirect(True)
    try:
        root.attributes("-topmost", True)
    except tk.TclError:
        pass
    mx, my, mw, mh = primary_monitor(root)
    img = None
    path = args.image
    if not path:
        for n in ("splash.png", "splash.jpg", "splash.gif"):
            if os.path.isfile(os.path.join(HERE, n)):
                path = os.path.join(HERE, n)
                break
    if path and os.path.isfile(path):
        img = load_image(path)
    FONT = ("Helvetica", 15, "italic")
    if img is not None:
        # no larger than 80% of the monitor
        k = max(1, -(-img.width() // int(mw * 0.8)), -(-img.height() // int(mh * 0.8)))
        if k > 1:
            img = img.subsample(k, k)
        w, h = img.width(), img.height()
        cv = tk.Canvas(root, width=w, height=h, bd=0, highlightthickness=0, bg=BG)
        cv.pack()
        cv.create_image(0, 0, image=img, anchor="nw")
        ty = h - 24                 # the status line sits ON the picture, along its bottom
    else:
        w, h = min(460, mw - 40), 150
        cv = tk.Canvas(root, width=w, height=h, bd=0, highlightthickness=0, bg=BG)
        cv.pack()
        cv.create_text(w // 2, 44, text="Starting the simulation", fill=FG,
                       font=("Helvetica", 18, "bold italic"))
        ty = 100
    # the text is drawn twice, a dark copy a pixel off, so it reads on any picture
    shadow = cv.create_text(w // 2 + 1, ty + 1, text="", fill="#000000", font=FONT,
                            width=w - 40, anchor="center")
    status = cv.create_text(w // 2, ty, text="", fill=FG, font=FONT, width=w - 40,
                            anchor="center")

    def say(text, colour=FG):
        cv.itemconfig(shadow, text=text)
        cv.itemconfig(status, text=text, fill=colour)
    root.update_idletasks()
    root.geometry("%dx%d+%d+%d" % (w, h, mx + (mw - w) // 2, my + (mh - h) // 2))
    q = queue.Queue()

    def reader():
        for line in sys.stdin:
            q.put(line.rstrip("\n"))
        q.put(None)
    threading.Thread(target=reader, daemon=True).start()
    ready = [None]

    def pump():
        try:
            while True:
                line = q.get_nowait()
                if line is None:
                    root.destroy()
                    return
                kind, _, text = line.partition(" ")
                if kind == "STAGE":
                    say(text.rstrip(" .") + " ...")          # an operation under way
                elif kind == "READY":
                    say(text or "Ready", OK)
                    ready[0] = time.monotonic()
        except queue.Empty:
            pass
        if ready[0] is not None and time.monotonic() - ready[0] > 3.0:
            root.destroy()
            return
        root.after(150, pump)
    root.after(100, pump)
    root.mainloop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
