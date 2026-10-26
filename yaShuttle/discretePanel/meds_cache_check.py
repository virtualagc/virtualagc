#!/usr/bin/env python3
"""Do NSTS_MEDS_CACHE and NSTS_MEDS_BATCH draw the same picture as the old path?

    python3 meds_cache_check.py run OUTDIR [IDP_RESTORE_DIR]    # once with the options OFF, once ON
    python3 meds_cache_check.py compare DIR_OFF DIR_ON

`run` starts MEDS2 (its default display, CRT 1 and IDP 1; IDP_RESTORE_DIR, a simulatePASS capture
directory, gives it a real page), waits about 15 s, then writes OUTDIR/lit.png and OUTDIR/dark.png:
the widget's framebuffer grabbed with the wall clock's flash phase held at "lit" and then at "dark".
It reads the options from the environment, so:

    NSTS_MEDS_CACHE=0 NSTS_MEDS_BATCH=0 python3 meds_cache_check.py run /tmp/off  CAPTURE_DIR
    NSTS_MEDS_CACHE=1 NSTS_MEDS_BATCH=1 python3 meds_cache_check.py run /tmp/on   CAPTURE_DIR
    python3 meds_cache_check.py compare /tmp/off /tmp/on

`compare` prints the number of differing pixels and the largest channel difference for lit and dark;
0 and 0 for both is the pass.  It uses Qt only (no extra packages), so it runs on macOS, Windows
and WSL as it does on Linux.  Run it on the SAME machine for both, with the same capture.
"""
import os
import sys
import time as _real_time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)


class _FakeTime(object):
    """MEDS2's `time`, with the wall clock's phase within the second held when asked."""
    phase = None

    def time(self):
        t = _real_time.time()
        return t if self.phase is None else float(int(t)) + self.phase

    def __getattr__(self, name):
        return getattr(_real_time, name)


def run(outdir, restore):
    os.makedirs(outdir, exist_ok=True)
    import MEDS2
    ft = _FakeTime()
    MEDS2.time = ft
    n = [0]
    orig = MEDS2.VectorDisplay._tick

    def tick(self):
        n[0] += 1
        k = n[0]
        if k == 900:
            ft.phase = 0.10                              # lit
            self.dirty = True
        elif k == 1000:
            self.widget.grabFramebuffer().save(os.path.join(outdir, "lit.png"))
            ft.phase = 0.80                              # dark
            self.dirty = True
        elif k == 1100:
            self.widget.grabFramebuffer().save(os.path.join(outdir, "dark.png"))
            print("meds_cache_check: wrote %s" % outdir, flush=True)
            MEDS2.QtWidgets.QApplication.quit()
        return orig(self)
    MEDS2.VectorDisplay._tick = tick
    sys.argv = ["MEDS2.py", "--port-base", os.environ.get("MEDS_CHECK_PORT", "42870")]
    if restore:
        sys.argv += ["--idp-restore", restore]
    MEDS2.main()


def compare(a, b):
    from PyQt6.QtGui import QImage
    ok = True
    for name in ("lit", "dark"):
        ia = QImage(os.path.join(a, name + ".png")).convertToFormat(QImage.Format.Format_RGBA8888)
        ib = QImage(os.path.join(b, name + ".png")).convertToFormat(QImage.Format.Format_RGBA8888)
        if ia.isNull() or ib.isNull() or ia.size() != ib.size():
            print("%s: missing or different sizes (%s, %s)" % (name, ia.size(), ib.size()))
            ok = False
            continue
        w, h = ia.width(), ia.height()
        da = bytes(ia.constBits().asarray(ia.sizeInBytes()))
        db = bytes(ib.constBits().asarray(ib.sizeInBytes()))
        diff = sum(1 for x, y in zip(da, db) if x != y)
        mx = max((abs(x - y) for x, y in zip(da, db)), default=0)
        print("%s: %dx%d, %d differing bytes, largest channel difference %d" % (name, w, h, diff, mx))
        ok = ok and diff == 0
    print("PASS: identical" if ok else "DIFFERENT")
    return 0 if ok else 1


if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "run":
        run(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else None)
    elif len(sys.argv) == 4 and sys.argv[1] == "compare":
        sys.exit(compare(sys.argv[2], sys.argv[3]))
    else:
        print(__doc__)
        sys.exit(2)
