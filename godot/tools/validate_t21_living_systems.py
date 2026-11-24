#!/usr/bin/env python3
"""T21 authored-fiction schema validation; not a real historical/physical verification."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GAME = ROOT / "godot"
DATA = GAME / "data" / "t21_living_systems.json"


def check() -> None:
    data = json.loads(DATA.read_text(encoding="utf-8"))
    assert data["schema"] == "alchul.t21.living_systems.v1"
    assert data["status"] == "PROVISIONAL_FICTIONAL_SETTLEMENT_NOT_HISTORY_OR_APPROVED_ANATOMY"
    assert data["era"] == "mature_surface_before_long_descent"
    assert data["source_scene"] == "res://assets/m2/ALC_M2_RIVER_STATION_v001.glb"
    assert data["source_model"] == "res://scenes/m11_t17_physical_sensing_lab.tscn"
    assert data["max_watches"] == 8
    assert set(data["initial_state"]) >= {
        "pressure", "integrity", "clarity", "nursery", "gas", "food",
        "materials", "record", "route_safe"}
    assert len(data["places"]) == 4
    assert {x["id"] for x in data["places"]} == {"bank", "nursery", "culture", "workshop"}
    assert len(data["actions"]) == 8
    assert {x["id"] for x in data["actions"]} == {
        "survey", "brace", "relief", "screen", "vent", "warm", "store", "route"}
    assert data["controls"]["reset"] == "R"
    actions = {x["id"]: x for x in data["actions"]}
    for key, row in actions.items():
        assert row["description"] and row["site"] in {"bank","nursery","culture","workshop"}
        assert row["max_uses"] >= 1
        assert row["effects"] or row.get("set_true")
        assert all(t in data["initial_state"] for t in row["effects"])
    assert actions["brace"]["effects"]["pressure"] > 0
    assert actions["relief"]["effects"]["pressure"] < 0 and actions["relief"]["effects"]["food"] < 0
    assert actions["screen"]["effects"]["clarity"] > 0 and actions["screen"]["effects"]["food"] < 0
    assert actions["vent"]["effects"]["gas"] < 0 and actions["vent"]["effects"]["nursery"] < 0
    assert actions["warm"]["effects"]["nursery"] > 0 and actions["warm"]["effects"]["gas"] > 0
    assert actions["route"]["set_true"] == ["route_safe"]
    assert "not" in data["reference_scope"].lower()
    assert "Alchul does not" in data["contact_scope"]
    assert "dimensionless" in data["scientific_scope"]
    required = [
        "MEDIA/T21_LIVING_CIVILIZATION_FIRST_SYSTEMS.md",
        "WRITING/CHRONICLE_03_THE_SOUND_IN_THE_SUPPORT.md",
        "godot/scripts/t21_living_systems_scene.gd",
        "godot/scenes/t21_living_systems_scene.tscn",
        "godot/tests/t21_living_systems_smoke.gd",
    ]
    assert all((ROOT / p).is_file() for p in required)
    print("ALCHUL T21 CONTRACT PASS — 4 linked sites, 8 causal choices, 8 watches; fictional status preserved")


if __name__ == "__main__":
    check()
