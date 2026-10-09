#!/usr/bin/env python3
"""THE CAUTION AND WARNING TONES, synthesised from their published parameters.

The Orbiter had exactly four alarm tones, from two redundant tone generators
in the C&W electronics unit, and no voice callouts (Caution and Warning
Workbook USA006019, Table 2-1, PDF p. 19, "actual" values; SCOM OI-28 Part 1
section 2.2; ~/workspace/pass-run/entry/landing-indicators-findings.md
section 3).  No recording is known, so each is generated here:

  C&W TONE   400 Hz for 0.4 s, then 1024 Hz for 0.4 s, alternating; until a
             MASTER ALARM pushbutton silences it.
  SM ALERT   512 Hz, steady; while PASS holds its alert-tone bit (PASS times
             it: 0-99 s, set on SPEC 2 item 23, 1 s typical).
  SIREN      666 Hz up to 1470 Hz and back, 5 s a cycle; until silenced.
  KLAXON     2560 Hz gated 2.1 ms on / 1.6 ms off, mixed with 256 Hz gated
             215 ms on / 70 ms off; until silenced.

THE C&W TONE'S TIMING is the workbook's own reading of its "2.5 Hz rate": "(In
other words, it is 400 Hz for 0.4 seconds, then 1024 Hz for 0.4 seconds)" --
not 0.2 s each, as a set of synthesised files circulating as authentic has it
(they also put the alert tone at 560 Hz, the spec's tolerance, not the
measured 512; their constant level shows they are synthesised too).

NOT DOCUMENTED, AND CHOSEN HERE: every waveform (sine), the siren's sweep law
(linear, a triangle: the workbook says only "varying frequency from 666 Hz to
1470 Hz and return", and those files sweep linearly too), the klaxon's mix
(equal), the loudness (one level for all,
below full scale), and soft 3 ms edges where a tone is gated, so the gates do
not click.  The generated files are cached; nothing here is committed audio.

    python3 cwaudio.py [TONE ...]     write the files and play each once
"""
import math
import os
import struct
import subprocess
import sys
import tempfile
import wave

RATE = 22050
LEVEL = 0.35                    # of full scale: below clipping, not deafening
EDGE_S = 0.003                  # gating ramps

CACHE = os.environ.get("NSTS_CW_AUDIO_CACHE") or os.path.join(
    tempfile.gettempdir(), "nsts-cw-audio")

# How long each generated file runs.  The steady and alternating tones are
# made whole cycles long, so a player looping the file joins seamlessly.
LOOP_S = {"cw": 8.0, "sm": 4.0, "siren": 10.0, "klaxon": 2.85}


def _env(t, on_s, period_s):
    """1 inside a gate's ON part, 0 in its OFF part, with soft edges."""
    ph = t % period_s
    if ph >= on_s:
        return 0.0
    return min(1.0, ph / EDGE_S, (on_s - ph) / EDGE_S)


def samples(tone, seconds):
    n = int(round(seconds * RATE))
    out = []
    ph = 0.0
    for i in range(n):
        t = i / RATE
        if tone == "cw":
            # alternating 400 / 1024 Hz every 0.4 s; phase kept continuous
            f = 400.0 if (t % 0.8) < 0.4 else 1024.0
            ph += 2 * math.pi * f / RATE
            v = math.sin(ph)
        elif tone == "sm":
            v = math.sin(2 * math.pi * 512.0 * t)
        elif tone == "siren":
            # 666 -> 1470 -> 666 Hz over 5 s, swept linearly (a triangle)
            u = (t % 5.0) / 5.0
            f = 666.0 + (1470.0 - 666.0) * (2 * u if u < 0.5 else 2 * (1 - u))
            ph += 2 * math.pi * f / RATE
            v = math.sin(ph)
        elif tone == "klaxon":
            hi = math.sin(2 * math.pi * 2560.0 * t) * _env(t, 0.0021, 0.0037)
            lo = math.sin(2 * math.pi * 256.0 * t) * _env(t, 0.215, 0.285)
            v = 0.5 * (hi + lo)
        else:
            raise ValueError("cwaudio: no tone %r" % tone)
        out.append(v)
    return out


def path_of(tone):
    """The tone's WAV file, generated on first use."""
    os.makedirs(CACHE, exist_ok=True)
    p = os.path.join(CACHE, "cw-%s-v2.wav" % tone)
    if not os.path.exists(p):
        s = samples(tone, LOOP_S[tone])
        tmp = p + ".%d.tmp" % os.getpid()
        with wave.open(tmp, "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(b"".join(struct.pack("<h", int(32767 * LEVEL * v)) for v in s))
        os.replace(tmp, p)
    return p


def _player_cmd(path):
    if sys.platform == "darwin":
        return ["afplay", path]
    import shutil
    for exe, args in (("paplay", ()), ("aplay", ("-q",)),
                      ("ffplay", ("-nodisp", "-autoexit", "-loglevel", "quiet"))):
        if shutil.which(exe):
            return [exe] + list(args) + [path]
    return None


class Tone:
    """One tone, looping until stop().  On Windows winsound plays one sound
    at a time, so a second tone replaces the first there (two together is
    undocumented anyway: the generators' outputs probably summed).  Call poll() now and then: a player
    that reached the end of the file is started again (Linux, macOS);
    Windows loops it itself.  Silent, and says so once, where there is no
    player or NSTS_NO_AUDIO=1."""

    def __init__(self, tone, log=None):
        self.tone, self.log = tone, log or (lambda m: None)
        self.proc = None
        self.on = False
        self.enabled = os.environ.get("NSTS_NO_AUDIO") != "1"
        self._warned = False

    def _start(self):
        if not self.enabled:
            return
        try:
            p = path_of(self.tone)
        except OSError as e:
            self._warn("cannot write %s: %s" % (self.tone, e))
            return
        if sys.platform == "win32":
            try:
                import winsound
                winsound.PlaySound(p, winsound.SND_FILENAME | winsound.SND_ASYNC
                                   | winsound.SND_LOOP | winsound.SND_NODEFAULT)
            except (ImportError, RuntimeError) as e:
                self._warn("cannot play %s: %s" % (self.tone, e))
            return
        cmd = _player_cmd(p)
        if cmd is None:
            self._warn("no audio player (paplay, aplay or ffplay; afplay on macOS)")
            return
        try:
            self.proc = subprocess.Popen(cmd, stdin=subprocess.DEVNULL,
                                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except OSError as e:
            self._warn("cannot start %s: %s" % (cmd[0], e))

    def _warn(self, m):
        if not self._warned:
            self._warned = True
            self.log("cwaudio: " + m + " -- the tones are silent")

    def start(self):
        if self.on:
            return
        self.on = True
        self._start()

    def poll(self):
        if self.on and self.proc is not None and self.proc.poll() is not None:
            self._start()

    def stop(self):
        if not self.on:
            return
        self.on = False
        if sys.platform == "win32":
            try:
                import winsound
                winsound.PlaySound(None, 0)
            except (ImportError, RuntimeError):
                pass
        if self.proc is not None and self.proc.poll() is None:
            self.proc.terminate()
        self.proc = None


if __name__ == "__main__":
    import time
    for name in sys.argv[1:] or ("cw", "sm", "siren", "klaxon"):
        print("cwaudio: %s -> %s" % (name, path_of(name)))
        t = Tone(name, print)
        t.start()
        end = time.monotonic() + min(LOOP_S[name], 6.0)
        while time.monotonic() < end:
            t.poll()
            time.sleep(0.1)
        t.stop()
