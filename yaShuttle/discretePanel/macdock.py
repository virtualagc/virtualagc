#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Give each program its own name in the macOS Dock and menu bar.

On Linux every window is listed on the desktop's panel under its own title --
"CRT1", "Panel", "1" -- which is how they are told apart.  On macOS the Dock
lists APPLICATIONS, not windows, and names each from its bundle; python.org's
Python runs every script inside the same Python.app, so all of them were
"Python", with the same icon.

    import macdock; macdock.set_app_name("CRT1")      # before Tk() / QApplication

The name comes from CFBundleName in the running process's copy of the
bundle's Info.plist, which AppKit reads when the application starts -- so it
must be changed first.  Reached through the Objective-C runtime with ctypes,
so nothing needs installing.  Anything that goes wrong leaves the name as it
was: this is a convenience, never a reason to fail.  A no-op on Linux.

Windows has the same trouble with its taskbar, and the same call cures it
there by another means; see set_app_name.

The same call also keeps the program from being treated as background work
when nobody can see its windows -- Windows' power throttling, macOS's App
Nap -- since a display or a panel that answers late holds the GPC up.
"""

import sys


def set_app_name(name):
    if sys.platform == "win32" and name:
        # THE TASKBAR HAS THE SAME HABIT AS THE DOCK.  Windows groups buttons
        # by application, and every program here is python.exe, so the
        # displays, the keyboards and the panel would share one button.  An
        # application id of its own gives each its own.  Called before Tk()
        # or QApplication, as on macOS, and as harmless if it fails.
        #
        # AND DPI AWARENESS, here because this is the one call every program
        # makes before it has a window, which is the only time it can be
        # declared.  See windowLayout.win_dpi_aware for what it is for.
        try:
            import windowLayout
            windowLayout.win_dpi_aware()
        except Exception:
            pass
        # AND NOT A BACKGROUND PROCESS.  Windows throttles a program whose
        # windows it thinks nobody can see -- all of them, when a KVM switch
        # takes the monitors away -- moving it to slow cores and ignoring its
        # timer requests.  A display that answers its GPC late holds the
        # computer up; see yaGPC2/src/win32/posix_win32.c.
        try:
            import ctypes
            from ctypes import wintypes

            class _Throttle(ctypes.Structure):
                _fields_ = [("Version", ctypes.c_ulong), ("ControlMask", ctypes.c_ulong),
                            ("StateMask", ctypes.c_ulong)]
            state = _Throttle(1, 0x1 | 0x4, 0)   # EXECUTION_SPEED | IGNORE_TIMER_RESOLUTION: off
            k32 = ctypes.WinDLL("kernel32")
            # Typed, or the process handle -- the pseudo-handle -1 -- is
            # passed as a 32-bit int and arrives as something else.
            k32.GetCurrentProcess.restype = wintypes.HANDLE
            k32.SetProcessInformation.argtypes = [wintypes.HANDLE, ctypes.c_int,
                                                  ctypes.c_void_p, wintypes.DWORD]
            k32.SetProcessInformation(k32.GetCurrentProcess(), 4,   # ProcessPowerThrottling
                                      ctypes.byref(state), ctypes.sizeof(state))
        except Exception:
            pass
        try:
            import ctypes
            ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(
                "VirtualAGC.yaShuttle." + "".join(c for c in name if c.isalnum()))
        except Exception:
            pass
        return
    if sys.platform != "darwin" or not name:
        return
    try:
        import ctypes
        import ctypes.util
        objc = ctypes.cdll.LoadLibrary(ctypes.util.find_library("objc"))
        ctypes.cdll.LoadLibrary(ctypes.util.find_library("Foundation"))
        objc.objc_getClass.restype = ctypes.c_void_p
        objc.sel_registerName.restype = ctypes.c_void_p

        def send(obj, sel, *args, argtypes=()):
            fn = ctypes.CFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p,
                                  *argtypes)(("objc_msgSend", objc))
            return fn(obj, objc.sel_registerName(sel), *args)

        def nsstring(text):
            return send(objc.objc_getClass(b"NSString"), b"stringWithUTF8String:",
                        text.encode("utf-8"), argtypes=(ctypes.c_char_p,))

        bundle = send(objc.objc_getClass(b"NSBundle"), b"mainBundle")
        info = send(bundle, b"infoDictionary") if bundle else None
        if info:
            send(info, b"setObject:forKey:", nsstring(name), nsstring("CFBundleName"),
                 argtypes=(ctypes.c_void_p, ctypes.c_void_p))
        # AND NOT A BACKGROUND PROCESS -- macOS's App Nap, the counterpart of
        # the Windows power throttling above, and with the same trigger: a
        # program none of whose windows can be seen, as when a KVM switch
        # takes the monitors away, or they are hidden or covered.  Some tens
        # of seconds later macOS "naps" it: its threads drop to background
        # QoS (scheduling priority 46 -> 4, `ps -o pri`), which on Apple
        # silicon confines them to the efficiency cores -- two of them on an
        # M1 Max, shared with whatever else the machine is doing in the
        # background -- and its timers are coalesced.
        #
        # For a display that is not an inconvenience, it is the GPC's I/O.
        # MEDS2 redraws a whole display for every fill, and measured with
        # CRT 1's window hidden, SPEC 34 up and --rate 2, a redraw went from
        # 25 ms to 150 ms the moment the priority fell.  The IDP answering
        # the GPC shares the process (and Python's one lock) with those
        # redraws, so it answered later and later: with the efficiency cores
        # also busy, 1037 of 1901 polls timed out at the GPC, keystrokes
        # were lost and the IDP sat in one read of the DK bus for 108 s
        # while nothing else -- the keyboard among it -- was heard.  That is
        # the "every key after SPEC 33 lost at --rate 2" of RENDEZVOUS_PLAN
        # 5a.  At --rate 1 there is half as much redrawing in a wall second,
        # which is why it went on working there.
        #
        # So every program opts out, here, before it has a window, for the
        # life of the process: NSActivityUserInitiatedAllowingIdleSystemSleep
        # (no App Nap -- but the Mac may still sleep when idle, as before)
        # and NSActivityLatencyCritical (no timer coalescing).  The token is
        # retained and never ended; the activity ends with the process.
        try:
            info_ = send(objc.objc_getClass(b"NSProcessInfo"), b"processInfo")
            activity = send(info_, b"beginActivityWithOptions:reason:",
                            ctypes.c_uint64(0x00EFFFFF | 0xFF00000000),
                            nsstring("real-time simulation (%s)" % name),
                            argtypes=(ctypes.c_uint64, ctypes.c_void_p))
            if activity:
                send(activity, b"retain")
                _ACTIVITY.append(activity)
        except Exception:
            pass
    except Exception:
        pass


# The App Nap opt-out's token (see set_app_name), held for the process's life.
_ACTIVITY = []
