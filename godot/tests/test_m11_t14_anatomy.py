import copy
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from validate_m11_t14_anatomy import load_review, validate


class DecisionSafetyTest(unittest.TestCase):
    def setUp(self):
        self.data = load_review()

    def mutate(self, fn):
        variant = copy.deepcopy(self.data)
        fn(variant)
        self.assertNotEqual(validate(variant), [])

    def test_authoritative_contract(self):
        self.assertEqual(validate(self.data), [])

    def test_cannot_approve_self(self):
        self.mutate(lambda d: d.update(current_decision="provisional_H-B"))

    def test_production_flag_rejected(self):
        self.mutate(lambda d: d.update(status="APPROVED"))

    def test_unapproved_gate_must_remain(self):
        self.mutate(lambda d: d.update(prohibited_unapproved_promotion=False))

    def test_present_descendants_not_surface_copy(self):
        self.mutate(lambda d: d.update(present_day_body_specified=True))

    def test_era_does_not_extend_to_modern(self):
        self.mutate(lambda d: d.update(era_scope="2026 present"))

    def test_hybrid_has_no_numbers(self):
        self.mutate(lambda d: d["comparisons"][2].update(
            first_sampled_clear_corridor_width_normalized=3.2))

    def test_cannot_invent_tail_benefit(self):
        self.mutate(lambda d: d["comparisons"][0].update(
            violations_at_2p8_of_101=0))

    def test_no_automatic_biology_approval(self):
        self.mutate(lambda d: d["comparisons"][1].update(
            scientific_approval=True))

    def test_source_evidence_must_not_collapse(self):
        self.mutate(lambda d: d.update(evidence_classes=["fictional_canon"]))

    def test_creator_gate_cannot_pass(self):
        self.mutate(lambda d: d["gates"][5].update(status="approved"))

    def test_real_physical_scale_not_inferred(self):
        self.mutate(lambda d: d["comparisons"][0].update(length_claim="2.3 meters"))

    def test_defer_option_always_available(self):
        self.mutate(lambda d: d.update(review_options=["provisional_H-A"]))


if __name__ == "__main__":
    unittest.main()
