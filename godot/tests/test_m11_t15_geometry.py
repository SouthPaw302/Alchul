"""Adversarial checks: no fake site sizes or biological approval may slip into T15."""
import copy
import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]/"tools"))
from validate_m11_t15_geometry import load, validate

class T15GeometrySafety(unittest.TestCase):
    def setUp(self):
        self.base=load()
    def reject(self,change):
        item=copy.deepcopy(self.base)
        change(item)
        self.assertTrue(validate(item))
    def test_baseline(self):
        self.assertEqual(validate(self.base),[])
    def test_approval_false(self):
        self.reject(lambda d:d["science_policy"].update({"creator_approval":True}))
    def test_calibrated_meters_false(self):
        self.reject(lambda d:d["science_policy"].update({"source_units_verified_meters":True}))
    def test_actual_geometry_required(self):
        self.reject(lambda d:d["science_policy"].update({"actual_glb_source_meshes":False}))
    def test_original_source_path_immutable(self):
        self.reject(lambda d:d["geometry_source_stages"][1].update({"path":"res://fake_nursery.glb"}))
    def test_real_GLB_source_all_stages_required(self):
        self.reject(lambda d:d["geometry_source_stages"].pop())
    def test_not_HC(self):
        self.reject(lambda d:d["candidate_ids"].append("H-C"))
    def test_ratio_evidence_not_calibrated(self):
        self.reject(lambda d:d["science_policy"].update({"body_to_asset_scale_established":True}))
    def test_finite_ratios(self):
        self.reject(lambda d:d["synthetic_unverified_body_to_asset_scale_factors"].append(float("inf")))
    def test_unique_probe_positions(self):
        self.reject(lambda d:d["sample_site_aabb_fractions"].append([0.1,0.1]))
    def test_probe_coords_bounded(self):
        self.reject(lambda d:d["sample_site_aabb_fractions"][2].__setitem__(0,2.0))
    def test_uncertainty_not_removed(self):
        self.reject(lambda d:d.update({"output_scope":"certified historical access"}))
    def test_modern_body_not_implied(self):
        self.reject(lambda d:d["science_policy"].update({"modern_descendant_body_known":True}))
if __name__=="__main__":
    unittest.main()
