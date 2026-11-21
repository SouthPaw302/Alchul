#!/usr/bin/env python3
"""T08-T09 software tests. Passing is NOT proof of an extinct animal's biomechanics."""
import copy
import json
import math
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
import m11_t08_t09_analysis as study


class StudyContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = json.loads(study.CONFIG_PATH.read_text('utf-8'))
        cls.rig = json.loads((ROOT / cls.config['input_rig']).read_text('utf-8'))
        cls.result = study.analyze(cls.config, cls.rig)

    def test_schema_preserves_uncertainty(self):
        self.assertEqual(self.result['schema'], 'alchul.m11.t08-t09.results.v1')
        self.assertIn('NOT_FOSSIL_DATA', self.result['status'])
        self.assertIn('not_meters', self.result['units'])

    def test_profiles_normalized_and_named(self):
        self.assertEqual(set(self.result['t08']), {'H-A', 'H-B'})
        for key in ('H-A', 'H-B'):
            self.assertAlmostEqual(sum(self.config['com_profiles'][key].values()), 1.0)
            self.assertEqual(set(self.config['com_profiles'][key]), set(study.REGIONS))
            self.assertEqual(len(self.result['t08'][key]['cases']), 4)

    def test_bilateral_static_support_is_not_one_foot_support(self):
        for key in ('H-A','H-B'):
            cases = self.result['t08'][key]['cases']
            self.assertTrue(cases['two_feet_neutral']['proxy_static_inside_box'])
            self.assertFalse(cases['right_foot_only']['proxy_static_inside_box'])
            self.assertGreater(cases['two_feet_neutral']['signed_margin'], 0)
            self.assertLess(cases['right_foot_only']['signed_margin'], 0)

    def test_shift_tail_mass_changes_center_location(self):
        for key in ('H-A','H-B'):
            row=self.result['t08'][key]
            self.assertGreater(row['tail_halved_com_x'], row['tail_1p5x_com_x'])
            self.assertEqual(row['sensitivity_neutral']['samples'], 256)
            self.assertGreaterEqual(row['sensitivity_neutral']['fraction_positive'], 0)
            self.assertLessEqual(row['sensitivity_neutral']['fraction_positive'], 1)

    def test_three_distinct_nonopposable_tips_near_and_far(self):
        for key in ('H-A','H-B'):
            near=self.result['t09'][key]['near']
            far=self.result['t09'][key]['far']
            self.assertEqual(set(near['digits']), {'I','II','III'})
            self.assertEqual(near['contact_count'], 3)
            self.assertEqual(far['contact_count'], 0)
            self.assertTrue(near['all_three_close'])
            self.assertFalse(far['all_three_close'])
            self.assertLessEqual(near['maximum_contact_error'], near['tolerance'])
            self.assertIn('forearm_axial_pronation', self.result['t09'][key]['excluded_controls'])
            self.assertIn('human_thumb_opposition', self.result['t09'][key]['excluded_controls'])

    def test_repeated_analysis_is_deterministic(self):
        other=study.analyze(self.config,self.rig)
        self.assertEqual(other,self.result)

    def test_invalid_fossil_status_fails_closed(self):
        tamper=copy.deepcopy(self.config)
        tamper['status']='approved_science'
        with self.assertRaises(ValueError):
            study.analyze(tamper,self.rig)

    def test_out_of_range_joint_samples_are_rejected(self):
        tamper=copy.deepcopy(self.config)
        tamper['grasp']['wrist_yaw_samples_deg'].append(180)
        points=study.anchors(self.rig['bodies'][0])
        with self.assertRaises(ValueError):
            study.solve_three_digit_fixture(points,self.rig['joints'],tamper['grasp'])

    def test_mass_total_error_rejected(self):
        points=study.anchors(self.rig['bodies'][0]);centers=study.mass_centers(points)
        weights=copy.deepcopy(self.config['com_profiles']['H-A']);weights['tail']+=.1
        with self.assertRaises(ValueError):
            study.center_of_mass(centers,weights,'two_feet_neutral',{})


if __name__=='__main__':
    unittest.main()
