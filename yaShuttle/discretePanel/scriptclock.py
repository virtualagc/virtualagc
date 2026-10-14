"""Vehicle-second script timing from simulatePASS's shared runtime rate file.

The clock integrates elapsed wall time rather than multiplying an absolute
wall timestamp: changing the rate never moves deadlines backwards.
"""
import math
import os
import time
import threading


def runtime_rate():
    try:
        with open(os.environ.get("YAGPC_RATE_FILE", "")) as stream:
            rate = float(stream.read().strip())
        return rate if math.isfinite(rate) and rate > 0 else 1.0
    except (OSError, ValueError):
        return 1.0


class ScriptClock:
    def __init__(self, wall=None, rate=None):
        self.lock = threading.RLock()
        self.wall = wall or (lambda: time.monotonic())
        self.read_rate = rate or runtime_rate
        self.last_wall = self.wall()
        self.value = self.last_wall
        self.rate = self.read_rate()

    def now(self):
        with self.lock:
            return self._now()

    def _now(self):
        wall = self.wall()
        self.value += max(0.0, wall - self.last_wall) * self.rate
        self.last_wall = wall
        self.rate = self.read_rate()
        return self.value

    def delay_ms(self, seconds):
        # Recheck long waits frequently, so runtime rate changes take effect.
        return max(1, min(100, int(max(0.0, seconds) * 1000 / self.rate) + 1))

    def schedule(self, after, seconds, callback):
        deadline = self.now() + seconds
        def poll():
            remaining = deadline - self.now()
            if remaining <= 0:
                callback()
            else:
                after(self.delay_ms(remaining), poll)
        poll()
