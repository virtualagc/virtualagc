#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Which processes are running, and with what command lines, without /proc.

manager.py, simulatePASS.py and windowLayout.py find the simulation's
programs by reading /proc, which only Linux has.  They still do on Linux,
with their own code, unchanged; where there is no /proc (macOS, Windows)
they call this instead:

    argvs()         (pid, argv) for every process whose argv can be read
    cmdline(pid)    one process's argv joined by spaces, or ""
    children()      {ppid: [pid, ...]} for every process

and, on Windows only, send_signal(pid, name) -- the emulator cannot be sent
a signal there, so it is told by other means.

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


# ---------------------------------------------------------------------------
# Windows.  The process list and each process's parent come from a Toolhelp
# snapshot; a command line comes from NtQueryInformationProcess, which hands
# back the string the process was started with (Windows 8.1 and later), and
# CommandLineToArgvW splits it by the rules the C runtime itself uses.
#
# TWO NORMALISATIONS, for the same reason as the macOS one above: the callers
# were written against Linux names.
#
#   "yaGPC2.exe" is reported as "yaGPC2".
#
#   A Python program started from a virtual environment is TWO processes.
#   venv\Scripts\python.exe is a small launcher that starts the real
#   interpreter with the same arguments and waits for it, so the program
#   would be counted twice and its windows would belong to a process nobody
#   started.  The launcher is left out of argvs(); children() still has
#   both, so a walk down from the launcher's pid reaches the interpreter.

_WIN_API = None


def _win_api():
    global _WIN_API
    if _WIN_API is None:
        _WIN_API = _win_api_load()
    return _WIN_API


def _win_api_load():
    import ctypes
    from ctypes import wintypes
    k32 = ctypes.WinDLL("kernel32", use_last_error=True)
    ntdll = ctypes.WinDLL("ntdll")
    shell32 = ctypes.WinDLL("shell32", use_last_error=True)

    class PROCESSENTRY32W(ctypes.Structure):
        _fields_ = [("dwSize", wintypes.DWORD), ("cntUsage", wintypes.DWORD),
                    ("th32ProcessID", wintypes.DWORD),
                    ("th32DefaultHeapID", ctypes.c_size_t),
                    ("th32ModuleID", wintypes.DWORD), ("cntThreads", wintypes.DWORD),
                    ("th32ParentProcessID", wintypes.DWORD),
                    ("pcPriClassBase", wintypes.LONG), ("dwFlags", wintypes.DWORD),
                    ("szExeFile", wintypes.WCHAR * 260)]

    k32.CreateToolhelp32Snapshot.restype = wintypes.HANDLE
    k32.CreateToolhelp32Snapshot.argtypes = [wintypes.DWORD, wintypes.DWORD]
    k32.Process32FirstW.argtypes = [wintypes.HANDLE, ctypes.POINTER(PROCESSENTRY32W)]
    k32.Process32NextW.argtypes = [wintypes.HANDLE, ctypes.POINTER(PROCESSENTRY32W)]
    k32.OpenProcess.restype = wintypes.HANDLE
    k32.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
    k32.CloseHandle.argtypes = [wintypes.HANDLE]
    k32.LocalFree.argtypes = [wintypes.HLOCAL]
    ntdll.NtQueryInformationProcess.argtypes = [
        wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.ULONG,
        ctypes.POINTER(wintypes.ULONG)]
    shell32.CommandLineToArgvW.restype = ctypes.POINTER(wintypes.LPWSTR)
    shell32.CommandLineToArgvW.argtypes = [wintypes.LPCWSTR, ctypes.POINTER(ctypes.c_int)]
    return ctypes, wintypes, k32, ntdll, shell32, PROCESSENTRY32W


def _win_processes():
    """[(pid, ppid)] for every process."""
    ctypes, wintypes, k32, _ntdll, _shell32, PROCESSENTRY32W = _win_api()
    TH32CS_SNAPPROCESS = 0x00000002
    snap = k32.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    if snap is None or snap == wintypes.HANDLE(-1).value:
        return []
    rows = []
    try:
        entry = PROCESSENTRY32W()
        entry.dwSize = ctypes.sizeof(entry)
        ok = k32.Process32FirstW(snap, ctypes.byref(entry))
        while ok:
            rows.append((int(entry.th32ProcessID), int(entry.th32ParentProcessID)))
            ok = k32.Process32NextW(snap, ctypes.byref(entry))
    finally:
        k32.CloseHandle(snap)
    return rows


def _win_argv(pid):
    """argv of pid, or None if it cannot be read (another user's process, a
    protected one, one that has exited)."""
    ctypes, wintypes, k32, ntdll, shell32, _entry = _win_api()
    PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
    ProcessCommandLineInformation = 60
    handle = k32.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, pid)
    if not handle:
        return None
    try:
        # A UNICODE_STRING -- two USHORT lengths, padding, a pointer -- with
        # the characters it points to following it in the same buffer.
        need = wintypes.ULONG(0)
        ntdll.NtQueryInformationProcess(handle, ProcessCommandLineInformation,
                                        None, 0, ctypes.byref(need))
        if need.value == 0:
            return None
        buf = ctypes.create_string_buffer(need.value)
        if ntdll.NtQueryInformationProcess(handle, ProcessCommandLineInformation,
                                           buf, need.value, ctypes.byref(need)) != 0:
            return None
        length = int.from_bytes(buf.raw[0:2], sys.byteorder)
        pointer = ctypes.c_void_p.from_buffer(buf, ctypes.sizeof(ctypes.c_void_p)).value
        if not pointer or length == 0:
            return None
        text = ctypes.wstring_at(pointer, length // 2)
    finally:
        k32.CloseHandle(handle)
    argc = ctypes.c_int(0)
    parts = shell32.CommandLineToArgvW(text, ctypes.byref(argc))
    if not parts:
        return None
    try:
        argv = [parts[i] for i in range(argc.value)]
    finally:
        k32.LocalFree(parts)
    if argv and argv[0].replace("/", "\\").rsplit("\\", 1)[-1].lower() == "yagpc2.exe":
        argv[0] = "yaGPC2"
    return argv


def _win_is_python(argv):
    return argv[0].replace("/", "\\").rsplit("\\", 1)[-1].lower().startswith("python")


def _win_argvs():
    rows = _win_processes()
    found = {}
    for pid, _ppid in rows:
        if pid == 0:
            continue
        argv = _win_argv(pid)
        if argv:
            found[pid] = argv
    launchers = set()
    for pid, ppid in rows:
        child, parent = found.get(pid), found.get(ppid)
        if (child and parent and _win_is_python(child) and _win_is_python(parent)
                and child[1:] == parent[1:]):
            launchers.add(ppid)
    for pid, argv in found.items():
        if pid not in launchers:
            yield pid, argv


def argvs():
    """(pid, argv) for every process whose command line can be read."""
    if sys.platform == "win32":
        for item in _win_argvs():
            yield item
        return
    for (pid,) in _ps("pid="):
        argv = _darwin_argv(pid)
        if argv is not None:
            yield pid, argv


def cmdline(pid):
    """pid's command line, its arguments joined by spaces, or ""."""
    argv = _win_argv(pid) if sys.platform == "win32" else _darwin_argv(pid)
    return " ".join(argv).strip() if argv else ""


def children():
    """{ppid: [pid, ...]} for every running process."""
    kids = {}
    rows = _win_processes() if sys.platform == "win32" else _ps("pid=,ppid=")
    for pid, ppid in rows:
        kids.setdefault(ppid, []).append(pid)
    return kids


def send_signal(pid, name):
    """Windows: deliver "SIGINT" or "SIGUSR1" to a yaGPC2, which listens for
    each as a named event there (see yaGPC2/src/win32/posix_compat.h).  True
    if the event existed and was set -- so False means no emulator with that
    pid is listening, which a signal sent to a dead process never said."""
    import ctypes
    from ctypes import wintypes
    k32 = ctypes.WinDLL("kernel32", use_last_error=True)
    k32.OpenEventW.restype = wintypes.HANDLE
    k32.OpenEventW.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.LPCWSTR]
    k32.SetEvent.argtypes = [wintypes.HANDLE]
    k32.CloseHandle.argtypes = [wintypes.HANDLE]
    EVENT_MODIFY_STATE = 0x0002
    handle = k32.OpenEventW(EVENT_MODIFY_STATE, False,
                            "Local\\yaGPC2-%d-%s" % (pid, name))
    if not handle:
        return False
    try:
        return bool(k32.SetEvent(handle))
    finally:
        k32.CloseHandle(handle)
