"""THE DAP PUSHBUTTON LAMPS, as PASS lights them: for scripts that press DAP
pushbuttons and must know what they did.

    lamps = DapLamps(port_base)          # listens at once, on a thread
    lamps.wait(5.0)                      # until a lamp word has come in
    lamps.lit("LOW_Z"), lamps.low_z_lit(), lamps.dap_b(), lamps.state()

PASS writes the forward DAP panel's (C3's) lamps to FF1's discrete output
cards about every 1.3 s; yaGPC2 sends each write as a VALUE record (op 4,
type 4 -- DOH) on FF1's hardware-side bus, port base + 100, as panelO6
reads them for its lamps: five or more big-endian halfwords, op, type,
card << 8 | channel, count, the words.  The bits are panelO6's DAP_LAMP
(card 10 channel 1 for the rotation and translation options, LOW Z 0x0001;
card 10 channel 2 for Z NORM/PULSE and HIGH Z; card 2 channels 1-2 for
A/B, AUTO/INRTL/LVLH/FREE).

WHICH BUTTONS TOGGLE.  GCQORB.hal: every DAP pushbutton SELECTS -- A/B,
AUTO/INRTL/LVLH/FREE, PRI/ALT/VERN, the DISC/PULSE and NORM/PULSE pairs and
HIGH Z, which also turns LOW Z off (lines 3337-3364) -- except LOW Z, which
TOGGLES: pressed with the +Z jets already inhibited it sets
LOW_Z_OPTION_SELECT 1, "turn off the low plus-Z option" (lines 1443-1458,
3256-3280).  So LOW Z is pressed only when its lamp disagrees with what is
wanted (set_low_z).
"""
import os
import select
import socket
import struct
import threading
import time

GROUP = "239.255.1.1"
MDM_IO_OFFSET = 100                 # FF1's hardware-side bus (FFk: + k - 1)
MDM_OP_VALUE, MDM_TYPE_DOH = 4, 4

LAMP = {   # name: (card, channel, mask) -- panelO6.DAP_LAMP
    "PRI": (10, 1, 0x4000), "ROLL_DISC": (10, 1, 0x2000), "ROLL_PULSE": (10, 1, 0x1000),
    "ALT": (10, 1, 0x0800), "PITCH_DISC": (10, 1, 0x0400), "PITCH_PULSE": (10, 1, 0x0200),
    "VERN": (10, 1, 0x0100), "YAW_DISC": (10, 1, 0x0080), "YAW_PULSE": (10, 1, 0x0040),
    "X_NORM": (10, 1, 0x0020), "X_PULSE": (10, 1, 0x0010),
    "Y_NORM": (10, 1, 0x0004), "Y_PULSE": (10, 1, 0x0002), "LOW_Z": (10, 1, 0x0001),
    "Z_NORM": (10, 2, 0x8000), "Z_PULSE": (10, 2, 0x4000), "HIGH_Z": (10, 2, 0x2000),
    "AUTO": (2, 1, 0x0004), "A": (2, 1, 0x0002), "LVLH": (2, 1, 0x0001),
    "INRTL": (2, 2, 0x1000), "B": (2, 2, 0x0800), "FREE": (2, 2, 0x0400),
}


class DapLamps(object):
    def __init__(self, port_base, iface=None):
        self.words = {}             # (card, channel) -> the last word PASS wrote
        self.t = {}                 # (card, channel) -> when it came (time.time())
        self.lock = threading.Lock()
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
        except (AttributeError, OSError):
            pass
        s.bind(("", port_base + MDM_IO_OFFSET))
        s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                     struct.pack("4s4s", socket.inet_aton(GROUP), socket.inet_aton(
                         iface or os.environ.get("NSTS_BUS_IFACE", "127.0.0.1"))))
        self.sock = s
        threading.Thread(target=self._listen, daemon=True).start()

    def _listen(self):
        while True:
            try:
                ready, _, _ = select.select([self.sock], [], [], 1.0)
                if not ready:
                    continue
                data = self.sock.recv(512)
            except (OSError, ValueError):
                return
            if len(data) < 10:
                continue
            op, typ, addr, cnt = struct.unpack(">HHHH", data[:8])
            if op != MDM_OP_VALUE or typ != MDM_TYPE_DOH:
                continue
            card, ch = addr >> 8, addr & 0xff
            n = min(cnt, (len(data) - 8) // 2)
            words = struct.unpack(">%dH" % n, data[8:8 + 2 * n])
            now = time.time()
            with self.lock:
                for i, w in enumerate(words):
                    self.words[(card, ch + i)] = w
                    self.t[(card, ch + i)] = now

    def wait(self, timeout=10.0):
        """Until the lamp words have come in at least once; False if not."""
        end = time.time() + timeout
        while time.time() < end:
            with self.lock:
                if (10, 1) in self.words and (2, 1) in self.words:
                    return True
            time.sleep(0.2)
        return False

    def lit(self, name):
        """The lamp: True, False, or None before its word has come in."""
        card, ch, mask = LAMP[name]
        with self.lock:
            w = self.words.get((card, ch))
        return None if w is None else bool(w & mask)

    def low_z_lit(self):
        return self.lit("LOW_Z")

    def dap_b(self):
        return self.lit("B")

    def state(self):
        """Every lamp's name that is lit."""
        return [k for k in LAMP if self.lit(k)]

    def fresh_since(self, t0, name="LOW_Z"):
        """Whether the word holding the lamp has been rewritten since t0."""
        card, ch, _ = LAMP[name]
        with self.lock:
            return self.t.get((card, ch), 0.0) > t0

    def until(self, name, want, timeout=8.0):
        """Until the lamp reads want, after a fresh word (PASS rewrites the
        lamps about every 1.3 s); True if it did."""
        t0 = time.time()
        end = t0 + timeout
        while time.time() < end:
            if self.fresh_since(t0, name) and self.lit(name) == want:
                return True
            time.sleep(0.2)
        return False


def set_low_z(lamps, press, want, timeout=8.0, tries=2):
    """LOW Z to want (True on): press(), a function that presses the C3 LOW Z
    pushbutton once, only while the lamp disagrees -- the button toggles --
    and the lamp then confirmed.  Returns (ok, presses)."""
    presses = 0
    for _ in range(tries + 1):
        if not lamps.until("LOW_Z", lamps.low_z_lit(), timeout=3.0):
            lamps.wait(timeout)                     # a fresh word first
        if lamps.low_z_lit() == want:
            return True, presses
        if presses >= tries:
            break
        press()
        presses += 1
        if lamps.until("LOW_Z", want, timeout=timeout):
            return True, presses
    return lamps.low_z_lit() == want, presses
