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
    except Exception:
        pass
