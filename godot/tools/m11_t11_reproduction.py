#!/usr/bin/env python3
"""ALCHUL T11: reproducible, dimensionless reproductive-constraint screening.

The canon's ~75% internal development is an input, not a model inference.
This script does not simulate a reproductive organ, respiratory physiology,
embryonic metabolic rates, elapsed time, or actual animal viability.
"""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

DATA = Path(__file__).resolve().parents[1] / "data"
CONFIG = DATA / "m11_t11_reproductive_constraints.json"
RESULTS = DATA / "m11_t11_screening_results.json"
STATUS = "noncanonical_dimensionless_screening_not_biological_viability"
REQUIRED_SCENARIOS = (
    "reference", "internal_hypoxia", "restrictive_internal_transfer",
    "stagnant_nursery", "excessive_maternal_load",
    "desiccating_nursery", "overheated_nursery",
)
PARAMETERS = (
    "internal_conductance", "internal_gradient", "external_conductance",
    "external_gradient", "external_ventilation", "maternal_burden_coefficient",
    "clutch_load_index", "nursery_humidity_index", "nursery_heat_stress_index",
)


def read_json(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError("JSON root must be a dictionary")
    return value


def validate_config(config: dict) -> None:
    if config.get("scientific_status") != STATUS:
        raise ValueError("T11 would claim unapproved biological validation")
    if config.get("schema_version") != "m11_t11_v1":
        raise ValueError("Unexpected T11 schema")
    canon = config.get("fixed_canon", {})
    if canon.get("fraction_internal_development") != 0.75:
        raise ValueError("Cannot edit the canon ~75% development premise")
    if "not chronological" not in str(canon.get("definition", "")):
        raise ValueError("Developmental stage must not masquerade as elapsed time")
    model = config.get("model", {})
    if model.get("sample_count") != 101:
        raise ValueError("101-stage grid required (includes 0.75)")
    if model.get("relative_demand_at_start") != 0.18 or model.get("relative_demand_at_end") != 1.0:
        raise ValueError("Unknown numerical demand normalization")
    if model.get("relative_demand_exponent") != 2.0:
        raise ValueError("Unexpected relative demand curve")
    if not math.isclose(model.get("maternal_load_floor", -1) + model.get("maternal_load_growth", -1), 1.0):
        raise ValueError("Maternal proxy terms must sum to 1.0")
    if model.get("maternal_budget_index") != 1.0:
        raise ValueError("Maternal budget normalization changed")
    bounds = model.get("acceptable_nursery_humidity_index", [])
    if bounds != [0.4, 0.85] or model.get("maximum_nursery_heat_stress_index") != 0.7:
        raise ValueError("Unreviewed nursery envelope")
    if set(config.get("scenarios", {})) != set(REQUIRED_SCENARIOS):
        raise ValueError("Control or negative scenario missing")
    for name, scenario in config["scenarios"].items():
        if not scenario.get("description") or any(k not in scenario for k in PARAMETERS):
            raise ValueError("Missing scenario assumptions: " + name)
        for key in PARAMETERS:
            v = scenario[key]
            if isinstance(v, bool) or not isinstance(v, (float, int)) or not math.isfinite(v):
                raise ValueError("Invalid assumption: " + name + "." + key)
            if v < 0:
                raise ValueError("Negative assumption: " + key)
            if key in ("internal_gradient", "external_gradient", "external_ventilation",
                       "nursery_humidity_index", "nursery_heat_stress_index") and v > 1:
                raise ValueError("Proportional index above 1: " + key)
    if not config.get("forbidden_inferences"):
        raise ValueError("Unknowns must be declared")


def demand(t: float, model: dict) -> float:
    return model["relative_demand_at_start"] + (
        model["relative_demand_at_end"] - model["relative_demand_at_start"]
    ) * t ** model["relative_demand_exponent"]


def maternal_load(t: float, model: dict, scenario: dict) -> float:
    return scenario["maternal_burden_coefficient"] * scenario["clutch_load_index"] * (
        model["maternal_load_floor"] + model["maternal_load_growth"] * t * t
    )


def round6(value: float) -> float:
    return round(value, 6)


def solve_scenario(config: dict, name: str, scenario: dict) -> dict:
    model = config["model"]
    retention = config["fixed_canon"]["fraction_internal_development"]
    n = model["sample_count"]
    samples = [i / (n - 1) for i in range(n)]
    internal_supply = scenario["internal_conductance"] * scenario["internal_gradient"]
    external_supply = (
        scenario["external_conductance"] * scenario["external_gradient"]
        * scenario["external_ventilation"]
    )
    internal_margin = min(
        internal_supply - demand(t, model) for t in samples if t <= retention
    )
    external_margin = min(
        external_supply - demand(t, model) for t in samples if t >= retention
    )
    maternal_margin = min(
        model["maternal_budget_index"] - maternal_load(t, model, scenario)
        for t in samples if t <= retention
    )
    low, high = model["acceptable_nursery_humidity_index"]
    flags = {
        "internal_oxygen_index": internal_margin >= -1e-10,
        "external_oxygen_index": external_margin >= -1e-10,
        "maternal_load_index": maternal_margin >= -1e-10,
        "nursery_moisture_index": low <= scenario["nursery_humidity_index"] <= high,
        "nursery_heat_index": scenario["nursery_heat_stress_index"] <= model["maximum_nursery_heat_stress_index"],
    }
    return {
        "scenario": name,
        "minimum_internal_oxygen_margin": round6(internal_margin),
        "minimum_external_oxygen_margin": round6(external_margin),
        "minimum_maternal_budget_margin": round6(maternal_margin),
        "relative_demand_at_laying": round6(demand(retention, model)),
        "internal_supply_index": round6(internal_supply),
        "external_supply_index": round6(external_supply),
        "constraints": flags,
        "screening_pass": all(flags.values()),
        "meaning": "algebraic consistency within invented assumptions; never a viability prediction",
    }


def build_results(config: dict) -> dict:
    validate_config(config)
    model = config["model"]
    scenarios = {
        name: solve_scenario(config, name, config["scenarios"][name])
        for name in REQUIRED_SCENARIOS
    }
    reference = config["scenarios"]["reference"]
    return {
        "schema_version": config["schema_version"],
        "scientific_status": STATUS,
        "canon_fraction_internal": config["fixed_canon"]["fraction_internal_development"],
        "units": "dimensionless indices, NOT partial pressure, oxygen flux, metabolic rate, temperature, or days",
        "stage_definition": "0..1 embryonic developmental progress (not chronological time)",
        "scenarios": scenarios,
        "reference_profile": [
            {
                "stage": round6(t),
                "demand": round6(demand(t, model)),
                "internal_supply": round6(reference["internal_conductance"] * reference["internal_gradient"]),
                "external_supply": round6(
                    reference["external_conductance"] * reference["external_gradient"] * reference["external_ventilation"]
                ),
                "maternal_load": round6(maternal_load(t, model, reference)),
            }
            for t in (i / 20 for i in range(21))
        ],
    }


def equal_nested(actual: object, expected: object) -> bool:
    if isinstance(expected, dict):
        return isinstance(actual, dict) and set(actual) == set(expected) and all(
            equal_nested(actual[k], v) for k, v in expected.items()
        )
    if isinstance(expected, list):
        return isinstance(actual, list) and len(actual) == len(expected) and all(
            equal_nested(a, b) for a, b in zip(actual, expected)
        )
    if isinstance(expected, bool):
        return isinstance(actual, bool) and actual == expected
    if isinstance(expected, (int, float)):
        return isinstance(actual, (int, float)) and not isinstance(actual, bool) and math.isclose(
            actual, expected, rel_tol=0, abs_tol=1e-6
        )
    return actual == expected


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="compare tracked results with recomputed values")
    parser.add_argument("--write", action="store_true", help="update tracked results after explicit review")
    args = parser.parse_args()
    config = read_json(CONFIG)
    expected = build_results(config)
    if args.write:
        RESULTS.write_text(json.dumps(expected, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print("T11 results written; REVIEW these before claiming any science")
        return 0
    if args.check:
        if not RESULTS.is_file() or not equal_nested(read_json(RESULTS), expected):
            raise SystemExit("T11 FAIL: tracked outcomes do not match the current assumptions")
        if not expected["scenarios"]["reference"]["screening_pass"]:
            raise SystemExit("T11 FAIL: reference control unexpectedly fails")
        for name in REQUIRED_SCENARIOS[1:]:
            if expected["scenarios"][name]["screening_pass"]:
                raise SystemExit("T11 FAIL: negative control unexpectedly passes: " + name)
        print("ALCHUL T11 DETERMINISTIC SCREENING PASS (NOT biological validation)")
        return 0
    print(json.dumps(expected, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
