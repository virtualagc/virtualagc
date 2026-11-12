#!/usr/bin/env python3
"""FLIGHT WIZARD: pick the part of the STS-134 flight you want to fly, and get the command that flies it.

    python3 flightwizard.py                 ask everything
    python3 flightwizard.py launch          go straight to a scenario (see --list)

It asks which part of the flight, a handful of options (the window size as a percentage, the number of CRTs, which
out-the-window views, the layout, ...), prepares a run directory, and then prints the command, runs it, or both.
Your answers are remembered PER SCENARIO (what you chose for the launch is not what you chose for the docking) and
offered as the defaults next time; a scenario can be put back to the distribution defaults.

WHAT IT LOOKS FOR, all relative to this directory (discretePanel/) -- nothing is downloaded:

    OI340700-OPS1.7z .. OPS3.7z, OPS2.7z, OPS0.7z    the encrypted volumes, shipped here
    local/tapes/*.mmv                  OPTIONAL unencrypted volumes (also *.mmv here): used in preference to the archives
    local/snapshots/STS134-snapshots.7z   the encrypted snapshot set (with snapshot-index.json beside it)
    local/snapshots/unpacked/SET/NAME  OPTIONAL: the same snapshots unpacked; used in preference to the archive
    local/portview-textures.7z         the textures archive (unpacked here if portview's files are missing)
    *.layout                           window layouts, the same directory the Manager's file chooser opens

THE VOLUME ("tier").  A snapshot runs only on the volumes it was taken with (vehicle.json), and a scenario needs the
phases it will use: T1 is whole (launch and aborts, landings, orbit); T1-no16 has no OPS 1/6 (landings, orbit); T1-no136
has no OPS 1/3/6 (orbit: docking, undocking, coasts).  The wizard takes the most inclusive unencrypted volume that the
snapshot accepts and the scenario needs; with none, it asks for the password ONCE and tries OPS1, OPS3, OPS2, OPS0 in that
order -- the first that opens is your tier, and it says so.  The password is only ever passed to the child through
$YAGPC_TAPE_PASSWORD; it is never written anywhere.  --ignore-tape-digest is never used.

THE PRINTED COMMAND needs the same things the run does: the run directory (made under local/runs/), and, for an
encrypted volume, $YAGPC_TAPE_PASSWORD (or it asks).
"""
import argparse
import getpass
import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
FLIGHTS = os.path.join(HERE, "examples", "flights")
YAGPC2 = os.path.join(os.path.dirname(HERE), "yaGPC2")
sys.path.insert(0, os.path.join(YAGPC2, "tools"))
LOCAL = os.environ.get("FLIGHTWIZARD_LOCAL") or os.path.join(HERE, "local")     # the environment variable is for tests
SETTINGS = os.path.join(LOCAL, "wizard-settings.json")

# ---- the volumes, most inclusive first.  The digests are the volumes' contents (the .7z are their encrypted forms).
TIERS = [
    {"name": "T1", "sha": "9bdc5531838c45957aa42ec50a6683d094c88159decf16376c2776713b6530c4", "archive": "OI340700-OPS1.7z",
     "has": {"launch", "landing", "orbit"}, "text": "the whole volume: launch and aborts, landings, orbit"},
    {"name": "T1-no16", "sha": "25ef02250c865586c7b575902c1ab1efdcb1e93fbf9c483bc6bf96607a2cf761", "archive": "OI340700-OPS3.7z",
     "has": {"landing", "orbit"}, "text": "no OPS 1/6: landings and orbit, no launch or aborts"},
    {"name": "T1-no136", "sha": "916a53b7cdc1201919b52abdad24bbedc8e1d8da84a22239fc07e28c5fb20452", "archive": "OI340700-OPS2.7z",
     "has": {"orbit"}, "text": "no OPS 1/3/6: orbit, rendezvous and docking, undocking"},
]
OPS0 = {"name": "OPS0", "archive": "OI340700-OPS0.7z", "has": set(), "text": "the boot volume (no snapshot runs on it)"}
PASSWORD_ORDER = [t["archive"] for t in TIERS] + [OPS0["archive"]]      # OPS1, OPS3, OPS2, OPS0

SNAPSHOT_ARCHIVE = os.path.join(LOCAL, "snapshots", "STS134-snapshots.7z")
SNAPSHOT_DIR = os.path.join(LOCAL, "snapshots", "unpacked")
TEXTURES_ARCHIVE = os.path.join(LOCAL, "portview-textures.7z")
KEYPAD = os.path.join(HERE, "examples", "keys-keypad.json")
TARGETS = os.path.join(FLIGHTS, "sts134-targets.txt")
TARGETS_UNDOCK = os.path.join(FLIGHTS, "sts134-targets-undock-0320.txt")
SITES = os.path.join(YAGPC2, "tools", "sites")

# ---- the options a user may change.  key: (question, kind, distribution default; per-scenario overrides below)
OPTIONS = {
    "rate":     ("Simulated seconds per wall second (1 = real time)", float, 1.0),
    "size":     ("Window size as a percentage (100 = the usual size, 50 = half)", float, 50.0),
    "crts":     ("Number of CRT displays (1-4)", int, 2),
    "portview": ("Out-the-window views (portview)", bool, True),
    "views":    ("Which views, comma separated (front,up,left,right,aft,cctv,rpop)", str, "front,up,left,right"),
    "station":  ("Crew station windows (fwd, aft, all, auto)", str, "all"),
    "input":    ("Hand controllers (virtual = the keypad, auto, joystick, both)", str, "virtual"),
    "keypad":   ("Use the keypad key file for the hand controllers", bool, True),
    "hold":     ("Bring the windows up and hold the vehicle until you press Enter (time to arrange windows)", bool, True),
    "layout":   ("Window layout file from this directory (blank for none)", str, ""),
    "predictor": ("RPOP predictor (coast or hold)", str, "coast"),
    "engine":   ("Failing main engine (1-3)", int, 2),
    "failat":   ("Seconds after liftoff at which it fails", float, 150.0),
    "runway":   ("RTLS runway (15 or 33)", int, 15),
    "stop":     ("Stop after", str, ""),
    "when":     ("GMT (DDD/HH:MM:SS) or MET (DDD/HH:MM:SS with a leading M, e.g. M001/12:00:00) to be at", str, ""),
}
COMMON = ["rate", "size", "crts", "portview", "views", "station", "input", "keypad", "hold", "layout"]


def scenario_table():
    t = {}
    t["prelaunch"] = dict(
        title="Pre-launch: IPL, the day-of-launch uplink and IMU alignment (about 50 minutes of flight time)",
        need="orbit", snap="IPL-eq-T1-no136/sts134-ipl", capture="sts134-ipl", driver="fly_sts134.py",
        args=["--from", "UPLINK"], stop=("--to", ["IMU"], "IMU"), logsfx="", opts=COMMON,
        note="Ends with the vehicle gyrocompassed on the pad.  A vehicle left there can launch by 'launch' once its snapshot is taken.")
    t["launch"] = dict(
        title="Launch and ascent, from OPS 101 (the countdown from T-19 minutes) to orbit",
        need="launch", snap="ST6-prelaunch-T1no136/sts134-imu", capture="sts134-imu", driver="fly_sts134.py",
        args=["--from", "COUNT"], stop=("--to", ["TERMINAL", "ASCENT", "OMS2", "OPS2"], "OPS2"), logsfx="", opts=COMMON,
        note="OPS 101 to liftoff to OMS 2 and OPS 2.")
    t["rtls"] = dict(
        title="Return to launch site: a main engine fails during ascent, the crew aborts, and lands at KSC",
        need="launch", snap="ST6-prelaunch-T1no136/sts134-imu", capture="sts134-imu", driver="fly_sts134.py",
        args=["--from", "COUNT", "--abort", "RTLS", "--land-time", "1800"], stop=("--to", ["LAND"], "LAND"), logsfx="",
        opts=COMMON + ["engine", "failat", "runway"], env_sites="ksc-navaids.txt",
        note="Fly the whole abort, from the count to the wheels stopped.")
    t["tal"] = dict(
        title="Transoceanic abort landing at Zaragoza: a main engine fails, the crew aborts, and lands in Spain",
        need="launch", snap="ST6-prelaunch-T1no136/sts134-imu", capture="sts134-imu", driver="fly_sts134.py",
        args=["--from", "COUNT", "--abort", "TAL", "--abort-site", "ZZA", "--land-time", "1800", "--incorporate-at-land",
              "--gps-auto-at-land"], stop=("--to", ["LAND"], "LAND"), logsfx="", opts=COMMON + ["engine", "failat"],
        env_sites="zza-navaids.txt", failat_default=290.0, note="Fly the whole abort, from the count to the wheels stopped.")
    t["rendezvous"] = dict(
        title="Rendezvous with the ISS and docking, from the ground uplink on flight day 3 to the hard mate",
        need="orbit", snap="ST4-rndz-dock-T1no136/sts134r-uplink", capture="sts134r-uplink", driver="fly_return.py",
        args=["--from", "RNDZNAV", "--targets", TARGETS], stop=("--to", ["STAY"], "STAY"), logsfx="", opts=COMMON + ["predictor"],
        crts_default=4, views_default="front,up,left,right,cctv,rpop", note="About 4.6 hours of flight time.")
    t["undock"] = dict(
        title="Undocking and fly-around, from the hatch closed to the separation burn SEP3",
        need="orbit", snap="ST3b-undock-return/sts134r-start", capture="sts134r-start", driver="fly_undock.py",
        args=["--from", "SEPCFG", "--targets", TARGETS_UNDOCK], stop=("--to", ["SEP3"], "SEP3"), logsfx="",
        opts=COMMON + ["predictor"], crts_default=4, views_default="front,up,left,right,aft,cctv,rpop",
        note="About 5.5 hours of flight time.")
    t["landing"] = dict(
        title="Deorbit, entry and landing at KSC, from OPS 301 (TIG minus 75 minutes) to the wheels stopped",
        need="landing", snap="ST5-deorbit-prep/sts134r-pre-ops301", capture="sts134r-pre-ops301", driver="fly_return.py",
        args=["--from", "DEORBIT", "--targets", TARGETS_UNDOCK], stop=("--to", ["EXEC", "ENTRY", "LAND"], "LAND"), logsfx="",
        opts=COMMON, also=[("ST5-deorbit-prep/sts134r-orbit", "sts134r-orbit")], resume_env="RETURN_RESUME_FROM",
        note="About 2.3 hours of flight time.")
    t["coast"] = dict(
        title="Coast on orbit: start at a time you name (the nearest snapshot before it, with the clocks running from there)",
        need="orbit", snap=None, capture=None, driver=None, args=[], stop=None, logsfx="", opts=COMMON + ["when"],
        note="No scripted burns or uplinks: the vehicle flies on as it was left.")
    return t


SCENARIOS = scenario_table()
ORDER = ["prelaunch", "launch", "rtls", "tal", "coast", "rendezvous", "undock", "landing"]


# ---------------------------------------------------------------- settings (per scenario)
def load_settings():
    try:
        return json.load(open(SETTINGS))
    except (OSError, ValueError):
        return {}


def save_settings(s):
    try:
        os.makedirs(LOCAL, exist_ok=True)
        json.dump(s, open(SETTINGS, "w"), indent=1)
    except OSError as e:
        print("(settings not saved: %s)" % e)


def defaults_for(sc):
    d = {k: OPTIONS[k][2] for k in sc["opts"]}
    for k in sc["opts"]:
        if k + "_default" in sc:
            d[k] = sc[k + "_default"]
    if "stop" in sc and sc["stop"]:
        d["stop"] = sc["stop"][2]
    if "stop" not in d and sc["stop"]:
        d["stop"] = sc["stop"][2]
    return d


# ---------------------------------------------------------------- asking
class Asker:
    def __init__(self, yes, presets):
        self.yes = yes
        self.presets = presets                  # --set key=value, applied after the remembered values

    def ask(self, prompt, default, kind=str, choices=None):
        shown = ("yes" if default else "no") if kind is bool else default
        if self.yes:
            return default
        while True:
            try:
                raw = input("%s [%s]: " % (prompt, shown)).strip()
            except EOFError:
                sys.exit("\nflightwizard: no answer (standard input closed)")
            if raw == "":
                return default
            try:
                if kind is bool:
                    if raw.lower() in ("y", "yes", "1", "true"):
                        return True
                    if raw.lower() in ("n", "no", "0", "false"):
                        return False
                    raise ValueError
                v = kind(raw)
                if choices and v not in choices:
                    raise ValueError
                return v
            except ValueError:
                print("  not understood%s" % (": one of %s" % ", ".join(map(str, choices)) if choices else ""))


def coerce(key, text):
    kind = OPTIONS[key][1]
    if kind is bool:
        return text.lower() in ("y", "yes", "1", "true", "on")
    return kind(text)


# ---------------------------------------------------------------- volumes
def sha256_of(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def sevenz():
    exe = shutil.which("7z") or shutil.which("7za") or shutil.which("7zz")
    if not exe:
        sys.exit("flightwizard: no 7z on the PATH (the encrypted volumes and snapshots need it)")
    return exe


def plain_volumes():
    """{sha256: path} of the unencrypted volumes found."""
    found = {}
    for d in (os.path.join(LOCAL, "tapes"), HERE):
        if os.path.isdir(d):
            for f in sorted(os.listdir(d)):
                if f.lower().endswith(".mmv"):
                    p = os.path.join(d, f)
                    try:
                        found.setdefault(sha256_of(p), p)
                    except OSError:
                        pass
    return found


def archive_opens(path, pw):
    r = subprocess.run([sevenz(), "l", "-slt", "--", path], input=(pw + "\n").encode(),
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return r.returncode == 0


class Volumes:
    """Chooses the volume for a scenario; remembers the password for the length of this run only."""

    def __init__(self, tapes_dir=None):
        self.pw = os.environ.get("YAGPC_TAPE_PASSWORD")
        self.opened = {}                       # archive name -> True/False, for this password
        self.home = tapes_dir or HERE

    def archive_path(self, name):
        return os.path.join(self.home, name)

    def password(self):
        if self.pw is None:
            self.pw = getpass.getpass("password for the encrypted volumes: ")
        return self.pw

    def open_tier(self):
        """The first archive, in OPS1, OPS3, OPS2, OPS0 order, that the password opens; (name, path) or None."""
        for name in PASSWORD_ORDER:
            path = self.archive_path(name)
            if os.path.isfile(path) and archive_opens(path, self.password()):
                return name, path
        return None

    def choose(self, need, accepted, asker):
        """-> (tier dict, tape argument, env for the child, how).  `accepted`: the digests the snapshot runs on."""
        fits = [t for t in TIERS if need in t["has"] and t["sha"] in accepted]
        if not fits:
            sys.exit("flightwizard: no volume both runs these snapshots and has what this scenario needs (%s)" % need)
        plain = plain_volumes()
        for t in fits:
            if t["sha"] in plain:
                return t, plain[t["sha"]], {}, "the unencrypted copy %s" % plain[t["sha"]]
        # only the encrypted ones: the password says which tier the user holds
        got = self.open_tier()
        if got is None:
            sys.exit("flightwizard: the password opens none of %s" % ", ".join(PASSWORD_ORDER))
        name, path = got
        tier = next((t for t in TIERS if t["archive"] == name), None)
        print("The password opens %s%s." % (name, " -- tier %s: %s" % (tier["name"], tier["text"]) if tier else " (the boot volume)"))
        if tier is None or tier not in fits:
            held = tier["name"] if tier else "OPS0"
            sys.exit("flightwizard: that tier (%s) cannot fly this scenario%s.  Needed: one of %s." % (
                held, "" if tier is None or tier["sha"] in accepted else " from these snapshots",
                ", ".join(t["name"] for t in fits)))
        env = {"YAGPC_TAPE_PASSWORD": self.pw}
        if not asker.yes:
            if asker.ask("Save an unencrypted copy as local/tapes/%s.mmv so you are not asked again?" % tier["name"], False, bool):
                self.save_plain(tier, path)
        return tier, path, env, "the encrypted volume %s" % path

    def save_plain(self, tier, path):
        os.makedirs(os.path.join(LOCAL, "tapes"), exist_ok=True)
        r = subprocess.run([sevenz(), "x", "-so", "--", path], input=(self.pw + "\n").encode(),
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if r.returncode != 0 or hashlib.sha256(r.stdout).hexdigest() != tier["sha"]:
            print("(not saved: the archive did not give the expected volume)")
            return
        out = os.path.join(LOCAL, "tapes", tier["name"] + ".mmv")
        open(out, "wb").write(r.stdout)
        print("saved %s" % out)


# ---------------------------------------------------------------- snapshots
def snapshot_rows():
    """The index rows of the snapshots available: unpacked directories first, else the archive's index."""
    import snapshot_bundle as sb
    if os.path.isdir(SNAPSHOT_DIR) and sb.snapshots_under(SNAPSHOT_DIR):
        rows, where = sb.build_index([SNAPSHOT_DIR])
        for r in rows:
            r["_dir"] = where[r["name"]]
        return rows
    idx = os.path.join(os.path.dirname(SNAPSHOT_ARCHIVE), "snapshot-index.json")
    if os.path.isfile(SNAPSHOT_ARCHIVE) and os.path.isfile(idx):
        return json.load(open(idx))["snapshots"]
    sys.exit("flightwizard: no snapshots.  Put the snapshot archive STS134-snapshots.7z and its snapshot-index.json in\n"
             "  %s\n  (or unpack the snapshots under %s/SET/NAME)." % (os.path.dirname(SNAPSHOT_ARCHIVE), SNAPSHOT_DIR))


def accepted_digests(row):
    return {row["tapeSha256"]} | set(row.get("tapeSha256Also") or [])


def parse_when(text, rows):
    """'DDD/HH:MM[:SS]' is GMT; 'M' + that is MET.  -> GMT as (day, seconds)."""
    t = text.strip().upper()
    met = t.startswith("M")
    if met:
        t = t[1:]
    m = re.fullmatch(r"(\d+)/(\d+):(\d+)(?::(\d+(?:\.\d*)?))?", t)
    if not m:
        sys.exit("flightwizard: a time looks like 138/06:30:00 (GMT) or M001/17:15:00 (MET)")
    day, h, mi, s = int(m.group(1)), int(m.group(2)), int(m.group(3)), float(m.group(4) or 0)
    return met, day * 86400 + h * 3600 + mi * 60 + s


def row_seconds(row, met):
    key = "met" if met else "gmt"
    t = row.get(key)
    if not t:
        return None
    m = re.fullmatch(r"(-?)(\d+)/(\d+):(\d+):(\d+(?:\.\d*)?)", t)
    sec = int(m.group(2)) * 86400 + int(m.group(3)) * 3600 + int(m.group(4)) * 60 + float(m.group(5))
    return -sec if m.group(1) else sec


def coast_snapshot(rows, text):
    met, target = parse_when(text, rows)
    # a coast on orbit: the sets that are the vehicle on orbit (not the pre-launch ones, which are on the pad)
    best = None
    for r in rows:
        if r["set"].startswith(("IPL", "ST6")):
            continue
        s = row_seconds(r, met)
        if s is not None and s <= target and (best is None or s > best[0]):
            best = (s, r)
    if best is None:
        sys.exit("flightwizard: no snapshot on orbit at or before that time")
    return best[1], target - best[0]


def stage_snapshot(row, dest, pw_holder, asker):
    """Put snapshot `row` in directory `dest`; returns dest."""
    import snapshot_bundle as sb
    if row.get("_dir"):
        if os.path.exists(dest):
            shutil.rmtree(dest)
        shutil.copytree(row["_dir"], dest)
        return dest
    pw = pw_holder.pw or os.environ.get("YAGPC_SNAPSHOT_PASSWORD") or getpass.getpass("password for the snapshot archive: ")
    with tempfile.TemporaryDirectory() as tmp:
        try:
            src = sb.extract_one(SNAPSHOT_ARCHIVE, row["name"], tmp, pw)
        except SystemExit:
            pw = getpass.getpass("password for the snapshot archive (the volumes' did not open it): ")
            src = sb.extract_one(SNAPSHOT_ARCHIVE, row["name"], tmp, pw)
        if os.path.exists(dest):
            shutil.rmtree(dest)
        shutil.move(src, dest)
    return dest


# ---------------------------------------------------------------- the command
def env_prefix(env):
    return " ".join("%s=%s" % (k, shlex.quote(v)) for k, v in env.items() if k != "YAGPC_TAPE_PASSWORD")


def build(scn_id, sc, o, tape, run, base, row, rows, env_extra):
    """-> (argv, env, cwd)."""
    env = dict(env_extra)
    size = int(round(768 * float(o.get("size", 50)) / 100.0))
    if sc["driver"] is None:                      # the coast viewer: simulatePASS itself
        # a restored vehicle model needs these on (simulatePASS says so when they are missing); the MET epoch is the
        # snapshot's own: its GMT less its MET
        env.update({"YAGPC_VEHDYN": "1", "YAGPC_MDM_DEVICES": "1"})
        if row.get("_dir") and os.path.isfile(os.path.join(row["_dir"], "vehicle.json")):
            env["YAGPC_MTU_MET_EPOCH"] = "%.3f" % json.load(open(os.path.join(row["_dir"], "vehicle.json")))["metEpoch"]
        elif row.get("gmtUnix") is not None and row_seconds(row, True) is not None:
            env["YAGPC_MTU_MET_EPOCH"] = "%.3f" % (row["gmtUnix"] - row_seconds(row, True))
        argv = [sys.executable, "-u", os.path.join(HERE, "simulatePASS.py"), "--gpcs", "1", "--tape", tape,
                "--snapshot-resume", row["_arg"], "--rt-factor", "%g" % float(o["rate"]), "--port-base", str(base),
                "--logs", os.path.join(run, "logs"), "--snapshot-dir", run, "--size", str(size), "--crts", str(o["crts"])]
        if o.get("portview"):
            argv += ["--portview-views", o["views"]]
        else:
            argv += ["--no-portview"]
        for k in ("station", "input"):
            if o.get(k):
                argv += ["--" + k, o[k]]
        if o.get("keypad") and os.path.isfile(KEYPAD):
            argv += ["--hc-keys", KEYPAD]
        if o.get("hold"):
            argv += ["--hold-start"]
        if o.get("layout"):
            argv += ["--layout", os.path.join(HERE, o["layout"])]
        return argv, env, HERE
    argv = [sys.executable, "-u", os.path.join(FLIGHTS, sc["driver"]), "--logs", run, "--tape", tape,
            "--port-base", str(base), "--rate", "%g" % float(o["rate"]), "--size", str(size), "--crts", str(o["crts"])]
    argv += sc["args"]
    if sc["stop"]:
        argv += [sc["stop"][0], o.get("stop") or sc["stop"][2]]
    if o.get("portview"):
        argv += ["--portview", "--portview-views" if sc["driver"] == "fly_sts134.py" else "--views", o["views"]]
    for k, flag in (("station", "--station"), ("input", "--input")):
        if o.get(k):
            argv += [flag, o[k]]
    if o.get("keypad") and os.path.isfile(KEYPAD):
        argv += ["--hc-keys", KEYPAD]
    if o.get("hold"):
        argv += ["--hold-start"]
    if o.get("layout"):
        argv += ["--layout", os.path.join(HERE, o["layout"])]
    if scn_id == "rtls":
        argv += ["--rtls-runway", str(o["runway"])]
    if "engine" in o:
        env["YAGPC_SSME_FAIL"] = "%d@%g" % (o["engine"], o["failat"])
    if sc.get("env_sites"):
        env["YAGPC_NAVAIDS"] = os.path.join(SITES, sc["env_sites"])
    if sc["driver"] != "fly_sts134.py":
        env["FLY_DURATION"] = "60000"
        if o.get("predictor"):
            env["NSTS_RPOP_PREDICTOR"] = o["predictor"]
    else:
        env["FLY_DURATION"] = "60000"
    if sc.get("resume_env"):
        env[sc["resume_env"]] = os.path.join(run, sc["capture"])
    return argv, env, FLIGHTS


def free_base(start=30000):
    import socket
    for base in range(start, 60000, 200):
        try:
            for p in (base, base + 100):
                s = socket.socket()
                s.bind(("127.0.0.1", p))
                s.close()
            return base
        except OSError:
            continue
    return start


def textures_ready():
    r = subprocess.run([sys.executable, os.path.join(HERE, "portview.py"), "--check"], cwd=HERE,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return r.returncode == 0


def ensure_textures(asker):
    if textures_ready():
        return True
    print("portview's textures are not unpacked here.")
    if os.path.isfile(TEXTURES_ARCHIVE):
        if asker.ask("Unpack %s into %s?" % (TEXTURES_ARCHIVE, HERE), True, bool):
            subprocess.run([sevenz(), "x", "-y", os.path.abspath(TEXTURES_ARCHIVE)], cwd=HERE)
            return textures_ready()
    else:
        print("  Download portview-textures.7z (900 MiB) from https://www.ibiblio.org/apollo/Downloads/ and put it in\n  %s"
              % os.path.dirname(TEXTURES_ARCHIVE))
    return False


def layouts():
    return sorted(f for f in os.listdir(HERE) if f.endswith(".layout"))


# ---------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0], formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("scenario", nargs="?", choices=ORDER, help="skip the menu")
    ap.add_argument("--list", action="store_true", help="list the scenarios and exit")
    ap.add_argument("--yes", action="store_true", help="ask nothing: take the remembered (or default) answers")
    ap.add_argument("--set", action="append", default=[], metavar="KEY=VALUE", help="an answer given in advance (see --list-options)")
    ap.add_argument("--list-options", action="store_true")
    ap.add_argument("--reset", action="store_true", help="put the scenario's answers back to the distribution defaults")
    ap.add_argument("--print", dest="mode", action="store_const", const="print", help="print the command only")
    ap.add_argument("--run", dest="mode", action="store_const", const="run", help="run it only")
    ap.add_argument("--both", dest="mode", action="store_const", const="both", help="print it and run it")
    ap.add_argument("--port-base", type=int, help="the simulator's first TCP port (default: a free one)")
    ap.add_argument("--tapes-dir", help="where the OI340700-OPS*.7z are (default: this directory); for tests")
    ap.add_argument("--no-save", action="store_true", help="do not remember the answers")
    a = ap.parse_args()

    if a.list or a.list_options:
        if a.list_options:
            for k, (q, kind, d) in OPTIONS.items():
                print("%-10s %s (default %s)" % (k, q, d))
        else:
            for k in ORDER:
                print("%-11s %s" % (k, SCENARIOS[k]["title"]))
        return

    asker = Asker(a.yes, {})
    if a.scenario:
        scn_id = a.scenario
    else:
        print("Which part of the flight?")
        for i, k in enumerate(ORDER, 1):
            print("  %d  %s" % (i, SCENARIOS[k]["title"]))
        if a.yes:
            sys.exit("flightwizard: name a scenario")
        scn_id = ORDER[asker.ask("Number", 1, int, range(1, len(ORDER) + 1)) - 1]
    sc = SCENARIOS[scn_id]
    print("\n%s\n%s\n" % (sc["title"], sc["note"]))

    settings = load_settings()
    dflt = defaults_for(sc)
    if a.reset:
        settings.pop(scn_id, None)
    mine = dict(dflt)
    mine.update({k: v for k, v in settings.get(scn_id, {}).items() if k in dflt})
    for item in a.set:
        k, _, v = item.partition("=")
        if k not in OPTIONS:
            sys.exit("flightwizard: unknown option %s (--list-options)" % k)
        mine[k] = coerce(k, v)
    changed = False
    if not a.yes and not a.set:
        print("Settings for this scenario (remembered from last time where you changed them):")
        for k in sc["opts"] + (["stop"] if sc["stop"] else []):
            print("  %-10s %s" % (k, mine.get(k)))
        choice = asker.ask("Keep these, change some, or reset to the distribution defaults? (k/c/r)", "k", str, ("k", "c", "r"))
        changed = choice != "k"
        if choice == "r":
            mine = dict(dflt)
            settings.pop(scn_id, None)
        if choice == "c":
            if layouts():
                print("Layouts here: %s" % ", ".join(layouts()))
            for k in sc["opts"]:
                q, kind, _ = OPTIONS[k]
                if k == "views" and not mine.get("portview"):
                    continue
                if k == "when":
                    mine[k] = asker.ask(q, mine.get(k) or "", str)
                else:
                    mine[k] = asker.ask(q, mine[k], kind)
            if sc["stop"]:
                mine["stop"] = asker.ask("Stop after (%s)" % ", ".join(sc["stop"][1]), mine["stop"], str, sc["stop"][1])
    if mine.get("layout") and not os.path.isfile(os.path.join(HERE, mine["layout"])):
        sys.exit("flightwizard: no layout %s in %s" % (mine["layout"], HERE))
    if "when" in mine and not mine["when"]:
        if a.yes:
            sys.exit("flightwizard: coast needs --set when=...")
        mine["when"] = asker.ask(OPTIONS["when"][0], "", str)
    if changed and not a.no_save:               # --yes and --set answers are one-off: never remembered
        keep = {k: v for k, v in mine.items() if v != dflt.get(k) and k != "when"}
        if keep:
            settings[scn_id] = {k: v for k, v in mine.items() if k != "when"}
        else:
            settings.pop(scn_id, None)
        save_settings(settings)

    mode = a.mode
    if not mode:
        mode = asker.ask("Print the command, run it, or both? (print/run/both)", "both", str, ("print", "run", "both"))

    rows = snapshot_rows()
    if scn_id == "coast":
        row, off = coast_snapshot(rows, mine["when"])
        print("Starting at snapshot %s (GMT %s, MET %s): %.1f minutes before the time you asked for; at rate %g that is "
              "%.1f minutes of waiting." % (row["name"], row.get("gmt"), row.get("met", "-"), off / 60.0, mine["rate"],
                                           off / 60.0 / max(float(mine["rate"]), 1e-9)))
    else:
        row = next((r for r in rows if r["name"] == sc["snap"]), None)
        if row is None:
            sys.exit("flightwizard: the snapshot %s is not in your snapshot set" % sc["snap"])

    vols = Volumes(a.tapes_dir)
    tier, tape, venv, how = vols.choose(sc["need"], accepted_digests(row), asker)
    print("Volume: %s (%s) -- %s" % (tier["name"], tier["text"], how))

    if mine.get("portview") and not a.yes:
        if not ensure_textures(asker):
            if asker.ask("Continue without the out-the-window views?", True, bool):
                mine["portview"] = False
            else:
                sys.exit(1)

    stamp = time.strftime("%Y%m%d-%H%M%S")
    run = os.path.join(LOCAL, "runs", "%s-%s" % (scn_id, stamp))
    os.makedirs(run, exist_ok=True)
    if sc["capture"]:
        stage_snapshot(row, os.path.join(run, sc["capture"]), vols, asker)
        for name, cap in sc.get("also", []):
            r2 = next(r for r in rows if r["name"] == name)
            stage_snapshot(r2, os.path.join(run, cap), vols, asker)
    else:
        if row.get("_dir"):
            row["_arg"] = row["_dir"]
        else:
            row["_arg"] = "%s::%s" % (SNAPSHOT_ARCHIVE, row["name"])
    base = a.port_base or free_base()
    argv, env, cwd = build(scn_id, sc, mine, tape, run, base, row, rows, venv)
    env.update({k: v for k, v in venv.items()})

    shown = "cd %s && %s%s" % (shlex.quote(cwd), (env_prefix(env) + " ") if env_prefix(env) else "", " ".join(map(shlex.quote, argv)))
    if mode in ("print", "both"):
        print("\n%s\n" % shown)
        if "YAGPC_TAPE_PASSWORD" in env:
            print("(the volume is encrypted: export YAGPC_TAPE_PASSWORD, or you will be asked for it)\n")
    if mode in ("run", "both"):
        child = dict(os.environ)
        child.update(env)
        print("Run directory: %s\n" % run)
        sys.exit(subprocess.call(argv, cwd=cwd, env=child))


if __name__ == "__main__":
    main()
