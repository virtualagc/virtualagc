#!/usr/bin/env python3
"""Set up the hand controllers by doing, not by editing JSON: press the key for each action, move the stick the way
it asks.  Run on request only:  python3 flightwizard.py --hand-controllers   (or  python3 handcontroller_setup.py).

KEYBOARD   asks for a key for each of the twelve virtual-controller actions and writes local/hand-keys.json, which the
           wizard then passes as --hc-keys in place of the keypad layout.  Backspace keeps an action's default key.
JOYSTICK   lists the connected sticks, asks which is the RHC and where the THC comes from, finds each axis by watching
           which one moves, and merges the result into ~/.config/nsts/joysticks.json (the old file is kept as .bak;
           its other entries are kept).

Both need pygame (the same as the virtual controllers).  Nothing is changed until the last question is answered.
"""
import json
import os
import shutil
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
KEYS_OUT = os.path.join(os.environ.get("FLIGHTWIZARD_LOCAL") or os.path.join(HERE, "local"), "hand-keys.json")
JOY_OUT = os.path.expanduser("~/.config/nsts/joysticks.json")

ACTIONS = [("rhc", "pitch-", "PITCH FORWARD (stick forward, nose down)"), ("rhc", "pitch+", "PITCH BACK (stick back, nose up)"),
           ("rhc", "yaw-", "YAW LEFT"), ("rhc", "yaw+", "YAW RIGHT"),
           ("rhc", "roll-", "ROLL LEFT"), ("rhc", "roll+", "ROLL RIGHT"),
           ("thc", "+X", "TRANSLATE FORWARD (+X)"), ("thc", "-X", "TRANSLATE BACK (-X)"),
           ("thc", "+Y", "TRANSLATE RIGHT (+Y)"), ("thc", "-Y", "TRANSLATE LEFT (-Y)"),
           ("thc", "-Z", "TRANSLATE UP (-Z)"), ("thc", "+Z", "TRANSLATE DOWN (+Z)")]


def need_pygame():
    try:
        import pygame
    except ImportError:
        sys.exit("handcontroller_setup: pygame is not installed (pip install pygame)")
    return pygame


def ask(prompt, default=None):
    t = input("%s%s " % (prompt, " [%s]" % default if default is not None else ""))
    return t.strip() or (default if default is not None else "")


# ---------------------------------------------------------------- keyboard
def capture_keys(pygame, actions, wait=None):
    """{(group, action): key name}; an action left out was skipped.  `wait` is for tests: it supplies the key events."""
    pygame.init()
    screen = pygame.display.set_mode((640, 130))
    pygame.display.set_caption("Hand controller keys")
    font = pygame.font.Font(None, 30)
    chosen = {}
    for n, (group, action, text) in enumerate(actions):
        while True:
            screen.fill((20, 20, 30))
            for i, line in enumerate(("%d of %d: press the key for %s" % (n + 1, len(actions), text),
                                      "Backspace keeps the default;  Esc stops")):
                screen.blit(font.render(line, True, (230, 230, 230)), (10, 20 + 40 * i))
            pygame.display.flip()
            ev = wait() if wait else pygame.event.wait()
            if ev.type == pygame.QUIT:
                return None
            if ev.type != pygame.KEYDOWN:
                continue
            if ev.key == pygame.K_ESCAPE:
                return None
            if ev.key == pygame.K_BACKSPACE:
                print("  %s: default kept" % text)
                break
            name = pygame.key.name(ev.key)
            used = [a for (g, a), k in chosen.items() if k == name]
            if used:
                print("  %s is already %s; another key please" % (name, used[0]))
                continue
            chosen[(group, action)] = name
            print("  %s: %s" % (text, name))
            break
    pygame.display.quit()
    return chosen


def keyboard_setup(pygame):
    print("Hand controllers from the KEYBOARD.  A small window opens; press the key you want for each action.")
    chosen = capture_keys(pygame, ACTIONS)
    if chosen is None:
        print("Stopped; nothing written.")
        return
    keys = {}
    for (g, a), k in chosen.items():
        keys.setdefault(g, {})[a] = [k]
    if not keys:
        print("Nothing chosen; nothing written.")
        return
    os.makedirs(os.path.dirname(KEYS_OUT), exist_ok=True)
    with open(KEYS_OUT, "w") as f:
        json.dump({"_comment": "Written by handcontroller_setup.py; actions not named keep the default keys.", "keys": keys}, f, indent=2)
    print("Written %s.  The wizard uses it for the keyboard controllers from now on." % KEYS_OUT)


# ---------------------------------------------------------------- joysticks
def open_sticks(pygame):
    pygame.init()
    pygame.joystick.init()
    sticks = {}
    for i in range(pygame.joystick.get_count()):
        js = pygame.joystick.Joystick(i)
        js.init()
        sticks[i] = js
    return sticks


def selector_for(i, sticks):
    """How a role names stick i so it cannot be mistaken for another: its name if that is unique among those connected,
    else its GUID if that is, else its number (which can change if sticks are unplugged and replugged)."""
    js = sticks[i]
    names = [s.get_name() for s in sticks.values()]
    if names.count(js.get_name()) == 1:
        return {"match": js.get_name()}, ""
    guids = [s.get_guid() for s in sticks.values()]
    if guids.count(js.get_guid()) == 1:
        return {"guid": js.get_guid()}, ""
    return {"index": i}, ("  Note: two sticks of this model are connected and the system gives them the same identity, so this one is\n"
                          "  recorded by its NUMBER; plug them in the same order, or run this setup again, if the numbering changes.")


def watch_axis(pygame, js, used, prompt, timeout=30.0):
    """(axis number, +1 or -1) of the axis that moves furthest when the user does what `prompt` says."""
    print("  " + prompt)
    pygame.event.pump()
    base = [js.get_axis(i) for i in range(js.get_numaxes())]
    t0 = time.time()
    while time.time() - t0 < timeout:
        pygame.event.pump()
        moved = sorted(((abs(js.get_axis(i) - base[i]), i) for i in range(js.get_numaxes()) if i not in used), reverse=True)
        if moved and moved[0][0] > 0.6:
            i = moved[0][1]
            sign = 1 if js.get_axis(i) - base[i] > 0 else -1
            print("    axis %d (%s)" % (i, "increasing" if sign > 0 else "decreasing"))
            release(pygame, js, base)
            return i, sign
        time.sleep(0.02)
    return None


def release(pygame, js, base):
    print("    ...let go")
    while True:
        pygame.event.pump()
        if all(abs(js.get_axis(i) - base[i]) < 0.2 for i in range(js.get_numaxes())):
            return
        time.sleep(0.02)


def watch_button(pygame, js, prompt, timeout=30.0):
    print("  " + prompt)
    t0 = time.time()
    while time.time() - t0 < timeout:
        for ev in pygame.event.get():
            if ev.type == pygame.JOYBUTTONDOWN and ev.instance_id == js.get_instance_id():
                print("    button %d" % (ev.button + 1))
                return ev.button + 1
        time.sleep(0.02)
    return None


def rhc_profile(pygame, js):
    prof, used = {"axes": {}}, set()
    for dest, prompt in (("rhc.roll", "Push the stick to the RIGHT (roll right) and hold it there."),
                         ("rhc.pitch", "Pull the stick BACK (nose up) and hold it there."),
                         ("rhc.yaw", "TWIST the stick to the RIGHT (yaw right) and hold it there.")):
        r = watch_axis(pygame, js, used, prompt)
        if r is None:
            print("    nothing moved; stopping this stick")
            return None
        used.add(r[0])
        prof["axes"][str(r[0])] = {"to": dest, "sign": r[1], "deadband": 0.05}
    return prof


def thc_from_buttons(pygame, js, prof):
    if not js.get_numhats():
        print("  This stick has no hat, so it cannot also be the THC; use a second stick, or the keyboard.")
        return False
    print("  The THC will be: the hat for up/down/left/right, and two buttons for forward/back.")
    prof["hat"] = {"left": "-Y", "right": "+Y", "down": "+Z", "up": "-Z"}
    prof["buttons"] = {}
    for d, text in (("+X", "TRANSLATE FORWARD (+X)"), ("-X", "TRANSLATE BACK (-X)")):
        b = watch_button(pygame, js, "Press the button for " + text + ".")
        if b is None:
            return False
        prof["buttons"][str(b)] = d
    return True


def thc_from_axes(pygame, js):
    prof, used = {"axes": {}}, set()
    for dest, prompt in (("thc.X", "Push the stick FORWARD (translate forward, +X) and hold it there."),
                         ("thc.Y", "Push the stick to the RIGHT (translate right, +Y) and hold it there."),
                         ("thc.Z", "TWIST the stick to the RIGHT (translate down, +Z) and hold it there.")):
        r = watch_axis(pygame, js, used, prompt)
        if r is None:
            return None
        used.add(r[0])
        prof["axes"][str(r[0])] = {"to": dest, "sign": r[1], "threshold": 0.5, "hysteresis": 0.15}
    return prof


def joystick_setup(pygame):
    sticks = open_sticks(pygame)
    if not sticks:
        print("No joystick is connected.  Plug it in and run this again.")
        return
    print("Connected sticks:")
    for i, js in sticks.items():
        print("  %d  %s   (%d axes, %d buttons, %d hats)" % (i, js.get_name(), js.get_numaxes(), js.get_numbuttons(), js.get_numhats()))
    rhc = int(ask("Which number is the ROTATION hand controller (RHC)?", min(sticks)))
    if rhc not in sticks:
        print("No stick %d." % rhc)
        return
    thc_opts = [i for i in sticks if i != rhc]
    others = "/".join(str(i) for i in thc_opts)
    where = ask("THC (translation) from: the hat and two buttons of the SAME stick, the number of a SECOND stick%s, or NONE?"
                % (" (%s)" % others if others else ""), "same")
    roles, profiles, notes = {}, {}, []
    sel, note = selector_for(rhc, sticks)
    roles["rhc"] = sel
    notes.append(note)
    print("RHC axes on %s:" % sticks[rhc].get_name())
    prof = rhc_profile(pygame, sticks[rhc])
    if prof is None:
        return
    thc_stick = None
    if where.lower().startswith("same"):
        if not thc_from_buttons(pygame, sticks[rhc], prof):
            return
    elif where.lower() != "none":
        thc_stick = int(where)
        if thc_stick not in sticks or thc_stick == rhc:
            print("Not a second stick.")
            return
        if sticks[thc_stick].get_name() == sticks[rhc].get_name():
            print("The two sticks are the same model, and a stick's axis settings are filed under its model name, so they\n"
                  "would get the same settings.  Not supported yet: use a different second stick, or the same stick for both.")
            return
    profiles[sticks[rhc].get_name()] = prof
    if thc_stick is not None:
        sel, note = selector_for(thc_stick, sticks)
        roles["thc"] = sel
        notes.append(note)
        print("THC axes on %s:" % sticks[thc_stick].get_name())
        tp = thc_from_axes(pygame, sticks[thc_stick])
        if tp is None:
            return
        profiles[sticks[thc_stick].get_name()] = tp
    old = {}
    if os.path.isfile(JOY_OUT):
        try:
            old = json.load(open(JOY_OUT))
        except ValueError:
            old = {}
    new = dict(old)
    new["roles"] = dict(old.get("roles", {}), **roles)
    if where.lower() == "none" or thc_stick is None:
        new["roles"].pop("thc", None)
    new["sticks"] = dict(old.get("sticks", {}), **profiles)
    for n in notes:
        if n:
            print(n)
    if os.path.isfile(JOY_OUT):
        shutil.copy2(JOY_OUT, JOY_OUT + ".bak")
    os.makedirs(os.path.dirname(JOY_OUT), exist_ok=True)
    with open(JOY_OUT, "w") as f:
        json.dump(new, f, indent=2)
    print("Written %s%s." % (JOY_OUT, " (the old one is %s.bak)" % JOY_OUT if os.path.isfile(JOY_OUT + ".bak") else ""))
    print("Check it with:  python3 handcontrollers.py --list-joysticks   (and --probe to watch the values)")


def main():
    pygame = need_pygame()
    print("Hand controller setup.  Nothing is written until you finish a section.")
    what = ask("Set up the KEYBOARD keys, a JOYSTICK, or QUIT? [keyboard/joystick/quit]", "quit").lower()
    if what.startswith("k"):
        keyboard_setup(pygame)
    elif what.startswith("j"):
        joystick_setup(pygame)


if __name__ == "__main__":
    main()
