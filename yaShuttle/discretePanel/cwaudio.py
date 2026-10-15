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

FORMAT AND PLAYBACK (owner, 2026-10-15, after clicks, pops and gaps on Linux):
48 kHz, stereo, signed 16-bit little-endian -- the format that played clean;
mono 22 kHz did not.  Each loop is a whole number of cycles (or ends silent),
so it joins without a pop.  ffplay is preferred: it loops the WAV with
-loop 0, no gap.  paplay and aplay are fed the headerless cw-<tone>-v3.raw by a
shell "while :; do cat; done" loop, also gapless.  NSTS_CW_PLAYER forces one.

    python3 cwaudio.py [TONE ...]     write the files and play each once
"""
import math
import os
import struct
import subprocess
import sys
import tempfile
import wave

RATE = 48000                    # the format proven clean on Linux (owner, 2026-10-15):
CHANNELS = 2                    # stereo, signed 16-bit little-endian, 48 kHz
LEVEL = 0.35                    # of full scale: below clipping, not deafening
EDGE_S = 0.003                  # gating ramps

CACHE = os.environ.get("NSTS_CW_AUDIO_CACHE") or os.path.join(
    tempfile.gettempdir(), "nsts-cw-audio")
VERSION = "v3"


def _env(i, on_n, period_n, edge_n):
    """1 inside a gate's ON part (samples), 0 in its OFF part, soft edges."""
    ph = i % period_n
    if ph >= on_n:
        return 0.0
    return min(1.0, ph / edge_n, (on_n - ph) / edge_n)


def loop_samples(tone):
    """One seamless loop of the tone, as floats in -1..1.

    THE LOOP JOINS AT ZERO, with the sine's slope continuing: every loop is a
    whole number of cycles (the C&W's 1024 Hz half is 410 cycles in 19,219
    samples, which makes it 1023.988 Hz: 0.001 percent), or ends silent
    (klaxon).  A waveform that did not return to zero at the end of the file
    popped at every restart (owner, 2026-10-15)."""
    out = []
    if tone == "cw":
        # 400 Hz for 0.4 s, 1024 Hz for 0.4 s, phase restarting at zero
        for n, cycles in ((19200, 160), (19219, 410)):
            out += [math.sin(2 * math.pi * cycles * i / n) for i in range(n)]
    elif tone == "sm":
        # 512 Hz steady: one second is 512 whole cycles
        out = [math.sin(2 * math.pi * 512.0 * i / RATE) for i in range(RATE)]
    elif tone == "siren":
        # 666 -> 1470 -> 666 Hz, a triangle, 5 s; the phase accumulated, then
        # the frequencies scaled so that the loop holds a whole number of cycles
        n = 5 * RATE
        fs = []
        for i in range(n):
            u = i / n
            fs.append(666.0 + (1470.0 - 666.0) * (2 * u if u < 0.5 else 2 * (1 - u)))
        total = sum(fs) / RATE
        k = round(total) / total
        ph = 0.0
        for f in fs:
            out.append(math.sin(ph))
            ph += 2 * math.pi * f * k / RATE
    elif tone == "klaxon":
        # 2560 Hz gated 2.1 ms on / 1.6 ms off (77 periods) mixed with 256 Hz
        # gated 215 ms on / 70 ms off: a 285 ms loop that ends with both off
        n = int(round(0.285 * RATE))
        edge = int(round(EDGE_S * RATE))
        hi_on, hi_per = int(round(0.0021 * RATE)), int(round(0.0037 * RATE))
        lo_on, lo_per = int(round(0.215 * RATE)), n
        for i in range(n):
            hp = i % hi_per
            hi = math.sin(2 * math.pi * 2560.0 * hp / RATE) * _env(i, hi_on, hi_per, edge)
            if i >= 77 * hi_per:
                hi = 0.0
            lo = math.sin(2 * math.pi * 256.0 * i / RATE) * _env(i, lo_on, lo_per, edge)
            out.append(0.5 * (hi + lo))
    else:
        raise ValueError("cwaudio: no tone %r" % tone)
    return out


def _pcm(tone):
    """The loop as stereo signed 16-bit little-endian bytes."""
    frames = bytearray()
    for v in loop_samples(tone):
        x = int(round(32767 * LEVEL * v))
        frames += struct.pack("<hh", x, x)
    return bytes(frames)


def path_of(tone, raw=False):
    """The tone's file, generated on first use: the .wav (ffplay, afplay,
    winsound) or, with raw=True, the headerless samples the paplay/aplay
    pipelines are fed."""
    os.makedirs(CACHE, exist_ok=True)
    p = os.path.join(CACHE, "cw-%s-%s.%s" % (tone, VERSION, "raw" if raw else "wav"))
    if not os.path.exists(p):
        pcm = _pcm(tone)
        tmp = p + ".%d.tmp" % os.getpid()
        if raw:
            with open(tmp, "wb") as fh:
                fh.write(pcm)
        else:
            with wave.open(tmp, "wb") as w:
                w.setnchannels(CHANNELS)
                w.setsampwidth(2)
                w.setframerate(RATE)
                w.writeframes(pcm)
        os.replace(tmp, p)
    return p


def _player_cmd(tone):
    """(argv, own process group) that plays the tone until killed, or None.
    ffplay loops the WAV itself, without a gap (-loop 0).  paplay and aplay
    are fed the raw samples by a shell loop, which is gapless too."""
    import shutil
    if sys.platform == "darwin":
        return ["afplay", path_of(tone)], False
    # NSTS_CW_PLAYER=paplay|aplay|ffplay forces one, for a machine where the
    # first found sounds wrong
    want = os.environ.get("NSTS_CW_PLAYER")
    order = [want] if want else ["ffplay", "paplay", "aplay"]
    for exe in order:
        if not shutil.which(exe):
            continue
        if exe == "ffplay":
            return ["ffplay", "-nodisp", "-loglevel", "quiet", "-loop", "0", path_of(tone)], True
        if exe == "paplay":
            sink = "exec paplay --raw --format=s16le --rate=%d --channels=%d" % (RATE, CHANNELS)
        else:
            sink = "exec aplay -q -t raw -f S16_LE -c %d -r %d" % (CHANNELS, RATE)
        return ["sh", "-c", 'while :; do cat "$0"; done | ' + sink, path_of(tone, raw=True)], True
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
        if sys.platform == "win32":
            try:
                p = path_of(self.tone)
            except OSError as e:
                self._warn("cannot write %s: %s" % (self.tone, e))
                return
            try:
                import winsound
                winsound.PlaySound(p, winsound.SND_FILENAME | winsound.SND_ASYNC
                                   | winsound.SND_LOOP | winsound.SND_NODEFAULT)
            except (ImportError, RuntimeError) as e:
                self._warn("cannot play %s: %s" % (self.tone, e))
            return
        try:
            found = _player_cmd(self.tone)
        except OSError as e:
            self._warn("cannot write %s: %s" % (self.tone, e))
            return
        if found is None:
            self._warn("no audio player (ffplay, paplay or aplay; afplay on macOS)")
            return
        cmd, own_group = found
        try:
            self.proc = subprocess.Popen(cmd, stdin=subprocess.DEVNULL,
                                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                                         start_new_session=own_group)
            self._group = own_group
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
            if getattr(self, "_group", False):
                try:                       # the shell loop, cat and the player together
                    import signal
                    os.killpg(self.proc.pid, signal.SIGTERM)
                except (OSError, ProcessLookupError):
                    self.proc.terminate()
            else:
                self.proc.terminate()
        self.proc = None


if __name__ == "__main__":
    import time
    for name in sys.argv[1:] or ("cw", "sm", "siren", "klaxon"):
        print("cwaudio: %s -> %s" % (name, path_of(name)))
        t = Tone(name, print)
        t.start()
        end = time.monotonic() + 6.0
        while time.monotonic() < end:
            t.poll()
            time.sleep(0.1)
        t.stop()
