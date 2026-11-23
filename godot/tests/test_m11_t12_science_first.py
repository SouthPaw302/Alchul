"""T12 evidence-before-fiction, deep-time chronology, six-person safeguards."""
import copy
import importlib.util
from pathlib import Path
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "validate_m11_t12_science_first.py"
spec = importlib.util.spec_from_file_location("t12_checker", SCRIPT)
t12 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(t12)


class ScienceFirstT12Tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.earth = t12.load(t12.EARTH_PATH)
        cls.people = t12.load(t12.PEOPLE_PATH)

    def test_baseline_reproduces(self):
        summary = t12.validate(self.earth, self.people)
        self.assertEqual(summary["era_count"], 9)
        self.assertEqual(summary["role_count"], 6)
        self.assertEqual(summary["present_endpoint"], "2026 CE")

    def test_explicit_real_nonavian_extinction(self):
        out = t12.validate(self.earth, self.people)
        self.assertFalse(out["real_nonavian_survival_observed"])
        self.assertEqual(out["boundary_ma"], 66)

    def test_intraplate_facts_not_plate_free(self):
        self.assertIn("within the North American plate",
                      self.earth["authority_policy"]["real_present_day"])
        self.assertIn("intraplate", self.earth["eras"][-1]["real_world"]["summary"].lower())

    def test_reject_survival_claim_as_fossil(self):
        v = copy.deepcopy(self.earth)
        v["authority_policy"]["surviving_non_avian_dinosaurs_claimed"] = True
        with self.assertRaises(t12.ContractError):
            t12.validate(v, self.people)

    def test_reject_fake_civilization_evidence(self):
        v = copy.deepcopy(self.earth)
        v["authority_policy"]["hidden_civilization_evidence_claimed"] = True
        with self.assertRaises(t12.ContractError):
            t12.validate(v, self.people)

    def test_reject_invented_present_anatomy(self):
        v = copy.deepcopy(self.earth)
        v["eras"][-1]["fiction"]["body_reconstructed"] = True
        with self.assertRaises(t12.ContractError):
            t12.validate(v, self.people)

    def test_reject_plate_free_earthquakes(self):
        v = copy.deepcopy(self.earth)
        v["authority_policy"]["real_present_day"] = "New Madrid is outside plate tectonics."
        with self.assertRaises(t12.ContractError):
            t12.validate(v, self.people)

    def test_reject_missing_cenozoic_era(self):
        v = copy.deepcopy(self.earth)
        v["eras"] = [e for e in v["eras"] if e["id"] != "neogene"]
        with self.assertRaises(t12.ContractError):
            t12.validate(v, self.people)

    def test_reject_age_boundary_without_review(self):
        v = copy.deepcopy(self.earth)
        v["eras"][3]["start_ma"] = 64.0
        with self.assertRaises(t12.ContractError):
            t12.validate(v, self.people)

    def test_missing_real_world_references_rejected(self):
        v = copy.deepcopy(self.earth)
        v["eras"][1]["real_world"]["source_urls"] = []
        with self.assertRaises(t12.ContractError):
            t12.validate(v, self.people)

    def test_all_roles_are_distinct_without_caste(self):
        roles = self.people["roles"]
        self.assertEqual(len({p["id"] for p in roles}), 6)
        self.assertEqual(len({p["activity"] for p in roles}), 6)
        self.assertTrue(all(p["specialist_is_caste"] is False for p in roles))

    def test_egg_bearer_not_nursery_caretaker(self):
        byid = {p["id"]: p for p in self.people["roles"]}
        self.assertNotEqual(byid["egg_bearing_adult"]["id"], byid["nursery_worker"]["id"])
        self.assertFalse(byid["egg_bearing_adult"]["sex_or_gender_inferred"])
        self.assertFalse(byid["nursery_worker"]["sex_or_gender_inferred"])

    def test_juvenile_is_not_scaled_adult_approval(self):
        byid = {p["id"]: p for p in self.people["roles"]}
        self.assertEqual(byid["juvenile_learner"]["life_stage"], "juvenile")
        self.assertFalse(byid["juvenile_learner"]["body_plan_approved"])

    def test_reject_assigning_humanlike_reproductive_caste(self):
        v = copy.deepcopy(self.people)
        v["roles"][2]["specialist_is_caste"] = True
        with self.assertRaises(t12.ContractError):
            t12.validate(self.earth, v)

    def test_reject_role_promoted_to_science(self):
        v = copy.deepcopy(self.people)
        v["roles"][0]["body_plan_approved"] = True
        with self.assertRaises(t12.ContractError):
            t12.validate(self.earth, v)

    def test_reject_present_day_role_extrapolation(self):
        v = copy.deepcopy(self.people)
        v["roles"][5]["post_kpg_body_claimed"] = True
        with self.assertRaises(t12.ContractError):
            t12.validate(self.earth, v)

    def test_reject_made_up_peak_date(self):
        v = copy.deepcopy(self.people)
        v["selected_era_scope"] = "70Ma_exact"
        with self.assertRaises(t12.ContractError):
            t12.validate(self.earth, v)

    def test_reject_removed_t11_continuity(self):
        v = copy.deepcopy(self.people)
        v["roles"][2]["required_models"] = ["other_model"]
        with self.assertRaises(t12.ContractError):
            t12.validate(self.earth, v)


if __name__ == "__main__":
    unittest.main()
