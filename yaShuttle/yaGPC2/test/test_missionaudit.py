"""Source precedence and evidence extraction, independent of a live simulator."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('missionaudit', Path(__file__).resolve().parents[1] / 'tools/missionaudit.py')
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


class EvidenceTests(unittest.TestCase):
    def read(self, text):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / 'flight.log'
            p.write_text(text)
            return audit.entry_measurements(p)

    def test_first_touchdown_brakes_and_missing_observables(self):
        values, _ = self.read('vehdyn: LEFT MAIN gear TOUCHDOWN at t=100.00: ground speed 195.3 kt, sink 1.21 ft/s\n'
                              'vehdyn: RIGHT MAIN gear TOUCHDOWN at t=100.02: ground speed 195.2 kt, sink 1.20 ft/s\n'
                              'vehdyn: LEFT MAIN gear TOUCHDOWN at t=102.00: ground speed 180.0 kt, sink 0.5 ft/s\n'
                              'vehdyn: BRAKES on at t=116.76\n')
        self.assertEqual(values['td_kgs'], 195.3)
        self.assertEqual(values['td_sink'], 1.21)
        self.assertAlmostEqual(values['brake_td'], 16.76)
        self.assertNotIn('td_keas', values)
        self.assertNotIn('rollout_s', values)

    def test_setup_does_not_prove_navigation_incorporation(self):
        values, _ = self.read('landaids: 2 runway(s), 2 MLS site(s) from sites.txt\nGPS receiver available\n'
                              'vehdyn-entry: t=10.0 h=16300 ft M=0.5\n')
        self.assertNotIn('mls_alt', values)
        self.assertNotIn('gps_alt', values)
        self.assertNotIn('adta_mach', values)

    def test_deployment_nearby_sample_has_offset(self):
        values, notes = self.read('vehdyn-entry: t=10.0 h=140000 ft M=5.0\n'
                                  'vehdyn: left air data probe DEPLOYING at t=11.0\n'
                                  'vehdyn-entry: t=12.0 h=138000 ft M=4.9\n')
        self.assertIn(values['deploy_mach'], [5.0, 4.9])
        self.assertIn('sample', notes['deploy_mach'])

    def test_distant_sample_does_not_supply_deployment_mach(self):
        values, _ = self.read('vehdyn-entry: t=10.0 h=140000 ft M=5.0\n'
                              'vehdyn: left air data probe DEPLOYING at t=20.0\n')
        self.assertNotIn('deploy_mach', values)

    def test_explicit_navigation_statements(self):
        values, _ = self.read('ADTA incorporated Mach 3.0\nGPS incorporated EI+1244 s h=153000 ft\n'
                              'MLS INCORPORATED h=16300 ft\n')
        self.assertEqual(values['adta_mach'], 3.0)
        self.assertEqual(values['gps_ei'], 1244)
        self.assertEqual(values['gps_alt'], 153000)
        self.assertEqual(values['mls_alt'], 16300)

    def test_oms2_is_not_mislabeled_as_deorbit(self):
        values, _ = self.read('vehdyn: t=100.0 s left OMS ON\nvehdyn: t=268.6 s left OMS off\n'
                              'ENTRY INTERFACE t=5000\n')
        self.assertNotIn('deorbit_s', values)

    def test_deorbit_engine_pair_is_not_mixed(self):
        values, _ = self.read('DEORBIT start at t=100\nvehdyn: t=100.0 s left OMS ON\n'
                              'vehdyn: t=100.2 s right OMS ON\nvehdyn: t=259.2 s left OMS off\n'
                              'vehdyn: t=260.0 s right OMS off\nENTRY INTERFACE t=1000\n')
        self.assertAlmostEqual(values['deorbit_s'], 159.8)

    def test_source_conflicts_do_not_mutate_original_rows(self):
        r = dict(event='Main Engine Cutoff (MECO)', description='MECO Command Flag',
                 report_met=501.006, sim_met=504.0, diff=2.994, flag=True, note='')
        before = dict(r)
        alternatives = audit.summary_alternatives([r])[0]
        self.assertEqual(r, before)
        self.assertEqual([x['report_met'] for x in alternatives], [501.5, 501.8])
        self.assertTrue(all('source conflict' in x['note'] for x in alternatives))

    def test_secondary_value_keeps_quantity_units(self):
        r = dict(event='Main touchdown ground speed', sim_met=207.6, report_met=195.3,
                 units='KGS', description='KGS', diff=12.3, flag=False, note='')
        alt = audit.entry_alternatives(r)[0]
        self.assertEqual(alt['units'], 'KGS')
        self.assertEqual(alt['report_met'], 196.0)
        self.assertEqual(r['report_met'], 195.3)


if __name__ == '__main__':
    unittest.main()
