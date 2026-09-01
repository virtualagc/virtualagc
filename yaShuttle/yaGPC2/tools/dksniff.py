#!/usr/bin/env python3
"""Watch a DK bus passively while a real MEDS session runs.

RECEIVE ONLY.  It joins the multicast group and never sends, so it cannot
disturb the run the way a stub peer does -- which is the point: a stub
ANSWERS the GPC, and answering changes what the GPC does next.

What it is for: telling the two halves of a blank display apart.  A
critical-format display is drawn by BRANCHING into the unit's own
critical-format buffer, so the GPC sends almost nothing for it; the
background has to have arrived earlier, during the unit's IPL, as
FORMAT_FILLs to 0x0100 and up.  If those never happened, or arrived empty,
the display draws its variable data over nothing.  This says which.

    dksniff.py [--port-base 6900] [--bus 6 --bus 7 --bus 8] [--out FILE]
"""
import argparse, socket, struct, sys, time, select

GROUP = "239.255.1.1"
IUA_DEU = 10
FUNC = {0x380: "TIME_FILL", 0x38c: "DISPLAY_FILL", 0x394: "FORMAT_FILL",
        0x398: "MEDS_XFER", 0x3a0: "DUMP", 0x010: "POLL", 0x040: "BITE",
        0x080: "RESET_SPL"}
XFER_FUNCS = (0x380, 0x38c, 0x394, 0x398, 0x3a0)


def glyphs(words):
    """The text a run of character FCWs draws, for eyeballing a fill."""
    out = []
    for w in words:
        if (w & 0xc000) == 0xc000:
            a, b = (w >> 7) & 0x7f, w & 0x7f
            out.append((chr(a) if 0x20 <= a < 0x60 else ".") +
                       (chr(b) if 0x20 <= b < 0x60 else "."))
    return "".join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--port-base", type=int, default=6900)
    ap.add_argument("--bus", type=int, action="append", default=None,
                    help="6/7/8 = DK1/2/3; repeatable [default: 7]")
    ap.add_argument("--iface", default="127.0.0.1")
    ap.add_argument("--out", help="write the record here [default: stdout]")
    ap.add_argument("--seconds", type=float, default=0)
    a = ap.parse_args()
    buses = a.bus or [7]
    out = open(a.out, "w") if a.out else sys.stdout

    socks = {}
    for b in buses:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        # SO_REUSEADDR only, deliberately.  A multicast datagram goes to
        # every socket bound to the port that joined the group, so this gets
        # a copy of what MEDS gets.  SO_REUSEPORT would put this socket in a
        # reuseport group with MEDS's, and the whole point of the tool is
        # that it cannot take anything away from the run it is watching.
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind(("", a.port_base + b))
        s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                     struct.pack("4s4s", socket.inet_aton(GROUP),
                                 socket.inet_aton(a.iface)))
        s.setblocking(False)
        socks[s.fileno()] = (s, b)

    st = {b: dict(xfer=None, left=0, buf=[], counts={}, fmt=0, fmtnz=0)
          for b in buses}
    t0 = time.time()

    def rec(line):
        out.write("%8.3f %s\n" % (time.time() - t0, line))
        out.flush()

    for b in buses:
        rec("bus %d (DK%d) on port %d -- listening only"
            % (b, b - 5, a.port_base + b))

    poller = select.poll()
    for fd in socks:
        poller.register(fd, select.POLLIN)
    last = time.time()
    try:
        while not (a.seconds and time.time() - t0 > a.seconds):
            for fd, _ in poller.poll(500):
                s, b = socks[fd]
                try:
                    d, _src = s.recvfrom(65535)
                except OSError:
                    continue
                v = st[b]
                if len(d) == 4:
                    w0, w1 = struct.unpack(">HH", d)
                    cmd = (w0 << 8) | (w1 >> 8)
                    iua, func = (cmd >> 19) & 0x1f, (cmd >> 9) & 0x3ff
                    count = cmd & 0x1ff
                    if iua == IUA_DEU and func in FUNC:
                        if v["xfer"] is not None and len(v["buf"]) < v["left"]:
                            rec("DK%d   SHORT: %s wanted %d, got %d"
                                % (b - 5, FUNC.get(v["xfer"], "?"),
                                   v["left"], len(v["buf"])))
                        v["xfer"], v["buf"], v["left"] = None, [], 0
                        name = FUNC[func]
                        v["counts"][name] = v["counts"].get(name, 0) + 1
                        if func in XFER_FUNCS:
                            v["xfer"], v["left"] = func, count
                        continue
                if v["xfer"] is not None and len(d) == 2:
                    v["buf"].append(struct.unpack(">H", d)[0])
                    if len(v["buf"]) >= v["left"]:
                        w, f = v["buf"], v["xfer"]
                        v["xfer"], v["buf"] = None, []
                        if f in (0x38c, 0x394) and len(w) >= 2:
                            cnt, addr = w[0], w[1] & 0x1fff
                            body = w[2:2 + cnt]
                            nz = sum(1 for x in body if x)
                            if f == 0x394:
                                v["fmt"] += 1
                                v["fmtnz"] += nz
                            rec("DK%d %-12s %4d hw @ 0x%04x  nonzero %d/%d |%s"
                                % (b - 5, FUNC[f], cnt, addr, nz, cnt,
                                   glyphs(body)[:56]))
                        elif f == 0x380:
                            rec("DK%d TIME_FILL    %s"
                                % (b - 5, " ".join("%04x" % x for x in w)))
            if time.time() - last >= 15:
                last = time.time()
                for b in buses:
                    v = st[b]
                    rec("DK%d totals: %s  FORMAT_FILLs %d carrying %d "
                        "non-zero halfwords"
                        % (b - 5, dict(sorted(v["counts"].items())),
                           v["fmt"], v["fmtnz"]))
    except KeyboardInterrupt:
        pass
    for b in buses:
        v = st[b]
        rec("DK%d FINAL: %s  FORMAT_FILLs %d carrying %d non-zero halfwords"
            % (b - 5, dict(sorted(v["counts"].items())), v["fmt"], v["fmtnz"]))


if __name__ == "__main__":
    main()
