"""T10 model contract tests. Passing never certifies animal biomechanics."""
from __future__ import annotations
import copy, json, math, pathlib, sys, unittest
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
import m11_t10_mechanics as m

class MechanicalChecks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config=json.loads(m.CONFIG.read_text())
        cls.rig=json.loads((ROOT/cls.config['source_rig']).read_text())
        cls.previous=json.loads((ROOT/cls.config['source_t08_t09_results']).read_text())
        cls.result=m.analyze(cls.config,cls.rig,cls.previous)

    def test_sources_match_exact_t07_geometry_and_status(self):
        self.assertEqual(cls_hash(self.rig),self.previous['input_rig_geometry_sha256'])
        self.assertEqual(self.result['source_T07_geometry_sha256'],self.previous['input_rig_geometry_sha256'])
        self.assertIn('NOT_BIOLOGICAL_VALIDATION',self.result['status'])

    def test_biological_certainty_escalation_rejected(self):
        c=copy.deepcopy(self.config);c['status']='validated_species'
        with self.assertRaises(ValueError):m.analyze(c,self.rig,self.previous)
        r=copy.deepcopy(self.rig);r['bodies'][0]['bones'][0]['anchor'][0]+=0.1
        with self.assertRaises(ValueError):m.analyze(self.config,r,self.previous)

    def test_contact_assumption_has_exact_2D_equilibrium(self):
        for key,row in self.result['candidates'].items():
            x=row['force_checks']['supported_fixture']
            self.assertTrue(x['near_reachable_from_T09'])
            self.assertTrue(x['equilibrium_feasible_assumed'])
            self.assertLess(x['resultant_wrench_residual'],1e-5)
            self.assertTrue(x['normal_strength_pass'])
            self.assertTrue(x['torque_proxy_pass'])
            self.assertTrue(x['friction_pass'])
            self.assertEqual(len(x['fingers']),3)
            self.assertEqual({v['digit'] for v in x['fingers']},set(m.DIGITS))

    def test_without_wall_not_a_free_grip(self):
        for row in self.result['candidates'].values():
            x=row['force_checks']['unsupported_no_wall']
            self.assertFalse(x['equilibrium_feasible_assumed'])
            self.assertFalse(x['backing_wall'])

    def test_slippery_and_torque_weakened_fail_closed(self):
        for row in self.result['candidates'].values():
            self.assertFalse(row['force_checks']['slippery_wet_fixture']['equilibrium_feasible_assumed'])
            self.assertFalse(row['force_checks']['very_weak_finger_joint']['equilibrium_feasible_assumed'])

    def test_ring_is_explicit_hypothetical_not_real_hand(self):
        for row in self.result['candidates'].values():
            x=row['force_checks']['hypothetical_ring_clamp']
            self.assertTrue(x['equilibrium_feasible_conditional'])
            self.assertLess(x['residual_wrench'],1e-5)
            self.assertFalse(x['all_three_contacts_reachable_with_T07'])
            self.assertFalse(x['force_closure_verified'])
            self.assertFalse(row['force_checks']['hypothetical_ring_low_friction']['equilibrium_feasible_conditional'])

    def test_step_phases_require_mass_shift_but_not_dynamic_gait(self):
        for row in self.result['candidates'].values():
            r=row['stepping']
            self.assertFalse(r['no_shift_one_foot_inside'])
            self.assertTrue(r['modelled_shift_feasible'])
            self.assertGreater(r['required_com_lateral_shift_for_0p025_margin'],0)
            self.assertEqual(len(r['phases']),6)
            self.assertTrue(all(phase['within_assumed_contact'] for phase in r['phases']))

    def test_substrate_friction_negative_control(self):
        for row in self.result['candidates'].values():
            x=row['stepping']['friction_cases']
            self.assertTrue(x['wet_stone']['no_slip_proxy'])
            self.assertFalse(x['slippery_mud']['no_slip_proxy'])

    def test_pedal_digit_two_is_not_weightbearing_assumption(self):
        bad=copy.deepcopy(self.config);bad['locomotion']['supported_digits'].append('II')
        with self.assertRaises(ValueError):m.analyze(bad,self.rig,self.previous)

    def test_tail_clearance_sensitivity_and_monotonic_width(self):
        a=self.result['candidates']['H-A']['corner_clearance']
        b=self.result['candidates']['H-B']['corner_clearance']
        self.assertGreater(a['first_passing_width_IN_TEST_GRID'],b['first_passing_width_IN_TEST_GRID'])
        for val in (a,b):
            widths=val['width_results']
            self.assertTrue(widths[-1]['clearance_pass'])
            self.assertFalse(widths[0]['clearance_pass'])
            passed=False
            for x in widths:
                passed=passed or x['clearance_pass']
                if passed:self.assertTrue(x['clearance_pass'])

    def test_shortening_tail_reduces_required_corridor_width(self):
        v=self.config['clearance'];A=m.anchors(self.rig['bodies'][0]);B=m.anchors(self.rig['bodies'][1])
        threshold_A=next(w for w in v['corridor_test_widths_normalized'] if m.turn_clearance(A,v,w)['clearance_pass'])
        for i in range(1,5):A[f'caudal_0{i}']=B[f'caudal_0{i}']
        threshold_short=next(w for w in v['corridor_test_widths_normalized'] if m.turn_clearance(A,v,w)['clearance_pass'])
        self.assertLess(threshold_short,threshold_A)

    def test_recomputation_is_identical(self):
        self.assertEqual(m.analyze(self.config,self.rig,self.previous),self.result)


def cls_hash(rig):
    import hashlib
    data=[{'id':b['id'],'bones':b['bones']} for b in rig['bodies']]
    return hashlib.sha256(json.dumps(data,sort_keys=True,separators=(',',':')).encode()).hexdigest()

if __name__=='__main__': unittest.main()
