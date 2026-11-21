#!/usr/bin/env python3
"""Validate ALCHUL M11 T07 research-only skeletal graph and joint controls.

This verifies engineering invariants and provenance, not palaeontology or
actual physiological range of motion. Uses Python standard library only.
"""
from __future__ import annotations

import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT.parent
DATA = ROOT / "data/m11_t07_skeletal_reference.json"
SIDES = ("L", "R")
MANUAL = ("I", "II", "III")
PEDAL = ("II", "III", "IV")
EXPECTED_AXIAL = (
    "pelvis", "spine", "thorax", "neck_01", "neck_02",
    "skull", "mandible", "caudal_01", "caudal_02", "caudal_03", "caudal_04",
)
EXPECTED_PER_SIDE = 16


def assert_true(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def validate() -> dict:
    data = json.loads(DATA.read_text("utf-8"))
    assert_true(data.get("schema") == "alchul.m11.t07.skeletal-reference.v1",
                "T07 skeletal registry schema must match version 1")
    assert_true(data.get("status") == "engineering_hypothesis_not_canon",
                "T07 must not be represented as a canonical species")
    assert_true("not_meters" in data.get("units", ""), "Only illustrative units are allowed")
    assert_true("NOT MEASURED" in data.get("angles", ""), "Joint degrees are not measured facts")
    sources = data.get("source_refs", [])
    assert_true(len(sources) >= 6, "Need current canon, dossier, QA and independent references")
    for s in sources:
        if "path" in s:
            assert_true((PROJECT / s["path"]).is_file(), "Missing source " + s["path"])
        else:
            assert_true(s.get("url", "").startswith("https://"),
                        "Research references must provide inspectable links")
    assert_true(len(data.get("blocked_joint_controls", [])) >= 4,
                "Forbidden primate/axial control register missing")
    assert_true("forearm_axial_pronation" in data["blocked_joint_controls"],
                "Do not permit unconstrained pronation")
    assert_true("human_thumb_opposition" in data["blocked_joint_controls"],
                "Do not invent a mammalian thumb")
    controls = data.get("joints", {})
    assert_true(len(controls) >= 12, "Missing key limb/axial control envelopes")
    for label, control in controls.items():
        assert_true(control.get("axis") in ("x", "y", "z"),
                    f"Illegal axis for {label}")
        assert_true(float(control["min_deg"]) < 0 < float(control["max_deg"]),
                    f"Control {label} must include neutral rest")
        assert_true(-90 < float(control["min_deg"]) < 0
                    and 0 < float(control["max_deg"]) < 90,
                    f"Unbounded art-control angle on {label}")
        assert_true("thumb" not in label and "pronation" not in label,
                    f"Unpermitted joint name {label}")
    bodies = data.get("bodies", [])
    assert_true(len(bodies) == 2 and {x.get("id") for x in bodies} == {"H-A", "H-B"},
                "Both competing hypotheses required")
    for body in bodies:
        identifier = body["id"]
        bones = body.get("bones", [])
        assert_true(len(bones) == len(EXPECTED_AXIAL) + 2 * EXPECTED_PER_SIDE,
                    f"{identifier}: incorrect bone count")
        by_name = {}
        for b in bones:
            n = b.get("name")
            assert_true(n not in by_name, f"Duplicate bone {identifier}/{n}")
            parent = b.get("parent")
            assert_true(parent is None or parent in by_name,
                        f"Bone {n} must follow its parent in topological order")
            assert_true(b.get("region") in ("axial", "cranial", "caudal",
                                            "forelimb", "manual", "hindlimb", "pedal"),
                        f"Bone {n} missing role")
            xyz = b.get("anchor", [])
            assert_true(len(xyz) == 3 and all(type(v) in (int, float)
                        and math.isfinite(v) and abs(v) < 20 for v in xyz),
                        f"Nonfinite reference point {identifier}/{n}")
            by_name[n] = b
        assert_true(all(n in by_name for n in EXPECTED_AXIAL),
                    f"{identifier}: axial reference incomplete")
        assert_true(by_name["pelvis"]["parent"] is None, "Pelvis is sole root")
        assert_true(len([b for b in bones if b["parent"] is None]) == 1,
                    "A disconnected duplicate root exists")
        for side in SIDES:
            for base in ("scapula", "humerus", "antebrachium", "carpus",
                         "femur", "tibia", "metatarsus"):
                assert_true(base + "_" + side in by_name,
                            f"Missing {identifier}/{base}_{side}")
            assert_true(by_name["humerus_" + side]["parent"] == "scapula_" + side,
                        "Non-primate shoulder chain broken")
            assert_true(by_name["antebrachium_" + side]["parent"] == "humerus_" + side,
                        "Elbow link broken")
            assert_true(by_name["carpus_" + side]["parent"] == "antebrachium_" + side,
                        "Forearm/carpus link broken")
            for digit in MANUAL:
                n = f"manual_{digit}_1_{side}"
                d = f"manual_{digit}_2_{side}"
                assert_true(n in by_name and d in by_name, f"Missing manual digit {digit}/{side}")
                assert_true(by_name[n]["parent"] == "carpus_" + side and
                            by_name[d]["parent"] == n, f"Disconnected finger {digit}/{side}")
            for digit in PEDAL:
                n = f"pedal_{digit}_{side}"
                assert_true(n in by_name and
                            by_name[n]["parent"] == "metatarsus_" + side,
                            f"Missing pedal digit {digit}/{side}")
            assert_true(abs(by_name["femur_" + side]["anchor"][2]) > 0,
                        "Non-degenerate digitigrade stance reference needed")
        for control in controls.values():
            for side in (SIDES if "{side}" in control["bone"] else ("",)):
                target = control["bone"].replace("{side}", side)
                assert_true(target in by_name, f"Unbound rig control: {target}")
        assert_true(abs(by_name["pelvis"]["anchor"][1] -
                        float(body["hip_datum_normalized"])) < 1e-5,
                    "Hip reference not aligned")
    a = next(b for b in bodies if b["id"] == "H-A")
    b = next(b for b in bodies if b["id"] == "H-B")
    assert_true(a["hip_datum_normalized"] == b["hip_datum_normalized"],
                "Matched hip reference required")
    assert_true(next(x for x in a["bones"] if x["name"] == "caudal_04")["anchor"][0]
                < next(x for x in b["bones"] if x["name"] == "caudal_04")["anchor"][0],
                "H-A should retain longer skeletal tail reference")
    for required in ("scripts/m11_t07_joint_lab.gd", "scenes/m11_t07_joint_lab.tscn",
                     "tests/m11_t07_joint_smoke.gd"):
        assert_true((ROOT / required).is_file(), f"Missing runnable T07 component {required}")
    print("ALCHUL T07 GRAPH PASS — H-A/H-B each have 43 connected bones, three distinct manual digits/side and gated joints")
    return data


if __name__ == "__main__":
    validate()
