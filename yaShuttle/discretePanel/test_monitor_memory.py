"""simulatePASS.MonitorMemory: windows put back when a KVM brings the monitors back.

Fake monitors, windows and clock; no Windows needed, so it runs everywhere."""
import sys, unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import simulatePASS as sp

HOME = ((0, 0, 3840, 2160, 144), (3840, 0, 7680, 2160, 144))     # two monitors at 150%
AWAY = ((0, 0, 3840, 2160, 96),)                                 # the KVM's stand-in


class Desk(object):
    """Monitors and windows as Windows would have them."""

    def __init__(self, key):
        self.key, self.t, self.win, self.puts, self.said = key, 0.0, {}, [], []

    def rects(self):
        return dict(self.win)

    def put(self, wid, rect, size):
        self.puts.append((wid, rect, size))
        old, role = self.win[wid]
        if not size:
            rect = (rect[0], rect[1], rect[0] + old[2] - old[0], rect[1] + old[3] - old[1])
        self.win[wid] = (rect, role)
        return rect

    def memory(self):
        return sp.MonitorMemory(lambda: self.key, self.rects, self.put, self.said.append,
                                now=lambda: self.t)

    def run(self, mem, seconds):
        for _ in range(int(seconds)):
            self.t += 1.0
            mem.poll()


class Tests(unittest.TestCase):
    def test_kvm_away_and_back_puts_windows_back(self):
        d = Desk(HOME)
        d.win = {"a": ((100, 100, 700, 700), "crt1"), "b": ((4000, 200, 4800, 900), "panel")}
        m = d.memory()
        d.run(m, 5)
        home = dict(d.win)
        d.key = AWAY                                    # KVM away: Windows piles and shrinks
        d.run(m, 1)
        d.win = {"a": ((0, 0, 400, 400), "crt1"), "b": ((50, 50, 583, 517), "panel")}
        d.run(m, 10)
        self.assertEqual(d.puts, [])                    # nothing to go back to while away
        d.key = HOME                                    # KVM back; Windows leaves them be
        d.run(m, 1)
        d.win = {"a": ((0, 0, 600, 600), "crt1"), "b": ((75, 75, 875, 775), "panel")}
        d.run(m, 5)
        self.assertEqual(d.win, home)
        self.assertTrue(any("as they were before; 2 window(s)" in s for s in d.said), d.said)
        self.assertFalse(any("dpi" in s for s in d.said), d.said)   # no KVM warning

    def test_waits_for_the_monitors_to_settle(self):
        d = Desk(HOME)
        d.win = {"a": ((100, 100, 700, 700), "crt1")}
        m = d.memory()
        d.run(m, 5)
        d.key = AWAY
        d.run(m, 1)
        d.key = HOME
        d.t += 1.0; m.poll()
        d.win = {"a": ((0, 0, 600, 600), "crt1")}
        d.t += 1.0; m.poll()
        self.assertEqual(d.puts, [])                    # not before WIN_SETTLE_S
        d.run(m, 4)
        self.assertEqual(d.win["a"][0], (100, 100, 700, 700))

    def test_moved_again_after_put_back_is_put_back_again(self):
        d = Desk(HOME)
        d.win = {"a": ((100, 100, 700, 700), "crt1")}
        m = d.memory()
        d.run(m, 5)
        d.key = AWAY
        d.run(m, 6)
        d.key = HOME
        d.run(m, 4)                                     # settled and put back
        d.win["a"] = ((100, 100, 1000, 1000), "crt1")   # its toolkit rescaled it after
        d.run(m, 1)
        self.assertEqual(d.win["a"][0], (100, 100, 700, 700))

    def test_users_moves_are_remembered(self):
        d = Desk(HOME)
        d.win = {"a": ((100, 100, 700, 700), "crt1")}
        m = d.memory()
        d.run(m, 5)
        d.win["a"] = ((900, 300, 1500, 900), "crt1")    # the owner drags it
        d.run(m, 2)
        d.key = AWAY
        d.run(m, 1)
        d.win["a"] = ((0, 0, 400, 400), "crt1")
        d.run(m, 6)
        d.key = HOME
        d.run(m, 5)
        self.assertEqual(d.win["a"][0], (900, 300, 1500, 900))

    def test_caption_box_keeps_its_size(self):
        d = Desk(HOME)
        d.win = {"s": ((100, 1800, 2500, 1940), "subtitles")}
        m = d.memory()
        d.run(m, 5)
        d.key = AWAY
        d.run(m, 1)
        d.win["s"] = ((0, 900, 1600, 1100), "subtitles")
        d.run(m, 6)
        d.key = HOME
        d.run(m, 5)
        self.assertEqual(d.win["s"][0], (100, 1800, 1700, 2000))   # moved, not resized
        self.assertTrue(all(size is False for wid, _r, size in d.puts if wid == "s"))

    def test_started_away_says_so_once(self):
        d = Desk(AWAY)
        d.win = {"a": ((0, 0, 400, 400), "crt1")}
        m = d.memory()
        d.run(m, 5)
        d.key = HOME
        d.run(m, 6)
        d.key = AWAY
        d.run(m, 6)
        d.key = HOME
        d.run(m, 6)
        told = [s for s in d.said if "144 dpi" in s]
        self.assertEqual(len(told), 1, d.said)
        self.assertIn("for 96 dpi", told[0])

    def test_a_new_window_is_left_alone(self):
        d = Desk(HOME)
        d.win = {"a": ((100, 100, 700, 700), "crt1")}
        m = d.memory()
        d.run(m, 5)
        d.key = AWAY
        d.run(m, 1)
        d.win = {"a": ((0, 0, 400, 400), "crt1"), "n": ((10, 10, 300, 300), "kybd1")}
        d.run(m, 6)
        d.key = HOME
        d.run(m, 5)
        self.assertNotIn("n", [w for w, _r, _s in d.puts])


if __name__ == "__main__":
    unittest.main()
