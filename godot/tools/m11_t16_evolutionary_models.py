#!/usr/bin/env python3
"""Bounded morphometric scenario ensemble for FICTIONAL pre-KPg descendants.

Methods borrow uncertainty accounting, archosaur skeletal topology, extant
phylogenetic bracketing and proxy mass-property analysis; NO empirical training
set, phylogenetic ancestral-state posterior or verified selection coefficients.
Never call these predictions probability estimates for the species.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import math
import random
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
REFERENCE=ROOT/"data/m11_t07_skeletal_reference.json"
PROFILES=ROOT/"data/m11_t16_evolutionary_profiles.json"
GENERATED=ROOT/"data/m11_t16_evolved_candidate_bones.json"
REGIONS={"axial","cranial","caudal","forelimb","manual","hindlimb","pedal"}


def read(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def verify_sources(base: dict, cfg: dict) -> None:
    if base.get("status")!="engineering_hypothesis_not_canon" or len(base.get("bodies",[]))!=2:
        raise ValueError("original two T07 research bodies required")
    if cfg.get("schema")!="alchul.m11.t16.evolutionary-morphometric-ensemble.v1" or cfg.get("status")!="UNVALIDATED_EVOLUTIONARY_TRAJECTORY_HYPOTHESES_NOT_CANON":
        raise ValueError("T16 sources promoted")
    if cfg.get("epistemic_limits",{}).get("creator_approved") is not False:
        raise ValueError("invented creator approval")
    a,b=base["bodies"]
    if len(a["bones"])!=43 or len(b["bones"])!=43:
        raise ValueError("43 control reference bones required")
    if [(x["name"],x["parent"]) for x in a["bones"]] != [(x["name"],x["parent"]) for x in b["bones"]]:
        raise ValueError("two references do not have matching osteological topology")
    for profile in cfg.get("selection_contexts",[]):
        p=profile["params"]
        if not 0<=profile["morph_source_mix"]<=1 or set(p)!=set(cfg["model_params_contract"])-{"morph_source_mix"}:
            raise ValueError("evolutionary profile fields inconsistent")
        for name,value in p.items():
            if not math.isfinite(value) or not 0.78<=value<=1.20:
                raise ValueError(f"unbounded reconstruction alteration {name}")


def deformation(name: str, region: str, params: dict, delta: list[float]) -> list[float]:
    x,y,z=delta
    if name.startswith("caudal_") or region=="caudal":
        x*=params["tail_scale"]
    if name in ("spine","thorax"):
        x*=params["thorax_reach"]
    if name.startswith("neck_"):
        y*=params["neck_height"]
    if region in ("forelimb","manual"):
        x*=params["forelimb_reach"]
    if region=="hindlimb":
        y*=params["hindlimb_height"]
    if region=="pedal":
        z*=params["pedal_spread"]
    if region=="cranial":
        x*=params["cranial_length"]
    return [x,y,z]


def body_graph(base:dict, profile:dict, mix:float|None=None, params:dict|None=None)->list[dict]:
    a,b=base["bodies"]
    first={rec["name"]:rec for rec in a["bones"]}
    second={rec["name"]:rec for rec in b["bones"]}
    mix=profile["morph_source_mix"] if mix is None else mix
    p=profile["params"] if params is None else params
    positions={}
    result=[]
    for old in a["bones"]:
        name=old["name"]; parent=old["parent"]
        old_a=first[name]["anchor"]; old_b=second[name]["anchor"]
        if parent is None:
            v=[old_a[i]*(1-mix)+old_b[i]*mix for i in range(3)]
        else:
            parent_a=first[parent]["anchor"]; parent_b=second[parent]["anchor"]
            delta=[(old_a[i]-parent_a[i])*(1-mix)+(old_b[i]-parent_b[i])*mix for i in range(3)]
            warped=deformation(name, old["region"],p,delta)
            v=[positions[parent][i]+warped[i] for i in range(3)]
        if any(not math.isfinite(q) for q in v):raise ValueError("nonfinite evolved skeleton")
        rounded=[round(q,6) for q in v]
        positions[name]=rounded
        result.append({"name":name,"parent":parent,"anchor":rounded,"region":old["region"]})
    return result


def radius(name: str)->float:
    if name=="thorax":return 0.34
    if name=="spine":return 0.30
    if name=="skull":return 0.28
    if name.startswith("neck_"):return 0.16
    if name.startswith("caudal_"):return max(0.065,0.19-0.03*int(name.split("_")[-1]))
    if name.startswith("femur"):return 0.19
    if name.startswith("tibia"):return 0.13
    if name.startswith("metatarsus"):return 0.105
    if name.startswith("humerus"):return 0.12
    if name.startswith("antebrachium"):return 0.085
    if name.startswith("manual_"):return 0.048
    if name.startswith("pedal_"):return 0.058
    return 0.12


def morphology_summary(bones:list[dict], profile:dict, cfg:dict)->dict:
    p={b["name"]:b for b in bones}
    pos={k:v["anchor"] for k,v in p.items()}
    # Cylindrical segment volume * assumed region-specific density coefficients.
    # This is a software COM proxy, NOT real specimen mass, force, or balance.
    weighed=0.0
    com=[0.0,0.0,0.0]
    group_totals={}
    for record in bones:
        parent=record["parent"]
        if parent is None:continue
        pt=pos[parent]; end=record["anchor"]
        seg=math.dist(pt,end)
        r=radius(record["name"])*profile["params"]["integument_volume"]
        weighted_vol=math.pi*r*r*seg*cfg["ensemble"]["soft_tissue_density_weights"][record["region"]]
        weighed+=weighted_vol
        for i in range(3):com[i]+=((pt[i]+end[i])/2.0)*weighted_vol
        group_totals[record["region"]]=group_totals.get(record["region"],0.0)+weighted_vol
    com=[round(x/weighed,6) for x in com]
    xs=[rec["anchor"][0] for rec in bones]
    ys=[rec["anchor"][1] for rec in bones]
    z_feet=[abs(pos[k][2]) for k in pos if k.startswith("pedal_III_") or k.startswith("pedal_IV_")]
    return {"total_axis_extent_x_normalized":round(max(xs)-min(xs),6),
        "maximum_reference_height_normalized":round(max(ys)-min(ys),6),
        "lateral_pedal_spread_proxy_normalized":round(max(z_feet)*2,6) if z_feet else None,
        "geometric_volume_weighted_COM_x_proxy":com[0],
        "geometric_volume_weighted_COM_xyz_proxy":com,
        "relative_segment_volume_proxy":round(weighed,6),
        "caudal_volume_fraction_proxy":round(group_totals.get("caudal",0)/weighed,6),
        "all_outputs_are_model_units":True,
        "is_biological_prediction":False}


def ensemble(base:dict,cfg:dict,profile:dict)->dict:
    # Reproducible sensitivity interval: arbitrary input perturbations, NOT posterior confidence.
    seed=cfg["ensemble"]["seed"]+int(profile["id"][1])*97
    rng=random.Random(seed)
    values=[]
    n=cfg["ensemble"]["replicates_per_profile"]
    for i in range(n):
        perturb=cfg["ensemble"]["parameter_perturbation_fraction"]
        p={k:max(0.75,min(1.25,v*(1+rng.uniform(-perturb,perturb))))
           for k,v in profile["params"].items()}
        mix=max(0,min(1,profile["morph_source_mix"]+
                        rng.uniform(-cfg["ensemble"]["mix_perturbation"],
                                    cfg["ensemble"]["mix_perturbation"])))
        sample=morphology_summary(body_graph(base,profile,mix,p),{**profile,"params":p},cfg)
        values.append(sample)
    fields=["total_axis_extent_x_normalized","maximum_reference_height_normalized",
            "lateral_pedal_spread_proxy_normalized",
            "geometric_volume_weighted_COM_x_proxy","caudal_volume_fraction_proxy"]
    return {field:[round(min(v[field] for v in values),6),
                   round(max(v[field] for v in values),6)] for field in fields}


def build(base:dict,cfg:dict)->dict:
    verify_sources(base,cfg)
    rows=[]
    for profile in cfg["selection_contexts"]:
        bones=body_graph(base,profile)
        rows.append({"id":profile["id"],"label":profile["label"],
            "status":"HYPOTHESIS_NOT_FOSSIL_OR_CANON","role_is_not_caste":True,
            "source_morph_mix":profile["morph_source_mix"],
            "params":profile["params"],"bones":bones,
            "model_surrogate":morphology_summary(bones,profile,cfg),
            "bounded_input_sensitivity_range_not_confidence":ensemble(base,cfg,profile)})
    return {"schema":"alchul.m11.t16.evolved-candidate-geometry.v1",
        "status":"PROVISIONAL_EVOLUTIONARY_MORPHOMETRY_NOT_CANON",
        "reference_bone_count":43,"candidate_count":len(rows),
        "reconstruction_method":"parent-local H-A/H-B osteological morphometry plus 24 bounded perturbations / case",
        "not_statistical_selection_simulation":True,
        "not_verified_allometry":True,"true_meters":False,
        "creator_approved":False,"extant_survivor_claim":False,
        "source_sha256":{
            "rig":hashlib.sha256(REFERENCE.read_bytes()).hexdigest(),
            "profiles":hashlib.sha256(PROFILES.read_bytes()).hexdigest()},
        "candidates":rows}


def main()->int:
    parser=argparse.ArgumentParser()
    parser.add_argument("--check",action="store_true")
    args=parser.parse_args()
    base=read(REFERENCE); cfg=read(PROFILES)
    generated=build(base,cfg)
    if args.check:
        if generated["candidate_count"]!=3 or any(len(row["bones"])!=43 for row in generated["candidates"]):
            print("T16 EVOLUTIONARY PREDICTOR CHECK FAIL: body graph contract")
            return 1
        for row in generated["candidates"]:
            metrics=row["model_surrogate"]
            if not all(math.isfinite(metrics[k]) for k in (
                    "total_axis_extent_x_normalized",
                    "geometric_volume_weighted_COM_x_proxy",
                    "relative_segment_volume_proxy")):
                print("T16 EVOLUTIONARY PREDICTOR CHECK FAIL: surrogate nonfinite")
                return 1
            if any(lo>hi for lo,hi in row["bounded_input_sensitivity_range_not_confidence"].values()):
                print("T16 EVOLUTIONARY PREDICTOR CHECK FAIL: sensitivity range")
                return 1
        if len({tuple(round(row["model_surrogate"][k],5) for k in (
                "total_axis_extent_x_normalized","lateral_pedal_spread_proxy_normalized"))
                for row in generated["candidates"]})!=3:
            print("T16 EVOLUTIONARY PREDICTOR CHECK FAIL: no distinct candidate anatomies")
            return 1
        print("ALCHUL T16 EVOLUTIONARY MORPHOMETRICS PASS: 3 distinct 43-bone hypotheses, 72 sensitivity replicates, no approval")
        return 0
    GENERATED.write_text(json.dumps(generated,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    print("T16 generated 3 new distinct rigged research candidate graphs:",GENERATED)
    return 0


if __name__=="__main__":
    raise SystemExit(main())
