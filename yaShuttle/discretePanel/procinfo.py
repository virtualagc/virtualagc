#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Which processes are running, and with what command lines, without /proc.

manager.py, simulatePASS.py and windowLayout.py find the simulation's
programs by reading /proc, which only Linux has.  They still do on Linux,
with their own code, unchanged; where there is no /proc (macOS) they call
this instead:

    argvs()         (pid, argv) for every process whose argv can be read
    cmdline(pid)    one process's argv joined by spaces, or ""
    children()      {ppid: [pid, ...]} for every process

THE ARGUMENTS ARE EXACT ON macOS TOO.  `ps` joins a command line with spaces,
so an argument containing one could not be told from two.  sysctl
KERN_PROCARGS2 returns argv as the process received it, NUL-separated, just
as /proc/PID/cmdline does.  Only `ps` is used for what it gets right: the
list of PIDs and their parents.

ONE NORMALISATION.  python.org's macOS Python re-executes itself as
.../Python.app/Contents/MacOS/Python, so that is argv[0] of every Python
program there.  The callers recognise a Python program by a basename that
starts with "python", as it does on Linux, so that path is reported as
"python3".
"""

import subprocess
import sys


def _ps(fields):
    try:
        out = subprocess.run(["ps", "-ax", "-o", fields], capture_output=True,
                             text=True, timeout=10).stdout
    except (OSError, subprocess.SubprocessError):
        return []
    rows = []
    for line in out.splitlines():
        try:
            rows.append([int(v) for v in line.split()])
        except ValueError:
            continue
    return rows


def _darwin_argv(pid):
    """argv of pid from sysctl KERN_PROCARGS2, or None if it cannot be read
    (another user's process, one that has exited)."""
    import ctypes
    import ctypes.util
    libc = ctypes.CDLL(ctypes.util.find_library("c"), use_errno=True)
    CTL_KERN, KERN_ARGMAX, KERN_PROCARGS2 = 1, 8, 49

    argmax = ctypes.c_int(0)
    size = ctypes.c_size_t(ctypes.sizeof(argmax))
    mib = (ctypes.c_int * 2)(CTL_KERN, KERN_ARGMAX)
    if libc.sysctl(mib, 2, ctypes.byref(argmax), ctypes.byref(size), None, 0) != 0:
        return None

    buf = ctypes.create_string_buffer(argmax.value)
    size = ctypes.c_size_t(argmax.value)
    mib = (ctypes.c_int * 3)(CTL_KERN, KERN_PROCARGS2, pid)
    if libc.sysctl(mib, 3, buf, ctypes.byref(size), None, 0) != 0:
        return None
    data = buf.raw[:size.value]
    if len(data) < 4:
        return None

    # int argc, the executable's path, NUL padding, then argc strings.
    argc = int.from_bytes(data[:4], sys.byteorder)
    rest = data[4:]
    end = rest.find(b"\0")
    if end < 0:
        return None
    rest = rest[end:].lstrip(b"\0")
    argv = [a.decode("utf-8", "replace") for a in rest.split(b"\0")[:argc]]
    if argv and argv[0].endswith("/Python.app/Contents/MacOS/Python"):
        argv[0] = "python3"
    return argv


def argvs():
    """(pid, argv) for every process whose command line can be read."""
    for (pid,) in _ps("pid="):
        argv = _darwin_argv(pid)
        if argv is not None:
            yield pid, argv


def cmdline(pid):
    """pid's command line, its arguments joined by spaces, or ""."""
    argv = _darwin_argv(pid)
    return " ".join(argv).strip() if argv else ""


def children():
    """{ppid: [pid, ...]} for every running process."""
    kids = {}
    for pid, ppid in _ps("pid=,ppid="):
        kids.setdefault(ppid, []).append(pid)
    return kids
