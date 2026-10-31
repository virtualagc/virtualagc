#!/usr/bin/env python3
"""Fly STS-134 continuously from OPS 2 through the FD1--FD3 burns.

The vehicle resumes from an OPS2 capture by default.  ``--from-launch`` runs
the existing ascent phases and then continues in the same simulator process.
An interrupted stage can continue from a recorded checkpoint with
``--resume-from DIR --resume-after NC1|NC2|NC3``; a pre-NC1 coast checkpoint
can also be resumed with ``--resume-from DIR`` alone. Prior burn and capture
records are carried into the new result. Ground targeting is recalculated at
each burn using the truth state and the Orbiter's rotating 4x4 gravity
propagator; the planned controls are keyed through PASS in OPS 202.
"""
import argparse
import copy
import calendar
import datetime
import hashlib
import json
import math
import os
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
PANEL = os.path.dirname(os.path.dirname(HERE))
YAGPC2 = os.path.join(os.path.dirname(PANEL), "yaGPC2")
sys.path.insert(0, PANEL)
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(YAGPC2, "tools"))

import crewscript  # noqa: E402
import fly_rndz134 as rndz  # noqa: E402
import fly_sts134  # noqa: E402
import groundstation  # noqa: E402
import rndz_start  # noqa: E402
import fd13_propagator  # noqa: E402

FT = 0.3048
G_FT_S2 = 9.80665 / FT
OMS_THRUST_LBF = 6087.0
OMS_VE_FT_S = 10136.8
OMS_POSTBURN_MARGIN_S = 5.0
OMS_MIN_MEASUREMENT_OFFSET_S = 120.0
# Keep the card's <0.2 ft/s RCS null, then use the rendezvous stage's existing
# TRANS PULSE cleanup so a small accepted VGO residual does not compound over
# the long NC3-to-NC4 coast.
DEFAULT_RCS_PULSE_TRIM_FPS = 0.08
# A prior rate-1 NC3 replay's before/after truth captures were fit with the
# same J2--J4 propagator used here.  Its 24.59 ft/s RCS null sequence has an
# equivalent impulse midpoint 102 s after TIG (fit: 24.49 ft/s, 157 ft and
# 0.015 ft/s endpoint residual).  The mission's 11.5 s duration is not a
# useful RCS midpoint: null_vgo() distributes the corrections over several
# passes.  Keep this empirical center separate from that nominal duration.
RCS_EFFECTIVE_MIDPOINT_OFFSET_S = 102.0
TAPE = os.path.expanduser("~/workspace/pass-run/rtls-fix/full2-kscG16.mmv")
OPS2 = os.path.expanduser("~/sts134-runs/ascent2/sts134-ops2")
TARGETS = os.path.expanduser("~/sts134-runs/approach-snaps/sts134-targets.txt")
START_UTC = "2011-05-18T06:10:00"
TIGS = [
    {"name": "NC1", "doy": 136, "h": 15, "m": 48, "s": 38.1, "duration": 66.7, "engine": 1},
    {"name": "NC2", "doy": 137, "h": 6, "m": 22, "s": 51.6, "duration": 14.4, "engine": 3},
    {"name": "NC3", "doy": 137, "h": 15, "m": 41, "s": 14.0, "duration": 11.5, "engine": 4},
    {"name": "NC4", "doy": 138, "h": 6, "m": 7, "s": 27.4, "duration": 10.6, "engine": 2},
]
# These are prior scales for the weighted targeting solve, not values replayed
# from the flown burns.  Ground targeting determines each run's actual vector.
DV_SCALES_FPS = [93.6, 11.2, 2.7, 8.2]
# Per-axis targeting bounds (ft/s) for the differential corrector.  The
# nominal scales above regularize solutions; they do not constrain them.  In
# particular, an unconstrained solve can assign hundreds of ft/s to the RCS
# NC3 burn even though the six-pass VGO null cannot deliver it.  The generous
# OMS bounds leave room to move correction into the earlier/later OMS burns;
# the NC3 bound keeps a three-axis request within the measured RCS capability.
DV_BOUNDS_FPS = [150.0, 100.0, 40.0, 100.0]
# A same-checkpoint rate-2 replay delivered a 41.7 ft/s NC3 vector with 16
# null passes, leaving 0.82 ft/s VGO and missing the strict 0.2 ft/s-per-axis
# trim threshold. This is a capped flight-tested candidate, not proof that the
# remaining full-rate trajectories or trim converge; the earlier 32-pass run
# spent substantially more propellant without a useful reduction in residual.
RCS_VGO_NULL_PASSES = 8
TIG_NAMES = tuple(x["name"] for x in TIGS)



def targeting_state_scales(schedule):
    """Choose state residual scales, tightening a single NC4 terminal solve."""
    if len(schedule) == 1 and schedule[0].get("name") == "NC4":
        return [1000.0, 1000.0, 1000.0, 2.5, 2.5, 2.5]
    return [100.0, 100.0, 100.0, 0.1, 0.1, 0.1]


def terminal_state_acceptance(error_ft_fts):
    """Apply the revised 5 kft and 5 ft/s NC4 handoff limits."""
    import math
    try:
        values = [float(x) for x in error_ft_fts]
        if len(values) != 6 or not all(math.isfinite(x) for x in values):
            raise ValueError
        position = math.sqrt(sum(x*x for x in values[:3]))
        velocity = math.sqrt(sum(x*x for x in values[3:]))
    except (TypeError, ValueError):
        return {"accepted": False, "position_error_ft": None, "velocity_error_fts": None}
    return {"accepted": position <= 5000.0 and velocity <= 5.0,
            "position_error_ft": position, "velocity_error_fts": velocity}

def first_burn_index(resume_after=None):
    """Return the first scheduled burn not already completed by a checkpoint."""
    if resume_after is None:
        return 0
    if resume_after not in TIG_NAMES[:-1]:
        raise ValueError("resume-after must name NC1, NC2, or NC3")
    return TIG_NAMES.index(resume_after) + 1


def remaining_burns(active, local_index):
    """Select unflown burns using the active schedule's local position."""
    return active[local_index:]


def targeting_burns(schedule, first_index):
    """Keep every unflown burn in the targeting horizon, through NC4."""
    return schedule[first_index:]


def resume_targeting_prior(result, schedule, first_index):
    """Reuse the last recorded solution suffix as the resumed solve's seed."""
    positions = {event["name"]: i for i, event in enumerate(schedule)}
    for entry in reversed(result.get("targeting", [])):
        start = positions.get(entry.get("burn"))
        controls = entry.get("controls_mps_lvlh")
        if start is None or start > first_index or not isinstance(controls, list):
            continue
        offset = first_index - start
        suffix = controls[offset:]
        if len(suffix) == len(schedule) - first_index:
            try:
                return [float(v) for vector in suffix for v in vector]
            except (TypeError, ValueError):
                continue
    return None


def load_targeting_seed(path, schedule, first_index):
    """Load a complete targeting solution as a differential-corrector seed."""
    with open(path) as f:
        result = json.load(f)
    controls = resume_targeting_prior(result, schedule, first_index)
    if controls is None:
        raise ValueError("targeting seed has no complete burn suffix for this checkpoint")
    with open(path, "rb") as f:
        digest = hashlib.sha256(f.read()).hexdigest()
    entries = result.get("targeting", [])
    selected = next((entry for entry in reversed(entries)
                     if resume_targeting_prior({"targeting": [entry]}, schedule, first_index)
                     is not None), None)
    return {"controls": controls, "path": os.path.abspath(path), "sha256": digest,
            "burn": selected.get("burn") if selected else None,
            "source": result.get("source"),
            "provenance": result.get("seed_provenance")}


def select_targeting_prior(result, schedule, first_index, seed_path=None):
    """Use an explicit external seed in preference to the checkpoint's plan."""
    if seed_path:
        seed = load_targeting_seed(seed_path, schedule, first_index)
        return seed["controls"], seed
    return resume_targeting_prior(result, schedule, first_index), None


def execution_burns(schedule, first_index, final_index):
    """Select the burns to execute, which may end before the targeting horizon."""
    return schedule[first_index:final_index + 1]


def capture_gmt(capture):
    """Read a capture's epoch as GPC GMT, converting capture.json's Unix key."""
    if capture.get("gmt") is not None:
        return float(capture["gmt"])
    if capture.get("gmtUnix") is not None:
        return gmt_of_unix(float(capture["gmtUnix"]))
    return None


def snapshot_truth(capture_dir):
    """Return the captured M50 truth state from vehdyn's SI save payload."""
    with open(os.path.join(capture_dir, "vehdyn.json")) as f:
        values = json.load(f)["vehdyn"]
    if len(values) < 127:
        raise ValueError("capture vehdyn payload has no saved GMT")
    if len(values) < 168:
        raise ValueError("capture vehdyn payload has no Orbiter mass properties")
    propellant = [float(x) for x in values[16:21]]
    dry_kg = float(values[167])
    return {"t": float(values[2]), "r": [float(x) for x in values[3:6]],
            "v": [float(x) for x in values[6:9]], "q": [float(x) for x in values[9:13]],
            "w": [float(x) for x in values[13:16]], "gmt": float(values[126]),
            "dry_kg": dry_kg, "propellant_kg": propellant,
            "mass_kg": dry_kg + sum(propellant)}


def can_resume_result(status, completed_burn, checkpoint_recorded=False):
    """Allow a recorded pre-NC1 checkpoint or a completed-burn checkpoint."""
    if completed_burn is None:
        return (status in ("running", "failed", "short-test-complete",
                           "partial-stage-complete", "full-stage-complete")
                and checkpoint_recorded)
    if status == "running":
        return True
    if status == "short-test-complete":
        return completed_burn == "NC1"
    return status in ("partial-stage-complete", "full-stage-complete", "failed") and checkpoint_recorded


def resume_result_at_checkpoint(prior_result, capture_path, completed_burn, rate):
    """Fork a prior result at a durable pre-burn or completed-burn checkpoint.

    A completed run may be replayed from an earlier verified capture to validate
    a corrected driver.  Drop later captures, burns, and terminal summaries so
    the new result describes only the history actually preceding the replay.
    """
    result = copy.deepcopy(prior_result)
    source = os.path.realpath(capture_path)
    captures = result.get("snapshots", [])
    index = next((i for i, item in enumerate(captures)
                  if os.path.realpath(item.get("path", "")) == source), None)
    if index is None:
        raise ValueError("resume capture is not recorded in sibling RESULT.json")
    result["snapshots"] = captures[:index + 1]
    if completed_burn is None:
        checkpoint_gmt = capture_gmt(captures[index])
        if any(float(item.get("tig_gmt", float("inf"))) <= checkpoint_gmt
               for item in result.get("burns", [])):
            raise ValueError("a pre-NC1 resume cannot follow a recorded burn")
        result["burns"] = []
        result.pop("targeting", None)
    else:
        burn_index = next((i for i, item in enumerate(result.get("burns", []))
                           if item.get("name") == completed_burn), None)
        if burn_index is None:
            raise ValueError("prior RESULT.json has no completed %s burn" % completed_burn)
        result["burns"] = result.get("burns", [])[:burn_index + 1]
        schedule_index = {name: i for i, name in enumerate(TIG_NAMES)}
        result["targeting"] = [item for item in result.get("targeting", [])
                               if schedule_index.get(item.get("burn"), len(TIG_NAMES))
                               <= schedule_index[completed_burn]]
    result.pop("final", None)
    result.pop("terminal_sample", None)
    result["status"] = "running"
    result.pop("error", None)
    prior_rate = result.get("rate")
    if prior_rate is not None:
        for item in result["burns"]:
            item.setdefault("flight_rate", prior_rate)
    result["resume"] = {"after": completed_burn, "capture": os.path.abspath(capture_path),
                         "rate": rate}
    if prior_rate is not None:
        result["resume"]["prior_rate"] = prior_rate
    result["rate"] = rate
    return result


def completed_status(to_burn):
    """Distinguish the NC1 acceptance test from other partial stages."""
    if to_burn == "NC4":
        return "full-stage-complete"
    if to_burn == "NC1":
        return "short-test-complete"
    return "partial-stage-complete"


def burn_acceptance(designed_magnitude_fts, flown_magnitude_fts):
    """Classify the measurement without preventing later burns from running."""
    if designed_magnitude_fts is None or flown_magnitude_fts is None:
        return {"accepted": False, "reason": "unmeasured"}
    tolerance = max(0.01 * abs(float(designed_magnitude_fts)), 0.3)
    error = abs(float(flown_magnitude_fts) - float(designed_magnitude_fts))
    if error - tolerance > 1e-9:
        return {"accepted": False,
                "reason": "magnitude error %.3f ft/s exceeds %.3f ft/s tolerance"
                          % (error, tolerance),
                "error_fts": error, "tolerance_fts": tolerance}
    return {"accepted": True, "reason": "within per-burn magnitude tolerance",
            "error_fts": error, "tolerance_fts": tolerance}


def execution_acceptance(offset_s, cutoff_verified):
    """Require the command event at its intended epoch and a completed cutoff."""
    if offset_s is None:
        return {"accepted": False, "reason": "command event time unmeasured"}
    if abs(float(offset_s)) > 1.0:
        return {"accepted": False,
                "reason": "command event offset %.3f s exceeds 1.000 s" % float(offset_s)}
    if cutoff_verified is not True:
        return {"accepted": False, "reason": "cutoff not verified before postburn capture"}
    return {"accepted": True, "reason": "EXEC timing and cutoff verified"}


def parse_vehicle_key_trace(text, key="EXEC"):
    """Parse panelO6's vehicle-clock timestamp for a key actually sent."""
    marker = "vehicle-key: " + key.upper()
    for line in text.splitlines():
        if marker not in line:
            continue
        fields = {}
        for word in line.split():
            if "=" in word:
                name, value = word.split("=", 1)
                fields[name] = value
        try:
            if "monotonic" in fields:
                return {"host_monotonic": float(fields["monotonic"])}
            return {name: float(fields[name]) for name in
                    ("vehicle_t", "sample_t", "sample_age_s", "rate")}
        except (KeyError, ValueError):
            continue
    return None


def oms_burn_duration_s(engine, dv_fts, weight_lbf):
    """Estimate OMS valve-on time from the rocket equation and loaded weight."""
    engines = {1: 2, 2: 1, 3: 1}.get(int(engine))
    if engines is None:
        return 0.0
    dv = math.sqrt(sum(float(x) ** 2 for x in dv_fts))
    mass_slugs = float(weight_lbf) / G_FT_S2
    return mass_slugs * OMS_VE_FT_S / (engines * OMS_THRUST_LBF) * (
        1.0 - math.exp(-dv / OMS_VE_FT_S))


def planned_burn_timing(controls_mps_lvlh, initial, schedule):
    """Estimate each planned burn's impulse midpoint and the mass before it.

    Mission Report durations describe the flown burns, but a re-targeted OMS
    vector can be much larger or smaller.  Use the same mass/thrust model as
    the execution measurement and carry estimated OMS propellant use forward
    through the remaining-burn horizon.
    """
    weight = float(initial.get("weight_lbf", 200000.0))
    timings = []
    for i, event in enumerate(schedule):
        dv_mps = controls_mps_lvlh[3 * i:3 * i + 3]
        dv_fts = [float(x) / FT for x in dv_mps]
        magnitude_fts = math.sqrt(sum(x * x for x in dv_fts))
        modeled = oms_burn_duration_s(event["engine"], dv_fts, weight)
        duration = (max(float(event["duration"]), modeled)
                    if event["engine"] != 4 else float(event["duration"]))
        midpoint_offset = (RCS_EFFECTIVE_MIDPOINT_OFFSET_S
                           if event["engine"] == 4 else duration / 2.0)
        timings.append({"burn": event["name"], "weight_lbf": weight,
                        "duration_s": duration,
                        "midpoint_offset_s": midpoint_offset,
                        "midpoint_unix": float(event["unix"]) + midpoint_offset})
        if event["engine"] != 4 and magnitude_fts > 0.0:
            weight *= math.exp(-magnitude_fts / OMS_VE_FT_S)
    return timings


def oms_measurement_gmt(tig_gmt, event_duration_s, modeled_duration_s):
    """Wait for a settled sensed delta-V after the modeled OMS cutoff.

    The sensed accumulator can lag the valve-on estimate by tens of seconds
    in the truth feed.  A 60-second post-cutoff sample is normally sufficient,
    but NC2's recorded +60 sample still included thrust; the impulse stabilized
    around TIG+100..120 seconds.  Keep the normal margin and enforce that
    empirically observed minimum window.
    """
    cutoff_gmt = float(tig_gmt) + max(float(event_duration_s),
                                      float(modeled_duration_s) + OMS_POSTBURN_MARGIN_S)
    return max(cutoff_gmt + 60.0,
               float(tig_gmt) + OMS_MIN_MEASUREMENT_OFFSET_S)


def oms_fire_active(capture_path, engine):
    """Return whether an OMS engine selected for this burn is firing in a capture."""
    if engine == 4:
        return False
    with open(os.path.join(capture_path, "vehdyn.json")) as f:
        values = json.load(f)["vehdyn"]
    flags = {1: (112, 119), 2: (112,), 3: (119,)}.get(int(engine))
    if flags is None or len(values) <= max(flags):
        raise ValueError("capture has no OMS fire-state fields")
    return any(values[i] != 0 for i in flags)


def gmt_poll_delay(remaining, rate):
    """Bound wall sleeps as an accelerated vehicle clock approaches a deadline."""
    rate = max(1.0, float(rate))
    if remaining <= 120.0:
        return min(0.5, max(0.05, remaining / (2.0 * rate)))
    return min(10.0, max(0.5, remaining / (2.0 * rate)))


def extrapolate_truth(truth, elapsed_wall, rate):
    """Estimate the GPC epoch and M50 state between truth-feed updates."""
    out = dict(truth)
    advance = max(0.0, float(elapsed_wall)) * max(0.1, float(rate))
    out["gmt"] = float(truth["gmt"]) + advance
    out["t"] = float(truth["t"]) + advance
    # wait_gmt_precise() intentionally returns just before the deadline.  A
    # TRU1 sample can be several simulated seconds old at 3X; advancing only
    # its clocks makes the reported event state internally inconsistent and
    # rotates the LVLH frame relative to the vehicle state.  Carry r/v forward
    # with the same J2-J4 model used by the ground targeting solution.
    if len(truth.get("r", ())) == 3 and len(truth.get("v", ())) == 3 and advance > 0.0:
        r, v = rndz_start.propagate(truth["r"], truth["v"], advance, True, step=1.0)
        out["r"], out["v"] = r, v
    return out


def next_periodic_snapshot_gmt(current_gmt, snap_every, resume_capture_gmt=None):
    """Keep resumed periodic snapshots anchored to the durable checkpoint."""
    if resume_capture_gmt is not None:
        deadline = float(resume_capture_gmt) + float(snap_every)
        if current_gmt < deadline:
            return deadline
    return float(current_gmt) + float(snap_every)


def next_snapshot_after_event(capture_gmt, next_snap, snap_every, tolerance=60.0):
    """Advance cadence when a required event capture satisfies its deadline."""
    capture_gmt = float(capture_gmt)
    next_snap = float(next_snap)
    snap_every = float(snap_every)
    tolerance = float(tolerance)
    if capture_gmt < next_snap - tolerance:
        return next_snap
    # A nearby or late event capture stands in for the periodic checkpoint.
    # Re-anchor from its actual time so the following interval is one full
    # cadence, including when the capture falls just before its deadline.
    return capture_gmt + snap_every


def unix_of(utc):
    return calendar.timegm(datetime.datetime.fromisoformat(utc).timetuple())


def gmt_of_unix(value):
    d = datetime.datetime.fromtimestamp(value, datetime.timezone.utc)
    return d.timetuple().tm_yday * 86400 + d.hour * 3600 + d.minute * 60 + d.second + d.microsecond * 1e-6


def event_unix(event):
    return calendar.timegm((2011, 1, event["doy"], event["h"], event["m"], int(event["s"]))) + event["s"] % 1


def targeting_state(truth, weight_lbf):
    """Keep truth, attitude, mass, and simulator epoch for full-field prediction."""
    gmt = float(truth["gmt"])
    return {"unix": unix_of("2011-01-01T00:00:00") + gmt - 86400.0,
            "t": float(truth["t"]), "gmt": gmt,
            "r": list(truth["r"]), "v": list(truth["v"]),
            "q": list(truth.get("q", (1.0, 0.0, 0.0, 0.0))),
            "w": list(truth.get("w", (0.0, 0.0, 0.0))),
            "mass_kg": float(weight_lbf) * 0.45359237,
            "weight_lbf": float(weight_lbf)}


def load_target_state(targets, final_utc):
    """Construct the desired final M50 state from rndz_start's J2--J4 line."""
    start = subprocess.run(
        [sys.executable, os.path.join(YAGPC2, "tools", "rndz_start.py"), "start",
         "--targets", targets, "--ti", "2011-05-18T07:38:00", "--start", final_utc,
         "--nc-point=-246,0,1.2"], check=True, capture_output=True, text=True)
    line = next((x for x in start.stdout.splitlines() if x.startswith("YAGPC_VEHDYN_START_REL=")), None)
    if not line:
        raise RuntimeError("rndz_start.py did not emit YAGPC_VEHDYN_START_REL")
    fields = [float(x) for x in line.split("=", 1)[1].split(",")]
    _, rt0, vt0 = rndz_start.read_target(targets, rndz.NORAD_ISS)
    target_epoch, _, _ = rndz_start.read_target(targets, rndz.NORAD_ISS)
    final_time = unix_of(final_utc)
    rt, vt = rndz_start.propagate(rt0, vt0, final_time - target_epoch, True, step=30.0)
    rs, vs = rndz_start.lvc_to_m50(rt, vt, fields[1:7])
    return {"gmt": gmt_of_unix(final_time), "unix": final_time, "r": rs, "v": vs,
            "reference_r": rt, "reference_v": vt,
            "relative_m": fields[1:7], "rndz_start": start.stdout}


def final_relative_state(target, rs, vs):
    """Return actual and desired shuttle-to-ISS LVC state and their error."""
    actual = rndz_start.m50_to_lvc(target["reference_r"], target["reference_v"], rs, vs)
    desired = list(target["relative_m"])
    error = [actual[i] - desired[i] for i in range(6)]
    return actual, desired, error


def truth_at_unix(truth, target_unix):
    """Propagate a sampled truth state to the requested epoch, even for tiny offsets."""
    sampled_unix = unix_of("2011-01-01T00:00:00") + float(truth["gmt"]) - 86400.0
    correction = float(target_unix) - sampled_unix
    aligned = dict(truth)
    if correction != 0.0:
        aligned["r"], aligned["v"] = rndz_start.propagate(
            truth["r"], truth["v"], correction, True, step=1.0)
    aligned["gmt"] = float(truth["gmt"]) + correction
    aligned["t"] = float(truth["t"]) + correction
    return aligned, correction


def optimizer():
    """Load the system SciPy with the system NumPy, avoiding user-site shadows."""
    import site
    user_site = site.getusersitepackages()
    if user_site in sys.path:
        sys.path.remove(user_site)
    import numpy as np
    from scipy.optimize import least_squares
    return np, least_squares


def source_manifest():
    """Identify the exact source revision used to start a flight."""
    def git_value(*args):
        return subprocess.run(["git", "-C", HERE, *args], check=True,
                              capture_output=True, text=True).stdout.strip()
    try:
        return {"repository": git_value("rev-parse", "--show-toplevel"),
                "branch": git_value("rev-parse", "--abbrev-ref", "HEAD"),
                "revision": git_value("rev-parse", "HEAD"),
                "dirty": bool(git_value("status", "--porcelain"))}
    except (OSError, subprocess.CalledProcessError):
        return {"repository": None, "branch": None, "revision": None,
                "dirty": None}


def source_history(prior_result, current_source):
    """Retain source revisions across checkpoint resumes."""
    history = list(prior_result.get("source_history", []))
    complete = prior_result.get("source_history_complete")
    if not history and prior_result.get("source"):
        history.append(prior_result["source"])
        if complete is None:
            complete = not prior_result.get("resume")
    elif not history:
        history.append({"unknown": True})
        complete = False
    if complete is None:
        complete = True
    if not history or history[-1] != current_source:
        history.append(current_source)
    return history, bool(complete)



def burn_setup_gmt(event_gmt, next_snap, snap_every=1800, setup_lead_s=17 * 60,
                   keying_window_s=300, minimum_lead_s=12 * 60,
                   capture_clearance_s=60):
    """Keep a periodic capture clear of the burn's long keying sequence."""
    setup = float(event_gmt) - float(setup_lead_s)
    deadline = float(next_snap)
    interval = float(snap_every)
    if interval <= 0:
        raise ValueError("snap interval must be positive")
    while deadline <= setup:
        deadline += interval
    previous = deadline - interval
    clearance = float(capture_clearance_s)
    latest_setup = float(event_gmt) - float(minimum_lead_s)
    if setup < deadline <= setup + float(keying_window_s):
        candidate = deadline + clearance
        if candidate <= latest_setup:
            return candidate
        # If there is not enough time after the next deadline, start after
        # the previous periodic capture instead of keying across either one.
        candidate = previous + clearance
        if candidate <= latest_setup:
            return candidate
    if setup - float(keying_window_s) <= previous <= setup:
        candidate = setup + clearance
        if candidate <= latest_setup:
            return candidate
    return setup

def require_resume_setup_lead(current_gmt, setup_gmt, burn_name):
    """Refuse a checkpoint that leaves no time for the next burn's load sequence."""
    if float(current_gmt) > float(setup_gmt):
        raise ValueError(
            "resume capture is after %s setup (capture GMT %.3f, setup GMT %.3f); "
            "choose an earlier checkpoint" %
            (burn_name, float(current_gmt), float(setup_gmt)))


def snapshot_checkpoint_gmt(args, logs):
    """Return the recorded checkpoint epoch used to anchor resumed cadence."""
    source = getattr(args, "resume_from", None)
    if source:
        result_path = os.path.join(os.path.dirname(os.path.abspath(source)), "RESULT.json")
        try:
            with open(result_path) as f:
                result = json.load(f)
            match = next((item for item in result.get("snapshots", [])
                          if os.path.realpath(item.get("path", "")) == os.path.realpath(source)), None)
            if match is not None:
                return capture_gmt(match)
        except (OSError, ValueError, TypeError):
            pass
        try:
            return capture_gmt(json.load(open(os.path.join(source, "capture.json"))))
        except (OSError, ValueError, TypeError):
            pass
    return None


class FD13(rndz.Rendezvous):
    def __init__(self, args):
        os.makedirs(args.logs, exist_ok=True)
        super().__init__(args)
        current_source = source_manifest()
        self.result = {"status": "running", "tape": args.tape, "rate": args.rate,
                       "from_launch": args.from_launch, "burns": [], "snapshots": [],
                       "source": current_source, "source_history": [current_source],
                       "source_history_complete": True,
                       "errors": []}
        if args.resume_from:
            source = os.path.abspath(args.resume_from)
            prior_path = os.path.join(os.path.dirname(source), "RESULT.json")
            if not os.path.isdir(source):
                raise FileNotFoundError("FD13 resume capture not found: " + source)
            if not all(os.path.isfile(os.path.join(source, x))
                       for x in ("vehicle.json", "vehdyn.json")):
                raise ValueError("FD13 resume capture needs vehicle.json and vehdyn.json")
            with open(prior_path) as f:
                prior_result = json.load(f)
            completed = args.resume_after
            capture = next((s for s in prior_result.get("snapshots", [])
                            if os.path.realpath(s.get("path", "")) == os.path.realpath(source)), None)
            burn = next((b for b in prior_result.get("burns", [])
                         if b.get("name") == completed), None) if completed else None
            if completed is None:
                recoverable = capture is not None and not prior_result.get("errors")
            else:
                recoverable = (capture is not None and burn is not None
                               and not prior_result.get("errors")
                               and burn.get("truth_after_burn_plus_60") is not None)
            if not can_resume_result(prior_result.get("status"), completed, recoverable):
                raise ValueError("FD13 resume requires a recorded checkpoint before NC1 or after a completed burn")
            if capture is None:
                raise ValueError("resume capture is not recorded in sibling RESULT.json")
            if completed and burn is None:
                raise ValueError("prior RESULT.json has no completed %s burn" % completed)
            if completed and capture.get("gmt", 0) < burn["tig_gmt"] + burn["duration_s"]:
                raise ValueError("resume capture predates completed %s cutoff" % completed)
            if completed is None and capture.get("gmt", 0) >= gmt_of_unix(event_unix(TIGS[0])):
                raise ValueError("a pre-NC1 resume capture must precede the NC1 TIG")
            if completed and oms_fire_active(source, burn.get("engine_selector_item", 4)):
                raise ValueError("resume capture is during the %s OMS burn" % completed)
            self.result = resume_result_at_checkpoint(prior_result, source, completed, args.rate)
            history, complete = source_history(prior_result, current_source)
            self.result["source_history"] = history
            self.result["source_history_complete"] = complete
            self.result["source"] = current_source
        self.result["rate"] = args.rate
        self.target = load_target_state(args.targets, START_UTC)
        with open(os.path.join(args.logs, "rndz-start.txt"), "w") as f:
            f.write(self.target["rndz_start"])
        self.save_result()

    def say(self, text):
        print("fly_fd13: %s" % text, flush=True)
        self.checklog.write("%s %s\n" % (time.strftime("%H:%M:%S"), text))
        self.checklog.flush()

    def vehicle_key_trace(self, key):
        path = os.path.join(self.a.logs, "logs", "panel.log")
        try:
            with open(path, "rb") as log_file:
                log_file.seek(getattr(self, "played_at", 0))
                text = log_file.read().decode("utf-8", "replace")
        except OSError:
            return None
        return parse_vehicle_key_trace(text, key)

    def save_result(self):
        path = os.path.join(self.a.logs, "RESULT.json")
        tmp = path + ".tmp"
        with open(tmp, "w") as f:
            json.dump(self.result, f, indent=2)
            f.write("\n")
        os.replace(tmp, path)

    def start(self, resume=None):
        if self.a.from_launch:
            # fly_sts134 starts the pad/ascent simulator with the same combined
            # volume.  The RNDZ target and MET streams are supplied here.
            os.environ.pop("YAGPC_VEHDYN_START_REL", None)
            for k, v in self.rndz_environment().items():
                os.environ[k] = v
            return fly_sts134.Flight.start(self, None)
        env = dict(os.environ, **self.rndz_environment(), PYTHONUNBUFFERED="1")
        env.pop("YAGPC_VEHDYN_START_REL", None)
        cmd = [sys.executable, "-u", os.path.join(PANEL, "simulatePASS.py"), "--gpcs", "1",
               "--crts", str(self.a.crts), "--tape", self.a.tape, "--no-wait-user", "--size", "384",
               "--port-base", str(self.base), "--logs", os.path.join(self.a.logs, "logs"),
               "--snapshot-dir", self.a.logs, "--duration", "200000", "--rhc", "lh",
               "--input", "virtual",
               "--snapshot-resume", resume, "--no-portview"]
        if self.a.rate != 1:
            cmd += ["--rt-factor", "%g" % self.a.rate]
        outp = os.path.join(self.a.logs, "simulatePASS.out")
        self.out = open(outp, "w")
        self.ears = rndz.Ears(self.base)
        self.proc = subprocess.Popen(cmd, env=env, stdout=self.out, stderr=subprocess.STDOUT,
                                     stdin=subprocess.DEVNULL, cwd=PANEL)
        self.leave_nothing_running()
        self.wait_file(outp, "session commands on port", 180)
        time.sleep(5)
        self.cw_start()

    def rndz_environment(self):
        return {"NSTS_NO_AUDIO": "1", "NSTS_ANNOUNCE_ROWS": "all", "NSTS_PANEL_OPS": "GNC,2",
                "YAGPC_MDM_DEVICES": "1", "YAGPC_VEHDYN": "1", "YAGPC_OMS_ARMED": "1",
                "YAGPC_VEHDYN_ORBITER_KG": str(fly_sts134.FL["orbiter_kg"]),
                "YAGPC_VEHDYN_STATELOG": "10", "YAGPC_VEHDYN_TARGETS": self.a.targets,
                "YAGPC_RNP": "2011,136", "YAGPC_MTU_MET_EPOCH": "%.3f" % rndz.MET_ZERO_UNIX}

    def resume_copy(self):
        if self.a.from_launch:
            return None
        source = self.a.resume_from or self.a.ops2
        if not os.path.isdir(source):
            label = "FD13 resume capture" if self.a.resume_from else "OPS2 capture"
            raise FileNotFoundError(label + " directory not found: " + source)
        label = ("after-" + self.a.resume_after if self.a.resume_after else "checkpoint") if self.a.resume_from else "ops2"
        dst = os.path.join(self.a.logs, "resume-" + label)
        if os.path.exists(dst):
            raise FileExistsError("refusing to overwrite run's resume copy: " + dst)
        shutil.copytree(source, dst)
        return dst

    def ascent_to_ops2(self):
        fly_sts134.FL["name"] = "sts134"
        phases = fly_sts134.PHASES[:fly_sts134.PHASES.index("OPS2") + 1]
        for phase in phases:
            self.say("== ascent %s" % phase)
            # Several phase names (IPL, UPLINK) also exist on Rendezvous;
            # explicitly dispatch the ascent implementation.
            getattr(fly_sts134.Flight, phase.lower())(self)
            fly_sts134.Flight.snapshot(self, phase.lower())
        fly_sts134.FL["name"] = "sts134r"
        self.ears = rndz.Ears(self.base)
        self.cw_start()

    def trajectory(self, controls, initial, schedule, final_time, step=45.0):
        np, _ = optimizer()
        r, v, now = list(initial["r"]), list(initial["v"]), initial["unix"]
        q = list(initial.get("q", (1.0, 0.0, 0.0, 0.0)))
        # Orbital guidance holds attitude through each coast; free-integrating
        # the instantaneous body rates would produce hours of fictitious tumble.
        w = [0.0, 0.0, 0.0]
        mass_kg = float(initial.get("mass_kg", 113000.0))
        propagator = getattr(self, "_fd13_propagator", None)
        if propagator is None:
            propagator = fd13_propagator.FD13Propagator(initial, rndz.RNP)
            self._fd13_propagator = propagator
        timings = planned_burn_timing(controls, initial, schedule)
        for i, event in enumerate(schedule):
            center = timings[i]["midpoint_unix"]
            if center <= now:
                continue
            # PASS interprets the loaded LVLH vector in the orbital frame at
            # TIG.  Keep that inertial direction fixed while placing the
            # impulse at its modeled center; rotating the axes to the
            # midpoint creates a several-ft/s command error on long burns.
            frame_epoch = float(event["unix"])
            sim_time = float(initial["t"]) + now - float(initial["unix"])
            r_frame, v_frame, q, _ = propagator.advance(
                r, v, sim_time, frame_epoch - now, q, w, mass_kg)
            rows = rndz_start.lvlh_rows(r_frame, v_frame)
            r, v, q, _ = propagator.advance(
                r_frame, v_frame, sim_time + frame_epoch - now,
                center - frame_epoch, q, w, mass_kg)
            now = center
            dv = controls[3 * i:3 * i + 3]
            dv_mps = math.sqrt(sum(float(x) ** 2 for x in dv))
            isp_s = 270.0 if event["engine"] == 4 else 316.0
            mass_kg *= math.exp(-dv_mps / (9.80665 * isp_s))
            inertial = [sum(rows[k][j] * dv[k] for k in range(3)) for j in range(3)]
            v = [v[j] + inertial[j] for j in range(3)]
        if final_time <= now:
            raise ValueError("final targeting time must follow all included burn midpoints")
        sim_time = float(initial["t"]) + now - float(initial["unix"])
        r, v, q, _ = propagator.advance(r, v, sim_time, final_time - now,
                                        q, w, mass_kg)
        return np.asarray(r + v)

    def wait_gmt(self, gmt):
        """Wait close to a requested epoch, including at accelerated rates.

        Flight.wait_gmt() may sleep 30 wall seconds per poll.  At rate 3 that
        can put a TIG-relative capture or the final 06:10 state as much as 90
        simulated seconds late.  Shorten the polling interval as the target
        approaches so those measurements remain tied to their requested
        epochs.  Inside the final two minutes, poll at most every half wall second:
        the vehicle truth feed is sampled every 10 simulated seconds, and a
        long sleep near TIG can otherwise miss the EXEC window under load.
        """
        while True:
            truth = self.truth()
            remaining = gmt - truth["gmt"]
            if remaining <= 0:
                return truth
            time.sleep(gmt_poll_delay(remaining, self.a.rate))

    def wait_gmt_precise(self, gmt):
        """Predict the deadline between bus truth samples for the RCS THC start.

        ``truth()`` can wait up to three wall seconds for a multicast sample.
        At 3X that blocking read alone can put the first THC pulse roughly nine
        simulated seconds past TIG, despite short sleeps in ``wait_gmt``.
        Once the next truth sample is within four rate-scaled seconds, use the
        measured vehicle-clock rate to sleep to the epoch and return an
        interpolated state without another blocking read.
        """
        previous = None
        nominal_rate = max(1.0, float(self.a.rate))
        while True:
            truth = self.truth()
            sampled_wall = time.monotonic()
            remaining = float(gmt) - truth["gmt"]
            if remaining <= 0.0:
                return truth

            rate = nominal_rate
            if previous is not None:
                prev_truth, prev_wall = previous
                elapsed = sampled_wall - prev_wall
                delta = truth["gmt"] - prev_truth["gmt"]
                if elapsed > 0.05 and delta > 0.0:
                    observed = delta / elapsed
                    if 0.1 <= observed <= 10.0:
                        rate = observed

            if remaining <= 4.0 * rate:
                wall_to_deadline = remaining / rate
                time.sleep(max(0.0, wall_to_deadline - 0.10))
                return extrapolate_truth(truth, time.monotonic() - sampled_wall, rate)

            previous = (truth, sampled_wall)
            time.sleep(gmt_poll_delay(remaining, nominal_rate))

    def design(self, current, schedule, prior=None):
        """Weighted multiple-burn differential corrector in inertial M50."""
        np, least_squares = optimizer()
        count = len(schedule)
        scales = np.repeat(np.asarray([DV_SCALES_FPS[e["index"]] * FT for e in schedule]), 3)
        bounds = np.repeat(np.asarray([DV_BOUNDS_FPS[e["index"]] * FT for e in schedule]), 3)
        target = np.asarray(self.target["r"] + self.target["v"])
        scale_state = np.asarray(targeting_state_scales(schedule))
        if prior is None or len(prior) != len(scales):
            prior = np.zeros(len(scales))
        else:
            prior = np.asarray(prior, dtype=float)
        # Older saved plans can predate the engine-specific bounds.
        prior = np.clip(prior, -bounds, bounds)
        def residual(u):
            end = self.trajectory(u, current, schedule, self.target["unix"])
            return np.r_[(end - target) / scale_state, (u - prior) / scales * 0.01]
        solution = least_squares(residual, prior, bounds=(-bounds, bounds), max_nfev=600, diff_step=1e-4,
                                 x_scale=scales, xtol=1e-9, ftol=1e-9, gtol=1e-9)
        miss = self.trajectory(solution.x, current, schedule, self.target["unix"]) - target
        controls = [solution.x[3 * i:3 * i + 3].tolist() for i in range(count)]
        return {"controls_mps_lvlh": controls, "position_miss_m": float(np.linalg.norm(miss[:3])),
                "velocity_miss_mps": float(np.linalg.norm(miss[3:])), "cost": float(solution.cost),
                "trajectory_model": "physics.c EGM96 4x4 with PASS RNP/rotation, Cd=2.2 drag at fixed measured attitude, OMS/RCS rocket-equation mass updates",
                "position_miss_within_1000_ft": bool(np.linalg.norm(miss[:3]) <= 1000 * FT),
                "control_bounds_fts": [DV_BOUNDS_FPS[e["index"]] for e in schedule],
                "planned_burn_timing": planned_burn_timing(solution.x, current, schedule),
                # SciPy's success flag means only that its termination
                # conditions were met.  A bounded solve can terminate cleanly
                # while still being far from the rendezvous target, so keep
                # optimizer convergence separate from flight acceptance.
                "evaluations": int(solution.nfev),
                "optimizer_converged": bool(solution.success)}

    def coast_to(self, gmt, next_snap, snap_every):
        while True:
            now = self.truth()["gmt"]
            if now >= gmt:
                return next_snap
            due = min(gmt, next_snap)
            waited = self.wait_gmt_precise(due)
            now = waited["gmt"]
            if due == next_snap and now >= next_snap - 1.0 and now < gmt + 1e-6:
                name = "coast-%03d" % (len(self.result["snapshots"]) + 1)
                captured_gmt = self.take_snapshot(name)
                next_snap = float(captured_gmt) + snap_every

    def take_snapshot(self, name):
        path = os.path.join(self.a.logs, "sts134r-" + name)
        if os.path.exists(path):
            raise FileExistsError("refusing to overwrite snapshot " + path)
        self._snapshot(name)
        if not os.path.isfile(os.path.join(path, "vehicle.json")):
            raise RuntimeError("snapshot did not produce vehicle.json: " + path)
        with open(os.path.join(path, "capture.json")) as capture_file:
            saved_gmt = capture_gmt(json.load(capture_file))
        if saved_gmt is None:
            raise RuntimeError("snapshot did not record a vehicle capture epoch: " + path)
        self.result["snapshots"].append({"name": name, "path": path, "gmt": saved_gmt})
        self.save_result()
        return self.result["snapshots"][-1]["gmt"]

    def load_burn(self, event, dv):
        name, tig = event["name"], event["gmt"]
        met = (event["unix"] - rndz.MET_ZERO_UNIX)
        day, hour, minute, sec = rndz.dhms_f(met)
        values = [x / FT for x in dv]
        target_time = ("+3     keys ITEM 1 0 + %d + %s + %s + %s EXEC\n"
                       % (day, " ".join("%d" % hour),
                          " ".join("%d" % minute), " ".join("%.1f" % sec)))
        target_dv = "+4     keys ITEM 1 9 %s %s %s EXEC\n" % tuple(
            rndz.keys_num(x, "%.1f") for x in values)
        wt = self.orbiter_lb()
        event["orbiter_weight_lbf"] = float(wt)
        if event["engine"] != 4:
            trims = "+4     keys ITEM 6 + 0 . 4 + 5 . 2 - 5 . 2 EXEC\n"
            if event["engine"] == 1:
                trims = "+4     keys ITEM 6 + 0 . 4 - 5 . 7 + 5 . 7 EXEC\n"
            trim_wt = trims + "+4     keys ITEM 9 + %s EXEC\n" % " ".join("%d" % round(wt))
        else:
            # CC 9-3 still requires the orbiter weight for RCS targeting;
            # it omits the one-engine OMS trim entries, not ITEM 9.
            trim_wt = "+4     keys ITEM 9 + %s EXEC\n" % " ".join("%d" % round(wt))
        dap = ("+3     dap c3 a\n+2     dap c3 auto\n+2     dap c3 alt\n"
               if event["engine"] != 4 else
               "+3     dap c3 a\n+2     dap c3 auto\n+2     dap c3 pri\n"
               "+2     dap c3 x_norm\n+2     dap c3 y_norm\n+2     dap c3 z_norm\n")
        script = ("+1     keys OPS 2 0 2 PRO\n"
                  "wait crt 1 title 2021/ timeout 120\n"
                  "+3     keys RESUME\n"
                  "wait crt 1 title MNVR EXEC timeout 60\n"
                  "+3     keys ITEM %d EXEC\n" % event["engine"]
                  + trim_wt + target_time
                  # MM 202 reinitializes the MNVR display when TGT 10
                  # computes T1.  Reassert the engine selection, trims, and
                  # weight after that compute, as tiburn() does, before LOAD.
                  + "+3     keys ITEM %d EXEC\n" % event["engine"]
                  + trim_wt + target_dv
                  + "+4     keys ITEM 2 2 EXEC\n+4     keys ITEM 2 3 EXEC\n"
                  + dap)
        if event["engine"] != 4:
            script += ("+3     keys ITEM 2 7 EXEC\n"
                       "+3     dap c3 x_norm\n+2     dap c3 y_norm\n+2     dap c3 z_norm\n")
        self.play(script, name.lower() + "-load")
        self.script_done(name.lower() + "-load", 600)

    def execute_and_measure(self, event, dv, pre_name):
        name, tig = event["name"], event["gmt"]
        values = [x / FT for x in dv]
        rcs_vgo_residual = None
        rcs_null_start_gmt = None
        rcs_null_end_gmt = None
        exec_key_trace = None
        exec_event_gmt = None
        exec_offset_s = None
        if event["engine"] == 4:
            # Read the loaded VGO before TIG so a missing live downlist cannot
            # force a GPC snapshot between the deadline and the first THC
            # dispatch.  A snapshot can pause the flight long enough to make
            # the first RCS pulse miss its TIG timing gate.
            initial_vgo = None
            logs = getattr(self.a, "logs", None)
            if logs:
                pre_capture = os.path.join(logs, "sts134r-" + pre_name)
                pre_mem = rndz.PassMemory.from_capture(pre_capture)
                if pre_mem is not None:
                    initial_vgo = dict(zip("xyz", pre_mem.svec(pre_mem.A["VGO_BODY"])))
            # CC 9-3 flies the loaded VGO with the THC at TIG.  DAP A/AUTO/
            # PRI/NORM was selected during the early burn load; repeating it
            # at TIG-30 can finish after TIG at accelerated rates.
            burn_state = self.wait_gmt_precise(tig)
            self.say("%s: RCS VGO null begins at TIG GMT %.1f; designed LVLH DV "
                     "%+.2f %+.2f %+.2f ft/s (%.2f total)"
                     % (name, burn_state["gmt"], *values,
                        math.sqrt(sum(x * x for x in values))))
            rcs_null_start_gmt = float(burn_state["gmt"])
            if initial_vgo is None:
                rcs_vgo_residual = self.null_vgo(name.lower(), RCS_VGO_NULL_PASSES)
            else:
                rcs_vgo_residual = self.null_vgo(name.lower(), RCS_VGO_NULL_PASSES,
                                                  initial_vgo=initial_vgo)
            rcs_null_end_gmt = float(self.truth()["gmt"])
            self.say("%s: RCS VGO null ended at GMT %.1f (+%.1f s)"
                     % (name, rcs_null_end_gmt, rcs_null_end_gmt - rcs_null_start_gmt))
            exec_state = burn_state
            exec_event_gmt = rcs_null_start_gmt
            exec_offset_s = rcs_null_start_gmt - tig
        else:
            # Keep the truth sample that met the deadline.  A second multicast
            # read can block for several wall seconds if the feed is quiet,
            # enough to let the vehicle clock pass the programmed TIG at rate 2.
            exec_state = self.wait_gmt(tig - 15.0)
            self.play("+0     keys EXEC\n", name.lower() + "-exec")
            self.script_done(name.lower() + "-exec", 120)
            exec_key_trace = self.vehicle_key_trace("EXEC")
            if exec_key_trace is not None and "vehicle_t" in exec_key_trace:
                exec_event_gmt = exec_state["gmt"] + (
                    exec_key_trace["vehicle_t"] - exec_state["t"])
                exec_offset_s = exec_event_gmt - (tig - 15.0)
            self.say("%s: EXEC deadline sample at GMT %.3f (%+.3f s from TIG), designed LVLH DV "
                     "%+.2f %+.2f %+.2f ft/s (%.2f total)"
                     % (name, exec_state["gmt"], exec_state["gmt"] - tig, *values,
                        math.sqrt(sum(x * x for x in values))))
            if exec_key_trace is None:
                self.say("%s: actual EXEC key event has no panel trace" % name)
            elif "vehicle_t" not in exec_key_trace:
                self.say("%s: EXEC key send time recorded; vehicle-clock mapping deferred until after burn"
                         % name)
            else:
                self.say("%s: actual EXEC key event GMT %.3f (%+.3f s from TIG-15); "
                         "truth sample age %.3f s at %.3f simulated s/s"
                         % (name, exec_event_gmt, exec_offset_s,
                            exec_key_trace["sample_age_s"], exec_key_trace["rate"]))
        modeled_oms_s = oms_burn_duration_s(
            event["engine"], values, event.get("orbiter_weight_lbf", 200000.0))
        if event["engine"] == 4:
            # VGO nulling ends at a truth-dependent epoch; start the margin
            # from that actual completion rather than the historical pad duration.
            cutoff_gmt = rcs_null_end_gmt
        else:
            cutoff_gmt = tig + max(event["duration"],
                                   modeled_oms_s + OMS_POSTBURN_MARGIN_S)
        measurement_gmt = (oms_measurement_gmt(tig, event["duration"], modeled_oms_s)
                           if event["engine"] != 4 else cutoff_gmt + 60.0)
        capture_gmt_target = measurement_gmt
        terminal_gmt = self.target.get("gmt") if name == "NC4" else None
        handoff_min_gmt = tig + event["duration"] + 120.0 if name == "NC4" else None
        if handoff_min_gmt is not None:
            capture_gmt_target = max(capture_gmt_target, handoff_min_gmt)
        if terminal_gmt is not None and terminal_gmt < capture_gmt_target:
            # A large NC4 correction can keep OMS firing past 06:10. Preserve
            # the actual terminal truth before waiting for a safe postburn handoff.
            self.wait_gmt(terminal_gmt)
            terminal_state = self.truth()
            terminal_snapshot_gmt = self.take_snapshot("terminal-06-10")
            terminal_path = os.path.join(self.a.logs, "sts134r-terminal-06-10")
            if os.path.isfile(os.path.join(terminal_path, "vehdyn.json")):
                terminal_state = snapshot_truth(terminal_path)
            self.result["terminal_sample"] = {
                "gmt": terminal_state["gmt"] if terminal_state.get("gmt") is not None else terminal_snapshot_gmt,
                "truth": terminal_state,
                "snapshot": "terminal-06-10",
            }
            self.save_result()
        self.wait_gmt(capture_gmt_target)
        post_name = "nc4-plus-2-min" if name == "NC4" else name.lower() + "-plus-60"
        post_state = self.truth()
        oms_probe_names = []
        oms_cutoff_verified = None
        if event["engine"] != 4:
            # A modeled cutoff plus a fixed delay can still sample while the
            # selected OMS engine is firing. The old NC2 +60 captures were
            # TIG+76..80 s and still had the right engine on, understating
            # sensed DV. Probe the saved valve state and move the measurement
            # forward in short increments until thrust has actually stopped.
            for attempt in range(1, 41):
                probe_name = "%s-oms-probe-%02d" % (name.lower(), attempt)
                probe_gmt = self.take_snapshot(probe_name)
                if probe_gmt is None:
                    probe_gmt = self.truth()["gmt"]
                oms_probe_names.append(probe_name)
                probe_path = os.path.join(self.a.logs, "sts134r-" + probe_name)
                if not oms_fire_active(probe_path, event["engine"]):
                    oms_cutoff_verified = True
                    break
                if attempt == 40:
                    raise RuntimeError("%s OMS still firing after ten minutes of cutoff checks" % name)
                self.say("%s: OMS still firing at GMT %.1f; checking again in 15 s"
                         % (name, probe_gmt))
                post_state = self.wait_gmt(probe_gmt + 15.0)
        post_gmt = self.take_snapshot(post_name)
        if post_gmt is None:
            post_gmt = post_state["gmt"]
        if exec_key_trace is not None and "host_monotonic" in exec_key_trace:
            vehicle_clock = self.ears.vehicle_clock_at(exec_key_trace["host_monotonic"])
            if vehicle_clock is not None:
                exec_key_trace = vehicle_clock
                exec_event_gmt = vehicle_clock["vehicle_gmt"]
                exec_offset_s = exec_event_gmt - (tig - 15.0)
                self.say("%s: actual EXEC key event GMT %.3f (%+.3f s from TIG-15); "
                         "truth sample age %.3f s at %.3f simulated s/s"
                         % (name, exec_event_gmt, exec_offset_s,
                            vehicle_clock["sample_age_s"], vehicle_clock["rate"]))
            else:
                self.say("%s: panel EXEC trace has no bracketing vehicle-clock samples" % name)
        before = self.vehdyn_capture(pre_name)
        after = self.vehdyn_capture(post_name)
        flown = None
        if before and after:
            flown = [(after["sensed"][i] - before["sensed"][i]) / FT for i in range(3)]
        oms_state = None
        if before and after and "oms_s" in before and "oms_s" in after:
            oms_state = {
                "fire_before": list(before.get("oms_fire", ())),
                "fire_after": list(after.get("oms_fire", ())),
                "on_seconds_before": list(before["oms_s"]),
                "on_seconds_after": list(after["oms_s"]),
                "on_seconds_delta": [after["oms_s"][i] - before["oms_s"][i]
                                     for i in range(2)],
                "propellant_before_kg": list(before.get("oms_propellant_kg", ())),
                "propellant_after_kg": list(after.get("oms_propellant_kg", ())),
            }
            if ("oms_propellant_kg" in before and
                    "oms_propellant_kg" in after):
                oms_state["propellant_delta_kg"] = [
                    after["oms_propellant_kg"][i] - before["oms_propellant_kg"][i]
                    for i in range(2)]
        item = {"name": name, "tig_gmt": tig, "tig_unix": event["unix"], "duration_s": event["duration"],
                "source": self.result.get("source"),
                "engine_selector_item": event["engine"], "designed_dv_lvlh_mps": dv,
                "designed_dv_lvlh_fts": values,
                "designed_magnitude_fts": math.sqrt(sum(x * x for x in values)),
                "flown_sensed_dv_m50_fts": flown,
                "flown_magnitude_fts": None if flown is None else math.sqrt(sum(x*x for x in flown)),
                "modeled_oms_burn_duration_s": modeled_oms_s,
                "oms_state": oms_state,
                "measurement_target_gmt": measurement_gmt,
                "postburn_capture_target_gmt": capture_gmt_target,
                "measurement_offset_after_tig_s": post_gmt - tig,
                "exec_key_trace": exec_key_trace,
                "exec_event_gmt": exec_event_gmt,
                "exec_offset_from_intended_s": exec_offset_s,
                "oms_cutoff_verified": oms_cutoff_verified,
                "oms_cutoff_probe_snapshots": oms_probe_names,
                "truth_at_exec": exec_state,
                "truth_after_burn_plus_60": post_state,
                "pre_snapshot": pre_name, "post_snapshot": post_name}
        if event["engine"] == 4:
            item["rcs_null_start_gmt"] = rcs_null_start_gmt
            item["rcs_null_end_gmt"] = rcs_null_end_gmt
            item["rcs_null_elapsed_s"] = (None if rcs_null_end_gmt is None else
                                          rcs_null_end_gmt - rcs_null_start_gmt)
            item["rcs_vgo_residual_fts"] = (
                None if rcs_vgo_residual is None else
                [float(rcs_vgo_residual[axis]) for axis in "xyz"])
            item["rcs_vgo_trim_accepted"] = (
                rcs_vgo_residual is not None and
                all(abs(float(rcs_vgo_residual[axis])) < rndz.TRIM_TOL_FPS
                    for axis in "xyz"))
        rate = getattr(getattr(self, "a", None), "rate", None)
        if rate is not None:
            item["flight_rate"] = rate
        self.result["burns"].append(item)
        cutoff_verified = (oms_cutoff_verified is True if event["engine"] != 4 else
                           rcs_null_end_gmt is not None and post_gmt >= rcs_null_end_gmt)
        item["execution_acceptance"] = execution_acceptance(exec_offset_s, cutoff_verified)
        item["acceptance"] = burn_acceptance(
            item["designed_magnitude_fts"], item["flown_magnitude_fts"])
        if not item["execution_acceptance"]["accepted"]:
            item["acceptance"]["accepted"] = False
            item["acceptance"]["reason"] = item["execution_acceptance"]["reason"]
        self.save_result()
        if not item["acceptance"]["accepted"]:
            self.say("%s: burn outside acceptance (%s); proceeding from the flown truth state"
                     % (name, item["acceptance"]["reason"]))
        return post_gmt

    def run_fd13(self):
        schedule = []
        for i, raw in enumerate(TIGS):
            e = dict(raw)
            e["index"] = i
            e["unix"] = event_unix(raw)
            e["gmt"] = gmt_of_unix(e["unix"])
            schedule.append(e)
        current = self.truth()
        resume_capture_gmt = None
        if self.a.resume_from:
            capture_path = os.path.join(self.a.resume_from, "capture.json")
            with open(capture_path) as f:
                resume_capture_gmt = capture_gmt(json.load(f))
        next_snap = next_periodic_snapshot_gmt(
            current["gmt"], self.a.snap_every, resume_capture_gmt)
        final_index = [e["name"] for e in schedule].index(self.a.to)
        first_index = first_burn_index(self.a.resume_after)
        if first_index > 0:
            completed = schedule[first_index - 1]
            if current["gmt"] < completed["gmt"] + completed["duration"]:
                raise ValueError("resume capture is before %s cutoff" % completed["name"])
        targeting = targeting_burns(schedule, first_index)
        active = execution_burns(schedule, first_index, final_index)
        prior, seed = select_targeting_prior(
            self.result, schedule, first_index, self.a.targeting_seed)
        if seed is not None:
            self.result["targeting_seed"] = {key: seed[key] for key in
                                               ("path", "sha256", "burn", "source", "provenance")}
            self.save_result()
        if not active:
            raise ValueError("resume-after must precede the requested --to burn")
        for i, event in enumerate(active):
            self.say("coasting to %s setup, GMT %.1f" % (event["name"], event["gmt"] - 17 * 60))
            next_snap = self.coast_to(event["gmt"] - 17 * 60, next_snap, self.a.snap_every)
            tr = self.truth()
            initial = targeting_state(tr, self.orbiter_lb())
            # A partial run executes only through --to, but keeps all
            # remaining burns in the ground-targeting horizon so even NC2 by
            # itself aims toward the eventual NC4 handoff.
            remaining = remaining_burns(targeting, i)
            seed = prior
            self.say("%s: truth-state ground solve for %d remaining burn(s)" % (event["name"], len(remaining)))
            plan = self.design(initial, remaining, seed)
            prior = [x for vector in plan["controls_mps_lvlh"] for x in vector]
            dv = plan["controls_mps_lvlh"][0]
            event["targeting"] = plan
            self.say("%s: predicted terminal position miss %.2f ft, velocity miss %.4f ft/s; nfev %d"
                     % (event["name"], plan["position_miss_m"] / FT,
                        plan["velocity_miss_mps"] / FT, plan["evaluations"]))
            if not plan["position_miss_within_1000_ft"]:
                self.say("%s: target miss exceeds 1000 ft; continuing the scheduled flight for terminal-state measurement"
                         % event["name"])
            self.result.setdefault("targeting", []).append({
                "burn": event["name"], "start_gmt": tr["gmt"],
                "controls_mps_lvlh": plan["controls_mps_lvlh"],
                "planned_burn_timing": plan["planned_burn_timing"],
                "predicted_terminal_position_miss_ft": plan["position_miss_m"] / FT,
                "predicted_terminal_velocity_miss_fts": plan["velocity_miss_mps"] / FT,
                "position_miss_within_1000_ft": plan["position_miss_within_1000_ft"],
                "optimizer_converged": plan["optimizer_converged"],
                "target_within_1000_ft": plan["position_miss_within_1000_ft"],
                "solver_evaluations": plan["evaluations"],
            })
            self.save_result()
            # Program LOAD/TIMER at the checklist setup point (TIG-17 min);
            # the keypad script takes long enough that starting it at TIG-60
            # would consume the EXEC margin and let the burn expire almost
            # immediately.  The TIG-60 snapshot must contain the loaded state.
            self.load_burn(event, dv)
            next_snap = self.coast_to(event["gmt"] - 60.0, next_snap, self.a.snap_every)
            pre_name = event["name"].lower() + "-minus-60"
            pre_gmt = self.take_snapshot(pre_name)
            next_snap = next_snapshot_after_event(pre_gmt, next_snap, self.a.snap_every)
            post_gmt = self.execute_and_measure(event, dv, pre_name)
            next_snap = next_snapshot_after_event(post_gmt, next_snap, self.a.snap_every)
            # Re-target at every burn from the actual postburn truth.
            latest = self.truth()
            initial = targeting_state(latest, self.orbiter_lb())
            if i + 1 < len(active):
                remaining = remaining_burns(targeting, i + 1)
                next_plan = self.design(initial, remaining, prior[3:])
                prior = [x for vector in next_plan["controls_mps_lvlh"] for x in vector]
        if self.a.to == "NC4":
            handoff_gmt = event_unix(active[-1])
            handoff_gmt = gmt_of_unix(handoff_gmt + active[-1]["duration"] + 120.0)
            handoff_gmt = max(handoff_gmt, self.result["burns"][-1].get(
                "postburn_capture_target_gmt", handoff_gmt))
            next_snap = self.coast_to(handoff_gmt, next_snap, self.a.snap_every)
            if not any(s.get("name") == "nc4-plus-2-min" for s in self.result["snapshots"]):
                self.take_snapshot("nc4-plus-2-min")
            final = self.target["gmt"]
            terminal_sample = self.result.get("terminal_sample")
            if terminal_sample is None:
                next_snap = self.coast_to(final, next_snap, self.a.snap_every)
                tr = self.truth()
            else:
                tr = terminal_sample["truth"]
            final_truth, epoch_correction = truth_at_unix(tr, self.target["unix"])
            relative, desired, error = final_relative_state(
                self.target, final_truth["r"], final_truth["v"])
            desired_ft = [x / FT for x in desired]
            relative_ft = [x / FT for x in relative]
            self.result["final"] = {"gmt": final, "gmt_utc": START_UTC,
                                     "sampled_gmt": tr["gmt"],
                                     "sample_epoch_correction_s": epoch_correction,
                                     "relative_state_ft_fts": relative_ft,
                                     "desired_relative_state_ft_fts": desired_ft,
                                     "error_ft_fts": [x / FT for x in error],
                                     "acceptance": terminal_state_acceptance([x / FT for x in error]),
                                     "desired_relative_state_m_mps": self.target["relative_m"]}
        self.result["status"] = completed_status(self.a.to)
        self.save_result()

    def preflight_resume_setup(self, checkpoint_dir):
        """Reject a too-late checkpoint before creating a simulator process."""
        if not self.a.resume_from:
            return
        schedule = []
        for i, raw in enumerate(TIGS):
            event = dict(raw)
            event["index"] = i
            event["unix"] = event_unix(raw)
            event["gmt"] = gmt_of_unix(event["unix"])
            schedule.append(event)
        first_index = first_burn_index(self.a.resume_after)
        if first_index >= len(schedule):
            return
        event = schedule[first_index]
        current = snapshot_truth(checkpoint_dir)
        checkpoint_capture = snapshot_checkpoint_gmt(self.a, self.a.logs)
        next_snap = next_periodic_snapshot_gmt(
            current["gmt"], self.a.snap_every, checkpoint_capture)
        setup_gmt = burn_setup_gmt(event["gmt"], next_snap, self.a.snap_every)
        require_resume_setup_lead(current["gmt"], setup_gmt, event["name"])


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--logs", required=True)
    ap.add_argument("--port-base", type=int, default=59200)
    ap.add_argument("--rate", type=float, default=1.0)
    ap.add_argument("--tape", default=TAPE)
    ap.add_argument("--targets", default=TARGETS)
    ap.add_argument("--ops2", default=OPS2)
    ap.add_argument("--resume-from", metavar="DIR",
                    help="continue from a recorded FD13 snapshot instead of the OPS2 capture")
    ap.add_argument("--resume-after", choices=("NC1", "NC2", "NC3"),
                    help="first unflown burn after the checkpoint")
    ap.add_argument("--targeting-seed", metavar="RESULT.json",
                    help="seed the next ground solve from another recorded complete target plan")
    ap.add_argument("--from-launch", action="store_true")
    ap.add_argument("--to", choices=("NC1", "NC2", "NC3", "NC4"), default="NC4")
    ap.add_argument("--snap-every", type=float, default=1800.0)
    ap.add_argument("--crts", type=int, default=2)
    ap.add_argument("--pulse-trim", type=float, default=DEFAULT_RCS_PULSE_TRIM_FPS, metavar="FPS",
                    help="after the card's <0.2 ft/s RCS VGO null, trim residual axes at or above FPS "
                         "with TRANS PULSE; use 0 for the card's limit alone (default %(default)s)")
    a = ap.parse_args()
    if a.snap_every <= 0 or a.rate <= 0 or a.pulse_trim < 0:
        ap.error("--snap-every and --rate must be positive; --pulse-trim cannot be negative")
    if a.resume_after and not a.resume_from:
        ap.error("--resume-after requires --resume-from")
    if a.targeting_seed and not os.path.isfile(a.targeting_seed):
        ap.error("targeting seed does not exist: " + a.targeting_seed)
    if a.resume_from and a.from_launch:
        ap.error("--resume-from cannot be combined with --from-launch")
    if a.resume_after and TIG_NAMES.index(a.resume_after) >= TIG_NAMES.index(a.to):
        ap.error("--resume-after must precede --to")
    if not os.path.isfile(a.tape):
        ap.error("tape does not exist: " + a.tape)
    if not os.path.isfile(a.targets):
        ap.error("target file does not exist: " + a.targets)
    os.environ["NSTS_NO_AUDIO"] = "1"
    # Attributes consumed by the existing ascent phases/start path when the
    # same simulator is flown from launch through OPS 2.
    a.portview = False
    a.portview_views = None
    a.duration = 200000
    a.hold_start = False
    a.layout = None
    a.count_to = 300.0
    a.reuplink = False
    a.from_ = None
    a.g3_from_mm = False
    a.land_time = 900.0
    a.incorporate_at_land = False
    fly_sts134.FL["name"] = "sts134r"
    # The already configured ascent volume is the common tape.  Keep a
    # manifest of the exact image used; the OPS2 capture's tape SHA is checked
    # by simulatePASS when it is resumed.
    with open(a.tape, "rb") as tape_file:
        a.tape_sha256 = hashlib.sha256(tape_file.read()).hexdigest()
    f = FD13(a)
    f.result["rcs_pulse_trim_fps"] = a.pulse_trim
    f.save_result()
    try:
        resume = f.resume_copy()
        f.preflight_resume_setup(resume)
        f.start(resume)
        if a.from_launch:
            f.ascent_to_ops2()
        f.run_fd13()
    except BaseException as exc:
        f.result["status"] = "failed"
        f.result["error"] = "%s: %s" % (type(exc).__name__, exc)
        f.save_result()
        raise
    finally:
        proc = getattr(f, "proc", None)
        if proc is not None:
            try:
                # simulatePASS can reject startup because another run owns
                # this port base.  In that case this child has already exited;
                # sending `quit` anyway would reach and terminate the other
                # flight's session on the shared UDP port.
                if proc.poll() is None:
                    crewscript.send_session("quit", f.base)
                proc.wait(timeout=120)
            except subprocess.TimeoutExpired:
                f.say("simulator did not exit within 120 s after quit")
                f.result["errors"].append("simulator did not exit within 120 s after quit")
                f.save_result()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
