#!/usr/bin/env python

'''
Try to use pip to install a package from a the directory modules/ at the top
of the Virtual AGC source tree.  It's intended to be run inside of a loop
indexed by i (= 0 or 1).  `pathToTop` is the absolute or relative path to
the top of the Virtual AGC source tree.  `package` is the name of the module
being installed.  The README.md describes this in more detail.
'''
def pipIt(i, pathToTop, package, retryMessage=True):
    import sys
    import os
    import subprocess
    import importlib
    if i > 0:
        print(f"Failed to import {package}, even though installed.",
                file=sys.stderr)
        os._exit(1)
    try:
        print(f"The required module {package} is missing.",
                file=sys.stderr)
        print(f"One-time installation of the module ...", 
            file=sys.stderr)
        subprocess.run([
            sys.executable, "-m", "pip", "install", 
            "--break-system-packages", "--user", "-q", "-e", 
            f"{pathToTop}/modules/{package}"
        ], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Failed to install module {package}. Error: {e}",
            file=sys.stderr)
        os._exit(1)
    if package in sys.modules:
        del sys.modules[package]
    importlib.invalidate_caches()
    import site
    importlib.reload(site)
    if retryMessage:
        print(f"Retrying importation ...", file=sys.stderr)
