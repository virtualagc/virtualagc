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
was: this is a convenience, never a reason to fail.  A no-op off macOS.
"""

import sys


def set_app_name(name):
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
