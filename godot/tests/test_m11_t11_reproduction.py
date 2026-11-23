"""Reproducibility, adversarial controls and scientific-boundary tests for T11."""
import copy
import importlib.util
from pathlib import Path
import unittest

TOOL_PATH = Path(__file__).resolve().parents[1] / "tools" / "m11_t11_reproduction.py"
spec = importlib.util.spec_from_file_location("m11_t11_reproduction", TOOL_PATH)
t11 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(t11)


class T11ConstraintTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = t11.read_json(t11.CONFIG)
        cls.results = t11.build_results(cls.config)

    def test_canon_fraction_and_stage_definition(self):
        self.assertEqual(self.results["canon_fraction_internal"], 0.75)
        self.assertIn("not chronological", self.config["fixed_canon"]["definition"])
        self.assertIn("not chronological", self.results["stage_definition"])

    def test_canon_change_rejected(self):
        altered = copy.deepcopy(self.config)
        altered["fixed_canon"]["fraction_internal_development"] = 0.8
        with self.assertRaises(ValueError):
            t11.build_results(altered)

    def test_scientific_certification_rejected(self):
        altered = copy.deepcopy(self.config)
        altered["scientific_status"] = "biologically_proven_viable"
        with self.assertRaises(ValueError):
            t11.build_results(altered)

    def test_normalized_demand_not_real_units(self):
        self.assertAlmostEqual(t11.demand(0.0, self.config["model"]), 0.18)
        self.assertAlmostEqual(t11.demand(0.75, self.config["model"]), 0.64125)
        self.assertAlmostEqual(t11.demand(1.0, self.config["model"]), 1.0)
        self.assertIn("NOT partial pressure", self.results["units"])

    def test_reference_passes_only_algebraic_screen(self):
        scenario = self.results["scenarios"]["reference"]
        self.assertTrue(scenario["screening_pass"])
        self.assertTrue(all(scenario["constraints"].values()))
        self.assertIn("never a viability prediction", scenario["meaning"])

    def test_hypoxia_internal_fails(self):
        s = self.results["scenarios"]["internal_hypoxia"]
        self.assertFalse(s["constraints"]["internal_oxygen_index"])
        self.assertGreater(self.results["scenarios"]["reference"]["minimum_internal_oxygen_margin"], 0)

    def test_restricted_transfer_internal_fails(self):
        s = self.results["scenarios"]["restrictive_internal_transfer"]
        self.assertFalse(s["constraints"]["internal_oxygen_index"])
        self.assertTrue(s["constraints"]["external_oxygen_index"])

    def test_stagnant_nursery_external_fails(self):
        s = self.results["scenarios"]["stagnant_nursery"]
        self.assertFalse(s["constraints"]["external_oxygen_index"])
        self.assertTrue(s["constraints"]["internal_oxygen_index"])

    def test_maternal_burden_fails_separately(self):
        s = self.results["scenarios"]["excessive_maternal_load"]
        self.assertFalse(s["constraints"]["maternal_load_index"])
        self.assertTrue(s["constraints"]["internal_oxygen_index"])

    def test_humidity_and_heat_independent(self):
        dry = self.results["scenarios"]["desiccating_nursery"]["constraints"]
        hot = self.results["scenarios"]["overheated_nursery"]["constraints"]
        self.assertFalse(dry["nursery_moisture_index"])
        self.assertTrue(dry["nursery_heat_index"])
        self.assertFalse(hot["nursery_heat_index"])
        self.assertTrue(hot["nursery_moisture_index"])

    def test_all_negative_controls_are_rejected(self):
        for key in t11.REQUIRED_SCENARIOS[1:]:
            with self.subTest(key=key):
                self.assertFalse(self.results["scenarios"][key]["screening_pass"])

    def test_profile_contains_retention_transition(self):
        stages = [x["stage"] for x in self.results["reference_profile"]]
        self.assertEqual(len(stages), 21)
        self.assertIn(0.75, stages)
        self.assertEqual(stages[0], 0.0)
        self.assertEqual(stages[-1], 1.0)

    def test_tracked_report_matches_deterministic_output(self):
        self.assertTrue(t11.equal_nested(t11.read_json(t11.RESULTS), self.results))

    def test_no_unjustified_organ_or_fixed_clutch_claim(self):
        text = str(self.config).lower()
        self.assertIn("known eggshell", text)
        self.assertIn("fixed clutch size", text)
        self.assertIn("sexual or social roles", text)
        self.assertNotIn("gestation_days", text)
        self.assertNotIn("organ_mesh", text)

    def test_missing_assumption_fails_closed(self):
        altered = copy.deepcopy(self.config)
        del altered["scenarios"]["reference"]["internal_conductance"]
        with self.assertRaises(ValueError):
            t11.build_results(altered)

    def test_invalid_gradient_fails_closed(self):
        altered = copy.deepcopy(self.config)
        altered["scenarios"]["reference"]["internal_gradient"] = 1.5
        with self.assertRaises(ValueError):
            t11.build_results(altered)


if __name__ == "__main__":
    unittest.main()
