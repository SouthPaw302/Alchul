#!/usr/bin/env python3
"""Reject unsupported M11 anatomy claims and inconsistent comparison geometry.

This checks a *research-only*, dimensionless drawing registry, not real biological
measurements. It does not validate biomechanics, paleontology, or the game build.
"""
from __future__ import annotations

import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parent
REGISTRY = ROOT / "data/m11_anatomy_candidates.json"
EXPECTED_IDS = {"H-A", "H-B"}
PARAMETERS = (
    "hip_height",
    "torso_length",
    "tail_length",
    "neck_rise",
    "forelimb_reach",
    "stance_half_width",
)


def check(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def validate() -> None:
    data = json.loads(REGISTRY.read_text(encoding="utf-8"))
    check(data.get("schema") == "alchul.m11.anatomy-comparison.v1", "Wrong M11 registry schema")
    check(data.get("status") == "research_only_not_canon", "M11 candidate status must be noncanonical")
    check("not_meters" in data.get("units", ""), "Provisional units must not be real-world dimensions")
    check("unmeasured" in data.get("anatomical_certainty", ""), "Research uncertainty label missing")
    for source in data.get("source_docs", []):
        check(source.endswith(".md") and (REPO / source).is_file(), f"Missing canon/research source: {source}")
    check(len(data.get("source_docs", [])) >= 3, "Missing comparative source documentation")

    locked = data.get("locked_constraints", {})
    check(locked.get("functional_forelimb_digits") == 3, "Forelimb digit baseline changed")
    check(locked.get("hindlimb_architecture") == "theropod-derived digitigrade", "Ancestral gait erased")
    check(locked.get("egg_retention_fraction_approx") == 0.75, "Locked late egg-retention canon changed")
    check(locked.get("alchul_visible_body") is False, "Alchul must not receive a visible species body")
    check("unresolved" in locked.get("reproductive_mechanism", ""), "Reproductive anatomy is unknown")
    check(locked.get("nonhuman_wrist_pronation") == "not unconstrained", "Primate wrist assumption inserted")

    hypotheses = data.get("hypotheses", [])
    check(len(hypotheses) == 2, "Exactly two competing test bodies required")
    candidates = {h.get("id"): h for h in hypotheses}
    check(set(candidates) == EXPECTED_IDS, "H-A and H-B required")
    for identifier, h in candidates.items():
        check(h.get("status") == "provisional", f"{identifier} must remain provisional")
        check(h.get("digit_count") == 3, f"{identifier} has non-three-digit hand")
        check(bool(h.get("primary_test")) and bool(h.get("potential_failure")),
              f"{identifier} missing falsification questions")
        for parameter in PARAMETERS:
            value = h.get(parameter)
            check(type(value) in (float, int) and math.isfinite(value) and 0 < value < 10,
                  f"{identifier} invalid nonmetric parameter {parameter}")
    check(candidates["H-A"]["hip_height"] == candidates["H-B"]["hip_height"],
          "Matched views require identical illustration hip-height datum")
    check(candidates["H-A"]["tail_length"] > candidates["H-B"]["tail_length"],
          "Competing hypotheses must differ in their central tail prediction")
    check(candidates["H-B"]["neck_rise"] > candidates["H-A"]["neck_rise"],
          "Upright-reading alternate should have a distinct neck/head pose")

    plate_ids = [p.get("id") for p in data.get("plates", [])]
    check(plate_ids == [f"M11_VIEW_{i:02d}" for i in range(1, 11)],
          "M11 requires ten ordered study plate targets")
    check(all(bool(p.get("subject")) for p in data.get("plates", [])),
          "Every study plate needs a declared purpose")
    check(len(data.get("prohibitions", [])) >= 5, "Unsupported anatomy/Alchul exclusions missing")
    for required in ("scenes/m11_anatomy_lab.tscn", "scripts/m11_anatomy_lab.gd",
                     "tests/m11_anatomy_lab_smoke.gd"):
        check((ROOT / required).is_file(), f"Missing M11 runnable study file: {required}")
    print("ALCHUL M11 REGISTRY PASS — H-A/H-B, equal hip datum, 3 digits, ten plates, no canon promotion")


if __name__ == "__main__":
    validate()
