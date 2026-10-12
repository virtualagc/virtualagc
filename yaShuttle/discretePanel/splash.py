#!/usr/bin/env python3
"""A start-up splash: tells the user the simulation is still coming up and
what it is doing, in front of everything, until simulatePASS says it is ready.

Started by simulatePASS.py; it reads lines from its stdin:

    STAGE text      the current step, shown big; earlier ones tick off below
    READY text      everything is up: shown for a moment, then the window closes

and closes by itself when stdin closes.  Runs fine without a display (it then
exits at once), so a headless run is unaffected.
"""
import sys
import threading
import time
import queue

try:
    import tkinter as tk
except Exception:                       # no Tk here: simulatePASS carries on without
    sys.exit(0)

BG, FG, DIM, OK, WARN = "#1e1e1e", "#e8e8e8", "#8a8a8a", "#7ec87e", "#f2c14e"


def main():
    try:
        root = tk.Tk()
    except Exception:
        return 0
    root.title("Starting")
    root.configure(bg=BG)
    root.overrideredirect(True)                 # no frame: nothing to drag or close
    try:
        root.attributes("-topmost", True)
    except tk.TclError:
        pass
    w, h = 640, 330
    sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
    root.geometry("%dx%d+%d+%d" % (w, h, (sw - w) // 2, (sh - h) // 3))
    tk.Label(root, text="STARTING THE SIMULATION", bg=BG, fg=FG,
             font=("Helvetica", 22, "bold")).pack(pady=(22, 4))
    tk.Label(root, text="Please wait.  Do not touch the windows or the keyboard until this "
             "message goes.", bg=BG, fg=WARN, font=("Helvetica", 13), wraplength=w - 40).pack()
    cur = tk.Label(root, text="", bg=BG, fg=FG, font=("Helvetica", 15), wraplength=w - 40)
    cur.pack(pady=(18, 4))
    done_box = tk.Label(root, text="", bg=BG, fg=DIM, font=("Helvetica", 11), justify="left",
                        anchor="w", wraplength=w - 60)
    done_box.pack(fill="x", padx=30)
    clock = tk.Label(root, text="0 s", bg=BG, fg=DIM, font=("Helvetica", 11))
    clock.pack(side="bottom", pady=10)
    q = queue.Queue()
    t0 = time.monotonic()
    stages = []                                 # finished steps

    def reader():
        for line in sys.stdin:
            q.put(line.rstrip("\n"))
        q.put(None)
    threading.Thread(target=reader, daemon=True).start()

    state = {"cur": "", "ready": None}

    def pump():
        try:
            while True:
                line = q.get_nowait()
                if line is None:
                    root.destroy()
                    return
                kind, _, text = line.partition(" ")
                if kind == "STAGE":
                    if state["cur"]:
                        stages.append(state["cur"])
                    state["cur"] = text
                    cur.config(text=text + " ...", fg=FG)
                    done_box.config(text="\n".join("  ✓ " + s for s in stages[-6:]))
                elif kind == "READY":
                    if state["cur"]:
                        stages.append(state["cur"])
                        state["cur"] = ""
                    cur.config(text=text or "Ready", fg=OK)
                    done_box.config(text="\n".join("  ✓ " + s for s in stages[-6:]))
                    state["ready"] = time.monotonic()
        except queue.Empty:
            pass
        clock.config(text="%d s" % (time.monotonic() - t0))
        if state["ready"] is not None and time.monotonic() - state["ready"] > 4.0:
            root.destroy()
            return
        root.after(200, pump)
    root.after(100, pump)
    root.mainloop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
