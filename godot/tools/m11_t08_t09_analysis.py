#!/usr/bin/env python3
"""ALCHUL T08–T09: dimensionless balance and three-digit reach test harness.

Not fossil biomechanics, a motor solver, a grasp-force model, or biological proof.
All assumptions are explicit in m11_t08_t09_experiment.json. Standard library only.

Run from repo root:
  python3 godot/tools/m11_t08_t09_analysis.py --write
  python3 godot/tools/m11_t08_t09_analysis.py --check
"""
from __future__ import annotations

import argparse
import hashlib
import itertools
import json
import math
import random
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "data/m11_t08_t09_experiment.json"
RESULT_PATH = ROOT / "data/m11_t08_t09_results.json"
REGIONS = ("pelvis", "trunk", "head_neck", "tail", "hindlimbs", "forelimbs")
DIGITS = ("I", "II", "III")


def midpoint(a: tuple[float, ...], b: tuple[float, ...]) -> tuple[float, ...]:
    return tuple((x + y) / 2 for x, y in zip(a, b))


def average(vectors: list[tuple[float, ...]]) -> tuple[float, ...]:
    if not vectors:
        raise ValueError("cannot average zero points")
    return tuple(sum(a[i] for a in vectors) / len(vectors) for i in range(3))


def add(a: tuple[float, ...], b: tuple[float, ...]) -> tuple[float, ...]:
    return tuple(x + y for x, y in zip(a, b))


def sub(a: tuple[float, ...], b: tuple[float, ...]) -> tuple[float, ...]:
    return tuple(x - y for x, y in zip(a, b))


def scale(a: tuple[float, ...], factor: float) -> tuple[float, ...]:
    return tuple(x * factor for x in a)


def length(a: tuple[float, ...]) -> float:
    return math.sqrt(sum(x*x for x in a))


def rot_z(a: tuple[float, ...], angle_deg: float) -> tuple[float, float, float]:
    r = math.radians(angle_deg)
    c, s = math.cos(r), math.sin(r)
    return a[0] * c - a[1] * s, a[0] * s + a[1] * c, a[2]


def rot_y(a: tuple[float, ...], angle_deg: float) -> tuple[float, float, float]:
    r = math.radians(angle_deg)
    c, s = math.cos(r), math.sin(r)
    return a[0] * c + a[2] * s, a[1], -a[0] * s + a[2] * c


def rounded(p: tuple[float, ...] | float, decimals: int = 5) -> Any:
    if isinstance(p, (tuple, list)):
        return [rounded(v, decimals) for v in p]
    return round(float(p), decimals)


def anchors(body: dict) -> dict[str, tuple[float, float, float]]:
    points = {b["name"]: tuple(map(float, b["anchor"])) for b in body["bones"]}
    if len(points) != 43:
        raise ValueError("T07 expected 43 bone control points")
    return points


def mass_centers(points: dict) -> dict[str, tuple[float, ...]]:
    return {
        "pelvis": points["pelvis"],
        "trunk": midpoint(points["pelvis"], points["thorax"]),
        "head_neck": average([points["neck_01"], points["neck_02"], points["skull"]]),
        "tail": average([points[f"caudal_0{i}"] for i in range(1, 5)]),
        "hindlimbs": average([points[k] for side in ("L", "R") for k in (
            f"femur_{side}", f"tibia_{side}", f"metatarsus_{side}")]),
        "forelimbs": average([points[k] for side in ("L", "R") for k in (
            f"humerus_{side}", f"antebrachium_{side}", f"carpus_{side}")]),
    }


def center_of_mass(centers: dict, weights: dict, case: str, cargo: dict) -> tuple[float, ...]:
    if set(weights) != set(REGIONS):
        raise ValueError("all six proxy regions must have mass fractions")
    if not math.isclose(sum(weights.values()), 1.0, abs_tol=1e-8):
        raise ValueError("proxy mass weights must total 1")
    points = dict(centers)
    if case == "two_feet_forward_reach":
        points["forelimbs"] = add(points["forelimbs"], (0.30, -0.10, 0))
        points["head_neck"] = add(points["head_neck"], (0.10, -0.06, 0))
    mass_total = sum(weights.values())
    weighted = tuple(sum(weights[r] * points[r][i] for r in REGIONS) for i in range(3))
    if case == "two_feet_with_cargo_proxy":
        fraction = float(cargo["additional_mass_fraction_of_base"])
        cargo_point = tuple(float(v) for v in cargo["at"])
        weighted = add(weighted, scale(cargo_point, fraction))
        mass_total += fraction
    return scale(weighted, 1 / mass_total)


def support_patch(points: dict, foot: dict, case: str) -> list[float]:
    sides = ["R"] if case == "right_foot_only" else ["L", "R"]
    rear = float(foot["backward_reach_x"])
    front = float(foot["forward_reach_x"])
    width = float(foot["lateral_half_width"])
    xs = [points[f"metatarsus_{side}"][0] + off for side in sides for off in (-rear, front)]
    zs = [points[f"metatarsus_{side}"][2] + off for side in sides for off in (-width, width)]
    return [min(xs), max(xs), min(zs), max(zs)]


def support_margin(com: tuple[float, ...], box: list[float]) -> float:
    """Signed xz-margin for an intentionally axis-aligned approximation."""
    x, z = com[0], com[2]
    return min(x - box[0], box[1] - x, z - box[2], box[3] - z)


def sensitivity(centers: dict, weights: dict, patch: list[float], cfg: dict) -> dict:
    rng = random.Random(int(cfg["seed"]))
    margins = []
    for _ in range(int(cfg["samples"])):
        perturb = {r: weights[r] * rng.uniform(float(cfg["segment_scale_min"]),
                                                 float(cfg["segment_scale_max"])) for r in REGIONS}
        total = sum(perturb.values())
        perturb = {r: p / total for r, p in perturb.items()}
        proxy = center_of_mass(centers, perturb, "two_feet_neutral", {})
        margins.append(support_margin(proxy, patch))
    margins.sort()
    return {"samples": len(margins), "p05_margin": rounded(margins[int(len(margins)*0.05)]),
            "p95_margin": rounded(margins[int(len(margins)*0.95)]),
            "fraction_positive": rounded(sum(m >= 0 for m in margins) / len(margins))}


def fingertip_positions(points: dict, side: str, shoulder_deg: float,
                         elbow_deg: float, wrist_yaw_deg: float,
                         digit_angles: dict[str, float]) -> dict[str, tuple[float, ...]]:
    base = points[f"scapula_{side}"]
    elbow0 = points[f"humerus_{side}"]
    wrist0 = points[f"carpus_{side}"]
    elbow = add(base, rot_z(sub(elbow0, base), shoulder_deg))
    wrist = add(elbow, rot_z(sub(wrist0, elbow0), shoulder_deg + elbow_deg))
    tips: dict[str, tuple[float, ...]] = {}
    for digit in DIGITS:
        first = points[f"manual_{digit}_1_{side}"]
        last = points[f"manual_{digit}_2_{side}"]
        p = add(wrist, rot_y(rot_z(sub(first, wrist0), shoulder_deg + elbow_deg), wrist_yaw_deg))
        tip = add(p, rot_y(rot_z(sub(last, first), shoulder_deg + elbow_deg + digit_angles[digit]), wrist_yaw_deg))
        tips[digit] = tip
    return tips


def contact_targets(points: dict, grasp_cfg: dict, side: str, far: bool) -> dict:
    scapula = points[f"scapula_{side}"]
    offset = grasp_cfg["fixture_offsets_from_scapula"]
    delta = float(grasp_cfg["far_fixture_forward_delta"]) if far else 0.0
    return {digit: add(scapula, (float(offset["x"]) + delta,
                                float(offset["y"]), float(offset["z_by_digit"][i])))
            for i, digit in enumerate(DIGITS)}


def solve_three_digit_fixture(points: dict, joints: dict, grasp_cfg: dict,
                               side: str = "R", far: bool = False) -> dict:
    for base, control in (("shoulder_samples_deg", "shoulder_swing"),
                          ("elbow_samples_deg", "elbow_flex"),
                          ("wrist_yaw_samples_deg", "wrist_fold")):
        lo, hi = float(joints[control]["min_deg"]), float(joints[control]["max_deg"])
        if not all(lo <= v <= hi for v in grasp_cfg[base]):
            raise ValueError("configuration requests motion beyond the T07 joint gate")
    for digit in DIGITS:
        gate = joints[f"manual_{digit}_flex"]
        if not all(gate["min_deg"] <= v <= gate["max_deg"] for v in grasp_cfg["digit_flex_samples_deg"]):
            raise ValueError(f"finger {digit} samples exceed T07 gate")
    targets = contact_targets(points, grasp_cfg, side, far)
    tolerance = float(grasp_cfg["contact_tolerance"])
    best: dict | None = None
    for shoulder, elbow, yaw in itertools.product(grasp_cfg["shoulder_samples_deg"],
                                                  grasp_cfg["elbow_samples_deg"],
                                                  grasp_cfg["wrist_yaw_samples_deg"]):
        results: dict[str, tuple[float, float, tuple]] = {}
        for digit in DIGITS:
            candidates = []
            for flex in grasp_cfg["digit_flex_samples_deg"]:
                points_out = fingertip_positions(points, side, shoulder, elbow, yaw, {d: flex for d in DIGITS})
                tip = points_out[digit]
                candidates.append((length(sub(tip, targets[digit])), float(flex), tip))
            results[digit] = min(candidates, key=lambda row: row[0])
        max_error = max(item[0] for item in results.values())
        mean_error = sum(item[0] for item in results.values()) / 3
        score = (max_error, mean_error)
        if best is None or score < best["score"]:
            best = {"score": score, "shoulder_deg": shoulder, "elbow_deg": elbow,
                    "wrist_yaw_deg": yaw, "per_digit": results}
    if best is None:
        raise ValueError("no pose samples")
    contact = {digit: {"error": rounded(best["per_digit"][digit][0]),
                       "finger_flex_deg": best["per_digit"][digit][1],
                       "predicted_tip": rounded(best["per_digit"][digit][2]),
                       "target": rounded(targets[digit])}
               for digit in DIGITS}
    return {"fixture": "far_unreachable_control" if far else "near_three_point_brace",
            "side": side, "sampling":"enumerated finite angles; not continuous IK or force closure",
            "shoulder_deg": best["shoulder_deg"],
            "elbow_deg": best["elbow_deg"],
            "wrist_yaw_deg": best["wrist_yaw_deg"],
            "maximum_contact_error": rounded(best["score"][0]),
            "tolerance": tolerance,
            "contact_count": sum(v["error"] <= tolerance for v in contact.values()),
            "all_three_close": all(v["error"] <= tolerance for v in contact.values()),
            "digits": contact}


def analyze(config: dict, rig: dict) -> dict:
    if config.get("status") != "noncanonical_proxy_not_biological_validation":
        raise ValueError("research status boundary violated")
    if config.get("schema") != "alchul.m11.t08-t09.engineering-study.v1":
        raise ValueError("wrong experiment schema")
    if rig.get("schema") != "alchul.m11.t07.skeletal-reference.v1":
        raise ValueError("T07 source rig schema changed")
    output = {"schema":"alchul.m11.t08-t09.results.v1",
              "status": "PROVISIONAL_ASSUMPTION_DRIVEN_ENGINEERING_EXPERIMENT_NOT_FOSSIL_DATA",
              "units":config["units"],
              "provenance": "Recomputed from T07 skeleton anchor coordinates + T08/T09 explicitly assumed inputs",
              "input_rig_geometry_sha256": hashlib.sha256(json.dumps(
                  [{"id": b["id"], "bones": b["bones"]} for b in rig["bodies"]],
                  sort_keys=True, separators=(",", ":")).encode()).hexdigest(),
              "input_assumptions_sha256": hashlib.sha256(json.dumps(config, sort_keys=True,
                  separators=(",", ":")).encode()).hexdigest(),
              "t08":{}, "t09":{}}
    for body in rig["bodies"]:
        key = body["id"]
        p = anchors(body)
        centers = mass_centers(p)
        weights = {name:float(value) for name,value in config["com_profiles"][key].items()}
        if not math.isclose(sum(weights.values()), 1.0, abs_tol=1e-8):
            raise ValueError("invalid segment weight normalization")
        cases = {}
        for name in config["movement_cases"]:
            com = center_of_mass(centers, weights, name, config["load_case"])
            box = support_patch(p, config["foot_patch"], name)
            margin = support_margin(com, box)
            cases[name] = {"projected_com_xz":rounded((com[0],com[2])),
                           "com_xyz":rounded(com),"support_box_xmin_xmax_zmin_zmax":rounded(box),
                           "signed_margin":rounded(margin),
                           "proxy_static_inside_box":margin >= 0}
        def tail_variant(factor:float)->float:
            revised={region: value * (factor if region=="tail" else 1.0) for region,value in weights.items()}
            total=sum(revised.values());revised={k:v/total for k,v in revised.items()}
            return center_of_mass(centers,revised,"two_feet_neutral",{})[0]
        output["t08"][key] = {"region_mass_fractions":weights,
            "region_centers_xyz":{r:rounded(centers[r]) for r in REGIONS},
            "cases":cases,
            "sensitivity_neutral":sensitivity(centers,weights,
                 support_patch(p,config["foot_patch"],"two_feet_neutral"),
                 config["mass_uncertainty"]),
            "tail_halved_com_x":rounded(tail_variant(.5)),
            "tail_1p5x_com_x":rounded(tail_variant(1.5))}
        output["t09"][key] = {"near":solve_three_digit_fixture(p,rig["joints"],config["grasp"],"R",False),
                              "far":solve_three_digit_fixture(p,rig["joints"],config["grasp"],"R",True),
                              "excluded_controls": ["forearm_axial_pronation","human_thumb_opposition"],
                              "statement":"Close fingertip proximity at finite sampled poses only; no thumb, no force closure, no tendon model"}
    return output


def main() -> int:
    parser=argparse.ArgumentParser(description=__doc__)
    choice=parser.add_mutually_exclusive_group(required=True)
    choice.add_argument("--write", action="store_true", help="Update canonical reproducible experiment result data")
    choice.add_argument("--check", action="store_true", help="Require committed results to match recomputation exactly")
    args=parser.parse_args()
    cfg=json.loads(CONFIG_PATH.read_text("utf-8"))
    rig=json.loads((ROOT/cfg["input_rig"]).read_text("utf-8"))
    results=analyze(cfg,rig)
    content=json.dumps(results, indent=2, sort_keys=True)+"\n"
    if args.write:
        RESULT_PATH.write_text(content,"utf-8")
        print("WROTE", RESULT_PATH)
    else:
        if not RESULT_PATH.is_file() or RESULT_PATH.read_text("utf-8")!=content:
            raise SystemExit("ALCHUL T08-T09 FAIL: tracked analysis does not match input rig/assumptions")
        print("ALCHUL T08-T09 RECOMPUTATION PASS — reproducible proxies, not biological measurements")
    for key in ("H-A","H-B"):
        t8=results["t08"][key]["cases"]
        near=results["t09"][key]["near"]
        far=results["t09"][key]["far"]
        print(key,"neutral margin",t8["two_feet_neutral"]["signed_margin"],
              "one-foot margin",t8["right_foot_only"]["signed_margin"],
              "near fixture",near["maximum_contact_error"],near["contact_count"],
              "far fixture",far["maximum_contact_error"],far["contact_count"])
    return 0


if __name__=="__main__":
    raise SystemExit(main())
