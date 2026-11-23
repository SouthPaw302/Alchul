#!/usr/bin/env python3
"""T15 source-GLB geometry audit contract, not a unit-calibrated site clearance test."""
from __future__ import annotations
import json
import math
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
CONFIG=ROOT/"data/m11_t15_settlement_probes.json"
RIG=ROOT/"data/m11_t07_skeletal_reference.json"
STATUS="UNSCALED_ORIGINAL_MESH_INTERSECTIONS_NOT_TRAVERSABILITY"
SOURCES={
    "M2":"res://assets/m2/ALC_M2_RIVER_STATION_v001.glb",
    "M3":"res://assets/m3/ALC_M3_NURSERY_CIRCULATION_v001.glb",
    "M4":"res://assets/m4/ALC_M4_HARVEST_PRECINCT_v001.glb",
    "M5":"res://assets/m5/ALC_M5_CONNECTIVE_SETTLEMENT_v001.glb",
}


def load() -> dict:
    return json.loads(CONFIG.read_text(encoding="utf-8"))


def validate(cfg:dict, rig:dict | None=None)->list[str]:
    errors=[]
    if cfg.get("schema")!="alchul.m11.t15.source-mesh-synthetic-probes.v1": errors.append("schema")
    if cfg.get("status")!=STATUS: errors.append("false_clearance_certification")
    p=cfg.get("science_policy",{})
    must_true=("actual_glb_source_meshes","probe_is_synthetic","triangle_intersections_are_not_accessibility_proof","fiction_not_earth_evidence")
    must_false=("source_units_verified_meters","body_to_asset_scale_established","biological_approval","creator_approval","modern_descendant_body_known")
    if not isinstance(p,dict) or any(p.get(k) is not True for k in must_true) or any(p.get(k) is not False for k in must_false):errors.append("science_and_creator_gate")
    stages=cfg.get("geometry_source_stages",[])
    if not isinstance(stages,list) or {s.get("id"):s.get("path") for s in stages if isinstance(s,dict)}!=SOURCES or len(stages)!=4:errors.append("source_glb_provenance")
    else:
        for path in SOURCES.values():
            if not (ROOT/path.replace("res://","")).is_file():errors.append("missing_source_"+path)
    if cfg.get("candidate_ids")!=["H-A","H-B"]:errors.append("unapproved_candidate_or_hybrid")
    if cfg.get("candidate_rig")!="res://data/m11_t07_skeletal_reference.json":errors.append("non_T07_bodies")
    ratios=cfg.get("synthetic_unverified_body_to_asset_scale_factors",[])
    if not (isinstance(ratios,list) and len(ratios)==3 and
        all(isinstance(x,(int,float)) and math.isfinite(x) and x>0 for x in ratios) and
        ratios==sorted(set(ratios))):errors.append("non_sensitivity_ratios")
    points=cfg.get("sample_site_aabb_fractions",[])
    if not (isinstance(points,list) and len(points)==5 and
        all(isinstance(x,list) and len(x)==2 and all(isinstance(v,(int,float)) and math.isfinite(v) and 0<v<1 for v in x) for x in points) and
        len({tuple(x) for x in points})==5):errors.append("synthetic_probe_positions")
    y=cfg.get("probe_center_y_aabb_fraction")
    if not isinstance(y,(int,float)) or not math.isfinite(y) or not 0<y<1:errors.append("probe_y")
    if "UNKNOWN" not in cfg.get("output_scope","").upper():errors.append("hidden_uncertainty")
    if len(cfg.get("excluded_claims",[]))<7:errors.append("exclusions")
    if rig is None: rig=json.loads(RIG.read_text(encoding="utf-8"))
    if rig.get("status")!="engineering_hypothesis_not_canon" or {b.get("id") for b in rig.get("bodies",[])}!={"H-A","H-B"}:errors.append("unapproved_rig")
    else:
        for b in rig["bodies"]:
            if len(b.get("bones",[]))!=43:errors.append("altered_reference_bone_count")
    return errors


def main()->int:
    errors=validate(load())
    if errors:
        print("T15 SOURCE GEOMETRY CONTRACT FAIL:",", ".join(errors))
        return 1
    print("ALCHUL T15 OFFLINE PASS: 4 real GLB paths, 2 unapproved H-A/H-B rigs, 3 uncalibrated ratios, 5 synthetic probes, no canon")
    return 0


if __name__=="__main__":
    raise SystemExit(main())
