#!/usr/bin/env python3
"""videoscan.py: FIND SUDDEN CHANGES IN A REGION OF A VIDEO (the ISS blinking
out of a view), so a run need not be watched or its video reviewed in full.

    python3 videoscan.py VIDEO --grab 3600 --out frame.png      # one frame, to pick a region
    python3 videoscan.py VIDEO --roi 100,200,640,480 [--roi ...] [--gmt0 138/09:00:00]
                         [--start S] [--end S] [--save-frames DIR] [--follow]

A REGION (--roi x,y,w,h, pixels of the video frame; several allowed) is
reduced to grey levels, and the frame-to-frame change inside it is followed.
A vehicle that vanishes or reappears between two frames makes that change jump
to many times its running median -- whatever the background, the view's own
slow motion included.  "Change" is the NUMBER of pixels (at half size) that
differ by more than --pixel-delta grey levels between consecutive frames, so
a small bright object blinking in a large region still counts.  Reported, per region: the time (video seconds, and GMT
if --gmt0 gives the GMT at the video's start), the size of the jump, and
whether a second jump follows within --max-gap seconds (a blink: gone and
back) with the time between them.  --save-frames writes the frames before,
at and after each event, so the events can be looked at in a minute.

MKV can be read while it is being recorded (--follow keeps waiting for more
frames); MP4 only once it is closed.  Uses ffmpeg's decoder through OpenCV.
"""
import argparse
import sys
import time
from collections import deque

import cv2
import numpy as np


def fmt(t):
    h, r = divmod(t, 3600)
    m, s = divmod(r, 60)
    return "%d:%02d:%05.2f" % (h, m, s)


def gmt_of(t, gmt0):
    if gmt0 is None:
        return ""
    day, hms = gmt0.split("/")
    hh, mm, ss = (float(x) for x in hms.split(":"))
    sec = hh * 3600 + mm * 60 + ss + t
    d = int(day) + int(sec // 86400)
    sec %= 86400
    return "  GMT %03d/%02d:%02d:%04.1f" % (d, sec // 3600, sec % 3600 // 60, sec % 60)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("video")
    ap.add_argument("--roi", action="append", help="x,y,w,h in frame pixels (default: the whole frame)")
    ap.add_argument("--gmt0", help="GMT at the video's start, like 138/09:00:00")
    ap.add_argument("--start", type=float, default=0.0, help="start at this video second")
    ap.add_argument("--end", type=float, default=0.0, help="stop at this video second")
    ap.add_argument("--factor", type=float, default=8.0, help="jump = this many times the running median (default 8)")
    ap.add_argument("--abs", dest="absmin", type=float, default=20.0,
                    help="and at least this many changed pixels at half size (default 20)")
    ap.add_argument("--pixel-delta", type=float, default=40.0,
                    help="a pixel counts as changed above this many grey levels (default 40)")
    ap.add_argument("--max-gap", type=float, default=10.0, help="a blink returns within this many seconds (default 10)")
    ap.add_argument("--save-frames", metavar="DIR")
    ap.add_argument("--follow", action="store_true", help="keep waiting for a file still being written")
    ap.add_argument("--grab", type=float, metavar="SECOND", help="write one frame at this second and exit")
    ap.add_argument("--out", default="frame.png")
    a = ap.parse_args()

    cap = cv2.VideoCapture(a.video)
    if not cap.isOpened():
        sys.exit("videoscan: cannot open %s" % a.video)
    fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
    W, H = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)), int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    if a.grab is not None:
        cap.set(cv2.CAP_PROP_POS_MSEC, a.grab * 1000.0)
        ok, fr = cap.read()
        if not ok:
            sys.exit("videoscan: no frame at %.1f s" % a.grab)
        cv2.imwrite(a.out, fr)
        print("wrote %s (%dx%d); pick a region as x,y,w,h in these pixels" % (a.out, W, H))
        return
    rois = []
    for r in (a.roi or ["0,0,%d,%d" % (W, H)]):
        x, y, w, h = (int(v) for v in r.split(","))
        rois.append((x, y, min(w, W - x), min(h, H - y)))
    if a.start:
        cap.set(cv2.CAP_PROP_POS_MSEC, a.start * 1000.0)
    print("# %s: %dx%d, %.2f fps; regions %s" % (a.video, W, H, fps, rois), flush=True)
    prev = [None] * len(rois)
    hist = [deque(maxlen=int(fps * 4)) for _ in rois]       # recent changes, ~4 s
    open_ev = [None] * len(rois)                            # a jump awaiting its partner
    recent = deque(maxlen=int(fps * 3))                     # frames kept for --save-frames
    n = 0
    events = 0
    while True:
        ok, fr = cap.read()
        if not ok:
            if a.follow:
                time.sleep(2.0)
                cap.release()
                cap = cv2.VideoCapture(a.video)
                cap.set(cv2.CAP_PROP_POS_FRAMES, n + int(a.start * fps))
                continue
            break
        t = a.start + n / fps
        n += 1
        if a.end and t > a.end:
            break
        small = cv2.resize(fr, (W // 4, H // 4), interpolation=cv2.INTER_AREA) if a.save_frames else None
        if a.save_frames:
            recent.append((t, fr.copy()))
        for i, (x, y, w, h) in enumerate(rois):
            g = cv2.cvtColor(fr[y:y + h, x:x + w], cv2.COLOR_BGR2GRAY)
            g = cv2.resize(g, (max(8, w // 2), max(8, h // 2)), interpolation=cv2.INTER_AREA).astype(np.float32)
            if prev[i] is not None:
                d = float(np.count_nonzero(np.abs(g - prev[i]) > a.pixel_delta))
                base = float(np.median(hist[i])) if len(hist[i]) >= fps else None
                if base is not None and d > max(a.factor * max(base, 1.0), a.absmin):
                    ev = open_ev[i]
                    if ev is not None and t - ev[0] <= a.max_gap:
                        print("BLINK  region %d  gone/changed at %s%s, back/changed again %.2f s later (%d and %d changed pixels vs median %.1f)"
                              % (i, fmt(ev[0]), gmt_of(ev[0], a.gmt0), t - ev[0], ev[1], d, base), flush=True)
                        events += 1
                        open_ev[i] = None
                        if a.save_frames:
                            cv2.imwrite("%s/blink_r%d_%s.png" % (a.save_frames, i, fmt(ev[0]).replace(":", "-")), fr)
                    else:
                        if ev is not None:
                            print("JUMP   region %d  at %s%s (%d changed pixels vs median %.1f), no partner within %.0f s"
                                  % (i, fmt(ev[0]), gmt_of(ev[0], a.gmt0), ev[1], ev[2], a.max_gap), flush=True)
                            events += 1
                        open_ev[i] = (t, d, base)
                else:
                    hist[i].append(d)
                    ev = open_ev[i]
                    if ev is not None and t - ev[0] > a.max_gap:
                        print("JUMP   region %d  at %s%s (%d changed pixels vs median %.1f), no partner within %.0f s"
                              % (i, fmt(ev[0]), gmt_of(ev[0], a.gmt0), ev[1], ev[2], a.max_gap), flush=True)
                        events += 1
                        open_ev[i] = None
            prev[i] = g
    print("# done: %d frames (%.1f s), %d event(s)" % (n, n / fps, events), flush=True)


if __name__ == "__main__":
    main()
