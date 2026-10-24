#!/usr/bin/env python3
"""Small regression checks for FD13 checkpoint continuation selection."""
import contextlib
import io
import json
import os
import pathlib
import sys
import tempfile
import unittest
from types import SimpleNamespace
from unittest import mock

import crewscript
import fly_fd13
import fly_sts134
import fly_rndz134 as rndz
from fly_fd13 import (FD13, FT, RCS_VGO_NULL_PASSES, can_resume_result, first_burn_index,
                      capture_gmt, gmt_poll_delay, next_periodic_snapshot_gmt,
                      extrapolate_truth,
                      truth_at_unix,
                      resume_targeting_prior,
                      load_targeting_seed,
                      select_targeting_prior,
                      targeting_state,
                      burn_acceptance, execution_acceptance, parse_vehicle_key_trace,
                      completed_status, execution_burns, remaining_burns, targeting_burns,
                      next_snapshot_after_event, snapshot_truth, source_history,
                      planned_burn_timing, oms_fire_active, oms_burn_duration_s,
                      oms_measurement_gmt, resume_result_at_checkpoint,
                      burn_setup_gmt, require_resume_setup_lead, snapshot_checkpoint_gmt,
                      targeting_state_scales, terminal_state_acceptance,
                      DEFAULT_RCS_PULSE_TRIM_FPS)


class ResumeSelectionTests(unittest.TestCase):
    def test_targeting_state_retains_truth_and_simulator_epoch(self):
        truth = {"t": 39868.178177, "gmt": 11859942.329177022,
                 "r": [1.0, 2.0, 3.0], "v": [4.0, 5.0, 6.0]}
        initial = targeting_state(truth, 250000.0)
        self.assertEqual(initial["t"], truth["t"])
        self.assertEqual(initial["gmt"], truth["gmt"])
        self.assertEqual(initial["r"], truth["r"])
        self.assertEqual(initial["v"], truth["v"])
        self.assertEqual(initial["q"], [1.0, 0.0, 0.0, 0.0])
        self.assertEqual(initial["w"], [0.0, 0.0, 0.0])
        self.assertAlmostEqual(initial["mass_kg"], 250000.0 * 0.45359237)
        self.assertEqual(initial["weight_lbf"], 250000.0)
        self.assertAlmostEqual(initial["gmt"] - initial["t"], 11820074.151)
        self.assertAlmostEqual(initial["unix"], 1305613542.329177)

    def test_source_manifest_records_branch_revision_and_dirty_state(self):
        outputs = ["/repo\n", "codex/fd13-test\n", "abc123\n", " M file.py\n"]
        with mock.patch("fly_fd13.subprocess.run",
                        side_effect=[SimpleNamespace(stdout=value) for value in outputs]) as run:
            self.assertEqual(fly_fd13.source_manifest(), {
                "repository": "/repo", "branch": "codex/fd13-test",
                "revision": "abc123", "dirty": True})
        self.assertEqual(run.call_count, 4)

    def test_source_history_keeps_checkpoint_lineage_and_current_revision(self):
        old = {"revision": "old", "dirty": False}
        new = {"revision": "new", "dirty": False}
        self.assertEqual(source_history({"source": old}, new), ([old, new], True))
        self.assertEqual(source_history({"source_history": [old, new]}, new),
                         ([old, new], True))
        self.assertEqual(source_history({"resume": {"after": "NC1"}}, new),
                         ([{"unknown": True}, new], False))

    def test_oms_postburn_delay_uses_design_delta_v_and_engine_count(self):
        nc2 = oms_burn_duration_s(3, [63.5, 0.0, 0.0], 200000.0)
        nc1 = oms_burn_duration_s(1, [93.6, 0.0, 0.0], 200000.0)
        self.assertGreater(nc2, 14.4)
        self.assertGreater(nc2, nc1)
        self.assertLess(nc1, 66.7)
        self.assertEqual(oms_burn_duration_s(4, [100.0, 0.0, 0.0], 200000.0), 0.0)

    def test_planned_burn_timing_uses_retargeted_oms_duration_and_updates_mass(self):
        schedule = [
            {"name": "NC2", "engine": 3, "duration": 14.4, "unix": 10000.0},
            {"name": "NC4", "engine": 2, "duration": 10.6, "unix": 20000.0},
        ]
        controls = [63.5 * FT, 0.0, 0.0, 8.2 * FT, 0.0, 0.0]
        timing = planned_burn_timing(controls, {"weight_lbf": 250000.0}, schedule)
        self.assertGreater(timing[0]["duration_s"], schedule[0]["duration"])
        self.assertAlmostEqual(timing[0]["midpoint_unix"],
                               schedule[0]["unix"] + timing[0]["duration_s"] / 2.0)
        self.assertLess(timing[1]["weight_lbf"], timing[0]["weight_lbf"])

    def test_nc3_targeting_uses_fitted_rcs_impulse_midpoint(self):
        event = {"name": "NC3", "engine": 4, "duration": 11.5, "unix": 10000.0}
        timing = planned_burn_timing([24.6 * FT, 0.0, 0.0], {}, [event])[0]
        self.assertEqual(timing["duration_s"], 11.5)
        self.assertAlmostEqual(timing["midpoint_offset_s"], 102.0)
        self.assertAlmostEqual(timing["midpoint_unix"], 10102.0)

    def test_trajectory_uses_tig_lvlh_frame_and_planned_impulse_midpoint(self):
        flight = FD13.__new__(FD13)
        event = {"name": "NC2", "engine": 3, "duration": 14.4, "unix": 10000.0}
        initial = {"unix": 9000.0, "t": 0.0, "gmt": 1000.0, "weight_lbf": 250000.0,
                   "r": [7000000.0, 0.0, 0.0], "v": [0.0, 7500.0, 0.0]}
        controls = [63.5 * FT, 0.0, 0.0]
        timing = planned_burn_timing(controls, initial, [event])[0]
        calls = []
        frame_states = []

        class Propagator:
            def advance(_self, r, v, _t, dt, q, w, mass):
                calls.append(dt)
                return ([x + dt for x in r], [x + dt for x in v], list(q), list(w))

        flight._fd13_propagator = Propagator()

        def lvlh_rows(r, v):
            frame_states.append((list(r), list(v)))
            return [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]

        with mock.patch("fly_fd13.optimizer", return_value=(
                         SimpleNamespace(asarray=lambda value: value), None)), \
             mock.patch("fly_fd13.rndz_start.lvlh_rows", side_effect=lvlh_rows):
            flight.trajectory(controls, initial, [event], 10500.0)
        midpoint = timing["midpoint_unix"]
        self.assertEqual(len(frame_states), 1)
        self.assertAlmostEqual(calls[0], event["unix"] - initial["unix"])
        self.assertAlmostEqual(calls[1], midpoint - event["unix"])
        self.assertAlmostEqual(calls[2], 10500.0 - midpoint)
        self.assertAlmostEqual(frame_states[0][0][0], initial["r"][0] + 1000.0)
        self.assertGreater(calls[0] + calls[1], 1000.0)

    def test_resume_capture_oms_fire_state_detects_selected_engine(self):
        with tempfile.TemporaryDirectory(prefix="fd13-oms-fire-") as temporary:
            path = pathlib.Path(temporary)
            values = [0.0] * 228
            values[119] = 1.0
            (path / "vehdyn.json").write_text(json.dumps({"vehdyn": values}))
            self.assertTrue(oms_fire_active(path, 3))
            self.assertFalse(oms_fire_active(path, 2))

    def test_vehdyn_capture_exposes_oms_engine_time_and_propellant(self):
        with tempfile.TemporaryDirectory(prefix="fd13-oms-state-") as temporary:
            logs = pathlib.Path(temporary)
            capture = logs / "sts134r-probe"
            capture.mkdir()
            values = [0.0] * 228
            values[19:21] = [2300.0, 2200.0]
            values[21:24] = [1.0, 2.0, 3.0]
            values[112], values[118] = 1.0, 101.5
            values[119], values[125] = 0.0, 99.0
            (capture / "vehdyn.json").write_text(json.dumps({"vehdyn": values}))
            flight = FD13.__new__(FD13)
            flight.a = SimpleNamespace(logs=temporary)
            self.assertEqual(flight.vehdyn_capture("probe"), {
                "sensed": [1.0, 2.0, 3.0],
                "oms_propellant_kg": [2300.0, 2200.0],
                "oms_fire": (True, False),
                "oms_s": (101.5, 99.0),
            })

    def test_snapshot_truth_uses_exact_vehdyn_m50_state(self):
        with tempfile.TemporaryDirectory(prefix="fd13-truth-") as temporary:
            values = [0.0] * 228
            values[2] = 12.5
            values[3:9] = [304.8, 609.6, 914.4, 3.048, 6.096, 9.144]
            values[9:16] = [1.0, 0.0, 0.0, 0.0, 0.01, 0.02, 0.03]
            values[16:21] = [1.0, 2.0, 3.0, 4.0, 5.0]
            values[126] = 12345.0
            values[167] = 100.0
            pathlib.Path(temporary, "vehdyn.json").write_text(json.dumps({"vehdyn": values}))
            self.assertEqual(snapshot_truth(temporary), {
                "t": 12.5, "r": [304.8, 609.6, 914.4],
                "v": [3.048, 6.096, 9.144], "q": [1.0, 0.0, 0.0, 0.0],
                "w": [0.01, 0.02, 0.03], "gmt": 12345.0,
                "dry_kg": 100.0, "propellant_kg": [1.0, 2.0, 3.0, 4.0, 5.0],
                "mass_kg": 115.0})

    def test_nc2_measurement_waits_past_modeled_cutoff(self):
        flight = FD13.__new__(FD13)
        with tempfile.TemporaryDirectory(prefix="fd13-nc2-measure-") as temporary:
            flight.a = SimpleNamespace(rate=1.0, logs=temporary)
            actions = []
            flight.wait_gmt = lambda gmt: (actions.append(gmt) or {"gmt": gmt, "t": gmt})
            flight.play = lambda script, name: None
            flight.script_done = lambda name, timeout: None
            flight.truth = lambda: {"gmt": actions[-1], "t": actions[-1]}

            def take_snapshot(name):
                path = pathlib.Path(temporary, "sts134r-" + name)
                path.mkdir()
                values = [0.0] * 228
                values[119] = 1.0 if name.endswith("probe-01") else 0.0
                (path / "vehdyn.json").write_text(json.dumps({"vehdyn": values}))
                return actions[-1]

            flight.take_snapshot = take_snapshot
            def vehdyn_capture(name):
                before = name == "pre"
                return {"sensed": [0.0, 0.0, 0.0],
                        "oms_fire": (False, False),
                        "oms_s": (10.0, 10.0) if before else (70.0, 70.0),
                        "oms_propellant_kg": [1000.0, 1000.0] if before else [500.0, 500.0]}
            flight.vehdyn_capture = vehdyn_capture
            flight.save_result = lambda: None
            flight.say = lambda message: None
            flight.result = {"burns": [], "snapshots": []}
            event = {"name": "NC2", "gmt": 100.0, "unix": 200.0,
                     "duration": 14.4, "engine": 3, "orbiter_weight_lbf": 200000.0}
            flight.execute_and_measure(event, [63.5 * FT, 0.0, 0.0], "pre")
            modeled = oms_burn_duration_s(3, [63.5, 0.0, 0.0], 200000.0)
            self.assertAlmostEqual(actions[1], oms_measurement_gmt(100.0, 14.4, modeled))
            self.assertAlmostEqual(actions[2], actions[1] + 15.0)
            burn = flight.result["burns"][0]
            self.assertEqual(burn["oms_cutoff_probe_snapshots"],
                             ["nc2-oms-probe-01", "nc2-oms-probe-02"])
            self.assertTrue(burn["oms_cutoff_verified"])
            self.assertEqual(burn["oms_state"]["on_seconds_delta"], [60.0, 60.0])
            self.assertEqual(burn["oms_state"]["propellant_delta_kg"], [-500.0, -500.0])
            self.assertGreater(burn["measurement_offset_after_tig_s"], actions[1] - 100.0)

    def test_oms_measurement_window_uses_modeled_cutoff_and_tig_floor(self):
        nc2_modeled = oms_burn_duration_s(3, [63.5, 0.0, 0.0], 200000.0)
        self.assertAlmostEqual(oms_measurement_gmt(100.0, 14.4, nc2_modeled),
                               100.0 + max(14.4, nc2_modeled + 5.0) + 60.0)
        short_modeled = oms_burn_duration_s(3, [1.0, 0.0, 0.0], 100000.0)
        self.assertEqual(oms_measurement_gmt(100.0, 1.0, short_modeled), 220.0)
        nc1_modeled = oms_burn_duration_s(1, [93.6, 0.0, 0.0], 200000.0)
        self.assertAlmostEqual(oms_measurement_gmt(100.0, 66.7, nc1_modeled),
                               100.0 + max(66.7, nc1_modeled + 5.0) + 60.0)

    def test_late_nc4_measurement_preserves_terminal_and_postburn_handoff_captures(self):
        flight = FD13.__new__(FD13)
        flight.a = SimpleNamespace(rate=1.0, logs=os.path.join(
            tempfile.gettempdir(), "fd13-nc4-no-real-capture"))
        flight.target = {"gmt": 152.6}
        now, waits, snapshots = [0.0], [], []
        def wait_gmt(gmt):
            waits.append(gmt)
            now[0] = gmt
            return {"gmt": gmt, "t": gmt}
        flight.wait_gmt = wait_gmt
        flight.play = lambda script, name: None
        flight.script_done = lambda name, timeout: None
        flight.truth = lambda: {"gmt": now[0], "t": now[0], "r": [1.0, 2.0, 3.0],
                                "v": [4.0, 5.0, 6.0]}
        flight.take_snapshot = lambda name: (snapshots.append((name, now[0])) or now[0])
        flight.vehdyn_capture = lambda name: {"sensed": [0.0, 0.0, 0.0]}
        flight.save_result = lambda: None
        flight.say = lambda message: None
        flight.result = {"burns": [], "snapshots": []}
        event = {"name": "NC4", "gmt": 100.0, "unix": 200.0,
                 "duration": 10.6, "engine": 2, "orbiter_weight_lbf": 200000.0}
        with mock.patch("fly_fd13.oms_fire_active", return_value=False):
            flight.execute_and_measure(event, [100.0 * FT, 0.0, 0.0], "pre")
        self.assertEqual(waits, [85.0, 152.6, flight.result["burns"][0]["postburn_capture_target_gmt"]])
        self.assertEqual([s[0] for s in snapshots], ["terminal-06-10", "nc4-oms-probe-01",
                                                       "nc4-plus-2-min"])
        self.assertAlmostEqual(snapshots[0][1], 152.6)
        self.assertGreater(snapshots[1][1], snapshots[0][1])
        self.assertAlmostEqual(flight.result["terminal_sample"]["gmt"], 152.6)

    def test_default_starts_at_nc1(self):
        self.assertEqual(first_burn_index(), 0)

    def test_checkpoint_skips_completed_burns(self):
        self.assertEqual(first_burn_index("NC1"), 1)
        self.assertEqual(first_burn_index("NC2"), 2)
        self.assertEqual(first_burn_index("NC3"), 3)

    def test_nc4_is_not_a_valid_resume_checkpoint(self):
        with self.assertRaises(ValueError):
            first_burn_index("NC4")

    def test_resumed_schedule_suffix_uses_local_position(self):
        schedule = [{"name": name} for name in ("NC1", "NC2", "NC3", "NC4")]
        active = schedule[first_burn_index("NC1"):]
        self.assertEqual([x["name"] for x in remaining_burns(active, 0)],
                         ["NC2", "NC3", "NC4"])
        self.assertEqual([x["name"] for x in remaining_burns(active, 1)],
                         ["NC3", "NC4"])

    def test_partial_execution_retains_all_later_burns_for_targeting(self):
        schedule = [{"name": name} for name in ("NC1", "NC2", "NC3", "NC4")]
        first = first_burn_index("NC1")
        final = next(i for i, event in enumerate(schedule) if event["name"] == "NC2")
        planned = targeting_burns(schedule, first)
        executed = execution_burns(schedule, first, final)
        self.assertEqual([x["name"] for x in planned], ["NC2", "NC3", "NC4"])
        self.assertEqual([x["name"] for x in executed], ["NC2"])

    def test_resume_reuses_suffix_of_last_saved_targeting_solution(self):
        schedule = [{"name": name} for name in ("NC1", "NC2", "NC3", "NC4")]
        controls = [[float(i), float(i + 1), float(i + 2)] for i in range(4)]
        result = {"targeting": [{"burn": "NC1", "controls_mps_lvlh": controls}]}
        self.assertEqual(resume_targeting_prior(result, schedule, 2),
                         [2.0, 3.0, 4.0, 3.0, 4.0, 5.0])
        self.assertEqual(resume_targeting_prior(result, schedule, 1),
                         [1.0, 2.0, 3.0, 2.0, 3.0, 4.0, 3.0, 4.0, 5.0])

    def test_targeting_seed_loads_complete_suffix_with_provenance(self):
        schedule = [{"name": name} for name in ("NC1", "NC2", "NC3", "NC4")]
        controls = [[float(i), float(i + 1), float(i + 2)] for i in range(4)]
        result = {"source": {"revision": "abc"},
                  "seed_provenance": {"run": "known-source"}, "targeting": [
            {"burn": "NC1", "controls_mps_lvlh": controls}]}
        with tempfile.TemporaryDirectory() as directory:
            path = os.path.join(directory, "RESULT.json")
            with open(path, "w") as f:
                json.dump(result, f)
            seed = load_targeting_seed(path, schedule, 0)
        self.assertEqual(seed["controls"], [v for vector in controls for v in vector])
        self.assertEqual(seed["burn"], "NC1")
        self.assertEqual(seed["source"], {"revision": "abc"})
        self.assertEqual(seed["provenance"], {"run": "known-source"})
        self.assertEqual(len(seed["sha256"]), 64)

    def test_targeting_seed_rejects_missing_suffix(self):
        schedule = [{"name": name} for name in ("NC1", "NC2", "NC3", "NC4")]
        with tempfile.TemporaryDirectory() as directory:
            path = os.path.join(directory, "RESULT.json")
            with open(path, "w") as f:
                json.dump({"targeting": []}, f)
            with self.assertRaisesRegex(ValueError, "complete burn suffix"):
                load_targeting_seed(path, schedule, 0)

    def test_explicit_targeting_seed_overrides_checkpoint_plan(self):
        schedule = [{"name": name} for name in ("NC1", "NC2", "NC3", "NC4")]
        old = [[float(i), float(i + 1), float(i + 2)] for i in range(4)]
        new = [[float(i + 10), float(i + 11), float(i + 12)] for i in range(4)]
        checkpoint_result = {"targeting": [{"burn": "NC1", "controls_mps_lvlh": old}]}
        seed_result = {"targeting": [{"burn": "NC1", "controls_mps_lvlh": new}]}
        with tempfile.TemporaryDirectory() as directory:
            path = os.path.join(directory, "seed.json")
            with open(path, "w") as f:
                json.dump(seed_result, f)
            controls, provenance = select_targeting_prior(
                checkpoint_result, schedule, 3, path)
        self.assertEqual(controls, [13.0, 14.0, 15.0])
        self.assertEqual(provenance["burn"], "NC1")

    def test_completed_nc1_short_test_can_continue_to_nc4(self):
        self.assertTrue(can_resume_result("short-test-complete", "NC1"))

    def test_completion_status_distinguishes_partial_stages(self):
        self.assertEqual(completed_status("NC1"), "short-test-complete")
        self.assertEqual(completed_status("NC2"), "partial-stage-complete")
        self.assertEqual(completed_status("NC3"), "partial-stage-complete")
        self.assertEqual(completed_status("NC4"), "full-stage-complete")

    def test_completed_short_test_cannot_skip_to_later_unflown_burn(self):
        self.assertFalse(can_resume_result("short-test-complete", "NC2"))
        self.assertFalse(can_resume_result("full-stage-complete", "NC1"))
        self.assertTrue(can_resume_result("full-stage-complete", "NC3",
                                          checkpoint_recorded=True))
        self.assertTrue(can_resume_result("running", "NC2"))
        self.assertFalse(can_resume_result("failed", "NC1"))
        self.assertTrue(can_resume_result("failed", "NC1", checkpoint_recorded=True))
        self.assertTrue(can_resume_result("partial-stage-complete", "NC2",
                                          checkpoint_recorded=True))

    def test_replay_from_completed_stage_truncates_after_checkpoint(self):
        with tempfile.TemporaryDirectory(prefix="fd13-replay-") as temporary:
            capture = os.path.join(temporary, "coast-085")
            prior = {
                "status": "full-stage-complete", "rate": 3.0, "errors": [],
                "snapshots": [
                    {"name": "coast-084", "path": os.path.join(temporary, "coast-084"), "gmt": 10.0},
                    {"name": "coast-085", "path": capture, "gmt": 20.0},
                    {"name": "nc4-plus-2-min", "path": os.path.join(temporary, "handoff"), "gmt": 30.0},
                ],
                "burns": [
                    {"name": name, "truth_after_burn_plus_60": {"gmt": i}}
                    for i, name in enumerate(("NC1", "NC2", "NC3", "NC4"))
                ],
                "targeting": [
                    {"burn": name, "controls_mps_lvlh": [[float(i), 0.0, 0.0]] * (4 - i)}
                    for i, name in enumerate(("NC1", "NC2", "NC3", "NC4"))
                ],
                "final": {"gmt": 40.0}, "terminal_sample": {"gmt": 40.0},
            }
            replay = resume_result_at_checkpoint(prior, capture, "NC3", 3.0)
            self.assertEqual([x["name"] for x in replay["snapshots"]], ["coast-084", "coast-085"])
            self.assertEqual([x["name"] for x in replay["burns"]], ["NC1", "NC2", "NC3"])
            self.assertEqual([x["burn"] for x in replay["targeting"]], ["NC1", "NC2", "NC3"])
            self.assertEqual(replay["status"], "running")
            self.assertNotIn("final", replay)
            self.assertNotIn("terminal_sample", replay)
            self.assertEqual(prior["status"], "full-stage-complete")
            self.assertEqual(len(prior["burns"]), 4)

    def test_resumed_periodic_snapshots_stay_anchored_to_capture(self):
        checkpoint_gmt = 11857887.69966
        self.assertAlmostEqual(
            next_periodic_snapshot_gmt(checkpoint_gmt + 70.0, 1800.0, checkpoint_gmt),
            checkpoint_gmt + 1800.0)

    def test_capture_json_gmtunix_converts_to_gpc_gmt(self):
        capture = {"gmtUnix": 1305561044.978842}
        self.assertAlmostEqual(capture_gmt(capture), 11807444.978842, places=5)

    def test_fresh_snapshot_schedule_starts_from_current_state(self):
        self.assertEqual(next_periodic_snapshot_gmt(500.0, 1800.0), 2300.0)

    def test_late_resume_starts_a_new_period_from_current_state(self):
        self.assertEqual(next_periodic_snapshot_gmt(2500.0, 1800.0, 500.0), 4300.0)

    def test_snapshot_checkpoint_gmt_uses_recorded_capture_epoch(self):
        with tempfile.TemporaryDirectory(prefix="fd13-snapshot-checkpoint-") as temporary:
            capture = pathlib.Path(temporary, "coast-007")
            capture.mkdir()
            pathlib.Path(temporary, "RESULT.json").write_text(json.dumps({
                "snapshots": [{"name": "coast-007", "path": str(capture),
                               "gmtUnix": 1305561044.978842}]}))
            args = SimpleNamespace(resume_from=str(capture))
            self.assertAlmostEqual(snapshot_checkpoint_gmt(args, temporary),
                                   11807444.978842, places=5)

    def test_early_event_capture_does_not_advance_periodic_deadline(self):
        self.assertEqual(next_snapshot_after_event(939.0, 1000.0, 1800.0), 1000.0)

    def test_event_capture_within_tolerance_advances_one_period(self):
        self.assertEqual(next_snapshot_after_event(1024.0, 1000.0, 1800.0), 2824.0)

    def test_event_capture_just_before_deadline_reanchors_period(self):
        self.assertEqual(next_snapshot_after_event(970.0, 1000.0, 1800.0), 2770.0)

    def test_late_event_capture_reanchors_next_period(self):
        self.assertEqual(next_snapshot_after_event(1061.0, 1000.0, 1800.0), 2861.0)

    def test_burn_setup_keeps_original_lead_when_deadline_is_late(self):
        tig = 10000.0
        setup = tig - 17 * 60
        self.assertEqual(burn_setup_gmt(tig, setup + 400.0), setup)

    def test_burn_setup_moves_after_deadline_just_before_nominal_setup(self):
        tig = 10000.0
        setup = tig - 17 * 60
        self.assertEqual(burn_setup_gmt(tig, setup - 1800.0), setup + 60.0)

    def test_burn_setup_moves_to_deadline_before_keying_window(self):
        tig = 10000.0
        setup = tig - 17 * 60
        first_deadline = 7200.0
        next_deadline = 9000.0
        self.assertEqual(burn_setup_gmt(tig, first_deadline), next_deadline + 60.0)

    def test_burn_setup_uses_previous_capture_when_next_deadline_breaks_minimum_lead(self):
        tig = 10000.0
        setup = tig - 17 * 60
        next_deadline = tig - 12 * 60
        self.assertEqual(burn_setup_gmt(tig, next_deadline - 1800.0),
                         next_deadline - 1800.0 + 60.0)

    def test_preflight_accepts_nc3_checkpoint_with_full_setup_lead(self):
        flight = object.__new__(FD13)
        flight.a = SimpleNamespace(resume_from="checkpoint", resume_after="NC2",
                                   snap_every=1800.0, logs="logs")
        with mock.patch("fly_fd13.snapshot_truth", return_value={"gmt": 11891254.0}), \
             mock.patch("fly_fd13.snapshot_checkpoint_gmt", return_value=11891254.0):
            flight.preflight_resume_setup("checkpoint-copy")

    def test_preflight_rejects_nc3_checkpoint_after_setup_before_start(self):
        flight = object.__new__(FD13)
        flight.a = SimpleNamespace(resume_from="checkpoint", resume_after="NC2",
                                   snap_every=1800.0, logs="logs")
        with mock.patch("fly_fd13.snapshot_truth", return_value={"gmt": 11893214.075}), \
             mock.patch("fly_fd13.snapshot_checkpoint_gmt", return_value=11893214.075):
            with self.assertRaisesRegex(ValueError, "after NC3 setup.*choose an earlier checkpoint"):
                flight.preflight_resume_setup("checkpoint-copy")

    def test_resume_allows_checkpoint_before_next_burn_setup(self):
        setup = 11892254.0
        require_resume_setup_lead(setup, setup, "NC3")
        require_resume_setup_lead(setup - 1.0, setup, "NC3")

    def test_resume_rejects_checkpoint_after_next_burn_setup(self):
        setup = 11892254.0
        with self.assertRaisesRegex(ValueError, "after NC3 setup.*choose an earlier checkpoint"):
            require_resume_setup_lead(11893214.075, setup, "NC3")

    def test_trajectory_propagates_to_planned_oms_impulse_midpoint(self):
        flight = FD13.__new__(FD13)
        event = {"name": "NC2", "engine": 3, "duration": 14.4, "unix": 10000.0}
        initial = {"unix": 9000.0, "gmt": 10000.0, "t": 0.0, "weight_lbf": 250000.0,
                   "r": [7000000.0, 0.0, 0.0], "v": [0.0, 7500.0, 0.0]}
        controls = [63.5 * FT, 0.0, 0.0]
        timing = planned_burn_timing(controls, initial, [event])[0]
        calls = []

        def propagate(r, v, dt, zonal=True, step=10.0):
            calls.append(dt)
            return list(r), list(v)

        def advance(r, v, sim_time, dt, q, w, mass):
            calls.append(dt)
            return list(r), list(v), list(q), mass

        fake_propagator = SimpleNamespace(advance=advance)
        with mock.patch("fly_fd13.fd13_propagator.FD13Propagator",
                        return_value=fake_propagator), \
             mock.patch("fly_fd13.rndz_start.lvlh_rows", return_value=[
                 [1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]):
            flight.trajectory(controls, initial, [event], 10500.0)
        midpoint = timing["midpoint_unix"]
        self.assertAlmostEqual(calls[0], event["unix"] - initial["unix"])
        self.assertAlmostEqual(calls[1], midpoint - event["unix"])
        self.assertAlmostEqual(calls[2], 10500.0 - midpoint)
        self.assertEqual(calls[0], 1000.0)

class FlightAcceptanceTests(unittest.TestCase):
    def test_burn_measurement_is_classified_without_conflating_flight_progress(self):
        self.assertTrue(burn_acceptance(100.0, 101.0)["accepted"])
        self.assertFalse(burn_acceptance(100.0, 101.01)["accepted"])
        self.assertTrue(burn_acceptance(10.0, 10.3)["accepted"])
        self.assertFalse(burn_acceptance(10.0, 10.31)["accepted"])
        rejected = burn_acceptance(222.0, 83.0)
        self.assertFalse(rejected["accepted"])
        self.assertEqual(rejected["tolerance_fts"], 2.22)
        self.assertIn("exceeds", rejected["reason"])
        self.assertFalse(burn_acceptance(100.0, None)["accepted"])

    def test_execution_gate_requires_timing_and_verified_cutoff(self):
        self.assertTrue(execution_acceptance(-0.9, True)["accepted"])
        self.assertFalse(execution_acceptance(1.01, True)["accepted"])
        self.assertFalse(execution_acceptance(None, True)["accepted"])
        self.assertFalse(execution_acceptance(0.0, False)["accepted"])

    def test_panel_exec_trace_parses_vehicle_clock_sample(self):
        trace=parse_vehicle_key_trace(
            "panelO6: vehicle-key: EXEC vehicle_t=7100.123 sample_t=7100.100 "
            "sample_age_s=0.004 rate=3.000 [t=9107.9]")
        self.assertEqual(trace, {'vehicle_t':7100.123,'sample_t':7100.1,
                                 'sample_age_s':0.004,'rate':3.0})
        direct = parse_vehicle_key_trace(
            'panelO6: vehicle-key: EXEC monotonic=12345.678901234 [t=9107.9]')
        self.assertEqual(direct, {'host_monotonic':12345.678901234})
        self.assertIsNone(parse_vehicle_key_trace('panelO6: script complete'))

    def test_scripted_key_trace_records_successful_send_time(self):
        sent = []
        traces = []

        class FakeBus:
            def send_key(self, key):
                sent.append(key)

        player = crewscript.Player.__new__(crewscript.Player)
        player.stopped = False
        player.bus = FakeBus()
        player.key_trace = lambda name, mono: traces.append((name, mono))
        player.after = lambda _ms, _callback: None
        player.gap = (0.3, 0.3)
        player.log = lambda _message: None
        key = ('kb', 1, [0x0040], 'EXEC')
        player._type(0, [key], 0)
        self.assertEqual(sent, [key])
        self.assertEqual(len(traces), 1)
        self.assertEqual(traces[0][0], 'EXEC')
        self.assertGreater(traces[0][1], 0.0)

    def test_vehicle_clock_interpolates_script_key_time_from_truth_feed(self):
        ears = rndz.Ears.__new__(rndz.Ears)
        ears.lock = rndz.threading.Lock()
        ears.hist_clock = [(10.0, 100.0, 1000.0), (11.0, 102.0, 1002.0)]
        trace = ears.vehicle_clock_at(10.25)
        self.assertAlmostEqual(trace['vehicle_t'], 100.5)
        self.assertAlmostEqual(trace['vehicle_gmt'], 1000.5)
        self.assertAlmostEqual(trace['sample_t'], 100.0)
        self.assertAlmostEqual(trace['sample_age_s'], 0.25)
        self.assertAlmostEqual(trace['rate'], 2.0)
        self.assertIsNone(ears.vehicle_clock_at(9.0))

    def test_large_predicted_terminal_miss_is_returned_for_reporting(self):
        import numpy as np

        flight = FD13.__new__(FD13)
        flight.target = {"r": [0.0, 0.0, 0.0], "v": [0.0, 0.0, 0.0], "unix": 10.0}
        flight.trajectory = lambda *_args: np.asarray([2000 * FT, 0.0, 0.0, 0.0, 0.0, 0.0])

        class Solution:
            x = np.zeros(3)
            cost = 0.0
            nfev = 1
            success = True

        observed = {}

        def fake_least_squares(_residual, prior, **kwargs):
            observed["prior"] = prior.copy()
            observed["bounds"] = kwargs["bounds"]
            observed["max_nfev"] = kwargs["max_nfev"]
            observed["x_scale"] = kwargs["x_scale"]
            return Solution()

        with mock.patch.object(fly_fd13, "optimizer", return_value=(np, fake_least_squares)):
            plan = flight.design({"r": [0.0] * 3, "v": [0.0] * 3, "unix": 0.0},
                                 [{"index": 2, "name": "NC3", "engine": 4,
                                   "duration": 11.5, "unix": 1.0}],
                                 [1000.0, -1000.0, 1000.0])
        self.assertFalse(plan["position_miss_within_1000_ft"])
        self.assertAlmostEqual(plan["position_miss_m"] / FT, 2000.0)
        # Optimizer termination is not evidence that the rendezvous target
        # was reached: this bounded solve converged while retaining a 2 kft
        # terminal position miss.
        self.assertTrue(plan["optimizer_converged"])
        self.assertNotIn("success", plan)
        self.assertEqual(plan["control_bounds_fts"], [40.0])
        self.assertTrue(np.allclose(observed["bounds"][0], -40.0 * FT))
        self.assertTrue(np.allclose(observed["bounds"][1], 40.0 * FT))
        self.assertTrue(np.allclose(observed["prior"], [40.0 * FT, -40.0 * FT, 40.0 * FT]))
        self.assertEqual(observed["max_nfev"], 600)
        self.assertTrue(np.allclose(observed["x_scale"], [2.7 * FT] * 3))

    def test_final_relative_state_is_measured_against_iss_and_compared_to_desired(self):
        target = {"r": [100.0, 200.0, 300.0], "v": [4.0, 5.0, 6.0],
                  "reference_r": [1.0, 2.0, 3.0], "reference_v": [7.0, 8.0, 9.0],
                  "relative_m": [10.0, 20.0, 30.0, 1.0, 2.0, 3.0]}
        actual = [11.0, 18.0, 33.0, 1.5, 1.0, 3.25]
        with mock.patch.object(fly_fd13.rndz_start, "m50_to_lvc", return_value=actual) as convert:
            measured, desired, error = fly_fd13.final_relative_state(
                target, [101.0, 201.0, 301.0], [4.1, 5.1, 6.1])
        convert.assert_called_once_with(target["reference_r"], target["reference_v"],
                                        [101.0, 201.0, 301.0], [4.1, 5.1, 6.1])
        self.assertEqual(measured, actual)
        self.assertEqual(desired, target["relative_m"])
        self.assertEqual(error, [1.0, -2.0, 3.0, 0.5, -1.0, 0.25])

    def test_final_truth_corrects_subquarter_second_epoch_offset(self):
        sampled_gmt = 11945400.162944583
        target_unix = fly_fd13.unix_of("2011-01-01T00:00:00") + 11945400.0 - 86400.0
        truth = {"gmt": sampled_gmt, "t": 27883.7759,
                 "r": [1.0, 2.0, 3.0], "v": [4.0, 5.0, 6.0], "extra": "retained"}
        propagated = ([7.0, 8.0, 9.0], [10.0, 11.0, 12.0])
        with mock.patch.object(fly_fd13.rndz_start, "propagate",
                               return_value=propagated) as advance:
            aligned, correction = truth_at_unix(truth, target_unix)
        self.assertAlmostEqual(correction, -0.162944583, places=7)
        advance.assert_called_once_with(truth["r"], truth["v"], correction, True, step=1.0)
        self.assertEqual(aligned["r"], propagated[0])
        self.assertEqual(aligned["v"], propagated[1])
        self.assertAlmostEqual(aligned["gmt"], 11945400.0)
        self.assertAlmostEqual(aligned["t"], truth["t"] + correction)
        self.assertEqual(aligned["extra"], truth["extra"])

    def test_load_target_state_retains_propagated_iss_reference(self):
        reference_r, reference_v = [1.0, 2.0, 3.0], [4.0, 5.0, 6.0]
        desired_r, desired_v = [11.0, 12.0, 13.0], [14.0, 15.0, 16.0]
        run = SimpleNamespace(stdout="YAGPC_VEHDYN_START_REL=0,1,2,3,4,5,6\n")
        with mock.patch.object(fly_fd13.subprocess, "run", return_value=run), \
             mock.patch.object(fly_fd13.rndz_start, "read_target",
                               return_value=(1000.0, [20.0] * 3, [30.0] * 3)), \
             mock.patch.object(fly_fd13.rndz_start, "propagate",
                               return_value=(reference_r, reference_v)), \
             mock.patch.object(fly_fd13.rndz_start, "lvc_to_m50",
                               return_value=(desired_r, desired_v)):
            target = fly_fd13.load_target_state("targets.txt", "2011-05-18T06:10:00")
        self.assertEqual(target["r"], desired_r)
        self.assertEqual(target["v"], desired_v)
        self.assertEqual(target["reference_r"], reference_r)
        self.assertEqual(target["reference_v"], reference_v)
        self.assertEqual(target["relative_m"], [1.0, 2.0, 3.0, 4.0, 5.0, 6.0])

    def test_nc4_single_burn_uses_terminal_acceptance_scales(self):
        self.assertEqual(targeting_state_scales([{"name": "NC4"}]),
                         [1000.0, 1000.0, 1000.0, 2.5, 2.5, 2.5])

    def test_other_targeting_horizons_keep_original_state_scales(self):
        baseline = [100.0, 100.0, 100.0, 0.1, 0.1, 0.1]
        self.assertEqual(targeting_state_scales([{"name": "NC3"}]), baseline)
        self.assertEqual(targeting_state_scales([{"name": "NC3"}, {"name": "NC4"}]), baseline)

    def test_terminal_state_gate_uses_position_and_velocity_norms(self):
        accepted = terminal_state_acceptance([3000, 4000, 0, 3, 4, 0])
        self.assertTrue(accepted["accepted"])
        self.assertEqual(accepted["position_error_ft"], 5000.0)
        self.assertEqual(accepted["velocity_error_fts"], 5.0)
        self.assertFalse(terminal_state_acceptance([5000.1, 0, 0, 0, 0, 0])["accepted"])
        self.assertFalse(terminal_state_acceptance([0, 0, 0, 5.01, 0, 0])["accepted"])
        self.assertFalse(terminal_state_acceptance([float("nan")] * 6)["accepted"])
        self.assertFalse(terminal_state_acceptance([0] * 5)["accepted"])


class CompletedShortResumeTests(unittest.TestCase):
    def test_resume_rejects_capture_while_selected_oms_is_firing(self):
        with tempfile.TemporaryDirectory(prefix="fd13-midburn-resume-") as temporary:
            root = pathlib.Path(temporary)
            capture = root / "sts134r-nc1-plus-60"
            capture.mkdir()
            (capture / "vehicle.json").write_text("{}\n")
            values = [0.0] * 228
            values[112] = 1.0
            (capture / "vehdyn.json").write_text(json.dumps({"vehdyn": values}))
            prior = {
                "status": "partial-stage-complete", "errors": [],
                "burns": [{"name": "NC1", "tig_gmt": 100.0, "duration_s": 66.7,
                           "engine_selector_item": 2,
                           "truth_after_burn_plus_60": {"gmt": 226.7}}],
                "snapshots": [{"name": capture.name, "path": str(capture), "gmt": 300.0}],
            }
            (root / "RESULT.json").write_text(json.dumps(prior))
            args = SimpleNamespace(logs=str(root / "continued"), resume_from=str(capture),
                                   resume_after="NC1", from_launch=False, rate=1.0,
                                   tape="tape.mmv", targets="targets.txt")
            with mock.patch.object(rndz.Rendezvous, "__init__", return_value=None):
                with self.assertRaisesRegex(ValueError, "during the NC1 OMS burn"):
                    FD13(args)

    def test_completed_nc1_short_capture_initializes_as_full_run_checkpoint(self):
        with tempfile.TemporaryDirectory(prefix="fd13-short-resume-") as temporary:
            root = pathlib.Path(temporary)
            capture = root / "sts134r-nc1-plus-60"
            capture.mkdir()
            (capture / "vehicle.json").write_text("{}\n")
            (capture / "vehdyn.json").write_text(json.dumps({"vehdyn": [0.0] * 228}) + "\n")
            prior = {
                "status": "short-test-complete", "error": "stale prior failure",
                "burns": [{
                    "name": "NC1", "tig_gmt": 100.0, "duration_s": 66.7}],
                "snapshots": [{"name": "nc1-plus-60", "path": str(capture), "gmt": 226.7}],
            }
            (root / "RESULT.json").write_text(json.dumps(prior))
            args = SimpleNamespace(logs=str(root / "continued"), resume_from=str(capture),
                                   resume_after="NC1", from_launch=False, rate=1.0,
                                   tape="tape.mmv", targets="targets.txt")
            def fake_init(flight, a):
                flight.a = a

            with mock.patch.object(rndz.Rendezvous, "__init__", new=fake_init), \
                 mock.patch.object(fly_fd13, "load_target_state",
                                   return_value={"test": True, "rndz_start": "fixture target\n"}):
                flight = FD13(args)
            self.assertEqual(flight.result["status"], "running")
            self.assertNotIn("error", flight.result)
            self.assertEqual(flight.result["burns"], prior["burns"])
            self.assertEqual(flight.result["resume"], {
                "after": "NC1", "capture": str(capture), "rate": 1.0})
            self.assertEqual(json.loads((root / "continued" / "RESULT.json").read_text()),
                             flight.result)

    def test_failed_run_can_resume_from_a_recorded_postburn_checkpoint(self):
        with tempfile.TemporaryDirectory(prefix="fd13-failed-resume-") as temporary:
            root = pathlib.Path(temporary)
            capture = root / "sts134r-coast-034"
            capture.mkdir()
            (capture / "vehicle.json").write_text("{}\n")
            (capture / "vehdyn.json").write_text(json.dumps({"vehdyn": [0.0] * 228}) + "\n")
            prior = {
                "status": "failed", "error": "display disconnected after checkpoint",
                "rate": 3.0,
                "errors": [],
                "burns": [{
                    "name": "NC1", "tig_gmt": 100.0, "duration_s": 66.7,
                    "engine_selector_item": 1,
                    "truth_after_burn_plus_60": {"gmt": 226.7},
                }],
                "snapshots": [{
                    "name": "coast-034", "path": str(capture), "gmt": 300.0,
                }],
            }
            (root / "RESULT.json").write_text(json.dumps(prior))
            args = SimpleNamespace(logs=str(root / "continued"), resume_from=str(capture),
                                   resume_after="NC1", from_launch=False, rate=2.0,
                                   tape="tape.mmv", targets="targets.txt")

            def fake_init(flight, a):
                flight.a = a

            with mock.patch.object(rndz.Rendezvous, "__init__", new=fake_init), \
                 mock.patch.object(fly_fd13, "load_target_state",
                                   return_value={"test": True, "rndz_start": "fixture target\n"}):
                flight = FD13(args)
            self.assertEqual(flight.result["status"], "running")
            self.assertEqual(flight.result["rate"], 2.0)
            self.assertEqual(flight.result["resume"], {
                "after": "NC1", "capture": str(capture), "rate": 2.0,
                "prior_rate": 3.0})
            self.assertEqual(flight.result["burns"][0]["flight_rate"], 3.0)
            self.assertNotIn("error", flight.result)

    def test_failed_pre_nc1_run_can_resume_from_a_recorded_coast_capture(self):
        with tempfile.TemporaryDirectory(prefix="fd13-preburn-resume-") as temporary:
            root = pathlib.Path(temporary)
            capture = root / "sts134r-coast-003"
            capture.mkdir()
            (capture / "vehicle.json").write_text("{}\n")
            (capture / "vehdyn.json").write_text(json.dumps({"vehdyn": [0.0] * 228}) + "\n")
            nc1_gmt = fly_fd13.gmt_of_unix(fly_fd13.event_unix(fly_fd13.TIGS[0]))
            prior = {
                "status": "failed", "error": "KeyboardInterrupt", "rate": 2.0,
                "errors": [], "burns": [],
                "snapshots": [{"name": "coast-003", "path": str(capture),
                               "gmt": nc1_gmt - 600.0}],
            }
            (root / "RESULT.json").write_text(json.dumps(prior))
            args = SimpleNamespace(logs=str(root / "continued"), resume_from=str(capture),
                                   resume_after=None, from_launch=False, rate=2.0,
                                   tape="tape.mmv", targets="targets.txt")

            def fake_init(flight, a):
                flight.a = a

            with mock.patch.object(rndz.Rendezvous, "__init__", new=fake_init), \
                 mock.patch.object(fly_fd13, "load_target_state",
                                   return_value={"test": True, "rndz_start": "fixture target\n"}):
                flight = FD13(args)

            self.assertEqual(flight.result["status"], "running")
            self.assertEqual(flight.result["burns"], [])
            self.assertEqual([s["name"] for s in flight.result["snapshots"]], ["coast-003"])
            self.assertEqual(flight.result["resume"], {
                "after": None, "capture": str(capture), "rate": 2.0,
                "prior_rate": 2.0})
            self.assertNotIn("error", flight.result)

    def test_pre_nc1_resume_rejects_post_nc1_capture(self):
        with tempfile.TemporaryDirectory(prefix="fd13-late-preburn-") as temporary:
            root = pathlib.Path(temporary)
            capture = root / "late"
            capture.mkdir()
            (capture / "vehicle.json").write_text("{}\n")
            (capture / "vehdyn.json").write_text(json.dumps({"vehdyn": [0.0] * 228}) + "\n")
            nc1_gmt = fly_fd13.gmt_of_unix(fly_fd13.event_unix(fly_fd13.TIGS[0]))
            (root / "RESULT.json").write_text(json.dumps({
                "status": "failed", "errors": [], "burns": [],
                "snapshots": [{"name": "late", "path": str(capture), "gmt": nc1_gmt + 1.0}],
            }))
            args = SimpleNamespace(logs=str(root / "continued"), resume_from=str(capture),
                                   resume_after=None, from_launch=False, rate=2.0,
                                   tape="tape.mmv", targets="targets.txt")

            def fake_init(flight, a):
                flight.a = a

            with mock.patch.object(rndz.Rendezvous, "__init__", new=fake_init):
                with self.assertRaisesRegex(ValueError, "must precede the NC1 TIG"):
                    FD13(args)

    def test_failed_run_without_recorded_burn_checkpoint_cannot_resume(self):
        with tempfile.TemporaryDirectory(prefix="fd13-unsafe-resume-") as temporary:
            root = pathlib.Path(temporary)
            capture = root / "unrelated"
            capture.mkdir()
            (capture / "vehicle.json").write_text("{}\n")
            (capture / "vehdyn.json").write_text(json.dumps({"vehdyn": [0.0] * 228}) + "\n")
            (root / "RESULT.json").write_text(json.dumps({
                "status": "failed", "errors": ["NC1 burn rejected"],
                "burns": [{"name": "NC1", "tig_gmt": 100.0, "duration_s": 66.7}],
                "snapshots": [{"name": "unrelated", "path": str(capture), "gmt": 300.0}],
            }))
            args = SimpleNamespace(logs=str(root / "continued"), resume_from=str(capture),
                                   resume_after="NC1", from_launch=False, rate=3.0,
                                   tape="tape.mmv", targets="targets.txt", port_base=61000)
            with mock.patch.object(rndz.Rendezvous, "__init__", return_value=None):
                with self.assertRaisesRegex(ValueError, "recorded checkpoint"):
                    FD13(args)

    def test_near_deadline_polling_stays_within_half_wall_second(self):
        for rate in (1, 2, 3, 8):
            with self.subTest(rate=rate):
                self.assertLessEqual(gmt_poll_delay(60, rate), 0.5)
                self.assertLessEqual(gmt_poll_delay(15, rate), 0.5)
                self.assertLessEqual(gmt_poll_delay(120, rate), 0.5)

    def test_far_deadline_keeps_coarse_polling(self):
        self.assertEqual(gmt_poll_delay(600, 3), 10.0)

    def test_wait_gmt_returns_the_sample_that_met_the_deadline(self):
        flight = FD13.__new__(FD13)
        flight.a = SimpleNamespace(rate=2)
        sample = {"gmt": 1234.5, "t": 99.0}
        flight.truth = lambda: sample
        self.assertIs(flight.wait_gmt(1234.5), sample)

    def test_coast_to_uses_precise_wait_and_anchors_next_period_to_saved_capture(self):
        flight = FD13.__new__(FD13)
        flight.a = SimpleNamespace(rate=3.0)
        flight.result = {"snapshots": []}
        now = [0.0]
        waits, captures = [], []

        def wait_precise(gmt):
            waits.append(gmt)
            now[0] = gmt
            return {"gmt": gmt}

        def take_snapshot(name):
            captures.append((name, now[0]))
            return now[0] + 0.2

        flight.truth = lambda: {"gmt": now[0]}
        flight.wait_gmt_precise = wait_precise
        flight.take_snapshot = take_snapshot
        next_snap = flight.coast_to(2000.0, 1000.0, 1800.0)
        self.assertEqual(waits, [1000.0, 2000.0])
        self.assertEqual(captures, [("coast-001", 1000.0)])
        self.assertAlmostEqual(next_snap, 2800.2)

    def test_snapshot_result_uses_epoch_in_capture_json(self):
        flight = FD13.__new__(FD13)
        with tempfile.TemporaryDirectory(prefix="fd13-capture-time-") as temporary:
            flight.a = SimpleNamespace(logs=temporary)
            flight.result = {"snapshots": []}
            flight.save_result = lambda: None

            def snapshot(name):
                path = pathlib.Path(temporary, "sts134r-" + name)
                path.mkdir()
                (path / "vehicle.json").write_text("{}\n")
                (path / "capture.json").write_text(json.dumps({"gmt": 12345.6}))

            flight._snapshot = snapshot
            flight.truth = mock.Mock(side_effect=AssertionError("snapshot return time is not capture time"))
            observed = flight.take_snapshot("coast-001")
        self.assertEqual(observed, 12345.6)
        self.assertEqual(flight.result["snapshots"][0]["gmt"], 12345.6)

    def test_deadline_extrapolation_advances_clock_and_m50_state_together(self):
        sample = {"gmt": 100.0, "t": 25.0,
                  "r": [6800000.0, 0.0, 0.0], "v": [0.0, 7500.0, 0.0]}
        result = extrapolate_truth(sample, 0.25, 3.0)
        self.assertEqual(result["gmt"], 100.75)
        self.assertEqual(result["t"], 25.75)
        expected_r, expected_v = fly_fd13.rndz_start.propagate(
            sample["r"], sample["v"], 0.75, True, step=1.0)
        for actual, expected in zip(result["r"], expected_r):
            self.assertAlmostEqual(actual, expected)
        for actual, expected in zip(result["v"], expected_v):
            self.assertAlmostEqual(actual, expected)
        self.assertNotEqual(result["r"], sample["r"])
        self.assertNotEqual(result["v"], sample["v"])
        self.assertEqual(sample["gmt"], 100.0)

    def test_precise_wait_extrapolates_instead_of_blocking_for_next_truth(self):
        flight = FD13.__new__(FD13)
        flight.a = SimpleNamespace(rate=3.0)
        flight.truth = lambda: {"gmt": 100.0, "t": 25.0}
        with mock.patch.object(fly_fd13.time, "monotonic", side_effect=(0.0, 3.2333333333)), \
             mock.patch.object(fly_fd13.time, "sleep") as sleep:
            result = flight.wait_gmt_precise(110.0)
        self.assertAlmostEqual(result["gmt"], 109.7, places=3)
        sleep.assert_called_once()

    def test_burn_exec_uses_deadline_sample_without_an_extra_truth_read(self):
        flight = FD13.__new__(FD13)
        flight.a = SimpleNamespace(rate=1.0, logs=tempfile.gettempdir())
        deadline = {"gmt": 85.0, "t": 10.0}
        post = {"gmt": 226.7, "t": 151.7}
        actions = []
        waits = iter((deadline, post))
        flight.wait_gmt = lambda gmt: (actions.append(("wait", gmt)), next(waits))[1]
        flight.play = lambda script, name: actions.append(("play", name))
        flight.script_done = lambda name, timeout: actions.append(("done", name))
        flight.truth = lambda: (actions.append(("truth",)), post)[1]
        flight.take_snapshot = lambda name: actions.append(("snapshot", name))
        flight.vehdyn_capture = lambda name: {"sensed": [0.0, 0.0, 0.0] if name == "pre" else [10 * FT, 0.0, 0.0]}
        flight.save_result = lambda: None
        flight.say = lambda message: None
        flight.result = {"burns": []}

        with mock.patch("fly_fd13.oms_fire_active", return_value=False):
            flight.execute_and_measure(
                {"name": "NC1", "gmt": 100.0, "unix": 200.0, "duration": 66.7,
                 "engine": 1, "orbiter_weight_lbf": 200000.0},
                [10 * FT, 0.0, 0.0], "pre")

        self.assertIs(flight.result["burns"][0]["truth_at_exec"], deadline)
        self.assertEqual([a[0] for a in actions[:5]], ["wait", "play", "done", "wait", "truth"])


class RcsBurnTests(unittest.TestCase):
    def test_null_vgo_uses_preburn_capture_when_live_downlist_is_missing(self):
        flight = FD13.__new__(FD13)
        flight.a = SimpleNamespace(rate=1.0, pulse_trim=0.0)
        watch = SimpleNamespace(
            get=lambda key: 0 if key == "CGNV_DV_COUNT" else None)
        flight.strk_watch = lambda: watch
        flight.probe = mock.Mock(side_effect=AssertionError("must not snapshot at TIG"))
        flight.say = lambda message: None
        expected = {"x": 0.05, "y": -0.10, "z": 0.15}

        actual = flight.null_vgo("nc3", 6, initial_vgo=expected)

        self.assertEqual(actual, expected)
        flight.probe.assert_not_called()

    def test_vgo_trim_offsets_use_vehicle_time_at_any_rate(self):
        class Watch:
            def __init__(self):
                self.vector = 0

            def get(self, key):
                if key == "CGNV_DV_COUNT":
                    return 0
                if key.startswith("CGZV_VGO$"):
                    axis = int(key[-1]) - 1
                    value = ([100.0, 100.0, 100.0] if self.vector == 0 else
                             [0.0, 0.0, 0.0])[axis]
                    if axis == 2:
                        self.vector += 1
                    return value
                return None

        for rate in (1.0, 3.0):
            with self.subTest(rate=rate):
                flight = FD13.__new__(FD13)
                flight.a = SimpleNamespace(rate=rate, pulse_trim=0.0)
                flight.thc_acc = {"+x": 1.0, "+y": 1.0, "+z": 1.0}
                scripts = []
                flight.strk_watch = lambda: Watch()
                flight.play = lambda script, name: scripts.append(script)
                flight.script_done = lambda name, timeout: None
                flight.wait_sim = lambda seconds: None
                flight.say = lambda message: None
                flight.null_vgo("nc3", 1)
                self.assertEqual(scripts[0].splitlines(), [
                    "+0.00   thc fwd +x 12.00",
                    "+12.30   thc fwd +y 12.00",
                    "+24.60   thc fwd +z 12.00",
                ])

    def test_oms_load_reselects_engine_and_reapplies_trim_after_tgt10(self):
        flight = FD13.__new__(FD13)
        flight.orbiter_lb = lambda: 250000
        calls = []
        flight.play = lambda script, name: calls.append((script, name))
        flight.script_done = lambda name, timeout: calls.append((name, timeout))

        flight.load_burn({"name": "NC2", "gmt": 1000.0, "unix": 2000.0, "engine": 3},
                         [1.0, 2.0, 3.0])

        script = calls[0][0]
        compute = script.index("keys ITEM 1 0")
        dv = script.index("keys ITEM 1 9")
        load = script.index("keys ITEM 2 2")
        engine_again = script.index("keys ITEM 3 EXEC", compute)
        trim_again = script.index("keys ITEM 6", engine_again)
        weight_again = script.index("keys ITEM 9", trim_again)
        self.assertLess(compute, engine_again)
        self.assertLess(engine_again, trim_again)
        self.assertLess(trim_again, weight_again)
        self.assertLess(weight_again, dv)
        self.assertLess(dv, load)

    def test_rcs_load_selects_rcs_without_oms_mnvr_setup(self):
        flight = FD13.__new__(FD13)
        flight.orbiter_lb = lambda: 250000
        calls = []
        flight.play = lambda script, name: calls.append((script, name))
        flight.script_done = lambda name, timeout: calls.append((name, timeout))

        flight.load_burn({"name": "NC3", "gmt": 1000.0, "unix": 2000.0, "engine": 4},
                         [1.0, 2.0, 3.0])

        script = calls[0][0]
        self.assertIn("keys ITEM 4 EXEC", script)
        self.assertIn("keys ITEM 2 2 EXEC", script)
        self.assertIn("keys ITEM 2 3 EXEC", script)
        self.assertNotIn("keys ITEM 2 7 EXEC", script)
        self.assertIn("keys ITEM 9 + 2 5 0 0 0 0 EXEC", script)
        self.assertIn("dap c3 pri", script)
        for axis in ("x_norm", "y_norm", "z_norm"):
            self.assertIn("dap c3 " + axis, script)

    def test_rcs_execution_nulls_vgo_instead_of_sending_mnvr_exec(self):
        flight = FD13.__new__(FD13)
        flight.a = SimpleNamespace(rate=1.0)
        actions = []
        flight.wait_gmt = lambda gmt: (actions.append(("wait", gmt)),
                                       {"gmt": 171.5, "t": 102.5})[1]
        flight.wait_gmt_precise = lambda gmt: (actions.append(("wait-precise", gmt)),
                                               {"gmt": 100.0, "t": 31.0})[1]
        flight.play = lambda script, name: actions.append(("play", script, name))
        flight.script_done = lambda name, timeout: actions.append(("done", name))
        flight.null_vgo = lambda label, passes: (
            actions.append(("null-vgo", label, passes)) or
            {"x": 0.1, "y": -0.1, "z": 0.19})
        flight.say = lambda message: None
        flight.truth = lambda: {"gmt": 171.5, "t": 102.5}
        flight.take_snapshot = lambda name: actions.append(("snapshot", name))
        flight.vehdyn_capture = lambda name: {
            "sensed": [0.0, 0.0, 0.0] if name == "pre" else [10 * FT, 0.0, 0.0]}
        flight.save_result = lambda: None
        flight.result = {"burns": []}

        flight.execute_and_measure(
            {"name": "NC3", "gmt": 100.0, "unix": 200.0, "duration": 11.5, "engine": 4},
            [10 * FT, 0.0, 0.0], "pre")

        self.assertIn(("null-vgo", "nc3", RCS_VGO_NULL_PASSES), actions)
        self.assertIn(("wait-precise", 100.0), actions)
        self.assertFalse(any(a[0] == "play" for a in actions))
        self.assertNotIn(("wait", 70.0), actions)
        self.assertEqual(flight.result["burns"][0]["truth_at_exec"]["gmt"], 100.0)
        self.assertEqual(flight.result["burns"][0]["flight_rate"], 1.0)
        self.assertEqual(flight.result["burns"][0]["rcs_vgo_residual_fts"],
                         [0.1, -0.1, 0.19])
        self.assertTrue(flight.result["burns"][0]["rcs_vgo_trim_accepted"])
        self.assertEqual(flight.result["burns"][0]["rcs_null_start_gmt"], 100.0)
        self.assertEqual(flight.result["burns"][0]["rcs_null_end_gmt"], 171.5)
        self.assertEqual(flight.result["burns"][0]["rcs_null_elapsed_s"], 71.5)

    def test_large_rcs_null_samples_vgo_between_axis_holds(self):
        states = [
            (-10.0, 10.0, 0.0),
            (-5.0, 10.0, 0.0),
            (-5.0, 5.0, 0.0),
            (-0.1, 5.0, 0.0),
            (-0.1, 0.1, 0.0),
        ]
        events = []

        class Watch:
            def __init__(self):
                self.sample = 0

            def get(self, name):
                if name == "CGNV_DV_COUNT":
                    return 0
                axis = int(name.rsplit("$", 1)[1]) - 1
                value = states[self.sample][axis]
                events.append(("read", axis, self.sample))
                if axis == 2:
                    self.sample += 1
                return float(value)

        flight = rndz.Rendezvous.__new__(rndz.Rendezvous)
        flight.a = SimpleNamespace(pulse_trim=0.0)
        flight.thc_acc = dict(rndz.THC_ACC_SEED)
        flight.strk_watch = Watch
        flight.say = lambda message: None
        flight.play = lambda script, name: events.append(("play", script, name))
        flight.script_done = lambda name, timeout: None
        flight.wait_sim = lambda seconds: None

        final = flight.null_vgo("nc3", 4)

        commands = [event for event in events if event[0] == "play"]
        self.assertEqual([event[2] for event in commands],
                         ["nc3-null-0", "nc3-null-1", "nc3-null-2", "nc3-null-3"])
        self.assertIn("thc fwd -x", commands[0][1])
        self.assertIn("thc fwd +y", commands[1][1])
        self.assertEqual(final, {"x": -0.1, "y": 0.1, "z": 0.0})
        first_y = events.index(commands[1])
        self.assertEqual(sum(1 for event in events[:first_y] if event[0] == "read"), 6)


    def test_vgo_trim_offsets_keep_thc_holds_contiguous_at_three_x(self):
        flight = FD13.__new__(FD13)
        flight.a = SimpleNamespace(rate=3.0, pulse_trim=0.0)
        flight.thc_acc = {"+x": 1.0, "+y": 1.0, "+z": 1.0}
        scripts = []

        class Watch:
            def __init__(self):
                self.vector = 0

            def get(self, key):
                if key == "CGNV_DV_COUNT":
                    return 0
                if key.startswith("CGZV_VGO$"):
                    axis = int(key[-1]) - 1
                    value = ([100.0, 100.0, 100.0] if self.vector == 0 else
                             [0.0, 0.0, 0.0])[axis]
                    if axis == 2:
                        self.vector += 1
                    return value
                return None

        flight.strk_watch = lambda: Watch()
        flight.play = lambda script, name: scripts.append(script)
        flight.script_done = lambda name, timeout: None
        flight.wait_sim = lambda seconds: None
        flight.say = lambda message: None
        flight.null_vgo("nc3", 1)
        lines = scripts[0].splitlines()
        self.assertEqual(lines, [
            "+0.00   thc fwd +x 12.00",
            "+12.30   thc fwd +y 12.00",
            "+24.60   thc fwd +z 12.00",
        ])

class FromLaunchTests(unittest.TestCase):
    def test_ascent_start_requests_virtual_hand_controllers(self):
        with tempfile.TemporaryDirectory(prefix="fd13-ascent-start-") as temporary:
            args = SimpleNamespace(
                crts=2, tape="ascent.mmv", port_base=61240, logs=temporary,
                duration=1000, rate=2.0, no_splash=True, portview=False,
                portview_views=None, hold_start=False, layout=None, abort=None)
            flight = fly_sts134.Flight(args)
            flight.leave_nothing_running = lambda: None
            flight.wait_file = lambda *args: None
            with mock.patch.object(fly_sts134.subprocess, "Popen") as popen, \
                 mock.patch.object(fly_sts134.time, "sleep"):
                flight.start()
                command = popen.call_args.args[0]
            self.assertEqual(command[command.index("--rhc") + 1], "lh")
            self.assertEqual(command[command.index("--input") + 1], "virtual")
            flight.out.close()

    def test_ascent_and_fd13_share_one_simulator_instance(self):
        phases = fly_sts134.PHASES[:fly_sts134.PHASES.index("OPS2") + 1]
        actions = []
        methods = {
            phase.lower(): (lambda flight, name=phase.lower(): actions.append(("phase", name)))
            for phase in phases
        }
        methods["start"] = lambda flight, resume: actions.append(("start", resume))
        methods["snapshot"] = lambda flight, name: actions.append(("snapshot", name))
        fake_flight = type("FakeAscentFlight", (), methods)
        flight = FD13.__new__(FD13)
        flight.a = SimpleNamespace(from_launch=True)
        flight.base = 59240
        flight.rndz_environment = lambda: {"NSTS_NO_AUDIO": "1", "YAGPC_MDM_DEVICES": "1"}
        flight.say = lambda message: None
        flight.cw_start = lambda: actions.append(("rendezvous-cw-start",))
        old_name = fly_sts134.FL.get("name")

        with mock.patch.dict(os.environ, {"YAGPC_VEHDYN_START_REL": "stale"}), \
             mock.patch.object(fly_sts134, "Flight", fake_flight), \
             mock.patch.object(rndz, "Ears", side_effect=lambda base: ("rndz-ears", base)):
            try:
                FD13.start(flight, resume=None)
                flight.ascent_to_ops2()
                self.assertEqual(os.environ["NSTS_NO_AUDIO"], "1")
                self.assertNotIn("YAGPC_VEHDYN_START_REL", os.environ)
                self.assertEqual(flight.ears, ("rndz-ears", flight.base))
            finally:
                if old_name is None:
                    fly_sts134.FL.pop("name", None)
                else:
                    fly_sts134.FL["name"] = old_name

        expected = [("start", None)]
        for phase in phases:
            expected.extend((("phase", phase.lower()), ("snapshot", phase.lower())))
        expected.append(("rendezvous-cw-start",))
        self.assertEqual(actions, expected)


class FromFd13StartTests(unittest.TestCase):
    def test_rendezvous_resumes_capture_without_synthesized_start_state(self):
        with tempfile.TemporaryDirectory(prefix="fd13-rndz-start-") as temporary:
            capture = os.path.join(temporary, "sts134r-nc4-plus-2-min")
            logs = os.path.join(temporary, "logs")
            os.mkdir(capture)
            flight = rndz.Rendezvous.__new__(rndz.Rendezvous)
            flight.a = SimpleNamespace(
                from_fd13=capture, zero_sensor_bias=False, lambert_mc=False,
                dass_iloads=None, crts=2, rate=1.0, portview=False, views=None,
                tape="ascent-tape.mmv", rhc="lh", logs=logs, hold_start=False,
                station="all", input=None, layout=None, layout_aft=None,
                targets="targets.txt")
            flight.base = 59240
            flight.seed_imu_rm = lambda resume: setattr(flight, "seeded_from", resume)
            flight.leave_nothing_running = lambda: None
            flight.wait_file = lambda *args: None

            with mock.patch.dict(os.environ, {"YAGPC_VEHDYN_START_REL": "stale"}), \
                 mock.patch.object(rndz, "Ears", return_value=object()), \
                 mock.patch.object(rndz.Rendezvous, "cw_start"), \
                 mock.patch.object(rndz.threading, "Thread"), \
                 mock.patch.object(rndz.time, "sleep"), \
                 mock.patch.object(rndz.subprocess, "Popen") as popen:
                try:
                    rndz.Rendezvous.start(flight)
                    command = popen.call_args.args[0]
                    environment = popen.call_args.kwargs["env"]
                    resume_at = command.index("--snapshot-resume")
                    resume_copy = os.path.join(logs, "resume-fd13")
                    self.assertEqual(command[resume_at + 1], resume_copy)
                    self.assertEqual(flight.seeded_from, resume_copy)
                    self.assertNotIn("--date-time-epoch", command)
                    self.assertNotIn("YAGPC_VEHDYN_START_REL", environment)
                    self.assertEqual(environment["NSTS_NO_AUDIO"], "1")
                finally:
                    flight.out.close()

    def test_fd13_ops2_resume_requests_virtual_hand_controllers(self):
        with tempfile.TemporaryDirectory(prefix="fd13-stage-start-") as temporary:
            flight = FD13.__new__(FD13)
            flight.a = SimpleNamespace(from_launch=False, crts=2, tape="ascent.mmv",
                                       rate=2.0, logs=temporary)
            flight.base = 62240
            flight.rndz_environment = lambda: {"NSTS_NO_AUDIO": "1"}
            flight.leave_nothing_running = lambda: None
            flight.wait_file = lambda *args: None
            flight.cw_start = lambda: None
            with mock.patch.object(rndz, "Ears", return_value=object()), \
                 mock.patch.object(fly_fd13.subprocess, "Popen") as popen, \
                 mock.patch.object(fly_fd13.time, "sleep"):
                flight.start("resume-capture")
                command = popen.call_args.args[0]
            self.assertEqual(command[command.index("--rhc") + 1], "lh")
            self.assertEqual(command[command.index("--input") + 1], "virtual")
            flight.out.close()

    def test_rendezvous_constructor_creates_log_directory(self):
        with tempfile.TemporaryDirectory(prefix="fd13-rndz-logs-") as temporary:
            logs = os.path.join(temporary, "new-logs")
            flight = rndz.Rendezvous(SimpleNamespace(logs=logs, port_base=59240))
            try:
                self.assertTrue(pathlib.Path(logs, "rndz-check.log").is_file())
            finally:
                flight.checklog.close()

class FromFd13MainTests(unittest.TestCase):
    def test_failed_simulator_start_does_not_quit_existing_port_owner(self):
        with tempfile.TemporaryDirectory(prefix="fd13-port-collision-") as temporary:
            tape = os.path.join(temporary, "tape.mmv")
            targets = os.path.join(temporary, "targets.txt")
            pathlib.Path(tape).write_bytes(b"fixture tape")
            pathlib.Path(targets).write_text("fixture targets\n")
            instances = []
            actions = []

            class FakeFD13:
                def __init__(self, args):
                    self.a = args
                    self.result = {"status": "running", "errors": []}
                    self.proc = None
                    instances.append(self)

                def save_result(self):
                    pass

                def resume_copy(self):
                    actions.append("resume-copy")
                    return None

                def preflight_resume_setup(self, _resume):
                    actions.append("preflight")

                def start(self, _resume):
                    actions.append("start")
                    self.proc = mock.Mock()
                    self.proc.poll.return_value = 1  # simulatePASS refused an occupied base
                    raise RuntimeError("a previous run is still up on this port base")

            argv = ["fly_fd13.py", "--logs", os.path.join(temporary, "logs"),
                    "--tape", tape, "--targets", targets]
            with mock.patch.object(sys, "argv", argv), \
                 mock.patch.object(fly_fd13, "FD13", FakeFD13), \
                 mock.patch.object(fly_fd13.crewscript, "send_session") as send_session, \
                 mock.patch.dict(os.environ, {}, clear=False):
                with self.assertRaisesRegex(RuntimeError, "previous run is still up"):
                    fly_fd13.main()
            self.assertEqual(len(instances), 1)
            self.assertEqual(actions, ["resume-copy", "preflight", "start"])
            instances[0].proc.wait.assert_called_once_with(timeout=120)
            send_session.assert_not_called()

    def test_main_defaults_to_and_records_rcs_pulse_trim(self):
        with tempfile.TemporaryDirectory(prefix="fd13-pulse-trim-main-") as temporary:
            tape = os.path.join(temporary, "tape.mmv")
            targets = os.path.join(temporary, "targets.txt")
            pathlib.Path(tape).write_bytes(b"fixture tape")
            pathlib.Path(targets).write_text("fixture targets\n")
            instances = []

            class FakeFD13:
                def __init__(self, args):
                    self.a = args
                    self.result = {"status": "running", "errors": []}
                    self.proc = None
                    instances.append(self)

                def save_result(self):
                    pass

                def resume_copy(self):
                    return None

                def preflight_resume_setup(self, _resume):
                    pass

                def start(self, _resume):
                    pass

                def run_fd13(self):
                    pass

            def run(extra, logs):
                argv = ["fly_fd13.py", "--logs", logs, "--tape", tape,
                        "--targets", targets, *extra]
                with mock.patch.object(sys, "argv", argv), \
                     mock.patch.object(fly_fd13, "FD13", FakeFD13), \
                     mock.patch.dict(os.environ, {}, clear=False):
                    self.assertEqual(fly_fd13.main(), 0)
                return instances[-1]

            default = run([], os.path.join(temporary, "default"))
            self.assertEqual(default.a.pulse_trim, DEFAULT_RCS_PULSE_TRIM_FPS)
            self.assertEqual(default.result["rcs_pulse_trim_fps"],
                             DEFAULT_RCS_PULSE_TRIM_FPS)

            override = run(["--pulse-trim", "0"], os.path.join(temporary, "disabled"))
            self.assertEqual(override.a.pulse_trim, 0.0)
            self.assertEqual(override.result["rcs_pulse_trim_fps"], 0.0)

    def test_main_rejects_terminal_state_outside_acceptance_limits(self):
        with tempfile.TemporaryDirectory(prefix="fd13-main-terminal-gate-") as temporary:
            root = os.path.abspath(temporary)
            capture = os.path.join(root, "sts134r-nc4-plus-2-min")
            os.mkdir(capture)
            pathlib.Path(capture, "vehicle.json").write_text("{}\n")
            pathlib.Path(capture, "vehdyn.json").write_text(json.dumps({"vehdyn": [0.0] * 228}) + "\n")
            tape = os.path.join(root, "ascent.mmv")
            pathlib.Path(tape).write_bytes(b"fixture tape")
            result = {"status": "full-stage-complete", "tape": tape,
                      "final": {"gmt_utc": "2011-05-18T06:10:00", "gmt": 11945400.0,
                                "acceptance": {"accepted": False}},
                      "snapshots": [{"name": "nc4-plus-2-min", "path": capture}]}
            pathlib.Path(root, "RESULT.json").write_text(json.dumps(result))
            received = []

            class FakeRendezvous:
                def __init__(self, args):
                    received.append(args)
                def run(self):
                    pass

            argv = ["fly_rndz134.py", "--logs", os.path.join(root, "logs"),
                    "--from-fd13", capture]
            with mock.patch.object(sys, "argv", argv), \
                 mock.patch.object(rndz, "Rendezvous", FakeRendezvous), \
                 contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as error:
                    rndz.main()
            self.assertEqual(error.exception.code, 2)
            self.assertEqual(received, [])

    def test_main_accepts_only_recorded_terminal_capture_and_uses_its_tape(self):
        with tempfile.TemporaryDirectory(prefix="fd13-main-") as temporary:
            root = os.path.abspath(temporary)
            capture = os.path.join(root, "sts134r-nc4-plus-2-min")
            unrelated = os.path.join(root, "unrelated")
            os.mkdir(capture)
            os.mkdir(unrelated)
            for directory in (capture, unrelated):
                pathlib.Path(directory, "vehicle.json").write_text("{}\n")
                pathlib.Path(directory, "vehdyn.json").write_text(
                    json.dumps({"vehdyn": [0.0] * 228}) + "\n")
            tape = os.path.join(root, "ascent.mmv")
            pathlib.Path(tape).write_bytes(b"fixture tape")
            result = {
                "status": "full-stage-complete", "tape": tape,
                "final": {"gmt_utc": "2011-05-18T06:10:00", "gmt": 11945400.0,
                          "acceptance": {"accepted": True}},
                "snapshots": [{"name": "nc4-plus-2-min", "path": capture}],
            }
            with open(os.path.join(root, "RESULT.json"), "w") as out:
                json.dump(result, out)

            old_phases = list(fly_sts134.PHASES)
            old_name = fly_sts134.FL.get("name")
            received = []

            class FakeRendezvous:
                def __init__(self, args):
                    received.append(args)

                def run(self):
                    pass

            argv = ["fly_rndz134.py", "--logs", os.path.join(root, "logs"),
                    "--from-fd13", capture]
            try:
                with mock.patch.object(sys, "argv", argv), \
                     mock.patch.object(rndz, "Rendezvous", FakeRendezvous):
                    rndz.main()
                self.assertEqual(len(received), 1)
                self.assertEqual(received[0].from_, "UPLINK")
                self.assertEqual(received[0].from_fd13, capture)
                self.assertEqual(received[0].tape, tape)
                self.assertEqual(received[0].dass_iloads, "rndz")

                received.clear()
                patched_argv = ["fly_rndz134.py", "--logs", os.path.join(root, "patched-logs"),
                                "--from-fd13", capture, "--dass-iloads", "all"]
                with mock.patch.object(sys, "argv", patched_argv), \
                     mock.patch.object(rndz, "Rendezvous", FakeRendezvous):
                    rndz.main()
                self.assertEqual(len(received), 1)
                self.assertEqual(received[0].dass_iloads, "all")
                received.clear()

                values = [0.0] * 228
                values[112] = 1.0
                pathlib.Path(capture, "vehdyn.json").write_text(json.dumps({"vehdyn": values}))
                with mock.patch.object(sys, "argv", argv), \
                     mock.patch.object(rndz, "Rendezvous", FakeRendezvous), \
                     contextlib.redirect_stderr(io.StringIO()):
                    with self.assertRaises(SystemExit):
                        rndz.main()
                self.assertEqual(received, [])

                received.clear()
                bad_argv = ["fly_rndz134.py", "--logs", os.path.join(root, "bad-logs"),
                            "--from-fd13", unrelated]
                with mock.patch.object(sys, "argv", bad_argv), \
                     mock.patch.object(rndz, "Rendezvous", FakeRendezvous), \
                     contextlib.redirect_stderr(io.StringIO()):
                    with self.assertRaises(SystemExit) as error:
                        rndz.main()
                self.assertEqual(error.exception.code, 2)
                self.assertEqual(received, [])
            finally:
                fly_sts134.PHASES[:] = old_phases
                if old_name is None:
                    fly_sts134.FL.pop("name", None)
                else:
                    fly_sts134.FL["name"] = old_name


if __name__ == "__main__":
    unittest.main()
