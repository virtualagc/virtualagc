"""Vehicle-second script timing from simulatePASS's shared runtime rate file.

The clock integrates elapsed wall time rather than multiplying an absolute
wall timestamp: changing the rate never moves deadlines backwards.
"""
import math
import os
import time
import threading
import socket
import struct
import re


def runtime_rate():
    try:
        with open(os.environ.get("YAGPC_RATE_FILE", "")) as stream:
            rate = float(stream.read().strip())
        return rate if math.isfinite(rate) and rate > 0 else 1.0
    except (OSError, ValueError):
        return 1.0


_truth = None
_truth_lock = threading.Lock()

class TruthTime:
    def __init__(self, port):
        self.latest = None
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind(("", port))
        threading.Thread(target=self._read, daemon=True).start()

    def _read(self):
        while True:
            try:
                data = self.socket.recv(65536)
            except OSError:
                return
            if data[:4] == b"TRU1" and len(data) >= 12:
                value = struct.unpack(">d", data[4:12])[0]
                if math.isfinite(value):
                    self.latest = value


def truth_time():
    global _truth
    match = re.search(r"simulatePASS-rate-(\d+)$", os.environ.get("YAGPC_RATE_FILE", ""))
    if not match:
        return None
    with _truth_lock:
        if _truth is None:
            _truth = TruthTime(int(match.group(1)) + 98)
        return _truth.latest


class ScriptClock:
    def __init__(self, wall=None, rate=None, vehicle=None):
        self.vehicle = vehicle if vehicle is not None else (truth_time if wall is None and rate is None else lambda: None)
        self.last_vehicle = None
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
        vehicle = self.vehicle()
        if vehicle is not None:
            if self.last_vehicle is not None:
                self.value += max(0.0, vehicle - self.last_vehicle)
            self.last_vehicle = vehicle
        elif self.last_vehicle is None:
            self.value += max(0.0, wall - self.last_wall) * self.rate
        # Once truth has arrived, missing packets freeze rather than invent time.
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
