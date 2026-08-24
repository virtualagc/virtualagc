#!/usr/bin/env python3
"""The GPC discrete-signal bus, in Python.

This is the same wire protocol as com/discretes.coffee in Don Schmidt's
nsts-sim-gpc, and the two must stay in step.  It is duplicated rather than
shared because the devices that own discretes are written in whatever
language suited them -- the mass memory is CoffeeScript, the crew panel
here is Python -- and a four-word message is not worth a dependency.

Background.  A GPC's discrete inputs are hardware lines, not bus traffic:
the crew panel drives HALT/STANDBY/RUN, a mass memory drives its own
READY, the orbiter drives BFS engage.  Each GPC reads them with two PCIs
(READ DISCRETE INPUT A, X'0818', inputs 1-32; READ DISCRETE INPUTS B,
X'081C', inputs 33-40).  Nothing in the simulation drove them, so every
GPC came up holding a fixed constant, and software that HANDSHAKES on a
discrete -- FCMBOOT waits for mass memory READY to drop and rise again --
could never get past it.

They are carried the way every other inter-process signal here is, on a
multicast bus, following the plan in virtualagc/virtualagc#1343: publish
SET/RESET bit messages rather than whole words, so that devices owning
different bits of the same register do not overwrite each other's.

Message layout, four 16-bit words in network order:

    0   operation   SET = 1, RESET = 2
    1   register    A = 1 (inputs 1-32), B = 2 (inputs 33-40)
    2   mask, high half     IBM bit 0 is 0x8000 of this word
    3   mask, low half

IBM bit numbering runs from the most significant end, matching the POO
and both emulators.

A discrete is a LEVEL, not an event, and this bus is UDP: no delivery
guarantee, and as #1343 notes, no replay for anyone who attaches late.
A device that owns a discrete must therefore republish its current state
periodically as well as on change, or a GPC that started late will hold a
stale level forever.  REPUBLISH_MS is that period.
"""

import socket
import struct

GROUP = "239.255.1.1"
PORT = 6980                 # busConfig._gpcDiscretes
IFACE = "127.0.0.1"         # matches Bus.IFACE / NSTS_BUS_IFACE

SET = 1
RESET = 2

REG_A = 1                   # discrete inputs 1-32
REG_B = 2                   # discrete inputs 33-40

REPUBLISH_MS = 250
WORDS = 4


def bit_mask(n):
    """IBM bit n of a 32-bit discrete register."""
    return (0x80000000 >> n) & 0xFFFFFFFF


def encode(op, reg, mask):
    """The four words of one set/reset, as bytes ready to send."""
    mask &= 0xFFFFFFFF
    return struct.pack(">HHHH", op & 0xFFFF, reg & 0xFFFF,
                       (mask >> 16) & 0xFFFF, mask & 0xFFFF)


def decode(data):
    """Parse a datagram, or None if it is not a discrete message.

    Anything unrecognised is ignored rather than guessed at, so unrelated
    traffic on the bus cannot corrupt a register.
    """
    if data is None or len(data) < WORDS * 2:
        return None
    op, reg, hi, lo = struct.unpack(">HHHH", data[:WORDS * 2])
    if op not in (SET, RESET):
        return None
    if reg not in (REG_A, REG_B):
        return None
    return {"op": op, "reg": reg, "mask": ((hi << 16) | lo) & 0xFFFFFFFF}


def apply(value, msg):
    """Apply a decoded message to a register value."""
    if msg is None:
        return value
    if msg["op"] == SET:
        return (value | msg["mask"]) & 0xFFFFFFFF
    return value & ~msg["mask"] & 0xFFFFFFFF


def sender(iface=IFACE):
    """A socket for publishing discretes."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 128)
    s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF,
                 socket.inet_aton(iface))
    return s


def receiver(iface=IFACE, timeout=None):
    """A socket subscribed to the discrete bus."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("", PORT))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(GROUP),
                             socket.inet_aton(iface)))
    if timeout is not None:
        s.settimeout(timeout)
    return s


def publish(sock, op, reg, mask):
    sock.sendto(encode(op, reg, mask), (GROUP, PORT))
