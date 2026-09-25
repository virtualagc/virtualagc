#!/usr/bin/env python3
"""Print whole display frames as text, from MEDS2's announcements.

    python3 screenwatch.py <port-base> [substring]

Run the simulation with NSTS_ANNOUNCE_ROWS=all and MEDS2 sends every frame
of every display, not just the two title rows a crew script waits on.  This
joins that multicast and prints the frames whose body contains the
substring (default: every frame).

WHY IT EXISTS.  A question about what the flight software believes is
answered in the BODY of a display -- MTU ACCUM's status characters on SPEC
2, which GPC commands which bus on SPEC 6 -- and on a headless X server
there is nothing to photograph: a window grab returns the backing store,
which is black wherever nothing has repainted.  Text is also the only form
of the answer anybody can re-check later.
"""
import socket, struct, sys, time
port = int(sys.argv[1]) + 91
want = sys.argv[2] if len(sys.argv) > 2 else None
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('', port))
s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
             struct.pack('4s4s', socket.inet_aton('239.255.1.1'),
                         socket.inet_aton('127.0.0.1')))
s.settimeout(1.0)
last = None
while True:
    try:
        data, _ = s.recvfrom(65535)
    except socket.timeout:
        continue
    text = data.decode('utf-8', 'replace')
    name, _, body = text.partition('\n')
    if want and want not in name:
        continue
    if 'ACCUM' not in body and 'TIME' not in body:
        continue
    if body == last:
        continue
    last = body
    print("=== %s  at %s" % (name, time.strftime('%H:%M:%S')), flush=True)
    for ln in body.split('\n'):
        if ln.strip():
            print("   %s" % ln.rstrip(), flush=True)
