#!/usr/bin/env python3
"""T17 dimensionless, deterministic physical source -> sensor -> reaction study.
Neither body organ physiology nor anomaly detection is inferred.
"""
from __future__ import annotations
import json, math, argparse
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/"data/m11_t17_physical_sensing.json"
CHANNELS=("water","vibration","stress","heat","gas","acoustic")
STATUS="FICTIONAL_CAUSAL_SENSOR_ENGINEERING_NOT_VERIFIED_RECEPTOR_BIOLOGY"

def load()->dict:return json.loads(DATA.read_text(encoding="utf-8"))

def validate(cfg:dict)->list[str]:
    errors=[]
    if cfg.get("schema")!="alchul.m11.t17.physical-stimulus-lab.v1" or cfg.get("status")!=STATUS:errors.append("scope")
    if cfg.get("canon_approved_sensor_organs") is not False or cfg.get("alchul_physical_signal") is not False:errors.append("supernatural_sensor_canon")
    sources=cfg.get("sources",[]); sensors=cfg.get("sensors",[])
    if len(sources)!=6 or {s["channel"] for s in sources}!=set(CHANNELS):errors.append("physical_source_types")
    if len(sensors)!=4:errors.append("reader_count")
    if len({s["id"] for s in sources})!=len(sources):errors.append("duplicate_source")
    for source in sources:
        if not all(math.isfinite(source[k]) for k in ("amplitude","spread","frequency","phase")) or source["spread"]<=0 or not 0<=source["amplitude"]<=1:errors.append("invalid_source")
        if len(source.get("position",[]))!=2:errors.append("source_location")
    for sensor in sensors:
        if set(sensor.get("channels",[]))!=set(CHANNELS):errors.append("reader_channel_scope")
        if not 0<sensor.get("threshold",0)<1 or not 0<sensor.get("sensitivity",0)<=1:errors.append("reader_detection_threshold")
        if not 0<=sensor.get("noise",-1)<.3 or not 0<=sensor.get("cross_talk",-1)<.3:errors.append("unrealistic_proxy_noise_scope")
        if len(sensor.get("position",[]))!=2:errors.append("reader_location")
    return errors

def sense(cfg:dict,sensor_id:str,channel:str,t:float,source_active:dict|None=None,inject_false_positive:bool=False)->dict:
    if not math.isfinite(t):raise ValueError("nonfinite time")
    if channel not in CHANNELS:raise ValueError("invalid channel")
    candidates=[x for x in cfg["sensors"] if x["id"]==sensor_id]
    if len(candidates)!=1:raise ValueError("invalid reader")
    sensor=candidates[0]
    direct=0.;other=0.;contributors=[]
    active=source_active or {}
    for source in cfg["sources"]:
        if active.get(source["id"],True) is False:continue
        d=math.dist(sensor["position"],source["position"])
        periodic=.82+.18*math.sin(t*source["frequency"]*math.tau+source["phase"])
        energy=source["amplitude"]*math.exp(-d/source["spread"])*periodic
        if source["channel"]==channel:
            direct+=energy
            contributors.append(source["id"])
        else:other+=energy
    cross=sensor["cross_talk"]*other/len(CHANNELS)
    noise=sensor["noise"]*math.sin((t+13.)*(CHANNELS.index(channel)+2)*1.73+len(sensor_id))
    demo=cfg["false_positive_demo"]["amplitude"] if (
        inject_false_positive and sensor_id==cfg["false_positive_demo"]["sensor"] and
        channel==cfg["false_positive_demo"]["channel"]) else 0.
    reading=max(0.,min(1.,sensor["sensitivity"]*direct+cross+noise+demo))
    flag=reading>=sensor["threshold"]
    return {"sensor":sensor_id,"channel":channel,"reading_normalized":round(reading,6),
        "threshold":sensor["threshold"],"detect":flag,"source_energy":round(direct,6),
        "cross_talk":round(cross,6),"noise":round(noise,6),"demo_injection":demo,
        "matched_sources":contributors,"false_positive":flag and direct<.05,
        "causal_physics_only":True,"is_Alchul_contact_evidence":False}

def main()->int:
    cfg=load()
    problems=validate(cfg)
    if problems:print("T17 CONFIG FAIL:",problems);return 1
    bank=sense(cfg,"bank_reader","water",0.0)
    off=sense(cfg,"bank_reader","water",0.0,{"river_pulse":False})
    if bank["reading_normalized"]<=off["reading_normalized"]:
        print("T17 ERROR: no stimulus response");return 1
    no_water={s["id"]:False for s in cfg["sources"] if s["channel"]=="water"}
    flagged=sense(cfg,"witness_reader","water",0.0,no_water,True)
    if not flagged["false_positive"] or flagged["source_energy"]>=.05 or flagged["is_Alchul_contact_evidence"]:
        print("T17 ERROR: cannot observe false positive without magic");return 1
    print("ALCHUL T17 OFFLINE PASS: six causes/four readers, attenuation, reproducible reaction and explicit false positive")
    print(json.dumps({"bank_physical":bank,"bank_without_water_source":off,"witness_false_positive":flagged},indent=2))
    return 0
if __name__=="__main__":raise SystemExit(main())
